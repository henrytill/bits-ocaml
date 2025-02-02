open Bits.Hlist

let x = HCons (3, HCons ("str", HCons (35.0, HNil)))
let a = get Z x
let b = get (S Z) x
let c = get (S (S Z)) x

let () =
  print_endline (string_of_int a);
  print_endline b;
  print_endline (string_of_float c)
