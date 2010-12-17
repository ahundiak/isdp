#include "machine.h"
#include "NFMerrordef.h"
#include <time.h>
#include "ERR.h"
#include "DEBUG.h"

 extern struct tm *localtime ();

long NFMget_ris_timestamp (ret_date)
     char  *ret_date;
{
  static char *fname = "NFMget_date_time" ;
  long         clock ;
  struct  tm   *cur_tm;
  
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
  
  sprintf (ret_date, "%.4d-%.2d-%.2d:%.2d:%.2d:%.2d",
	   cur_tm->tm_year+1900, cur_tm->tm_mon+1, cur_tm->tm_mday,
	   cur_tm->tm_hour, cur_tm->tm_min, cur_tm->tm_sec) ;
  
  /* when date stuff gets stable take this debug out */
  _NFMdebug ((fname, "DATE %s\n",
	      ret_date)) ; 
  
  return (NFM_S_SUCCESS);
}




