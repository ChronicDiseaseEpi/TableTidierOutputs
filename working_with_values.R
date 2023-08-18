library(tidyverse)
library(janitor)
mydata <- read_json("PMC7442954_1_124_all_data.json",
                    simplifyVector = TRUE)

## Convert values according to the type
mydf <- mydata$tableResults %>% 
  clean_names() %>% 
  as_tibble() 

# Numerator and percentage
np <- mydf %>% 
  filter(str_detect(characteristics_1, fixed("No. (%)"))) %>% 
  separate(value, into = c("x", "p"), sep = "\\(", remove = FALSE, fill = "right") %>% 
  mutate(p = str_sub(p, 1, -2),
         across(c(x, p), as.double))  %>% 
  mutate(n = x/(p/100))

# Numerator, denominator and percentage
xnp <-  mydf %>% 
  filter(str_detect(characteristics_1, fixed("No./total (%)"))) %>% 
  separate(value, into = c("x","n", "p"), sep = "/|\\(", remove = FALSE, fill = "right") %>% 
  mutate(p = str_sub(p, 1, -2),
         across(c(x, n, p), as.double))

## Join numerator, denominator and percentage together
xnp <- bind_rows(xnp, np)
rm(np)

# Median and interquartile range
iqr <- mydf %>% 
  filter(!str_detect(characteristics_1, "%")) %>% 
  separate(value, into = c("m","l", "u"), sep = "\\-|\\(", remove = FALSE, fill = "right") %>% 
  mutate(u = str_sub(u, 1, -2),
         across(c(m, l, u), as.double))
rm(mydf)

## plot median and Interquartile range data
iqrplot <- ggplot(iqr, aes(x = arms_1, y = m, ymin = l, ymax = u, colour = arms_1)) +
  geom_point() +
  geom_linerange() +
  facet_wrap(~ characteristics_2, scales = "free" ) +
  coord_flip()
iqrplot

npplot <- ggplot(xnp, aes(x = interaction(characteristics_2), y = p, fill = arms_1)) +
  geom_col(position = position_dodge()) +
  facet_wrap(~ characteristics_1, scales = "free" ) +
  coord_flip()
npplot
