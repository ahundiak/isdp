class implementation COcctform;

/*
 *   Filename:   COcct_ctbl.I
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   January 1989
 *
 *   This file contains the actions that interface with the color table:
 *
 *   set_current_color   - sets the current color to a new logical color.
 *
 *   update_color_table   - updates the color table with my local values.
 *
 *   restore_color_table   - restores the color table to its original values.
 *
 *   History:
 */



#include "stdio.h"
#include "cct.h"

#include "OMmacros.h"
#include "OMprimitives.h"

#include "wl.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "dpgraphics.h"
#include "cctmessage.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"


/*----- set_current_color ----------------------------------------------------*/

method set_current_color ( int save_current_color, logical_index, display )

/*
 * ABSTRACT:   Set_current_color sets the current color to that with the given
 *      logical index.  It sets the active and reserved flags according to
 *      the given values.
 * PARAMETERS
 *    logical_index (in):   logical color to set current
 *
 * HISTORY:   01/11/88  Created.         C. M. Jablonski
 */

{
   int      status = OM_S_SUCCESS;
   IGRushort   colors[3];
   IGRint      packed_color;
   IGRdouble   color_code, page;
   IGRlong      msg;
   struct IGRdisplay   disbuf;

   /* save the past current color */
   if ( save_current_color )
   {
      colors[0] = (IGRushort) (me->curr_red * 65535.0);
      colors[1] = (IGRushort) (me->curr_green * 65535.0);
      colors[2] = (IGRushort) (me->curr_blue * 65535.0);
      packed_color = CLpack_colors( colors[0], colors[1], colors[2] );
      if (me->modified_ctbl[ me->curr_color ] != packed_color)
      {
         me->modified_ctbl[ me->curr_color ] = packed_color;
         if (( me->curr_color > 0 ) && ( me->curr_color < (me->num_colors - 1) ))
         {
            /* change logical color */
            ige$modify_color_table( 
               start_color = me->curr_color,
               num_colors = 1, 
               colors = &me->modified_ctbl[me->curr_color],
               flags = ( PACKED_COLORS ) );
         }
         else
         {
            /* change reserved color */
            if ( me->curr_color == 0 )
            {
               ige$change_reserved_colors(bgcolor = &me->modified_ctbl[me->curr_color], 
                                          flags = PACKED_COLORS);
            }
            else
            {
               ige$change_reserved_colors(fgcolor = &me->modified_ctbl[me->curr_color], 
                                          flags = PACKED_COLORS);
            }
         }
      }
#if defined ( DEBUG_CCT )
      else
      {
         printf("COcctform.set_current_color current color unchanged=> not modifying/remapping\n");
      }
#endif
   }
   
   /* save the last color (for unhiliting the box) */
   me->last_color = me->curr_color;
   if (logical_index > me->num_colors - 1)
   {
      /* The -2 has to do with bg and hilight being in array */
      me->curr_color = ( (logical_index - 2) % (me->num_colors - 2)) + 1;
   }
   else
   {
      me->curr_color = logical_index;
   }

   /* set the form active color */
   if (( me->curr_color > 0 ) && ( me->curr_color < (me->num_colors - 1) ))
   {
      /* set the active color for ems.  This will be the full color number 
         if over num_bg_log_hl_colors.  It is the logical color number*/
      gr$get_active_display( buffer = &disbuf );
      disbuf.color = (IGRushort) logical_index;
      gr$put_active_display( buffer = &disbuf );
   
      /* set the color code number in the field */
      color_code = (IGRdouble) me->curr_color;
      FIg_set_value( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_COLOR_CODE, color_code);
   }
   else
   {
      /* clear the color code field for reserved colors and those out of range*/
      FIg_set_text( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_COLOR_CODE, "");
   }

   if ( (me->curr_color != me->num_colors - 1) && (me->curr_color != 0) &&
      ( ((me->curr_color - 1) / 64) != me->curr_color_page ) )
   {
      /* change page if current color not on current page and not bg or hl */
      me->curr_color_page = (me->curr_color - 1) / 64;
      page = (IGRdouble) (me->curr_color_page + 1);
      FIg_set_value( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_PAGE, page);
      FIg_set_value( me->forms[CCT_FORM_LABEL].form_ptr, SCROLL_PAGE, page);
      if (display)
      {
            om$send(msg      = message COcctform.draw_color_pallet( &msg ), 
               targetid   = my_id );         
      }
   }

   CLunpack_colors( me->modified_ctbl[ me->curr_color ], &colors[0], &colors[1], &colors[2] );
   me->curr_red = colors[0] / 65535.0;
   me->curr_green = colors[1] / 65535.0;
   me->curr_blue = colors[2] / 65535.0;

   /* initialize the name gadget */
   status = ige$get_name_from_color( color = me->curr_color, name = me->curr_colname );
   if (status == 0)
   {
      sprintf(me->curr_colname, "%s", "");
   }
   FIfld_set_text( me->forms[CCT_FORM_LABEL].form_ptr, KEYIN_NAME, 0, 0, me->curr_colname, FALSE);

   return( status );
}


/*----- update_color_table ---------------------------------------------------*/

method update_color_table ( int * sts )

/*
ABSTRACT:
   Update_color_table updates the system color table entries
   with my local values.  This is called when we exit the form.


HISTORY:   01/11/89  Created.         C. M. Jablonski
*/

{
   IGRshort   num_names, num_colors;

   /* update the color names */
   num_names = om$dimension_of( varray = me->modified_names );
   ige$modify_color_names( num_names = num_names, names = me->modified_names );

   /* update the color table */
   num_colors = om$dimension_of(   varray   = me->modified_ctbl );
   ige$modify_color_table( num_colors = num_colors, colors = me->modified_ctbl,
      flags = ( PACKED_COLORS | IGE_CHANGE_BACKGROUND | IGE_CHANGE_HIGHLIGHT ) );

   return( OM_S_SUCCESS );
}


/*----- restore_color_table --------------------------------------------------*/

method restore_color_table ( int * sts )

/*
 * ABSTRACT:   Restore_color_table restores the system color table entries
 *      to the values they had prior to the invocation of this
 *      command object if the user hasn't checked out of the form.
 *
 * HISTORY:   01/11/88  Created.         C. M. Jablonski
 */

{
   IGRshort   num_names, num_colors;

   /* restore the color names */
   num_names = om$dimension_of( varray   = me->orig_names );
   ige$modify_color_names( num_names = num_names, names = me->orig_names );

   /* restore the color table */
   num_colors = om$dimension_of (   varray   = me->orig_ctbl );
   ige$modify_color_table( num_colors   = num_colors,
                 colors      = me->orig_ctbl,
                 flags      = ( PACKED_COLORS | IGE_CHANGE_BACKGROUND | IGE_CHANGE_HIGHLIGHT ) );

   return( OM_S_SUCCESS );
}

end implementation COcctform;
