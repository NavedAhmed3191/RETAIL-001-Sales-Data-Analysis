Select
	count(*) As Total_Orders,
	sum(sales) as Total_Sales,
	sum(profit) AS Total_Profit,
	sum(Quantity) AS Total_Quantity,
	Round(avg(Sales),2) AS Average_Sales,
	min(Sales) as Min_Sales,
	Max(Sales) AS Max_sales
from sales_data;

Select
	sum(profit) AS Total_Profit,
	sum(sales) AS Total_Sales,
	Round((Sum(profit)::Numeric / sum(sales)) * 100,2) AS Overall_Profit_Margin
from sales_data

--Which product category generates the highest profit?

Select
	category,
	sum(profit) AS Total_Profit,
	sum(sales) AS Total_Sales
from sales_data
group by category
order by Total_Profit desc;

--Calculate category-wise profit margin

Select
	category,
	sum(profit) AS Total_Profit,
	sum(sales) AS Total_Sales,
	Round((Sum(Profit)::Numeric/Sum(Sales))*100,2) AS Profit_Margin
from sales_data
group by category
order by Total_Profit desc;


--How do sales and profits change month by month?

Select
	DATE_TRUNC('month', order_date) AS sales_month,
	sum(sales) AS total_sales,
	sum(profit) AS total_profit,
	sum(Quantity) AS total_quantity,
	count(order_id) AS total_orders
from sales_data
group by DATE_TRUNC('month', order_date)
order by sales_month;


SELECT
    product,
    category,
    SUM(quantity) AS total_quantity,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM sales_data
WHERE EXTRACT(MONTH FROM order_date) = 12
GROUP BY product, category
ORDER BY total_sales DESC;


SELECT
    category,
    SUM(quantity) AS total_quantity,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(profit) * 100.0 / NULLIF(SUM(sales), 0), 2
    ) AS profit_margin_pct
FROM sales_data
WHERE EXTRACT(MONTH FROM order_date) = 12
GROUP BY category
ORDER BY total_sales DESC;

SELECT
    product,
    SUM(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 5
        THEN sales ELSE 0
    END) AS may_sales,

    SUM(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 12
        THEN sales ELSE 0
    END) AS december_sales,

    SUM(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 5
        THEN sales ELSE 0
    END)
    -
    SUM(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 12
        THEN sales ELSE 0
    END) AS sales_difference

FROM sales_data
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY product
ORDER BY sales_difference DESC;


SELECT
    product,

    SUM(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 5
        THEN quantity ELSE 0
    END) AS may_units,

    SUM(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 12
        THEN quantity ELSE 0
    END) AS december_units,

    COUNT(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 5
        THEN order_id
    END) AS may_orders,

    COUNT(CASE
        WHEN EXTRACT(MONTH FROM order_date) = 12
        THEN order_id
    END) AS december_orders

FROM public.sales_data
WHERE EXTRACT(YEAR FROM order_date) = 2025
GROUP BY product
ORDER BY may_orders DESC;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_rows
FROM sales_data;



SELECT
    product,
    EXTRACT(MONTH FROM order_date) AS month_number,
    COUNT(order_id) AS total_orders,
    SUM(quantity) AS total_units,
    SUM(sales) AS total_sales

FROM public.sales_data

WHERE product IN ('Laptop', 'Mobile', 'Bag', 'Notebook')

GROUP BY
    product,
    EXTRACT(MONTH FROM order_date)

ORDER BY
    product,
    month_number;


	SELECT
    EXTRACT(MONTH FROM order_date) AS month_number,
    COUNT(order_id) AS total_orders,
    SUM(quantity) AS total_units,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit

FROM public.sales_data

GROUP BY EXTRACT(MONTH FROM order_date)

ORDER BY month_number;



select
    to_char(order_date, 'Month') as month,
	count(distinct order_id) as total_orders,
    round(sum(sales)::numeric, 2) as total_sales,
    round(sum(profit)::numeric, 2) as total_profit,

    round(
        sum(sales)::numeric / count(distinct order_id),
        2
    ) as average_order_value,

    round(
        (sum(profit)::numeric / sum(sales)) * 100,
        2
    ) as profit_margin_pct

from sales_data

group by extract(month from order_date),
         to_char(order_date, 'Month')

order by extract(month from order_date);



select
    to_char(order_date, 'Month') as month,
    product,
    sum(quantity) as total_quantity,
    round(sum(sales)::numeric, 2) as total_sales,
    round(sum(profit)::numeric, 2) as total_profit,
    round(
        (sum(profit)::numeric / sum(sales)) * 100,
        2
    ) as profit_margin_pct

from sales_data

where extract(month from order_date) in (5, 12)

group by
    extract(month from order_date),
    to_char(order_date, 'Month'),
    product

order by
    extract(month from order_date),
    total_profit desc;



