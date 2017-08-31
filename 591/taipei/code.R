library("rvest");
library("httr");
##  Crawling 591 taipei houses information
WebUrl     <- "https://rent.591.com.tw/new/?kind=0&region=1";
NewestHouseIndex <- 
  read_html(WebUrl) %>% html_nodes(".pageBreak+ .pageNum-form") %>%
  html_attr(name = "data-total") %>% as.numeric();
## All 591-rent page-index have 30 houses-index.
AllPageIndex  <- seq(0, NewestHouseIndex, 30);
## All 591-rent page-index urls
AllPageIndexUrls <- paste(
  "https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=1&firstRow=",
  AllPageIndex,
  "&totalRows=",
  NewestHouseIndex,
  sep=''
  );
##  Using the newest 2 page-index to demo
PageIndexUrls <- tail(AllPageIndexUrls,2)
##  House index urls
HouseIndexUrls <- lapply(PageIndexUrls,function(x){
  ##  det: detail
  det <- GET(x) %>% content();
  det <- det$data$data;
  id  <- lapply(det, function(d) d$post_id);
  
  ## u: each house-index urls
  u <- paste("https://rent.591.com.tw/rent-detail-",id,".html",sep='');
  return(u)
})
HouseIndexUrls <- unlist(HouseIndexUrls);
# > head(HouseIndexUrls);
# [1] "https://rent.591.com.tw/rent-detail-5464829.html"
# [2] "https://rent.591.com.tw/rent-detail-5464734.html"
# [3] "https://rent.591.com.tw/rent-detail-5464502.html"
# [4] "https://rent.591.com.tw/rent-detail-4886898.html"
# [5] "https://rent.591.com.tw/rent-detail-4354605.html"
# [6] "https://rent.591.com.tw/rent-detail-5464405.html"
HousesDetails <- list();
N <- length(HouseIndexUrls);
for( i in seq(N) ){
  ##  u: url
  u    <- HouseIndexUrls[i];
  ## try to "read_html", if error, then return error
  html <- tryCatch(read_html(u),error = function(e) e);
  ## if not error, then continuous
  if(class(html)[2] != "error"){
    ## Address and title
    AddressTitle <- html_nodes(html,".addr , .houseInfoTitle") %>% html_text();
    AddressTitle <- data.frame("Address" = AddressTitle[1], "Title" = AddressTitle[2]);
    show(AddressTitle)
    ## if title is not NULL
    if(dim(AddressTitle)[2]==2){
    price <- html_nodes(html,".price i") %>% html_text();
    price <- unlist(strsplit(gsub(",","",price),split = " "));
    price <- t(data.frame(price[1], row.names = price[2]));
    row.names(price) <- NULL;
    show(price)
    type <- html_nodes(html,".attr li") %>% html_text();
    type <- gsub("\\s","",type);
    type <- strsplit(type,split = ":",);
    type <- lapply(
      type,
      function(x){
        ##  o: output
        o <- t(data.frame(x[2], row.names = x[1]));
        row.names(o) <- NULL;
        return(o)
      }
    )
    type <- do.call("cbind",type);
    show(type);
    other            <- html_nodes(html,".two em") %>% html_text();
    names(other)     <- gsub(" ","",
                             html_nodes(html,".one") %>% html_text());
    other            <- t(data.frame(other));
    row.names(other) <- NULL;
    show(other)
    details <- data.frame(AddressTitle, price, type, other);
    #colnames(x.detail) <- gsub(".U.00A0.","",colnames(x.detail));
    #colnames(x.detail) <- gsub("\\.","/",colnames(x.detail));
    HousesDetails[[i]] <- details
    }
  }
}
HousesDetails        <- Reduce( function(x, y) merge(x, y, all = T), HousesDetails );
HousesDetails        <- data.frame(HousesDetails);
head(HousesDetails)
