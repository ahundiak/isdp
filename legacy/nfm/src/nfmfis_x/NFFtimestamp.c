
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*
	As ERR.h defines va_start to use va_alist, i had to undefine va_start 
	before including the stdarg.h.  MVR 7 Jan 1994 
*/
#ifdef OS_SCO_UNIX
#undef	va_start
#include <stdarg.h>
#define va_start(list, parmN) \
     list = ((char *)(&parmN)) + ((sizeof(parmN) + sizeof(int) - 1) & \
                     ~(sizeof(int)-1));
#endif

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

void __NFFts_data (char *format, ...)
  {
    auto      char    buffer[80];
    auto      va_list args;
    static    char    *fname = "__NFFts_data";

    va_start (args, format);
    vsprintf (buffer, format, args);
    va_end (args);

    _NFIdebug ((fname, "adding <%s> to buffer\n", buffer));

    strncat (NFFglobal.timestamp_buffer,
        buffer, sizeof (NFFglobal.timestamp_buffer) - 1);
  }


void __NFFts_commit ()
  {
    auto    FILE  *outfile;
    static  short first_time = TRUE;
    static  char  *fname = "__NFFts_commit";
    static  char  *file_header_info = "\
#\n\
# No file I/O is included in the times represented; all data is buffered\n\
# until the command is finished.  File is written at the end of the command.\n\
#\n\
# Command             -  Workflow command string\n\
# User Start Time     -  User selects command\n\
# Access Validated    -  End of workflow validation\n\
# User Form Displayed -  First chance for user to input command data\n\
# User Input Finished -  User accepts form\n\
# Command Finished    -  Command completed on server and returned to client\n\
# Workflow State Set  -  Set next workflow state completed\n\
# End of Command      -  First chance for new user input to be processed\n\
#\n";

    if ((outfile = fopen (NFFglobal.timestamp_file, "a")) == NULL)
      {
        _NFIdebug ((fname, "failed to open <%s> for timestamp output\n",
            NFFglobal.timestamp_file));
        return;
      }

    if (first_time == TRUE)
      {
        fputs (file_header_info, outfile);
        first_time = FALSE;
      }

    _NFIdebug ((fname, "writing buffer to file\n"));

    fputs (NFFglobal.timestamp_buffer, outfile);
    fclose (outfile);
    strcpy (NFFglobal.timestamp_buffer, "");
  }
