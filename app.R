library(shiny)
options(shiny.host = '127.0.0.1')
options(shiny.port = 8050)

# Define UI for miles per gallon app ----
ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("Docker Shiny Example"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(),
  
  # Main panel for displaying outputs ----
  mainPanel()
)

# Define server logic to plot various variables against mpg ----
server <- function(input, output) {
  
}

shinyApp(ui, server)
