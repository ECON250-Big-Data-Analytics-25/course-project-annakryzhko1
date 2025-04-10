# Step-By-Step

This is document for implementation details  of the final project.

## Part 1. Data Importing to Google BigQuery

*Note*. Conclusions from this part were corrected later.

Data importing was done the same way for all files with uploading from csv-files and schema autodetection. No serious issues detected.
The minor issue is some spelling of some columns, like **product_name_lenght**, it could lead to some confusion later. But as the columns do not look like something that is valuable for further tasks I've decided to left them as it is. 

The first impression is that table **fp-products** has the most missing values among all tables. It is also not very informative, no product names, only ids and number of characters in the name. My assumprion it is done for anonymization, so no one can link products to sellers.

### sellers

**fp-sellers** has issues with city names, there are different names for sao paulo like sp / sp, sao paulo sp, sao paulo - sp, são paulo etc.  I've looked through the city names using this sql query:
```{sql}
SELECT seller_city, seller_state 
FROM `econ250-2025.akryzhko.fp_sellers`
group by seller_city, seller_state
order by seller_state, seller_city
```
As I'm not familiar with brasilian cities, I've consulted with chatgpt, where I've suspected misspelling or wrongness.

It looks like the city name was typed manually and has a lot of errors.

You can check the [full list of issues](./seller_city_names.md) found by me. In summary, there are several patterns like:
- city / state
- city state
- city \ state
- city/state
- city - state
- city, state
- city, state, country

Where we can do cleaning for all rows the same way. 
Also, it is related to two witespaces.

<!-- trunk-ignore(markdownlint/MD034) -->
There is also obiusly incorrect data like - vendas@creditparts.com.br or 04482255. We can include some regexp testing to remove such values as not correct. Then we should replace the city name with not specified or none.

If we need the correct data for stakeholders about sellers divided by city, then we also should correct all misspellings. There are a lot of them.

Some issues were dicovered later, I've missed some of the data issues. I've decided to describe them in chronological order, they will have mark **exploratory analysis issue**.


## Part 2. Source Definitions in dbt 

After decsribing the first table using copy paste to include all columns decription and adding tests, it does look a bit slow to me.
I've decided to use chatGPT to format the initial column listing in yml format with descriptions. If AI is good at something, it is at routine work like that. 

For the first table it was in several steps:

1. Schema copied from bigquery ui

>chatGPT request: form dbt source description for this schema in yml format

2. Description copied from the kaggle site:

>chatGPT request: add columns description  to it (unique values description is not required)

This task was done fast by chatGPT and save a lot of time for me.

For the next tables it was enough to ask for the same output and give it the description from kaggle.

### Data tests for sources

The data tests were added manually. It allowed me to get familiar with the dataset better, ask myself about characteristics of each column. Are null values allowed? Are values unique in dataset? 

Using diagram with relations for datasets from the task, 
I've added also all relationships that are present in the diagram between the chosen sets. There were no issues with keys except for category names.

Also, I've added accepted values for columns that are dictionary columns like payment type or order status.

Table **fp-products** has almost no tests, because of a lot of missing values.

What I've missed on step 1, is that column names in translation table with autodetect schema were generic, not the correct names. After writing the table columns description and data tests for that table, there were errors during testing that helped me to discover this.
So, I've changed table column names, like this:

```{sql}
ALTER TABLE `econ250-2025.akryzhko.fp_product_category_name_translation`
  RENAME COLUMN string_field_0 TO product_category_name;
```

After failing relationship tests between fp_products and fp_product_category_name_translation, I've checked what are the issues by comparing the list of values from two table, using full join like this:

