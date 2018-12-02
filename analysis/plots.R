library(tidyverse)

dir <- "/Users/guyaridor/Desktop/deep_learning_project/analysis/"
dat <- read.csv(paste(dir, "results.csv", sep=""))

players <- unique(dat$player)
for (player in players) {
  filtered_dat = filter(dat, player == UQ(player))
  q <- ggplot(filtered_dat, aes(x=result)) + geom_density() + 
    ggtitle(paste(player, "Distribution of Results")) + xlab("Chips Won") +
    geom_vline(aes(xintercept=mean(result)), color="#FF0000")
  print(q)
}