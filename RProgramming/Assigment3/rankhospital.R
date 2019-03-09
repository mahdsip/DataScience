rankhospital <- function(state, outcome, num = "best") {
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
  data <- arrange(data,data[,3])
  
  if (class(num)=="numeric"){
    if (num<1 | num > nrow(data))
      return(NA)
  }
  if (class(num)=="character"){
    valid <- any(num==c('best','worst'))
    if (valid==FALSE)
      stop(' invalid num')  
    if (num=='best') num <- 1
    if (num=='worst') num <- nrow(data)
  }
  data <- data[order(data[,3],data[,1]),]
  data[num,1]
}
