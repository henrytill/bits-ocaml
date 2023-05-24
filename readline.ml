(* Adapted from: https://v2.ocaml.org/manual/afl-fuzz.html *)

let () =
  let s = read_line () in
  let arr = Array.init (String.length s) (String.get s) in
  match Array.to_list arr with
  | ['s'; 'e'; 'c'; 'r'; 'e'; 't'; ' '; 'c'; 'o'; 'd'; 'e'] -> failwith "uh oh"
  | _ -> ()
