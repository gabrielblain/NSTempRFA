test_that("Add_RegQuant works with valid inputs", {
  # Simulate dummy data
  prob <- c(0.8, 0.9, 0.95)
  regional_pars <- matrix(c(10, 0.5, 5, 0.2, 0.1), nrow = 1)  # loc, loc_slope, scale, scale_slope, shape
  site_temp <- seq(25, 35, length.out = 50)
  n.year <- 10

  # Run the function
  result <- Add_RegQuant(prob, regional_pars, site_temp, n.year)

  # Check output type and structure
  expect_type(result, "double")
  expect_length(result, length(prob))
  expect_named(result)
  expect_false(any(is.na(result)))
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
