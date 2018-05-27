# get all O->D trips
od <- read.csv('/home/nate/scarbs_transit/trips/all_O->D.csv')
# convert some columns to factor
cols <- c('o','d','route_id','service_id','trip_id','h1','h2')
od[,cols] <- lapply(od[,cols],factor)
# identify and remove service days with wierd levels of service
# we should only have weekdays in this dataset
# get a frequency table of service_ids
freq = table(od$service_id)
# identify those further than 2 standard deviations from the mean trip count
wierd_days = as.numeric( 
	row.names(
		freq[ freq < mean(freq) - 1.5*sd(freq)]
	)
)
# plot the frequency table
#plot(freq)
#abline(h=mean(freq) - 1.5*sd(freq))
wierd_trips = od[ od$service_id %in% wierd_days, ]
od = od[ ! od$service_id %in% wierd_days, ]
# travel time in minutes
od$travel_time = (od$d_etime - od$o_etime) / 60
# identify the peaks
od$ToD <- factor( 
	ifelse(
		od$h1 %in% c(7,8,9),
		'morning',
		ifelse(
			od$h1 %in% c(12+4,12+5,12+6),
			'evening',
			'other'
		)
	)
)

# import sample times
sample_times <- read.csv('/home/nate/scarbs_transit/trips/sample-times.csv',stringsAsFactors=F)
sample_times$h = factor(sample_times$h)
sample_times$service_id = factor(sample_times$service_id)
# identify the peaks
sample_times$ToD <- factor( 
	ifelse(
		sample_times$h %in% c(7,8,9),
		'morning',
		ifelse(
			sample_times$h %in% c(12+4,12+5,12+6),
			'evening',
			'other'
		)
	)
)
# subset to the peaks
sample_times = sample_times[sample_times$ToD %in% c('morning','evening'),]
