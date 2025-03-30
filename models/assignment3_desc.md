# 2.2 Follow-up
The title with the least percentage of mobile views from top-200 is Анна_Ярославна with corresponding mobile_percentage 47.27%. 
It is the article about historical figure if Kyiv Rus. We can assume that the majority of readers are schoolchildren and students.

The analysis is done in UTC time and then Kyiv time. Actually the analysis is the same, because I am manually calculate UTC time to the local time to make plausible explanations. 

The table of results are sorted differently in this two sections. 

In conclusion, no need to read the analysis in Kyiv time if you've read the analysis in UTC time.


## Analysis in UTC

| Row | hour_of_day | total_views | total_mobile_views | mobile_percentage |
|-----|------------|-------------|---------------------|-------------------|
| 1   | 0         | 8           | 3                   | 37.5%             |
| 2   | 1         | 7           | 3                   | 42.86%            |
| 3   | 2         | 5           | 1                   | 20%               |
| 4   | 3         | 5           | 0                   | 0%                |
| 5   | 4         | 6           | 0                   | 0%                |
| 6   | 5         | 12          | 5                   | 41.67%            |
| 6   | 5         | 12          | 5                   | 41.67%            |
| 7   | 6         | 10          | 4                   | 40%               |
| 8   | 7         | 14          | 7                   | 50%               |
| 9   | 8         | 14          | 7                   | 50%               |
| 10  | 9         | 14          | 7                   | 50%               |
| 11  | 10        | 11          | 6                   | 54.55%            |
| 12  | 11        | 13          | 7                   | 53.85%            |
| 13  | 12        | 13          | 7                   | 53.85%            |
| 14  | 13        | 13          | 7                   | 53.85%            |
| 15  | 14        | 13          | 7                   | 53.85%            |
| 16  | 15        | 13          | 6                   | 46.15%            |
| 17  | 16        | 14          | 7                   | 50%               |
| 18  | 17        | 14          | 7                   | 50%               |
| 19  | 18        | 14          | 7                   | 50%               |
| 20  | 19        | 13          | 7                   | 53.85%            |
| 21  | 20        | 14          | 7                   | 50%               |
| 22  | 21        | 14          | 7                   | 50%               |
| 23  | 22        | 8           | 5                   | 62.5%             |
| 24  | 23        | 13          | 6                   | 46.15%            |

From 7am till 21pm UTC time the views are almost constant 13-14 views per hour with the only exception at 10-00. It is 12pm in Kyiv, this exception could be due to lunch time in Ukraine. At this period the mobile percentage is high 50% with its maxiumum at 10am (12pm Kyiv time), the possible explanation it is easier to check the required info with mobile phone at lunch.

At the night surprisingly there is a peak with 13 views (almost daytime maximum) at 23pm UTC (1am in Kyiv). After that decreasing to 5 views per hours at 3-4 am in the morning (minimum of the day). After that the number of views is increasing with slight drop at 6am. 6am UTC is 8am at Kyiv time,  the usual commute time for schoolchildren and students.  As for mobile_percentage, there is a day maximum at 10pm (12pm Kyiv time), the hypothesis is it could be due to checking info before sleep using mobile phone. Then the mobile-percentage is less than 50% through the night, with 0 mobile views at 3-4am UTC. It might be that at this period most views are done by users that are in different time zones, users for which it is day, this way we could explain the desktop devices as the preffered way to read the article.

The query was done like this:

```{SQL}

WITH
  views_data AS (
  SELECT
    hour_of_day,
    COUNT(views) AS total_views,
    COUNTIF(src="mobile") AS total_mobile_views
  FROM
     `econ250-2025.akryzhko.int_assignment3_uk_wiki`
  WHERE
    title = "Анна_Ярославна"
  GROUP BY
    hour_of_day )

SELECT
  hour_of_day,
  total_views,
  total_mobile_views,
  FORMAT('%s%%', CAST(ROUND((views_data.total_mobile_views/views_data.total_views) * 100, 2) AS STRING)) as mobile_percentage
FROM
  views_data
ORDER BY hour_of_day ASC

```

