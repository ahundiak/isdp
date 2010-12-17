#include <stdio.h>
#include <varargs.h>
#include "MEMstruct.h"
#include "PDMproto.h"

extern char PDM_DEBUG_FILE[];
extern int  PDMdebug_on;

_PDMdebug( va_alist)
va_dcl
  /*  arguments to send to vfprintf ()  */
  {
    FILE       *outfile, *fopen ();
    char        *fname;   /*  Name of calling function          */
    char        *format; /*    printf () format specification    */
    short      do_not_close;
    va_list    args;

    if (!PDMdebug_on) return;

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

  /*  fprintf (outfile, "NFM: %s: ", fname); */

    /*  Print out the remainder of the message  */

    va_start (args);

    fname = va_arg (args, char *);
    format = va_arg (args, char *);
    fprintf (outfile, "%s: ", fname);
    vfprintf (outfile, format, args);

    va_end (args);

    /*  Close the file  */

    if (do_not_close == 0)
fclose (outfile);


    return;
  } 

/*
void PDMdisplay_msg(s)
char *s;
  {
    int i,len;
    int x,y;
    char msg_string[80]; 

    msg_string[0] = '\0';

    len = strlen(s);
    if (len > 78)
      len = 78;

    strcpy(msg_string,s);

    for(i=1;i<=len;i++)
      if (msg_string[i] == '\n')
        msg_string[i] = ' ';

      printf("<%s>\n",msg_string);

    wrefresh();
  }

void PDMclear_msg()
  { 
    initscr();
    refresh();
    endwin();
    initscr();
    reset_shell_mode();
  }

*/

