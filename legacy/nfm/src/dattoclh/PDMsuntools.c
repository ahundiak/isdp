#include <varargs.h>
#include <stdio.h>

#define TRUE 1
#define FALSE 0
#define PDM_S_SUCCESS 0

extern int debug_on;
extern char PDM_DEBUG_FILE[100];

/****************************************************************************

Name
   pdmShellSort

Abstract

Synopsis
  int pdmShellSort ( )

Description
   Input:

   Input/Output:

   Output:

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

History
   Kumar Narayanan Fri Mar 19 13:30:52 CST 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int pdmShellSort (int obj_count, char **nodes)
{
  int     jump, max, m, n, all_sorted_flag = TRUE;
  char	temp[20];
  char  *fname="pdmShellSort";

   _PDMdebug(fname,"Enter");
   jump = obj_count;
   while (jump > 1)
     {
	jump = jump / 2;
	max = obj_count - jump;
	do
	 {
	  all_sorted_flag = TRUE;
	  for (m = 0; m < max; ++m)
	   {
	    n = m + jump;
	    if (strcmp(nodes[m], nodes[n]) > 0)
		{
		  all_sorted_flag = FALSE;
		  strcpy(temp, nodes[m]); /* temp_row */
		  strcpy(nodes[m], nodes[n]); /* move row */
		  strcpy(nodes[n], temp); /* move temp row */
		}
	    }
	   }
	  while (!all_sorted_flag);
 	}
     _PDMdebug(fname,"Exit");
  return (PDM_S_SUCCESS);
}

/****************************************************************************

Name
   pdmGetDate

Abstract

Synopsis
  long pdmGetDate (date )

Description
   Input:

   Input/Output:

   Output:
      date

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

History
   Kumar Narayanan Fri Mar 19 13:30:52 CST 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/

/****************************************************************************
Main Function
****************************************************************************/


int pdmGetDate ( date )
  char	*date;
  {
  long       systime;
   char *fname = "pdmGetDate";

     if(debug_on) _PDMdebug(fname, "Enter\n");
  /* get date from system */
  time (&systime);
  /*  strncpy(date, ctime(&systime), 26); date[24] = '\0'; */
  /*cftime(date, "%D", &systime);*/  /* SSRS - commented */
     if(debug_on) _PDMdebug(fname, "Exit\n");
  return (PDM_S_SUCCESS);
  }

#include <varargs.h>

int pdmDebugOnOff (int flag)
{
     PDM_DEBUG_FILE[0] = '\0';
     debug_on  = flag;
     sprintf (PDM_DEBUG_FILE, "/usr/tmp/pdm.dbg");
     return (PDM_S_SUCCESS);
}

_PDMdebug( va_alist)
va_dcl
  /*  arguments to send to vfprintf ()  */
  {
    FILE       *outfile, *fopen ();
    char        *fname;   /*  Name of calling function          */
    char        *format; /*    printf () format specification    */
    short      do_not_close;
    va_list    args;

    if (!debug_on) return;

    /*  Open the debug file  */

    if ((strcmp (PDM_DEBUG_FILE, "")) == 0)
      {
        /*  Default to stderr  */

        outfile = stderr;

        do_not_close = 1;
      }
    else
      {
        if ((outfile = fopen (PDM_DEBUG_FILE, "a")) == NULL)
                                return ;
        do_not_close = 0;
      }

    /*  Print out the name of the calling function  */

    /*  Print out the remainder of the message  */

    va_start (args);

    fname = va_arg (args, char *);
    format = va_arg (args, char *);
    fprintf (outfile, "%s: ", fname);
    vfprintf (outfile, format, args);

    va_end (args);

     fprintf(outfile,"\n");

    /*  Close the file  */

    if (do_not_close == 0)
        fclose (outfile);

    return;
  }

