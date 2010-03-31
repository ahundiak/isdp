/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/*
Notes
        This method determines the location of a point(2D) with respect to a
        loop. The location returned is one of the following - 
        EMS_L_ONVRTX   - point was on vertex
        EMS_L_OUTSIDE  - point was outside the loop.
*/

class implementation EMSptgralp;

#include "EMS.h"

from EMSedge import EMpt_location;

method EMpt_location( IGRlong               *EMmsg;
                      IGRdouble             *point;  
                      struct EMSptloc_info  *location;
                      struct EMSpartolbasis *partolbasis )
{
    IGRlong           sts = OM_S_SUCCESS,
                      msg = EMS_S_Success;

    OM_S_CHANSELECT          to_edges;



   location->num_located_edges=0;
   location->location = EMS_L_UNKNWN;
   location->loop_id = my_id;


   /* 
    * If the option specifies that the input point is to be processed only by
    * active loops and if I am inactive then just return.
    */
   if(( location->options & EMS_PTLOC_ACTLOOP ) &&
       ( !( ME.EMSloop->lp_props & EMLP_ACTIVE )))
         goto wrapup;

   to_edges.type = OM_e_addr;
   to_edges.u_sel.addr = &ME.EMSbd_owner->to_comps;

   sts = om$send( msg = message EMSedge.EMpt_location( &msg,
                                                        point,
                                                        location, 
                                                        NULL,
                                                        partolbasis ),
                  p_chanselect = &to_edges );
   EMerr_hndlr( !( 1 & msg & sts ), msg, EMS_E_EdgeError, wrapup );

   if( location->location != EMS_L_ONVRTX )
       location->location = EMS_L_OUTSIDE;


wrapup:
   if( ! & msg & sts ) msg = EMS_I_DegenerateLoop;
   EMWRAPUP( msg, sts, "In EMSptgralp.EMpt_location" )

   return( sts );   
}

end implementation EMSptgralp;
