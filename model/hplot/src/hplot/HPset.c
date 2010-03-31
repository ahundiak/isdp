#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "hpmsg.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"

/*
 *  Prototype declaration for static functions
 */

/* HPset.c */
static HPdump_light (void);

#define DEBUGGER 0

#if DEBUGGER

/*---HPdump_light--------------------------------------------------_*/

/*
NAME
   HPdump_light: static
        
KEYWORDS
   Hsplot
   light source
   static
   debug
        
DESCRIPTION
   Display the light sources

GLOBALS USED
   HPglobal      : global structure
   num_lights    : number of global lights
   global_lights : array of global lights
   ambient_light : ambient light
                        
HISTORY
   ??/??/?? M. Lanier
      Created
*/

static HPdump_light (void)

   {
   int i;

   fprintf (stderr, "Lights\n");
   fprintf (stderr, "  Number of global lights = %1d\n", HPglobal.num_global_lights);

   for (i = 0; i < HPglobal.num_global_lights; i++)
      if (HPglobal.global_lights[i].flags & HS_LIGHT_ENABLED)
         {
         fprintf (stderr, "    Global Lights #%1d\n", i);
         if (HPglobal.global_lights[i].flags & HS_LIGHT_PARALLEL)
            fprintf (stderr, "      PARALLEL\n");
         if (HPglobal.global_lights[i].flags & HS_LIGHT_POINT)
            fprintf (stderr, "      POINT\n");
         if (HPglobal.global_lights[i].flags & HS_LIGHT_SPOT)
            fprintf (stderr, "      SPOT\n");
         if (HPglobal.global_lights[i].flags & HS_LIGHT_PENCIL)
            fprintf (stderr, "      PENCIL\n");
         if (HPglobal.global_lights[i].flags & HS_LIGHT_AMBIENT)
            fprintf (stderr, "      AMBIENT\n");
         fprintf (stderr, "      location --- %f %f %f\n",
                  HPglobal.global_lights[i].location[0],
                  HPglobal.global_lights[i].location[1],
                  HPglobal.global_lights[i].location[2]);
         fprintf (stderr, "      direction -- %f %f %f\n",
                  HPglobal.global_lights[i].direction[0],
                  HPglobal.global_lights[i].direction[1],
                  HPglobal.global_lights[i].direction[2]);
         fprintf (stderr, "      radius------ %f\n", HPglobal.global_lights[i].radius);
         fprintf (stderr, "      angle ------ %f\n", HPglobal.global_lights[i].angle);
         fprintf (stderr, "      color ------ %d %d %d\n",
                  HPglobal.global_lights[i].red, 
                  HPglobal.global_lights[i].green, 
                  HPglobal.global_lights[i].blue);
         }

   fprintf (stderr, "    Ambient Light\n");
   fprintf (stderr, "      location --- %f %f %f\n",
            HPglobal.ambient_light.location[0],
            HPglobal.ambient_light.location[1],
            HPglobal.ambient_light.location[2]);
   fprintf (stderr, "      direction -- %f %f %f\n",
            HPglobal.ambient_light.direction[0],
            HPglobal.ambient_light.direction[1],
            HPglobal.ambient_light.direction[2]);
   fprintf (stderr, "      radius------ %f\n", HPglobal.ambient_light.radius);
   fprintf (stderr, "      angle ------ %f\n", HPglobal.ambient_light.angle);
   fprintf (stderr, "      color ------ %d %d %d\n",
            HPglobal.ambient_light.red, 
            HPglobal.ambient_light.green, 
            HPglobal.ambient_light.blue);
   }

#endif

/*---set_color_table_rgb_values-----------------------------------------------*/

/*
NAME
   set_color_table_rgb_values
        
KEYWORDS
   HSplot
   color table
        
DESCRIPTION
   Copy the colortable values from the input buffer into the
   global structure
        
PARAMETERS
   table_size :(IN) : Number of colors in the colortable
   rgb_value :(IN) : Colortable read from the plotfile
        
GLOBALS USED
   HPglobal         : global structure
   color_table      : global structure color table
   color_table_size : number of entries in the color table

HISTORY

   ??/??/?? M. Lanier
      Created
*/

