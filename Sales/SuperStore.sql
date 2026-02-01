use Superstore

select * from SuperStore

--Distinct deyerleri tapmaq

select distinct (Item_Fat_Content ) from SuperStore

select distinct (Item_Type ) from SuperStore

select distinct (Outlet_Size ) from SuperStore

select distinct (Outlet_Establishment_Year ) from SuperStore

select distinct (Outlet_Location_Type ) from SuperStore

select distinct (Outlet_Type ) from SuperStore

--Null deyerlerin İtem_Weight ve sutunundan silinmesi

delete from SuperStore
where Item_Weight is null

--Item_Fat_Content sutununda LF ve Reg deyerlerini uygun olaraq Low Fat ve Regular veziyyetine getirmek

UPDATE SuperStore
SET Item_Fat_Content =
    CASE 
        WHEN Item_Fat_Content = 'LF'  THEN 'Low Fat'
        WHEN Item_Fat_Content = 'reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END;

--Item_Visibility sutununun deyerlerinin yuvarlaqlasdirilmasi
begin tran
update SuperStore
set Item_Visibility=ROUND(Item_Visibility,4)
 
  select * from SuperStore

  rollback

--Item_Type sutunundaki deyerleri kateqoriyaya bolmek

alter table SuperStore
add  Item_Group varchar(30);

select distinct (Item_Type ) from SuperStore
select distinct (Item_Group ) from SuperStore
select * from SuperStore

begin tran

update  SuperStore
set Item_Group=
case 
   when Item_Type in ('Fruits and Vegetables','Meat','Seafood','Dairy','Baking Goods','Breads')
      then 'Perisable'
	  when Item_Type in ('Snack Foods','Starchy Foods','Others','Frozen Foods','Breakfast ','Canned')
      then 'Non-Perisable'
	   when Item_Type in ('Soft Drinks','Hard Drinks')
      then 'Drinks'
	    when Item_Type in ('Household','Health and Hygiene')
      then 'Household'

	  else 'other'
	  end;

	  rollback

--Item_Visibily grouplasdirma

alter table superstore
add Visibility_Group varchar(30)

select *,round(Item_Visibility,2)
 from SuperStore
 
 begin tran

 update SuperStore 
 set Visibility_Group=
 case
when Item_Visibility<0.1 and  Item_Visibility!=0
then 'Low Visibilty'
when Item_Visibility>=0.1 
then 'High Visibilty'
else 'Unknown'
 end;

 rollback

 select * from SuperStore

 --İtem_Outlet_Sales sutunundakı deyerlerin yuvarlaqlaşdırılması

 select  * from SuperStore
 
 update SuperStore
 set Item_Outlet_Sales=round(Item_Outlet_Sales,4)

  --İtem_Weight sutunundakı deyerlerin yuvarlaqlaşdırılması

   select  * from SuperStore
 
 update SuperStore
 set Item_Weight=round(Item_Weight,2)

 --İtem_MRP sutunundakı deyerlerin yuvarlaqlaşdırılması

    select  * from SuperStore

 update SuperStore
 set Item_MRP=round(Item_MRP,3)

 --Index yaratmaq

 create index Item_Identifier
 on superstore(Item_identifier)

 --                            Funksiya yaratmaq

 create function dbo.OutletSales(@Deyer int)
 returns table
 as return
 (
 select * from SuperStore
 where Item_Outlet_Sales>@Deyer
 );

 drop function OutletSales

 select * from dbo.outletSales(2000)

 --                           With clouse and Window functions

 --Her item_type esasen en cox satilan mehsul
 with cte as (
 select * ,
 row_number() over(partition by item_type order by item_outlet_sales desc) as rn
 from superstore
 )
 select * from cte
 where rn=1

 --Her outlet_identifier uzre top 3 mehsul satis deyerine esesen

 select distinct(outlet_identifier) from SuperStore

 with Top3 as(
 select *,
 row_number() over(partition by outlet_identifier order by item_outlet_sales desc) as T3
 from superstore
 )
 select * from  Top3
 where t3<=3

 --Her outlet_size kategoriyasi uzre satis siralamasi

 select distinct(outlet_size) from SuperStore

 select outlet_size,
 item_outlet_sales,
 rank() over(partition by outlet_size order by item_outlet_sales asc) as Ranking 
 from SuperStore

 --Item_FaT-content uzre en cox satilan 5 mehsulu gormek
 
 select distinct(Item_Fat_Content) from SuperStore

 with iFC as (select  *,
 row_number() over(partition by item_fat_content order by item_outlet_sales desc) as Ranking
 from SuperStore)
 select * from IFC where Ranking<=5

 --Her item_type esasen satis payini hesablayan sorgu

WITH cte AS (
    SELECT 
        item_type,
        item_outlet_sales,
        ROW_NUMBER() OVER (PARTITION BY item_type ORDER BY item_outlet_sales DESC) AS rn,
        SUM(item_outlet_sales) OVER (PARTITION BY item_type) AS total_by_type
    FROM SuperStore
)
SELECT 
    item_type,
    item_outlet_sales,
    total_by_type,
    item_outlet_sales  / total_by_type AS salesRatio
FROM cte
WHERE rn <= 5;

--Snack_Foods kateqoriyasi uzre top 5 mehsul

select * from SuperStore

SELECT top 5
    item_identifier,
    item_fat_content,
    item_mrp,
    ROW_NUMBER() OVER (
        PARTITION BY item_type 
        ORDER BY CASE WHEN item_type = 'Snack Foods' THEN item_outlet_sales END DESC
    ) AS Snack_Food
FROM SuperStore
WHERE item_type = 'Snack Foods';

--Runing Total İtem_outlet_sales-e esasen

select Item_Identifier,outlet_establishment_year,
sum(item_outlet_sales) over(partition by item_identifier order by outlet_establishment_year desc ) as Runing_Total
from SuperStore

