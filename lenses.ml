(** Inspired by:
    Darin Morrison's
    {{: https://github.com/freebroccolo/ocaml-optics}{i ocaml-optics} library}
*)

class type ['s, 't, 'a, 'b] lensp = object
  method get: 's -> 'a
  method set: 'b -> 's -> 't
end

type ('s, 'a) lens = ('s, 's, 'a, 'a) lensp

let compose this other = object
  method get s   = other#get (this#get s)
  method set d s = this#set (other#set d (this#get s)) s
end

let get s l = l#get s
let set l b = l#set b

(* Some data *)

type address =
  { _road     : string
  ; _city     : string
  ; _postcode : string
  }

type person =
  { _name   : string
  ; _addr   : address
  ; _salary : int
  }

let fred =
  { _name = "Fred"
  ; _addr = { _road = "26 Bumblebee Ln"
            ; _city = "Manassis"
            ; _postcode = "02134"
            }
  ; _salary = 100
  }

(* Some lenses for the data *)

let name : (person, string) lens = object
  method get = fun x   -> x._name
  method set = fun v x -> { x with _name = v }
end

let addr : (person, address) lens = object
  method get = fun x   -> x._addr
  method set = fun v x -> { x with _addr = v }
end

let postcode : (address, string) lens = object
  method get = fun x   -> x._postcode
  method set = fun v x -> { x with _postcode = v}
end

(* Some examples *)

let set_postcode = set (compose addr postcode)

let test1 = get fred (compose addr postcode)

let new_fred = set_postcode "555555" fred
