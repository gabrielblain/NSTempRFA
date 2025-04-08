#' dataset_add
#'
#' @param dataset
#' A numeric matrix with extreme air temperature data from multiple sites.
#'   The first column must contain the years, and the remaining columns contain
#'   temperature data from each site.
#' @returns
#' A `list` object with the following elements:
  #' \describe{
  #'   \item{scaled_data}{A matrix of standardized (z-score) temperature values for each site.}
#'   \item{reg_mean}{Mean temperature values for each site.}
#'   \item{reg_sd}{Standard deviation of temperature values for each site.}
#'  }
#' @export
#' @importFrom stats sd
#' @examples
#'
#' dataset <- dataset
#' dataset_add <- dataset_add(dataset)
#'
dataset_add <- function(dataset) {
  n <- ncol(dataset)
  scaled_data <- dataset[,-c(1)]
  reg_mean <- apply(dataset[2:n], 2, mean, na.rm = TRUE)
  reg_sd <- apply(dataset[2:n], 2, sd, na.rm = TRUE)
  for (site in 2:n){
    scaled_data[,(site-1)] <- as.numeric(scale(dataset[,site]))
  }
  return(list(scaled_data = scaled_data,
              reg_mean = reg_mean,
              reg_sd = reg_sd))
}
