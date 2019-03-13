#!/usr/bin/r
# This script scrapes the html results from http://results.vasaloppet.se/2018/

setwd('~/btsync/workspace/hiihto/vasaloppet18')

# Results for men and women have to be pulled separately
# Lets use the default settings and se we have 469 pages of 25 skiers
# with all together 11723 finishers.
# library(httr)
library(rvest)
library(dplyr)
library(stringr)
library(glue)
library(tidyr)
library(fs)
setwd("~/btsync/workspace/hiihto/vasaloppet18")

vuosi <- 2016

is.even <- function(x) x %% 2 == 0


tibble(
  vuosi = c(2016:2019),
  event_id = c("VL_9999991678885A000000048A",
               "VL_9999991678885A0000000551",
               "VL_9999991678885B00000006B0",
               "VL_9999991678885C0000000700"),
  result_pages = c(477,469,470,431)
) -> event_id_df


event_id <- event_id_df[event_id_df$vuosi == vuosi,]$event_id
max_result_pages <- event_id_df[event_id_df$vuosi == vuosi,]$result_pages

dir_create(glue("./tempdata/men/{vuosi}/"))

# check which pages have already been scraped
pages_processed <- fs::dir_info(path = glue("./tempdata/men/{vuosi}/"), type = "file", glob = "*.csv") %>% 
  select(path) %>% 
  mutate(path = as.integer(sub("\\.csv", "", sub(glue("\\./tempdata/men/{vuosi}/file"), "", path)))) %>% 
  pull(path)

if (length(pages_processed) == 0) pages_processed <- 0


# dat <- list()
for (page in max(pages_processed)+1:max_result_pages){
# for (page in 1:3){
url <- glue("https://results.vasaloppet.se/{vuosi}/index.php?page={page}&event={event_id}&pid=list&ranking=time_finish_brutto&search%5Bsex%5D=M&search%5Bage_class%5D=%25&search%5Bnation%5D=%25")

tryCatch({
    read_html(url) %>% 
      html_nodes(css = '.list-field-wrap') %>%
      html_text() %>%
      .[-1:-2] %>% 
      gsub("\\n", "", .) %>% 
      str_trim(., side = "both") -> res
  }, error=function(e) e
)

if (!exists("res")) next()

page_res <- vector()
for (i in 1:length(res)){
  if (!is.even(i)){
    next()
  } else {
    tmp_str <- paste(res[i-1],res[i])
  }
  page_res <- c(page_res,tmp_str)
}

# if nationality is missing then impute a (NA)
for (nr in 1:length(page_res)){
  if (!grepl("\\(",page_res[nr])) {
    page_res[nr] <- sub("Number", "\\(NA\\) Number", page_res[nr])
    page_res[nr] <- sub("Nat–", "Nat", page_res[nr])
  }
}

restbl <- page_res %>% 
  gsub("Number|Nat|NatGRL|ACH|GGY|Finish|Diff| \\(William Ernest\\)|WLS|'","", .) %>% 
  gsub("  |\\)|\\(", ";", .) %>%
  gsub("([a-z]);([A-Z])", "\\1 \\2", .) %>% 
  gsub("  |\\)|\\(", ";", .) %>%
  gsub(" ;|; |;;", ";", .) %>% 
  # .[-1] %>% 
  read.table(text = ., sep = ";")

# spitls
pg <- read_html(url)
html_attr(html_nodes(pg, "a"), "href") %>% 
  .[grepl("^\\?content=", .)] %>% 
  sub("^.+idp\\=", "", .) %>% 
  sub("\\&lang.+$", "", .) -> idps 

splitdat <- tibble()
startgroupdat_list <- list()
for (id in 1:length(idps)){
  
  tryCatch({
    read_html(glue("https://results.vasaloppet.se/{vuosi}/?content=detail&fpid=search&pid=search&idp={idps[id]}&search_event={event_id}")) %>% 
      html_table() -> htmltbls
  }, error=function(e) e
  )
  if (!exists("htmltbls")) next()

  htmltbls[[length(htmltbls)]] -> splittmp
  splittmp$V4 <- restbl$V4[id]
  splittmp <- mutate_all(splittmp, as.character)
  splitdat <- bind_rows(splitdat,splittmp)
  htmltbls[[2]] -> startgroup
  startgroup <- spread(startgroup, X1, X2)
  startgroup$V4 <- restbl$V4[id]
  startgroup <- mutate_all(startgroup, as.character)
  startgroupdat_list[[id]] <- startgroup
  rm(htmltbls)
}
startgroupdat <- do.call(bind_rows, startgroupdat_list)
  
restbl <- mutate_all(restbl, as.character)

restbl1 <- left_join(restbl,splitdat)
restbl2 <- left_join(restbl1,startgroupdat)

# dat[[page]] <- restbl2

readr::write_csv(restbl2, glue("./tempdata/men/{vuosi}/file{stringr::str_pad(page, 3, pad = '0')}.csv"))
rm(res)
}


# read csv's into a single data frame
flies <- fs::dir_info(path = glue("./tempdata/men/{vuosi}/"), type = "file", glob = "*.csv") %>% 
  select(path) %>% pull() %>% sort()
dat <- list()
for (fly in 1:length(flies)){
  if (vuosi == 2016){
    tmp <- readr::read_csv(flies[fly]) %>% 
      mutate(V5 = as.integer(V5))
             # `Time Of Day` = hms::as.hms(`Time Of Day`),
             # Time = hms::as.hms(Time),
             # Diff = hms::as.hms(Diff),
             # `min/ km` = hms::as.hms(`min/ km`),
             # `km/h` = as.numeric(`km/h`)
      # )
  } else if (vuosi == 2017){
    tmp <- readr::read_csv(flies[fly]) %>% 
      mutate(V5 = as.integer(V5),
             V4 = as.integer(V4)
             # `Time Of Day` = hms::as.hms(`Time Of Day`),
             # Time = hms::as.hms(Time),
             # Diff = hms::as.hms(Diff),
             # `min/ km` = hms::as.hms(`min/ km`),
             # `km/h` = as.numeric(`km/h`)
      )
  } else if (vuosi == 2018){
    tmp <- readr::read_csv(flies[fly]) %>% 
      mutate(V5 = as.integer(V5),
             V4 = as.integer(V4)#,
             # `Time Of Day` = hms::as.hms(`Time Of Day`),
             # Time = hms::as.hms(Time),
             # Diff = hms::as.hms(Diff),
             # `min/ km` = hms::as.hms(`min/ km`),
             # `km/h` = as.numeric(`km/h`)
      )
  } else if (vuosi == 2019){
    tmp <- readr::read_csv(flies[fly]) %>% 
      mutate(V5 = as.integer(V5),
             `Time Of Day` = hms::as.hms(`Time Of Day`),
             Time = hms::as.hms(Time),
             Diff = hms::as.hms(Diff),
             `min/ km` = hms::as.hms(`min/ km`),
             `km/h` = as.numeric(`km/h`)
      )
  }
dat[[fly]] <- tmp
}

df <- do.call(bind_rows, dat)

saveRDS(df, glue("./data/resultat_med_splits_raw_men_{vuosi}.RDS"))
