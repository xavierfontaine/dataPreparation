% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datesManipulations.R
\name{dateFormatUnifier}
\alias{dateFormatUnifier}
\title{Unify dates format}
\usage{
dateFormatUnifier(dataSet, format = "Date")
}
\arguments{
\item{dataSet}{Matrix, data.frame or data.table}

\item{format}{desired target format: Date, POSIXct or POSIXlt, (character, default to Date)}
}
\value{
The same dataSet set but with dates column with the desired format
}
\description{
Unify every column in a date format to the same date format
}
\details{
This function only handle Date, POSIXct and POSIXlt dates. 
POSIXct format is a bit slower than Date but can keep hours-min.
}
\examples{
# build a data.table
dataSet <- data.table( column1 = as.Date("2016-01-01"), column2 = as.POSIXct("2017-01-01") )

# Use the function
dataSet = dateFormatUnifier(dataSet, format = "Date")

# Control result
sapply(dataSet, class)
# return date for both column
}
