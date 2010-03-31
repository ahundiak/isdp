#include <stdio.h>
#include <string.h>

#include "igrtypedef.h"
#include "igr.h"
#include "hplot.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "hsmacdef.h"
#include "hpmsg.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"

/*-----------------------
 *
 *  for functions
 *      HPfini_zbuffering
 *      HPinit_zbuffering
 *      HPset_line_style
 */

#include "HPpr_hplot_f.h"

/*----------------------*/

#define		ROUND(x)	(int)((x) + 0.5)

/*---HPplotfile_interpreter-------------------------------------------------*/

/*
NAME
        HPplotfile_interpreter
        
KEYWORDS
        HSplot
        plotfile

DESCRIPTION
        This function interprets the shaded plotfile command data
        
PARAMETERS
        file_ptr	:(IN) : File pointer for the shaded plotfile
        command		:(IN) : Id and sub id for the command read
        level		:(IN) : level on which the command resides (obsolete)
        range		:(IN) : range of the data in the command, if applies
        data_num	:(IN) : the number of items read
        data_ptr	:(IN) : pointer to a structure containing the data read
        
GLOBALS USED
        HPglobal	: global structure, initialized and set

FUNCTIONS CALLED
        set_color_table_rgb_values
        set_depth_cue_intensity
        set_light_source
        set_old_light_source
        set_old_old_light_source
        memcpy
        set_plot_scale
        HPinit_zbuffering
        HPfini_zbuffering
        HPmessage

HISTORY
        ??/??/??	L. Brodnax, M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
int HPplotfile_interpreter (FILE * file_ptr,
                                IGRchar command[2],
                                IGRint level,
                                IGRdouble range[6],
                                IGRint data_num,
                                IGRchar * data_ptr)
#else
int HPplotfile_interpreter (
                                file_ptr,
                                command,
                                level,
                                range,
                                data_num,
                                data_ptr)

   FILE *file_ptr;      /* plotfile descriptor */
   IGRchar command[2];  /* current command to processed */
IGRint level;   /* graphic level if draw command */
IGRdouble range[6];     /* range of element if draw cmd with range */
IGRint data_num;        /* number of data things if array */
IGRchar *data_ptr;      /* pointer to data */

