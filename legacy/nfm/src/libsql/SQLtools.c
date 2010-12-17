#include "machine.h"
#include <stdio.h>
#include <string.h>
#include "SQLstruct.h"
#include "SQLerrordef.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "sql.h"
#include "RISlimits.h"
/* #include "RISerror.h" */
#include "RISprototype.h"
#include <time.h>


 extern struct tm *localtime ();

  struct SQLglobal_st SQLglobal ;

void _SQLglobal_init ()
{
  long i ;

  for (i=0; i<LAST_PREPARED_QUERY+1; i++)
    {
      SQLglobal.prep[i] = 0 ;
    }
}


long SQLload_ris_print_format (ris_print_format) 
     char *ris_print_format ;
{
  strcpy (SQLglobal.ris_print_format, ris_print_format) ;
  return (SQL_S_SUCCESS) ;
}


long SQLget_ris_print_format (ris_print_format) 
     char *ris_print_format ;
{

  strcpy (ris_print_format, SQLglobal.ris_print_format);
  return (SQL_S_SUCCESS);
}

/* 
     Purpose : verifies that RIS function SQLdatetime_to_ascii
     can process the format specified in ris_print_format   
 */
     
long SQLis_ris_print_format_good (ris_print_format) 
     char *ris_print_format ;
{
  char  *fname = "SQLis_ris_print_format_good" ;
  int status ;
  char out_string [512], message [512];
  datetime date ;

  date.year = 1991 ;
  date.month = 12 ;
  date.day = 25 ;
  date.hour = 10 ;
  date.minute = 55 ;
  date.second = 7 ;
  

  status = RISdatetime_to_ascii (&date, out_string, ris_print_format) ;
  if (status != RIS_SUCCESS)
    {
      sprintf (message, "%.4d-%.2d-%.2d:%d:%d:%d",
	       date.year, date.month, date.day, 
	       date.hour, date.minute, date.second) ;
      _SQLdebug ((fname, "Failure : RISdatetime_to_ascii : date <%s> : RISstatus <%ld>",
	       message, status));
      ERRload_struct (SQL, SQL_E_INVALID_DATE, "%s", message);
      return (SQL_E_MESSAGE);
    }

  _SQLdebug ((fname, "SUCCESSFUL\n")) ;
  return (SQL_S_SUCCESS);
}


/* 
 Doc: SQLget_datetime
 
 Abstract:
     This function will return the current date and time in the format
     specified at login time
     
 Returns:
       SQL_S_SUCCESS - Success
       Other         - Failure
         
*/
 

long SQLget_datetime (ret_date)
     char  *ret_date;  /* O - The returned date/time */
{
  char *fname = "SQLget_datetime" ;
  long         clock, status ;
  struct  tm   *cur_tm;
  struct datetime  ptr ;
  char   message [512];

  _SQLdebug ((fname, "ENTER\n")) ;

  clock = time ((long *) 0);
  if (! clock)
    {
      _SQLdebug ((fname, "System call to clock failed\n")) ;
      ERRload_struct (SQL, SQL_E_MESSAGE, "%s", "Clock failed") ;
      return (SQL_E_MESSAGE) ;
    }

  cur_tm = localtime (&clock);
  if (cur_tm == NULL)
    {
      _SQLdebug ((fname, "System call to localtime failed\n")) ;
      ERRload_struct (SQL, SQL_E_MESSAGE, "%s", "Localtime failed") ;
      return (SQL_E_MESSAGE) ;
    }

  ptr.year = (unsigned int) (cur_tm->tm_year+1900) ;
  ptr.month = (unsigned int)cur_tm->tm_mon+1;
  ptr.day = (unsigned int) cur_tm->tm_mday ;
  ptr.hour = (unsigned int) cur_tm->tm_hour ;
  ptr.minute = (unsigned int) cur_tm->tm_min;
  ptr.second = (unsigned int) cur_tm->tm_sec ;

  status = RISdatetime_to_ascii (&ptr, ret_date,
				 SQLglobal.ris_print_format) ;
  
  if (status != RIS_SUCCESS)
    {
      sprintf (message, "%.4d-%.2d-%.2d:%d:%d:%d",
	       ptr.year, ptr.month, ptr.day, 
	       ptr.hour, ptr.minute, ptr.second) ;
      _SQLdebug ((fname, "Failure : RISdatetime_to_ascii : date <%s> : RISstatus = <%ld>",
		  message, status));
      ERRload_struct (SQL, SQL_E_INVALID_DATE, "%s", message);
      return (SQL_E_INVALID_DATE);
    }

  /* when date stuff gets stable take this debug out */
  _SQLdebug ((fname, "DATETIME <%s>\n", ret_date)) ;
  return (SQL_S_SUCCESS);
}


