#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/times.h>
#include "timing.h"
		
struct	timing_stuff	timing[100];

static int	max_timing_index = -1;

/*---init_timing----------------------------------------------------------*/

void init_timing( int index, char *title )

   {
   if( strcmp( title, timing[index].title ) == 0 ) return;

   memcpy( timing[index].title, title, strlen( title ) + 1 );
	
   timing[index].stime = 0;
   timing[index].etime = 0;
   timing[index].atime = 0;
   timing[index].ncalls = 0;
	
   if( index > max_timing_index ) max_timing_index = index;
   }
	
/*---report_timing--------------------------------------------------------*/
	
void report_timing( FILE *fp )

   {
   double	atime, pct;
   int	i;

   fprintf( fp, "\n\nTiming Results.\n" );
   fprintf( fp, "------------------------------------------------------------------------------\n" );
   fprintf( fp, "routine                                   number accumulated avg. time pct tot\n" );
   fprintf( fp, "name                                      calls  time sec    per call   time\n" );
   fprintf( fp, "----------------------------------------- ------ ----------- --------- -------\n" );

   for( i=0; i<=max_timing_index; i++ )
      {
      if( timing[i].ncalls > 0 )
         {
         atime  = (double)timing[i].atime;

         if( timing[0].atime != 0 )
            pct = (atime / (double)timing[0].atime) * 100;
         else
            pct = 0.0;
	
         fprintf( fp, " %-40s %6d %11.3f %9.5f %7.2f\n",
                          timing[i].title,
                          timing[i].ncalls,
                          atime / 60.0,
                          (atime / (double)timing[i].ncalls) / 60.0,
                          pct ); 
         }
      }
   }

