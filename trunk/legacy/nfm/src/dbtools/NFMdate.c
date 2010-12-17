#include "machine.h"
#include "DBTOOLS.h"
#include <string.h>

#define NFM_E_BAD_DATE  0x0807a1ba /* PS */


extern struct NFMglobal_st NFMglobal ;

/* This definition clashes with the similar definition in libFTR.so
   So changed it to localize it  --  Jujare */

/* char message [512] ; */
   char message1 [512] ; 

long  NFMascii_to_timestamp_format (in_str, out_str)
  char *in_str ;         /* I - formatted or user input */
  char *out_str ;        /* O - timestamp format */
{
  char *fname = "NFMascii_to_timestamp_format" ;
  long    status ;
  char    date_time_str [200] ;
  char    display_date[100] ;
  long    _NFMget_date_time_str () ;

  _NFMdebug ((fname, "ENTER input string %s\n", in_str)) ;

  out_str [0] = 0 ;
  status = _NFMget_date_time_str (in_str, date_time_str,
				  out_str,
				  display_date) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  if (strlen (out_str))
    {
      _NFMdebug ((fname, "SUCCESSFUL : <%s>\n", out_str)) ;
      return (NFM_S_SUCCESS) ;
    }


  status = SQLascii_to_timestamp (date_time_str, out_str) ;
  if (status != SQL_S_SUCCESS)
    {
     _NFMdebug ((fname, "Failure :SQLAscii_to_timestamp: status = <0x%.8x>\n", status)) ;
      if(status == SQL_E_INVALID_DATE)
      {
	strcpy(date_time_str,"Cannot Retrieve Date/Time Format");
        status = NFMget_date_info(display_date,display_date,date_time_str);
        ERRload_struct(NFM,NFM_E_BAD_DATE,"%s%s",in_str,date_time_str);
        return(NFM_E_BAD_DATE);
        return(SQL_E_INVALID_DATE);
      }
      else
      {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
      }

    }
  
  _NFMdebug ((fname, "SUCCESSFUL : out string %s\n", out_str));
  return (NFM_S_SUCCESS) ;
}

long  NFMvalidate_and_format_date (input_string, display_date, timestamp_date)
     char *input_string ; /* i - A date string, usually entered by a user.
			     ex. 1/12/91p */
     char *display_date ; /* o - If input_string is a valid date, by NFM
			     rules, contains a properly formatted string
			     that is suitable for display to the user,
			     in the currently selected date format.
			     ex. 01/12/1991 */
     char *timestamp_date ; /* o - contains the same date in a timestamp
			     format suitable for use in a SQL stmt
			     ex. 1991-12-01:00:00:00 */
{
  char *fname = "NFMvalidate_and_format_date";
  long    status ;
  char   date_time_str [200] ;
  long    _NFMget_date_time_str () ;

  _NFMdebug ((fname, "ENTER input string %s\n", input_string)) ;

  timestamp_date [0] = 0 ;
  display_date [0] = 0 ;
  status = _NFMget_date_time_str (input_string, date_time_str,
				  timestamp_date,
				  display_date) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }



  if (strlen(timestamp_date) && (strlen (display_date)))
    {
      _NFMdebug ((fname, "SUCCESSFUL : out string %s : correct_in_str %s\n", 
		  timestamp_date, display_date));
      return (NFM_S_SUCCESS) ;
    }

  _NFMdebug ((fname, "date_time_str <%s>\n", date_time_str)) ;

  status = SQLascii_to_timestamp_and_f_input (date_time_str, 
					      timestamp_date,
					      display_date) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL : out string %s : correct_in_str %s\n", 
	      timestamp_date, display_date));
  return (NFM_S_SUCCESS) ;
}



long NFMget_date_info (date_type, time_type, format_string)
     char *date_type ;         /* o-  AMERICAN, ITALIAN, etc...*/
     char *time_type ;         /* o-  24HR or 12HR *************/
     char *format_string ;     /* o-   mm/dd/yyyy hh24:nn:ss... RIS input */
{
  char *fname = "NFMget_date_info" ;

  SQLget_ris_print_format (format_string) ;
  strcpy (date_type, NFMglobal.date_format) ;
  strcpy (time_type, NFMglobal.time_format) ;
  _NFMdebug ((fname, "date type %s : format of date type %s\n",
	      date_type, format_string)) ;

  return (NFM_S_SUCCESS) ;
}


