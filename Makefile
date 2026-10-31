# basalam developer tasks. Run `make help` for the list.

SALAM ?= salam
BUILD := build
FLAGS := --log-level=warn --backend=llvm
SOURCES := basalam tests $(wildcard examples)

# Salam links with the host toolchain on macOS. Pin the deployment target to
# the running OS so the linker does not warn about mismatched SDK versions.
ifeq ($(shell uname -s),Darwin)
export MACOSX_DEPLOYMENT_TARGET ?= $(shell sw_vers -productVersion)
endif

EXAMPLES := $(patsubst examples/%.salam,$(BUILD)/examples/%,$(wildcard examples/*.salam))

.PHONY: help build test test-llvm test-pty example examples docs-examples run format check release-check docs docs-check docs-format-check clean

help:
	@echo "make build     type-check and compile every file in basalam/ with --backend=llvm"
	@echo "make test      build and run the test suite (tests/run.sh)"
	@echo "make test-llvm build and run the test suite with --backend=llvm"
	@echo "make test-pty  build tests/pty/winch_demo and drive it through a pty (needs a terminal; not in check)"
	@echo "make examples  build every program in examples/ into build/examples/ with --backend=llvm"
	@echo "make docs-examples type-check every complete example in the docs"
	@echo "make run       build and run the demo example"
	@echo "make format    format all Salam sources in place"
	@echo "make check     format check, strict build, strict examples, tests, doc examples (the library gate; CI also runs test-llvm and the docs job)"
	@echo "make release-check  check release metadata: Version, changelog headings and links (see RELEASING.md)"
	@echo "make docs      preview the documentation site (needs: npm i -g mint@4.2.988)"
	@echo "make docs-check validate the documentation site and its links"
	@echo "make docs-format-check  fail if mint format would rewrite a docs page"
	@echo "make clean     remove build output"

# `salam obj basalam/basalam.salam` does not load the package's sibling
# files, so it would miss errors in them. Compiling a tiny consumer that
# includes the package does type-check every file, used or not.
build:
	@mkdir -p $(BUILD)
	@printf 'include "../basalam/basalam.salam"\n\nfunc main:\n    println basalam.Version\nend\n' > $(BUILD)/check.salam
	$(SALAM) build $(BUILD)/check.salam --output=$(BUILD)/check $(FLAGS)

test:
	SALAM=$(SALAM) sh tests/run.sh

test-llvm:
	SALAM=$(SALAM) SALAM_BACKEND=llvm sh tests/run.sh

# The repo's only pty test: it owns a terminal, so it cannot live in
# tests/run.sh. Kept out of `check` on purpose (it is new and unproven in CI).
test-pty: $(BUILD)/tests/pty/winch_demo
	python3 tests/pty/winch_test.py $(BUILD)/tests/pty/winch_demo

$(BUILD)/tests/pty/winch_demo: tests/pty/winch_demo.salam $(wildcard basalam/*.salam)
	@mkdir -p $(BUILD)/tests/pty
	$(SALAM) build $< --output=$@ $(FLAGS)

examples: $(EXAMPLES)
example: examples

docs-examples:
	SALAM=$(SALAM) sh tests/doc-examples.sh

$(BUILD)/examples/%: examples/%.salam $(wildcard basalam/*.salam)
	@mkdir -p $(BUILD)/examples
	$(SALAM) build $< --output=$@ $(FLAGS)

run: $(BUILD)/examples/demo
	./$(BUILD)/examples/demo

format:
	$(SALAM) format $(SOURCES)

check:
	$(SALAM) format --check $(SOURCES)
	$(MAKE) build examples test
	$(MAKE) docs-examples

# The release policy gate: no tag, no network, no build. `make check` stays
# independent of it so an ordinary pull request never needs a release.
release-check:
	sh tests/release-check.sh check

docs:
	mint dev

docs-check:
	mint validate
	mint broken-links --check-anchors

docs-format-check:
	mint format
	git diff --exit-code -- '*.mdx' 'docs.json'

clean:
	rm -rf $(BUILD) .salam-build
