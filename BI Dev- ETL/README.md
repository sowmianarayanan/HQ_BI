Hi,

I have used MySQL as database since it is Open-source and easy to install. Even though I am familiar with Pentaho Kettle ETL, Amazon Redshift & Oracle PL/SQL , I have picked MySQL and creating Stored procedures in MySQL just to come out of my comfort zone.

Since I had very less time during working days, I was unable to follow exact conventions and include error handlers in proc. please excuse for missing few things.

Below are the steps to follow:

Step 1: Run primary_data.sql, It has table creation scripts for source table (primary_data schema & table creation)

Step 2: Run bi_data.sql, It has table creation scripts for target BI Tables (bi_data schema & table creation), In addition to the tables explained in problem, we have three more tables 

2.1. dim_datetime - Date & Time dimension table, Single dimension table having granularity at Hour level.

2.2. dim_hotel - SCD Type 1: Dimension table to hold all hotel information. 

2.3. job_config - To Keep track of job executions and to have lock mechanism where jobs cannot start if previous execution is still running.

Step 3: Run the script dim_datetime.sql ( Prerequisites script )

It accepts start & end date, populates hourly entry between this range. Dimension tables are very important for the BI stack to rollup and drill down.  We have included Date & Time in a same dimension at hour granularity as it is needed as per problem statement. We have kept very few columns in dim_datetime table, But we can extend it later depending on our reporting needs.

Execute: create_dim_datetime('2011-01-01','2020-10-01'); -- It will create 24 * numberofdays within the range

Step 4: populate_valid_offers.sql : ETL Script to process source table info to bi_data.valid_offers 

How it works:

4.1 . Look at Job_config where any other instance of same process running ( with Status : "Started" ), It proceeds if there are no existing jobs. 

4.2 . Create a temp table on primary_data.offer for the all database entries created after last_processed 

4.3 . Join offer,fx_rate,lst_currency for all offers with valid_offer_flag = 1; 

4.4 . Date(checkout_date) has been taken as reference for forex price lookup, on a assumption that people will settle their payments on checkout day. 

4.5 . Null will be assigned if there are no forex price conversion details available in fx_rate on the specific day.

4.6 . Update the Job_config with status 'Completed' on completion. Execute: call populate_valid_offers();

Step 5: populate_hotel_offers.sql : ETL Script to process source table info bi_data.hotel_offers where it will create entry for each day and hour if it had atleast one offer on that day. 

5.1 . Look at Job_config where any other instance of same process running ( with Status : "Started" ), It proceeds if there are no existing jobs. 

5.2 . Create a temp table on primary_data.offer for the all database entries created after last_processed 

5.3 . dim_hotel will be updated with recent data ( SCD Type 1 ).

5.4 . Join dim_hotel,dim_datetime & temp table to have all combination of date and hour information for every hotel, On multiple offer entries for the same hour interval, Max of valid_offer_flag will be considered. 

5.5 . On Duplicate Key Constraint, Update the valid_offer_flag with the recent (takes care of changing invalid to valid offer and vice-versa).

5.6 . Update the Job_config with status 'Completed' on completion.


Execution Steps:

1. Execute primary_data.sql
2. Execute bi_data.sql
3. Execute dim_date_time.sql
4. Execute populate_valid_offers.sql
5. Execute populate_hotel_offers.sql
6. call create_dim_datetime('2011-01-01','2020-10-01');
7. call populate_valid_offers();
8. call populate_hotel_offers();

Data Cleaning:
9. Execute data-cleaning/data_cleaning.sql
10. call data_cleaning();

