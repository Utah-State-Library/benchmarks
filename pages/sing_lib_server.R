## Welcome alert on init

# shinyalert(
#   "Welcome to the Benchmark Dashboard!",
#   HTML(
#     '<p style="text-align: left;">This dashboard shows changes in benchmarked numbers over time for individual libraries and multiple libraries. Use the filters to select your library, which benchmark you want to see (out of the 9 that exist in FY24), whether you want to see it shown Per Capita or as reported in the PLS, etc. Enjoy!<br><br>
#                 <b>Note about benchmark percentiles:</b> <em>I did not copy all of the numbers from previous year\'s pdf benchmark tables.</em> Instead, I took the 48 libraries that are benchmarked in FY24 and calculated previous benchmarks for this group of libraries using the historical PLS data. It is possible, and likely, that some of these libraries were not benchmarked in previous years, and their inclusion may shift the benchmark percentiles a bit from what is shown in previous years\' benchmark tables. This shouldn\'t be too far off and doesn\'t impact the actual number and per capita numbers that are displayed.</p>'
#   ),
#   type = "",
#   html = T,
#   imageUrl = "logo.jpeg"
# )

observe({
  if (input$metric_sl == "Actual Number") {
    b_list <- benchmarks2
  } else {
    b_list <- benchmarks
  }
  updatePickerInput(
    session,
    "benchmark_sl",
    choices = b_list,
    selected = b_list[1]
  )
})

b_name_sl <- reactive({
  names(benchmarks)[benchmarks == input$benchmark_sl]
})
b_name_actual_sl <- reactive({
  names(benchmarks2)[benchmarks2 == input$benchmark_sl]
})

df_serv_sl <- reactive({
  df_pctl %>%
    filter(
      LIBNAME %in% input$libname_sl,
      Period_ID >= input$year_sl[1],
      Period_ID <= input$year_sl[2]
    ) %>%
    select(
      LIBNAME,
      Period_ID,
      POPU_LSA,
      Percentile = intersect(contains(input$benchmark_sl), contains("pctl")),
      Per_Cap = intersect(contains(input$benchmark_sl), contains("per_cap")),
      Per_Cap_tt = intersect(contains(input$benchmark_sl), contains("pc_viz")),
      Actual = intersect(contains(input$benchmark_sl), contains("act_n")),
      Actual_tt = intersect(contains(input$benchmark_sl), contains("act_viz"))
    )
})

output$hc_bench_sl <- renderHighchart({
  shiny::validate(
    need((nrow(df_serv_sl()) != 0), "Please Select a Library")
  )

  df <- df_serv_sl() %>%
    rowwise() %>%
    mutate(
      b_name = b_name_sl(),
      b_name_actual = b_name_actual_sl(),
      Percentile_tt = round(Percentile, 3),
      Group = ifelse(
        Percentile < .1,
        "Bottom 10th Percentile",
        ifelse(
          Percentile >= .1 & Percentile < .7,
          "> 10th and < 70th Percentile",
          "Top 70th Percentile"
        )
      ),
      metric = ifelse(input$metric_sl == "Number Per Capita", Per_Cap, Actual)
    )

  if (input$metric_sl == "Number Per Capita") {
    title_p <- b_name_sl()
  } else {
    title_p <- b_name_actual_sl()
  }

  df_red <- df %>% filter(Group == "Bottom 10th Percentile")
  df_green <- df %>% filter(Group == "> 10th and < 70th Percentile")
  df_darkgreen <- df %>% filter(Group == "Top 70th Percentile")

  # Create highcharter scatter plot
  hc <- highchart() %>%
    hc_xAxis(
      title = list(text = "Fiscal Year"),
      allowDecimals = FALSE
    ) %>%
    hc_yAxis(title = list(text = title_p), min = 0) %>%
    hc_tooltip(
      pointFormat = "<b>Year:</b> {point.x:.0f}<br>
                 <b>Library:</b> {point.LIBNAME}<br>
                 <b>LSA Population:</b> {point.POPU_LSA}<br>
                 <hr>
                 <b>{point.b_name_actual} (PLS):</b> {point.Actual_tt}<br>
                 <b>{point.b_name}:</b> {point.Per_Cap_tt}<br>
                 <b>Percentile:</b> {point.Percentile_tt}
                 "
    ) %>%
    hc_title(text = paste0(title_p, " Over Time")) %>%
    hc_subtitle(text = paste0(input$libname_sl))

  if (input$color_dots_sl == "Yes") {
    hc %>%
      hc_add_series(
        df,
        type = "line",
        hcaes(x = Period_ID, y = metric),
        name = paste0(title_p),
        color = "lightgrey",
        showInLegend = F
      ) %>%
      hc_add_series(
        df_red,
        hcaes(x = Period_ID, y = metric, group = Group),
        type = "scatter",
        marker = list(symbol = "circle"),
        color = "red"
      ) %>%
      hc_add_series(
        df_green,
        hcaes(x = Period_ID, y = metric, group = Group),
        type = "scatter",
        marker = list(symbol = "square"),
        color = "lightgreen"
      ) %>%
      hc_add_series(
        df_darkgreen,
        hcaes(x = Period_ID, y = metric, group = Group),
        type = "scatter",
        marker = list(symbol = "triangle"),
        color = "darkgreen"
      )
  } else {
    hc %>%
      hc_add_series(
        df,
        type = "line",
        hcaes(x = Period_ID, y = metric),
        name = paste0(title_p, " Over Time"),
        showInLegend = F
      )
  }
})