#endif

   {
   IGRint status;       /* return code from called functions */
   IGRdouble *p_dbl;    /* pointer to double */
   IGRint j;    /* useful counter */
   static IGRchar initialized = 0;      /* been here flag */

   IGRint rle_width;
   IGRint rle_length;
   IGRint i, *itemp;



   /* initialize HPglobal and curves */
   range[0] = 0.0;
   level = 0;
   if (!initialized)
      {
      initialized = 1;

      HPglobal.active_color = 1;
      HPglobal.color_table_size = 0;
      HPglobal.line_width = 0;
      HPglobal.perspective = 0;

      for (j = 1; j < 16; ++j)
         HPglobal.viewport_to_wld[j] = 0.0;

      HPglobal.viewport_to_wld[0] = 1.0;
      HPglobal.viewport_to_wld[5] = 1.0;
      HPglobal.viewport_to_wld[10] = 1.0;
      HPglobal.viewport_to_wld[15] = 1.0;

      for (j = 1; j < 16; ++j)
         HPglobal.rotation.m16[j] = 0.0;

      HPglobal.rotation.m16[0] = 1.0;
      HPglobal.rotation.m16[5] = 1.0;
      HPglobal.rotation.m16[10] = 1.0;
      HPglobal.rotation.m16[15] = 1.0;

      for (j = 1; j < 16; ++j)
         HPglobal.post_rotation[j] = 0.0;

      HPglobal.post_rotation[0] = 1.0;
      HPglobal.post_rotation[5] = 1.0;
      HPglobal.post_rotation[10] = 1.0;
      HPglobal.post_rotation[15] = 1.0;

      HPglobal.translucency = 0;
      HPglobal.trans_grid = 1;
      HPglobal.rendering_mode = 0;
      HPglobal.num_global_lights = 0;

      for (j = 0; j < MAX_LIGHTS; j++)
         HPglobal.global_lights[j].flags = 0;

      HPglobal.ambient_light.flags = 0;
      HPglobal.ambient_light.red = 0;
      HPglobal.ambient_light.green = 0;
      HPglobal.ambient_light.blue = 0;
      HPglobal.depth_cue_near = 100;
      HPglobal.depth_cue_far = 100;
      HPglobal.display_hidden_edges = 0;

      HPglobal.objid = 0;
      HPglobal.osnum = 0;

      for (j = 0; j < MAX_USER_LINE_STYLES; j++)
         HPglobal.user_line_styles[j] = 0xffff;
      }

   /* process individual command */

   switch (command[0])
      {
      case SETUP_COMMAND:
         switch (command[1])
            {
            case SET_MIPMAP_HOME:
               break;

            case SET_USER_LINE_STYLE:
               HPglobal.user_line_styles[((unsigned short *) (data_ptr))[0]] =
                  ((unsigned short *) (data_ptr))[1];
               break;

            case SET_COLOR_TABLE_RGB:
               status = set_color_table_rgb_values (
                                  (IGRint) data_num, (IGRshort *) data_ptr);

               if (status)
                  return (HSplot_error);
               break;

            case SET_TRANSLUCENCY_GRID:
               HPglobal.trans_grid = *(IGRchar *) data_ptr;
               break;

            case SET_DEPTH_CUE_INTENSITIES:
               status = set_depth_cue_intensity (data_ptr);
               if (status)
                  return (HSplot_error);
               break;

            case SET_WINDOW_LIGHT_SOURCE:
               status = set_light_source ((struct HS_light_source *) data_ptr, 0);
               if (status)
                  return (HSplot_error);
               break;

            case SET_GLOBAL_LIGHT_SOURCE:
               status = set_light_source ((struct HS_light_source *) data_ptr, 1);
               if (status)
                  return (HSplot_error);
               break;

            case SET_AMBIENT_LIGHT_SOURCE:
               status = set_light_source ((struct HS_light_source *) data_ptr, 2);
               if (status)
                  return (HSplot_error);
               break;

            case OLD_WINDOW_LIGHT_SOURCE:
               status = set_old_light_source ((struct HS_old_light_source *) data_ptr, 0);
               if (status)
                  return (HSplot_error);
               break;

            case OLD_GLOBAL_LIGHT_SOURCE:
               status = set_old_light_source ((struct HS_old_light_source *) data_ptr, 1);
               if (status)
                  return (HSplot_error);
               break;

            case OLD_AMBIENT_LIGHT_SOURCE:
               status = set_old_light_source ((struct HS_old_light_source *) data_ptr, 2);
               if (status)
                  return (HSplot_error);
               break;

            case OLD_OLD_WINDOW_LIGHT_SOURCE:
               status = set_old_old_light_source ((struct HS_old_old_light_source *) data_ptr, 0);
               if (status)
                  return (HSplot_error);
               break;

            case OLD_OLD_GLOBAL_LIGHT_SOURCE:
               status = set_old_old_light_source ((struct HS_old_old_light_source *) data_ptr, 1);
               if (status)
                  return (HSplot_error);
               break;

            case OLD_OLD_AMBIENT_LIGHT_SOURCE:
               status = set_old_old_light_source ((struct HS_old_old_light_source *) data_ptr, 2);
               if (status)
                  return (HSplot_error);
               break;

            case SET_VIEW_ORIENTATION_RANGE:
               memcpy (HPglobal.xform.m16, HPglobal.matrix, 16 * sizeof (IGRdouble));
               memcpy (HPglobal.viewport, HPglobal.range, 6 * sizeof (IGRdouble));

               status = set_plot_scale ();


               for (i = 0; i < 16; i++)
                  HPglobal.xform.m16[i] *= HPglobal.scale;

               for (i = 0; i < 6; i++)
                  HPglobal.viewport[i] *= HPglobal.scale;

               HPglobal.world_to_viewport_scale =
                  HPheader.world_to_viewport_scale *
                  HPglobal.scale;

               if (HPglobal.rendering_mode != HPmode_WIREFRAME)
                  {
                  status = HPinit_zbuffering (
                                              HPglobal.scale,
                                          HPglobal.world_to_viewport_scale);
                  }

               break;

            case SET_VIEW_IN_PARALLEL:
               HPglobal.perspective = 0;
               break;

            case SET_VIEW_IN_PERSPECTIVE:
               HPglobal.perspective = 1;
               break;

            default:
               goto unknown_cmd;
               }
         break;

      case BASIC_ATTR_COMMAND:
         switch (command[1])
            {
            case SET_ACTIVE_MIPMAP:
               break;

            case SET_HIDDEN_SYMBOLOGY:
               HPglobal.display_hidden_edges = 1;
               HPglobal.hsym = *(struct GRhesym *) data_ptr;
               break;

            case SET_ACTIVE_TILING_TOLERANCE:
               if( HPglobal.tiling_tolerance == 0.0 )
                  HPglobal.tiling_tolerance = *(IGRdouble *) data_ptr;
               HPglobal.accuracy_mode = HS_ACCURACY_MODE_WINDOW;
               break;

            case SET_ACTIVE_SHADING_ACCURACY:
               HPglobal.accuracy = *(IGRshort *) data_ptr;
               HPglobal.accuracy_mode = HS_ACCURACY_MODE_ACTIVE;
               break;

            case SET_ACTIVE_PHONG_ATTRIBUTES:
               break;
 
            case SET_ACTIVE_FG_COLOR_INDEX:
               HPglobal.active_color = *(IGRshort *) data_ptr;
               break;

            case SET_ACTIVE_LINE_STYLE:
               HPglobal.line_style = *(IGRint *) data_ptr;
               HPset_line_style (*(IGRshort *) data_ptr);
               break;

            case SET_ACTIVE_LINE_WIDTH:
               HPglobal.line_width = (IGRshort) (*(IGRdouble *) data_ptr);
               if( HPglobal.line_width > HPglobal.max_line_width)
               {
                   HPglobal.line_width = HPglobal.max_line_width;
               }
               break;

            case SET_ACTIVE_RENDERING_MODE:
               if (HPglobal.rendering_mode == HPmode_WIREFRAME &&
                   *(IGRchar *) data_ptr != HPmode_WIREFRAME)
                  {
                  status = HPinit_zbuffering (
                                              HPglobal.scale,
                                          HPglobal.world_to_viewport_scale);
                  }
               else
                  {
                  if (HPglobal.rendering_mode != HPmode_WIREFRAME &&
                      *(IGRchar *) data_ptr == HPmode_WIREFRAME)
                     {
                     status = HPfini_zbuffering (
                                                 file_ptr,
                                                 &rle_width,
                                                 &rle_length);
                     }
                  }

               HPglobal.rendering_mode = *(IGRchar *) data_ptr;
               break;

            case SET_ACTIVE_TRANSLUCENCY:
               HPglobal.translucency = *(IGRchar *) data_ptr;
               break;

            case SET_VIEWPORT_TO_WLD_MATRIX:
               p_dbl = (IGRdouble *) data_ptr;
               for (j = 0; j < 16; ++j)
                  HPglobal.viewport_to_wld[j] = *p_dbl++;
               break;

            case SET_ACTIVE_ROTATION_MATRIX:
               p_dbl = (IGRdouble *) data_ptr;
               for (j = 0; j < 16; ++j)
                  HPglobal.rotation.m16[j] = *p_dbl++;
               break;

            case SET_ACTIVE_POST_ROTATION_MATRIX:
               p_dbl = (IGRdouble *) data_ptr;
               for (j = 0; j < 16; ++j)
                  HPglobal.post_rotation[j] = *p_dbl++;
               break;

            case SET_OBJECT_INFO:
               itemp = (IGRint *) data_ptr;

               HPglobal.objid = itemp[0];
               HPglobal.osnum = (IGRshort)itemp[1];

#              if defined (BIG_ENDIAN)
               HSconv_int  ( &HPglobal.objid, 1 );
               HSconv_short( &HPglobal.osnum, 1 );
#              endif

               break;

            default:
               goto unknown_cmd;
               }
         break;

      case PRIMITIVE_COMMAND:

         switch (command[1])
            {
            case oldNURB_EDGE:
            case oldNURB_CURVE:
            case NURB_EDGE:
            case NURB_CURVE:
               break;

            case NURB_SURFACE:
            case NURB_SURFACE_WITH_RANGE:
               break;

            default:
               goto unknown_cmd;
               }

         break;

      default:
         goto unknown_cmd;
         }

   return HSplot_success;

   /* error exit -- unknown command type or subtype */

unknown_cmd:
   HPmessage (HP_F_UnsReq, NULL, 
              HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE);

   return HSplot_error;

   }    /* HPplotfile_interpreter */

