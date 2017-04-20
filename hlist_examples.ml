open Hlist

let x = HCons (3, HCons ("str", HCons (35.0, HNil)))

let a = get EZ x
let b = get (ES EZ) x
let c = get (ES (ES EZ)) x
