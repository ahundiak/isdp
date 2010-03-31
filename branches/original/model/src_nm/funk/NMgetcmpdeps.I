/*
Given an edgeid, this function will get all the true dependents. If
classid is input, it will return only the dependents of that class.

Optionally, it will also send a message to the dependents.

This function is intended as an interface to simulate a direct channel
connection between a generated element and its indirect dependents.

The arguments 'frominx' and 'toinx' simulate the indices on a ordered
channel.

The arguments numdeps, deps and depbufsize can be NULL if the intention is
to send a message only.

WHEN NON NULL, THE ARGUMENT numdeps, MUST BE INITILIZED BY THE CALLER. This
is in order to be able to call the function multiple times and have information
appended to preexisting list. 
*/
class implementation NMedge;

#include "OMmacros.h"
#include "emsmacros.h"
#include "nddef.h"
#include "REpointer.h"

#define StaticBuf 10
#define DepInc	10

extern OMuword OPP_EMSpointer_class_id, OPP_EMSboundary_class_id, 
	       OPP_NMcreated_class_id, OPP_NDnodeid_class_id;

from EMSboundary import EMget_put_creator_id;

from EMSpointer import EMget_pointer_info;

IGRint NMget_comp_dependents(EMmsg, refcomp, chkclsid, numdeps, deps, 
			     depbufsize, messg, frominx, toinx) 
