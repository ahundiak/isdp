class implementation NMvertex_use;

#include "OMmacros.h"

method NMgetsurface_info(IGRlong *EMmsg; GRobjid *sfid; 
			  struct EMSpartolbasis *ptol)
{
 IGRlong	sts = OM_S_SUCCESS;
 IGRint		numeds = 0, i;
 GRobjid	*eds = NULL;

 
 *EMmsg = EMS_S_Success;

 if(sfid) *sfid = NULL_OBJID;
 if(ptol) ptol->is_valid = FALSE;

 sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
       NULL_OBJID, &numeds, &eds, NULL, NULL, NULL, NULL, 
       NMquery_InTransientState), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<numeds; i++)
  {
   struct GRid junked, junksf;

   junked.objid = eds[i];
   junksf.osnum = junked.osnum = OM_Gw_current_OS;
   junksf.objid = NULL_OBJID;

   sts = NMfind_sf_no_matter_what(EMmsg, &junked, sfid ? &junksf : NULL, 
	 ptol, NULL);
   if(sfid && !IF_NULL_OBJID(junksf.objid))
    {
     *sfid = junksf.objid;
     goto wrapup;
    }

   if(ptol && ptol->is_valid) goto wrapup;
  }
 
 *EMmsg = EMS_I_NotFound;

wrapup:
if(eds) om$dealloc(ptr = eds);
EMWRAPUP(*EMmsg, sts, "NMvertex_use.NMgetsurface_info");
return(sts);
}

end implementation NMvertex_use;
