#' Regional Quantile Estimation for a Site Using Time-Varying GEV Parameters
#'
#' Computes quantiles for a given site based on regional GEV parameters and
#' a time-varying location and scale model. Estimated quantiles are adjusted
#' by the site's mean temperature.
#'
#' @param prob
#' A numeric vector of probabilities strictly between 0 and 1, with no
#' missing values.
#' @param regional_pars
#' A 1-row, 5-column `matrix` or `data.frame` containing regional
#' GEV parameters: location intercept, location slope, scale intercept,
#' scale slope, and shape.
#' @param site_temp
#' A numeric vector or 1-column matrix of site air temperature data.
#' @param n.year
#' A single integer indicating the year index for which quantiles are
#' calculated. Must be between 1 and `length(site_temp)`.
#'
#' @returns
#' A named numeric vector of adjusted regional quantiles for the specified
#' year. Names are of the form `"Q90"`, `"Q95"``, etc.
#'
#' @export
#' @importFrom extRemes qevd
#'
#' @examples
#' prob <- c(0.90, 0.92, 0.93, 0.94, 0.95, 0.97, 0.99)
#' add.data <- Dataset_add(TmaxCPC_SP)
#' best.parms <- Best_model(add.data = add.data$add_data)
#' regional_pars <- Reg_par(best_model = best.parms$atsite.models)
#' Add_RegQuant(
#'   prob          = prob,
#'   regional_pars = regional_pars,
#'   site_temp     = TmaxCPC_SP$Pixel_1,
#'   n.year        = 34
#' )
Add_RegQuant <- function(prob, regional_pars, site_temp, n.year) {
  check_prob(prob) # defined in input_checks.R
  regional_pars <- check_reg_par(regional_pars) # reuses existing helper
  check_site_temp(site_temp) # defined in input_checks.R
  check_n.year(n.year, site_temp) # defined in input_checks.R

  loc <- regional_pars[1] + regional_pars[2] * n.year
  scale_val <- regional_pars[3] + regional_pars[4] * n.year
  shape <- regional_pars[5]

  if (scale_val <= 0) {
    stop("Calculated scale parameter must be positive.", call. = FALSE)
  }

  Qt <- extRemes::qevd(
    prob,
    loc = loc,
    scale = scale_val,
    shape = shape,
    type = "GEV"
  ) +
    mean(site_temp, na.rm = TRUE)

  names(Qt) <- paste0("Q", prob * 100)
  Qt
}
