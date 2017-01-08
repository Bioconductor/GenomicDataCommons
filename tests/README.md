## Running tests

```{r}
devtools::test()
```

Should also run under `R CMD BiocCheck/check`.

## Tests

A test file lives in tests/testthat/. Its name must start with test. Here’s an example of a test file from the stringr package:

```{r}
library(stringr)
context("String length")

test_that("str_length is number of characters", {
  expect_equal(str_length("a"), 1)
  expect_equal(str_length("ab"), 2)
  expect_equal(str_length("abc"), 3)
})

test_that("str_length of factor is length of level", {
  expect_equal(str_length(factor("a")), 1)
  expect_equal(str_length(factor("ab")), 2)
  expect_equal(str_length(factor("abc")), 3)
})

test_that("str_length of missing is missing", {
  expect_equal(str_length(NA), NA_integer_)
  expect_equal(str_length(c(NA, 1)), c(NA, 1))
  expect_equal(str_length("NA"), 2)
})
```

Tests are organised hierarchically: expectations are grouped into tests which are organised in files:

An expectation is the atom of testing. It describes the expected result of a computation: Does it have the right value and right class? Does it produce error messages when it should? An expectation automates visual checking of results in the console. Expectations are functions that start with expect_.

A test groups together multiple expectations to test the output from a simple function, a range of possibilities for a single parameter from a more complicated function, or tightly related functionality from across multiple functions. This is why they are sometimes called unit as they test one unit of functionality. A test is created with test_that() .

A file groups together multiple related tests. Files are given a human readable name with context().
