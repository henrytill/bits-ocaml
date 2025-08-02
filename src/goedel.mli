(** {{:https://semantic-domain.blogspot.com/2012/12/total-functional-programming-in-partial.html}
     Total Functional Programming in a Partial Impure Language}

    see {!Ppx_goedel}*)

type ('a, 'b) hom
type nat
type one
type ('a, 'b) pair
type ('a, 'b) arr

val id : ('a, 'a) hom
val compose : ('a, 'b) hom -> ('b, 'c) hom -> ('a, 'c) hom
val unit : ('a, one) hom
val pair : ('a, 'b) hom -> ('a, 'c) hom -> ('a, ('b, 'c) pair) hom
val fst : (('a, 'b) pair, 'a) hom
val snd : (('a, 'b) pair, 'b) hom
val curry : (('a, 'b) pair, 'c) hom -> ('a, ('b, 'c) arr) hom
val eval : ((('a, 'b) arr, 'a) pair, 'b) hom
val zero : (one, nat) hom
val succ : (nat, nat) hom
val iter : ('a, 'b) hom -> (('a, 'b) pair, 'b) hom -> (('a, nat) pair, 'b) hom
val run : (one, nat) hom -> int
