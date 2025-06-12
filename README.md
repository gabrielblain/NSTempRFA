
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

## Basic Instructions: Functions

## Function `Add_Discord()`

### Description

This function calculates the Hosking and Wallis’ discordance measure
(discord) and the robust discordance measure (Neykov et al. 2007)
\<10.1029/2006WR005322\> using the additive approach proposed in Martins
et al. (2022) <doi:10.1590/1678-4499.20220061>.

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

A data.frame with 9 columns:  
- Local Site identifier.  
- SampleSize Number of observations for each site.  
- l_1 L-moment ratio (mean).  
- l_2 L-moment ratio (L-scale).  
- t_3 L-moment ratio (L-skewness).  
- t_4 L-moment ratio (L-kurtosis).  
- t_5 L-moment ratio (higher-order L-moment).  
- discord Original discordance statistic indicating potential outlier
status.  
- Rdiscord Robust discordance statistic indicating potential outlier
status.

### Example

``` r
d <- Add_Discord(dataset)
d
#>        Local SampleSize      l_1       l_2         t_3         t_4          t_5
#> 1   station1         30 35.88014 0.9101509 -0.01000236 -0.02660405  0.018535639
#> 2   station2         30 36.26881 0.7665997  0.11838208  0.17344439 -0.072148735
#> 3   station3         30 35.83018 0.6930622 -0.02287773  0.12284304  0.002239872
#> 4   station4         30 35.92437 0.7248267  0.10588835  0.17731736  0.103498918
#> 5   station5         30 36.04813 0.9035106  0.07319447  0.05764218  0.006110935
#> 6   station6         30 36.02385 0.8043848  0.07776934  0.10362090  0.027541962
#> 7   station7         30 36.16505 0.7646563  0.10113017  0.12760768  0.040031997
#> 8   station8         30 36.26044 0.7656625  0.12206614  0.12993288  0.021108886
#> 9   station9         30 35.78842 0.8056041  0.06239341  0.16295610  0.060259533
#> 10 station10         30 35.98069 0.7931523  0.16382678  0.16124689  0.129321805
#> 11 station11         30 35.98803 0.9311351  0.11049566  0.25120122  0.094061369
#> 12 station12         30 36.04637 0.7742376  0.10761928  0.24473054  0.116691268
#> 13 station13         30 35.83736 0.7859081  0.12783581  0.16835376  0.008625145
#> 14 station14         30 35.80372 0.7505526  0.09521710  0.16468093  0.007416054
#> 15 station15         30 36.03321 0.8850777  0.13837747  0.08950170  0.034428494
#>      discord  Rdiscord
#> 1  2.7436767 3.7123300
#> 2  0.7497172 0.8683772
#> 3  2.7705597 2.2528774
#> 4  1.1483500 0.9962320
#> 5  1.6051706 1.9325744
#> 6  0.5632837 0.7828627
#> 7  0.8301919 0.9292602
#> 8  1.1464680 1.2553979
#> 9  0.9762547 2.0755583
#> 10 1.5619263 1.2136336
#> 11 3.1028722 7.3386056
#> 12 1.6057547 3.7007056
#> 13 0.7652931 0.9069083
#> 14 0.7572773 0.6398330
#> 15 1.8055169 1.4725148
```

