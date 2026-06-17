test_that("Fit_model returns correct output structure for multiple sites", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures, model = 2)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 15)
  expect_equal(ncol(result), 6)

  expect_named(
    result,
    c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")
  )
})


test_that("Fit_model works with a vector input", {
  set.seed(123)
  temperatures <- rnorm(100)

  result <- Fit_model(temperatures, model = 1)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(result$size, 100)
})


test_that("Fit_model accepts models 1 to 4", {
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  for (m in 1:4) {
    result <- Fit_model(temperatures, model = m)

    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 15)
  }
})


test_that("Fit_model rejects invalid model values", {
  temperatures <- matrix(rnorm(1500), ncol = 15)

  expect_error(
    Fit_model(temperatures, model = "two"),
    "`model` must be a single integer between 1 and 4."
  )

  expect_error(
    Fit_model(temperatures, model = 7),
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
  expect_equal(nrow(result), 15)

  expect_equal(result$size[1], 90)
  expect_equal(result$size[5], 89)
})


test_that("Fit_model handles sites with all missing values", {

  temperatures <- matrix(rnorm(1500), ncol = 15)

  temperatures[, 3] <- NA

  result <- Fit_model(temperatures, model = 1)

  expect_equal(result$size[3], 0)

  expect_true(
    all(is.na(result[3, 1:5]))
  )
})


test_that("Fit_model returns finite sample sizes", {
  set.seed(123)

  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures, model = 4)

  expect_true(
    all(is.finite(result$size))
  )

  expect_true(
    all(result$size > 0)
  )
})


test_that("Fit_model returns numeric parameter columns", {
  set.seed(123)

  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures, model = 2)

  expect_true(is.numeric(result$mu0))
  expect_true(is.numeric(result$mu1))
  expect_true(is.numeric(result$sigma0))
  expect_true(is.numeric(result$sigma1))
  expect_true(is.numeric(result$shape))
})


test_that("Fit_model handles sites with all missing values", {

  temperatures <- matrix(rnorm(1500), ncol = 15)
  temperatures[,3] <- NA

  result <- Fit_model(temperatures, model = 1)

  expect_equal(result$size[3], 0)
  expect_true(all(is.na(result[3,1:5])))
})

test_that("Fit_model stores correct sample sizes", {

  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  temperatures[1:10,1] <- NA
  temperatures[1:20,2] <- NA

  result <- Fit_model(temperatures, model = 1)

  expect_equal(result$size[1], 90)
  expect_equal(result$size[2], 80)
  expect_equal(result$size[3], 100)
})

test_that("Fit_model works with a single-column matrix", {

  set.seed(123)

  temperatures <- matrix(rnorm(100), ncol = 1)

  result <- Fit_model(temperatures, model = 1)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(result$size, 100)
})

test_that("Fit_model correctly handles different sample sizes across sites", {

  set.seed(123)

  temperatures <- matrix(rnorm(500), ncol = 5)

  temperatures[1:5,1] <- NA
  temperatures[1:10,2] <- NA
  temperatures[1:20,3] <- NA

  result <- Fit_model(temperatures, model = 2)

  expect_equal(result$size, c(95,90,80,100,100))
})

test_that("Fit_model works with one site", {

  set.seed(123)

  temperatures <- matrix(rnorm(100), ncol = 1)

  result <- Fit_model(temperatures, model = 4)

  expect_equal(nrow(result), 1)
  expect_equal(result$size, 100)
})

test_that("fit_gev_ismev works for model 1", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  result <- NSTempRFA:::fit_gev_ismev(local, time, 1)

  expect_true(is.numeric(result) || is.null(result))

  if (!is.null(result)) {
    expect_length(result, 5)
    expect_equal(result[2], 0)
    expect_equal(result[4], 0)
  }
})


test_that("fit_gev_ismev works for model 2", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  result <- NSTempRFA:::fit_gev_ismev(local, time, 2)

  expect_true(is.numeric(result) || is.null(result))

  if (!is.null(result)) {
    expect_length(result, 5)
    expect_equal(result[4], 0)
  }
})


test_that("fit_gev_ismev works for model 3", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  result <- NSTempRFA:::fit_gev_ismev(local, time, 3)

  expect_true(is.numeric(result) || is.null(result))

  if (!is.null(result)) {
    expect_length(result, 5)
    expect_equal(result[2], 0)
  }
})


test_that("fit_gev_ismev works for model 4", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  result <- NSTempRFA:::fit_gev_ismev(local, time, 4)

  expect_true(is.numeric(result) || is.null(result))

  if (!is.null(result)) {
    expect_length(result, 5)
  }
})

test_that("fit_gev returns a numeric vector", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  result <- NSTempRFA:::fit_gev(local, time, 1)

  expect_type(result, "double")
  expect_length(result, 5)
})

test_that("fit_gev_ismev returns NULL when fitting fails", {

  local <- 1
  time <- 1

  result <- NSTempRFA:::fit_gev_ismev(local, time, 1)

  expect_null(result)
})

test_that("fit_gev_alt returns a numeric vector", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  result <- NSTempRFA:::fit_gev_alt(local, time, 1)

  expect_type(result, "double")
  expect_length(result, 5)
})

test_that("fit_gev_alt returns NA vector when all methods fail", {

  local <- 1
  time <- 1

  result <- NSTempRFA:::fit_gev_alt(local, time, 1)

  expect_true(all(is.na(result)))
})

test_that("fit_gev_alt handles all model types", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  for (m in 1:4) {

    result <- NSTempRFA:::fit_gev_alt(local, time, m)

    expect_length(result, 5)
  }
})

test_that("fit_gev preserves zero coefficients correctly", {

  set.seed(123)

  local <- rnorm(100)
  time <- seq_along(local)

  r1 <- NSTempRFA:::fit_gev(local, time, 1)
  r2 <- NSTempRFA:::fit_gev(local, time, 2)
  r3 <- NSTempRFA:::fit_gev(local, time, 3)

  expect_equal(r1[2], 0)
  expect_equal(r1[4], 0)

  expect_equal(r2[4], 0)

  expect_equal(r3[2], 0)
})
