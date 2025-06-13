test_that("Add_Discord returns expected structure", {
  set.seed(123)
  years <- 1980:2020
  temp_data <- matrix(rnorm(length(years) * 8, mean = 30, sd = 5), ncol = 8)
  dataset <- cbind(Years = years, temp_data)

  result <- Add_Discord(dataset)

  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), 9)
  expect_named(result, c("Local", "SampleSize", "l_1", "l_2", "t_3", "t_4", "t_5", "discord", "Rdiscord"))
  expect_equal(nrow(result), 8)
})

test_that("Add_Discord throws error when Years column has NAs", {
  set.seed(123)
  years <- c(1980:2020); years[5] <- NA
  temp_data <- matrix(rnorm(length(years) * 8, mean = 30, sd = 5), ncol = 8)
  dataset <- cbind(Years = years, temp_data)

  expect_error(Add_Discord(dataset), "Column 'Years' cannot have missing data")
})

test_that("Add_Discord throws error when less than 7 sites", {
  years <- 1980:2020
  temp_data <- matrix(rnorm(length(years) * 6, mean = 30, sd = 5), ncol = 6)
  dataset <- cbind(Years = years, temp_data)

  expect_error(Add_Discord(dataset), "The number of sites should be at least 7")
})

test_that("Add_Discord throws error when any site has fewer than 10 observations", {
  years <- 1980:2020
  temp_data <- matrix(rnorm(length(years) * 8, mean = 30, sd = 5), ncol = 8)
  temp_data[1:32, 3] <- NA  # 41 - 32 = 9 valid values in site 3
  dataset <- cbind(Years = years, temp_data)

  expect_error(Add_Discord(dataset), "All sites must have at least 10 years of records")
})

test_that("Discord measures are non-negative", {
  years <- 1980:2020
  temp_data <- matrix(rnorm(length(years) * 8, mean = 30, sd = 5), ncol = 8)
  dataset <- cbind(Years = years, temp_data)

  result <- Add_Discord(dataset)
  expect_true(all(result$discord >= 0))
  expect_true(all(result$Rdiscord >= 0))
})
