library(rvest)
library(magrittr)

###### Setting ######
# exmple package : bcROCsurface
target_packageName <- "bcROCsurface"

# Download directory
dr <- "C:/zips/"

# Repository
# CRAN main(r-realese): https://cran.r-project.org/bin/windows/contrib/3.4/
# Korea Seoul 1 mirror(r-realese):
repo <- "http://cran.nexr.com/bin/windows/contrib/3.4/"
###### ####### ######

packages <<- c(target_packageName)
zips <<- character()

addPackages <- function(pkg_name) {
  address <- paste0("https://cran.r-project.org/web/packages/", paste0(pkg_name, "/index.html"))
  doc <- read_html(address)
  tds <- doc %>% html_nodes("table") %>% html_nodes("td")
  
  for ( i in 1:(tds %>% length()) ) {
    td <- tds %>% extract(i) %>% html_text()
    if ( td == "Imports:") {
      import_pkgs <- tds %>% extract(i+1) %>% html_nodes("a")
      
      for ( pkg in import_pkgs ) {
        pkg_txt <- pkg %>% html_text()
        if ( ! pkg_txt %in% packages ) {
          packages <<- c(packages, pkg_txt)
          addPackages(pkg_txt)
        }
      }
    }
    else if ( td == "Depends:") {
      import_pkgs <- tds %>% extract(i+1) %>% html_nodes("a")
      
      for ( pkg in import_pkgs ) {
        pkg_txt <- pkg %>% html_text()
        if ( ! pkg_txt %in% packages ) {
          packages <<- c(packages, pkg_txt)
          addPackages(pkg_txt)
        }
      }
    }
    else if ( grepl ("r-release: ", tds %>% extract(i) %>% html_text()) ) {
      rvec <- strsplit(tds %>% extract(i) %>% html_text(), ", ")
      zips <<- c(zips, gsub("r-release: ", "", rvec[[1]] [ grepl("r-release: ", rvec[[1]]) ] ))
      break
    }
  }
}


addPackages(target_packageName)


print(packages)
print(zips)

dir.create(dr, showWarnings = FALSE)
for ( zip in zips) {
  if( !file.exists(paste0(dr,zip)) )
    download.file(paste0(repo, zip), paste0(dr,zip))
  else
    cat(zip, " : exists", '\n')
}
