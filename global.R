
# Guillaume Lobet - University of Liege
  
  
  if (!require("visNetwork",character.only = TRUE)){
    devtools::install_git('https://github.com/dataknowledge/visNetwork')
  }
  
  packages <- c("plyr", "rjson", "RCurl")
  for(p in packages){
    if (!require(p,character.only = TRUE)){
      install.packages(p,dep=TRUE)
      if(!require(p,character.only = TRUE))stop("Package not found")
    }
  }
  
  