IGRlong *EMmsg;
struct GRid *refcomp;
OMuword *chkclsid;
IGRint *numdeps;
struct GRid **deps;
IGRint *depbufsize;
OM_S_MESSAGE *messg;
IGRint frominx, toinx;
{
 IGRlong 		sts = OM_S_SUCCESS;
 GRobjid		creatorid = NULL_OBJID;
 struct GRid		*creator_child = NULL, 
			*ptrobj = NULL, ptrobjbuf[StaticBuf], 
			*ptrobj_child = NULL, go;
 IGRint			i, numptrobj = 0, num_creator_child = 0, 
			num_ptrobj_child = 0, j;
 OM_S_CHANSELECT	to_children;
 unsigned int	ptrtype;
 IGRint			locnumdeps = 0, locdepbufsize = 0, 
			logical_inx = 0;
 struct GRid		*locdeps = NULL;
 
 *EMmsg = EMS_S_Success;
 EMmake_chanselect(NDchildren_children, &to_children);

 if(frominx > toinx)
  {
   *EMmsg = EMS_E_InvalidArg;
   sts = OM_E_INVALIDRANGE;
   goto wrapup;
  }

 if(EFisAncestryValid(EMmsg, refcomp->objid, refcomp->osnum, 
    OPP_EMSboundary_class_id, TRUE))
  {
   sts = om$send(msg = message EMSboundary.EMget_put_creator_id
         (EMmsg, &creatorid, FALSE), targetid = refcomp->objid, 
         targetos = refcomp->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(IF_NULL_OBJID(creatorid))
    {
     sts = EFget_creator_id(EMmsg, refcomp->objid, refcomp->osnum, 
	   &creatorid, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

  }
 else if(EFisAncestryValid(EMmsg, refcomp->objid, refcomp->osnum, 
      OPP_NMcreated_class_id, TRUE))
  {
   sts = om$send(msg = message NMcreated.NMget_put_creator_id
         (EMmsg, &creatorid, FALSE), targetid = refcomp->objid, 
         targetos = refcomp->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  {
   *EMmsg = EMS_I_InvalidArg;
   goto wrapup;
  }

 EMerr_hndlr(IF_NULL_OBJID(creatorid), *EMmsg, EMS_I_Useless, wrapup);

 if(!EFisAncestryValid(EMmsg, creatorid, refcomp->osnum,
    OPP_NDnodein_class_id, TRUE))
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }

 sts = om$send(mode = OM_e_wrt_message, 
       msg = message NDnodein.NDget_objects(ND_CHILDREN | ND_IN_BUF, NULL, 
       NULL, &creator_child, 0, MAXINT, &num_creator_child), 
       targetid = creatorid, targetos = refcomp->osnum, senderid = NULL_OBJID);
 if(!(1&sts)) goto wrapup;
 EMerr_hndlr(!num_creator_child, *EMmsg, EMS_I_Useless, wrapup);

 if(num_creator_child > StaticBuf)
  ptrobj = (struct GRid *) om$malloc(size = num_creator_child * 
              sizeof(struct GRid));
 else ptrobj = ptrobjbuf;
 EMerr_hndlr(!ptrobj, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 numptrobj = 0;
 for(i=0; i<num_creator_child; i++)
  if(EFisAncestryValid(EMmsg, creator_child[i].objid, creator_child[i].osnum, 
     OPP_EMSpointer_class_id, FALSE))
   ptrobj[numptrobj++] = creator_child[i];

 EMerr_hndlr(!numptrobj, *EMmsg, EMS_I_Useless, wrapup);

 locdeps = (struct GRid *) om$malloc(size = DepInc * sizeof(struct GRid));
 EMerr_hndlr(!locdeps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 locdepbufsize = DepInc;

 logical_inx = 0;
 for(i=0; i<numptrobj; i++)
  {
   IGRshort mattyp;
   IGRmatrix mat;

   if(logical_inx > toinx) break;

   /* The pointer type being EMS_ASobject_key indicates that it points to
      data that was generated during previous compute. Such data is temporary
      and hence ignored.
   */
   sts = om$send(msg = message EMSpointer.EMget_pointer_info(EMmsg, NULL, 
	 &ptrtype, NULL, NULL), 
         targetid = ptrobj[i].objid, targetos = ptrobj[i].osnum, 
         senderid = NULL_OBJID);
   if(!(1&sts)) goto wrapup;
   if(ptrtype == EMS_ASobject_key) continue;
    
   /* If this pointer is not pointing to the reference component, ignore
      it.
   */
   sts = om$send(msg = message NDnode.ASreturn_go(&go, &mattyp, mat), 
         targetid = ptrobj[i].objid, targetos = ptrobj[i].osnum, 
         senderid = NULL_OBJID);
   if(!(1&sts)) goto wrapup;
   if(!IF_EQ_GRID(go, *refcomp)) continue;

   sts = om$send(mode = OM_e_wrt_message, 
         msg = message NDnodein.NDget_objects(ND_CHILDREN | ND_IN_BUF, NULL, 
         NULL, &ptrobj_child, 0, MAXINT, &num_ptrobj_child), 
         targetid = ptrobj[i].objid, targetos = ptrobj[i].osnum, 
         senderid = NULL_OBJID);
   if(!(1&sts)) goto wrapup;

   for(j=0; j<num_ptrobj_child; j++)
    {
     if(chkclsid && !EFisAncestryValid(EMmsg, ptrobj_child[j].objid, 
                     ptrobj_child[j].osnum, *chkclsid, FALSE))
      continue;

     if(logical_inx >= frominx)
      {
       if( (locnumdeps+1) > locdepbufsize)
        {
         locdeps = (struct GRid *) om$realloc(ptr = (IGRchar *) locdeps, size = 
                   (locnumdeps + DepInc) * sizeof(struct GRid));
         EMerr_hndlr(!locdeps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
         locdepbufsize = locnumdeps + DepInc;
        }
       locdeps[locnumdeps++] = ptrobj_child[j];
      }
     logical_inx++;

    } /* for(j=0; j<num_ptrobj_child; j++) */

  } /* for(i=0; i<numptrobj; i++) */

 EMerr_hndlr(!locnumdeps, *EMmsg, EMS_I_Useless, wrapup);

 if(deps && numdeps)
  {
   if(*depbufsize < (*numdeps + locnumdeps))
    {
     if(*deps)
      *deps = (struct GRid *) om$realloc(ptr = (IGRchar *) *deps, size = 
               (*numdeps + locnumdeps + DepInc) * sizeof(struct GRid));
     else *deps = (struct GRid *) om$malloc(size = 
	       (locnumdeps + DepInc) * sizeof(struct GRid));
     EMerr_hndlr(!*deps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     *depbufsize = *numdeps + locnumdeps + DepInc;
    }
   OM_BLOCK_MOVE(locdeps, &(*deps)[*numdeps],locnumdeps * sizeof(struct GRid));
   *numdeps += locnumdeps;
  }

 if(messg)
  for(i=0; i<locnumdeps; i++)
   {
    sts = om$send(msg = messg, targetid = locdeps[i].objid, 
          targetos = locdeps[i].osnum, senderid = refcomp->objid);
    if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
    if(sts == OM_I_STOP_SENDING) break;
    if( (!(1&sts)) || (sts == OM_I_STOP_SENDING)) goto wrapup;
   }

wrapup:
if(ptrobj && (ptrobj != ptrobjbuf)) om$dealloc(ptr = ptrobj);
if(locdeps) om$dealloc(ptr = locdeps);
if((1&sts) && (*EMmsg == EMS_I_Useless)) sts = OM_I_CHAN_EMPTY;
EMWRAPUP(*EMmsg, sts, "NMget_comp_dependents");
return(sts);
}



extern OMuword OPP_GRnotify_class_id;

IGRint NMget_comp_listeners(EMmsg, refcomp, chkclsid, numdeps, deps, 
			     depbufsize, messg, frominx, toinx) 
IGRlong *EMmsg;
struct GRid *refcomp;
OMuword *chkclsid;
IGRint *numdeps;
struct GRid **deps;
IGRint *depbufsize;
OM_S_MESSAGE *messg;
IGRint frominx, toinx;
{
 IGRlong 		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_listeners;
 IGRint			i, listeners_count = 0;
 OM_S_OBJECT_LINKAGE	*listeners = NULL, listbuf[StaticBuf];
 IGRint			locnumdeps = 0, locdepbufsize = 0, 
			logical_inx = 0;
 struct GRid		*locdeps = NULL;

 *EMmsg = EMS_S_Success;
 EMmake_chanselect(GRnotify_notification, &to_listeners);

 if(frominx > toinx)
  {
   *EMmsg = EMS_E_InvalidArg;
   sts = OM_E_INVALIDRANGE;
   goto wrapup;
  }

 if(!EFisAncestryValid(EMmsg, refcomp->objid, refcomp->osnum, 
     OPP_GRnotify_class_id, TRUE))
  {
   *EMmsg = EMS_I_Useless;
   goto wrapup;
  }

 sts = om$get_channel_count(objid = refcomp->objid, osnum = refcomp->osnum, 
       p_chanselect = &to_listeners, count = (OMuint *) &listeners_count);
 if(!(1&sts)) goto wrapup;
 EMerr_hndlr(!listeners_count, *EMmsg, EMS_I_Useless, wrapup);

 if(listeners_count > StaticBuf)
  listeners = (OM_S_OBJECT_LINKAGE *) om$malloc(size = listeners_count * sizeof
	   (OM_S_OBJECT_LINKAGE));
 else listeners = listbuf;
 EMerr_hndlr(!listeners, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$get_channel_objects(objid = refcomp->objid, osnum = refcomp->osnum, 
       p_chanselect = &to_listeners, list = listeners, size = listeners_count, 
       count = (OMuint *) &listeners_count);
 if(!(1&sts)) goto wrapup;

 locdeps = (struct GRid *) om$malloc(size = DepInc * sizeof(struct GRid));
 EMerr_hndlr(!locdeps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 locdepbufsize = DepInc;

 logical_inx = 0;
 for(i=0; i<listeners_count; i++)
  {
   if(logical_inx > toinx) break;

   if(chkclsid && !EFisAncestryValid(EMmsg, listeners[i].S_objid, 
                   listeners[i].osnum, *chkclsid, FALSE))
   continue;

   if(logical_inx >= frominx)
    {
     if( (locnumdeps+1) > locdepbufsize)
      {
       locdeps = (struct GRid *) om$realloc(ptr = (IGRchar *) locdeps, size = 
                 (locnumdeps + DepInc) * sizeof(struct GRid));
       EMerr_hndlr(!locdeps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       locdepbufsize = locnumdeps + DepInc;
      }
     locdeps[locnumdeps].objid = listeners[i].S_objid;
     locdeps[locnumdeps++].osnum = listeners[i].osnum;
    }
   logical_inx++;
  }

 EMerr_hndlr(!locnumdeps, *EMmsg, EMS_I_Useless, wrapup);

 if(deps && numdeps)
  {
   if(*depbufsize < (*numdeps + locnumdeps))
    {
     if(*deps)
      *deps = (struct GRid *) om$realloc(ptr = (IGRchar *) *deps, size = 
               (*numdeps + locnumdeps + DepInc) * sizeof(struct GRid));
     else *deps = (struct GRid *) om$malloc(size = 
	       (locnumdeps + DepInc) * sizeof(struct GRid));
     EMerr_hndlr(!*deps, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
     *depbufsize = *numdeps + locnumdeps + DepInc;
    }
   OM_BLOCK_MOVE(locdeps, &(*deps)[*numdeps],locnumdeps * sizeof(struct GRid));
   *numdeps += locnumdeps;
  }

 if(messg)
  for(i=0; i<locnumdeps; i++)
   {
    sts = om$send(msg = messg, targetid = locdeps[i].objid, 
          targetos = locdeps[i].osnum, senderid = refcomp->objid);
    if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
    if(sts == OM_I_STOP_SENDING) break;
    if( (!(1&sts)) || (sts == OM_I_STOP_SENDING)) goto wrapup;
   }

wrapup:
if(listeners && (listeners != listbuf)) om$dealloc(ptr = listeners);
if(locdeps) om$dealloc(ptr = locdeps);
if((1&sts) && (*EMmsg == EMS_I_Useless)) sts = OM_I_CHAN_EMPTY;
EMWRAPUP(*EMmsg, sts, "NMget_comp_listeners");
return(sts);
}


end implementation NMedge;
