#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "igrtypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "hpmsg.h"
#include "HPmacros.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"


/*------------------------------
 *  for function
 *     HSconv_double
 *     HSconv_short
 */

#include "HSrle.h"
#include "hsanimate.h"
#include "HSpr_rle_uti.h"

/*------------------------------*/

#define DEBUG 0

/*  constants and stuff for units option */

#define     HSplot_UNIT_IN     0
#define     HSplot_UNIT_FT     1
#define     HSplot_UNIT_MM     2
#define     HSplot_UNIT_CM     3
#define     HSplot_UNIT_M      4

static double HSplot_ConversionTable[5] = {  1.0,        /* in to in */
                                            12.0,        /* ft to in */
                                             0.0393696,  /* mm to in */
                                             0.393696,   /* cm to in */
                                            39.3696 };   /*  m to in */

static int HSplot_SelectedUnits = HSplot_UNIT_IN;

/*  declaration of static functions */

static void HPgeneral_options (void);
static void HPdebug_options (void);
static void HPbuild_ignore_list (char *list);
static int  HPparse_plotsize( char *optarg );
static int  HPparse_units( char *s );
static void HPconvert_to_inches(void);

/*---HPread_command_line-------------------------------------------*/

/*

NAME
   HPread_command_line

KEYWORDS
   HSplot
   init

DESCRIPTION
   Read and parse the command line arguments

PARAMETERS
   argc :(IN) :  The number of arguments on the command line
   argv :(IN) :  List of strings, one for each command line argument

GLOBALS USED
   HPcommand_line :  Array of command line information

NOTES
   The command line arguments are:

   HSplot [options] [<plotfile]

      options:
         choose one
            -e Plot size: dimensions in inches (default: scale = 1)
            -s Plot size: scale factor (default: scale = 1)

         plus
            -r Plot resolution in inches (default: 100 pixels/inch)

            -d Device Driver (path + name) (CLIX only)
            -o Device Output Port (p#) (CLIX only)

            -u Units (in, ft, mm, cm, m)

            -f input plotfile name (default: stdin)
            -t Input IGDS textfile name
            -g Output IGDS textfile name
            -p Output Rasterfile name (unconditional save)

            -c Number of copies (CLIX only)
            -b black_and_white edges
            -l line width constant (0.0, 0.02)
            -R Replication Factor (1, 2, 3,... )
            -w use_colortable_background
            -m max line width (0-31)
            -T tiling_tolerance (.25-8.0)
            -k rasterfile type (25, 27, PS)
            -a Anti Alias output
            -z dont plot (CLIX only)
            -i feedback object id's
            -q Plot Queue
            -h turn on heartbeat
            -W Exclude Wireframe

            -? Display the usage information
            -v Display the current version number
            -x List of objid:osnum for objects to ignore

         for debugging
            -6 Use 6 bytes per pixel
            -P Use 7 bytes per pixel(phong lighting)

      options in alphabetical order

            -a Anti Alias output
            -b black_and_white edges
            -c Number of copies
            -d Device Driver, path + name
            -e Plot size: dimensions in inches (default: scale = 1)
            -f Input plotfile name (default: stdin)
            -g Output IGDS textfile name
            -h turn on heartbeat
            -i feedback object id's
            -k Rasterfile type
            -l line width constant
            -m max line width
            -o Device Output Port
            -p Output Rasterfile name (unconditional save)
            -q Plot Queue
            -r Plot resolution in inches (default: 100 pixels/inch)
            -s Plot size: scale factor (default: scale = 1)
            -t Input IGDS textfile
            -u Units (in, ft, mm, cm, m)
            -v Display the current version number
            -w use_colortable_background
            -x List of objid:osnum for objects to ignore
            -z dont plot
            -6 Use 6 bytes per pixel
            -P Use 7 bytes per pixel(phong lighting)
            -R Replication Factor
            -T tiling_tolerance (.25-8.0)
            -W Exclude Wireframe
            -? Display the usage information

   What happens when you use the -t and/or -g options

   +----------+----------+-----------------------------------------+
   |    -t    |    -g    | action                                  |
   +----------+----------+-----------------------------------------+
   | not used | not used | Do not create text metafile with raster |
   |          |          | attachment                              |
   +----------+----------+-----------------------------------------+
   |   used   | not used | Create text metafile with raster        |
   |          |          | raster attachment and default output    |
   |          |          | file of a unique filename               |
   +----------+----------+-----------------------------------------+
   | not used |   used   | Do not create text metafile with raster | 
   |          |          | attachment.  The output_textfile given  |
   |          |          | is ignored and a warning issued         | 
   +----------+----------+-----------------------------------------+
   |   used   |   used   | Create text metafile with raster        |
   |          |          | attachment using input text metafile    |
   |          |          | and output text metafile of the given   |
   |          |          | name                                    |
   +----------+----------+-----------------------------------------+

HISTORY
   ??/??/??     M. Lanier
      Created
   11/12/95     M. Lanier
      Added code to the -P argument which instructs HSplot to use
      phong lighting.
*/

