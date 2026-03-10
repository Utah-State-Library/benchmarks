tabPanel(
  "Benchmark Distribution - All Libraries",
  column(
    3,
    wellPanel(
      pickerInput(
        "libname",
        label = "Select Library",
        choices = libnames,
        selected = libnames,
        multiple = T,
        options = list(
          `actions-box` = TRUE,
          `selected-text-format` = paste0("count > ", length(libnames) - 1),
          `count-selected-text` = "All"
        )
      ),
      pickerInput(
        "benchmark",
        label = "Select Benchmark",
        choices = benchmarks,
        selected = benchmarks,
        multiple = F
      ),
      sliderInput(
        "year",
        label = "Year Range",
        min = min(df_pctl$Period_ID),
        max = max(df_pctl$Period_ID),
        value = c(max(df_pctl$Period_ID) - 5, max(df_pctl$Period_ID)),
        round = TRUE,
        step = 0,
        sep = ""
      ),
      bsCollapse(
        id = "collapseAboutDots",
        open = "About Benchmarks",
        bsCollapsePanel(
          "About Benchmarks",
          tags$p(
            "Benchmarks are calculated by finding the percentile rank of library's per capita values (turnover and percent of collections budget are not calculated per capita)"
          ),
          tags$p(
            tags$span(style = "color:red; font-weight:bold;", "RED"),
            tags$span(
              " points indicate that a library was in the bottom 10th percentile"
            )
          ),
          tags$p(
            tags$span(
              style = "color:lightgreen; font-weight:bold;",
              "LIGHT GREEN"
            ),
            tags$span(
              " points indicate that a library was above the 10th percentile, but below the 70th percentile"
            )
          ),
          tags$p(
            tags$span(style = "color:green; font-weight:bold;", "GREEN"),
            tags$span(
              "  points indicate that a library was above the 70th percentile"
            )
          )
        )
      )
    )
  ),
  column(
    9,
    highchartOutput("hc_bench", height = 650),
    hr(),
    tags$p(
      "This dashboard was created using data from the Public Library Survey",
      style = "text-align:center; color:grey"
    ),
    tags$p(
      "Contact Sam Dutton (samdutton@utah.gov) for questions/comments",
      style = "text-align:center; color:grey"
    )
  )
)
