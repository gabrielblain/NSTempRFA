test_that("Dataset_add returns the expected structure", {
  set.seed(123)

  years <- 1980:2009
  temp <- matrix(rnorm(30 * 3), ncol = 3)

  dataset <- cbind(Years = years, temp)

  result <- Dataset_add(dataset)

  expect_type(result, "list")
  expect_named(result, c("add_data", "reg_mean"))

  expect_true(is.matrix(result$add_data))
  expect_type(result$reg_mean, "double")

  expect_identical(
    dim(result$add_data),
    dim(temp)
  )

  expect_length(
    result$reg_mean,
    3
  )
})


test_that("Dataset_add centers each site", {
  set.seed(123)

  years <- 1980:2009
  temp <- matrix(rnorm(30 * 4), ncol = 4)

  dataset <- cbind(Years = years, temp)

  result <- Dataset_add(dataset)

  expect_equal(
    unname(colMeans(result$add_data)),
    rep(0, 4),
    tolerance = 1e-10
  )
})


test_that("Dataset_add preserves missing values", {
  set.seed(123)

  years <- 1980:2009
  temp <- matrix(rnorm(30 * 3), ncol = 3)

  temp[5, 2] <- NA
  temp[10, 3] <- NA

  dataset <- cbind(Years = years, temp)

  result <- Dataset_add(dataset)

  expect_identical(
    sum(is.na(result$add_data)),
    sum(is.na(temp))
  )
})


test_that("Dataset_add returns the correct site means", {
  set.seed(123)

  years <- 1980:2009
  temp <- matrix(rnorm(30 * 3), ncol = 3)

  dataset <- cbind(Years = years, temp)

  result <- Dataset_add(dataset)

  expect_identical(
    unname(result$reg_mean),
    unname(colMeans(temp))
  )
})


test_that("Dataset_add throws error when Years contains NA", {
  years <- 1980:2009
  years[5] <- NA

  temp <- matrix(rnorm(30 * 3), ncol = 3)

  dataset <- cbind(Years = years, temp)

  expect_error(
    Dataset_add(dataset),
    "Column 'Years' cannot have missing data."
  )
})


test_that("Dataset_add throws error when number of sites is too small", {
  years <- 1980:2009
  temp <- matrix(rnorm(30 * 2), ncol = 2)

  dataset <- cbind(Years = years, temp)

  expect_error(
    Dataset_add(dataset),
    "The number of sites should be larger than 2."
  )
})


test_that("Dataset_add throws error when a site has fewer than 10 observations", {
  years <- 1980:2009
  temp <- matrix(rnorm(30 * 3), ncol = 3)

  # Site 1 has only 5 observations
  temp[1:25, 1] <- NA

  dataset <- cbind(Years = years, temp)

  expect_error(
    Dataset_add(dataset),
    "All sites must have at least 10 observations."
  )
})


test_that("Dataset_add throws error for invalid input type", {
  dataset <- "bad data"
  expect_error(
    Dataset_add(dataset),
    "Input 'dataset' must be a matrix or data frame."
  )
})


test_that("Dataset_add works with a data frame input", {
  set.seed(123)

  years <- 1980:2009
  temp <- matrix(rnorm(30 * 3), ncol = 3)

  dataset <- data.frame(
    Years = years,
    Site1 = temp[, 1],
    Site2 = temp[, 2],
    Site3 = temp[, 3]
  )

  result <- Dataset_add(dataset)

  expect_type(result, "list")
  expect_true(is.matrix(result$add_data))
  expect_length(result$reg_mean, 3)
})


test_that("Dataset_add returns add_data with same dimensions as the original site matrix", {
  set.seed(123)

  years <- 1980:2009
  temp <- matrix(rnorm(30 * 5), ncol = 5)

  dataset <- cbind(Years = years, temp)

  result <- Dataset_add(dataset)

  expect_identical(
    dim(result$add_data),
    c(30L, 5L)
  )
})
