#!/usr/bin/env python3
"""Drive tests/pty/winch_demo.salam through a pty and assert it gets a ResizeEvent.

Not part of tests/run.sh: that harness feeds /dev/null on stdin and compares
stdout byte for byte, so it cannot own a terminal. Run `make test-pty`.

Usage: python3 tests/pty/winch_test.py build/tests/pty/winch_demo
"""

import fcntl
import os
import pty
import select
import struct
import subprocess
import sys
import termios
import time

READY_TIMEOUT = 10.0
RESIZE_TIMEOUT = 10.0


def set_size(fd, cols, rows):
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))


def read_until_line(master, proc, want, timeout):
    """Read master until a newline-terminated line equals want.

    Returns (found, output). A deadline, never a sleep: a regression fails the
    check instead of hanging it. Escape sequences carry no newline, so they
    stay out of the compared line.
    """
    out = b""
    end = time.monotonic() + timeout
    while True:
        for line in out.split(b"\n"):
            if line.strip() == want:
                return True, out
        left = end - time.monotonic()
        if left <= 0:
            return False, out
        if proc.poll() is not None and not select.select([master], [], [], 0)[0]:
            return False, out
        if select.select([master], [], [], min(left, 0.1))[0]:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                return False, out
            if not chunk:
                return False, out
            out += chunk


def main():
    if len(sys.argv) != 2:
        print("usage: winch_test.py <path to winch_demo binary>")
        return 2
    binary = sys.argv[1]

    master, slave = pty.openpty()
    # The size must be set before the child starts: start() reads it once.
    set_size(slave, 100, 30)

    def child_setup():
        # A new session plus TIOCSCTTY makes the pty the child's controlling
        # terminal, so a winsize change delivers SIGWINCH to its group.
        os.setsid()
        fcntl.ioctl(0, termios.TIOCSCTTY, 0)

    proc = subprocess.Popen(
        [binary],
        stdin=slave,
        stdout=slave,
        stderr=slave,
        preexec_fn=child_setup,
    )
    try:
        ok, out = read_until_line(master, proc, b"ready", READY_TIMEOUT)
        if not ok:
            print("FAIL: no `ready` within %ss" % READY_TIMEOUT)
            print(repr(out))
            return 1

        set_size(slave, 60, 15)
        ok, out = read_until_line(master, proc, b"resize 60 15", RESIZE_TIMEOUT)
        if not ok:
            print("FAIL: no `resize 60 15` within %ss" % RESIZE_TIMEOUT)
            print(repr(out))
            return 1

        print("PASS: resize 60 15")
        return 0
    finally:
        if proc.poll() is None:
            proc.kill()
        proc.wait()
        os.close(master)
        os.close(slave)


if __name__ == "__main__":
    sys.exit(main())
