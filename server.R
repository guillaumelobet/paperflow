# Guillaume Lobet - University of Liege


# PaperFlow


shinyServer(
  
  function(input, output) {
    
    #------------------------------------------------------
    # LOAD THE USER DATA
    
    Data <- reactive({
      if(input$datasource != "ImpactStory"){
        inFile <- input$data_file   
        if (is.null(inFile)) return(NULL)
        data <- read.csv(inFile$datapath, sep=";")  
        return(data)
      }else{
        return(NULL)
      }
    })   
    
    #------------------------------------------------------
    # PROCESS THE DATA
    
    Results <- reactive({
      
      if(input$runPaperFlow == 0){return()}

      if(exists("network")){
        if(!is.null(network) & input$save){
          htmlwidgets::saveWidget(network, paste(input$dir,"/",input$username,"_network.html", sep=""))
          return(network)
        }
      }
      
      authors <- F
      merge <- F
    
      # Get the data from an impactstory profile
      if(input$datasource == "ImpactStory"){
        
        rs <- data.frame(authors="", first_author="", title="", journal="", 
                         month=0, year=0, volume=0, pages="",citations=0,key1="")
        path <- paste("https://impactstory.org/profile/",input$username,".json", sep="")
        
        tryCatch({          
          if(exists("products")){
            if(is.null(products) || input$username != usr){
              f <- getURL(path, verbose = F)
              data <- fromJSON(f)      
              products <<-data$products
              usr <<- input$username
            }
          }else{
            f <- getURL(path, verbose = F)
            data <- fromJSON(f)      
            products <<-data$products
          }
          
          for(i in 1:length(products)){
            prod <- products[i][[1]]
            if(!is.null(prod$biblio$calculated_genre)){
              if(prod$biblio$calculated_genre == 'article'){
                
                title <- prod$biblio$display_title
                authors <- gsub(";", ",", prod$biblio$authors)
                fauthor <- strsplit(authors, ",")[[1]][1]
                year <- as.numeric(prod$biblio$display_year)
                date <- prod$biblio$date
                if(!is.null(date)){
                  month <- as.numeric(strsplit(date, "-")[[1]][2])
                }else{
                  month <- 1
                }
                journal <- prod$biblio$journal
                if(is.null(journal)) journal=""
                keywords <- gsub(";", ",", prod$biblio$keywords)
                if(length(keywords) == 0) keywords <- "1"
                
                # metrics
                cites <- 0
                awards <- prod$awards;
                for(aw in awards){  
                  metrics <- aw$metrics;
                  for(met in metrics){	
                    # Scopus citations
                    if(met$display_provider == 'Scopus'){
                      cites <- met$display_count; 
                    }
                  }
                }
                temp <- data.frame(authors=authors, first_author=fauthor, title=title, 
                                   journal=journal, month=month, year=year, volume=0, pages="",
                                   citations=cites,key1=keywords)
                rs <- rbind(rs, temp)        
              }
            }
          }
          rs$key2 <- "A"
          rs <- rs[2:nrow(rs),]
          
        }, warning = function(w) {
          message("ImpactStory profile could not be retrieved. Please check you username and internet connection")
          print(w)
          return(w)
        }, error = function(e) {
          message("ImpactStory profile could not be retrieved. Please check you username and internet connection")
          print(e)
          return(e)
        })
      }else{
        rs <- Data()
      }
      
      rs <- rs[order(rs$year, rs$month),]
      #format title
      rs$title <- as.character(rs$title)
      for(i in 1:nrow(rs)){
        ti <- strsplit(rs$title[i], " ")[[1]]
        ti_string <- ""
        c <- 0
        for(t in ti){
          c <- c+1
          sep <- " "
          if(c == 6){
            sep <- "</br>"
            c <- 0
          }
          ti_string <- paste(ti_string, sep, t, sep="")
        }
        rs$title[i] <- ti_string
      }
      
      rs$id <- c(1:nrow(rs))
      rs$name <- paste(rs$first_author," et al, ",rs$year,sep="")
      rs$full_name <- paste(rs$first_author," et al, ",rs$year,"</br> ",rs$journal,", ", 
                            rs$volume, ", ",rs$pages,"</br>",rs$title,
                            "<hr>Citations:",rs$citations,
                            "</br>Keywords: ", rs$key1, sep="")
      
      rs$key1 <- as.character(rs$key1)
      rs$key2 <- as.character(rs$key2)
      rs$authors <- gsub(" ","",as.character(rs$authors))
      
      if(!input$authors){
        # Connections table
        temp <- NULL
        for(i in 1:nrow(rs)){
          key <- strsplit(x = gsub(";",",",rs$key1[i]), ",")[[1]]
          for(k in key){
            k <- gsub(" ","",k)
            temp <- rbind(temp, data.frame(id=rs$id[i], year=rs$year[i], month=rs$month[i], key=k))
          }
        }
      }else{
        # Connections table
        temp <- NULL
        for(i in 1:nrow(rs)){
          key <- strsplit(x = rs$authors[i], ",")[[1]]
          for(k in key){
            temp <- rbind(temp, data.frame(id=rs$id[i], year=rs$year[i], month=rs$month[i], key=k))
          }
        }
      } 
      
      
      temp <- temp[order(temp$year, temp$month),]
      temp$key <- gsub(" ","",temp$key)
      conns = NULL
      for(i in 1:nrow(temp)){
        to = NULL
        if(i < nrow(temp)){
          for(j in (i+1):nrow(temp)){
            if(temp$id[j] != temp$id[i] & (grepl(temp$key[i], temp$key[j]) | grepl(temp$key[j], temp$key[i]))){
              to = temp$id[j]
              break
            }
          }
        }
        if(!is.null(to)) conns = rbind(conns, data.frame(from=temp$id[i], to=to,key=temp$key[i]))
      }
      
      nodes <- data.frame(id = rs$id, label=rs$name, group=rs$key2, title=rs$full_name, value=rs$citations)
      edges <- data.frame(from = conns$from, to = conns$to, title=conns$key)
      
      if(!input$hierarchical){
        network <<- visNetwork(nodes, edges, width = "100%", legend=T) %>% 
          visEdges(arrow = "to") %>%
          visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
      }else{      
        network <<- visNetwork(nodes, edges, width = "100%", legend=T) %>% 
          visEdges(arrow = "to") %>%
          visHierarchicalLayout() %>%          
          visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
      }

    })
  
    
    # Plot the different growth factors
    output$visnetwork <- renderVisNetwork({
      if(input$runPaperFlow == 0){return()}
      Results()
    })
       
    
  }
)