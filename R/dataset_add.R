#' dataset_add
#'
#' @param dataset
#' A numeric matrix with extreme air temperature data from multiple sites.
#'   The first column must contain the years, and the remaining columns contain
#'   temperature data from each site.
#' @returns
#' A `list` object with the following elements:
  #' \describe{
  #'   \item{scaled_data}{A matrix of centered temperature values for each site.}
#'   \item{reg_mean}{Mean temperature values for each site.}
#'  }
#' @export
#' @examples
#'
#' dataset <- dataset
#' dataset.add <- dataset_add(dataset)
#'
dataset_add <- function(dataset) {

  if (anyNA(dataset[, 1])) {
    stop("Column 'Years' cannot have missing data.")
  }
  n <- ncol(dataset)
  dataset.year <- dataset[, 2:n]
  add_data <- dataset.year
  n <- ncol(dataset.year)
  if (n < 3) {
    stop("The number of sites should be larger than 2.")
  }

  min_sample_size <- min(colSums(!is.na(dataset.year)))

  if (min_sample_size < 10) {
    stop("All sites must have at least 10 years of records. So sorry, we cannot proceed.")
  }

  reg_mean <- apply(dataset.year, 2, mean, na.rm = TRUE)
  for (site in 1:n){
    add_data[,site] <- dataset.year[,site] - as.numeric(reg_mean[site])
  }
  return(list(add_data = add_data,
              reg_mean = reg_mean))
}
