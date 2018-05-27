# Data is the origin and destination arrival times for trips between two stops
# Get all O->D trips
source('/home/nate/scarbs_transit/import-data.r')

# density() params
bw = 1
n = 1000
# colors
col_exp = rgb(187,125,69,alpha=70,max=255) # blue
col_loc = rgb(100,90,166,alpha=74,max=255) # red
# segments to look at 
segments = list(
	list(
		name = '198_vs_86_kennedy_lawrence', 
		# from stop_code 6487 (lawrence) to stop_code 15278 (kennedy) 
		# from stop_code 1037 (kennedy) to stop_code 6488 (lawrence) 
		east_stops = c(6488,6487), # check 
		west_stops = c(15278,1037), # check
		express_names = c('198_0_198','198_1_198'),
		xlim = c(10,30),
		ylim = c(0,.21)
	)#,
#	list(
#		name = '95_vs_95e_bayview_UTSC',
#		east_stops = c(7698,7699), # ellesmere at military trail
#		west_stops = c(9188,9069), # york mills at bayview
#		express_names = c('95_0_95E','95_1_95E'),
#		xlim = c(30,60),
#		ylim = c(0,.14)
#	)
)
# loop over each of the segments to be plotted
for( segment in segments ){
	# set variables for this iteration
	name = segment[['name']]
	east_stops = segment[['east_stops']]
	west_stops = segment[['west_stops']]
	express_names = segment[['express_names']]
	xlim = segment[['xlim']]
	ylim = segment[['ylim']]
	# print
	print(paste( 'working on', name ))
	# identify the direction of travel (RELATIVE TO THIS SEGMENT)
	od$dir <- factor(
		ifelse(
			od$o %in% west_stops & od$d %in% east_stops, # heading east
			'east',
			ifelse(
				od$o %in% east_stops & od$d %in% west_stops, # heading west
				'west',
				'unknown'
			)
		)
	)
	# distinguish express service (RELATIVE TO THIS SEGMENT)
	od$express <- factor( od$direction_id %in% express_names )
	# plot
#	pdf(
#		paste0('/home/nate/Dropbox/UTSC transit/figures/',name,'.pdf'),
#		width = (max(xlim)-min(xlim))*0.2,
#		height = 4
#	)
		par( mfrow=c(5,1), mar=c(0,0,0,0), family="serif" ) # margins are bottom left top right
		# four plots by direction and peak time
		for(time_of_day in c('morning','evening')){
			for(direction in c('west','east')){
				# make blank plot
				plot( 0, axes=F, type="b", xlab="", ylab="", xlim=xlim, ylim=ylim, main='' )
				# for both express and local, plot the density
				for(express in c(T,F)){
					# get data for each direction of travel
					d = od[od$express==express & od$dir==direction & od$ToD==time_of_day,]
					# calculate the density
					dens = density( d$travel_time, bw=bw, n=n )
					print( paste( time_of_day, direction, express, sqrt( 2*var(d$travel_time) ) ) )
					polygon( # plot the densities together
						x=dens$x, y=dens$y, 
						col=( if(express) col_exp else col_loc ), 
						lty=0
					)
					# plot the medians
#					abline(
#						v = c( median(w$travel_time), median(e$travel_time) ),
#						col = if(express) col_exp else col_loc,
#						lty=2
#					)
				}
			}
		}
		plot( 0, axes=F, type="b", xlab="", ylab="", xlim=xlim, ylim=ylim, main='' )
		ticks = seq(xlim[1],xlim[2],by=2)
		abline(v=ticks)
		text(x=ticks,y=rep(mean(ylim),length(ticks)),labels=ticks)
#	dev.off()
}
#	# stats output
#	w_exp = od[od$express==T & od$dir=='west' & od$ToD==time_of_day,'travel_time']
#	w_loc = od[od$express==F & od$dir=='west' & od$ToD==time_of_day,'travel_time']
#	e_exp = od[od$express==T & od$dir=='east' & od$ToD==time_of_day,'travel_time']
#	e_loc = od[od$express==F & od$dir=='east' & od$ToD==time_of_day,'travel_time']
#	print( paste(name, time_of_day, 'w / e express travel time gains') )
#	print(1 - median(w_exp) / median(w_loc) )
#	print(1 - median(e_exp) / median(e_loc) )