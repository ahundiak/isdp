class implementation NMnonmanitp;

#include "emsmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "bserr.h"
#include "EMSprop.h"
#include "NMmsg.h"
#include "msmacros.h"

#define StaticBuf 10

#ifndef DEBUG
#define DEBUG 0
#endif

from NMedge import NMcheck, NMreset_refuse, NMget_edge_info, NMprop, 
                   NMdisconnect_edges;
from NMvertex_use import NMcheck, NMreset, NMget_incedence_info, NMpoint, 
			 NMprop;
from NMvertex import NMpoint, NMcheck, NMprop;
from EMSboundary import EMgetsurface_info, EMget_objid, EMget_put_creator_id;
from EMSedge import EMendpts;

extern OMuint OM_Gf_verbose_warning;
extern IGRboolean NMtp_persistent;
 static void		delete_ele();
method NMreexecute(IGRlong *EMmsg; struct GRvg_construct *construct;
		   unsigned short reex_options)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 IGRint			i, j = 0;
 struct NMgmSSI		old_ssi, new_ssi;
 struct GRmd_env	locenv;
 IGRint			bytes_in, bytes_out;
 extern OM_S_OBJID	current_creator;
 OM_S_CHANSELECT	to_children, to_comm;
 IGRint			num_child;
 IGRboolean		atleast_one_fail = FALSE;
 struct NMentities	*this_nm = NULL;
 OM_S_CHANSELECT	to_vtx, to_vtxuses;

 GRobjid		*vtu_edges = NULL, *model_vtu = NULL;
 IGRint			num_vtuedges = 0, num_nmedgeedges = 0, 
			num_modelvtu = 0;
 IGRdouble		uvpt[2], xyzpt[3];
 struct IGRbsp_surface	*surf_geom = NULL;
 struct GRid		*nmedge_edges = NULL;
 enum EMScvinttype	*vtu_loc = NULL;
 IGRchar		status_str[250], dot[2];
 unsigned char	nmedge_props = NMedge_Active, 
			vtxuse_props = NMvtxuse_Active, 
			vtx_props = NMvtx_Active, 
			prop_opt = NMprop_SetOff;
 struct GRid		modelid, activeid, nmtpid;
 IGRboolean		have_children = FALSE;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&old_ssi);
 NMinit_ssi(&new_ssi);
 strcpy(dot, ".");

 current_creator = my_id;

 if(OM_Gf_verbose_warning)
  fprintf(stderr, "** Recomputing NMnonmanitp node id %d\n", my_id);

 ex$message(msgnumb = NM_I_RecompNmTp, buff = status_str);
 strcat(status_str, dot);
 UI_status(status_str);

 if(IF_NULL_OBJID(construct->env_info->md_id.objid))
  {
   bytes_in = sizeof(struct GRmd_env);
   gr$get_module_env(msg = EMmsg, sizbuf = &bytes_in, buffer = &locenv, 
                     nret = &bytes_out);
   if(!(1&*EMmsg)) goto wrapup;
   construct->env_info = &locenv;
  }

 modelid.objid = NULL_OBJID;
 sts = om$send(msg = message NMnonmanitp.NMpass_model(EMmsg, NULL, &modelid), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 
 /* If no model connected, delete myself.
 */
 if(IF_NULL_OBJID(modelid.objid))
  {
   ex$message(msgnumb = NM_I_DeletingOrphanNode);
   sleep(1);
   sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, construct->env_info), 
         targetid = my_id);

   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 /* If the model has multiple NMtp objects connected, delete myself. This
    indicates, possible merging of disjoint trees at this point.
 */
 
 nmtpid.objid = NULL_OBJID;
 sts = NMcreate_nmtp(EMmsg, &modelid, construct->env_info, &nmtpid, NULL, 
       NMcrtnmtp_QueryOnly, construct);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if( (!IF_NULL_OBJID(nmtpid.objid)) && (!IF_EQ_OBJID(nmtpid.objid, my_id)))
  {
   ex$message(msgnumb = NM_I_DPRtreeMergeDetected);
   sleep(1);
   sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, construct->env_info), 
         targetid = my_id);

   /* After I delete myself, the other guy needs to recompute.
   */
   sts = om$send(msg = OPPmargs, targetid = nmtpid.objid, 
         targetos = nmtpid.osnum);
   *EMmsg = EMS_I_Fail;
   goto wrapup;
  }

 /* Send a message to all pointers to translate and store the key, before
    deleting/updating my topology.
 */
 sts = EMmake_chanselect(NDchildren_children, &to_children);
 if (!(1&sts)) goto wrapup;

 sts = om$get_channel_count(p_chanselect = &to_children,
                            object = me,
                            count = (OMuint *) &num_child);
 if (!(1&sts)) goto wrapup;
 for (i=0;i<num_child;i++)
  {
   have_children = TRUE;
   sts = om$send (msg = message EMSpointerA.EMstore_key_from_id(EMmsg,
         NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if (!(1&sts&*EMmsg)) goto wrapup;
  }

 /* Get my old ssi. For each NM topological element, try updating it. If
    it cannot update, delete it. Put back the elements which successfully
    updated, into the new SSI and post it to my instance data. Elements which
    do not update will indicate topology mismatch.
 */

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &old_ssi, NULL), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 strcat(status_str, dot);
 UI_status(status_str);

 /* Update the NMedges.
 */
 EMmake_chanselect(EMSedge_to_common_edge, &to_comm);

 for(i=0; i<old_ssi.num_nmedges; i++)
  {
   IGRboolean need_to_reconnect = FALSE, need_to_check = TRUE;

   if(IF_NULL_OBJID(old_ssi.nmedges[i])) continue;

   sts = om$send(msg = message NMedge.NMcheck(EMmsg, NULL, NULL), 
	 targetid = old_ssi.nmedges[i]);
   if(!(1&*EMmsg&sts))
    {
     sts = om$send(msg = message NMedge.NMreset_refuse(EMmsg, NULL, NULL, 
           construct->env_info), targetid = old_ssi.nmedges[i]);
     if(!(1&*EMmsg&sts)) goto delete_nmedge;
     need_to_check = FALSE;
     need_to_reconnect = FALSE;
    }

   /* Get all the edges from the NMedge. Each of these edges should be the
      top edges. There should not be any EMSpartedges or NMpartedges owning
      any of the parent edges. If there are any, that indicates a topology
      mismatch.

      In case of topology mismatch due to a parent edge getting split, I
      am simply deleting the NMedge, for now. Is there something more 
      meaningful that can be done - like creating NMedges for individual
      partedges and moving all the original dependents to the new NMedges?

      Similarly, each of the parent edges should be owned by an active loop.
      If it is not, then delete the NMedge. Again, is there some action that
      can be taken.

      None of the parent edges should have a NMedge created by a modeling
      operation. If there is one, delete this NMedge.

      Connect the NMedge to any new common edges that may have come into
      existence.
  */
   if(nmedge_edges) om$dealloc(ptr = nmedge_edges);
   nmedge_edges = NULL;
   num_nmedgeedges = 0;
   sts = om$send(msg = message NMedge.NMget_edge_info(EMmsg, &num_nmedgeedges, 
	 &nmedge_edges, NULL, NULL, NULL, NULL), targetid =old_ssi.nmedges[i]);
   if(!(1&*EMmsg&sts)) goto delete_nmedge;
   if(!num_nmedgeedges) goto delete_nmedge;

   for(j=0; j<num_nmedgeedges; j++)
    {
     IGRint num = 0;
     struct GRid model_nmedge;
     struct GRid creator_id;

     sts = EMcount_partedges(EMmsg, nmedge_edges[j].objid, &num, NULL, 
	   NULL, NULL, NULL);
     if( (!(1&*EMmsg&sts)) || num) goto delete_nmedge;

     num = 0;
     sts = NMcount_nmpartedges(EMmsg, nmedge_edges[j].objid,
           nmedge_edges[j].osnum, &num, NULL, NULL, NULL, NULL);
     if( (!(1&*EMmsg&sts)) || num) goto delete_nmedge;

     num = 0;
     sts = EMcount_loops(EMmsg, nmedge_edges[j].objid, &num, NULL, EMLP_ACTIVE,
	   NULL, NULL);
     if( (!(1&*EMmsg&sts)) || !num) goto delete_nmedge;	

     /* Check for a NMedge being created by a modeling operation. If there
        is one, delete this NMedge. Should I move the dependents of this NMedge
        to the NMedge created by the modeling operation?
     */
     model_nmedge.objid = NULL_OBJID;
     sts = NMget_edge_mates(EMmsg, &nmedge_edges[j], NULL, NULL, NULL, NULL, 
	   NULL, &model_nmedge, NULL, NULL, NULL);
     if( (!(1&*EMmsg&sts)) || (!IF_NULL_OBJID(model_nmedge.objid)))
      goto delete_nmedge;

     /* Get the creator id and the top tree node from this edge. If it is
        not the same as the node I currently depend on, disconnect that
        edge from the NMedge.
        The creator id of every edge connected to me must have the node
        I am connected to as the top node in the tree. This check is required
        so that trees that become disjoint (after undo) do not have a link
        through the NMedge.
     */
     creator_id.objid = NULL_OBJID;
     creator_id.osnum = modelid.osnum;
     sts = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg, 
           &creator_id.objid, FALSE), targetid = nmedge_edges[j].objid, 
           targetos = nmedge_edges[j].osnum);
     if(!(1&*EMmsg&sts)) goto delete_nmedge;
     if(!IF_NULL_OBJID(creator_id.objid))
      {
       sts = NMget_node(EMmsg, &creator_id, NULL, NULL, NULL, NULL, NULL, 
             &activeid, NULL);
       if(!(1&*EMmsg&sts)) goto delete_nmedge;
       if(!IF_EQ_GRID(modelid, activeid))
        {
	 sts = om$send(msg = message NMedge.NMdisconnect_edges(EMmsg, 1, 
	       &nmedge_edges[j], NULL, construct->env_info, NULL, NULL), 
	       targetid = old_ssi.nmedges[i]);
	 if(!(1&*EMmsg&sts)) goto delete_nmedge;
         goto next_nmedge_edge;
        }
      }

     /* Get this edge's common edge. Make sure the NMedge is also connected
        to it.
     */
     if(need_to_check)
      {
       GRobjid commid = NULL_OBJID;
       IGRint inx;
       IGRboolean found = FALSE;

       sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &commid), 
             senderid = nmedge_edges[j].objid, p_chanselect = &to_comm);
       if(!(1&*EMmsg&sts)) goto delete_nmedge;
       if(IF_NULL_OBJID(commid)) continue;

       for(inx = 0; inx<num_nmedgeedges; inx++)       
        if(IF_EQ_OBJID(commid, nmedge_edges[inx].objid))
         {
	  found = TRUE;
	  break;
         }
       if(!found)
        {
	 need_to_reconnect = TRUE;
	 need_to_check = FALSE;
        }

      } /* if(need_to_check) */

