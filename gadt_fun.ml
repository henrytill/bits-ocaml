(** natural numbers *)
type zero = Zero

and 'a succ = Succ of 'a

(** length-indexed vector *)
type (_, _) vec =
  | Nil : ('a, zero) vec
  | Cons : 'a * ('a, 'n) vec -> ('a, 'n succ) vec

(** map over a length-indexed vector, preserving length *)
let rec map : type a b n. (a -> b) -> (a, n) vec -> (b, n) vec =
  fun f -> function
  | Nil -> Nil
  | Cons (a, l) -> Cons (f a, map f l)

(** head is exhaustive on vectors of length at least 1 *)
let head : type a n. (a, n succ) vec -> a = function
  | Cons (a, _) -> a

(** equality witness *)
type (_, _) eq = Refl : ('a, 'a) eq

(** type-safe cast *)
let cast : type a b. (a, b) eq -> a -> b = function
  | Refl -> fun x -> x
