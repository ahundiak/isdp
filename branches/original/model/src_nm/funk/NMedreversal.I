class implementation NMedge;

#include "OMmacros.h"
#include "emsmacros.h"
#include "EMSprop.h"

extern OMuword OPP_NMedge_class_id;

from EMSedge import EMget_props;

IGRint NMedge_reversal(EMmsg, ed1, ed2, nmed, reverse)
IGRlong *EMmsg;
struct GRid *ed1, *ed2, *nmed;
IGRboolean *reverse;
{
 IGRlong		sts = OM_S_SUCCESS;
 struct GRid		locnmed, *loced = NULL;
 IGRboolean		*locrev = NULL, found = FALSE;
 IGRint			locnumed = 0, i;
 IGRboolean		rev1 = FALSE, rev2 = FALSE;

 *EMmsg = EMS_S_Success;

 /* Got to have an nmedge.
 */
 if(nmed) locnmed = *nmed;
 else if(ed1 && EFisAncestryValid(EMmsg, ed1->objid, ed1->osnum, 
		OPP_NMedge_class_id, TRUE))
  {
   locnmed = *ed1;
   ed1 = NULL;
  }
 else if(ed2 && EFisAncestryValid(EMmsg, ed2->objid, ed2->osnum, 
		OPP_NMedge_class_id, TRUE))
  {
   locnmed = *ed2;
   ed2 = NULL;
  }
 else if(ed1 || ed2)
  {
   sts = NMget_edge_mates(EMmsg, ed1 ? ed1 : ed2, &locnumed, &loced, &locrev, 
         NULL, NULL, &locnmed, NMquery_ConsiderExternalToModel, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }  
 else 
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 if(!locrev && (!IF_NULL_OBJID(locnmed.objid)))
  {
   sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, &locnumed, &loced,
         NULL, NULL, &locrev, NULL), targetid = locnmed.objid, 
         senderid = NULL_OBJID, targetos = locnmed.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else if(!locrev)
  {
   /* If the input edges are common edges, use their reverse connect property
      else error out.
   */
   if(ed1 && ed2 && EFisAncestryValid(EMmsg, ed1->objid, ed1->osnum, 
      OPP_EMSedge_class_id, TRUE) && EFisAncestryValid(EMmsg, ed2->objid, 
      ed2->osnum, OPP_EMSedge_class_id, TRUE))
    {
     OM_S_CHANSELECT to_comm;
     OM_S_OBJECT_LINKAGE comm;
     OMuint count = 0;
     IGRushort edprops = NULL;

     EMmake_chanselect(EMSedge_to_common_edge, &to_comm);
     sts = om$get_channel_objects(objid = ed1->objid, osnum = ed1->osnum, 
           p_chanselect = &to_comm, list = &comm, size = 1, count = &count);
     if(!(1&sts)) goto wrapup;

     if(count && (IF_EQ_OBJID(comm.S_objid, ed2->objid)))
      {
       sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
	     targetid = ed1->objid, targetos = ed1->osnum, 
	     senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(edprops & EMED_REVERSE_CONNECT) *reverse = TRUE;
       else *reverse = FALSE;
       goto wrapup;
      }
     else
      {
       *EMmsg = EMS_E_Fail;
       goto wrapup;
      }
    }    
   else
    {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
    }
  }


 if(ed1)
  {
   found = FALSE;
   for(i=0; i<locnumed; i++)
    if(IF_EQ_GRID(loced[i], *ed1))
     {
      found = TRUE;
      rev1 = locrev[i];
      break;
     }
   EMerr_hndlr(!found, *EMmsg, EMS_E_Fail, wrapup);
  }

 if(ed2)
  {
   found = FALSE;
   for(i=0; i<locnumed; i++)
    if(IF_EQ_GRID(loced[i], *ed2))
     {
      found = TRUE;
      rev2 = locrev[i];
      break;
     }
   EMerr_hndlr(!found, *EMmsg, EMS_E_Fail, wrapup);
  }


 if(ed1 && ed2)
  { 
   /* Not quite sure about the '^' operator. Will worry about it later.
   */
   if( (rev1 && rev2) || (!rev1 && !rev2)) *reverse = FALSE;
   else *reverse = TRUE;
  }
 else if(ed1) *reverse = rev1;
 else if(ed2) *reverse = rev2;

wrapup:
if(locrev) om$dealloc(ptr = locrev);
if(loced) om$dealloc(ptr = loced);
EMWRAPUP(*EMmsg, sts, "NMedge_reversal");
return(sts);
}


end implementation NMedge;
