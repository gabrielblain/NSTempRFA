#' Time-varying parameters of a given GEV model
#'
#' @param temperatures
#' A vector or single-column matrix of air temperature data, either original
#' or centered by subtracting the sample mean.
#'
#' @param model
#' A single integer between 1 and 4 defining the GEV model.
#' May be provided by \code{Best_model()}.
#'
#' @returns
#' A \code{data.frame} containing the estimated parameters
#' (\code{mu0}, \code{mu1}, \code{sigma0}, \code{sigma1}, \code{shape},
#' \code{size}).  If fitting fails for a site, \code{NA}s are returned for
#' that site.
#'
#' @details
#' The function attempts to fit the model using \code{ismev::gev.fit()} with
#' the following optimisers in sequence:
#' \code{Nelder-Mead}, \code{BFGS}, \code{CG}, \code{L-BFGS-B}, \code{SANN}.
#' The first optimiser that converges is used; if all fail, \code{NA}s are
#' returned for that site.
#'
#' @importFrom ismev gev.fit
#' @importFrom stats na.omit
#' @importFrom spsUtil quiet
#' @export
#'
#' @examples
#' temperatures <- TmaxCPC_SP$Pixel_1
#' model <- 4
#' Fit_model(temperatures, model)
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
  par_mat <- matrix(NA_real_, n.sites, 5)

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
  colnames(out) <- c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")
  out
}

# -----------------------------------------------------------------------------
# Internal: call ismev::gev.fit() for a given model and optimiser,
# returning a 5-element numeric parameter vector or NULL on failure.
# Replaces fit_gev_ismev() + fit_gev_alt() + fit_gev().
# -----------------------------------------------------------------------------
#' @noRd
fit_gev_single <- function(local, time, model_id, method) {
  spec <- GEV_MODEL_SPECS[[model_id]]

  fit <- try(
    spsUtil::quiet(
      ismev::gev.fit(
        local,
        ydat = as.matrix(time),
        mul = spec$mul,
        sigl = spec$sigl,
        shl = NULL,
        mulink = identity,
        siglink = identity,
        shlink = identity,
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
  rep(NA_real_, 5)
}
