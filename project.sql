--Проверка данных на выбросы
---запрос 1.1
select max(quantity::int),
       min(quantity::int),
       avg(quantity::int),
       percentile_disc(0.5) within group (order by quantity::int) as median,
       percentile_disc(0.75) within group (order by quantity::int) as q75,
       percentile_disc(0.9) within group (order by quantity::int) as q9,
       percentile_disc(0.95) within group (order by quantity::int) as q95,
       percentile_disc(0.99) within group (order by quantity::int) as q99
from online_shop.order 

--запрос 1.2
select max(price::int),
       min(price::int),
       avg(price::int),
       percentile_disc(0.5) within group (order by price::int) as median,
       percentile_disc(0.75) within group (order by price::int) as q75,
       percentile_disc(0.9) within group (order by price::int) as q9,
       percentile_disc(0.95) within group (order by price::int) as q95,
       percentile_disc(0.99) within group (order by price::int) as q99
from online_shop.order


---Запрос 1.3  - определение количества пользователей после очистки от выбросов
select count(distinct client_id) as count
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<> 0
  
---Запрос 1.4  - определение количества пользователей 
select count(distinct client_id) as count
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id

---Запрос 1.5 - портрет пользователя
select avg(t2.quantity) as avg_quantity,
	   avg(t2.price) as avg_price,
	   count(t1.page)/count(distinct t1.client_id) as count_page,
       count(t2.order_id)/count(distinct t1.client_id) as count_order
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0


---Запрос 1.6 - часть суток оформления заказа
SELECT count(distinct client_id),
        CASE
           WHEN date_part('hour', event_timestamp::timestamp) BETWEEN 6 AND 18 THEN 'day'
           ELSE 'night'
       END AS time_of_day
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0 
  and t1.action_type = 'payment'
group by time_of_day

---Запрос 2.1 - расчет dau
select count(distinct t1.client_id) as dau,
	   date_trunc('day', event_timestamp::date) as cohort
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0
group by date_trunc('day', event_timestamp::date)

--Запрос 2.2
select min(dau),
	   max(dau),
	   avg(dau)
from 
	(select count(distinct t1.client_id) as dau,
			date_trunc('day', event_timestamp::date) as cohort
	  from online_shop.action t1
      join online_shop.order t2 on t1.action_id=t2.action_id
	  where t2.quantity<>0 
	 	and t2.quantity<>999
	    and t2.price<>0
	 group by date_trunc('day', event_timestamp::date)) as dau

---Запрос 2.3  - расчет wau
select count(distinct t1.client_id) as wau,
	   date_trunc('week', event_timestamp::date) as cohort
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0
group by date_trunc('week', event_timestamp::date) 

---Запрос 2.4
select min(wau),
	   max(wau),
	   avg(wau)
from 
	(select count(distinct t1.client_id) as wau,
			date_trunc('week', event_timestamp::date) as cohort
	 from online_shop.action t1
	 join online_shop.order t2 on t1.action_id=t2.action_id
	 where t2.quantity<>0 
	   and t2.quantity<>999 
	   and t2.price<>0
	group by date_trunc('week', event_timestamp::date)) as wau


--Запрос 2.5 - расчет mau
select count(distinct t1.client_id) as mau,
	   date_trunc('month', event_timestamp::date) as cohort
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0
group by date_trunc('month', event_timestamp::date) 

--Запрос 2.6
select min(mau),
	   max(mau),
	   avg(mau)
from 
	(select count(distinct t1.client_id) as mau,
			date_trunc('month', event_timestamp::date) as cohort
	 from online_shop.action t1
     join online_shop.order t2 on t1.action_id=t2.action_id
     where t2.quantity<>0 
       and t2.quantity<>999 
       and t2.price<>0
	group by date_trunc('month', event_timestamp::date)	) as mau

---Запрос 2.7 -- распределение покупок по времени суток
select date_part('hour', event_timestamp::timestamp) as day,
	   count(*) as cnt,
	   round(100 * count(*) / sum(count(*)) over (), 2) as share
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where  t2.quantity<>0 
   and t2.quantity<>999 
   and t2.price<>0 
   and t1.action_type = 'payment'
group by 1
order by 2


--Запрос 2.8 -- расчет ARPU
select sum(t2.price)/ count(distinct t1.client_id) as ARPU
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0


--Запрос 2.9 - расчет ARPPU
select sum(t2.price)/ count(t1.client_id) as ARPPU
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0 
  and action_type='payment'

---Запрос 2.10 - изменение ARPU и ARPPU
select sum(t2.price)/ count(distinct t1.client_id) as ARPU,
	   sum(t2.price)/ count(t1.client_id) as ARPPU,
	   date_trunc('month', event_timestamp::date) as cogort
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0
  and action_type='payment'
group by date_trunc('month', event_timestamp::date)

---ВОРОНКА ПРОДАЖ
---Запрос 3.1 - первый визит
select count(client_id) as first_visit
from online_shop.action t1
where  action_type='registration'

-- Запрос 3.2 - просмотр карточки товара
select count(distinct client_id) as view_product
from online_shop.action t1
where action_type='view_product'

---Запрос 3.3 - оформление заказа
select count(distinct client_id) as place_order
from online_shop.action t1
where action_type='place_order'

---Запрос 3.4 - оплата  заказа
select count(distinct client_id) as payment_order
from online_shop.action t1
join online_shop.order t2 on t1.action_id=t2.action_id
where t2.quantity<>0 
  and t2.quantity<>999 
  and t2.price<>0 
  and action_type='payment'

