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
    # htmlBr(),
    # htmlBr(),
    htmlH3("Filters", className = "text-primary", style = list("margin-bottom" = "0px")),
    htmlH4("Target of Study", className = "text-dark", style = list("margin" = "7px")),
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
        }),
      style = list("margin-bottom" = "7px")
    ),
    # htmlBr(),
    htmlH4("Interpretation of Target of Study:", style = list("margin-bottom" = "7px")),
    htmlH6("- Population is number of people living", style = list("margin" = "0px")),
    htmlH6("- Income is GDP per capita adjusted for purchasing power", style = list("margin" = "0px")),
    htmlH6("- Children per Woman is the number of children born to each woman", style = list("margin" = "0px")),
    htmlH6("- Child Mortality is deaths of children under 5 per 1000 live births", style = list("margin" = "0px")),
    htmlH6("- Population Density is average number of people per km2", style = list("margin" = "0px")),
    # htmlBr(),
    htmlH4("Region", style = list("margin-bottom" = "4px")),
    dccRadioItems(
      id = "region_input",
      className = "radio",
      value = "Asia",
      options =
        gap %>% pull(region) %>% unique() %>%
          purrr::map(function(region) list(label = region, value = region))
    ),
    # htmlBr(),
    htmlH4("Country", style = list("margin-bottom" = "4px")),
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
    # htmlBr(),
    htmlH4("Year", style = list("margin-bottom" = "4px")),
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
            dccGraph(id = "line_plot")
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
    # input("target_input_y", "value"),
    input("region_input", "value"),
    input("year_input", "value"),
    input("target_input_y", "value")
  ),
  function(region_f, year_f, target) {
    gap_f <- gap %>%
      filter(region == region_f, year == year_f) %>%
      select(region, country, year, !!sym(target))

    gap_f <- gap_f %>%
      arrange(desc(!!sym(target))) %>%
      head(10)

    p <- ggplot(gap_f, aes(
      x = !!sym(target),
      y = reorder(country, !!sym(target))
    )) +
      geom_col(show.legend = FALSE, fill = "blue") +
      labs(
        y = "Country", x = labels[[target]],
        title = paste0("Top 10 countries in ", region_f)
      )

    ggplotly(p, width = 400, height = 400)
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
      geom_point() +
      labs(
        x = labels[[x]],
        y = labels[[y]],
        title = paste0(labels[[y]], " vs ", labels[[x]])
      )
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
  output("line_plot", "figure"),
  list(
    input("target_input_y", "value"),
    input("region_input", "value"),
    input("country_input", "value"),
    input("year_input", "value")
  ),
  function(target, continent_x, country_x, year_x) {

    # World
    df <- gap %>%
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
    df <- rbind(df, df_continent, df_country)
    df <- df %>%
      filter(year <= year_x)

    label_order <- df %>%
      filter(year == max(df$year)) %>%
      arrange(desc({{ target }}))

    df$label <- factor(df$label,
      levels = c("World", continent_x, country_x)
    )
    p <- ggplot(df, aes(
      x = year,
      y = target_study,
      color = label,
      label = label
    )) +
      geom_line() +
      labs(x = "Year", y = labels[[target]], title = paste0(labels[[target]], " over time ")) +
      geom_text(
        data = label_order,
        check_overlap = TRUE,
        position = position_dodge(width = 2),
      ) +
      ggthemes::scale_color_tableau() +
      theme(legend.position = "none")
    return(ggplotly(p))
  }
)

# app$run_server(debug=T)
app$run_server(host = "0.0.0.0")