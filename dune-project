(lang dune 3.17)

(name bits)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name bits)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
  (ocaml
   (> 5.0.0))
  (delimcc_of_fxhandler
   (>= 0.1))
  (sqlite3
   (>= 5.3.0)))
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
