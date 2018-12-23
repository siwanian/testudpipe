#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
options(shiny.maxRequestSize=30*1024^2)

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  Dataset <- reactive({
    if (is.null(input$file)) { return(NULL) } 
    else{
      Data <- readLines(input$file$datapath)
      Data <- str_replace_all(Data,"<.*?>","")
      Data <- Data[Data!= ""]
      return(Data)
    }
  })
  
  lmodel <- reactive(
    {mlang = textOutput(input$lang)
    lmodel = udpipe_download_model(language = mlang, overwrite = FALSE)
    return(lmodel)}
  )
  
  
  model = reactive({
    model = udpipe_load_model(lmodel)
    return(model)
  })
  annot.obj = reactive({
    x <- udpipe_annotate(model(),x=Dataset())
    x <- as.data.frame(x)
    return(x)
  })
  output$downloadData <- downloadHandler(
    filename = function(){
      "annotated_data.csv"
    },
    content = function(file){
      write.csv(annot.obj()[,-4],file,row.names = FALSE)
    }
  )
  output$antd = renderDataTable({
    if(is.null(input$file)){ return (NULL)}
    else {
      out = annot.obj()[,-4]
      return(out)
    }
  })
  
  output$plot0 = renderPlot({
    if(is.null(input$file)){ return (NULL)}
    else {
      all_adjectives = annot.obj() %>% subset(., xpos %in% "JJ")
      top_adjectives = txt_freq(all_adjectives$lemma)
      wordcloud(top_adjectives$key,top_adjectives$freq, min.freq = 3, colors = 1:10)
    }
  })
  output$plot1 = renderPlot({
    if(is.null(input$file)){ return (NULL)}
    else {
      all_nouns = annot.obj() %>% subset(., xpos %in% "NN")
      top_nouns = txt_freq(all_nouns$lemma)
      wordcloud(top_nouns$key,top_nouns$freq, min.freq = 3, colors = 1:10)
    }
  })
  output$plot2 = renderPlot({
    if(is.null(input$file)){ return (NULL)}
    else {
      all_proper_noun = annot.obj() %>% subset(., xpos %in% "NNP")
      top_proper_noun = txt_freq(all_proper_noun$lemma)
      wordcloud(top_proper_noun$key,top_proper_noun$freq, min.freq = 3, colors = 1:10)
    }
  })
  output$plot3 = renderPlot({
    if(is.null(input$file)){ return (NULL)}
    else {
      co_occ <- cooccurrence(
        x = subset(annot.obj(), xpos %in% input$xpos),
        term = 'lemma',
        group = c("doc_id","paragraph_id","sentence_id"))
      wordnet <- head(co_occ, 50)
      wordnet <- igraph::graph_from_data_frame(wordnet)
      ggraph(wordnet, layout = 'fr')+
        geom_edge_link(aes(width = cooc,edge_alpha = cooc), edge_colour = "orange")+
        geom_node_text(aes(label = name),col = "darkgreen",size = 4)+
        theme_graph(base_family = "Arial Narrow")+
        theme(legend.position = "none")+
        labs(title = " Cooccurrences Plot", subtitle = "  Co-occurence graph of selected" )
    }
  })
})