/* 
 Doc: SQLget_date
 
 Abstract:
     This function will return the current date and time in the format
     specified at login time
     
 Returns:
       SQL_S_SUCCESS - Success
       Other         - Failure
         
*/
 

long SQLget_date (ret_date)
     char  *ret_date;  /* O - The returned date */
{
  char *fname = "SQLget_date" ;
  long         clock, status, len ;
  struct  tm   *cur_tm;
  struct datetime  ptr ;
  char   message [512];

  _SQLdebug ((fname, "ENTER\n")) ;

  clock = time ((long *) 0);
  if (! clock)
    {
      _SQLdebug ((fname, "System call to clock failed\n")) ;
      ERRload_struct (SQL, SQL_E_MESSAGE, "%s", "Clock failed") ;
      return (SQL_E_MESSAGE) ;
    }

  cur_tm = localtime (&clock);
  if (cur_tm == NULL)
    {
      _SQLdebug ((fname, "System call to localtime failed\n")) ;
      ERRload_struct (SQL, SQL_E_MESSAGE, "%s", "Localtime failed") ;
      return (SQL_E_MESSAGE) ;
    }

  ptr.year = (unsigned int) (cur_tm->tm_year+1900) ;
  ptr.month = (unsigned int)cur_tm->tm_mon+1;
  ptr.day = (unsigned int) cur_tm->tm_mday ;
  ptr.hour = (unsigned int) cur_tm->tm_hour ;
  ptr.minute = (unsigned int) cur_tm->tm_min;
  ptr.second = (unsigned int) cur_tm->tm_sec ;

  status = RISdatetime_to_ascii (&ptr, ret_date,
				 SQLglobal.ris_print_format) ;
  
  if (status != RIS_SUCCESS)
    {
      sprintf (message, "%.4d-%.2d-%.2d:%d:%d:%d",
	       ptr.year, ptr.month, ptr.day, 
	       ptr.hour, ptr.minute, ptr.second) ;
      _SQLdebug ((fname, "Failure : RISdatetime_to_ascii : date <%s> : RISstatus = <%ld>",
	       message,status));
      ERRload_struct (SQL, SQL_E_INVALID_DATE, "%s", message);
      return (SQL_E_INVALID_DATE);
    }
  len = strlen (ret_date) -9 ;  /* :00:00:00 is 9 len */
  ret_date [len] = 0 ;
 
  /* when date stuff gets stable take this debug out */
  _SQLdebug ((fname, "DATETIME <%s>\n", ret_date)) ;
    return (SQL_S_SUCCESS);
  }


long SQLload_database_type (db_type) 
     char *db_type ;
{
  char *fname = "SQLload_database_type" ;

  SQLglobal.db_type = db_type[0] ;
  _SQLdebug ((fname, "SQLglobal.db_type is %c\n", SQLglobal.db_type)) ;
  return (SQL_S_SUCCESS) ;
}

long SQLget_database_type (db_type) 
     char *db_type ;
{
  char *fname = "SQLget_database_type" ;

  db_type[0] = SQLglobal.db_type  ;
  db_type[1] = 0 ;
  _SQLdebug ((fname, "dbtype is %s\n", db_type)) ;
  return (SQL_S_SUCCESS) ;
}


long SQLget_dbtype (schema_name, dbtype)
     char *schema_name ;
     char *dbtype ;
{
  char *fname = "SQLget_dbtype" ;
  ris_db_info *dbp ;

  _SQLdebug ((fname, "schema name <%s>\n", schema_name)) ;

/* returns void */
  RISget_schema_info (schema_name, NULL, &dbp, NULL) ;
  dbtype [0] = dbp -> dtype ;
  dbtype [1] = 0 ;
  SQLload_database_type (dbtype) ;
  free (dbp) ;

  _SQLdebug ((fname, "SUCCESSFUL : dbtype is <%s>\n", dbtype)) ;
  return (SQL_S_SUCCESS) ;
}


