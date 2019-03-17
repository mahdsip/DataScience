# This function load the R on FHIR package from the library 
# where R stores its packages.
library(RonFHIR)

getAreaInfo <- function(postalCode){
  client <- fhirClient$new("https://vonk.fire.ly")
  postalQuery <- paste("address-postalcode=", postalCode, sep = "")
  
  bundle <- client$search("Patient", c(postalQuery, "address-use=home"))
  
  genders <- c()
  
  while(!is.null(bundle)){
    genders <- c(genders, bundle$entry$resource$gender)
    bundle <- client$continue(bundle)
  }
  
  table(genders)
}
getAreaInfo(3999)


bundle <- client$search("Patient", c("name=Peter"))
births <- c()

while(!is.null(bundle)){
  births <- c(births, bundle$entry$resource$birthDate)
  bundle <- client$continue(bundle)
}

table(births)

# Searching with a searchParams object
query <- searchParams$new()
query$select(c("name", "birthDate"))$where("given:exact=Peter")$orderBy("family")

peters <- client$searchByQuery(query, "Patient") 
# equivalent: client$search("Patient", c("_elements=name,birthDate","given:exact=Peter", "_sort=family"))

#GraphQL read
client$qraphQL("{id name{given,family}}", "Patient/example")

#GraphQL read
client$qraphQL("{PatientList(name:\"pet\"){name @first @flatten{family,given @first}}}")

# Operations
client$operation("Observation", name = "lastn")

















# connect to the server
client <- fhirClient$new("http://test.fhir.org/r3")

# just get a random patient, and print the identifier informaation
a <- client$read(location = "Patient/example", summaryType = "true")
a$identifier

# count Patients on the server with gender = male
b <- client$search("Patient", "gender=male", summaryType="count")
b$total

# now, graphql on a resource
c <- client$qraphQL(location = "Patient/example", query = "{id name{given,family}}")
print(c)

# and a graphQL based search
d <- client$qraphQL(location = NULL, query = "{PatientList(name:\"pet\"){name @first @flatten{family,given @first}}}")
print(d)

# invoking a FHIR operation
e <- client$operation(resource = "Observation", id = NULL, name = "lastn", parameters = "max=3&patient=Patient/example&category=vital-signs")
print(e)