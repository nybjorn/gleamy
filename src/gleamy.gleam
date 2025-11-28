import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  greet()
  let filepath = "./sample.txt"
  let assert Ok(file) = simplifile.read(from: filepath)

  let first_column = get_column("^\\d+", file)
  let second_column = get_column("\\d+$", file)
  let distances =
    list.zip(
      list.sort(first_column, int.compare),
      list.sort(second_column, int.compare),
    )
    |> list.map(fn(a) { int.absolute_value(a.0 - a.1) })
  echo distances |> list.fold(0, int.add)
  echo distances |> sum_int_list()

  let calculate_filepath = "./rpn.txt"
  let assert Ok(calculate_file) = simplifile.read(from: calculate_filepath)
  let assignements =
    calculate_file
    |> string.split("\n")
    |> list.map(fn(line) {
      let parts = string.split(line, "→")
      let terms = string.replace(result.unwrap(list.first(parts), ""), "\"", "")
      let right =
        string.trim(result.unwrap(
          list.first(result.unwrap(list.rest(parts), [])),
          "",
        ))
      assert check_result(terms, right)
    })

  Nil
}

fn check_result(left: String, right: String) -> Bool {
  let tokens = string.split(left, " ")
  echo tokens
  let sum = calculate_rpn(tokens)
  echo sum
  let expected_sum = result.unwrap(int.parse(right), 0)
  echo expected_sum
  sum == expected_sum
}

fn calculate_rpn(tokens: List(String)) -> Int {
  calculate_rpn_loop(tokens, [])
}

fn calculate_rpn_loop(tokens: List(String), stack: List(Int)) -> Int {
  case tokens {
    [] -> stack |> list.first() |> result.unwrap(0)
    [first_token, ..rest_of_tokens] ->
      case first_token {
        "+" -> {
          handle_operator(stack, rest_of_tokens, int.add)
        }
        "-" -> {
          handle_operator(stack, rest_of_tokens, int.subtract)
        }
        "*" -> {
          handle_operator(stack, rest_of_tokens, int.multiply)
        }
        "/" -> {
          handle_operator(stack, rest_of_tokens, divide)
        }
        _ -> {
          let new_stack = case int.parse(first_token) {
            Ok(number) -> list.append([number], stack)
            Error(_) -> stack
          }
          calculate_rpn_loop(rest_of_tokens, new_stack)
        }
      }
  }
}

fn handle_operator(stack: List(Int), rest_of_tokens: List(String), operator: fn(Int, Int) -> Int) -> Int {
  let #(a, b, remaining_stack) = get_terms(stack)
  let result = maths(b, a, operator)
  calculate_rpn_loop(
  rest_of_tokens,
  list.append([result], remaining_stack)
  )
}

fn get_terms(stack: List(Int)) -> #(Int, Int, List(Int)) {
  let a = list.first(stack) |> result.unwrap(0)
  let b = list.first(list.drop(stack, 1)) |> result.unwrap(0)
  #(a, b, list.drop(stack,2))
}

fn divide(a: Int, b: Int ) -> Int {
  case b{
    0 -> panic as "Division by zero is not allowed."
    _ -> a / b
  }
}

fn maths(a: Int, b: Int, func: fn(Int, Int) -> Int) -> Int {
  func(a, b)
}

fn get_column(reg_exp: String, content: String) -> List(Int) {
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regexp_first) = regexp.compile(reg_exp, options)
  regexp.scan(regexp_first, content)
  |> list.map(fn(m) {
    case int.parse(m.content) {
      Ok(value) -> value
      Error(_) -> panic as "Failed to parse integer from matched content."
    }
  })
}

pub fn sum_int_list(x: List(Int)) -> Int {
  // The public function calls the private tail recursive function
  sum_int_list_loop(x, 0)
}

fn sum_int_list_loop(x: List(Int), accumulator: Int) -> Int {
  case x {
    [] -> accumulator
    [first_int_list, ..the_rest_of_the_list] ->
      sum_int_list_loop(the_rest_of_the_list, accumulator + first_int_list)
  }
}

pub fn greet() -> Nil {
  io.println("Hello from gleamy!")
}
