COPY (
	SELECT 
		t.trip_id,
		st1.stop_code AS o,
		st2.stop_code AS d,
		st1.etime AS o_etime,
		st2.etime AS d_etime,
		t.service_id,
		t.direction_id,
		t.route_id,
		st1.h AS h1,
		st2.h AS h2
	FROM ttc_trips AS t 
	JOIN ttc_stop_times AS st1 ON t.trip_id = st1.trip_id
	JOIN ttc_stop_times AS st2 ON t.trip_id = st2.trip_id
	WHERE 
		t.dow IN (1,2,3,4,5) AND 
		st1.stop_code IN ( -- origin
			7676, -- 
			7699, -- west UTSC ellesmere at military trail
			6371, -- 
			1037, -- east just outside kennedy station
			15281, -- west next from UTSC bus terminal
			6487, -- west kingston and Lawrence 
			9188, -- east york mills and bayview
			9076, -- east york mills and leslie
			14710,1037,2254,2292,2289,2283,4212,6488,15280,2942, -- eastbound 198
			14814,9188,9076,9070,9088,6371,6368,7719,7678,7693,7696,7684,7694,7676,1048,1052,7704 -- eastbound 95 express
		) AND 
		st2.stop_code IN ( -- destination
			7698, -- east UTSC ellesmere at military trail
			7677, -- 
			6372, -- 
			15278, -- west just outside kennedy station
			6488, -- east kingston and lawrence
			9069, -- west york mills and bayview
			9077, -- west york mills and leslie
			7700,7691,1049,7695,7685,7697,7692,7679,7720,7714,9083,9071,9077, -- stops on the 95E westbound
			2943,2951,6487,4226,4213,2282,11282,2243,2293,10140,15278 -- inbound stops on the 198
		) AND 
		st1.stop_sequence < st2.stop_sequence
	ORDER BY t.trip_id, st1.etime 
) TO '/home/nate/scarbs_transit/trips/all_O->D.csv' CSV HEADER;