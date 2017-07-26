library(tidyverse)
library(rvest)
library(stringr)

colleges <- read_html("https://en.wikipedia.org/wiki/List_of_colleges_in_Ontario")

colleges %>%
  html_nodes("table.wikitable") %>%
  html_table(header=TRUE) %>%
  bind_rows() -> college_list

