/*
Given an edgeid, this function will get the collection of edges that match
in model space and are interconnected via NM topology.
*/
class implementation NMedge;

#include "EMSprop.h"
#include "OMmacros.h"

#define StaticBuf 10

extern OMuword OPP_NMedge_class_id, OPP_NMlistedge_class_id;

from EMSedge import EMget_props;
from EMSboundary import EMgetsurface_info;

extern IGRboolean NMedgevtxuse_assoc;

IGRint NMget_edge_mates(EMmsg, refedge, numedges, edges, reverse, refuse, 
			refsf, nmedge, nmquery_opt, ssi, construct)
IGRlong *EMmsg;
struct GRid *refedge;
IGRint *numedges;
struct GRid **edges, *refuse, *refsf, *nmedge;
IGRboolean **reverse;
unsigned int nmquery_opt;
struct NMgmSSI *ssi;
struct GRvg_construct *construct;
{
 IGRlong 		sts = OM_S_SUCCESS;
 struct GRid		*locnmedge = NULL, foundnmedge;
 OMuword 		chkclsid = OPP_NMedge_class_id;
 IGRint			numnmedge = 0, i, nmedbufsize = 0;
 unsigned char	nmedprops = NULL;

 *EMmsg = EMS_S_Success;

 if(numedges) *numedges = 0;
 if(edges) *edges = NULL;
 if(reverse) *reverse = NULL;
 if(refuse) refuse->objid = NULL_OBJID;
 if(refsf) refsf->objid = NULL_OBJID;
 if(nmedge) nmedge->objid = NULL_OBJID;
 foundnmedge.objid = NULL_OBJID;

 sts = NMget_comp_dependents(EMmsg, refedge, &chkclsid, &numnmedge, 
       &locnmedge, &nmedbufsize, NULL, 0, MAXINT);
 if(!(1&*EMmsg&sts)) goto wrapup;
 sts = NMget_comp_listeners(EMmsg, refedge, &chkclsid, &numnmedge, 
       &locnmedge, &nmedbufsize, NULL, 0, MAXINT);
 if(!(1&*EMmsg&sts)) goto wrapup;

