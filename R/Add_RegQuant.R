#' Regional Quantile Estimation for a Site Using Time-Varying GEV Parameters
#'
#' Computes quantiles for a given site based on regional GEV parameters and
#' a time-varying location and scale model. The estimated quantiles are adjusted
#' by the site's mean temperature.
#'
#' @param prob A numeric vector of probabilities (values strictly between 0 and 1) with no missing data.
#' @param regional_pars A 1-row, 5-column matrix or data frame containing the regional GEV parameters:
#' location intercept, location slope, scale intercept, scale slope, and shape.
#' @param site_temp A numeric vector or 1-column matrix of site's air temperature time series.
#' @param n.year A single integer indicating the year (index) for which quantiles should be calculated.
#' Must be between 1 and the length of site_temp.
#'
#' @return A named numeric vector of adjusted regional quantiles for the specified year.
#' @export
#' @importFrom extRemes qevd
#'
#' @examples
#' prob <- c(0.8, 0.85, 0.90, 0.92, 0.93, 0.94, 0.95, 0.97, 0.99)
#' best_model <- best_sites
#' regional_pars <- reg_par(best_model = best_model)
#' RegQuant <- Add_RegQuant(
#'   prob = prob,
#'   regional_pars = regional_pars,
#'   site_temp = dataset$station1,
#'   n.year = 30
#' )
Add_RegQuant <- function(prob,
                         regional_pars,
                         site_temp,
                         n.year) {

  # === Input checks ===
  if (!is.numeric(prob) || any(is.na(prob)) || any(prob <= 0) || any(prob >= 1)) {
    stop("`prob` must be a numeric vector with values strictly between 0 and 1 and no missing data.")
  }

  regional_pars <- as.matrix(regional_pars)
  if (!is.numeric(regional_pars) || ncol(regional_pars) != 5 || nrow(regional_pars) != 1) {
    stop("`regional_pars` must be a numeric matrix or data frame with 5 columns and 1 row.")
  }

  site_temp <- as.numeric(site_temp)
  if (!is.numeric(site_temp) || length(site_temp) == 0 || any(is.na(site_temp))) {
    stop("`site_temp` must be a numeric vector or 1-column matrix with no missing values.")
  }

  if (!is.numeric(n.year) || length(n.year) != 1 || n.year < 1 || n.year > length(site_temp)) {
    stop("`n.year` must be a single integer between 1 and the length of `site_temp`.")
  }

  # === Core computation ===
  max_time <- length(site_temp)
  site_mean <- mean(site_temp, na.rm = TRUE)
  time_scaled <- scale(1L:max_time)[, 1]  # standardize time for trend modeling
  selected_time <- time_scaled[n.year]

  loc <- regional_pars[1] + regional_pars[2] * selected_time
  scale_val <- regional_pars[3] + regional_pars[4] * selected_time
  shape <- regional_pars[5]

  Qt <- extRemes::qevd(prob, loc = loc, scale = scale_val, shape = shape, type = "GEV")
  Qt_adj <- Qt + site_mean
  names(Qt_adj) <- paste0("Q", prob * 100)

  return(Qt_adj)
}
