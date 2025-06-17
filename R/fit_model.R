#' Time-varying parameters of a given GEV model.
#'
#' @param add_data
#' A numeric matrix of air temperature data subtracted by their sample means
#' for each site, as calculated by the dataset_add().
#' @param model
#' A single interger number from 1 to 6 defining the GEV model.
#' May be provided by `best_model()`
#' @returns
#' A `data.frame` with the time-varying parameters of the given model.
#' @export
#' @importFrom extRemes fevd
#' @importFrom spsUtil quiet
#' @importFrom stats na.omit
#' @examples
#' add_data <- add_data
#' model <- 2
#' fit_model(add_data=add_data,model=model)
fit_model <- function(add_data, model){
  if(!is.numeric(model) || length(model) != 1 || model < 1 || model > 6) {
    stop("Model must be a single interger number from 1 to 6 defining the GEV model.")}
  add_data <- as.matrix(add_data)
  n.sites <- ncol(add_data)
  size <- matrix(NA,n.sites,1)
  at.site.pars <- as.data.frame(matrix(NA,n.sites,7))
  for (i in 1:n.sites){
    local <- na.omit(add_data[,i])
    size[i,1] <- length(local)
    scaled <- scale(1L:size[i,1])
    time <- scaled[,1]
    Avg <- attr(scaled,"scaled:center")
    S <- attr(scaled,"scaled:scale")
    at.site.par1 <- quiet(try(fit(local,time,model)))
    if(!is.numeric(at.site.par1)) {
      at.site.par1 <- quiet(try(fitLmom(local,time)))
    }
    at.site.par <- at.site.par1
    at.site.pars[i,1:6] <- at.site.par
  }
  at.site.pars[,7] <- size
  colnames(at.site.pars) <- c("mu0","mu1","mu2","sigma0","sigma1","shape","size")
  return(at.site.pars)
}

fit <- function(local,time,model){
  if (model == 1){
    parms <- quiet(summary(try(
      fevd(local,
           location.fun = ~ 1,
           scale.fun = ~ 1,
           shape.fun = ~ 1,
           type = "GEV",
           method = c("GMLE"),
           use.phi=FALSE))
    )
    )
    parms  <- c(parms$par[1],0,0,parms$par[2],0,parms$par[3])} else if (model == 2){
      parms <- quiet(summary(try(
        fevd(local,
             location.fun = ~ time,
             scale.fun = ~ 1,
             shape.fun = ~ 1,
             type = "GEV",
             method = c("GMLE"),
             use.phi=FALSE))
      )
      )
      parms  <- c(parms$par[1],parms$par[2],0,parms$par[3],0,parms$par[4])} else if (model == 3){
        parms <- quiet(summary(try(
          fevd(local,
               location.fun = ~ 1,
               scale.fun = ~ time,
               shape.fun = ~ 1,
               type = "GEV",
               method = c("GMLE"),
               use.phi=FALSE))
        )
        )
        parms  <- c(parms$par[1],0,0,parms$par[2],parms$par[3],parms$par[4])} else if (model == 4){
          parms <- quiet(summary(try(
            fevd(local,
                 location.fun = ~ time,
                 scale.fun = ~ time,
                 shape.fun = ~ 1,
                 type = "GEV",
                 method = c("GMLE"),
                 use.phi=FALSE))
          )
          )
          parms  <- c(parms$par[1],parms$par[2],0,parms$par[3],parms$par[4],parms$par[5])} else if (model == 5){
            parms <- quiet(summary(try(
              fevd(local,
                   location.fun = ~ time+ I(time^2),
                   scale.fun = ~ 1,
                   shape.fun = ~ 1,
                   type = "GEV",
                   method = c("GMLE"),
                   use.phi=FALSE))
            )
            )
            parms  <- c(parms$par[1],parms$par[2],parms$par[3],parms$par[4],0,parms$par[5])} else {
              parms <- quiet(summary(try(
                fevd(local,
                     location.fun = ~ time+ I(time^2),
                     scale.fun = ~ time,
                     shape.fun = ~ 1,
                     type = "GEV",
                     method = c("GMLE"),
                     use.phi=FALSE))
              )
              )
              parms  <- c(parms$par[1],parms$par[2],parms$par[3],parms$par[4],parms$par[5],parms$par[6])}
}

fitLmom <- function(local,time){
  parms <- quiet(summary(try(
    fevd(local,
         location.fun = ~ 1,
         scale.fun = ~ 1,
         shape.fun = ~ 1,
         type = "GEV",
         method = c("Lmoments"),
         use.phi=FALSE))))
  parms  <- (c(parms[1],0,0,parms[2],0,parms[3]))
}
