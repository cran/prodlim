#' @export
lifeTab.competing.risks <- function(object,
                                    times,
                                    cause,
                                    newdata,
                                    stats,
                                    intervals=FALSE,
                                    percent=TRUE,
                                    format,...){
    # {{{---------get the indices--------------------------
    IndeX <- predict(object,newdata=newdata,level.chaos=0,times=times,type="list")
    # }}}
    # {{{--------------times-------------------------------
    times <- IndeX$times
    Ntimes <- IndeX$dimensions$time
    pindex <- IndeX$indices$time
    delayed <- attr(object$model.response,"entry.type")=="leftTruncated"
    # }}}
    # {{{---------covariate strata--------------------------
    Nstrata <- IndeX$dimensions$strata
    findex <- IndeX$indices$strata
    # }}}
    # {{{---------competing causes--------------------------
    if (missing(cause)){
        causes <- attributes(object$model.response)$states
    } else{
        causes <- checkCauses(cause,object)
    }
    # }}}
    # {{{--------------stats-------------------------------
    if (missing(stats) || (!missing(stats) && is.null(stats)))
        stats <- list(c("n.event",0),c("n.lost",0))
    else
        stats <- c(list(c("n.event",0),c("n.lost",0)),stats)
    #
    # }}}
    # {{{---------loop over causes--------------------------
    #
    outList <- lapply(causes,function(cc){
        # ---no. at atrisk, events, and censored------------------
        if (intervals==FALSE){
            if (is.null(object$clustervar)){
                ## only one column for n.risk
                xxx <- .C("summary_prodlim",pred.nrisk=integer(Ntimes*Nstrata),pred.nevent=integer(Ntimes*Nstrata),pred.nlost=integer(Ntimes*Nstrata),nrisk=as.integer(object$n.risk),nevent=as.integer(object$n.event[[cc]]),nlost=as.integer(object$n.lost),as.double(times),as.double(object$time),as.integer(object$first.strata[findex]),as.integer(object$size.strata[findex]),as.integer(Nstrata),as.integer(Ntimes),NAOK=FALSE,PACKAGE="prodlim")
                out <- data.frame(cause=cc,n.risk=xxx$pred.nrisk,n.event=xxx$pred.nevent,n.lost=xxx$pred.nlost)
                ## out <- data.frame(n.risk=xxx$pred.nrisk)
            }
            else{
                xxx <- .C("summary_prodlim",pred.nrisk=integer(Ntimes*Nstrata),pred.nevent=integer(Ntimes*Nstrata),pred.nlost=integer(Ntimes*Nstrata),nrisk=as.integer(object$n.risk[,1]),nevent=as.integer(object$n.event[[cc]][,1]),nlost=as.integer(object$n.lost),as.double(times),as.double(object$time),as.integer(object$first.strata[findex]),as.integer(object$size.strata[findex]),as.integer(Nstrata),as.integer(Ntimes),NAOK=FALSE,PACKAGE="prodlim")
                out <- data.frame(cause=cc,n.risk=xxx$pred.nrisk,n.event=xxx$pred.nevent,n.lost=xxx$pred.nlost)
                ## out <- data.frame(n.risk=xxx$pred.nrisk)
                for (cv in 1:length(object$clustervar))
                    yyy <- .C("summary_prodlim",pred.nrisk=integer(Ntimes*Nstrata),pred.nevent=integer(Ntimes*Nstrata),pred.nlost=integer(Ntimes*Nstrata),nrisk=as.integer(object$n.risk[,1+cv]),nevent=as.integer(object$n.event[[cc]][,1+cv]),nlost=as.integer(object$n.lost[,1+cv]),as.double(times),as.double(object$time),as.integer(object$first.strata[findex]),as.integer(object$size.strata[findex]),as.integer(Nstrata),as.integer(Ntimes),NAOK=FALSE,PACKAGE="prodlim")
                outCV <- data.frame(cause=cc,n.risk=yyy$pred.nrisk,n.event=yyy$pred.nevent,n.lost=yyy$pred.nlost)
                ## outCV <- data.frame(n.risk=yyy$pred.nrisk)
                names(outCV) <- paste(object$clustervar,names(outCV),sep=".")
                out <- cbind(out,outCV)
            }
        }
        # }}}
        # {{{-------Intervals---------------------------
        else{
            #,----
            #|      get the no. at risk at the left limit of the interval
            #|      and count events and censored excluding the left limit
            #`----
            start <- min(min(object$time),0)-.1
            lower <- c(start,times[-length(times)])
            upper <- times
            lagTimes <- c(min(min(object$time),0)-.1 , times[-length(times)])
            if (is.null(object$clustervar)){
                ## only one column in n.event and n.risk 
                xxx <- .C("life_table",
                          pred.nrisk=integer(Ntimes*Nstrata),
                          pred.nevent=integer(Ntimes*Nstrata),
                          pred.nlost=integer(Ntimes*Nstrata),
                          nrisk=as.integer(object$n.risk),
                          nevent=as.integer(object$n.event[[cc]]),
                          nlost=as.integer(object$n.lost),
                          as.double(lower),
                          as.double(upper),
                          as.double(object$time),
                          as.integer(object$first.strata[findex]),
                          as.integer(object$size.strata[findex]),
                          as.integer(Nstrata),
                          as.integer(Ntimes),
                          as.integer(delayed),
                          NAOK=FALSE,
                          PACKAGE="prodlim")
                out <- data.frame(cause=cc,n.risk=xxx$pred.nrisk,n.event=xxx$pred.nevent,n.lost=xxx$pred.nlost)
            }
            else{
                xxx <- .C("life_table",
                          pred.nrisk=integer(Ntimes*Nstrata),
                          pred.nevent=integer(Ntimes*Nstrata),
                          pred.nlost=integer(Ntimes*Nstrata),
                          nrisk=as.integer(object$n.risk[,1]),
                          nevent=as.integer(object$n.event[[cc]][,1]),
                          nlost=as.integer(object$n.lost[,1]),
                          as.double(lower),
                          as.double(upper),
                          as.double(object$time),
                          as.integer(object$first.strata[findex]),
                          as.integer(object$size.strata[findex]),
                          as.integer(Nstrata),
                          as.integer(Ntimes),
                          as.integer(delayed),
                          NAOK=FALSE,
                          PACKAGE="prodlim")
                out <- data.frame(cause=cc,n.risk=xxx$pred.nrisk,n.event=xxx$pred.nevent,n.lost=xxx$pred.nlost)
                lagxxx <- .C("life_table",
                             pred.nrisk=integer(Ntimes*Nstrata),
                             pred.nevent=integer(Ntimes*Nstrata),
                             pred.nlost=integer(Ntimes*Nstrata),
                             nrisk=as.integer(object$n.risk[,1]),
                             nevent=as.integer(object$n.event[[cc]][,1]),
                             nlost=as.integer(object$n.lost[,1]),
                             as.double(lagTimes),
                             as.double(object$time),
                             as.integer(object$first.strata[findex]),
                             as.integer(object$size.strata[findex]),
                             as.integer(Nstrata),
                             as.integer(Ntimes),
                             as.integer(delayed),
                             intervals=as.integer(TRUE),
                             NAOK=FALSE,
                             PACKAGE="prodlim")
                out$n.risk <- lagxxx$pred.nrisk
                for (cv in 1:length(object$clustervar)){
                    yyy <- .C("life_table",
                              pred.nrisk=integer(Ntimes*Nstrata),
                              pred.nevent=integer(Ntimes*Nstrata),
                              pred.nlost=integer(Ntimes*Nstrata),
                              nrisk=as.integer(object$n.risk[,1+cv]),
                              nevent=as.integer(object$n.event[[cc]][,1+cv]),
                              nlost=as.integer(object$n.lost[,1+cv]),
                              as.double(lower),
                              as.double(upper),
                              as.double(object$time),
                              as.integer(object$first.strata[findex]),
                              as.integer(object$size.strata[findex]),
                              as.integer(Nstrata),
                              as.integer(Ntimes),
                              as.integer(delayed),
                              NAOK=FALSE,
                              PACKAGE="prodlim")
                    outCV <- data.frame(n.risk=yyy$pred.nrisk,n.event=yyy$pred.nevent,n.lost=yyy$pred.nlost)
                    names(outCV) <- paste(object$clustervar,names(outCV),sep=".")
                    out <- cbind(out,outCV)
                }
            }
        }
        # }}}
        # {{{ percent
        if (!is.null(stats)){
            statsList <- lapply(stats,function(x){
                name.x <- x[1]
                if (name.x=="risk") name.x="cuminc"
                if (percent==TRUE && (match(x[1],c("n.event","n.lost","n.risk"),nomatch=0)==0)){
                    if (x[1]=="surv") { # only one for all causes
                        100*as.numeric(c(x[2],object[[name.x]])[pindex+1])
                    } else{
                        100*as.numeric(c(x[2],object[[name.x]][[cc]])[pindex+1])
                    }
                }
                else{
                    if (x[1]%in%c("surv","n.lost")) {# only one for all causes
                        as.numeric(c(x[2],object[[name.x]])[pindex+1])
                    } else{
                        as.numeric(c(x[2],object[[name.x]][[cc]])[pindex+1])
                    }
                }
            })
            names(statsList) <- sapply(stats,function(x)x[[1]])
            add <- do.call("cbind",statsList)
            add <- add[,match(colnames(add),colnames(out),nomatch=FALSE)==0,drop=FALSE]
            if (NROW(out)==1)
                out <- data.frame(cbind(out,add))
            else
                out <- cbind(out,add)
        }
        # }}}
        # {{{ split according to covariate strata----------------
        if (intervals==TRUE){
            tt <- data.table::data.table(time0=c(0,round(times[-length(times)],2)),time1=times)
        }else{
            tt <- data.table::data.table(time=times)
        }
        if (!is.null(newdata) || Nstrata > 1) {
            if (format[[1]]=="list"){
                split.cova <- rep(1:Nstrata,rep(Ntimes,Nstrata))
                out <- split(out,split.cova)
                names(out) <- IndeX$names.strata
                out <- lapply(out,function(x){
                    x <- cbind(as.matrix(tt),as.matrix(x))
                    rownames(x) <- 1:NROW(x)
                    x
                })
            }else{
                X <- IndeX$predictors[rep(1:Nstrata,rep(Ntimes,Nstrata)),,drop=FALSE]
                out <- cbind(X,tt,out)
                data.table::setDT(out)
                data.table::setkeyv(out,colnames(X))
                out
            }
        } else{
            out <- cbind(tt,out)
            rownames(out) <- 1:NROW(out)
            out
        }
    }) 
    # }}}
    if (format[[1]]!="list") {
        key <- c("cause",data.table::key(outList[[1]]))
        outList <- data.table::rbindlist(outList)
        data.table::setkeyv(outList,key)
    } else{
        names(outList) <- causes
    }
    outList
}
