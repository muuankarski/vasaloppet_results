library(tidyverse)
library(hrbrthemes)
library(extrafont)
loadfonts()
library(viridis)

d <- readRDS("./data/resultat_med_splits_tidy.RDS") %>% as_tibble()

split_data <- data_frame(
  split = c('Start', 'Smågan','Mångsbodarna','Risberg','Evertsberg','Oxberg','Hökberg','Eldris','Mora Förvarning','Finish'),
  stage_name = c(NA,'1. Start - Smågan','2. Smågan - Mångsbodarna','3. Mångsbodarna - Risberg','4. Risberg - Evertsberg','5. Evertsberg - Oxberg','6. Oxberg - Hökberg','7. Hökberg - Eldris','8. Eldris - Mora Förvarning','9. Mora Förvarning - Finish'),
  distance = c(0, 11,13,11,13,14,9,10,8,1),
  distance_cum = cumsum(distance)
)

d$split_place <- as.integer(d$split_place)

# lisätään kaikille lähtöpaikalle aika 0
d_lahto <- d %>% filter(split == "Finish") %>% 
  mutate(split_time = as.POSIXct(x = "2018-03-07 00:00:00 EET"),
         split = "Start")

d <- bind_rows(d,d_lahto)

d %>% left_join(., split_data) -> dd #%>%  filter(grepl("FIN", nat), sex == "men") -> dd

dd$mitali <- ifelse(dd$time < as.POSIXct(x = "2018-03-07 06:36:00 EET"), "mitali", "ei mitalia")

dd_pos <- dd %>% filter(split %in% c("Smågan","Finish")) %>% mutate(net_position = lag(split_place) - split_place) %>% filter(!is.na(net_position)) %>% arrange(net_position)

dd_pos <- dd %>% 
            filter(split %in% c("Smågan","Finish")) %>% 
            group_by(nr) %>% 
            arrange(nr,split) %>% 
            mutate(net_position = lead(split_place) - split_place) %>% 
            ungroup() %>% 
            arrange(net_position) %>% 
  filter(!is.na(nr))

tops <- dd_pos %>% slice(1:3) %>% pull(nr)
bottoms <-  dd_pos %>% arrange(desc(net_position)) %>% slice(1:3) %>% pull(nr)

dd <- left_join(dd, dd_pos %>% filter(!is.na(net_position)) %>% select(nr,net_position))
# dd <- sample_n(dd, size = 5000)

dd_kainu <- dd %>% filter(nr %in% c(tops,bottoms,2))

p <- ggplot(data = dd, aes(x = distance_cum, y = split_time, group = nr, color = mitali)) + 
  geom_line(alpha = .01, show.legend = FALSE) + 
  # geom_point(alpha = .01) +
  geom_line(data = dd_kainu %>% filter(nr %in% c(tops,2)),  show.legend = FALSE, color = "white", alpha = .8) +
  geom_line(data = dd_kainu %>% filter(nr %in% bottoms),  show.legend = FALSE, color = "dim grey") +
  geom_point(data = dd_kainu, show.legend = FALSE, color = "white", fill = "dim grey", shape = 21, alpha = .6) +
  ggrepel::geom_text_repel(data = dd_kainu %>% filter(split %in% c("Finish")), 
                           aes(label = paste0(name,"\n",net_position)), 
                           nudge_x = 5, size = 3, family = "Roboto Condensed", show.legend = FALSE, color = "dim grey", lineheight = .8) +
  scale_x_continuous(breaks = split_data$distance_cum, labels = paste0(split_data$split," ",split_data$distance_cum,"km"), limits = c(0,100)) +
  theme_ipsum_rc(base_size = 12, plot_title_size = 15, subtitle_size = 12) + 
  # scale_color_ipsum() +
  scale_color_manual(values = c("#4DBBD5B2","#FFD700")) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Overtakes in Vasaloppet 2018: Top and bottom 3 skiers",
       subtitle = 
