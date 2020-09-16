#####################################################################
### global.R
#####################################################################


# 1.0 loading libraries ---------------------------------------------------

# manipulate data
library(tidyverse)
library(tidyr)
library(DT)

# for visualization
library(highcharter)

# 1.1 library fro Connecting to database 
library(rJava)
library(RJDBC)



# 2.0 ReactivePoll Ficar Em Casa ------------------------------------------

FicarEmCasa_data <- reactivePoll(
  1 * 60 * 60 * 1000,
  session = NULL,
  checkFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.48.246:1521:OSPROD",
                "report",
                "report")
    
    max_date_ficarEmCasa <-
      dbGetQuery(conn,
                 "SELECT MAX (created_at) AS max_date  FROM osadmin.covid19_subscription sub")
    
    dbDisconnect(conn)
    
    
    return(max_date_ficarEmCasa)
    
  },
  
  valueFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.48.246:1521:OSPROD",
                "report",
                "report")
    
    
    # Query data
    sql_sttm <-
      "SELECT TRUNC (created_at) created_at,
         COUNT (*) counter_subscription,
         DECODE (PACKAGE_ID,  1, '1GB',  2, '3GB',  3, '5GB') package,
         pkg.name package_name,
         SUM (pkg.cost_amt / 100) cost_amt
    FROM osadmin.covid19_subscription sub, osadmin.COVID19_PACKAGE pkg
   WHERE pkg.id = sub.package_id AND response_code = 0 AND package_id > 0
GROUP BY TRUNC (created_at), package_id, pkg.name"
    
    
    
    # getting data
    ficarEmCasa_records <-
      dbGetQuery(conn, sql_sttm)
    
    dbDisconnect(conn)
    
    return(ficarEmCasa_records)
    
  }
)




# 2.1 ReactivePoll Estudar Em Casa ------------------------------------------

EstudarEmCasa_data <- reactivePoll(
    1 * 60 * 60 * 1000,
    session = NULL,
    checkFunc = function() {
        drv <- JDBC("oracle.jdbc.OracleDriver",
                    classPath = "ojdbc14.jar", " ")
        
        conn <-
            dbConnect(drv,
                      "jdbc:oracle:thin:@10.100.48.246:1521:OSPROD",
                      "report",
                      "report")
        
        max_date_estudarEmCasa <-
            dbGetQuery(conn,
                       "SELECT MAX (created_at) AS max_date  FROM osadmin.sgtw_record")
        
        dbDisconnect(conn)
        
        
        return(max_date_estudarEmCasa)
        
    },
    
    valueFunc = function() {
        drv <- JDBC("oracle.jdbc.OracleDriver",
                    classPath = "ojdbc14.jar", " ")
        
        conn <-
            dbConnect(drv,
                      "jdbc:oracle:thin:@10.100.48.246:1521:OSPROD",
                      "report",
                      "report")
        
        sql_sttm <-
            "SELECT TRUNC (created_at) created_at,
         COUNT (*) Subscription,
         SUM (charged_amount) Amount
      FROM osadmin.sgtw_record
GROUP BY TRUNC (created_at)"
        
        
        
        
        estudarEmCasa_records <-
            dbGetQuery(conn, sql_sttm)
        
        dbDisconnect(conn)
        
        return(estudarEmCasa_records)
        
    }
)



# 2.2 ReactivePoll Ficar Em Casa ------------------------------------------

gprs_traffic_data <- reactivePoll(
  1 * 60 * 60 * 1000,
  session = NULL,
  checkFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    max_date_gprs <-
      dbGetQuery(conn,
                 "SELECT MAX (date1) AS max_date FROM report.data_traffic_covid_estudar")
    
    dbDisconnect(conn)
    
    
    return(max_date_gprs)
    
  },
  
  valueFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    
    # Query data: data traffic
    sql_sttm <-
      "select * from report.data_traffic_covid_estudar"
    
    
    # getting data
  gprs_traffic_records <-
      dbGetQuery(conn, sql_sttm)
    
    
    
    
    dbDisconnect(conn)
    
    return(gprs_traffic_records)
    
  }
)


