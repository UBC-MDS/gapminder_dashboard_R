# Reflections

## Dashboard Summary

The gapminder dashboard has been created to enable users to learn more about the socio-economic trends across the world. It has been built upon the Gapminder data set, which is a great source of information about these parameters and is updated from time-to-time. 

The dashboard provides the following charts:
-	A world map (top-left) highlights the region for which data is being analysed. Countries in the region are highlighted using colour gradient based on value of the parameter. A tooltip gives specific values for each country.
-	A bar chart (top-right) represents the top 10 countries in the selected region having the highest value for the parameter.
-	A line chart (bottom-left) plots the trend for the parameter over the selected time horizon. It includes overall average for the world, average for the selected region and value for the selected country. 
-	A bubble chart (bottom-right) compares the parameter with other parameters for the specified region, country and year.

## What works well

The dashboard covers a wide range of socio-economic parameters that can be analysed, and it allows the users to drill down deeper into the historical trends and specific regions by providing multiple filters, such as region, country, and year. This allows the users to analyse the data at desired level of granularity. It also allows the user to compare changes in one parameter with respect to changes in other. According to user feedback, the application has been easy to use and interpret.

## Issues with Heroku Deployment

The R app is working fine locally. But when we deploy it on Heroku, we observe a few discrepancies:
-	We observe that the target values selected from filters is not correctly reflected in the charts. It is to be noted that the other filter elements - region, country and year - are correctly getting selected. We have re-confirmed that the variable names are correctly used in the callback functions. We have also tested different HTML components to check if something else works. But, we have not been able to fix this issue for the deployed app. This is a known issue and will be updated in the next version.
-	We notice that the legend on the map is not properly positioned compared to the position of the map. We searched on the internet and tried multiple code recommendations but this has not been fixed. This is a known issue and will be updated in the next version.

## Limitations and Improvement Areas

In terms of functionality, the dashboard needs the following enhancements
-	It needs to be more reactive to the changes in display environment. Currently, it works well for a large screen display with fixed resolution. But when we look at it on smaller screens, such as tablet or mobile, or when we use a different resolution, layout and size of charts do not get adjusted automatically. The functionality where plot area and chart area get adjusted as per the screen size and resolution needs to be incorporated.
-	It needs to have more interactivity in all the plots. This includes the option to highlight sections of interest in all plots and grey out the other data points. This also includes the option to select countries from the world map and see their metircs in other plots.
-	The DashR works perfectly in the local system; however, after deploying on Heroku, on the website instead of showing life expectancy in the target column it shows child mortality and the dropdown option are not working well(which we believe this issue comes from Heroku and DashR).
-	There is always also some room to improve our style to engage our users more and make the application more appealing

## Differences between the DashR and DashPy app
Obviously, the language of the 2 dashboards are different so the syntaxes were different, but another important difference between these 2 was the deployment of these 2 apps. Deploying DashPy is now automatic from our github main which means after merging to main the code will automatically deploy on `Herolu` website; however, in DashR this process should be done manually.

## About received feedbacks
All the feedbacks were valuable and helped us to improve our application, and among all of them, we found the feedback that suggested changing the `year` dropdown to slider more constructive for our app because it makes it easier for the user to change and test different years faster. Also, there was another valuable feedback that recommended adding some descriptions for users to make the target options clear.
