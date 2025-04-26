(lang dune 3.17)

(subst disabled)

(using mdx 0.4)

(name bits)

(generate_opam_files true)

(source
 (github henrytill/bits-ocaml))

(authors "Henry Till <henrytill@gmail.com>")

(package
 (name bits)
 (synopsis "Some random bits of code")
 (description "Some random bits of code")
 (allow_empty)
 (depends
  (ocaml
   (>= 5.0.0))
  (delimcc_of_fxhandler
   (>= 0.1))
  dune
  (mdx
   (and
    :with-test
    (>= 2.5.0)))
  (sqlite3
   (and
    :with-test
    (>= 5.3.0)))))
