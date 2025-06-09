```ocaml
# open Bits.Calc.Intro;;
# #install_printer pp;;
```

```ocaml
# List.fold_left (+) (const 0) [const 1; const 2; const 3];;
- : t = (Add (Add (Add (Const 0, Const 1), Const 2), Const 3))
```

```ocaml
# List.fold_right (+) [const 1; const 2; const 3] (const 0);;
- : t = (Add (Const 1, Add (Const 2, Add (Const 3, Const 0))))
```
