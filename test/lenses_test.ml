open Lenses

type address = {
  _road : string;
  _city : string;
  _postcode : string;
}

type person = {
  _name : string;
  _addr : address;
  _salary : int;
}

let fred =
  {
    _name = "Fred";
    _addr = { _road = "26 Bumblebee Ln"; _city = "Manassis"; _postcode = "02134" };
    _salary = 100;
  }

(* Some lenses for the data *)

let name : (person, string) lens' =
  object
    method get x = x._name
    method set v x = { x with _name = v }
  end

let addr : (person, address) lens' =
  object
    method get x = x._addr
    method set v x = { x with _addr = v }
  end

let postcode : (address, string) lens' =
  object
    method get x = x._postcode
    method set v x = { x with _postcode = v }
  end

let run_example () =
  let fred_postcode = get fred (compose addr postcode) in
  print_endline ("Fred's postcode: " ^ fred_postcode);
  let set_postcode = set (compose addr postcode) in
  let fred = set_postcode "55555" fred in
  let fred_postcode = get fred (compose addr postcode) in
  print_endline ("Fred's updated postcode: " ^ fred_postcode)

let () = run_example ()