```{sql}
with categories as (
  select distinct product_category_name
  from `econ250-2025.akryzhko.fp_products`
)

SELECT pr.product_category_name, tr.product_category_name_english
FROM categories as pr
FULL OUTER JOIN `econ250-2025.akryzhko.fp_product_category_name_translation` as tr ON tr.product_category_name = pr.product_category_name
```
The category translation for **pc_gamer** was missing. Also, the table column names were values inside translation table **product_category_name_english**.
No translation for **portateis_cozinha_e_preparadores_de_alimentos**.
And the last one, the products table contains a lot of null in category column.
So the fixes are:
```{sql}
-- deleting row with column names
delete from `econ250-2025.akryzhko.fp_product_category_name_translation` 
where product_category_name = "product_category_name"

-- adding translation
insert into  `econ250-2025.akryzhko.fp_product_category_name_translation` 
(product_category_name, product_category_name_english )
values("portateis_cozinha_e_preparadores_de_alimentos","portable_kitchen_and_food_preparators") 

-- adding trnslation for pc_gamer

insert into `econ250-2025.akryzhko.fp_product_category_name_translation` 
(product_category_name, product_category_name_english )
values("pc_gamer","pc_gamer")
```
The existence of NULL in the *fp_products* is mot a problem for relationship test. 

So, all 45 tests are green, I can proceed further.

## Part 3: Staging models in dbt 
At this stage, I decided to start from perithery, and go to child models, to check referential integrity as soon as the model is done. 

### fp_stg_product_category_name

Some cleaning was done in previous step for this model.

I've removed column **product_category_name_english** and added two derived columns here: 'en', 'pt' with proper category name in corresponding language that can be shown in UI for users, including in our dashboards. Values are received by replacing _ for whitespace and capitalization of first letter in each word. 

The solution is not ideal, it is prone to issues like having words as "Pc", "Dvd" that should be in upper case shown capitalized.

To resolve the issue, we can either capitalize all letters, or decide that it requires manual fixes. I don't like the idea of uppercase transformation, as it makes text less readable. So, let's just decide that we've planned the professional translators to check and fix the values.

Also, new category *(nenhum)/(none)* was added, for all products that have null as category in **fp_products** table. 

## fp_stg_products
This is the table that contains the most "depleted" data, there is no product names, or product descriptions only number of characters. Also there are a lot of missing values. So, the first question that we should ask, what is valuable for our later analysis to work primarily to provide that data. 

We already no that there is no duplicates by product_id from our data tests in previous part.

So, I think the most interesting for the further analysis is product category. The only issue with that data is that there are null valuess, so I've decided to use *(nenhum)/(none)* category for them.

Other data has secondary interest for us. 
They are grouped into 2 structs: product_description (description length, product name length, number of photos) and product_measurements (width, length, height, width).  
Grouping for product measurements is done because I believe you rarely need length separated from width, either in UI or in calculations of freight, they are used together.
As for product_description, right now the data there is not really valuable, so let's group it together with fixing some naming issues mentioned in part 1 (lenght > length).

I'm not going to handle NULL values except for photos, as it easy for them, if null, then there is 0 photos. 

## fp_stg_sellers
In this model, the main focus on cleaning data for seller_city. I've used unit tests to write down the transformation, this is the classical case for unit testing. 

I've done string transformations and mapping the misspelled values with jinja templates.

After fixing all the found issues from Part 1, the number of different cities reduced from 631 to 594, the naming was unified.

**Exploratory Analysis Issue: seller_zip_code_prefix**. Another issue was discovered for *seller_zip_code_prefix*. I've used when using schema autodetect mechanism. It recognized the type as integer for that column, then values liks "01234" where converted to integer and the final value become 1234, first zero is lost. So, I've decided to redo the table with schema created manually. After that, I've run the tests created in Part 2 for sources. And one test failed! The row with column names were added as row with schema created manually, and value seller_state was not among accepted values for state. Work done in previous step helped a lot.
I've deleted the row from initial source table.

Now, the data looks good in this view.

### fp_stg_customers

I've started by checking the customer_city column. But it is clear that thic column does not repeat the issues from seller dataset. It contains much more cities, so to check all of them difficult, after looking in sevreal pages and no issues detected, I've done some checks like this:

```{sql}
SELECT distinct customer_city, customer_state FROM `econ250-2025.akryzhko.fp_customers` 
where customer_city like "sao%"
group by customer_city, customer_state
order by customer_state, customer_city

```
No issues with sao paulo, no special characters or numbers, no slashes.
It looks like no work is required. For state, there is already a test that checks accepted values and it is green.

