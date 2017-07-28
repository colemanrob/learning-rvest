easy web scrape
================

learning rvest
--------------

This script scrapes [feats.findhelp.ca](http://feats.findhelp.ca/eng/search.html) for Employment Service locations. My strategy was:

-   write a function that grabs each data element, and parses the html
-   write a function that iterates through the pages and applies all the grabbing functions
-   iteratively add the scrapped data as a new row in a dataframe

### Problems

The html is not the best. The table containing the data is malformed. The next page selector doesn't have it's own css class or id. This script will focus on what does work and you can check **here** for how i solved the other issues.

Libraries
---------

``` r
library(tidyverse) #dplyr for pipes and purr to map the data onto a dataframe
library(rvest) # get and parse the html
library(stringr) # work with strings
library(knitr) # make a pretty table
```

Create functions to scrape elements
-----------------------------------

Write a function that grabs each element we want to scrape. I used the [Selector Gadget](http://selectorgadget.com/) to find the css element.

``` r
# grab the SP name box
get_name_box <- function(url) {
  read_html(url) %>%
    html_nodes(".namewidth") %>%
    html_text()
}

# grab the SP city
get_city_box <- function(url) {
  read_html(url) %>%
    html_nodes(".locwidth") %>%
    html_text()
}

# the node is tricky here because the html is so malformed
# nth-child(11) works for page 1, then (12) works from pages 2-31
get_next_url <- function(url) {
  read_html(url) %>%
    html_node("a:nth-child(12)") %>%
    html_attr("href") %>%
    paste("http://services.findhelp.ca", ., sep = "")
}

# grab the SP url
get_sp_website <- function(url) {
  read_html(url) %>%
    html_nodes(".namewidth a") %>%
    html_attr("href") %>%
    str_subset("http")
}
```

Function to iterate
-------------------

This applies the grabbing functions iteratively, and adds the scrapped data as a row onto a new dataframe using [purrr](https://github.com/tidyverse/purrr).

``` r
# user supplies n, the number of pages to scrape (10 results per page)
scrape <- function(url, n) {
  Sys.sleep(1) # add some time so we don't look like a webcrawler
  if(!is.na(url)){
  map_df(1:n, ~{ #add results to dataframe
    oUrl <- url
    name <- get_name_box(url)
    city <- get_city_box(url)
    site <- get_sp_website(url)
    url <<- get_next_url(url)
    data.frame(site_name = name,
               site_city = city,
               site_web = site)
  })
}}
```

scape the data
--------------

Now declare the url and scrape away:

``` r
url <- "http://services.findhelp.ca/eo/en/multi?print=false&servingRegion=false&showMap=true&client=&orderBy=ORGANIZATION&location=&program=PR034&pageNum=2&includeEnglish=true"

site_data <- scrape(url, 2) # lets just grab 2 pages of data - **max is 31 here**
```

See results

``` r
site_data %>% 
  separate(site_name, into = c("Name", "Address"), sep = "Ontario Employment Services ") -> cleaner

cleaner %>% 
  separate(Address, into = c("Addresses", "rest"), sep = ", ON") %>% 
  select(-rest) %>% 
  head() %>% 
  kable()
```

| Name                  | Addresses                                                | site\_city   | site\_web                        |
|:----------------------|:---------------------------------------------------------|:-------------|:---------------------------------|
| Agilec. Fergus.       | 370 St Andrew St West Unit 2, Fergus                     | Fergus       | <http://www.agilec.ca/fergus>    |
| Agilec. Innisfil.     | 1070 Innisfil Beach Rd Unit 1, Innisfil                  | Innisfil     | <http://agilec.ca/innisfil>      |
| Agilec. Mount Forest. | 392 Main St North Unit 7, Mount Forest                   | Mount Forest | <http://www.agilec.ca/mtforest>  |
| Agilec.               | 385 Fairway Rd South Unit 205, Kitchener                 | Waterloo     | <http://www.agilec.ca/kitchener> |
| Agilec. Orillia.      | Orillia City Centre, 50 Andrew St South Ste 102, Orillia | Orillia      | <http://www.agilec.ca/orillia>   |
| Agilec. Ottawa.       | 1900 City Park Dr Ste 100, Ottawa                        | Ottawa       | <http://www.agilec.ca/ottawa>    |
