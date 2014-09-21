# load libraries
library(XML)
library(RCurl)
library(rjson)
library(ggplot2)

# query Courses data from Coursera API
webpage <- getURL("https://api.coursera.org/api/catalog.v1/courses?fields=id,language,targetAudience,estimatedClassWorkload")
courses <- fromJSON(readLines(textConnection(webpage), warn=F))
courses <- as.data.frame(do.call(rbind, 
                                 lapply(lapply(courses[[1]], unlist), 
                                        "[", unique(unlist(c(sapply(courses[[1]],names)))))))
courses <- courses[,c(1,4,5,6)]
names(courses) <- c("id","lang","audience","workload")
courses$workload <- gsub(" hours/week","",courses$workload)
courses$workload <- (as.numeric(gsub(".*-","",courses$workload))
                     +as.numeric(gsub("-.*","",courses$workload)))/2

# query Sessions data from Coursera API
webpage <- getURL("https://api.coursera.org/api/catalog.v1/sessions?fields=id,courseId,startMonth,startYear,signatureTrackPrice,eligibleForSignatureTrack")
sessions <- fromJSON(readLines(textConnection(webpage), warn=F))
sessions <- as.data.frame(do.call(rbind, 
                                  lapply(lapply(sessions[[1]], unlist), 
                                         "[", unique(unlist(c(sapply(sessions[[1]],names)))))))
sessions <- sessions[,c(2,4:7)]
names(sessions) <- c("id","month","year","price","signature")
sessions$price <- as.numeric(as.character(sessions$price))

# merge Courses and Sessions by courseID
data <- merge(sessions,courses,by="id")
data <- subset(data,!is.na(data$year))

# plotting function
plotData <- function(data,plottype,year)
{
  year <- as.numeric(year)
  if(year!=0) data <- data[which(data$year==year),]
  
  # workload ~ lang plot
  if(plottype==1)
  {
    data$count <- 1
    data <- aggregate(workload~lang+year+signature,data,mean,na.rm=T)
    plot <- ggplot(data,aes(x=lang,y=workload,fill=signature))
    plot <- plot + geom_bar(stat="identity") + facet_grid(year~signature)
    return(print(plot))
  }
  
  # workload ~ audience plot
  if(plottype==2)
  {
    data$count <- 1
    data <- aggregate(workload~audience+year+signature,data,mean,na.rm=T)
    plot <- ggplot(data,aes(x=audience,y=workload,fill=signature))
    plot <- plot + geom_bar(stat="identity") + facet_grid(year~signature)
    return(print(plot))
  }
  
  # workload ~ year plot
  if(plottype==3)
  {
    data$count <- 1
    data <- aggregate(workload~year+signature,data,mean,na.rm=T)
    plot <- ggplot(data,aes(x=year,y=workload,fill=signature))
    plot <- plot + geom_bar(stat="identity") + facet_grid(.~signature)
    return(print(plot))
  }
  
  # count ~ year plot
  if(plottype==4)
  {
    data$count <- 1
    data <- aggregate(count~year+signature,data,sum,na.rm=T)
    plot <- ggplot(data,aes(x=year,y=count,fill=signature))
    plot <- plot + geom_bar(stat="identity") + facet_grid(.~signature)
    return(print(plot))
  }
  
  # count ~ audience plot
  if(plottype==5)
  {
    data$count <- 1
    data <- aggregate(count~audience+year+signature,data,sum,na.rm=T)
    plot <- ggplot(data,aes(x=audience,y=count,fill=signature))
    plot <- plot + geom_bar(stat="identity") + facet_grid(year~signature)
    return(print(plot))
  }
}

shinyServer(
  function(input, output) 
    {
    text <- c("Workload by Language","Workload by Audience","Workload by Year",
              "Number of Courses by Year","Number of Courses by Audiences")
      output$caption <-renderText(text[as.numeric(input$plottype)])
      output$plot <- renderPlot(plotData(data,input$plottype,input$year))
    }
)