library(shiny)
library(bs4Dash)
library(tidyverse)
library(shinycssloaders)
# library(argonR)
# library(argonDash)


source(file = 'global.R', local = TRUE)

# ui layout
source(file = "ui/Sidebar.R", local = TRUE)
source(file = "ui/Navbar.R", local = TRUE)


# elements
source(file = "ui/dashboard_tab.R", local = TRUE)
source(file = "ui/campanhas_tab.R", local = TRUE)


shiny::shinyApp(
    ui = bs4DashPage(
        old_school = FALSE,
        sidebar_min = TRUE,
        sidebar_collapsed = FALSE,
        controlbar_collapsed = FALSE,
        controlbar_overlay = TRUE,
        title = "Executive Dashboard",
        # navbar = bs4DashNavbar(),
        navbar = bs4DashNavbar(
            skin = "light",
            # status = "success",
            "Mozambique Telecom - TMCEL"
            ),
        # navbar = dashboardHeader(),
        # navbar = Navbar,
        # sidebar = bs4DashSidebar(),
        sidebar = Sidebar,
        # controlbar = bs4DashControlbar(),
        footer = bs4DashFooter(
            copyrights = a(
                href = "https://reinaldozezela.netlify.com/", 
                target = "_blank", "@ReinaldoZezela"
            ),
            right_text = "2020"
        ),
        # body = bs4DashBody()
        body = bs4DashBody(
            bs4TabItems(
                dashboard_tab,
                campanhas_tab
                # cards_tab,
                # tables_tab,
                # tabsets_tab,
                # alerts_tab,
                # images_tab,
                # items_tab,
                # effects_tab,
                # sections_tab
            )
        ),
    ),
    server = function(input, output) {
        
        # dashboardUI
        source(file = "server/01_svr_dashboard.R", local = TRUE)
        
        source(file = "server/02_svr_campaign.R", local = TRUE)
    }
)