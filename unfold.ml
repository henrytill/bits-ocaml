let rec unfoldr f seed =
  match f seed with
  | None -> []
  | Some (v, seed') -> v :: unfoldr f seed'

let schemeunfold isempty head tail seed =
  unfoldr (fun seed -> if isempty seed then None else Some (head seed, tail seed)) seed
