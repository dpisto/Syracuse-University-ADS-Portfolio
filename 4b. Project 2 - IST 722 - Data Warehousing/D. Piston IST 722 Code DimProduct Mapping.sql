--Fudgeflix columns for product dimension
select 
	[title_id]						--PK, varchar(20), not null
	,[title_type]					--varchar(20), not null
	,[title_name]					--varchar(100), not null
	,null as product_is_active		--need to assign data type
	,null as product_vendor			--FK, need to assign data type
	,[title_synopsis]				--varchar(max), not null
from [fudgeflix_v3].[dbo].[ff_titles]

--Fudgemart columns for product dimension
select	
	p.[product_id]					--PK, int, not null
	,p.[product_department]			--varchar(20), not null
	,p.[product_name]				--varchar(50), not null
	,p.[product_is_active]			--bit, not null
	,v.[vendor_name]				--varchar(50), not null
	,p.[product_description]		--varchar(1000), null
from [fudgemart_v3].[dbo].[fm_products] p
join [fudgemart_v3].[dbo].[fm_vendors] v
on p.[product_vendor_id] = v.[vendor_id]


