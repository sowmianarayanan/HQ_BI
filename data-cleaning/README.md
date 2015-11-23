
Data Cleaning script checks for data inconsistencies in valid_offers.Due to Time constraints I have created a simple script which checks for few test cases in key fields from this table.

  # hotel_id - Not Null and Valid Number checks
  
  # currency_id - Not Null and Valid Number checks
  
  # source_sustem_code - Not Null check
  
  # checkin_date - Valid Date Check

  # checkoutdate - Valid Date Check
  
  # available_cnt - Valid Number Check
  
  # sellings_price - Not Null check

  # checking and checkout date - difference between the two days should not be more than 30/60 days.(depends on industry standards)
  
  # offer_valid_from - Valid Date Check
  
  # offer_valid_to - Valid Date Check
  
  # offer_valid_from & offer_valid_to - difference between should not be more than 30 days
  
  Test Cases for fx_rate table ( Not implemented in Script )
  
  # currency_rate - Not Null & Not Equal to 0 Check
  
  # Currency_rate - Multiple Entries for the same day - Dedup old entries for same day.
  
  Test Cases for  lst_currency ( Not implemented in Script )
  
  # Code - Not Null & Char.Length Check
  
  # Name - Not Null Check.
