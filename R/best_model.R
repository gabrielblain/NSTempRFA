#' Time-varying parameters of the best fitted GEV model
#'
#' This function fits six time-varying GEV models (with different assumptions
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
#'     Index (1--6) of the model with the lowest total AICc across all sites.
#'   }
#'   \item{atsite.models}{
#'     Data frame containing the estimated parameters
#'     (`mu0`, `mu1`, `mu2`, `sigma0`, `sigma1`, `shape`)
#'     and sample size for each site. Parameters that are not part of the
#'     selected model are set to zero.
#'   }
#' }
#'
#' @details
#' Model fitting is performed via `ismev::gev.fit()`.  Six models
#' are considered, where location is mu(t) = mu0 + mu1 * t + mu2 * t^2 and
#' scale is sigma(t) = sigma0 + sigma1 * t:
#' \enumerate{
#'   \item Stationary (constant location and scale).
#'   \item Linear time-varying location only.
#'   \item Linear time-varying scale only.
#'   \item Linear time-varying location and scale.
#'   \item Quadratic time-varying location only, GEV(2,0,0).
#'   \item Quadratic time-varying location and linear time-varying scale,
#'   GEV(2,1,0).
#' }
#' For each site the function tries up to five optimisation methods
#' (`Nelder-Mead`, `BFGS`, `CG`, `L-BFGS-B`, `SANN`)
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
  n.models <- length(GEV_MODEL_SPECS)
  all_pars <- lapply(
    seq_len(n.models),
    function(m) matrix(NA_real_, n.sites, N_PARS)
  )
  aic_mat <- matrix(Inf, n.sites, n.models)
  sizes <- integer(n.sites)

  for (i in seq_len(n.sites)) {
    local <- na.omit(add.data[, i])
    sizes[i] <- length(local)
    if (sizes[i] == 0L) {
      next
    }

    fit <- spsUtil::quiet(fit.models(local, seq_len(sizes[i])))

    aic_mat[i, ] <- fit$at.site.AIC
    for (m in seq_len(n.models)) {
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
    "mu2",
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

# Columns of ydat passed to ismev::gev.fit(): column 1 = t, column 2 = t^2.
# `mul` / `sigl` are column indices of ydat.
#' @noRd
GEV_MODEL_SPECS <- list(
  list(mul = NULL, sigl = NULL), # 1: GEV(0,0,0)
  list(mul = 1L, sigl = NULL),   # 2: GEV(1,0,0)
  list(mul = NULL, sigl = 1L),   # 3: GEV(0,1,0)
  list(mul = 1L, sigl = 1L),     # 4: GEV(1,1,0)
  list(mul = 1:2, sigl = NULL),  # 5: GEV(2,0,0)
  list(mul = 1:2, sigl = 1L)     # 6: GEV(2,1,0)
)

# Number of slots in the full parameter vector:
# (mu0, mu1, mu2, sigma0, sigma1, shape)
#' @noRd
N_PARS <- 6L

# Positional indices into the 6-element parameter vector that each model's
# MLE fills (gev.fit returns: location coefs, scale coefs, shape).
# Slots absent from a model are fixed at zero.
#' @noRd
GEV_PAR_MAP <- list(
  c(1L, 4L, 6L),                # 1: mu0, sigma0, shape
  c(1L, 2L, 4L, 6L),           # 2: mu0, mu1, sigma0, shape
  c(1L, 4L, 5L, 6L),           # 3: mu0, sigma0, sigma1, shape
  c(1L, 2L, 4L, 5L, 6L),       # 4: mu0, mu1, sigma0, sigma1, shape
  c(1L, 2L, 3L, 4L, 6L),       # 5: mu0, mu1, mu2, sigma0, shape
  c(1L, 2L, 3L, 4L, 5L, 6L)    # 6: all parameters
)

# Number of estimated parameters in each model (used in AICc)
#' @noRd
GEV_K_VALS <- c(3L, 4L, 4L, 5L, 5L, 6L)

#' @noRd
OPTIM_METHODS <- c("Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN")


# -----------------------------------------------------------------------------
# Internal: fit one GEV model, cycling through optimisers until one succeeds.
# Returns the fit object or NULL on total failure.
# -----------------------------------------------------------------------------
#' @noRd
try_model <- function(local, time, model_id) {
  spec <- GEV_MODEL_SPECS[[model_id]]
  ydat <- cbind(time, time^2)

  for (method in OPTIM_METHODS) {
    result <- try(
      {
        fit <- ismev::gev.fit(
          local,
          ydat = cbind(time, time^2),
          mul = spec$mul,
          sigl = spec$sigl,
          shl = NULL,
          mulink = identity,
          siglink = exp,                          # was: identity
          shlink = identity,
          siginit = gev_siginit(local, spec),     # new
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
# Internal: extract a 6-element parameter vector from a fitted model,
# placing MLE estimates in the correct slots and zeroing the rest.
# -----------------------------------------------------------------------------
#' @noRd
extract_pars <- function(model, model_id) {
  if (is.null(model)) {
    return(rep(NA_real_, N_PARS))
  }
  out <- numeric(N_PARS)
  out[GEV_PAR_MAP[[model_id]]] <- model$mle
  out[4L] <- exp(out[4L]) # sigma0 is now the scale itself, not its log
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
# Internal: fit all six GEV models to one site and return parameters + AICc.
# -----------------------------------------------------------------------------
#' @noRd
fit.models <- function(local, time) {
  n <- length(local)
  ids <- seq_along(GEV_MODEL_SPECS)
  models <- lapply(ids, try_model, local = local, time = time)

  list(
    pars = lapply(ids, function(i) extract_pars(models[[i]], i)),
    at.site.AIC = mapply(safe_AICc, models, GEV_K_VALS, MoreArgs = list(n = n))
  )
}
