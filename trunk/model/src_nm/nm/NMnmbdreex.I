class implementation NMnonmanibnd;

/*
  HISTORY

        Sudha   06/28/93        Modified for BSprototype ansification
*/

#include "emsmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "NMmsg.h"
#include "msmacros.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfcvs.h"
#include "bschangepar.h"

#define StaticBuf 10

extern OMuword OPP_GRcurve_class_id, OPP_NMedflp_class_id;

from EMSloop import EMexecuteCurveFunction;

method NMreexecute(IGRlong *EMmsg; struct GRvg_construct *construct;
		   unsigned short reex_options)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 struct NMgmSSI		old_ssi;
 unsigned short	ssi_options;
 struct GRid		*nodes = NULL, my_GRid;
 IGRint			numnodes = 0, ndbufsize = 0, i, j;
 struct EMSobject_info  *parents = NULL, parentsbuf[StaticBuf];
 struct EMSdataselect	*cv_obj = NULL, cvbuf[StaticBuf];
 struct GRid		*cvids = NULL, cvidsbuf[StaticBuf];
 struct GRmd_env	locenv;
 extern OM_S_OBJID	current_creator;
 IGRboolean		was_active = FALSE, nodes_obtained = FALSE;
 OM_S_CHANSELECT	to_children;
 IGRint			num_child, numcv = 0, tmpnumcv = 0;
 struct GRid		*surfid = NULL, surfidbuf[StaticBuf];
 IGRint			*num_cvs_persf, numcvspersfbuf[StaticBuf], num_sfs, 
			tmpnumsfs;
 unsigned short	map_opt = 
			EMMapBnd_WantBadCurves |
                    	EMMapBnd_StrokeIfNeeded | EMMapBnd_NoValidate | 
		    	EMMapBnd_NoFixing | EMMapBnd_ClipBdryArea |
		    	EMMapBnd_NoRmvColEds, 
			nm_opt = NULL;
 IGRdouble		save_cht;
 struct EMScurveinfo	curve_info;
 IGRint			cvbufsize = 0, numcvs_created = 0, cvlcbufsize =0;
 struct GRid		*created_cvs = NULL;
 struct IGRbsp_surface	*surf_geom = NULL;
 IGRchar		status_str[200];

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&old_ssi);
 was_active = (ME.NMnonmanigm->nmprops & NMgm_Active) ? TRUE : FALSE;
 BSEXTRACTPAR(&rc, BSTOLCHRDHT, save_cht);
 BSchangepar(&rc, BSTOLCHRDHT, ME.NMnonmanibnd->cht);

 curve_info.messg_linestr = NULL;
 curve_info.messg_gencrv = NULL;
 curve_info.construct_list = construct;
 curve_info.linestr.objid = NULL_OBJID;
 curve_info.gencrv.objid = NULL_OBJID;
 curve_info.linestr_counter = curve_info.gencrv_counter = 0;
 curve_info.curves = &created_cvs;
 curve_info.buf_size = (IGRlong *) &cvbufsize;
 curve_info.num_curves = (IGRlong *) &numcvs_created;

#if DEBUG
 fprintf(stderr, "** Recomputing NMnonmanibnd node id %d\n", my_id);
