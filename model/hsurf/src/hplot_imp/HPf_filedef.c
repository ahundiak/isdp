
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <FI.h>
#include <sys/types.h>
#include "wl.h"

#if defined X11
#include <dirent.h>
#else
#include <sys/dirent.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "hsdef.h"
#include "HSplot.h"
#include "HSplot_def.h"

#include "HSpr_hplot.h"

#define	DEBUG	0

static IGRchar *Plotfile = "Plotfile";
static IGRchar *Textfile = "Textfile";
static IGRchar *Rasterfile = "Rasterfile";
static IGRchar *Queue = "Queue";
static IGRchar *Size = "Size";
static IGRchar *Scale = "Scale";
static IGRchar *Copies = "Copies";
static IGRchar *Date = "Date";
static IGRchar *Mail_Begin = "Mail at Begin";
static IGRchar *Mail_End = "Mail at End";
static IGRchar *Save_Plotfile = "Save Plotfile";
static IGRchar *Save_Rasterfile = "Save Rasterfile";
static IGRchar *Save_Textfile = "Save Textfile";
static IGRchar *Window_Contents = "Window Contents";
static IGRchar *Fence_Contents = "Fence Contents";
static IGRchar *White_Background = "White Background";
static IGRchar *Exclude_Wireframe = "Exclude Wireframe";
static IGRchar *Create_Textfile = "Create Textfile";
static IGRchar *Black_and_White = "Black and White";
static IGRchar *Line_Width_Constant = "Line Width Constant";
static IGRchar *Max_Line_Width = "Max Line Width";
static IGRchar *Raster_Type = "Raster Type";
static IGRchar *BG_Color = "BG_Color";
static IGRchar *Edge_Color = "Edge_Color";
static IGRchar *Old_File = "Old Design File";

/*---DUMP_DEFAULTS-------------------------------------------------------*/

/*
NAME
        DUMP_DEFAULTS: macro
        
KEYWORDS
        shaded plotting
        
DESCRIPTION
        Display the values read from, or being written to the
        shaded plotting default file.

HISTORY
        ??/??/??	M. Lanier
                Created
*/

#define	DUMP_DEFAULTS							\
	{								\
	fprintf( stderr, "\nDEFAULTS\n" );				\
	if( plotfile )							\
		fprintf( stderr, "%s:%s:\n", Plotfile, plotfile );	\
									\
	if( rasterfile )						\
		fprintf( stderr, "%s:%s:\n", Rasterfile, rasterfile );	\
									\
	if( textfile )							\
		fprintf( stderr, "%s:%s:\n", Textfile, textfile );	\
									\
	if( queue )							\
		fprintf( stderr, "%s:%s:\n", Queue, queue );		\
									\
	if( size_x && size_y && *dpb_flags & HS_PLOT_PLOT_BY_SIZE)	\
		fprintf( stderr, "%s:%f %f:\n", 			\
			Size, *size_x, *size_y );			\
									\
	if( scale && !(*dpb_flags & HS_PLOT_PLOT_BY_SIZE) )		\
		fprintf( stderr, "%s:%f:\n", Scale, *scale );		\
									\
	if( copies )							\
		fprintf( stderr, "%s:%d:\n", Copies, *copies );		\
									\
	if( date )							\
		fprintf( stderr, "%s:%s:\n", Date, date );		\
									\
	if( line_width_constant )					\
		fprintf( stderr, "%s:%lf:\n", 				\
			Line_Width_Constant, *line_width_constant );	\
									\
	if( max_line_width )						\
		fprintf( stderr, "%s:%1d:\n", 				\
			Max_Line_Width, *max_line_width );		\
									\
	if( raster_type )						\
		fprintf( stderr, "%s:%1d:\n", 				\
			Raster_Type, *raster_type );			\
									\
	if( *dpb_flags & HS_PLOT_SAVE_PLOTFILE )			\
		fprintf( stderr, "%s::\n", Save_Plotfile );		\
									\
	if( *dpb_flags & HS_PLOT_SAVE_RASTERFILE )			\
		fprintf( stderr, "%s::\n", Save_Rasterfile );		\
									\
	if( *dpb_flags & HS_PLOT_SAVE_TEXTFILE )			\
		fprintf( stderr, "%s::\n", Save_Textfile );		\
									\
	if( *dpb_flags & HS_PLOT_WINDOW_CONTENTS )			\
		fprintf( stderr, "%s::\n", Window_Contents );		\
	else								\
		fprintf( stderr, "%s::\n", Fence_Contents );		\
									\
	if( *dpb_flags & HS_PLOT_MAIL_AT_BEGIN )			\
		fprintf( stderr, "%s::\n", Mail_Begin );		\
									\
	if( *dpb_flags & HS_PLOT_MAIL_AT_END )				\
		fprintf( stderr, "%s::\n", Mail_End );			\
									\
	if( *dpb_flags & HS_PLOT_BG_COLOR )				\
		fprintf( stderr, "%s::\n", BG_Color );			\
									\
	if( *dpb_flags & HS_PLOT_EDGE_COLOR )				\
		fprintf( stderr, "%s::\n", Edge_Color );		\
									\
	if( *dpb_flags & HS_PLOT_BLACK_AND_WHITE )			\
		fprintf( stderr, "%s::\n", Black_and_White );		\
									\
	if( *dpb_flags & HS_PLOT_WHITE_BACKGROUND )			\
		fprintf( stderr, "%s::\n", White_Background );		\
									\
	if( *dpb_flags & HS_PLOT_EXCLUDE_WIREFRAME )			\
		fprintf( stderr, "%s::\n", Exclude_Wireframe );		\
									\
	if( *dpb_flags & HS_PLOT_CREATE_TEXTFILE )			\
		fprintf( stderr, "%s::\n", Create_Textfile );		\
	}

