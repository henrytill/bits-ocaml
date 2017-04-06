module type SAFE_ARRAY = sig
  type ('s, 'a) t
  type 's index
  type 'a brand =
    | Brand : ('s, 'a) t -> 'a brand
    | Empty : 'a brand
  val brand    : 'a array -> 'a brand
  val last     : ('s, 'a) t -> 's index
  val set      : ('s, 'a) t -> 's index -> 'a -> unit
  val get      : ('s, 'a) t -> 's index -> 'a
  val zero     : 's index
  val last     : ('s, 'a) t -> 's index
  val index    : ('s, 'a) t -> int -> 's index option
  val position : 's index   -> int
  val middle   : 's index   -> 's index -> 's index
  val next     : 's index   -> 's index -> 's index option
  val previous : 's index   -> 's index -> 's index option
end

module SafeArray : SAFE_ARRAY = struct

  type ('s, 'a) t = 'a array

  type 's index = int

  type 'a brand =
    | Brand : ('s, 'a) t -> 'a brand
    | Empty : 'a brand

  let brand arr =
    if Array.length arr > 0 then
      Brand arr
    else
      Empty

  let set      = Array.set
  let get      = Array.get
  let zero     = 0
  let last arr = (Array.length arr) - 1

  let index arr i =
    if i > 0 && i < Array.length arr then
      Some i
    else
      None

  let position idx = idx

  let middle idx1 idx2 = (idx1 + idx2) / 2

  let next idx limit =
    let next = idx + 1 in
    if next <= limit then
      Some next
    else
      None

  let previous limit idx =
    let prev = idx - 1 in
    if prev >= limit then
      Some prev
    else
      None
end

let bsearch cmp arr v =
  let open SafeArray in
  let rec look barr low high =
    let mid = middle low high in
    let x   = get barr mid in
    let res = cmp v x in
    if res = 0 then
      Some (position mid)
    else if res < 0 then
      match previous low mid with
      | Some prev -> look barr low prev
      | None      -> None
    else
      match next mid high with
      | Some next -> look barr next high
      | None      -> None
  in
  match brand arr with
  | Brand barr -> look barr zero (last barr)
  | Empty      -> None

let arr = [| 'a'; 'b'; 'c'; 'd' |]
let test1 = bsearch compare arr 'c'
let test2 = bsearch compare arr 'a'
let test3 = bsearch compare arr 'x'
