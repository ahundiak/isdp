class implementation NMnonmanigm;

#include "OMmacros.h"
#include "nm.h"
#include "emsmacros.h"

from NMcreated import NMget_put_creator_id;
from NMvertex_use import NMgetsurface_info;
from NMedge import NMget_edge_info;

extern OMuword OPP_NMcreated_class_id, OPP_EMSboundary_class_id, 
               OPP_NMedge_class_id, OPP_NMvertex_class_id, 
               OPP_NMvertex_use_class_id;

IGRint NMfind_creator(EMmsg, created_elem, creator_id, fixit)
IGRlong *EMmsg;
GRobjid created_elem, *creator_id;
IGRboolean fixit;
{
 IGRlong		sts = OM_S_SUCCESS;
 GRobjid		loccrtid;
 struct GRid		junk, sfid, *nmnodes = NULL;
 IGRint			i, j, m, num_nmnodes = 0, nodebufsize = 0, 
			numedsin = 0;
 OMuint			count = 0;
 struct NMgmSSI		ssi;
 struct NMentities	*this_nm = NULL;
 IGRboolean		found = FALSE;
 OM_S_OBJID		my_id = NULL_OBJID;
 OM_S_CHANSELECT	to_vtxuse;

 *EMmsg = EMS_S_Success;
 if(!creator_id) creator_id = &loccrtid;
 NMinit_ssi(&ssi);

 *creator_id = NULL_OBJID;
 if(!EFisAncestryValid(EMmsg, created_elem, OM_Gw_current_OS, 
     OPP_NMcreated_class_id, TRUE))
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

 junk.objid = created_elem;
 junk.osnum = OM_Gw_current_OS;
 sfid.objid = NULL_OBJID;
 if(EFisAncestryValid(EMmsg, created_elem, OM_Gw_current_OS, 
    OPP_EMSboundary_class_id, TRUE))
  {
   sts = NMfind_sf_no_matter_what(EMmsg, &junk, &sfid, NULL, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else if(EFisAncestryValid(EMmsg, created_elem, OM_Gw_current_OS, 
         OPP_NMedge_class_id, TRUE))
  {
   sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, NULL, NULL, 
         NULL, &sfid, NULL, NMquery_ConsiderExternalToModel), 
         targetid = created_elem);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else if(EFisAncestryValid(EMmsg, created_elem, OM_Gw_current_OS, 
         OPP_NMvertex_class_id, TRUE))
  {
   NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuse);
   sts = om$get_channel_count(objid = created_elem, p_chanselect = &to_vtxuse, 
         count = &count);
   if(!(1&sts)) goto wrapup;
   for(i=0; i<count; i++)
    {
     sts = om$send(msg = message NMvertex_use.NMgetsurface_info(EMmsg, 
           &sfid.objid, NULL), senderid = created_elem, 
           p_chanselect = &to_vtxuse, from = i, to = i);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(!IF_NULL_OBJID(sfid.objid)) break;
    }
  }
 else if(EFisAncestryValid(EMmsg, created_elem, OM_Gw_current_OS, 
         OPP_NMvertex_use_class_id, TRUE))
  {
   sts = om$send(msg = message NMvertex_use.NMgetsurface_info(EMmsg, 
         &sfid.objid, NULL), targetid = created_elem);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 EMerr_hndlr(IF_NULL_OBJID(sfid.objid), *EMmsg, EMS_I_Useless, wrapup);

 sts = NMget_node(EMmsg, &sfid, NULL, NULL, &nmnodes, &num_nmnodes, 
       &nodebufsize, NULL, NMgetnode_All);
 if(!(1&*EMmsg&sts)) goto wrapup;
 EMerr_hndlr(!num_nmnodes, *EMmsg, EMS_I_Useless, wrapup);

 for(i=0; i<num_nmnodes; i++) 
  {
   found = FALSE;

   sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &ssi, NULL), 
         targetid = nmnodes[i].objid);
   if(sts == OM_W_UNKNOWN_MSG)
    {
     sts = OM_S_SUCCESS;
     goto end_search;
    }

   if(!(1&*EMmsg&sts)) goto wrapup;

   /* If the created element is in the ssi as the added element, then we
      have hit the creator.
   */
   for(j=0; j<ssi.num_vtx; j++)
    if(IF_EQ_OBJID(created_elem, ssi.vtx[j]))
     {
      found = TRUE;
      break;
     }
   if(found) goto end_search;

   for(j=0; j<ssi.num_nmedges; j++)
    if(IF_EQ_OBJID(created_elem, ssi.nmedges[j]))
     {
      found = TRUE;
      break;
     }
   if(found) goto end_search;


   for(j=0; j<ssi.num_sfs; j++)   
    {
     this_nm = &ssi.nmentities[j];
     for(m=0; m<this_nm->num_flps; m++)
      if(IF_EQ_OBJID(this_nm->flps[m], created_elem))
       {
	found = TRUE;
	break;
       }
     if(found) goto end_search;


     for(m=0; m<this_nm->num_vtxuses; m++)
      if(IF_EQ_OBJID(this_nm->vtxuses[m], created_elem))
       {
	found = TRUE;
	break;
       }
     if(found) goto end_search;


     for(m=0; m<this_nm->num_edges; m++)
      if(IF_EQ_OBJID(this_nm->edges[m], created_elem))
       {
	found = TRUE;
	break;
       }
     if(found) goto end_search;


     numedsin = 0;
     for(m=0; m<this_nm->numedgesout; m++)
      numedsin += this_nm->numedgesin[m];

     for(m=0; m<numedsin; m++)
      if(IF_EQ_OBJID(this_nm->edgesin[m], created_elem))
       {
	found = TRUE;
	break;
       }
     if(found) goto end_search;


    } /* for(j=0; j<ssi.num_sfs; j++) */

end_search:

   NMfree_ssi(&ssi);
   NMinit_ssi(&ssi);
   if(found)
    {
     *creator_id = nmnodes[i].objid;
     break;
    }

  } /* for(i=0; i<num_nmnodes; i++) */


if(found && fixit)
  sts = om$send(msg = message NMcreated.NMget_put_creator_id(EMmsg, creator_id,
        TRUE), targetid = created_elem);

wrapup:
if(nmnodes) om$dealloc(ptr = nmnodes);
EMWRAPUP(*EMmsg, sts, "NMfind_creator");
return(sts);
}

end implementation NMnonmanigm;
