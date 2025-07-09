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
  let () = Printf.printf "%d\n" a in
  let () = set x (return 20) in
  let* a = get result in
  let () = Printf.printf "%d\n" a in
  let () = set y (return 30) in
  let* a = get result in
  let () = Printf.printf "%d\n" a in
  return ()

let () = run example
