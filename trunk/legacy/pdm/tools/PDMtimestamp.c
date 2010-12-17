#include "PDMtimestamp.h"
#include <stdio.h>
#include <string.h>
/*#include <tools.h>*/
#include <stdarg.h>
#include <sys/types.h>
#include <sys/times.h>



extern int  PDMtime_enabled;
extern char PDMtimestamp_buffer[4096];
extern char PDMtimestamp_file[256];
extern int  PDMtime_value;

void _PDMtime_data (char *format, ...)
  {
    auto      char    buffer[80];
    auto      va_list args;
    static    char    *fname = "__PDMtime_data";

    va_start (args, format);
    vsprintf (buffer, format, args);
    va_end (args);

    _PDMdebug (fname, "adding <%s> to buffer\n", buffer);

    strncat (PDMtimestamp_buffer,
        buffer, sizeof (PDMtimestamp_buffer) - 1);
  }


void _PDMtime_commit ()
  {
    auto    FILE  *outfile;
    static  short first_time = 1;
    static  char  *fname = "_PDMtime_commit";
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
     if(!strcmp(PDMtimestamp_file,""))
       {
        _PDMdebug (fname, "timestamp file name is not given , hence /usr/tmp/pdmtime.log\n");
        strcpy(PDMtimestamp_file,"/usr/tmp/pdmtime.log");
       }

    if ((outfile = fopen (PDMtimestamp_file, "a")) == NULL)
      {
        _PDMdebug (fname, "failed to open <%s> for timestamp output\n",
            PDMtimestamp_file);
        return;
      }

    if (first_time == 1)
      {
        fputs (file_header_info, outfile);
        first_time = 0;
      }

    _PDMdebug (fname, "writing buffer to file\n");

    fputs (PDMtimestamp_buffer, outfile);
    fclose (outfile);
    strcpy (PDMtimestamp_buffer, "");
  }
