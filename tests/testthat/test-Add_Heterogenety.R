test_that("Add_Heterogenety returns a numeric H value", {
  set.seed(123)
  dataset.add <- matrix(rnorm(1500), ncol = 15)
  result <- Add_Heterogenety(dataset.add = dataset.add, rho = 0.5, Ns = 100)
  expect_length(result, 1)
  expect_true(is.numeric(result))
  expect_false(is.na(result))
})

test_that("Add_Heterogenety throws error when number of sites is too low", {
  dataset.add <- matrix(rnorm(300), ncol = 5)
  expect_error(Add_Heterogenety(dataset.add, rho = 0.5, Ns = 100),
               "The number of sites should be larger than 6")
})

test_that("Add_Heterogenety throws error for sites with less than 10 years", {
  dataset.add <- matrix(rnorm(1500), ncol = 15)  # 100 rows x 15 sites
  dataset.add[1:95, 1] <- NA  # Site 1 has only 5 records
  expect_error(Add_Heterogenety(dataset.add, rho = 0.5, Ns = 100),
               "All sites must have at least 10 years of records")
})

test_that("Add_Heterogenety throws error for invalid rho values", {
  dataset.add <- matrix(rnorm(1500), ncol = 15)
  expect_error(Add_Heterogenety(dataset.add, rho = 1.1, Ns = 100),
               "`rho` must be a single smaller \\(larger\\) than -1 \\(1\\)\\.")
  expect_error(Add_Heterogenety(dataset.add, rho = -1.1, Ns = 100),
               "`rho` must be a single smaller \\(larger\\) than -1 \\(1\\)\\.")
})

test_that("Add_Heterogenety throws error if Ns is too small", {
  dataset.add <- matrix(rnorm(1500), ncol = 15)
  expect_error(Add_Heterogenety(dataset.add, rho = 0.5, Ns = 50),
               "Ns should be larger than 99")
})

test_that("Add_Heterogenety handles fallback when Kappa fails", {
  set.seed(123)
  dataset.add <- matrix(rnorm(1500, mean = 1, sd = 0.0001), ncol = 15)  # Near-constant but not fully
  expect_error(Add_Heterogenety(dataset.add, rho = 0.5, Ns = 100), NA)
})
