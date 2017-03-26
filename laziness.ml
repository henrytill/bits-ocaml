(** Lazy datatypes inspired by
    {{: https://existentialtype.wordpress.com/2011/04/24/the-real-point-of-laziness/ }
    {i The Point of Laziness}}, by Bob Harper
  *)

module type PROCESS = sig
  (** Represents a function that, when applied, generates a value of some type *)
  type 'a t = unit -> 'a option

  (** Represents the UNIX standard input *)
  val stdin : char t

  (** Represents a random number generator *)
  val random : int t
end


module type STREAM = sig
  type 'a t

  (** An ephemeral process of creation *)
  type 'a process

  (** The type of values that arise when the stream is exposed *)
  type 'a front =
    | Nil
    | Cons of 'a * 'a t

  (** Exposes the stream *)
  val expose : 'a t -> 'a front

  (** Creates a persistent stream from an ephemeral process of creation for its elements *)
  val memo : 'a process -> 'a t

  (* Creates recursive networks of streams *)
  (* val fix : ('a t -> 'a t) -> 'a t *)
end

module type STREAM_FUNCTOR = functor (P : PROCESS) -> STREAM with type 'a process := 'a P.t

module Process : PROCESS = struct
  type 'a t = unit -> 'a option
  let stdin ()  = Some (input_char stdin)
  let random () =  Some (Random.int 127)
end

module MakeStream : STREAM_FUNCTOR = functor (P : PROCESS) -> struct

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

module ProcessStream = MakeStream(Process)

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
