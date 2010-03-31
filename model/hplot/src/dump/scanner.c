#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPmacros.h"
#include "HPdef.h"
#include "dump.h"

/*---ems_metafile_scanner---------------------------------------------------*/

int ems_metafile_scanner ( FILE *out_file,           /* output file pointer */
                           int  *commands_processed) /* counter of cmds processed */

   {
   int            status;      /* return code from called functions */
   int            num;         /* number of data items input */
   char           *ptr;        /* pointer to data buffer */
   IGRchar        command[2];  /* current command being processed */
   unsigned short level;       /* graphic level if draw command */
   double         range[6];    /* range if cmd with */
   extern char    debug_flag;  /* user wants messages */

   /* process file header */

   status = dump_header (out_file);
   if (status) return (HSplot_error);

   /* loop: get command type and rest of command */

   for (;;)
      {
      status = HPplotfile_reader (HPglobal.pfl,
                                  command,
                                  &level,
                                  range,
                                  &num,
                                  &ptr);

      if (status == HSplot_EOF)
         {
         if (debug_flag)
            printf ("processed %d commands\n", *commands_processed);

         return HSplot_success;
         }

      if (status) return HSplot_error;

      ++*commands_processed;

      /* process individual command, don't store it */

      status = dump_element (out_file, command, level, range, num, ptr);
      if (status)
         return HSplot_error;
      }
   }
