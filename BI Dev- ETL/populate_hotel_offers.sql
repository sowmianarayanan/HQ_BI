DROP PROCEDURE IF EXISTS populate_hotel_offers;

DELIMITER //

CREATE PROCEDURE populate_hotel_offers()
    

  BEGIN
    
     DECLARE  v_status VARCHAR(255);
	 DECLARE  v_job_name VARCHAR(255); 
	 DECLARE  current_status VARCHAR(255); 
     DECLARE  v_start_time DATETIME;
     DECLARE  v_insert_datetime DATETIME;
     DECLARE invalid_value CONDITION FOR SQLSTATE '45000';
     DECLARE EXIT HANDLER FOR invalid_value 
	 
     SET v_status = 'Started';
	 SET v_job_name = 'populate_hotel_offers';
	 SET v_start_time = sysdate();
    
    BEGIN
       	/* Check whether no jobs are running parallely Exit if the Job status is set to Running  */

		SELECT 
			job_status
		INTO current_status FROM
			job_config
		WHERE
			job_name = 'populate_hotel_offers';

		IF current_status = 'Started' THEN    
			SELECT 'Job is already Running, Exiting..';
			SIGNAL invalid_value;
		 ELSE
			/* Update Job etl_activity table with start time and status  */     
			SELECT 'Starting Execution..';
			UPDATE job_config 
				  SET  start_time = v_start_time,end_time = NULL,`job_status` = v_status
			WHERE
				 job_name = v_job_name;
		END IF;

    END;
    
    
    BEGIN
    
      /* Create Temporary Table for primary_data.offer table */
     
     SELECT IFNULL(last_processed,DATE_FORMAT('1970-01-01', '%Y-%m-%d %H:%i:%s')) INTO v_start_time from bi_data.job_config
        WHERE job_name = 'populate_hotel_offers';
        
     DROP TABLE IF EXISTS hotel_offer_temp;
     
     CREATE TABLE hotel_offer_temp
     as
     select * from primary_data.offer off
     where off.insert_datetime > v_start_time;
     
     END;
     
	BEGIN
    
    /* SCD Type 1 for dim_hotel */
     
	  INSERT INTO dim_hotel ( hotel_id,inserted_date, updated_date) 
		select distinct hotel_id,sysdate(),sysdate() from bi_data.hotel_offer_temp
		  ON DUPLICATE KEY UPDATE
		updated_date=sysdate();
        
        COMMIT;
     
     END;
     
    
     BEGIN
     
            INSERT INTO  hotel_offers ( hotel_id,date,hour,breakfast_included_flag,valid_offer_available_flag) 
            select
			hot.hotel_id,
            dat.fulldate,
			dat.hour,
			temp.breakfast_included_flag,
			max(case when dat.date_value between temp.offer_valid_from and temp.offer_valid_to 
					 then temp.valid_offer_flag 
					 else 0 
			end) as valid_offer_available_flag
			from
				dim_hotel hot
				join
				hotel_offer_temp temp on hot.hotel_id = temp.hotel_id
				join
				dim_datetime dat on dat.fulldate between temp.offer_valid_from and temp.offer_valid_to
			group by 1,2,3,4
            ON DUPLICATE KEY UPDATE breakfast_included_flag=breakfast_included_flag,
									valid_offer_available_flag=valid_offer_available_flag;
 
     END;
     
     BEGIN
    
    /* Update Job Config on completion of Job  */ 
		SET v_status = 'Completed';
		SELECT  max(insert_datetime) INTO v_insert_datetime FROM hotel_offer_temp;
		UPDATE job_config 
				  SET  end_time = now(),last_processed = v_insert_datetime ,`job_status` = v_status
			WHERE job_name = v_job_name;
				 
		COMMIT;        
    
    END;
   
END //



