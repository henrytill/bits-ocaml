.SUFFIXES:

BIN =\
	readline

all: $(BIN)

readline: readline.ml

input:
	mkdir -p $@

input/testcase: input
	echo asdf > input/testcase

.SUFFIXES: .ml
.ml:
	ocamlopt -afl-instrument $^ -o $@

.PHONY: fuzz
fuzz: readline input/testcase
	afl-fuzz -m none -i input -o output ./readline

.PHONY: clean
clean:
	rm -f $(BIN)
