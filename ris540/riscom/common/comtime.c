/* Do not alter this PINNACLE information: $Revision: 1.3.3.1 $ */
/*
**	NAME:							comtime.c
**	AUTHORS:						Dan Karier
**	CREATION DATE:					1/91
**	ABSTRACT:
**	Get the current date/time from the system in a string format
**	that can be compared accurately with strcmp().  Return a pointer
**	to the string.
**
**	For unix this is century-year-day(1-366)-hour(0-23)-minute-second.
**	
**	Works for vms too.
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#if defined (unix)
#include "wrap.prt"
#endif

#if defined (unix) || defined(WIN32) || defined(DOS)
# include <sys/types.h>
# include <time.h>
#endif

#if defined (WIN32)
# include <sys/timeb.h>
#endif

#ifdef vax
# include <types.h>
# include <time.h>
#endif /* vax */

#include "risdebug.h"
#include "comdebug.prt"
 
/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comtime_c
#include "comtime.prt"
#include "sys.prt"


extern char *RIScom_timestamp()
{
	static  char buf[RIS_DATETIME_PRECISION]; /* return pointer to this */
	time_t seconds;
	struct tm  * t;

	seconds = time(0);
	t = localtime(&seconds);
	
		/* century-year day(1-366) hour-minute-second */

	sprintf(buf,"19%02d %03d %02d:%02d:%02d", 
		t->tm_year,t->tm_yday+1,t->tm_hour,t->tm_min,t->tm_sec);

	return buf;
}
/* Melania M Stewart : Time Only */
extern char *RIScom_timestamp_TO()
{
	static  char buf[RIS_DATETIME_PRECISION]; /* return pointer to this */
	time_t seconds;
	struct tm  * t;

	seconds = time(0);
	t = localtime(&seconds);
	
	sprintf(buf,"%02d:%02d:%02d", 
		t->tm_hour,t->tm_min,t->tm_sec);

	return buf;
}

#if defined (WIN32)
/* Melania M Stewart : Time Only */
extern char *RIScom_timestamp_TO_WIN32()
{
	static  char buf[RIS_DATETIME_PRECISION]; /* return pointer to this */
	struct tm  * t;
	struct _timeb timebuffer ;

	_ftime (&timebuffer) ;

	t = localtime(&(timebuffer.time));
	
	sprintf(buf,"%02d:%02d:%02d.%hu", 
		t->tm_hour,t->tm_min,t->tm_sec, timebuffer.millitm);
	return buf;
}
#endif

/*** Melania M Stewart - This function can be used for putting timestamp at different places
                         of the code ***/
extern void TimeStamp (
    char *Title)
{
    FILE *fd ;
#if defined WIN32    
    char *LOG_FILE = "c:\\tmp\\timestamp.log";
#else    
    char *LOG_FILE = "/tmp/timestamp.log";
#endif
    if ((fd = fopen (LOG_FILE, "a+")) == NULL)
    {
        return ;
    }
#if defined WIN32    
    fprintf (fd, "%-25s : %s\n", Title, RIScom_timestamp_TO_WIN32()) ;
#else
    fprintf (fd, "%-25s : %s\n", Title, RIScom_timestamp_TO()) ;
#endif    
    fclose (fd) ;
}