long NFMvalidate_time (in_time) 
char *in_time ;
{
    int     i;
    long    status ;
    char    *save_time;
    char    *fname = "NFMvalidate_time" ;
    char    *tokens[4];

    _NFMdebug ((fname, "ENTER\n")) ;
    /*  Initialize the tokens array  */

    for (i = 0; i < 3; ++i)
        tokens[i] = NULL;

    /*  Save the input string  */

    if ((save_time = (char *) malloc (strlen (in_time) + 1)) == NULL)
      {
        _NFMdebug ((fname, "error allocating dynamic memory; size = <%d>\n",
            strlen (in_time) + 1));
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        return (NFM_E_MALLOC) ;
      }

    strcpy (save_time, in_time);

    /*  Parse the string  */

    for (i = 0; i < 3; ++i)
      {
        if (i)
            tokens[i] = strtok (NULL, ":");
        else
            tokens[i] = strtok (save_time, ":");

        if (tokens[i] == NULL)
          {
	    if (i != 0)
	      {
		_NFMdebug ((fname, "Bad delimiter\n"));
		ERRload_struct (NFM, NFM_E_DATE_BAD_DELIMITER, "%s", 
				":") ;
		status = NFM_E_DATE_BAD_DELIMITER ;
	      }
	    else
	      {
		_NFMdebug ((fname, "Not enough fields specified\n"));
		ERRload_struct (NFM, NFM_E_DATE_NOT_ENOUGH_FIELDS, "", "");
		status = NFM_E_DATE_NOT_ENOUGH_FIELDS ;
	      }
            free (save_time);
            return (status);
          }
	else 
	  {
/*	    _NFMdebug ((fname, "token is %s\n", tokens [i])) ; */
	  }
      }

    if ((tokens[3] = strtok (NULL, ":")) != NULL)
      {
        _NFMdebug ((fname, "Must be 3 separate fields\n"));
	ERRload_struct (NFM, NFM_E_DATE_BE_THREE_FIELDS, "", "");
        free (save_time);
        return (NFM_E_DATE_BE_THREE_FIELDS);
      }
/** hour **/
    if ((atoi (tokens[0]) < 0))
      {
	/*  It is an invalid 2 digit hour value  */
	_NFMdebug ((fname, "Failure : Invalid 2 digit hour value <%s>\n", 
		 tokens[0]));
	ERRload_struct (NFM, NFM_E_DATE_BAD_HOUR_VALUE, "%s", tokens[0]);
	free (save_time);
	return (NFM_E_DATE_BAD_HOUR_VALUE);
      }
    else
      {
	if (strcmp (NFMglobal.time_format, "12HR") == 0)
	  {
	    if (atoi (tokens[0]) > 12)
	      {
		_NFMdebug ((fname, "Failure : hour information must be in 12HR : value keyed in was <%s>",
			 tokens[0]));
		_NFMdebug ((fname, "%s\n", message1)) ;
		ERRload_struct (NFM, NFM_E_DATE_TIME_FORMAT, "%s", "12HR") ;
		free (save_time);
		return (NFM_E_DATE_TIME_FORMAT);
	      }
	  }
	else
	  {
	    if (atoi (tokens[0]) > 24)
	      {
		_NFMdebug ((fname, "Failure : hour information must be in 24HR : value keyed in was <%s>",
			 tokens[0]));
		ERRload_struct (NFM, NFM_E_DATE_TIME_FORMAT, "%s", "24HR");
		free (save_time);
		return (NFM_E_DATE_TIME_FORMAT);
	      }
	  }
      }

/*** minutes **/
    if (((atoi (tokens[1])) < 0) || ((atoi (tokens[1])) > 60))
      {
        /*  It is an invalid minutes value  */

	_NFMdebug ((fname, "Failure : Invalid minutes value <%s>\n", tokens[1]));
	ERRload_struct (NFM, NFM_E_DATE_BAD_MINUTE_VALUE, "%s", tokens[1]);
        free (save_time);
        return (NFM_E_DATE_BAD_MINUTE_VALUE);
      }
/*** seconds ***/
    if (((atoi (tokens[2])) < 0) || ((atoi (tokens[2])) > 60))
      {
        /*  It is an invalid seconds value  */
	_NFMdebug ((fname, "Invalid seconds value <%s>\n", tokens[2]));
	ERRload_struct (NFM, NFM_E_DATE_BAD_SECOND_VALUE, "%s", tokens[2]);
        free (save_time);
        return (NFM_E_DATE_BAD_SECOND_VALUE) ;
      }

    free (save_time);
    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS) ;
  }


