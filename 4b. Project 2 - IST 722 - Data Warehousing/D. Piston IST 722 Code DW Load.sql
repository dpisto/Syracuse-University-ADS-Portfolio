use
ist722_hhkhan_oa3_dw
----------------------------------------------------------------

--Customers Dimension
--Insert data from FudgeFlix Customer Stage to Datawarehouse
INSERT INTO [fudgemart].[DimCustomer]
           ([CustomerID]
           ,[CustomerName]
		   ,[CustomerState]
           ,[CustomerCity]
           ,[CustomerPostalCode])
select 
	[account_id]
	,account_firstname collate SQL_Latin1_General_CP1_CI_AS + ' ' + account_lastname
	,[zip_state]
	,[zip_city]	
	,[account_zipcode]
from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFLixCustomers]

--Insert data from FudgeMart Customer Stage to Datawarehouse
INSERT INTO [fudgemart].[DimCustomer]
           ([CustomerID]
           ,[CustomerName]
		   ,[CustomerState]
           ,[CustomerCity]
		   ,[CustomerPostalCode])
select 
	[customer_id]
	,concat([customer_firstName],' ',[customer_lastname])
	,[customer_state]
	,[customer_city]
	,[customer_zip]	
from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartCustomers]


--Check table for combined observations
select * from [ist722_hhkhan_oa3_dw].[fudgemart].[DimCustomer]

--------------------------------------------------------------------

 --Product Dimension Load

 --Insert data from staged FudgeFlixProduct
 INSERT INTO [fudgemart].[DimProduct]      
		    ([ProductID]
           ,[ProductName]
		   ,[ProductDepartment]
           ,[Discontinued]
           ,[VendorName]
           ,[ProductDescription])
select 
	[title_id]						--PK, varchar(20), not null
	,[title_name]					--varchar(100), not null
	,[title_type]					--varchar(20), not null
	,case when [product_is_active] is null then 'Y' else 'N' end			--need to assign data type
	,case when [product_vendor]	is null then 'Unknown Vendor' end			--FK, need to assign data type
	,[title_synopsis]			--varchar(max), not null
from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixProducts]

 --Insert data from staged FudgeMartProduct
INSERT INTO [fudgemart].[DimProduct]      
		   ([ProductID]
          ,[ProductName]
		  ,[ProductDepartment]
          ,[Discontinued]
          ,[VendorName]
          ,[ProductDescription])
select	
	cast([product_id] as varchar(20))					--PK, int, not null
	,[product_name]				--varchar(50), not null
	,[product_department]			--varchar(20), not null	
	,case when [product_is_active] = 1 then 'Y' else 'N'	end		--bit, not null
	,[vendor_name]				--varchar(50), not null
	,case when [product_description] is null then 'No Description' end --varchar(1000), null
from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartProducts]

select * from [fudgemart].[DimProduct]  
go
------------------------------------------------------------------------------------------------

--Date Dimension
--Load from stgFMFFDimDate table
insert into [fudgemart].[DimDate]
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
select 
	[Datekey]
	,[Date]
	,[FullDateUSA]
	,[DayOfWeekinMonth]
	,[DayName]
	,[DayOfMonth]
	,[DayOfYear]
	,[WeekOfYear]
	,[MonthName]
	,[Month]
	,[Quarter]
	,[QuarterName]
	,[Year]
	,case when [IsWeekday] = 1 then 'Y' else 'N' end
from [ist722_hhkhan_oa3_stage].[dbo].[stgFMFFDimDate] 



---------------------------------------------------------------------------------------------------------

--Load Order Fullfillment Fact

insert into [fudgemart].[FactOrderFullfillment]
	  ( [ProductKey]
		,[OrderID]
		,[CustomerKey] 
		,[OrderDateKey]
		,[ShippedDateKey]
		,[ReturnDateKey] 
		,[Quantity] 
		,[OrderToShippedLagInDays] 
		,[ShiptoReturnLagInDays] )
select 
	p.ProductKey
	,[at_id]	as Order_ID
	,c.[CustomerKey]			 
	,case when f.at_queue_date is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.at_queue_date) end as OrderDateKey
	,case when f.at_shipped_date is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.at_shipped_date) end as ShippedDateKey
	,case when f.at_returned_date is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.at_returned_date) end as ReturnDateKey
	,count(f.at_id) as Quantity
	,case when (f.at_shipped_date) is not null then datediff(day, f.at_queue_date, f.at_shipped_date) else -1 end as TimetoShip
	,case when (f.at_returned_date) is not null then datediff(day, f.at_shipped_date, f.at_returned_date) else -1 end as TimetoReturn
from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixOrderFullmentFact] f
join [ist722_hhkhan_oa3_dw].[fudgemart].[DimCustomer] c on f.at_account_id = c.CustomerID
join [ist722_hhkhan_oa3_dw].[fudgemart].[DimProduct] p on f.at_title_id = p.ProductID collate SQL_Latin1_General_CP1_CS_AS	
group by 
	p.ProductKey
	,[at_id]
	,c.[CustomerKey]	
	,case when f.at_queue_date is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.at_queue_date) end 
	,case when f.at_shipped_date is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.at_shipped_date) end
	,case when f.at_returned_date is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.at_returned_date) end 
	,case when (f.at_shipped_date) is not null then datediff(day, f.at_queue_date, f.at_shipped_date) else -1 end
	,case when (f.at_returned_date) is not null then datediff(day, f.at_shipped_date, f.at_returned_date) else -1 end


insert into [fudgemart].[FactOrderFullfillment]
	  ( [ProductKey]
		,[OrderID]
		,[CustomerKey] 
		,[OrderDateKey]
		,[ShippedDateKey]
		,[ReturnDateKey] 
		,[Quantity] 
		,[OrderToShippedLagInDays] 
		,[ShiptoReturnLagInDays] )
select
	p.ProductKey
	,f.[Order_ID]		
	,c.CustomerKey
	,case when f.[Order_Date]is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.Order_Date) end as OrderDateKey
	,case when f.[Shipped_Date]is null then -1 else [ExternalSources2].[dbo].[getDateKey](f.Shipped_Date) end as ShippedDateKey
	,-1 as ReturnDateKey	
	,f.[order_qty]	
	,case when (f.Shipped_Date) is not null then datediff(day, f.Order_Date, f.Shipped_Date) else -1 end as TimetoShip
	,-1 as TimetoReturn
from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartOrderFullmentFact] f
join [ist722_hhkhan_oa3_dw].[fudgemart].[DimCustomer] c on c.CustomerID = f.Customer_ID
join [ist722_hhkhan_oa3_dw].[fudgemart].[DimProduct] p on p.ProductID = cast(f.[Product_ID] as varchar(20))


select * from [fudgemart].[FactOrderFullfillment]





