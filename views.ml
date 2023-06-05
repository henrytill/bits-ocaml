module type SHOW = sig
  type t
  val show : t -> string
end

module type VIEW = sig
  type t
  type 'a view
  val into : t view -> t
  val out : t -> t view
end

module type NAT = sig
  type t
  type 'a view =
    | Zero
    | Succ of 'a
  val to_int : t -> int
  val of_int : int -> t
  val add : t -> t -> t
  val mul : t -> t -> t
  include SHOW with type t := t
  include VIEW with type t := t and type 'a view := 'a view
end

module Nat : NAT = struct
  type t = int

  type 'a view =
    | Zero
    | Succ of 'a

  let into = function
    | Zero   -> 0
    | Succ n -> n + 1

  let out = function
    | 0 -> Zero
    | n -> Succ (n - 1)

  let show = string_of_int

  let to_int x = x

  let of_int x = x

  let add x y = x + y

  let mul x y = x * y
end

module type TREE = sig
  type t
  type 'a view =
    | Tip
    | Leaf of int
    | Fork of 'a * 'a
  include VIEW with type t := t and type 'a view := 'a view
end

module Tree : TREE = struct
  type 'a view =
    | Tip
    | Leaf of int
    | Fork of 'a * 'a

  type t = In of t view

  let into = function
    | Tip         -> In Tip
    | Leaf x      -> In (Leaf x)
    | Fork (x, y) -> In (Fork (x, y))

  let out (In x) = x
end

module Examples = struct
  let zero = Nat.(into Zero)
  let succ n = Nat.(into (Succ n))

  let seven = succ (succ (succ (succ (succ (succ (succ zero))))))

  let rec fact m =
    let open Nat in
    let one = succ zero in
    match out m with
    | Zero   -> one
    | Succ n -> mul m (fact n)

  let rec fib x =
    let open Nat in
    match out x with
    | Zero   -> zero
    | Succ n -> (
        match out n with
        | Zero   -> succ zero
        | Succ n -> add (fib n) (fib (succ n)))


  let tip = Tree.(into Tip)
  let leaf x = Tree.(into (Leaf x))
  let fork x y = Tree.(into (Fork (x, y)))

  let tree = fork (fork (leaf 1) (leaf 2)) (fork (leaf 3) tip)
end
