/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgraloop;

#include "EMS.h"
#include "emsmacros.h"

from EMSsubbs import EMpartolbasis;

method EMgetsurface_info(IGRlong *EMmsg;GRobjid *srfid;
			 struct EMSpartolbasis *partolbasis)
{
  IGRlong 		sts;
  OM_S_CHANSELECT	to_requesters;
  OMuint		sf;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  sts = EMmake_chanselect (EMShelper_to_requesters, &to_requesters);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* If the graphic loop has no surface (requester) then quit.
*/
  sts = om$get_channel_count(objid = my_id,
                             p_chanselect = &to_requesters,
			     count = &sf);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  if(!sf)
   {
      if(srfid) *srfid = NULL_OBJID;
      *EMmsg = EMS_I_NotFound;
   }
  else
   {
/* If the parametric tolerance is desired, get it from the surface. The
   'compute_new' flag given to the surface is '!is_valid'. If the 'is_valid'
   flag in the structure is FALSE, that means the tolerance has to be
   recomputed.
*/
     if(partolbasis)
      {
        sts = om$send(msg=message EMSsubbs.EMpartolbasis
			(EMmsg,partolbasis->mattyp,partolbasis->mat,
			 &partolbasis->in_world,!partolbasis->is_valid,
			 &partolbasis->tol),p_chanselect=&to_requesters);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_F_Fail,wrapup);
        partolbasis->is_valid = TRUE;
      }
     if(srfid)
      {
        OM_S_OBJECT_LINKAGE	srf;
        OMuint			count;

        sts = om$get_channel_objects(objid = my_id,
                                     p_chanselect = &to_requesters,
				     list=&srf,
                                     size=1,
                                     count=&count);
        if((!(1&sts)) || (count!=1)){*EMmsg=EMS_F_Fail; goto wrapup;}
        else *EMmsg=EMS_S_Success;
        *srfid = srf.S_objid;
      }
   }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSgraloop.EMgetsurface_info")
  return(sts);
}

end implementation EMSgraloop;
