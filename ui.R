library("shiny")

shinyUI(
  fluidPage(
    
    titlePanel("UDPipe NLP workflow"),
    
    sidebarLayout( 
      
      sidebarPanel(  
        
        fileInput("file",label = "Upload text file"),
        
        checkboxGroupInput("xpos", 
                           label = h3("Select XPOS elements for analysis"),
                           choices = list("adjective" = "JJ",
                                          "noun" = "NN",
                                          "proper noun" = "NNP",
                                          "adverb"= "RB",
                                          "verb" = "VB"),
                           selected = c("JJ","NN","NNP")
        ),
        
        textInput("lang",label="type language for udpipe")
        
      ),# end of sidebar panel
      
      
      mainPanel(
        
        tabsetPanel(type = "tabs",
                    
                    tabPanel("Overview",
                             br(),
                             p("UDPipe NLP Workflow "),
                             br(),
                             h4('How to use this App'),
                             p("Please upload a text file from the left side panel by clicking on browse button"),
                             h4('Hint'),
                             p(span(strong(" 1) Smaller files should be used as big files sometime create problem"))),
                             p(span(strong(" 2) Upload the documents and wait till completion",align="justify")))
                    ),
                    
                    tabPanel("annotated documents",
                             dataTableOutput('antd'),
                             br(),
                             br(),
                             downloadButton("downloadData","Download Annotated Data")),
                    tabPanel("Word Cloud Plots", 
                             h3("Adverbs"),
                             plotOutput('plot0'),
                             h3("Nouns"),
                             plotOutput('plot1'),
                             h3("Proper Nouns"),
                             plotOutput('plot2')),         
                    tabPanel("Co-ocuurrence graphs",
                             plotOutput('plot3')
                    )
        )# end of tabsetPanel
      ) # end of main panel
    )# end of sidebarLayout
  ) # end if fluidPage
) # end of UI