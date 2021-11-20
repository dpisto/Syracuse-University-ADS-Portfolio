/*
	Fudgemart ROLAP Bus Architecture
	Original script by: Michael Fudge (mafudge@syr.edu)
	Adaopted by: IST 722 Group 3

	This script creates one conformed dimensional models in the fudgemart schema
		- FactOrderFullfillment	
			- DimDate
			- DimCustomer
			- DimProduct

*/

use
ist722_hhkhan_oa3_dw


-- Create the schema if it does not exist
IF (NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'fudgemart')) 
BEGIN
    EXEC ('CREATE SCHEMA [fudgemart] AUTHORIZATION [dbo]')
	PRINT 'CREATE SCHEMA [fudgemart] AUTHORIZATION [dbo]'
END
go 


-- delete all the fact tables in the schema
DECLARE @fact_table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='fudgemart' and TABLE_NAME like 'Fact%'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop  INTO @fact_table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [fudgemart].[' + @fact_table_name + ']')
	PRINT 'DROP TABLE [fudgemart].[' + @fact_table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @fact_table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go
-- delete all the other tables in the schema
DECLARE @table_name varchar(100)
DECLARE cursor_loop CURSOR FAST_FORWARD READ_ONLY FOR 
	select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
		where TABLE_SCHEMA='fudgemart' and TABLE_TYPE = 'BASE TABLE'
OPEN cursor_loop
FETCH NEXT FROM cursor_loop INTO @table_name
WHILE @@FETCH_STATUS= 0
BEGIN
	EXEC ('DROP TABLE [fudgemart].[' + @table_name + ']')
	PRINT 'DROP TABLE [fudgemart].[' + @table_name + ']'
	FETCH NEXT FROM cursor_loop  INTO @table_name
END
CLOSE cursor_loop
DEALLOCATE cursor_loop
go


use
ist722_hhkhan_oa3_dw


-- Customer Dimension
PRINT 'CREATE TABLE fudgemart.DimCustomer'
CREATE TABLE fudgemart.DimCustomer (
   [CustomerKey]  int IDENTITY  NOT NULL
   -- Attributes
,  [CustomerID]  int   NOT NULL
,  [CustomerName]  varchar(100)   NOT NULL
,  [CustomerCity]  varchar(50)   NOT NULL
,  [CustomerState]  char(4)   NOT NULL
,  [CustomerPostalCode]  char(5)   NOT NULL
	-- metadata
,  [RowIsCurrent]  bit  DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT pkFudgemartCustomer PRIMARY KEY ( [CustomerKey] )
);

-- Unknown Customer insert
SET IDENTITY_INSERT [fudgemart].[DimCustomer] ON
go
INSERT INTO [fudgemart].[DimCustomer]
           ([CustomerKey]
		   ,[CustomerID]
           ,[CustomerName]
		   ,[CustomerState]
           ,[CustomerCity]
           ,[CustomerPostalCode])
     VALUES
           (-1
		   ,-1
           ,'Unknown Customer'
           ,'None'
		   ,'None'
           ,'None')
GO
SET IDENTITY_INSERT [fudgemart].[DimCustomer] OFF
go


-- Product Dimension
PRINT 'CREATE TABLE fudgemart.DimProduct'
create table fudgemart.DimProduct
(
	ProductKey int identity not null,
	-- attributes
	ProductID varchar(20) not null, 
	ProductName varchar(150) not null,
	ProductDepartment varchar(20) not null,
	Discontinued char(1) default('N') not null,
	VendorName varchar(50) not null,
	ProductDescription varchar(max) not null,
	-- metadata
	RowIsCurrent bit default(1) not null,
	RowStartDate datetime default('1/1/1900') not null,
	RowEndDate datetime default('12/31/9999') not null,
	RowChangeReason nvarchar(200) default ('N/A') not null,
	-- keys
	constraint pkfudgemartDimProductKey primary key (ProductKey),	
);

