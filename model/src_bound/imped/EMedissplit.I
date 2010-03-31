/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the information as to whether an edge is 
 connected to a split object at the begining, at the end or both.
 The channel between edge and the split being absolute,it necessary to find
 the actual index of each object on the channel.For e.g if an edge was 
 connected to 2 splits and if one of the splits was deleted, then the
 channel count is still 2. 
	A blind send is done on each index. Empty index warning by OM is
 ignored.

Assumption
	On the absolute channel between edge and the split, begin split
 is always at index 0 of the edge and end split is always at index 1.

History
	SM	03/06/87	Creation date
*/
class implementation EMSedge;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"
#include "EMSbnddef.h"

extern OMuword	OPP_EMSsplit_class_id;

method EMissplit(IGRlong *EMmsg;IGRushort *split;GRobjid *split_obj)
{
   IGRlong               sts,i;
   GRobjid		 vtx[2];
   OM_S_CHANSELECT       to_owner, to_edges;
   OMuword		 dummy, classid;
   IGRint		 index;

   *EMmsg = EMS_S_Success;
   *split = NULL;
   if(split_obj) split_obj[0] = split_obj[1] = NULL_OBJID;

   to_owner.type = OM_e_addr;
   to_owner.u_sel.addr = &ME.EMSedge->to_owner;

   sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
   if(!(1&sts)) goto wrapup;

   for(i=0;i<2;i++)
    {
      vtx[i] = NULL_OBJID;
      
      sts = om$get_objid_at_index(object = me, p_chanselect = &to_owner, 
			index = i, objidaddr = &vtx[i], osnumaddr = &dummy);
      if(IF_NULL_OBJID(vtx[i]))
        sts = OM_S_SUCCESS;
      else
       {
	 sts = om$get_classid(objid = vtx[i], p_classid = &classid);
	 if(classid == OPP_EMSsplit_class_id)
	  {
	    sts = om$get_index(objid_c = vtx[i], p_chanselect = &to_edges, 
				objid = my_id, indexaddr =(OMuint *) &index);
	    EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

	    EMerr_hndlr( (index<0) || (index>1), *EMmsg, EMS_I_Fail, wrapup);
	
            *split |= (index == OUTGOING) ? EMSedge_BeginSplit : 
					    EMSedge_EndSplit;
	    if(split_obj) split_obj[!index] = vtx[i];
	  }
       }
    }

wrapup:
     EMWRAPUP(*EMmsg,sts,"In EMSedge.EMissplit")
     return(sts);
}   

end implementation EMSedge;
