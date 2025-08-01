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

let e1_alt =
  [%goedel
    let add : nat -> nat -> nat = fun x y -> iter x ~zero:y ~succ:(fun n -> Succ n) in
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

let e2_alt =
  [%goedel
    let sum : nat -> nat -> nat = fun x y -> iter x ~zero:y ~succ:(fun n -> Succ n) in
    let mult : nat -> nat -> nat = fun x y -> iter x ~zero:Zero ~succ:(fun n -> sum y n) in
    mult (Succ (Succ Zero)) (Succ (Succ (Succ Zero)))]

let () =
  Printf.printf "2 + 3 = %d\n" (Bits.Goedel.run e1);
  Printf.printf "2 + 3 = %d\n" (Bits.Goedel.run e1_alt);
  Printf.printf "2 * 3 = %d\n" (Bits.Goedel.run e2);
  Printf.printf "2 * 3 = %d\n" (Bits.Goedel.run e2_alt)