# 2.2 ReactivePoll: data traffic general ------------------------------------------

gprs_data_traffic_general <- reactivePoll(
  1 * 60 * 60 * 1000,
  session = NULL,
  checkFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    max_date_gprs_general <-
      dbGetQuery(conn,
                 "SELECT MAX (date1) AS max_date FROM report.data_traffic")
    
    dbDisconnect(conn)
    
    
    return(max_date_gprs_general)
    
  },
  
  valueFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    
    # Query data: data traffic
    sql_sttm <-
      "select * from report.data_traffic"
    
    
    # getting data
    gprs_traffic_records_general <-
      dbGetQuery(conn, sql_sttm)
    
    
    
    
    dbDisconnect(conn)
    
    return(gprs_traffic_records_general)
    
  }
)


# 3.0 Transforming data ---------------------------------------------------



base_ficarEmCasa_data <- reactive({
    
    dataset <- FicarEmCasa_data()
    
    
    # convert variables
    
    dataset$CREATED_AT <- as.Date(dataset$CREATED_AT)
    
    # convert all character variable to factor
    dataset <- mutate_if(dataset, is.character, as.factor)
    
    
    return(dataset)
    
})



# 3.1 Transforming gpsr data -----------------------------------------

base_gprs_traffic_data <- reactive({

  dataset <- gprs_traffic_data()
  
  # convert variable data type
  dataset$DATE1 <- as.Date(dataset$DATE1)
  
  return(dataset)
  
})

base_gprs_traffic_data_general <- reactive({
  
  dataset <- gprs_data_traffic_general()
  
  # convert variable data type
  dataset$DATE1 <- as.Date(dataset$DATE1)
  
  return(dataset)
  
})





# 2.0 Aggregate data ------------------------------------------------------


# fique em casa
ficaEmCasa_monthly_tbl <- reactive({
  result <-
    base_ficarEmCasa_data() %>%
    group_by(Month = lubridate::floor_date(CREATED_AT, unit = "month")) %>%
    summarise(Subscription = sum(COUNTER_SUBSCRIPTION),
              Amount = sum(COST_AMT))
  
  result
  
})


# ficaEmCasa_package_monthly_tbl <- reactive({
#   result <-
#     base_ficarEmCasa_data() %>%
#     group_by(Month = lubridate::floor_date(CREATED_AT, unit = "month"), PACKAGE) %>%
#     summarise(Subscription = sum(COUNTER_SUBSCRIPTION),
#               Amount = sum(COST_AMT)) %>%
#     ungroup()
#   
#   result
#   
# })



ficaEmCasa_package_monthly_tbl <- reactive({
  
  dataset <- base_ficarEmCasa_data()
  
  result <- 
    dataset %>% 
    group_by(Month = lubridate::floor_date(CREATED_AT, unit = "month"), PACKAGE) %>% 
    summarise(Subscription = sum(COUNTER_SUBSCRIPTION),
              Amount = sum(COST_AMT)
    ) %>% 
    ungroup()
  
  result
  
  
})
  

# 2.1 create table for Total values ---------------------------------------

total_FicaEmCasa_tbl <- reactive({
    
    result <- 
    base_ficarEmCasa_data() %>%
        # group_by(Month = lubridate::floor_date(CREATED_AT, unit = "month")) %>%
        summarise(
            total_Subscription = sum(COUNTER_SUBSCRIPTION),
            total_Amount = sum(COST_AMT)
        )
    
    result
    
    
})
    


# 3.0 Estudar em Casa -----------------------------------------------------

base_estudarEmCasa <- reactive({
    
    dataset <- EstudarEmCasa_data()
    
    
    # EstudarEmCasa_data %>% glimpse()
    
    # convert variable to date
    dataset$CREATED_AT <- as.Date(dataset$CREATED_AT)
    
    
    return(dataset)
    
})




# getting total
total_estudarEmCasa_tbl <- reactive({
    
    result <- 
    base_estudarEmCasa() %>%
        # group_by(Month = lubridate::floor_date(CREATED_AT, unit = "month")) %>%
        summarise(Subscription = sum(SUBSCRIPTION),
                  Amount = sum(AMOUNT))
    
    result
    
    
})