"Each line represent an individual skier, gold with medal, blue without
Dark color marks the overtakers, white line marks who got overtaken
Number shows the net difference in positions between Smågan and Finish",
       y= "Race time (hours)", 
       x = NULL,
       caption = paste0(
"Data: results.vasaloppet.se/2018\n",
Sys.time(),
"\nmarkuskainu.fi"))

ggsave(filename = "top_bottom3_overtakers.png", plot = p, device = "png", width = 12, height = 8, dpi = 90)

# karskitools::sposti(to = "mikko.kainu@gmail.com", subject = "Ohitukset", liite = "top_bottom3_overtakers.png", body = "kuva!")
# karskitools::sposti(to = "markus.kainu@kela.fi", subject = "Ohitukset", liite = "top_bottom3_overtakers.png", body = "kuva!")


# start_group


dd %>% 
  filter(!split %in% "Start") %>% 
  filter(split_place == 1) %>% 
  select(name,nr,split,split_time,sex, distance_cum) %>% 
  mutate(name = ifelse(sex == "men", "medal, men", "medal, women"),
         nr = 0,
         split_time1 = split_time) -> medal

medal$start_time <- as.POSIXct(x = "2018-03-07 00:00:00 EET")
medal$timediff <- (medal$split_time - medal$start_time) * 1.5
medal$split_time <- medal$start_time + medal$timediff


dd %>% 
  filter(split == "Finish") %>% 
  group_by(start_group) %>% 
  arrange(time) %>% 
  slice(1) %>% 
  ungroup() %>% 
  pull(nr) -> group_winners_nr

group_winners <- dd %>% filter(nr %in% group_winners_nr)

p <- ggplot(data = dd, aes(x = distance_cum, y = split_time, group = nr, color = start_group)) + 
  geom_line(alpha = .01) + 
  geom_line(data = group_winners,  show.legend = FALSE, color = "black", alpha = .6) +
  geom_line(data = medal, aes(group = sex),  show.legend = FALSE, color = "white", alpha = .8) +
  geom_point(data = medal, show.legend = FALSE, color = "white", fill = "dim grey", shape = 21, alpha = .6) +
  ggrepel::geom_text_repel(data = medal %>% filter(split %in% c("Finish")),
                           aes(label = name),
                           nudge_x = -5, size = 3, family = "Roboto Condensed", show.legend = FALSE, color = "white", lineheight = .8) +
  ggrepel::geom_text_repel(data = group_winners %>% filter(split %in% c("Finish")),
                           aes(label = paste(name, start_group, "\n", format(time, "%H:%M:%S"))),
                           nudge_x = 6, size = 2.5, family = "Roboto Condensed", show.legend = FALSE, color = "dim grey", lineheight = .8) +
  scale_x_continuous(breaks = split_data$distance_cum, labels = paste0(split_data$split," ",split_data$distance_cum,"km"), limits = c(0,100)) +
  theme_ipsum_rc(base_size = 12, plot_title_size = 15, subtitle_size = 12) + 
  # scale_color_viridis(discrete = TRUE, option = "plasma") +
  scale_fill_manual(values = c(
    pal_startrek(palette = "uniform", alpha = 1)(7),
    pal_uchicago(palette = "dark", alpha = 1)(7)
  )) + 
  theme(legend.position = "left") +
  # scale_color_manual(values = c("#4DBBD5B2","#FFD700")) +
  theme(axis.text.x = element_text(angle = 45)) +
  guides(colour = guide_legend(override.aes = list(alpha=1))) +
  labs(title = "Start group winners in Vasaloppet 2018",
       subtitle = 
         "Each line represent an individual skier, different start groups have different colors
Number shows the net difference in positions between Smågan and Finish",
       y= "Race time (hours)", 
       x = NULL,
       caption = paste0(
         "Data: results.vasaloppet.se/2018\n",
         Sys.time(),
         "\nmarkuskainu.fi"))

ggsave(filename = "startgroups_winners.png", plot = p, device = "png", width = 12, height = 12, dpi = 90)

karskitools::sposti(to = "mikko.kainu@gmail.com", subject = "Starttiryhmät ja mitalirajat", liite = "startgroups_medallimits.png", body = "terveiset muskarista")
