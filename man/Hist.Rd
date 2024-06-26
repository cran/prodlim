% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Hist.R
\name{Hist}
\alias{Hist}
\title{Create an event history object}
\usage{
Hist(
  time,
  event,
  entry = NULL,
  id = NULL,
  cens.code = "0",
  addInitialState = FALSE
)
}
\arguments{
\item{time}{for right censored data a numeric vector of event times -- for
interval censored data a list or a data.frame providing two numeric vectors
the left and right endpoints of the intervals.  See \code{Details}.}

\item{event}{A vector or a factor that specifies the events that occurred at
the corresponding value of \code{time}. Numeric, character and logical
values are recognized.  It can also be a list or a data.frame for the
longitudinal form of storing the data of a multi state model -- see
\code{Details}.}

\item{entry}{Vector of delayed entry times (left-truncation) or list of two
times when the entry time is interval censored.}

\item{id}{Identifies the subjects to which multiple events belong for the
longitudinal form of storing the data of a multi state model -- see
\code{Details}.}

\item{cens.code}{A character or numeric vector to identify the right
censored observations in the values of \code{event}.  Defaults to "0" which
is equivalent to 0.}

\item{addInitialState}{If TRUE, an initial state is added to all ids for the
longitudinal input form of a multi-state model.}
}
\value{
An object of class \code{Hist} for which there are print and plot
methods.  The object's internal is a matrix with some of the following
columns: \item{time}{ the right censored times} \item{L}{the left endpoints
of internal censored event times} \item{R}{the right endpoints of internal
censored event times} \item{status}{\code{0} for right censored, \code{1}
for exact, and \code{2} for interval censored event times.} \item{event}{an
integer valued numeric vector that codes the events.} \item{from}{an integer
valued numeric vector that codes the \code{from} states of a transition in a
multi state model.} \item{to}{an integer valued numeric vector that codes
the \code{to} states of a transition in a multi state model.}

Further information is stored in \code{\link{attributes}}.  The key to the
official names given to the events and the from and to states is stored in
an attribute "states".
}
\description{
Functionality for managing censored event history response data. The
function can be used as the left hand side of a formula: \code{Hist} serves
\code{\link{prodlim}} in a similar way as \code{\link[survival]{Surv}} from the
survival package serves `survfit'. \code{Hist} provides the suitable
extensions for dealing with right censored and interval censored data from
competing risks and other multi state models. Objects generated with
\code{Hist} have a print and a plot method.
}
\details{
*Specification of the event times*

If \code{time} is a numeric vector then the values are interpreted as right
censored event times, ie as the minimum of the event times and the censoring
times.

If \code{time} is a list with two elements or data frame with two numeric
columns The first element (column) is used as the left endpoints of interval
censored observations and the second as the corresponding right endpoints.
When the two endpoints are equal, then this observation is treated as an
exact uncensored observation of the event time.  If the value of the right
interval endpoint is either \code{NA} or \code{Inf}, then this observation
is treated as a right censored observation. Right censored observations can
also be specified by setting the value of \code{event} to \code{cens.code}.
This latter specification of right censored event times overwrites the
former: if \code{event} equals \code{cens.code} the observation is treated
as right censored no matter what the value of the right interval endpoint
is.

*Specification of the events*

If \code{event} is a numeric, character or logical vector then the order of
the attribute "state" given to the \code{value} of \code{Hist} is determined
by the order in which the values appear.  If it is a factor then the order
from the levels of the factor is used instead.

**Normal form of a multi state model**

If \code{event} is a list or a data.frame with exactly two elements, then
these describe the transitions in a multi state model that occurred at the
corresponding \code{time} as follows: The values of the first element are
interpreted as the \code{from} states of the transition and values of the
second as the corresponding \code{to} states.

**Longitudinal form of a multi state model**

If \code{id} is given then \code{event} must be a vector. In this case two
subsequent values of \code{event} belonging to the same value of \code{id}
are treated as the \code{from} and \code{to} states of the transitions.
}
\examples{


## Right censored responses of a two state model
## ---------------------------------------------

Hist(time=1:10,event=c(0,1,0,0,0,1,0,1,0,0))

## change the code for events and censored observations

Hist(time=1:10,event=c(99,"event",99,99,99,"event",99,"event",99,99),cens.code=99)

TwoStateFrame <- SimSurv(10)
SurvHist <- with(TwoStateFrame,Hist(time,status))
summary(SurvHist)
plot(SurvHist)

## Right censored data from a competing risk model
## --------------------------------------------------

CompRiskFrame <- data.frame(time=1:10,event=c(1,2,0,3,0,1,2,1,2,1))
CRHist <- with(CompRiskFrame,Hist(time,event))
summary(CRHist)
plot(CRHist)

## Interval censored data from a survival model
icensFrame <- data.frame(L=c(1,1,3,4,6),R=c(2,NA,3,6,9),event=c(1,1,1,2,2))
with(icensFrame,Hist(time=list(L,R)))

## Interval censored data from a competing risk model
with(icensFrame,Hist(time=list(L,R),event))

## Multi state model
MultiStateFrame <- data.frame(time=1:10,
			      from=c(1,1,3,1,2,4,1,1,2,1),
			      to=c(2,3,1,2,4,2,3,2,4,4))
with(MultiStateFrame,Hist(time,event=list(from,to)))

##  MultiState with right censored observations

MultiStateFrame1 <- data.frame(time=1:10,
			      from=c(1,1,3,2,1,4,1,1,3,1),
			      to=c(2,3,1,0,2,2,3,2,0,4))
with(MultiStateFrame1,Hist(time,event=list(from,to)))

## Using the longitudinal input method 
MultiStateFrame2 <- data.frame(time=c(0,1,2,3,4,0,1,2,0,1),
			      event=c(1,2,3,0,1,2,4,2,1,2),
			      id=c(1,1,1,1,2,2,2,2,3,3))
 with(MultiStateFrame2,Hist(time,event=event,id=id))

}
\seealso{
\code{\link{plot.Hist}}, \code{\link{summary.Hist}},
\code{\link{prodlim}}
}
\author{
Thomas A. Gerds \email{tag@biostat.ku.dk}, Arthur Allignol
\email{arthur.allignol@fdm.uni-freiburg.de}
}
\keyword{survival}
