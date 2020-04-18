Download and process Vasaloppets results data using R
=============================================

This project allows you to download and process [Vasaloppets](https://en.wikipedia.org/wiki/Vasaloppet) results data from [results.vasaloppet.se](http://results.vasaloppet.se/).

It outputs a results with split times for both women and men in the Sundays main event in `.RDS` and `.csv` -format in `./data`-folder. This setup has been tested to process data from 2016-2020.

First install the required libraries.

```r
libs_cran <- c("rvest","dplyr","stringr","glue","tidyr","fs","here")
inst <- match(libs_cran, .packages(all=TRUE)); install.packages(libs_cran[which(is.na(inst))])
```

Then pull all the individual pages for both men and women into `.csv`-files by running the following commands.

```r
source("./scrape_results_men.R")
source("./scrape_results_women.R")
```

Both will end with an error :), womens after ~10 minutes, men in ~60minutes. Once processed run  `source("process_results_data.R")` to get the final data. `analysis.R`-script does not work!

Data should look like this

```
dat <- readr::read_csv("./data/resultat_med_splits_tidy_2020.csv")
> glimpse(dat)
Rows: 107,352
Columns: 25
$ place       <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3…
$ name        <chr> "Eliassen, Petter", "Eliassen, Petter", "Eliassen, Petter", "Eliass…
$ nat         <chr> "NOR", "NOR", "NOR", "NOR", "NOR", "NOR", "NOR", "NOR", "NOR", "NOR…
$ nr          <dbl> 14, 14, 14, 14, 14, 14, 14, 14, 14, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3…
$ class       <chr> "H35", "H35", "H35", "H35", "H35", "H35", "H35", "H35", "H35", "H21…
$ v6          <chr> "Club–", "Club–", "Club–", "Club–", "Club–", "Club–", "Club–", "Clu…
$ v7          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
$ time        <time> 04:25:14, 04:25:14, 04:25:14, 04:25:14, 04:25:14, 04:25:14, 04:25:…
$ diff        <dttm> 2020-04-17 21:00:00, 2020-04-17 21:00:00, 2020-04-17 21:00:00, 202…
$ split       <chr> "Smågan", "Mångsbodarna", "Risberg", "Evertsberg", "Oxberg", "Hökbe…
$ time_of_day <time> 08:36:45, 09:12:26, 09:43:05, 10:24:08, 11:03:35, 11:31:09, 12:00:…
$ split_time  <time> 00:36:44, 01:12:25, 01:43:04, 02:24:07, 03:03:34, 03:31:08, 04:00:…
$ split_diff  <dbl> 2204, 2141, 1839, 2463, 2367, 1654, 1777, 1353, 116, 2218, 2114, 18…
$ min_km      <time> 03:21:00, 02:45:00, 02:48:00, 03:26:00, 02:38:00, 03:04:00, 02:58:…
$ km_h        <dbl> 17.96, 21.86, 21.53, 17.54, 22.81, 19.60, 20.26, 22.34, 18.64, 17.8…
$ split_place <chr> "28", "37", "31", "10", "7", "1", "2", "–", "1", "47", "19", "102",…
$ club        <chr> "–", "–", "–", "–", "–", "–", "–", "–", "–", "–", "–", "–", "–", "–…
$ group       <chr> "H35", "H35", "H35", "H35", "H35", "H35", "H35", "H35", "H35", "H21…
$ number      <dbl> 14, 14, 14, 14, 14, 14, 14, 14, 14, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3…
$ start_group <chr> "VL0", "VL0", "VL0", "VL0", "VL0", "VL0", "VL0", "VL0", "VL0", "VL0…
$ team        <chr> "Team Ragde Eiendom", "Team Ragde Eiendom", "Team Ragde Eiendom", "…
$ x1          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
$ x2          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
$ sex         <chr> "men", "men", "men", "men", "men", "men", "men", "men", "men", "men…
$ split1      <chr> "1. Start - Smågan", "2. Smågan - Mångsbodarna", "3. Mångsbodarna -…
> head(dat)
# A tibble: 6 x 25
  place name  nat      nr class v6    v7    time     diff                split time_of_day split_time split_diff min_km  km_h split_place club  group number
  <dbl> <chr> <chr> <dbl> <chr> <chr> <lgl> <time>   <dttm>              <chr> <time>      <time>          <dbl> <time> <dbl> <chr>       <chr> <chr>  <dbl>
1     1 Elia… NOR      14 H35   Club– NA    04:25:14 2020-04-17 21:00:00 Småg… 08:36:45    00:36:44         2204 03:21   18.0 28          –     H35       14
2     1 Elia… NOR      14 H35   Club– NA    04:25:14 2020-04-17 21:00:00 Mång… 09:12:26    01:12:25         2141 02:45   21.9 37          –     H35       14
3     1 Elia… NOR      14 H35   Club– NA    04:25:14 2020-04-17 21:00:00 Risb… 09:43:05    01:43:04         1839 02:48   21.5 31          –     H35       14
4     1 Elia… NOR      14 H35   Club– NA    04:25:14 2020-04-17 21:00:00 Ever… 10:24:08    02:24:07         2463 03:26   17.5 10          –     H35       14
5     1 Elia… NOR      14 H35   Club– NA    04:25:14 2020-04-17 21:00:00 Oxbe… 11:03:35    03:03:34         2367 02:38   22.8 7           –     H35       14
6     1 Elia… NOR      14 H35   Club– NA    04:25:14 2020-04-17 21:00:00 Hökb… 11:31:09    03:31:08         1654 03:04   19.6 1           –     H35       14
# … with 6 more variables: start_group <chr>, team <chr>, x1 <lgl>, x2 <lgl>, sex <chr>, split1 <chr>
```


