open Bits.Lens

type[@warning "-69"] address = {
  road : string;
  city : string;
  postcode : string;
}

type[@warning "-69"] person = {
  name : string;
  addr : address;
  salary : int;
}

let fred =
  {
    name = "Fred";
    addr = { road = "26 Bumblebee Ln"; city = "Manassis"; postcode = "02134" };
    salary = 100;
  }

(* Some lenses for the data *)

let[@warning "-32"] name : (person, string) lens' =
  object
    method get x = x.name
    method set v x = { x with name = v }
  end

let addr : (person, address) lens' =
  object
    method get x = x.addr
    method set v x = { x with addr = v }
  end

let postcode : (address, string) lens' =
  object
    method get x = x.postcode
    method set v x = { x with postcode = v }
  end

let run_example () =
  let postcode = compose addr postcode in
  let print s = print_endline ("Fred's postcode: " ^ s) in
  let () = fred |> view postcode |> print in
  let () = fred |> over postcode (fun _ -> "55555") |> view postcode |> print in
  ()

let () = run_example ()
