open HList

let x = HCons (3, HCons ("str", HCons (35.0, HNil)))

let a = get Z x
let b = get (S Z) x
let c = get (S (S Z)) x
