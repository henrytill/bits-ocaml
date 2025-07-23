open Bits.Spreadsheet.Cell

let ( let* ) = ( >>= )

let example =
  let* x = cell (return 10) in
  let* y = cell (return 20) in
  let* result = cell (return 0) in
  let () =
    set
      result
      (let* a = get x in
       let* b = get y in
       return (a + b))
  in
  let* a = get result in
  let () = set x (return 20) in
  let* b = get result in
  let () = set y (return 30) in
  let* c = get result in
  return [ a; b; c ]

let () =
  let expected = [ 30; 40; 50 ] in
  let obtained = run example in
  if List.equal Int.equal expected obtained then
    exit 0
  else
    exit 1
