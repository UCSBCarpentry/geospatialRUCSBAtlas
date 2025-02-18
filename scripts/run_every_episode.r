# a script to run all the episodes

# start fresh
rm(list=ls())

episode_list <- list.files("scripts", pattern='^ep', full.names=TRUE)
episode_list

# this runs a script #1 straight through:
# source(episode_list[1])

# time for a for loop:
for (episode in episode_list) {
    source(episode)
}
