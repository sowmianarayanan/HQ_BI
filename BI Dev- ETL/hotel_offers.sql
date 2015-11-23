select 
date(offer_valid_from),
date(offer_valid_to),
extract( hour from offer_valid_from),
date_format(offer_valid_from,'%Y-%m-%d %H:00:00'),
date_format(offer_valid_to,'%Y-%m-%d %H:00:00'),
offer_valid_from,
offer_valid_to,
TIMESTAMPDIFF(HOUR,date_format(offer_valid_from,'%Y-%m-%d %h:00:00'),date_format(offer_valid_to,'%Y-%m-%d %h:00:00'))
 from  primary_data.offer
where valid_offer_flag = 1
and hotel_id = 64
order by offer_valid_from asc
limit 10;



select 

off.hotel_id,
dt.full_date,
dt.
off.breakfast_included_flag,

 from
bi_date.dim_date_time dt
left join
 bi_data.valid_offers  off on  dt.date_value between off.valid_from_date and off.valid_from_to;
