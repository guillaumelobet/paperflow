# PaperFlow

PaperFlow display your publication in network fashion, making sense of your scientific journey. PaperFlow was created by [Guillaume Lobet](http://www.guillaumelobet.be).

## Required libraries

- [visNetwork](http://dataknowledge.github.io/visNetwork/)
		
		devtools::install_git('https://github.com/dataknowledge/visNetwork')
  
- [plyr](http://cran.r-project.org/web/packages/plyr/index.html)
- [rjson](http://cran.r-project.org/web/packages/rjson/index.html)
- [RCurl](http://cran.r-project.org/web/packages/RCurl/index.html)

## Install and run PaperFlow

Run the following command in your R console:

	library(shiny)
	shiny::runGitHub("guillaumelobet/paperflow", "guillaumelobet") 
	
	
