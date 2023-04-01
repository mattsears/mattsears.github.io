---
layout: post
title: Using SQL to improve your Ruby code
date: 2023-03-31 00:00 +0000
---

I love refactoring Ruby code. One of the best ways to clean Ruby code is by leaning more on your
database for the work. You not only make the Ruby code more efficient, we can spread the work load
between our web servers and database servers <!--more--> It may sound obvious, but I can't count how
many times I've come across projects not utilizing the power of SQL.

Let's take a look at an example I've recently came across. I've simplified the example for the
purposes of brevity, but the idea is the same. This particular project is using a dashboard view
displaying recent sales data and comparing results from previous months.

~~~ruby
# app/controllers/dashboard_controller.rb

def index
  @current_sales = Orders.where(created_at: DateTime.now.all_month)
                         .select('SUM(total) as total_sales')

  @previous_sales = Orders.where(created_at: DateTime.now.last_month)
                          .select('SUM(total) as total_sales')
  ...
end
~~~

In our controller, we're retrieving the sales data from the current month and last month. It's
pretty simple, but note we're making two database queries to get the data we need. Now, let's take a look at
the view:

~~~erb
<table>
  <thead>
    <tr>
      <th>This Month's Sales</th>
      <th>Last Month's Sales</th>
      <th>Difference</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><%= @current_sales.total_sales %></td>
      <td><%= @previous_sales.total_sales %></td>
      <td>
        <%= number_to_percentage(
          ((@current_sales.total_sales - @previous_sales.total_sales) / @current_sales.total_sales * 100) %>
        )%>
      </td>
    </tr>
  </tbody>
</table>
~~~

Okay merge the pull request because we're done, right? _Wrong_. Although the above code solves the
business problem, we've created a few more problems down the road:

#### The Problem

  1. **It's slow**. As mentioned before, we have to make two queries to the database just for this
     calculation and we're using Ruby to do math which is slow.
  2. **It's not reusable**. If we want sales data somewhere else, we'll have to write new code.
  3. **It's limiting**. We only have this month and last month's data, but we know someone in the future is
     going want to see more.

#### SQL LAG function to the Rescue

Most popular databases have the `LAG()` function which gives us the ability look at the previous row
for comparing data to the current row. This is perfect since we need to see previous month's sales
data to be able to calculate a percentage increase or decrease.

Let's write our SQL code, but first, we're going to wrap our SQL query into a plain Ruby object so
that it's easier to test and re-use. In some cases, I like to organize SQL queries into it's own
directory like `/app/queries`.

~~~sql
# app/queries/sales_data_query.rb

class SalesDataQuery
  def self.monthly_sales_report
    sql_string = %Q{
      WITH sales AS (
        SELECT
          date_trunc('month', created_at)::date AS order_month,
          SUM(order.total) AS total_sales,
        FROM orders
        GROUP BY date_trunc('month', created_at)
      ),
      sales2 AS (
        order_month,
        total_sales,
        SELECT LAG(total_sales,1) OVER (ORDER BY "created_at") previous_total_sales
        FROM sales
      )
      SELECT
        order_month,
        total_sales,
        previous_total_sales,
        (100.0*(total_sales - previous_total_sales) / NULLIF(total_sales,0)) percent_diff
      FROM sales2
      ORDER BY "created_at" DESC
    }

    ActiveRecord::Base.connection.exec_query(sql_string)
  end
end
~~~

The SQL looks a little complicated, but it's doing a lot of work for us. It's adding up total sales
for this month and the previous months, plus it's calculating the percent difference - all in one
SQL statement. The results look like this:

~~~
order_month | total_sales | previous_total_sales | percent_diff
------------+-------------+----------------------+-------------
          1 |        2000 | 1099                 | 45.05
          2 |        1001 | 2200                 | -119.78
          3 |        3400 | 3000                 | 11.76
          4 |        9909 | 8920                 | 9.98
...
~~~

As you can see, we not only have this month and last, we have all the months in the database. Let's
go back to our code. In our controller, we make only one call to the database and we can loop
through the results in our view with no math calculations this time.

~~~ruby
# app/controllers/dashboard_controller.rb

def index
  @sales =  SalesDataQuery.monthly_sales_report
end
~~~

~~~erb
<table>
  <thead>
    <tr>
      <th>Month</th>
      <th>Sales</th>
      <th>% Difference</th>
    </tr>
  </thead>
  <tbody>
    <% @sales.each do |sale| %>
      <tr>
        <td><%= sales.month %></td>
        <td><%= sales.total_sales %></td>
        <td><%= number_to_percentage(sale.percent_diff)%></td>
      </tr>
    <% end %>
  </tbody>
</table>
~~~

Now this is a pull request we can approve!

This is just one example, but hopefully illustrates the point that knowing more about how utilizing
SQL queries can simplify your Ruby code and make your application run more efficiently. I encourage
you to take a closer look at the SQL language for your database of choice - there is a wealth of
power yet to be realized.
