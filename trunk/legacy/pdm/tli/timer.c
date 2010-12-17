/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

Name:		timer.c

Purpose:	This function is used to time sections of code.
	When called to start, the timer is initialized. When called
	to stop, the timer is stopped and the elapsed and CPU
	seconds are printed on the specified file descriptor.

Author: Jeff Silvaggi

Date: 06-08-90

Change History:
**********************************************************************/
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/param.h>

timer( on, text, fp )
int on;			/* 1 = init  0 = stop and print */
char *text;		/* Text to print */
FILE *fp;		/* Output FILE pointer */
{
float esec, csec, hz;
long new_time;
struct tms nt_str;		/* New time structure */

static long etime;
static struct tms time_str;

hz = (float)HZ;

if( on )
  etime = times( &time_str);
else
{
  /* Print stats */
  new_time = times( &nt_str );
  esec = (float)(new_time - etime);
  esec /= hz;

  csec = (nt_str.tms_utime - time_str.tms_utime) + (nt_str.tms_stime - time_str.tms_stime);
  csec /= hz;

  fprintf( fp, "%s: Elapsed = %lf   cpu = %lf\n", text, esec, csec );
}

return(0);
} /* End of timer() */
