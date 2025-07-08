test_that("Site_parCI works with minimal valid input", {
  set.seed(123)
  atsite_temp <- matrix(rnorm(30), ncol = 1)  # 30 years for 1 site
  model <- 2
  site_par <- data.frame(mu0 = 0, mu1 = 0.1,  sigma0 = 1, sigma1 = 0, shape = 0.1)

  result <- Site_parCI(atsite_temp, model, site_par, n.boots = 100)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(2, 5))
  expect_equal(rownames(result), c("Lower 95% CI", "Upper 95% CI"))
})

test_that("Site_parCI throws error with non-vector or multi-column input", {
  invalid_data <- matrix(rnorm(30 * 2), ncol = 2)  # Two columns

  site_par <- data.frame(mu0 = 0, mu1 = 0.1, sigma0 = 1, sigma1 = 0, shape = 0.1)

  expect_error(
    Site_parCI(invalid_data, 1, site_par, 110),
    "data_site must be a vector or single column matrix"
  )
})

test_that("Site_parCI throws error if site has less than 10 years", {
  atsite_temp <- matrix(rnorm(9), ncol = 1)  # Less than 10 years
  site_par <- data.frame(mu0 = 0, mu1 = 0.1, sigma0 = 1, sigma1 = 0, shape = 0.1)

  expect_error(
    Site_parCI(atsite_temp, 1, site_par, 100),
    "Site must have at least 10 years of records"
  )
})

test_that("Site_parCI throws error for n.boots less than 100", {
  atsite_temp <- matrix(rnorm(30), ncol = 1)
  site_par <- data.frame(mu0 = 0, mu1 = 0.1, mu2 = 0, sigma0 = 1, sigma1 = 0, shape = 0.1)

  expect_error(
    Site_parCI(atsite_temp, 1, site_par, 50),
    "n.boots must be larger than 99"
  )
})

test_that("Site_parCI throws error for non-numeric site_par", {
  atsite_temp <- matrix(rnorm(30), ncol = 1)
  site_par_non_numeric <- data.frame(mu0 = "a", mu1 = "b", sigma0 = "d", sigma1 = "e", shape = "f")

  expect_error(
    Site_parCI(atsite_temp, 1, site_par_non_numeric, 110),
    "Input 'reg_par' must be a numeric data frame or matrix with 5 columns."
  )
})

test_that("Site_parCI throws error if site_par has wrong dimensions", {
  atsite_temp <- matrix(rnorm(30), ncol = 1)

  # Wrong number of columns
  site_par_wrong_cols <- data.frame(a = 1, b = 2)
  expect_error(
    Site_parCI(atsite_temp, 1, site_par_wrong_cols, 110),
    "Input 'site_par' must have exactly 1 row and 5 columns."
  )

  # More than one row
  site_par_two_rows <- data.frame(mu0 = c(0, 1), mu1 = c(0.1, 0.2),
                                  sigma0 = c(1, 1), sigma1 = c(0, 0), shape = c(0.1, 0.1))
  expect_error(
    Site_parCI(atsite_temp, 1, site_par_two_rows, 110),
    "Input 'site_par' must have exactly 1 row and 5 columns."
  )
})
