best <- function(state, outcome) {
  ## Read outcome data
  if (!file.exists("outcome-of-care-measures.csv"))
      stop('file outcome-of-care-measures.csv  not present')
  file <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  ## Check that state and outcome are valid
  valid <- any(state==file$State)
  if (valid==FALSE)
    stop(' invalid state')
  valid <- any(outcome==c('heart attack','heart failure','pneumonia'))
  if (valid==FALSE)
   stop(' invalid outcome')
  ## Return hospital name in that state with lowest 30-day death rate
  if (outcome=="heart attack") 
    outcome = "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack"
  if (outcome=="heart failure") 
    outcome = "Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure"  
  if (outcome=="pneumonia") 
    outcome = "Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia"    
  data <- select(file,Hospital.Name,State,outcome)
  data[,3] <- suppressWarnings(as.numeric(data[,3]))
  data <- data[!is.na(data[,3]),]
  data <- filter(data,State ==state)
  ## return data
  data$Hospital.Name[which.min(data[, 3])]
}
