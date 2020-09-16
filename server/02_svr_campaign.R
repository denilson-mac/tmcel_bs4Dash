#######################################################################
### 02_svr_campaign.R
######################################################################

plot_data_traffic <- reactive({
    
    dataset <- base_gprs_traffic_data()
    
    result <- 
        dataset %>% 
        group_by(DATE1) %>% 
        summarise(upload = round(sum(UPLOADVOLUME_MB/1024)),
                  download = round(sum(DOWNLOADVOLUME_MB/1024))
        ) %>% 
        ungroup()
    
    return(result)
    
})


plot_data_traffic_general <- reactive({
    
    dataset <- base_gprs_traffic_data_general()
    
    result <- 
        dataset %>% 
        group_by(DATE1) %>% 
        summarise(upload = round(sum(UPLOADVOLUME_MB/(1024*1024))),
                  download = round(sum(DOWNLOADVOLUME_MB/(1024*1024)))
        ) %>% 
        ungroup()
    
    return(result)
    
})



# 2.2 Render Dashboard UI -------------------------------------------------


output$campaignUI <- renderUI({
    
    
    
    tagList(
        
        fluidRow(
                   bs4ValueBox(
                    value = strong(prettyNum(total_FicaEmCasa_tbl()$total_Subscription, big.mark = ",")),
                    subtitle = "Total Subscricao",
                    status = "primary",
                    # icon = "shopping-cart",
                    icon = "users",
                    # href = "#",
                    footer = shiny::div("#FiqueEmCasa")
                   ),
                   
                   bs4ValueBox(
                    value = strong(paste(
                        prettyNum(total_FicaEmCasa_tbl()$total_Amount, big.mark = ","),
                        " MT")),
                    subtitle = "Montante Total",
                    status = "success",
                    # icon = "sliders",
                    icon = "money-bill-wave",
                    footer = shiny::div("#FiqueEmCasa")
                   ),
                   
                   bs4ValueBox(
                       value = strong(prettyNum(total_estudarEmCasa_tbl()$Subscription, big.mark = ",")),
                       subtitle = "Total Subscricao",
                       status = "primary",
                       icon = "users",
                       # icon = "shopping-cart",
                       # status = "danger",
                       # icon = "cogs",
                       footer = shiny::div("#EstudeEmCasa")
                   ),
                   
                   bs4ValueBox(
                       value = strong(paste(
                           prettyNum(total_estudarEmCasa_tbl()$Amount, big.mark = ","),
                           " MT")),
                       subtitle = "Montante Total",
                       status = "success",
                       # icon = "sliders",
                       icon = "money-bill",
                       footer = shiny::div("#EstudeEmCasa")
                   )
                 ),
        
        # fluidRow(
        #            bs4InfoBox(
        #             title = "Messages",
        #             value = 1410,
        #             icon = "envelope"
        #            ),
        #            bs4InfoBox(
        #             title = "Bookmarks",
        #             status = "info",
        #             value = 240,
        #             icon = "bookmark"
        #            ),
        #            bs4InfoBox(
        #             title = "Comments",
        #             gradientColor = "danger",
        #             value = 41410,
        #             icon = "comments"
        #            )
        #          ),
       br(),
        
        fluidRow(
            column(
                width = 6,
                uiOutput("tab_fiqueEmCasa")
            ),
            column(
                width = 6,
                uiOutput("tab_estudeEmCasa")
            )
        )
        
    )
})


output$tab_fiqueEmCasa <- renderUI({
    
    bs4TabCard(
        id = "tabcard_fiqueEmCasa",
        title = "#FiqueEmCasa",
        width = 12,
        bs4TabPanel(
            tabName = "Visao Geral",
            active = TRUE,
            highchartOutput("hc_plot_ficar_em_casa", height = "500px")
        ),
        bs4TabPanel(
            tabName = "Subscricao por Pacote",
            active = FALSE,
            highchartOutput("hc_plot_package_subscription", height = "500px")
        ),
        bs4TabPanel(
            tabName = "Montante por Pacote",
            active = FALSE,
            highchartOutput("hc_plot_package_amount", height = "500px")
        )
    )
    
    
})


