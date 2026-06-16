#' Discordance measures calculated from the additive approach
#'
#' This function calculates the Hosking and Wallis' discordance measure (discord) and
#' the robust discordance measure (Neykov et al. 2007) <doi:10.1029/2006WR005322> using
#' the additive approach proposed in Martins et al. (2022) <doi:10.1590/1678-4499.20220061>.
#'
#' @param dataset A numeric matrix with extreme air temperature data from multiple sites.
#'   The first column must contain the years, and the remaining columns contain
#'   temperature data from each site.
#'
#' @returns A `data.frame` with 8 columns:
#' \describe{
#'     \item{Local}{Site identifier.}
#'     \item{SampleSize}{Number of observations for each site.}
#'     \item{l_1}{First L-moment (mean).}
#'     \item{l_2}{Second L-moment (L-scale).}
#'     \item{t_3}{L-skewness ratio.}
#'     \item{t_4}{L-kurtosis ratio.}
#'     \item{t_5}{Fifth-order L-moment ratio.}
#'     \item{discord}{Original discordance statistic indicating potential outlier status.}
#' }
#'
#' @details The discordance measures identify sites that are potentially discordant
#'   within a regional frequency analysis framework for extreme air temperature series.
#'
#' @export
#' @importFrom lmomRFA regsamlmu
#' @importFrom rrcov getDistance Cov
#'
#' @examples
#' # Add_Discord(TmaxCPC_SP)
Add_Discord <- function(dataset) {

  if (ncol(dataset) < 2) {
    stop("The dataset must contain a year column and at least one site.")
  }

  if (anyNA(dataset[, 1])) {
    stop("Column 'Years' cannot have missing data.")
  }

  n_total <- ncol(dataset)

  dataset.year <- dataset[, 2:n_total, drop = FALSE]

  n_sites <- ncol(dataset.year)

  if (n_sites < 3) {
    stop("The number of sites should be at least 3.")
  }

  min_sample_size <- min(colSums(!is.na(dataset.year)))

  if (min_sample_size < 10) {
    stop("All sites must have at least 10 years of records.")
  }

  d <- as.data.frame(matrix(NA_real_, n_sites, 8))

  d[, 1:7] <- regsamlmu(dataset.year, lcv = FALSE)
  d[, 8] <- sqrt(getDistance(Cov(d[, 4:6])))

  colnames(d) <- c(
    "Local", "SampleSize",
    "l_1", "l_2", "t_3", "t_4", "t_5",
    "discord"
  )

  return(d)
}
