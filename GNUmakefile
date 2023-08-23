.SUFFIXES:

FUZZ = afl-fuzz
OCAMLC = ocamlc
OCAMLFIND = ocamlfind
OCAMLMKTOP = ocamlmktop
OCAMLOPT = ocamlopt
OPAM = opam

OCAMLFLAGS =
OCAMLOPTFLAGS =

-include config.mk

BIN =\
	delimcc_test \
	delimcc_top \
	readline

all: $(BIN)

delimcc_top: delimcc_tutorial.ml
	$(OCAMLFIND) $(OCAMLMKTOP) -o $@ -linkpkg -package delimcc $<

delimcc_test: OCAMLOPTFLAGS += -w -58
delimcc_test: delimcc_tutorial.ml delimcc_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ -linkpkg -package delimcc $^

readline: OCAMLOPTFLAGS += -afl-instrument
readline: readline.ml

.SUFFIXES: .ml
.ml:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ $<

input:
	mkdir -p $@

input/testcase: input
	echo asdf > $@

.PHONY: fuzz
fuzz: readline input/testcase
	$(FUZZ) -m none -i input -o output ./readline

.PHONY: clean
clean:
	rm -f $(BIN)
	rm -f *.cm[iox]
	rm -f *.o

ocaml-bits.export: FORCE
	$(OPAM) switch export $@

FORCE:
