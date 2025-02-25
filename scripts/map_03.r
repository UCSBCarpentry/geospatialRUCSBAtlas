# Map 3
# this is the  layout page with 4 maps on it
# maps 4 - 5 - 6 zoom in tryptic
# and map 7, which is a version of map 1
# 

# set map number
current_sheet <- 3
# set ggplot counter
current_ggplot <- 0

gg_labelmaker <- function(plot_num){
  gg_title <- c("Map:", current_sheet, " ggplot:", plot_num)
  plot_text <- paste(gg_title, collapse=" " )
  print(plot_text)
  current_ggplot <<- plot_num
  return(plot_text)
}

