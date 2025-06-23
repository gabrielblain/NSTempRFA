#' Time-varying parameters of a given GEV model.
#'
#' @param add_data
#' A numeric matrix of air temperature data subtracted by their sample means
#' for each site, as calculated by the dataset_add().
#' @param model
#' A single integer number from 1 to 6 defining the GEV model.
#' May be provided by `best_model()`.
#' @returns
#' A `data.frame` with the time-varying parameters of the given model.
#' @export
#' @importFrom extRemes fevd
#' @importFrom spsUtil quiet
#' @importFrom stats na.omit
#' @examples
#' add_data <- add_data
#' model <- 2
#' fit_model(add_data = add_data, model = model)
fit_model <- function(add_data, model) {
  if (!is.numeric(model) || length(model) != 1 || model < 1 || model > 6) {
    stop("Model must be a single interger number from 1 to 6 defining the GEV model.")
  }

  add_data <- as.matrix(add_data)
  n.sites <- ncol(add_data)
  size <- matrix(NA, n.sites, 1)
  at.site.pars <- as.data.frame(matrix(NA, n.sites, 7))

  for (i in 1:n.sites) {
    local <- na.omit(add_data[, i])
    size[i, 1] <- length(local)

    if (size[i, 1] == 0) {
      at.site.pars[i, 1:6] <- rep(NA, 6)
      next
    }

    scaled <- scale(1L:size[i, 1])
    time <- scaled[, 1]

    at.site.par1 <- quiet(try(fit(local, time, model), silent = TRUE))

    # Se o ajuste por máxima verossimilhança falhar, tenta via Lmoments
    if (!is.numeric(at.site.par1)) {
      at.site.par1 <- quiet(try(fitLmom(local, time), silent = TRUE))
    }

    # Se ainda assim falhar, preenche com NA
    if (!is.numeric(at.site.par1)) {
      at.site.par1 <- rep(NA, 6)
    }

    at.site.pars[i, 1:6] <- at.site.par1
  }

  at.site.pars[, 7] <- size
  colnames(at.site.pars) <- c("mu0", "mu1", "mu2", "sigma0", "sigma1", "shape", "size")
  return(at.site.pars)
}

#-------------------------------
# Função fit(): Ajuste principal
#-------------------------------
fit <- function(local, time, model) {
  result <- try(fevd_call(local, time, model), silent = TRUE)
  if (inherits(result, "try-error") || is.null(result)) return(NA)
  return(result)
}

#-------------------------------------------
# Função fevd_call(): Chamada segura ao fevd
#-------------------------------------------
fevd_call <- function(local, time, model) {
  fit_result <- switch(as.character(model),
                       "1" = fevd(local, location.fun = ~1, scale.fun = ~1, shape.fun = ~1,
                                  type = "GEV", method = "GMLE", use.phi = FALSE),
                       "2" = fevd(local, location.fun = ~time, scale.fun = ~1, shape.fun = ~1,
                                  type = "GEV", method = "GMLE", use.phi = FALSE),
                       "3" = fevd(local, location.fun = ~1, scale.fun = ~time, shape.fun = ~1,
                                  type = "GEV", method = "GMLE", use.phi = FALSE),
                       "4" = fevd(local, location.fun = ~time, scale.fun = ~time, shape.fun = ~1,
                                  type = "GEV", method = "GMLE", use.phi = FALSE),
                       "5" = fevd(local, location.fun = ~time + I(time^2), scale.fun = ~1, shape.fun = ~1,
                                  type = "GEV", method = "GMLE", use.phi = FALSE),
                       "6" = fevd(local, location.fun = ~time + I(time^2), scale.fun = ~time, shape.fun = ~1,
                                  type = "GEV", method = "GMLE", use.phi = FALSE)
  )

  # Se o ajuste falhar, retorna NA
  if (!inherits(fit_result, "fevd")) return(NA)

  parms <- try(summary(fit_result)$par, silent = TRUE)
  if (inherits(parms, "try-error") || is.null(parms)) return(NA)

  # Preenche o vetor de parâmetros conforme o modelo
  if (model == 1) return(c(parms[1], 0, 0, parms[2], 0, parms[3]))
  if (model == 2) return(c(parms[1], parms[2], 0, parms[3], 0, parms[4]))
  if (model == 3) return(c(parms[1], 0, 0, parms[2], parms[3], parms[4]))
  if (model == 4) return(c(parms[1], parms[2], 0, parms[3], parms[4], parms[5]))
  if (model == 5) return(c(parms[1], parms[2], parms[3], parms[4], 0, parms[5]))
  if (model == 6) return(c(parms[1], parms[2], parms[3], parms[4], parms[5], parms[6]))
}

#---------------------------------------
# Função fitLmom(): Ajuste via L-Moments
#---------------------------------------
fitLmom <- function(local, time) {
  result <- try({
    fit_result <- fevd(local, location.fun = ~1, scale.fun = ~1, shape.fun = ~1,
                       type = "GEV", method = "Lmoments", use.phi = FALSE)
    parms <- summary(fit_result)$par
    c(parms[1], 0, 0, parms[2], 0, parms[3])
  }, silent = TRUE)

  if (inherits(result, "try-error") || is.null(result)) return(NA)
  return(result)
}
