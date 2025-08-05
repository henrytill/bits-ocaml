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

  let pp fmt =
    let open Format in
    let wrap flag fmt x pp =
      if flag then
        fprintf fmt "@[<hv 1>(%a)@]" pp x
      else
        pp fmt x
    in
    let rec go flag fmt fm =
      wrap flag fmt fm @@ fun fmt -> function
      | Var x -> fprintf fmt "Var %S" x
      | Const m -> fprintf fmt "Const %d" m
      | Add (a, b) -> fprintf fmt "@[<hv 1>Add@;<1 0>(%a,@, %a)@]" unwrapped a unwrapped b
      | Mul (a, b) -> fprintf fmt "@[<hv 1>Mul@;<1 0>(%a,@, %a)@]" unwrapped a unwrapped b
    and wrapped fmt = go true fmt
    and unwrapped fmt = go false fmt in
    fprintf fmt "@[<hv 1>%a@]" wrapped

  let show = Format.asprintf "%a" pp
  let to_string = show
  let const i = Const i
  let var s = Var s
  let ( + ) x y = Add (x, y)
  let ( * ) x y = Mul (x, y)
end
