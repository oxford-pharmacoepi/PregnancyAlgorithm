# Load libraries
library("DatabaseConnector")
library("here")

# Set connection details
server     <-"mssqltest.cqnqzwtn5s1q.us-east-1.rds.amazonaws.com"
user       <-"ohdsi"
password   <-"AB45BC78EA34"


connectionDetails <-DatabaseConnector::downloadJdbcDrivers("sql server",here::here())


# Connect to the database via database connector to run the algorithm
connectionDetails <-DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                               server = server,
                                                               user = user,
                                                               password = password,
                                                               pathToDriver = here::here())


targetDialect <-"sql server"
cdmDatabaseSchema <-"CDMV5.dbo"
vocabularyDatabaseSchema <-"ohdsi.dbo"
resultsDatabaseSchema <-"tempdb.dbo"

connection = connect(connectionDetails)

#source("~/GitHub/PregnancyEpisodeAlgorithm/R/main.R")
PregnancyEpisodeAlgorithm::clean (connectionDetails, resultsDatabaseSchema)
PregnancyEpisodeAlgorithm::init (connectionDetails, resultsDatabaseSchema, useMppUpload = FALSE)
PregnancyEpisodeAlgorithm::execute (connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema)
disconnect(connection)

library("dplyr")
library("dbplyr")
library(CDMConnector)


db <- DBI::dbConnect(odbc::odbc(),
                     Driver   = "ODBC Driver 18 for SQL Server",
                     Server   =  "mssqltest.cqnqzwtn5s1q.us-east-1.rds.amazonaws.com",
                     Database = "CDMV5",
                     UID      = "ohdsi",
                     PWD      = "AB45BC78EA34",
                     TrustServerCertificate="yes")

cdm <- CDMConnector::cdm_from_con(
  con = db,
  cdm_schema = c("CDMV5", "dbo"),
  write_schema = c(schema =  c("tempdb", "dbo"),
                   prefix = "pet_")
  
)

cdm$pet_motherTable <- tbl(db, in_schema("tempdb","pregnancy_episodes"))
DBI::dbDisconnect(attr(cdm, "dbcon"), shutdown = TRUE)
