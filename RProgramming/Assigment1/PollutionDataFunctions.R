file="specdata.zip"   
folder ="specdata/"
fileURL = "https://d396qusza40orc.cloudfront.net/rprog%2Fdata%2Fspecdata.zip"

if(!file.exists(destfile)){
  res <- tryCatch({download.file(fileURL,
                                destfile=file,
                                method="auto")
                  outDir<-"."
                  unzip(zipF,exdir=outDir)
                  },
                  error=function(e) {
                  message(paste("URL does not seem to exist:", fileURL))
                  message("Here's the original error message:")
                  message(e)
                  1},
                  finally = {
                    message(paste("Processed URL:", fileURL))
                    message(paste("Processed zipfile:",file))
                  })
}
  if (res!=1) 
  {  
    number <- length(list.files(folder,pattern="*.csv"))
    pollutantMean(folder,"sulfate",number)
    A <- completeCases(folder,number)
    B <- correlationTreshold(folder,number,100)
  }    
    
pollutantMean<- function(directory, pollutant, numberOfFiles)   
  { 
    sensorData <- data.frame()
    for (i in 1:numberOfFiles){
      A <- read.csv(list.files(path = directory, pattern = ".csv", full.names = TRUE)[i])
      sensorData <- rbind(A,sensorData)
    }
    mean(sensorData[[pollutant]],na.rm = TRUE)
  }



completeCases<- function(directory, numberOfFiles)   
{ 
  sensorData <- data.frame()
  for (i in 1:numberOfFiles){
    filename <- list.files(path = directory, pattern = ".csv", full.names = TRUE)[i]
    data <- read.csv(filename)
    comp <- sum(complete.cases(data))
    sensorData <- rbind(data.frame(sensor=filename,cases=comp),sensorData)
  }
  sensorData
}


correlationTreshold<- function(directory, numberOfFiles,treshold)   
{ 
  name <- vector()
  corre <- vector()
  for (i in 1:numberOfFiles){
    filename <- list.files(path = directory, pattern = ".csv", full.names = TRUE)[i]
    data <- read.csv(filename)
    comp <- sum(complete.cases(data))
    if (comp>treshold)
    {
      name <- c(name,filename)
      #data <- data[complete.cases(data),]
      corre <- c(corre,cor(x = data$sulfate,y = data$nitrate, use = "complete.obs"))
    }
  }  
    names(corre) <- name
    corre
}
