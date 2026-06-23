test_that("Reg_parCI returns the correct structure", {

  set.seed(123)

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  result <- Reg_parCI(
    add_data = add_data,
    model = 1,
    reg_par = reg_par,
    n.boots = 100
  )

  expect_type(result, "double")
  expect_equal(dim(result), c(2, 5))

  expect_equal(
    rownames(result),
    c("Lower 95% CI", "Upper 95% CI")
  )

  expect_equal(
    colnames(result),
    c(
      "weighted_mu0",
      "weighted_mu1",
      "weighted_sigma0",
      "weighted_sigma1",
      "weighted_shape"
    )
  )

  expect_false(anyNA(result))
})



test_that("Reg_parCI rejects invalid model values", {

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 5, reg_par, n.boots = 100),
    "`model` must be a single integer between 1 and 4"
  )

  expect_error(
    Reg_parCI(add_data, model = "two", reg_par, n.boots = 100),
    "`model` must be a single integer between 1 and 4"
  )
})



test_that("Reg_parCI rejects invalid n.boots", {

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 50),
    "`n.boots` must be a single integer"
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 99.5),
    "`n.boots` must be a single integer"
  )
})



test_that("Reg_parCI rejects non-numeric add_data", {

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(
      add_data = "not numeric",
      model = 1,
      reg_par = reg_par,
      n.boots = 100
    ),
    "`add_data` must be numeric"
  )
})



test_that("Reg_parCI rejects empty add_data", {

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(
      add_data = matrix(numeric(0), nrow = 0),
      model = 1,
      reg_par = reg_par,
      n.boots = 100
    ),
    "`add_data` cannot be empty"
  )
})



test_that("Reg_parCI rejects fewer than three sites", {

  add_data <- matrix(rnorm(40 * 2), ncol = 2)

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 100),
    "The number of sites must be larger than 2"
  )
})



test_that("Reg_parCI rejects sites with fewer than ten observations", {

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  add_data[1:35, 1] <- NA

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 100),
    "All sites must have at least 10 years of records"
  )
})



test_that("Reg_parCI rejects invalid reg_par dimensions", {

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(1:4, nrow = 1)

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 100),
    "`reg_par` must have exactly 1 row and 5 columns"
  )
})



test_that("Reg_parCI rejects non-finite reg_par values", {

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(
    c(0, 0.01, 1, Inf, 0.1),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 100),
    "`reg_par` must contain finite numeric values"
  )
})



test_that("Reg_parCI rejects non-positive time-varying scale parameter", {

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(
    c(
      0,
      0,
      1,
      -0.05,
      0.1
    ),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 100),
    "Time-varying scale parameter became non-positive"
  )
})



test_that("Reg_parCI rejects invalid transformed values", {

  add_data <- matrix(1000, nrow = 40, ncol = 4)

  reg_par <- matrix(
    c(
      0,
      0,
      1,
      0,
      -0.2
    ),
    nrow = 1
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par, n.boots = 100),
    "Invalid transformed values encountered"
  )
})



test_that("Lower confidence limits are smaller than upper confidence limits", {

  set.seed(123)

  add_data <- matrix(rnorm(40 * 4), ncol = 4)

  reg_par <- matrix(
    c(0, 0.01, 1, 0.001, 0.1),
    nrow = 1
  )

  result <- Reg_parCI(
    add_data = add_data,
    model = 1,
    reg_par = reg_par,
    n.boots = 100
  )

  expect_true(
    all(result[1, ] <= result[2, ])
  )
})
