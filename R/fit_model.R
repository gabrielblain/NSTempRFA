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
#' sigma(t) = exp(`sigma0` + `sigma1` * t), so `sigma0` and `sigma1` are
#' coefficients on the log scale (in models with constant scale,
#' `sigma0` is the log of the scale parameter).
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
# returning a 6-element numeric parameter vector or NULL on failure.
# Replaces fit_gev_ismev() + fit_gev_alt() + fit_gev().
# -----------------------------------------------------------------------------
#' @noRd
fit_gev_single <- function(local, time, model_id, method) {
  spec <- GEV_MODEL_SPECS[[model_id]]

  fit <- try(
    spsUtil::quiet(
      ismev::gev.fit(
        local,
        ydat = cbind(time, time^2),
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

  extract_pars(fit, model_id) # defined in best_model.R
}

# -----------------------------------------------------------------------------
# Internal: try each optimiser in turn; return the first success or NA vector.
# -----------------------------------------------------------------------------
#' @noRd
fit_gev_site <- function(local, time, model_id) {
  for (method in OPTIM_METHODS) {
    result <- fit_gev_single(local, time, model_id, method)
    if (!is.null(result)) return(result)
  }
  rep(NA_real_, 6)
}