#endif
 
 ex$message(msgnumb = NM_I_RecompEdgeCreation)
 ex$message(msgnumb = NM_I_RecompEdgeCreation, buff = status_str)

 if(IF_NULL_OBJID(construct->env_info->md_id.objid))
  {
   IGRint bytes_in, bytes_out;
   bytes_in = sizeof(struct GRmd_env);
   gr$get_module_env(msg = EMmsg, sizbuf = &bytes_in, buffer = &locenv, 
                     nret = &bytes_out);
   if(!(1&*EMmsg)) goto wrapup;
   construct->env_info = &locenv;
  }

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 /* Remove the feature loops created by the nodes above me, before
    recomputing myself. It is assumed that if this node is unevaluated, so
    is the entire tree.
 */
 if( (!(reex_options & NMreex_NoUneval)) && 
     (!(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)))
  {
   sts = NMget_node(EMmsg, &my_GRid, NULL, NULL, &nodes, &numnodes, &ndbufsize,
	 NULL, NMgetnode_All);
   if(!(1&*EMmsg&sts)) goto wrapup;
   nodes_obtained = TRUE;

   for(i=numnodes-1; i>=0; i--)
    {
     ssi_options = NMssiact_EraseFlps | NMssiact_DeactTopology |
		     NMssiact_EraseVtx;
     sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options,
           construct->env_info, NULL), 
	   targetid = nodes[i].objid, targetos = nodes[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

 /* Send a message to all pointers to translate and store the key, before
    deleting/recreating my topology.
 */
 sts = EMmake_chanselect(NDchildren_children, &to_children);
 if (!(1&sts)) goto wrapup;

 sts = om$get_channel_count(p_chanselect = &to_children,
                            object = me,
                            count = (OMuint *) &num_child);
 if (!(1&sts)) goto wrapup;
 for (i=0;i<num_child;i++)
  {
   sts = om$send (msg = message EMSpointerA.EMstore_key_from_id(EMmsg,
         NULL, NULL), p_chanselect = &to_children, from = i, to = i);
   if (sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
   if (!(1&sts&*EMmsg)) goto wrapup;
  }

 /* Collect my curve parents for recreating boundaries.
 */

 tmpnumsfs = ME.NMnonmanibnd->num_sfs;
 if(tmpnumsfs > StaticBuf)
  {
   surfid = (struct GRid *) om$malloc(size = tmpnumsfs * sizeof(struct GRid));
   num_cvs_persf = (IGRint *) om$malloc(size = tmpnumsfs * sizeof(IGRint));
  }
 else
  {
   surfid = surfidbuf;
   num_cvs_persf = numcvspersfbuf;
  }
 EMerr_hndlr(!surfid || !num_cvs_persf, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 numcv = 0;
 for(i=0; i<tmpnumsfs; i++)
  numcv += ME.NMnonmanibnd->num_cvs[i];

 if(numcv > StaticBuf)
  {
   cv_obj = (struct EMSdataselect *) om$malloc(size = numcv *  
	   sizeof(struct EMSdataselect));
   cvids = (struct GRid *) om$malloc(size = numcv * sizeof(struct GRid));
   cvlcbufsize = numcv;
  }
 else
  {
   cv_obj = cvbuf;
   cvids = cvidsbuf;
   cvlcbufsize = StaticBuf;
  }
 EMerr_hndlr(!cv_obj || !cvids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$send(msg = message NMnonmanigm.NMget_SSI(EMmsg, &old_ssi, 
       NMgetssi_cache | NMgetssi_NoNmEdge | NMgetssi_NoVtx), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Collect all valid surfaces to create boundaries. For each surface
    get the number of curves and the curve ids. If no curves exist for a
    surface, update the existing boundaries.
 */
 numcv = 0;
 tmpnumcv = 0;
 num_sfs = 0;
 for(i=0; i<tmpnumsfs; i++)
  {
   sts = NMtag(EMmsg, &surfid[num_sfs], &ME.NMnonmanibnd->sfid[i], FALSE);
   if( (*EMmsg == EMS_I_Fail) || (IF_NULL_OBJID(surfid[num_sfs].objid)))
    {
     numcv += ME.NMnonmanibnd->num_cvs[i];
     continue;
    }

   num_cvs_persf[num_sfs] = 0;
   for(j=0; j<ME.NMnonmanibnd->num_cvs[i]; j++)
    {
     sts = NMtag(EMmsg, &cvids[tmpnumcv], 
	   &ME.NMnonmanibnd->cvid[numcv], FALSE);
     if( (*EMmsg == EMS_I_Fail) || 
	 (IF_NULL_OBJID(cvids[tmpnumcv].objid)))
      {
       numcv++;
       continue;
      }

     cv_obj[tmpnumcv].datatype = EMSdata_object;
     cv_obj[tmpnumcv].data.object = &cvids[tmpnumcv];
     tmpnumcv++;
     cvlcbufsize--;
     (num_cvs_persf[num_sfs])++;
     numcv++;
    }

   /* If no curve parents, use the xyz geometry of the featureloops created
      to re-create boundaries. At this point, un-evaluation of this node has
      already taken place. So any edge replacements that had occured on the
      feature loops have been undone. The feature loops are now the closest
      representation of the original curves that were used to create the
      boundaries.
   */

   if(!num_cvs_persf[num_sfs])
    {
     struct NMentities *this_nm = NULL;
     unsigned short eligible_edge_type = NULL;
     extern IGRint EMmake_surface_curves();

     for(j=0; j<old_ssi.num_sfs; j++)
      if(IF_EQ_GRID(old_ssi.nmentities[j].sfid, surfid[num_sfs]))
       {
	this_nm = &old_ssi.nmentities[j];
	break;
       }

     if(!this_nm) goto next_sf;

     if(surf_geom) om$dealloc(ptr = surf_geom);
     surf_geom = NULL;
     sts = EMgetvggeom(EMmsg, &construct->env_info->md_env.matrix_type, 
           construct->env_info->md_env.matrix, &surfid[num_sfs], &surf_geom, NULL);
     if(!(1&*EMmsg&sts)) goto wrapup;

     if(created_cvs) om$dealloc(ptr = created_cvs);
     created_cvs = NULL;
     cvbufsize = 0;
     numcvs_created = 0;
     for(j=0; j<this_nm->num_flps; j++)
      {
       /* Ignore Edflps since they were created internally.
       */
       if(EFisAncestryValid(EMmsg, this_nm->flps[j], surfid[num_sfs].osnum, 
	  OPP_NMedflp_class_id, FALSE)) continue;
	
       sts = om$send(msg = message EMSloop.EMexecuteCurveFunction(EMmsg, 
	     surf_geom, &construct->env_info->md_env.matrix_type, 
	     construct->env_info->md_env.matrix, surfid[num_sfs].objid, 
	     EMmake_surface_curves, (IGRchar *) &curve_info, 
	     eligible_edge_type), targetid = this_nm->flps[j]);
       if(!(1&*EMmsg&sts)) goto wrapup;
      }

     if(!numcvs_created) goto next_sf;
     if(cvlcbufsize < numcvs_created)
      {
       if(cv_obj == cvbuf)
        {
         cv_obj = (struct EMSdataselect *) om$malloc(size = 
		  (numcvs_created + tmpnumcv) *  sizeof(struct EMSdataselect));
	 cvids = (struct GRid *) om$malloc(size = (numcvs_created + tmpnumcv)
		  * sizeof(struct GRid));
	 EMerr_hndlr(!cv_obj || !cvids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	 if(tmpnumcv)
	  {
	   OM_BLOCK_MOVE(cvbuf,cv_obj,tmpnumcv * sizeof(struct EMSdataselect));
	   OM_BLOCK_MOVE(cvidsbuf, cvids, tmpnumcv * sizeof(struct GRid));
	  }
	 cvlcbufsize = numcvs_created;
        }
       else if(cv_obj)
        {
         cv_obj = (struct EMSdataselect *) om$realloc(ptr = (IGRchar *)cv_obj, 
		size = (numcvs_created + tmpnumcv) 
			* sizeof(struct EMSdataselect));
         cvids = (struct GRid *) om$realloc(ptr = (IGRchar *)cvids, 
		size = (numcvs_created + tmpnumcv) * sizeof(struct GRid));
	
	 EMerr_hndlr(!cv_obj || !cvids, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
	 cvlcbufsize = numcvs_created;	
        }
       else
        {
	 *EMmsg = EMS_E_Fail;
	 goto wrapup;
        }
      }

     for(j=0; j<numcvs_created; j++)
      {
       struct IGRbsp_curve *cvptr = NULL;
       IGRlong locsts, locrc;

       sts = EMgetvggeom(EMmsg, &construct->env_info->md_env.matrix_type, 
             construct->env_info->md_env.matrix, &created_cvs[j], &cvptr, NULL);
       if(!(1&*EMmsg&sts)) goto wrapup;

       if(cvptr)
        {
         cv_obj[tmpnumcv].datatype = EMSdata_curve3d;
         cv_obj[tmpnumcv++].data.curve = cvptr;
         cvlcbufsize--;
         (num_cvs_persf[num_sfs])++;
        }

       locsts = om$send(msg = message GRgraphics.GRdelete(&locrc, 
		construct->env_info), targetid = created_cvs[j].objid, 
		targetos = created_cvs[j].osnum);
      }

    } /* if(!num_cvs_persf[num_sfs]) */

next_sf:
   if(num_cvs_persf[num_sfs]) num_sfs++;

  } /* for(i=0; i<tmpnumsfs; i++) */


 /* Delete my old topology 
 */
 ssi_options = NMssiact_RedrawAffectedSfs | NMssiact_DeleteTopology;
 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options, 
       construct->env_info, NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 current_creator = NULL_OBJID;

 sts = om$send(msg = message NMnonmanibnd.NMcreate_boundaries(EMmsg, num_sfs, 
       surfid, num_cvs_persf, cv_obj, construct->env_info, construct,
       map_opt, nm_opt, status_str), targetid = my_id);
 ME.NMnonmanigm->nmprops &= ~NMgm_Unevaluated;

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

 ssi_options = NMssiact_DrawFlps | NMssiact_DrawVtx;
 sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssi_options, 
       construct->env_info, NULL), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 
 /* Re-execute the nodes above me if so specified.
 */
 if(reex_options & NMreex_RecomputeAll)
  {
   unsigned short locoptions;
   
   locoptions = reex_options | NMreex_NoUneval;
   locoptions &= ~NMreex_RecomputeAll;
   if(!nodes_obtained)
    {
     sts = NMget_node(EMmsg, &my_GRid, NULL, NULL, &nodes, &numnodes, 
	  &ndbufsize, NULL, NMgetnode_All);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   for(i=0; i<numnodes; i++)
    {
     if(IF_EQ_GRID(my_GRid, nodes[i])) continue;
     sts = om$send(msg = message NMnonmanigm.NMreexecute(EMmsg, construct, 
           locoptions), targetid = nodes[i].objid, 
           targetos = nodes[i].osnum);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }
  }

wrapup:

for(i=0; i<numcvs_created; i++)
 {
  IGRlong locsts, locrc;
  locsts = om$send(msg = message GRgraphics.GRdelete(&locrc, construct->env_info), 
	   targetid = created_cvs[i].objid, targetos = created_cvs[i].osnum);
 }

BSchangepar(&rc, BSTOLCHRDHT, save_cht);
current_creator = NULL_OBJID;
/* Set the active property to what it was in the begining.
*/
if(was_active) ME.NMnonmanigm->nmprops |= NMgm_Active;
else ME.NMnonmanigm->nmprops &= (~NMgm_Active);

if(nodes) om$dealloc(ptr = nodes);

if(cv_obj && (cv_obj != cvbuf)) om$dealloc(ptr = cv_obj);
if(cvids && (cvids != cvidsbuf)) om$dealloc(ptr = cvids);
if(parents && (parents != parentsbuf)) om$dealloc(ptr = parents);
if(created_cvs) om$dealloc(ptr = created_cvs);
if(surf_geom) om$dealloc(ptr = surf_geom);

if(!(1&*EMmsg&sts))
 {
  IGRlong locsts, rc;

  ex$message(msgnumb = NM_I_RecompFailedNullNode)
  sleep(3);
  ssi_options = NMssiact_EraseFlps | NMssiact_DeactTopology |
                NMssiact_EraseVtx;
  locsts = om$send(msg = message NMnonmanigm.NMSSI_action(&rc, ssi_options,
        construct->env_info, NULL), targetid = my_id);

  ssi_options = NMssiact_RedrawAffectedSfs | NMssiact_DeleteTopology;
  locsts = om$send(msg = message NMnonmanigm.NMSSI_action(&rc, ssi_options, 
        construct->env_info, NULL), targetid = my_id);
  ME.NMnonmanigm->nmprops &= ~NMgm_Unevaluated;
  ME.NMnonmanigm->nmprops |= NMgm_NullState;
 }

ex$message(msgnumb = NM_I_ClearStatusField)

EMWRAPUP(*EMmsg, sts, "NMnonmanibnd.NMreexecute");
return(sts);
}

end implementation NMnonmanibnd;
