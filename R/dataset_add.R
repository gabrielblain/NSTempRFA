#' dataset_add
#'
#' @param dataset
#' A numeric matrix with extreme air temperature data from multiple sites.
#' The first column must contain the years, and the remaining columns contain
#' temperature data from each site.
#'
#' @returns
#' A `list` object with the following elements:
#' \describe{
#'   \item{add_data}{A matrix of centered temperature values for each site.}
#'   \item{reg_mean}{Mean temperature values for each site.}
#' }
#'
#' @export
#' @examples
#' Dataset_add(TmaxCPC_SP)

Dataset_add <- function(dataset) {
  dataset.year <- check_dataset(dataset)
  reg_mean <- colMeans(dataset.year, na.rm = TRUE)
  add_data <- scale(dataset.year, center = reg_mean, scale = FALSE)
  list(add_data = add_data, reg_mean = reg_mean)
}
