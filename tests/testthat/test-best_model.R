test_that("Best_model returns correct structure", {
  # Generate a small fake dataset (10 years, 3 sites)
  set.seed(123)
  fake_data <- matrix(rnorm(30), ncol = 3)

  # Run the function
  result <- Best_model(fake_data)

  # Check that result is a list with 2 elements
  expect_type(result, "list")
  expect_named(result, c("best", "atsite.models"))

  # Check that 'best' is an integer between 1 and 4
  expect_type(result$best, "integer")
  expect_true(result$best >= 1 && result$best <= 4)

  # Check that 'atsite.models' is a data frame with correct columns
  expect_s3_class(result$atsite.models, "data.frame")
  expect_equal(ncol(result$atsite.models), 6)
  expect_equal(colnames(result$atsite.models),
               c("mu0", "mu1", "sigma0", "sigma1", "shape", "size"))

  # Check dimensions: number of rows = number of sites
  expect_equal(nrow(result$atsite.models), ncol(fake_data))
})

test_that("Best_model handles NA rows (sites with all missing data)", {
  set.seed(123)
  data_with_na <- matrix(rnorm(30), ncol = 3)
  data_with_na[,1] <- NA  # First site entirely NA

  result <- Best_model(data_with_na)

  # The size column for site 1 should be 0
  expect_equal(result$atsite.models$size[1], 0)

  # The rest of the sites should still have non-NA sizes
  expect_true(all(result$atsite.models$size[-1] > 0))
})

test_that("Best_model throws error with non-numeric input", {
  expect_error(Best_model("not a matrix"), "must be a matrix or data frame")
})
