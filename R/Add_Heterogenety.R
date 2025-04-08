#' Add_Heterogenety
#'
#' @param dataset.add
#' A numeric matrix of standardized (z-score) temperature values for each site,
#' as calculated by the Add_Discord() function.
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
#' @importFrom lmom pelkap pelglo quakap quaglo
#' @importFrom MASS mvrnorm
#' @importFrom stats pnorm sd
#' @examples
#' rho <- 0.5
#' Ns <- 100
#' scaled_data <- scaled_data
#' Add_Heterogenety(dataset.add=scaled_data,rho = rho,Ns = Ns)

Add_Heterogenety <- function(dataset.add,rho,Ns){
  n.sites <- ncol(dataset.add)
  if (Ns<100){stop("Ns should be larger than 99.")}
  if (!is.numeric(rho) || length(rho) != 1 ||
      rho >= 1 || rho <= -1) {
    stop("`rho` must be a single smaller (larger) than -1 (1).")
  }
  if (n.sites<3){stop("The number of sites should be larger than 2.")}
  vetor.numerador <- matrix(NA,n.sites,1)
  V.sim <- matrix(NA,Ns,1)
  x1.atoutset <- regsamlmu(dataset.add, lcv = FALSE)
  weight <- sum(x1.atoutset[,2])
  vet.l2<- as.matrix(x1.atoutset[,2]*x1.atoutset[,4])
  vet.t3<- as.matrix(x1.atoutset[,2]*x1.atoutset[,5])
  vet.t4<- as.matrix(x1.atoutset[,2]*x1.atoutset[,6])
  vet.t5<- as.matrix(x1.atoutset[,2]*x1.atoutset[,7])
  reg.l2 <- sum(vet.l2)/weight
  reg.t3 <- sum(vet.t3)/weight
  reg.t4 <- sum(vet.t4)/weight
  reg.t5 <- sum(vet.t5)/weight
  rmom <- c(0,reg.l2,reg.t3,reg.t4,reg.t5)
  reg.par <- try(pelkap(rmom),TRUE)
  is.kap=length(reg.par)
  if (is.kap==1){reg.par=try(pelglo(rmom),TRUE)}
  for (v in 1:n.sites){
    vetor.numerador[v] <- x1.atoutset[v,2]*(x1.atoutset[v,4]-reg.l2)^2}
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
    vet.l2.sim<- as.matrix(x1.atoutset[,2]*x1.sim[,4])
    reg.l2.sim <- sum(vet.l2.sim)/weight
    for (v in 1:n.sites){
      vetor.numerador[v] <- x1.atoutset[v,2]*(x1.sim[v,4]-reg.l2.sim)^2}
    V.sim[ns,1] <- sqrt(sum(vetor.numerador)/weight)
  }
  H <- c((V-mean(V.sim))/sd(V.sim))

  return(H)
}