long SQLascii_to_timestamp (date_time_str, timestamp_str)
     char *date_time_str ;
     char *timestamp_str ;
{
  char *fname = "SQLascii_to_timestamp" ;
  long status ;
  datetime date ;

  _SQLdebug ((fname, "date time str <%s>\n", date_time_str)) ;
  status = (long) RISascii_to_datetime (&date, date_time_str, 
					SQLglobal.ris_print_format) ;
/****************************************************************************
/* Year 2000 Fixes - Ravi 30=May-1998
/* Either if RISascii_to_datetime fails or if the returned date has year < 100
/* date is made invalid. User is forced to enter 4 digit year this way.
*****************************************************************************/
  if (status != RIS_SUCCESS || date.year < 100)
    {
      _SQLdebug ((fname, "Failure : RISascii_to_datetime : date <%s> :  RISstatus <%d>\n", 
		  date_time_str, status));
      ERRload_struct (SQL, SQL_E_INVALID_DATE, "%s", date_time_str);
      return (SQL_E_INVALID_DATE);
    }

/*
  if (date.year <100)
    {
      date.year = 1900 + date.year ;
    }
*/

/* End of Year 2000 fixes */
  sprintf (timestamp_str, "%.4d-%.2d-%.2d:%d:%d:%d",
	   date.year, date.month, date.day, 
	   date.hour, date.minute, date.second) ;

  _SQLdebug ((fname, "SUCCESSFUL : timestamp str <%s>\n",
              timestamp_str)) ;
  return (SQL_S_SUCCESS) ;
}


long SQLascii_to_timestamp_and_f_input (date_time_str, timestamp_str,
					formatted_str)
     char *date_time_str ;
     char *timestamp_str ;
     char *formatted_str ;
{
  char *fname = "SQLascii_to_timestamp_and_f_input" ;
  long status ;
  datetime date ;

  _SQLdebug ((fname, "date time str <%s>\n", date_time_str)) ;
  status = (long) RISascii_to_datetime (&date, date_time_str, 
					SQLglobal.ris_print_format) ;
/****************************************************************************
/* Year 2000 Fixes - Ravi 30=May-1998
/* Either if RISascii_to_datetime fails or if the returned date has year < 100
/* date is made invalid. User is forced to enter 4 digit year this way.
*****************************************************************************/
  if (status != RIS_SUCCESS || date.year < 100)
    {
      _SQLdebug ((fname, "Failure : RISascii_to_datetime : date <%s> : RISstatus <%d>\n",
		  date_time_str, status)) ;
      ERRload_struct (SQL, SQL_E_INVALID_DATE, "%s", date_time_str);
      return (SQL_E_INVALID_DATE);
    }

/*
  if (date.year < 100)
    {
      date.year = 1900 + date.year ;
    }
*/

/* End of Year 2000 fixes */
  sprintf (timestamp_str, "%.4d-%.2d-%.2d:%d:%d:%d",
	   date.year, date.month, date.day, 
	   date.hour, date.minute, date.second) ;

  status = (long) RISdatetime_to_ascii (&date, formatted_str,
					SQLglobal.ris_print_format) ;
  if (status != RIS_SUCCESS)
    {
      _SQLdebug ((fname, "Failure : RISdatetime_to_ascii : date <%s> : RISstatus <%d>\n", 
		  timestamp_str, status)) ;
      ERRload_struct (SQL, SQL_E_INVALID_DATE, "%s", timestamp_str) ;
      return (SQL_E_INVALID_DATE) ;
    }

  _SQLdebug ((fname, "SUCCESSFUL : timestamp str <%s> : formatted str <%s>\n",
              timestamp_str, formatted_str)) ;
  return (SQL_S_SUCCESS) ;
}

/*****************************************************
/* Adding this function TEMPORARILY - Ravi 15 June 98 

SQLdatetime_to_ascii(dattime_str, ascii_str);
char *datetime_str, *ascii_str;
{

  status = RISdatetime_to_ascii (datetime_str, ascii_str, SQLglobal.ris_print_format) ;

}

 End of TEMPORARY edition 
*************************************/