Table contains the same issue with zip code as sellers. But as I do need it for further investigation, and the fix is the same, I've decided to skip it.

So, stg model just repeats all columns as is and is ready if I need it later for extension.

### ft_stg_order_payments

**Exploratory Analysis Issue: seller_zip_code_prefix**. 
There are some outliers in data when you are checking by payment type:

- payment type credit card: only 2 payments is the whole database with payment installment 0. Although, we can assume that it is paying upfront, as it is so rare, it could be the incorrect data. Decision to fix it with 1.

- payment type boleto: only one order_id that has payment sequential 2, and 1 is missing. It looks like we should change it to 1 (931a32b4ca3fdc36741af29ea645d8bf).

Similar:

- 2 orders with  order_id =744bade1fcf9ff3f31d860ace076d422 and
    order_id = 1a57108394169c0b47d8f876acc9ba2d where payment sequential is 2 and the 1 does not exist. The payment amount is the same as the price of the bought product + freight.
 So we can set payment_sequential to 1 in this case.


 After some research, I've found 80 such rows where the payments_sequential starts from 80:

 ```{sql}
 with agg_sequential as (
SELECT order_id, 
array_to_string(array_agg(cast(payment_sequential as string) order by payment_sequential), ",") as sequential,
array_agg(payment_sequential order by payment_sequential) as int_sequential
FROM `econ250-2025.akryzhko.fp_order_payments` 
group by order_id
order by order_id
), array_sequential as (
  select STRING_AGG(CAST(num AS STRING), ",") as gen FROM UNNEST(generate_array(1,36)) as num
)
select 
order_id,
sequential,
gen,
STRPOS(gen, sequential) as pos
from agg_sequential
cross join array_sequential
where int_sequential[0] != 1 or STRPOS(gen, sequential) = 0
 ```

 Most of them has only one payment, and several that have payments 2,3.

 I can skip fixing this issue for now, but it is better to understand for further analysis.

 At the end clustered by order_id table was created, with minor cleaning.
 
 ### fp_stg_order_items

 In this case, I've decided to create table with clustering by order_id, and add derived column total_amount that is the sum of price and freight per item, as this sum should be paid by the customer.

 ## fp_stg_orders

**Exploratory Analysis Issue: fp_stg_orders dates**. 

If we check the dates there are some unexpected relations for some of them, like there are 61 result when the order was delivered earlier than it was approved:

```{sql}
SELECT
  *
FROM
  `econ250-2025.akryzhko.fp_orders`
where  order_approved_at > order_delivered_customer_date
```
I should be careful if finding average delivery time where time differences are used, they could be negative.
But these results are rare, so I'm not going to fix it at the moment.

**Exploratory Analysis Issue: fp_stg_orders statuses**. 

There are 6 orders that has status canceled but were paid and delivered:

```{sql}
SELECT
  array_agg(order_id)
FROM
  `econ250-2025.akryzhko.fp_orders`
where order_status = "canceled"  and order_delivered_customer_date is not null
```
```{sql}
select 
* FROM `econ250-2025.akryzhko.fp_order_payments` 
where order_id in unnest(["65d1e226dfaeb8cdc42f665422522d14", "770d331c84e5b214bd9dc70a10b829d0", "dabf2b0e35b423f94618bf965fcb7514", "8beb59392e21af5eb9547ae1a9938d06", "2c45c33d2f9cb8ff8b1c86cc28c11c30", "1950d777989f6a877539f53795b4c3c3"])
```
Not clear how it should be calculated when calculating sales (?).
Some orders were delivered to carrier but there is no data that it is delevered to customer.
________________________________

Now back to staging. 
Let's add several columns for the most relevant order statuses except unavailable:
- is_canceled
- is_shipped
- is_delivered

And time differences:

For customer is important order_purchase_timestamp, and order_estimated_delivery_date. So we can calculate difference between time when order was delivered and when it was estimated.

To evaluate the sellers we can use diff between  order_approved_at and purchasing time and order_delivered_carrier_date and purchasing time.

