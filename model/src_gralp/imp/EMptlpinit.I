/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
Notes
        This method initializes a loop. The properties bit mask should be
        sent to this method.The range box of the loop is updated.
*/
class implementation EMSptgralp;

#include "EMS.h"

from EMSedge import EMgetrange;

method EMptlpinit( IGRlong           *EMmsg;
                   IGRushort  props )
{
  IGRlong                sts;
  OM_S_CHANSELECT        to_edges;

  to_edges.type = OM_e_addr;
  to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

  
  ME.EMSloop->lp_props = props | EMLP_NOAREA_NOHOLE;

  sts = om$send( msg = message EMSedge.EMgetrange( EMmsg,
                                                   ME.EMSloop->range,
                                                   NULL ),
                 p_chanselect = &to_edges );
  if( !( 1 & *EMmsg & sts )) goto wrapup;

wrapup:
  EMWRAPUP( *EMmsg, sts, "In EMSptgralp.EMlpinit" )
  return( sts );
}

end implementation EMSptgralp;