-- Unknown Product insert
use
ist722_hhkhan_oa3_dw

SET IDENTITY_INSERT [fudgemart].[DimProduct] ON
GO
INSERT INTO [fudgemart].[DimProduct]
           ([ProductKey]
		   ,[ProductID]
           ,[ProductName]
		   ,[ProductDepartment]
           ,[Discontinued]
           ,[VendorName]
           ,[ProductDescription])
     VALUES
           (-1
		   ,'-1'
           ,'Unknown Product'
		   ,'Unknown Dept'
           ,'?'
           ,'Unknown Vendor'
           ,'No Description')
GO
SET IDENTITY_INSERT [fudgemart].[DimProduct] OFF
GO

-- date dimension
PRINT 'CREATE TABLE fudgemart.DimDate'
CREATE TABLE [fudgemart].[DimDate](
	[DateKey] [int] NOT NULL,
	[Date] [datetime] NULL,
	[FullDateUSA] [nchar](11) NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[DayName] [nchar](10) NOT NULL,
	[DayOfMonth] [tinyint] NOT NULL,
	[DayOfYear] [int] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[MonthName] [nchar](10) NOT NULL,
	[MonthOfYear] [tinyint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [nchar](10) NOT NULL,
	[Year] [int] NOT NULL,
	[IsAWeekday] varchar(1) NOT NULL DEFAULT (('N')),
	constraint pkFudgemartDimDate PRIMARY KEY ([DateKey])
)

-- Unknown Date Value insert
INSERT INTO [fudgemart].[DimDate]
           ([DateKey]
           ,[Date]
           ,[FullDateUSA]
           ,[DayOfWeek]
           ,[DayName]
           ,[DayOfMonth]
           ,[DayOfYear]
           ,[WeekOfYear]
           ,[MonthName]
           ,[MonthOfYear]
           ,[Quarter]
           ,[QuarterName]
           ,[Year]
           ,[IsAWeekday])
     VALUES
           (-1
           ,null
           ,'Unknown'
           ,0
           ,'Unknown'
           ,0
           ,0
           ,0
           ,'Unknown'
           ,0
           ,0
           ,'Unknown'
           ,0
           ,'?')
GO


-- orderfullfillment fact table
PRINT 'CREATE TABLE fudgemart.FactOrderFullfillment'
CREATE TABLE fudgemart.FactOrderFullfillment (
   [ProductKey]  int   NOT NULL
,  [OrderID]  int   NOT NULL
	-- dimensions
,  [CustomerKey]  int   NOT NULL
,  [OrderDateKey]  int   NOT NULL
,  [ShippedDateKey]  int   NOT NULL
,  [ReturnDateKey]  int   NOT NULL
	-- facts
,  [Quantity]  smallint   NOT NULL
,  [OrderToShippedLagInDays] smallint null
,  [ShiptoReturnLagInDays] smallint null

   --keys
, CONSTRAINT pkfudgemartFactSales PRIMARY KEY ( ProductKey, OrderID )
, CONSTRAINT fkfudgemartFactSalesProductKey FOREIGN KEY ( ProductKey )
	REFERENCES fudgemart.DimProduct (ProductKey)
, CONSTRAINT fkfudgemartFactSalesCustomerKey FOREIGN KEY ( CustomerKey )
	REFERENCES fudgemart.DimCustomer (CustomerKey)
, CONSTRAINT fkfudgemartFactSalesOrderDateKey FOREIGN KEY (OrderDateKey )
	REFERENCES fudgemart.DimDate (DateKey)
, CONSTRAINT fkfudgemartFactSalesShippedDateKey FOREIGN KEY (ShippedDateKey )
	REFERENCES fudgemart.DimDate (DateKey)
, CONSTRAINT fkfudgemartFactSalesReturnDateKey FOREIGN KEY (ReturnDateKey )
	REFERENCES fudgemart.DimDate (DateKey)

) 
;

GO
PRINT 'SCRIPT COMPLETE'
GO


