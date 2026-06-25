test_that("Reg_par returns a one-row data frame with five columns", {
  best_model <- data.frame(
    mu0 = c(10, 20),
    mu1 = c(1, 2),
    sigma0 = c(3, 4),
    sigma1 = c(0.1, 0.2),
    shape = c(0.05, 0.10),
    size = c(50, 100)
  )

  result <- Reg_par(best_model)

  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 1L)
  expect_identical(ncol(result), 5L)

  expect_named(
    result,
    c(
      "weighted_mu0",
      "weighted_mu1",
      "weighted_sigma0",
      "weighted_sigma1",
      "weighted_shape"
    )
  )
})

test_that("Reg_par computes weighted means correctly", {
  best_model <- data.frame(
    mu0 = c(10, 20),
    mu1 = c(1, 3),
    sigma0 = c(2, 6),
    sigma1 = c(0.1, 0.5),
    shape = c(0.05, 0.15),
    size = c(1, 3)
  )

  result <- Reg_par(best_model)

  expect_identical(result$weighted_mu0, (10 * 1 + 20 * 3) / 4)
  expect_identical(result$weighted_mu1, (1 * 1 + 3 * 3) / 4)
  expect_identical(result$weighted_sigma0, (2 * 1 + 6 * 3) / 4)
  expect_identical(result$weighted_sigma1, (0.1 * 1 + 0.5 * 3) / 4)
  expect_identical(result$weighted_shape, (0.05 * 1 + 0.15 * 3) / 4)
})

test_that("Reg_par rejects non-data-frame input", {
  expect_error(
    Reg_par(matrix(1:12, ncol = 6)),
    "Input 'best_model' must be a data frame."
  )
})

test_that("Reg_par rejects missing columns", {
  best_model <- data.frame(
    mu0 = 1,
    mu1 = 1,
    sigma0 = 1,
    sigma1 = 1,
    size = 10
  )

  expect_error(
    Reg_par(best_model),
    "must contain the columns"
  )
})

test_that("Reg_par rejects non-numeric columns", {
  best_model <- data.frame(
    mu0 = 1,
    mu1 = 1,
    sigma0 = 1,
    sigma1 = 1,
    shape = "a",
    size = 10
  )

  expect_error(
    Reg_par(best_model),
    "All columns in 'best_model' must be numeric"
  )
})

test_that("Reg_par rejects NA values in size column", {
  best_model <- data.frame(
    mu0 = 1,
    mu1 = 1,
    sigma0 = 1,
    sigma1 = 1,
    shape = 0.1,
    size = NA
  )

  expect_error(
    Reg_par(best_model),
    "All columns in 'best_model' must be numeric."
  )
})

test_that("Reg_par rejects zero total sample size", {
  best_model <- data.frame(
    mu0 = c(1, 2),
    mu1 = c(1, 2),
    sigma0 = c(1, 2),
    sigma1 = c(1, 2),
    shape = c(0.1, 0.2),
    size = c(0, 0)
  )

  expect_error(
    Reg_par(best_model),
    "The sum of the 'size' column must be greater than zero."
  )
})

test_that("Reg_par works for a single site", {
  best_model <- data.frame(
    mu0 = 10,
    mu1 = 1,
    sigma0 = 2,
    sigma1 = 0.1,
    shape = 0.05,
    size = 30
  )

  result <- Reg_par(best_model)

  expect_identical(result$weighted_mu0, 10)
  expect_identical(result$weighted_mu1, 1)
  expect_identical(result$weighted_sigma0, 2)
  expect_identical(result$weighted_sigma1, 0.1)
  expect_identical(result$weighted_shape, 0.05)
})

test_that("Reg_par rejects NA values in parameter columns", {
  best_model <- data.frame(
    mu0 = c(10, NA),
    mu1 = c(1, 2),
    sigma0 = c(3, 4),
    sigma1 = c(0.1, 0.2),
    shape = c(0.05, 0.10),
    size = c(50, 100)
  )

  expect_error(
    Reg_par(best_model),
    "All values in 'best_model' must be finite"
  )
})

test_that("Reg_par rejects Inf values", {
  best_model <- data.frame(
    mu0 = c(10, Inf),
    mu1 = c(1, 2),
    sigma0 = c(3, 4),
    sigma1 = c(0.1, 0.2),
    shape = c(0.05, 0.10),
    size = c(50, 100)
  )

  expect_error(
    Reg_par(best_model),
    "All values in 'best_model' must be finite"
  )
})

test_that("Reg_par rejects -Inf values", {
  best_model <- data.frame(
    mu0 = c(10, -Inf),
    mu1 = c(1, 2),
    sigma0 = c(3, 4),
    sigma1 = c(0.1, 0.2),
    shape = c(0.05, 0.10),
    size = c(50, 100)
  )

  expect_error(
    Reg_par(best_model),
    "All values in 'best_model' must be finite"
  )
})
