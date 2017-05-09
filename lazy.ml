module type LAZY = sig
  type 'a t
  val delay : (unit -> 'a) -> 'a t
  val force : 'a t -> 'a
end

module Lazy : LAZY = struct
  type 'a t = Thunk of (unit -> 'a)
  let delay f = Thunk f
  let force (Thunk t) = t ()
end
