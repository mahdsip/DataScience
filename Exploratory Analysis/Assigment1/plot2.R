library(dplyr)

file.name <- "./household_power_consumption.txt"
url       <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
zip.file  <- "./data.zip"

# Check if the data is downloaded and download when applicable
if (!file.exists(file.name)) {
  download.file(url, destfile = zip.file)
  unzip(zip.file)
  file.remove(zip.file)
}

CONSUMP = read.csv(file.name, sep = ";",dec = ".",na.strings = "?")
CONSUMP$Date = as.Date(CONSUMP$Date, "%d/%m/%Y")
CONSUMP2DAYS = filter(CONSUMP,Date>="2007-02-01"&Date<="2007-02-02")
CONSUMP2DAYS$Datetime =  as.POSIXct(strptime(paste(CONSUMP2DAYS$Date, CONSUMP2DAYS$Time, sep = " "),format = "%Y-%m-%d %H:%M:%S"))
CONSUMP2DAYS$Global_active_power = as.double(CONSUMP2DAYS$Global_active_power)
plot(CONSUMP2DAYS$Global_active_power~CONSUMP2DAYS$Datetime, type="l", ylab="Global Active Power (kilowatts)", xlab="")
dev.copy(png, file="plot2.png", height=480, width=480)
dev.off()
