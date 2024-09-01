open Views

let zero = Nat.(into Zero)
let succ n = Nat.(into (Succ n))
let seven = succ (succ (succ (succ (succ (succ (succ zero))))))

let rec fact m =
  let open Nat in
  let one = succ zero in
  match out m with
  | Zero -> one
  | Succ n -> mul m (fact n)

let rec fib m =
  let open Nat in
  match out m with
  | Zero -> zero
  | Succ n -> begin
      match out n with
      | Zero -> succ zero
      | Succ n -> add (fib n) (fib (succ n))
    end

let tip = Tree.(into Tip)
let leaf x = Tree.(into (Leaf x))
let fork x y = Tree.(into (Fork (x, y)))
let tree = fork (fork (leaf 1) (leaf 2)) (fork (leaf 3) tip)
let () = print_endline (Nat.show (fact seven))
