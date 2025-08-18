test_that("Dataset_add returns correct output structure and values", {
  # Create a small example dataset
  years <- 1991:2000
  site_data <- matrix(c(
    30, 31, 29, 32, 33, 30, 31, 32, 30, 29,
    28, 29, 27, 30, 31, 28, 29, 30, 28, 27,
    33, 34, 32, 35, 36, 33, 34, 35, 33, 32,
    31, 32, 30, 33, 34, 31, 32, 33, 31, 30,
    29, 30, 28, 31, 32, 29, 30, 31, 29, 28,
    27, 28, 26, 29, 30, 27, 28, 29, 27, 26,
    32, 33, 31, 34, 35, 32, 33, 34, 32, 31
  ), ncol = 7)

  dataset <- cbind(years, site_data)

  # Run the function
  result <- Dataset_add(dataset)

  # Check structure
  expect_type(result, "list")
  expect_named(result, c("add_data", "reg_mean"))
  expect_true(is.matrix(result$add_data))
  expect_length(result$reg_mean, 7)

  # Check that each site's column mean of add_data is approximately zero
  site_means <- colMeans(result$add_data, na.rm = TRUE)
  expect_true(all(abs(site_means) < 1e-10))
})

test_that("Dataset_add throws error when Years column contains NA", {
  dataset_with_na <- matrix(1:80, ncol = 8)
  dataset_with_na[1, 1] <- NA
  expect_error(Dataset_add(dataset_with_na), "Column 'Years' cannot have missing data.")
})

test_that("Dataset_add throws error when fewer than 3 sites are provided", {
  dataset_few_sites <- matrix(1:30, ncol = 3) # Only 4 sites + 1 year column = 5 columns
  expect_error(Dataset_add(dataset_few_sites), "The number of sites should be larger than 2.")
})

test_that("Dataset_add throws error when any site has fewer than 10 non-NA records", {
  years <- 1991:2000
  site_data <- matrix(NA, ncol = 7, nrow = 10)
  site_data[, 1:6] <- 30 # Enough data for 6 sites
  site_data[1:9, 7] <- 30 # Only 9 valid years for site 7 (should trigger error)
  dataset <- cbind(years, site_data)
  expect_error(Dataset_add(dataset), "at least 10 years of records")
})
