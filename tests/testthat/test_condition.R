context("conditions")

check_structure = function(x, classes = character(0), pattern = NULL) {
  for (cl in c(classes, "condition"))
    expect_is(x, cl)
  expect_length(x, 2)
  expect_true(setequal(names(x), c("message", "call")))
  expect_is(x$message, "character")
  expect_length(x$message, 1)
  if (!is.null(pattern))
    expect_true(grepl(pattern, x$message))
  expect_true(is.null(x$call) || is.call(x$call))
}

test_that("base condition constructors", {
  x = condition("error", "assertion_error", "foo")
  check_structure(x, c("assertion_error", "error"), "foo")

  x = condition("warning", "custom_warning", "msg")
  check_structure(x, c("custom_warning", "warning"), "msg")

  x = condition_error("value", "msg")
  check_structure(x, c("value_error", "error"), "msg")

  x = condition_warning("lookup", "msg")
  check_structure(x, c("lookup_warning", "warning"), "msg")

  x = condition_message("missing", "msg")
  check_structure(x, c("missing_message", "message"), "msg")
})

test_that("standardized condition constructors", {
  ns = asNamespace("conditions")
  funs = ls(ns)
  funs = funs[grepl("^[a-z]+_(error|warning|message)", funs) & !grepl("^(condition_|as_)", funs)]
  for (name in funs) {
    f = match.fun(name)
    x = tryCatch(f("<grepme>"), condition = function(e) e)
    parts = strsplit(name, "_")[[1L]]
    check_structure(x, c(name, parts[2L]), pattern = "<grepme>")
  }
})

test_that("argument checks", {
  str.error = "non-missing, non-empty string"
  expect_error(io_error(0), "string")
  expect_error(io_error(NULL), "string")
  expect_error(io_error(0), "string")
  expect_error(condition_message(NA_character_, "msg"), str.error)
  expect_error(condition_message(character(0), "msg"), str.error)
  expect_error(condition_message(c("a", "b"), "msg"), str.error)
  expect_error(condition_message("", "msg"), str.error)
  expect_error(condition_message("class", NA), str.error)
  expect_error(condition_message("class", letters), str.error)
  expect_error(condition_message("class", "msg", call = NA), "call")
  expect_error(condition_message("class", "msg", call = logical(0)), "call")
})
