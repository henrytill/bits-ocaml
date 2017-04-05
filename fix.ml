(* https://sympa.inria.fr/sympa/arc/caml-list/2012-10/msg00110.html *)

(* There is a difficulty here because OCaml doesn't support higher-ranked
   type variables. In this declaration, f is not a "type", but a "type
   operator" [kind * -> *]. To do the same in OCaml, you can use a
   functor (not a Haskell functor; in OCaml the word "functor" denotes a
   higher-order module that may depend on other modules/functors);
   functors are higher-kinded. *)

module type ParamType = sig
  type ('a, 'b) t
end

module Fix (M : ParamType) = struct
  type 'b fix = In of ('b fix, 'b) M.t
end

module List = struct
  module Param = struct
    type ('a, 'b) t = Nil | Cons of 'b * 'a
  end
  include Fix(Param)
end

open List.Param
open List

let rec to_usual_list =
  function
  | In Nil -> []
  | In (Cons (x, xs)) -> x :: to_usual_list xs

(* The good news is that OCaml also supports equi-recursive rather than
   iso-recursive types, which allows you to remove the "In" wrapper at
   each recursion layer. For that you must compile the incumbing module
   (and all the modules that also see this equirecursion through an
   interface) with the "-rectypes" option. Then you can write: *)

module type ParamType = sig
  type ('a, 'b) t
end

module EqFix (M : ParamType) = struct
  type 'b fix = ('b fix, 'b) M.t
end

module EqList = struct
  module Param = struct
    type ('a, 'b) t = Nil | Cons of 'b * 'a
  end
  include EqFix(Param)
end

open EqList.Param

let rec to_usual_list =
  function
  | Nil -> []
  | (Cons (x, xs)) -> x :: to_usual_list xs

(*The syntax of modules is quite heavy and could appear frightening. If
  you insist you can use first-class modules to move some of these uses
  from functors to simple functions. I choose to begin with the "simple"
  way to do it first.

  Higher-kinded variables envy is probably the most severe illness about
  OCaml type worshippers (or Haskellers that for some (good!) reason
  come to wander in these parts of Functional County). In practice we do
  without it with not too much problems, but heavy use of monad
  transformers would be complicated indeed by this functor step, which
  is one of the reason it's not a very popular style around here.
  You may also distract yourself by thinking about the imperfections of
  higher-kinded variables in the languages that do support them; the
  limitation to constructor polymorphism rather than arbitrary
  type-level functions make them less expressive than you would like.
  The day we work out the details of the absolutely perfect higher-order
  type abstraction, maybe OCaml will jump to it? *)
