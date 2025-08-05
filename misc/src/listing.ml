module type MONAD = sig
  type 'a t

  val return : 'a -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module List_monad = struct
  type 'a t = 'a list

  let return a = [ a ]
  let bind m f = List.flatten (List.map f m)
end

module type Applicative_syntax = sig
  type 'a t

  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
end

module type Monad_syntax = sig
  include Applicative_syntax

  val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
  val ( and* ) : 'a t -> 'b t -> ('a * 'b) t
end

module Make_syntax (M : MONAD) : Monad_syntax with type 'a t = 'a M.t = struct
  type 'a t = 'a M.t

  let ( let+ ) m f = M.bind m (fun a -> M.return (f a))
  let ( and+ ) ma mb = M.bind ma (fun a -> M.bind mb (fun b -> M.return (a, b)))
  let ( let* ) = M.bind
  let ( and* ) = ( and+ )
end

include Make_syntax (List_monad)

let return = List_monad.return
