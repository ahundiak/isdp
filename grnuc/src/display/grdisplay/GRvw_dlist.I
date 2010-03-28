class implementation GRviewdyn;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "godef.h"

#include "madef.h"
#include "dpdef.h"

#include "wl.h"
#include "dl.h"

#include "exmacros.h"

#include "DPdlist.h"

extern IGRdouble *DPdlist_fb_buffer;
extern IGRdouble DPdlist_stroke_tolerance;
extern int DPdlist_wf_fb_pipe_id;

/* Old Prototypes */
#include "maidmx.h" /* MAidmx() */
#include "dpmtxstack.h" /* DPpush_vwmtx() */
#include "dpclpstack.h" /* DPpush_clip() */
#include "dpsetrng.h" /* DPsetrng() */

from GRmodule import GRmdinfntptr;
from GRgraphics import GRdisyourself;

%safe
static IGRmatrix id_matrix = { 1.0, 0.0, 0.0, 0.0,
                               0.0, 1.0, 0.0, 0.0,
                               0.0, 0.0, 1.0, 0.0,
                               0.0, 0.0, 0.0, 1.0 };
%endsafe

method DPsetup_for_dlist_feedback( IGRlong *msg; IGRboolean setup_dl )

/*
NAME
   IGEgragad.DPsetup_for_dlist_feedback

DESCRIPTION
   This method sets up an IGEgragad object as the feedback pipeline
   for display list stroking

SYNOPSIS
   method DPsetup_for_dlist_feedback(
      IGRlong *msg,
      IGRboolean setup_dl )

PARAMETERS
   msg (OUT) - status return
   setup_dl (IN) - if TRUE, initialize DL for this window

GLOBALS USED
   DPdlist_fb_buffer
   DPdlist_stroke_tolerance

RETURN VALUES
   OM_S_SUCCESS - Success
   OM_E_ERROR - Failure

HISTORY
   05/10/93 S.P. Rogers
      Initial specification and design
   05/13/93 S.P. Rogers
      Initial implementation
*/
   
{
   IGRint ii;
   IGRdouble *dbl_ptr1, *dbl_ptr2, *dbl_ptr3;
   IGRdouble id_mtx[16];
   int sts;
   GRspacenum mod_osnum;
   OM_S_OBJID mod_objid;
   struct  GRid	   fontid;   /* font manager objid and osnum  */


   /* initialize this View Dynamics gragad */
   *msg = MSSUCC;

   me->gragad.flags = DPVIEW_DYNAMICS | AXIS_WLD_ALIGN | IS_WIN_ON;

   /* grid parameters */
   me->gragad.uor_per_ref_x = DEF_UOR_PER_REF;
   me->gragad.uor_per_ref_y = DEF_UOR_PER_REF;
   me->gragad.grid_per_ref_x = DEF_GRID_PER_REF;
   me->gragad.grid_per_ref_y = DEF_GRID_PER_REF;

   me->gragad.origin[0] = 0.0;
   me->gragad.origin[1] = 0.0;
   me->gragad.origin[2] = 0.0;

   for ( ii = 0; ii < 32; ii++ )
   {
      me->gragad.levels[ii] = 0xFFFFFFFF;
   }

   me->gragad.act_z = 0.0;

   me->gragad.vvol_viewport_scale = 1.0;

   me->gragad.vw_volume[0] =
   me->gragad.vw_volume[1] = 
   me->gragad.vw_volume[2] = GRDGNLIMITS_MIN_D;
   me->gragad.vw_volume[3] =
   me->gragad.vw_volume[4] = 
   me->gragad.vw_volume[5] = GRDGNLIMITS_MAX_D;

   me->gragad.dit_clip_range[0] =
   me->gragad.dit_clip_range[1] = 
   me->gragad.dit_clip_range[2] = GRDGNLIMITS_MIN_D;
   me->gragad.dit_clip_range[3] =
   me->gragad.dit_clip_range[4] = 
   me->gragad.dit_clip_range[5] = GRDGNLIMITS_MAX_D;

   MAidmx( msg, id_mtx );

   dbl_ptr1 = (IGRdouble *)me->gragad.rotation;
   dbl_ptr2 = (IGRdouble *)me->gragad.wld_to_viewport;
   dbl_ptr3 = (IGRdouble *)me->gragad.viewport_to_wld;

   for ( ii = 0; ii < 16; ii++ )
   {
      *dbl_ptr1++ = id_mtx[ii];
      *dbl_ptr2++ = id_mtx[ii];
      *dbl_ptr3++ = id_mtx[ii];
   }

   DPsetrng( msg, (IGRdouble *)me->gragad.wld_to_viewport,
             &me->gragad.range_chk );

   ex$get_cur_mod( id = &mod_objid, osnum = &mod_osnum );

   /* make sure the font mgr has been created */
   sts = ex$get_super( mod_id = mod_objid,
                       mod_osnum = mod_osnum,
                       super_name = "GRFONTMGR",
                       create = TRUE,
                       super_class = "GRfm",
                       super_id = &fontid.objid,
                       super_osnum = &fontid.osnum );

   sts = om$send( msg = message GRmodule.GRmdinfntptr( msg,
                                                       &me->gragad.fnt_os_ptr ),
                  senderid = NULL_OBJID,
                  targetos = mod_osnum,
                  targetid = mod_objid );

   if ( setup_dl )
   {
      /* the senderid is not me, so I'll initialize the DL stuff      */
      /* If the sender_id is my_id, then the HSURF override of this   */
      /* message sent back w.r.t message and it doesn't want DL stuff */
      /* initialized (pretty tricky, huh)                             */

      /* create gpipe feedback buffer */
      if ( DLcreate_feedback_pipeline( DL_ORTHO_PIPE, DPdlist_fb_buffer,
           DP_DLIST_FB_BUFFER_SIZE / sizeof(IGRdouble) , &me->gragad.gpipe_id ) != DL_SUCCESS )
      {
         *msg = MSFAIL;
         return( OM_E_ERROR );
      }

      DPdlist_wf_fb_pipe_id = me->gragad.gpipe_id;

      /* ??? what should this be ??? */
      DLset_curve_max_points( me->gragad.gpipe_id, 100 );

      DPpush_vwmtx( msg, id_mtx, me->gragad.vvol_viewport_scale, me->gragad.gpipe_id,
                    NULL, NULL, NULL );

      /* dit tolerance is equivalent to world tolerance (mapping world to world)  */
      DLset_curve_tolerance( me->gragad.gpipe_id,
                             DPdlist_stroke_tolerance,
                             DPdlist_stroke_tolerance );

      DPpush_clip( msg, FALSE, FALSE, FALSE, me->gragad.dit_clip_range, me->gragad.gpipe_id,
                   me->gragad.vw_volume );
   }

   return( OM_S_SUCCESS );
} /* DPsetup_for_dlist_feedback */


