# PaperFlow

PaperFlow display your publication in network fashion, making sense of your scientific journey. PaperFlow was created by [Guillaume Lobet](http://www.guillaumelobet.be).

## Required libraries

- visNetwork
		
		devtools::install_git('https://github.com/dataknowledge/visNetwork')
  
- plyr
- rjson
- RCurl

## Install and run PaperFlow

Run the following command in your R console:

	library(shiny)
	runGitHub("guillaumelobet/paperflow", "guillaumelobet") 
	
	
