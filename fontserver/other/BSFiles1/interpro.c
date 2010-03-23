




/*****************************************************************************
*                                                                            *
*              Copyright 1986 by Bitstream Inc., Cambridge, MA               *
*                            All Rights Reserved                             *
*                                                                            *
*****************************************************************************/



/**************************** I N T E R P R O . C ****************************

    The routines in this module contain Interpro operating-system calls. They
    must be modified in order to run on any other processor.

 ****************************************************************************/


#include "../hfiles/stdef.h"              /* Bitstream standard macros */
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>




FUNCTION  void  ipro_fname_bak (bmapname)
  char     *bmapname;                   /* pointer to filename string */

/*  Examines the current directory ('.') for the filename string in bmapname.
 *  If the file exists, it is renamed to '<filename>.bak'. If '<filename>.bak'
 *  already exists, it will first be deleted -- in other words 1 backup is
 *  kept around, a fairly common convention.
 */

    DECLARE
    char    pathname[256];          /* full pathname of file */
    char    pathname_bak[256];      /* full pathname of .bak file */
    bool    bmf_found;              /* T/F  if <bmapname> already exists */
    bool    bmfbak_found;           /* T/F  if <bmapname>.bak already exists */
    struct  stat buf;		    /* file status structure */


    BEGIN
    sprintf (pathname, "%.14s", bmapname);
    sprintf (pathname_bak, "%.13sb", bmapname);
    
    bmf_found = !stat (pathname, &buf);
    bmfbak_found = !stat (pathname_bak, &buf);

    if (bmf_found && bmfbak_found)	/* if both exists, delete .bak file */
    {
	if (unlink (pathname_bak))
	    printf("\n***  UNLINK failed on \"%s\" ***\n", pathname_bak);
    }
    
    if (bmf_found)	/* move file to .bak file */
    {
	if (link (pathname, pathname_bak))	/* link to .bak */
	{
	    printf("\n***  LINK failed on \"%s\" ***\n", pathname_bak);
	}
	else if (unlink (pathname))	/* delete old link */
	{
	    printf("\n***  UNLINK failed on \"%s\" ***\n", pathname);
	}
    }

    return;
    END




FUNCTION  void  ipro_todays_date (yy, mm, dd, hh, min, ss)
  fix15    *yy, *mm, *dd, *hh, *min, *ss;

/* IPRO_TODAYS_DATE -- Function to get today's date.
 * Output arguments:  yy -- year,  mm -- month,  dd -- day,
 *                    hh -- hour,  min -- minute,  ss -- second
 */
 
    DECLARE
    struct tm	*time_ptr;
    fix31	the_time;

    BEGIN
    time (&the_time);
    time_ptr = localtime (&the_time);
    *yy = time_ptr->tm_year + 1900;
    *mm = time_ptr->tm_mon + 1;
    *dd = time_ptr->tm_mday;
    *hh = time_ptr->tm_hour;
    *min = time_ptr->tm_min;
    *ss = time_ptr->tm_sec;
    return;
    END





FUNCTION  fix31  ipro_clock_high_32 ()

/* IPRO_CLOCK_HIGH_32 -- Function to read high 32 bits of system clock
 * Returns: -- system time to the nearest second (apollo: .25 sec) */

    DECLARE
    fix31	the_time;

    BEGIN
    time (&the_time);
    return (the_time);
    END





FUNCTION  void  ipro_memory_init()

/* Do nothing */

    DECLARE
    BEGIN
    END
