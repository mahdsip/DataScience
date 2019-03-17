#Introduction

In this practice there is the necesary steps to connect a database throght 3 SQL implementations: ODBC (microsoft), Oracle(official client) and JDBC(Java).

RJDBC will run quicker because it converts date to character and everything else to numeric. 
RODBC will try to preserve the data type of the SQL table.

If RODBC is very slow, would make sure that your R timezone - sys.setenv(TZ='GMT') set to GMT for example - is same as the time zone of the SQL server from where you are pulling data. 

It could be that the date column is taking a long time to be interpreted especially if it has a timestamp.

See performance query 
#system.time(df <- sqlQuery(cn, query))

#RODBC
```{r eval=FALSE}
install.packages("RODBC")
library(RODBC)
#DD1 would be the DSN 
con <- odbcConnect("DD1", uid="rquser", pwd="rquser", rows_at_time = 500)
sqlSave(con,test_table, "TEST_TABLE")
sqlQuery(con,"select count(*) from TEST_TABLE")
d <- sqlQuery(con, "select * from TEST_TABLE")
close(con)
```

#RORACLE
```{r eval=FALSE}
##Special instructions are needed for installing RORacle, since it needs to be downloaded and compiled.
library(RCurl)
zipi <- getURLContent("http://download.oracle.com/otn/nt/roracle/ROracle_1.3-1.zip")
install.packages(zipi, repos = NULL)
#Download binary from oracle: http://www.oracle.com/technetwork/database/database-technologies/r/roracle/downloads/index.html
setwd('C:\\Users\\MH026898\\Downloads')   # set to path of download
install.packages('ROracle_1.3-1.zip', repos = NULL)
#Then load the library and use the package - you may have to change XXXX to whatever is in your TNS Names:
library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "rquser", "rquser")
dbWriteTable(con,"TEST_TABLE", test_table)
dbGetQuery(con,"select count(*) from TEST_TABLE")
d <- dbReadTable(con, "TEST_TABLE")
dbDisconnect(con)
library('ROracle')
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "USER GOES HERE", "PASSWORD GOES HERE", dbname='XXX')
#test connection:
dbReadTable(con, 'DUAL')
#Use conection string instead of TNS NAMES
library('ROracle')
drv <- dbDriver("Oracle")
host <- "10.181.85.198"
port <- 1521
sid <- "cws"
connect.string <- paste(
  "(DESCRIPTION=",
  "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
  "(CONNECT_DATA=(SID=", sid, ")))", sep = "")
## Use username/password authentication.
con <- dbConnect(drv, "reports", "reports", dbname=connect.string)
##test connection:
  
rs <- dbSendQuery(con, "select * from parametros_birt")
## We now fetch records from the resultSet into a data.frame.
data <- fetch(rs)       ## extract all rows
dim(data)
dbDisconnect(con)
```
#USING RJDBC
```{r eval=FALSE}
ConnectDB = function(){
  library(rJava)
  library(RJDBC)
  .jinit()
  drv <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="jdbcDrivers/Oracle/ojdbc6.jar")
  drv <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="./ojdbc6.jar")
  con <- dbConnect(drv, "jdbc:oracle:thin:@//IPADRESS:PORT/SERVICENAME", "user", "passw")
  return(con)
}
con <- ConnectDB()
#It can be used other drivers for jdbc
library(RJDBC)
drv <- JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver","/sqljdbc4.jar") 
con <- dbConnect(drv, "jdbc:sqlserver://server.location", "username", "password")
dbGetQuery(con, "select column_name from table")
