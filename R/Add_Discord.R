#' Discordance measures calculated from the additive approach
#'
#' This function calculates the Hosking and Wallis' discordance measure (discord) and
#' the robust discordance measure (Neykov et al. 2007) <10.1029/2006WR005322> using
#' the additive approach proposed in Martins et al. (2022) <doi:10.1590/1678-4499.20220061>.
#'
#' @param dataset A numeric matrix with extreme air temperature data from multiple sites.
#'   The first column must contain the years, and the remaining columns contain
#'   temperature data from each site.
#'
#' @returns A `data.frame` with 9 columns:
#' \describe{
#'     \item{Local}{Site identifier.}
#'     \item{SampleSize}{Number of observations for each site.}
#'     \item{l_1}{L-moment ratio (mean).}
#'     \item{l_2}{L-moment ratio (L-scale).}
#'     \item{t_3}{L-moment ratio (L-skewness).}
#'     \item{t_4}{L-moment ratio (L-kurtosis).}
#'     \item{t_5}{L-moment ratio (higher-order L-moment).}
#'     \item{discord}{Original discordance statistic indicating potential outlier status.}
#'     \item{Rdiscord}{Robust discordance statistic indicating potential outlier status.}
#' }
#'
#' @details The discordance measures identify sites that are potentially discordant
#'   within a regional frequency analysis framework for extreme air temperature series.
#'
#' @export
#' @importFrom lmomRFA regsamlmu
#' @importFrom rrcov getDistance Cov CovMcd
#'
#' @examples
#' # d <- Add_Discord(dataset)
Add_Discord <- function(dataset) {
  if (anyNA(dataset[, 1])) {
    stop("Column 'Years' cannot have missing data.")
  }
  n <- ncol(dataset)
  dataset.year <- dataset[, 2:n]
  n <- ncol(dataset.year)
  if (n < 7) {
    stop("The number of sites should be at least 7.")
  }

  min_sample_size <- min(colSums(!is.na(dataset.year)))

  if (min_sample_size < 10) {
    stop("All sites must have at least 10 years of records. So sorry, we cannot proceed.")
  }

  n.sites <- n - 1
  d <- as.data.frame(matrix(NA, n.sites, 9))
  d[, 1:7] <- regsamlmu(dataset.year, lcv = FALSE)
  d[, 8] <- sqrt(getDistance(Cov(d[, 4:6])))
  d[, 9] <- sqrt(getDistance(CovMcd(d[, 4:6])))
  colnames(d) <- c("Local", "SampleSize", "l_1", "l_2", "t_3", "t_4", "t_5", "discord", "Rdiscord")

  return(d)
}
