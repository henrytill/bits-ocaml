let e1 =
  [%goedel
    let add : nat -> nat -> nat =
      fun x y ->
      iter
        (match x with
        | Zero -> y
        | Succ n -> Succ n)
    in
    add (Succ (Succ Zero)) (Succ (Succ (Succ Zero)))]

let e2 =
  [%goedel
    let sum : nat -> nat -> nat =
      fun x y ->
      iter
        (match x with
        | Zero -> y
        | Succ n -> Succ n)
    in
    let mult : nat -> nat -> nat =
      fun x y ->
      iter
        (match x with
        | Zero -> Zero
        | Succ n -> sum y n)
    in
    mult (Succ (Succ Zero)) (Succ (Succ (Succ Zero)))]

let () =
  Printf.printf "2 + 3 = %d\n" (Bits.Goedel.run e1);
  Printf.printf "2 * 3 = %d\n" (Bits.Goedel.run e2)
