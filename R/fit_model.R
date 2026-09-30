#' Time-varying parameters of a given GEV model
#'
#' @param temperatures
#' A vector or single-column matrix of air temperature data, either original
#' or centered by subtracting the sample mean.
#'
#' @param model
#' A single integer between 1 and 6 defining the GEV model
#' (see `Best_model()` for the description of each model).
#' May be provided by `Best_model()`.
#'
#' @returns
#' A `data.frame` containing the estimated parameters
#' (`mu0`, `mu1`, `mu2`, `sigma0`, `sigma1`, `shape`, `size`).
#' The location is mu(t) = `mu0` + `mu1` * t + `mu2` * t^2 and the scale is
#' sigma(t) = `sigma0` * exp(`sigma1` * t), where t = 1, 2, ..., `size`.
#' Thus `sigma0` is the scale at t = 0 and `sigma1` is the log rate of
#' change of the scale (`sigma1` = 0 means a constant scale).
#' Parameters that are not part of the selected model are set to
#' zero. If fitting fails for a site, `NA`s are returned for
#' that site.
#'
#' @details
#' The function attempts to fit the model using `ismev::gev.fit()` with
#' a log link for the scale parameter (which keeps the scale positive at all
#' times) and the following optimisers in sequence:
#' `Nelder-Mead`, `BFGS`, `CG`, `L-BFGS-B`, `SANN`.
#' The first optimiser that converges is used; if all fail, `NA`s are
#' returned for that site.
#' Internally, the series is centred on its mean and a standardised time
#' variable is used to reduce the collinearity between t and t^2.  The
#' estimates are converted back to the original units and to the original
#' time index, so `mu0` is expressed in the same units as `temperatures`.
#'
#' @importFrom ismev gev.fit
#' @importFrom stats na.omit var
#' @importFrom spsUtil quiet
#' @export
#'
#' @examples
#' temperatures <- TmaxCPC_SP$Pixel_1
#' model <- 4
#' Fit_model(temperatures, model)
#'
#' # Quadratic time-varying location and log-linear time-varying scale
#' Fit_model(temperatures, model = 6)
Fit_model <- function(temperatures, model) {
  if (length(temperatures) == 0) {
    stop("`temperatures` cannot be empty.", call. = FALSE)
  }

  if (!is.numeric(temperatures)) {
    stop("`temperatures` must be a numeric vector or matrix.", call. = FALSE)
  }

  check_model(model) # defined in input_checks.R

  temperatures <- as.matrix(temperatures)
  n.sites <- ncol(temperatures)
  sizes <- integer(n.sites)
  par_mat <- matrix(NA_real_, n.sites, 6)

  for (i in seq_len(n.sites)) {
    local <- na.omit(temperatures[, i, drop = TRUE])
    sizes[i] <- length(local)
    if (sizes[i] == 0L) {
      next
    }

    par_mat[i, ] <- fit_gev_site(local, seq_len(sizes[i]), model_id = model)
  }

  out <- as.data.frame(par_mat)
  out$size <- sizes
  colnames(out) <- c("mu0", "mu1", "mu2", "sigma0", "sigma1", "shape", "size")
  out
}

# -----------------------------------------------------------------------------
# Internal: starting values for the scale coefficients on the log scale.
# The intercept starts at log of the Gumbel moment estimate of the scale and
# the trend coefficient (if any) at zero.  Also used by try_model().
# -----------------------------------------------------------------------------
#' @noRd
gev_siginit <- function(local, spec) {
  sig0 <- log(sqrt(6 * stats::var(local)) / pi)
  if (!is.finite(sig0)) {
    sig0 <- 0
  }
  if (is.null(spec$sigl)) sig0 else c(sig0, 0)
}


# -----------------------------------------------------------------------------
# Internal: call ismev::gev.fit() for a given model and optimiser,
# returning a 6-element numeric parameter vector (referring to the original
# time index) or NULL on failure.
# Replaces fit_gev_ismev() + fit_gev_alt() + fit_gev().
# -----------------------------------------------------------------------------
#' @noRd
fit_gev_single <- function(local, time, model_id, method) {
  spec <- GEV_MODEL_SPECS[[model_id]]
  st <- scale_time(time) # defined in Best_model.R

  fit <- try(
    spsUtil::quiet(
      ismev::gev.fit(
        local,
        ydat = cbind(st$z, st$z^2),
        mul = spec$mul,
        sigl = spec$sigl,
        shl = NULL,
        mulink = identity,
        siglink = exp,
        shlink = identity,
        siginit = gev_siginit(local, spec),
        show = FALSE,
        method = method,
        maxit = 10000L
      )
    ),
    silent = TRUE
  )

  if (inherits(fit, "try-error") || is.null(fit) || is.null(fit$mle)) {
    return(NULL)
  }

  # defined in Best_model.R
  unscale_pars(extract_pars(fit, model_id), st$centre, st$spread)
}


# -----------------------------------------------------------------------------
# Internal: try each optimiser in turn; return the first success or NA vector.
# The series is centred before fitting (so that raw and centred inputs start
# the optimiser from equivalent points) and the mean is added back to mu0.
# -----------------------------------------------------------------------------
#' @noRd
fit_gev_site <- function(local, time, model_id) {
  centre <- mean(local)
  local_c <- local - centre

  for (method in OPTIM_METHODS) {
    result <- fit_gev_single(local_c, time, model_id, method)
    if (!is.null(result)) {
      result[1L] <- result[1L] + centre # mu0 back in the input's units
      return(result)
    }
  }
  rep(NA_real_, 6)
}
