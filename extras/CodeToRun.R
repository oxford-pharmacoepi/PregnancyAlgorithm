# Load libraries
library("DatabaseConnector")
library("here")

## fill in these details
# Set connection details
server     <-""
user       <-""
password   <-""


connectionDetails <-DatabaseConnector::downloadJdbcDrivers("sql server",here::here())


# Connect to the database via database connector to run the algorithm
connectionDetails <-DatabaseConnector::createConnectionDetails(dbms = "sql server",
                                                               server = server,
                                                               user = user,
                                                               password = password,
                                                               pathToDriver = here::here())

## fill in these details
targetDialect <-"sql server"
cdmDatabaseSchema <-""
vocabularyDatabaseSchema <-""
resultsDatabaseSchema <-""

connection = connect(connectionDetails)

source("~/pregnancyAlgorithm/R/main.R")
PregnancyAlgorithm::clean (connectionDetails, resultsDatabaseSchema)
PregnancyAlgorithm::init (connectionDetails, resultsDatabaseSchema)
PregnancyAlgorithm::execute (connectionDetails, cdmDatabaseSchema, resultsDatabaseSchema)
disconnect(connection)