IGRint set_color_table_rgb_values (IGRint table_size,
                                   IGRshort * rgb_value)

   {
   IGRint size; /* size of color table in bytes */


   size = (table_size - 1) * 3 * sizeof (IGRshort);

   HPglobal.color_table_size = table_size;

   memcpy (&HPglobal.color_table[0][0], rgb_value, 3 * sizeof (IGRshort));
   memcpy (&HPglobal.color_table[1][0], &rgb_value[3], size);

   return HSplot_success;

   }    /* set_color_table_rgb_values */

/*---set_depth_cue_intensity------------------------------------------------------*/

/*
NAME
   set_depth_cue_intensity
        
KEYWORDS
   HSplot
   depth cue
        
DESCRIPTION
   Copy the depth cue values to the global structure
        
PARAMETERS
   depth_cues :(IN) : buffer containing the depth cue info read from the
                        shaded plotfile
                                
GLOBALS USED
   HPglobal  : global structure
   depth_cue_near : depth cue near value
   depth_cue_far : depth cue far value
                
HISTORY
   ??/??/?? M. Lanier
      Created
*/

IGRint set_depth_cue_intensity (IGRchar * depth_cues)

   {

   /*
    * Copy the depth cue intensities into the active structure
    */

   HPglobal.depth_cue_near = depth_cues[0];
   HPglobal.depth_cue_far = depth_cues[1];

#  if DEBUGGER
   fprintf (stderr, "Depth cue values -- %d %d\n",
            HPglobal.depth_cue_near, HPglobal.depth_cue_far);
#  endif

   return HSplot_success;
   }

/*---set_light_source------------------------------------------------------*/

/*
NAME
   set_light_source
        
KEYWORDS
   HSplot
   light source
        
DESCRIPTION
   Copy the light source read from the shaded plotfile into the
   global structure
        
PARAMETERS
   light  :(IN) : structure containing the light read
   type   :(IN) : the type of light read
        
GLOBALS USED
   HPglobal             : global structure
      global_lights     : array of global lights in the global structure
      num_global_lights : number of global lights in the global structure
      ambient_light     : structure containing the ambient light
                
FUNCTIONS CALLED
   HPdump_light (debug only)
        
HISTORY
   ??/??/?? M. Lanier
      Created
*/

IGRint set_light_source (struct HS_light_source * light,
                         IGRint type)

   {
   IGRint i;

   if (type != 2)
      {
      i = HPglobal.num_global_lights++;
      HPglobal.global_lights[i] = *light;
      }
   else
      {
      HPglobal.ambient_light = *light;
      }

#  if DEBUGGER
   HPdump_light ();
#  endif

   return HSplot_success;
   }

/*---set_old_light_source------------------------------------------------------*/

/*
NAME
   set_old_light_source
        
KEYWORDS
   HSplot
   light source
        
DESCRIPTION
   Given a light source of an older format, read from the shaded plotfile,
   convert it to the current light source format and place in the
   global structure
        
PARAMTERS
   light  :(IN) : light source of older format
   type  :(IN) : type of light
        
GLOBALS USED
   HPglobal             : global structure
      num_global_lights : Number of global lights read
      global_lights     : array of global lights
      ambient_light     : single ambient light
                
HISTORY
   ??/??/?? M. Lanier
      Created
*/

