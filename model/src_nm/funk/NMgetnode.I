/*
nodeidarray, numnodes and bufsize arguments are used only if the option
is NMgetnode_All.
For options requiring single node output, the argument 'nodeid' is used.
*/
class implementation NMnonmani;

#include "OMmacros.h"
#include "emsmacros.h"
#include "EMSprop.h"
#include "nm.h"

extern OMuword OPP_NMnonmani_class_id, OPP_GRconnector_class_id, OPP_EMSdprparam_class_id,
               OPP_GRgrgrp_class_id;

#define StaticBuf	10
#define Inc		3

from EMSsurface import EMgetactiveid;
from EMSdpr import EMget_dpr_props;

IGRint NMget_node(EMmsg, refid, stopid, stopclsid, nodeidarray, numnodes, 
		  bufsize, nodeid, options)
IGRlong *EMmsg;
struct GRid *refid, *stopid, **nodeidarray, *nodeid;
OMuword *stopclsid;
IGRint *numnodes, *bufsize;
IGRushort options;
{
 IGRlong 		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_owners;
 OM_S_OBJECT_LINKAGE	*owners = NULL, ownersbuf[StaticBuf];
 IGRint			numowners = 0, i;
 struct GRid		locnodeid;

 *EMmsg = EMS_S_Success;

 locnodeid = *refid;

 /* If the reference node is a surface/solid, skip all the inactive DPR
    nodes.
 */
 if(EFisAncestryValid(EMmsg, refid->objid, refid->osnum, 
    OPP_EMSsurface_class_id, FALSE))
  {
   sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg, &locnodeid, 
         NULL), targetid = refid->objid, targetos = refid->osnum, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 while(!IF_NULL_OBJID(locnodeid.objid))
  {
   if(options & NMgetnode_All)
    {
     if(!*bufsize)
      {
       if(*nodeidarray)
        *nodeidarray = (struct GRid *) om$realloc(ptr = (IGRchar *) *nodeidarray, 
                       size = (Inc + *numnodes) * sizeof(struct GRid));
       else
        *nodeidarray = (struct GRid *) om$malloc(size = Inc * 
                       sizeof(struct GRid));
       EMerr_hndlr(!*nodeidarray, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       *bufsize = Inc;
      }

     (*nodeidarray)[(*numnodes)++] = locnodeid;
     (*bufsize)--;
    }
   else *nodeid = locnodeid;

   sts = EMmake_chanselect(GRconnector_to_owners, &to_owners);
   sts = om$get_channel_count(objid = locnodeid.objid, osnum = locnodeid.osnum,
                            p_chanselect = &to_owners, count = (OMuint *)
&numowners);
   if(!(1&sts)) goto wrapup;
   if(!numowners) goto wrapup;
   if(owners && (owners != ownersbuf))
    {
     om$dealloc(ptr = owners);
     owners = NULL;
    }
   if(numowners > StaticBuf)
    owners = (OM_S_OBJECT_LINKAGE *) om$malloc(size = numowners * 
                                             sizeof(OM_S_OBJECT_LINKAGE));
   else owners = (OM_S_OBJECT_LINKAGE *) ownersbuf;
   EMerr_hndlr(!owners, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   sts = om$get_channel_objects(objid = locnodeid.objid, 
         osnum = locnodeid.osnum, p_chanselect = &to_owners, list = owners, 
	 size = numowners, count = (OMuint *) &numowners);
   if(!(1&sts)) goto wrapup;

   locnodeid.objid = NULL_OBJID;
   for (i=0; i<numowners; i++)
    {
     struct GRid junk;
     junk.objid = owners[i].S_objid;
     junk.osnum = owners[i].osnum;

     /* Skip inactive DPR owners.
     */
     if(EFisAncestryValid(EMmsg, junk.objid, junk.osnum, 
        OPP_EMSdpr_class_id, FALSE))
      {
	IGRushort props = NULL;
	
       sts = om$send(msg = message EMSdpr.EMget_dpr_props(EMmsg, &props), 
             senderid = NULL_OBJID, targetid = owners[i].S_objid, 
             targetos = owners[i].osnum);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(!(props & EMSIS_ACTIVE_STATE)) continue;
      }
     /* If the caller wants to stop at first encounter of a object of a
	given class, check and break.
     */
     else if(stopclsid && EFisAncestryValid(EMmsg, junk.objid, junk.osnum, 
             *stopclsid, FALSE)) break;
     /* If the caller wants to stop at the first encounter of a given objid, 
	check and break.
     */
     else if(stopid && (IF_EQ_GRID(*stopid, junk))) break;
     /* If the owner does not have GRconnector in its ancestry, stop.
        This indicates termination of ownership tree. I have added this check
	to prevent from GRsvset objects from being returned as
	top nodes. Don't know how else to prevent them.
	Aug 22, 1991.
     */
     else if(!EFisAncestryValid(EMmsg, junk.objid, junk.osnum, 
        OPP_GRconnector_class_id, FALSE)) break;

     /* If the owner is a graphic group, stop. Rather than this rigmarole
        why not stop as soon as a non-NMnonmani owner is encountered? The
        above check about GRconnectors will also become unnecessary. It is
        too late for 2.1 to answer this burning question. Hence I am resorting
        to simply fixing the problem at hand which is to not pick up graphic
        groups.
        SM Oct 19, 1992.
     */
     else if(EFisAncestryValid(EMmsg, junk.objid, junk.osnum, 
        OPP_GRgrgrp_class_id, FALSE)) break;

        /* 
		If owner is EMSdprparam  then stop searching for owners. 
						...Vadiraj(29.Nov.93)
	*/
     else if(EFisAncestryValid(EMmsg, junk.objid, junk.osnum, 
        OPP_EMSdprparam_class_id, FALSE)) break;
     
     locnodeid.objid = owners[i].S_objid;
     locnodeid.osnum = owners[i].osnum;

     break;

    } /* for (i=0; i<numowners; i++) */

  } /* while(!IF_NULL_OBJID(locnodeid.objid)) */

wrapup:
if(owners && (owners != ownersbuf)) om$dealloc(ptr = owners);
EMWRAPUP(*EMmsg,  sts,  "NMget_node");
return(sts);
}



/* Function to be used during transmigration.
*/
IGRint NMgetnode_trans(EMmsg, args, refid, nodeid)
IGRlong *EMmsg;
struct GRid *refid, *nodeid;
struct NMgetnode_trans_args *args;
{
 return(NMget_node(EMmsg, refid, args ? args->stopid : NULL, 
        args ? args->stopclsid : NULL, NULL, NULL, NULL, nodeid, NULL));
}

end implementation NMnonmani;
