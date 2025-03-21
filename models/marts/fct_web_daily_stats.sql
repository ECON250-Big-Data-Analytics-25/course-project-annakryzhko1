SELECT 
date,
count(distinct fullVisitorId) as unique_visitors,
count(distinct visitId) as unique_visits,
count(distinct transaction.transactionId) as transaction_count,
sum(transaction.transactionRevenue)/ 1e6 as revenue_sum
 FROM {{source("test_dataset", "week5_web_visits")}}
 join {{ref('week5_transactions_deduplicated_view')}} using(date, visitId)
 group by 1
