dimColor <- function(x,density=55){
  ccrgb=as.list(col2rgb(1,alpha=TRUE))
  names(ccrgb) <- c("red","green","blue","alpha")
  ccrgb$alpha=density
  do.call("rgb",c(ccrgb,list(max=255)))
}