# Guillaume Lobet - University of Liege


# PaperFlow


library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel(h1("- PaperFlow -")),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      #h4("Model Assisted Root Image Analysis"),
      helpText("PaperFlow display your publication in network fashion, making sense of your scientific journey. PaperFlow was created by Guillaume Lobet."),
      
      helpText("www.guillaumelobet.be"),
      
      tags$hr(),      
      
      selectInput("datasource", label = "Data coming from:",
                  choices = c("CSV", "ImpactStory"), selected = "Excell"),
      
      fileInput('data_file', 'Choose CSV File', accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),

      textInput("username", label = "Username", value = "GuillaumeLobet"),
            
      checkboxInput("authors", label = "Authors network", value = F),
      
      checkboxInput("hierarchical", label = "Hierachical network", value = F),
            
      # Saving the simulation results 
      textInput('dir', value = "~/Desktop/", label = "Were you want to save your network"),
      checkboxInput("save", label = "Save network as an HTML file", value = F),
      
      actionButton(inputId = "runPaperFlow", label="Unleash PaperFlow"),
      
      tags$hr(),
      
      img(src = "paperflow_icon.png", width = 200)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(     
        tabPanel("PaperFlow Network",
                 visNetworkOutput("visnetwork"),
                value=1
        ),
        id="tabs1"
      )
    )
  )
))