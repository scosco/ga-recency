-- GA sample data: bigquery-public-data.google_analytics_sample.ga_sessions_
-- filter for sessions with a certain condition
-- show time difference in days between these sessions per visitor

WITH const AS (SELECT 
  '170601' startDate, 
  '170801' endDate
  )
,d as (
  SELECT 
      fullvisitorid, 
      -- put dates into an array ordered ascending
      array_agg(distinct parse_date('%Y%m%d',date) order by parse_date('%Y%m%d',date) ) dates
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20*` t
  WHERE 
      -- only sessions with add to cart events
      (select count(1)>0 from t.hits WHERE eventinfo.eventaction='Add to Cart' )
    AND
      -- use temp table for date range
      (select _table_suffix between startDate and endDate from const)
  group by 1
  having array_length(dates)>2 -- for testing REMOVE
)

SELECT 
  fullvisitorid,
    -- select from unnested array - feed into new array
    array(select as struct *, 
      -- show previous date
      lag(date) over (order by date) prevDate,
      -- show time diff to previous date
      date_diff(date, lag(date) over (order by date) , DAY) diff
  FROM d.dates as date)
FROM d
