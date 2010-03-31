#include <stdio.h>
#include <math.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "HPmacros.h"
#include "HPdef.h"
#include "hpmsg.h"
#include "HPtiming.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"

/*-----------------------
 *
 *  for functions
 *     HPfini_zbuffering
 *     HPenter_HSURF
 *     HPexit_HSURF
 */

#include "HPpr_hplot_f.h"

/*----------------------*/

/*-----------------------
 *
 *  for functions
 *     HPread_command_line
 *     HPread_header
 *     HPread_device
 *     HPread_env_vars
 *     HPset_globals
 *     HPplotfile_interpreter
 *     HPinitialize_message_system
 *     HPmessage
 *     HPplot_rasterfile
 *     HPplot_rasterfile_with_text
 *     HPplotfile_reader
 */

#include "HPpr_hplot.h"

/*---main------------------------------------------------------------------*/

/*
NAME
   main

KEYWORDS
   HSplot
   main

DESCRIPTION
   The main routine of the HSplot process.

PARAMETERS
   argc :(IN) :  Number of arguments on the command line
   argv :(IN) :  array of array of command line arguments

GLOBALS USED
   HPheader        : global structure
   save_rasterfile : save rasterfile option
   HPcommand_line  : global structure
   dont_plot       : dont plot option
   HPglobal        : global structure
   pfl             : File pointer for the shaded plotfile
   textfile        : name of the textfile
   copies          : number of copies to make
   rasterfile      : name of the rasterfile

FUNCTIONS CALLED
   HPinitialize_message_system
   HPread_command_line
   HPread_header
   HPread_env_vars
   HPread_device
   HPset_globals
   HPenter_HSURF
   HPtiming_start
   HPplotfile_reader
   HPplotfile_interpreter
   HPfini_zbuffering
   HPtiming_stop
   HPplot_rasterfile_with_text
   HPplot_rasterfile
   HPmessage
   close
   HPexit_HSURF
   ODExit
   ulink

HISTORY
   ??/??/?? L. Brodnax, M. Lanier
      Created
*/

void main (IGRint argc, IGRchar * argv[])

   {
   int status;
   IGRchar command[2];
   IGRshort level;
   IGRdouble range[6];
   IGRint num;
   IGRchar *ptr;

   IGRint rle_width, rle_length;

   HPinitialize_message_system ("HSplot", "hpmsg.msg");

   if( HPread_command_line (argc, argv)) goto fini;

   if( status = HPread_header() ) 
      {
      HPmessage( status, NULL, HPmessage_PREFIX_PRODNAME );
      goto fini;
      }

   if( HPread_env_vars ()) goto fini;
   if( HPread_device ()) goto fini;

   if (HPset_globals ()) goto quit;

   HPenter_HSURF ();

   /* Time rasterfile creation (1) */

   HPtiming_start (1);

   /* Process the textfile contents */
   /* the outermost loop ends when we have reached the end of file The next */
   /* loop ends when we reach end of file, or end or page.  */

   status = HSplot_success;
   while (status != HSplot_EOF)
      {
      status = HSplot_success;

      while (status != HSplot_EOF)
         {
         status = HPplotfile_reader (HPglobal.pfl,
                                     command,
                                     &level,
                                     range,
                                     &num,
                                     &ptr);

         if (status != HSplot_EOF)
            {
            status = HPplotfile_interpreter (HPglobal.pfl,
                                             command,
                                             level,
                                             range,
                                             num,
                                             ptr);

            }

         if (status == HSplot_error)
            {
            char buf[25];

            HPmessage (HP_F_PartPlot, NULL,
                       HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);

            sprintf (buf, "-objid, osnum: %d %d", HPglobal.objid, HPglobal.osnum);

            HPmessage_str (buf,
                       HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);

            status = HSplot_EOF;
            }

         if (status && status != HSplot_EOF) goto quit;
         }
      }

   status = HPfini_zbuffering (HPglobal.pfl,
                               &rle_width,
                               &rle_length);

   /* stop timing rasterfile creation(1) */

   HPtiming_stop (1);

   if( !HPglobal.dont_plot )
      {

      /*
       *  If a device driver has been specified, either because we're running
       *  from within a device queue, or the driver was specifed on the HSplot
       *  command line, or the DRIVER environment variable is set, then we
       *  will send the rasterfile to the plotting device directly from HSplot
       *  if.....
       *    we are not doing shaded plots with text, or
       *    the rasterfile type is not Postscript
       */

      if( (HPcommand_line.device_driver != NULL || getenv( "DRIVER" ) != NULL) &&
          (HPglobal.rasterfile_type != HPrasterfile_type_PS) )
         {
         if( HPglobal.input_textfile != NULL )
            {
            HPattach_rasterfile_to_textfile();
            HPsubmit_textfile(NULL);
            }
     
         else
            {
#           if defined (CLIX)
            status = HPplot_rasterfile( HPglobal.rasterfile, rle_width, rle_length );
 
            if( status )
               HPmessage( status, NULL,
                          HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );

#           endif /* CLIX */
            }
         }

      else
         {
         if( HPglobal.input_textfile != NULL )
            {
            HPattach_rasterfile_to_textfile();
            HPsubmit_textfile(HPglobal.queue);
            }

         else
         if( HPglobal.queue != NULL )
            HPsubmit_rasterfile(); 
         }
      }

   else
      {
      if( HPglobal.input_textfile != NULL )
         HPattach_rasterfile_to_textfile();
      }

quit:

   fclose (HPglobal.pfl);

   HPexit_HSURF ();

#  if defined (CLIX)
   if (!(HPglobal.dont_plot))
      {
      status = ODExit (0);
      if_bad (status)
         HPmessage (HP_F_ODExt, NULL,
                    HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);
      }
#  endif

   if (!HPheader.save_rasterfile) unlink (HPglobal.rasterfile);

fini:;
   if( HPglobal.heartbeat ) printf( "\n" );

   }    /* main */
