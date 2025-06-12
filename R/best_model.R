#' Time-varying parameters of the best fitted GEV model.
#'
#' @param temperatures
#' A numeric matrix of scaled (z-score) or divided air temperature data for each site,
#' as calculated by the Add_Discord() or Mult_Discord() functions.
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
#' @examplesIf interactive()
#' add_data <- add_data
#' best.parms <- best_model(temperatures=add_data)
best_model <- function(temperatures){
  temperatures <- as.matrix(temperatures)
  n.sites <- ncol(temperatures)
  size <- matrix(NA,n.sites,1)
  at.site.model1 <- as.data.frame(matrix(NA,n.sites,6))
  at.site.model2 <- as.data.frame(matrix(NA,n.sites,6))
  at.site.model3 <- as.data.frame(matrix(NA,n.sites,6))
  at.site.model4 <- as.data.frame(matrix(NA,n.sites,6))
  at.site.model5 <- as.data.frame(matrix(NA,n.sites,6))
  at.site.model6 <- as.data.frame(matrix(NA,n.sites,6))
  at.site.AICs <- as.data.frame(matrix(NA,n.sites,6))
  atsite.models <- as.data.frame(matrix(NA,n.sites,7))
  for (i in 1:n.sites){
    local <- na.omit(temperatures[,i])
    size[i,1] <- length(local)
    time <- 1L:size[i,1]
    #time <- time - mean(time)
    selecting <- fit.models(local,time)
    at.site.AICs[i,] <- selecting$at.site.AIC
    at.site.model1[i,] <- selecting$models1
    at.site.model2[i,] <- selecting$models2
    at.site.model3[i,] <- selecting$models3
    at.site.model4[i,] <- selecting$models4
    at.site.model5[i,] <- selecting$models5
    at.site.model6[i,] <- selecting$models6
  }
  best <- which.min(colSums(at.site.AICs))
  atsite.models[,1:6] <- switch(
    best,
    at.site.model1,
    at.site.model2,
    at.site.model3,
    at.site.model4,
    at.site.model5,
    at.site.model6)
  atsite.models[,7] <- size
  colnames(atsite.models) <- c("mu0","mu1","mu2","sigma0","sigma1","shape","size")
  return(list(best = best,
              atsite.models = atsite.models))
}

fit.models <- function(local,time){
  at.site.AIC <- matrix(NA,1,6)
  models <- list(
    model1 <- quiet(summary(try(
      fevd(local,
           location.fun = ~ 1,
           scale.fun = ~ 1,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    ),
    model2 <- quiet(summary(try(
      fevd(local,
           location.fun = ~ time,
           scale.fun = ~ 1,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    ),
    model3 <- quiet(summary(try(
      fevd(local,
           location.fun = ~ 1,
           scale.fun = ~ time,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    ),
    model4 <- quiet(summary(try(
      fevd(local,
           location.fun = ~ time,
           scale.fun = ~ time,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    ),
    model5 <- quiet(summary(try(
      fevd(local,
           location.fun = ~ time+ I(time^2),
           scale.fun = ~ 1,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    ),
    model6 <- quiet(summary(try(
      fevd(local,
           location.fun = ~ time+ I(time^2),
           scale.fun = ~ time,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    )
  )
  models1  <- c(model1$par[1],0,0,model1$par[2],0,model1$par[3])
  models2  <- c(model2$par[1],model2$par[2],0,model2$par[3],0,model2$par[4])
  models3  <- c(model3$par[1],0,0,model3$par[2],model3$par[3],model3$par[4])
  models4  <- c(model4$par[1],model4$par[2],0,model4$par[3],model4$par[4],model4$par[5])
  models5  <- c(model5$par[1],model5$par[2],model5$par[3],model5$par[4],0,model5$par[5])
  models6  <- c(model6$par[1],model6$par[2],model6$par[3],model6$par[4],model6$par[5],model6$par[6])

  at.site.AIC <- (c(models[[1]]$AIC,models[[2]]$AIC,models[[3]]$AIC,
                    models[[4]]$AIC,models[[5]]$AIC,models[[6]]$AIC))
  return(list(models1 = models1,
              models2 = models2,
              models3 = models3,
              models4 = models4,
              models5 = models5,
              models6 = models6,
              at.site.AIC = at.site.AIC))
}
