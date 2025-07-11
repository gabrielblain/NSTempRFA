% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Add_RegQuant.R
\name{Add_RegQuant}
\alias{Add_RegQuant}
\title{Regional Quantile Estimation for a Site Using Time-Varying GEV Parameters}
\usage{
Add_RegQuant(prob, regional_pars, site_temp, n.year)
}
\arguments{
\item{prob}{A numeric vector of probabilities (values strictly between 0 and 1) with no missing data.}

\item{regional_pars}{A 1-row, 5-column matrix or data frame containing the regional GEV parameters:
location intercept, location slope, scale intercept, scale slope, and shape.}

\item{site_temp}{A numeric vector or 1-column matrix of site's air temperature time series.}

\item{n.year}{A single integer indicating the year (index) for which quantiles should be calculated.
Must be between 1 and the length of site_temp.}
}
\value{
A named numeric vector of adjusted regional quantiles for the specified year.
}
\description{
Computes quantiles for a given site based on regional GEV parameters and
a time-varying location and scale model. The estimated quantiles are adjusted
by the site's mean temperature.
}
\examples{
prob <- c(0.8, 0.85, 0.90, 0.92, 0.93, 0.94, 0.95, 0.97, 0.99)
best_model <- best_sites
regional_pars <- reg_par(best_model = best_model)
RegQuant <- Add_RegQuant(
  prob = prob,
  regional_pars = regional_pars,
  site_temp = dataset$station1,
  n.year = 30
)
}
