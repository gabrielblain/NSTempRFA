#' Simulated and Centered Extreme Air Temperature Data
#'
#' A simulated dataset of annual extreme air temperatures for 15 weather stations,
#' each centered by subtracting its sample mean. The values were generated from
#' a Generalized Extreme Value (GEV) distribution, with parameters fitted using
#' observed data from Ribeirão Preto, São Paulo, Brazil.
#'
#' The dataset was created using the `dataset_add()` function.
#'
#' @format A numeric matrix with 30 rows and 15 columns. Rows represent years,
#' and columns represent different weather stations. Some values are missing (NA).
#'
#' \describe{
#'   \item{station1–station15}{Centered annual extreme air temperature values for each station.}
#' }
#'
#' @source Simulated using the Generalized Extreme Value (GEV) distribution
#' fitted to observed data from Ribeirão Preto, Brazil.
"add_data"
