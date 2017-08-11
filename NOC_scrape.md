NOC Scrape
================

Scraping NOCs
-------------

Seems I can never find a list of NOCs when I need it. This script scrapes the NOCs from the [NOCs site](http://noc.esdc.gc.ca/English/NOC/Matrix.aspx) and turns it into a list.

Libraries
---------

``` r
library(tidyverse) # make tidy
library(rvest) # scrape data
library(knitr) # make a table
```

Scraper
-------

Read in the appropriate list of NOCs

``` r
nocs <- read_html("http://noc.esdc.gc.ca/English/NOC/QuickSearch.aspx?ver=16&val65=*")
```

Parse the HTML into a list then a file

``` r
nocs %>%
  html_nodes(".NoBulletWithLessPadding a") %>%
  html_text() %>% 
  tibble() %>% # turn it into a dataframe object
  separate(".", into=c("code", "desc"), sep=4) %>% #seperate the code from the description
  top_n(15) %>% # show only first 15
  kable() # make a nice table
```

| code | desc                                                  |
|:-----|:------------------------------------------------------|
| 0912 | Utilities managers                                    |
| 2153 | Urban and land use planners                           |
| 2175 | Web designers and developers                          |
| 2282 | User support technicians                              |
| 3114 | Veterinarians                                         |
| 4011 | University professors and lecturers                   |
| 6345 | Upholsterers                                          |
| 7237 | Welders and related machine operators                 |
| 7373 | Water well drillers                                   |
| 7442 | Waterworks and gas maintenance workers                |
| 7532 | Water transport deck and engine room crew             |
| 8231 | Underground production and development miners         |
| 9243 | Water and waste treatment plant operators             |
| 9437 | Woodworking machine operators                         |
| 9442 | Weavers, knitters and other fabric making occupations |

**Voila!** use `write_csv` to export to a file
