#' Add_Heterogenety
#'
#' @param dataset.add
#' A numeric matrix of air temperature data as that calculated by the dataset_add().
#' @param rho
#' A single numeric value (constant) describing the average correlation among the sites.
#' It must be larger than -1.0 and lower than 1.0.
#' @param Ns
#' Number of simulated groups of series.
#' Default is 100, but at least 500 is recommended.
#' @returns
#' Hosking and Wallis' heterogeneity measure using an additive approach,
#' as proposed in Martins et al. (2022) <doi:10.1590/1678-4499.20220061>.
#' @export
#' @importFrom lmomRFA regsamlmu
#' @importFrom lmom pelkap pelwak quakap quawak
#' @importFrom MASS mvrnorm
#' @importFrom stats pnorm sd
#' @importFrom Matrix nearPD
#' @examples
#' rho <- 0.51
#' Ns <- 500
#' add.data <- Dataset_add(TmaxCPC_SP)
#' Add_Heterogenety(dataset.add=add.data$add_data,rho = rho,Ns = Ns)
Add_Heterogenety <- function(dataset.add,rho,Ns){
  n.sites <- ncol(dataset.add)
  if (n.sites < 3) stop("The number of sites should be equal to or larger than 3.")

  min_sample_size <- min(colSums(!is.na(dataset.add)))
  if (min_sample_size < 10)
    stop("All sites must have at least 10 years of records. So sorry, we cannot proceed.")

  if (Ns < 100) stop("Ns should be larger than 99.")
  if (!is.numeric(rho) || length(rho) != 1 || rho >= 1 || rho <= -1)
    stop("`rho` must be a single smaller (larger) than -1 (1).")

  V.sim <- numeric(Ns)
  vetor.numerador <- numeric(n.sites)

  x1.atoutset <- regsamlmu(dataset.add, lcv = FALSE)
  weight <- sum(x1.atoutset[, 2])

  # Regional L-moments
  reg.l2 <- sum(x1.atoutset[, 2] * x1.atoutset[, 4]) / weight
  reg.t3 <- sum(x1.atoutset[, 2] * x1.atoutset[, 5]) / weight
  reg.t4 <- sum(x1.atoutset[, 2] * x1.atoutset[, 6]) / weight
  reg.t5 <- sum(x1.atoutset[, 2] * x1.atoutset[, 7]) / weight

  rmom <- c(0, reg.l2, reg.t3, reg.t4, reg.t5)

  reg.par <- try(pelkap(rmom), silent = TRUE)
  is.kap <- length(reg.par)

  if (is.kap == 1 || any(!is.finite(reg.par))) {
    reg.par <- try(pelwak(rmom), silent = TRUE)
    is.kap <- length(reg.par)
  }

  if (is.kap == 1 || any(!is.finite(reg.par))) {
    warning("Failed to fit regional distribution. Returning NA.")
    return(NA)
  }

  for (v in 1:n.sites) {
    vetor.numerador[v] <- x1.atoutset[v, 2] * (x1.atoutset[v, 4] - reg.l2)^2
  }
  V <- sqrt(sum(vetor.numerador) / weight)

  max.n.years <- max(x1.atoutset[, 2])
  sigma <- matrix(rho, n.sites, n.sites)
  diag(sigma) <- 1

  # Ensure positive definiteness
  if (any(eigen(sigma)$values <= 0)) {
    sigma <- as.matrix(nearPD(sigma, corr = TRUE)$mat)
  }

  for (ns in 1:Ns) {
    u.sim <- tryCatch({
      pnorm(mvrnorm(n = max.n.years, mu = rep(0, n.sites), Sigma = sigma))
    }, error = function(e) {
      warning("mvrnorm failed (simulation ", ns, "): ", conditionMessage(e))
      return(matrix(NA, max.n.years, n.sites))
    })

    if (anyNA(u.sim)) {
      V.sim[ns] <- NA
      next
    }

    data.sim <- matrix(NA, max.n.years, n.sites)
    for (site in 1:n.sites) {
      site_years <- x1.atoutset[site, 2]
      if (is.kap == 5) {
        data.sim[1:site_years, site] <- quawak(u.sim[1:site_years, site], reg.par)
      } else {
        data.sim[1:site_years, site] <- quakap(u.sim[1:site_years, site], reg.par)
      }
    }

    x1.sim <- regsamlmu(data.sim, lcv = FALSE)
    reg.l2.sim <- sum(x1.atoutset[, 2] * x1.sim[, 4]) / weight

    for (v in 1:n.sites) {
      vetor.numerador[v] <- x1.atoutset[v, 2] * (x1.sim[v, 4] - reg.l2.sim)^2
    }
    V.sim[ns] <- sqrt(sum(vetor.numerador) / weight)
  }

  if (all(is.finite(V.sim)) && sd(V.sim, na.rm = TRUE) > 0) {
    H <- (V - mean(V.sim, na.rm = TRUE)) / sd(V.sim, na.rm = TRUE)
  } else {
    warning("V.sim contains invalid values or zero variance. Returning NA.")
    H <- NA
  }

  return(H)
}