select
    product,

    sum(sales) filter (
        where extract(month from order_date) = 5
    ) as may_sales,

    sum(profit) filter (
        where extract(month from order_date) = 5
    ) as may_profit,

    sum(sales) filter (
        where extract(month from order_date) = 12
    ) as december_sales,

    sum(profit) filter (
        where extract(month from order_date) = 12
    ) as december_profit

from sales_data

where extract(month from order_date) in (5, 12)

group by product

order by may_profit desc;



select
    product,

    coalesce(sum(sales) filter (
        where extract(month from order_date) = 5
    ), 0) as may_sales,

    coalesce(sum(profit) filter (
        where extract(month from order_date) = 5
    ), 0) as may_profit,

    coalesce(sum(sales) filter (
        where extract(month from order_date) = 12
    ), 0) as december_sales,

    coalesce(sum(profit) filter (
        where extract(month from order_date) = 12
    ), 0) as december_profit

from sales_data

where extract(month from order_date) in (5, 12)

group by product

order by may_profit desc;


with product_performance as (
    select
        product,

        coalesce(sum(profit) filter (
            where extract(month from order_date) = 5
        ), 0) as may_profit,

        coalesce(sum(profit) filter (
            where extract(month from order_date) = 12
        ), 0) as december_profit

    from sales_data

    where extract(month from order_date) in (5, 12)

    group by product
)

select
    product,
    may_profit,
    december_profit,

    december_profit - may_profit as profit_change,

    round(
        ((december_profit - may_profit)::numeric
        / nullif(may_profit, 0)) * 100,
        2
    ) as profit_change_pct

from product_performance

order by profit_change asc;



with product_performance as (
    select
        product,

        coalesce(sum(profit) filter (
            where extract(month from order_date) = 5
        ), 0) as may_profit,

        coalesce(sum(profit) filter (
            where extract(month from order_date) = 12
        ), 0) as december_profit

    from sales_data

    where extract(month from order_date) in (5, 12)

    group by product
),

profit_analysis as (
    select
        product,
        may_profit,
        december_profit,
        december_profit - may_profit as profit_change

    from product_performance
)

select
    product,
    may_profit,
    december_profit,
    profit_change,

    case
        when profit_change > 0 then 'Improved'
        when profit_change < 0 then 'Declined'
        else 'No Change'
    end as performance_status

from profit_analysis

order by profit_change asc;


with product_performance as (
    select
        product,

        coalesce(sum(profit) filter (
            where extract(month from order_date) = 5
        ), 0) as may_profit,

        coalesce(sum(profit) filter (
            where extract(month from order_date) = 12
        ), 0) as december_profit

    from sales_data

    where extract(month from order_date) in (5, 12)

    group by product
),

classified_products as (
    select
        product,

        case
            when december_profit > may_profit then 'Improved'
            when december_profit < may_profit then 'Declined'
            else 'No Change'
        end as performance_status

    from product_performance
)

select
    performance_status,
    count(*) as total_products,

    round(
        count(*) * 100.0 / sum(count(*)) over (),
        2
    ) as percentage

from classified_products

group by performance_status
order by percentage desc;



select
    category,

    sum(sales) filter (
        where extract(month from order_date) = 5
    ) as may_sales,

    sum(profit) filter (
        where extract(month from order_date) = 5
    ) as may_profit,

    round(
        (sum(profit) filter (
            where extract(month from order_date) = 5
        ) / nullif(sum(sales) filter (
            where extract(month from order_date) = 5
        ), 0)) * 100,
        2
    ) as may_margin,

    sum(sales) filter (
        where extract(month from order_date) = 12
    ) as december_sales,

    sum(profit) filter (
        where extract(month from order_date) = 12
    ) as december_profit,

    round(
        (sum(profit) filter (
            where extract(month from order_date) = 12
        ) / nullif(sum(sales) filter (
            where extract(month from order_date) = 12
        ), 0)) * 100,
        2
    ) as december_margin

from sales_data

where extract(month from order_date) in (5, 12)

group by category

order by may_profit desc;


with category_profit as (
    select
        category,

        sum(profit) filter (
            where extract(month from order_date) = 5
        ) as may_profit,

        sum(profit) filter (
            where extract(month from order_date) = 12
        ) as december_profit

    from sales_data

    where extract(month from order_date) in (5, 12)

    group by category
)

select
    category,
    may_profit,
    december_profit,

    round(
        may_profit * 100.0 /
        sum(may_profit) over (), 2
    ) as may_profit_contribution_pct,

    round(
        december_profit * 100.0 /
        sum(december_profit) over (), 2
    ) as december_profit_contribution_pct

from category_profit

order by may_profit desc;



select
    count(*) as total_records,
    count(distinct order_id) as total_orders,

    round(sum(sales)::numeric, 2) as total_sales,

    round(sum(profit)::numeric, 2) as total_profit,

    round(
        (sum(profit)::numeric / sum(sales)) * 100,
        2
    ) as overall_profit_margin

from sales_data;