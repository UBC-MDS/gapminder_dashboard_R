library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
library(dashBootstrapComponents)

library(ggplot2)
library(dplyr)
library(purrr)
library(plotly)

app <- Dash$new()

gap <- read.csv("data/processed/gapminder_processed.csv")

country_list <- gap %>% 
  select(name, id) %>%
  distinct()

# Selection filter options - Target of the study

targets_df = data.frame(c(
  "population", "income_group", "income", "life_expectancy",
  "children_per_woman", "child_mortality", 
  "pop_density", "co2_per_capita", 
  "years_in_school_men", "years_in_school_women"
))

# opt_dropdown_targets = dataframe(c("population" = "Population", "income_group" = "Income Group"))

target_options_label = c("Population", "Income Group", "GDP", "Life Expectancy",
                           "Children per woman", "Child Mortality",
                           "Population density", "CO2 per capita",
                           "Avg years in school (men)", "Avg years in school (men)")

target_options_value = c("population", "income_group", "income", "life_expectancy",
                                "children_per_woman", "child_mortality",
                                "pop_density", "co2_per_capita",
                                "years_in_school_men", "years_in_school_women")

target_options_df <- data.frame(target_options_label, target_options_value)

## Layouts

filter_panel <- htmlDiv(
  list(
    htmlH2("Gapminder Dashboard"),
    htmlBr(),
    htmlBr(),
    htmlH3("Filters", className = "text-primary"),
    htmlH5("Target of Study", className="text-dark"),
    dccDropdown(
      id  ="target_input_y",
      className = "dropdown",
      value = "life_expectancy",
      options = target_options_df %>%
        pull(target_options_value) %>%
        purrr::map(function(target_options_value) list(label = target_options_value, 
                                                       value = target_options_value))
    ),
    htmlBr(),
    dccDropdown(
      id  ="target_input_x",
      className = "dropdown",
      value = "income",
      options = target_options_df %>%
        pull(target_options_value) %>%
        purrr::map(function(target_options_value) list(label = target_options_value, 
                                                       value = target_options_value))
    ),
    htmlBr(),
    htmlH5("Country"),
    dccDropdown(
      id  ="country_input",
      className = "dropdown",
      value = "Afghanistan",
      options = gap %>%
        pull(country) %>% unique() %>%
        purrr::map(function(country) list(label = country, 
                                                       value = country))
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
    htmlH5("Year"),
    # htmlBr(),
    dccDropdown(
      id = "year_input",
      className = "dropdown",
      options = gap %>% pull(year) %>% unique() %>%
        purrr::map(function(year) list(label = year, value = year)),
      value = 1970
    )
  )
)

plot_body = htmlDiv(
  list(
    dbcRow(
      list(
        dbcCol(
          list(
            htmlH2("Selected Region")
            ### First plot goes here
            
          ),
          className = "world-map"
        ),
        dbcCol(
          htmlH2("Top 10 countries in the region")
          ### Second plot goes here
        )
      ), 
      className="top-row",
    ), # End of topmost dbcRow
    dbcRow(
      list(
        dbcCol(
          list(
            htmlH2("Target of study over time")
            ### Third plot goes here
            
          ),
          className = "line-plot"
        ),
        dbcCol(
          list(
            htmlH2("Target 1 vs Target 2"),
            ### Fourth plot goes here
            dccGraph(id='bubble_plot')
          ),
          className = "bubble-plot"
        )
      ), 
      className = "bottom-row"
    ) # End of bottom dbcRow
  )
)
page_layout = htmlDiv(
  className = "page_layout",
  children = list(
    dbcCol(filter_panel, className="panel"),
    dbcCol(plot_body, className="body")
  )
)

# Overall layout
app$layout(
  htmlDiv(className = "app", 
          children = page_layout)
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
    gap_f <- gap %>%
      filter(year == year_inp) %>%
      filter(region == region)
    p <- gap_f %>% 
      ggplot(aes(
        x = !!sym(x),
        y = !!sym(y),
        # color = region,
        color = population)) +
      geom_point()
    ggplotly(p)
  }
)


app$run_server(debug=T)