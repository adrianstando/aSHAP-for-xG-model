library(dplyr)

preprocess <- function(data){
  raw_data <- data
  shot_stats <- raw_data %>% filter(result != "OwnGoal") %>%
    mutate(status = ifelse(result == "Goal", 1, 0)) %>%
    mutate(distanceToGoal = sqrt((105 - (X * 105)) ^ 2 + (32.5 - (Y * 68)) ^ 2)) %>%
    mutate(angleToGoal = abs(atan((7.32 * (105 - (X * 105))) / ((105 - (X * 105))^2 + (32.5 - (Y * 68)) ^ 2 - (7.32 / 2) ^ 2)) * 180 / pi)) %>%
    mutate(h_a = factor(h_a),
           situation = factor(situation),
           shotType = factor(shotType),
           lastAction = factor(lastAction),
           minute = as.numeric(minute)) %>%
    select(status, minute, h_a, situation, shotType, lastAction, 
           distanceToGoal, angleToGoal, league, season, match_id, result, player_id) %>%
    select(status, minute, h_a, situation, shotType, lastAction, 
           distanceToGoal, angleToGoal)
  as.data.frame(shot_stats)
} 
