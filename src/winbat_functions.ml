open Core.Std
open Winbat_ast

let rec expand_command (name : varstring) (exprs : varstrings) =
  match name with
  | `Str "println" -> (
      match exprs with
      | [] ->
        `Call (`Str "echo:", [])
      | _ ->
        `Call (`Str "echo", exprs)
    )
  | `Str "print" ->
    `Call (`Str "echo | set /p =", exprs)
  | `Str "call" -> (
      match exprs with
      | cmd :: args ->
        expand_command cmd args
      | [] ->
        failwith "call must have at least 1 argument."
    )
  | _ ->
    `Call (name, exprs)

let rec expand_statement (stmt : statement) : statement =
  match stmt with
  | `Call (name, exprs) ->
    expand_command name exprs
  | `If (condition, stmts) ->
    `If (condition, expand_statements stmts)
  | `IfElse (condition, then_stmts, else_stmts) ->
    `IfElse (condition,
             expand_statements then_stmts,
             expand_statements else_stmts)
  (*      | IfElse (expr, then_stmt, else_stmt) ->
          IfElse (expand_expression expr,
              expand_statement then_stmt,
              expand_statement else_stmt)
          | While (expr, stmt) ->
          While (expand_expression expr, expand_statement stmt)
          | Block stmts ->
          Block (expand_statements stmts) *)
  | `Assignment _
  | `ArithAssign _
  | `Comment _ | `Raw _ | `Label _ | `Goto _ | `Empty -> stmt

and expand_statements (stmts: statements) : statements =
  List.map stmts ~f: expand_statement

let expand (ast : t) : t =
  expand_statements ast
