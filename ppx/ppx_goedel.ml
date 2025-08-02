(** {{:https://semantic-domain.blogspot.com/2012/12/total-functional-programming-in-partial.html}
     Total Functional Programming in a Partial Impure Language}

    see {!Bits.Goedel}*)

open Ppxlib

module Term = struct
  type var = string

  type ty =
    | Nat
    | One
    | Prod of ty * ty
    | Arrow of ty * ty

  type term =
    | Var of var
    | Let of var * term * term
    | Lam of var * term
    | App of term * term
    | Unit
    | Pair of term * term
    | Fst of term
    | Snd of term
    | Zero
    | Succ of term
    | Iter of term * term * var * term
    | Annot of term * ty

  let rec print_ty ppf =
    let open Format in
    function
    | One -> fprintf ppf "unit"
    | Nat -> fprintf ppf "nat"
    | Prod (ty1, ty2) -> fprintf ppf "(%a * %a)" print_ty ty1 print_ty ty2
    | Arrow ((Arrow (_, _) as ty1), ty2) -> fprintf ppf "(%a) -> %a" print_ty ty1 print_ty ty2
    | Arrow (ty1, ty2) -> fprintf ppf "%a -> %a" print_ty ty1 print_ty ty2

  let rec string_of_ty = function
    | One -> "unit"
    | Nat -> "nat"
    | Prod (ty1, ty2) -> Printf.sprintf "(%s * %s)" (string_of_ty ty1) (string_of_ty ty2)
    | Arrow ((Arrow (_, _) as ty1), ty2) ->
        Printf.sprintf "(%s) -> %s" (string_of_ty ty1) (string_of_ty ty2)
    | Arrow (ty1, ty2) -> Printf.sprintf "%s -> %s" (string_of_ty ty1) (string_of_ty ty2)
end

module Quote = struct
  let id ~loc = [%expr Bits.Goedel.id]
  let compose ~loc f g = [%expr Bits.Goedel.compose [%e f] [%e g]]
  let unit ~loc = [%expr Bits.Goedel.unit]
  let fst ~loc = [%expr Bits.Goedel.fst]
  let snd ~loc = [%expr Bits.Goedel.snd]
  let pair ~loc f g = [%expr Bits.Goedel.pair [%e f] [%e g]]
  let prod ~loc f g = [%expr Bits.Goedel.prod [%e f] [%e g]]
  let curry ~loc f = [%expr Bits.Goedel.curry [%e f]]
  let eval ~loc = [%expr Bits.Goedel.eval]
  let zero ~loc = [%expr Bits.Goedel.zero]
  let succ ~loc = [%expr Bits.Goedel.succ]
  let iter ~loc z s = [%expr Bits.Goedel.iter [%e z] [%e s]]

  let rec find ~loc x = function
    | [] -> raise Not_found
    | (x', _) :: _ when x = x' -> [%expr Bits.Goedel.snd]
    | _ :: ctx' -> [%expr Bits.Goedel.compose Bits.Goedel.fst [%e find ~loc x ctx']]
end

module Context = struct
  open Term

  type ctx = (var * ty) list

  type 'a result =
    | Error of string
    | Done of 'a

  type 'a t = ctx -> 'a result

  let return v = fun _ -> Done v

  let ( >>= ) m f =
    fun ctx ->
    match m ctx with
    | Done v -> f v ctx
    | Error s -> Error s

  let with_hyp hyp cmd = fun ctx -> cmd (hyp :: ctx)

  let lookup ~loc x ctx =
    try Done (Quote.find ~loc x ctx, List.assoc x ctx)
    with Not_found -> Error (Printf.sprintf "'%s' unbound" x)

  let error fmt = Printf.ksprintf (fun msg _ -> Error msg) fmt
  let run cmd = cmd []
end

