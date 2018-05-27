-- select service days
DELETE FROM ttc_trips
WHERE 
	service_id <= 17459 OR -- start
	service_id IN ( 17486, 17487, 17488 ) OR -- gap period
	service_id >= 17644; --end
-- start date is...
SELECT (timestamp 'epoch' + 17460 * interval '1 day')::date;
-- end date is...
SELECT (timestamp 'epoch' + 17643 * interval '1 day')::date;

-- remove trips that don't even need to be processed
DELETE FROM ttc_trips WHERE ST_Length(orig_geom) < 500;

-- update the service_id after processing finished
WITH sub AS (
	SELECT 
		t.trip_id, 
		( to_timestamp(st.etime) AT TIME ZONE 'America/Toronto' )::date - '1970-01-01'::date AS service_id
	FROM ttc_trips AS t 
	LEFT JOIN ttc_stop_times AS st
		ON t.trip_id = st.trip_id AND st.stop_sequence = 1
)
UPDATE ttc_trips AS t SET service_id = sub.service_id
FROM sub 
WHERE t.trip_id = sub.trip_id AND (t.service_id != sub.service_id OR t.service_id IS NULL) ;

-- set the day of week (dow) on trips table from the service_id 
-- for easier queries later
UPDATE ttc_trips SET dow = EXTRACT(DOW FROM timestamp 'epoch' + service_id * interval '1 day');

-- number of complete weekdays in the dataset
SELECT COUNT( DISTINCT service_id )
FROM ttc_trips
WHERE service_id IS NOT NULL AND dow IN (1,2,3,4,5); 

-- how many valid weekday trips do we have on each route?
SELECT 
	route_id,
	COUNT(*),
	array_agg(DISTINCT dow),
	array_agg(DISTINCT direction_id)
FROM ttc_trips 
WHERE 
	dow IN (1,2,3,4,5) AND 
	NOT ignore
GROUP BY route_id;

-- set the local time of the stops
UPDATE ttc_stop_times SET tloc = 
	(timestamptz 'epoch' + etime * interval '1 second') AT TIME ZONE 'America/Toronto'
WHERE tloc IS NULL;

-- add stop codes directly into the stop times table
UPDATE ttc_stop_times AS st SET stop_code = s.stop_code 
FROM ttc_stops AS s 
WHERE s.uid = st.stop_uid AND st.stop_code IS NULL; 