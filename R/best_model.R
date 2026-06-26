#' Time-varying parameters of the best fitted GEV model
#'
#' This function fits four time-varying GEV models (with different assumptions
#' on non-stationarity in location and/or scale) to each temperature series,
#' computes the AICc of each model, and selects the best one according to the
#' lowest total AICc.
#'
#' @param add.data
#' A numeric matrix of air temperature data as calculated by `Dataset_add()`.
#'
#' @returns
#' A list with:
#' \describe{
#'   \item{best}{
#'     Index (1--4) of the model with the lowest total AICc across all sites.
#'   }
#'   \item{atsite.models}{
#'     Data frame containing the estimated parameters
#'     (\code{mu0}, \code{mu1}, \code{sigma0}, \code{sigma1}, \code{shape})
#'     and sample size for each site.
#'   }
#' }
#'
#' @details
#' Model fitting is performed via \code{ismev::gev.fit()}.  Four nested models
#' are considered:
#' \enumerate{
#'   \item Stationary (constant location and scale).
#'   \item Time-varying location only.
#'   \item Time-varying scale only.
#'   \item Time-varying location and scale.
#' }
#' For each site the function tries up to five optimisation methods
#' (\code{Nelder-Mead}, \code{BFGS}, \code{CG}, \code{L-BFGS-B}, \code{SANN})
#' and uses the first that converges.  Model selection is based on the sum of
#' site-level AICc values.
#'
#' @importFrom ismev gev.fit
#' @importFrom stats na.omit
#' @importFrom spsUtil quiet
#' @export
#'
#' @examples
#' add.data <- Dataset_add(TmaxCPC_SP)
#' best.parms <- Best_model(add.data = add.data$add_data)

Best_model <- function(add.data) {
  if (!is.matrix(add.data) && !is.data.frame(add.data)) {
    stop("Input 'add.data' must be a matrix or data frame.", call. = FALSE)
  }

  add.data <- as.matrix(add.data)

  if (ncol(add.data) < 1L) {
    stop("'add.data' must contain at least one site.", call. = FALSE)
  }

  if (min(colSums(!is.na(add.data))) < 10L) {
    stop("All sites must have at least 10 observations.", call. = FALSE)
  }

  n.sites <- ncol(add.data)
  all_pars <- lapply(1:4, function(m) matrix(NA_real_, n.sites, 5))
  aic_mat <- matrix(Inf, n.sites, 4)
  sizes <- integer(n.sites)

  for (i in seq_len(n.sites)) {
    local <- na.omit(add.data[, i])
    sizes[i] <- length(local)
    if (sizes[i] == 0L) {
      next
    }

    fit <- spsUtil::quiet(fit.models(local, seq_len(sizes[i])))

    aic_mat[i, ] <- fit$at.site.AIC
    for (m in 1:4) {
      all_pars[[m]][i, ] <- fit$pars[[m]]
    }
  }

  total_AIC <- colSums(aic_mat, na.rm = TRUE)

  if (all(is.infinite(total_AIC))) {
    stop("All model fits failed.", call. = FALSE)
  }

  best <- which.min(total_AIC)
  atsite.models <- as.data.frame(all_pars[[best]])
  atsite.models$size <- sizes
  colnames(atsite.models) <- c(
    "mu0",
    "mu1",
    "sigma0",
    "sigma1",
    "shape",
    "size"
  )

  list(best = best, atsite.models = atsite.models)
}

# =============================================================================
# Best_model.R
# Internal helpers
# =============================================================================

# -----------------------------------------------------------------------------
# Package-level constants — defined once, referenced everywhere
# -----------------------------------------------------------------------------

#' @noRd
GEV_MODEL_SPECS <- list(
  list(mul = NULL, sigl = NULL),
  list(mul = 1L, sigl = NULL),
  list(mul = NULL, sigl = 1L),
  list(mul = 1L, sigl = 1L)
)

# Positional indices into the 5-element parameter vector
# (mu0, mu1, sigma0, sigma1, shape) that each model's MLE fills.
# Slots absent from a model are fixed at zero.
#' @noRd
GEV_PAR_MAP <- list(
  c(1L, 3L, 5L),
  c(1L, 2L, 3L, 5L),
  c(1L, 3L, 4L, 5L),
  c(1L, 2L, 3L, 4L, 5L)
)

#' @noRd
GEV_K_VALS <- c(3L, 4L, 4L, 5L)

#' @noRd
OPTIM_METHODS <- c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN")


# -----------------------------------------------------------------------------
# Internal: fit one GEV model, cycling through optimisers until one succeeds.
# Returns the fit object or NULL on total failure.
# -----------------------------------------------------------------------------
#' @noRd
try_model <- function(local, time, model_id) {
  spec <- GEV_MODEL_SPECS[[model_id]]

  for (method in OPTIM_METHODS) {
    result <- try(
      {
        fit <- ismev::gev.fit(
          local,
          ydat = as.matrix(time),
          mul = spec$mul,
          sigl = spec$sigl,
          shl = NULL,
          mulink = identity,
          siglink = identity,
          shlink = identity,
          method = method,
          maxit = 10000L,
          show = FALSE
        )
        if (is.null(fit$mle)) {
          stop("Fit failed.", call. = FALSE)
        }
        return(fit)
      },
      silent = TRUE
    )

    if (!inherits(result, "try-error")) return(result)
  }

  NULL
}


# -----------------------------------------------------------------------------
# Internal: extract a 5-element parameter vector from a fitted model,
# placing MLE estimates in the correct slots and zeroing the rest.
# -----------------------------------------------------------------------------
#' @noRd
extract_pars <- function(model, model_id) {
  if (is.null(model)) {
    return(rep(NA_real_, 5))
  }
  out <- numeric(5)
  out[GEV_PAR_MAP[[model_id]]] <- model$mle
  out
}


# -----------------------------------------------------------------------------
# Internal: compute AICc, returning Inf when the fit is unusable.
# -----------------------------------------------------------------------------
#' @noRd
safe_AICc <- function(model, k, n) {
  nllh <- model$nllh
  if (is.null(nllh) || is.na(nllh) || n <= k + 1L) {
    return(Inf)
  }
  AIC <- 2 * k + 2 * nllh
  AIC + (2 * k * (k + 1L)) / (n - k - 1L)
}


# -----------------------------------------------------------------------------
# Internal: fit all four GEV models to one site and return parameters + AICc.
# -----------------------------------------------------------------------------
#' @noRd
fit.models <- function(local, time) {
  n <- length(local)
  models <- lapply(1:4, try_model, local = local, time = time)

  list(
    pars = lapply(1:4, function(i) extract_pars(models[[i]], i)),
    at.site.AIC = mapply(safe_AICc, models, GEV_K_VALS, MoreArgs = list(n = n))
  )
}
