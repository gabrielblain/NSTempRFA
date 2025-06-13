test_that("Add_RegQuant returns expected output for valid inputs", {
  prob <- c(0.8, 0.85, 0.9)
  reg_par <- data.frame(
    weighted_mu0 = 1,
    weighted_mu1 = 0.2,
    weighted_mu2 = -0.01,
    weighted_sigma0 = 0.5,
    weighted_sigma1 = 0.01,
    weighted_shape = 0.1
  )
  site_temp <- rnorm(50, mean = 20)
  Qt <- Add_RegQuant(prob = prob,
                     reg_par = reg_par,
                     site_temp = site_temp,
                     n.year = 10)

  expect_type(Qt, "double")
  expect_length(Qt, length(prob))
  expect_true(all(is.finite(Qt)))
})
