test_that("fit_model returns correct output structure for 15 sites", {
  # Simula um add_data com 15 sites e 100 anos (linhas)
  set.seed(123)
  add_data <- matrix(rnorm(1500), ncol = 15)

  result <- fit_model(add_data = add_data, model = 2)

  # Deve retornar data.frame
  expect_s3_class(result, "data.frame")

  # Deve ter 15 linhas (uma por site)
  expect_equal(nrow(result), 15)

  # Deve ter 7 colunas com nomes específicos
  expect_equal(ncol(result), 7)
  expect_named(result, c("mu0", "mu1", "mu2", "sigma0", "sigma1", "shape", "size"))
})

test_that("fit_model handles invalid model input", {
  add_data <- matrix(rnorm(1500), ncol = 15)

  # Testa para modelo não numérico
  expect_error(fit_model(add_data, model = "two"),
               "Model must be a single interger number from 1 to 6")

  # Testa para modelo fora do intervalo
  expect_error(fit_model(add_data, model = 7),
               "Model must be a single interger number from 1 to 6")
})

test_that("fit_model handles NA values within 15-site data", {
  # Criando um add_data com NAs
  add_data <- matrix(rnorm(1500), ncol = 15)
  add_data[1:10, 1] <- NA  # Coluna 1 com NAs
  add_data[20:30, 5] <- NA # Coluna 5 com NAs

  result <- fit_model(add_data, model = 1)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 15)
})

test_that("fit_model falls back to fitLmom when GMLE fails for some sites", {
  # Criar um dataset com sites onde o GMLE deve falhar (exemplo: colunas com poucos valores)
  add_data <- matrix(rnorm(1500), ncol = 15)

  # Fazendo alguns sites terem poucas observações válidas
  add_data[1:98, 3] <- NA
  add_data[1:95, 7] <- NA

  result <- fit_model(add_data, model = 1)

  # Continua retornando um data.frame de 15 linhas
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 15)
})

test_that("fit_model returns NA parameters if even Lmoments fail", {
  # Dados com todos os valores NA para todos os sites
  add_data <- matrix(NA, ncol = 15, nrow = 100)

  result <- fit_model(add_data, model = 1)

  # Todos os parâmetros dos 15 sites devem ser NA
  expect_true(all(is.na(result[, 1:6])))
  expect_equal(nrow(result), 15)
})
