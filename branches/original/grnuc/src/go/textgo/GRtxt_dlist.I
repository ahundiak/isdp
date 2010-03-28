class implementation GRtext;
   

#include "wl.h"
#include "dl.h"
#include "gotextdef.h"
#include "DPdlist.h"
#include "OMerrordef.h"
#include "msdef.h"

extern struct GRid DPdlist_wf_fb_gragad;
extern IGRdouble *DPdlist_fb_buffer;
extern int DPdlist_wf_fb_pipe_id;
extern IGRboolean DPdlist_feedback_in_progress;
static struct DPdlist_fixed_data *fixed;


from GRviewdyn import DPdisplay_for_dlist;

/*---DPdlist_process_polygons_for_text-------------------*/

int DPdlist_process_polygons_for_text( )

/*
NAME
   DPdlist_process_polygons_for_text

DESCRIPTION
   This function processes the polygons to be added to the text

SYNOPSIS
   int DPdlist_process_polygons_for_text
      
PARAMETERS
   none

GLOBALS USED
   fixed
   DPdlist_fb_buffer
   DPdlist_feedback_in_progress

RETURN VALUES
   DLIST_S_SUCCESS

HISTORY
   09/08/93 Shridar Subramanian
      Intitial specification, design, and implementation
*/

{
   int qsize;
   int sts, cur_size;
   IGRdouble *elem_ptr, *set_ptr;
   IGRdouble *points;
   IGRuint num_points;

   /* Add polygons to the text structure  */

   sts = DLIST_S_SUCCESS;

   set_ptr = DPdlist_fb_buffer;
   while ( ((WLuint16 *)set_ptr)[0] == DL_FB_PXYZ )
   {
      qsize = ( (int *)set_ptr)[1];
      elem_ptr = &set_ptr[1];
      set_ptr += qsize + 1;
      while( qsize )
      {
         points = &elem_ptr[1];  
         num_points = ((int *)elem_ptr)[0] / 3;
         sts = DPdlist_add_polygon_to_text( fixed, num_points, points );
         if ( !(1 & sts) )
         {
            goto wrapup;
         }
         cur_size =  1 + ( (int *) elem_ptr)[0];
         qsize = qsize - cur_size;
         elem_ptr = elem_ptr + cur_size;
      }
   }
wrapup:
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;

   return( sts );
} /* DPdlist_process_polygons_for_text */ 

/*---DPdlist_process_lines_for_text-------------------*/

int DPdlist_process_lines_for_text( )

/*
NAME
   DPdlist_process_lines_for_text

DESCRIPTION
   This function processes the lines to be added to the text

SYNOPSIS
   int DPdlist_process_lines_for_text
      
PARAMETERS
   none

GLOBALS USED
   fixed
   DPdlist_fb_buffer
   DPdlist_feedback_in_progress

RETURN VALUES
   DLIST_S_SUCCESS

HISTORY
   09/08/93 Shridar Subramanian
      Intitial specification, design, and implementation
*/

{
   int qsize;
   int sts, cur_size;
   IGRdouble *elem_ptr, *set_ptr;
   IGRdouble *points;
   IGRuint num_points;

   sts = DLIST_S_SUCCESS;
   if ( fixed && (fixed->ele_flags & DP_DLIST_ELE_FILLED) )
   {
      fixed->ele_flags &= (~DP_DLIST_ELE_FILLED);
   }

   elem_ptr = DPdlist_fb_buffer;
   while ( ((WLuint16 *)elem_ptr)[0] == DL_FB_LXYZ )
   {
      qsize = ( (int *)elem_ptr)[1];
      points = &elem_ptr[1];
      num_points = qsize / 3;
      sts = DPdlist_add_curve_to_text( fixed, num_points, points );
      if ( !(1 & sts) )
      {
         goto wrapup;
      }
      elem_ptr = elem_ptr + qsize + 1;
   }
wrapup:
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;

   return( sts );

} /* DPdlist_process_lines_for_text */

method GRadd_to_display_list( 
   IGRlong *msg; 
   IGRboolean is_hidden_line )

/*
NAME
   GRadd_to_display_list
 
DESCRIPTION
   This is an override of the GRadd_to_display_list defined in GRgraphics.
   This method adds the element to the display list.
 
 
GLOBALS USED
   none
 
RETURN VALUES
   OM_S_SUCCESS - Success
   OM_E_ERROR - Failure
 
HISTORY
   08/02/93  Shridar Subramanian
      Initial specification and design and implementation
*/

{
   unsigned short ele_flags;
   int sts;
   
   *msg = MSSUCC;
   sts = OM_S_SUCCESS;
   DPdlist_feedback_in_progress = TRUE;

   if ( me^^GRtext.attr.flag & EMPTY_TEXT_FLAG )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   sts = DPdlist_set_element_flags( my_id, OM_Gw_current_OS, &ele_flags );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   if ( me->properties & GRFILLED_DISPLAY )
   {
      ele_flags |= DP_DLIST_ELE_FILLED;
   }

   sts = DPdlist_add_text( my_id, OM_Gw_current_OS, ele_flags,
                           me->display_attr.color,
                           me->display_attr.style,
                           me->display_attr.weight,
                           me->level, &fixed );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }
   /* display text to get its strokes in the feedback buffer             */
   /* DPdrawtext ( dptxstrk.C ) will call DPdlist_process_lines_for_text */
   /* or DPdlist_process_polygons_for_text                               */

   sts = om$send( msg = message GRviewdyn.DPdisplay_for_dlist( msg, my_id, 
                                                             OM_Gw_current_OS ),
                  targetid = DPdlist_wf_fb_gragad.objid,
                  targetos = DPdlist_wf_fb_gragad.osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & *msg) )
   {
      goto wrapup;
   }


   sts = DPdlist_finish_text( fixed );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }
  

wrapup:
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;


   DPdlist_feedback_in_progress = FALSE;

   return( sts );
} /* GRadd_to_display_list */

end implementation GRtext;
