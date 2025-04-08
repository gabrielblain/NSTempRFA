#' Discordance measure calculated from the additive approach
#'
#' This function calculates the Hosking and Wallis' discordance measure using an additive approach,
#' as proposed in Martins et al. (2022) <doi:10.1590/1678-4499.20220061>.
#' The discordance measure identifies sites that are potentially discordant within a regional
#' frequency analysis framework for extreme air temperature series.
#'
#' @param dataset
#' A numeric matrix with extreme air temperature data from multiple sites.
#' The first column must contain the years, and the remaining columns contain
#' temperature data from each site.
#' @returns
#' A `data.frame` with 8 columns:
#' \describe{
#'     \item{Local}{Site identifier.}
#'     \item{SampleSize}{Number of observations for each site.}
#'     \item{l_1}{L-moment ratio (mean).}
#'     \item{l_2}{L-moment ratio (L-scale).}
#'     \item{t_3}{L-moment ratio (L-skewness).}
#'     \item{t_4}{L-moment ratio (L-kurtosis).}
#'     \item{t_5}{L-moment ratio (higher-order L-moment).}
#'     \item{discord}{Discordance statistic indicating potential outlier status.}
#'   }
#'
#' @details The discordance measure is computed using the squared Mahalanobis distance
#'   between the site's L-moment ratios and the regional average, based on the additive
#'   approach to regional frequency analysis.
#'
#' @export
#' @importFrom lmomRFA regsamlmu
#' @importFrom rrcov   getDistance Cov
#' @examples
#'
#' dataset <- dataset
#' d <- Add_Discord(dataset)
#'
Add_Discord <- function(dataset) {
  n <- ncol(dataset)
  n.sites <- n - 1
  d <- as.data.frame(matrix(NA, n.sites, 8))
  dataset.year <- dataset[, 2:n]
  d[, 1:7] <- regsamlmu(dataset.year, lcv = FALSE)
  d[, 8] <- sqrt(getDistance(Cov(d[, 4:6])))

  colnames(d) <- c("Local", "SampleSize", "l_1", "l_2", "t_3", "t_4", "t_5", "discord")
  return(d)
}
