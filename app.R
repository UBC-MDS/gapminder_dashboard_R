library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)

library(ggplot2)
library(dplyr)
library(purrr)
library(plotly)

app <- Dash$new()

gap <- read.csv("data/processed/gapminder_processed.csv")

country_list <- gap %>%
  select(country, id) %>%
  distinct()

# Selection filter options - Target of the study

target_options_value <- c(
  "population",
  "income",
  "life_expectancy",
  "children_per_woman",
  "child_mortality",
  "pop_density"
)

targets_df <- data.frame(target_options_value)

labels <- list(
  "population" = "Population",
  "income" = "Income",
  "life_expectancy" = "Life Expectancy",
  "child_mortality" = "Child Mortality",
  "children_per_woman" = "Children per Woman",
  "pop_density" = "Population Density"
)


## Layouts

filter_panel <- htmlDiv(
  list(
    htmlH2("Gapminder Dashboard"),
    htmlBr(),
    htmlBr(),
    htmlH3("Filters", className = "text-primary"),
    htmlH5("Target of Study", className = "text-dark"),
    dccDropdown(
      id = "target_input_y",
      className = "dropdown",
      value = "life_expectancy",
      options = targets_df %>%
        pull(target_options_value) %>%
        purrr::map(function(target_options_value) {
          list(
            label = labels[[target_options_value]],
            value = target_options_value
          )
        })
    ),
    htmlBr(),
    dccDropdown(
      id = "target_input_x",
      className = "dropdown",
      value = "income",
      options = targets_df %>%
        pull(target_options_value) %>%
        purrr::map(function(target_options_value) {
          list(
            label = labels[[target_options_value]],
            value = target_options_value
          )
        })
    ),
    htmlBr(),
    htmlH5("Region"),
    dccRadioItems(
      id = "region_input",
      className = "radio",
      value = "Asia",
      options =
        gap %>% pull(region) %>% unique() %>%
          purrr::map(function(region) list(label = region, value = region))
    ),
    htmlBr(),
    htmlH5("Country"),
    dccDropdown(
      id = "country_input",
      className = "dropdown",
      value = "Afghanistan",
      options = gap %>%
        pull(country) %>% unique() %>%
        purrr::map(function(country) {
          list(
            label = country,
            value = country
          )
        })
    ),
    htmlBr(),
    htmlH5("Year"),
    # htmlBr(),
    dccSlider(
      id = "year_input",
      min = 1950,
      max = 2018,
      step = 1,
      marks = list(
        "1950" = "1950",
        "1975" = "1975",
        "2000" = "2000",
        "2018" = "2018"
      ),
      value = 1970,
      tooltip = list(placement = "bottom")
    )
  )
)

plot_body <- htmlDiv(
  list(
    dbcRow(
      list(
        dbcCol(
          list(
            ### First plot goes here
            dccGraph(id = "map")
          ),
          className = "world-map"
        ),
        dbcCol(
            list(
                ### Second plot goes here
                dccGraph(id = "bar_chart")
            ),
            className = "bar_chart"
        )
      ),
      className = "top-row",
    ), # End of topmost dbcRow
    dbcRow(
      list(
        dbcCol(
          list(
            ### Third plot goes here
            dccGraph(id='line_plot')
          ),
          className = "line-plot"
        ),
        dbcCol(
          list(
            ### Fourth plot goes here
            dccGraph(id = "bubble_plot")
          ),
          className = "bubble-plot"
        )
      ),
      className = "bottom-row"
    ) # End of bottom dbcRow
  )
)
page_layout <- htmlDiv(
  className = "page_layout",
  children = list(
    dbcCol(filter_panel, className = "panel"),
    dbcCol(plot_body, className = "body")
  )
)

# Overall layout
app$layout(
  htmlDiv(
    className = "app",
    children = page_layout
  )
)

app$callback(
  output("bar_chart", "figure"),
  list(
    input("target_input_y", "value"),
    input("region_input", "value"),
    input("year_input", "value"),
    input("target_input_x", "value")
  ),
  function(target, region_f, year_f) {
    gap_f <- gap %>%
      filter(region == region_f, year == year_f) %>%
      select(region, country, year, target)

    colnames(gap_f)[4] <- "target"
    gap_f <- gap_f[order(-gap_f$target),][1:10,]

    p <- ggplot(gap_f, aes(x = target,
                           y = reorder(country, target))) +
      geom_col(show.legend = FALSE, fill = "blue") +
      labs(y = "Country", x = target,
           title = "Top 10 countries")

    ggplotly(p)
  }
)
    
app$callback(
  output("bubble_plot", "figure"),
  list(
    input("year_input", "value"),
    input("region_input", "value"),
    input("target_input_y", "value"),
    input("target_input_x", "value")
  ),
  function(year_inp, region, x, y) {
    region_value <- region
    gap_f <- gap %>%
      filter(year == year_inp) %>%
      filter(region == region_value)
    p <- gap_f %>%
      ggplot(aes(
        x = !!sym(x),
        y = !!sym(y),
        color = population
      )) +
      geom_point()
    ggplotly(p)
  }
)

app$callback(
  output("map", "figure"),
  list(
    input("region_input", "value"),
    input("target_input_y", "value")
  ),
  function(region, stat) {
    region_value <- region

    data <- gap %>%
      filter(region == region_value)

    map_plot <- plot_ly(data,
      type = "choropleth",
      locations = ~code,
      z = data[[stat]],
      text = ~country,
      color = data[[stat]]
    ) %>%
      layout(title = paste0(labels[[stat]], " for ", region))

    ggplotly(map_plot)
  }
)

app$callback(
  output('line_plot', 'figure'),
  list(input('target_input_y', 'value'),
       input('region_input', 'value'),
       input('country_input', 'value'),
       input('year_input', 'value')),
  function(target, continent_x, country_x, year_x) {
    
    # World 
    df = gap %>%
      group_by(year) %>% 
      summarise(target_study = mean(!!sym(target))) %>%
      mutate(label = "World")
    
    # Region
    df_continent <- gap %>%
      filter(region == continent_x) %>%
      group_by(year) %>%
      summarise(target_study = mean(!!sym(target))) %>%
      mutate(label = continent_x)
    
    # Country
    df_country <- gap %>%
      filter(country == country_x) %>%
      group_by(year) %>%
      summarise(target_study = mean(!!sym(target))) %>%
      mutate(label = country_x)
    
    # Year
    df = rbind(df,df_continent, df_country)
    df = df %>%
      filter(year<=year_x)
    
    label_order <- df %>%
      filter(year == max(df$year)) %>%
      arrange(desc({{target}}))
    
    df$label <- factor(df$label,
                       levels = c("World", continent_x, country_x))
    p <- ggplot(df, aes(x = year,
                        y = target_study,
                        color = label,
                        label = label
    )) +
      geom_line() +
      labs(x = "Year", y = target)+
      geom_text(data = label_order, 
                check_overlap = TRUE,
                position = position_dodge(width = 2),
                ) +
      ggthemes::scale_color_tableau()+
      theme(legend.position="none")
    return (ggplotly(p))
  }
)

app$run_server(host = '0.0.0.0')