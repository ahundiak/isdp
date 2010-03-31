 /* During the boolean processing, if the intobj->reversed flag is set, 
    the edges were reversed (set props). We need to toggle this bit in the
    copy to undo what the boolean did. For a partedge the bounds also need
    to be reversed.
    After undoing the affect of boolean processing on the intersection data
    we need to reverse the data if the reverse flag is TRUE.
 */

class implementation NMinters;

#include "EMSprop.h"
#include "EMSopt.h"

from EMSedge import EMset_props, EMgetbounds;
from EMSpartedge import EMputbounds;
extern OMuword OPP_EMSpartedge_class_id;

void NMfixIntAfterTpVal(EMmsg, inters, reverse)
IGRlong	*EMmsg;
struct EMSinters *inters;
IGRboolean reverse;
{
 IGRlong		sts;
 struct EMSinters	*this_inters;
 struct EMSintobj	*this_intobj;
 extern void		EMbreak_connection();
 extern IGRboolean	EFisAncestryValid();
 OM_S_CHANSELECT	to_comm;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 EMmake_chanselect(EMSedge_to_common_edge, &to_comm);

 this_inters = (struct EMSinters *) inters;
 while(this_inters)
  {
   this_intobj = (struct EMSintobj *) this_inters->cvs;
   while(this_intobj)
    {
     if(this_intobj->this_uvintobj.datatype == EMSdata_object)
      {
	GRobjid		junk;
	
	junk = (this_intobj->this_uvintobj.data.object)->objid;
	
	sts = om$send(msg = message EMSedge.EMset_props (EMmsg, 
		EMED_REVERSE_CONNECT, EMS_O_OFF), 
		targetid = junk, senderid = junk);
	if(!(1&*EMmsg&sts)) goto wrapup;
	
	sts = om$send(msg = message Root.wild_disconnect(to_comm), 
		targetid = junk, senderid = junk);
	if(!(1&sts)) goto wrapup;
	
	if(this_intobj->reversed)
	 {
	  sts = om$send(msg = message EMSedge.EMset_props(EMmsg, EMED_REVERSED,
		 EMS_O_TOGGLE), targetid = junk, senderid = junk);
	  if(!(1&*EMmsg&sts)) goto wrapup;
	  if(EFisAncestryValid(EMmsg, junk, OM_Gw_current_OS, 
			       OPP_EMSpartedge_class_id, FALSE))
	   {
 	    struct EMSedgebound bounds[2], tmpbound;

	    sts = om$send(msg = message EMSedge.EMgetbounds(EMmsg, bounds), 
			targetid = junk, senderid = junk);
	    if(!(1&*EMmsg&sts)) goto wrapup;
	
            tmpbound = bounds[0];
            bounds[0] = bounds[1];
            bounds[1] = tmpbound;
            sts = om$send (msg = message EMSpartedge.EMputbounds (EMmsg,
                       bounds), targetid = junk, senderid = junk);
	    if(!(1&*EMmsg&sts)) goto wrapup;	
	   }
	
	 }
      }

     if(this_intobj->other_intobj_node) 
      EMbreak_connection(this_intobj->other_intobj_node);
       EMbreak_connection(this_intobj);
     if(reverse)
      {
	IGRboolean fwd_on = FALSE, bwd_on = FALSE;
	
       this_intobj->reversed = !this_intobj->reversed;
       if(this_intobj->props & EMSintobj_bwd_noconnectuv)
        {
	 this_intobj->props &= ~EMSintobj_bwd_noconnectuv;
	 fwd_on = TRUE;
        }
       if(this_intobj->props & EMSintobj_fwd_noconnectuv)
        {
	 this_intobj->props &= ~EMSintobj_fwd_noconnectuv;
	 bwd_on = TRUE;
        }

       if(fwd_on)
        this_intobj->props |= EMSintobj_fwd_noconnectuv;	 
       if(bwd_on)
        this_intobj->props |= EMSintobj_bwd_noconnectuv;	 

      }
     this_intobj = this_intobj->next;

    }
   this_inters = this_inters->next;
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "NMfixIntAfterTpVal");
return;
}



void NMset_object_data_to_null(inters, uv, xyz)
struct EMSinters *inters;
IGRboolean uv, xyz;
{
 struct EMSinters *this_inters;
 struct EMSintobj *this_intobj;
 IGRint i;

 this_inters = inters;
 while(this_inters)
  {
   for(i=0; i<2; i++)
    {
     this_intobj = i ? this_inters->cvs : this_inters->pts;
     while(this_intobj)
      {
       if(uv && (this_intobj->this_uvintobj.datatype == EMSdata_object))
        (this_intobj->this_uvintobj.data.object)->objid = NULL_OBJID;
       if(xyz && (this_intobj->this_xyzintobj.datatype == EMSdata_object))
        (this_intobj->this_xyzintobj.data.object)->objid = NULL_OBJID;

       this_intobj = this_intobj->next;
      }
    }
   this_inters = this_inters->next;
  }
}

end implementation NMinters;
