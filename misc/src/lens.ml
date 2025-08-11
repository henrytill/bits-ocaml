(** Inspired by: Darin Morrison's
    {{:https://github.com/freebroccolo/ocaml-optics} {i ocaml-optics} library} *)

class type ['s, 'a] getter = object
  method get : 's -> 'a
end

class type ['s, 't, 'b] setter = object
  method set : 'b -> 's -> 't
end

class type ['s, 't, 'a, 'b] lens = object
  inherit ['s, 'a] getter
  inherit ['s, 't, 'b] setter
end

type ('s, 'a) lens' = ('s, 's, 'a, 'a) lens

let compose this that =
  object
    method get s = that#get (this#get s)
    method set d s = this#set (that#set d (this#get s)) s
  end

let view (l : < get : 's -> 'a ; .. >) s = l#get s
let get = view
let set (l : < set : 'b -> 's -> 't ; .. >) b s = l#set b s
let over (l : < get : 's -> 'a ; set : 'b -> 's -> 't ; .. >) f s = l#set (f (l#get s)) s
