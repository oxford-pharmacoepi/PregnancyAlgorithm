## making the algorithm fit the PET table

library("dplyr")
library("dbplyr")
library("CDMConnector")


db <- DBI::dbConnect(odbc::odbc(),
                     Driver   = "ODBC Driver 18 for SQL Server",
                     Server   =  "",
                     Database = "",
                     UID      = "",
                     PWD      = "",
                     TrustServerCertificate="yes")

cdm <- CDMConnector::cdm_from_con(
  con = db,
  cdm_schema = c("", ""),
  write_schema = c(schema =  c("", ""),
                   prefix = "pet_")

)

mothers_sql <- db %>% tbl(DBI::Id(catalog = "", schema = "", table = "pregnancy_episodes")) %>% collect()
names(mothers_sql ) <- tolower(names(mothers_sql ))
cdm <- insertTable(cdm, "mothers_sql2", mothers_sql , overwrite = TRUE)
cdm$mothertable  <- cdm$mothers_sql2 %>%
  dplyr::transmute(person_id = person_id,
                   pregnancy_id = row_number(),
                   pregnancy_start_date = as.Date(episode_start_date),
                   pregnancy_end_date = as.Date(episode_end_date),
                   gestational_length_in_day = episode_length,
                   pregnancy_outcome = as.numeric(ifelse(
                     original_outcome=="SA" & gestational_length_in_day <= (12*7),4067106,ifelse(
                       original_outcome=="SA" & gestational_length_in_day > (12*7),4081422, ifelse(
                         original_outcome=="DELIV",4092289,ifelse(
                           original_outcome %in% c("AB","ECT"),4081422,ifelse(
                             original_outcome=="LB",4092289,ifelse(
                               original_outcome=="SB",4067106,0))))))),
                   pregnancy_mode_delivery = NA,
                   pregnancy_single = NA,
                   prev_pregnancy_gravidity = episode - 1)



DBI::dbDisconnect(attr(cdm, "dbcon"), shutdown = TRUE)
