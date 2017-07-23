library(rvest)
library(magrittr)

# exmple package : ggplot2
target_packageName <- "ggplot2"


packages <<- c(target_packageName)
zips <<- character()

addPackages <- function(pkg_name) {
  address <- paste0("https://cran.r-project.org/web/packages/", paste0(pkg_name, "/index.html"))
  doc <- read_html(address)
  tds <- doc %>% html_nodes("table") %>% html_nodes("td")
  
  flag <- TRUE
  for ( i in 1:(tds %>% length()) ) {
    if ( flag && tds %>% extract(i) %>% html_text() == "Imports:") {
      import_pkgs <- tds %>% extract(i+1) %>% html_nodes("a")
      
      for ( pkg in import_pkgs ) {
        pkg_txt <- pkg %>% html_text()
        if ( ! pkg_txt %in% packages ) {
          packages <<- c(packages, pkg_txt)
          addPackages(pkg_txt)
        }
      }
      flag <- FALSE
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

dir.create("zips", showWarnings = FALSE)
for ( zip in zips) {
  if( !file.exists(paste0("zips/",zip)) )
    download.file(paste0("https://cran.r-project.org/bin/windows/contrib/3.4/", zip), paste0("zips/",zip))
  else
    cat(zip, " : exists", '\n')
}
