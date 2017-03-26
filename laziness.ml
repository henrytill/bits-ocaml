(* https://existentialtype.wordpress.com/2011/04/24/the-real-point-of-laziness/ *)

module type PROCESS = sig
  type 'a t = unit -> 'a option
  val stdin : char t
  val random : int t
end

module type STREAM = functor (Process : PROCESS) -> sig
  type 'a t
  type 'a front =
    | Nil
    | Cons of 'a * 'a t
  val expose : 'a t -> 'a front
  val memo : 'a Process.t -> 'a t
  val fix : ('a t -> 'a t) -> 'a t
end
