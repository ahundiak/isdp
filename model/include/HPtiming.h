#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>

#undef __

struct	timing_stuff
		{
		int	stime, etime;
		int	atime;
		int	ncalls;
		};
		
extern struct	timing_stuff	timing[100];
extern struct	tms	 	tms_data;


/*---HPtiming_start--------------------------------------------------------------*/

#define	HPtiming_start( index )							\
										\
	{									\
	if( HPreport_file != NULL || HPglobal.debug )				\
		timing[index].stime = times( &tms_data );			\
	}
	
/*---HPtiming_stop---------------------------------------------------------------*/

#define	HPtiming_stop( index )							\
										\
	{									\
	if( HPreport_file != NULL || HPglobal.debug )				\
		{								\
		timing[index].etime = times( &tms_data );				\
		timing[index].atime += (timing[index].etime - timing[index].stime);	\
		timing[index].ncalls++;							\
		}								\
	}
