library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(tidyverse)
library(magrittr)
library(highcharter)
library(shinyBS)
library(shinyalert)

#rsconnect::writeManifest()

options(scipen = 999)

df_pctl <- read.csv("data/df_pctl.csv")

libnames <- unique(df_pctl$LIBNAME) %>% sort()

benchmarks <- c(
  "b1_",
  "b2",
  "b3",
  "b4", #"b5",
  "b6",
  #"b7","b8",
  "b9",
  "b10",
  "b11",
  "b12"
)
names(benchmarks) <- c(
  "Visits Per Capita",
  "Physical Material Circ Per Capita",
  "Electronic Material Circ Per Capita",
  "Physical Material Turnover",
  #"Electronic Material Turnover",
  "Internet Terminal Use Per Capita",
  #"Wifi Use Per Capita",
  #"Program Attendance Per Capita",
  "Local Operation Expense Per Capita",
  "Percent of Budget is Collections",
  "FTE Per Capita",
  "Number of Programs Per Capita"
)

benchmarks2 <- c(
  "b1_",
  "b2",
  "b3",
  "b4", #"b5",
  "b6",
  #"b7","b8",
  "b9",
  "b10",
  "b11",
  "b12"
)
names(benchmarks2) <- c(
  "Visits",
  "Physical Material Circ",
  "Electronic Material Circ",
  "Physical Material Turnover",
  #"Electronic Material Turnover",
  "Internet Terminal Use",
  #"Wifi Use",
  #"Program Attendance",
  "Local Operation Expense",
  "Percent of Budget is Collections",
  "FTE",
  "Number of Programs"
)


ui <- fluidPage(
  tagList(
    # Formats collapsing
    tags$style(HTML(
      "
            .panel-heading .panel-title a.collapsed:after {
            transform: rotate(180deg);
            transition: .5s ease-in-out;
            }
            .panel-heading .panel-title a:after {
            content:'⏶';
            text-align: right;
            float:right;
            transition: .5s ease-in-out;
            }
            .panel-heading .panel-title a:not([class]):after {
            transform: rotate(180deg);
            }",
      "hr {border-top: 1px solid #000000;}"
    ))
  ),

  #   tags$style(HTML(
  #     "table {
  #     border-collapse: collapse;
  #   }
  #   tr, td, th {
  #     padding: 0em;
  #   }"
  #   ))
  #),

  # tags$style(HTML(
  #   "
  #     .shiny-output-error-validation {
  #       color: green;
  #       text-align: center;
  #     }
  #   "
  # )),

  navbarPage(
    title = "Benchmarks Over Time",
    #       div(
    #       "",
    #       tags$script(HTML(
    #         "var header = $('.navbar > .container-fluid');
    # header.append('<div style=\"float:left\"><ahref=\"URL\"><img src=\"usllogo.jpeg\" alt=\"alt\" style=\"float:left;height:50px;\"> </a>`</div>');console.log(header)"
    #       ))
    #     ),

    source("pages/sing_lib_ui.R", local = TRUE)$value,
    source("pages/dots_ui.R", local = TRUE)$value
  )
)

server <- function(input, output, session) {
  source("pages/dots_server.R", local = TRUE)$value
  source("pages/sing_lib_server.R", local = TRUE)$value
}

shinyApp(ui = ui, server = server)
