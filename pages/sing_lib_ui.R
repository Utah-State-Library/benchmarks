tabPanel(
  "Individual Library Benchmarks",
  column(
    3,
    wellPanel(
      pickerInput(
        "libname_sl",
        label = "Select Library",
        choices = libnames,
        selected = libnames[1],
        multiple = TRUE,
        options = pickerOptions(maxOptions = 1)
      ),
      pickerInput(
        "benchmark_sl",
        label = "Select Benchmark",
        choices = benchmarks2,
        selected = benchmarks2[1],
        multiple = F
      ),
      radioButtons(
        "metric_sl",
        label = "Which Value to Graph?",
        choices = c("Actual Number", "Number Per Capita"),
        selected = "Actual Number",
        inline = T
      ),
      radioButtons(
        "color_dots_sl",
        label = "Show Benchmark Category?",
        choices = c("Yes", "No"),
        selected = "Yes",
        inline = T
      ),
      sliderInput(
        "year_sl",
        label = "Year Range",
        min = min(df_pctl$Period_ID),
        max = max(df_pctl$Period_ID),
        value = c(max(df_pctl$Period_ID) - 5, max(df_pctl$Period_ID)),
        round = TRUE,
        step = 0,
        sep = ""
      ),
      bsCollapse(
        id = "collapseAboutSingLib",
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
    highchartOutput("hc_bench_sl", height = 650),
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
