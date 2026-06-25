test_that("Site_parCI returns a matrix with the correct dimensions", {
  set.seed(123)
  temperatures <- rnorm(500) # large sample for reliable convergence
  model <- 2
  site_par <- Fit_model(temperatures, model)

  skip_if(
    anyNA(site_par[1, 1:5]),
    "Fit_model did not converge — skipping"
  )

  result <- Site_parCI(
    atsite_temp = temperatures,
    model = model,
    site_par = site_par[1, 1:5],
    n.boots = 100
  )

  expect_true(is.matrix(result))
  expect_identical(dim(result), c(2L, 5L))
  expect_named(
    as.data.frame(result),
    c("mu0", "mu1", "sigma0", "sigma1", "shape")
  )
  expect_true(all(is.finite(result[, c(1, 3, 5)])))
})


test_that("Site_parCI accepts a single-column matrix", {
  set.seed(123)

  atsite_temp <- matrix(rnorm(50), ncol = 1)
  site_par <- matrix(c(0, 0.02, 1, 0.001, 0.1), nrow = 1)

  result <- Site_parCI(
    atsite_temp = atsite_temp,
    model = 1,
    site_par = site_par,
    n.boots = 100
  )

  expect_true(is.matrix(result))
})


test_that("Site_parCI rejects invalid model values", {
  temp <- rnorm(50)
  pars <- matrix(c(0, 0, 1, 0, 0.1), nrow = 1)

  expect_error(
    Site_parCI(temp, 0, pars, 100),
    "`model` must be a single integer"
  )

  expect_error(
    Site_parCI(temp, 5, pars, 100),
    "`model` must be a single integer"
  )

  expect_error(
    Site_parCI(temp, "two", pars, 100),
    "`model` must be a single integer"
  )
})


test_that("Site_parCI rejects invalid n.boots", {
  temp <- rnorm(50)
  pars <- matrix(c(0, 0, 1, 0, 0.1), nrow = 1)

  expect_error(
    Site_parCI(temp, 1, pars, 50),
    "`n.boots`"
  )

  expect_error(
    Site_parCI(temp, 1, pars, 99.5),
    "`n.boots`"
  )
})


test_that("Site_parCI rejects series shorter than 10 observations", {
  temp <- rnorm(9)
  pars <- matrix(c(0, 0, 1, 0, 0.1), nrow = 1)

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "at least 10 years"
  )
})


test_that("Site_parCI rejects all missing values", {
  temp <- rep(NA, 50)
  pars <- matrix(c(0, 0, 1, 0, 0.1), nrow = 1)

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "contains only missing values"
  )
})


test_that("Site_parCI rejects matrices with more than one column", {
  temp <- matrix(rnorm(100), ncol = 2)
  pars <- matrix(c(0, 0, 1, 0, 0.1), nrow = 1)

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "single-column matrix"
  )
})


test_that("Site_parCI rejects non-numeric site_par", {
  temp <- rnorm(50)

  pars <- matrix(
    c("a", "b", "c", "d", "e"),
    nrow = 1
  )

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "`site_par` must be numeric"
  )
})


test_that("Site_parCI rejects site_par with incorrect dimensions", {
  temp <- rnorm(50)

  pars <- matrix(1:10, nrow = 2)

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "exactly 1 row and 5 columns"
  )
})


test_that("Site_parCI rejects missing values in site_par", {
  temp <- rnorm(50)

  pars <- matrix(
    c(0, 0, 1, NA, 0.1),
    nrow = 1
  )

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "cannot contain missing or infinite values"
  )
})


test_that("Site_parCI rejects non-positive scale parameters", {
  temp <- rnorm(50)

  pars <- matrix(
    c(0, 0, -1, 0, 0.1),
    nrow = 1
  )

  expect_error(
    Site_parCI(temp, 1, pars, 100),
    "scale parameter becomes non-positive"
  )
})


test_that("Site_parCI works when shape parameter equals zero", {
  set.seed(123)

  temp <- rnorm(50)

  pars <- matrix(
    c(0, 0.01, 1, 0.001, 0),
    nrow = 1
  )

  result <- Site_parCI(
    temp,
    model = 2,
    site_par = pars,
    n.boots = 100
  )

  expect_true(is.matrix(result))
  expect_identical(dim(result), c(2L, 5L))
})
