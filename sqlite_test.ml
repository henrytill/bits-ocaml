let () =
  let version = Sqlite3.sqlite_version () in
  print_endline (string_of_int version)
