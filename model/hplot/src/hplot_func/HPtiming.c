#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

struct	timing_stuff
		{
		int	stime, etime;
		int	atime;
		int	ncalls;
		};
		
extern struct	timing_stuff	timing[100];
extern struct	tms	 	tms_data;

/*---HPtiming_report-------------------------------------------------------------*/
	
/*	
NAME
	HPtiming_report
	
KEYWORD
	HSplot
	timing
	
DESCRIPTION
	Display timing information for each of the set of timing nodes
	
HISTORY
	??/??/??	M. Lanier
		Created
		
*/	

#if defined(__STDC__) || defined(__cplusplus)
	HPtiming_report( FILE	*outfile )
#else
	HPtiming_report( outfile )

	FILE	*outfile;
#endif

	{
	double	atime;

	fprintf( outfile, "\n\nTiming Results.\n" );
	fprintf( outfile, "-------------------------------------------------------------\n" );
	fprintf( outfile, "routine                  number accumulated avg. time pct tot\n" );
	fprintf( outfile, "name                     calls  time sec    per call   time\n" );
	fprintf( outfile, "------------------------ ------ ----------- --------- -------\n" );

	if( timing[0].ncalls != 0 )
		{
		atime  = (double)timing[0].atime;

		fprintf( outfile, " Total time            %6d %11.3f %9.5f %7.2f\n",
				timing[0].ncalls,
				atime / 60.0,
				(atime / (double)timing[0].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[1].ncalls != 0 )
		{
		atime  = (double)timing[1].atime;
		atime -= (double)timing[2].atime;

		fprintf( outfile, " create rle            %6d %11.3f %9.5f %7.2f\n",
				timing[1].ncalls,
				atime / 60.0,
				(atime / (double)timing[1].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[2].ncalls != 0 )
		{
		atime  = (double)timing[2].atime;
		atime -= (double)timing[3].atime;
		atime -= (double)timing[4].atime;
		atime -= (double)timing[5].atime;

		fprintf( outfile, "  create band          %6d %11.3f %9.5f %7.2f\n",
				timing[2].ncalls,
				atime / 60.0,
				(atime / (double)timing[2].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[3].ncalls != 0 )
		{
		atime  = (double)timing[3].atime;
		atime -= (double)timing[6].atime;
		atime -= (double)timing[7].atime;

		fprintf( outfile, "   zbuffered surface   %6d %11.3f %9.5f %7.2f\n",
				timing[3].ncalls,
				atime / 60.0,
				(atime / (double)timing[3].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[6].ncalls != 0 )
		{
		atime  = (double)timing[6].atime;

		fprintf( outfile, "    raster lines       %6d %11.3f %9.5f %7.2f\n",
				timing[6].ncalls,
				atime / 60.0,
				(atime / (double)timing[6].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[7].ncalls != 0 )
		{
		atime  = (double)timing[7].atime;

		fprintf( outfile, "    silly lines        %6d %11.3f %9.5f %7.2f\n",
				timing[7].ncalls,
				atime / 60.0,
				(atime / (double)timing[7].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[4].ncalls != 0 )
		{
		atime  = (double)timing[4].atime;

		fprintf( outfile, "   zbuffered curve     %6d %11.3f %9.5f %7.2f\n",
				timing[4].ncalls,
				atime / 60.0,
				(atime / (double)timing[4].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	if( timing[5].ncalls != 0 )
		{
		atime  = (double)timing[5].atime;

		fprintf( outfile, "   make rle            %6d %11.3f %9.5f %7.2f\n",
				timing[5].ncalls,
				atime / 60.0,
				(atime / (double)timing[5].ncalls) / 60.0,
				(atime / (double)timing[0].atime) * 100 );	
		}

	}
