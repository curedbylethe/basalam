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

.PHONY: help build test test-llvm example examples docs-examples run format check docs docs-check clean

help:
	@echo "make build     type-check and compile every file in basalam/ with --backend=llvm"
	@echo "make test      build and run the test suite (tests/run.sh)"
	@echo "make test-llvm build and run the test suite with --backend=llvm"
	@echo "make examples  build every program in examples/ into build/examples/ with --backend=llvm"
	@echo "make docs-examples type-check every complete example in the docs"
	@echo "make run       build and run the demo example"
	@echo "make format    format all Salam sources in place"
	@echo "make check     format check, strict build, strict examples, tests, doc examples (the library gate; CI also runs test-llvm and the docs job)"
	@echo "make docs      preview the documentation site (needs: npm i -g mint)"
	@echo "make docs-check validate the documentation site and its links"
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

docs:
	mint dev

docs-check:
	mint validate
	mint broken-links --check-anchors

clean:
	rm -rf $(BUILD) .salam-build
