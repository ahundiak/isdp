class implementation GRpoint;

#include "wl.h"
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
   This method is an override of the GRadd_to_display_list defined in GRgraphics
 
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

   *msg = MSSUCC;
   *msg = MSSUCC;
   sts = OM_S_SUCCESS;
   DPdlist_feedback_in_progress = TRUE;

   /* display point to get its strokes in the feedback buffer */
   sts = om$send( msg = message GRviewdyn.DPdisplay_for_dlist( msg, my_id, 
                                                               OM_Gw_current_OS),
                  targetid = DPdlist_wf_fb_gragad.objid,
                  targetos = DPdlist_wf_fb_gragad.osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & *msg) )
   {
      goto wrapup;
   }

   if ( ((WLuint16 *)DPdlist_fb_buffer)[0] == 0 )
   {
      /* nothing added to feedback buffer */
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   points = &DPdlist_fb_buffer[1]; 

   sts = DPdlist_set_element_flags( my_id, OM_Gw_current_OS, &ele_flags );
   if ( !(1 & sts) )
   {
      *msg = MSFAIL;
      sts = OM_E_ERROR;
      goto wrapup;
   }

   sts = DPdlist_add_point( my_id, OM_Gw_current_OS, ele_flags, me->display_attr.color,
                            me->display_attr.style, me->display_attr.weight,
                            me->level, points );
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

end implementation GRpoint;

