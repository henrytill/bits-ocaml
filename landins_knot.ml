(** "Landin's Knot" - implements recursion by backpatching *)
let landins_knot : (('a -> 'b) -> 'a -> 'b) -> 'a -> 'b =
  fun f ->
  let r = ref (fun x -> assert false) in
  let fixedpoint = f (fun x -> !r x) in
  r := fixedpoint;
  fixedpoint

let factorial : int -> int =
  let f g x =
    if x = 0 then
      1
    else
      x * g (x - 1)
  in
  landins_knot f
