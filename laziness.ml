(* https://existentialtype.wordpress.com/2011/04/24/the-real-point-of-laziness/ *)

module type PROCESS = sig
  type 'a t = unit -> 'a option
  (** Represents a function that, when applied, generates a value of some
      type *)

  val stdin : char t
  (** Represents the UNIX standard input *)

  val random : int t
  (** Represents a random number generator *)
end

module Process : PROCESS = struct
  type 'a t = unit -> 'a option
  let stdin ()  = Some (input_char stdin)
  let random () =  Some (Random.int 127)
end

module type STREAM_FUNCTOR = functor (P : PROCESS) -> sig
  type 'a t

  type 'a front =
    | Nil
    | Cons of 'a * 'a t
    (** The type of values that arise when the stream is exposed *)

  val expose : 'a t -> 'a front
  (** Exposes the stream *)

  val memo : 'a P.t -> 'a t
  (** Creates a persistent stream from an ephemeral process of creation for its
      elements *)

  (* val fix : ('a t -> 'a t) -> 'a t *)
  (** Creates recursive networks of streams *)
end

module Stream : STREAM_FUNCTOR = functor (P : PROCESS) -> struct
  type 'a t = Stream of (unit -> 'a front)

  and 'a front =
    | Nil
    | Cons of 'a * 'a t

  let expose (Stream d) = d ()

  let rec memo process =
    match process () with
    | Some v -> Stream (fun () -> Cons (v, memo process))
    | None   -> Stream (fun () -> Nil)
end

module ProcessStream = Stream (Process)

exception End

let next_random : unit -> int =
  let process = Process.random in
  let module P = ProcessStream in
  let seed = ref (P.memo process) in
  let next () =
    match P.expose !seed with
    | P.Cons (curr, next) -> seed := next; curr
    | P.Nil               -> raise End
  in
  next
