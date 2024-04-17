(* Notes:
   https://github.com/ocaml/ocaml/pull/8900#issuecomment-539530661
   https://okmij.org/ftp/ML/#hlist *)

type _ t =
  | HNil : unit t
  | HCons : 'a * 'b t -> ('a * 'b) t

type (_, _) index =
  | Z : ('a * 'xs, 'a) index
  | S : ('xs, 'a) index -> ('x * 'xs, 'a) index

let rec get : type a b. (a, b) index -> a t -> b =
  fun index l ->
  match (index, l) with
  | Z, HCons (h, _) -> h
  | S e, HCons (_, t) -> get e t
  | _, HNil -> .

let rec length : type tys. tys t -> int = function
  | HNil -> 0
  | HCons (_, t) -> 1 + length t

let head = function
  | HCons (h, _) -> h

let tail = function
  | HCons (_, t) -> t