long _NFMget_date_time_str (input_string, date_time_str,
			    timestamp_date, display_date)
     char *input_string ;
     char  *date_time_str ;
     char *timestamp_date ;
     char *display_date ;
{
  char *fname = "_NFMget_date_time_str" ;
  char    date_portion [30], time_portion [30] ;
  char    *ptr ;
  long    status, len ;
  long NFMvalidate_ascii_date_string ();
  long NFMvalidate_time ();

  _NFMdebug ((fname, "input string <%s>\n", input_string)) ;
  strcpy (date_portion, input_string) ;
  time_portion [0] = 0 ;

  ptr = (char *) strchr (input_string, ' ') ;
  if (ptr != NULL)
    {
      len = ptr - input_string;
      date_portion [len] = 0 ;
      strcpy (time_portion, &input_string[len+1]) ;
      _NFMdebug ((fname, "%s BLANK %s\n", date_portion, time_portion)) ;
    }
  else
    {
      ptr = (char *) strchr (input_string, ':') ;
      if (ptr != NULL)
	{
	  len = ptr - input_string;
	  date_portion [len] = 0 ;
	  strcpy (time_portion, &input_string[len+1]) ;
	  _NFMdebug ((fname, "%s : %s\n", date_portion, time_portion)) ;
	}
    }

 if (strlen (time_portion))
    {
      status = NFMvalidate_time (time_portion) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "validate time_portion : status = <0x%.8x>\n",
		      status));
	  return (status) ;
        }

      if (! strlen (date_portion))
	/*** date not given, time given ***/
	{
	  status = NFMget_RISdate (date_portion) ;
	  if (status == NFM_S_SUCCESS)
	    {
	      sprintf (timestamp_date, "%s:%s", date_portion, time_portion) ;
	      _NFMdebug ((fname, "Default to system date : %s\n", 
			  display_date)) ;
	  SQLget_date (date_portion) ;
	  sprintf (display_date, "%s %s", date_portion,time_portion) ;
	  _NFMdebug ((fname, "Default to system date : %s\n", display_date)) ;
	      return (NFM_S_SUCCESS) ;
	    }
	  else
	    {
	      strcpy (message1, "Unabled to get date") ;
	      _NFMdebug ((fname, "%s\n", message1)) ;
	      ERRload_struct (NFM, NFM_E_INVALID_DATE, "", "") ;
	      return (NFM_E_INVALID_DATE) ;
	    }
	}
    }
  
/* date given - time not given */
  else if (strlen (date_portion))
    {
/*** dmands suggestion for easier search *******/
      strcpy (time_portion, "00:00:00") ;
    }
/* date not given - time not given */
  else
    {
      status = NFMget_RISdate (date_portion) ;
      if (status == NFM_S_SUCCESS)
	{
	  sprintf (timestamp_date, "%s:00:00:00", date_portion) ;
	  _NFMdebug ((fname, "Default to system date : %s\n",
		      timestamp_date)) ;
	  SQLget_date (date_portion) ;
	  sprintf (display_date, "%s 00:00:00", date_portion) ;
	  _NFMdebug ((fname, "Default to system date : %s\n", display_date)) ;
	  return (NFM_S_SUCCESS) ;
	}
      else
	{
	  strcpy (message1, "Unabled to get date") ;
	  _NFMdebug ((fname, "%s\n", message1)) ;
	  ERRload_struct (NFM, NFM_E_INVALID_DATE, "", "") ;
	  return (NFM_E_INVALID_DATE) ;
	}
    }

  sprintf (date_time_str, "%s %s", date_portion, time_portion) ;
_NFMdebug ((fname, "SUCCESSFUL : <%s> \n", date_time_str)) ;
return (NFM_S_SUCCESS) ;
}

/* 
 Doc: NFMget_datetime
 
 Abstract:
     This function will return the current date and time in the format
     specified at login time
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
*/
 

long NFMget_datetime (ret_date)
     char  *ret_date;  /* O - The returned date/time */
{
  char *fname = "NFMget_datetime" ;
  long status ;

  status = SQLget_datetime (ret_date);
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/* 
 Doc: NFMget_date
 
 Abstract:
     This function will return the current date and time in the format
     specified at login time
     
 Returns:
       NFM_S_SUCCESS - Success
       Other         - Failure
         
*/
 

long NFMget_date (ret_date)
     char  *ret_date;  /* O - The returned date */
{
  char *fname = "NFMget_date" ;
  long status ;

  status = SQLget_date (ret_date) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;

}

/********************************************
 Function added TEMPORARILY by Ravi - 15 June 1998 
NFMdatetime_to_ascii(datetime_str, ascii_str)
char *datetime_str, *ascii_str);
{
long status;

status = SQLdatetime_to_ascii(datetime_str, ascii_str);
if(status == SQL_S_SUCCESS)
   _NFMdebug((fname, "Ascii Date : %s, Successful\n", ascii_str));
else
   _NFMdebug((fname, "Datetime to Ascii conversion failed\n"));

return(status);

}

 End of TEMPORARY addition 
*********************************/
