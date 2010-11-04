/* $RCSfile: fsntrpr.c $$Revision: 1.2 $$Date: 1991/02/28 16:38:09 $ Copyright (c) 1990 Intergraph Corp. */


/**************************** I N T E R P R O . C ****************************

    The routines in this module contain Interpro operating-system calls. They
    must be modified in order to run on any other processor.

 ****************************************************************************/

#include "../hfiles/FSTypes.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>



void  _FSIproTodaysDate (yy, mm, dd, hh, min, ss)
  Int16	*yy, *mm, *dd, *hh, *min, *ss;

/* _FSIproTodaysDate -- Function to get today's date.
 * Output arguments:	yy -- year, mm -- month, dd -- day,
 *			hh -- hour, min -- minute, ss -- second
 */
{
    struct tm	*timePtr;
    Int32	theTime;

    time ((long *)&theTime);
    timePtr = localtime ((long *)&theTime);
    *yy = timePtr->tm_year + 1900;
    *mm = timePtr->tm_mon + 1;
    *dd = timePtr->tm_mday;
    *hh = timePtr->tm_hour;
    *min = timePtr->tm_min;
    *ss = timePtr->tm_sec;
    return;
}



Int32  _FSIproClockHigh32 ()

/* _FSIproClockHigh32 -- Function to read high 32 bits of system clock
 * Returns: -- system time to the nearest second (apollo: .25 sec)
 */
{
    Int32	theTime;

    time ((long *)&theTime);
    return (theTime);
}



void  _FSIproMemoryInit(void)
{
    return;
}
