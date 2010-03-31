
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include <sys/types.h>
#ifndef X11
#include <sys/dir.h>
#endif

#include "wl.h"
#include "DIdef.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "madef.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"

#include "HSplot_label.h"
#include "HSplot.h"
#include "HSplot_def.h"

#include "HSpr_hplot.h"

#define MAXDIRS  1

extern char *GRget_ingrhome ();

static char *dir = NULL;
static char subdir[] = "ip/cnuc/render/subscribed";

static void HPsetup_ip_dir ()
   {
   dir = (char *)malloc (strlen (GRget_ingrhome (NULL)) + strlen (subdir) + 4);
   sprintf (dir, "%s/%s", GRget_ingrhome (NULL), subdir);
   }

/*---readln-----------------------------------------*/

/*
 *  Read a line from an ascii file
 */

static int	readln( FILE *fp, char *line, int buflen )

   {
   unsigned char	c;
   int			i;

   i = 0;
   while( (c=getc(fp)) != 10 && (i++) < buflen )
      {
      if( c == 0xff ) return 0;
      *line++ = c;
      }

   *line = 0;
   return 1;
   }

/*---HPpqinfo-------------------------------------------------------*/

/*
Name
   HPpqinfo

Description
   This function retrieves the maximum plotter limits associated
   with the specifed plotter queue.

History
   mrm     04/14/89    creation
*/

int HPpqinfo( char *plotter_queue,
              double *x, 
              double *y,
              double *r,
              char *plotter_unit )
   {
   int sts;
   char *c, buf[32], filename[128];
   FILE *fp;
   char line[256], *l;
   double rx, ry;

   sts = PI_F_FAIL;

   if (strlen (plotter_queue))
      {
      strncpy (buf, plotter_queue, 32);
      if (c = strchr (buf, '@'))
         {
         *c = NULL;
         }

      if (dir == NULL)
         HPsetup_ip_dir ();

      sprintf (filename, "%s/%s.pd", dir, buf);
      if (fp = fopen (filename, "r"))
         {
         *x = *y = 1.0;

         while( readln( fp, line, 256 ) )
            {
            if( (l = strstr( line, "PD_SIZE" )) != NULL )
               {
               sts = sscanf (line, "%*s %lf %lf", x, y);
               sts = PI_S_SUCCESS;
               plotter_unit[0] = 'm';
               plotter_unit[1] = NULL;
               COcvtsize (x, y, plotter_unit);
               }

            else
            if( (l = strstr( line, "RESOLUTION" )) != NULL )
               {
               sts = sscanf (line, "%*s %lf %lf", &rx, &ry);
               sts = PI_S_SUCCESS;
               rx /= 39.37;
               ry /= 39.37;
               *r = (rx+ry) / 2.0;
               }
            }

         fclose (fp);
         }
      }

   return (sts);
   }

/*---HPspformatqinfo-----------------------------------------*/

/*
Name
   HPspformatqinfo

Description
   This function formats a plotter queue name and its limits for
   display on the Submit Plot form.  The active output units are
   used for the limit display.
*/

int HPspformatqinfo( char *queue,
                     double x,
                     double y,
                     double r,
                     char *unit, 
                     char *buf )
   {
   char active_units[3][32];
   double v[2];
   OMuword osnum;
   int sts, i, j;

   /* get the current module space number */

   ex$get_cur_mod (osnum = &osnum);

   /* get the active output unit to display plotter limits */

   i = 0;

   co$get_default_units (msg = &sts,
                         table_name = "UOM_DISTANCE",
                         osnum = osnum,
                         flag = &i,
                         num_defaults = &j,
                         default_units = active_units);

   if (!(sts & 1))
      {
      sprintf (active_units[0], "in");  /* take a guess */
      }

   /* convert the plotter limits to default output units */

   v[0] = x;
   v[1] = y;

   co$cvt_value_to_value (msg = &sts,
                          unit_type = "UOM_DISTANCE",
                          osnum = osnum,
                          alias_to_cvt_from = unit,
                          alias_to_cvt_to = active_units[0],
                          num_vals = 2,
                          values_in = v,
                          values_out = v);

   sprintf (buf, "%-14s (%3ddpi) %7.3f x %7.3f %s", queue, (int)r, v[0], v[1], active_units[0]);

   return (PI_S_SUCCESS);
   }

/*---HPspqlist-----------------------------------------------------*/

/*
NAME
   HPspqlist
        
KEYWORDS
   shaded plotting
        
DESCRIPTION
   Collect the list of available queues and place them in the
   queue field list
        
PARAMTERS
   form :(IN) : id of the form on which to add the qlist
   qcount :(OUT): number of queues found

GLOBALS USED
   -none-
        
FUNCTIONS CALLED
   FIfld_set_list_text
   HPpqinfo
   HPspformatqinfo
   fgets
   pclose
   popen
   strchr

HISTORY
   ??/??/?? M. Lanier
      Created
                
   02/12/93 M. Lanier
      Changed HPpqinfo, HPspformatqinfo to COpqinfo, CPspformatqinfo.  These
      are the wireframe plotting functions that do the same thing, but do
      not have a problem.

   06/13/97 M. Lanier
      Re-entered the functions HPpqinfo and HPspformatqinfo, which were copied
      from the function COpqinfo and COspformatqinfo. Wanted to add
      resolution to the string
*/

IGRint HPspqlist (Form form,
                  IGRint * qcount,
                  char *defq,
                  unsigned int *con_flags)

   {
   IGRchar *c, queue[128], buf[128], buf0[128], unit[16];
   IGRint sts;
   IGRdouble x, y, r;
   FILE *pp = NULL, *popen ();

   sts = PI_F_NOQUEUE;
   *qcount = 0;

   *con_flags |= HP_CONTROL_DEF_QUE_NOT_EXIST;

   if (pp = popen ("qstat", "r"))
      {
      while (fgets (buf, sizeof (buf), pp) != NULL)
         {
         if ((c = (IGRchar *) strchr (buf, '@')) != NULL)
            {
            *c = NULL;

            if (strcmp (defq, buf) == 0)
               *con_flags &= ~HP_CONTROL_DEF_QUE_NOT_EXIST;

            if (HPpqinfo (buf, &x, &y, &r, unit))
               {
               HPspformatqinfo (buf, x, y, r, unit, queue);
               if (FIfld_set_list_text( form,
                                        SP_QUEUE,
                                        *qcount,
                                        0, queue, 0) == 0)
                  {
                  sts = PI_S_SUCCESS;
                  *qcount = *qcount + 1;
                  }
               }
            }
         }

      pclose (pp);
      }

   return (sts);
   }