## License

MIT-license

## devtools::session_info

```r
> devtools::session_info()
─ Session info ─────────────────────────────────────────────────────────────────────────
 setting  value                       
 version  R version 3.6.2 (2019-12-12)
 os       Ubuntu 18.04.3 LTS          
 system   x86_64, linux-gnu           
 ui       RStudio                     
 language en_US                       
 collate  en_US.UTF-8                 
 ctype    en_US.UTF-8                 
 tz       Europe/Helsinki             
 date     2020-04-18                  

─ Packages ─────────────────────────────────────────────────────────────────────────────
 package     * version date       lib source        
 assertthat    0.2.1   2019-03-21 [2] CRAN (R 3.5.3)
 backports     1.1.6   2020-04-05 [3] CRAN (R 3.6.2)
 broom         0.5.5   2020-02-29 [3] CRAN (R 3.6.2)
 callr         3.4.3   2020-03-28 [3] CRAN (R 3.6.2)
 cellranger    1.1.0   2016-07-27 [2] CRAN (R 3.5.2)
 cli           2.0.2   2020-02-28 [2] CRAN (R 3.6.2)
 colorspace    1.4-1   2019-03-18 [3] CRAN (R 3.5.3)
 crayon        1.3.4   2017-09-16 [2] CRAN (R 3.5.2)
 curl          4.3     2019-12-02 [2] CRAN (R 3.6.2)
 DBI           1.1.0   2019-12-15 [3] CRAN (R 3.6.2)
 dbplyr        1.4.2   2019-06-17 [3] CRAN (R 3.6.0)
 desc          1.2.0   2018-05-01 [2] CRAN (R 3.6.2)
 devtools      2.2.2   2020-02-17 [2] CRAN (R 3.6.2)
 digest        0.6.25  2020-02-23 [2] CRAN (R 3.6.2)
 dplyr       * 0.8.5   2020-03-07 [2] CRAN (R 3.6.2)
 ellipsis      0.3.0   2019-09-20 [3] CRAN (R 3.6.1)
 evaluate      0.14    2019-05-28 [2] CRAN (R 3.6.0)
 extrafont   * 0.17    2014-12-08 [2] CRAN (R 3.6.2)
 extrafontdb   1.0     2012-06-11 [2] CRAN (R 3.6.2)
 fansi         0.4.1   2020-01-08 [2] CRAN (R 3.6.2)
 forcats     * 0.5.0   2020-03-01 [3] CRAN (R 3.6.2)
 fs          * 1.4.1   2020-04-04 [3] CRAN (R 3.6.2)
 gdtools       0.2.2   2020-04-03 [3] CRAN (R 3.6.2)
 generics      0.0.2   2018-11-29 [3] CRAN (R 3.5.1)
 ggplot2     * 3.3.0   2020-03-05 [2] CRAN (R 3.6.2)
 ggrepel       0.8.2   2020-03-08 [2] CRAN (R 3.6.2)
 glue        * 1.4.0   2020-04-03 [2] CRAN (R 3.6.2)
 gridExtra     2.3     2017-09-09 [2] CRAN (R 3.6.2)
 gtable        0.3.0   2019-03-25 [3] CRAN (R 3.5.3)
 haven         2.2.0   2019-11-08 [3] CRAN (R 3.6.1)
 here          0.1     2017-05-28 [2] CRAN (R 3.6.2)
 hms           0.5.3   2020-01-08 [2] CRAN (R 3.6.2)
 hrbrthemes  * 0.8.0   2020-03-06 [2] CRAN (R 3.6.2)
 htmltools     0.4.0   2019-10-04 [2] CRAN (R 3.6.2)
 httr          1.4.1   2019-08-05 [2] CRAN (R 3.6.1)
 jsonlite      1.6.1   2020-02-02 [2] CRAN (R 3.6.2)
 knitr         1.28    2020-02-06 [2] CRAN (R 3.6.2)
 lattice       0.20-41 2020-04-02 [4] CRAN (R 3.6.2)
 lifecycle     0.2.0   2020-03-06 [2] CRAN (R 3.6.2)
 lubridate     1.7.8   2020-04-06 [3] CRAN (R 3.6.2)
 magrittr      1.5     2014-11-22 [2] CRAN (R 3.5.1)
 memoise       1.1.0   2017-04-21 [2] CRAN (R 3.6.2)
 modelr        0.1.6   2020-02-22 [3] CRAN (R 3.6.2)
 munsell       0.5.0   2018-06-12 [3] CRAN (R 3.5.0)
 nlme          3.1-145 2020-03-04 [4] CRAN (R 3.6.2)
 packrat       0.5.0   2018-11-14 [1] CRAN (R 3.6.2)
 pillar        1.4.3   2019-12-20 [2] CRAN (R 3.6.2)
 pkgbuild      1.0.6   2019-10-09 [2] CRAN (R 3.6.2)
 pkgconfig     2.0.3   2019-09-22 [2] CRAN (R 3.6.2)
 pkgload       1.0.2   2018-10-29 [2] CRAN (R 3.6.2)
 prettyunits   1.1.1   2020-01-24 [3] CRAN (R 3.6.2)
 processx      3.4.2   2020-02-09 [3] CRAN (R 3.6.2)
 ps            1.3.2   2020-02-13 [3] CRAN (R 3.6.2)
 purrr       * 0.3.3   2019-10-18 [2] CRAN (R 3.6.2)
 R6            2.4.1   2019-11-12 [2] CRAN (R 3.6.2)
 Rcpp          1.0.4   2020-03-17 [2] CRAN (R 3.6.2)
 readr       * 1.3.1   2018-12-21 [2] CRAN (R 3.5.2)
 readxl        1.3.1   2019-03-13 [3] CRAN (R 3.5.3)
 remotes       2.1.1   2020-02-15 [2] CRAN (R 3.6.2)
 reprex        0.3.0   2019-05-16 [3] CRAN (R 3.6.0)
 rlang         0.4.5   2020-03-01 [2] CRAN (R 3.6.2)
 rmarkdown     2.1     2020-01-20 [2] CRAN (R 3.6.2)
 rprojroot     1.3-2   2018-01-03 [2] CRAN (R 3.6.2)
 rstudioapi    0.11    2020-02-07 [3] CRAN (R 3.6.2)
 Rttf2pt1      1.3.8   2020-01-10 [2] CRAN (R 3.6.2)
 rvest       * 0.3.5   2019-11-08 [3] CRAN (R 3.6.1)
 scales        1.1.0   2019-11-18 [3] CRAN (R 3.6.1)
 selectr       0.4-2   2019-11-20 [3] CRAN (R 3.6.1)
 sessioninfo   1.1.1   2018-11-05 [2] CRAN (R 3.6.2)
 stringi       1.4.6   2020-02-17 [2] CRAN (R 3.6.2)
 stringr     * 1.4.0   2019-02-10 [2] CRAN (R 3.5.3)
 systemfonts   0.1.1   2019-07-01 [3] CRAN (R 3.6.1)
 testthat      2.3.2   2020-03-02 [2] CRAN (R 3.6.2)
 tibble      * 3.0.0   2020-03-30 [2] CRAN (R 3.6.2)
 tidyr       * 1.0.2   2020-01-24 [2] CRAN (R 3.6.2)
 tidyselect    1.0.0   2020-01-27 [2] CRAN (R 3.6.2)
 tidyverse   * 1.3.0   2019-11-21 [3] CRAN (R 3.6.1)
 usethis       1.5.1   2019-07-04 [2] CRAN (R 3.6.2)
 utf8          1.1.4   2018-05-24 [2] CRAN (R 3.5.2)
 vctrs         0.2.4   2020-03-10 [2] CRAN (R 3.6.2)
 viridis     * 0.5.1   2018-03-29 [2] CRAN (R 3.6.2)
 viridisLite * 0.3.0   2018-02-01 [3] CRAN (R 3.5.0)
 withr         2.1.2   2018-03-15 [3] CRAN (R 3.5.0)
 xfun          0.12    2020-01-13 [2] CRAN (R 3.6.2)
 xml2        * 1.3.0   2020-04-01 [2] CRAN (R 3.6.2)
```