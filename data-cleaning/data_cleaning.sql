USE primary_data;

DROP PROCEDURE IF EXISTS data_cleaning;

DELIMITER //

CREATE PROCEDURE data_cleaning()
    
  BEGIN
  
     DECLARE  v_status VARCHAR(255);
	 DECLARE  v_job_name VARCHAR(255); 
	 DECLARE  current_status VARCHAR(255); 
     DECLARE  v_start_time DATETIME;
     DECLARE  v_last_processed DATETIME;
	 DECLARE v_finished INTEGER DEFAULT 0;
     DECLARE v_id BIGINT;
	 DECLARE v_hotel_id BIGINT;
     DECLARE v_currency_id INT(11);
	 DECLARE v_source_system_code VARCHAR(255);
	 DECLARE v_available_cnt VARCHAR(255);
	 DECLARE v_sellings_price VARCHAR(255);
	 DECLARE v_checkin_date DATE;
	 DECLARE v_checkout_date DATE;
	 DECLARE v_valid_offer_flag VARCHAR(2);
	 DECLARE v_offer_valid_from DATETIME;
	 DECLARE v_offer_valid_to DATETIME;
	 DECLARE v_breakfast_included_flag VARCHAR(2);
     DECLARE v_insert_datetime DATETIME;
     DECLARE v_count int default 0;
     DECLARE invalid_record  int default 0;
     DECLARE v_verror_msg VARCHAR(1000) default NULL;
 
    BEGIN
       	/* Check whether no jobs are running parallely Exit if the Job status is set to Running  */
        
		 SET v_status = 'Started';
		 SET v_job_name = 'data_cleaning';
         SET v_start_time = sysdate();

		SELECT 
			job_status
		INTO current_status FROM
			bi_data.job_config
		WHERE
			job_name = 'data_cleaning';

		IF current_status = 'Started' THEN    
			SELECT 'Job is already Running, Exiting..';
      #      SIGNAL job_config_exit;
		 ELSE
			/* Update Job etl_activity table with start time and status  */     
			SELECT 'Starting Execution..';
			UPDATE bi_data.job_config 
				  SET  start_time = v_start_time,end_time = NULL,`job_status` = v_status
			WHERE
				 job_name = v_job_name;
		END IF;

    END;
    
	BEGIN
         /* Drop and create a temporary table of primary_data.offer (Delta on insert_datetime)  */      
			SELECT 
				IFNULL(last_processed,DATE_FORMAT('1970-01-01', '%Y-%m-%d %H:%i:%s')) INTO v_start_time FROM bi_data.job_config
			WHERE
				job_name = v_job_name ;
                    
		    DROP TABLE IF EXISTS offer_temp_dc;
				 
			CREATE TABLE offer_temp_dc AS SELECT * FROM
				offer off
			WHERE
				off.insert_datetime > v_start_time;
     
     END;
     
     BEGIN
		 
		 -- declare cursor for employee email
		 DEClARE v_cursor CURSOR FOR 
                 SELECT  id,
						 hotel_id,
                         currency_id,
                         source_system_code,
                         available_cnt,
                         sellings_price,
                         checkin_date,
                         checkout_date,
                         valid_offer_flag,
                         offer_valid_from,
                         offer_valid_to,
						 breakfast_included_flag,
                         insert_datetime
                 FROM offer_temp_dc;
		 
		 -- declare NOT FOUND handler
		 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
		 
		 OPEN v_cursor;
		 
		 get_record: LOOP
         
         SET invalid_record = 0; 
         
         FETCH v_cursor INTO v_id,v_hotel_id,v_currency_id,
         v_source_system_code,v_available_cnt,v_sellings_price,v_checkin_date,v_checkout_date,
                         v_valid_offer_flag,v_offer_valid_from,v_offer_valid_to,v_breakfast_included_flag,v_insert_datetime;
		 
	     SET invalid_record = 0;      
         
		 IF v_finished = 1 THEN 
		 LEAVE get_record;
		 END IF;
          
         SET v_count = v_count + 1;
         
         IF v_hotel_id  NOT REGEXP '^[0-9]+$' OR v_hotel_id is null THEN
         SET invalid_record = 1;
		 SET v_verror_msg = "hotel_id has incorrect values";
         END IF;
         
          IF v_currency_id  NOT REGEXP '^[0-9]+$' OR v_currency_id is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","currency_id has incorrect values");
         END IF;
         
          IF v_source_system_code is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","source_system_code has incorrect values");
         END IF;
         
          IF v_sellings_price is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","v_sellings_price has incorrect values");
         END IF;
         
          IF v_checkin_date is null OR date(v_checkin_date) is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","checkin_date has incorrect values");
         END IF;
         
          IF v_checkout_date is null OR date(v_checkout_date) is null  THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","checkin_date has incorrect values");
         END IF;
         
         IF v_valid_offer_flag is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","valid_offer_flag has incorrect values");
         END IF;
         
         IF v_offer_valid_from is null OR date(v_offer_valid_from) is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","offer_valid_from has incorrect values");
         END IF;
         
         IF v_offer_valid_to is null OR date(v_offer_valid_to) is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","offer_valid_to has incorrect values");
         END IF;
         
         IF v_breakfast_included_flag is null THEN
         SET invalid_record = 1;
         SET v_verror_msg = CONCAT(v_verror_msg,";","breakfast_included_flag has incorrect values");
         END IF;
         
         IF invalid_record = 1 THEN
         
         INSERT INTO bi_data.offer_error values ( v_id,v_hotel_id,v_currency_id,v_source_system_code,v_available_cnt,v_sellings_price,v_checkin_date,v_checkout_date,
                         v_valid_offer_flag,v_offer_valid_from,v_offer_valid_to,v_breakfast_included_flag,v_insert_datetime,v_verror_msg);
               
         COMMIT;
         
         END IF;
         
		 END LOOP get_record;
		 
		 CLOSE v_cursor; 
          
          
     END;
     
     BEGIN
    
    /* Update Job Config on completion of Job  */ 
    SET v_status = 'Completed';
    SELECT  max(insert_datetime) INTO v_last_processed FROM offer_temp_dc;
    UPDATE bi_data.job_config 
		      SET  end_time = now(),last_processed = v_last_processed ,`job_status` = v_status
        WHERE job_name = v_job_name;
             
     COMMIT;        
    
    END;

         
END //
