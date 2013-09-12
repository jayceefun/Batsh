open Core.Std

let to_bash (batsh: Batsh.t) =
  let batsh_ast: Batsh.asttype = Batsh.Parser.parse_and_print_error batsh in
  let bash_ast: Bash.asttype = Batsh.compile_to_bash batsh_ast in
  printf "%a\n" Bash.Format.print bash_ast

let main (filename: string) (format: bool) () =
  let inx = In_channel.create filename in
  let batsh = Batsh.create_from_channel inx filename in
  if format then
    Batsh.Format.prettify batsh
  else
    to_bash batsh;
  In_channel.close inx

let () =
  let regular_file = Command.Spec.Arg_type.create (fun filename ->
    match Sys.is_file filename with
    | `Yes -> filename
    | `No | `Unknown ->
      eprintf "%s is not a regular file.\n%!" filename;
      exit 1
  )
  in
  Command.basic
    ~summary:"Batsh"
    ~readme:(fun () -> "Write once and runs on both UNIX and Windows.")
    Command.Spec.(
      empty
      +> anon ("filename" %: regular_file)
      +> flag "-format" no_arg ~doc:" print prettified source code"
    ) main
  |> Command.run ~version:"0.0" ~build_info:""