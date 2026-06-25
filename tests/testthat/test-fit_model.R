test_that("Fit_model returns correct output structure for multiple sites", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures, model = 2)

  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 15L)
  expect_identical(ncol(result), 6L)
  expect_named(result, c("mu0", "mu1", "sigma0", "sigma1", "shape", "size"))
})


test_that("Fit_model works with a vector input", {
  set.seed(123)
  temperatures <- rnorm(100)

  result <- Fit_model(temperatures, model = 1)

  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 1L)
  expect_identical(result$size, 100L)
})


test_that("Fit_model accepts models 1 to 4", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  for (m in 1:4) {
    result <- Fit_model(temperatures, model = m)
    expect_s3_class(result, "data.frame")
    expect_identical(nrow(result), 15L)
  }
})


test_that("Fit_model rejects invalid model values", {
  temperatures <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Fit_model(temperatures, model = "two"),
    "`model` must be a single integer between 1 and 4."
  )
  expect_error(
    Fit_model(temperatures, model = 7L),
    "`model` must be a single integer between 1 and 4."
  )
  expect_error(
    Fit_model(temperatures, model = 0),
    "`model` must be a single integer between 1 and 4."
  )
  expect_error(
    Fit_model(temperatures, model = 2.5),
    "`model` must be a single integer between 1 and 4."
  )
})


test_that("Fit_model rejects non-numeric temperatures", {
  expect_error(
    Fit_model("not numeric", model = 1),
    "`temperatures` must be a numeric vector or matrix."
  )
})


test_that("Fit_model rejects empty temperatures", {
  expect_error(
    Fit_model(numeric(0), model = 1),
    "`temperatures` cannot be empty."
  )
})


test_that("Fit_model handles missing values within sites", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)
  temperatures[1:10, 1] <- NA
  temperatures[20:30, 5] <- NA

  result <- Fit_model(temperatures, model = 1)

  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 15L)
  expect_identical(result$size[1], 90L)
  expect_identical(result$size[5], 89L)
})


test_that("Fit_model handles sites with all missing values", {
  temperatures <- matrix(rnorm(1500), ncol = 15)
  temperatures[, 3] <- NA

  result <- Fit_model(temperatures, model = 1)

  expect_identical(result$size[3], 0L)
  expect_true(all(is.na(result[3, 1L:5L])))
})


test_that("Fit_model returns finite sample sizes", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures, model = 4)

  expect_true(all(is.finite(result$size)))
  expect_true(all(result$size > 0L))
})


test_that("Fit_model returns numeric parameter columns", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures, model = 2)

  expect_type(result$mu0, "double")
  expect_type(result$mu1, "double")
  expect_type(result$sigma0, "double")
  expect_type(result$sigma1, "double")
  expect_type(result$shape, "double")
})


test_that("Fit_model stores correct sample sizes", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)
  temperatures[1:10, 1] <- NA
  temperatures[1:20, 2] <- NA

  result <- Fit_model(temperatures, model = 1)

  expect_identical(result$size[1], 90L)
  expect_identical(result$size[2], 80L)
  expect_identical(result$size[3], 100L)
})


test_that("Fit_model works with a single-column matrix", {
  set.seed(123)
  temperatures <- matrix(rnorm(100), ncol = 1)

  result <- Fit_model(temperatures, model = 1)

  expect_s3_class(result, "data.frame")
  expect_identical(nrow(result), 1L)
  expect_identical(result$size, 100L)
})


test_that("Fit_model correctly handles different sample sizes across sites", {
  set.seed(123)
  temperatures <- matrix(rnorm(500), ncol = 5)
  temperatures[1:5, 1] <- NA
  temperatures[1:10, 2] <- NA
  temperatures[1:20, 3] <- NA

  result <- Fit_model(temperatures, model = 2)

  expect_identical(result$size, c(95L, 90L, 80L, 100L, 100L))
})


test_that("Fit_model works with one site", {
  set.seed(123)
  temperatures <- matrix(rnorm(100), ncol = 1)

  result <- Fit_model(temperatures, model = 4)

  expect_identical(nrow(result), 1L)
  expect_identical(result$size, 100L)
})


test_that("Fit_model returns NULL or NA when fitting fails for a site", {
  # Single observation — fitting will fail for all optimisers
  temperatures <- matrix(1, nrow = 1, ncol = 1)

  result <- Fit_model(temperatures, model = 1)

  expect_identical(result$size[1], 1L)
  expect_true(all(is.na(result[1, 1L:5L])))
})


test_that("Fit_model preserves zero coefficients for stationary parameters", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  r1 <- Fit_model(temperatures, model = 1)
  r2 <- Fit_model(temperatures, model = 2)
  r3 <- Fit_model(temperatures, model = 3)

  # Only check sites where fitting succeeded
  expect_true(all(r1$mu1[!is.na(r1$mu1)] == 0))
  expect_true(all(r1$sigma1[!is.na(r1$sigma1)] == 0))
  expect_true(all(r2$sigma1[!is.na(r2$sigma1)] == 0))
  expect_true(all(r3$mu1[!is.na(r3$mu1)] == 0))
})


test_that("Fit_model handles all models returning length-5 parameter rows", {
  set.seed(123)
  temperatures <- rnorm(100)

  for (m in 1:4) {
    result <- Fit_model(temperatures, model = m)
    expect_identical(ncol(result), 6L)
    expect_length(as.numeric(result[1, 1:5]), 5)
  }
})
