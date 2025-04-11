# Assignment 5

## part 1. insert_overwrite
First run: 

dbt logs:
```{bash}
06:21:46  1 of 1 START sql incremental model akryzhko.fct_assignment5_totals ............. [RUN]
06:21:53  1 of 1 OK created sql incremental model akryzhko.fct_assignment5_totals ........ [CREATE TABLE (2.4m rows, 439.8 MiB processed) in 6.56s]
```

| #  | Date                  | Value | Timestamp                        |
|----|-----------------------|--------|----------------------------------|
| 1  | 2025-04-01 00:00:00 UTC | 15348 | 2025-04-11 06:21:47.407167 UTC |
| 2  | 2025-04-02 00:00:00 UTC | 15471 | 2025-04-11 06:21:47.407167 UTC |
| 3  | 2025-04-03 00:00:00 UTC | 14804 | 2025-04-11 06:21:47.407167 UTC |
| 4  | 2025-04-04 00:00:00 UTC | 14029 | 2025-04-11 06:21:47.407167 UTC |
| 5  | 2025-04-05 00:00:00 UTC | 13278 | 2025-04-11 06:21:47.407167 UTC |
| 6  | 2025-04-06 00:00:00 UTC | 14028 | 2025-04-11 06:21:47.407167 UTC |

```{bash}
06:43:36  1 of 1 START sql incremental model akryzhko.fct_assignment5_totals ............. [RUN]
06:43:50  1 of 1 OK created sql incremental model akryzhko.fct_assignment5_totals ........ [SCRIPT (244.1 MiB processed) in     ]
```

| Row | Date                  | Views | Insert Time                     |
|-----|-----------------------|--------|----------------------------------|
| 1   | 2025-04-01 00:00:00 UTC | 15348 | 2025-04-11 06:21:47.407167 UTC |
| 2   | 2025-04-02 00:00:00 UTC | 15471 | 2025-04-11 06:21:47.407167 UTC |
| 3   | 2025-04-03 00:00:00 UTC | 14804 | 2025-04-11 06:21:47.407167 UTC |
| 4   | 2025-04-04 00:00:00 UTC | 14029 | 2025-04-11 06:21:47.407167 UTC |
| 5   | 2025-04-05 00:00:00 UTC | 13278 | 2025-04-11 06:43:38.283094 UTC |
| 6   | 2025-04-06 00:00:00 UTC | 14028 | 2025-04-11 06:43:38.283094 UTC |

## part 2. Merge strategy
```{bash}
06:48:11  1 of 1 START sql incremental model akryzhko.fct_assignment5_lookup ............. [RUN]
06:48:18  1 of 1 OK created sql incremental model akryzhko.fct_assignment5_lookup ........ [CREATE TABLE (928.8k rows, 439.8 MiB processed) in 7.00s]
```

| Rank | Title                                | Value |
|------|--------------------------------------|-------|
| 1    | Minecraft:_Фільм                     | 8876  |
| 2    | Фільмографія_Тома_Круза              | 711   |
| 3    | Фільмографія_Бреда_Пітта             | 669   |
| 4    | Фільмографія_Тома_Генкса             | 659   |
| 5    | Фільмографія_Роберта_Де_Ніро         | 543   |
| 6    | Фільмографія_Джекі_Чана              | 506   |
| 7    | Фільмографія_Метта_Деймона           | 465   |
| 8    | Фільмографія_Джонні_Деппа            | 444   |
| 9    | Фільмографія_Двейна_Джонсона         | 407   |
| 10   | Фільмографія_Леонардо_Ді_Капріо      | 400   |

```{bash}
06:55:54  1 of 1 START sql incremental model akryzhko.fct_assignment5_lookup ............. [RUN]
06:56:06  1 of 1 OK created sql incremental model akryzhko.fct_assignment5_lookup ........ [MERGE (557.0k rows, 200.0 MiB processed) in 12.83s]
```
New result

| Rank | Title                                | Value |
|------|--------------------------------------|-------|
| 1    | Minecraft:_Фільм                     | 4681  |
| 2    | Фільмографія_Тома_Круза              | 349   |
| 3    | Фільмографія_Бреда_Пітта             | 301   |
| 4    | Фільмографія_Тома_Генкса             | 296   |
| 5    | Фільмографія_Роберта_Де_Ніро         | 220   |
| 6    | Фільмографія_Джекі_Чана              | 220   |
| 7    | Фільмографія_Метта_Деймона           | 209   |
| 8    | Фільмографія_Джонні_Деппа            | 205   |
| 9    | Фільмографія_Двейна_Джонсона         | 195   |
| 10   | Фільмографія_Леонардо_Ді_Капріо      | 175   |


## part 3

### performance comparison

| Strategy         | First Run | Second Run |
|------------------|-----------|-------------|
| Insert Overwrite | 6.56s     | 14.03s      |
| Merge            | 7.00s     | 12.83s      |


| Strategy         | First Run Amount           | Second Run Amount             |
|------------------|----------------------------|-------------------------------|
| Insert Overwrite | 2.4m rows, 439.8 MiB       | 244.1 MiB processed           |
| Merge            | 928.8k rows, 439.8 MiB     | 557.0k rows, 200.0 MiB        |


if we compare time, the first run for both strategies takes approximately the same time.
The second un takes more time (~10%) for insert_overwrite. And comapring first run to second, second run takes twice as much time as the first one (7s vs 13-15s).

If we look at the amount of data processed, the first run it is the same for both strategies.
The second run has processed less amount of data (~20%) for merge strategy.

The efficiency of incremental models in this case are seen mostly in amount of data processed that is important as BigQuery charges for this. 
Our initial table contains data only for 6 days and our increments should update data for two days, we already see significant gains in amount of data, if the periods are longer the ratio of the data processed on the first run and consequent runs will be even higher.

### data accuracy analysis

Why when using merge strategy and aggregated fields we recieve different results on first and second run?

We can check on the initial table if we recieve the same results when data is filtered for the last two days, like that:

```{sql}
SELECT 
title,
date_trunc(min(datehour), day) as min_date,
date_trunc(max(datehour), day) as max_date,
sum(views) as total_views
 FROM `econ250-2025.test_dataset.assignment5_input` 
WHERE TIMESTAMP_TRUNC(datehour, DAY) >= TIMESTAMP("2025-04-05") and  title like '%Фільм%'
group by title
order by total_views desc
limit 10
```
Results of this request matches to what we can see in the second run results for the merge strategy.

It explains that it is dangerous to make aggregations in incremental model, as it aggregates only on filtered by incemental condition data.

In production env, you should avoid using aggregated fields with merge strategy. I guess it is possible to do with insert_overwrite and partitioning if we do aggregation for time that is less or equal to one partition period, and we replace 2 last partitions to be on the safe side. For example, monthly aggregations are possible if our partitions are monthly, and we replace partitions on increment for last 2 months.

### strategy selection

We have performance data on different queries run on the same dataset, so it might be hard to do some recommendation based on this. 

Based on our lectures material, insert_overwrite strategy is best for partitioned tables with append-only strategies. If there is table that requires updates to existing rows, then merge. But as we have seen from the example, you should be careful with aggregated columns in this case, as it aggregates only filtered data.