module Elaborate = struct
  open Term
  open Quote
  open Context

  let ( let* ) = ( >>= )

  let rec check ~loc e ty =
    match (e, ty) with
    | Lam (x, e), Arrow (ty1, ty2) ->
        with_hyp (x, ty1) (check ~loc e ty2 >>= fun t -> return (curry ~loc t))
    | Lam (_, _), ty -> error "Expected function type, got '%s'" (string_of_ty ty)
    | Unit, One -> return (unit ~loc)
    | Unit, ty -> error "Expected unit type, got '%s'" (string_of_ty ty)
    | Pair (e1, e2), Prod (ty1, ty2) ->
        let* t1 = check ~loc e1 ty1 in
        let* t2 = check ~loc e2 ty2 in
        return (pair ~loc t1 t2)
    | Pair (_, _), ty -> error "Expected product type, got '%s'" (string_of_ty ty)
    | Iter (en, ez, x, es), ty ->
        let* tn = check ~loc en Nat in
        let* tz = check ~loc ez ty in
        let* ts = with_hyp (x, ty) (check ~loc es ty) in
        return (compose ~loc (pair ~loc (id ~loc) tn) (iter ~loc tz ts))
    | Let (x, e1, e2), ty2 ->
        let* t1, ty1 = synth ~loc e1 in
        let* t2 = with_hyp (x, ty1) (check ~loc e2 ty2) in
        return (compose ~loc (pair ~loc (id ~loc) t1) t2)
    | _, _ -> (
        synth ~loc e >>= function
        | t, ty' when ty = ty' -> return t
        | _, ty' ->
            error "Expected type '%s', inferred type '%s'" (string_of_ty ty) (string_of_ty ty'))

  and synth ~loc = function
    | Var x -> lookup ~loc x
    | Zero -> return (compose ~loc (unit ~loc) (zero ~loc), Nat)
    | Succ e1 -> check ~loc e1 Nat >>= fun t1 -> return (compose ~loc t1 (succ ~loc), Nat)
    | App (e1, e2) -> (
        synth ~loc e1 >>= function
        | t1, Arrow (ty2, ty) ->
            check ~loc e2 ty2 >>= fun t2 -> return (compose ~loc (pair ~loc t1 t2) (eval ~loc), ty)
        | _, ty_bad -> error "Expected function, got '%s'" (string_of_ty ty_bad))
    | Fst e -> (
        synth ~loc e >>= function
        | t, Prod (ty1, _) -> return (compose ~loc t (fst ~loc), ty1)
        | _, ty_bad -> error "Expected product, got '%s'" (string_of_ty ty_bad))
    | Snd e -> (
        synth ~loc e >>= function
        | t, Prod (_, ty2) -> return (compose ~loc t (snd ~loc), ty2)
        | _, ty_bad -> error "Expected product, got '%s'" (string_of_ty ty_bad))
    | Let (x, e1, e2) ->
        let* t1, ty1 = synth ~loc e1 in
        let* t2, ty2 = with_hyp (x, ty1) (synth ~loc e2) in
        return (compose ~loc (pair ~loc (id ~loc) t1) t2, ty2)
    | Annot (e, ty) -> check ~loc e ty >>= fun t -> return (t, ty)
    | _ -> error "Checking term in synthesizing position"
end

let rec ty =
  let open Term in
  function
  | [%type: nat] -> Nat
  | [%type: unit] -> One
  | [%type: [%t? a] -> [%t? b]] -> Arrow (ty a, ty b)
  | [%type: [%t? a] * [%t? b]] -> Prod (ty a, ty b)
  | { ptyp_desc = Ptyp_poly (_, t); _ } -> ty t
  | t -> failwith (Format.asprintf "unhandled type declaration: %a" Pprintast.core_type t)

let var_of_pat pat =
  match pat.ppat_desc with
  | Ppat_var { txt; _ } -> txt
  | _ -> failwith "expected variable pattern"

let[@warning "-11"] rec term =
  let open Term in
  function
  | [%expr ()] -> Unit
  | [%expr [%e? e1], [%e? e2]] -> Pair (term e1, term e2)
  | [%expr fst [%e? e]] -> Fst (term e)
  | [%expr snd [%e? e]] -> Snd (term e)
  | [%expr Zero] -> Zero
  | [%expr Succ [%e? e]] -> Succ (term e)
  | [%expr
      iter
        (match [%e? en] with
        | Zero -> [%e? ez]
        | Succ [%p? x] -> [%e? es])] ->
      Iter (term en, term ez, var_of_pat x, term es)
  | [%expr iter [%e? en] ~zero:[%e? ez] ~succ:(fun [%p? x] -> [%e? es])] ->
      Iter (term en, term ez, var_of_pat x, term es)
  | [%expr
      let [%p? x] : [%t? t] = [%e? e1] in
      [%e? e2]] ->
      Let (var_of_pat x, Annot (term e1, ty t), term e2)
  | [%expr
      let [%p? x] = [%e? e1] in
      [%e? e2]] ->
      Let (var_of_pat x, term e1, term e2)
  | [%expr ([%e? e] : [%t? t])] -> Annot (term e, ty t)
  | { pexp_desc = Pexp_ident { txt = Lident x; _ }; _ } -> Var x
  | [%expr fun [%p? p] -> [%e? e]] -> Lam (var_of_pat p, term e)
  | [%expr fun [%p? p1] [%p? p2] -> [%e? e]] -> Lam (var_of_pat p1, Lam (var_of_pat p2, term e))
  | [%expr fun [%p? p1] [%p? p2] [%p? p3] -> [%e? e]] ->
      Lam (var_of_pat p1, Lam (var_of_pat p2, Lam (var_of_pat p3, term e)))
  | [%expr [%e? e1] [%e? e2]] -> App (term e1, term e2)
  | [%expr [%e? e1] [%e? e2] [%e? e3]] -> App (App (term e1, term e2), term e3)
  | [%expr [%e? e1] [%e? e2] [%e? e3] [%e? e4]] ->
      App (App (App (term e1, term e2), term e3), term e4)
  | e -> failwith (Format.asprintf "unknown expression: %a" Pprintast.expression e)

let expand ~loc ~path:_ expr =
  try
    let term = term expr in
    match Context.run (Elaborate.synth ~loc term) with
    | Context.Done (code, _) -> code
    | Context.Error msg ->
        Ast_builder.Default.(
          pexp_extension ~loc (Location.error_extensionf ~loc "System T type error: %s" msg))
  with Failure msg ->
    Ast_builder.Default.(
      pexp_extension ~loc (Location.error_extensionf ~loc "System T error: %s" msg))

let extension =
  Extension.declare
    "goedel"
    Extension.Context.expression
    Ast_pattern.(single_expr_payload __)
    expand

let () = Driver.register_transformation ~extensions:[ extension ] "ppx_goedel"
