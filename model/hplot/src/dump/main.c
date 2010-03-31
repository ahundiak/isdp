#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPmacros.h"
#include "HPdef.h"
#include "dump.h"

char debug_flag = 0;

/*---(main)-------------------------------------------------------*/

main (argc, argv)

   int argc;    /* command line argument count */
   char *argv[];        /* pointers to command line argument strings */

   {
   FILE *tfp;   /* output temp file pointer from fopen */
   int status;  /* return code from called functions */
   int i;       /* counter */
   int num_commands = 0;        /* number of commands stored */
   char *ptr;   /* char finger */
   char *plotfile_name = 0;     /* pointer to plotfile name string */
   char *tempfile_name = 0;     /* pointer to tempfile name string */
   char ch;     /* a char */

   HPdload ("dump_dload.o");
   HPinitialize_message_system ("dump_mf.x", "hpmsg.msg");

   if (argc < 2)
      {
      printf ("usage: %s plotfile_name[tempfile_name]\n", argv[0]);
      exit (0);
      }

   for (i = 1; i < argc; ++i)
      {
      ptr = argv[i];
      ch = *ptr++;
      if (ch == '-')
         {
         ch = *ptr++;
         switch (ch)
            {
            case 'd':
            case 'D':
               debug_flag = 1;
               break;

            default:
               fprintf (stderr, "unknown option %c\n", ch);
               break;
               }
         }
      else if (!plotfile_name)
         plotfile_name = argv[i];
      else if (!tempfile_name)
         tempfile_name = argv[i];
      else
         {
         fprintf (stderr, "too many arguments (%d)\n", argc);
         status = HSplot_success;
         goto quit;
         }
      }


   /* command line plotfile-name is required */

   if (!plotfile_name)
      {
      fprintf (stderr, "no plotfile name given\n");
      status = HSplot_success;
      goto quit;
      }

   if (debug_flag)
      printf ("dump plotfile %s -> %s\n", plotfile_name, tempfile_name);

   HPcommand_line.plotfile = plotfile_name;

   /* open tempfile for writing */

   if (!tempfile_name)
      tfp = stderr;
   else
      {
      tfp = fopen (tempfile_name, "w");
      if (!tfp)
         {
         fprintf (stderr, "error opening file \"%s\" for write\n", tempfile_name);
         status = HSplot_success;
         goto quit;
         }
      }

   /* read plotfile and write human readable output to tempfile */

   status = ems_metafile_scanner (tfp, &num_commands);
   fprintf( tfp, "fini   :\n" );

quit:
   if (status)
      exit (1);
   else
      exit (0);
   }    /* main */
