#include <stdio.h>
#include <string.h>

#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "hpmsg.h"

#include "HPpr_hplot.h"

#define DEBUG	0

/*-------------------------------------*/

/*
 *  Include the prototype directly because the include file
 *  requires some OM things
 */

extern int HPcreate_textfile_with_raster_attachment (IGRchar *in_meta,
                                                     IGRchar *rasfil,
                                                     IGRchar *out_meta);

#if defined (CLIX)

/*---HPplot_rasterfile-----------------------------------------------------*/

IGRint HPplot_rasterfile (IGRchar * rle_file,
                          IGRint width,
                          IGRint height)

   {
   IGRint status;
   struct ODRasAttr rasterAttr;
   IGRint x_ext, y_ext;
   IGRint i;

#  if DEBUG
   fprintf( stderr, "HPplot_rasterfile\n" );
#  endif


   x_ext = (int) ((double) width * HPglobal.replication_factor);
   y_ext = (int) ((double) height * HPglobal.replication_factor);

   /*
    * set plot origin to <0,0>
    */

   status = ODPlotOrigin (HPdevice.ws_no, (IGRlong) 0, (IGRlong) 0);
   return_bad (status);

   /*
    * set window to the size of the plotter in device units
    */

   status = ODPlotAreaSize (HPdevice.ws_no, x_ext, y_ext);
   return_bad (status);

   /*
    * Clear the plot area
    */

   status = ODClearPlot (HPdevice.ws_no);
   return_bad (status);


   rasterAttr.Scale = HPglobal.replication_factor;
   rasterAttr.Options = ODM_RAS_SCANNABLE | ODM_RAS_INDEXED_COLOR;
   rasterAttr.FgColorIndex = 0;
   rasterAttr.FgColorR = 0;
   rasterAttr.FgColorG = 0;
   rasterAttr.FgColorB = 0;
   rasterAttr.BgColorIndex = 1;
   rasterAttr.BgColorR = 0;
   rasterAttr.BgColorG = 0;
   rasterAttr.BgColorB = 0;
   rasterAttr.TransColorIndex = 2;
   rasterAttr.TransColorR = 0;
   rasterAttr.TransColorG = 0;
   rasterAttr.TransColorB = 0;

   status = ODRasterFile (
                          HPdevice.ws_no,
                          (IGRlong) 0, (IGRlong) 0,
                          &rasterAttr,
                          rle_file,
                          0);

   return_bad (status);

   for (i = 0; i < HPglobal.copies; i++)
      {
      status = ODShowPlot (HPdevice.ws_no);
      sleep (5);
      return_bad (status);
      }

   return HSplot_success;
   }
#endif /* CLIX */

/*---HPsubmit_textfile----------------------------------__*/

HPsubmit_textfile (char *queue)

   {
   IGRchar outfile[40];

   IGRchar buf[512], cmd[512];
   FILE *pp = NULL;
   FILE *popen ();
   IGRint i;
   IGRchar c;
   char *envr, *getenv ();

#  if DEBUG
   fprintf( stderr, "HPsubmit_textfile\n" );
#  endif

   strcpy (cmd, "qpr 2>&1 ");

   if( queue != NULL )
      {
      sprintf( buf, " -q %s ", queue );
      }

   else
      {

      /* Get queue name by parsing the DEV_ATT envrionment */
      /* variable string.  */

      envr = getenv ("DEV_ATT");

      if (envr != NULL)
         {
#        if DEBUG
         fprintf (stderr, "DEV_ATT: %s\n", envr);
#        endif

         /*
          * Find the period at the end of the name and change that character to
          * a zero (0)
          */

         i = strlen (envr);
         while (envr[i] != '.')
            i--;

         envr[i] = 0;

         /*
          * Find the slash at the beginning of the name
          */

         while (envr[i] != '/')
            i--;

         /*
          * From the character right of the slash, to the end string, is the
          * queue name.  Put that on the command line
          */

         sprintf (buf, " -q %s ", &envr[i + 1]);
         }

      else
         {
         printf( "Queue not specified\n" );
         }
      }

   strcat (cmd, buf);

   /*
    * Specify the IGDS textfile interpreter
    */

   sprintf (buf, " -t igds ");
   strcat (cmd, buf);

   /*
    * Add the plot size to the command line
    */

   sprintf (buf, " -o \" -e %.3fx%.3f \" ",
            HPglobal.size_x, HPglobal.size_y);

   strcat (cmd, buf);

   /*
    * Put the name of the rasterfile and the IGDS textfile with raster
    * attachment, on the command line
    */

   sprintf (buf, " -n %1d -p 63 -e RASTERFILE=%s %s",
            HPglobal.copies, HPglobal.rasterfile, HPglobal.output_textfile);

   strcat (cmd, buf);

   if( HPglobal.debug )
      fprintf (stderr, "%s\n", cmd);

   /*
    * Create a pipe using the just created command line
    */

   pp = popen (cmd, "r");

   if (pp == NULL)
      {
      fprintf (stderr, "execute fail\n");
      }
   else
      {
      cmd[0] = NULL;

      /*
       * get feedback from request
       */

      i = 0;
      c = getc (pp);
      while (c != 10 && c > 0)
         {
         buf[i++] = c;
         if (i > 127)
            i = 127;
         c = getc (pp);
         }

      buf[i] = 0;

      /*if( HPglobal.debug )*/
         fprintf (stderr, "%s\n", buf);

      pclose (pp);
      }

   /*
    * Clean up
    */

   unlink (HPglobal.output_textfile);
   }

