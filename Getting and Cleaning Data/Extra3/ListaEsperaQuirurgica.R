install.packages("RSelenium")

#Ejecutar Selenium
# cd C:\Selenium
# java -Dwebdriver.gecko.driver="C:\Selenium\chromedriver.exe" -jar selenium-server-standalone-3.141.5.jar

library(RSelenium)
library(stringr)

remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444L
                      , browserName = "chrome"
)
#remDr <- remoteDriver(port = 4444L)

remDr$open()
basePage <- "https://servicioselectronicos.sanidadmadrid.org/LEQ/Consulta.aspx"
remDr$navigate(basePage)

#Coger todos los hospitales
TodosHosp <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]')
remDr$findElement(using = "xpath", value = TodosHosp)$clickElement()
hospitales <- unlist(remDr$findElement(using = "xpath", value = TodosHosp)$getElementText())
##Separar la variable en una lista y con el n�mero de hospitales hacer un bucle y hacer option[i]
hosp <- unlist(strsplit(hospitales,split='\n', fixed=TRUE))
hosp <- trimws(hosp)

#Hay que seleccionar un hospital para que se puedan seleccionar especialidad y fecha
hospital <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]/option[1]')
remDr$findElement(using = "xpath", value = hospital)$clickElement()  

row <- 0

final <- data.frame(hospital=character(),
                    especialidad = character(),
                    fecha = character(),
                    lesp=integer(),
                    npac = integer(),
                    stringsAsFactors = FALSE) 

enviar <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_btnEnviar"]')


for (i in 1:(length(hosp)-1))
{
#Coger todas las especialidades, se debe seleccionar primero un hospital
#hospital <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]/option[@value="2549"]')
hospital <- c(paste0('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]/option[',i+25,']'))
remDr$findElement(using = "xpath", value = hospital)$clickElement()   

nombreHospital <- unlist(remDr$findElement(using = "xpath", value = hospital)$getElementText())

TodasEsp <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlEspecialidad"]')
remDr$findElement(using = "xpath", value = TodasEsp)$clickElement()
especialidades <- unlist(remDr$findElement(using = "xpath", value = TodasEsp)$getElementText())
es <- unlist(strsplit(especialidades,split='\n', fixed=TRUE))
es <- trimws(es)

j<-1
for (j in 1:length(es))
  
{

hospital <- c(paste0('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]/option[',i+25,']'))
remDr$findElement(using = "xpath", value = hospital)$clickElement()   


#Coger datos
esp <- c(paste0('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlEspecialidad"]/option[',j,']'))
remDr$findElement(using = "xpath", value = esp)$clickElement()
nombreEspecialidad <- unlist(remDr$findElement(using = "xpath", value = esp)$getElementText())

# #Todas las fechas
TodasFech <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlFecha"]')
remDr$findElement(using = "xpath", value = TodasFech)$clickElement()
fechas <- unlist(remDr$findElement(using = "xpath", value = TodasFech)$getElementText())
fec <- unlist(strsplit(fechas,split='\n', fixed=TRUE))
fec <- trimws(fec)

k<-0
lfec <- length(fec)
while (k < lfec)
{
k <- k+1
remDr$findElement(using = "xpath", value = hospital)$clickElement()
#Sys.sleep(5)
remDr$findElement(using = "xpath", value = esp)$clickElement()
#Sys.sleep(5)
fecha <- c(paste0('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlFecha"]/option[',k,']'))
remDr$findElement(using = "xpath", value = fecha)$clickElement()
nombreFecha <- unlist(remDr$findElement(using = "xpath", value = fecha)$getElementText())
#Sys.sleep(5)

remDr$findElement(using = "xpath", value = enviar)$clickElement()
#Sys.sleep(5)

datos <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_lblIndicadores"]')
C <- unlist(remDr$findElement(using = "xpath", value = datos)$getElementText())

X <- str_split(C, "\n",simplify = TRUE)

lestp <- str_split(X[1], ":",simplify = TRUE)
npac <- str_split(X[3], ":",simplify = TRUE)

l <- trimws(lestp[2])
l<-as.numeric( str_replace(l,"\\,","."))

n <- trimws(npac[2])
n<-as.numeric( str_replace(n,"\\,","."))
row <- row+1

final[row,"lesp"] <- l
final[row,"npac"] <- n
final[row,]$hospital <- as.character(nombreHospital)
final[row,]$especialidad <- as.character(nombreEspecialidad)
final[row,]$fecha <- as.character(nombreFecha)
reinicio <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_LinkButton1"]')
remDr$findElement(using = "xpath", value = reinicio)$clickElement()
}

}

}

#En algunas ocasiones ponen punto en los millares para el n�mero de pacientes en leq
final2 <- final
final$lesp2 <- as.character(final$lesp)
final$lesp2 <- str_replace(final$lesp2,"\\.","")
final$lesp2 <- as.integer(final$lesp2)

final$lesp <- final$lesp2
final <- final[,1:5]

load('CRUZROJA-PPEASTURIAS.Rdata')

datos <- rbind(datos,final)

save(datos,file = 'LEQ.Rdata')

############################################################
save.image(file = 'Octubre.Rdata')

save.image(file = 'CRUZROJAYGOMEZULLA.Rdata')
save.image(file = 'SANCARLOS-PPEASTURIAS.Rdata')
save(final2,file = 'FINAL-SANCARLOS-PPEASTURIAS.Rdata')
load('Octubre.Rdata')

load('CRUZROJAYGOMEZULLA.Rdata')

final <- subset(final,final$hospital!='HOSPITAL CLINICO SAN CARLOS')

datos<- rbind(final,final2)
save(datos,file = 'CRUZROJA-PPEASTURIAS.Rdata')
load('CRUZROJA-PPEASTURIAS.Rdata')


datos$lesp2 <- as.character(datos$lesp)
datos$lesp2 <- str_replace(datos$lesp2,"\\.","")
datos$lesp2 <- as.integer(datos$lesp2)
library(ggplot2)

SanCarlos <- subset(final,final$hospital=='HOSPITAL CLINICO SAN CARLOS')
p = ggplot(data = SanCarlos, aes(x = especialidad, y = npac))
p = p + geom_bar(stat='identity')
#p = p + facet_wrap(~hospital,ncol=3)
#p = p + ylim(-0, 400)
p+ theme(axis.text.x = element_text(angle = 90, hjust = 1))
p

p = ggplot(data = final, aes(x = especialidad, y = npac))
p = p + geom_bar(stat='identity')
p = p + facet_wrap(~hospital,ncol=3)
p+ theme(axis.text.x = element_text(angle = 90, hjust = 1))
#p = p + ylim(-0, 400)
p

TodosHosp <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlHospital"]')
remDr$findElement(using = "xpath", value = TodosHosp)$clickElement()
hospitales <- unlist(remDr$findElement(using = "xpath", value = TodasEsp)$getElementText())

TodasEsp <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlEspecialidad"]')
remDr$findElement(using = "xpath", value = TodasEsp)$clickElement()
especialidades <- unlist(remDr$findElement(using = "xpath", value = TodasEsp)$getElementText())
especialidadesValue <- unlist(remDr$findElement(using = "xpath", value = TodasEsp)$getElementAttribute("value"))

#Todas las fechas
TodasFech <- c('//*[@id="ctl00_ctl00_ctl00_MasterCuerpo_MasterCuerpo_ContenedorContenidoSeccion_ddlFecha"]')
remDr$findElement(using = "xpath", value = TodasFech)$clickElement()
fechas <- unlist(remDr$findElement(using = "xpath", value = TodasFech)$getElementText())