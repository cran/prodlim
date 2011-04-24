# {{{ SmartControl 
SmartControl <- function(call,
                         keys,
                         ignore,
                         defaults,
                         forced,
                         split,
                         ignore.case=TRUE,
                         replaceDefaults,
                         verbose=TRUE)
  # }}}
{
  if (missing(split)) split <- "\\."
  # {{{ set up argument list 
  SmartArgs <- as.list(call)
  SmartArgs <- SmartArgs[names(SmartArgs)!=""]
  if (ignore.case==TRUE){
    names(SmartArgs) <- tolower(names(SmartArgs))
  }
  # }}}

  # {{{remove ignorable arguments
  if (!missing(ignore) && is.character(ignore)){
    if (ignore.case==TRUE){
      ignore <- tolower(ignore)
    }
    SmartArgs <- SmartArgs[match(names(SmartArgs),
                                 ignore,
                                 nomatch=0)==0]
  }
  if (verbose==TRUE){
    allKeysRegexp <- paste("^",keys,split,sep="",collapse="|")
    notIgnored <- grep(allKeysRegexp,names(SmartArgs),val=FALSE,ignore.case=TRUE)
    Ignored <- names(SmartArgs)[-notIgnored]
    SmartArgs <- SmartArgs[notIgnored]
    if (length(Ignored)>0){
      paste(Ignored,collapse=", ")
      warning(paste("The following argument(s) are not smart and therefore ignored: ",paste(Ignored,collapse=", ")))
    }
  }
  # }}}
  # {{{ default arguments
  DefaultArgs <- vector(mode="list",length=length(keys))
  names(DefaultArgs) <- keys
  if (!missing(defaults)){
    whereDefault <- match(names(defaults),names(DefaultArgs),nomatch=0)
    if (all(whereDefault))
      DefaultArgs[whereDefault] <- defaults
    else
      stop("Could not find the following default arguments: ",paste(names(defaults[0==whereDefault]),","))
  }
  if (!missing(replaceDefaults)){
    if (length(replaceDefaults)==1){
      replaceDefaults <- rep(replaceDefaults,length(keys))
      names(replaceDefaults) <- keys
    }
    else {
      stopifnot(length(replaceDefaults)==length(keys))
      stopifnot(all(match(names(replaceDefaults),keys)))
      replaceDefaults <- replaceDefaults[keys]
    }
  }
  else{
    replaceDefaults <- rep(FALSE,length(keys))
    names(replaceDefaults) <- keys
  }
  

  # }}}
  # {{{ forced arguments
  keyForced <- vector(mode="list",length=length(keys))
  names(keyForced) <- keys
  if (!missing(forced)){
    whereDefault <- match(names(forced),names(keyForced),nomatch=0)
    if (all(whereDefault))
      keyForced[whereDefault] <- forced
    else stop("Not all forced arguments found.")
  }
  # }}}
  # {{{ loop over keys
  keyArgList <- lapply(keys,function(k){
    keyRegexp <- paste("^",k,split,sep="")
    foundArgs <- grep(keyRegexp,names(SmartArgs),val=TRUE,ignore.case=TRUE)
    if (length(foundArgs)>0){
      keyArgs <- SmartArgs[foundArgs]
      if (ignore.case)
        argNames <- sapply(strsplit(tolower(names(keyArgs)),tolower(keyRegexp)),function(x)x[[2]])
      else
        argNames <- sapply(strsplit(names(keyArgs),keyRegexp),function(x)x[[2]])
      
      keyArgs <- lapply(keyArgs,function(x){
        ## expressions for arrow labels in plot.Hist
        ## cannot be evaluated at this point
        ## if the expression is communicated
        ## more than one level higher
        maybeFail <- try(e <- eval(x),silent=TRUE)
        if (class(maybeFail)=="try-error")
          x
        else
          eval(x)
      })
      names(keyArgs) <- argNames
    }
    else{
      keyArgs <- NULL
    }
    # }}}
  # {{{ prepending the forced arguments-----------------
  if (length(keyForced[[k]])>0){
      keyArgs <- c(keyForced[[k]],keyArgs)
    }
    # }}}
  # {{{ appending default arguments
    if (length(DefaultArgs[[k]])>0 && replaceDefaults[k]==FALSE){
      keyArgs <- c(keyArgs,DefaultArgs[[k]])
    }
    # }}}
  # {{{ removing duplicates
    keyArgs[!duplicated(names(keyArgs))]
  })
  
  names(keyArgList) <- keys
  keyArgList
  # }}}
}