IGRint HPread_command_line (IGRint argc, IGRchar * argv[])

   {
   extern char *optarg;
   extern int  optind, opterr;

#  if defined (CLIX)
   static IGRchar option_string_normal[] = {"abc:d:e:f:g:hik:l:m:o:q:p:r:s:t:vwx:z?R:T:W"};
   static IGRchar option_string_debug[]  = {"abc:d:e:f:g:hik:l:m:o:q:p:r:s:t:u:vwx:z?6PR:T:W"};
#  else
   static IGRchar option_string_normal[] = {"abe:f:g:hik:l:m:p:q:r:s:t:vwx:zR:T:W"};
   static IGRchar option_string_debug[]  = {"abe:f:g:hik:l:m:p:q:r:s:t:u:vwx:z6PR:T:W"};
#  endif

   IGRchar   option, ch, *option_string;
   IGRchar   *strchr ();
   IGRdouble temp_dbl;
   IGRchar   *size;
   IGRint    status;

   char      *expr, *getenv ();

   struct stat	s;


   HPcommand_line.size_x = 0.0;
   HPcommand_line.size_y = 0.0;
   HPcommand_line.scale = -1.0;
   HPcommand_line.resolution = -1.0;
   HPcommand_line.line_width_constant = 0.0;
   HPcommand_line.max_line_width = 16;
   HPcommand_line.rasterfile_type = HPrasterfile_type_Undefined;
   HPcommand_line.flags = 0;
   HPcommand_line.copies = 1;
   HPcommand_line.plotfile = NULL;
   HPcommand_line.rasterfile = NULL;
   HPcommand_line.input_textfile = NULL;
   HPcommand_line.output_textfile = NULL;
   HPcommand_line.device_driver = NULL;
   HPcommand_line.device_port = NULL;
   HPcommand_line.dont_plot = FALSE;
   HPcommand_line.black_and_white_edges = FALSE;
   HPcommand_line.white_background = TRUE;
   HPcommand_line.heartbeat = TRUE;
   HPcommand_line.bytes_per_pixel = 5;
   HPcommand_line.tiling_tolerance = 0.0;
   HPcommand_line.replication_factor = 0.0;

   HPglobal.ignore_list = NULL;
   HPglobal.anti_aliasing = FALSE;
   HPglobal.flags = 0;

   /*  If the debug environment variable is set, then use the expanded */
   /*  option list */

   if( getenv( "HSplot_DEBUG" ) != NULL )
      option_string = option_string_debug;
   else
      option_string = option_string_normal;

   while ((option = getopt (argc, argv, option_string)) != EOF)
      {
      switch (option)
         {
         case 'W':
            HPcommand_line.flags |= HPflag_Exclude_Wireframe;
            break;

         case 'h':
            HPglobal.heartbeat = TRUE;
            break;

         case 'a':
            HPglobal.anti_aliasing = TRUE;
            break;

         case 'x':
            HPbuild_ignore_list (optarg);
            break;

         case 'i':
            HPglobal.flags |= HPpflag_FEEDBACK_OBJID;
            break;

         case 'e':
            if (!(HPcommand_line.flags & HPflag_PlotSize))
               {
               if ((size = strchr (optarg, 'x')))
                  {
                  size++;

                  if ((optarg[0] >= '0') && (optarg[0] <= '9') &&
                      (size[0] >= '0') && (size[0] <= '9'))
                     {
                     sscanf (optarg, "%lf%c%lf",
                             &HPcommand_line.size_x,
                             &ch,
                             &HPcommand_line.size_y);

                     /*
                      * load the plot dimension from the scanline.  Set the
                      * scale to -1, indicating "use the dimensions not the
                      * scale factor"
                      */

                     HPcommand_line.flags |= HPflag_PlotSize;
                     HPcommand_line.scale = -1.0;
                     }
                  else
                     {
                     HPmessage (HP_I_InvPltDm, optarg, HPmessage_PREFIX_PRODNAME);
                     }
                  }
               else
                  {
                  HPmessage (HP_I_InvPltDm, optarg, HPmessage_PREFIX_PRODNAME);
                  }
               }
            else
               {
               HPmessage (HP_I_PltSzDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 's':

            /*
             * plot scale factor
             */

            if (!(HPcommand_line.flags & HPflag_PlotSize))
               {
               if( optarg[0] >= 'A' && optarg[0] <= 'E' )
                  {
                  if( HPparse_plotsize( optarg ) )
                     {

                     /*
                      * Set the scale to -1, indicating "use the 
                      * dimensions not the scale factor"
                      */

                     HPcommand_line.flags |= HPflag_PlotSize;
                     HPcommand_line.scale = -1.0;
                     }
                  else
                     {
                     HPmessage (HP_I_InvPltScl, optarg, HPmessage_PREFIX_PRODNAME);
                     }
                  }
               else
                  {

                  /*
                   * get the double value off the command line
                   */

                  status = HPparse_double (optarg,
                                           strlen (optarg),
                                           &temp_dbl);

                  if (status)
                     {
                     HPcommand_line.flags |= HPflag_PlotSize;
                     HPcommand_line.scale = temp_dbl;
                     }
                  else
                     {
                     HPmessage (HP_I_InvPltScl, optarg, HPmessage_PREFIX_PRODNAME);
                     }
                  }
               }
            else
               {
               HPmessage (HP_I_PltSzDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'r':

            /*
             * plot resolution
             */

            if (!(HPcommand_line.flags & HPflag_DeviceDriver))
               {
               if (!(HPcommand_line.flags & HPflag_PlotRes))
                  {

                  /*
                   * get the double value off the command line
                   */

                  status = HPparse_double (optarg,
                                           strlen (optarg),
                                           &temp_dbl);

                  if (status)
                     {
                     HPcommand_line.flags |= HPflag_PlotRes;
                     HPcommand_line.resolution = temp_dbl;
 
                     if( !getenv( "HSplot_DONT_PLOT" ) )
                        HPcommand_line.dont_plot = TRUE;
                     }
                  else
                     {
                     HPmessage (HP_I_InvPltRes, optarg, HPmessage_PREFIX_PRODNAME);
                     }
                  }
               else
                  {
                  HPmessage (HP_I_PltResDf, NULL, HPmessage_PREFIX_PRODNAME);
                  HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
                  }
               }
            else
               {
               HPmessage (HP_I_DvcDrvr, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'd':

            /*
             * Load device driver name
             */

            if (!(HPcommand_line.flags & HPflag_PlotRes))
               {
               if (!(HPcommand_line.flags & HPflag_DeviceDriver))
                  {
                  HPcommand_line.flags |= HPflag_DeviceDriver;
                  HPcommand_line.device_driver = (char *) malloc (strlen (optarg) + 1);
                  strcpy (HPcommand_line.device_driver, optarg);

                  HPcommand_line.resolution = -1;
                  HPcommand_line.dont_plot = FALSE;
                  }
               else
                  {
                  HPmessage (HP_I_DvcDrvr, NULL, HPmessage_PREFIX_PRODNAME);
                  HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
                  }
               }
            else
               {
               HPmessage (HP_I_PltResDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'o':

            /*
             * Load device port
             */

            if (!(HPcommand_line.flags & HPflag_DevicePort))
               {
               HPcommand_line.flags |= HPflag_DevicePort;
               HPcommand_line.device_port = (char *) malloc (strlen (optarg) + 1);
               strcpy (HPcommand_line.device_port, optarg);
               }
            else
               {
               HPmessage (HP_I_DvcPrt, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'f':

            /*
             * Load the input plotfile
             */

            if (!(HPcommand_line.flags & HPflag_PlotFileName))
               {
               HPcommand_line.flags |= HPflag_PlotFileName;
               HPcommand_line.plotfile = (char *) malloc (strlen (optarg) + 1);
               strcpy (HPcommand_line.plotfile, optarg);
               }
            else
               {
               HPmessage (HP_I_InpFlDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'p':

            /*
             * Load the output rasterfile
             */

            if (!(HPcommand_line.flags & HPflag_RasterFileName))
               {
               HPcommand_line.flags |= HPflag_RasterFileName;
               HPcommand_line.rasterfile = (char *) malloc (strlen (optarg) + 1);
               strcpy (HPcommand_line.rasterfile, optarg);
               }
            else
               {
               HPmessage (HP_F_OtpRlDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 't':

            /*
             * Load the input textfile
             */

            if (!(HPcommand_line.flags & HPflag_TextFileName))
               {
               HPcommand_line.flags |= HPflag_TextFileName;
               HPcommand_line.input_textfile = (char *) malloc (strlen (optarg) + 1);
               strcpy (HPcommand_line.input_textfile, optarg);
               }
            else
               {
               HPmessage (HP_I_InpTfDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'g':

            /*
             * Load the output textfile
             */

            if (HPcommand_line.output_textfile == NULL)
               {
               HPcommand_line.output_textfile = (char *) malloc (strlen (optarg) + 1);
               strcpy (HPcommand_line.output_textfile, optarg);
               }
            else
               {
               HPmessage (HP_I_OtpTfDf, NULL, HPmessage_PREFIX_PRODNAME);
               HPmessage (HP_I_IptIgnrd, optarg, HPmessage_PREFIX_PRODNAME);
               }

            break;

         case 'q':
       
            if( HPcommand_line.queue == NULL )
               { 
               HPcommand_line.queue = (char *)malloc( strlen(optarg) + 1 );
               strcpy( HPcommand_line.queue, optarg );
               }
 
            else
               {
               }

         case 'c':
            sscanf (optarg, "%d", &HPcommand_line.copies);
            break;

         case 'b':
            HPcommand_line.flags |= HPflag_Black_And_White;
            HPcommand_line.black_and_white_edges = TRUE;
            break;

         case 'R':
            sscanf (optarg, "%lf", &HPcommand_line.replication_factor);
            break;

         case 'T':
            sscanf (optarg, "%lf", &HPcommand_line.tiling_tolerance);
            break;

         case 'l':
            sscanf (optarg, "%lf", &HPcommand_line.line_width_constant);
            break;

         case 'w':
            HPcommand_line.white_background = FALSE;
            break;

         case 'm':
            sscanf (optarg, "%d", &HPcommand_line.max_line_width);
            break;

         case 'k':
            if( strcmp( optarg, "25" ) == 0 )
               HPcommand_line.rasterfile_type = HPrasterfile_type_25;

            else
            if( strcmp( optarg, "27" ) == 0 )
               HPcommand_line.rasterfile_type = HPrasterfile_type_27;

            else
            if( strcmp( optarg, "PS" ) == 0 ||
                strcmp( optarg, "Ps" ) == 0 ||
                strcmp( optarg, "pS" ) == 0 ||
                strcmp( optarg, "ps" ) == 0 )
               HPcommand_line.rasterfile_type = HPrasterfile_type_PS;

            else
               {
               HPmessage( HP_E_UnsupRasFilTyp, optarg, HPmessage_PREFIX_PRODNAME );
               return HP_E_UnsupRasFilTyp;
               }

            break;

         case 'u':
            if( !HPparse_units( optarg ) )
               HPmessage( HP_E_UnNtSup, optarg, HPmessage_PREFIX_PRODNAME );
            break;

         case 'v':
            HPversion ();
            return (HSplot_info);

         case 'z':
            HPcommand_line.dont_plot = TRUE;
            HPcommand_line.flags |= HPflag_DontPlot;
            break;

         case '6':
            HPcommand_line.bytes_per_pixel = 6;
            break;

         case 'P':
            HPcommand_line.bytes_per_pixel = 7;
            break;

         case '?':
         default:
            HPgeneral_options ();
            /* HPdebug_options (); */

            return (HSplot_info);
         }
      }

   /*
    *  Check for the error condition of the user supplying an output textfile
    *  but not an input textfile
    */

   if( HPcommand_line.output_textfile && !HPcommand_line.input_textfile )
      {
      HPmessage( HP_W_NoInTxFl, NULL, HPmessage_PREFIX_PRODNAME );
      }

   /*
    * Make sure the input and output textfile names are not the same
    */

   if( HPcommand_line.output_textfile != NULL &&
       HPcommand_line.input_textfile != NULL )
      {
      if( strcmp( HPcommand_line.output_textfile,
                  HPcommand_line.input_textfile ) == 0 )
         {
         HPmessage( HP_E_TxFlSm, NULL, HPmessage_PREFIX_PRODNAME );
         return HP_E_TxFlSm;
         }
      }

   /* If a plotfile has not been entered via the -f option, then check to */
   /* see if there is one sitting at the end of the command line */

   if( HPcommand_line.plotfile == NULL )
      {
      for( ; optind<argc; optind++ )
         {
         if( stat( argv[optind], &s ) == 0 )
            {
            HPcommand_line.plotfile = (char *)malloc( strlen( argv[optind] ) + 1 );
            strcpy( HPcommand_line.plotfile, argv[optind] );
            break;
            }
         }
      }

   if( HSplot_SelectedUnits >= 0 )
      HPconvert_to_inches();
   else
      return HP_E_UnNtSup;

#  if DEBUG
   fprintf (stderr, "HPcommand_line\n");
   fprintf (stderr, "   size_x, size_y ---------- %f %f\n", 
      HPcommand_line.size_x, HPcommand_line.size_y);
   fprintf (stderr, "   scale ------------------- %f\n", HPcommand_line.scale);

   if (HPcommand_line.resolution > 0)
      fprintf (stderr, "   resolution -------------- %f\n", HPcommand_line.resolution);

   if (HPcommand_line.line_width_constant > 0.0)
      fprintf (stderr, "   line_width_constant ----- %f\n", 
         HPcommand_line.line_width_constant);

   if (HPcommand_line.replication_factor > 0.0)
      fprintf (stderr, "   replication_factor ------ %f\n", 
         HPcommand_line.replication_factor);

   if (HPcommand_line.max_line_width > 0)
      fprintf (stderr, "   max_line_width ---------- %d\n", 
         HPcommand_line.max_line_width);

   fprintf (stderr, "   rasterfile_type --------- " );
   switch( HPcommand_line.rasterfile_type )
      {
      case HPrasterfile_type_25:   fprintf( stderr, "25\n"   ); break;
      case HPrasterfile_type_27:   fprintf( stderr, "27\n"   ); break;
      case HPrasterfile_type_PS:   fprintf( stderr, "PS\n"   ); break;
      default:                     fprintf( stderr, "Unsupported\n" ); break;
      }

   fprintf (stderr, "   copies ------------------ %d\n", HPcommand_line.copies);

   if (HPcommand_line.plotfile != NULL)
      fprintf (stderr, "   plotfile ---------------- %s\n", HPcommand_line.plotfile);

   if (HPcommand_line.input_textfile != NULL)
      fprintf (stderr, "   input_textfile ---------- %s\n", 
         HPcommand_line.input_textfile);

   if (HPcommand_line.output_textfile != NULL)
      fprintf (stderr, "   output_textfile --------- %s\n", 
         HPcommand_line.output_textfile);

   if (HPcommand_line.rasterfile != NULL)
      fprintf (stderr, "   rasterfile -------------- %s\n", HPcommand_line.rasterfile);

   if (HPcommand_line.device_driver != NULL)
      fprintf (stderr, "   device driver ----------- %s\n", HPcommand_line.device_driver);

   if (HPcommand_line.device_port != NULL)
      fprintf (stderr, "   device port ------------- %s\n", HPcommand_line.device_port);

   if( HPcommand_line.queue )
      fprintf( stderr, "   queue ------------------- %s\n", HPcommand_line.queue );
   fprintf (stderr, "   dont_plot --------------- %d\n", HPcommand_line.dont_plot);
   fprintf (stderr, "   black_and_white_edges --- %d\n", 
      HPcommand_line.black_and_white_edges);
   fprintf (stderr, "   white_background -------- %d\n", 
      HPcommand_line.white_background);
   fprintf (stderr, "   bytes_per_pixel --------- %d\n\n", 
      HPcommand_line.bytes_per_pixel);
#  endif

   return (HSplot_success);
   }

/*---HPgeneral_options-----------------------------------------------*/

/*
NAME
   HPgeneral_options

KEYWORDS
   HSplot
   options

DESCRIPTION
   Display the options that you want the user to know about

HISTORY
   ??/??/?? M. Lanier
      Created
*/

static void HPgeneral_options (void)

   {
   HPmessage (HP_I_Usg_title, NULL, 0);
   HPmessage (HP_I_Usg_blank, NULL, 0);
   HPmessage (HP_I_Usg_options, NULL, 0);
   HPmessage (HP_I_Usg_choose_one, NULL, 0);
   HPmessage (HP_I_Usg_e, NULL, 0);
   HPmessage (HP_I_Usg_s, NULL, 0);
   HPmessage (HP_I_Usg_blank, NULL, 0);
   HPmessage (HP_I_Usg_plus, NULL, 0);

#  if defined (CLIX)
   HPmessage (HP_I_Usg_d, NULL, 0);
   HPmessage (HP_I_Usg_o, NULL, 0);
   HPmessage (HP_I_Usg_blank, NULL, 0);
#  endif

   HPmessage (HP_I_Usg_r, NULL, 0);
   HPmessage (HP_I_Usg_blank, NULL, 0);
   HPmessage (HP_I_Usg_f, NULL, 0);
   HPmessage (HP_I_Usg_t, NULL, 0);
   HPmessage (HP_I_Usg_g, NULL, 0);
   HPmessage (HP_I_Usg_p, NULL, 0);
   HPmessage (HP_I_Usg_blank, NULL, 0);

#  if defined (CLIX)
   HPmessage (HP_I_Usg_c, NULL, 0);
#  endif

   HPmessage (HP_I_Usg_b, NULL, 0);
   HPmessage (HP_I_Usg_l, NULL, 0);
   HPmessage (HP_I_Usg_R, NULL, 0);
   HPmessage (HP_I_Usg_w, NULL, 0);
   HPmessage (HP_I_Usg_m, NULL, 0);
   HPmessage (HP_I_Usg_T, NULL, 0);
   HPmessage (HP_I_Usg_k, NULL, 0);
   HPmessage (HP_I_Usg_q, NULL, 0);
   HPmessage (HP_I_Usg_W, NULL, 0);

#  if DISABLE
   HPmessage (HP_I_Usg_u, NULL, 0);
#  endif

#  if defined (CLIX)
   HPmessage (HP_I_Usg_z, NULL, 0);
#  endif

   HPmessage (HP_I_Usg_i, NULL, 0);
   HPmessage (HP_I_Usg_x, NULL, 0);
   HPmessage (HP_I_Usg_x_1, NULL, 0);
   HPmessage (HP_I_Usg_blank, NULL, 0);
   HPmessage (HP_I_Usg_help, NULL, 0);
   HPmessage (HP_I_Usg_v, NULL, 0);
   }

/*---HPdebug_options----------------------------------------*/

/*
NAME
   HPdebug_options

KEYWORDS
   HSplot
   debug
   options

DESCRIPTION
   Display information about the options you dont want the
   user to know about

HISTORY
   ??/??/?? M. Lanier
      Created
*/

static void HPdebug_options (void)

   {
   fprintf (stderr, "\n");
   fprintf (stderr, "  for debugging\n");
   fprintf (stderr, "    -6      Use 6 bytes per pixel\n");
   fprintf (stderr, "\n");
   }

/*---HPparse_double-------------------------------------------------------*/

/*
NAME
    HPparse_double

KEYWORDS
    HSplot

DESCRIPTION
    Convert a string into a double

PARAMETERS
    s :(IN) :  String to convert
    n :(IN) :  The length of the string
    d :(OUT):  The Parsed double to return

HISTORY
    ??/??/?? M. Lanier
       Created
*/

IGRint HPparse_double (IGRchar * s, IGRint n, IGRdouble * d)

   {
   IGRdouble a, b = 0.0;
   IGRboolean frac;
   IGRint i;

   frac = FALSE;
   a = 0.0;

   for (i = 0; i < n; i++)
      {
      if (s[i] == '.')
         {
         frac = TRUE;
         b = 0.1;
         }
      else
         {
         if (s[i] >= '0' && s[i] <= '9')
            {
            if (frac)
               {
               a = a + ((double) (s[i] - '0')) * b;
               b *= 0.1;
               }
            else
               {
               a = a * 10 + ((double) (s[i] - '0'));
               }
            }
         else
            {
            return (FALSE);
            }
         }
      }

   *d = a;

   return (TRUE);
   }

/*---HPread_header----------------------------------------------------------*/

/*
NAME
   HPread_header

KEYWORDS
   HSplot
   shaded plotfile

DESCRIPTION
   read the plotfile header, either from the named file or standard input.
   and store the data in the header structure

GLOBALS USED
   HPglobal : General HSplot global information
   HPcommand_line : Command line arguments

NOTES
   Here it is 06-11-97 and looking back over the code, I find I've forgotten
   most of what this data is used for.  So now is as good a time as any to 
   write it down.  

   user_line_width:  This only makes sence when your doing raster hidden line and
      are banding. (Look elsewhere for a description of banding, possibly in 
      hplot_func/HPbanding.c).  Let's see if I can make a simple explanation of a
      confusition situation.....

      When rasterizing a line with weight greater than 1 pixel, you want to 
      expand the width of that line out perpendicular to the line itself.  When
      that line is at the edge of the viewport, then part of that line will be
      chopped off as it expands over the boundaries of the viewport. If you have
      read the explanation of banding, you will realize that a band is simple a
      viewport that is a subset of the big viewport, which incompases the entire
      image. Anyway, if you have a weighted line that spans two bands, then 
      at the scanline at which the two bands meet, the weight line looks like
      something has taken a bite out of it.  The only solution was to force the
      bands to overlap, and the number of scanlines of overlap had to be half the
      width of the widest line. 

      HSplot needs to know what the overlap value is before it ever sees the 
      objects.  But, if it hasn't seen the objects yet, how does it know what that
      overlap value is.  We could have set that to 16, which is the max is could
      be, but if your widest line is only 3, then using 16 is overkill.  Therefore,
      the best solution was to have the Create Shaded Plot File command look at
      the data as it is writing it to the shaded plotfile, keep track of the
      widest line, and write that information into the header of the shaded
      plotfile.  Then, when HSplot reads the header of the shaded plotfile, it
      already knows the width of the widest line.

   shading_style: Remember in the above explanation of 'use_line_width', it said
      'when your doing raster hidden line'? Well, if we're not doing raster 
      hidden line, then the width of the widest line does not matter, an overlap
      of 1 works just fine.  So, if we're not doing raster hidden line, we
      just set the overlap value to 1 and don't worry about it.

   max_line_width: Another of those values that only applies when doing raster hidden
      line.  In the case of user_line_width, we're wanting to know the width of the
      widest line.  With this value, we're saying, "I don't care how wide the widest
      line is.  All lines, wider than this value are to assume this value"  This
      gives the user a little control over the banding operation and a possible 
      shot at a performance boost, however unlikely.

   line_width_constant: Here's one, whose original purpose is completly forgotten.
      It's value today is to give the user some control over what replication 
      factor is used in creating the raster image.  If the user has a particular
      replication factor in mind, then the following equation is used to compute
      the line_width_constant..

         line_width_constant = replication_factor / device_resolution.

      Usually, we just tell the user, if you want to best possible quality, then
      use a value of 0.0001 for the line_width_constant.  Yeah.. this is alot 
      smaller than it has to be, but it's easy for the user to understand.


HISTORY
   ??/??/?? M. Lanier
      Created
 */

int HPread_header (void)

   {
   IGRint sts;  /* return code from called functions */
   IGRchar rest[HEADER_FILLER]; /* buffer for rest of header */
   IGRchar junk[80];

   /*
    * Attempt to open the plotfile, if a name is given
    */

   if (HPcommand_line.plotfile != NULL)
      {
      HPglobal.pfl = fopen (HPcommand_line.plotfile, "r");

      if (!HPglobal.pfl)
         {
         HPmessage (HP_F_OpnInpFl, HPcommand_line.plotfile,
                    HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);
         return (HSplot_error);
         }
      }
   else
      {
      HPglobal.pfl = stdin;
      }

   /*
    * Get the file type from the header and make sure this is the correct one
    * for this textfile interpreter
    */

   sts = fread (HPheader.file_type, sizeof (IGRchar), 2, HPglobal.pfl);
   sts |= fread (&HPheader.version, sizeof (IGRshort), 1, HPglobal.pfl);
   sts |= fread (&HPheader.world_to_viewport_scale, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.save_plotfile, 2, 1, HPglobal.pfl);
   sts |= fread (&HPheader.save_rasterfile, 2, 1, HPglobal.pfl);
   sts |= fread (HPheader.input_textfile, sizeof (IGRchar), 80, HPglobal.pfl);
   sts |= fread (HPheader.rasterfile, sizeof (IGRchar), 80, HPglobal.pfl);
   sts |= fread (junk, sizeof (IGRchar), 80, HPglobal.pfl);
   sts |= fread (&HPheader.xsize, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.ysize, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.line_width_constant, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.max_line_width, sizeof (IGRshort), 1, HPglobal.pfl);
   sts |= fread (&HPheader.user_line_width, sizeof (IGRshort), 1, HPglobal.pfl);
   sts |= fread (&HPheader.shading_style, sizeof (IGRshort), 1, HPglobal.pfl);

   sts |= fread (&HPheader.size_x, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.size_y, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.plotter_resolution, sizeof (IGRdouble), 1, HPglobal.pfl);
   sts |= fread (&HPheader.raster_type, sizeof (IGRint), 1, HPglobal.pfl);
   sts |= fread (&HPheader.queue, sizeof (IGRchar), 32, HPglobal.pfl);
   sts |= fread (&HPheader.date, sizeof (IGRchar), 32, HPglobal.pfl);

   sts |= fread (&HPheader.save_textfile, 2, 1, HPglobal.pfl);
   sts |= fread (&HPheader.create_textfile, 2, 1, HPglobal.pfl);
   sts |= fread (&HPheader.white_background, 2, 1, HPglobal.pfl);
   sts |= fread (&HPheader.black_and_white_edges, 2, 1, HPglobal.pfl);
   sts |= fread (&HPheader.exclude_wireframe, 2, 1, HPglobal.pfl);

   sts |= fread (rest, sizeof (IGRchar), HEADER_FILLER, HPglobal.pfl);

#  ifdef BIG_ENDIAN
   HSconv_short (&HPheader.version, 1);
   HSconv_double (&HPheader.world_to_viewport_scale, 1);
   HSconv_double (&HPheader.xsize, 1);
   HSconv_double (&HPheader.ysize, 1);
   HSconv_double (&HPheader.line_width_constant, 1);
   HSconv_short (&HPheader.max_line_width, 1);
   HSconv_short (&HPheader.user_line_width, 1);
   HSconv_short (&HPheader.shading_style, 1);
   HSconv_double(&HPheader.size_x, 1);
   HSconv_double(&HPheader.size_y, 1);
   HSconv_double(&HPheader.plotter_resolution, 1);
   HSconv_int   (&HPheader.raster_type, 1);
   HSconv_short (&HPheader.save_plotfile, 1);
   HSconv_short (&HPheader.save_rasterfile, 1);
   HSconv_short (&HPheader.save_textfile, 1);
   HSconv_short (&HPheader.create_textfile, 1);
   HSconv_short (&HPheader.white_background, 1);
   HSconv_short (&HPheader.black_and_white_edges, 1);
   HSconv_short (&HPheader.exclude_wireframe, 1);
#  endif

   if (sts <= 0)
      return HP_F_HdrReadErr;

   if (HPheader.file_type[0] != 'H' ||
       HPheader.file_type[1] != 'S')
      return HP_F_HdrBadEle;

   if (HPheader.version < 0x1400)
      {
      HPheader.line_width_constant = HP_DEFAULT_LINE_WIDTH_CONSTANT;
      HPheader.max_line_width = HP_DEFAULT_MAX_LINE_WIDTH;
      HPheader.user_line_width = HP_DEFAULT_USER_LINE_WIDTH;
      HPheader.shading_style = 3;
      }

   if( HPheader.version < 0x3400 )
      {
      HPheader.plotter_resolution = 100.0;
      HPheader.size_x = 1.0;
      HPheader.size_y = 1.0;
      HPheader.raster_type = HPrasterfile_type_25;
      HPheader.queue[0] = 0;
      HPheader.date[0] = 0;
      HPheader.save_textfile = 0;
      HPheader.create_textfile = 0;
      HPheader.white_background = 0;
      HPheader.black_and_white_edges = 0;
      }

#  if DEBUG
   fprintf (stderr, "\nHPheader\n");
   fprintf (stderr, "   file_type --------------- %s\n", HPheader.file_type);
   fprintf (stderr, "   version ----------------- %4x\n", HPheader.version);
   fprintf (stderr, "   world_to_viewport_scale - %f\n", 
      HPheader.world_to_viewport_scale);
   fprintf (stderr, "   save_plotfile ----------- %d\n", HPheader.save_plotfile);
   fprintf (stderr, "   save_rasterfile --------- %d\n", HPheader.save_rasterfile);
   fprintf (stderr, "   save_textfile ----------- %d\n", HPheader.save_textfile);
   fprintf (stderr, "   create_textfile --------- %d\n", HPheader.create_textfile);
   fprintf (stderr, "   white_background -------- %d\n", HPheader.white_background);
   fprintf (stderr, "   black_and_white_edges --- %d\n", HPheader.black_and_white_edges);
   fprintf (stderr, "   exclude_wireframe ------- %d\n", HPheader.exclude_wireframe);
   fprintf (stderr, "   rasterfile -------------- %s\n", HPheader.rasterfile);
   fprintf (stderr, "   input_textfile ---------- %s\n", HPheader.input_textfile);
   fprintf (stderr, "   xsize, ysize ------------ %f %f\n", 
      HPheader.xsize, HPheader.ysize);
   fprintf (stderr, "   line_width_constant ----- %f\n", HPheader.line_width_constant);
   fprintf (stderr, "   max_line_width ---------- %d\n", HPheader.max_line_width);
   fprintf (stderr, "   user_line_width --------- %d\n", HPheader.user_line_width);
   fprintf (stderr, "   shading_style ----------- %d\n", HPheader.shading_style);
   fprintf (stderr, "   size_x, size_y ---------- %f %f\n", 
      HPheader.size_x, HPheader.size_y);
   fprintf (stderr, "   plotter_resolution ------ %f\n", HPheader.plotter_resolution);

   fprintf (stderr, "   raster_type ------------- " );
   switch( HPheader.raster_type )
      {
      case HPrasterfile_type_25:   fprintf( stderr, "25\n"   ); break;
      case HPrasterfile_type_27:   fprintf( stderr, "27\n"   ); break;
      case HPrasterfile_type_PS:   fprintf( stderr, "PS\n"   ); break;
      default:                     fprintf( stderr, "Unsupported\n" ); break;
      }

   fprintf (stderr, "   queue ------------------- %s\n", HPheader.queue);
   fprintf (stderr, "   date -------------------- %s\n", HPheader.date);
#  endif

   return (HSplot_success);
   }

/*---HPread_device------------------------------------------------*/

/*
NAME
   HPread_device

KEYWORDS
   HSplot
   device

DESCRIPTION
   Get attributes from the output device.

GLOBALS USED
   HPcommand_line : command line arguments
   HPdevice : information retrieved from the device

HISTORY
   ??/??/?? M. Lanier
      Created
*/

int HPread_device (void)

   {
   int status;
   char      *expr, *getenv ();

   /* Initialize the device resolution to 0, that way if its other */
   /* than this when we set the global variables, then we'll know */
   /* to use this rather than the value in the header */

   HPdevice.resolution = 0.0;

#  if defined (CLIX)
   if( HPcommand_line.resolution < 0 &&
      (HPcommand_line.device_driver != NULL || getenv( "DRIVER" ) != NULL) )
      {
#     ifndef X11
      Enter_tools_no_act ();
#     endif

      status = ODEnter (0);
      if_bad (status)
         {
         HPmessage (HP_F_ODEntr, NULL,
                    HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);
         return (HSplot_error);
         }

      status = ODOpenWorkstation ( HPcommand_line.device_driver,
                                   HPcommand_line.device_port,
                                   &HPdevice.ws_no);
      if_bad (status)
         {
         HPmessage (HP_F_ODOpnWrkSttn, NULL,
                    HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);
         return (HSplot_error);
         }

      /*
       * Get info about the workstation
       */

      status = ODInqWsInfo ( HPdevice.ws_no,
                             &HPdevice.ws_info);
      if_bad (status)
         {
         HPmessage (HP_F_ODInqWsInf, NULL,
                    HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);
         return (HSplot_error);
         }

      HPdevice.ws_info.XRes /= 39.37;
      HPdevice.ws_info.YRes /= 39.37;
      HPdevice.ws_info.ApparentXRes /= 39.37;
      HPdevice.ws_info.ApparentYRes /= 39.37;

      HPdevice.resolution =
         (HPdevice.ws_info.XRes <= HPdevice.ws_info.YRes) ? 
          HPdevice.ws_info.XRes : HPdevice.ws_info.YRes;

#     if DEBUG
      fprintf (stderr, "\nHPdevice\n");
      fprintf (stderr, "   ws_info\n");
      fprintf (stderr, "      XRes, YRes ---------- %f %f\n",
               HPdevice.ws_info.XRes, HPdevice.ws_info.YRes);
      fprintf (stderr, "      ApparentXRes, YRes -- %f %f\n",
               HPdevice.ws_info.ApparentXRes, HPdevice.ws_info.ApparentYRes);
      fprintf (stderr, "      XSize, YSize -------- %f %f\n",
               ((double) HPdevice.ws_info.XSize) / HPdevice.resolution,
               ((double) HPdevice.ws_info.YSize) / HPdevice.resolution);
      fprintf (stderr, "      flags\n");
      fprintf (stderr, "         ODM_NO_RASTER ---- %d\n", 
         HPdevice.ws_info.Flags & ODM_NO_RASTER);
      fprintf (stderr, "         ODM_NO_POLYFILL -- %d\n", 
         HPdevice.ws_info.Flags & ODM_NO_POLYFILL);
      fprintf (stderr, "         ODM_NO_COLOR ----- %d\n", 
         HPdevice.ws_info.Flags & ODM_NO_COLOR);
      fprintf (stderr, "         ODM_BITMAP_TEXT -- %d\n", 
         HPdevice.ws_info.Flags & ODM_BITMAP_TEXT);
      fprintf (stderr, "         ODM_LANDSCAPE ---- %d\n", 
         HPdevice.ws_info.Flags & ODM_LANDSCAPE);
      fprintf (stderr, "         ODM_WHITE_WRITER - %d\n", 
         HPdevice.ws_info.Flags & ODM_WHITE_WRITER);
      fprintf (stderr, "   resolution ------------- %f\n", HPdevice.resolution);
#     endif
      }
#  endif        /* CLIX */

   return (HSplot_success);
   }

/*---HPread_env_vars------------------------------------------------*/

/*
NAME
   HPread_env_vars

KEYWORDS
   HSplot
   environment variables

DESCRIPTION
   Read the environment variables

GLOBALS USED
   HPenv_var : environment variable information

HISTORY
   ??/??/?? M. Lanier
      Created
*/

int HPread_env_vars (void)

   {
   char *expr, *getenv ();
   double dtmp;
   int itmp, debug;

   HPenv_var.debug = 0;
   HPenv_var.line_width_constant = -1;
   HPenv_var.max_line_width = -1;
   HPenv_var.input_textfile = NULL;
   HPenv_var.dont_plot = 0;

   expr = NULL;
   expr = getenv ("TEXTFILE");

   if (expr != NULL)
      if (strlen (expr) > 0)
         {
         HPenv_var.input_textfile = (IGRchar *) malloc (strlen (expr) + 1);
         strcpy (HPenv_var.input_textfile, expr);
         }

   expr = getenv ("HSplot_DEBUG");
   if (expr != NULL)
      {
      sscanf (expr, "%d", &debug);

      HPenv_var.debug = debug;
      }

   dtmp = 0.0;
   expr = getenv ("HSplot_LINE_WIDTH_CONSTANT");
   if (expr != NULL)
      sscanf (expr, "%lf", &dtmp);

   if (dtmp > 0.0)
      HPenv_var.line_width_constant = dtmp;

   itmp = 0;
   expr = getenv ("HSplot_MAX_LINE_WIDTH");
   if (expr != NULL)
      sscanf (expr, "%d", &itmp);

   if (itmp > 0.0)
      HPenv_var.max_line_width = itmp;

   itmp = 0;
   expr = getenv ("HSplot_DONT_PLOT");
   if (expr != NULL)
      sscanf (expr, "%d", &itmp);

   if (itmp > 0)
      HPenv_var.dont_plot = itmp;

#  if DEBUG
   fprintf (stderr, "\nHPenv_vars\n");
   fprintf (stderr, "   debug ------------------- %d\n", HPenv_var.debug);

   fprintf (stderr, "   line_width_constant ----- %f\n", HPenv_var.line_width_constant);
   fprintf (stderr, "   max_line_width ---------- %d\n", HPenv_var.max_line_width);
   if (HPenv_var.input_textfile != NULL)
      fprintf (stderr, "   input_textfile ---------------- %s\n", 
         HPenv_var.input_textfile);
   fprintf (stderr, "   dont_plot --------------- %d\n", HPenv_var.dont_plot);
#  endif

   return (HSplot_success);
   }

/*---HPset_globals------------------------------------------------*/

/*
NAME
   HPset_globals

KEYWORDS
   HSplot

DESCRIPTION
   Having read information from the command line, plotfile header and
   environment variables, decide which to use in producing the plot

GLOBALS USED
   HPcommand_line : the command line variables
   HPenv_var : environment variable information
   HPglobal : general global information

HISTORY
   ??/??/?? M. Lanier
      Created
   11/12/95        M. Lanier
      Modified to support 7 bytes/pixel mode (phong lights)
*/

int HPset_globals (void)

   {

   /*
    *  The resolution comes from three places: the plotfile header, the
    *  command line and the device. The value from the command line take
    *  presidence over all.  If that is not specified (variable contains
    *  a value equal to 0.0) then use the value from the device.  If that
    *  is not specified, then use the value from the plotfile header.
    */ 

   if( HPcommand_line.resolution > 0.0 )
      HPglobal.resolution = HPcommand_line.resolution;

   else
   if( HPdevice.resolution > 0.0 )
      HPglobal.resolution = HPdevice.resolution;

   else
      HPglobal.resolution = HPheader.plotter_resolution;

   /*
    *  plot size set at the command line overrides what is in the
    *  header
    */

   if( HPcommand_line.size_x != 0.0 )
      {
      HPglobal.size_x = HPcommand_line.size_x;
      HPglobal.size_y = HPcommand_line.size_y;
      }

   else
      {
      HPglobal.size_x = HPheader.size_x;
      HPglobal.size_y = HPheader.size_y;
      }

   /*
    *  the rasterfile type set at the command line overrides that what
    *  is in the plotfile header 
    */

   if( HPcommand_line.rasterfile_type != HPrasterfile_type_Undefined )
      HPglobal.rasterfile_type = HPcommand_line.rasterfile_type;
   else
      HPglobal.rasterfile_type = HPheader.raster_type;

   /*
    *  The line_width_constant input on the command line takes precedence over
    *  all.  The line_width_constant input thru an environment variable takes
    *  prescedence over that in the header
    */

   if (HPcommand_line.line_width_constant > 0.0)
      HPglobal.line_width_constant = HPcommand_line.line_width_constant;

   else 
   if (HPenv_var.line_width_constant > 0.0)
      HPglobal.line_width_constant = HPenv_var.line_width_constant;

   else
      HPglobal.line_width_constant = HPheader.line_width_constant;

   /*
    *  the command line input for max line width takes precendence over all
    *  the environment variable input preceeds next, and the header value
    *  is used else
    */

   if (HPcommand_line.max_line_width > 0.0)
      HPglobal.max_line_width = HPcommand_line.max_line_width;

   else 
   if (HPenv_var.max_line_width > 0.0)
      HPglobal.max_line_width = HPenv_var.max_line_width;

   else
      HPglobal.max_line_width = HPheader.max_line_width;

   /*
    *  The command line variable for white_background, defaults to TRUE.
    *  if selected from the command line, it will be FALSE, nothing else.
    *  Therefore, the global variable for white_background will be FALSE
    *  if the command line variable is FALSE, and the header value if
    *  the command line variable is TRUE
    */

   if( HPcommand_line.white_background )
      HPglobal.white_background = HPheader.white_background;
   else
      HPglobal.white_background = !HPheader.white_background;
      /*HPglobal.white_background = FALSE;*/

   /*
    *  If the -b option is not on the command line, then use the header
    *  value, if the -b option is on the command line, then toggle the
    *  header value.
    */

   if( HPcommand_line.black_and_white_edges )
      HPglobal.black_and_white_edges = !HPheader.black_and_white_edges;
   else
      HPglobal.black_and_white_edges = HPheader.black_and_white_edges;


   /*
    * If there was a rasterfile on the command line, use it instead of the
    * header name
    */

   if (HPcommand_line.rasterfile != NULL)
      {
      strcpy (HPglobal.rasterfile, HPcommand_line.rasterfile);
      HPheader.save_rasterfile = 1;
      }

   else
      strcpy (HPglobal.rasterfile, HPheader.rasterfile);

   /*
    * Make sure the line width constant is a valid number.  Appended .001 to
    * the resolution constant so as to include resolutions that are very
    * slightly greater than the constant.
    */

   if (HPglobal.resolution <= 100.001 && HPglobal.line_width_constant < 0.01)
      HPglobal.line_width_constant = 0.01;

   else 
   if (HPglobal.resolution <= 200.001 && HPglobal.line_width_constant < 0.005)
      HPglobal.line_width_constant = 0.005;

   else 
   if (HPglobal.resolution <= 300.001 && HPglobal.line_width_constant < 0.003333)
      HPglobal.line_width_constant = 0.003333;

   else 
   if (HPglobal.line_width_constant < 0.0025)
      HPglobal.line_width_constant = 0.0025;

   /* copy the replication factor from the command line structure */

   HPglobal.replication_factor = HPcommand_line.replication_factor;
   
   /*
    * set copies
    */

   HPglobal.copies = HPcommand_line.copies;

   /*
    * set the overlap and bytes_per_pixel.  Shading style of 1 means that
    * everything was smooth, constant or area fill.  Shading style of 2 means
    * everything was raster or reverse edges.
    */

   if (HPheader.shading_style == 1)
      {
      HPglobal.overlap = 1;

      /*
       * When in shading mode, we can have either 6 bytes per pixel (gouraud)
       * or 7 bytes per pixel (phong).   (MLanier 11/12/95)
       */

      if (HPcommand_line.bytes_per_pixel == 7)
         HPglobal.bytes_per_pixel = 7;
      else
         HPglobal.bytes_per_pixel = 6;
      }
   else
      {
      HPglobal.overlap = ((HPheader.user_line_width + 1) >> 1) + 2;

      if (HPheader.shading_style == 2 && (HPcommand_line.bytes_per_pixel == 5))
         HPglobal.bytes_per_pixel = 5;
      else
         HPglobal.bytes_per_pixel = 6;
      }

   /*
    *  the textfile name can come from three sources, command line, environment
    *  variable and header. In the case of the header, the string will always
    *  have something, but the flag, "create_textfile" will tell weather to use
    *  it or not.
    */

   if (HPcommand_line.input_textfile != NULL)
      {
      HPglobal.input_textfile = HPcommand_line.input_textfile;
      if (HPenv_var.input_textfile != NULL)
         free (HPenv_var.input_textfile);
      }

   else
   if (HPenv_var.input_textfile != NULL)
      HPglobal.input_textfile = HPenv_var.input_textfile;

   else
   if (HPheader.create_textfile)
      HPglobal.input_textfile = HPheader.input_textfile;

   else
      HPglobal.input_textfile = NULL;

   HPglobal.output_textfile = HPcommand_line.output_textfile;

   /*
    *  Now that we've set the input and output textfile names, check the
    *  rasterfile format and if it is PS and shaded plots with  
    *  text is active, then display a message and disable the feature
    */

   if( HPglobal.input_textfile != NULL )
      {
      if( HPglobal.rasterfile_type == HPrasterfile_type_PS )
         {
         HPmessage (HP_I_ShPlTxPs, NULL, HPmessage_PREFIX_PRODNAME);
         HPmessage (HP_I_ShPlTxDsbl, NULL, HPmessage_PREFIX_PRODNAME);

         HPglobal.input_textfile = NULL;
         }
      }

   /*
    *  The queue name on the command line overrides that in the header
    */

   if( HPcommand_line.queue != NULL )
      HPglobal.queue = HPcommand_line.queue;
   else
      HPglobal.queue = HPheader.queue;

   if( HPenv_var.dont_plot )
      HPglobal.dont_plot = (HPcommand_line.dont_plot) ? FALSE : TRUE;
   else
      HPglobal.dont_plot = HPcommand_line.dont_plot;


   /*
    *  If the exclude_wireframe is set in the header, and not on the
    *  command line, set it in the global flags.  If the exclude_wireframe
    *  is not set in the header, but is on the command line, then set it
    *  in the global flags.
    */

   if( HPheader.exclude_wireframe )
      {
      if( !(HPcommand_line.flags & HPflag_Exclude_Wireframe) )
         HPglobal.flags |= HPflag_Exclude_Wireframe;
      }
   else
      {
      if( (HPcommand_line.flags & HPflag_Exclude_Wireframe) )
         HPglobal.flags |= HPflag_Exclude_Wireframe;
      }


   /*
    * Set some globals that would otherwise cause problems it they some vile
    * value
    */

   HPglobal.tiling_tolerance = HPcommand_line.tiling_tolerance;

   HPglobal.elem_finish = 11;
   HPglobal.elem_spec_refl = 0.5;
   HPglobal.elem_diff_refl = 1.0;
   HPglobal.elem_transparency = 0.0;
   HPglobal.elem_opacity = 1.0 - HPglobal.elem_transparency;

#  if DEBUG
   fprintf (stderr, "\nHPglobal\n");
   fprintf (stderr, "   resolution ---------------- %f\n", HPglobal.resolution);
   fprintf (stderr, "   size_x, size_y ------------ %f %f\n", 
      HPglobal.size_x, HPglobal.size_y);
   fprintf( stderr, "   white_background ---------- %d\n", HPglobal.white_background );
   fprintf( stderr, "   black_and_white_edges ----- %d\n", 
      HPglobal.black_and_white_edges );
   fprintf (stderr, "   line_width_constant ------- %f\n", HPglobal.line_width_constant);
   fprintf (stderr, "   max_line_width ------------ %d\n", HPglobal.max_line_width);
   fprintf (stderr, "   rasterfile ---------------- %s\n", HPglobal.rasterfile);

   fprintf (stderr, "   rasterfile_type ----------- " );
   switch( HPglobal.rasterfile_type )
      {
      case HPrasterfile_type_25:   fprintf( stderr, "25\n"   ); break;
      case HPrasterfile_type_27:   fprintf( stderr, "27\n"   ); break;
      case HPrasterfile_type_PS:   fprintf( stderr, "PS\n"   ); break;
      default:                     fprintf( stderr, "Unsupported\n" ); break;
      }

   fprintf (stderr, "   overlap ------------------- %d\n", HPglobal.overlap);
   fprintf (stderr, "   bytes_per_pixel ----------- %d\n", HPglobal.bytes_per_pixel);
   if (HPglobal.input_textfile != NULL)
      fprintf (stderr, "   input_textfile ------------ %s\n", 
         HPglobal.input_textfile);
   fprintf( stderr, "   queue --------------------- %s\n", HPglobal.queue );
   fprintf (stderr, "   copies -------------------- %d\n", HPglobal.copies);
   fprintf (stderr, "   anti_aliasing ------------- %d\n", HPglobal.anti_aliasing );
   fprintf (stderr, "   dont_plot ----------------- %d\n", HPglobal.dont_plot );
   fprintf (stderr, "   debug --------------------- %d\n\n\n", HPenv_var.debug);
#  endif

   return (HSplot_success);
   }

/*---HPbuild_ignore_list--------------------------------------------*/

/*
Description:
   This is a list of objid:osnum that identify objects in the plotfile
   to ignore.

History
   5/15/96 Created  Mike Lanier
*/

static void HPbuild_ignore_list (char *list)
   {
   int i, j, n, m, o;
   struct HPignore_list *l;

   /*
    * The 'list' string is of the format <objid>:<osnum>[, <objid>:<osnum>]
    * the objid and osnum are separated by a colon ":" and, if there are more
    * than one objid:osnum pairs, then they are separated by a comma ","
    */

   /*
    * First, remove all embeded blanks
    */

   n = strlen (list);
   for (i = 0, j = 0; i < n; i++)
      if (list[i] != ' ')
         list[j++] = list[i];

   list[n = j] = 0;

   for (m = 0, i = 0; i < n; i++)
      {
      if (list[i] == ':')
         {
         o = m;
         m = 0;
         }

      else if (list[i] == ',')
         {
         l = (struct HPignore_list *) malloc (sizeof (struct HPignore_list));
         l->objid = o;
         l->osnum = m;
         l->next = HPglobal.ignore_list;
         HPglobal.ignore_list = l;

         m = 0;
         }

      else
         {
         m = m * 10 + (int) (list[i] - '0');
         }
      }

   l = (struct HPignore_list *) malloc (sizeof (struct HPignore_list));
   l->objid = o;
   l->osnum = m;
   l->next = HPglobal.ignore_list;
   HPglobal.ignore_list = l;

   } /* HPbuild_ignore_list */

/*---HPparse_plotsize--------------------------------------------------*/

/*
NAME
   HPparse_plotsize

DESCRIPTION
   This function is used, in the case where the user has used the -s
   option to select on of the standard plot sizes, ansi or iso.  This
   function parses the string for the plotsize symbol, 'A', 'B', etc.
   and assigned the appropriate value to the x_size, y_size variables
   in the command line structure

NOTE
   Standard Plotsizes

      ansi                 iso
      -------------------+-----------------------
      A-size: 11x8.5 in  | A0: 118.9x84.1 cm
      B-size: 17x11 in   | A1: 84.1x59.4 cm
      C-size: 22x17 in   | A2: 59.4x42.0 cm
      D-size: 34x22 in   | A3: 42.0x29.7 cm
      E-size: 44x34 in   | A4: 29.7x21.0 cm

HISTORY
   06/12/97 M. Lanier
      Created

*/

#define   A   0
#define   B   1
#define   C   2
#define   D   3
#define   E   4

#define   A0  0
#define   A1  1
#define   A2  2
#define   A3  3
#define   A4  4

#define   CMtoIN  0.3937

static double   AnsiPlotsizes[5][2] = { { 11.0,  8.5 },
                                        { 17.0, 11.0 },
                                        { 22.0, 17.0 },
                                        { 34.0, 22.0 },
                                        { 44.0, 34.0 } };
                                        

static double   IsoPlotsizes[5][2] = { { 118.0, 84.1 },
                                       {  84.1, 59.4 },
                                       {  59.4, 42.0 },
                                       {  42.0, 29.7 },
                                       {  29.7, 21.0 } };

static int  HPparse_plotsize( char *optarg )
   {
   switch( optarg[0] )
      {
      case 'A':
         if( strlen(optarg) > 1 )
            {

            /*
             *  The iso sizes are in centimenters, multiply by
             *  CMtoIN to convert to inches
             */

            switch( optarg[1] )
               {
               case '0':
                  HPcommand_line.size_x = IsoPlotsizes[A0][0] * CMtoIN;
                  HPcommand_line.size_y = IsoPlotsizes[A0][1] * CMtoIN;
                  return TRUE;

               case '1':
                  HPcommand_line.size_x = IsoPlotsizes[A1][0] * CMtoIN;
                  HPcommand_line.size_y = IsoPlotsizes[A1][1] * CMtoIN;
                  return TRUE;

               case '2':
                  HPcommand_line.size_x = IsoPlotsizes[A2][0] * CMtoIN;
                  HPcommand_line.size_y = IsoPlotsizes[A2][1] * CMtoIN;
                  return TRUE;

               case '3':
                  HPcommand_line.size_x = IsoPlotsizes[A3][0] * CMtoIN;
                  HPcommand_line.size_y = IsoPlotsizes[A3][1] * CMtoIN;
                  return TRUE;

               case '4':
                  HPcommand_line.size_x = IsoPlotsizes[A4][0] * CMtoIN;
                  HPcommand_line.size_y = IsoPlotsizes[A4][1] * CMtoIN;
                  return TRUE;
               }
            }
         else
            {
            HPcommand_line.size_x = AnsiPlotsizes[A][0];
            HPcommand_line.size_y = AnsiPlotsizes[A][1];
            return TRUE;
            }

         return FALSE;

      case 'B':
         HPcommand_line.size_x = AnsiPlotsizes[B][0];
         HPcommand_line.size_y = AnsiPlotsizes[B][1];
         return TRUE;

      case 'C':
         HPcommand_line.size_x = AnsiPlotsizes[C][0];
         HPcommand_line.size_y = AnsiPlotsizes[C][1];
         return TRUE;

      case 'D':
         HPcommand_line.size_x = AnsiPlotsizes[D][0];
         HPcommand_line.size_y = AnsiPlotsizes[D][1];
         return TRUE;

      case 'E':
         HPcommand_line.size_x = AnsiPlotsizes[E][0];
         HPcommand_line.size_y = AnsiPlotsizes[E][1];
         return TRUE;
      }   

   /* If you get here, the function could not translate the string */
   /* return an error */

   return FALSE;

   } /* HPparse_plotsize */


/*---HPparse_units--------------------------------------------------------*/

static int	HPparse_units( char *s )

   {

   /*
    *  Set the selected units flag to 0, so that later on we'll know that
    *  we have an error.
    */

   HSplot_SelectedUnits = -1;

   /* If the string has less than 1 character then return an error */

   if( strlen(s) < 1 ) return 0;

   /*
    *  If the string is exactly 1 character and equal to 'm' then set the
    *  selected units to meters
    */

   if( strlen(s) == 1 && s[0] == 'm' )
      {
      HSplot_SelectedUnits = HSplot_UNIT_M;
      return 1;
      }

   /*
    *  It the string has more than 2 characters then return an error
    */

   if( strlen(s) != 2 ) return 0;

   /*  Check for selection of inches */

   if( s[0] == 'i' && s[1] == 'n' )
      {
      HSplot_SelectedUnits = HSplot_UNIT_IN;
      return 1;
      }

   /*  Check for selection of feet */

   if( s[0] == 'f' && s[1] == 't' )
      {
      HSplot_SelectedUnits = HSplot_UNIT_FT;
      return 1;
      }

   /*  Check for selection of millimeters */

   if( s[0] == 'm' && s[1] == 'm' )
      {
      HSplot_SelectedUnits = HSplot_UNIT_MM;
      return 1;
      }

   /*  Check for selection of centimeters */

   if( s[0] == 'c' && s[1] == 'm' )
      {
      HSplot_SelectedUnits = HSplot_UNIT_CM;
      return 1;
      }

   /*  Noting valid found, return an error */

   return 0;

   } /* HSparse_units */


/*---HPconvert_to_inches----------------------------------------------*/

static void HPconvert_to_inches()

   {
   HPcommand_line.resolution *= HSplot_ConversionTable[HSplot_SelectedUnits];
   HPcommand_line.size_x *= HSplot_ConversionTable[HSplot_SelectedUnits];
   HPcommand_line.size_y *= HSplot_ConversionTable[HSplot_SelectedUnits];

   } /* HPconvert_to_inches */
