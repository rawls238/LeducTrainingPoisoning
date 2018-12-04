library(tidyverse)
library(xtable)

dir <- "/Users/guyaridor/Desktop/deep_learning_project/analysis/"
dat <- read.csv(paste(dir, "results.csv", sep=""))
dat <- filter(dat, player != "deepstack")
dat$result <- as.numeric(dat$result)

players <- unique(dat$player)
for (player in players) {
  filtered_dat <- filter(dat, player == UQ(player))
  q <- ggplot(filtered_dat, aes(x=result, color=type)) + geom_density() + 
    ggtitle(paste(player, "Distribution of Results")) + xlab("Chips Won")
  print(q)
}


player_frame <- as.data.frame(matrix(nrow=0, ncol=3))
colnames(player_frame) <- c("Player", "Unbiased", "Biased")
for (player in players) {
  filtered <- dat %>% filter(player == UQ(player))
  biased <- filtered %>% filter(type == "biased")
  unbiased <- filtered %>% filter(type == "unbiased")
  
  biased_win_rate <- nrow(filter(biased, result > 0)) / nrow(biased)
  unbiased_win_rate <- nrow(filter(unbiased, result > 0)) / nrow(unbiased)
  biased_mean <- signif(mean(biased$result), digits=3)
  unbiased_mean <- signif(mean(unbiased$result), digits=3)
  
  bias_sde <- signif(1.96 * sd(biased$result) / length(nrow(biased$result)), digits=2)
  unbias_sde <- signif(1.96 * sd(unbiased$result) / length(nrow(unbiased$result)), digits=2)
  
  biased_str <- biased_win_rate
  unbiased_str <- unbiased_win_rate
  #biased_str <- signif(sd(biased$result), digits=3)
  #unbiased_str <- signif(sd(unbiased$result), digits=3)
  player_frame[nrow(player_frame) + 1,] = c(player, unbiased_str, biased_str)
}

q <- xtable(player_frame)
print(q, type="latex")