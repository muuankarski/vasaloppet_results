# This script scrapes the html results from http://results.vasaloppet.se/2018/
# Results for men and women have to be pulled separately
# Lets use the default settings and se we have 469 pages of 25 skiers
# with all together 11723 finishers.
# library(httr)
library(rvest)
library(dplyr)
library(stringr)
library(glue)
library(tidyr)
setwd("~/btsync/workspace/hiihto/vasaloppet18")

# ************************************************************************************
#
# Process data

dat <-  bind_rows(
  readRDS("./data/resultat_med_splits_raw_men.RDS") %>% 
    mutate(sex = "men"),
  readRDS("./data/resultat_med_splits_raw_women.RDS")  %>% mutate(sex = "women")
  ) %>% 
  mutate(
    V5 = ifelse(sex == "men", paste0("H",V5), paste0("D",V5))
  ) %>% select(-Name) %>% 
  arrange(sex,V1,`Time Of Day`)

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
         time = v8,
         diff = v9)
# variable types

# dat$time <- as.POSIXct(dat$time, format="%H:%M:%S")
# dat$split_time <- as.POSIXct(dat$split_time, format="%H:%M:%S")
# dat$time_of_day <- as.POSIXct(dat$time_of_day, format="%H:%M:%S")
# 
# dat$time <- as.POSIXct(sub("1970-01-01", "2019-03-03", dat$time))
# dat$time_of_day <- as.POSIXct(sub("1970-01-01", "2019-03-03", dat$time_of_day))
# dat$split_time <- as.POSIXct(sub("1970-01-01", "2019-03-03", dat$split_time))

dat$place <- as.integer(dat$place)
dat$nr <- as.integer(dat$nr)

dat$diff <- sub("\\+","00:", dat$diff)
dat$diff <- ifelse(nchar(dat$diff) > 8, sub("^00:", "", dat$diff), dat$diff)
dat$diff <- as.POSIXct(dat$diff, format="%H:%M:%S")

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

# split diffs dit not come out nicely from data
dat <- dat %>% 
  group_by(nr) %>% 
  mutate(split_diff = split_time - lag(split_time)) %>% 
  ungroup()

dat$split_diff <- ifelse(dat$split == "Smågan", dat$split_time, dat$split_diff)



# dat %>% 
  # manual corrections
  # mutate(
    # split_diff = ifelse(nr %in% c(10943,8354,12994) & split == "Finish", NA, split_diff),
         # Manipulate splits differences
  #        split_diff = paste0("00:",split_diff),
  #        split_diff = sub("00:0", "0", split_diff),
  #        split_diff = ifelse(split == "Finish", paste0("00:",split_diff),split_diff),
  #        split_diff_h = sub(":.+$", "", split_diff),
  #        split_diff_m = sub("^.+?:|?:.+$", "", split_diff),
  #        split_diff_m = sub(":.+$", "", split_diff_m),
  #        split_diff_s = sub("^.+:", "", split_diff)) %>%
  # # Split diffs 
  # mutate(split_diff_h = as.integer(split_diff_h) * 3600,
  #        split_diff_m = as.integer(split_diff_m) * 60,
  #        split_diff_s = as.integer(split_diff_s),
  #        split_diff_sum = split_diff_h + split_diff_m +split_diff_s) %>% 
  # # Split diff
  # group_by(split) %>% 
  # arrange(split_diff_sum) %>% 
  # mutate(
  #   split_diff_time = as.POSIXct(split_diff, format="%H:%M:%S"),
  #   split_difference = split_diff_time - split_diff_time[1],
  #   split_difference = format(.POSIXct(split_difference), "%M:%S")
  #   ) %>% 
  # ungroup() %>% 
  # split rank
  # group_by(split) %>% 
  # # outoja splittejä
  # mutate(split_diff = ifelse(split != "Finish" & split_diff < 1000, NA, split_diff)) %>% 
  # arrange(split_diff) %>% 
  # mutate(rank = 1:n()) %>% 
  # ungroup() %>% 
  # arrange(sex,place,split) -> ddd


    
saveRDS(dat, "./data/resultat_med_splits_tidy_2019.RDS")
