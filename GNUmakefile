.SUFFIXES:

FUZZ = afl-fuzz
OCAMLC = ocamlc
OCAMLOPT = ocamlopt
OCAMLDEP = ocamldep
OCAMLFIND = ocamlfind

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

OCAMLCFLAGS = -bin-annot -g
OCAMLOPTFLAGS = -bin-annot -g
OCAMLFINDFLAGS =

INCLUDES =
ALL_OCAMLCFLAGS = $(INCLUDES) $(OCAMLCFLAGS)
ALL_OCAMLOPTFLAGS = $(INCLUDES) $(OCAMLOPTFLAGS)

bindir = /bin
prefix = /usr/local
DESTDIR = $(prefix)

SRC_CMOS =
SRC_CMOS += src/calc.cmo
SRC_CMOS += src/defunctionalization.cmo
SRC_CMOS += src/delimcc_tutorial.cmo
SRC_CMOS += src/gadt_fun.cmo
SRC_CMOS += src/hlist.cmo
SRC_CMOS += src/landins_knot.cmo
SRC_CMOS += src/lenses.cmo
SRC_CMOS += src/listing.cmo
SRC_CMOS += src/safe_array.cmo
SRC_CMOS += src/unfold.cmo
SRC_CMOS += src/views.cmo

SRC_CMXS = $(SRC_CMOS:.cmo=.cmx)

SRC_MLIS = src/delimcc_tutorial.mli
SRC_MLS = $(SRC_CMOS:.cmo=.ml)

TESTS =
TESTS += test/delimcc_test.byte
TESTS += test/hlist_test.byte
TESTS += test/landins_knot_test.byte
TESTS += test/lenses_test.byte
TESTS += test/readline_test.byte
TESTS += test/sqlite_test.byte
TESTS += test/views_test.byte

TESTS_OPT = $(TESTS:.byte=.exe)

INCLUDES = -I src

-include config.mk

.PHONY: all
all: byte opt

.PHONY: byte
byte: $(SRC_CMOS) $(TESTS)

.PHONY: opt
opt: $(SRC_CMXS) $(TESTS_OPT)

.SUFFIXES: .mli .cmi
.mli.cmi:
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -c $(OCAMLFINDFLAGS) $<

.SUFFIXES: .ml .cmo
.ml.cmo:
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -c $(OCAMLFINDFLAGS) $<

.SUFFIXES: .ml .cmx
.ml.cmx:
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -c $(OCAMLFINDFLAGS) $<

src/delimcc_tutorial.cmo: OCAMLFINDFLAGS += -linkpkg -package delimcc
src/delimcc_tutorial.cmx: OCAMLFINDFLAGS += -linkpkg -package delimcc
src/delimcc_tutorial.cmx: OCAMLOPTFLAGS += -w -58

# test

test/delimcc_test.%: OCAMLFINDFLAGS += -linkpkg -package delimcc

test/delimcc_test.byte: src/delimcc_tutorial.cmo test/delimcc_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/delimcc_test.exe: src/delimcc_tutorial.cmx test/delimcc_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/hlist_test.byte: src/hlist.cmo test/hlist_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/hlist_test.exe: src/hlist.cmx test/hlist_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/landins_knot_test.byte: src/landins_knot.cmo test/landins_knot_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/landins_knot_test.exe: src/landins_knot.cmx test/landins_knot_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/lenses_test.byte: src/lenses.cmo test/lenses_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/lenses_test.exe: src/lenses.cmx test/lenses_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/readline_test.byte: test/readline_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/readline_test.exe: OCAMLOPTFLAGS += -afl-instrument
test/readline_test.exe: test/readline_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/sqlite_test.%: OCAMLFINDFLAGS += -linkpkg -package sqlite3

test/sqlite_test.byte: test/sqlite_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/sqlite_test.exe: test/sqlite_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/views_test.byte: src/views.cmo test/views_test.ml
	$(OCAMLFIND) $(OCAMLC) $(ALL_OCAMLCFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

test/views_test.exe: src/views.cmx test/views_test.ml
	$(OCAMLFIND) $(OCAMLOPT) $(ALL_OCAMLOPTFLAGS) -o $@ $(OCAMLFINDFLAGS) $^

input:
	mkdir -p $@

input/testcase: | input
	echo asdf > $@

.PHONY: fuzz
fuzz: test/readline_test.exe input/testcase
	$(FUZZ) -m none -i input -o output ./$<

$(DESTDIR)$(bindir):
	mkdir -p $@

.PHONY: install
install: $(TESTS_OPT) | $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) test/delimcc_test.exe $(DESTDIR)$(bindir)/delimcc_test.exe
	$(INSTALL_PROGRAM) test/hlist_test.exe $(DESTDIR)$(bindir)/hlist_test.exe
	$(INSTALL_PROGRAM) test/landins_knot_test.exe $(DESTDIR)$(bindir)/landins_knot_test.exe
	$(INSTALL_PROGRAM) test/sqlite_test.exe $(DESTDIR)$(bindir)/sqlite_test.exe
	$(INSTALL_PROGRAM) test/views_test.exe $(DESTDIR)$(bindir)/views_test.exe

.PHONY: clean
clean:
	rm -f $(SRC_CMOS) $(SRC_CMOS:.cmo=.cmi)
	rm -f $(SRC_CMOS:.cmo=.cmt) $(SRC_MLIS:.mli=.cmti)
	rm -f $(SRC_CMXS) $(SRC_CMXS:.cmx=.o)
	rm -f $(TESTS) $(TESTS_OPT)
	rm -f $(TESTS:.byte=.cmi) $(TESTS:.byte=.cmo) $(TESTS:.byte=.cmt)
	rm -f $(TESTS_OPT:.exe=.cmx) $(TESTS_OPT:.exe=.o)

.depend: GNUmakefile $(SRC_MLIS) $(SRC_MLS)
	$(OCAMLDEP) $(INCLUDES) $(SRC_MLIS) $(SRC_MLS) > $@

include .depend
