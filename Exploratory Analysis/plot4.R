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
par(mfrow = c(2, 2))
plot(CONSUMP2DAYS$Global_active_power~CONSUMP2DAYS$Datetime, type="l", ylab="Global Active Power", xlab="")
plot(CONSUMP2DAYS$Voltage~CONSUMP2DAYS$Datetime, type="l", ylab="Voltage", xlab="Datetime")
plot(CONSUMP2DAYS$Sub_metering_1~CONSUMP2DAYS$Datetime, type="l",ylab="Energy sub metering", xlab="", cex=0.8)
lines(CONSUMP2DAYS$Sub_metering_2~CONSUMP2DAYS$Datetime, col='Red')
lines(CONSUMP2DAYS$Sub_metering_3~CONSUMP2DAYS$Datetime, col='Blue')
legend("topright", pch = 2, col = c("black","blue", "red"), legend = c("Sub_metering_1", "Sub_metering_2","Sub_metering_3"))
plot(CONSUMP2DAYS$Global_reactive_power~CONSUMP2DAYS$Datetime, type="l", ylab="Global_reactive_power", xlab="Datetime")
dev.copy(png, file="plot4.png", height=480, width=480)
dev.off()
