test_that("Fit_model returns correct output structure for 15 sites", {
  # Simula um temperatures com 15 sites e 100 anos (linhas)
  set.seed(123)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  result <- Fit_model(temperatures = temperatures, model = 2)

  # Deve retornar data.frame
  expect_s3_class(result, "data.frame")

  # Deve ter 15 linhas (uma por site)
  expect_equal(nrow(result), 15)

  # Deve ter 7 colunas com nomes específicos
  expect_equal(ncol(result), 6)
  expect_named(result, c("mu0", "mu1", "sigma0", "sigma1", "shape", "size"))
})

test_that("Fit_model handles invalid model input", {
  temperatures <- matrix(rnorm(1500), ncol = 15)

  # Testa para modelo não numérico
  expect_error(Fit_model(temperatures, model = "two"),
               "Model must be a single integer number from 1 to 4 defining the GEV model.")

  # Testa para modelo fora do intervalo
  expect_error(Fit_model(temperatures, model = 7),
               "Model must be a single integer number from 1 to 4 defining the GEV model.")
})

test_that("Fit_model handles NA values within 15-site data", {
  # Criando um temperatures com NAs
  temperatures <- matrix(rnorm(1500), ncol = 15)
  temperatures[1:10, 1] <- NA  # Coluna 1 com NAs
  temperatures[20:30, 5] <- NA # Coluna 5 com NAs

  result <- Fit_model(temperatures, model = 1)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 15)
})

test_that("Fit_model falls back to fitLmom when GMLE fails for some sites", {
  # Criar um dataset com sites onde o GMLE deve falhar (exemplo: colunas com poucos valores)
  temperatures <- matrix(rnorm(1500), ncol = 15)

  # Fazendo alguns sites terem poucas observações válidas
  temperatures[1:98, 3] <- NA
  temperatures[1:95, 7] <- NA

  result <- Fit_model(temperatures, model = 1)

  # Continua retornando um data.frame de 15 linhas
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 15)
})

test_that("Fit_model returns NA parameters if even Lmoments fail", {
  # Dados com todos os valores NA para todos os sites
  temperatures <- matrix(NA, ncol = 15, nrow = 100)

  result <- Fit_model(temperatures, model = 1)

  # Todos os parâmetros dos 15 sites devem ser NA
  expect_true(all(is.na(result[, 1:5])))
  expect_equal(nrow(result), 15)
})