 for(i=0; i<numnmedge; i++)
  {
   sts = om$send(msg = message NMedge.NMprop(EMmsg, NMprop_Get, &nmedprops), 
         targetid = locnmedge[i].objid, targetos = locnmedge[i].osnum, 
         senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* If NMedges created external to modeling operations are to be ignored
      check and do it.
   */
   if( (!(nmquery_opt & NMquery_ConsiderExternalToModel)) && 
       (nmedprops & NMedge_ExternalToModel))
    continue;

   /* If inactive NMedges are to be ignored, check and do it.
   */
   if( (!(nmquery_opt & NMquery_ConsiderInactive)) && 
       (!(nmedprops & NMedge_Active)))
    continue;

   foundnmedge = locnmedge[i];
   break;
  }

 if(IF_NULL_OBJID(foundnmedge.objid)) numnmedge = 0;

 /* If there is no NMedge present, see if the input edge has a common edge
    and return that as the mate.
    If the options specify creation of an NMedge if none found, do so and
    call the function recursively to fill in other output information.
 */
 if(!numnmedge && (nmquery_opt & NMquery_CreateIfNotFound))
  {
   struct GRid surfid;
   unsigned char nmprops = NMedge_Active;
   unsigned int	connect_opt = NULL;
   struct GRvg_construct  locconstruct;
   struct IGRdisplay	locdisp;
   struct GRmd_env	locenv;

   surfid.objid = NULL_OBJID;
   sts = om$send(msg = message EMSboundary.EMgetsurface_info
	 (EMmsg, &surfid.objid, NULL), targetid = refedge->objid, 
	 targetos = refedge->osnum, senderid = NULL_OBJID);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(IF_NULL_OBJID(surfid.objid), *EMmsg, EMS_E_Fail, wrapup);
   surfid.osnum = refedge->osnum;

   /* Generate default construct list if one is not supplied.
   */
   if(!construct)
    {
     locconstruct.geometry = NULL;
     locconstruct.display = &locdisp;
     locconstruct.class_attr = NULL;
     locconstruct.msg = EMmsg;
     locconstruct.env_info = &locenv;

     EMidmatrix(EMmsg, &locenv.md_env.matrix_type, locenv.md_env.matrix);
     locenv.md_id.osnum = surfid.osnum;
     locenv.md_id.objid = NULL_OBJID;

     sts = EFget_construction_info_from_id(EMmsg, &locconstruct, surfid.objid, 
           surfid.osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
     locconstruct.newflag = FALSE;
     construct = &locconstruct;
    }

   if(nmquery_opt & NMquery_ConsiderExternalToModel)
    {    
     nmprops |= NMedge_ExternalToModel;
     connect_opt |= NMconnect_ExternalToModel;
    }

   if(ssi) connect_opt |= NMconnect_AddToSSI;

   /* Construct a NMedge.
   */
   sts = om$construct(osnum = refedge->osnum, 
	 classid = NMedgevtxuse_assoc ? OPP_NMedge_class_id :
		   OPP_NMlistedge_class_id,
         p_objid = &foundnmedge.objid, msg = message NMedge.NMinit
                 (EMmsg, ssi ? NMinit_AddToSSI : NULL, nmprops, 0, NULL,
		  NULL, NULL, NULL, ssi));
   if(!(1&sts)) goto wrapup;
   foundnmedge.osnum = refedge->osnum;

   /* Connect up the reference edge to the NMedge.
   */
   sts = om$send(msg = message NMedge.NMconnect_edges
         (EMmsg, 1, refedge, &surfid, NULL, construct->env_info, NULL, 
	  connect_opt), 
          targetid = foundnmedge.objid, targetos = foundnmedge.osnum, 
          senderid = NULL_OBJID);
   if(!(1&sts)) goto wrapup;

   /* Rather than calling the function recursively, I could fill in all the
      output information right here. But... Later.
   */
   nmquery_opt &= (~NMquery_CreateIfNotFound);
   sts = NMget_edge_mates(EMmsg, refedge, numedges, edges, reverse, refuse,
	 refsf, nmedge, nmquery_opt, ssi, construct);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else if(!numnmedge &&  (numedges || edges || reverse || refuse || refsf))
  {
   OM_S_OBJECT_LINKAGE commedge;
   OM_S_CHANSELECT to_common_edge;

   EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);
   sts = om$get_channel_objects(objid = refedge->objid, osnum = refedge->osnum,
	 p_chanselect = &to_common_edge, list = &commedge, size = 1, 
	 count = (OMuint *) &numnmedge);
   if(!(1&sts)) goto wrapup;
   if(!numnmedge)
    {
     if(edges)
      {
       *edges = (struct GRid *) om$malloc(size = sizeof(struct GRid));
       EMerr_hndlr(!*edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       (*edges)[0] = *refedge;
      }
     if(numedges) *numedges = 1;
     if(reverse)
      {
       *reverse = (IGRboolean *) om$malloc(size = sizeof(IGRboolean));
       EMerr_hndlr(!*reverse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
       (*reverse)[0] = FALSE;
      }
     if(refuse) *refuse = *refedge;
     if(refsf)
      {
       sts = om$send(msg = message EMSboundary.EMgetsurface_info
	     (EMmsg, &refsf->objid, NULL), targetid = refedge->objid, 
	     targetos = refedge->osnum, senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       refsf->osnum = refedge->osnum;
      }
     *EMmsg = EMS_I_Useless;
    }
   else
    {
     if(edges)
      {
       *edges = (struct GRid *) om$malloc(size = 2 * sizeof(struct GRid));
       EMerr_hndlr(!*edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       (*edges)[0] = *refedge;
       (*edges)[1].objid = commedge.S_objid;
       (*edges)[1].osnum = commedge.osnum;
      }
     if(numedges) *numedges = 2;
     if(reverse)
      {
       IGRushort edprops;

       *reverse = (IGRboolean *) om$malloc(size = 2 * sizeof(IGRboolean));
       EMerr_hndlr(!*reverse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);   
       (*reverse)[0] = FALSE;
       sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops), 
	     senderid = NULL_OBJID, targetid = refedge->objid, 
	     targetos = refedge->osnum);
       if(!(1&*EMmsg&sts)) goto wrapup;
       if(edprops & EMED_REVERSE_CONNECT) (*reverse)[1] = TRUE;
       else (*reverse)[1] = FALSE;
      }
     if(refuse) *refuse = *refedge;
     if(refsf)
      {
       sts = om$send(msg = message EMSboundary.EMgetsurface_info
	     (EMmsg, &refsf->objid, NULL), targetid = refedge->objid, 
	     targetos = refedge->osnum, senderid = NULL_OBJID);
       if(!(1&*EMmsg&sts)) goto wrapup;
       refsf->osnum = refedge->osnum;
      }

    } /* if(!numnmedge) */

  } /* if(!numnmedge) */

 else if(numnmedge)
  {
   if(nmedge) *nmedge = foundnmedge;

   if(numedges || edges || reverse || refuse || refsf)
    {
     sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, numedges, edges,
           refuse, refsf, reverse, NULL), targetid = foundnmedge.objid, 
           targetos = foundnmedge.osnum, senderid = NULL_OBJID);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

wrapup:
if(locnmedge) om$dealloc(ptr = locnmedge);
EMWRAPUP(*EMmsg, sts, "NMget_edge_mates");
return(sts);
}

end implementation NMedge;
