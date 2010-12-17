#include <string.h>
#include <time.h>
#include <PDUerror.h>
#include "PDUproto.h"

  char    ethnic[20];
static  char    message[50];

int  PDUascii_to_timestamp (in_str, out_str)
  char *in_str ;         /* I - formatted or user input */
  char *out_str ;        /* O - timestamp format */
{
  char    delimiter[2];
  long    status, len ;
  char    token1 [10], token2 [10], token3 [10], *ptr, date_portion [30] ;
  char    time_portion [30], date_str[30], time_str[30] ;
  int  Ethnic_to_timestamp () ;

  _pdm_debug("in the function PDUascii_to_timestamp", 0);

  _pdm_debug("date string = <%s>", in_str);

  /* set ethnic type */
  strcpy(ethnic, "AMERICAN");

  /*  Determine which delimiter to use  */

  if (! strcmp (ethnic, "AMERICAN"))
    strcpy (delimiter, "/");
  else if (! strcmp (ethnic, "BRITISH"))
    strcpy (delimiter, "/");
  else if (! strcmp (ethnic, "FRENCH"))
      strcpy (delimiter, ".");
  else if (! strcmp (ethnic, "GERMAN"))
      strcpy (delimiter, ".");
  else if (! strcmp (ethnic, "SPANISH"))
      strcpy (delimiter, ".");
  else if ((! strcmp (ethnic, "ITALIAN")))
      strcpy (delimiter, "-");
  else
    {
      _pdm_debug("INVALID DATE FORMAT", 0);
    }

  _pdm_debug("setting date portion", 0);
  strcpy (date_portion, in_str) ;
  time_portion [0] = '\0' ;

  ptr = (char *) strchr (in_str, ' ') ;
  if (ptr != NULL)
    {
      len = ptr - in_str;
      date_portion [len] = 0 ;
      strcpy (time_portion, &in_str[len+1]) ;
      _pdm_debug("date portion = <%s>", date_portion);
      _pdm_debug("time portion = <%s>", time_portion);
    }
  else
    {
      ptr = (char *) strchr (in_str, ':') ;
      if (ptr != NULL)
        {
          len = ptr - in_str;
          date_portion [len] = 0 ;
          strcpy (time_portion, &in_str[len+1]) ;
          _pdm_debug("date_portion = <%s>", date_portion);
          _pdm_debug("time_portion = <%s>", time_portion);
        }
    }

  if (strlen (time_portion))
    {
      strcpy (time_str, time_portion) ;
    }
/* date given - time not given */
  else if (strlen (date_portion))
    {
      strcpy (time_str, "00:00:00") ;
    }
/* date not given - time not given */
  else
    {
      status = PDUget_RISdate (date_str) ;
      if (status )
        {
          sprintf (out_str, "%s:00:00:00", date_str) ;
          _pdm_debug("out string = <%s>", out_str);
           return(1);
        }
      else
        {
          _pdm_debug("Unable to get date", 0);
          return(1);
        }
    }

  if (strlen (date_portion))
    {
        status = PDUvalidate_American(date_portion,token1,token2,token3);
    }
/*** date not given, time given ***/
  else if (strlen (time_portion))
    {
      status = PDUget_RISdate (date_str) ;
      if (status )
        {
          sprintf (out_str, "%s:%s", date_str, time_str) ;
          _pdm_debug("Default to system date : %s", out_str) ;
          return (0) ;
        }
      else
        {
           _pdm_debug("Unable to get date", 0);
          return (1) ;
        }
    }

  status = Ethnic_to_timestamp (token1, token2, token3, time_str, out_str);
  if (status )
    {
      _pdm_debug("Ethnic to timestamp failed", 0) ;
      return (status) ;
    }

  _pdm_debug("SUCCESSFUL : out string %s", out_str);
  return (0) ;
}


