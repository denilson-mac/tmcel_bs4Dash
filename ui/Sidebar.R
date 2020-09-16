Sidebar <- bs4DashSidebar(
    skin = "light",
    status = "primary",
    title = "Dashboard",
    brandColor = "primary",
    # url = "https://www.google.fr",
    # src = "https://adminlte.io/themes/AdminLTE/dist/img/user2-160x160.jpg",
    url = "http://www.tmcel.mz/",
    src = "tmcel_logo.jpg",
    elevation = 3,
    opacity = 0.8,
    bs4SidebarUserPanel(
        img = "https://image.flaticon.com/icons/svg/1149/1149168.svg", 
        text = "Welcome Onboard!"
    ),
    bs4SidebarMenu(
        bs4SidebarHeader("Menu Principal"),
        bs4SidebarMenuItem(
            "Dashboard",
            tabName = "dashboard",
            # icon = ionicon(name = "desktop-outline")
            icon = "desktop"
        ),
        bs4SidebarMenuItem(
            "Campanhas",
            tabName = "campanhas",
            icon = "id-card"
    )
)
)