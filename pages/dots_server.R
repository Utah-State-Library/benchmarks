b_name <- reactive({
  names(benchmarks)[benchmarks == input$benchmark]
})
b_name_actual <- reactive({
  names(benchmarks2)[benchmarks2 == input$benchmark]
})

df_serv <- reactive({
  df_pctl %>%
    filter(
      LIBNAME %in% input$libname,
      Period_ID >= input$year[1],
      Period_ID <= input$year[2]
    ) %>%
    select(
      LIBNAME,
      Period_ID,
      POPU_LSA,
      Percentile = intersect(contains(input$benchmark), contains("pctl")),
      Per_Cap = intersect(contains(input$benchmark), contains("per_cap")),
      Per_Cap_tt = intersect(contains(input$benchmark), contains("pc_viz")),
      Actual = intersect(contains(input$benchmark), contains("act_viz"))
    )
})

output$hc_bench <- renderHighchart({
  # Jitter the x-axis (Year) values
  df <- df_serv() %>%
    mutate(
      b_name = b_name(),
      b_name_actual = b_name_actual(),
      Year_jittered = as.numeric(Period_ID) + runif(n(), min = -0.2, max = 0.2),
      Percentile_tt = round(Percentile, 3),
      Group = ifelse(
        Percentile < .1,
        "Bottom 10th Percentile",
        ifelse(
          Percentile >= .1 & Percentile < .7,
          "> 10th and < 70th Percentile",
          "Top 70th Percentile"
        )
      )
    )

  df_red <- df %>% filter(Group == "Bottom 10th Percentile")
  df_green <- df %>% filter(Group == "> 10th and < 70th Percentile")
  df_darkgreen <- df %>% filter(Group == "Top 70th Percentile")

  # Create highcharter scatter plot
  highchart() %>%
    hc_chart(type = "scatter") %>%
    hc_xAxis(
      title = list(text = "Year"),
      categories = as.character(unique(df_serv()$Period_ID)),
      tickPositions = unique(df_serv()$Period_ID)
    ) %>%
    hc_title(text = paste0(b_name(), " Over Time")) %>%
    hc_yAxis(title = list(text = b_name()), min = 0) %>%
    hc_add_series(
      df_red,
      hcaes(x = Year_jittered, y = Per_Cap, group = Group),
      type = "scatter",
      marker = list(symbol = "circle"),
      color = "red"
    ) %>%
    hc_add_series(
      df_green,
      hcaes(x = Year_jittered, y = Per_Cap, group = Group),
      type = "scatter",
      marker = list(symbol = "square"),
      color = "lightgreen"
    ) %>%
    hc_add_series(
      df_darkgreen,
      hcaes(x = Year_jittered, y = Per_Cap, group = Group),
      type = "scatter",
      marker = list(symbol = "triangle"),
      color = "darkgreen"
    ) %>%
    hc_tooltip(
      pointFormat = "<b>Year:</b> {point.x:.0f}<br>
                 <b>Library:</b> {point.LIBNAME}<br>
                 <b>LSA Population:</b> {point.POPU_LSA}<br>
                 <hr>
                 <b>{point.b_name_actual} (PLS):</b> {point.Actual}<br>
                 <b>{point.b_name}:</b> {point.Per_Cap_tt}<br>
                 <b>Percentile:</b> {point.Percentile_tt}
                 "
    )
})
