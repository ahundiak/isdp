/* $Id: VDXtools.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtools.C
 *
 * Description:
 *		Support function for extract for review command.
 *		VDXdebug
 *		VDXgen_filename
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log $
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/errno.h>
#include <time.h>
#include <fcntl.h>
#include "UMS.h"
#include "VDXmsg.h"

extern int errno;


void VDXdebug (state, log_file, filename, msg_buf)
    int  state;        /* 1 = print msg to log file and window */
    FILE *log_file;    /* ptr to the log file */
    char *filename;    /* Name of routine where error/warning occured */
    char *msg_buf;     /* buffer containing the message.              */
{
    if (state == 1)
       printf ("%s\n", msg_buf);  /* print msg to local window */
           
    if (log_file != NULL)
     {
        if (filename != NULL)
           fprintf (log_file, "%s: %s\n", filename, msg_buf); 
        else
           fprintf (log_file, "%s\n", msg_buf);  /* print msg to log file */
     }
    return;
}



long VDXgen_filename (in_filename, out_filename, extension)
   char *in_filename;
   char *out_filename;
   char *extension;
{
    int i, j, k;
    char tmp_ext[5];
    
    i = 0;
    j = 0;
    k = 0;
 
    if (in_filename == NULL)
       return (VDX_E_NoFilename);

    strcpy (out_filename, in_filename);

    for (i = strlen (out_filename); i; i = i - 1)
    {
      if (*(out_filename + i) == '.')
        {
          /***  BW.  4/29/94  Check filename.  If it exceeds 10 chars
                before the extension, truncate it.  must allow 4 chars for
                the extension.                                          ***/
          j = i;
          k = 0;
          while ( (j > 0) && (out_filename[j] != '/') )
           {
              k = k + 1;
              j = j - 1;
           }
          if (k > 10)
             j = k - 11;  /**  allow for i pointing at "." **/
          else
             j = 0;
          *(out_filename + i - j) = '\0';
          break;
        }
    }   
   if (extension != NULL)
    {
       strncpy (tmp_ext, extension, 4);
       tmp_ext[4] = '\0';
       strcat (out_filename, tmp_ext);
    }
   return (VDX_S_SUCCESS);
}
