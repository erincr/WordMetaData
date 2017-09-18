if(!require("shiny")) install.packages("shiny")
if(!require("shinyFiles")) install.packages("shinyFiles")
library(shiny)
library(shinyFiles)

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Shiny Text"),
  
  # dir
  sidebarPanel(
    shinyDirButton("dir", "Choose directory", "Extract metadata"),
    br(),
    br(),
    downloadButton('downloadData', 'Download Data')
  ),
  
  mainPanel(
    dataTableOutput("present")
  )
))
