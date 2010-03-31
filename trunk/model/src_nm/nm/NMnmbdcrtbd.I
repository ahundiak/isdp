class implementation NMnonmanibnd;

/* HISTORY

 SM       ????????      Creation

 NP       06/17/93      Funtction "EMmkintlist" is now called by a new
                        name, "EMmakeintlist", due to addition of two
                        new curve type parameters.
                        NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN

                              THE CALL (CURRENTLY SET TO NULL).
 RT       09/28/94	transmigrate flag should be set to FALSE for curves

*/

#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "emsinterdef.h"
#include "grownerdef.h"
#include "emsmacros.h"
#include "msmacros.h"
#include "NMmsg.h"

#define StaticBuf 10

from EMSsurface import EMputLsIfNotThere;
from EMSsubbs import EMget_natedge_info;
from EMSlinedge import EMsetIsoType;
from EMSedge import EMget_bcxyz_geom, EMtrimyourself;
from NMvertex import NMcheck;

extern OMuword OPP_EMSplane_class_id;

method NMcreate_boundaries(IGRlong *EMmsg; IGRint num_sfs;
			   struct GRid *surfid; IGRint *num_cvs_persf;
			   struct EMSdataselect *curves;
			    struct GRmd_env *my_env; 
			    struct GRvg_construct *construct;
			    unsigned short map_options,
			    nm_options; IGRchar *status_str)