next_nmedge_edge:
;
    } /*    for(j=0; j<num_nmedgeedges; j++) */

   if(need_to_reconnect)
    {
     sts = om$send(msg = message NMedge.NMreset_refuse(EMmsg, NULL, NULL, 
           construct->env_info), targetid = old_ssi.nmedges[i]);
     if(!(1&*EMmsg&sts)) goto delete_nmedge;
     need_to_check = FALSE;
     need_to_reconnect = FALSE;
    }

   if(!have_children)
    {
     IGRint count = 1;

     om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDget_objects
            (ND_CHILDREN, NULL, NULL, NULL, 0, MAXINT, &count), 
            targetid = old_ssi.nmedges[i]);
     if(count) have_children = TRUE;
    }


   sts = NMsetUpSSI(EMmsg, NULL, &new_ssi, NULL);
   if(!(1&*EMmsg&sts)) goto delete_nmedge;

   new_ssi.nmedges[new_ssi.num_nmedges++] = old_ssi.nmedges[i];
   new_ssi.nmedgesbufsize--;

   goto next_nmedge;

delete_nmedge:

   if(OM_Gf_verbose_warning)
    fprintf(stderr, "Could not update NMedge %d - Deleting it\n",
     old_ssi.nmedges[i]);

   delete_ele(old_ssi.nmedges[i], construct->env_info);
   sts = om$send(msg = message NMedge.NMprop(EMmsg, prop_opt, &nmedge_props), 
         targetid = old_ssi.nmedges[i]);

   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   atleast_one_fail = TRUE;

