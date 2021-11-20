--Fudgeflix columns for customer dimension
select 
	a.[account_id]					--PK, int, not null
	,a.[account_firstname]			--varchar(50), not null
	,a.[account_firstname]			--varchar(50), not null
	,z.[zip_city]					--varchar(50), PK, not null
	,z.[zip_state]					--char(2), not null
	,a.[account_zipcode]			--char(5), FK, not null
from [fudgeflix_v3].[dbo].[ff_accounts] a 
join [fudgeflix_v3].[dbo].[ff_zipcodes] z
on a.[account_zipcode] = z.[zip_code]

--Fudgemart columns for customer dimension
select 
	[customer_id]					--PK, int, not null
	,[customer_firstName]			--varchar(50), not null
	,[customer_lastname]			--varchar(50), not null
	,[customer_city]				--varchar(50), not null
	,[customer_state]				--char(2), not null
	,[customer_zip]					--char(5), not null
from [fudgemart_v3].[dbo].[fm_customers]