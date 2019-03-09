rankall <- function(outcome, num = "best") {
  ## Read outcome data
  if (!file.exists("outcome-of-care-measures.csv"))
    stop('file outcome-of-care-measures.csv  not present')
  file <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  ## Check that state and outcome are valid
  valid <- any(outcome==c('heart attack','heart failure','pneumonia'))
  if (valid==FALSE)
    stop(' invalid outcome')
  
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
  ## Return hospital name in that state with lowest 30-day death rate
  if (outcome=="heart attack") 
    result <- file %>% group_by(State)%>%arrange(Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack)%>%filter(row_number()==num)%>%select(Hospital.Name,State)%>%arrange(State)
  if (outcome=="heart failure") 
    result <- file %>% group_by(State)%>%arrange(Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure)%>%filter(row_number()==num)%>%select(Hospital.Name,State)%>%arrange(State)
  if (outcome=="pneumonia") 
    result <- file %>% group_by(State)%>%arrange(Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia)%>%filter(row_number()==num)%>%select(Hospital.Name,State)%>%arrange(State)
   
  result <- rename(result, hospital = Hospital.Name, state = State)
  return(result)
}
