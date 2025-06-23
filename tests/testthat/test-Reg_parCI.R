test_that("Reg_parCI works for valid input", {
  set.seed(123)
  add_data <- matrix(rnorm(30 * 7), 30, 7)
  reg_par_valid <- data.frame(
    mu0 = 0.1, mu1 = 0.2, mu2 = 0.3,
    sigma0 = 1, sigma1 = 0.1, shape = 0.2
  )

  result <- Reg_parCI(add_data, model = 1, reg_par = reg_par_valid, n.boots = 110)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(2, 6))
  expect_true(all(c("Lower 95% CI", "Upper 95% CI") %in% rownames(result)))
})

test_that("Reg_parCI throws error if n.boots < 100", {
  add_data <- matrix(rnorm(30 * 7), 30, 7)
  reg_par_valid <- data.frame(
    mu0 = 0.1, mu1 = 0.2, mu2 = 0.3,
    sigma0 = 1, sigma1 = 0.1, shape = 0.2
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par = reg_par_valid, n.boots = 50),
    "n.boots must be larger than 100"
  )
})

test_that("Reg_parCI throws error when number of sites < 7", {
  add_data <- matrix(rnorm(30 * 6), 30, 6)  # Only 6 sites
  reg_par_valid <- data.frame(
    mu0 = 0.1, mu1 = 0.2, mu2 = 0.3,
    sigma0 = 1, sigma1 = 0.1, shape = 0.2
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par = reg_par_valid, n.boots = 110),
    "number of sites should be larger than 6"
  )
})

test_that("Reg_parCI throws error if any site has < 10 years of data", {
  add_data <- matrix(rnorm(30 * 7), 30, 7)
  add_data[1:25, 1] <- NA  # Make site 1 have only 5 non-NA values
  reg_par_valid <- data.frame(
    mu0 = 0.1, mu1 = 0.2, mu2 = 0.3,
    sigma0 = 1, sigma1 = 0.1, shape = 0.2
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par = reg_par_valid, n.boots = 110),
    "at least 10 years of records"
  )
})

test_that("Reg_parCI throws error when reg_par is non-numeric", {
  add_data <- matrix(rnorm(30 * 7), 30, 7)

  reg_par_non_numeric <- data.frame(
    mu0 = "a", mu1 = "b", mu2 = "c",
    sigma0 = "d", sigma1 = "e", shape = "f"
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par = reg_par_non_numeric, n.boots = 110),
    "must be a numeric data frame with 6 columns"
  )
})

test_that("Reg_parCI throws error when reg_par has wrong number of columns", {
  add_data <- matrix(rnorm(30 * 7), 30, 7)

  reg_par_wrong_cols <- data.frame(mu0 = 1, mu1 = 2, mu2 = 3)  # Only 3 columns

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par = reg_par_wrong_cols, n.boots = 110),
    "must have exactly 1 row and 6 columns"
  )
})

test_that("Reg_parCI throws error when reg_par has more than 1 row", {
  add_data <- matrix(rnorm(30 * 7), 30, 7)

  reg_par_multi_row <- data.frame(
    mu0 = c(1, 2), mu1 = c(3, 4), mu2 = c(5, 6),
    sigma0 = c(7, 8), sigma1 = c(9, 10), shape = c(11, 12)
  )

  expect_error(
    Reg_parCI(add_data, model = 1, reg_par = reg_par_multi_row, n.boots = 110),
    "must have exactly 1 row and 6 columns"
  )
})
