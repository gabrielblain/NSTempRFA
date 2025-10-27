
# NSTempRFA

<!-- badges: start -->

<!-- Example badges you can add after uploading to GitHub: [![R-CMD-check](https://github.com/yourusername/NSTempRFA/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yourusername/NSTempRFA/actions) [![CRAN status](https://www.r-pkg.org/badges/version/NSTempRFA)](https://CRAN.R-project.org/package=NSTempRFA) [![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) -->

[![R-CMD-check](https://github.com/gabrielblain/NSTempRFA/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gabrielblain/NSTempRFA/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

A package designed to apply the RFA technique to air temperature data
under climate change conditions

## Installation

You can install the development version of NSTempRFA from GitHub with:

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

## Basic Instructions

### **Load the library for examples below**

``` r
library(NSTempRFA)
```

### Function `Add_Discord()`

### Description

This function calculates the Hosking and Wallis’ discordance measure
(discord) using the additive approach proposed in Martins et al. (2022)
<doi:10.1590/1678-4499.20220061>.

### Usage

Add_Discord(dataset)

### Arguments

**dataset:** A numeric matrix with extreme air temperature data from
multiple sites. The first column must contain the years, and the
remaining columns contain temperature data from each site.

### Details

The discordance measures identify sites that are potentially discordant
within a regional frequency analysis framework for extreme air
temperature series.

### Value

A data.frame with seven columns:  
- Local Site identifier.  
- SampleSize Number of observations for each site.  
- l_1 L-moment ratio (mean).  
- l_2 L-moment ratio (L-scale).  
- t_3 L-moment ratio (L-skewness).  
- t_4 L-moment ratio (L-kurtosis).  
- t_5 L-moment ratio (higher-order L-moment).  
- discord Original discordance statistic indicating potential outlier
status.

### Example

``` r
dataset <- TmaxCPC_SP
Add_Discord(dataset)
#>       Local SampleSize      l_1       l_2          t_3        t_4          t_5
#> 1   Pixel_1         34 35.49129 0.5702889 -0.046839615 0.12967963  0.117454055
#> 2   Pixel_2         34 33.47568 0.7114659  0.008514648 0.12875566 -0.016283412
#> 3   Pixel_3         34 34.42286 0.6216035 -0.006632936 0.11958897  0.050620060
#> 4   Pixel_4         34 35.05986 0.5818588  0.103225296 0.05659463  0.082984024
#> 5   Pixel_5         34 34.97852 0.7661857  0.180355170 0.09655880  0.101565708
#> 6   Pixel_6         34 34.54346 0.7651060  0.171180354 0.13719846  0.027045326
#> 7   Pixel_7         34 34.30666 0.7231769  0.114853094 0.16820816  0.015520001
#> 8   Pixel_8         34 32.81977 0.7120049  0.193897168 0.15569518  0.088295774
#> 9   Pixel_9         34 35.96037 0.8583378  0.186372622 0.10856159  0.011871484
#> 10 Pixel_10         34 35.46055 0.8180569  0.161493008 0.16103322 -0.009130147
#>      discord
#> 1  1.7860794
#> 2  1.6373754
#> 3  1.2644379
#> 4  2.4153036
#> 5  1.3050367
#> 6  0.7750693
#> 7  1.3517363
#> 8  1.9897006
#> 9  1.9723056
#> 10 1.3101471
```

### Function `Dataset_add()`

### Description

Subtract the sample mean of each column from their corresponding data.

### Usage

dataset_add(dataset)

### Arguments

**dataset:** A numeric matrix with extreme air temperature data from
multiple sites. The first column must contain the years, and the
remaining columns contain temperature data from each site.

### Value

A list object with the following elements:  
- Subtracted_data: A matrix of temperature values subtracted by their
sample mean.  
- reg_mean: Sample mean for each site.

### Example

``` r
dataset <- TmaxCPC_SP
Dataset_add(dataset)
#> $add_data
#>         Pixel_1     Pixel_2     Pixel_3     Pixel_4     Pixel_5     Pixel_6
#> 1   0.806680901  0.39890895  0.51382457  0.07826973 -1.26789206 -0.62984085
#> 2  -1.276407019 -1.07100835 -1.46701802 -1.14710640 -0.92446249 -0.79555893
#> 3  -1.067941439 -0.36950841 -0.81885517 -1.31494545  0.54887659  0.35712051
#> 4  -0.876817479 -0.68805471 -0.57519520  0.28452660  0.66295130 -0.42699433
#> 5  -0.129327549 -0.74817052 -0.27107609  0.44226815 -0.18384283 -0.84130478
#> 6   0.036894071 -0.63226476 -0.60400761 -0.79813026 -1.78046530 -0.92012787
#> 7   2.638433681  1.95663676  2.08730327  1.33298088  0.14825327  0.86101532
#> 8   0.444929351 -0.47622457  0.29207241  0.47764565 -1.57320898 -0.23893738
#> 9   1.040842281 -1.64627423 -1.50838841 -1.25554298 -1.11890142 -1.59651947
#> 10 -1.506883399 -2.42683187 -1.84099568 -0.21410774 -1.38093679 -1.37288666
#> 11  0.324857941 -1.55034795 -0.66855992  0.03188683 -1.41308706 -2.18091965
#> 12  0.371961821  0.58032069  0.53155910  1.13059594  0.68552286  1.42906951
#> 13  0.811525571  1.88877330  1.33351146  1.41313912  1.54653818  2.03365707
#> 14 -1.943567049 -2.21049085 -1.74813450 -1.44470237 -1.37753027 -1.80634308
#> 15  0.049181211  1.02473674  0.53503811 -0.39466499 -1.64567678 -1.55134964
#> 16  0.021272881  1.69644389  1.78262340  1.20808388 -1.49557989 -0.52707673
#> 17  0.395166621  0.68113551  0.42061245 -0.31176399 -1.38004416 -1.31818772
#> 18 -0.888894809  0.04522548 -0.37732685 -1.31680320 -0.47039526 -0.38025284
#> 19  0.380510551  0.32385859  0.34467708  0.10145928 -0.09685629  0.39632034
#> 20  1.573175651  0.94999156  0.47639858 -1.10231422  0.35593302  0.06438446
#> 21  0.407774201 -0.41990819 -0.17923725 -0.53943657 -0.17395132 -0.84939194
#> 22  0.859503021 -0.35633626  0.36359035  0.54243828  0.29317743  0.12120056
#> 23 -0.951265109 -2.10568776 -1.96636570 -0.94400428 -0.74292105 -1.39243699
#> 24 -0.411588449  0.17400584  0.12923061  0.67784096  1.06674463  0.70520019
#> 25  0.537821041  0.48855433  0.53112423  0.34025551  0.58240015  0.59571457
#> 26  0.567846521 -0.29345479  0.06583797 -0.45301078  0.07931025 -0.48486710
#> 27 -1.640302429 -0.43832173 -1.15145481 -1.16273521  0.23186380 -0.02808381
#> 28  0.006403191 -0.80364766 -0.73622502 -0.89390205 -0.88955038 -0.80413437
#> 29  1.060312491  1.03521952  1.04153072  0.76687600  1.53927500  1.46383285
#> 30  0.902807461  2.65113673  1.84338772  1.91324593  3.89446527  3.31644058
#> 31 -1.427316439  0.75615916  0.48415004  0.73680855  2.06313211  2.15882492
#> 32 -1.255941169 -0.76440206 -0.90240467 -0.87110923 -0.38806265  0.15259933
#> 33 -0.003717199  1.76204524  1.84878170  2.50021721  2.62044031  3.17444229
#> 34  0.142069091  0.58778224  0.18999111  0.18574120  1.98448069  1.31539154
#>        Pixel_7      Pixel_8     Pixel_9   Pixel_10
#> 1  -0.22739680  0.101871711 -1.17935888 -1.3090836
#> 2  -1.11911662 -1.011674659 -1.37078420 -1.4325768
#> 3  -0.36224635 -1.069068689  0.51408824  0.1935943
#> 4  -0.28177531 -0.048602829 -0.32252065 -0.1915604
#> 5  -0.37523539 -0.147311939 -0.98650304 -0.4959847
#> 6  -0.72715647 -1.013328329 -1.76890889 -0.2924286
#> 7   0.91251104  0.823360671  0.64647349  0.7911132
#> 8   0.33811681 -0.042125479 -1.63996068 -0.5049988
#> 9  -1.47085078 -0.268409509 -1.41883413 -1.5299050
#> 10 -1.64861567 -1.330280079 -0.94290105 -0.8587967
#> 11 -2.54513819 -1.010923159 -1.51050893 -1.5668694
#> 12  0.86088292  0.210121381  0.84732112  0.2927726
#> 13  1.25885122  0.920772781 -0.07001439  0.1628173
#> 14 -1.92120631 -2.161268009 -1.39242498 -2.2887703
#> 15 -0.35035212 -1.156675119 -2.66049520 -2.5558716
#> 16  1.23415487  0.213909371 -1.18843786 -1.3668496
#> 17 -1.06052668 -0.898059619 -0.45487920 -0.5257050
#> 18 -0.71214946 -1.450120699 -0.26275579 -0.2712456
#> 19  0.05151861 -1.352054369 -0.52853719 -1.0365235
#> 20 -0.76660807 -1.295602579 -0.87979070 -0.8687760
#> 21 -0.80171092 -1.016113059  0.43672999 -0.2468506
#> 22  0.12325780  0.496650921  1.04116114  1.2301925
#> 23 -1.25236781 -0.008384479 -0.45061818 -0.5201851
#> 24  0.83279531  1.542698131  1.77628382  2.2546600
#> 25  0.62188833  0.806156381  0.65869578  1.1264862
#> 26 -0.28351481  0.199932321  0.70248851  0.5215362
#> 27 -0.52587779 -0.303710709  0.57683619  0.4834198
#> 28 -0.75292094 -0.970168839 -0.89823095 -0.7556092
#> 29  1.14297597  0.548031081  2.41230067  1.0458702
#> 30  2.90345876  3.093185651  3.94813594  3.3613800
#> 31  2.03954809  2.267257911  2.89697703  2.9804519
#> 32  0.48710744  0.231853711 -1.19216481 -0.7576615
#> 33  3.36168020  3.492275461  2.49659404  2.9711364
#> 34  1.01601903  1.605804671  2.16454371  1.9608215
#> 
#> $reg_mean
#>  Pixel_1  Pixel_2  Pixel_3  Pixel_4  Pixel_5  Pixel_6  Pixel_7  Pixel_8 
#> 35.49129 33.47568 34.42286 35.05986 34.97852 34.54346 34.30666 32.81977 
#>  Pixel_9 Pixel_10 
#> 35.96037 35.46055
```

### Function `Add_Heterogenety()`

### Description

Calculates Hosking and Wallis’ heterogeneity measure using the additive
approach proposed in MARTINS et al. (2022).

### Usage

Add_Heterogenety(dataset.add, rho, Ns)

\##Arguments **dataset.add**: A matrix of temperature values subtracted
by their sample mean, as calculated by the `Add_Discord()` function.  
**rho**: A single numeric value (constant) describing the average
correlation among the sites. It must be larger than -1.0 and lower than
1.0.  
**Ns**: Number of simulated groups of series. Default is 100, but at
least 500 is recommended.

### Example

``` r
rho <- 0.51
Ns <- 500
add.data <- Dataset_add(TmaxCPC_SP)
Add_Heterogenety(dataset.add=add.data$add_data,rho = rho,Ns = Ns)
#> [1] 0.9286533
```

### Function `Best_model()`

### Description

Calculates the time-varying parameters of the best fitting GEV model for
each site. See **Methodological Details** for more information on the
candidade GEV-models considered in this package.

\###Usage Best_model(add_data)

### Arguments

**add_data**: A matrix of temperature values subtracted by their sample
mean. May be generated by the `dataset_add()` function

### Value

A list object with the following elements:  
- best: The best model among the six candidates. - atsite.models: The
time-varying parameters of the best model.

### Example

``` r
add.data <- Dataset_add(TmaxCPC_SP)
Best_model(add.data=add.data$add_data)
#> $best
#> V2 
#>  2 
#> 
#> $atsite.models
#>           mu0          mu1    sigma0 sigma1       shape size
#> 1  -0.2864336 -0.004971809 0.9852760      0 -0.23987862   34
#> 2  -1.0227894  0.035332791 1.1698222      0 -0.29729970   34
#> 3  -0.7748006  0.022975995 1.0269278      0 -0.26978834   34
#> 4  -0.6901442  0.015431062 0.8563226      0 -0.11111473   34
#> 5  -1.6362737  0.062523525 0.8888875      0  0.02677818   34
#> 6  -1.5547575  0.059680647 1.0063711      0 -0.08750300   34
#> 7  -1.5262793  0.063459052 1.0688034      0 -0.23920558   34
#> 8  -1.4567797  0.057640734 1.0035459      0 -0.15821851   34
#> 9  -2.0731388  0.094374300 1.1884099      0 -0.27779739   34
#> 10 -2.0294572  0.096551734 1.2348429      0 -0.41420337   34
```

### Function `Reg_par()`

### Description

Calculates the regional parameters for the regional time-varying GEV
distribution.

### Usage

Reg_par(best_model)

### Arguments

**best_model**: A 7-column data.frame as that generated by Best_model()
function.  
- 1st column is the mu0 parameters  
- 2nd is the mu1 parameters  
- 3rd is the mu2 parameters  
- 4th is the sigma0 parameters  
- 5th is the sigma1 parameters  
- 6th is the shape parameters  
- 7th is the sample sizes.

### Value

A data.frame with the regional parameters of the regional time-varying
distribution.

### Example

``` r
add.data <- Dataset_add(TmaxCPC_SP)
best.parms <- Best_model(add.data=add.data$add_data)
Reg_par(best_model=best.parms$atsite.models)
#>   weighted_mu0 weighted_mu1 weighted_sigma0 weighted_sigma1 weighted_shape
#> 1    -1.305085    0.0502998        1.042921               0     -0.2068231
```

### Function `Reg_parCI()`

### Description

Calculates the 95% confidence intervals of time-varying parameters of
the regional GEV distribution. It follows the method proposed by Burn
(2003) and O’Brien and Burn (2014). The spatial dependence between sites
is preserved.

### Usage

Reg_parCI(add_data, reg_par, max_time, n.boots)

### Arguments

**add_data**: A matrix of temperature values subtracted by their sample
mean. May be generated by the `dataset_add()` function.  
**reg_par**: A 6-column and 1-row data.frame as that generated by
reg_par(), that is: - 1st column is the mu0 parameter  
- 2nd is the mu1 parameter  
- 3rd is the mu2 parameter  
- 4th is the sigma0 parameter  
- 5th is the sigma1 parameter  
- 6th is the shape parameter  
**max_time**: A single number describing the number of the year that the
time-varying parameters should be calculated. For example, if the users
need to calculated the parameters for the first year max_time is set to
1 and the 30th year max_time is set to 30.  
**n.boots**: A single number describing the number of copies of the
original dataset. Whenever possible n.boots should be set to 999 (its
default value), as suggested by Burn (2003) and O’Brien and Burn (2014).

### Value

A matrix containing the 95% confidence intervals (lower and upper
bounds) of the time-varying parameter estimates.

### Example

``` r
add.data <- Dataset_add(TmaxCPC_SP)
best.parms <- Best_model(add.data=add.data$add_data)
regional.parms <- Reg_par(best_model=best.parms$atsite.models)
Reg_parCI(add_data=add.data$add_data,
model=2,
reg_par=regional.parms,
n.boots=100)
#> This calculation takes a real while.
#>   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100%
#>              weighted_mu0 weighted_mu1 weighted_sigma0 weighted_sigma1
#> Lower 95% CI    -1.885425   0.02784601        0.860996               0
#> Upper 95% CI    -0.643991   0.07644145        1.244353               0
#>              weighted_shape
#> Lower 95% CI    -0.43383148
#> Upper 95% CI    -0.01451781
```

### Function `Site_parCI`

### Description

Calculates the 95% confidence intervals of time-varying parameters of a
at-site GEV distribution. It follows the method proposed by Burn (2003).

### Usage

Site_parCI(data_site, site_par, max_time, n.boots)

### Arguments

**data_site**: A vector or single column matrix of temperature values
subtracted by its sample mean  
**site_par**: A 6-column and 1-row data.frame. It may be obtained from
best.parms()  
• 1st column is the mu0 parameter  
• 2nd is the mu1 parameter  
• 3rd is the mu2 parameter  
• 4th is the sigma0 parameter  
• 5th is the sigma1 parameter  
• 6th is the shape parameter  
**max_time**: A single number describing the number of the year that the
time-varying parameters should be calculated. For example, if the users
need to calculated the parameters for the first year max_time is set to
1 and the 30th year max_time is set to 30.  
**n.boots**: A single number describing the number of copies of the
original data sample. Whenever possible n.boots should be set to 999
(its default value), as suggested by Burn (2003).

### Value

A matrix containing the 95% confidence intervals of the time-varying
parameter estimates for a at-site model.

### Example

``` r
 temperatures <- TmaxCPC_SP$Pixel_1
model <- 2
 site_par <- Fit_model(temperatures, model)
 Site_parCI(atsite_temp=temperatures,
            model=model,
            site_par=site_par[1:5],
            n.boots=100)
#> This calculation may take a while.
#>   |                                                                              |                                                                      |   0%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |===                                                                   |   4%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  17%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |================================                                      |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |======================================                                |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  77%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================| 100%
#>                   mu0         mu1    sigma0 sigma1      shape
#> Lower 95% CI 34.47589 -0.03638963 0.7983467      0 -1.0845594
#> Upper 95% CI 35.85089  0.02677963 1.8725642      0 -0.1004983
```

### Function `Add_RegProb`

### Description

Calculates the cumulative probability of extreme air temperature data
using the Additional nonstationary RFA approach based on the GEV
distribution.

### Usage

Add_RegProb(quantiles, reg_par, site_mean, max_time)

### Arguments

**quantiles**: A numeric vector with no missing data with extreme air
temperatures  
**reg_par**: A 6-column and 1-row data.frame as that generated by
reg_par(), that is: - 1st column is the mu0 parameter  
- 2nd is the mu1 parameter  
- 3rd is the mu2 parameter  
- 4th is the sigma0 parameter  
- 5th is the sigma1 parameter  
- 6th is the shape parameter  
**site_mean**: A single number with site’s average value for the air
temperature data  
**max_time**: A single number describing the number of the year that the
time-varying parameters should be calculated. For example, if the users
need to calculated the parameters for the first year max_time is set to
1 and the 30th year max_time is set to 30.

### Value

Cumulative probabilities of extreme air temperature data calculated from
the Additional nonstationary RFA approach.

### Example

``` r
 quantiles <- c(37.2, 37.5, 37.8, 37.9, 38.0, 38.1, 38.2, 38.5, 39.0)
 add.data <- Dataset_add(TmaxCPC_SP)
 best.parms <- Best_model(add.data=add.data$add_data)
 regional_pars <- Reg_par(best_model = best.parms$atsite.models)
 Add_RegProb(quantiles=quantiles,
                   regional_pars=regional_pars,
                   site_temp=TmaxCPC_SP$Pixel_1,
                   n.year=34)
#>            [,1]
#>  [1,] 0.7902025
#>  [2,] 0.8545796
#>  [3,] 0.9038670
#>  [4,] 0.9172022
#>  [5,] 0.9291197
#>  [6,] 0.9397071
#>  [7,] 0.9490556
#>  [8,] 0.9706002
#>  [9,] 0.9902066
```

### Function `Add_RegQuant`

### Description

Calculates quantiles estimates from cumulative probabilities of extreme
air temperature data using the Additional nonstationary RFA approach
based on the GEV distribution.

### Usage

Add_RegQuant(prob, reg_par, site_mean, max_time)

### Arguments

**prob**: A numeric vector with no missing data with the cumulative
probabilities (between 0 and 1).  
**reg_par**: A 6-column and 1-row data.frame as that generated by
reg_par(), that is: - 1st column is the mu0 parameter  
- 2nd is the mu1 parameter  
- 3rd is the mu2 parameter  
- 4th is the sigma0 parameter  
- 5th is the sigma1 parameter  
- 6th is the shape parameter  
**site_mean**: A single number with site’s average value for the air
temperature data  
**max_time**: A single number describing the number of the year that the
time-varying parameters should be calculated. For example, if the users
need to calculated the parameters for the first year max_time is set to
1 and the 30th year max_time is set to 30.

### Value

Quantile estimates of extreme air temperature data calculated from the
Additional nonstationary RFA approach.

### Example

``` r
 prob <- c(0.8, 0.85, 0.90, 0.92, 0.93, 0.94, 0.95, 0.97, 0.99)
 add.data <- Dataset_add(TmaxCPC_SP)
 best.parms <- Best_model(add.data=add.data$add_data)
 regional_pars <- Reg_par(best_model = best.parms$atsite.models)
 Add_RegQuant(
   prob = prob,
   regional_pars = regional_pars,
   site_temp = TmaxCPC_SP$Pixel_1,
   n.year = 34
 )
#>      Q80      Q85      Q90      Q92      Q93      Q94      Q95      Q97 
#> 37.24134 37.47600 37.77291 37.92247 38.00787 38.10295 38.21086 38.48963 
#>      Q99 
#> 38.99157
```

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

Burn, D.H., 2003. The use of resampling for estimating confidence
intervals for single site and pooled frequency analysis. Hydrol. Sci. J.
48 (1), 25–38. DOI: 10.1623/hysj.48.1.25.43485.

O’Brien, N.L., Burn,H.D. A nonstationary index-flood technique for
estimating extreme quantiles for annual maximum streamflow, Journal of
Hydrology, v.519, 2014, DOI: 10.1016/j.jhydrol.2014.09.041.

Dalrymple, T. (1960). Flood frequency analysis. Geological Survive Water
Supply Paper, 1543-A, 11-51. DOI: 10.3133/wsp1543A

\[IPCC\] Intergovernmental Panel on Climate Change (2021). Climate
Change 2021: The Physical Science Basis. Contribution of Working Group I
to the Sixth Assessment Report of the Intergovernmental Panel on Climate
Change. Cambridge University Press. Available at:
<https://www.ipcc.ch/report/ar6/wg1/> Accessed on: Jan. 1, 2025.

Martins, L. L., Souza, J. C., Sobierajski, G. R. and Blain, G. C.
(2022). Is it possible to apply the regional frequency analysis to daily
extreme air temperature data? Bragantia, 81, 1-22. DOI:
10.1590/1678-4499.20220061

Smith, A., Sampson, C., & Bates, P. D. (2015). Regional flood frequency
analysis at the global scale. Water Resources Research, 51(1), 539–553.
DOI: 10.1002/2014WR015814

Hosking JRM, Wallis JR (1997) Regional frequency analysis: an approach
based on L-moments. Cambridge University Press. DOI:
10.1017/cbo9780511529443
