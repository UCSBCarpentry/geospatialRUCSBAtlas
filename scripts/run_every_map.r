# a script to run each map.

# start fresh
rm(list=ls())

map_list <- list.files("scripts", pattern='^ma', full.names=TRUE)
map_list

# this runs a script #1 straight through:
# source(episode_list[1])

# time for a for loop:
for (map_sheet in map_list) {
    cat("\n******** Building map: ", map_sheet, " *********\n\n")
    source(map_sheet, echo = TRUE)
}
