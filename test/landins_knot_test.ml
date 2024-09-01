let () =
  let x = Landins_knot.factorial 9 in
  assert (x = 362880);
  print_int x;
  print_newline ()
