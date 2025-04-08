#' Heterogenety measure calculated from the multiplicative approach
#'
#' @param dataset.mult
#' A numeric matrix of air temperature values divided by their sample means
#' for each site, as calculated by the dataset_mult() function.
#' @param rho
#' A single numeric value (constant) describing the average correlation among the sites.
#' It must be larger than -1.0 and lower than 1.0.
#' @param Ns
#' Number of simulated groups of series.
#' Default is 100, but at least 500 is recommended.
#' @returns
#' Hosking and Wallis' heterogeneity measure using the multiplicative approach,
#' as proposed in Hosking and Wallis (1997) <doi:10.1017/CBO9780511529443>.
#' @export
#' @importFrom lmomRFA regsamlmu
#' @importFrom lmom pelkap pelglo quakap quaglo
#' @importFrom MASS mvrnorm
#' @importFrom stats pnorm sd
#' @examples
#' rho <- 0.5
#' Ns <- 100
#' divided_data <- divided_data
#' mult_Heterogenety(dataset.mult=divided_data,rho = rho,Ns = Ns)

mult_Heterogenety <- function(dataset.mult,rho,Ns){
  n.sites <- ncol(dataset.mult)
  if (Ns<100){stop("Ns should be larger than 99.")}
  if (!is.numeric(rho) || length(rho) != 1 ||
      rho >= 1 || rho <= -1) {
    stop("`rho` must be a single smaller (larger) than -1 (1).")
  }
  if (n.sites<3){stop("The number of sites should be larger than 2.")}
  vetor.numerador <- matrix(NA,n.sites,1)
  V.sim <- matrix(NA,Ns,1)
  x1.atoutset <- regsamlmu(dataset.mult)
  weight <- sum(x1.atoutset[,2])
  vet.t<- as.matrix(x1.atoutset[,2]*x1.atoutset[,4])
  vet.t3<- as.matrix(x1.atoutset[,2]*x1.atoutset[,5])
  vet.t4<- as.matrix(x1.atoutset[,2]*x1.atoutset[,6])
  vet.t5<- as.matrix(x1.atoutset[,2]*x1.atoutset[,7])
  reg.t <- sum(vet.t)/weight
  reg.t3 <- sum(vet.t3)/weight
  reg.t4 <- sum(vet.t4)/weight
  reg.t5 <- sum(vet.t5)/weight
  rmom <- c(1,reg.t,reg.t3,reg.t4,reg.t5)
  reg.par <- try(pelkap(rmom),TRUE)
  is.kap=length(reg.par)
  if (is.kap==1){reg.par=try(pelglo(rmom),TRUE)}
  for (v in 1:n.sites){
    vetor.numerador[v] <- x1.atoutset[v,2]*(x1.atoutset[v,4]-reg.t)^2}
  V <- sqrt(sum(vetor.numerador)/weight)
  max.n.years <- max(x1.atoutset[,2])
  data.sim <- matrix(NA,max.n.years,n.sites)
  sigma <- matrix(rho,n.sites,n.sites)
  diag(sigma) <- 1
  for (ns in 1:Ns){
    u.sim <- pnorm(mvrnorm(n  =  max.n.years, mu = rep(0,n.sites), Sigma = sigma, tol  =  1e-06, empirical  =  FALSE))
    for (site in 1:n.sites){
      if (is.kap==1){
        data.sim[1:x1.atoutset[site,2],site] <- as.numeric(scale(quaglo(u.sim[1:x1.atoutset[site,2],site],
                                                                        c(reg.par[1],reg.par[2],reg.par[3]))))} else {
                                                                          data.sim[1:x1.atoutset[site,2],site] <- as.numeric(scale(quakap(u.sim[1:x1.atoutset[site,2],site],
                                                                                                                                          c(reg.par[1],reg.par[2],reg.par[3],reg.par[4]))))}
    }
    x1.sim <- regsamlmu(data.sim, lcv  =  FALSE)
    vet.t.sim<- as.matrix(x1.atoutset[,2]*x1.sim[,4])
    reg.t.sim <- sum(vet.t.sim)/weight
    for (v in 1:n.sites){
      vetor.numerador[v] <- x1.atoutset[v,2]*(x1.sim[v,4]-reg.t.sim)^2}
    V.sim[ns,1] <- sqrt(sum(vetor.numerador)/weight)
  }
  H <- c((V-mean(V.sim))/sd(V.sim))

  return(H)
}
