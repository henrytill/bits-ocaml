(** Inspired by: Darin Morrison's
    {{:https://github.com/freebroccolo/ocaml-optics} {i ocaml-optics} library} *)

class type ['s, 't, 'a, 'b] lens = object
  method get : 's -> 'a
  method set : 'b -> 's -> 't
end

type ('s, 'a) lens' = ('s, 's, 'a, 'a) lens

let compose this that =
  object
    method get s = that#get (this#get s)
    method set d s = this#set (that#set d (this#get s)) s
  end

let get s l = l#get s
let set l b = l#set b
