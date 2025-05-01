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
  | Cons (x, xs) -> Cons (f x, map f xs)

(** head is exhaustive on vectors of length at least 1 *)
let head : type a n. (a, n succ) vec -> a = function
  | Cons (x, _) -> x

(** last is exhaustive on vectors of length at least 1 *)
let rec last : type a n. (a, n succ) vec -> a = function
  | Cons (x, Nil) -> x
  | Cons (_, (Cons (_, _) as xs)) -> last xs

(** equality witness *)
type (_, _) eq = Refl : ('a, 'a) eq

(** type-safe cast *)
let cast : type a b. (a, b) eq -> a -> b = fun Refl x -> x
