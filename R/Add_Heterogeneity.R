#' Add_Heterogeneity
#'
#' @param dataset.add
#' A numeric matrix of air temperature data as calculated by
#' \code{Dataset_add()}.
#' @param rho
#' A single numeric value describing the average inter-site correlation.
#' Must be strictly between -1 and 1.
#' @param Ns
#' Number of simulated groups of series. Default is 100; at least 500
#' is recommended.
#'
#' @returns
#' Hosking and Wallis' heterogeneity measure using an additive approach,
#' as proposed in Martins et al. (2022)
#' \doi{10.1590/1678-4499.20220061}.
#' Returns \code{NA} if the regional distribution cannot be fitted or if
#' simulated statistics have zero variance.
#'
#' @export
#' @importFrom lmomRFA regsamlmu
#' @importFrom lmom pelkap pelwak quakap quawak
#' @importFrom MASS mvrnorm
#' @importFrom stats pnorm sd
#' @importFrom Matrix nearPD
#'
#' @examples
#' add.data <- Dataset_add(TmaxCPC_SP)
#' Add_Heterogeneity(dataset.add = add.data$add_data, rho = 0.51, Ns = 500)
Add_Heterogeneity <- function(dataset.add, rho, Ns) {
  dataset.add <- check_heterogeneity_data(dataset.add) # input_checks.R
  check_rho(rho) # input_checks.R
  check_Ns(Ns) # input_checks.R

  n.sites <- ncol(dataset.add)
  x1.atoutset <- lmomRFA::regsamlmu(dataset.add, lcv = FALSE)
  weight <- sum(x1.atoutset[, 2])
  site_years <- x1.atoutset[, 2]
  max.n.years <- max(site_years)

  wt_mean <- function(col) sum(x1.atoutset[, 2] * x1.atoutset[, col]) / weight
  rmom <- c(0, wt_mean(4), wt_mean(5), wt_mean(6), wt_mean(7))
  reg.l2 <- rmom[2]

  reg.par <- fit_regional_dist(rmom)

  if (is.null(reg.par)) {
    warning("Failed to fit regional distribution. Returning NA.", call. = FALSE)
    return(NA)
  }

  V <- sqrt(sum(x1.atoutset[, 2] * (x1.atoutset[, 4] - reg.l2)^2) / weight)

  sigma <- make_sigma(rho, n.sites)

  V.sim <- vapply(
    seq_len(Ns),
    simulate_V,
    FUN.VALUE = numeric(1),
    sigma = sigma,
    n.sites = n.sites,
    site_years = site_years,
    weight = weight,
    reg.l2 = reg.l2,
    x1.atoutset = x1.atoutset,
    reg.par = reg.par,
    max.n.years = max.n.years
  )

  return(compute_H(V, V.sim))
}


# -----------------------------------------------------------------------------
# Internal: build and repair the inter-site correlation matrix.
# -----------------------------------------------------------------------------
#' @noRd
make_sigma <- function(rho, n.sites) {
  sigma <- matrix(rho, n.sites, n.sites)
  diag(sigma) <- 1

  if (any(eigen(sigma, only.values = TRUE)$values <= 0)) {
    sigma <- as.matrix(Matrix::nearPD(sigma, corr = TRUE)$mat)
  }

  return(sigma)
}


# -----------------------------------------------------------------------------
# Internal: compute H from observed V and simulated V.sim,
# warning and returning NA if V.sim is degenerate.
# -----------------------------------------------------------------------------
#' @noRd
compute_H <- function(V, V.sim) {
  V.sim_sd <- stats::sd(V.sim, na.rm = TRUE)

  if (!all(is.finite(V.sim)) || V.sim_sd == 0) {
    warning(
      "V.sim contains invalid values or zero variance. Returning NA.",
      call. = FALSE
    )
    return(NA)
  }

  return((V - mean(V.sim, na.rm = TRUE)) / V.sim_sd)
}


# -----------------------------------------------------------------------------
# Internal: fit regional distribution, trying kappa then Wakeby as fallback.
# Returns the parameter vector or NULL on failure.
# -----------------------------------------------------------------------------
#' @noRd
fit_regional_dist <- function(rmom) {
  reg.par <- try(lmom::pelkap(rmom), silent = TRUE)

  if (inherits(reg.par, "try-error") || !all(is.finite(reg.par))) {
    reg.par <- try(lmom::pelwak(rmom), silent = TRUE)
  }

  if (inherits(reg.par, "try-error") || !all(is.finite(reg.par))) {
    return(NULL)
  }

  return(reg.par)
}


# -----------------------------------------------------------------------------
# Internal: quantile function dispatcher — Wakeby (length 5) or kappa.
# -----------------------------------------------------------------------------
#' @noRd
regional_quantile <- function(u, reg.par) {
  if (length(reg.par) == 5) {
    return(lmom::quawak(u, reg.par))
  } else {
    return(lmom::quakap(u, reg.par))
  }
}


# -----------------------------------------------------------------------------
# Internal: simulate one V statistic from the fitted regional distribution.
# Returns NA_real_ if mvrnorm fails or produces non-finite values.
# -----------------------------------------------------------------------------
#' @noRd
simulate_V <- function(
  ns,
  sigma,
  n.sites,
  site_years,
  weight,
  reg.l2,
  x1.atoutset,
  reg.par,
  max.n.years
) {
  u.sim <- tryCatch(
    stats::pnorm(
      MASS::mvrnorm(n = max.n.years, mu = rep(0, n.sites), Sigma = sigma)
    ),
    error = function(e) {
      warning(
        "mvrnorm failed (simulation ",
        ns,
        "): ",
        conditionMessage(e),
        call. = FALSE
      )
      NULL
    }
  )

  if (is.null(u.sim) || anyNA(u.sim)) {
    return(NA_real_)
  }

  # Simulate data for each site and pad to max.n.years rows
  data.sim <- do.call(
    cbind,
    mapply(
      function(yrs, col) {
        out <- rep(NA_real_, max.n.years)
        out[seq_len(yrs)] <- regional_quantile(
          u.sim[seq_len(yrs), col],
          reg.par
        )
        out
      },
      site_years,
      seq_len(n.sites),
      SIMPLIFY = FALSE
    )
  )

  x1.sim <- lmomRFA::regsamlmu(data.sim, lcv = FALSE)
  reg.l2.sim <- sum(x1.atoutset[, 2] * x1.sim[, 4]) / weight
  numerator <- x1.atoutset[, 2] * (x1.sim[, 4] - reg.l2.sim)^2

  return(sqrt(sum(numerator) / weight))
}
