
# NSTempRFA

<!-- badges: start -->

<!-- badges: end -->

A package designed to apply the RFA technique to air temperature data
under climate change conditions

## Installation

You can install the development version of NSTempRFA like so:

``` r
# install.packages("devtools")
devtools::install_github("gabrielblain/NSTempRFA")
```

## Theoretical Background

The Regional Frequency Analysis (RFA; Dalrymple, 1960) technique has
been widely used to improve the probabilistic assessment of extreme
rainfall and flood events worldwide. The fundamental concept behind RFA
is to evaluate whether a group of time series from distinct sites can be
considered “acceptably homogeneous” (Hosking and Wallis, 1997). If this
condition is met, data from all sites can be pooled together,
effectively trading space for time, and thus extending the effective
data length (Smith et al. 2015).

In its original version, the RFA is valid only when the variable of
interest assumes strictly positive values. However, Martins et
al. (2022) verified that this technique can can be effectively applied
to extreme maximum (Tmax) and minimum (Tmin) air temperature series,
which may assume both positive and negative values, by adopting the
so-called additive approach.

This additional approach is consistent with the physical characteristics
of temperature data. Since the fundamental temperature scale is the
Kelvin scale, where 0 K equals -273.15°C (or -459.67°F), both Tmax and
Tmin values fall within a relatively narrow range compared to their
distance from absolute zero. As a result, the variability in Tmax and
Tmin distributions can be treated as largely independent of their sample
mean (Martins et al. 2022). Moreover, when expressed in Celsius or
Fahrenheit, Tmin values may be negative, further justifying the use of
the additive approach.

Although the study by Martins et al. (2022) showed promising results, it
did not address the influence of long-term warming trends, which have
been documented in nearly all regions of the world (IPCC, 2021). This
calls for an extension of the RFA framework to incorporate
time-dependent, nonstationary statistical properties.

This package proposes a new methodology for applying the RFA to extreme
Tmax and Tmin data under nonstationary climate conditions.

## Examples

``` r
library(NSTempRFA)
## basic example code
```

# Methodological Details

From a statistical perspective, ongoing climate change has altered the
frequency and intensity of extreme weather events, leading to a
nonstationary environment (O’Brien et al., 2014). As a result, the
original RFA technique must be extended to account for nonstationarities
in the data. To the best of our knowledge, O’Brien et al. (2014) was the
first study to propose such an extension. This package adapted this
extension to the additive approach (equation 1):

$$
Q_{i,t}(F) = mu_t + q_t(F), \quad i = 1, \dots, N \quad \text{and} \quad 0 < F < 1
$$

Where: - $Q_{i,t}(F)$ is the quantile function at site *i* and time
*t*, - $q_t(F)$ is the time-varying regional quantile function (growth
curve), - $mu_t$ is the time-dependent index value (regional location
parameter), - and *N* is the number of sites in the homogeneous region.

Add more information

## BugReports:

<https://github.com/gabrielblain/NSTempRFA/issues>

## License:

MIT

## Authors:

Gabriel Constantino Blain, Graciela da Rocha Sobierajski, Leticia Lopes
Martins. Maintainer: Gabriel Constantino Blain,
<gabriel.blain@sp.gov.br>

## Acknowledgments:

## References