next_nmedge:
   ;
  } /* for(i=0; i<old_ssi.num_nmedges; i++) */

 NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);


 strcat(status_str, dot);
 UI_status(status_str);

 /* Update the vertex uses.
 */
 for(i=0; i<old_ssi.num_sfs; i++)
  {
   IGRboolean delete_all = FALSE;
   IGRint m;

   this_nm = &old_ssi.nmentities[i];
   if(IF_NULL_OBJID(this_nm->sfid.objid))
    delete_all = TRUE;

   for(j=0; j<this_nm->num_vtxuses; j++)
    {
     struct NMentities *new_nm = NULL;
     IGRboolean vtxuse_uvpt_updated = FALSE;

     if(IF_NULL_OBJID(this_nm->vtxuses[j])) continue;
     if(delete_all) goto delete_vtxuse;

     sts = om$send(msg = message NMvertex_use.NMcheck(EMmsg), 
	    targetid = this_nm->vtxuses[j]);
     if(!(1&*EMmsg&sts))
      {
       sts = om$send(msg = message NMvertex_use.NMreset(EMmsg, NULL, 
             construct->env_info), targetid = this_nm->vtxuses[j]);
       if(!(1&*EMmsg&sts)) goto delete_vtxuse;
       vtxuse_uvpt_updated = TRUE;
      }

     /* The same criteria used for updating an NMedge also apply to the
        vertex use. Delete the vertex use if -
        o Any of the parent edges are split.
        o Any of the parent edges are not owned by an active loop.
        o There already exists a vertex use at the same location,
	  created by a modeling operation.
     */
     if(vtu_edges) om$dealloc(ptr = vtu_edges);
     if(vtu_loc) om$dealloc(ptr = vtu_loc);
     vtu_edges = NULL;
     vtu_loc = NULL;
     num_vtuedges = 0;

     sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
	   NULL_OBJID, &num_vtuedges, &vtu_edges, &vtu_loc, NULL, NULL, NULL, 
	   NULL), targetid = this_nm->vtxuses[j]);
     if( (!(1&*EMmsg&sts)) || !num_vtuedges) goto delete_vtxuse;

     for(m=0; m<num_vtuedges; m++)
      {
       IGRint num = 0;
       struct GRid refedge;

       if(!vtxuse_uvpt_updated)
        {
	 enum EMScvinttype tmploc;
	 IGRdouble uvpt[2];
	
         tmploc = vtu_loc[m];	
         if( (tmploc == EMScvint_rtend) || (tmploc == EMScvint_lfend))
          {
           sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
                 tmploc == EMScvint_rtend ? NULL : uvpt, 
	         tmploc == EMScvint_rtend ? uvpt : NULL, NULL, NULL, NULL), 
	         targetid = vtu_edges[m]);
           if(!(1&*EMmsg&sts)) goto delete_vtxuse;
           sts = om$send(msg = message NMvertex_use.NMpoint
	         (EMmsg, uvpt, FALSE), targetid = this_nm->vtxuses[j]);
           if(!(1&*EMmsg&sts)) goto delete_vtxuse;	
           vtxuse_uvpt_updated = TRUE;
          }
        }

       sts = EMcount_partedges(EMmsg, vtu_edges[m], &num, NULL, 
	     NULL, NULL, NULL);
       if( (!(1&*EMmsg&sts)) || num) goto delete_vtxuse;

       num = 0;
       sts = NMcount_nmpartedges(EMmsg, vtu_edges[m], OM_Gw_current_OS, 
             &num, NULL, NULL, NULL, NULL);
       if( (!(1&*EMmsg&sts)) || num) goto delete_vtxuse;

       num = 0;
       sts = EMcount_loops(EMmsg, vtu_edges[m], &num, NULL, EMLP_ACTIVE,
	     NULL, NULL);
       if( (!(1&*EMmsg&sts)) || !num) goto delete_vtxuse;	

       if(model_vtu) om$dealloc(ptr = model_vtu);
       model_vtu = NULL;
       num_modelvtu = 0;

       refedge.objid = vtu_edges[m];
       refedge.osnum = OM_Gw_current_OS;       
       sts = NMget_vertex_use(EMmsg, &refedge, &num_modelvtu, &model_vtu, NULL,
	     NULL, NULL, NULL, NULL, NULL, NULL, NULL, &vtu_loc[m], NULL,
	     NULL, NULL, NULL, NULL);
       if(!(1&*EMmsg&sts)) goto delete_vtxuse;
       if(num_modelvtu && model_vtu && (!IF_NULL_OBJID(model_vtu[0])))
        goto delete_vtxuse;

      } /* for(m=0; m<num_vtuedges; m++) */

     if(!vtxuse_uvpt_updated) goto delete_vtxuse;

     sts = NMsetUpSSI(EMmsg, &this_nm->sfid, &new_ssi, &new_nm);
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(!new_nm) goto delete_vtxuse;

     new_nm->vtxuses[(new_nm->num_vtxuses)++] = this_nm->vtxuses[j];
     new_nm->vtxusebufsize--;

     goto next_vtxuse;

