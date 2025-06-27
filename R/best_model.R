#' Time-varying parameters of the best fitted GEV model.
#'
#' @param add_data
#' A numeric matrix of air temperature data as that calculated by the dataset_add().
#' @returns
#' A `list` object with the following elements:
#' \describe{
#'   \item{best}{The best model among the six candidates.}
#'   \item{atsite.models}{The time-varying parameters of the best model.}
#'  }
#' @export
#' @importFrom extRemes fevd
#' @importFrom spsUtil quiet
#' @importFrom stats na.omit
#' @examples
#' add_data <- add_data
#' best.parms <- best_model(add_data=add_data)
best_model <- function(add_data) {
  # Input checks
  if (!is.matrix(add_data) && !is.data.frame(add_data)) {
    stop("Input 'add_data' must be a matrix or data frame.")
  }
  add_data <- as.matrix(add_data)
  n.sites <- ncol(add_data)
  size <- matrix(NA, n.sites, 1)
  at.site.model1 <- as.data.frame(matrix(NA, n.sites, 6))
  at.site.model2 <- as.data.frame(matrix(NA, n.sites, 6))
  at.site.model3 <- as.data.frame(matrix(NA, n.sites, 6))
  at.site.model4 <- as.data.frame(matrix(NA, n.sites, 6))
  at.site.model5 <- as.data.frame(matrix(NA, n.sites, 6))
  at.site.model6 <- as.data.frame(matrix(NA, n.sites, 6))
  at.site.AICs <- as.data.frame(matrix(NA, n.sites, 6))
  atsite.models <- as.data.frame(matrix(NA, n.sites, 7))

  for (i in 1:n.sites) {
    local <- na.omit(add_data[, i])
    size[i, 1] <- length(local)
    if (length(local) == 0) {
      # If no data for this site, fill with NAs and Inf AIC to skip it
      at.site.AICs[i, ] <- rep(Inf, 6)
      at.site.model1[i, ] <- rep(NA, 6)
      at.site.model2[i, ] <- rep(NA, 6)
      at.site.model3[i, ] <- rep(NA, 6)
      at.site.model4[i, ] <- rep(NA, 6)
      at.site.model5[i, ] <- rep(NA, 6)
      at.site.model6[i, ] <- rep(NA, 6)
      next
    }

    scaled <- scale(1L:size[i, 1])
    time <- scaled[, 1]

    selecting <- fit.models(local, time)
    at.site.AICs[i, ] <- selecting$at.site.AIC
    at.site.model1[i, ] <- selecting$models1
    at.site.model2[i, ] <- selecting$models2
    at.site.model3[i, ] <- selecting$models3
    at.site.model4[i, ] <- selecting$models4
    at.site.model5[i, ] <- selecting$models5
    at.site.model6[i, ] <- selecting$models6
  }

  best <- which.min(colSums(at.site.AICs))

  atsite.models[, 1:6] <- switch(
    best,
    at.site.model1,
    at.site.model2,
    at.site.model3,
    at.site.model4,
    at.site.model5,
    at.site.model6
  )
  atsite.models[, 7] <- size
  colnames(atsite.models) <- c("mu0", "mu1", "mu2", "sigma0", "sigma1", "shape", "size")

  return(list(
    best = best,
    atsite.models = atsite.models
  ))
}


fit.models <- function(local, time) {
  # Return NA/Inf if no data
  if (length(local) == 0) {
    return(list(
      models1 = rep(NA, 6),
      models2 = rep(NA, 6),
      models3 = rep(NA, 6),
      models4 = rep(NA, 6),
      models5 = rep(NA, 6),
      models6 = rep(NA, 6),
      at.site.AIC = rep(Inf, 6)
    ))
  }

  safe_fit <- function(expr) {
    res <- try(expr, silent = TRUE)
    if (inherits(res, "try-error")) {
      return(NULL)
    }
    return(res)
  }

  safe_summary <- function(model) {
    if (is.null(model)) return(NULL)
    quiet(summary(model))
  }

  models <- list(
    safe_summary(safe_fit(fevd(local,
                               location.fun = ~ 1,
                               scale.fun = ~ 1,
                               shape.fun = ~ 1,
                               type = "GEV",
                               method = "GMLE",
                               use.phi = FALSE))),

    safe_summary(safe_fit(fevd(local,
                               location.fun = ~ time,
                               scale.fun = ~ 1,
                               shape.fun = ~ 1,
                               type = "GEV",
                               method = "GMLE",
                               use.phi = FALSE))),

    safe_summary(safe_fit(fevd(local,
                               location.fun = ~ 1,
                               scale.fun = ~ time,
                               shape.fun = ~ 1,
                               type = "GEV",
                               method = "GMLE",
                               use.phi = FALSE))),

    safe_summary(safe_fit(fevd(local,
                               location.fun = ~ time,
                               scale.fun = ~ time,
                               shape.fun = ~ 1,
                               type = "GEV",
                               method = "GMLE",
                               use.phi = FALSE))),

    safe_summary(safe_fit(fevd(local,
                               location.fun = ~ time + I(time^2),
                               scale.fun = ~ 1,
                               shape.fun = ~ 1,
                               type = "GEV",
                               method = "GMLE",
                               use.phi = FALSE))),

    safe_summary(safe_fit(fevd(local,
                               location.fun = ~ time + I(time^2),
                               scale.fun = ~ time,
                               shape.fun = ~ 1,
                               type = "GEV",
                               method = "GMLE",
                               use.phi = FALSE)))
  )

  # Helper to safely extract parameters or NA vector
  safe_par <- function(model, n) {
    if (is.null(model) || is.null(model$par) || length(model$par) < n) {
      return(rep(NA, n))
    } else {
      return(model$par[1:n])
    }
  }

  # Extract parameters for each model, filling zeros for missing ones to keep length 6
  models1 <- c(safe_par(models[[1]], 3)[1], 0, 0, safe_par(models[[1]], 3)[2], 0, safe_par(models[[1]], 3)[3])
  models2 <- c(safe_par(models[[2]], 4)[1], safe_par(models[[2]], 4)[2], 0, safe_par(models[[2]], 4)[3], 0, safe_par(models[[2]], 4)[4])
  models3 <- c(safe_par(models[[3]], 4)[1], 0, 0, safe_par(models[[3]], 4)[2], safe_par(models[[3]], 4)[3], safe_par(models[[3]], 4)[4])
  models4 <- c(safe_par(models[[4]], 5)[1], safe_par(models[[4]], 5)[2], 0, safe_par(models[[4]], 5)[3], safe_par(models[[4]], 5)[4], safe_par(models[[4]], 5)[5])
  models5 <- c(safe_par(models[[5]], 5)[1], safe_par(models[[5]], 5)[2], safe_par(models[[5]], 5)[3], safe_par(models[[5]], 5)[4], 0, safe_par(models[[5]], 5)[5])
  models6 <- c(safe_par(models[[6]], 6)[1], safe_par(models[[6]], 6)[2], safe_par(models[[6]], 6)[3], safe_par(models[[6]], 6)[4], safe_par(models[[6]], 6)[5], safe_par(models[[6]], 6)[6])

  # Helper to safely extract AIC or Inf if missing
  safe_AIC <- function(model) {
    if (is.null(model) || is.null(model$AIC) || is.na(model$AIC)) {
      return(Inf)
    } else {
      return(model$AIC)
    }
  }

  at.site.AIC <- sapply(models, safe_AIC)

  return(list(
    models1 = models1,
    models2 = models2,
    models3 = models3,
    models4 = models4,
    models5 = models5,
    models6 = models6,
    at.site.AIC = at.site.AIC
  ))
}
