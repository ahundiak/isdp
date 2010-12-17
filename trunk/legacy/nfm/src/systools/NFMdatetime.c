#include "machine.h"
#include "NFMsysinc.h"

 extern struct tm *localtime ();
 extern struct NFMglobal_st NFMglobal ;
/* 
 Doc: NFMget_RISdatetime
 
 Abstract:
     This function will return the current date and time in the RIS
     'timestamp' format. Until the final formatting of the output
     string, it is the same as NFMget_date_time ().
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
*/
 

long NFMget_RISdatetime (ret_datetime)
     char  *ret_datetime;  /* O - The returned date/time */
{
  static char *fname = "NFMget_RISdatetime" ;
    long         clock;
    struct  tm   *cur_tm;
    char         *getenv ();

    clock = time ((long *) 0);
    if (! clock)
     {
       _NFMdebug ((fname, "System call to clock failed\n")) ;
       ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Clock failed") ;
       return (NFM_E_MESSAGE) ;
     }

    cur_tm = localtime (&clock);
    if (cur_tm == NULL)
      {
	_NFMdebug ((fname, "System call to localtime failed\n")) ;
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Localtime failed") ;
	return (NFM_E_MESSAGE) ;
      }

/* KT - For now this function will ignore the NFMglobal.date_format 
        global that is checked by NFMget_date_time ().
*/

    sprintf (ret_datetime, "%.4d-%.2d-%.2d:%.2d:%.2d:%.2d",
             cur_tm->tm_year+1900, cur_tm->tm_mon+1, cur_tm->tm_mday,
	     cur_tm->tm_hour, cur_tm->tm_min, cur_tm->tm_sec) ;

/* when date stuff gets stable take this debug out */
    _NFMdebug ((fname, "DATETIME <%s>\n", ret_datetime)) ; 

    return (NFM_S_SUCCESS);
  }


/* 
 Doc: NFMget_RISdate
 
 Abstract:
     This function will return the current date in the RIS
     'timestamp' format. Until the final formatting of the output
     string, it is the same as NFMget_date_time ().
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
*/
 
long NFMget_RISdate (ret_date)
     char  *ret_date;  /* O - The returned date/time */
{
  static char *fname = "NFMget_RISdate" ;
    long         clock;
    struct  tm   *cur_tm;
    char         *getenv ();

    clock = time ((long *) 0);
    if (! clock)
     {
       _NFMdebug ((fname, "System call to clock failed\n")) ;
       ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Clock failed") ;
       return (NFM_E_MESSAGE) ;
     }

    cur_tm = localtime (&clock);
    if (cur_tm == NULL)
      {
	_NFMdebug ((fname, "System call to localtime failed\n")) ;
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Localtime failed") ;
	return (NFM_E_MESSAGE) ;
      }

/* KT - For now this function will ignore the NFMglobal.date_format 
        global that is checked by NFMget_date_time ().
*/

    sprintf (ret_date, "%.4d-%.2d-%.2d",
             cur_tm->tm_year+1900, cur_tm->tm_mon+1, cur_tm->tm_mday);

/* when date stuff gets stable take this debug out */
    _NFMdebug ((fname, "DATE <%s>\n", ret_date));
    return (NFM_S_SUCCESS);
  }


/* 
 Doc: NFMget_RIStime
 
 Abstract:
     This function will return the current time in the RIS
     'timestamp' format. Until the final formatting of the output
     string, it is the same as NFMget_date_time ().
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
 History:
     kht    9-30-1991    Creation
     
*/
 
long NFMget_RIStime (ret_time)
     char  *ret_time;  /* O - The returned date/time */
{
  static char *fname = "NFMget_RIStime" ;
    long         clock;
    struct  tm   *cur_tm;
    char         *getenv ();

    clock = time ((long *) 0);
    if (! clock)
     {
       _NFMdebug ((fname, "System call to clock failed\n")) ;
       ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Clock failed") ;
       return (NFM_E_MESSAGE) ;
     }

    cur_tm = localtime (&clock);
    if (cur_tm == NULL)
      {
	_NFMdebug ((fname, "System call to localtime failed\n")) ;
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Localtime failed") ;
	return (NFM_E_MESSAGE) ;
      }

/* KT - For now this function will ignore the NFMglobal.date_format 
        global that is checked by NFMget_date_time ().
*/

    sprintf (ret_time, "%.2d:%.2d:%.2d",
	     cur_tm->tm_hour, cur_tm->tm_min, cur_tm->tm_sec) ;

  /* when date stuff gets stable take this debug out */
  _NFMdebug ((fname, "TIME <%s>\n", ret_time)) ; 
  return (NFM_S_SUCCESS);
  }


