#' Time-varying parameters of the best fitted GEV model.
#'
#' This function fits four time-varying GEV models (with different assumptions on
#' non-stationarity in location and/or scale) to each temperature series, computes
#' the AICc of each model, and selects the best one according to the lowest total AICc.
#'
#' @param add.data
#' A numeric matrix of air temperature data as that calculated by the `Dataset_add()` function.
#'
#' @returns
#' A list with:
#' \describe{
#'   \item{best}{
#'   Index (1-4) of the model with the lowest total AICc across all sites.
#'   }
#'   \item{atsite.models}{
#'   Data frame containing the estimated parameters
#'   (`mu0`, `mu1`, `sigma0`, `sigma1`, `shape`) and sample size for each site.
#'   }
#' }
#'
#' @details
#' Model fitting is done using `ismev::gev.fit()`.
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

  if (ncol(add.data) < 1) {
    stop("'add.data' must contain at least one site.", call. = FALSE)
  }

  min_sample_size <- min(colSums(!is.na(add.data)))

  if (min_sample_size < 10) {
    stop("All sites must have at least 10 observations.", call. = FALSE)
  }

  n.sites <- ncol(add.data)
  size <- matrix(NA, n.sites, 1)

  at.site.model1 <- at.site.model2 <-
    at.site.model3 <- at.site.model4 <-
      as.data.frame(matrix(NA, n.sites, 5))

  at.site.AICs <- as.data.frame(matrix(NA, n.sites, 4))
  atsite.models <- as.data.frame(matrix(NA, n.sites, 6))

  for (i in seq_len(n.sites)) {
    local <- na.omit(add.data[, i])
    size[i, 1] <- length(local)

    if (length(local) == 0) {
      at.site.AICs[i, ] <- rep(Inf, 4)

      at.site.model1[i, ] <-
        at.site.model2[i, ] <-
          at.site.model3[i, ] <-
            at.site.model4[i, ] <- rep(NA, 5)

      next
    }

    time <- matrix(seq_len(size[i, 1]))

    selecting <- quiet(
      fit.models(local, time)
    )

    at.site.AICs[i, ] <- selecting$at.site.AIC
    at.site.model1[i, ] <- selecting$models1
    at.site.model2[i, ] <- selecting$models2
    at.site.model3[i, ] <- selecting$models3
    at.site.model4[i, ] <- selecting$models4
  }

  total_AIC <- colSums(at.site.AICs, na.rm = TRUE)

  if (all(is.infinite(total_AIC))) {
    stop("All model fits failed.", call. = FALSE)
  }

  best <- which.min(total_AIC)

  atsite.models[, 1:5] <- switch(
    best,
    at.site.model1,
    at.site.model2,
    at.site.model3,
    at.site.model4
  )

  atsite.models[, 6] <- size

  colnames(atsite.models) <-
    c("mu0", "mu1", "sigma0", "sigma1", "shape", "size")

  return(
    list(
      best = best,
      atsite.models = atsite.models
    )
  )
}


#--------------------------------------------------
# Internal: fit models and compute AICc
#--------------------------------------------------
fit.models <- function(local, time) {
  if (length(local) == 0) {
    return(
      list(
        models1 = rep(NA, 5),
        models2 = rep(NA, 5),
        models3 = rep(NA, 5),
        models4 = rep(NA, 5),
        at.site.AIC = rep(Inf, 4)
      )
    )
  }

  methods <- c(
    "Nelder-Mead",
    "BFGS",
    "CG",
    "L-BFGS-B",
    "SANN"
  )

  try_model <- function(model_id) {
    for (method in methods) {
      result <- try(
        {
          fit <- switch(
            as.character(model_id),

            "1" = ismev::gev.fit(
              local,
              ydat = as.matrix(time),
              mul = NULL,
              sigl = NULL,
              shl = NULL,
              mulink = identity,
              siglink = identity,
              shlink = identity,
              method = method,
              maxit = 10000,
              show = FALSE
            ),

            "2" = ismev::gev.fit(
              local,
              ydat = as.matrix(time),
              mul = 1,
              sigl = NULL,
              shl = NULL,
              mulink = identity,
              siglink = identity,
              shlink = identity,
              method = method,
              maxit = 10000,
              show = FALSE
            ),

            "3" = ismev::gev.fit(
              local,
              ydat = as.matrix(time),
              mul = NULL,
              sigl = 1,
              shl = NULL,
              mulink = identity,
              siglink = identity,
              shlink = identity,
              method = method,
              maxit = 10000,
              show = FALSE
            ),

            "4" = ismev::gev.fit(
              local,
              ydat = as.matrix(time),
              mul = 1,
              sigl = 1,
              shl = NULL,
              mulink = identity,
              siglink = identity,
              shlink = identity,
              method = method,
              maxit = 10000,
              show = FALSE
            )
          )

          if (is.null(fit) || is.null(fit$mle)) {
            stop("Fit failed.")
          }

          fit$method_used <- method

          return(fit)
        },
        silent = TRUE
      )

      if (!inherits(result, "try-error") && !is.null(result)) {
        return(result)
      }
    }

    return(NULL)
  }

  models <- list(
    try_model(1),
    try_model(2),
    try_model(3),
    try_model(4)
  )

  extract_pars <- function(model, model_id) {
    if (is.null(model) || is.null(model$mle)) {
      return(rep(NA, 5))
    }

    mle <- model$mle

    switch(
      as.character(model_id),

      "1" = c(mle[1], 0, mle[2], 0, mle[3]),
      "2" = c(mle[1], mle[2], mle[3], 0, mle[4]),
      "3" = c(mle[1], 0, mle[2], mle[3], mle[4]),
      "4" = c(mle[1], mle[2], mle[3], mle[4], mle[5])
    )
  }

  models1 <- extract_pars(models[[1]], 1)
  models2 <- extract_pars(models[[2]], 2)
  models3 <- extract_pars(models[[3]], 3)
  models4 <- extract_pars(models[[4]], 4)

  k_values <- c(3, 4, 4, 5)
  n <- length(local)

  safe_AICc <- function(model, k, n) {
    if (
      is.null(model) ||
        is.null(model$nllh) ||
        is.na(model$nllh) ||
        n <= k + 1
    ) {
      return(Inf)
    }

    AIC <- 2 * k + 2 * model$nllh

    AICc <- AIC +
      (2 * k * (k + 1)) /
        (n - k - 1)

    return(AICc)
  }

  at.site.AICc <- mapply(
    safe_AICc,
    models,
    k_values,
    MoreArgs = list(n = n)
  )

  return(
    list(
      models1 = models1,
      models2 = models2,
      models3 = models3,
      models4 = models4,
      at.site.AIC = at.site.AICc
    )
  )
}
