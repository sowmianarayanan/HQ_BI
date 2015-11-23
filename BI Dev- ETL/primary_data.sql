CREATE SCHEMA IF NOT EXISTS primary_data;

USE primary_data;

CREATE TABLE IF NOT EXISTS offer
(
id bigint,
hotel_id bigint,
currency_id int,
source_system_code varchar(255),
available_cnt varchar(255),
sellings_price varchar(255),
checkin_date date,
checkout_date date,
valid_offer_flag varchar(2),
offer_valid_from datetime,
offer_valid_to datetime,
breakfast_included_flag varchar(2),
insert_datetime datetime
);


LOAD DATA LOCAL INFILE '/Users/sowmia.naraynan/Downloads/offer.csv'
 INTO TABLE offer
 FIELDS TERMINATED BY ','
 LINES TERMINATED BY '\n' 
 IGNORE 1 LINES ;

create index idx_offer on offer(insert_datetime);

CREATE TABLE lst_currency
(
id int,
`code` varchar(40),
`name` varchar(40)
);

LOAD DATA LOCAL INFILE '/Users/sowmia.naraynan/Downloads/lst_currency.csv'
 INTO TABLE lst_currency
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n' 
 IGNORE 1 LINES ;

CREATE TABLE fx_rate 
(
id int,
prim_currency_id int,
scnd_currency_id int,
`date` date,
currency_rate int
);

LOAD DATA LOCAL INFILE '/Users/sowmia.naraynan/Downloads/fx_rate.csv'
 INTO TABLE fx_rate
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n' 
 IGNORE 1 LINES ;