delete_vtxuse:
      if(OM_Gf_verbose_warning)
       fprintf(stderr, "Could not update Vtxuse %d - Deleting it\n",
        this_nm->vtxuses[j]);

       delete_ele(this_nm->vtxuses[j], construct->env_info);
       sts = om$send(msg = message Root.wild_disconnect(to_vtx), 
             targetid = this_nm->vtxuses[j]);
       sts = om$send(msg = message NMvertex_use.NMprop(EMmsg, prop_opt, 
	     &vtxuse_props), targetid = this_nm->vtxuses[j]);

       sts = OM_S_SUCCESS;
       *EMmsg = EMS_S_Success;
       atleast_one_fail = TRUE;

next_vtxuse:
    if(!have_children)
     {
      IGRint count = 1;

      om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDget_objects
            (ND_CHILDREN, NULL, NULL, NULL, 0, MAXINT, &count), 
            targetid = this_nm->vtxuses[j]);
      if(count) have_children = TRUE;
     }

    } /* for(j=0; j<this_nm->num_vtxuses; j++) */

  } /* for(i=0; i<old_ssi.num_sfs; i++) */


 strcat(status_str, dot);
 UI_status(status_str);

 /* Update the vertices.
 */
 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuses);
 for(i=0; i<old_ssi.num_vtx; i++)
  {
   struct GRid surfid;
   IGRlong locsts, locmsg;

   sts = om$get_channel_count(objid = old_ssi.vtx[i], 
	 p_chanselect = &to_vtxuses, count = (OMuint *) &j);
   if(!(1&sts)) goto wrapup;

   /* If the vertex has no more vertex uses left, delete it.
   */
   if(!j) goto delete_vtx;

   /* Update the xyz point in the instance data (evaluate the first vertex
      use), and send NMcheck message to the vertex to create compatible
      vertex uses in all parametric spaces.
   */
   if(surf_geom) om$dealloc(ptr = surf_geom);
   if(vtu_edges) om$dealloc(ptr = vtu_edges);
   surf_geom = NULL;
   vtu_edges = NULL;
   num_vtuedges = 0;

   sts = om$send(msg = message NMvertex_use.NMget_incedence_info(EMmsg, 
         NULL_OBJID, &num_vtuedges, &vtu_edges, NULL, NULL, uvpt, NULL, 
	 NULL), senderid = old_ssi.vtx[i], p_chanselect = &to_vtxuses, 
	 from = 0, to = 0);
   if(!(1&*EMmsg&sts)) goto delete_vtx;

   surfid.objid = NULL_OBJID;
   for(j=0; j<num_vtuedges; j++)
    {
     locsts = om$send(msg = message EMSboundary.EMgetsurface_info(&locmsg, 
	      &surfid.objid, NULL), targetid = vtu_edges[j]);
     if(!IF_NULL_OBJID(surfid.objid)) break;
    }
   if(IF_NULL_OBJID(surfid.objid)) goto delete_vtx;

   surfid.osnum = construct->env_info->md_id.osnum;
   sts = EMgetvggeom(EMmsg, &construct->env_info->md_env.matrix_type, 
	 construct->env_info->md_env.matrix, &surfid, &surf_geom, NULL);
   if(!surf_geom) goto delete_vtx;

   BSsfeval(surf_geom, uvpt[0], uvpt[1], 0, xyzpt, &rc);
   if(rc != BSSUCC) goto delete_vtx;

   sts = om$send(msg = message NMvertex.NMpoint(EMmsg, xyzpt, FALSE), 
	 targetid = old_ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto delete_vtx;

   sts = om$send(msg = message NMvertex.NMcheck(EMmsg, &new_ssi, 
	 NMconnect_ExternalToModel | NMconnect_AddToSSI), 
	 targetid = old_ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto delete_vtx;

   sts = NMsetUpSSI(EMmsg, NULL, &new_ssi, NULL);
   if(!(1&*EMmsg&sts)) goto delete_vtx;
   new_ssi.vtx[new_ssi.num_vtx++] = old_ssi.vtx[i];
   new_ssi.vtxbufsize--;

   goto next_vtx;

delete_vtx:
   if(OM_Gf_verbose_warning)
    fprintf(stderr, "Could not update Vtx %d - Deleting it\n", old_ssi.vtx[i]);

   delete_ele(old_ssi.vtx[i], construct->env_info);
   sts = om$send(msg = message Root.wild_disconnect(to_vtxuses), 
             targetid = old_ssi.vtx[i]);
   sts = om$send(msg = message NMvertex.NMprop(EMmsg, prop_opt, 
	     &vtx_props), targetid = old_ssi.vtx[i]);

   atleast_one_fail = TRUE;
   sts = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

next_vtx:
    if(!have_children)
     {
      IGRint count = 1;

      om$send(mode = OM_e_wrt_message, msg = message NDnodein.NDget_objects
            (ND_CHILDREN, NULL, NULL, NULL, 0, MAXINT, &count), 
            targetid = old_ssi.vtx[i]);
      if(count) have_children = TRUE;
     }

  } /* for(i=0; i<old_ssi.num_vtx; i++) */

 strcat(status_str, dot);
 UI_status(status_str);


 sts = om$send(msg = message NMnonmanigm.NMput_SSI(EMmsg, &new_ssi), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Send a message to all the pointers to translate and store the object
    id, after having posted the new topology.
 */
 for (i=0;i<num_child;i++)
  {
   sts = om$send (msg = message EMSpointerA.EMstore_id_from_key(EMmsg,
             NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if (!(1&sts&*EMmsg)) goto wrapup;
  }

 if( (1&*EMmsg&sts) && atleast_one_fail)
  {
   ex$message(msgnumb = NM_I_PossTopMisMatchDet, buff = status_str);
   UI_status(status_str);
   sleep(1);
  }

wrapup:
current_creator = NULL_OBJID;
if(nmedge_edges) om$dealloc(ptr = nmedge_edges);
if(surf_geom) om$dealloc(ptr = surf_geom);
if(vtu_edges) om$dealloc(ptr = vtu_edges);
if(vtu_loc) om$dealloc(ptr = vtu_loc);
if(model_vtu) om$dealloc(ptr = model_vtu);

NMfree_ssi(&old_ssi);
NMfree_ssi(&new_ssi);
if( (1&*EMmsg&sts) && (*EMmsg != EMS_I_Fail) && !have_children && 
    !NMtp_persistent)
 om$send(msg = message GRgraphics.GRdelete(&rc, construct->env_info), 
 targetid = my_id);

if( (1&*EMmsg&sts) && atleast_one_fail) *EMmsg = EMS_I_Fail;
ex$message(msgnumb = NM_I_ClearStatusField)

EMWRAPUP(*EMmsg, sts, "NMnonmanitp.NMreexecute");
return(sts);
}



static void delete_ele(id, env)
GRobjid id;
struct GRmd_env *env;
{
 struct GRid objGRid;

 objGRid.objid = id;
 objGRid.osnum = OM_Gw_current_OS;
 nd$wait_batch(type = GR_DELETED, nb_obj = 1, l_object = &objGRid, 
	             l_obj_info = env);
}

end implementation NMnonmanitp;
