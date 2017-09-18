if(!require("shiny")) install.packages("shiny")
if(!require("shinyFiles")) install.packages("shinyFiles")
library(shiny)
library(shinyFiles)
library(XML)

# SOURCE https://www.r-bloggers.com/microsoft-office-metadata-with-r/

FAILED <- function(doclocation){
  return(list(filename = doclocation, 
              time     = 0,
              words    = 0,
              pages    = 0))
}

getOneTime <- function(docLocation){
  d = suppressWarnings(unzip(docLocation,'docProps/app.xml'))
  if(length(d) == 0) return( FAILED(docLocation) )

  doc = xmlInternalTreeParse(unzip(docLocation,'docProps/app.xml'))
  doc = xmlToList(doc)
  
  if(length(doc) == 0){ FAILED(docLocation) }
  
  t = list(filename = docLocation, 
           time = as.numeric(doc$TotalTime),
           words = as.numeric(doc$Words),
           pages = as.numeric(doc$Pages)
           )
  return(t)
}


getAllTimesInDirectory <- function(directoryLocation){
  fileList = list.files(path = directoryLocation, pattern = "\\.docx", recursive = TRUE, full.names=T)
  results  = lapply(fileList, getOneTime)
  
  return(data.frame(filename = sapply(results, function(x) x$filename),
             time     = sapply(results, function(x) x$time),
             words    = sapply(results, function(x) x$words),
             pages    = sapply(results, function(x) x$pages)))
}

shinyServer(function(input, output) {
  
  # dir
  shinyDirChoose(input, 'dir', roots = c(home = '\\Users'))
  dir <- reactive(input$dir)
  output$dir <- renderPrint(dir())
  
  # path
  path <- reactive({
    home <- '\\Users'
    file.path(home, paste(unlist(dir()$path[-1]), collapse = .Platform$file.sep))
  })
  
  output$path <- renderPrint(path())
  
  res <- reactive({getAllTimesInDirectory(path())})
  
  output$present <- renderDataTable({
    res()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { 'file_sizes.csv' }, content = function(file) {
      write.csv(res(), file, row.names = FALSE)
    }
  )
})
