#' Check availability of a cause in competing risk settings
#'
#' For competing risk settings, check if the requested cause is known to the object
#' @param cause cause of interest
#' @param object object either obtained with \code{Hist} or \code{prodlim} 
#' @export
checkCauses <- function(cause,object){
    if (!is.null(cause)){
        cause <- unique(cause)
        if (!is.character(cause)) cause <- as.character(cause)
        fitted.causes <- prodlim::getStates(object)
        if (!is.null(fitted.causes)){
            if (!(all(cause %in% fitted.causes))){
                stop(paste0("Cannot find requested cause(s) in object.\n\n",
                            "Requested cause(s): ",
                            paste0(cause,collapse=", "),
                            "\n Available causes: ",
                            paste(fitted.causes,collapse=", "),"\n"))
            }
        }
        cause
    }
}
#----------------------------------------------------------------------
### checkCauses.R ends here