Let's name all these columns like diff_approved_purchased
Also, I will add column is_delivered_before_estimated 

## Part 4: Integrated Data Model 

I've partitioned table by order_purchase_timestamp. Each order has order purchase date, so there is no null values in this column. Also, all other dates/timestamps columns are happening later. For me, it looks like this column is the most appropriate for partitioning. I've chosen month granularity (this dataset does not contain a lot of daily data, so I've decided to choose month granularity).

There was issue with partitioning at first, there were 0 rows. The reason was partition_expiration_days set to 60 by default and data in the dataset is pretty outdated (2016-2021). So. I've tried to set expiration date to null, this setting works from big query, but I've had issues with dbt.
Finally, I just chose 20 years as inspiration date and that way proper partitioning was done for the table.

I've added clustering by order_status column. Not all statuses look useful, but some of them are crusial for analysis like canceled, delivered.

All tables were combined to the new model. The whole columns model described in [fp_sales_full_model](models/staging/fp_sales_full_model.yml). Also, I've added columns order_payment_total that is the sum of all payments related to order, and order_total_amount the sum of prices and delivery of ordered items.

## Part 5: Analytical Mart Models 
Three models were implemented in scope of this work.

### Sales stats

Model name: [fp_fct_sales_stats](models/marts/fp_fct_sales_stats.sql)

It allows to look at the big picturee, sales numbers across the platform calculated by year and month. I've also calculated YoY changes in the numbers.

I've cropped the period for analysis from the start of 2017 till the september 2018, as several months before and after were not representative.

Insights:

- hyper growth at first, but marginal growth is diminishing from month to month

- order count and total amount of revenue is growing approximately at the same rate

- median order total is stable during the period, that is not good, as it is in nominal values, median order total slightly decreasing

- paid mean is higher than ordered mean, it could be explained by customer's choosing to pay in installments (interest payments) - this is the conclusion done after checking the data in sales_full with filtering.

### sellers analytics

Model name: [fp_fct_seller_analytics](models/marts/fp_fct_seller_analytics.sql)

It allows to see the most "productive" sellers, theirs median order total, canceled orders percentage, and also how fast orders are approved and shipped. Also the resulting delivery to estimated date difference.

Insights:
- not a lot of big sellers on the platform,
the 50th seller has 314 orders for the whole period.
- delivery to estimated date median is negative for all sellers, that indicated that estimated date chosen to cautios, that can discorauge "impatient" customers

### payment type usage by state

Model: [fp_fct_payment_type_usage_by_state.sql](models/marts/fp_fct_payment_type_usage_by_state.sql)

It contains data about percent of usage of each payment type split by state and year. I've experimented with pivoting here. Not sure that representation is perfect for reading.

Insigts:
- credit card is leader in all states
- second place is by boleto
- significant spike in voucher usage in TO state in 2018

## Part 6: Testing and Documentation

**persist_docs** declaration is already in included dbt_project.yml.
So all descriptions are already added to bigquery.

### Custom data tests

1. I've found the issue with zip_code_prefix in two tables for sellers and customers, for sellers it was fixed, for customers there are still incorrect value with 4 digits code. Ideal case for custom generic data test.

test: [test_is_correct_zip_code](../macros/tests/test_is_correct_zip_code.sql)

I'm checking with regular expression that value contains 5 digits. I've added the test to model description, only for customers set severity to warning.

2. Custom data test that validates that number or orders in fp_sales_full table is the same as the sum of all orders in my first mart fp_fct_sales_stats. To make it work,  I've created fp_fct_sales_stats_all.sql as the initial mart cropped the first months and last months due to data issues. fp_fct_sales_stats_all.sql shows all the months, so I'm essentially checking that rows count in fp_sales_full coincides with the sum of orders counts from each month in mart.

There were an issue, because I've tried to add it to models/tests where my unit tests are located. But dbt cannot find it there, so now it is in /tests folder. Also, the test was added to /tests/schema.yml.

test: [assert_total_num_of_orders_coincides](../tests/assert_total_num_of_orders_coincides.sql)
































