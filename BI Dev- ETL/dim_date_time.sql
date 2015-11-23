USE bi_data;

DROP PROCEDURE IF EXISTS create_dim_datetime;

delimiter //
CREATE PROCEDURE create_dim_datetime (var_start_date DATE, var_end_date DATE)
BEGIN
    DECLARE cur_date DATE;

  --  TRUNCATE TABLE dim_datetime;

    SET cur_date = var_start_date;
    WHILE cur_date <= var_end_date DO
    
    BEGIN
       DECLARE v_hour INT Default 0;
         simple_loop: LOOP         
      /*   insert into table1 values(a); */
         
        INSERT INTO dim_datetime (
             date_id, 
			 date_value,
			 fulldate ,
			`date`,
			`hour`
        ) VALUES (
            date_format(concat(cur_date,' ',LPAD(v_hour,2,'0')),'%Y%m%d%H'),
            date_format(concat(cur_date,' ',LPAD(v_hour,2,'0')),'%Y-%m-%d %H'),
            DATE_FORMAT(cur_date,'%Y%m%d'),
            cur_date,
            v_hour
        );
 
       SET v_hour=v_hour+1;
       IF v_hour=24 THEN
            LEAVE simple_loop;
         END IF;
   END LOOP simple_loop;
   END;

        SET cur_date = DATE_ADD(cur_date, INTERVAL 1 DAY);
    
      END WHILE;
END //






