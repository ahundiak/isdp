/*
History

	SM	01-April-1991		Fool's creation.
	SM	05-Sept-1991		Instead of deleting nmedges and vtus
					directly via Root.delete, put them
					in the delete batch. This is to prevent
					graph manager from complaining.
	SM	03-Mar-1992		Supress all relevant error checks, so
					that most possible is accomplished 
					instead of aborting.
*/
class implementation NMnonmanigm;

#include "nmchandef.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "ndmacros.h"
#include "EMSlmdef.h"

#define StaticBuf 10

#define ManyEd_By_OneEd 0

from NMvertex import NMprop;
from NMvertex_use import NMprop, NMreplace_edge;
from EMSgraloop import EMdisplay;
from EMSsubbs import EMget_ele_header;
from EMSloop import EMset_props;
from EMSedge import EMset_props;
from NMedge import NMprop, NMconnect_edges, NMdisconnect_edges;
from EMSpartedge import EMgetbounds, EMputbounds;

extern struct NMgmssi_cache NMnonmanigm_ssi_cache;
extern OMuword OPP_NMlistvtxuse_class_id, OPP_NMlistedge_class_id, 
	       OPP_NMedflp_class_id, OPP_EMSpartedge_class_id;

method NMSSI_action (IGRlong *EMmsg; IGRushort options;
                    struct GRmd_env *env; struct NMgmSSI *in_ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 IGRint			i, j;
 enum GRdpmode		draw = GRbd, erase = GRbe;
 IGRboolean		delete_ele, deact_vtx, deact_top, unsplit_ed, 
			rev_ed, discon_flp, deact_nmedge, unchg_vtu, untr_vtu;
 OM_S_CHANSELECT	to_sf, to_edges, to_lp, to_vtxuse, to_vtx;
 unsigned char	vtudeact = NMvtxuse_Active, vtxdeact = NMvtx_Active, 
			nmedgedeact = NMedge_Active;
 struct DPele_header    local_sf_ele_header, *ele_header = NULL;
 struct IGResqbs        bsqsurf;
 GRrange                range;
 struct GRsymbology     symb;
 union IGRele_attr      ele_spec_att;
 struct NMentities	*this_nm = NULL;
 GRobjid		*tmpedsin = NULL, 
			tmpedsin_buf[StaticBuf], *tmpedsout = NULL, 
			tmpedsout_buf[StaticBuf];
 IGRint			*tmpnumedsin = NULL, tmpnumedsin_buf[StaticBuf];
 struct NMgmSSI		locssi;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&locssi);
 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuse);
 NMmake_chanselect(NMvertex_use_to_vtx, &to_vtx);

 ele_header = &local_sf_ele_header;
 ele_spec_att.bsqsurf = &bsqsurf;

 deact_top = options & NMssiact_DeactTopology;
 delete_ele = options & NMssiact_DeleteTopology;
 deact_vtx = deact_top ? TRUE : (options & NMssiact_DeactivateVtx);
 deact_nmedge = deact_top ? TRUE : (options & NMssiact_DeactivateNmEdge);
 unsplit_ed = deact_top ? TRUE : (options & NMssiact_UnsplitEdges);
 unchg_vtu = deact_top ? TRUE : (options & NMssiact_UnChangeVtxuse);
 untr_vtu = deact_top ? TRUE : (options & NMssiact_UnTransVtxuse);
 rev_ed = deact_top ? TRUE : (options & NMssiact_ReverseEdges);
 discon_flp = deact_top ? TRUE : (options & NMssiact_DisconnectFlps);

 EMerr_hndlr(deact_top && (ME.NMnonmanigm->nmprops & NMgm_Unevaluated)
	     && !delete_ele, *EMmsg, EMS_I_Useless, wrapup);
	
 if(discon_flp)
  EMmake_chanselect(EMShelper_to_requesters, &to_sf);
 if(delete_ele || deact_top)
  {
   EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
   EMmake_chanselect(EMSedge_to_owner, &to_lp);
  }

 if(in_ssi)
  locssi = *in_ssi;
 else
  {
   sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &locssi, NULL), 
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 if(options & NMssiact_EraseFlps)
  {
   for(i=0; i<locssi.num_sfs; i++)
    {
     this_nm = &locssi.nmentities[i];
     if(IF_NULL_OBJID(this_nm->sfid.objid)) continue;

     /*
      * Get the element header
      */
     sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
           &env->md_env, NULL, ele_header, 
	   range, &symb.display_attr, ele_spec_att, NULL),
           targetid = this_nm->sfid.objid, 
	   targetos = this_nm->sfid.osnum);
     if(! (1 & *EMmsg & sts)) continue;

     for(j=0; j<this_nm->num_flps; j++)
      {
       if(IF_NULL_OBJID(this_nm->flps[j])) continue;
	sts = om$send(msg = message EMSgraloop.EMdisplay(EMmsg, FALSE, 
	      &erase, NULL, NULL, ele_header, &env->md_env.matrix_type, 
	      env->md_env.matrix, NULL, NULL, NULL, NULL, NULL), 
              targetid = this_nm->flps[j]);

       sts = OM_S_SUCCESS;
       *EMmsg = EMS_S_Success;
      }
    }

  } /* if(options & NMssiact_EraseFlps) */


 /* In case of the option being deactivating topology, disconnect the
    connected edges and reconnect the disconnected edges.
 */
 if(deact_top)
  {
   struct GRid ed;

   /* Reconnect disconnected edges.
   */
   for(i=0; i<locssi.num_sfs; i++)
    {
     this_nm = &locssi.nmentities[i];
     ed.osnum = this_nm->sfid.osnum;
     for(j=this_nm->numeddiscon-1; j>=0; j--)
      {
       ed.objid = this_nm->eddiscon[j];
       if( (IF_NULL_OBJID(ed.objid)) || 
	   (IF_NULL_OBJID(this_nm->nmedgesdiscon[j]))) continue;

       sts = om$send(msg = message NMedge.NMconnect_edges(EMmsg, 1, 
             &ed, &this_nm->sfid, NULL, env, NULL, NULL), 
	     targetid = this_nm->nmedgesdiscon[j]);
       /*if(!(1&*EMmsg&sts)) goto wrapup;*/
      }
    }

   /* Disconnect edges connected.
   */
   for(i=0; i<locssi.num_sfs; i++)
    {
     this_nm = &locssi.nmentities[i];
     ed.osnum = this_nm->sfid.osnum;
     for(j=this_nm->numedcon-1; j>=0; j--)
      {
       ed.objid = this_nm->edcon[j];
       if( (IF_NULL_OBJID(ed.objid)) ||
	   (IF_NULL_OBJID(this_nm->nmedgescon[j]))) continue;

       sts = om$send(msg = message NMedge.NMdisconnect_edges(EMmsg, 1, 
             &ed, &this_nm->sfid, env, NULL, NULL), 
       targetid = this_nm->nmedgescon[j]);
       /*if(!(1&*EMmsg&sts)) goto wrapup;*/
      }
    }

  }


 for(i=0; i<locssi.num_sfs; i++)
  {
   this_nm = &locssi.nmentities[i];

   if(unsplit_ed && this_nm->numedgesout)
    {
     IGRint totaledsin = 0, idx = 0;

     /* Put back the edges out and delete the edges in if required. 
	Reverse the order of the data used for replacement to account for 
	possible multiple splits on the same edge.
     */
     for(j=0; j<this_nm->numedgesout; j++)        
      totaledsin += this_nm->numedgesin[j];
     if(totaledsin > StaticBuf)
      tmpedsin = (GRobjid *) om$malloc(size = totaledsin *
		sizeof(GRobjid));
     else tmpedsin = (GRobjid *) tmpedsin_buf;
     if(this_nm->numedgesout > StaticBuf)
      {
       tmpedsout = (GRobjid *) om$malloc(size = this_nm->numedgesout
			* sizeof(GRobjid));
       tmpnumedsin = (IGRint *) om$malloc(size = this_nm->numedgesout
			* sizeof(IGRint));
      }
     else 
      {
       tmpedsout = tmpedsout_buf;	 
       tmpnumedsin = tmpnumedsin_buf;
      }
     idx = 0;
     for(j=this_nm->numedgesout-1; j>=0; j--)
      {
       tmpedsout[idx] = this_nm->edgesout[j];
       tmpnumedsin[idx++] = this_nm->numedgesin[j];
      }
     idx = 0;
     for(j=totaledsin-1; j>=0; j--)
     tmpedsin[idx++] = this_nm->edgesin[j];

     EFrpl_old_new_eds(EMmsg, this_nm->numedgesout, tmpedsout, 
     tmpnumedsin, tmpedsin, OM_Gw_current_OS, ManyEd_By_OneEd, FALSE,
     FALSE);
     *EMmsg = EMS_S_Success;

    } /* if(unsplit_ed) */



   if(delete_ele || discon_flp || deact_top)
    {
     for(j=0; j<this_nm->num_flps; j++)
      {
       if(IF_NULL_OBJID(this_nm->flps[j])) continue;
       if(delete_ele)
        {
	 /* Disconnect the feature loop from its edges to prevent the 
	    edges from getting deleted. I didn't create them, so I ain't 
	    deleting them. I could send Root.delete wrt message to the loop
	    but I wish to get any other processing going on in the loop's
	    override (like notification).
	    The edges created by me will be explicitly deleted by me, not via
	    loops.
	 */
	 sts = om$send(msg = message Root.wild_disconnect(to_edges), 
              targetid = this_nm->flps[j]);
         /*if(!(1&sts)) goto wrapup;*/
         sts = om$send(msg = message Root.delete(TRUE), 
              targetid = this_nm->flps[j]);
         /*if(!(1&sts)) goto wrapup;*/
        }
       else
        {
	 sts = om$send(msg = message EMSloop.EMset_props(EMmsg, EMLP_ACTIVE, 
	       EMS_O_OFF), targetid = this_nm->flps[j]);
	
         sts = om$send(msg = message Root.wild_disconnect(to_sf), 
               targetid = this_nm->flps[j]);
        }

      } /* for(j=0; j<this_nm->num_flps; j++) */

    } /* if(delete_ele || discon_flp || deact_top) */


   /* If an edge of a vertex use was replaced by some other edge, undo that
      effect. Traverse the data backwards to take care of multiple replacements
      of the same vertex use.
   */
   if(unchg_vtu && this_nm->numvtxusechg)
    for(j=this_nm->numvtxusechg-1; j>=0; j--)
     {
      if(IF_NULL_OBJID(this_nm->vtxusechg[j])) continue;

      if(IF_NULL_OBJID(this_nm->origedges[j]))
       sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
             this_nm->repledges[j], 0, NULL, NULL,
	     NMconnect_InTransientState, NULL), 
	     targetid = this_nm->vtxusechg[j]);
      else
       sts = om$send(msg = message NMvertex_use.NMreplace_edge(EMmsg, 
             this_nm->repledges[j], 1, &this_nm->origedges[j], NULL,
	     NMconnect_InTransientState, NULL), 
	     targetid = this_nm->vtxusechg[j]);
      /*if(!(1&*EMmsg&sts)) goto wrapup;*/
     }

   /* If an vertex use was transfered from one vtx to another, disconnect
      it from the repl vtx and reconnect it to the orig vtx.
   */
   if(untr_vtu && this_nm->numvtxusetr)
    for(j=this_nm->numvtxusetr-1; j>=0; j--)
     {
      if(IF_NULL_OBJID(this_nm->vtxusetr[j])) continue;

      sts = om$send(msg = message Root.wild_disconnect(to_vtx), 
	    targetid = this_nm->vtxusetr[j]);
      /*if(!(1&sts)) goto wrapup;*/

      if(!IF_NULL_OBJID(this_nm->origvtx[j]))
       {
	sts = om$send(msg = message Root.connect(to_vtx, NULL, 
	      this_nm->origvtx[j], OM_Gw_current_OS, to_vtxuse, NULL), 
	      senderid = this_nm->origvtx[j], targetid = this_nm->vtxusetr[j]);
	/*if(!(1&sts)) goto wrapup;*/
       }
     }

   if(rev_ed)
    for(j=0; j<this_nm->numedgesrev; j++)
     if(!IF_NULL_OBJID(this_nm->edgesrev[j]))
      sts = NMreverse_the_edge(EMmsg, this_nm->edgesrev[j], OM_Gw_current_OS);


   if(delete_ele || deact_top)
    {
     IGRint totaledsin = 0;
     for(j=0; j<this_nm->numedgesout; j++)        
      totaledsin += this_nm->numedgesin[j];
     for(j=0; j<totaledsin; j++)
      {
       if(IF_NULL_OBJID(this_nm->edgesin[j])) continue;

       if(EFisAncestryValid(EMmsg, this_nm->edgesin[j], OM_Gw_current_OS, 
	  OPP_EMSpartedge_class_id, TRUE))
	sts = om$send(msg = message Root.wild_disconnect(to_edges), 
	      targetid = this_nm->edgesin[j]);
 
       if(delete_ele)
        {
         sts = om$send(msg = message Root.wild_disconnect(to_lp), 
		targetid = this_nm->edgesin[j]);

         sts = om$send(msg = message Root.delete(TRUE), 
	      targetid = this_nm->edgesin[j]);
	}
      }
    }

   if(delete_ele || deact_top)
    {
     for(j=0; j<this_nm->num_edges; j++)
      {
       if(IF_NULL_OBJID(this_nm->edges[j])) continue;

       if(EFisAncestryValid(EMmsg, this_nm->edges[j], OM_Gw_current_OS, 
	  OPP_EMSpartedge_class_id, TRUE))
	sts = om$send(msg = message Root.wild_disconnect(to_edges), 
	      targetid = this_nm->edges[j]);
 
        if(delete_ele)
        {
         sts = om$send(msg = message Root.wild_disconnect(to_lp), 
		targetid = this_nm->edges[j]);

         sts = om$send(msg = message Root.delete(TRUE), 
             targetid = this_nm->edges[j]);
	}
      }
    }

   if(delete_ele)
    {
     for(j=0; j<this_nm->num_vtxuses; j++)
      {
       struct GRid vtuGRid;

       if(IF_NULL_OBJID(this_nm->vtxuses[j])) continue;

       sts = om$send(msg = message NMvertex_use.NMprop
	     (EMmsg, NMprop_SetOff, &vtudeact), 
             targetid = this_nm->vtxuses[j]);
       if(EFisAncestryValid(EMmsg, this_nm->vtxuses[j], OM_Gw_current_OS,
	  OPP_NMlistvtxuse_class_id, TRUE))
        sts = om$send(msg = message Root.delete(TRUE), 
		targetid = this_nm->vtxuses[j]);
       else
        {
         vtuGRid.objid = this_nm->vtxuses[j];
         vtuGRid.osnum = OM_Gw_current_OS;
         nd$wait_batch(type = GR_DELETED, nb_obj = 1, l_object = &vtuGRid, 
		       l_obj_info = env);
	}
      }
    }
   else if(deact_vtx)
    for(j=0; j<this_nm->num_vtxuses; j++)
     {
      if(IF_NULL_OBJID(this_nm->vtxuses[j])) continue;
      sts = om$send(msg = message NMvertex_use.NMprop
	    (EMmsg, NMprop_SetOff, &vtudeact), 
         targetid = this_nm->vtxuses[j]);
     }

  } /* for(i=0; i<locssi.num_sfs; i++) */

 /* Erase the vertices created by me.
 */
 if(options & NMssiact_EraseVtx)
  for(i=0; i<locssi.num_vtx; i++)
   {
    if(IF_NULL_OBJID(locssi.vtx[i])) continue;

     sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
           &env->md_env.matrix_type, env->md_env.matrix, &erase, 
           &env->md_id), targetid = locssi.vtx[i]);
   }

 if(delete_ele)
  {
   for(i=0; i<locssi.num_nmedges; i++)
    {
     struct GRid nmedGRid;

     if(IF_NULL_OBJID(locssi.nmedges[i])) continue;

     sts = om$send(msg = message NMedge.NMprop
           (EMmsg, NMprop_SetOff, &nmedgedeact), 
           targetid = locssi.nmedges[i]);
     if(EFisAncestryValid(EMmsg, locssi.nmedges[i], OM_Gw_current_OS,
        OPP_NMlistedge_class_id, TRUE))
      sts = om$send(msg = message Root.delete(TRUE), 
		targetid = locssi.nmedges[i]);
     else
      {
       nmedGRid.objid = locssi.nmedges[i];
       nmedGRid.osnum = OM_Gw_current_OS;
       nd$wait_batch(type = GR_DELETED, nb_obj = 1, l_object = &nmedGRid, 
	             l_obj_info = env);
      }
    }

   ME.NMnonmanigm->num_nmedges = 0;

   for(i=0; i<locssi.num_vtx; i++)
    {
     if(IF_NULL_OBJID(locssi.vtx[i])) continue;	
     sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, env), 
           targetid = locssi.vtx[i]);
    }
   ME.NMnonmanigm->num_vtx = 0;
  }
 else
  {
   if(deact_vtx)
    for(i=0; i<locssi.num_vtx; i++)
     {
      if(IF_NULL_OBJID(locssi.vtx[i])) continue;	
      sts = om$send(msg = message NMvertex.NMprop
	    (EMmsg, NMprop_SetOff, &vtxdeact), 
            targetid = locssi.vtx[i]);
     }

   if(deact_nmedge)
    for(i=0; i<locssi.num_nmedges; i++)
     {
      if(IF_NULL_OBJID(locssi.nmedges[i])) continue;
      sts = om$send(msg = message NMedge.NMprop
	    (EMmsg, NMprop_SetOff, &nmedgedeact), 
            targetid = locssi.nmedges[i]);
     }
  }

 if(options & NMssiact_DrawVtx)
  for(i=0; i<locssi.num_vtx; i++)
   {
    if(IF_NULL_OBJID(locssi.vtx[i])) continue;	
    sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
          &env->md_env.matrix_type, env->md_env.matrix, &draw, 
          &env->md_id), targetid = locssi.vtx[i]);
   }


 if(options & NMssiact_RedrawAffectedSfs)
  {
   for(i=0; i<locssi.num_sfs; i++)
    {
     this_nm = &locssi.nmentities[i];
     if(IF_NULL_OBJID(this_nm->sfid.objid)) continue;
     sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
          &env->md_env.matrix_type, env->md_env.matrix, &draw, 
          &env->md_id), targetid = this_nm->sfid.objid);
    }
  }

 if(options & NMssiact_DrawFlps)
  {
   for(i=0; i<locssi.num_sfs; i++)
    {
     this_nm = &locssi.nmentities[i];
     if(IF_NULL_OBJID(this_nm->sfid.objid)) continue;

     /*
      * Get the element header
      */
     sts = om$send(msg = message EMSsubbs.EMget_ele_header(EMmsg, NULL,
           &env->md_env, NULL, ele_header, 
	   range, &symb.display_attr, ele_spec_att, NULL),
           targetid = this_nm->sfid.objid, 
 	   targetos = ME.NMnonmanigm->sfid[i].osnum);
     if(! (1 & *EMmsg & sts)) continue;

     for(j=0; j<this_nm->num_flps; j++)
      {
       if(IF_NULL_OBJID(this_nm->flps[j])) continue;
	sts = om$send(msg = message EMSgraloop.EMdisplay(EMmsg, FALSE, 
	      &draw, NULL, NULL, ele_header, &env->md_env.matrix_type, 
	      env->md_env.matrix, NULL, NULL, NULL, NULL, NULL), 
              targetid = this_nm->flps[j]);
        sts = OM_S_SUCCESS;
        *EMmsg = EMS_S_Success;
      }    
    }
  }

if(deact_top) ME.NMnonmanigm->nmprops |= NMgm_Unevaluated;
if(delete_ele)
 {
  NMnonmanigm_ssi_cache.is_valid = FALSE;
  NMnonmanigm_ssi_cache.elemid.objid = NULL_OBJID;
 }


wrapup:
if(!in_ssi) NMfree_ssi(&locssi);

if(tmpedsout && (tmpedsout != tmpedsout_buf)) om$dealloc(ptr = tmpedsout);
if(tmpedsin && (tmpedsin != tmpedsin_buf)) om$dealloc(ptr = tmpedsin);
if(tmpnumedsin && (tmpnumedsin != tmpnumedsin_buf)) 
  om$dealloc(ptr = tmpnumedsin);

EMWRAPUP(*EMmsg, sts, "NMnonmanigm.NMSSI_action");
*EMmsg = EMS_S_Success;
return(OM_S_SUCCESS);
}


end implementation NMnonmanigm;
