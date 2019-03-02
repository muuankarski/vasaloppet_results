# This script scrapes the html results from http://results.vasaloppet.se/2018/
# Results for men and women have to be pulled separately
# Lets use the default settings and se we have 469 pages of 25 skiers
# with all together 11723 finishers.
# library(httr)
library(rvest)
library(dplyr)
library(stringr)

is.even <- function(x) x %% 2 == 0

dat <- data_frame()
for (page in 1:469){
# for (page in 1:3){
url <- paste0("http://results.vasaloppet.se/2018/index.php?page=",page,"&event=VL_9999991678885B00000006B0&pid=list&ranking=time_finish_brutto&search%5Bsex%5D=M&search%5Bage_class%5D=%25&search%5Bnation%5D=%25")

read_html(url) %>% 
  html_nodes(css = '.list-field-wrap') %>%
  html_text() %>%
  .[-1:-2] %>% 
  gsub("\\n", "", .) %>% 
  str_trim(., side = "both") -> res

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
  if (!grepl("\\(",page_res[nr])) page_res[nr] <- sub("Number", "\\(NA\\) Number", page_res[nr])
}


restbl <- page_res %>% 
  gsub("Number|Nat|ACH|Finish|Diff","", .) %>% 
  gsub("  |\\)|\\(", ";", .) %>%
  gsub("([a-z]);([A-Z])", "\\1 \\2", .) %>% 
  gsub("  |\\)|\\(", ";", .) %>%
  gsub(" ;|; |;;", ";", .) %>% 
  read.table(text = ., sep = ";")

# spitls
pg <- read_html(url)
html_attr(html_nodes(pg, "a"), "href") %>% 
  .[grepl("^\\?content=", .)] %>% 
  sub("^.+idp\\=", "", .) %>% 
  sub("\\&lang.+$", "", .) -> idps 

splitdat <- data_frame()
startgroupdat <- data_frame()
for (id in 1:length(idps)){
  read_html(paste0("http://results.vasaloppet.se/2018/?content=detail&fpid=search&pid=search&idp=",idps[id],"&search_event=VL_9999991678885B00000006B0")) %>% 
    html_table() -> htmltbls 
  htmltbls[[length(htmltbls)]] -> splittmp
  splittmp$V4 <- restbl$V4[id]
  splittmp <- mutate_all(splittmp, as.character)
  splitdat <- bind_rows(splitdat,splittmp)
  htmltbls[[2]] -> startgroup
  startgroup <- spread(startgroup, X1, X2)
  startgroup$V4 <- restbl$V4[id]
  startgroup <- mutate_all(startgroup, as.character)
  startgroupdat <- bind_rows(startgroupdat,startgroup)
}

restbl <- mutate_all(restbl, as.character)

restbl1 <- left_join(restbl,splitdat)
restbl2 <- left_join(restbl1,startgroupdat)

dat <- bind_rows(dat,restbl2)
}
saveRDS(dat, "./data/resultat_med_splits_raw_men.RDS")

# Women

dat <- data_frame()
for (page in 1:80){
  url <- paste0("http://results.vasaloppet.se/2018/index.php?page=",page,"&event=VL_9999991678885B00000006B0&pid=list&ranking=time_finish_brutto&search%5Bsex%5D=W&search%5Bage_class%5D=%25&search%5Bnation%5D=%25")
  
  read_html(url) %>% 
    html_nodes(css = '.list-field-wrap') %>%
    html_text() %>%
    .[-1:-2] %>% 
    gsub("\\n", "", .) %>% 
    str_trim(., side = "both") -> res
  
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
    if (!grepl("\\(",page_res[nr])) page_res[nr] <- sub("Number", "\\(NA\\) Number", page_res[nr])
  }
  
  
  restbl <- page_res %>% 
    gsub("Number|Nat|ACH|Finish|Diff","", .) %>% 
    gsub("  |\\)|\\(", ";", .) %>%
    gsub("([a-z]);([A-Z])", "\\1 \\2", .) %>% 
    gsub("  |\\)|\\(", ";", .) %>%
    gsub(" ;|; |;;", ";", .) %>% 
    read.table(text = ., sep = ";")
  
  # spitls
  pg <- read_html(url)
  html_attr(html_nodes(pg, "a"), "href") %>% 
    .[grepl("^\\?content=", .)] %>% 
    sub("^.+idp\\=", "", .) %>% 
    sub("\\&lang.+$", "", .) -> idps 
  
  splitdat <- data_frame()
  for (id in 1:length(idps)){
    read_html(paste0("http://results.vasaloppet.se/2018/?content=detail&fpid=search&pid=search&idp=",idps[id],"&search_event=VL_9999991678885B00000006B0")) %>% 
      html_table() -> htmltbls 
    htmltbls[[length(htmltbls)]] -> splittmp
    splittmp$V4 <- restbl$V4[id]
    splittmp <- mutate_all(splittmp, as.character)
    splitdat <- bind_rows(splitdat,splittmp)
    htmltbls[[2]] -> startgroup
    startgroup <- spread(startgroup, X1, X2)
    startgroup$V4 <- restbl$V4[id]
    startgroup <- mutate_all(startgroup, as.character)
    startgroupdat <- bind_rows(startgroupdat,startgroup)
  }
  
  restbl <- mutate_all(restbl, as.character)
  
  restbl1 <- left_join(restbl,splitdat)
  restbl2 <- left_join(restbl1,startgroupdat)
  
  
  dat <- bind_rows(dat,restbl2)
}
saveRDS(dat, "./data/resultat_med_splits_raw_women.RDS")