IGRint set_old_light_source (struct HS_old_light_source * light,
                             IGRint type)

   {
   IGRint i;

   if (type != 2)
      {
      i = HPglobal.num_global_lights++;

      switch (light->type)
         {
         case HS_OLD_LIGHT_PARALLEL:
            HPglobal.global_lights[i].flags |= HS_LIGHT_PARALLEL;
            break;

         case HS_OLD_LIGHT_POINT:
            HPglobal.global_lights[i].flags |= HS_LIGHT_POINT;
            break;

         case HS_OLD_LIGHT_SPOT:
            HPglobal.global_lights[i].flags |= HS_LIGHT_SPOT;
            break;

         case HS_OLD_LIGHT_PENCIL:
            HPglobal.global_lights[i].flags |= HS_LIGHT_PENCIL;
            break;

         case HS_OLD_LIGHT_AMBIENT:
            HPglobal.global_lights[i].flags |= HS_LIGHT_AMBIENT;
            break;
            }

      HPglobal.global_lights[i].flags |= HS_LIGHT_ENABLED;
      HPglobal.global_lights[i].location[0] = light->location[0];
      HPglobal.global_lights[i].location[1] = light->location[1];
      HPglobal.global_lights[i].location[2] = light->location[2];
      HPglobal.global_lights[i].direction[0] = light->direction[0];
      HPglobal.global_lights[i].direction[1] = light->direction[1];
      HPglobal.global_lights[i].direction[2] = light->direction[2];
      HPglobal.global_lights[i].radius = light->radius;
      HPglobal.global_lights[i].angle = light->angle;
      HPglobal.global_lights[i].red = light->red;
      HPglobal.global_lights[i].green = light->green;
      HPglobal.global_lights[i].blue = light->blue;
      }
   else
      {
      HPglobal.ambient_light.flags |= HS_LIGHT_AMBIENT | HS_LIGHT_ENABLED;
      HPglobal.ambient_light.location[0] = light->location[0];
      HPglobal.ambient_light.location[1] = light->location[1];
      HPglobal.ambient_light.location[2] = light->location[2];
      HPglobal.ambient_light.direction[0] = light->direction[0];
      HPglobal.ambient_light.direction[1] = light->direction[1];
      HPglobal.ambient_light.direction[2] = light->direction[2];
      HPglobal.ambient_light.radius = light->radius;
      HPglobal.ambient_light.angle = light->angle;
      HPglobal.ambient_light.red = light->red;
      HPglobal.ambient_light.green = light->green;
      HPglobal.ambient_light.blue = light->blue;
      }

#  if DEBUGGER
   HPdump_light ();
#  endif

   return HSplot_success;
   }

/*---set_old_old_light_source------------------------------------------------------*/

/*
NAME
   set_old_old_light_source
        
KEYWORDS
   HSplot
   light source
        
DESCRIPTION
   Given a light source of another older format, convert it to the latest
   format and place in the global structure
        
PARAMETERS
   light  :(IN) : light source of another older format
   type  :(IN) : type of light
        
GLOBALS USED
   HPglobal             : global structure
      num_global_lights : number of global lights read
      global_lights     : array of global lights
      ambient_light     : single ambient light
                
HISTORY
   ??/??/?? M. Lanier
      Created
*/

IGRint set_old_old_light_source (struct HS_old_old_light_source * light,
                                 IGRint type)

   {
   IGRint i;

   if (type != 2)
      {
      i = HPglobal.num_global_lights++;

      switch (light->type)
         {
         case HS_OLD_LIGHT_PARALLEL:
            HPglobal.global_lights[i].flags |= HS_LIGHT_PARALLEL;
            break;

         case HS_OLD_LIGHT_POINT:
            HPglobal.global_lights[i].flags |= HS_LIGHT_POINT;
            break;

         case HS_OLD_LIGHT_SPOT:
            HPglobal.global_lights[i].flags |= HS_LIGHT_SPOT;
            break;

         case HS_OLD_LIGHT_PENCIL:
            HPglobal.global_lights[i].flags |= HS_LIGHT_PENCIL;
            break;

         case HS_OLD_LIGHT_AMBIENT:
            HPglobal.global_lights[i].flags |= HS_LIGHT_AMBIENT;
            break;
            }

      HPglobal.global_lights[i].flags |= HS_LIGHT_ENABLED;
      HPglobal.global_lights[i].location[0] = light->x;
      HPglobal.global_lights[i].location[1] = light->y;
      HPglobal.global_lights[i].location[2] = light->z;
      HPglobal.global_lights[i].direction[0] = light->x;
      HPglobal.global_lights[i].direction[1] = light->y;
      HPglobal.global_lights[i].direction[2] = light->z;
      HPglobal.global_lights[i].radius = light->radius;
      HPglobal.global_lights[i].angle = 0.0;
      HPglobal.global_lights[i].red = light->red;
      HPglobal.global_lights[i].green = light->green;
      HPglobal.global_lights[i].blue = light->blue;
      }
   else
      {
      HPglobal.ambient_light.flags |= HS_LIGHT_AMBIENT | HS_LIGHT_ENABLED;
      HPglobal.ambient_light.location[0] = light->x;
      HPglobal.ambient_light.location[1] = light->y;
      HPglobal.ambient_light.location[2] = light->z;
      HPglobal.ambient_light.direction[0] = light->x;
      HPglobal.ambient_light.direction[1] = light->y;
      HPglobal.ambient_light.direction[2] = light->z;
      HPglobal.ambient_light.radius = light->radius;
      HPglobal.ambient_light.angle = 0.0;
      HPglobal.ambient_light.red = light->red;
      HPglobal.ambient_light.green = light->green;
      HPglobal.ambient_light.blue = light->blue;
      }

#  if DEBUGGER
   HPdump_light ();
#  endif

   return HSplot_success;
   }