/*---HPattach_rasterfile_to_textfile--------------------------*/

void HPattach_rasterfile_to_textfile ()

   {
   char outfile[40];
   char unique_name[20];

#  if DEBUG
   fprintf( stderr, "HPattach_rasterfile_to_textfile\n" );
#  endif

   if( HPglobal.output_textfile == NULL )
      {
      HPgenerate_unique_name( unique_name );

      sprintf( outfile, "/usr/tmp/%s.txt", unique_name );

      HPcreate_textfile_with_raster_attachment ( HPglobal.input_textfile,
                                                 HPglobal.rasterfile,
                                                 outfile);

      HPglobal.output_textfile = (char *)malloc( strlen(outfile) + 1 );
      strcpy( HPglobal.output_textfile, outfile );

      HPmessage( HP_I_OtTxFlNm, outfile, HPmessage_PREFIX_PRODNAME );
      }
   else
      {
      HPcreate_textfile_with_raster_attachment ( HPglobal.input_textfile,
                                                 HPglobal.rasterfile,
                                                 HPglobal.output_textfile );
      }
   }

/*---HPsubmit_rasterfile---------------------------------*/

void HPsubmit_rasterfile()

   {
   FILE *pp = NULL;
   FILE *popen ();
   char cmd[256], buf[100];
   IGRint i;
   IGRchar c;

#  if DEBUG
   fprintf( stderr, "HPsubmit_rasterfile\n" );
#  endif

   strcpy( cmd, "qpr 2>&1 " );

   /*
    *  metafile interpreter .  If the rasterfile type is
    *  Postscript, then the interpreter is script, else it
    *  is raster
    */

   if( HPglobal.rasterfile_type == HPrasterfile_type_PS )
      strcat( cmd, "-t script " );
   else
      strcat( cmd, "-t raster " );

   /*
    *  queue
    */

   strcat( cmd, "-q " );
   strcat( cmd, HPglobal.queue );
   strcat( cmd, " " );

   /*
    * dimensions
    */

   if( HPglobal.rasterfile_type != HPrasterfile_type_PS )
      {
      sprintf( buf, " -o \" -e%.3fx%.3f \" ", 
         HPglobal.size_x, HPglobal.size_y );
      strcat( cmd, buf );
      }

   /*
    *  rasterfile name
    */

   strcat( cmd, HPglobal.rasterfile );

   if( HPglobal.debug )
      fprintf (stderr, "%s\n", cmd);

   pp = popen (cmd, "r");

   if (pp == NULL)
      {
      fprintf (stderr, "execute fail\n");
      }
   else
      {
      cmd[0] = NULL;

      /*
       * get feedback from request
       */

      i = 0;
      c = getc (pp);
      while (c != 10 && c > 0)
         {
         buf[i++] = c;
         if (i > 127)
            i = 127;
         c = getc (pp);
         }

      buf[i] = 0;

      /*if( HPglobal.debug )*/
         fprintf (stderr, "%s\n", buf);

      pclose (pp);
      }
   }
