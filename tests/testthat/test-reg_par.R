test_that("Reg_par returns expected output for valid input", {
  # Create a simple mock best_model data frame
  best_model_df <- data.frame(
    mu0 = c(1, 2, 3),
    mu1 = c(0.1, 0.2, 0.3),
    sigma0 = c(5, 6, 7),
    sigma1 = c(0.5, 0.6, 0.7),
    shape = c(0.2, 0.3, 0.4),
    size = c(10, 20, 30)
  )

  result <- Reg_par(best_model_df)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("weighted_mu0", "weighted_mu1", "weighted_sigma0", "weighted_sigma1", "weighted_shape"))
  expect_true(all(sapply(result, is.numeric)))
})

test_that("Reg_par throws error if input is not a data frame", {
  expect_error(Reg_par(matrix(1:10, ncol = 2)), "must be a data frame")
})

test_that("Reg_par throws error if required columns are missing", {
  incomplete_df <- data.frame(mu0 = 1:3, mu1 = 1:3)  # Missing other columns
  expect_error(Reg_par(incomplete_df), "must contain the columns")
})

test_that("Reg_par throws error if columns are non-numeric", {
  bad_df <- data.frame(
    mu0 = c(1, 2, 3),
    mu1 = c(0.1, 0.2, 0.3),
    sigma0 = c(5, 6, 7),
    sigma1 = c(0.5, 0.6, 0.7),
    shape = c("a", "b", "c"),  # Non-numeric
    size = c(10, 20, 30)
  )
  expect_error(Reg_par(bad_df), "must be numeric")
})

test_that("Reg_par throws error if size column contains NA", {
  df_with_na <- data.frame(
    mu0 = c(1, 2, 3),
    mu1 = c(0.1, 0.2, 0.3),
    sigma0 = c(5, 6, 7),
    sigma1 = c(0.5, 0.6, 0.7),
    shape = c(0.2, 0.3, 0.4),
    size = c(10, NA, 30)
  )
  expect_error(Reg_par(df_with_na), "Invalid or missing values in 'size'")
})

test_that("Reg_par throws error if total size is zero", {
  df_zero_size <- data.frame(
    mu0 = c(1, 2, 3),
    mu1 = c(0.1, 0.2, 0.3),
    sigma0 = c(5, 6, 7),
    sigma1 = c(0.5, 0.6, 0.7),
    shape = c(0.2, 0.3, 0.4),
    size = c(0, 0, 0)
  )
  expect_error(Reg_par(df_zero_size), "Invalid or missing values in 'size'")
})
