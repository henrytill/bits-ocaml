module Intro : sig
  type t

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val to_string : t -> string
  val const : int -> t
  val var : string -> t
  val ( + ) : t -> t -> t
  val ( * ) : t -> t -> t
end = struct
  type t =
    | Var of string
    | Const of int
    | Add of t * t
    | Mul of t * t

  let rec equal x y =
    match (x, y) with
    | Var a, Var b -> String.equal a b
    | Const a, Const b -> Int.equal a b
    | Add (a1, a2), Add (b1, b2) -> equal a1 b1 && equal a2 b2
    | Mul (a1, a2), Mul (b1, b2) -> equal a1 b1 && equal a2 b2
    | _, _ -> false

  let rec pp fmt x =
    let open Format in
    match x with
    | Var a -> fprintf fmt "@[Var %S@]" a
    | Const a -> fprintf fmt "@[Const %d@]" a
    | Add (a, b) -> fprintf fmt "@[Add (%a, %a)@]" pp a pp b
    | Mul (a, b) -> fprintf fmt "@[Mul (%a, %a)@]" pp a pp b

  let show = Format.asprintf "%a" pp
  let to_string = show
  let const i = Const i
  let var s = Var s
  let ( + ) x y = Add (x, y)
  let ( * ) x y = Mul (x, y)
end
