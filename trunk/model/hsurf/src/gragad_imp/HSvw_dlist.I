class implementation HSviewdyn;

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
#include "HSdlist.h"

#include "hsmacdef.h"
#include "HStl_window.h"

from GRmodule import GRmdinfntptr;
from GRgraphics import GRdisyourself;

extern IGRboolean DPdlist_feedback_in_progress;

%safe
static IGRmatrix id_matrix = { 1.0, 0.0, 0.0, 0.0,
                               0.0, 1.0, 0.0, 0.0,
                               0.0, 0.0, 1.0, 0.0,
                               0.0, 0.0, 0.0, 1.0 };
%endsafe

/* old prototypes */
#include "hstiler.h"
#include "HSe2_mesher.h"
#include "HStl_element.h"
#include "HSpr_driver.h"

/* new prototypes */
PROTO_HSdlist_save_tri_mesh

method DPsetup_for_dlist_feedback(IGRlong *msg; IGRboolean setup_dl )

{

   WLuint16 lscreen_no;

   om$send( mode = OM_e_wrt_message,
            msg = message GRviewdyn.DPsetup_for_dlist_feedback( msg, FALSE ),
            targetid = my_id );

   me->gragad.gpipe_id = 0xBADFACE;
   me->shading_style = HS_STYLE_SMOOTH;

   DPdlist_feedback_in_progress = TRUE;
   /* ignore returned status; 0 - is logical screen number, which */
   /* is nonsense for this gragad because it doesn't have an      */
   /* associated window                                           */
   HSinit_shading_window( 0, me->win_no, me->gragad.gpipe_id, NULL, 
                          NULL, me->shading_style, NULL_OBJID, 0 ); 

   DPdlist_feedback_in_progress = FALSE;

   /*
    * Set the world-to-viewport scale.  This allows us to tile to the
    * original window tolerance.
    */
   active_window->wv_scale = 1.0;

   /*
    * Set the transform matrix so that the buffered facets will be in
    * world coordinates.
    */
   HSset_active_transformation( id_matrix );

   /*
    * Set the rotate matrix so that the buffered facet normals will be in
    * world coordinates.
    */

   HSset_active_rotation( id_matrix );
   if (active_window->perspective == FALSE)
   {
      /* set the perspective scales */
      active_window->perspective = FALSE;   
      HSset_active_perspective_scales( 1.0, 1.0, 1.0 );
   }
   
   HSset_feedback_mode( FALSE );

   active_window->process_facet = HSsave_facet;
   active_window->process_mesh = HSdlist_save_tri_mesh;

   *msg = MSSUCC;
   return( OM_S_SUCCESS );
   }

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
   07/12/93 Shridar Subramanian
      Initial specification, design, and implementation
*/

{
   IGRlong sts;
   IGRshort matrix_type = MAIDMX;
   enum GRdpmode dp_mode = GRbd;
   struct DP_information dp_info;

   dp_info.gragad = &ME.IGEgragad->gragad;
   dp_info.win_no = ME.IGEgadget->win_no;
   dp_info.is_update = FALSE;
   dp_info.is_fit = FALSE;
   dp_info.is_hidden_line = TRUE;

   dp_info.hline_info = NULL;
   dp_info.hl_tiler = HStile_object;
   dp_info.view_objid = my_id;
   dp_info.view_osnum = OM_Gw_current_OS;

   HSset_feedback_mode( TRUE );

   sts = om$send( msg = message GRgraphics.GRdisyourself( msg,
                                                          &matrix_type,
                                                          id_matrix,
                                                          &dp_mode,
                                                          NULL,
                                                          &dp_info,
                                                          NULL ),
                  targetid = objid,
                  targetos = osnum );

   HSset_feedback_mode( FALSE );

   return( sts );

} /* DPdisplay_for_dlist */

end implementation HSviewdyn;

