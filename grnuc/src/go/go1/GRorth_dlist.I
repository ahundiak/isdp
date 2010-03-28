class implementation GRorthpoly;


#include "wl.h"
#include "dl.h"
#include "DPdlist.h"
#include "OMerrordef.h"
#include "msdef.h"

extern struct GRid DPdlist_wf_fb_gragad;
extern IGRdouble *DPdlist_fb_buffer;
extern int DPdlist_wf_fb_pipe_id;
extern IGRboolean DPdlist_feedback_in_progress;


from GRviewdyn import DPdisplay_for_dlist;


/*---GRadd_to_display_list-------------------------------------*/

method GRadd_to_display_list( 
   IGRlong *msg;
   IGRboolean is_hidden_line )

/*
NAME
   GRadd_to_display_list
 
DESCRIPTION
   This method overrides the GRadd_to_display_list method defined in GRgraphics
 
RETURN VALUES
   OM_S_SUCCESS - Success
   OM_E_ERROR - Failure
 
HISTORY
   08/02/93  Shridar Subramanian
      Initial specification and design and implementation
*/


{
   IGRdouble *points;
   unsigned short ele_flags;
   int sts;
   IGRuint num_points;

   *msg = MSSUCC;
   sts = OM_S_SUCCESS;
   DPdlist_feedback_in_progress = TRUE;


   /* display polygon to get its strokes in the feedback buffer */
   sts = om$send( msg = message GRviewdyn.DPdisplay_for_dlist( msg, my_id, OM_Gw_current_OS ),
                  targetid = DPdlist_wf_fb_gragad.objid,
                  targetos = DPdlist_wf_fb_gragad.osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & *msg) )
   {
      return( OM_E_ERROR );
   }

   if ( ((WLuint16 *)DPdlist_fb_buffer)[0] == 0 )
   {
      /* nothing added to feedback buffer */
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

   if ( ( ( WLuint16 *) DPdlist_fb_buffer)[0] == DL_FB_PXYZ )
   {
      /* The polygon is filled => subtract 1 off of num_points */
      /* because we don't want the terminating point           */
      num_points = ((int *)DPdlist_fb_buffer)[2] / 3 - 1;
      points = &DPdlist_fb_buffer[2]; 
      ele_flags |= DP_DLIST_ELE_FILLED;
      sts = DPdlist_add_polygon( my_id, OM_Gw_current_OS, ele_flags, 
                                 me->display_attr.color,
                                 me->display_attr.style, 
                                 me->display_attr.weight,
                                 me->level, 
                                 num_points, points );
      if ( !(1 & sts) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }
   }
   else
   {
      /* The polygon is not filled */
      num_points = ((int *)DPdlist_fb_buffer)[1] / 3;
      points = &DPdlist_fb_buffer[1];
      sts = DPdlist_add_curve( my_id, OM_Gw_current_OS, ele_flags, 
                               me->display_attr.color,
                               me->display_attr.style, 
                               me->display_attr.weight,
                               me->level, 
                               num_points, points );
      if ( !(1 & sts) )
      {
         *msg = MSFAIL;
         sts = OM_E_ERROR;
         goto wrapup;
      }

   }

wrapup:
   DLreset_feedback( DPdlist_wf_fb_pipe_id );
   ((WLuint16 *)DPdlist_fb_buffer)[0] = 0;
   ((WLuint16 *)DPdlist_fb_buffer)[1] = 0;


   DPdlist_feedback_in_progress = FALSE;

   return( sts );

} /* GRadd_to_display_list */

end implementation  GRorthpoly;

   
