# a script to run all the episodes

# start fresh
rm(list=ls())

episode_list <- list.files("scripts", pattern='^ep', full.names=TRUE)
episode_list

# this runs a script #1 straight through:
# source(episode_list[1])

# time for a for loop:
for (episode in episode_list) {
  cat("\n******** Running episode: ", episode, " *********\n\n")
  tt <- system.time(source(episode))
  cat("\n******** Episode ran in ", tt[3], " s *********\n\n")
}
