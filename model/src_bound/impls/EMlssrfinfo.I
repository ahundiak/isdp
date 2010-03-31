/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#include "emsmacros.h"

from EMSsubbs import EMpartolbasis;

method EMgetsurface_info(IGRlong *EMmsg;GRobjid *srfid;
			 struct EMSpartolbasis *partolbasis)
{
  IGRlong 		sts;
  OM_S_CHANSELECT	to_surface;
  OMuint		sf;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

  sts = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

/* If the loopset has no surface then quit.
*/
  sts = om$get_channel_count(object=me,p_chanselect=&to_surface,
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
			 &partolbasis->tol),p_chanselect=&to_surface);
        EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_F_Fail,wrapup);
        partolbasis->is_valid = TRUE;
      }
     if(srfid)
      {
        OM_S_OBJECT_LINKAGE	srf;
        OMuint			count;

        sts = om$get_channel_objects(object=me,p_chanselect=&to_surface,
				  list=&srf,size=1,count=&count);
        if((!(1&sts)) || (count!=1)){*EMmsg=EMS_F_Fail; goto wrapup;}
        else *EMmsg=EMS_S_Success;
        *srfid = srf.S_objid;
      }
   }

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSloopset.EMgetsurface_info")
  return(sts);
}

end implementation EMSloopset;