method DPdisplay_for_dlist(
   IGRlong *msg;
   OM_S_OBJID objid;
   OMuword osnum )

/*
NAME
   GRviewdyn.DPdisplay_for_dlist

DESCRIPTION
   This method sends a GRdisyourself message to an object so its strokes
   will be placed in a feedback buffer that can be copied into the display
   list.

SYNOPSIS
   method DPdisplay_for_dlist(
      IGRlong *msg;
      OM_S_OBJID objid;
      OMuword osnum )

PARAMETERS
   msg (OUT) - status return
   objid (IN) - the object id of the elemetn to display
   osnum (IN) - the object space number of the element

GLOBALS USED
   id_matrix (static)

RETURN VALUES
   OM_S_SUCCESS - Success
   Anything else - Error

HISTORY
   06/03/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   IGRlong sts;
   IGRshort matrix_type = MAIDMX;
   enum GRdpmode dp_mode = GRbd;
   struct DP_information dp_info;
   IGRdouble os_scale;

   dp_info.gragad = &ME.IGEgragad->gragad;
   dp_info.win_no = ME.IGEgadget->win_no;
   dp_info.is_update = FALSE;
   dp_info.is_fit = FALSE;
   dp_info.is_hidden_line = FALSE;

   dp_info.hline_info = NULL;
   dp_info.hl_tiler = NULL;
   dp_info.view_objid = my_id;
   dp_info.view_osnum = OM_Gw_current_OS;

   DPdlist_get_object_space_scale( osnum, &os_scale );

   /* set tolerance according to the object space the object is in */
   DLset_curve_tolerance( me->gragad.gpipe_id,
                          DPdlist_stroke_tolerance / os_scale,
                          DPdlist_stroke_tolerance / os_scale );

   sts = om$send( msg = message GRgraphics.GRdisyourself( msg,
                                                          &matrix_type,
                                                          id_matrix,
                                                          &dp_mode,
                                                          NULL,
                                                          &dp_info,
                                                          NULL ),
                  targetid = objid,
                  targetos = osnum );

   /* reset tolerance back to that of the master file */
   DLset_curve_tolerance( me->gragad.gpipe_id,
                          DPdlist_stroke_tolerance,
                          DPdlist_stroke_tolerance );

   return( sts );

} /* DPdisplay_for_dlist */

end implementation GRviewdyn;

