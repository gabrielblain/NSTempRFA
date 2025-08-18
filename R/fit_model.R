#' Time-varying parameters of a given GEV model.
#'
#' @param temperatures
#' A vector or single column matrix of air temperature data subtracted (or not) by its sample mean.
#' @param model
#' A single integer number from 1 to 4 defining the GEV model.
#' May be provided by `best_model()`.
#' @returns A `data.frame` with the estimated parameters (`mu0`, `mu1`, `sigma0`, `sigma1`, `shape`, `size`).
#' If fitting fails, `NA`s are returned for that site.
#'
#' @details The function first attempts to fit the model using `ismev::gev.fit`
#' (a generalized maximum likelihood estimation). If that fails, it tries
#' to `extRemes::fevd` with method = "MLE".
#'
#' @importFrom extRemes fevd
#' @importFrom ismev gev.fit
#' @importFrom stats na.omit
#' @export
#' @examples
#' temperatures <- TmaxCPC_SP$Pixel_1
#' model <- 4
#' Fit_model(temperatures, model)
Fit_model <- function(temperatures, model) {
  if (!is.numeric(model) || length(model) != 1 || model < 1 || model > 4) {
    stop("Model must be a single integer number from 1 to 4 defining the GEV model.")
  }

  temperatures <- as.matrix(temperatures)
  n.sites <- ncol(temperatures)
  size <- matrix(NA, n.sites, 1)
  at.site.pars <- as.data.frame(matrix(NA, n.sites, 6))

  for (i in 1:n.sites) {
    local <- na.omit(temperatures[, i])
    size[i, 1] <- length(local)

    if (size[i, 1] == 0) {
      at.site.pars[i, 1:5] <- rep(NA, 5)
      next
    }

    time <- 1L:size[i, 1]

    at.site.par1 <- try(fit(local, time, model), silent = TRUE)

    if (!is.numeric(at.site.par1)) {
      #message("GMLE did not converge. Trying MLE instead.")
      at.site.par1 <- try(fitMLE(local, time, model), silent = TRUE)
    }

    if (!is.numeric(at.site.par1)) {
      at.site.par1 <- rep(NA, 5)
    }

    at.site.pars[i, 1:5] <- at.site.par1
  }

  at.site.pars[, 6] <- size
  colnames(at.site.pars) <- c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")
  return(at.site.pars)
}

#-------------------------------
# Internal: Main fit wrapper
#-------------------------------
fit <- function(local, time, model) {
  result <- quiet(fevd_call(local, time, model))
  if (is.null(result) || !is.numeric(result)) return(NA)
  return(result)
}

#-------------------------------------------
# Internal: Safe call to ismev::gev.fit
#-------------------------------------------
fevd_call <- function(local, time, model) {
  time.matrix <- as.matrix(time)

  fit_result <- try(
    switch(as.character(model),
           "1" = ismev::gev.fit(local, ydat = time.matrix, mul = NULL, sigl = NULL, shl = NULL,
                                mulink = identity, siglink = identity, shlink = identity,
                                muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                method = "Nelder-Mead", maxit = 10000),
           "2" = ismev::gev.fit(local, ydat = time.matrix, mul = 1, sigl = NULL, shl = NULL,
                                mulink = identity, siglink = identity, shlink = identity,
                                muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                method = "Nelder-Mead", maxit = 10000),
           "3" = ismev::gev.fit(local, ydat = time.matrix, mul = NULL, sigl = 1, shl = NULL,
                                mulink = identity, siglink = identity, shlink = identity,
                                muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                method = "Nelder-Mead", maxit = 10000),
           "4" = ismev::gev.fit(local, ydat = time.matrix, mul = 1, sigl = 1, shl = NULL,
                                mulink = identity, siglink = identity, shlink = identity,
                                muinit = NULL, siginit = NULL, shinit = NULL, show = TRUE,
                                method = "Nelder-Mead", maxit = 10000)
    ),
    silent = TRUE
  )

  if (inherits(fit_result, "try-error") || is.null(fit_result)) return(NULL)

  parms <- try(fit_result$mle, silent = TRUE)
  if (inherits(parms, "try-error") || is.null(parms)) return(NULL)

  # Assemble return vector depending on model
  if (model == 1) return(c(parms[1], 0, parms[2], 0, parms[3]))
  if (model == 2) return(c(parms[1], parms[2], parms[3], 0, parms[4]))
  if (model == 3) return(c(parms[1], 0, parms[2], parms[3], parms[4]))
  if (model == 4) return(c(parms[1], parms[2], parms[3], parms[4], parms[5]))

  return(NULL)
}

#---------------------------------------
# Internal: Alternative fitting using multiple optimization methods
#---------------------------------------
fitMLE <- function(local, time, model) {
  time.matrix <- as.matrix(time)

  methods <- c("BFGS", "CG", "L-BFGS-B", "SANN", "Brent")

  for (method in methods) {
    result <- try({
      fit_result <- switch(as.character(model),
                           "1" = ismev::gev.fit(local, ydat = time.matrix, mul = NULL, sigl = NULL, shl = NULL,
                                                mulink = identity, siglink = identity, shlink = identity,
                                                muinit = NULL, siginit = NULL, shinit = NULL, show = FALSE,
                                                method = method, maxit = 10000),
                           "2" = ismev::gev.fit(local, ydat = time.matrix, mul = 1, sigl = NULL, shl = NULL,
                                                mulink = identity, siglink = identity, shlink = identity,
                                                muinit = NULL, siginit = NULL, shinit = NULL, show = FALSE,
                                                method = method, maxit = 10000),
                           "3" = ismev::gev.fit(local, ydat = time.matrix, mul = NULL, sigl = 1, shl = NULL,
                                                mulink = identity, siglink = identity, shlink = identity,
                                                muinit = NULL, siginit = NULL, shinit = NULL, show = FALSE,
                                                method = method, maxit = 10000),
                           "4" = ismev::gev.fit(local, ydat = time.matrix, mul = 1, sigl = 1, shl = NULL,
                                                mulink = identity, siglink = identity, shlink = identity,
                                                muinit = NULL, siginit = NULL, shinit = NULL, show = FALSE,
                                                method = method, maxit = 10000)
      )

      if (is.null(fit_result) || is.null(fit_result$mle)) stop("fit failed")

      parms <- fit_result$mle

      if (model == 1) return(c(parms[1], 0, parms[2], 0, parms[3]))
      if (model == 2) return(c(parms[1], parms[2], parms[3], 0, parms[4]))
      if (model == 3) return(c(parms[1], 0, parms[2], parms[3], parms[4]))
      if (model == 4) return(c(parms[1], parms[2], parms[3], parms[4], parms[5]))
    }, silent = TRUE)

    if (!inherits(result, "try-error") && is.numeric(result)) {
      message("Model fitted successfully using method: ", method)
      return(result)
    }
  }

  # If none worked, return NA
  message("All optimization methods failed.")
  return(rep(NA, 5))
}
