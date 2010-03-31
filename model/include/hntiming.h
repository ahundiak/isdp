
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/*
DESCRIPTION
	Define NC_TIMING as 1 and recompile ncv_func if you want
	execution time and time spent in individual functions.
	This code borrows heavily from the VE timing functions.

HISTORY
	C.M. Jablonski	06/16/89  Creation Date.
*/

#define NC_TIMING	0

#if NC_TIMING

#define NUM_NC_TIMES	12

#define NCtd_INIT		0
#define NCtd_DO_STEP		1
#define NCtd_MOVE_TOOL		2
#define NCtd_BRESENHAM		3
#define NCtd_SUBTRACT_SIM	4
#define NCtd_PAINT_SIM		5
#define NCtd_BUILD_SWVOL	6
#define NCtd_DEX_SWVOL		7
#define NCtd_SUBTRACT_DEX	8
#define NCtd_PAINT		9
#define NCtd_CLEANUP		10
#define NCtd_TILE		11

struct NCtd
	{
	IGRchar 	name[24];
	IGRlong		num_calls;
	struct tms	start;
	struct tms	stop;
	IGRdouble	total_time;
	};

extern struct NCtd	nc_timing_data[NUM_NC_TIMES];


#define START_NC_TIMING(x)						\
									\
	times( &nc_timing_data[x].start );				\
	

#define STOP_NC_TIMING(x)						\
									\
	times( &nc_timing_data[x].stop );				\
									\
	nc_timing_data[x].total_time +=					\
		((nc_timing_data[x].stop.tms_stime +			\
		  nc_timing_data[x].stop.tms_utime) -			\
		 (nc_timing_data[x].start.tms_stime +			\
		  nc_timing_data[x].start.tms_utime)) / 60.0;		\
	nc_timing_data[x].num_calls = nc_timing_data[x].num_calls + 1;	\
	

#else

#define START_NC_TIMING(x)

#define STOP_NC_TIMING(x)

#endif
