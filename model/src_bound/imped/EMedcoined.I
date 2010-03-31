/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the coincedent edge of the target edge.
	The determination is done solely based on topological information.
	No attempt is made to perform a geometrical check to determine
	coincedency.
	The topological criterion for coincedency is -
	Non seam edge with common edge owned by the same surface. Both
	edge must be active to qualify for coincedency.
	
Return Values
	EMS_S_Success			All is well.
	EMS_I_NotFound			No coincedent edge found.
					The id returned will be NULL_OBJID
					
History
	SM	Many moons ago		Creation.
	SM	01-Mar-89		For 1.3, removed the use of dummy
					edge in the topological deduction.
					Now any common edge pair on the same
					surface (except seams) will be
					coincedent.
*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"

method EMget_coincedent_edge(IGRlong *EMmsg;
			     GRobjid *coincedent_edge)
{
  IGRlong		sts = OM_S_SUCCESS;
  OM_S_CHANSELECT	to_common_edge;
  GRobjid		my_srf = NULL_OBJID, comm_srf = NULL_OBJID;
  OMuint		count;
  OM_S_OBJECT_LINKAGE	comm;
  extern IGRlong	EMmake_chanselect();

  *EMmsg = EMS_S_Success;
  *coincedent_edge = NULL_OBJID;

  if(ME.EMSedge->ed_props & EMED_SEAM) goto wrapup;

  sts = EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

  sts = om$get_channel_objects(object = me, p_chanselect = &to_common_edge, 
			list = &comm, size = 1, count = &count);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  /* If no common edge return */
  if(!count) goto wrapup;

  sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg, &my_srf, NULL), 
			targetid = my_id);
  if(!(1&*EMmsg&sts)) goto wrapup;
  if(IF_NULL_OBJID(my_srf)) goto wrapup;

  sts = om$send(msg = message EMSedge.EMgetsurface_info(EMmsg, &comm_srf, NULL)
			, targetid = comm.S_objid);
  if(!(1&*EMmsg&sts)) goto wrapup;
  if(IF_NULL_OBJID(comm_srf)) goto wrapup;

  if(IF_EQ_OBJID(my_srf, comm_srf)) *coincedent_edge = comm.S_objid;

wrapup:
if(IF_NULL_OBJID(*coincedent_edge)) *EMmsg = EMS_I_NotFound;

EMWRAPUP(*EMmsg, sts, "In EMSedge.EMget_coincedent_edge");
return(sts);
}


end implementation EMSedge;
