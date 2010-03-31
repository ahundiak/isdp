/* ###################   APOGEE COMPILED   ################## */
/*
	SM	Many moons ago		Creation.
	SM	27-Jun-89		If edge not owned by active loop
					try to get the surface info via 
					any (including inactive) loop as
					a last attempt.
*/
class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"

method EMgetsurface_info(IGRlong *EMmsg;GRobjid *srfid;
			 struct EMSpartolbasis *partolbasis)
{
  IGRlong 		sts,rc;
  extern IGRint		EMcount_partedges(), EMsend_loops(), EMcount_loops();
  IGRint		i, num_partedges = 0, num_loops = 0;
  OM_S_OBJECT_LINKAGE	*partedges = NULL, *loops = NULL;


  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(srfid)   *srfid = NULL_OBJID;
  if(partolbasis) partolbasis->is_valid = FALSE;

  sts = EMsend_loops(&rc,message EMSboundary.EMgetsurface_info
			   (EMmsg,srfid,partolbasis),my_id,0,0,
                            EMLP_ACTIVE,NULL,NULL);
  if(!(1&*EMmsg&sts)) goto wrapup;

  /* If I had no path upto the surface then try through my partedges
  */
  if( (partolbasis && !partolbasis->is_valid) ||
      (srfid && IF_NULL_OBJID(*srfid)))
   {
    sts = EMcount_partedges(EMmsg, my_id, &num_partedges, &partedges, 
			    NULL, NULL, NULL);
    if(!(1&*EMmsg&sts)) goto wrapup;
    for(i=0; i<num_partedges; i++)
     {
      sts = om$send(msg = message EMSboundary.EMgetsurface_info
				(EMmsg, srfid, partolbasis), 
			targetid = partedges[i].S_objid);
      if(!(1&*EMmsg&sts)) break;
      if(partolbasis && partolbasis->is_valid) break;
      if(srfid && !IF_NULL_OBJID(*srfid)) break;
     }
   }

  /* If no path to the surface via active loop or the partedges, try
     through any loop which owns this edge.
  */
  if( (partolbasis && !partolbasis->is_valid) ||
      (srfid && IF_NULL_OBJID(*srfid)))
   {
    sts = EMcount_loops(EMmsg, my_id, &num_loops, &loops, 
			    NULL, NULL, NULL);
    if(!(1&*EMmsg&sts)) goto wrapup;
    for(i=0; i<num_loops; i++)
     {
      sts = om$send(msg = message EMSboundary.EMgetsurface_info
				(EMmsg, srfid, partolbasis), 
			targetid = loops[i].S_objid);
      if(!(1&*EMmsg&sts) ||
          (partolbasis && partolbasis->is_valid) || 
          (srfid && !IF_NULL_OBJID(*srfid))) break;
     }
   }
  
wrapup:
  if(partedges) free(partedges);
  if(loops) free(loops);

  if( (partolbasis && !partolbasis->is_valid) ||
      (srfid && IF_NULL_OBJID(*srfid))) *EMmsg = EMS_I_NotFound;

  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMgetsurface_info");
  return(sts);
}

end implementation EMSedge;
