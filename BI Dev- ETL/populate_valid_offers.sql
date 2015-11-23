## TRUNCATE  TABLE bi_data.valid_offers;


DROP PROCEDURE IF EXISTS populate_valid_offers;

DELIMITER //

CREATE PROCEDURE populate_valid_offers()

BEGIN      

	 DECLARE  v_status VARCHAR(255);
	 DECLARE  v_job_name VARCHAR(255); 
	 DECLARE  current_status VARCHAR(255); 
     DECLARE  v_start_time DATETIME;
     DECLARE  v_insert_datetime DATETIME;
  #   DECLARE EXIT HANDLER FOR SQLEXCEPTION
 
    BEGIN
       	/* Check whether no jobs are running parallely Exit if the Job status is set to Running  */
        
		# DECLARE EXIT HANDLER FOR SQLEXCEPTION
        # DECLARE job_config_exit CONDITION FOR SQLSTATE '45000';
        # DECLARE EXIT HANDLER FOR job_config_exit 
        # RESIGNAL SET MESSAGE_TEXT = 'Job is already Running, Exiting';
		 SET v_status = 'Started';
		 SET v_job_name = 'populate_valid_offers';
         SET v_start_time = sysdate();

		SELECT 
			job_status
		INTO current_status FROM
			job_config
		WHERE
			job_name = 'populate_valid_offers';

		IF current_status = 'Started' THEN    
			SELECT 'Job is already Running, Exiting..';
      #      SIGNAL job_config_exit;
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
         /* Drop and create a temporary table of primary_data.offer (Delta on insert_datetime)  */      
			SELECT 
				IFNULL(last_processed,DATE_FORMAT('1970-01-01', '%Y-%m-%d %H:%i:%s')) INTO v_start_time FROM job_config
			WHERE
				job_name = v_job_name ;
                    
		    DROP TABLE IF EXISTS offer_temp;
				 
			CREATE TABLE offer_temp AS SELECT * FROM
				primary_data.offer off
			WHERE
				off.insert_datetime > v_start_time;
     
     END;
        
     /* Inserts data in bi_data.valid_offers  */       
      
	INSERT into valid_offers 
     select 
		off.id as offer_id,
		off.hotel_id,
		off.sellings_price * fx.currency_rate  as price_usd,
		off.sellings_price as original_price,
		lst_source.`code` as original_currency_code,
		off.breakfast_included_flag,
		offer_valid_from as valid_from_date,
		offer_valid_to as valid_to_date
		 from
		 offer_temp off
		 left join
		 primary_data.fx_rate fx on off.currency_id = fx.prim_currency_id and date(off.checkout_date) = fx.`date`
		  join
		 primary_data.lst_currency lst on fx.scnd_currency_id = lst.id and lst.`code` = 'USD' 
		  join
		 primary_data.lst_currency lst_source on lst_source.id = off.currency_id
		 where
		 off.valid_offer_flag = 1;
         
       COMMIT;  
   
    BEGIN
    
    /* Update Job Config on completion of Job  */ 
    SET v_status = 'Completed';
    SELECT  max(insert_datetime) INTO v_insert_datetime FROM offer_temp;
    UPDATE job_config 
		      SET  end_time = now(),last_processed = v_insert_datetime ,`job_status` = v_status
        WHERE job_name = v_job_name;
             
     COMMIT;        
    
    END;
   
END //



