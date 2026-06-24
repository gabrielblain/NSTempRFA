#' Time-varying parameters of a given GEV model.
#'
#' @param temperatures
#' A vector or single-column matrix of air temperature data, either original or
#' centered by subtracting the sample mean.
#'
#' @param model
#' A single integer between 1 and 4 defining the GEV model.
#' It may be provided by `Best_model()`.
#'
#' @returns
#' A `data.frame` containing the estimated parameters
#' (`mu0`, `mu1`, `sigma0`, `sigma1`, `shape`, `size`).
#' If fitting fails, `NA`s are returned for that site.
#'
#' @details
#' The function first attempts to fit the model using `ismev::gev.fit()`.
#' If this approach fails, several alternative optimization methods are tried.
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

  if (
    !is.numeric(model) ||
      length(model) != 1 ||
      model != as.integer(model) ||
      model < 1 ||
      model > 4
  ) {
    stop("`model` must be a single integer between 1 and 4.", call. = FALSE)
  }

  temperatures <- as.matrix(temperatures)

  n.sites <- ncol(temperatures)

  size <- numeric(n.sites)

  at.site.pars <- as.data.frame(matrix(NA, n.sites, 6))

  for (i in seq_len(n.sites)) {
    local <- na.omit(temperatures[, i, drop = TRUE])

    size[i] <- length(local)

    if (size[i] == 0) {
      at.site.pars[i, 1:5] <- rep(NA, 5)
      next
    }

    time <- seq_len(size[i])

    at.site.par1 <- try(fit_gev(local, time, model), silent = TRUE)

    if (!is.numeric(at.site.par1)) {
      at.site.par1 <- try(fit_gev_alt(local, time, model), silent = TRUE)
    }

    if (!is.numeric(at.site.par1)) {
      at.site.par1 <- rep(NA, 5)
    }

    at.site.pars[i, 1:5] <- at.site.par1
  }

  at.site.pars[, 6] <- size

  colnames(at.site.pars) <-
    c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")

  return(at.site.pars)
}


#-------------------------------------
# Internal: Main fit wrapper
#-------------------------------------
fit_gev <- function(local, time, model) {
  result <- quiet(fit_gev_ismev(local, time, model))

  if (is.null(result) || !is.numeric(result)) {
    return(rep(NA, 5))
  }

  result
}


#-------------------------------------
# Internal: Safe call to ismev::gev.fit
#-------------------------------------
fit_gev_ismev <- function(local, time, model) {
  time.matrix <- as.matrix(time)

  fit_result <- try(
    switch(
      as.character(model),

      "1" = ismev::gev.fit(
        local,
        ydat = time.matrix,
        mul = NULL,
        sigl = NULL,
        shl = NULL,
        mulink = identity,
        siglink = identity,
        shlink = identity,
        show = FALSE,
        method = "Nelder-Mead",
        maxit = 10000
      ),

      "2" = ismev::gev.fit(
        local,
        ydat = time.matrix,
        mul = 1,
        sigl = NULL,
        shl = NULL,
        mulink = identity,
        siglink = identity,
        shlink = identity,
        show = FALSE,
        method = "Nelder-Mead",
        maxit = 10000
      ),

      "3" = ismev::gev.fit(
        local,
        ydat = time.matrix,
        mul = NULL,
        sigl = 1,
        shl = NULL,
        mulink = identity,
        siglink = identity,
        shlink = identity,
        show = FALSE,
        method = "Nelder-Mead",
        maxit = 10000
      ),

      "4" = ismev::gev.fit(
        local,
        ydat = time.matrix,
        mul = 1,
        sigl = 1,
        shl = NULL,
        mulink = identity,
        siglink = identity,
        shlink = identity,
        show = FALSE,
        method = "Nelder-Mead",
        maxit = 10000
      )
    ),
    silent = TRUE
  )

  if (inherits(fit_result, "try-error") || is.null(fit_result)) {
    return(NULL)
  }

  parms <- try(fit_result$mle, silent = TRUE)

  if (inherits(parms, "try-error") || is.null(parms)) {
    return(NULL)
  }

  switch(
    as.character(model),

    "1" = c(parms[1], 0, parms[2], 0, parms[3]),

    "2" = c(parms[1], parms[2], parms[3], 0, parms[4]),

    "3" = c(parms[1], 0, parms[2], parms[3], parms[4]),

    "4" = c(parms[1], parms[2], parms[3], parms[4], parms[5])
  )
}


#-------------------------------------
# Internal: Alternative optimization methods
#-------------------------------------
fit_gev_alt <- function(local, time, model) {
  time.matrix <- as.matrix(time)

  methods <- c("BFGS", "CG", "L-BFGS-B", "SANN")

  for (method in methods) {
    result <- try(
      {
        fit_result <- switch(
          as.character(model),

          "1" = ismev::gev.fit(
            local,
            ydat = time.matrix,
            mul = NULL,
            sigl = NULL,
            shl = NULL,
            mulink = identity,
            siglink = identity,
            shlink = identity,
            show = FALSE,
            method = method,
            maxit = 10000
          ),

          "2" = ismev::gev.fit(
            local,
            ydat = time.matrix,
            mul = 1,
            sigl = NULL,
            shl = NULL,
            mulink = identity,
            siglink = identity,
            shlink = identity,
            show = FALSE,
            method = method,
            maxit = 10000
          ),

          "3" = ismev::gev.fit(
            local,
            ydat = time.matrix,
            mul = NULL,
            sigl = 1,
            shl = NULL,
            mulink = identity,
            siglink = identity,
            shlink = identity,
            show = FALSE,
            method = method,
            maxit = 10000
          ),

          "4" = ismev::gev.fit(
            local,
            ydat = time.matrix,
            mul = 1,
            sigl = 1,
            shl = NULL,
            mulink = identity,
            siglink = identity,
            shlink = identity,
            show = FALSE,
            method = method,
            maxit = 10000
          )
        )

        if (is.null(fit_result) || is.null(fit_result$mle)) {
          stop("Fit failed", call. = FALSE)
        }

        parms <- fit_result$mle

        switch(
          as.character(model),

          "1" = c(parms[1], 0, parms[2], 0, parms[3]),

          "2" = c(parms[1], parms[2], parms[3], 0, parms[4]),

          "3" = c(parms[1], 0, parms[2], parms[3], parms[4]),

          "4" = c(parms[1], parms[2], parms[3], parms[4], parms[5])
        )
      },
      silent = TRUE
    )

    if (!inherits(result, "try-error") && is.numeric(result)) {
      return(result)
    }
  }

  return(rep(NA, 5))
}