# ************************************************************************************
#
# Process data

dat <-  bind_rows(
  readRDS("./data/resultat_med_splits_raw_men.RDS") %>% mutate(sex = "men"),
  readRDS("./data/resultat_med_splits_raw_women.RDS")  %>% mutate(sex = "women")
) %>% 
  mutate(
    V5 = ifelse(sex == "men", paste0("H",V5), sub("ACD", "D", V5))
  ) %>% select(-Name)

# clean names
names(dat) <- names(dat) %>% 
  tolower(.) %>% 
  gsub(" |/","_", .) %>% 
  gsub("__", "_", .)

dat <- dat %>% 
  rename(split_diff = diff,
         split_time = time,
         split_place = place,
         place = v1,
         name = v2,
         nat = v3,
         nr = v4,
         class = v5,
         time = v6,
         diff = v7)
# variable types
## 
dat$place <- as.integer(dat$place)
dat$nr <- as.integer(dat$nr)
dat$time <- as.POSIXct(dat$time, format="%H:%M:%S")

dat$diff <- as.POSIXct(sub("\\+","0:", dat$diff), format="%H:%M:%S")

## splits
dat$split <- sub(" \\*", "", dat$split)
dat$split <- factor(dat$split, levels = c('Smågan','Mångsbodarna','Risberg','Evertsberg','Oxberg','Hökberg','Eldris','Mora Förvarning','Finish'))

## startgroup
dat$start_group <- factor(dat$start_group, levels = c('VL0','VL1','VL2','VL3','VL4','VL5','VL6','VL7','VL8','VL9','VL10'))

dat$split1[dat$split == "Smågan"] <- "1. Start - Smågan"
dat$split1[dat$split == "Mångsbodarna"] <- "2. Smågan - Mångsbodarna"
dat$split1[dat$split == "Risberg"] <- "3. Mångsbodarna - Risberg"
dat$split1[dat$split == "Evertsberg"] <- "4. Risberg - Evertsberg"
dat$split1[dat$split == "Oxberg"] <- "5. Evertsberg - Oxberg"
dat$split1[dat$split == "Hökberg"] <- "6. Oxberg - Hökberg"
dat$split1[dat$split == "Eldris"] <- "7. Hökberg - Eldris"
dat$split1[dat$split == "Mora Förvarning"] <- "8. Eldris - Mora Förvarning"
dat$split1[dat$split == "Finish"] <- "9. Mora Förvarning - Finish"
dat$split1 <- factor(dat$split1)

dat$split_time <- as.POSIXct(dat$split_time, format="%H:%M:%S")
dat$time_of_day <- as.POSIXct(dat$time_of_day, format="%H:%M:%S")

dat %>% 
  # manual corrections
  mutate(split_diff = ifelse(nr %in% c(10943,8354,12994) & split == "Finish", NA, split_diff),
         # Manipulate splits differences
         split_diff = paste0("00:",split_diff),
         split_diff = sub("00:0", "0", split_diff),
         split_diff = ifelse(split == "Finish", paste0("00:",split_diff),split_diff),
         split_diff_h = sub(":.+$", "", split_diff),
         split_diff_m = sub("^.+?:|?:.+$", "", split_diff),
         split_diff_m = sub(":.+$", "", split_diff_m),
         split_diff_s = sub("^.+:", "", split_diff)) %>%
  # Split diffs 
  mutate(split_diff_h = as.integer(split_diff_h) * 3600,
         split_diff_m = as.integer(split_diff_m) * 60,
         split_diff_s = as.integer(split_diff_s),
         split_diff_sum = split_diff_h + split_diff_m +split_diff_s) %>% 
  # Split diff
  group_by(split) %>% 
  arrange(split_diff_sum) %>% 
  mutate(
    split_diff_time = as.POSIXct(split_diff, format="%H:%M:%S"),
    split_difference = split_diff_time - split_diff_time[1],
    split_difference = format(.POSIXct(split_difference), "%M:%S")
    ) %>% 
  ungroup() %>% 
  # split rank
  group_by(split) %>% 
  arrange(split_diff_sum) %>% 
  mutate(rank = 1:n()) %>% 
  ungroup() -> ddd
    
saveRDS(ddd, "./data/resultat_med_splits_tidy.RDS")
