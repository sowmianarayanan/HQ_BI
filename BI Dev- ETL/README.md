Hi,

I have used MySQL as database since it is Open-source and easy to install. Even though I am familiar with Pentaho Kettle ETL & Oracle PL/SQL , I have
picked MySQL and creating Stored procedures in MySQL just to come out of my comfort zone.


Step 1: Run primary_data.sql, It has table creation scripts for source table ( primary_data schema creation )
Step 2: Run bi_data.sql, It has table creation scripts for target (BI Tables - bi_data schema creation )

In addition to the tables explained in problem, we have added few tables

2.1. dim_datetime - Date & Time in a same dimension table
2.2. dim_hotel - SCD Type 1: Dimension table to hold all hotel information.
2.3. job_config - To Keep track of job executions and to have lock mechanism where jobs should not start 
if previous execution is still running.

Step 3:  Run the script dim_datetime.sql  ( Prerequisites script )

     It will create table dim_datetime table. Dimension tables are very important for the BI stack to slice/rollup.
We have mixed Date & Time in a same dimension table as it matches our problem statement. We have kept few columns in
 dim_datetime table, But we can extend it later depending on our needs

Execute: create_dim_datetime('2011-01-01','2020-10-01'); 

It will create 24 * numberofdays within the range

Step 4: populate_valid_offers.sql : ETL to process source table info to bi_data.valid_offers

How it works:

4.1 . Look at Job_config where any other instance of same process running ( with Status : "Started" ), It proceeds if there are 
no existing jobs.
4.2 . Check for last_processed , Create a temp table for primary_data.offer so that recent updates does not affect the data.
4.3 . Join offer,fx_rate,lst_currency for all offers with valid_offer_flag = 1;
4.4 . Date(checkout_date) has been taken as reference for forex price lookup, on a assumption that people will settle their payments on checkout day.
4.5 . Null will be assigned if there are no forex price conversion details available in fx_rate
4.6 . Update the Job_config with status 'Completed'

Execute: call populate_valid_offers();

Step 5: populate_hotel_offers.sql : ETL to process source table info to bi_data.hotel_offers where it will create entry for each day and hour
if it had atleast one offer.

4.1 . Look at Job_config where any other instance of same process running ( with Status : "Started" ), It proceeds if there are 
no existing jobs.
4.2 . Check for last_processed , Create a temp table for primary_data.offer so that recent updates does not affect the data.
4.3 . dim_hotel will be updated with recent data ( SCD Type 1 ).
4.4 . Join dim_hotel,dim_datetime & temp table to have all combination of date and hour information for every hotel.
4.6 . On multiple offer entries, Max of valid_offer_flag will be considered.
4.7 . On Duplicate Key Constraint, Update the valid_offer_flag with the recent, this is take care of changing invalid to valid offer and vice-versa.
4.5 . Update the Job_config with status 'Completed'