{
 IGRlong			sts = OM_S_SUCCESS, status, rc;
 struct IGRbsp_surface		*surf_geom = NULL;
 struct EMSpartolbasis		partol;
 struct GRid			clip_ls, my_GRid;
 struct EMSgetlp_output		getlp_loops;
 GRobjid			*loops = NULL;
 IGRint				num_loops = 0, i, num_edges, j, sfnum, nump;
 unsigned char		edtype[4];
 unsigned short		edprops[4];
 OM_S_CHANSELECT		to_edges;
 struct NMgmSSI			ssi;
 struct EMSinters		*inters = NULL;
 struct EMSdataselect		this_xyzintobj, this_uvintobj;
 struct IGRbsp_curve		*this_xyz = NULL;
 struct EMSsfintedpar		*edpar = NULL;
 IGRint				num_bdry;
 unsigned short		trmopt = EMS_INTER_BDRYISAREA | 
				 EMS_INTER_CUTTING | EMS_INTER_STARTPT | 
				 EMS_INTER_STOPPT | EMS_INTER_MOREPRECISE;
 struct NMentities		*this_nm = NULL;
 IGRdouble			cht, tracetol;
 struct EMSsftracedata		tracedata;
 extern OM_S_OBJID		current_creator;
 struct EMSobject_info		*my_parents = NULL, my_parentsbuf[StaticBuf];
 IGRint				my_num_parents = 0;
 struct GRid			actid, *my_base = NULL, my_basebuf[StaticBuf], 
				*this_sf;
 IGRboolean			*my_trans = NULL, my_transbuf[StaticBuf];
 unsigned short		initas_opt = EMS_no_const_assoc 
				| EMSinit_dont_store_recomp_info;
 unsigned short 		nmprops = NMgm_Active;
 unsigned short 		ssiopt = NMssiact_DrawFlps | NMssiact_DrawVtx;
 IGRboolean			curve_assoc = TRUE;
 struct EMSdataselect		*crvptr = NULL;
 IGRchar			locsts_str[200], dot[2];


 *EMmsg = EMS_S_Success;
 partol.is_valid = FALSE;
 partol.mattyp = &my_env->md_env.matrix_type;
 partol.mat = my_env->md_env.matrix;
 EMmake_chanselect(EMSbd_owner_to_comps, &to_edges);
 NMinit_ssi(&ssi);
 NMinit_tracedata(&tracedata);
 getlp_loops.objs = NULL;
 getlp_loops.num_objs = 0;
 current_creator = NULL_OBJID;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 if(nm_options & NMcreatebnd_NoCurveAssoc) curve_assoc = FALSE;
 if(status_str) strcpy (dot, ".");
 if(status_str) strcpy(locsts_str, status_str);
 map_options &= (~EMMapBnd_WantStatMsg);
 map_options &= (~EMMapBnd_NoFixing);

 crvptr = curves;
 nump = num_sfs;
 for(sfnum = 0; sfnum < num_sfs; sfnum++)
  {
   if(status_str)
    {
     strcat (locsts_str, dot);
     UI_status (locsts_str);
    }

   if(loops) om$dealloc(ptr = loops);
   loops = NULL;
   num_loops = 0;

   this_sf = &surfid[sfnum];

   sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(EMmsg, 
       &my_env->md_env, NULL, 
       &clip_ls.objid, NULL, NULL), targetid = this_sf->objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
   clip_ls.osnum = surfid->osnum;

   if(surf_geom) om$dealloc(ptr = surf_geom);
   surf_geom = NULL;
   sts = EMgetvggeom(EMmsg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
         this_sf, &surf_geom, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;

   sts = EFsspbtol_by_geom(EMmsg, surf_geom, &partol.tol);
   if(!(1&*EMmsg&sts)) goto wrapup;
   partol.is_valid = TRUE;

   if(EFisAncestryValid(EMmsg, this_sf->objid, this_sf->osnum, 
      OPP_EMSplane_class_id, FALSE)) map_options |= EMMapBnd_SurfIsPlane;
   else map_options &= (~EMMapBnd_SurfIsPlane);

   for(j=0; j<num_cvs_persf[sfnum]; j++)
    {
     struct GRlc_info *cvlcptr = NULL, cvlc;
     struct IGRbsp_curve *cvptr = NULL;

     if(status_str)
      {
       strcat (locsts_str, dot);
       UI_status (locsts_str);
      }

     if(getlp_loops.objs) om$dealloc(ptr = getlp_loops.objs);
     getlp_loops.num_objs = 0;
     getlp_loops.objs = NULL;

     if(crvptr->datatype == EMSdata_object)
      {
        extern OMuword OPP_GR3dpoint_class_id;

	cvlc.located_obj = *(crvptr->data.object);
	cvlc.module_info = *my_env;
	cvlcptr = &cvlc;
        if(EFisAncestryValid(EMmsg, cvlc.located_obj.objid, 
            cvlc.located_obj.osnum,
          OPP_GR3dpoint_class_id, FALSE)) 
        map_options |= EMMapBnd_NoFixing;
      }
     else if(crvptr->datatype == EMSdata_curve3d)
     {
      IGRvector nvec;
      IGRint code=0;
      BSrc rc;
      extern void BSptlnplan();
      
      cvptr = crvptr->data.curve;
      BSptlnplan(cvptr->num_poles, cvptr->rational, cvptr->poles,
                 cvptr->weights,&code, nvec, &rc);
      if (code == 1) /* Point */
        map_options |= EMMapBnd_NoFixing;
      
     }
     else
      {
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
      }

     crvptr++;
     current_creator = my_id;
     status = EMget_mapped_data(1, cvptr ? &cvptr : NULL, cvlcptr, 
              NULL, surf_geom, &partol.tol, my_env, NULL, NULL, &getlp_loops, 
  	      NULL, clip_ls, map_options, NULL, EMmsg);
     current_creator = NULL_OBJID;

     if(!getlp_loops.num_objs)
       continue;

     if(loops)
      {
       loops = (GRobjid *) om$realloc(ptr = (IGRchar *)loops, size = sizeof(GRobjid) *
		        (num_loops + getlp_loops.num_objs));
       EMerr_hndlr(!loops, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       OM_BLOCK_MOVE(getlp_loops.objs, &loops[num_loops], sizeof(GRobjid) *
			getlp_loops.num_objs);
       num_loops += getlp_loops.num_objs;
      }
     else
      {
       loops = getlp_loops.objs;
       num_loops = getlp_loops.num_objs;
       getlp_loops.objs = NULL;
      }
     if(!(1&*EMmsg)) goto wrapup;

    } /* for(j=0; j<num_cvs_persf[sfnum]; j++) */

   if(!num_loops)
    {
     *EMmsg = EMS_I_NoMoreLoops;
     continue;
    }

   /* Set intelligent curve types for any iso edges that might have been
      constructed. Ignore errors returned from non linear edges.
   */
   sts = om$send(msg = message EMSsubbs.EMget_natedge_info(EMmsg, 
         &my_env->md_env, edtype, edprops), targetid = this_sf->objid);
   if(1&*EMmsg&sts)
    {
     for(i=0; i<num_loops; i++)
      sts = om$send(msg = message EMSlinedge.EMsetIsoType(EMmsg, 
	    this_sf->objid, NULL, &edtype[0], &edtype[1], TRUE), 
  	    senderid = loops[i], p_chanselect = &to_edges);
     *EMmsg = EMS_S_Success;
     sts = OM_S_SUCCESS;
    }

   sts = NMsetUpSSI(EMmsg, this_sf, &ssi, &this_nm);
   if(!(1&*EMmsg&sts)) goto wrapup;
   EMerr_hndlr(!this_nm, *EMmsg, EMS_E_Fail, wrapup);

   /* Set the data in the form of a inters list.
   */
   for(i=0; i<num_loops; i++)
    {
     GRobjid thisedg;
     GRspacenum edgeos;

     sts = om$get_channel_count(objid = loops[i], p_chanselect = &to_edges, 
	   count = (OMuint *) &num_edges);
     if(!(1&sts)) goto wrapup;
     for(j=0; j<num_edges; j++)
      {
       sts = om$get_objid_at_index(objid = loops[i], p_chanselect = &to_edges, 
 	     index = j, objidaddr = &thisedg, osnumaddr = &edgeos);
       if(!(1&sts)) goto wrapup;

       /* Structure malloced, so that it can be directly used in the new
          inters list.
       */
       this_xyz = (struct IGRbsp_curve *) om$malloc(size = 
                  sizeof(struct IGRbsp_curve));
       EMerr_hndlr(!this_xyz, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
       this_xyz->poles = NULL;
       this_xyz->knots = NULL;
       this_xyz->weights = NULL;
       
       sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, 
             &my_env->md_env, this_sf, surf_geom, 0, MAXINT, FALSE, NULL, 
             this_xyz), targetid = thisedg);
       if(!(1&*EMmsg&sts)) goto wrapup;
       this_xyzintobj.datatype = EMSdata_curve3d;
       this_xyzintobj.data.curve = this_xyz;

       this_uvintobj.data.object = (struct GRid *) om$malloc(size = 
                                   sizeof(struct GRid));
       this_uvintobj.data.object->objid = thisedg;
       this_uvintobj.data.object->osnum = edgeos;
       this_uvintobj.datatype = EMSdata_object;

       edpar = NULL;
       sts = om$send(msg = message EMSedge.EMtrimyourself(EMmsg,
             &clip_ls.objid, trmopt, &edpar, NULL, &num_bdry, NULL, 
             &partol), targetid = thisedg);
       if(!(1&*EMmsg&sts)) goto wrapup;
       EMerr_hndlr(num_bdry!=1, *EMmsg, EMS_E_Fail, wrapup);

       EMmakeintlist(EMmsg, &inters, NULL, this_sf, NULL, NULL, NULL, NULL,NULL,
  		   &this_xyzintobj, &this_uvintobj, NULL, NULL, NULL, edpar, 
		   NULL, NULL, NULL, NULL, NULL, TRUE, FALSE);
       if(!(1&*EMmsg)) goto wrapup;

       if(this_nm)
        {
         sts = NMstore_edges_created(EMmsg, &ssi, &this_nm->sfid, 1, &thisedg);
         if(!(1&*EMmsg&sts)) goto wrapup;
        }

      } /* for(j=0; j<num_edges; j++) */

     sts = om$send(msg = message Root.wild_disconnect(to_edges), 
           targetid = loops[i]);
     if(!(1&sts)) goto wrapup;
     sts = om$send(msg = message Root.delete(TRUE), 
           targetid = loops[i]);
     if(!(1&sts)) goto wrapup;

    } /* for(i=0; i<num_loops; i++) */

   if(curve_assoc) nump += num_cvs_persf[sfnum];

  } /* for(sfnum = 0; sfnum < num_sfs; sfnum++) */

 if(status_str)
  {
   strcat (locsts_str, dot);
   UI_status (locsts_str);
  }

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);

 if(inters)
  {
   /* Trace the inters list and call a function to create NM topology.
   */

   tracetol = 2 * cht;
   EMsfinttrace(EMmsg, &my_env->md_env.matrix_type, my_env->md_env.matrix, 
                inters, NULL, &tracetol, 
                &tracedata.num_grps, &tracedata.num_subgrps_grp, 
                &tracedata.num_elems_subgrp, &tracedata.elems, 
                &tracedata.subgrp_rev, &tracedata.elem_rev, 
                &tracedata.grp_closed, &tracedata.subgrp_closed);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(status_str)
    {
     strcat (locsts_str, dot);
     UI_status (locsts_str);
    }

   current_creator = my_id;
   sts = NMcreate_topology(EMmsg, inters, &tracedata, construct, 
         NMcreatetp_CreateDegenerateVtx, &ssi);
   if(!(1&*EMmsg&sts)) goto wrapup;
   ME.NMnonmanigm->nmprops &= (~NMgm_NullState);
  }
 else ME.NMnonmanigm->nmprops |= NMgm_NullState;
  
 for(i=0; i<ssi.num_vtx; i++)
  {
   sts = om$send(msg = message NMvertex.NMcheck(EMmsg, &ssi, 
	 NMconnect_AddToSSI), 
	 targetid = ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 sts = om$send(msg = message NMnonmanigm.NMput_SSI(EMmsg, &ssi), 
       targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 if( !(ME.NMnonmanigm->nmprops & NMgm_Unevaluated) && inters)
  {
   if(nump > StaticBuf)
    {
     my_parents = (struct EMSobject_info *) om$malloc(size = nump *
	          sizeof(struct EMSobject_info));
     my_base = (struct GRid *) om$malloc(size = nump * sizeof(struct GRid));
     my_trans = (IGRboolean *) om$malloc(size = nump * sizeof(IGRboolean));
    }
   else
    {
     my_parents = my_parentsbuf;
     my_base = my_basebuf;
     my_trans = my_transbuf;
    }
   EMerr_hndlr(!my_parents || !my_base || !my_trans, *EMmsg, 
	       EMS_E_NoDynamicMemory, wrapup);

   my_num_parents = 0;
   for(i=0; i<num_sfs; i++)
    {
     sts = NMget_node(EMmsg, &surfid[i], NULL, NULL, NULL, NULL, NULL, &actid, 
           NULL);
     if(IF_EQ_GRID(my_GRid, actid)) actid = surfid[i];
     my_parents[my_num_parents].grid = actid;
     my_parents[my_num_parents].env = *my_env;
     my_base[my_num_parents] = surfid[i];
     my_trans[my_num_parents] = TRUE;
     my_num_parents++;
    }

   if(curve_assoc)
    {
     IGRint numcrv = 0;
     for(i=0; i<num_sfs; i++) numcrv += num_cvs_persf[i];
    
     for(i=0; i<numcrv; i++)
      {
       if(curves[i].datatype != EMSdata_object) continue;

       my_parents[my_num_parents].grid = *(curves[i].data.object);
       my_parents[my_num_parents].env = *my_env;
       my_base[my_num_parents] = *(curves[i].data.object);
       my_trans[my_num_parents] = FALSE;
       my_num_parents++;
      }
    }

   sts = om$send(msg = message NMassoctrans.NMinit_associative(EMmsg, 
         initas_opt, NMinitas_NoDuplicateParents, my_num_parents, 
         my_parents,my_num_parents,my_trans, my_base, NULL, NULL, NULL, construct),
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;

   ME.NMnonmanigm->nmprops = NMgm_Active;

   ME.GRgraphics->properties = construct->properties | GRIS_ASSOCIATIVE |
		               GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   ME.GRflxown->owner_properties = GR_ORPHAN;

   /* Store the chord height tolerance.
   */
   ME.NMnonmanibnd->cht = cht;

   for(i=0; i<my_num_parents; i++)
    {
     sts = om$send(msg = message NMnonmanigm.NMprop(EMmsg, NMprop_SetOff, 
           &nmprops), targetid = my_parents[i].grid.objid, 
           targetos = my_parents[i].grid.osnum);
     if(sts == OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

  } /* if( !(ME.NMnonmanigm->nmprops & NMgm_Unevaluated) && inters) */

 /* Store the curve/sf correspondence for recompute.
 */
 sts = om$vla_set_dimension(varray = ME.NMnonmanibnd->sfid, size = num_sfs);
 sts = om$vla_set_dimension(varray = ME.NMnonmanibnd->num_cvs, size = num_sfs);
 sts = om$vla_set_dimension(varray = ME.NMnonmanibnd->cvid, size = nump);

 j=0;
 for(sfnum=0; sfnum<num_sfs; sfnum++)
  {
   sts = NMtag(EMmsg, &surfid[sfnum], &ME.NMnonmanibnd->sfid[sfnum], TRUE);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if(!curve_assoc)
    {
     ME.NMnonmanibnd->num_cvs[sfnum] = 0;
     continue;
    }

   ME.NMnonmanibnd->num_cvs[sfnum] = num_cvs_persf[sfnum];
   for(i=0; i<num_cvs_persf[sfnum]; i++)
    {
     if(curves[j].datatype == EMSdata_object)
      {
       sts = NMtag(EMmsg, curves[j].data.object, &ME.NMnonmanibnd->cvid[j],
	     TRUE);
       j++;
       if(!(1&*EMmsg&sts)) goto wrapup;
      }
     else
      {
       ME.NMnonmanibnd->cvid[j].objid = NULL_OBJID;
       ME.NMnonmanibnd->cvid[j].osnum = OM_Gw_current_OS;      
       j++;
      }
    }
  }
 ME.NMnonmanibnd->num_sfs = num_sfs;

 /* Display the feature loops created.
 */
  sts = om$send(msg = message NMnonmanigm.NMSSI_action(EMmsg, ssiopt, 
        construct->env_info, &ssi), targetid = my_id);

 if(!inters)
  {
   if(ME.NMnonmanigm->nmprops & NMgm_Unevaluated)
    {
     ex$message(msgnumb = NM_I_NullState);
     sleep(3);
    }
   else *EMmsg = EMS_I_NoMoreLoops;
  }

wrapup:
current_creator = NULL_OBJID;
(void) NMset_object_data_to_null(inters, TRUE, TRUE);
EMinters_data_free(&rc, inters, MAXINT, NULL, NULL);
EMinters_free(inters, MAXINT);
if(surf_geom) om$dealloc(ptr = surf_geom);
if(loops) om$dealloc(ptr = loops);
if(getlp_loops.objs) om$dealloc(ptr = getlp_loops.objs);

NMfree_ssi(&ssi);
EMsfinttrace_free (&rc, tracedata.num_grps,
                   tracedata.num_subgrps_grp, tracedata.num_elems_subgrp, 
                   tracedata.elems, tracedata.subgrp_rev, tracedata.elem_rev, 
                   tracedata.grp_closed, tracedata.subgrp_closed);

if(my_base && (my_base != my_basebuf)) om$dealloc(ptr = my_base);
if(my_trans && (my_trans != my_transbuf)) om$dealloc(ptr = my_trans);

EMWRAPUP(*EMmsg, sts, "NMcreate_boundaries");
return(sts);
}

end implementation NMnonmanibnd;
