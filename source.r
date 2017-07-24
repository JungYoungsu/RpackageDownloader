###### Setting ######
# Target packages (1~n) : (example) bcROCsurface, ggplot2
target_packages <- c("bcROCsurface", "ggplot2")

# Download directory
dr <- "C:/zips/"

# Repository
# CRAN main(r-realese): https://cran.r-project.org/bin/windows/contrib/3.4/
# Korea Seoul 1 mirror(r-realese):
repo <- "http://cran.nexr.com/bin/windows/contrib/3.4/"
###### ####### ######

list.of.packages <- c("rvest", "magrittr")
new.packages <- list.of.packages[!(list.of.packages 
                                   %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(rvest)
library(magrittr)

packages <<- c(target_packages)
zips <<- character()

addPackages <- function(pkg_name) {
  doc <- read_html(paste0("https://cran.r-project.org/web/packages/"
                          , paste0(pkg_name, "/index.html")))
  tds <- doc %>% html_nodes("table") %>% html_nodes("td")
  
  for ( i in 1:(tds %>% length()) ) {
    td <- tds %>% extract(i) %>% html_text()
    if ( td == "Imports:" || td == "Depends:") {
      import_pkgs <- tds %>% extract(i+1) %>% html_nodes("a")
      
      for ( pkg in import_pkgs ) {
        pk <- pkg %>% html_text()
        if ( ! pk %in% packages ) {
          packages <<- c(packages, pk)
          addPackages(pk)
        }
      }
    }
    else if ( grepl ("r-release: ", td) ) {
      rvec <- strsplit(td, ", ")
      zips <<- c(zips, gsub("r-release: ", "",
                            rvec[[1]] [ grepl("r-release: ", rvec[[1]]) ] ))
      break
    }
  }
}

for ( pk in target_packages ) {
  addPackages(pk)
}


print(packages)
print(zips)

dir.create(dr, showWarnings = FALSE)
for ( zip in zips) {
  if( !file.exists(paste0(dr,zip)) )
    download.file(paste0(repo, zip), paste0(dr,zip))
  else
    cat(zip, " : exists", '\n')
}

print("END")
