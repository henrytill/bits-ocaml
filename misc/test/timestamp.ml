let int_of_month = function
  | "January" -> 0
  | "February" -> 1
  | "March" -> 2
  | "April" -> 3
  | "May" -> 4
  | "June" -> 5
  | "July" -> 6
  | "August" -> 7
  | "September" -> 8
  | "October" -> 9
  | "November" -> 10
  | "December" -> 11
  | _ -> failwith "Invalid month name"

let parse_date date_str =
  Scanf.sscanf date_str "%s %d, %d" (fun month day year -> (int_of_month month, day, year))

let time_of_date date_str =
  let open Unix in
  let tm_mon, tm_mday, year = parse_date date_str in
  let tm_year = year - 1900 in
  let tm =
    {
      tm_sec = 0;
      tm_min = 0;
      tm_hour = 0;
      tm_mday;
      tm_mon;
      tm_year;
      tm_wday = 0;
      tm_yday = 0;
      tm_isdst = false;
    }
  in
  fst (mktime tm)

let convert_to_timestamp date_str = date_str |> time_of_date |> int_of_float |> string_of_int

let print_date date_str =
  let result = convert_to_timestamp date_str in
  Printf.printf "Timestamp for %s: %s\n" date_str result

let () = List.iter print_date [ "May 19, 2022"; "May 20, 2022"; "May 21, 2022" ]
