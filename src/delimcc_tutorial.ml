module Delimcc = Delimcc_of_fxhandler

let make_ops () =
  let p = Delimcc.new_prompt () in
  let reset = Delimcc.push_prompt p in
  let shift = Delimcc.shift p in
  (reset, shift)

(* Section 2.1 *)
module Exercise_01 = struct
  (* [2 * 3] : int *)
  let no_01 = 5 * ((2 * 3) + (3 * 4))

  (* [2 = 3] : bool *)
  let no_02 = (if 2 = 3 then "hello" else "hi") ^ " world"

  (* [let x = 1] : int *)
  let no_03 =
    fst
      (let x = 1 + 2 in
       (x, x))

  (* [3 + 1] : int *)
  let no_04 = String.length ("x" ^ string_of_int (3 + 1))
end

module Exercise_05 = struct
  let no_01 =
    let reset, shift = make_ops () in
    5 * reset (fun () -> shift (fun k -> k (2 * 3)) + (3 * 4))

  let no_02 =
    let reset, shift = make_ops () in
    reset (fun () -> if shift (fun k -> k (2 = 3)) then "hello" else "hi") ^ " world"
end