/*---set_plot_scale------------------------------------------------------*/

/*
NAME
   set_plot_scale
        
KEYWORDS
   HSplot
   scale
        
DESCRIPTION
   Compute the plot scale factor and replication factor
        
GLOBALS USED
   HPglobal               : global structure
      scale               :
      resolution          :
      range               :
      replication_factor  :
      line_width_constant :
   HPcommand_line         : global structure
      scale               :
      xsize               :
      ysize               :
                
HISTORY
   ??/??/?? M. Lanier
      Created
*/

IGRint set_plot_scale (void)

   {
   IGRdouble x_pixels, y_pixels;
   IGRdouble x_ext, y_ext;
   IGRdouble x_scl, y_scl;

#  if DEBUGGER
   fprintf (stderr, "HPglobal.view_info\n");
   fprintf (stderr, "   matrix\n");
   fprintf (stderr, "      %f %f %f %f\n",
            HPglobal.matrix[0], HPglobal.matrix[1],
            HPglobal.matrix[2], HPglobal.matrix[3]);
   fprintf (stderr, "      %f %f %f %f\n",
            HPglobal.matrix[4], HPglobal.matrix[5],
            HPglobal.matrix[6], HPglobal.matrix[7]);
   fprintf (stderr, "      %f %f %f %f\n",
            HPglobal.matrix[8], HPglobal.matrix[8],
            HPglobal.matrix[10], HPglobal.matrix[11]);
   fprintf (stderr, "      %f %f %f %f\n",
            HPglobal.matrix[12], HPglobal.matrix[13],
            HPglobal.matrix[14], HPglobal.matrix[15]);
   fprintf (stderr, "   range\n");
   fprintf (stderr, "      %f %f %f\n",
            HPglobal.range[0], HPglobal.range[1], HPglobal.range[2]);
   fprintf (stderr, "      %f %f %f\n",
            HPglobal.range[3], HPglobal.range[4], HPglobal.range[5]);
#  endif

   HPglobal.scale = HPcommand_line.scale;

   /*
    * Determine the plot dimension in pixels from the requested plot
    * dimension.
    */

   x_pixels = HPglobal.size_x * HPglobal.resolution;
   y_pixels = HPglobal.size_y * HPglobal.resolution;


   /*
    * Determing the extents of the metafile data in pixels
    */

   x_ext = HPglobal.range[3] - HPglobal.range[0];
   y_ext = HPglobal.range[4] - HPglobal.range[1];



   if (HPglobal.scale < 0.0)
      {

      /*
       * Calculated a scale factor to each size of the plot which maps the
       * metafile data to the requested plotsize.
       */

      x_scl = x_pixels / x_ext;
      y_scl = y_pixels / y_ext;

      /*
       * Set the overall scale factor to be the minimum of the above two.
       */

      HPglobal.scale = x_scl < y_scl ? x_scl : y_scl;
      }

   /* 
    *  if the replication_factor is other than 0.0 (ie a user input has
    *  been made), don't compute it using the line_width_constant
    */

   if (HPglobal.replication_factor == 0.0)
      {
      HPglobal.replication_factor = HPglobal.line_width_constant * HPglobal.resolution;
      HPglobal.replication_factor = (double) ((int) (HPglobal.replication_factor + 0.5));
      }

   HPglobal.scale /= HPglobal.replication_factor;
   HPglobal.resolution /= HPglobal.replication_factor;

   return HSplot_success;
   }
