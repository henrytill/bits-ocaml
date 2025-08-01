type ('a, 'b) hom = 'a -> 'b

type nat =
  | Z
  | S of nat

let id x = x
let compose f g a = g (f a)
let unit _ = ()
let pair f g a = (f a, g a)
let fst (a, _) = a
let snd (_, b) = b
let curry f a = fun b -> f (a, b)
let eval (f, v) = f v
let zero () = Z
let succ n = S n

let rec iter z s (a, n) =
  match n with
  | Z -> z a
  | S n -> s (a, iter z s (a, n))

let run tm =
  let rec loop acc = function
    | Z -> acc
    | S n -> loop (acc + 1) n
  in
  loop 0 (tm ())
