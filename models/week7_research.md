# Unit testing in dbt

The unit testing support in dbt is relatively new. The feature was introduced in release 1.8 (May 2024). This could explain that there are a lot of constraints for unit tests.

From my previous experience, I would say that support for unit testing of macros is something that is really missing. Testing small bits of reusable logic is where unit tests are especially valuable. Now only testing of the models supported out of the box. There are some workarounds for macros though.

## Testing Calculations

As first step in practical research, I've looked through our previous models to identify the places that make sense to cover with unit tests. According to recommendations, complex math calculations, transformations with regular expressions and window functions are the first candidates.

The first unit test was done for ukrainian wiki pages model. There we make calculations if the page is meta page using regular expression. It is also very convenient that there are examples in task description that we can use as input data. The resulting test is in [int_assignment3_uk_wiki_tests.yml](./tests/int_assignment3_uk_wiki_tests.yml). It was pretty straightforward, the test description looks clear and could be part of documentation efforts.

## Incremental

I've decided to choose something different for the next attempt. Dbt documentation has example with incremental model, unit tests allow us to test the condition inside its incremental block. This test case sounds really useful.
So, I chose model created during seminars *fct_week6_landing_page* and created test for it. The result is in this file
[fct_week6_landing_page_test.yml](./tests/fct_week6_landing_page_test.yml). 

There were several issues during implementation because of data types. But at the end, unit test has passed.
If I did code review for myself, I would say that there are too many unimportant data in mocked data. For example, if we look at the data mocked for data source of week5_hits, it looks like this:

```{yml}
    rows:
          - { visitId: 1, hitNumber: 1, date: 2020-01-01,
            page: 'struct("" as pagePath, "" as hostname, "" as pageTitle)' }
          - {visitId: 2, hitNumber: 1, date: 2025-03-30,
            page: 'struct("" as pagePath, "" as hostname, "" as pageTitle)' }
          - { visitId: 3, hitNumber: 1, date: 2025-03-31,
            page: 'struct("" as pagePath, "" as hostname, "" as pageTitle)' }
```
You can see hitNumber here that is checked in WHERE, so we need it for the unit test. also struct page looks very verbose. It is related to one of the current dbt constraints, quote from documetation:

> You must specify all fields in a BigQuery STRUCT in a unit test. You cannot use only a subset of fields in a STRUCT.

So, though hostname and pageTitle are not even mentioned at the model, test return error without them.

So, can we do better?

## testing incremental 2 + ephemeral

Our main goal was not to test the pagePath, but incremental behavior. So, the logical step is to separate concerns, to make incremental part in the different model than pagePath extraction.
As we do not need the model responsible for filtering the data by hitNumber and pagePath extraction to be materialized as table or view, I've decided to do it ephemeral.  So, the result are in 2 files:

- [fct_week7_landing_page_ephemeral](./marts/fct_week7_landing_page_ephemeral.sql)

- [fct_week7_landing_page_final.sql](./marts/fct_week7_landing_page_final.sql)

From documentation:
>Incremental models need to exist in the database first before running unit tests or doing a dbt build.

So, I've built the model successfully and started with unit testing.

The next caveat is that now model for testing depends on ephemeral model, and there is additional constraint mentioned in documentation:

> If you want to unit test a model that depends on an ephemeral model, you must use **format: sql** for that input.

It means that my sample data is not that easily readable and it is not that easily compared to out out.

SQL format:

```{yml}
  rows: |
          select 1 as visitId, CAST('2020-01-01' AS DATE) AS date union all
          select 2 as visitId, CAST('2025-03-30'AS DATE) AS date union all
          select 3 as visitId, CAST('2025-03-31' AS DATE) AS date
```

Json format:

```{json}
 rows:
        - { visitId: 2, date: 2025-03-30 }
        - { visitId: 3, date: 2025-03-31 }
```

I would say that it is serious issue for unit tests readability.

By the way, unit testing incremental behavior also has helped me to understand that I understood incorrectly the incremental condition (!).
After it has failed, I started investigate and has found the true meaning of the condition.

**Note.** There is a possibility to specify given/expected data in the separate file, but I think it is also not good for readability, unit tests should be readable.

## Documentation

After adding unit tests, I've checked generated documentation. Right now, documentation contains links to unit tests that reference a model. Also, it contains description if it was added as a field to yml-file. It is convenient especially for those who are unfamiliar with a codebase.

As a side note, declarative description of unit tests in *yml* could allow to add input/expected results to documentation too, something to look for in the future.


## Conclusion

It was interesting experience to try unit testing in dbt. A lot of it was familiar experience (running tests from command line, fast feedback, how results are reported). Description in *yml* format for unit tests makes input/expected data more visible, as for me, they are in main roles here.

 What is hopefully changes in next releases is adding new features, especially possibility to test macros, more universal way to declare the data for input/output, extended documentation.


 ## Presentation  

 [Presentation link](https://www.canva.com/design/DAGjYPaAizI/v72VbMqPTyv6-ZtgYAhx8Q/edit?utm_content=DA[…]m_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

 
