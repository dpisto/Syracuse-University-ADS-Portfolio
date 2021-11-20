/*
IST 722 Data Warehousing Final Product
Group 3
Staging Code for FudgeFlix and FudgeMart consolidated data warehouse
*/

drop table stgFMFFDimDate;
drop table stgFudgeFlixCustomers;
drop table stgFudgeMartCustomers;
drop table stgFudgeFlixOrderFullmentFact;
drop table stgFudgeMartOrderFullmentFact;
drop table stgFudgeFlixProducts;
drop table stgFudgeMartProducts;

--********************************************************************
--STAGE DIMCUSTOMER
--Stage FudgeFlix DimCustomer
select 
	a.[account_id]					--PK, int, not null
	,a.[account_firstname]			--varchar(50), not null
	,a.[account_lastname]			--varchar(50), not null
	,z.[zip_city]					--varchar(50), PK, not null
	,z.[zip_state]					--char(2), not null
	,a.[account_zipcode]			--char(5), FK, not null
into [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixCustomers]
from [fudgeflix_v3].[dbo].[ff_accounts] a 
join [fudgeflix_v3].[dbo].[ff_zipcodes] z
on a.[account_zipcode] = z.[zip_code]

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixCustomers]

--Stage Fudgemart DimCustomer
select 
	[customer_id]					--PK, int, not null
	,[customer_firstName]			--varchar(50), not null
	,[customer_lastname]			--varchar(50), not null
	,[customer_city]				--varchar(50), not null
	,[customer_state]				--char(2), not null
	,[customer_zip]					--char(5), not null
into [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartCustomers]
from [fudgemart_v3].[dbo].[fm_customers]

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartCustomers]

--*********************************************************************

--STAGE DIMPRODUCT
--Fudgeflix columns for product dimension
select 
	[title_id]						--PK, varchar(20), not null
	,[title_type]					--varchar(20), not null
	,[title_name]					--varchar(100), not null
	,null as product_is_active		--need to assign data type
	,null as product_vendor			--FK, need to assign data type
	,[title_synopsis]				--varchar(max), not null
into [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixProducts]
from [fudgeflix_v3].[dbo].[ff_titles]

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixProducts]

--Fudgemart columns for product dimension
select	
	p.[product_id]					--PK, int, not null
	,p.[product_department]			--varchar(20), not null
	,p.[product_name]				--varchar(50), not null
	,p.[product_is_active]			--bit, not null
	,v.[vendor_name]				--varchar(50), not null
	,p.[product_description]		--varchar(1000), null
into [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartProducts]
from [fudgemart_v3].[dbo].[fm_products] p
join [fudgemart_v3].[dbo].[fm_vendors] v
on p.[product_vendor_id] = v.[vendor_id]

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartProducts]

--***********************************************************************

--Create DimDate staging table with years from 1996 to 1998
--First query used to determine min and max dates
select min (at_queue_date)
		,max(at_queue_date)
		,min(at_shipped_date)
		,max(at_shipped_date)
from [fudgeflix_v3].[dbo].[ff_account_titles]

select min (Order_Date)
		,max(Order_Date)
		,min(Shipped_Date)
		,max(Shipped_Date)
from [fudgemart_v3].[dbo].[fm_Orders]

select *
into [ist722_hhkhan_oa3_stage].[dbo].[stgFMFFDimDate]
from [ExternalSources2].[dbo].[date_dimension]
where Year between 2008 and 2025

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFMFFDimDate]

--*********************************************************************

----STAGE ORDERFULLFILLMENTFACT
--OrderFullfillmentFact mapping from Fudgeflix
select 
	a.[at_id]				--PK, int, not null	
	,a.[at_account_id]		--FK, int, not null
	,a.[at_queue_date]		--datetime, not null
	,a.[at_shipped_date]	--datetime, not null
	,a.[at_returned_date]   --datetime, not null
	,a.[at_title_id]		--FK, varchar(20), not null
into [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixOrderFullmentFact]
from [fudgeflix_v3].[dbo].[ff_account_titles] a 

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeFlixOrderFullmentFact]

--Orderfullmentfact mapping from Fudgemart
select
	o.[Order_ID]		--PK, int, not null
	,o.[Customer_ID]	--FK, int, not null
	,o.[Order_Date]		--datetime, not null
	,o.[Shipped_Date]	--datetime, not null
	,od.[Product_ID]	--PK,FK,not null
	,od.[order_qty]		--int, not null
into [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartOrderFullmentFact]
from [fudgemart_v3].[dbo].[fm_Orders] o
join 
[fudgemart_v3].[dbo].[fm_order_details] od
on o.[order_id] = od.[order_id]

select * from [ist722_hhkhan_oa3_stage].[dbo].[stgFudgeMartOrderFullmentFact]