
--OrderFullfillmentFact mapping from Fudgeflix
select 
	a.[at_id]				--PK, int, not null	
	,a.[at_account_id]		--FK, int, not null
	,a.[at_queue_date]		--datetime, not null
	,a.[at_shipped_date]	--datetime, not null
	,a.at_returned_date
	,a.[at_title_id]		--FK, varchar(20), not null
	--,t2.[Order_Qty]			--derived, not null
from [fudgeflix_v3].[dbo].[ff_account_titles] a 
left join
	(select
	a2.[at_account_id]
	,a2.[at_queue_date]
	,count(a2.at_title_id) as Order_Qty
	from [fudgeflix_v3].[dbo].[ff_account_titles] a2
	group by at_account_id, at_queue_date) t2
on a.[at_account_id] = t2.[at_account_id] and a.[at_queue_date] = t2.[at_queue_date]
order by a.[at_id]

--Orderfullmentfact mapping from Fudgemart
select
	o.[Order_ID]		--PK, int, not null
	,o.[Customer_ID]	--FK, int, not null
	,o.[Order_Date]		--datetime, not null
	,o.[Shipped_Date]	--datetime, not null
	,od.[Product_ID]	--PK,FK,not null
	,od.[order_qty]		--int, not null
from [fudgemart_v3].[dbo].[fm_Orders] o
join 
[fudgemart_v3].[dbo].[fm_order_details] od
on o.[order_id] = od.[order_id]


