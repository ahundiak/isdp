class implementation NMedflp;

#include "OMmacros.h"
#include "emsgeteddef.h"

extern OMuword OPP_NMedflp_class_id;

IGRint NMnext_edge(EMmsg, option, refedge, refedgeos, edge)
IGRlong *EMmsg;
IGRushort option;
GRobjid refedge, *edge;
GRspacenum refedgeos;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 GRobjid		actlp = NULL_OBJID, search_edge = NULL_OBJID;
 struct GRid		sfid, *edflp = NULL;
 OMuword 		exact_clsid = OPP_NMedflp_class_id;
 IGRint			j, num_edflp = 0;
 OM_S_CHANSELECT	to_ed;

 *EMmsg = EMS_S_Success;
 *edge = NULL_OBJID;
 actlp = NULL_OBJID;

 sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg, 
       &actlp), refedge, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
 EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(IF_NULL_OBJID(actlp)) goto wrapup;

 search_edge = NULL_OBJID;

 sts = om$send(msg =  message EMSloop.EMnext_edge(EMmsg, 
       option, refedge, &search_edge), targetid = actlp, senderid = NULL_OBJID,
       targetos = refedgeos);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* While searching for the next edge, if we fall off an open loop, 
    check if it is an NMedflp. If so, we can go down to the 'region'
    loop and continue the search. If the open loop was not an NMedflp
    or we get back the same edge from a closed loop, stop the search.
    Conversely, if the search was done via a region loop, check if
    there is any NMedflp replacement on the edge we found.
 */
 if( (IF_NULL_OBJID(search_edge)) && (EFisAncestryValid(EMmsg, 
     actlp, OM_Gw_current_OS, OPP_NMedflp_class_id, TRUE)))
  {
   refedge = NULL_OBJID;	
   sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
         &refedge, TRUE), targetid = actlp, senderid = NULL_OBJID, 
         targetos = refedgeos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   actlp = NULL_OBJID;
   sts = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg, 
         &actlp), refedge, 0, MAXINT, EMLP_ACTIVE, NULL, NULL);
   EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(IF_NULL_OBJID(actlp)) goto wrapup;

   search_edge = NULL_OBJID;
   sts = om$send(msg =  message EMSloop.EMnext_edge(EMmsg, 
	 option, refedge, &search_edge), targetid = actlp, 
	 senderid = NULL_OBJID, targetos = refedgeos);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 if(!IF_NULL_OBJID(search_edge))
  {
   sts = om$send(msg =  message EMSboundary.EMgetsurface_info(EMmsg, 
	  &sfid.objid, NULL), targetid = actlp, senderid = NULL_OBJID, 
	  targetos = refedgeos);
   if(!(1&*EMmsg&sts)) goto wrapup;
   sfid.osnum = refedgeos;

   sts = NMget_feature_loops(EMmsg, &sfid, &num_edflp, &edflp, 
         &exact_clsid, 1, NULL, 0, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
	
   for(j=0; j<num_edflp; j++)
    {
     GRobjid region_edge = NULL_OBJID;

     if(IF_EQ_OBJID(edflp[j].objid, actlp)) continue;

     sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
           &region_edge, TRUE), targetid = edflp[j].objid, 
           targetos = edflp[j].osnum, senderid = NULL_OBJID); 
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(IF_EQ_OBJID(search_edge, region_edge))
      {
       OMuword junk;
       OMuint numed;
	
       /* Out of the edges in this NMedflp, choose the appropriate
	  edge (first or last)
       */
       EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);

       sts = om$get_channel_count(objid = edflp[j].objid, 
	      p_chanselect = &to_ed, count = &numed);
       if(!(1&sts)) goto wrapup;
       if(!numed) continue;

       sts = om$get_objid_at_index(objid = edflp[j].objid, 
	     p_chanselect = &to_ed, 
	     index = (option & EMGetEd_Next) ? 0 : (numed - 1), 
	     objidaddr = &search_edge, osnumaddr = &junk);
       if(!(1&sts)) goto wrapup;
       actlp = edflp[j].objid;
       break;
      }
       	
    } /* for(j=0; j<num_edflp; j++) */
	
  } /* if(!IF_NULL_OBJID(search_edge)) */



wrapup:

if(edflp) om$dealloc(ptr = edflp);
if(!IF_NULL_OBJID(search_edge)) *edge = search_edge;
else if(1&*EMmsg&sts) *EMmsg = EMS_I_NotFound;

EMWRAPUP(*EMmsg, sts, "NMnext_edge");
return(sts);
}

end implementation NMedflp;
