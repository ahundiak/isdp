/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMSptgralp;

#include "EMS.h"
#include "emsgeteddef.h"

method EMnext_edge( IGRlong           *EMmsg; 
                    IGRushort  option;
                    GRobjid            ref_edge, 
                                      *edge )
{
   IGRlong          sts;
   OM_S_CHANSELECT  to_comps;
   OMuword          dum;

   *EMmsg = EMS_I_OpenLoop;
   sts = OM_S_SUCCESS;

   if( option & EMGetEd_NonDegenerate )  
   {
      *EMmsg = EMS_I_OutOfBounds;
      *edge = NULL_OBJID;
   }
   else
   {
      to_comps.type = OM_e_addr;
      to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;
      sts = om$get_objid_at_index( object       =  me, 
                                   p_chanselect = &to_comps, 
                                   index        =  0,
                                   objidaddr    =  edge, 
                                   osnumaddr    = &dum );
   }

   EMWRAPUP( *EMmsg, sts, "In EMSptgralp.EMnext_edge" );
   return( sts );
}

end implementation EMSptgralp;
