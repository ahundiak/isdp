/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSgraloop;

#include "EMS.h"
#include "msdef.h"             /* MS error codes   */
#include "EMSfrtdef.h"         /* EMGL_NO_DISPLAY  */

from EMSedge import EMlocate;

method EMlocate( IGRlong               *EMmsg; 
                 struct IGRbsp_surface *surface;
                 struct GRlc_info      *loc_parms; 
                 struct GRlc_cvl       *cvl;
                 IGRlong               *prism_rel; 
                 IGRboolean            *inside, 
                                       *outside,
                                       *overlap,
                                       *was_located; 
                 struct GRid           *window_id )
/*
History

    09 December 1987   AIC   Creation Date
    10 APRIL    1991   SCW   Converted from old feature loop code
    29 JULY     1991   SCW   Added check for no_display flag
*/
{
  IGRlong           sts,  
                    msg1;
  OM_S_CHANSELECT   to_edges;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  msg1 = MSSUCC;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  if( !( ME.EMSloop->lp_props & EMLP_ACTIVE ))  goto wrapup;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &me^^EMSbd_owner.to_comps;

  sts = om$send( msg = message EMSedge.EMlocate(&msg1, 
                                                 surface, 
                                                 NULL, 
                                                 NULL,
                                                 loc_parms, 
                                                 cvl, 
                                                 prism_rel, 
                                                 inside, 
                                                 outside, 
                                                 overlap,
                                                 FALSE, 
                                                 was_located ), 
                 p_chanselect = &to_edges );
  if( !( 1 & msg1 & sts ))  goto wrapup;

  if( *was_located )  sts = OM_I_STOP_SENDING;

wrapup:

  EMSmsgReport( sts, "EMSgraloop.EMlocate", FALSE );

  return( OM_S_SUCCESS );
}

end implementation EMSgraloop;
