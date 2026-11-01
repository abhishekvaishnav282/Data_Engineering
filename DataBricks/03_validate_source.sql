SELECT 'customers' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[customers]
UNION ALL
SELECT 'customer_addresses' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[customer_addresses]
UNION ALL
SELECT 'employees' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[employees]
UNION ALL
SELECT 'orders' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[orders]
UNION ALL
SELECT 'order_items' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[order_items]
UNION ALL
SELECT 'payments' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[payments]
UNION ALL
SELECT 'returns' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[returns]
UNION ALL
SELECT 'return_items' AS table_name, COUNT_BIG(*) AS row_count FROM [retail_demo].[return_items];

SELECT (SELECT SUM(total_amount) FROM retail_demo.orders) AS order_revenue, (SELECT SUM(line_amount) FROM retail_demo.order_items) AS line_revenue;
