.SUFFIXES:

PREFIX = /usr/local

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
	landins_knot \
	readline \
	sqlite_test

STATIC_BIN =\
	delimcc_test \
	sqlite_test

all: $(BIN)

delimcc_top: delimcc_tutorial.ml
	$(OCAMLFIND) $(OCAMLMKTOP) -o $@ -linkpkg -package delimcc $<

delimcc_test: OCAMLOPTFLAGS += -w -58
delimcc_test: delimcc_tutorial.ml delimcc_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ -linkpkg -package delimcc $^

readline: OCAMLOPTFLAGS += -afl-instrument
readline: readline.ml

sqlite_test: sqlite_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ -linkpkg -package sqlite3 $^

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

.PHONY: install
install: delimcc_test sqlite_test
	mkdir -p $(PREFIX)/bin
	install -m 755 delimcc_test $(PREFIX)/bin/delimcc_test
	install -m 755 sqlite_test $(PREFIX)/bin/sqlite_test

.PHONY: clean
clean:
	rm -rf input output
	rm -f $(BIN)
	rm -f *.cm[iox]
	rm -f *.o

.PHONY: static
static: clean
	sh build-static-exe.sh $(STATIC_BIN)

FORCE:
