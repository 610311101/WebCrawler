require("httr");
require("rvest");
require("XML");
x            <- "https://www.ptt.cc/bbs/Gossiping/index.html";
x.GET        <- GET(x,set_cookies("over18"="1"));
x.content    <- content(x.GET);
x.nodes      <- html_nodes(x.content,".wide:nth-child(2)");
x.href       <- html_attr(x.nodes,"href");
## the newest page index 
x.index      <- as.numeric(gsub("[^0-9]","",x.href)) + 1;
x.index

page.url <- paste("https://www.ptt.cc/bbs/Gossiping/index",1:x.index,".html",sep='');
##  show the newest 6 page url
tail(page.url)

##  use the newest 6 page url for example
page.index <- gsub("https://www.ptt.cc/bbs/Gossiping/||.html","",tail(page.url));
text.url <- lapply(tail(page.url),function(x){
  x     <- GET(x,set_cookies("over18"="1"));
  x     <- content(x);
  x     <- html_nodes(x,".title a");
  x     <- html_attr(x,"href");
  x.url <- paste("https://www.ptt.cc",x,sep="");
  return(x.url)
})
names(text.url) <- page.index;
##  show each text url in the newest 6 page url.
str(text.url,vec.len = 1, nchar.max = 6);

text.list <- lapply(text.url,function(x1){
  x2.index <- gsub("https://www.ptt.cc/bbs/Gossiping/||.html","",x1)
  x2.text  <- lapply(x1,function(x2){
    x2       <- GET(x2,set_cookies("over18"="1"));
    x2       <- content(x2,"text");
    x2       <- htmlParse(x2);
    x2.text  <- xpathSApply(x2,"//div[@id='main-content']",xmlValue);
    return(x2.text)
  })
  names(x2.text) <- x2.index;
  return(x2.text)
})
##  [[2]][[7]] is the 7th text of the 2nd page index. 
pander(text.list[[2]][7]);