## Analysis in Kyiv Time

To look at the changes of the views through the day, I've added *ukr_hour_of_day* column, that calculates Kyiv time (UTC+2) and sorted by it to make analysis easier.


The results are:

| Row | hour_of_day | ukr_hour_of_day | total_views | total_mobile_views | mobile_percentage |
|-----|-----------|----------------|-------------|---------------------|-------------------|
| 1   | 22        | 0              | 8           | 5                   | 62.5%             |
| 2   | 23        | 1              | 13          | 6                   | 46.15%            |
| 3   | 0         | 2              | 8           | 3                   | 37.5%             |
| 4   | 1         | 3              | 7           | 3                   | 42.86%            |
| 5   | 2         | 4              | 5           | 1                   | 20%               |
| 6   | 3         | 5              | 5           | 0                   | 0%                |
| 7   | 4         | 6              | 6           | 0                   | 0%                |
| 8   | 5         | 7              | 12          | 5                   | 41.67%            |
| 9   | 6         | 8              | 10          | 4                   | 40%               |
| 10  | 7         | 9              | 14          | 7                   | 50%               |
| 11  | 8         | 10             | 14          | 7                   | 50%               |
| 12  | 9         | 11             | 14          | 7                   | 50%               |
| 13  | 10        | 12             | 11          | 6                   | 54.55%            |
| 14  | 11        | 13             | 13          | 7                   | 53.85%            |
| 15  | 12        | 14             | 13          | 7                   | 53.85%            |
| 16  | 13        | 15             | 13          | 7                   | 53.85%            |
| 17  | 14        | 16             | 13          | 7                   | 53.85%            |
| 18  | 15        | 17             | 13          | 6                   | 46.15%            |
| 19  | 16        | 18             | 14          | 7                   | 50%               |
| 20  | 17        | 19             | 14          | 7                   | 50%               |
| 21  | 18        | 20             | 14          | 7                   | 50%               |
| 22  | 19        | 21             | 13          | 7                   | 53.85%            |
| 23  | 20        | 22             | 14          | 7                   | 50%               |
| 24  | 21        | 23             | 14          | 7                   | 50%               |

*Note*. Formatting is done with chatGPT.


From 9am till 23pm the views are almost constant 13-14 views per hour with the only exception at 12-00. This exception could be due to lunch time. At this period the mobile percentage is high 50% with its maxiumum at 12am (it is easier to check the required info with mobile phone at lunch?).

At the night surprisingly there is a peak with 13 views (almost daytime maximum) at 12pm. After that decreasing to 5 views per hours at 5-6 am in the morning (minimum of the day). After that the number of views is increasing with slight drop at 8am (the usual time of commute time).  As for mobile_percentage, there is a day maximum at 1am, the hypothesis is it could be due to checking info before sleep using mobile phone. Then the mobile-percentage is less than 50% through the night, with 0 mobile views at 5-6am.
It might be that at this period most views are done by users that are in different time zones, users for which it is day (?).

The query was done like this:

```{SQL}

WITH
  views_data AS (
  SELECT
    hour_of_day,
    COUNT(views) AS total_views,
    COUNTIF(src="mobile") AS total_mobile_views
  FROM
     `econ250-2025.akryzhko.int_assignment3_uk_wiki`
  WHERE
    title = "Анна_Ярославна"
  GROUP BY
    hour_of_day )

SELECT
  hour_of_day,
  MOD(hour_of_day + 2, 24) as ukr_hour_of_day,
  total_views,
  total_mobile_views,
  FORMAT('%s%%', CAST(ROUND((views_data.total_mobile_views/views_data.total_views) * 100, 2) AS STRING)) as mobile_percentage
FROM
  views_data
ORDER BY ukr_hour_of_day ASC

```
