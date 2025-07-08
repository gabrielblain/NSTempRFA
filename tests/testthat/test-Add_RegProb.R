test_that("Add_RegProb returns probabilities between 0.0001 and 0.9999", {
  quantiles <- c(39.5, 40.0, 40.5)
  regional_pars <- data.frame(matrix(c(40, 0.1, 2, 0.05, 0.1), nrow = 1))
  site_temp <- rnorm(100, mean = 40, sd = 2)
  n.year <- 50

  result <- Add_RegProb(quantiles, regional_pars, site_temp, n.year)

  expect_true(all(result >= 0.0001))
  expect_true(all(result <= 0.9999))
})

test_that("Add_RegProb throws error with missing quantiles", {
  quantiles <- c(39.5, NA, 40.5)
  regional_pars <- data.frame(matrix(c(40, 0.1, 2, 0.05, 0.1), nrow = 1))
  site_temp <- rnorm(100, mean = 40, sd = 2)
  n.year <- 50

  expect_error(Add_RegProb(quantiles, regional_pars, site_temp, n.year),
               regexp = "must be a numeric vector with no missing values")
})

test_that("Add_RegProb throws error for invalid regional_pars dimensions", {
  quantiles <- c(39.5, 40.0, 40.5)
  wrong_regional_pars <- data.frame(matrix(c(40, 0.1, 2, 0.05), nrow = 1))  # Only 5 columns
  site_temp <- rnorm(100, mean = 40, sd = 2)
  n.year <- 30

  expect_error(Add_RegProb(quantiles, wrong_regional_pars, site_temp, n.year),
               regexp = "Input 'reg_par' must be a numeric data frame or matrix with 5 columns and 1 row.")
})

test_that("Add_RegProb throws error for non-numeric site_temp", {
  quantiles <- c(39.5, 40.0, 40.5)
  regional_pars <- data.frame(matrix(c(40, 0.1, 2, 0.05, 0.1), nrow = 1))
  site_temp <- as.character(rnorm(100, mean = 40, sd = 2))  # Non-numeric
  n.year <- 30

  expect_error(Add_RegProb(quantiles, regional_pars, site_temp, n.year),
               regexp = "must be a non-empty numeric vector")
})

test_that("Add_RegProb throws error when n.year is out of range", {
  quantiles <- c(39.5, 40.0, 40.5)
  regional_pars <- data.frame(matrix(c(40, 0.1, 2, 0.05, 0.1), nrow = 1))
  site_temp <- rnorm(100, mean = 40, sd = 2)
  n.year <- 150  # Bigger than length(site_temp)

  expect_error(Add_RegProb(quantiles, regional_pars, site_temp, n.year),
               regexp = "must be a single number between 1 and the length of `site_temp`")
})

test_that("Add_RegProb throws error if scale parameter becomes non-positive", {
  quantiles <- c(39.5, 40.0, 40.5)
  regional_pars <- data.frame(matrix(c(40, 0.1, -2, -0.05, 0.1), nrow = 1))  # Negative scale intercept and slope
  site_temp <- rnorm(100, mean = 40, sd = 2)
  n.year <- 30

  expect_error(Add_RegProb(quantiles, regional_pars, site_temp, n.year),
               regexp = "scale parameter must be positive")
})

test_that("Add_RegProb returns correct number of probabilities", {
  quantiles <- seq(38, 42, by = 0.5)
  regional_pars <- data.frame(matrix(c(40, 0.1, 2, 0.05, 0.1), nrow = 1))
  site_temp <- rnorm(100, mean = 40, sd = 2)
  n.year <- 20

  result <- Add_RegProb(quantiles, regional_pars, site_temp, n.year)
  expect_equal(length(result), length(quantiles))
})
