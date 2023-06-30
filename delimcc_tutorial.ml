let gen_ops () =
  let p = Delimcc.new_prompt() in
  let reset = Delimcc.push_prompt p in
  let shift = Delimcc.shift p in
  (reset, shift)

module Exercise05 = struct
  let no_01 =
    let (reset, shift) = gen_ops () in
    5 * reset (fun () -> shift (fun k -> k (2 * 3)) + 3 * 4)
  let no_02 =
    let (reset, shift) = gen_ops () in
    reset (fun () -> if shift (fun k -> k (2 = 3)) then "hello" else "hi") ^ " world"
end