output$tab_estudeEmCasa <- renderUI({
    
    bs4TabCard(
        id = "tabcard_estudeEmCasa",
        title = "#EstudeEmCasa",
        width = 12,
        bs4TabPanel(
            tabName = "Visao Geral",
            active = FALSE,
            highchartOutput("hc_plot_estudar_em_casa", height = "500px")
        ),
        bs4TabPanel(
            tabName = "Consumo de Dados",
            active = TRUE,
            highchartOutput("hc_plot_gprs_traffic", height = "500px")
        ),
        bs4TabPanel(
            tabName = "Consumo de Dados: Geral",
            active = FALSE,
            highchartOutput("hc_plot_gprs_traffic_general", height = "500px")
        )
    )
    
    
})

# Plot Ficar Em Casa ------------------------------------------------------

output$hc_plot_ficar_em_casa <- renderHighchart({
    
    
    
    # combo chart 2nd version
    hc_out <- 
        highchart() %>% 
        hc_yAxis_multiples(
            list(top = "0%", height = "30%", lineWidth = 3, title = list(text = "Numero de Subscricoes")),
            list(top = "30%", height = "70%", offset = 0,
                 showFirstLabel = FALSE, showLastLabel = FALSE,
                 title = list(text = "Montante em MTs"))
        ) %>% 
        hc_add_series(data = ficaEmCasa_monthly_tbl()$Subscription,
                      name = "Subscricao",
                      type = "column",
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_add_series(data = ficaEmCasa_monthly_tbl()$Amount,
                      name = "Montante Mensal",
                      type = "spline", yAxis = 1,
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>% 
        hc_exporting(enabled = TRUE)
    
    hc_out %>% 
        hc_xAxis(categories = ficaEmCasa_monthly_tbl()$Month) %>% 
        hc_title(text = "Numero de Subscricoes e Montante Mensal") %>% 
        hc_subtitle(text = "Campanha: COVID-19 #FiqueEmCasa")
    
})



# susbcricao por pacote
output$hc_plot_package_subscription <- renderHighchart({
    
    
    
    ficaEmCasa_package_group_monthly_tbl <-
        ficaEmCasa_package_monthly_tbl() %>%
        select(-Amount) %>%
        pivot_wider(names_from = PACKAGE, values_from = Subscription, values_fill = 0)
    
    
    highchart() %>%
        hc_xAxis(categories = ficaEmCasa_package_group_monthly_tbl$Month) %>%
        hc_add_series(data = ficaEmCasa_package_group_monthly_tbl$`1GB`,
                      name = "1GB",
                      type = "column",
                      dataLabels = list(enabled = TRUE)) %>%
        hc_add_series(data = ficaEmCasa_package_group_monthly_tbl$`3GB`,
                      name = "3GB",
                      type = "column",
                      dataLabels = list(enabled = TRUE)) %>%
        hc_add_series(data = ficaEmCasa_package_group_monthly_tbl$`5GB`,
                      name = "5GB",
                      type = "column",
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>% 
        hc_exporting(enabled = TRUE) %>% 
        hc_title(text = "Numero de Subscricoes por Pacotes") %>% 
        hc_subtitle(text = "Campanha: COVID-19 #EstudeEmCasa") %>% 
        hc_exporting(enabled = TRUE) 
    
    
    
})


# MOntante Mensal por Pacote

output$hc_plot_package_amount <- renderHighchart({
    
    
    ficaEmCasa_package_Amount_monthly_tbl <- 
        ficaEmCasa_package_monthly_tbl() %>% 
        select(-Subscription) %>% 
        pivot_wider(names_from = PACKAGE, values_from = Amount, values_fill = 0)
    
    highchart() %>% 
        hc_xAxis(categories = ficaEmCasa_package_Amount_monthly_tbl$Month) %>% 
        hc_add_series(data = ficaEmCasa_package_Amount_monthly_tbl$`1GB`,
                      name = "1GB",
                      type = "spline",
                      dataLabels = list(enabled = TRUE)) %>%
        hc_add_series(data = ficaEmCasa_package_Amount_monthly_tbl$`3GB`,
                      name = "3GB",
                      type = "spline",
                      dataLabels = list(enabled = TRUE)) %>%
        hc_add_series(data = ficaEmCasa_package_Amount_monthly_tbl$`5GB`,
                      name = "5GB",
                      type = "spline",
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>% 
        hc_exporting(enabled = TRUE) %>% 
        hc_title(text = "Montante Mensal por Pacotes") %>% 
        hc_subtitle(text = "Campanha: COVID-19 #EstudeEmCasa")
    
})

# Plot Estudar em Casa ----------------------------------------------------


output$hc_plot_estudar_em_casa <- renderHighchart({
    
    
    
    # combo chart 2nd version
    
    highchart() %>% 
        hc_xAxis(categories = estudarEmCasa_monthly_tbl()$Month) %>% 
        hc_add_series(data = estudarEmCasa_monthly_tbl()$Subscription,
                      name = "Subscricao",
                      type = "column",
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_add_series(data = estudarEmCasa_monthly_tbl()$Amount,
                      name = "Montante Mensal",
                      type = "spline", yAxis = 1,
                      dataLabels = list(enabled = TRUE)) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>% 
        hc_yAxis_multiples(
            list(top = "0%", height = "30%", lineWidth = 3, title = list(text = "Numero de Subscricoes")),
            list(top = "30%", height = "70%", offset = 0,
                 showFirstLabel = FALSE, showLastLabel = FALSE,
                 title = list(text = "Montante em MTs"))
        ) %>% 
        hc_exporting(enabled = TRUE) %>% 
        hc_title(text = "Numero de Subscricoes e Montante Mensal") %>% 
        hc_subtitle(text = "Campanha: COVID-19 #EstudeEmCasa")
    
})



# Plot GPRS Traffic -------------------------------------------------------

output$hc_plot_gprs_traffic <- renderHighchart({
    
    highchart() %>% 
        hc_xAxis(categories = plot_data_traffic()$DATE1) %>% 
        hc_add_series(data = plot_data_traffic()$upload,
                      name = "Upload",
                      type = "area") %>% 
        hc_add_series(data = plot_data_traffic()$download,
                      name = "Download",
                      type = "area",
                      dataLabels = list(enabled = TRUE)
                      # ,tooltip = list(pointFormat = "{plot_data_traffic$download_GB} GB")
        ) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
        hc_yAxis(plotLines = list(list(
            value = round(mean(plot_data_traffic()$download, na.rm = TRUE), 0),
            color = "green",
            width = 2,
            dashStyle = "shortdash",
            label = list ( text = 'Average')
        )),
        labels = list(format = '{value} GB')
        ) %>% 
        hc_add_theme(hc_theme_flat()) %>% 
        # hc_add_theme(hc_theme_sandsignika())
        # hc_add_theme(hc_theme_smpl())
        # hc_add_theme(hc_theme_538())
        hc_title(text = "Consumo diario de Dados em Gigabytes, GB") %>% 
        hc_subtitle(text = "Campanha: COVID-19 #EstudeEmCasa") %>% 
        hc_yAxis(title = list(text = "Gigabytes: GB")) %>% 
        hc_exporting(enabled = TRUE)
    
    
})


# General -----------------------------------------------------------
output$hc_plot_gprs_traffic_general <- renderHighchart({
    
    highchart() %>% 
        hc_xAxis(categories = plot_data_traffic_general()$DATE1) %>% 
        hc_add_series(data = plot_data_traffic_general()$upload,
                      name = "Upload",
                      type = "area") %>% 
        hc_add_series(data = plot_data_traffic_general()$download,
                      name = "Download",
                      type = "area",
                      dataLabels = list(enabled = TRUE)
                      # ,tooltip = list(pointFormat = "{plot_data_traffic$download_GB} GB")
        ) %>% 
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
        hc_yAxis(plotLines = list(list(
            value = round(mean(plot_data_traffic_general()$download, na.rm = TRUE), 0),
            color = "green",
            width = 2,
            dashStyle = "shortdash",
            label = list ( text = 'Average')
        )),
        labels = list(format = '{value} TB')
        ) %>% 
        hc_add_theme(hc_theme_flat()) %>% 
        # hc_add_theme(hc_theme_sandsignika())
        # hc_add_theme(hc_theme_smpl())
        # hc_add_theme(hc_theme_538())
        hc_title(text = "Consumo diario de Dados: Geral") %>% 
        hc_subtitle(text = "em Terabytes (TB)") %>% 
        hc_yAxis(title = list(text = "Terabytes: TB")) %>% 
        hc_exporting(enabled = TRUE)
    
    
})



