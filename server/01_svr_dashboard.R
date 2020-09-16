############################################################
### 01_srv_dashboard.R
##########################################################

# 1.1 0 getting actual prepaid subscribers -------------------
lastDay_prep_subscribers_tbl <- reactive({
    result <-
        prep_subscribers_tbl() %>%
        arrange(DATE1) %>%
        slice(n())
    
    return(result)
    
})


# 2.2 getting the last 30 days prepaid subscribers -----------------
previousDay_prep_subscribers_tbl <- reactive({
    result <-
        prep_subscribers_tbl() %>%
        arrange(DATE1) %>%
        slice(n() - 30)
    
    return(result)
    
})




# adding the actual numbers of subscribers to the chart
#  update on 2020-06-09
actual_subscribers_tbl <- reactive({
    
    result <- 
        lastDay_prep_subscribers_tbl() %>% 
        select(DATE1, Activos)
    
    return(result)
})


# new version: updated on 2020-06-09
prep_active_subscribers_tbl <- reactive({
    
    result <-
        prep_subscribers_tbl() %>%
        select(DATE1, Activos) %>%
        # filter(startsWith(as.character(DATE1), '01'))
        filter(grepl('01', DATE1)) %>%
        arrange(desc(DATE1))
    
    result <- rbind(actual_subscribers_tbl(), result)
    
    
    result <- 
        result %>% 
        arrange(DATE1) %>% 
        mutate(perc = round((Activos/lag(Activos) -1)*100, 2))
    
    return(result)
    
    
})




# 1.2 Render Dashboard UI -------------------------------------------------


output$dashboardUI <- renderUI({
    
    
    
    tagList(
        
        # fluidRow(
        #     column(
        #         width = 4,
        #         cardPad(
        #             color = "info",
        #             descriptionBlock(
        #                 header = "8390",
        #                 text = "VISITS",
        #                 right_border = FALSE,
        #                 margin_bottom = TRUE
        #             ),
        #             descriptionBlock(
        #                 header = "30%",
        #                 text = "REFERRALS",
        #                 right_border = FALSE,
        #                 margin_bottom = TRUE
        #             ),
        #             descriptionBlock(
        #                 header = "70%",
        #                 text = "ORGANIC",
        #                 right_border = FALSE,
        #                 margin_bottom = FALSE
        #             )
        #         )
        #     )
        # ),
        
        fluidRow(
            bs4InfoBox(
                title = "Total Activos",
                value = prettyNum(lastDay_prep_subscribers_tbl()$Activos, big.mark = ","),
                icon = "user-plus"
            ),
            bs4InfoBox(
                title = "Total Inactivos",
                gradientColor = "danger",
                # status = "info",
                value = prettyNum(lastDay_prep_subscribers_tbl()$Inactivos, big.mark = ","),
                icon = "user-times"
            ),
            bs4InfoBox(
                title = "Total DUO",
                # gradientColor = "danger",
                status = "info",
                value = prettyNum(DUO_subscribers_base_data()$Activos, big.mark = ","),
                icon = "user-plus"
            )
    ),
        
        br(),
        
        fluidRow(
            column(
                width = 6,
                uiOutput("tab_prepaid")
            ),
            column(
                width = 6,
                uiOutput("tab_postpaid")
            ) 
        )
        
    )
})


output$tab_prepaid <- renderUI({
    
    bs4TabCard(
        id = "tabcard_prepaid",
        title = "Prepaid",
        width = 12,
        bs4TabPanel(
            tabName = "Subscritores Activos",
            active = TRUE,
            highchartOutput("hc_plot_prepaid_active_subscribers", height = "500px")
        ),
        bs4TabPanel(
            tabName = "Tab 2",
            active = FALSE,
            "Content 2"
        ),
        bs4TabPanel(
            tabName = "Tab 3",
            active = FALSE,
            "Content 3"
        )
    )
    
    
})


output$tab_postpaid <- renderUI({
    
    bs4TabCard(
        id = "tabcard_postpaid",
        title = "Postpaid",
        width = 12,
        bs4TabPanel(
            tabName = "Tab 1",
            active = FALSE,
            "Content 1"
        ),
        bs4TabPanel(
            tabName = "Tab 2",
            active = TRUE,
            "Content 2"
        ),
        bs4TabPanel(
            tabName = "Tab 3",
            active = FALSE,
            "Content 3"
        )
    )
    
    
})


# Visualization -----------------------------------------------------------

output$hc_plot_prepaid_active_subscribers <- renderHighchart({
    
    # combo chart 2nd version
    highchart() %>% 
        hc_yAxis_multiples(
            list(top = "0%", height = "60%", lineWidth = 3, title = list(text = "Número de Subscritores")),
            list(top = "60%", height = "40%", offset = 0,
                 showFirstLabel = FALSE, showLastLabel = FALSE,
                 title = list(text = "Taxa de Crescimento"),
                 labels = list(format = '{value} %'))
        ) %>% 
        hc_add_series(data = prep_active_subscribers_tbl()$Activos,
                      name = "Numero de Subscritores",
                      type = "column",
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_add_series(data = prep_active_subscribers_tbl()$perc,
                      name = "Percentagem",
                      type = "area", yAxis = 1,
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_xAxis(categories = prep_active_subscribers_tbl()$DATE1) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>% 
        hc_title(text = "Numero de Subescritores Activos por Mes") %>% 
        hc_subtitle(text = "Prepagos") %>% 
        hc_exporting(enabled = TRUE) 
    
})