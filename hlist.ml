type hnil

type _ hlist =
  | HNil  : hnil hlist
  | HCons : 'h * 't hlist -> ('h * 't) hlist

type (_, _) elem =
  | EZ : ('x * 'xs, 'x) elem
  | ES : ('xs, 'x) elem -> ('y * 'xs, 'x) elem

let rec get : type tys ty. (tys, ty) elem -> tys hlist -> ty =
  fun elem l -> match elem, l with
    | EZ  , HCons (h, _) -> h
    | ES e, HCons (_, t) -> get e t
    | _   , HNil         -> .

let rec length : type tys. tys hlist -> int = function
  | HNil         -> 0
  | HCons (_, t) -> 1 + length t

let hhead = function
  | HCons (h, _) -> h

let htail = function
  | HCons (_, t) -> t