## Function `dataset_add()`

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
dataset <- dataset
dataset.add <- dataset_add(dataset)
dataset.add
#> $add_data
#>      station1    station2    station3    station4   station5     station6
#> 1  -0.6703581  0.16529744 -1.10888768 -0.78452255 -2.4101188  1.938189953
#> 2  -1.8949130 -2.84024583 -0.79227208 -1.23980735 -1.8235506 -0.739923782
#> 3  -2.3609912 -1.91731125  0.98661878  0.53582921 -1.7906241 -2.133642395
#> 4  -2.4741256 -0.61256770 -2.45347476 -1.88134983 -2.6246584 -1.865557272
#> 5  -1.9138497 -0.55008300 -1.42120617 -2.16576628 -1.9183661 -1.950152157
#> 6  -1.0790870 -0.09516983 -2.12300097 -0.61880138 -1.1476583 -1.039824565
#> 7  -2.2569319 -0.46470900  0.98347563 -1.87222167 -1.1561187 -1.994827726
#> 8  -1.6593689 -0.76383095  1.24388301 -0.61887005  1.1056513  1.939431666
#> 9  -0.4207335 -1.83895642 -1.31443417 -0.10777043 -0.3696588 -1.886336687
#> 10 -1.0623659  2.11456955 -0.02330494 -0.10431790 -1.0588082 -1.713403527
#> 11 -1.6568927 -0.21099689 -1.73541766  0.01477008 -0.3232024  0.149214780
#> 12 -0.9071309 -0.55238576 -0.49589597  0.28788260 -0.7811724 -0.675813996
#> 13  1.0499683 -0.27943199  0.13388674  0.65172401 -0.1457365 -0.351897227
#> 14  0.4442759 -1.24360428 -1.27542759 -1.40718878 -0.9576543  0.513097039
#> 15 -1.3201236 -0.42998026  0.33053770 -0.98055883 -1.1388563 -0.537836293
#> 16  0.1051411 -1.09361963 -0.49747807 -1.08025355 -0.9236582  0.176788110
#> 17  0.4645869  0.19343773 -0.41752518 -0.37482679 -1.2461744 -0.713154340
#> 18 -0.5748762 -0.91733955 -0.06884690 -0.42206606  1.6731776  0.821546414
#> 19  1.5594081  3.06240887  1.27365572  0.71348482  2.4957517  1.675160382
#> 20  1.3679178 -0.58141261 -0.17433395 -0.96933036  2.3383846  2.455797913
#> 21  0.7368384  1.85868924  0.87483184  0.49632506  1.4313065  1.595667290
#> 22  1.3101670 -0.31508316  1.24940130  0.61736485  0.6657105 -0.103701032
#> 23  2.1242436  1.87173753  2.45360164  3.69673034  1.4170228  0.646690026
#> 24  1.8207629  1.04815813  0.55746926  2.64334778  0.8274709  1.323600048
#> 25  1.7320056 -1.12291313 -0.17664097  0.62895117  0.3398146  0.063543957
#> 26  1.4397518  0.76722834  0.11125994  0.76653498  1.0273398 -0.340830475
#> 27  1.5650428  1.02935803  1.51812203  1.35444261  0.7936984 -0.042019688
#> 28  1.8040001 -0.01046598  0.31821129  0.85485445  1.8770482 -0.246005365
#> 29 -0.1883632  1.26548389  0.03246965 -0.34338512  0.3377390 -0.006695743
#> 30  2.9160009  2.46373847  2.01072253  1.70879494  3.4859009  3.042894694
#>       station7    station8    station9   station10    station11   station12
#> 1  -0.44975109 -0.79782426  0.63510699 -1.31632037 -2.349721611 -2.32197916
#> 2  -0.54239200 -2.23258873 -1.52903539 -0.76413519 -2.636169844 -1.80288950
#> 3  -1.25502074 -0.93471956 -2.06383749 -1.74500183 -1.188571712 -0.15684355
#> 4  -1.75776237 -1.41559586 -2.47729533 -1.86061291 -2.677427668 -1.58384161
#> 5  -2.22684855 -0.87472418 -2.47813592 -1.60609767 -2.501494773 -2.48740414
#> 6   0.69508612 -0.70626874 -0.94136125 -1.77217911 -0.317864498  0.95728037
#> 7  -1.88271548 -2.01572745 -0.56455437 -1.86275793 -1.925810382  0.74802208
#> 8   0.48395334  0.68366540  0.81573593 -0.11402100  0.023403469 -0.69828369
#> 9  -0.03975260  0.77419739  0.24254239 -0.98318626  0.014181074 -0.56290061
#> 10  1.46819061 -0.05608140 -0.82666840  2.06681498 -1.192322190 -0.07803361
#> 11 -1.29614548 -1.01654379 -1.00491904 -0.83255406 -0.901987857 -0.92806175
#> 12 -0.82908846  0.19651239  0.80889151 -0.05490057 -0.419482552  0.13416804
#> 13  0.79794053 -0.97136511 -1.10069408  0.58352873  0.119932192  1.14313335
#> 14 -1.40427175 -1.18089740 -0.34197162  1.18867455 -0.419603346 -0.24396765
#> 15 -1.24579888 -0.63046623 -0.63153525 -1.27068396  0.077742885 -1.19624869
#> 16 -1.57638825 -1.90177469 -0.57230654 -1.10985794  0.158688401 -1.29869562
#> 17 -0.12990760  0.77809961 -1.46661578 -0.33197808 -0.269136377 -0.62295968
#> 18 -0.19845611  2.74691663  0.89981714  0.26877560  0.701690472  0.92821527
#> 19  2.04393764 -0.05502127  1.39641833 -0.25885309  5.102582990  1.92277760
#> 20  0.09401428 -0.41296199  2.99717667  0.14671249 -0.007272568  0.82794020
#> 21  1.57961229  1.07711959  2.30185518 -0.05084489 -0.631359779  0.72430737
#> 22 -0.23971709  0.61490872  0.64900045  1.69462252  1.967468979  0.28900735
#> 23 -0.17074347  1.21033543  1.00850436  3.49240915  2.852523181  1.78670774
#> 24 -0.18776028  3.46427670  3.36331845  0.45895719  1.775731898 -0.75900838
#> 25 -0.21406880  0.06428527 -0.09372093  0.15218528  0.765937056 -0.22046894
#> 26  1.55134946  1.53139634  0.64648912  0.11768703  0.040240375  0.68259829
#> 27  1.87667137 -0.61616682 -0.64366292  0.40081814  2.333640896 -0.02693223
#> 28  0.30749758  1.55990378 -0.03850895  1.34530825  0.140475063  0.10892011
#> 29  1.20244700 -0.32208515  0.32980856  0.40572966 -0.306620389 -0.36034941
#> 30  3.54588880  1.43919538  0.68015817  3.61176128  1.670606614  5.09579044
#>      station13   station14   station15
#> 1  -1.54273055  0.85993031 -1.97199601
#> 2  -0.92922465 -0.36954238 -1.23394564
#> 3  -1.38725308 -1.78227335 -1.39435746
#> 4  -2.69496399 -1.74678874 -2.40695336
#> 5  -0.01635974 -2.53056761 -1.99237331
#> 6  -1.04246604 -1.68502752 -0.99535476
#> 7  -0.63042388 -1.19507965 -1.44832606
#> 8  -0.54605637  1.18650433  2.21262571
#> 9  -0.04067190 -1.39238281 -1.62597139
#> 10 -0.00678911 -0.66672338 -0.31670820
#> 11 -1.93729771 -0.89718137  0.21088927
#> 12 -0.26376663  0.49495782  2.02178015
#> 13 -0.48120979 -0.44752627 -0.08714036
#> 14 -1.04587398 -0.48887867 -1.04014497
#> 15 -1.50653976 -0.32296276 -1.35395610
#> 16 -0.72766830 -0.63875926 -0.47656479
#> 17 -0.92959841  0.17618974 -1.45121450
#> 18  3.29056023 -0.15719566  2.30676041
#> 19 -0.18838065 -0.14104692  0.85167579
#> 20  1.15936726  1.92143809  0.10983767
#> 21  0.68409117  0.27055983  2.28409944
#> 22  1.92189384  2.56689445  2.15941634
#> 23  1.22321081  2.07233900  0.70160868
#> 24  0.21290656  0.10872020  0.75284914
#> 25  0.64986027 -0.76606564  0.18629910
#> 26  1.74070076  0.45880225  0.15448082
#> 27  1.39479363  1.47585059  0.30642565
#> 28  0.48232053  0.58950248 -0.73778699
#> 29  0.01941084  0.07857613  0.32908181
#> 30  3.13815863  2.96773677  3.94496392
#> 
#> $reg_mean
#>  station1  station2  station3  station4  station5  station6  station7  station8 
#>  35.88014  36.26881  35.83018  35.92437  36.04813  36.02385  36.16505  36.26044 
#>  station9 station10 station11 station12 station13 station14 station15 
#>  35.78842  35.98069  35.98803  36.04637  35.83736  35.80372  36.03321
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
