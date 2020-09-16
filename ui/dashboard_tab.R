tabText1 <- "Raw denim you probably haven't heard of them jean shorts Austin. 
            Nesciunt tofu stumptown aliqua, retro synth master cleanse. Mustache 
            cliche tempor, williamsburg carles vegan helvetica. Reprehenderit 
            butcher retro keffiyeh dreamcatcher synth. Raw denim you probably 
            haven't heard of them jean shorts Austin. Nesciunt tofu stumptown 
            aliqua, retro synth master cleanse"


dashboard_tab <- bs4TabItem(
    tabName = "dashboard",
    uiOutput("dashboardUI") %>% withSpinner()
    # tabText1
)
