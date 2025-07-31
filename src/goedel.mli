type ('a, 'b) hom
type nat

val id : ('a, 'a) hom
val compose : ('a, 'b) hom -> ('b, 'c) hom -> ('a, 'c) hom
val unit : ('a, unit) hom
val pair : ('a, 'b) hom -> ('a, 'c) hom -> ('a, 'b * 'c) hom
val fst : ('a * 'b, 'a) hom
val snd : ('a * 'b, 'b) hom
val curry : ('a * 'b, 'c) hom -> ('a, 'b -> 'c) hom
val eval : (('a -> 'b) * 'a, 'b) hom
val zero : (unit, nat) hom
val succ : (nat, nat) hom
val iter : ('a, 'b) hom -> ('a * 'b, 'b) hom -> ('a * nat, 'b) hom
val run : (unit, nat) hom -> int