/*---HPfiledef---------------------------------------------*/

/*
NAME
        HPfiledef
        
KEYWORDS
        shaded plotting
        default file
        
DESCRIPTION
        Read defaults from, or write defaults to the shaded plotting
        defaults file.
        
PARAMETERS
        read_flag		:(IN)    :  Mode flag, reading or writing
        plotfile		:(IN/OUT):  pointer to the shaded plotfile name
        rasterfile		:(IN/OUT):  pointer to the rasterfile name
        textfile		:(IN/OUT):  pointer to the textfile name
        queue			:(IN/OUT):  pointer to the active queue name
        date			:(IN/OUT):  pointer to the date parameter
        size_x, size_y		:(IN/OUT):  pointer to the current plot size
        scale			:(IN/OUT):  pointer to the current plot scale
        copies			:(IN/OUT):  pointer to the number of copies parameter
        line_width_constant	:(IN/OUT):  pointer to the line width constant parameter
        max_line_width		:(IN/OUT):  pointer to the max line width parameter
        raster_type		:(IN/OUT):  pointer to the raster type flag
        dpb_flags		:(IN/OUT):  pointer to the dpb flags mask work

GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        get_modtype_data
        sprintf
        fopen
        fgets
        strlen
        strcmp
        sscanf
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
IGRint HPfiledef (IGRint read_flag,
                         IGRchar * plotfile,
                         IGRchar * rasterfile,
                         IGRchar * textfile,
                         IGRchar * queue,
                         IGRchar * date,
                         IGRdouble * size_x,
                         IGRdouble * size_y,
                         IGRdouble * scale,
                         IGRint * copies,
                         IGRdouble * line_width_constant,
                         IGRint * max_line_width,
                         IGRint * raster_type,
                         IGRint * dpb_flags)
#else
IGRint HPfiledef (read_flag,
                         plotfile,
                         rasterfile,
                         textfile,
                         queue,
                         date,
                         size_x, size_y,
                         scale,
                         copies,
                         line_width_constant,
                         max_line_width,
                         raster_type,
                         dpb_flags)

   IGRint read_flag;
   IGRchar *plotfile;
   IGRchar *rasterfile;
   IGRchar *textfile;
   IGRchar *queue;
   IGRchar *date;
   IGRdouble *size_x, *size_y;
   IGRdouble *scale;
   IGRint *copies;
   IGRdouble *line_width_constant;
   IGRint *max_line_width;
   IGRint *raster_type;
   IGRint *dpb_flags;

#endif

   {
   IGRint sts, i, n;
   IGRchar buf[256], *s, *e;
   FILE *fp;
   IGRdouble x, y;
   IGRchar modelpath[128];

   sts = PI_S_SUCCESS;

   modelpath[0] = NULL;
   get_modtype_data ("Grnuc", NULL, NULL, NULL, NULL, modelpath);
   if (modelpath[0] != NULL)
      {
      sprintf (buf, "%suserdata/HSplot.def", modelpath);

      if (read_flag)
         {
         if ((fp = fopen (buf, "r")) == NULL)
            {
            sts = PI_F_FAIL;
            }
         else
            {

            *dpb_flags &= ~(HS_PLOT_SAVE_PLOTFILE
                            | HS_PLOT_SAVE_RASTERFILE
                            | HS_PLOT_SAVE_TEXTFILE
                            | HS_PLOT_MAIL_AT_BEGIN
                            | HS_PLOT_MAIL_AT_END
                            | HS_PLOT_BG_COLOR
                            | HS_PLOT_EDGE_COLOR
                            | HS_PLOT_BLACK_AND_WHITE
                            | HS_PLOT_WHITE_BACKGROUND
                            | HS_PLOT_EXCLUDE_WIREFRAME
                            | HS_PLOT_CREATE_TEXTFILE
                            | HS_PLOT_OLD_FILE);

            while ((fgets (buf, 256, fp)) != NULL)
               {
               n = strlen (buf);
               i = 0;
               e = s = NULL;

               while (i < n)
                  {
                  if (buf[i] == ':')
                     if (s == NULL)
                        s = &buf[i];
                     else
                        {
                        e = &buf[i];
                        break;
                        }
                  i++;
                  }

               if (s != NULL && e != NULL)
                  {
                  *e = 0;
                  *s++ = 0;

                  if ((plotfile) && (!strcmp (buf, Plotfile)))
                     sscanf (s, "%s", plotfile);

                  else if ((rasterfile) && (!strcmp (buf, Rasterfile)))
                     sscanf (s, "%s", rasterfile);

                  else if ((textfile) && (!strcmp (buf, Textfile)))
                     sscanf (s, "%s", textfile);

                  else if ((queue) && (!strcmp (buf, Queue)))
                     sscanf (s, "%s", queue);

                  else if ((size_x && size_y) && !(strcmp (buf, Size)))
                     {
                     sscanf (s, "%lf %lf", &x, &y);
                     *size_x = x;
                     *size_y = y;
                     *dpb_flags |= HS_PLOT_PLOT_BY_SIZE;
                     }

                  else if ((scale) && !(strcmp (buf, Scale)))
                     {
                     sscanf (s, "%lf", &x);
                     *scale = x;
                     *dpb_flags &= ~HS_PLOT_PLOT_BY_SIZE;
                     }

                  else if ((copies) && !(strcmp (buf, Copies)))
                     {
                     sscanf (s, "%d", &i);
                     *copies = i;
                     }

                  else if ((date) && !(strcmp (buf, Date)))
                     {
                     sscanf (s, "%s", date);
                     }

                  else if ((line_width_constant) && !(strcmp (buf, Line_Width_Constant)))
                     {
                     sscanf (s, "%lf", &x);
                     *line_width_constant = x;
                     }

                  else if ((max_line_width) && !(strcmp (buf, Max_Line_Width)))
                     {
                     sscanf (s, "%d", &i);
                     *max_line_width = i;
                     }

                  else if ((raster_type) && !(strcmp (buf, Raster_Type)))
                     {
                     sscanf (s, "%d", &i);
                     *raster_type = i;
                     }

                  else if (!(strcmp (buf, Save_Plotfile)))
                     *dpb_flags |= HS_PLOT_SAVE_PLOTFILE;

                  else if (!(strcmp (buf, Save_Rasterfile)))
                     *dpb_flags |= HS_PLOT_SAVE_RASTERFILE;

                  else if (!(strcmp (buf, Save_Textfile)))
                     *dpb_flags |= HS_PLOT_SAVE_TEXTFILE;

                  else if (!(strcmp (buf, Window_Contents)))
                     *dpb_flags |= HS_PLOT_WINDOW_CONTENTS;

                  else if (!(strcmp (buf, Fence_Contents)))
                     *dpb_flags &= ~HS_PLOT_WINDOW_CONTENTS;

                  else if (!(strcmp (buf, Mail_Begin)))
                     *dpb_flags |= HS_PLOT_MAIL_AT_BEGIN;

                  else if (!(strcmp (buf, Mail_End)))
                     *dpb_flags |= HS_PLOT_MAIL_AT_END;

                  else if (!(strcmp (buf, BG_Color)))
                     *dpb_flags |= HS_PLOT_BG_COLOR;

                  else if (!(strcmp (buf, Edge_Color)))
                     *dpb_flags |= HS_PLOT_EDGE_COLOR;

                  else if (!(strcmp (buf, Black_and_White)))
                     *dpb_flags |= HS_PLOT_BLACK_AND_WHITE;

                  else if (!(strcmp (buf, White_Background)))
                     *dpb_flags |= HS_PLOT_WHITE_BACKGROUND;

                  else if (!(strcmp (buf, Exclude_Wireframe)))
                     *dpb_flags |= HS_PLOT_EXCLUDE_WIREFRAME;

                  else if (!(strcmp (buf, Create_Textfile)))
                     *dpb_flags |= HS_PLOT_CREATE_TEXTFILE;

                  else if (!(strcmp (buf, Old_File)))
                     *dpb_flags |= HS_PLOT_OLD_FILE;

                  }
               }

#				if DEBUG
            DUMP_DEFAULTS
#				endif
            }
         }
      else
         {      /* write */
         if ((fp = fopen (buf, "w")) == NULL)
            {
            sts = PI_F_FAIL;
            }
         else
            {
#				if DEBUG
            DUMP_DEFAULTS
#				endif

               if (plotfile)
               fprintf (fp, "%s:%s:\n", Plotfile, plotfile);

            if (textfile)
               fprintf (fp, "%s:%s:\n", Textfile, textfile);

            if (rasterfile)
               fprintf (fp, "%s:%s:\n", Rasterfile, rasterfile);

            if (queue)
               fprintf (fp, "%s:%s:\n", Queue, queue);

            if (size_x && size_y)
               fprintf (fp, "%s:%.3f %.3f:\n", Size, *size_x, *size_y);

            if (scale)
               fprintf (fp, "%s:%lf:\n", Scale, *scale);

            if (copies)
               fprintf (fp, "%s:%1d:\n", Copies, *copies);

            if (date && date[0] != 0)
               fprintf (fp, "%s:%s:\n", Date, date);

            if (line_width_constant)
               fprintf (fp, "%s:%f:\n", Line_Width_Constant, *line_width_constant);

            if (max_line_width)
               fprintf (fp, "%s:%1d:\n", Max_Line_Width, *max_line_width);

            if (raster_type)
               fprintf (fp, "%s:%1d:\n", Raster_Type, *raster_type);

            if (dpb_flags)
               {
               if (*dpb_flags & HS_PLOT_SAVE_PLOTFILE)
                  fprintf (fp, "%s::\n", Save_Plotfile);

               if (*dpb_flags & HS_PLOT_SAVE_RASTERFILE)
                  fprintf (fp, "%s::\n", Save_Rasterfile);

               if (*dpb_flags & HS_PLOT_SAVE_TEXTFILE)
                  fprintf (fp, "%s::\n", Save_Textfile);

               if (*dpb_flags & HS_PLOT_WINDOW_CONTENTS)
                  fprintf (fp, "%s::\n", Window_Contents);
               else
                  fprintf (fp, "%s::\n", Fence_Contents);

               if (*dpb_flags & HS_PLOT_MAIL_AT_BEGIN)
                  fprintf (fp, "%s::\n", Mail_Begin);

               if (*dpb_flags & HS_PLOT_MAIL_AT_END)
                  fprintf (fp, "%s::\n", Mail_End);

               if (*dpb_flags & HS_PLOT_BG_COLOR)
                  fprintf (fp, "%s::\n", BG_Color);

               if (*dpb_flags & HS_PLOT_EDGE_COLOR)
                  fprintf (fp, "%s::\n", Edge_Color);

               if (*dpb_flags & HS_PLOT_BLACK_AND_WHITE)
                  fprintf (fp, "%s::\n", Black_and_White);

               if (*dpb_flags & HS_PLOT_WHITE_BACKGROUND)
                  fprintf (fp, "%s::\n", White_Background);

               if (*dpb_flags & HS_PLOT_EXCLUDE_WIREFRAME)
                  fprintf (fp, "%s::\n", Exclude_Wireframe);

               if (*dpb_flags & HS_PLOT_CREATE_TEXTFILE)
                  fprintf (fp, "%s::\n", Create_Textfile);

               if (*dpb_flags & HS_PLOT_OLD_FILE)
                  fprintf (fp, "%s::\n", Old_File);
               }

            fclose (fp);
            }
         }

      return (sts);
      }
   else
      {
      fprintf (stderr, "Unable to locate Model path\n");
      return (0);
      }
   }
