(** {{:https://semantic-domain.blogspot.com/2015/07/how-to-implement-spreadsheet.html} How to
     implement a spreadsheet} *)

module Cell : sig
  type 'a cell
  (** The type of cells containg a value of type 'a *)

  type 'a exp
  (** The type expressions return a value of type 'a *)

  val return : 'a -> 'a exp
  val ( >>= ) : 'a exp -> ('a -> 'b exp) -> 'b exp

  val cell : 'a exp -> 'a cell exp
  (** Creates a new cell *)

  val get : 'a cell -> 'a exp
  (** Reads a cell *)

  val set : 'a cell -> 'a exp -> unit
  (** Modifies the contents of a cell *)

  val run : 'a exp -> 'a
  (** Runs an expression. Useful for looking at the values of cells from the outside. *)
end = struct
  type 'a cell = {
    mutable code : 'a exp;
        (** The expression that the cell contains. Mutable because we can alter the contents of a
            cell. *)
    mutable value : 'a option;
        (** [None] if the cell has not been evaluated yet.

            [Some v] if the code has evaluted to [v]. *)
    mutable reads : ecell list;
        (** A list containg all of the cells that were read when the code in the [code] field was
            executed. If the cell hasn't been evaluated yet, then this is the empty list.

            Lists all the cells this cell depends on. *)
    mutable observers : ecell list;
        (** A list containing all of the cells that have read this cell when they were evaluated. If
            the cell hasn't been evaluated yet, then this is the empty list.

            Lists all the cells which depend on this cell. *)
    id : int;  (** The unique identifer of this cell *)
  }

  and ecell = Pack : 'a cell -> ecell  (** Allows us to build heterogenous cells *)

  and 'a exp = unit -> 'a * ecell list
  (** A thunk, which when forced returns:
      - a value of type 'a
      - the list of cells that it read while evaluating *)

  let id (Pack c) = c.id

  let rec union xs ys =
    match xs with
    | [] -> ys
    | x :: xs' ->
        if List.exists (fun y -> id x = id y) ys then
          union xs' ys
        else
          x :: union xs' ys

  let return v () = (v, [])

  let ( >>= ) cmd f () =
    let a, cs = cmd () in
    let b, ds = f a () in
    (b, union cs ds)

  let r = ref 0

  let new_id () =
    incr r;
    !r

  let cell exp () =
    let n = new_id () in
    let cell = { code = exp; value = None; reads = []; observers = []; id = n } in
    (cell, [])

  let get c () =
    match c.value with
    | Some v -> (v, [ Pack c ])
    | None ->
        let v, ds = c.code () in
        c.value <- Some v;
        c.reads <- ds;
        List.iter (fun (Pack d) -> d.observers <- Pack c :: d.observers) ds;
        (v, [ Pack c ])

  let remove_observer o (Pack c) = c.observers <- List.filter (fun o' -> id o != id o') c.observers

  let rec invalidate (Pack c) =
    let os = c.observers in
    let rs = c.reads in
    c.observers <- [];
    c.value <- None;
    c.reads <- [];
    List.iter (remove_observer (Pack c)) rs;
    List.iter invalidate os

  let set c exp =
    c.code <- exp;
    invalidate (Pack c)

  let run cmd = fst (cmd ())
end
