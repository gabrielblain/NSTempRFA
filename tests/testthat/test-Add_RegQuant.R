test_that("Add_RegQuant works with valid inputs", {
  prob <- c(0.8, 0.9, 0.95)
  regional_pars <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  site_temp <- seq(25, 35, length.out = 50)
  n.year <- 10

  result <- Add_RegQuant(prob, regional_pars, site_temp, n.year)

  expect_type(result, "double")
  expect_length(result, length(prob))
  expect_named(result)
  expect_false(any(is.na(result)))
  expect_true(all(is.finite(result)))
})

test_that("Add_RegQuant errors with invalid prob", {
  rp <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  temp <- rep(30, 50)

  expect_error(Add_RegQuant(c(1.2, 0.9), rp, temp, 5), "must be a numeric vector with values strictly between 0 and 1")
  expect_error(Add_RegQuant(c(0.8, NA), rp, temp, 5), "must be a numeric vector with values strictly between 0 and 1")
})

test_that("Add_RegQuant errors with invalid regional_pars", {
  temp <- rep(30, 50)
  expect_error(Add_RegQuant(c(0.9), matrix(1:4, nrow = 1), temp, 5), "must be a numeric matrix or data frame with 5 columns")
  expect_error(Add_RegQuant(c(0.9), matrix(1:10, nrow = 2), temp, 5), "5 columns and 1 row")
})

test_that("Add_RegQuant errors with invalid site_temp", {
  rp <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  expect_error(Add_RegQuant(c(0.9), rp, NA, 5), "must be a numeric vector or 1-column matrix with no missing values")
  expect_error(Add_RegQuant(c(0.9), rp, numeric(0), 5), "must be a numeric vector or 1-column matrix with no missing values")
})

test_that("Add_RegQuant errors with invalid n.year", {
  rp <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  temp <- rep(30, 50)

  expect_error(Add_RegQuant(c(0.9), rp, temp, 0), "between 1 and the length")
  expect_error(Add_RegQuant(c(0.9), rp, temp, 100), "between 1 and the length")
  expect_error(Add_RegQuant(c(0.9), rp, temp, "five"), "must be a single integer")
})

test_that("Add_RegQuant errors with non-integer n.year", {
  rp <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  temp <- rep(30, 50)

  expect_error(
    Add_RegQuant(c(0.9), rp, temp, 10.5),
    "must be a single integer"
  )
})

test_that("Add_RegQuant errors with non-integer n.year", {
  rp <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  temp <- rep(30, 50)

  expect_error(
    Add_RegQuant(c(0.9), rp, temp, 10.5),
    "must be a single integer"
  )
})

test_that("Add_RegQuant errors when scale parameter becomes non-positive", {
  prob <- c(0.9)
  site_temp <- rep(30, 50)

  regional_pars <- matrix(
    c(10, 0.5, -2, -0.2, 0.1),
    nrow = 1
  )

  expect_error(
    Add_RegQuant(
      prob,
      regional_pars,
      site_temp,
      n.year = 20
    ),
    "scale parameter must be positive"
  )
})

test_that("Add_RegQuant and Add_RegProb are approximately inverse functions", {

  prob <- c(0.90, 0.95, 0.99)

  regional_pars <- matrix(
    c(10, 0.5, 5, 0.2, 0.1),
    nrow = 1
  )

  site_temp <- rep(30, 50)

  quantiles <- Add_RegQuant(
    prob,
    regional_pars,
    site_temp,
    n.year = 10
  )

  recovered_prob <- Add_RegProb(
    quantiles,
    regional_pars,
    site_temp,
    n.year = 10
  )

  expect_equal(
    as.vector(recovered_prob),
    prob,
    tolerance = 1e-6
  )
})

test_that("Add_RegQuant returns correctly named quantiles", {

  prob <- c(0.90, 0.95, 0.99)
  regional_pars <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  site_temp <- rep(30, 50)

  result <- Add_RegQuant(
    prob,
    regional_pars,
    site_temp,
    n.year = 10
  )

  expect_equal(
    names(result),
    c("Q90", "Q95", "Q99")
  )
})

test_that("Add_RegQuant returns increasing quantiles for increasing probabilities", {

  prob <- c(0.80, 0.90, 0.95, 0.99)
  regional_pars <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  site_temp <- rep(30, 50)

  result <- Add_RegQuant(
    prob,
    regional_pars,
    site_temp,
    n.year = 10
  )

  expect_true(all(diff(result) > 0))
})

test_that("Add_RegQuant works for the first year", {
  prob <- c(0.9)
  regional_pars <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  site_temp <- rep(30, 50)

  result <- Add_RegQuant(
    prob,
    regional_pars,
    site_temp,
    n.year = 1
  )

  expect_true(all(is.finite(result)))
})

test_that("Add_RegQuant works for the last year", {
  prob <- c(0.9)
  regional_pars <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)
  site_temp <- rep(30, 50)

  result <- Add_RegQuant(
    prob,
    regional_pars,
    site_temp,
    n.year = length(site_temp)
  )

  expect_true(all(is.finite(result)))
})
