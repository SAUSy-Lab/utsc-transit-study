# function for sampling waits and total travel times from uniform random arrivals 
# within a time period
add_waits <- function(trips,sample_times){
	# select the next time from a vector
	next_time <- function(etime,etimes){
		later = etimes[etimes >= etime]
		next_time = if( length(later) > 0 ) min(later) else NA
		return(next_time)
	}
	# get sample time points based on distinct days in the trips data
	sample = sample_times[sample_times$service_id %in% unique(trips$service_id), 'etime' ]
	# get arrival time for each sample point
	o_etime = sapply(sample, next_time, etimes=trips$o_etime)
	# bind them together in a table
	results = data.frame(cbind(sample,o_etime))
	# calculate wait times
	results$wait = (results$o_etime-results$sample) / 60
	# join to trips
	x = merge( x=results, y=trips, by='o_etime', type='left', all.x=T )
	# get the total travel time with wait included
	x$total = x$wait + x$travel_time
	# trim implausible outliers
	x = x[x$wait<30,]
	return(x)
}