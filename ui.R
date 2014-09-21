library(shiny)
shinyUI(
  pageWithSidebar(
    headerPanel("Coursera Stats on Free & Paid Courses"),
    sidebarPanel(
      h3("Select Plot Type & Year"),
      selectInput(
        inputId="plottype",label="Select Plot", selected=T,
                              choices = c("Workload by Language" = "1",
                                "Workload by Audience" = "2",
                                "Workload by Year" = "3",
                                "Number of Courses by Year" = "4",
                                "Number of Courses by Audiences" = "5"
                                )
          ),
      selectInput(
        inputId="year",label="Select Year", selected=T,
                            choices = c("All years" = "0",
                                "Only 2012" = "2012",
                                "Only 2013" = "2013",
                                "Only 2014" = "2014",
                                "Only 2015" = "2015"
                              )
      )
      ),
    mainPanel(
      h3(textOutput("caption")),
      plotOutput("plot")
      )
    )
)