---Запрос 3.5 -повторный заказ
SELECT COUNT(client_id) AS second_order
FROM 
	(SELECT client_id
    FROM online_shop.action
    WHERE action_type = 'payment'
    GROUP BY client_id
    HAVING COUNT(action_type) >= 2) AS second_order

---Запрос 3.6 -вся воронка
with first_visit as 
  (select count(client_id) as first_visit
   from online_shop.action t1
   where  action_type='registration'),
	 view_product as 
  (select count(distinct client_id) as view_product
   from online_shop.action t1
   where action_type='view_product'),
	 place_order as 
  (select count(distinct client_id) as place_order
   from online_shop.action t1
   where action_type='place_order'),
	payment_order as 
   (select count(distinct client_id) as payment_order
    from online_shop.action t1
    join online_shop.order t2 on t1.action_id=t2.action_id
    where t2.quantity<>0 
      and t2.quantity<>999 
      and t2.price<>0 
      and action_type='payment'),
   second_order as
	(SELECT COUNT(client_id) AS second_order
	 FROM 
	    (SELECT client_id
         FROM online_shop.action
         WHERE action_type = 'payment'
         GROUP BY client_id
         HAVING COUNT(action_type) >= 2) AS second_order),
	all_step as 
   (select 1 as step_num,
          'first_visit' as step, 
           first_visit as cnt
	from first_visit
	UNION
		select 2 as step_num,
	          'view_product' as step, 
	           view_product as cnt
	    from view_product
	UNION
		select 3 as step_num, 
		      'place_order' as step, 
		        place_order as cnt
		from place_order
	UNION
		select 4 as step_num, 
		       'payment_order' as step, 
		         payment_order as cnt
		from payment_order
	UNION
		select 5 as step_num, 
		       'second_order' as step, 
		        second_order as cnt
		from second_order)
select step, 
	   cnt,
	   100 * cnt / lag(cnt) over(order by step_num) as cr_next_step,
	   100 * cnt / (select cnt from all_step where step_num = 1) as cr_all
from all_step
order by step_num

--- Запрос 3.7 - время межу первым посещением и заказом
with first_visit as
	(select  client_id,
			 min(date_trunc('day',event_timestamp::date)) as date_first_visit
	from online_shop.action t1
	where action_type='registration'
	group by client_id),
    place_order as
	(select client_id,
			min(date_trunc('day',event_timestamp::date)) as date_place_order
	from online_shop.action t1
	where action_type='place_order'
	group by client_id	),
    time1 as
    (select fv.client_id,
	        po.date_place_order-fv.date_first_visit as time1
	from first_visit as fv
	left join place_order as po ON fv.client_id = po.client_id)
select  min(time1),
		max(time1),
		avg(time1)
from time1
		
--Запрос 3.8 - время между первым и повторным заказом
with first_order as
   (SELECT client_id,
		min(date_trunc('day',event_timestamp::date)) as date_first_order
	FROM online_shop.action
	WHERE action_type = 'payment'
	GROUP BY client_id),
    second_order AS
    (SELECT client_id,
		date_trunc('day',event_timestamp::date) as date_second_order
	 FROM 
	 	(SELECT client_id,
	            event_timestamp,
	           ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY event_timestamp) AS rn
	     from online_shop.action
	     WHERE action_type = 'payment') as rank_payment
	 WHERE rn=2	),
	time2 as 
    (select fo.client_id,
		    so.date_second_order-fo.date_first_order as time2
     from first_order as fo
     left join second_order as so on fo.client_id=so.client_id )
 select min(time2),
		max(time2),
		avg(time2)
from time2
 
	
---КОРОТНЫЙ АНАЛИЗ
--Запрос 4.1
 with min_orders as 
     (select client_id,
             date_trunc('month', min(event_timestamp::date)) as cogorta
      FROM online_shop.action t1
      join online_shop.order t2 on t1.action_id=t2.action_id
      WHERE t1.action_type = 'payment'
        and t2.quantity<>0 
        and t2.quantity<>999 
        and t2.price<>0 
      group by 1 ),
      orders_months as 
      (select distinct client_id,
              date_trunc('month', event_timestamp::date) as orders_months
       FROM online_shop.action t1
       join online_shop.order t2 on t1.action_id=t2.action_id
       WHERE t1.action_type = 'payment' 
        and  t2.quantity<>0 
         and t2.quantity<>999 
         and t2.price<>0),
      cohort as 
      (select	m.client_id,
		        m.cogorta,
		        om.orders_months,
		        (date_part('years', om.orders_months) - date_part('years', m.cogorta))*12 + (date_part('month', om.orders_months) - date_part('month', m.cogorta)) as period
       from	min_orders m
       join	orders_months om  on om.client_id = m.client_id
--where m.client_id='00076777-46f3-403f-a2cf-e9e12031a378'
       ),
       t1 as 
       (select	cogorta,
				period,
				count(client_id) as cnt_client
	    from	cohort
	    group by 1,2
         Order by 1),
		t2 as 
		( select cogorta,
				 sum(cnt_client) filter (where period = 0) as size, 
				 sum(cnt_client) filter (where period = 1) as p1,
				 sum(cnt_client) filter (where period = 2) as p2,
				 sum(cnt_client) filter (where period = 3) as p3,
				 sum(cnt_client) filter (where period = 4) as p4
         from t1
         group by 1)
select	cogorta,
		size,
		round (100 * p1/size, 2) as p1,
		round (100 * p2/size, 2) as p2,
		round (100 * p3/size, 2) as p3,
		round (100 * p4/size, 2) as p4
from t2

 




