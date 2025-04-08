#' dataset_mult
#'
#' @param dataset
#' A numeric matrix with extreme air temperature data from multiple sites.
#'   The first column must contain the years, and the remaining columns contain
#'   temperature data from each site.
#' @returns
#' A `list` object with the following elements:
#' \describe{
#'   \item{divided_data}{A matrix of temperature values for each site divided
#'   by their sample mean.}
#'   \item{reg_mean}{Sample mean temperature values for each site.}
#'  }
#' @export
#' @examples
#'
#' dataset <- dataset
#' dataset_mult <- dataset_mult(dataset)
#'
dataset_mult <- function(dataset) {
  n <- ncol(dataset)
  divided_data <- dataset[,-c(1)]
  reg_mean <- apply(dataset[2:n], 2, mean, na.rm = TRUE)
  for (site in 2:n){
    divided_data[,(site-1)] <- as.numeric(scale(dataset[,site]))
  }
  return(list(divided_data = divided_data,
              reg_mean = reg_mean))
}
