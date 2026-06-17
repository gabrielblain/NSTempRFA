test_that("Best_model returns correct structure", {

  set.seed(123)
  fake_data <- matrix(rnorm(90), ncol = 3)  # 30 years × 3 sites

  result <- Best_model(fake_data)

  # Output is a list
  expect_type(result, "list")
  expect_named(result, c("best", "atsite.models"))

  # Best model index
  expect_true(result$best %in% 1:4)

  # atsite.models structure
  expect_s3_class(result$atsite.models, "data.frame")

  expect_equal(
    colnames(result$atsite.models),
    c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")
  )

  expect_equal(ncol(result$atsite.models), 6)

  # Number of rows = number of sites
  expect_equal(
    nrow(result$atsite.models),
    ncol(fake_data)
  )
})


test_that("Best_model stores correct sample sizes", {

  set.seed(123)

  fake_data <- matrix(rnorm(90), ncol = 3)

  result <- Best_model(fake_data)

  expect_true(
    all(result$atsite.models$size == 30)
  )
})


test_that("Best_model throws error with invalid input type", {

  expect_error(
    Best_model("not a matrix"),
    "must be a matrix or data frame"
  )

})


test_that("Best_model throws error when there are no sites", {

  empty_data <- matrix(numeric(0), nrow = 10, ncol = 0)

  expect_error(
    Best_model(empty_data),
    "must contain at least one site"
  )

})


test_that("Best_model throws error when any site has fewer than 10 observations", {

  set.seed(123)

  fake_data <- matrix(rnorm(90), ncol = 3)

  # Site 1 will have only 5 observations
  fake_data[1:25, 1] <- NA

  expect_error(
    Best_model(fake_data),
    "All sites must have at least 10 observations"
  )

})


test_that("Best_model returns finite sample sizes", {

  set.seed(123)

  fake_data <- matrix(rnorm(90), ncol = 3)

  result <- Best_model(fake_data)

  expect_true(
    all(is.finite(result$atsite.models$size))
  )

})


test_that("Best_model returns one row per site", {

  set.seed(123)

  fake_data <- matrix(rnorm(150), ncol = 5)

  result <- Best_model(fake_data)

  expect_equal(
    nrow(result$atsite.models),
    5
  )

})


test_that("Best_model parameter columns are numeric", {

  set.seed(123)

  fake_data <- matrix(rnorm(90), ncol = 3)

  result <- Best_model(fake_data)

  expect_true(
    all(
      sapply(result$atsite.models, is.numeric)
    )
  )

})


test_that("Best_model returns finite parameter estimates", {

  set.seed(123)

  fake_data <- matrix(rnorm(90), ncol = 3)

  result <- Best_model(fake_data)

  expect_true(
    all(
      is.finite(
        as.matrix(result$atsite.models)
      )
    )
  )

})


test_that("Best_model returns a valid best model index", {

  set.seed(123)

  fake_data <- matrix(rnorm(120), ncol = 4)

  result <- Best_model(fake_data)

  expect_true(
    length(result$best) == 1
  )

  expect_true(
    result$best %in% 1:4
  )

})

test_that("Best_model accepts a data.frame input", {

  set.seed(123)

  fake_data <- as.data.frame(
    matrix(rnorm(90), ncol = 3)
  )

  result <- Best_model(fake_data)

  expect_type(result, "list")

  expect_equal(
    nrow(result$atsite.models),
    3
  )
})

test_that("Best_model stores sample sizes correctly with missing values", {

  set.seed(123)

  fake_data <- matrix(rnorm(90), ncol = 3)

  fake_data[1:5, 1] <- NA
  fake_data[1:10, 2] <- NA

  result <- Best_model(fake_data)

  expect_equal(result$atsite.models$size[1], 25)
  expect_equal(result$atsite.models$size[2], 20)
  expect_equal(result$atsite.models$size[3], 30)
})

test_that("Best_model works with a single site", {

  set.seed(123)

  fake_data <- matrix(rnorm(50), ncol = 1)

  result <- Best_model(fake_data)

  expect_equal(
    nrow(result$atsite.models),
    1
  )

  expect_true(
    result$best %in% 1:4
  )
})

test_that("Best_model returns an integer model index", {

  set.seed(123)

  fake_data <- matrix(rnorm(120), ncol = 4)

  result <- Best_model(fake_data)

  expect_true(
    is.numeric(result$best)
  )

  expect_equal(
    length(result$best),
    1
  )

  expect_true(
    result$best %in% 1:4
  )
})
