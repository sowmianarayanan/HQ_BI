CREATE SCHEMA IF NOT EXISTS bi_data;

USE bi_data;

CREATE TABLE valid_offers
(
offer_id INT,
hotel_id INT,
price_usd FLOAT,
original_price FLOAT,
original_currency_code VARCHAR(35),
breakfast_included_flag TINYINT,
valid_from_date DATETIME,
valid_to_date DATETIME
)ENGINE=InnoDB;

CREATE TABLE hotel_offers
(
hotel_id INT,
date DATE,
hour TINYINT,
breakfast_included_flag TINYINT,
valid_offer_available_flag TINYINT,
PRIMARY KEY(hotel_id,`date`,`hour`)
)ENGINE=InnoDB;

CREATE TABLE dim_hotel
(
hotel_id INT,
hotel_name VARCHAR(255),
is_active TINYINT,
inserted_date DATETIME,
updated_date DATETIME
)ENGINE=InnoDB;

CREATE TABLE job_config
(
id INT,
job_name VARCHAR(255),
last_processed	DATETIME,
start_time DATETIME,
end_time DATETIME,
job_status VARCHAR(255)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dim_datetime  (
    date_id INT NOT NULL, -- 2011010101
    date_value datetime,  -- 2011/01/01 01:00:00
	fulldate date,        -- 20110101
    `date` date,           --  2011/01/01
	`hour` int,            -- 01
    PRIMARY KEY(date_id)
) ENGINE=InnoDB;

INSERT INTO `bi_data`.`job_config`
(`id`,
`job_name`,
`last_processed`,
`start_time`,
`end_time`,
`job_status`)
VALUES
(1,
'populate_valid_offers',
NULL,
NULL,
NULL,
NULL);

INSERT INTO `bi_data`.`job_config`
(`id`,
`job_name`,
`last_processed`,
`start_time`,
`end_time`,
`job_status`)
VALUES
(2,
'populate_hotel_offers',
NULL,
NULL,
NULL,
NULL);

INSERT INTO `bi_data`.`job_config`
(`id`,
`job_name`,
`last_processed`,
`start_time`,
`end_time`,
`job_status`)
VALUES
(3,
'data_cleaning',
NULL,
NULL,
NULL,
NULL);


COMMIT;