# monthly data
estudarEmCasa_monthly_tbl <- reactive({
    
    result <- 
    base_estudarEmCasa() %>%
        group_by(Month = lubridate::floor_date(CREATED_AT, unit = "month")) %>%
        summarise(Subscription = sum(SUBSCRIPTION),
                  Amount = sum(AMOUNT))
    
    return(result)
    
    
})


# 4.0 Subscribers Base Report ---------------------------------------------


# 4.1 ReactivePoll Prepaid Subscribers ------------------------------------------

prepaid_subscribers_data <- reactivePoll(
  12 * 60 * 60 * 1000,
  session = NULL,
  checkFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    max_date <-
      dbGetQuery(conn,
                 "SELECT MAX (date1) AS max_date FROM report.dash_prepaid_subscribers")
    
    dbDisconnect(conn)
    
    
    return(max_date)
    
  },
  
  valueFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    
    # Query data
    sql_sttm <-
      "SELECT * FROM report.dash_prepaid_subscribers"
    
    
    # getting data
    prepaid_subscribers_records <-
      dbGetQuery(conn, sql_sttm)
    
    
    
    
    
    dbDisconnect(conn)
    
    return(prepaid_subscribers_records)
    
  }
)


# 4.1 examine the data

# prepaid_subscribers_data %>% glimpse()

subscribers_base_data <- reactive({
  
  dataset <- prepaid_subscribers_data()
  
  dataset$DATE1 <- as.Date(dataset$DATE1)
  
  dataset <- mutate_if(dataset, is.character, as.factor)
  
  return(dataset)
  
  
})


# 5.2 aggregate the data -----------------
prep_subscribers_tbl <- reactive({
  dataset <- subscribers_base_data()
  
  result <- dataset %>%
    pivot_wider(names_from = STATUS, values_from = COUNTER)
  
  return(result)
  
  
})
  


# DUO subscribers
# DUO_subscribers_data %>% glimpse()

# 4.1 ReactivePoll DUO Subscribers ------------------------------------------

DUO_subscribers_data <- reactivePoll(
  12 * 60 * 60 * 1000,
  session = NULL,
  checkFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    max_date <-
      dbGetQuery(conn,
                 "SELECT MAX (date1) AS max_date FROM report.dash_prepaid_subscribers")
    
    dbDisconnect(conn)
    
    
    return(max_date)
    
  },
  
  valueFunc = function() {
    drv <- JDBC("oracle.jdbc.OracleDriver",
                classPath = "ojdbc14.jar", " ")
    
    conn <-
      dbConnect(drv,
                "jdbc:oracle:thin:@10.100.55.195:1521:CDRX03",
                "report",
                "report")
    
    
   # Query data: DUO subscribers
    sql_sttm <- "SELECT COUNT (*) counter, status2
    FROM (SELECT sub.*,
                 sc.*,
                 CASE
                    WHEN sub.STATUS = 0 AND sub.STATUS_INSTALLED_ACTIVE = 1
                    THEN
                       'Activos'
                    WHEN sub.STATUS = 1 AND sub.STATUS_INSTALLED_ACTIVE = 1
                    THEN
                       'Inactivos'
                    ELSE
                       'Pacote Inicial'
                 END
                    status2
            FROM prepaid_subscriber_base sub, REPORT.SERVICE_CLASSES sc
           WHERE     sub.SERV_CLASS_ID = sc.service_class_id
                 AND UPPER (SERVICE_CLASS_NAME) LIKE '%DUO%')
GROUP BY status2"
    
    # getting data
    DUO_subscribers_records <-
      dbGetQuery(conn, sql_sttm)
    
    
    
    dbDisconnect(conn)
    
    return(DUO_subscribers_records)
    
  }
)


DUO_subscribers_base_data <- reactive({
  
  dataset <- DUO_subscribers_data()
  
  result <- 
    dataset %>% 
    pivot_wider(names_from = "STATUS2", values_from = "COUNTER")
  
  return(result)
})





