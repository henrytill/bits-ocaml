module M = struct
  type ('pre, 'post, 'a) t = 'pre -> 'a * 'post

  let return (x : 'a) : ('post, 'post, 'a) t = fun post -> (x, post)

  let bind (m : ('pre, 'mid, 'a) t) (f : 'a -> ('mid, 'post, 'b) t) : ('pre, 'post, 'b) t =
    fun pre ->
    let a, mid = m pre in
    f a mid

  let ( let* ) = bind
end

module File = struct
  type closed = Closed
  type opened = { fd : Unix.file_descr }

  let open_file : string -> (closed, opened, unit) M.t =
    fun filename Closed ->
    let fd = Unix.(openfile filename [ O_RDWR; O_CREAT ] 0o640) in
    ((), { fd })

  let read : (opened, opened, string) M.t =
    fun state ->
    let _ = Unix.lseek state.fd 0 Unix.SEEK_SET in
    let buf_len = 4096 in
    let buf = Bytes.create buf_len in
    let content = Buffer.create 16 in
    let rec read_chunks () =
      let bytes_read = Unix.read state.fd buf 0 buf_len in
      if bytes_read > 0 then
        let () = Buffer.add_subbytes content buf 0 bytes_read in
        read_chunks ()
    in
    read_chunks ();
    (Buffer.contents content, state)

  let write : string -> (opened, opened, unit) M.t =
    fun content state ->
    let _ = Unix.lseek state.fd 0 Unix.SEEK_SET in
    let bytes = Bytes.of_string content in
    let bytes_len = Bytes.length bytes in
    let _bytes_written = Unix.single_write state.fd bytes 0 bytes_len in
    Unix.ftruncate state.fd bytes_len;
    Unix.fsync state.fd;
    ((), state)

  let close : (opened, closed, unit) M.t =
    fun state ->
    Unix.close state.fd;
    ((), Closed)
end

let safe_file_operation : (File.closed, File.closed, string) M.t =
  let open M in
  let* () = File.open_file "example.txt" in
  let* content = File.read in
  let* () = File.write (content ^ " - modified") in
  let* () = File.close in
  return content

let test () =
  let result, final_state = safe_file_operation Closed in
  assert (final_state = Closed);
  print_endline result
