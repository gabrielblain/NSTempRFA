test_that("Add_Heterogeneity returns a numeric H value", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add = dataset.add,
    rho = 0.5,
    Ns = 100
  )

  expect_length(result, 1)
  expect_true(is.numeric(result))
  expect_false(is.na(result))
  expect_true(is.finite(result))
})


test_that("Add_Heterogeneity accepts the minimum number of sites", {

  set.seed(123)

  dataset.add <- matrix(rnorm(300), ncol = 3)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = 0.5,
    Ns = 100
  )

  expect_true(is.numeric(result))
  expect_length(result, 1)
})


test_that("Add_Heterogeneity throws error when fewer than 3 sites are supplied", {

  dataset.add <- matrix(rnorm(300), ncol = 2)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = 0.5, Ns = 100),
    "The number of sites should be equal to or larger than 3."
  )
})


test_that("Add_Heterogeneity throws error for sites with less than 10 years", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  dataset.add[1:95, 1] <- NA

  expect_error(
    Add_Heterogeneity(dataset.add, rho = 0.5, Ns = 100),
    "All sites must have at least 10 years of records"
  )
})


test_that("Add_Heterogeneity accepts exactly 10 observations", {

  set.seed(123)

  dataset.add <- matrix(rnorm(150), nrow = 10, ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = 0.5,
    Ns = 100
  )

  expect_true(is.numeric(result))
})


test_that("Add_Heterogeneity throws error if Ns is too small", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = 0.5, Ns = 99),
    "Ns should be larger than 99"
  )
})


test_that("Add_Heterogeneity accepts Ns equal to 100", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = 0.5,
    Ns = 100
  )

  expect_true(is.numeric(result))
})


test_that("Add_Heterogeneity accepts negative correlations", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = -0.5,
    Ns = 100
  )

  expect_true(is.numeric(result))
  expect_true(is.finite(result))
})


test_that("Add_Heterogeneity accepts correlations close to one", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = 0.99,
    Ns = 100
  )

  expect_true(is.numeric(result))
})


test_that("Add_Heterogeneity rejects rho greater than one", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = 1.1, Ns = 100),
    "'rho' must be a single numeric value strictly between -1 and 1."
  )
})


test_that("Add_Heterogeneity rejects rho smaller than minus one", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = -1.1, Ns = 100),
    "'rho' must be a single numeric value strictly between -1 and 1."
  )
})


test_that("Add_Heterogeneity rejects rho equal to one", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = 1, Ns = 100),
    "'rho' must be a single numeric value strictly between -1 and 1."
  )
})


test_that("Add_Heterogeneity rejects rho equal to minus one", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = -1, Ns = 100),
    "'rho' must be a single numeric value strictly between -1 and 1."
  )
})


test_that("Add_Heterogeneity rejects rho vectors", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = c(0.2, 0.5), Ns = 100),
    "'rho' must be a single numeric value strictly between -1 and 1."
  )
})


test_that("Add_Heterogeneity rejects non-numeric rho", {

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = "0.5", Ns = 100),
    "'rho' must be a single numeric value strictly between -1 and 1."
  )
})


test_that("Add_Heterogeneity returns a finite value", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = 0.5,
    Ns = 100
  )

  expect_true(is.finite(result))
})


test_that("Add_Heterogeneity returns a scalar", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = 0.5,
    Ns = 100
  )

  expect_equal(length(result), 1)
})

test_that("Add_Heterogeneity falls back to Wakeby when Kappa fails", {

  local_mocked_bindings(
    pelkap = function(...) NA,
    .package = "NSTempRFA"
  )

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Add_Heterogeneity(dataset.add, rho = 0.5, Ns = 100),
    NA
  )
})

test_that("Add_Heterogeneity returns NA when both regional distributions fail", {

  local_mocked_bindings(

    pelkap = function(...) NA,

    pelwak = function(...) NA,

    .package = "NSTempRFA"
  )

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  expect_warning(

    result <- Add_Heterogeneity(
      dataset.add,
      rho = 0.5,
      Ns = 100
    ),

    "Failed to fit regional distribution"
  )

  expect_true(is.na(result))
})

test_that("Add_Heterogeneity returns NA when V.sim has zero variance", {

  fake_lmom <- matrix(
    c(
      1,100,0,1,0.1,0.2,0.3,
      2,100,0,1,0.1,0.2,0.3,
      3,100,0,1,0.1,0.2,0.3
    ),
    nrow = 3,
    byrow = TRUE
  )

  local_mocked_bindings(

    regsamlmu = function(...) fake_lmom,

    .package = "NSTempRFA"
  )

  dataset.add <- matrix(rnorm(300), ncol = 3)

  expect_warning(

    result <- Add_Heterogeneity(
      dataset.add,
      rho = 0.5,
      Ns = 100
    ),

    "V.sim contains invalid values"
  )

  expect_true(is.na(result))
})

test_that("Add_Heterogeneity repairs non positive definite correlation matrices", {

  set.seed(123)

  dataset.add <- matrix(rnorm(1500), ncol = 15)

  result <- Add_Heterogeneity(
    dataset.add,
    rho = -0.9,
    Ns = 100
  )

  expect_true(is.numeric(result))
  expect_true(is.finite(result))
})
