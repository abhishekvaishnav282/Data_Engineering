-- Azure SQL / SQL Server T-SQL. Run against your chosen development database.
-- Uses retail_demo schema; the deployed source uses dbo. Change schema only in an empty database.
IF SCHEMA_ID(N'retail_demo') IS NULL EXEC(N'CREATE SCHEMA [retail_demo]');
GO

-- One customer: Transactional customer master. Email addresses are synthetic and use example.invalid.
IF OBJECT_ID(N'retail_demo.customers',N'U') IS NULL
CREATE TABLE [retail_demo].[customers] (
    [customer_id] INT NOT NULL PRIMARY KEY,
    [first_name] NVARCHAR(256) NOT NULL,
    [last_name] NVARCHAR(256) NOT NULL,
    [email] NVARCHAR(256) NOT NULL,
    [loyalty_tier] NVARCHAR(256) NOT NULL,
    [created_at] DATE NOT NULL
);
GO

-- One address per customer in this seed: Delivery/contact geography. Real systems may have multiple addresses per customer; this seed has one.
IF OBJECT_ID(N'retail_demo.customer_addresses',N'U') IS NULL
CREATE TABLE [retail_demo].[customer_addresses] (
    [address_id] INT NOT NULL PRIMARY KEY,
    [customer_id] INT NOT NULL,
    [city] NVARCHAR(256) NOT NULL,
    [state] NVARCHAR(256) NOT NULL,
    [postal_code] NVARCHAR(256) NOT NULL,
    [country] NVARCHAR(256) NOT NULL,
    CONSTRAINT [FK_demo_customer_addresses_customer_id] FOREIGN KEY ([customer_id]) REFERENCES [retail_demo].[customers] ([customer_id])
);
GO

-- One store employee: Associates orders with staff and stores.
IF OBJECT_ID(N'retail_demo.employees',N'U') IS NULL
CREATE TABLE [retail_demo].[employees] (
    [employee_id] INT NOT NULL PRIMARY KEY,
    [store_id] INT NOT NULL,
    [employee_name] NVARCHAR(256) NOT NULL,
    [role] NVARCHAR(256) NOT NULL
);
GO

-- One order header: Order-level customer, delivery address, store, channel, employee, date and total. Never sum header totals after joining to multiple order lines without restoring order grain.
IF OBJECT_ID(N'retail_demo.orders',N'U') IS NULL
CREATE TABLE [retail_demo].[orders] (
    [order_id] INT NOT NULL PRIMARY KEY,
    [customer_id] INT NOT NULL,
    [address_id] INT NOT NULL,
    [store_id] INT NOT NULL,
    [channel_id] INT NOT NULL,
    [employee_id] INT NOT NULL,
    [order_date] DATE NOT NULL,
    [status] NVARCHAR(256) NOT NULL,
    [total_amount] DECIMAL(18,2) NOT NULL,
    CONSTRAINT [FK_demo_orders_customer_id] FOREIGN KEY ([customer_id]) REFERENCES [retail_demo].[customers] ([customer_id]),
    CONSTRAINT [FK_demo_orders_address_id] FOREIGN KEY ([address_id]) REFERENCES [retail_demo].[customer_addresses] ([address_id]),
    CONSTRAINT [FK_demo_orders_employee_id] FOREIGN KEY ([employee_id]) REFERENCES [retail_demo].[employees] ([employee_id])
);
GO

-- One order line: Sales fact source, including product, quantity, selling price, discount and line amount.
IF OBJECT_ID(N'retail_demo.order_items',N'U') IS NULL
CREATE TABLE [retail_demo].[order_items] (
    [order_item_id] INT NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [promotion_id] INT NOT NULL,
    [quantity] INT NOT NULL,
    [unit_price] DECIMAL(18,2) NOT NULL,
    [discount_pct] INT NOT NULL,
    [line_amount] DECIMAL(18,2) NOT NULL,
    CONSTRAINT [FK_demo_order_items_order_id] FOREIGN KEY ([order_id]) REFERENCES [retail_demo].[orders] ([order_id])
);
GO

-- One captured payment per order in this seed: Payment method and value. The seed does not model partial captures or multiple payments per order.
IF OBJECT_ID(N'retail_demo.payments',N'U') IS NULL
CREATE TABLE [retail_demo].[payments] (
    [payment_id] INT NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL,
    [payment_date] DATE NOT NULL,
    [payment_method] NVARCHAR(256) NOT NULL,
    [amount] DECIMAL(18,2) NOT NULL,
    [status] NVARCHAR(256) NOT NULL,
    CONSTRAINT [FK_demo_payments_order_id] FOREIGN KEY ([order_id]) REFERENCES [retail_demo].[orders] ([order_id])
);
GO

-- One return header: A return belongs to an original order/customer. Every tenth seeded order has a return.
IF OBJECT_ID(N'retail_demo.returns',N'U') IS NULL
CREATE TABLE [retail_demo].[returns] (
    [return_id] INT NOT NULL PRIMARY KEY,
    [order_id] INT NOT NULL,
    [customer_id] INT NOT NULL,
    [return_date] DATE NOT NULL,
    [reason] NVARCHAR(256) NOT NULL,
    CONSTRAINT [FK_demo_returns_order_id] FOREIGN KEY ([order_id]) REFERENCES [retail_demo].[orders] ([order_id]),
    CONSTRAINT [FK_demo_returns_customer_id] FOREIGN KEY ([customer_id]) REFERENCES [retail_demo].[customers] ([customer_id])
);
GO

-- One returned line per return in this seed: References the actual original order line and its product. Refunds are separate from gross sales in the current marts.
IF OBJECT_ID(N'retail_demo.return_items',N'U') IS NULL
CREATE TABLE [retail_demo].[return_items] (
    [return_item_id] INT NOT NULL PRIMARY KEY,
    [return_id] INT NOT NULL,
    [order_item_id] INT NOT NULL,
    [product_id] INT NOT NULL,
    [quantity] INT NOT NULL,
    [refund_amount] DECIMAL(18,2) NOT NULL,
    CONSTRAINT [FK_demo_return_items_return_id] FOREIGN KEY ([return_id]) REFERENCES [retail_demo].[returns] ([return_id]),
    CONSTRAINT [FK_demo_return_items_order_item_id] FOREIGN KEY ([order_item_id]) REFERENCES [retail_demo].[order_items] ([order_item_id])
);
GO
