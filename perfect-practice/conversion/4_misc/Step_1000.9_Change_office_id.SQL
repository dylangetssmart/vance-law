
select * from sma_mst_offices
select 
	office_id,count(office_id)
from sma_TRN_Cases
group by office_id


alter table sma_TRN_Cases disable trigger all

update sma_TRN_Cases set office_id=7 

alter table sma_TRN_Cases enable trigger all
