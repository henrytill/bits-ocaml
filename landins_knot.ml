(** "Landin's Knot" - implements recursion by backpatching *)
let landins_knot f =
  let r = ref (fun x -> assert false) in
  let fixedpoint = f (fun x -> !r x) in
  r := fixedpoint;
  fixedpoint

let factorial =
  let f g x =
    if x = 0 then
      1
    else
      x * g (x - 1)
  in
  landins_knot f