int Ethnic_to_timestamp (token1, token2, token3,time_str, out_str)
  char    *token1, *token2, *token3 ;
  char    *time_str ;
  char    *out_str;
  {

    _pdm_debug("in the function Ethnic_to_timestamp", 0);

    if (! strcmp (ethnic, "AMERICAN"))
      {
        if ((strlen (token3)) == 4)
          sprintf (out_str, "%.4d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token1), atoi (token2), time_str);
        else
          sprintf (out_str, "19%.2d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token1), atoi (token2), time_str);
        return (0);
      }
    else if (! strcmp (ethnic, "BRITISH"))
      {
        if ((strlen (token3)) == 4)
          sprintf (out_str, "%.4d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
        else
          sprintf (out_str, "19%.2d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
      }
    else if (! strcmp (ethnic, "FRENCH"))
      {
        if (strlen (token3) == 4)
          sprintf (out_str, "%.4d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
        else
          sprintf (out_str, "19%.2d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
      }
    else if (! strcmp (ethnic, "GERMAN"))
      {
        if (strlen (token3) == 4)
          sprintf (out_str, "%.4d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
        else
          sprintf (out_str, "19%.2d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
      }
    else if (! strcmp (ethnic, "SPANISH"))
      {
        if (strlen (token3) == 4)
          sprintf (out_str, "%.4d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
        else
          sprintf (out_str, "19%.2d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
      }
    else if (! strcmp (ethnic, "ITALIAN"))
      {
        if ((strlen (token3)) == 4)
          sprintf (out_str, "%.4d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
        else
          sprintf (out_str, "19%.2d-%.2d-%.2d:%s",
                   atoi (token3), atoi (token2), atoi (token1), time_str);
      }
    else
      {
        _pdm_debug("INVALID DATE FORMAT", 0) ;
        return (1) ;
      }

    return (0) ;
  }

int PDUget_RISdate (ret_date)
     char  *ret_date;  /* O - The returned date/time */
{
    long         clock;
    struct  tm   *cur_tm;

    _pdm_debug("in the function PDUget_RISdate", 0);

    clock = time ((long *) 0);
    if (! clock)
     {
       _pdm_debug("Couldn't get the clock time", 0);
        return(1);
     }

    cur_tm = localtime (&clock);
    if (cur_tm == NULL)
      {
        _pdm_debug("System call to localtime failed", 0) ;
        return(1);
      }

    sprintf (ret_date, "%.4d-%.2d-%.2d",
             cur_tm->tm_year+1900, cur_tm->tm_mon+1, cur_tm->tm_mday);

    return (0);

  }

  /**************************************************************************
  This function validates the input date string against the American date
  format - mm/dd/yy or mm/dd/yyyy.

 *****************************************************************************/

#define DAY         1
#define MONTH       0
#define YEAR        2
#define DELIMITER  "/"
#define DELIM  "/"

int PDUvalidate_American (date, token1, token2, token3)
  char    *date;
  char    *token1, *token2, *token3 ;
  {
    int     i;
    char    *save_date;
    char    *tokens[4];


    /*  Initialize the tokens array  */

    for (i = 0; i < 3; ++i)
        tokens[i] = NULL;

    /*  Save the input string  */

    if ((save_date = (char *) malloc (strlen (date) + 1)) == NULL)
      {
        _pdm_debug ("error allocating dynamic memory; size = <%d>\n", 
                    (char *)strlen (date) + 1);
        return (1) ;
      }

    strcpy (save_date, date);

    /*  Parse the string  */

    for (i = 0; i < 3; ++i)
      {
        if (i)
 tokens[i] = strtok (NULL, DELIMITER);
        else
            tokens[i] = strtok (save_date, DELIMITER);

        if (tokens[i] == NULL)
          {
            if (i != 0)
              {
                _pdm_debug ("Bad delimiter\n",0);
              }
            else
              {
                _pdm_debug ("Not enough fields specified\n",0);
              }
            free (save_date);
            return (1);
          }
         else
          {
            _pdm_debug ("token is %s\n", tokens [i]) ;
          }
      }

    if ((tokens[3] = strtok (NULL, DELIMITER)) != NULL)
      {
        _pdm_debug ("Must be 3 separate fields\n",0);
        free (save_date);
        return (1) ;
      }

    if ((strlen (tokens[YEAR])) == 2)
      {
        if ((atoi (tokens[YEAR])) < 0)
          {
            /*  It is an invalid 2 digit year value  */
            sprintf (message, "Invalid 2 digit year value <%s>\n",
                     tokens[YEAR]) ;
            _pdm_debug ("%s", message) ;
         free (save_date);
            return (1) ;
          }
      }
    else if ((strlen (tokens[YEAR])) == 4)
      {
        if ((atoi (tokens[YEAR])) < 1900)
          {
            /*  It is an invalid 4 digit year value  */
            sprintf (message, "Invalid 4 digit year value <%s>\n",
                     tokens[YEAR]) ;
            _pdm_debug ("%s", message) ;
            free (save_date);
            return (1);
          }
      }
    else
      {
       /*  There is an incorrect number of digits in the year value  */

        sprintf (message, "Incorrect number of digits in year value <%d>\n",
                 strlen (tokens[YEAR])) ;
        _pdm_debug ("%s", message);
        free (save_date);
        return (1);
      }

    if (((atoi (tokens[MONTH])) <= 0) || ((atoi (tokens[MONTH])) > 12))
      {
        /*  It is an invalid month value  */

        sprintf (message, "Invalid month value <%s>\n", tokens[MONTH]) ;
        _pdm_debug ("%s", message);
        free (save_date);
        return (1) ;
      }

    if (((atoi (tokens[DAY])) <= 0) || ((atoi (tokens[DAY])) > 31))
      {
        /*  It is an invalid day value  */
        sprintf (message, "Invalid day value <%s>\n", tokens[DAY]);
        _pdm_debug ("%s", message);
        free (save_date);
        return (1) ;
      }
    strcpy (token1, tokens [0]) ;
    strcpy (token2, tokens [1]);
    strcpy (token3, tokens [2]);
    free (save_date);
    _pdm_debug ("SUCCESSFUL\n",0) ;
    return (1) ;
  }

int TIMEdebug (s)
char s[300];
  {
        FILE     *fopen(), *outfile;
        char      PDM_TIME[100];

         PDM_TIME[0] = '\0';
        sprintf (PDM_TIME, "%s%s%s","/usr/tmp",DELIM,"time.dbg");

                        if ((outfile = fopen (PDM_TIME, "a")) != NULL)
                        {
                        fputs (s, outfile);
                        fclose (outfile);
                                }

                else
                  {
                        fputs (s, stdout);
                        return (PDM_E_OPEN_FILE);
                  }
        return (PDM_S_SUCCESS);
  }


int _TIMEdebug (enter, exit, fn)
  char  *fn;
double  enter, exit;
  {
       char  PDM_TIME[100];

        FILE    *outfile, *fopen();
        sprintf (PDM_TIME, "%s%s%s", "/usr/tmp", DELIM, "time.dbg");
                        if ((outfile = fopen (PDM_TIME, "a")) != NULL) {
                        /*fprintf (outfile, "%f - %f\n", exit, enter);*/
                        fprintf (outfile, "%s ->  %f\n", fn, (exit - enter));
                        fclose (outfile);
                                }

                else
                  {
                        fputs (fn, stdout);
                        return (PDM_E_OPEN_FILE);
                  }
        return (PDM_S_SUCCESS);
  }
double system_time ()
{
        long timer;
        double e;

                timer=clock();
                e = (double)timer/1000000;

        return (e);
}

long call_time ()
{
        long timer;

                 time(&timer);

        return (timer);
}

