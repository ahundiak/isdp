/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSptgralp;

#include "EMS.h"

#include "emsdef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsgeteddef.h"

from EMSloopset import EMnesting,
                       EMtreemod, 
                       EMget_props;

method EMcloseyourself( IGRlong               *EMmsg;
                        GRobjid               *loopset;
                        IGRboolean            *closed;
                        struct EMSpartolbasis *partolbasis )
{
   IGRlong               sts;
   GRobjid               surfid = NULL_OBJID;
   struct EMSnest_info   nesting;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   EMerr_hndlr( !loopset, *EMmsg, EMS_I_Useless, wrapup );

   sts = om$send( msg = message EMSboundary.EMgetsurface_info( EMmsg, 
                                                              &surfid, 
                                                               NULL ), 
                  targetid = *loopset );
   EMerr_hndlr(!( 1 & *EMmsg & sts ), *EMmsg, EMS_E_LoopError, wrapup );

   ME.EMSloop->lp_props &= ~EMLP_OPEN;
   sts = om$send( msg = message EMSgraloop.EMglpinit( EMmsg, 
                                                      ME.EMSloop->lp_props, 
                                                      partolbasis, 
                                                      surfid ), 
                  targetid = my_id );
   EMerr_hndlr(!( 1 & *EMmsg & sts ), *EMmsg, EMS_E_LoopError, wrapup );

   nesting.loopid = my_id;
   nesting.lp_props = ME.EMSloop->lp_props;
   nesting.parent = *loopset;
   sts = om$send( msg = message EMSloopset.EMget_props( EMmsg, 
                                             (IGRushort *)&nesting.parent_props ),
                  targetid = *loopset );
   OM_BLOCK_MOVE( ME.EMSloop->range, nesting.range, 4 * sizeof(IGRdouble));
   sts = om$send( msg = message EMSloopset.EMtreemod( EMmsg,
                                                     &nesting,
                                                      ADD_CHILD,
                                                      partolbasis ),
                  targetid = nesting.parent );
   EMerr_hndlr(!( 1 & *EMmsg & sts ), *EMmsg, EMS_E_LoopsetError, wrapup );
    
wrapup:
   EMWRAPUP( *EMmsg, sts, "EMSptgralp.EMcloseyourself" )
   return( sts );
}

end implementation EMSptgralp;
