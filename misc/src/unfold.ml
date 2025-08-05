let[@tail_mod_cons] rec unfoldr f seed =
  match f seed with
  | None -> []
  | Some (v, seed') -> v :: unfoldr f seed'

let schemeunfold (isempty : 'a -> bool) (head : 'a -> 'b) (tail : 'a -> 'a) (seed : 'a) : 'b list =
  unfoldr
    (fun seed ->
      if isempty seed then
        None
      else
        Some (head seed, tail seed))
    seed
