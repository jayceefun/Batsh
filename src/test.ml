open Core.Std
open OUnit

let test_run_bash name =
  let filename = name ^ ".c" in
  let batsh = Parser.create_from_file filename in
  let bash = Bash.compile batsh in

  let inx, outx = Unix.open_process "bash" in
  let code = Bash.print bash in
  Out_channel.output_string outx code;
  Out_channel.close outx;
  let output = In_channel.input_all inx in
  In_channel.close inx;
  let exit_status = Unix.close_process (inx, outx) in
  let exit_message = Unix.Exit_or_signal.to_string_hum exit_status in
  assert_equal "exited normally" exit_message ~printer: Fn.id;

  let answer_filename = "output/" ^ name ^ ".txt" in
  let inx = In_channel.create answer_filename in
  let answer = In_channel.input_all inx in
  In_channel.close inx;
  assert_equal answer output ~printer: Fn.id

let test_bash name _ =
  test_run_bash name

let test_cases = "Batsh Unit Tests" >:::
                   ["Block" >:: test_bash "block";
                    "Arith" >:: test_bash "arith";
                    "Assignment" >:: test_bash "assignment";
                    "Array" >:: test_bash "array";
                    "Expressions" >:: test_bash "expr";
                    "If" >:: test_bash "if";
                    "While" >:: test_bash "while";
                    "Function" >:: test_bash "function";
                    "Recursion" >:: test_bash "recursion"]

let _ =
  run_test_tt_main test_cases
