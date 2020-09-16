tabText2 <- "Cosby sweater eu banh mi, qui irure terry richardson ex squid. 
            Aliquip placeat salvia cillum iphone. Seitan aliquip quis cardigan 
            american apparel, butcher voluptate nisi qui."


campanhas_tab <- bs4TabItem(
    tabName = "campanhas",
    uiOutput("campaignUI") %>% withSpinner()
    # tabText2
)