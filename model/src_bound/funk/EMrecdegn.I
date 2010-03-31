/* ###################   APOGEE COMPILED   ################## */
/*
*/

class implementation EMSloopset;

#include "EMS.h"
#ifndef DEBUG
#define DEBUG	0
#endif

#include "emssfint.h"
#include "OMmacros.h"
#include "emsimpdef.h"
#include "emsgeteddef.h"
#include "emsinterdef.h"
#include "emstplydel.h"
#include "bsparameters.h"
#include "bserr.h"

%safe
static void EMtrim_block_move();
%endsafe

from EMSloop import EMget_props, EMreverse, EMset_props;
from EMSopenloop import EMolpinit;
from EMSgraloop import EMglpinit;

extern OMuword OPP_EMSptgralp_class_id, OPP_EMSptedge_class_id, 
	       OPP_EMSgraloop_class_id;
	
IGRint	EMrecord_degeneracy(EMmsg, num_loops, loops, trim_info, degn_flags, 
			    options, sfos, partolbasis, lpset)
IGRlong			*EMmsg;
IGRint			num_loops;
GRobjid			*loops;
struct EMSsfintedpar	**trim_info;
IGRboolean		*degn_flags;
IGRushort	options;
GRspacenum		sfos;
struct EMSpartolbasis	*partolbasis;
GRobjid			lpset;
{
 IGRlong		sts;
 IGRushort	props;
 OMuint			numedges = 0;
 IGRint                 i;
 OMuword		lpclass;
 OM_S_CHANSELECT	to_edges;
 IGRboolean		isfeature = FALSE;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<num_loops; i++)
  {
   degn_flags[i] = FALSE;
   isfeature = FALSE;

   sts = om$send(msg=message EMSloop.EMget_props(EMmsg,&props),
			senderid = loops[i], 
			targetid = loops[i], targetos = sfos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = om$get_classid(objid = loops[i], osnum = sfos, p_classid = &lpclass);
   if(!(1&*EMmsg&sts)) goto wrapup;
   
   if( (lpclass == OPP_EMSgraloop_class_id) ||
       ((sts = om$is_ancestry_valid(subclassid = lpclass, 
				   superclassid = OPP_EMSgraloop_class_id))
	== OM_S_SUCCESS)) isfeature = TRUE;
	
   if(!isfeature)
    {
     sts = om$get_channel_count(objid = loops[i], osnum = sfos, 
			p_chanselect = &to_edges, count = &numedges);
     if(!(1&sts)) goto wrapup;
     if(numedges == 1)
      {
       GRobjid	edgeid;
       OMuword	edgeclassid;

       sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &edgeid), 
			senderid = loops[i], targetos = sfos, 
			p_chanselect = &to_edges);
       if(!(1&*EMmsg&sts)) goto wrapup;
       sts = om$get_classid(objid = edgeid, osnum = sfos, 
				p_classid = &edgeclassid);
       if(!(1&sts)) goto wrapup;
       if( (edgeclassid == OPP_EMSptedge_class_id) ||
	 ((sts = om$is_ancestry_valid(subclassid = edgeclassid, 
		superclassid = OPP_EMSptedge_class_id)) == OM_S_SUCCESS))
        {
	 GRobjid	surfid = NULL_OBJID;

	 sts = om$send(msg = message EMSloopset.EMgetsurface_info
				(EMmsg, &surfid, NULL), targetid = lpset, 
		targetos = sfos, senderid = lpset);
         if(!(1&*EMmsg&sts)) goto wrapup;

         sts = om$change_class(objid = loops[i],  osnum = sfos, 
                          classname = "EMSptgralp", 
                          sd_override = OM_K_change_class_sd_override);
         if(!(1&sts)) goto wrapup;
	 sts = om$send(msg = message EMSgraloop.EMglpinit
			(EMmsg, props, partolbasis, surfid), 
			targetid = loops[i], senderid = loops[i], 
			targetos = sfos);
         if(!(1&*EMmsg&sts)) goto wrapup;			
	 isfeature = TRUE;
        }
      }
    }

   if(isfeature) 
    {
     if(!IF_NULL_OBJID(trim_info[i]->edgeid) && 
        !IF_NULL_OBJID(trim_info[i]->next->edgeid)) 
      {
       sts = om$change_class(objid = loops[i],  osnum = sfos, 
                          classname = "EMSloop", 
                          sd_override = OM_K_change_class_sd_override);
       if(!(1&sts)) goto wrapup;
       sts = om$send(msg = message EMSloop.EMset_props
			(EMmsg, EMLP_NOAREA_NOHOLE, EMS_O_OFF), 
			targetid = loops[i], senderid = loops[i], 
			targetos = sfos);
       if(!(1&sts)) goto wrapup;
      }
     degn_flags[i] = TRUE;
     continue;
    }

   if(!(props & EMLP_OPEN)) continue;

   if(!IF_NULL_OBJID(trim_info[i]->edgeid) && 
      !IF_NULL_OBJID(trim_info[i]->next->edgeid)) continue;

   degn_flags[i] = TRUE;

   /* For the degenerate loop to represent a C loop, its begin point should
      not be dangling. If However both ends are dangling, it does not
      matter.
   */
   if(!(IF_NULL_OBJID(trim_info[i]->edgeid) && 
        IF_NULL_OBJID(trim_info[i]->next->edgeid)))
    {
     if(IF_NULL_OBJID(trim_info[i]->edgeid))
      {
	struct EMSsfintedpar junk;
       sts = om$send(msg = message EMSloop.EMreverse(EMmsg), 
			senderid = loops[i], targetid = loops[i], 
			targetos = sfos);
       if(!(1&*EMmsg&sts)) goto wrapup;
       EMtrim_block_move(trim_info[i], &junk);
       EMtrim_block_move(trim_info[i]->next, trim_info[i]);
       EMtrim_block_move(&junk, trim_info[i]->next);       
      }
    }
   /* change class to EMSopenloop and initialize the loop
    */
   sts = om$change_class(objid = loops[i],  osnum = sfos, 
                          classname = "EMSopenloop", 
                          sd_override = OM_K_change_class_sd_override);
   if(!(1&sts)) goto wrapup;
   
   sts = om$send(msg = message EMSopenloop.EMolpinit(EMmsg, props, 
			partolbasis, TRUE), targetid = loops[i], 
			senderid = loops[i], 
			targetos = sfos);
   if(!(1&sts&*EMmsg)) goto wrapup;

   if(IF_NULL_OBJID(trim_info[i]->edgeid) && 
      IF_NULL_OBJID(trim_info[i]->next->edgeid)) continue;
   else
    {
     sts = om$change_class(objid = loops[i],  osnum = sfos, 
                          classname = "EMSloop", 
                          sd_override = OM_K_change_class_sd_override);
     if(!(1&sts)) goto wrapup;
    }

   if(IF_NULL_OBJID(trim_info[i]->edgeid))
    EMtrim_block_move(trim_info[i]->next, trim_info[i]);
   else if(IF_NULL_OBJID(trim_info[i]->next->edgeid))
    EMtrim_block_move(trim_info[i], trim_info[i]->next);
  }

wrapup:
if(!(1&*EMmsg&sts)) *EMmsg = EMS_E_IntersectTrim;
return(sts);
}

static void EMtrim_block_move(from_add, to_add)
struct EMSsfintedpar *from_add, *to_add;
{
 struct EMSsfintedpar	*junk;
 junk = to_add->next;
 OM_BLOCK_MOVE(from_add, to_add, sizeof(struct EMSsfintedpar));
 to_add->next = junk;
}
end implementation EMSloopset;

