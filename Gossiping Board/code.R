require("httr");
require("rvest");
require("XML");
library("pander");
library("magrittr");
WebUrl   <- "https://www.ptt.cc/bbs/Gossiping/index.html";
## The newest page index 
NewestPageIndex <- WebUrl %>% GET(set_cookies("over18"="1")) %>% content() %>% 
  html_nodes(".wide:nth-child(2)") %>% html_attr("href");
NewestPageIndex <- as.numeric(gsub("[^0-9]","",NewestPageIndex)) + 1;
## All page index urls
AllPageIndexUrls <- paste("https://www.ptt.cc/bbs/Gossiping/index",
                      1:NewestPageIndex,
                      ".html", sep='');
## Using 2 page index urls to demo
PageIndexUrls <- tail(AllPageIndexUrls, 10000);
PageTextUrls <- 
  lapply(
    PageIndexUrls, 
    function(x){
      ##  u: url
      u <- GET(x,set_cookies("over18"="1")) %>% content() %>%
        html_nodes(".title a") %>% html_attr("href");
      u <- paste("https://www.ptt.cc", u, sep="");
      return(u)
      }
    );
names(PageTextUrls) <- PageIndexUrls;
PageTextUrls        <- unlist(PageTextUrls, use.names = F);
# > head(PageTextUrls)
# [1] "https://www.ptt.cc/bbs/Gossiping/M.1504194827.A.A74.html"
# [2] "https://www.ptt.cc/bbs/Gossiping/M.1504194829.A.D67.html"
# [3] "https://www.ptt.cc/bbs/Gossiping/M.1504194846.A.FB8.html"
# [4] "https://www.ptt.cc/bbs/Gossiping/M.1504194853.A.E6C.html"
# [5] "https://www.ptt.cc/bbs/Gossiping/M.1504194867.A.F1D.html"
# [6] "https://www.ptt.cc/bbs/Gossiping/M.1504194873.A.03E.html"
##  Crawling text 
N        <- length(PageTextUrls);
TextList <- list();
for( i in seq(N) ){
  ##  u: url
  u <- PageTextUrls[i];
  TextList[[i]] <- 
    GET(u, set_cookies("over18"="1")) %>% content("text") %>% 
    htmlParse() %>% xpathSApply("//div[@id='main-content']",xmlValue);
  cat("Crawling",u,"\n")
  Sys.sleep(0.5)
}
# TextList