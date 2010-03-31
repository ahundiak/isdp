 /*
  ALGORITHM :

	Given a set of valid boundary curves, single or composite, and a
	composite surface, this function maps all these curves into the
	UV-space of the respective component surfaces and generates the
	inters list for the composite surface as a whole.  Then, it calls
	boolean with the option EMSsfbool_opt_AdjacentRegions set.  This
	results in the original loop getting split into distinct adjacent
	loops.  Based on the nature of the loop that the longest oriented
	curve encloses, the rest of the loops are toggled to retain the
        desired area.

	NOTE :  The deletion of loops takes place within the boolean 
	        function, and the method that does this is in src_bound/implp/
                EMlpremadj.I
  ARGUMENTS :

	struct GRlc_info **crvs_info		Locate info for the curves
                                                to be imposed.

 	IGRint num_cvs                          Number of curves to be imposed.

	struct GRlc_info *surf_info             Locate info for the surface
                                                to be imposed.

	IGRushort imp_options                   The options supported are

                                               - EMSsfbool_opt_AdjacentRegions
                                              
                                               - EMSsfbool_opt_ConnectToComEdge
               
       IGRint lrgst_crv_inx                    The index of the largest curve
                                               in the array of curves to be
                                               imposed.


       IGRlong crv_reversed                    Flag indicating whether the
                                               above curve is reversed or
                                               not. 		

       GRobjid *lrgst_cmpid                    The lrgst curve id.


       struct GRid *dprid                      The grid of the state object
                                               created. This is the output
                                               of the function.

       IGRlong *EMmsg                          The error message value.	


  HISTORY :

    M.R. Vadiraj  :  01/07/93  :  Creation

    M.R. Vadiraj  :  05/24/94  :  Modified to take care of overlapping 
                                  curves.  They are now pushed across 
                                  the common-edge in case they are found
                                  to form a sliver.
*/ 

class implementation Root;

# include "igrtypedef.h"
# include "igr.h"
# include "igetypedef.h"
# include "igrdp.h"
# include "gr.h"
# include "griodef.h"
# include "go.h"
# include "ex.h"
# include "godef.h"
# include "grio.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "gocmacros.h"
# include "EMSmsgdef.h"
# include "emsimpdef.h"
# include "emsmapdef.h"
# include "EMSopt.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emssfintdef.h"
# include "EMSprop.h"
# include "emssfint.h"
# include "msdef.h"
# include "msmacros.h"
# include "emserr.h"
# include "EMSssprops.h"
# include "emsbool.h"
# include "bserr.h"
# include "bsparameters.h"
# include "bsdistptpts.h"
# include "bsdistptpt.h"
# include "bscvmidpt.h"
# include "mabcendpts.h"
# include "ECmsg.h"

#define FWD 1
#define BWD 2
#define DEL_EXTEND 3
#define DEEXTEND_EXTEND 4

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from GRvg import GRgetsize, GRgetgeom, EMptatpr;
from EMSsubbs import GRgenabsg, EMpartolbasis;
from EMSedge import EMget_props, EMreverse, EMptproject,
                    EMinternalpt, EMget_bcxyz_geom, EMendpts,
                    EMextend_geom, EMxyz_endpt;
from EMSboundary import EMgetxyzobj, EMgetsurface_info, EMget_objid;

%safe
static void EMrev_dup_inters();
static void EMstring_coinc_intobjs();
static IGRboolean EMintobjs_overlap();
static void EMpush_coinc_intobjs();
static IGRboolean EMdet_reversal();
static void EMsplit_and_append_inters();
static void EMdel_degenintobs_and_refine();
static void EMconnectDupOrgInts();
%endsafe

IGRlong EMsfimpose(crvs_info,
                   num_cvs,
                   surf_info,
                   imp_options,
                   num_lrgst_crvs,
                   lrgst_crv_inx,
                   crv_reversed,
                   lrgst_cmpid,
                   num_bad_pts,
                   bad_pts,
                   dprid,
                   EMmsg)
struct GRlc_info **crvs_info;
IGRint num_cvs;
struct GRlc_info *surf_info;
IGRushort imp_options;
IGRint num_lrgst_crvs;
IGRint *lrgst_crv_inx;
IGRlong crv_reversed;
GRobjid *lrgst_cmpid; 
IGRint *num_bad_pts;
IGRdouble **bad_pts;
struct GRid *dprid;
IGRlong *EMmsg;
{
    IGRlong stat_OM, msg_loc;
    IGRushort map_options;
    GRobjid loc_cmpid, first_coinc_edge, last_coinc_edge;
    IGRint i, off_set, num_mrkd_intobjs = 0, k = 0, j,
           num_overlap_intobjs = 0, extnd_options;
    IGRboolean  pos_orient, found = FALSE, modified = FALSE,
                overlap = FALSE;
    struct EMSintobj *tmp_intobj, *first_intobj, 
                     **save_mrkd_intobjs = NULL,
                     **overlap_intobjs = NULL;
    struct EMSinters *compsf_inters = NULL, *tmp_inters,
                     *dup_inters = NULL, *loc_inters = NULL; 
    struct EMSsftracedata compsf_trace, dup_trace_info, merged_trace,
                          junk_trace;
    struct EMSdataselect sfdata, cvdata;
    struct GRmdenv_info sfenv, cvenv;
    struct IGRbsp_surface *temp_sf = NULL;
    struct GRlc_info sf_info;
    enum EMSbooltype bool_type;
    IGRchar status_str[100];

    IGRint m, elem_count; 
    IGRboolean out_of_bounds = FALSE, sfinttrace_alloced,
               dup_trace_alloced = FALSE, crv_to_be_rev = FALSE,
               same_comm_edge = FALSE;
    OM_S_CHANSELECT chan_to_common;
    struct EMSintobj *first_grpobj = NULL, *last_grpobj = NULL;
    struct EMSsfintedpar *junk = NULL;

    GRobjid first_edgeid = NULL_OBJID, last_edgeid = NULL_OBJID;

    OM_S_OBJECT_LINKAGE common_edge1, common_edge2;
    IGRuint has_common_edge1, has_common_edge2;
    IGRdouble fstobj_stpt[3], fstobj_endpt[3], lastobj_stpt[3],
              lastobj_endpt[3], connect_tol, dis_tol;

    IGRboolean save_pathway_trim, save_pathway_orient;


    extern IGRlong EMboolean_surfaces_w_intersection();
    extern void EMmergeinters();
    extern void EMmergetrace();
    extern struct EMSintobj *EMcnvtcvintobj();
    extern IGRlong EMget_the_geometry();
    extern IGRlong EMintersect_surfaces();
    extern void EMsfinttrace_free(); 
    extern void EMinters_data_free(), EMinters_free();
    extern void EMsfintedpar_free();  
    extern IGRlong EMinternalpt();
    extern IGRint EMgetendpts_xyz();
    extern IGRint EMgetendpts_uv();
    extern void EMcmpinters();
    extern IGRlong EMgetvggeom();
    extern void EFget_coincident_edge();

    *EMmsg = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;

    stat_OM = BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, connect_tol);
    dis_tol = 2 * connect_tol;

    if(imp_options & EMS_SFINT_PUSHBADCOINC)
       imp_options &= ~EMS_SFINT_PUSHBADCOINC;
    imp_options |= EMS_SFINT_SKIPSFINT | EMS_SFINT_SKIPFIXING |
                   EMS_SFINT_DOUBLECHECK;

    OM_BLOCK_MOVE(&surf_info->module_info.md_env, &sfenv, 
                  sizeof(struct GRmdenv_info));
    sfdata.datatype = EMSdata_object;
    sfdata.data.object = (struct GRid *) &surf_info->located_obj;
    cvdata.datatype = EMSdata_object; 

    compsf_trace.num_grps           = 0;
    compsf_trace.num_subgrps_grp    = NULL;
    compsf_trace.num_elems_subgrp   = NULL;
    compsf_trace.elems              = NULL;
    compsf_trace.subgrp_rev         = NULL;
    compsf_trace.elem_rev           = NULL;
    compsf_trace.grp_closed         = NULL;
    compsf_trace.subgrp_closed      = NULL;

  /* Generate the intersection list for the composite surface */

    for(i = 0; i < num_cvs; i++)
       { 
    tmp_inters = NULL;
    loc_cmpid = found ? NULL_OBJID : (*lrgst_cmpid);
    OM_BLOCK_MOVE(&crvs_info[i]->module_info.md_env, &cvenv,
                  sizeof(struct GRmdenv_info));
    cvdata.data.object = (struct GRid *) &(crvs_info[i])->located_obj;

   map_options = EMMapBnd_WantStatMsg | EMMapBnd_StrokeIfNeeded |
                 EMMapBnd_WantBadCurves | EMMapBnd_NoValidate |
                 EMMapBnd_RmvDegenCvs | EMMapBnd_NoRmvColEds |
                 EMMapBnd_ClipBdryArea;
   first_intobj = EMcnvtcvintobj(&msg_loc, map_options, &sfenv, &sfdata, &cvenv,
                                  &cvdata, &loc_cmpid,
                                  &tmp_inters, &overlap);
                  EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
      for(j = 0; j < num_lrgst_crvs; j++) 
         {
          if(i == lrgst_crv_inx[j])
             crv_to_be_rev = TRUE;
         } 

      if(first_intobj) {
         if(crv_to_be_rev) {
      loc_inters = tmp_inters;
      while(loc_inters) {
      num_mrkd_intobjs += (loc_inters)->num_cvs;
      loc_inters = loc_inters->next;
      }
      if(!k)
      save_mrkd_intobjs = (struct EMSintobj **) om$malloc(size =
                                              num_mrkd_intobjs *
                                              sizeof(struct EMSintobj *));
      else
      save_mrkd_intobjs = (struct EMSintobj **) om$realloc(
                                  ptr = (IGRchar *)save_mrkd_intobjs,
                                  size = num_mrkd_intobjs *
                                         sizeof(struct EMSintobj *));
          loc_inters = tmp_inters;
          while(loc_inters) {
          tmp_intobj = loc_inters->cvs;
          while(tmp_intobj) {
                save_mrkd_intobjs[k++] = tmp_intobj;
                tmp_intobj = tmp_intobj->next;
                }
          loc_inters = loc_inters->next;
             }
           }
        }
     
        EMmergeinters (&msg_loc, &compsf_inters, tmp_inters);      
        EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
     }
     sfinttrace_alloced = FALSE;
	/* 
         * This is a check for curves that are open/become open after
	 * mapping.
         * The invalid curves are :
         * a) that are open in the parametric space of the respective
         *    surfaces.
         * b) open curves with their endpts on the common edges'
         *    without continuity across the common edge.
         */

         ex$message(msgnumb = EMS_I_ClearStatusField);
         ex$message(msgnumb = EMS_I_ValidateMappedCrvs);

         junk_trace.num_grps = 0;
         junk_trace.elems = NULL;

         save_pathway_trim = _pathway_trim;
         save_pathway_orient = _pathway_orient;
         _pathway_trim = 0;
         _pathway_orient = 0;

         stat_OM = EMintersect_surfaces (&msg_loc, NULL, &sfenv, 0, NULL, NULL,
                                         imp_options, NULL, NULL, NULL,
                                         NULL,
                                         NULL, &compsf_inters, NULL,
                                         &junk_trace, NULL,
                                         NULL, NULL,
                                         NULL);

         _pathway_trim = save_pathway_trim;
         _pathway_orient = save_pathway_orient;

         EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
         sfinttrace_alloced = TRUE;

     for(m = 0; m < junk_trace.num_grps; m++) {
             if(!junk_trace.grp_closed[m]) {
                 first_grpobj = junk_trace.elems[m][0];
                 junk = (struct EMSsfintedpar *) first_grpobj->more_info;

                 first_edgeid = junk->edgeid;

                 off_set = junk_trace.num_subgrps_grp[m];
                 last_grpobj = junk_trace.elems[m][off_set-1];
                 elem_count = 0;
                 if(junk_trace.num_elems_subgrp[m][off_set-1] > 1)
                    while(last_grpobj->next) {
                          elem_count++;
                          if(elem_count ==
                             junk_trace.num_elems_subgrp[m][off_set-1])
                          break;
                        else
                        last_grpobj = last_grpobj->next;
                          }
                 junk = (struct EMSsfintedpar *) last_grpobj->more_info;
                 last_edgeid = junk->next->edgeid;

                 if(IF_NULL_OBJID(first_edgeid) ||
                    IF_NULL_OBJID(last_edgeid))
                                 {
                                out_of_bounds = TRUE;
                                break;
                                }
                 else {
                   EMmake_chanselect(EMSedge_to_common_edge, &chan_to_common);
                   has_common_edge1 = FALSE;
                   has_common_edge2 = FALSE;

                   om$get_channel_objects (objid = first_edgeid,
                                           p_chanselect = &chan_to_common,
                                           count = &has_common_edge1, size = 1,
                                           list = &common_edge1);
                   om$get_channel_objects (objid = last_edgeid,
                                           p_chanselect = &chan_to_common,
                                           count = &has_common_edge2, size = 1,
                                           list = &common_edge2);

                   if(!has_common_edge1 && !has_common_edge2)
                     {
                   first_coinc_edge = last_coinc_edge = NULL_OBJID;
                   EFget_coincident_edge(&msg_loc, NULL, &sfenv.matrix_type,
                                         sfenv.matrix, NULL, NULL, 
                                         first_grpobj, &first_coinc_edge);
                   EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 
                   EFget_coincident_edge(&msg_loc, NULL, &sfenv.matrix_type,
                                         sfenv.matrix, NULL, NULL,
                                         last_grpobj, &last_coinc_edge);
                   EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
          
                   if(!IF_NULL_OBJID(first_coinc_edge) ||
                      !IF_NULL_OBJID(last_coinc_edge))
                   {
                   om$get_channel_objects (objid = first_coinc_edge,
                                           p_chanselect = &chan_to_common,
                                           count = &has_common_edge1, size = 1,
                                           list = &common_edge1);

                   om$get_channel_objects (objid = last_coinc_edge,
                                           p_chanselect = &chan_to_common,
                                           count = &has_common_edge2, size = 1,
                                           list = &common_edge2);    
                   if(has_common_edge1 || has_common_edge2)
                     {
                   out_of_bounds = TRUE;
                   break;
                     }
                   }
                   else    
                   continue;
                   }
                   else {
                   stat_OM = EMgetendpts_xyz(&msg_loc,
                             &sfenv.matrix_type,
                             sfenv.matrix,
                             &first_grpobj->this_xyzintobj,
                             first_grpobj->reversed,
                             1,
                             fstobj_stpt,
                             fstobj_endpt);
                   EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

                   stat_OM = EMgetendpts_xyz(&msg_loc,
                             &sfenv.matrix_type,
                             sfenv.matrix,
                             &last_grpobj->this_xyzintobj,
                             last_grpobj->reversed,
                             1,
                             lastobj_stpt,
                             lastobj_endpt);
                   EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

                   if(BSdistptpts(&msg_loc, fstobj_stpt, lastobj_endpt) 
                                 < dis_tol) 
                   continue;
                   else  {
                   same_comm_edge = TRUE;
                   out_of_bounds = TRUE;
                   break;
                   }
                 }
               }
             }
           }  
      
      if(sfinttrace_alloced) {
          EMsfinttrace_free (&msg_loc,
                             junk_trace.num_grps,
                             junk_trace.num_subgrps_grp,
                             junk_trace.num_elems_subgrp,
                             junk_trace.elems,
                             junk_trace.subgrp_rev,
                             junk_trace.elem_rev,
                             junk_trace.grp_closed,
                             junk_trace.subgrp_closed);
          EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
          }

      if(out_of_bounds) {

         *num_bad_pts = 4;  
         *bad_pts = (IGRdouble *) om$malloc(size = 12 * sizeof(IGRdouble));
            
         if(!same_comm_edge) {  
         stat_OM = EMgetendpts_xyz(&msg_loc,
                                   &sfenv.matrix_type,
                                   sfenv.matrix,
                                   &first_grpobj->this_xyzintobj,
                                   first_grpobj->reversed,
                                   1,
                                   fstobj_stpt,
                                   fstobj_endpt);
             EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

         stat_OM = EMgetendpts_xyz(&msg_loc,
                                   &sfenv.matrix_type,
                                   sfenv.matrix,
                                   &last_grpobj->this_xyzintobj,
                                   last_grpobj->reversed,
                                   1,
                                   lastobj_stpt,
                                   lastobj_endpt);
             EMerr_hndlr (EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
         }

         for(i = 0; i < 3; i++)  {
             (*bad_pts)[i] = fstobj_stpt[i];
             (*bad_pts)[3+i] = fstobj_endpt[i];
             (*bad_pts)[6+i] = lastobj_stpt[i];
             (*bad_pts)[9+i] = lastobj_endpt[i];
             }  

         *EMmsg = EMS_I_OutOfBounds;
         goto wrapup;

      } /* End checking for invalid curves after mapping */

      if(crv_reversed)  {
         for(i = 0; i < num_mrkd_intobjs; i++)
             {
             if(save_mrkd_intobjs[i])
             save_mrkd_intobjs[i]->reversed = TRUE;
             }
        }

      /* 
       * Toggle the reversal bits of those intobjs whose surfaces have
       * pos-orient bit set to NULL.
       *
       * This is to facilitate correct splitting and formulation of 
       * loops of the right kind further down.
      */
       
      ex$message(msgnumb = EMS_I_ClearStatusField);
      ex$message(msgnumb = EMS_I_Processing);  

      if(compsf_inters) {
         loc_inters = compsf_inters;
         OM_BLOCK_MOVE(&surf_info->module_info, &sf_info.module_info,
                       sizeof(struct GRmd_env));

         while(loc_inters) {
               tmp_intobj = loc_inters->cvs;

               while(tmp_intobj) {
                  if(tmp_intobj->props & EMSintobj_overlap) {
                     if(!overlap) overlap = TRUE;
                  if(!num_overlap_intobjs) {
                    overlap_intobjs = (struct EMSintobj **) om$malloc(size =
                                       sizeof(struct EMSintobj *));
                    overlap_intobjs[num_overlap_intobjs] = tmp_intobj;
                    num_overlap_intobjs++;
                  }
                  else {
                  num_overlap_intobjs++;
                  overlap_intobjs = (struct EMSintobj **) om$realloc(ptr =
                              (IGRchar *) overlap_intobjs, size =
                              num_overlap_intobjs * sizeof(struct EMSintobj *));
                  overlap_intobjs[num_overlap_intobjs - 1] = tmp_intobj;
                  }
               }
                     if(tmp_intobj->fwd)
                        tmp_intobj->fwd = NULL;
                     if(tmp_intobj->bwd)
                        tmp_intobj->bwd = NULL;

                     sf_info.located_obj.objid =
                             tmp_intobj->this_obj_node->this_obj.objid;
                     sf_info.located_obj.osnum =
                             tmp_intobj->this_obj_node->this_obj.osnum;
                     stat_OM = EMget_the_geometry(&sf_info, TRUE, NULL, FALSE,
                               NULL_OBJID, (IGRchar **)&temp_sf, &msg_loc);
                     EMerr_hndlr(EMSerror(msg_loc), *EMmsg,
                                   EMS_E_Fail, wrapup);
                     pos_orient = temp_sf->pos_orient;
                     if(!pos_orient)
                        tmp_intobj->reversed = !tmp_intobj->reversed;
                        tmp_intobj = tmp_intobj->next;

                     if(temp_sf) {
                        om$dealloc(ptr = temp_sf);
                        temp_sf = NULL;
                        }
                   }
                loc_inters = loc_inters->next;
              }

         } /* End orienting the inters for correct splitting. */
   

    if(overlap) {
    ex$message(msgnumb = EMS_I_ClearStatusField);
    ex$message(msgnumb = EMS_I_ImpCrvsOverlap);

    for(i = 0; i < num_mrkd_intobjs; i++)
           {
           if(save_mrkd_intobjs[i])
           save_mrkd_intobjs[i]->props |= EMSintobj_marked;
           }

    EMsplit_and_append_inters(&sfenv, num_overlap_intobjs,
                              overlap_intobjs, dis_tol, &msg_loc);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }

    ex$message(msgnumb = EMS_I_ClearStatusField);
    ex$message(msgnumb = EMS_I_Processing);

    if(compsf_inters) {
     EMstring_coinc_intobjs(&msg_loc, &sfenv.matrix_type,
                            sfenv.matrix, &compsf_inters);
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     if(overlap) {
     extnd_options = DEL_EXTEND;
     EMdel_degenintobs_and_refine(&compsf_inters, &surf_info->module_info,
                                  dis_tol, extnd_options, &msg_loc);  
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     extnd_options = DEEXTEND_EXTEND;
     EMdel_degenintobs_and_refine(&compsf_inters, &surf_info->module_info,
                                  dis_tol, extnd_options, &msg_loc);
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);  
     }

  /* Trace out the intersection list */

     compsf_trace.num_grps = 0;  
     compsf_trace.elems = NULL;

     save_pathway_trim = _pathway_trim;
     save_pathway_orient = _pathway_orient;
     _pathway_trim = 0;
     _pathway_orient = 0;

     stat_OM = EMintersect_surfaces (&msg_loc, NULL, &sfenv, 0, NULL, NULL,
               imp_options, NULL, NULL, NULL,
               NULL,
               NULL, &compsf_inters, NULL,
               &compsf_trace, NULL,
               NULL, NULL,
               NULL);

     _pathway_trim = save_pathway_trim;
     _pathway_orient = save_pathway_orient;

     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

   /* 
    * Copy the same and then reverse, set the 'fwd', 'bwd' ptrs and trace with
    * no 'refinement'.
    */

      imp_options |= EMS_SFINT_NOREFINE;
      EMrev_dup_inters(&msg_loc, compsf_inters, &dup_inters,
                       (struct GRid *)&surf_info->located_obj,
                       (struct GRmd_env *)&surf_info->module_info,
                       &dup_trace_info, imp_options);
      dup_trace_alloced = TRUE;
      EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup); 

   /*
    * Connect the original and duplicate intobjs thru 'other_intobj'
    * info.  These are to become 'common edges' of each other further
    * down.
    */

      ex$message(msgnumb = EMS_I_ClearStatusField);  
      ex$message(msgnumb = EMS_S_ProcessingOne);
      
      EMconnectDupOrgInts(&compsf_inters, &dup_inters,
                          &sfenv.matrix_type, sfenv.matrix,
                          dis_tol, &msg_loc);
      EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

      if(overlap) {
      EMpush_coinc_intobjs(&compsf_inters, &sfenv, dis_tol, map_options,
                           &msg_loc, &modified);
      if(msg_loc == EMS_I_OutOfBounds) goto wrapup;
      EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

      if(modified) {
      if(msg_loc == EMS_I_OutOfBounds)
        {
         *EMmsg = EMS_I_OutOfBounds;
         goto wrapup;
        }
      EMcmpinters(&msg_loc, &dup_inters);
      } 
    }
  
     if(overlap && modified) {
     loc_inters = compsf_inters;
     while(loc_inters) {
           tmp_intobj = loc_inters->cvs;
           while(tmp_intobj) {
           if(tmp_intobj->fwd) tmp_intobj->fwd = NULL;
           if(tmp_intobj->bwd) tmp_intobj->bwd = NULL;
           tmp_intobj = tmp_intobj->next;
           }
     loc_inters = loc_inters->next;
     }

     extnd_options = DEEXTEND_EXTEND;
     EMdel_degenintobs_and_refine(&compsf_inters, &surf_info->module_info,
                                  dis_tol, extnd_options, &msg_loc);
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     EMstring_coinc_intobjs(&msg_loc, &sfenv.matrix_type,
                            sfenv.matrix, &compsf_inters);
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     EMsfinttrace_free(&msg_loc,
                       compsf_trace.num_grps,
                       compsf_trace.num_subgrps_grp,
                       compsf_trace.num_elems_subgrp,
                       compsf_trace.elems,
                       compsf_trace.subgrp_rev,
                       compsf_trace.elem_rev,
                       compsf_trace.grp_closed,
                       compsf_trace.subgrp_closed);
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);  

     compsf_trace.num_grps = 0;
     compsf_trace.elems = NULL;

     save_pathway_trim = _pathway_trim;
     save_pathway_orient = _pathway_orient;
     _pathway_trim = 0;
     _pathway_orient = 0;

     stat_OM = EMintersect_surfaces (&msg_loc, NULL, &sfenv, 0, NULL, NULL,
               imp_options, NULL, NULL, NULL,
               NULL,
               NULL, &compsf_inters, NULL,
               &compsf_trace, NULL,
               NULL, NULL,
               NULL);

     _pathway_trim = save_pathway_trim;
     _pathway_orient = save_pathway_orient;

     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }

    if(overlap) {
    modified = FALSE;
    EMpush_coinc_intobjs(&dup_inters, &sfenv, dis_tol, map_options,
                         &msg_loc, &modified);
    if(msg_loc == EMS_I_OutOfBounds) goto wrapup;
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if(modified) {
      if(msg_loc == EMS_I_OutOfBounds)
        {
         *EMmsg = EMS_I_OutOfBounds;
         goto wrapup;
        }
      EMcmpinters(&msg_loc, &compsf_inters);
      }
    }

    ex$message(msgnumb = EMS_I_ClearStatusField);
    ex$message(msgnumb = EMS_S_ProcessingTwo);
  
    if(overlap && modified) {
    loc_inters = dup_inters;
    while(loc_inters) {
          tmp_intobj = loc_inters->cvs;
          while(tmp_intobj) {
          if(tmp_intobj->fwd) tmp_intobj->fwd = NULL;
          if(tmp_intobj->bwd) tmp_intobj->bwd = NULL;
          tmp_intobj = tmp_intobj->next;
          }
     loc_inters = loc_inters->next;
    }

    extnd_options = DEEXTEND_EXTEND;
    EMdel_degenintobs_and_refine(&dup_inters, &surf_info->module_info,
                                 dis_tol, extnd_options, &msg_loc);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    EMstring_coinc_intobjs(&msg_loc, &sfenv.matrix_type,
                           sfenv.matrix, &dup_inters);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);  
    }

    EMsfinttrace_free(&msg_loc,
                      dup_trace_info.num_grps,
                      dup_trace_info.num_subgrps_grp,
                      dup_trace_info.num_elems_subgrp,
                      dup_trace_info.elems,
                      dup_trace_info.subgrp_rev,
                      dup_trace_info.elem_rev,
                      dup_trace_info.grp_closed,
                      dup_trace_info.subgrp_closed);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    dup_trace_info.num_grps = 0;
    dup_trace_info.elems = NULL;

    save_pathway_trim = _pathway_trim;
    save_pathway_orient = _pathway_orient;
    _pathway_trim = 0;
    _pathway_orient = 0;

    stat_OM = EMintersect_surfaces (&msg_loc, NULL, &sfenv, 0, NULL, NULL,
              imp_options, NULL, NULL, NULL,
              NULL,
              NULL, &dup_inters, NULL,
              &dup_trace_info, NULL,
              NULL, NULL,
              NULL);

    _pathway_trim = save_pathway_trim;
    _pathway_orient = save_pathway_orient;

    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if(modified) {
    EMsfinttrace_free(&msg_loc,
                      compsf_trace.num_grps,
                      compsf_trace.num_subgrps_grp,
                      compsf_trace.num_elems_subgrp,
                      compsf_trace.elems,
                      compsf_trace.subgrp_rev,
                      compsf_trace.elem_rev,
                      compsf_trace.grp_closed,
                      compsf_trace.subgrp_closed);
     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

     compsf_trace.num_grps = 0;
     compsf_trace.elems = NULL;

     save_pathway_trim = _pathway_trim;
     save_pathway_orient = _pathway_orient;
     _pathway_trim = 0;
     _pathway_orient = 0;

     stat_OM = EMintersect_surfaces (&msg_loc, NULL, &sfenv, 0, NULL, NULL,
               imp_options, NULL, NULL, NULL,
               NULL,
               NULL, &compsf_inters, NULL,
               &compsf_trace, NULL,
               NULL, NULL,
               NULL);

     _pathway_trim = save_pathway_trim;
     _pathway_orient = save_pathway_orient;

     EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }

    ex$message(msgnumb = EMS_I_ClearStatusField);
    ex$message(msgnumb = EMS_I_00003);
      
    EMconnectDupOrgInts(&compsf_inters, &dup_inters,
                        &sfenv.matrix_type, sfenv.matrix,
                        dis_tol, &msg_loc);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    /* Merge the two inters lists and the respective trace-info */

    EMmergeinters (&msg_loc, &compsf_inters, dup_inters);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    EMmergetrace(&msg_loc, &compsf_trace, &dup_trace_info, &merged_trace);
    EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   
    if(!overlap)
    for(i = 0; i < num_mrkd_intobjs; i++)
    {
        if(save_mrkd_intobjs[i])
        save_mrkd_intobjs[i]->props |= EMSintobj_marked;
    }

    /* Call the boolean. */

    ex$message(msgnumb = EMS_I_ClearStatusField);

    imp_options |= EMSsfbool_opt_AdjacentRegions
                 | EMSsfbool_opt_ConnectToComEdge
                 | EMSsfbool_opt_display;
    strcpy (status_str, "Processing.");
    bool_type = EMSbool_TrimCompsfs;
    stat_OM = EMboolean_surfaces_w_intersection (&msg_loc,
              dprid, bool_type,
              (struct GRmdenv_info *)&surf_info->module_info,
              (GRobjid)surf_info->located_obj.objid,
              0, NULL,
              compsf_inters, NULL,
              &merged_trace,NULL,
              NULL, NULL,
              imp_options,
              NULL, NULL, status_str);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
    }
    else
    *EMmsg = EMS_E_InvalidArg;

wrapup :

       if(*EMmsg == EMS_I_OutOfBounds) {
       EMinters_data_free (&msg_loc, compsf_inters, MAXINT, NULL,
                           EMsfintedpar_free);
       EMinters_free (compsf_inters, MAXINT);
       }

       if(dup_trace_alloced) {
       EMsfinttrace_free (&msg_loc,
                          dup_trace_info.num_grps,
                          dup_trace_info.num_subgrps_grp,
                          dup_trace_info.num_elems_subgrp,
                          dup_trace_info.elems,
                          dup_trace_info.subgrp_rev,
                          dup_trace_info.elem_rev,
                          dup_trace_info.grp_closed,
                          dup_trace_info.subgrp_closed);  
      EMerr_hndlr(!(1&msg_loc), *EMmsg, msg_loc, wrapup);
      }

      if(overlap_intobjs) {
         om$dealloc(ptr = overlap_intobjs);
         overlap_intobjs = NULL;
      }

EMWRAPUP (*EMmsg, stat_OM, "EMsfimpose");

return (stat_OM);
}                

 /* 
  * The following function duplicates a given inters list, reverses the same,
  * and sets the 'fwd' and 'bwd' info on the intobjs of the reversed list.
  */  

static void EMrev_dup_inters(EMmsg, org_inters, dup_inters, sfgrid, sfenv,
                             dup_trace_info, opts)
IGRlong *EMmsg;
struct EMSinters *org_inters, **dup_inters;
struct EMSsftracedata *dup_trace_info;
struct GRid *sfgrid;
struct GRmd_env *sfenv;
IGRushort opts;
{
IGRlong msg_loc, stat_OM, nret, bufsiz;
struct EMSinters *loc_inters;
struct EMSintobj *loc_intobj;
struct GRvg_construct const_list;
struct IGRdisplay display_attr;

IGRboolean save_pathway_trim, save_pathway_orient;

extern IGRlong EMdupinters();
extern IGRlong EMintersect_surfaces();

*EMmsg = EMS_S_Success;
stat_OM = OM_S_SUCCESS;

bufsiz = sizeof(struct IGRdisplay);
gr$get_active_display(msg = &msg_loc,
                      sizbuf = &bufsiz,
                      buffer = &display_attr,
                      nret = &nret);
const_list.msg = &msg_loc;
const_list.class_attr = NULL;
const_list.level = NULL;
const_list.env_info = sfenv;
const_list.display = &display_attr;
const_list.newflag = FALSE;
const_list.name = NULL;
const_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
const_list.geometry = NULL;
         
         /*  Duplicating the inters list */
       
       stat_OM = EMdupinters(&msg_loc, &org_inters, dup_inters, TRUE, FALSE,
                             sfgrid, NULL, TRUE, sfenv, &const_list, NULL,
                             NULL, NULL, NULL, NULL, NULL);
                 EMerr_hndlr (!(stat_OM&msg_loc&1), *EMmsg, EMS_E_Fail, wrapup);
       
         /* Reversing the duplicate inters list */

         loc_inters = *dup_inters;
         while(loc_inters)

              {
              loc_intobj = loc_inters->cvs;
              while(loc_intobj)
                   {
                   if(loc_intobj->fwd) loc_intobj->fwd = NULL;
                   if(loc_intobj->bwd) loc_intobj->bwd = NULL;

                   loc_intobj->reversed = !loc_intobj->reversed;

                   if(loc_intobj->props & EMSintobj_marked)
                   loc_intobj->props &= ~EMSintobj_marked;

                   loc_intobj = loc_intobj->next;
                   }
              loc_inters = loc_inters->next;
              }  

         EMstring_coinc_intobjs(&msg_loc, &sfenv->md_env.matrix_type,
                                sfenv->md_env.matrix, dup_inters);
         EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

         /* Trace the duplicate inters list */

         dup_trace_info->num_grps = 0;
         loc_inters = *dup_inters;
         dup_trace_info->elems = NULL;

         save_pathway_trim = _pathway_trim;
         save_pathway_orient = _pathway_orient;
         _pathway_trim = 0;
         _pathway_orient = 0;

         stat_OM = EMintersect_surfaces (&msg_loc, NULL, sfenv, 0, NULL, NULL,
                     opts, NULL, NULL, NULL,
                     NULL,
                     NULL, dup_inters, NULL,
                     dup_trace_info, NULL,
                     NULL, NULL,
                     NULL);

         _pathway_trim = save_pathway_trim;
         _pathway_orient = save_pathway_orient;

         EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);

wrapup :
return;
}

/* 
 * This static function sets the 'fwd', 'bwd' pointers on intobjs that have 
 * end point continuity in the parametric space of their respective surfaces.
 * This is done on a per surface basis.
 *
 * ASSUMPTION : No ambiguous situation exists at the ends of an intobj.  That
 *              is, not more than one intobj can provide the 'fwd' or 'bwd'
 *              continuity to another intobj. 
 */

static void EMstring_coinc_intobjs(msg, mattyp, mat, inters)

IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSinters **inters;

{
    IGRlong msg_loc, sts;
    IGRboolean in_world;
    IGRdouble dist[4], dis_tol, tol_basis;  

    struct EMSintobj *tmp_intobj = NULL, 
                     *next_intobj = NULL;
    struct EMSinters *loc_inters = NULL;

    IGRpoint ref_start, ref_stop, 
             next_start, next_stop;

    extern IGRint EMgetendpts_uv();
    extern IGRboolean EFextract_par();

    sts = OM_S_SUCCESS;
    *msg = EMS_S_Success;

    loc_inters = *inters;

     while(loc_inters) {
           in_world = TRUE;
           sts = om$send (msg = message EMSsubbs.EMpartolbasis(
                              &msg_loc, mattyp,
                              mat, &in_world, FALSE, &tol_basis),
                              targetid = loc_inters->this_obj.objid,
                              targetos = loc_inters->this_obj.osnum,
                              senderid = NULL_OBJID);
                 EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
                 EFextract_par(BSTOLLENVEC, tol_basis, &dis_tol, &msg_loc);
           tmp_intobj = loc_inters->cvs;

           while(tmp_intobj) {

                sts = EMgetendpts_uv(&msg_loc,
                                     &tmp_intobj->this_uvintobj,
                                     tmp_intobj->reversed, 1,
                                     ref_start, ref_stop);
                EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, wrap_up);
                ref_start[2] = ref_stop[2] = NULL;

                next_intobj = tmp_intobj->next;

                if(!BSdistptpts(&msg_loc, ref_start, ref_stop ) < dis_tol) {
                while(next_intobj) {
                sts = EMgetendpts_uv(&msg_loc,
                                     &next_intobj->this_uvintobj,
                                     next_intobj->reversed, 1,
                                     next_start, next_stop);
                EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, wrap_up);
                next_start[2] = next_stop[2] = NULL; 
              
             if(!BSdistptpts(&msg_loc, next_start, next_stop) < dis_tol) {
                dist[0] = BSdistptpts(&msg_loc, ref_stop, next_start);
                dist[1] = BSdistptpts(&msg_loc, ref_stop, next_stop);
                dist[2] = BSdistptpts(&msg_loc, ref_start, next_start);
                dist[3] = BSdistptpts(&msg_loc, ref_start, next_stop);
              
                if(((dist[0] < dis_tol && dist[2] < dis_tol) ||
                    (dist[1] < dis_tol && dist[3] < dis_tol)) &&
                   dist[2] > dist[0] && dist[3] > dist[1]) {
                if(dist[1] < dis_tol && dist[3] < dis_tol)
                  next_intobj->reversed = !next_intobj->reversed;

                if(!tmp_intobj->fwd) {
                     tmp_intobj->props &= ~EMSintobj_fwd_noconnectuv;
                     tmp_intobj->props |= EMSintobj_fwd_connectuv;
                     tmp_intobj->fwd = next_intobj;
                   }

                   if(!next_intobj->bwd && tmp_intobj->fwd == next_intobj) {
                     next_intobj->props &= ~EMSintobj_bwd_noconnectuv;
                     next_intobj->props |= EMSintobj_bwd_connectuv;
                     next_intobj->bwd = tmp_intobj;
                   }
                }
                else if(((dist[0] < dis_tol && dist[2] < dis_tol) ||
                         (dist[1] < dis_tol && dist[3] < dis_tol)) &&
                        dist[1] > dist[3] && dist[0] > dist[2]) {
                     if(dist[0] < dis_tol && dist[2] < dis_tol)
                        next_intobj->reversed = !next_intobj->reversed;

                     if(!tmp_intobj->bwd) {
                     tmp_intobj->props &= ~EMSintobj_bwd_noconnectuv;
                     tmp_intobj->props |= EMSintobj_bwd_connectuv;
                     tmp_intobj->bwd = next_intobj;
                   }

                   if(!next_intobj->fwd && tmp_intobj->bwd == next_intobj) {
                     next_intobj->props &= ~EMSintobj_fwd_noconnectuv;
                     next_intobj->props |= EMSintobj_fwd_connectuv;
                     next_intobj->fwd = tmp_intobj;
                              }
                     }
                else if(dist[0] < dis_tol || dist[1] < dis_tol) 
                  {     
                   if(dist[1] < dis_tol)
                     next_intobj->reversed = !next_intobj->reversed;

                   if(dist[0] < dis_tol && dist[1] < dis_tol) {
                      if(dist[0] < dist[1])
                      next_intobj->reversed = !next_intobj->reversed;
                     }

                   if(!tmp_intobj->fwd) {
                     tmp_intobj->props &= ~EMSintobj_fwd_noconnectuv;
                     tmp_intobj->props |= EMSintobj_fwd_connectuv;
                     tmp_intobj->fwd = next_intobj;
                   }

                   if(!next_intobj->bwd && tmp_intobj->fwd == next_intobj) {
                     next_intobj->props &= ~EMSintobj_bwd_noconnectuv;
                     next_intobj->props |= EMSintobj_bwd_connectuv;
                     next_intobj->bwd = tmp_intobj;
                   }
                 }
                 else if(dist[2] < dis_tol || dist[3] < dis_tol)
                        {
                   if(dist[2] < dis_tol)
                     next_intobj->reversed = !next_intobj->reversed; 

                   if(dist[2] < dis_tol && dist[3] < dis_tol) {
                      if(dist[3] < dist[2])
                      next_intobj->reversed = !next_intobj->reversed;
                   }

                   if(!tmp_intobj->bwd) {
                     tmp_intobj->props &= ~EMSintobj_bwd_noconnectuv;
                     tmp_intobj->props |= EMSintobj_bwd_connectuv;
                     tmp_intobj->bwd = next_intobj;
                   }

                   if(!next_intobj->fwd && tmp_intobj->bwd == next_intobj) {
                     next_intobj->props &= ~EMSintobj_fwd_noconnectuv;
                     next_intobj->props |= EMSintobj_fwd_connectuv;
                     next_intobj->fwd = tmp_intobj;
                              }
                           }
                        }
                   next_intobj = next_intobj->next;
                     }
                   }
                   else {
                   tmp_intobj->fwd = tmp_intobj;
                   tmp_intobj->bwd = tmp_intobj;
                   }
           tmp_intobj = tmp_intobj->next;
             }
         loc_inters = loc_inters->next;
         }

    wrap_up :
    return;   
}

      
/* 
 * Given two intobjs, this function tells whether they overlap each other 
 * or not. The following are the only overlapping situations.
 * a) __________ b) _____________ c) ____________
      __________    ______             ________   
 */

static IGRboolean EMintobjs_overlap(first_intobj, second_intobj,
                                    mattyp, mat, msg, dis_tol)

struct EMSintobj *first_intobj,
                 *second_intobj;
IGRshort *mattyp;
IGRmatrix mat;
IGRlong *msg;
IGRdouble dis_tol;

{

	IGRlong msg_loc, sts;
        IGRint i;
        IGRdouble points1[9],
                  points2[9], *mindist = NULL;
        IGRboolean overlap = TRUE;
        IGRpoint ref_start, ref_stop,
                 next_start, next_stop,
                 ref_middle, next_middle;
        struct EMSpypoint *projected_pts = NULL;

        extern IGRint EMgetendpts_xyz();
        extern IGRlong EMinternalpt();
        extern IGRlong EMprojectpt();
        extern struct EMSpypoint *EMpypoint_malloc();
        extern void EMpypoint_free();

        mindist = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) * 3);
        projected_pts = EMpypoint_malloc(&msg_loc, 3);

        sts = EMgetendpts_xyz (&msg_loc, mattyp, mat,
                               &first_intobj->this_xyzintobj,
                               first_intobj->reversed, 1,
                               ref_start, ref_stop);
              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
       
              EMinternalpt(&msg_loc, mattyp, mat,
                           &first_intobj->this_xyzintobj,
                           EMScvint_middle, 1, ref_middle);
              EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

                for(i = 0; i < 3; i++) {
                    points1[i] = ref_start[i];
                    points1[3+i] = ref_middle[i];
                    points1[6+i] = ref_stop[i];
                    }

              EMprojectpt(&msg_loc, mattyp, mat,
                          &second_intobj->this_xyzintobj, 3, points1,
                          dis_tol, projected_pts, mindist);
              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);  

              if(mindist[0] > dis_tol || mindist[1] > dis_tol ||
                 mindist[2] > dis_tol)
                 overlap = FALSE;

              if(!overlap) {
                 sts = EMgetendpts_xyz(&msg_loc, mattyp, mat,
                                       &second_intobj->this_xyzintobj,
                                       second_intobj->reversed, 1,
                                       next_start, next_stop);
                 EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

                 EMinternalpt(&msg_loc, mattyp, mat,
                              &second_intobj->this_xyzintobj,
                              EMScvint_middle, 1, next_middle);
                 EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

                 for(i = 0; i < 3; i++) {
                    points2[i] = next_start[i];
                    points2[3+i] = next_middle[i];
                    points2[6+i] = next_stop[i];
                    }
  
                 EMprojectpt(&msg_loc, mattyp, mat,
                             &first_intobj->this_xyzintobj, 3, points2,
                             dis_tol, projected_pts, mindist);
                 EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

                     if(mindist[0] < dis_tol && mindist[1] < dis_tol &&
                        mindist[2] < dis_tol)
                        overlap = !overlap;
                }

             if(!overlap) {
                for(i = 0; i < 3; i++) {
                    points1[i] = ref_stop[i];
                    points1[3+i] = ref_middle[i];
                    points1[6+i] = ref_start[i];
                    }

                EMprojectpt(&msg_loc, mattyp, mat,
                            &second_intobj->this_xyzintobj, 3, points1,
                            dis_tol, projected_pts, mindist);
                EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
              
                if(mindist[0] < dis_tol && mindist[1] < dis_tol &&
                   mindist[2] < dis_tol)
                   overlap = !overlap;
                }  

wrap_up :

    if(projected_pts)
       {(void) EMpypoint_free(projected_pts, MAXINT);}
    if(mindist)
       {om$dealloc (ptr = mindist);}
return(overlap);
}

static void EMpush_coinc_intobjs(inters, sfenv, dis_tol, opts, 
                                 msg, modified)

struct EMSinters **inters;
struct GRmdenv_info *sfenv;
IGRdouble dis_tol;
IGRushort opts;
IGRlong *msg;
IGRboolean *modified;
{
  IGRint i, j, num_pushed_intobjs = 0,
         bufsiz, nret, num_edges = 0;
  OMuint obj_count;
  IGRuint has_common_edge;
  struct EMSsfintedpar *moreinfo = NULL;
  IGRushort edprops;
  IGRlong msg_loc, size, sts;
  IGRboolean ed_reversed = FALSE, in_world,
             overlap, pushable; 
  GRobjid l_inced = NULL_OBJID, r_inced = NULL_OBJID,
          xyz_edid = NULL_OBJID, tmp_edid = NULL_OBJID,
          *eds_arr = NULL;
  IGRpoint start_uv, stop_uv;
  OM_S_CHANSELECT chan_to_common, to_loopset, to_comps_chan;
  OM_S_OBJECT_LINKAGE common_edge, loop_set, ed_list;
  struct IGRbsp_surface *my_sfgeom = NULL, *other_surface = NULL;
  struct EMSinters *loc_inters;
  struct EMSintobj *tmp_intobj, **pushed_intobjs = NULL,
                   *mkshift_intobj, *new_intobj = NULL,
                   *other_intobj_node = NULL;
  struct EMSsfintedpar *inc_info = NULL, *old_incinfo = NULL;
  enum EMScvinttype l_intloc, r_intloc;
  struct EMSgetlp_output out_loops, out_cvs;
  struct EMSdataselect tmp_xyzdata, comm_uvdata, comm_xyzdata;
  struct EMSpartolbasis ptolbas;
  struct GRid commsfid, clip_ls, *my_surf = NULL;
  IGRboolean my_pos, other_pos;
  struct GRvg_construct construct_list;
  struct GRlc_info cv_obj_info;
  struct GRmd_env md_env;
  struct IGRdisplay display_attr;
  struct EMSproj_info proj_info[2];

  extern IGRlong EMgetvggeom();
  extern IGRint EMget_mapped_data();
  extern IGRlong EMmkintdata();
  extern struct EMSintobj *EMmakeintlist();
  extern void EMcmpinters();
  extern struct EMSsfintedpar *EMsfintedpar_malloc();
  extern IGRint EMgetendpts_uv();
  extern void EMgetincinfo();
  extern IGRlong EMpost_process_incident_info();
  extern struct EMSintobj *EMdelintobj();

  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  bufsiz = sizeof(struct IGRdisplay);
  gr$get_active_display(msg = &msg_loc,
                      sizbuf = &bufsiz,
                      buffer = &display_attr,
                      nret = &nret);

  bufsiz = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg_loc,
                    sizbuf = &bufsiz,
                    buffer = &md_env,
                    nret = &nret);

  EMmake_chanselect(EMSbd_owner_to_comps, &to_comps_chan);  
  EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);
  EMmake_chanselect(EMSedge_to_common_edge, &chan_to_common);

  loc_inters = *inters;
  while(loc_inters) {
  for(tmp_intobj = loc_inters->cvs; tmp_intobj; tmp_intobj = tmp_intobj->next)
     {
     if(!(tmp_intobj->props & EMSintobj_overlap))
       continue;

     inc_info = (struct EMSsfintedpar *) tmp_intobj->more_info;
     l_intloc = inc_info->intloc;
     r_intloc = inc_info->next->intloc;
     l_inced = inc_info->edgeid;
     r_inced = inc_info->next->edgeid;

        for(j = 0; j < 2; j++) {
        mkshift_intobj = NULL;
        pushable = FALSE;
        overlap = FALSE;
        tmp_edid = j ? r_inced : l_inced;
        sts = om$send(msg = message EMSedge.EMget_props(&msg_loc, &edprops),
                senderid = NULL_OBJID, targetid = tmp_edid,
        targetos =  tmp_intobj->this_obj_node->this_obj.osnum);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
     
        if(edprops & EMED_DEGENERATE)
        continue;  

        ed_reversed = edprops & EMED_REVERSED;

        sts = om$send(msg = message EMSboundary.EMgetxyzobj(&msg_loc,
                NULL, sfenv, NULL, NULL, NULL, NULL,
                tmp_intobj->this_obj_node->this_obj.osnum, &xyz_edid),
                senderid = NULL_OBJID, targetid = tmp_edid,
                targetos = tmp_intobj->this_obj_node->this_obj.osnum);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

        tmp_xyzdata.datatype = EMSdata_object;
        tmp_xyzdata.data.object = NULL;
        tmp_xyzdata.data.object = (struct GRid *) om$malloc(size =
                                   sizeof(struct GRid));
        EMerr_hndlr(!(tmp_xyzdata.data.object), *msg, EMS_E_Fail, wrap_up);
        tmp_xyzdata.data.object->objid = xyz_edid;
        tmp_xyzdata.data.object->osnum =
                                  tmp_intobj->this_obj_node->this_obj.osnum;

        mkshift_intobj = (struct EMSintobj *) om$malloc(size = sizeof(struct
                                                           EMSintobj));
        EMerr_hndlr(!mkshift_intobj, *msg, EMS_E_Fail, wrap_up);
        mkshift_intobj->fwd = mkshift_intobj->bwd = NULL;
        mkshift_intobj->this_obj_node = NULL;
        OM_BLOCK_MOVE(&tmp_xyzdata, &mkshift_intobj->this_xyzintobj,
                      sizeof(struct EMSdataselect));
        mkshift_intobj->reversed = ed_reversed;
        mkshift_intobj->next = NULL;

        overlap = EMintobjs_overlap(mkshift_intobj,
                                    tmp_intobj,
                                    &sfenv->matrix_type,
                                    sfenv->matrix, &msg_loc,
                                    dis_tol);

        om$dealloc(ptr = tmp_xyzdata.data.object);
        tmp_xyzdata.data.object = NULL;
        mkshift_intobj->reversed = FALSE;
        if(mkshift_intobj)
           om$dealloc(ptr = mkshift_intobj);

        if(overlap)
        pushable = EMdet_reversal(tmp_edid, tmp_intobj, sfenv, &msg_loc);
        if(overlap && pushable) break;
     }
        if(overlap && pushable) {
          if(!num_pushed_intobjs){
          num_pushed_intobjs++;
          pushed_intobjs = (struct EMSintobj **) om$malloc(size =
                            num_pushed_intobjs * sizeof(struct EMSintobj *));
          eds_arr = (GRobjid *) om$malloc(size = num_pushed_intobjs *
                                sizeof(GRobjid));
          eds_arr[num_pushed_intobjs - 1] = tmp_edid;
          pushed_intobjs[num_pushed_intobjs - 1] = tmp_intobj;
          }
          else {
          num_pushed_intobjs++;
          pushed_intobjs = (struct EMSintobj **) om$realloc(ptr =
                           (IGRchar *)pushed_intobjs, size = 
                           num_pushed_intobjs * sizeof(struct EMSintobj *));
          eds_arr = (GRobjid *) om$realloc(ptr = (IGRchar *)eds_arr,
                     size = num_pushed_intobjs * sizeof(GRobjid));
          eds_arr[num_pushed_intobjs - 1] = tmp_edid;
          pushed_intobjs[num_pushed_intobjs - 1] = tmp_intobj;
           }
         }
       } 
  loc_inters = loc_inters->next; 
  }
  
  for(i = 0; i < num_pushed_intobjs; i++) {
        if((*modified) == FALSE)
           *modified = TRUE;

        my_pos = other_pos = FALSE;
        my_surf = NULL;
        my_surf = &pushed_intobjs[i]->this_obj_node->this_obj;
        EMgetvggeom (&msg_loc, &sfenv->matrix_type,
                     sfenv->matrix,
                     my_surf,
                     &my_sfgeom, NULL);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
        my_pos = my_sfgeom->pos_orient;

        has_common_edge = FALSE;
        om$get_channel_objects(objid = eds_arr[i],
                               p_chanselect = &chan_to_common,
                               count = &has_common_edge, size = 1,
                               list = &common_edge);
        if(!has_common_edge) {
        EMdelintobj(&msg_loc, pushed_intobjs[i]);
        EMcmpinters(&msg_loc, inters);
  
        if(msg_loc == EMS_I_NoMore)
          {
        *msg = EMS_I_OutOfBounds;
        goto wrap_up;
          }
        else
        continue;
        }

        sts = om$send(msg = message EMSboundary.EMgetsurface_info(&msg_loc,
                                            &commsfid.objid, NULL),
                                senderid = NULL_OBJID,
                                targetid = common_edge.S_objid,
                                targetos = common_edge.osnum);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
        commsfid.osnum = common_edge.osnum;

        sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                      &sfenv->matrix_type,
                      sfenv->matrix, &size),
                      targetid = commsfid.objid,
                      targetos = commsfid.osnum,
                      senderid = NULL_OBJID);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

        other_surface = (struct IGRbsp_surface *) om$malloc(size = size);
        sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                      &sfenv->matrix_type,
                      sfenv->matrix, (IGRchar *)other_surface),
                      targetid = commsfid.objid,
                      targetos = commsfid.osnum,
                      senderid = NULL_OBJID);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
        other_pos = other_surface->pos_orient;
   
        construct_list.msg = &msg_loc;
        construct_list.env_info = &md_env;
        construct_list.newflag = FALSE;
        construct_list.geometry = NULL;
        construct_list.class_attr = NULL;
        construct_list.level = NULL;
        construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        construct_list.display = &display_attr;
        construct_list.name = NULL;

        cv_obj_info.located_obj.objid = 
        pushed_intobjs[i]->this_xyzintobj.data.object->objid;
        cv_obj_info.located_obj.osnum =
        pushed_intobjs[i]->this_xyzintobj.data.object->osnum;
        cv_obj_info.module_info.md_id.objid = md_env.md_id.objid;
        cv_obj_info.module_info.md_id.osnum = md_env.md_id.osnum;  
        OM_BLOCK_MOVE(sfenv, &cv_obj_info.module_info.md_env,
                                 sizeof(struct GRmdenv_info));
 
        om$get_channel_objects(objid = commsfid.objid,
                               osnum = commsfid.osnum,
                               p_chanselect = &to_loopset,
                               list = &loop_set,
                               size = 1,
                               count = &obj_count);
        
       clip_ls.objid = loop_set.S_objid;
       clip_ls.osnum = loop_set.osnum;
       out_loops.objs = NULL;
       out_cvs.objs   = NULL;

       opts &= ~(EMMapBnd_RmvDegenCvs| EMMapBnd_ClipBdryArea);
       opts |= EMMapBnd_NoClip;
       sts = EMget_mapped_data((IGRlong)1,
                               NULL,
                               &cv_obj_info,
                               &construct_list,
                               other_surface,
                               NULL,
                               sfenv,
                               NULL,
                               NULL,
                               &out_loops,
                               &out_cvs,
                               clip_ls,
                               opts,
                               NULL,
                               &msg_loc); 
       EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
       if(!out_loops.objs) continue;

           sts = om$get_channel_count(objid = out_loops.objs[0],
                                      osnum = loop_set.osnum,
                                      p_chanselect = &to_comps_chan,
                                      count = &obj_count);
           sts = om$get_channel_objects (objid = (out_loops.objs[0]),
                                    osnum = loop_set.osnum,
                                    p_chanselect = &to_comps_chan,
                                    list = &ed_list,
                                    size = obj_count,
                                    count = (OMuint *)&num_edges);
          
           xyz_edid = out_cvs.objs[0];
          
           comm_uvdata.datatype    = EMSdata_object;
           comm_uvdata.data.object = NULL;
           comm_uvdata.data.object  =
                      (struct GRid *) om$malloc (size = sizeof (struct GRid));
           comm_uvdata.data.object->objid = ed_list.S_objid;
           comm_uvdata.data.object->osnum = ed_list.osnum;

           comm_xyzdata.datatype    = EMSdata_object;
           comm_xyzdata.data.object = NULL;
           comm_xyzdata.data.object =
                      (struct GRid *) om$malloc (size = sizeof (struct GRid));
           comm_xyzdata.data.object->objid = xyz_edid;
           comm_xyzdata.data.object->osnum = ed_list.osnum;

           in_world = FALSE;
           ptolbas.is_valid = FALSE;
           ptolbas.in_world = FALSE;
           ptolbas.mattyp   = &(sfenv->matrix_type);
           ptolbas.mat      = sfenv->matrix;
           sts = om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                      &(sfenv->matrix_type), sfenv->matrix, &in_world,
                      FALSE, &(ptolbas.tol)),
                      targetid = commsfid.objid,
                      targetos = commsfid.osnum,
                      senderid = NULL_OBJID);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
           ptolbas.is_valid = TRUE;

           moreinfo = EMsfintedpar_malloc(&msg_loc, 2);

           old_incinfo = (struct EMSsfintedpar *)pushed_intobjs[i]->more_info;
           l_intloc = old_incinfo->intloc;
           r_intloc = old_incinfo->next->intloc;
           l_inced =  old_incinfo->edgeid;
           r_inced =  old_incinfo->next->edgeid;

           if(IF_EQ_OBJID(l_inced, r_inced)) {
           sts = EMgetendpts_uv(&msg_loc,
                                &comm_uvdata,
                                FALSE, 1,
                                start_uv, stop_uv);
                 EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, wrap_up);
                 start_uv[2] = stop_uv[2] = 0.0;

           has_common_edge = FALSE;
           om$get_channel_objects(objid = l_inced,
                                  p_chanselect = &chan_to_common,
                                  count = &has_common_edge, size = 1,
                                  list = &common_edge);
           if(has_common_edge) {
           for(j = 0; j < 2; j++) {
           sts = om$send(msg = message EMSedge.EMptproject(&msg_loc, 
                               (j == 0 ? start_uv : stop_uv), 1, &proj_info[j],
                               NULL, &ptolbas),
                         senderid = NULL_OBJID,
                         targetid = common_edge.S_objid,
                         targetos = common_edge.osnum);
           EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, wrap_up);
           }

           moreinfo->edgeid = common_edge.S_objid;
           moreinfo->point[0] = start_uv[0];
           moreinfo->point[1] = start_uv[1];
           moreinfo->edgepar.param = proj_info[0].param.param;
           moreinfo->edgepar.span_inx = proj_info[0].param.span_inx;
           moreinfo->info = NULL;
           moreinfo->intloc = proj_info[0].location;

           moreinfo->next->edgeid = common_edge.S_objid;
           moreinfo->next->point[0] = stop_uv[0];
           moreinfo->next->point[1] = stop_uv[1];
           moreinfo->next->edgepar.param = proj_info[1].param.param;
           moreinfo->next->edgepar.span_inx = proj_info[1].param.span_inx;
           moreinfo->next->info = NULL;
           moreinfo->next->intloc = proj_info[1].location;
           }
         }
         else {
           EMgetincinfo (&msg_loc, commsfid.osnum,
                         &comm_uvdata,
                         FALSE, NULL,
                         &(sfenv->matrix_type),
                         sfenv->matrix, commsfid.objid, dis_tol,
                         ptolbas.tol,
                         (struct EMSsfintedpar *)moreinfo);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

           EMgetincinfo (&msg_loc, commsfid.osnum,
                         &comm_uvdata,
                         TRUE, NULL,
                         &(sfenv->matrix_type),
                         sfenv->matrix, commsfid.objid, dis_tol,
                         ptolbas.tol,
                         ((struct EMSsfintedpar *)moreinfo)->next);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

           EMpost_process_incident_info(&msg_loc,
                                        (struct EMSsfintedpar **)&moreinfo,
                                        &ptolbas,
                                        commsfid.osnum);
           EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrap_up);
         }

           new_intobj =  EMmakeintlist(&msg_loc, inters, NULL, &commsfid, NULL,
                                       (IGRchar *)other_surface, NULL, NULL,
                                       NULL,
                                       &comm_xyzdata,
                                       &comm_uvdata, NULL,
                                       FALSE, NULL,
                                       (IGRchar *)moreinfo, NULL,
                                       NULL, NULL,
                                       NULL, NULL,
                                       TRUE, FALSE);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);  
        
              if(pushed_intobjs[i]->props & EMSintobj_marked)
                 new_intobj->props |= EMSintobj_marked;

              if(other_pos != my_pos)
                 new_intobj->reversed = !pushed_intobjs[i]->reversed;
              else
                 new_intobj->reversed = pushed_intobjs[i]->reversed;

              if(!(new_intobj->props & EMSintobj_overlap))
                 new_intobj->props |= EMSintobj_overlap;
           
           sts = om$send(msg = message Root.wild_disconnect(to_comps_chan),
                                targetid = out_loops.objs[0],
                                targetos = commsfid.osnum,
                                senderid = NULL_OBJID);
           EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrap_up);
              
           sts = om$send(msg = message Root.delete(1),
                         targetid = out_loops.objs[0],
                         targetos = commsfid.osnum,
                         senderid = NULL_OBJID);   
           EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrap_up);

           if(other_surface) other_surface = NULL;

           if(my_sfgeom) {
           om$dealloc(ptr = my_sfgeom);
           my_sfgeom = NULL;
           }

           if(pushed_intobjs[i]->other_intobj_node)
           {
           other_intobj_node = pushed_intobjs[i]->other_intobj_node;
           pushed_intobjs[i]->other_intobj_node = NULL;

           new_intobj->other_intobj_node = other_intobj_node;
           other_intobj_node->other_intobj_node = new_intobj;
           }

           EMdelintobj(&msg_loc, pushed_intobjs[i]);
           pushed_intobjs[i] = NULL;
       
           EMcmpinters(&msg_loc, inters);
  } 

wrap_up :

if(eds_arr) om$dealloc(ptr = eds_arr);
   eds_arr = NULL;

if(pushed_intobjs) om$dealloc(ptr = pushed_intobjs);
   pushed_intobjs = NULL;

return;
 }

static IGRboolean EMdet_reversal(coinc_ed, intobj, sfenv, msg)
GRobjid coinc_ed;
struct EMSintobj *intobj;
struct GRmdenv_info *sfenv;
IGRlong *msg;
{
  IGRlong msg_loc, sts;
  IGRushort edprops;
  IGRdouble points[4];
  IGRboolean reversed = FALSE;
  struct EMSproj_info proj_info[2];
  struct EMSpartolbasis ptolbas;
  struct EMSedgebound param0, param1;
  
  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  sts = om$send(msg = message EMSedge.EMinternalpt (&msg_loc, 2, NULL, points,
                NULL, NULL),
                targetid = intobj->this_uvintobj.data.object->objid,
                targetos = intobj->this_uvintobj.data.object->osnum,
                senderid = NULL_OBJID);
  EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, wrap_up);

  sts = om$send(msg = message EMSedge.EMget_props(&msg_loc, &edprops),
                senderid = NULL_OBJID, targetid = coinc_ed,
        targetos =  intobj->this_obj_node->this_obj.osnum);
        EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, wrap_up);

  ptolbas.is_valid = FALSE;
  ptolbas.in_world = FALSE;
  ptolbas.mattyp   = &(sfenv->matrix_type);
  ptolbas.mat      = sfenv->matrix;
  sts = om$send(msg = message EMSedge.EMptproject(&msg_loc, points, 2, 
                proj_info, NULL, &ptolbas),
                targetid = coinc_ed,
                targetos = intobj->this_obj_node->this_obj.osnum,
                senderid = NULL_OBJID);
  EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, wrap_up); 
  
  param0 = proj_info[0].param;
  param1 = proj_info[1].param;
  if(((double)(param0.span_inx) + param0.param) >
     ((double)(param1.span_inx) + param1.param))
  {
     reversed = TRUE;
  }
  if(edprops & EMED_REVERSED)
     reversed = !reversed;
  if(intobj->reversed)
     reversed = !reversed;

wrap_up :
return(reversed);
}

static void EMsplit_and_append_inters(sfenv, num_ovlaps, ovlaps, 
                                      dis_tol, msg)

struct GRmdenv_info *sfenv;
IGRint num_ovlaps;
struct EMSintobj **ovlaps;
IGRdouble dis_tol;
IGRlong *msg;

{
IGRlong msg_loc, sts;
IGRint i, j, k, l_index = 0, r_index = 0,
       edge_count = 0, lower_inx, num_match_eds = 0,
       higher_inx, num_splits = 0, count;
IGRboolean split = FALSE, in_world;
IGRdouble ed_begin_pt[2], ed_end_pt[2],
          mindist = 0, uv_tol = 0;
IGRpoint xyz_pt, prev_pt, ed_pt, ref_start, ref_stop;
GRobjid l_edgeid = NULL_OBJID,
        r_edgeid = NULL_OBJID,
        loop_id = NULL_OBJID;
enum EMScvinttype l_loc, r_loc;
struct EMSintobj *tmp_intobj = NULL;
struct EMSsfintedpar *inc_info = NULL,
                     *more_info = NULL;
struct EMSproj_info proj_info;
struct EMSedgebound ref_param0, ref_param1,
                    param;
struct EMSpypoint *split_info_uv = NULL,
                  *split_info_xyz = NULL,
                  *tmp_spinfo_uv = NULL,
                  *tmp_spinfo_xyz = NULL,
                  tmp_proj_info;
struct EMSpartolbasis ptolbas;
OM_S_CHANSELECT to_components;
struct GRid *match_eds = NULL;

extern struct EMSpypoint * EMpypoint_malloc();
extern IGRboolean EFextract_par();
extern IGRlong EMprojectpt();
extern IGRboolean EMmsplit_sf_intobj_uv();
extern void EMgetincinfo();
extern IGRlong EMpost_process_incident_info();
extern IGRint EMgetendpts_uv();
extern void EMsortpypts(); 
extern void EMsfintedpar_free();

  sts = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  EMmake_chanselect(EMSbd_owner_to_comps, &to_components);

  for(i = 0; i < num_ovlaps; i++) {
  num_splits = NULL;
  tmp_spinfo_uv = NULL;
  split_info_uv = NULL;
  tmp_spinfo_xyz = NULL;
  split_info_xyz = NULL;

  in_world = FALSE;
  ptolbas.is_valid = FALSE;
  ptolbas.in_world = FALSE;
  ptolbas.mattyp   = &(sfenv->matrix_type);
  ptolbas.mat      = sfenv->matrix;
  sts = om$send (msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                             &sfenv->matrix_type,
                             sfenv->matrix, &in_world, FALSE, &ptolbas.tol),
                       targetid = ovlaps[i]->this_obj_node->this_obj.objid,
                       targetos = ovlaps[i]->this_obj_node->this_obj.osnum,
                       senderid = NULL_OBJID);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
         EFextract_par(BSTOLLENVEC, ptolbas.tol, &uv_tol, &msg_loc);
  
  inc_info = (struct EMSsfintedpar *) ovlaps[i]->more_info;
  l_loc = inc_info->intloc;
  r_loc = inc_info->next->intloc;
  l_edgeid = inc_info->edgeid;
  r_edgeid = inc_info->next->edgeid;

  if(IF_EQ_OBJID(l_edgeid, r_edgeid)) continue;

  sts = om$send(msg = message EMSedge.EMendpts(&msg_loc, NULL, NULL,
                      &ref_param0, &ref_param1, NULL),
                      senderid = NULL_OBJID,
                      targetid = ovlaps[i]->this_uvintobj.data.object->objid,
                      targetos = ovlaps[i]->this_uvintobj.data.object->osnum);
        EMerr_hndlr(!(1&sts), *msg, EMS_E_EdgeError, wrap_up);

  sts = EMgetendpts_uv(&msg_loc, &ovlaps[i]->this_uvintobj,
                       ovlaps[i]->reversed, 1, ref_start, ref_stop);
        EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, wrap_up);
        ref_start[2] = ref_stop[2] = NULL;
          
  sts = EMsend_loops(&msg_loc, message EMSboundary.EMget_objid(msg, &loop_id),
                     l_edgeid, 0, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
        EMerr_hndlr(!(1&sts), *msg, EMS_E_LoopError, wrap_up);

  sts = om$get_channel_count(objid = loop_id, p_chanselect =
                             &to_components, count = (OMuint *)&edge_count);  
        EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrap_up);

  for(j = 0; j < 2; j++) {
  sts = om$get_index (osnum_c = ovlaps[i]->this_obj_node->this_obj.osnum,
                      objid_c = loop_id,
                      p_chanselect = &to_components,
                      objid = (j==0 ? l_edgeid : r_edgeid),
                      osnum2 = ovlaps[i]->this_obj_node->this_obj.osnum,
                      indexaddr = (OMuint *)(j==0 ? &l_index : &r_index));
        EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrap_up);
    }
  
  if(r_index == l_index + 1 && l_loc == EMScvint_rtend && 
     r_loc == EMScvint_rtend)
  {
  continue;
  }
  else if(l_index == r_index + 1 && l_loc == EMScvint_rtend && 
          r_loc == EMScvint_rtend)
  {
  continue;
  }
 
  if((!l_index && r_index == edge_count -1) || 
     (!r_index && l_index == edge_count -1))
    {
     num_match_eds = 2;
     match_eds = (struct GRid *) om$malloc(size = num_match_eds *
                                           sizeof(struct GRid));
     match_eds[0].objid = l_edgeid; 
     match_eds[0].osnum = ovlaps[i]->this_obj_node->this_obj.osnum;
     match_eds[1].objid = r_edgeid;  
     match_eds[1].osnum = ovlaps[i]->this_obj_node->this_obj.osnum;
    }
  else {
     lower_inx = l_index < r_index ? l_index : r_index;
     higher_inx = l_index > r_index ? l_index : r_index;

     num_match_eds = (higher_inx - lower_inx) + 1;
     match_eds = (struct GRid *) om$malloc(size = num_match_eds *
                                           sizeof(struct GRid));

     for(j = lower_inx;  j <= higher_inx; j++)
        {
     sts = om$get_objid_at_index(osnum = 
                                 ovlaps[i]->this_obj_node->this_obj.osnum,
                                 objid = loop_id,
                                 p_chanselect = &to_components,
                                 index = j,
                                 objidaddr = &match_eds[j - lower_inx].objid,
                                 osnumaddr = &match_eds[j - lower_inx].osnum);
           EMerr_hndlr(!(1&sts), *msg, EMS_E_OMerror, wrap_up);
        }
     }
     for(j = 0; j < num_match_eds; j++) {
     sts = om$send(msg = message EMSedge.EMendpts(&msg_loc, ed_begin_pt, 
                      ed_end_pt, NULL, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = match_eds[j].objid,
                      targetos = match_eds[j].osnum);
           EMerr_hndlr(!(1&sts), *msg, EMS_E_EdgeError, wrap_up);
     
     for(k = 0; k < 2; k++) {
     sts = om$send(msg = message EMSedge.EMptproject(&msg_loc, 
                         (k == 0 ? ed_begin_pt : ed_end_pt), 1,
                         &proj_info, NULL, &ptolbas),
                         targetid = ovlaps[i]->this_uvintobj.data.object->objid,
                         targetos = ovlaps[i]->this_uvintobj.data.object->osnum,
                         senderid = NULL_OBJID);
           if(msg_loc == EMS_I_NoSolution) continue;
           EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, wrap_up);
           
           param = proj_info.param;      
           if((((double)(param.span_inx) + param.param) >
              ((double)(ref_param0.span_inx) + ref_param0.param) &&
              ((double)(param.span_inx) + param.param) <
              ((double)(ref_param1.span_inx) + ref_param1.param)) ||
              (((double)(param.span_inx) + param.param) > 
               ((double)(ref_param1.span_inx) + ref_param1.param) &&
               ((double)(param.span_inx) + param.param) <
               ((double)(ref_param0.span_inx) + ref_param0.param)))
           {
            if(!k)
            {
            ed_pt[0] = ed_begin_pt[0];
            ed_pt[1] = ed_begin_pt[1];
            }
            else
            {
            ed_pt[0] = ed_end_pt[0];
            ed_pt[1] = ed_end_pt[1];
            }
            ed_pt[2] = NULL;

            if(BSdistptpt(&msg_loc, ed_pt, ref_start) < uv_tol ||
               BSdistptpt(&msg_loc, ed_pt, ref_stop) < uv_tol)
            continue;

            sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                          &sfenv->matrix_type, sfenv->matrix,
                          &proj_info.param.param, 1, xyz_pt),
                          targetid =
                          ovlaps[i]->this_xyzintobj.data.object->objid,
                          targetos =
                          ovlaps[i]->this_xyzintobj.data.object->osnum,
                          senderid = NULL_OBJID);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

            EMprojectpt(&msg_loc,
                        &(sfenv->matrix_type),
                        sfenv->matrix,
                        &(ovlaps[i]->this_xyzintobj),
                        1,
                        xyz_pt,
                        dis_tol,
                        &tmp_proj_info, &mindist);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

            if(num_splits) {
            if(BSdistptpts(&msg_loc, xyz_pt, prev_pt) < dis_tol)
            continue;
            }  

            OM_BLOCK_MOVE(xyz_pt, prev_pt, sizeof(IGRpoint));

            if(!num_splits) {
            split_info_uv = EMpypoint_malloc(&msg_loc, 1);
            split_info_xyz = EMpypoint_malloc(&msg_loc, 1);
            split_info_uv->next = NULL;
            split_info_xyz->next = NULL;
            tmp_spinfo_uv = split_info_uv;
            tmp_spinfo_xyz = split_info_xyz;  
            }
            else {
            tmp_spinfo_uv->next = EMpypoint_malloc(&msg_loc, 1);
            tmp_spinfo_xyz->next = EMpypoint_malloc(&msg_loc, 1);
            tmp_spinfo_uv->next->next = NULL;
            tmp_spinfo_xyz->next->next = NULL;  
            tmp_spinfo_uv = tmp_spinfo_uv->next;
            tmp_spinfo_xyz= tmp_spinfo_xyz->next;
            }  
            tmp_spinfo_uv->props    = EMS_PYPT_ATMIDDLE; /* known */
            tmp_spinfo_uv->point[0] = proj_info.proj_pt[0];
            tmp_spinfo_uv->point[1] = proj_info.proj_pt[1];
            tmp_spinfo_uv->span_inx = proj_info.param.span_inx;
            tmp_spinfo_uv->param    = proj_info.param.param;
            tmp_spinfo_uv->info     = NULL;
            tmp_spinfo_uv->next     = NULL;

            tmp_spinfo_xyz->props    = EMS_PYPT_ATMIDDLE; /* known */
            tmp_spinfo_xyz->point[0] = tmp_proj_info.point[0];
            tmp_spinfo_xyz->point[1] = tmp_proj_info.point[1];
            tmp_spinfo_xyz->point[2] = tmp_proj_info.point[2];
            tmp_spinfo_xyz->span_inx = tmp_proj_info.span_inx;
            tmp_spinfo_xyz->param    = tmp_proj_info.param;
            tmp_spinfo_xyz->info     = NULL;
            tmp_spinfo_xyz->next     = NULL;
            
            num_splits++;
            }
          }
        }
            if(num_splits) {
            if(num_splits > 1) {
            EMsortpypts(&msg_loc, &split_info_uv, 2, FALSE, &uv_tol);
            EMsortpypts(&msg_loc, &split_info_xyz, 3 , FALSE, dis_tol);
            }
            
            split = EMmsplit_sf_intobj_uv(&msg_loc, EMSintobj_split_noconnectuv,
                                    sfenv, ovlaps[i], split_info_uv,
                                    split_info_xyz, FALSE);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);
        
            if(split) {
            tmp_intobj = ovlaps[i];
            count = NULL;
            while(tmp_intobj && (count <= num_splits))
            {
            if((ovlaps[i]->props & EMSintobj_marked) && 
               (tmp_intobj != ovlaps[i]))
              tmp_intobj->props |= EMSintobj_marked;

            more_info = (struct EMSsfintedpar *)tmp_intobj->more_info;
            EMgetincinfo (&msg_loc, tmp_intobj->this_obj_node->this_obj.osnum,
                         &tmp_intobj->this_uvintobj,
                         FALSE, NULL,
                         &(sfenv->matrix_type),
                         sfenv->matrix, 
                         tmp_intobj->this_obj_node->this_obj.objid,
                         dis_tol,
                         ptolbas.tol,
                         (struct EMSsfintedpar *)more_info);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

           EMgetincinfo (&msg_loc, ovlaps[i]->this_obj_node->this_obj.osnum,
                         &tmp_intobj->this_uvintobj,
                         TRUE, NULL,
                         &(sfenv->matrix_type),
                         sfenv->matrix,
                         tmp_intobj->this_obj_node->this_obj.objid,
                         dis_tol,
                         ptolbas.tol,
                         ((struct EMSsfintedpar *)more_info)->next);
           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrap_up);

           EMpost_process_incident_info(&msg_loc,
                                      (struct EMSsfintedpar **)&more_info,
                                      &ptolbas,
                                      ovlaps[i]->this_obj_node->this_obj.osnum);
           EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrap_up);

          if(tmp_intobj->fwd) tmp_intobj->fwd = NULL;
          if(tmp_intobj->bwd) tmp_intobj->bwd = NULL;
   
           tmp_intobj = tmp_intobj->next;
           count++;
            }
          }

           EMsfintedpar_free(split_info_uv, num_splits);
           EMsfintedpar_free(split_info_xyz, num_splits);
    
           split_info_uv = split_info_xyz = NULL;

        } /* if (num_splits) */

     } /*for each overlap intobj */

wrap_up :
return;
}

/* 
 * This function deletes degenerate intobjs and extends its 'fwd' and 'bwd'
 * intobjs, if any, appropriately, so that any parametric jumps that may
 * result are avoided.
 * Also, this function refines the end point information of intobjs.
 */

static void EMdel_degenintobs_and_refine(inters, sfenv, dis_tol, options, msg)

struct EMSinters **inters;
struct GRmd_env *sfenv;
IGRdouble dis_tol;
IGRint options;
IGRlong *msg;

{
 IGRint i, j, num_del_intobjs = 0,
        num_dextext_intobjs = 0, extend_loc;  
 IGRlong sts, msg_loc;
 IGRboolean in_world, degenerate = FALSE;
 IGRdouble uv_tol, dist[4];
 IGRpoint stpt, endpt, stpt_uv, endpt_uv,
          stpt_xyz, endpt_xyz, extndpt_uv,
          extndpt_xyz;
 GRobjid *l_edges = NULL, *r_edges = NULL,
         l_edgeid, r_edgeid, tmp_ed;
 enum EMScvinttype l_loc, r_loc, tmp_loc;
 struct EMSpartolbasis ptolbas;
 struct EMSinters *loc_inters = NULL;
 struct EMSintobj *tmp_intobj = NULL,
                  **del_intobjs = NULL,
                  **fwd_intobjs = NULL,
                  **bwd_intobjs = NULL,
                  **dextext_intobjs = NULL;
 struct EMSsfintedpar *more_info = NULL;

 extern IGRint EMgetendpts_uv();
 extern IGRint EMgetendpts_xyz();
 extern IGRint EMextend_object();
 extern IGRboolean EFextract_par();
 extern void EMgetincinfo();
 extern IGRlong EMpost_process_incident_info();
 extern struct EMSintobj *EMdelintobj();
 extern void EMcmpinters();
 extern IGRboolean EMdegenerate_data();

 sts = OM_S_SUCCESS;
 msg_loc = EMS_S_Success;

 loc_inters = *inters;

 while(loc_inters) {
       tmp_intobj = loc_inters->cvs;

       while(tmp_intobj) {
       if(options == DEEXTEND_EXTEND) {
       l_edgeid = r_edgeid = NULL_OBJID;
       more_info = (struct EMSsfintedpar *) tmp_intobj->more_info;
       l_loc = more_info->intloc;
       r_loc = more_info->next->intloc;
       l_edgeid = more_info->edgeid;
       r_edgeid = more_info->next->edgeid;

       if((l_loc == EMScvint_middle && !IF_NULL_OBJID(l_edgeid)) ||
          (r_loc == EMScvint_middle && !IF_NULL_OBJID(r_edgeid))) {
          if(!num_dextext_intobjs) {
             dextext_intobjs = (struct EMSintobj **) om$malloc( size =
                                sizeof(struct EMSintobj *));
             dextext_intobjs[num_dextext_intobjs] = tmp_intobj;

             l_edges = (GRobjid *) om$malloc( size = sizeof(GRobjid));
             if(l_loc == EMScvint_middle) 
                l_edges[num_dextext_intobjs] = l_edgeid;
             else
                l_edges[num_dextext_intobjs] = NULL_OBJID;

                r_edges = (GRobjid *) om$malloc( size = sizeof(GRobjid));
             if(r_loc == EMScvint_middle)
                r_edges[num_dextext_intobjs] = r_edgeid;
             else
                r_edges[num_dextext_intobjs] = NULL_OBJID;

             num_dextext_intobjs++;
          }
          else {
             num_dextext_intobjs++;
             dextext_intobjs = (struct EMSintobj **) om$realloc(ptr =
                                (IGRchar *) dextext_intobjs, size =
                                num_dextext_intobjs * 
                                sizeof(struct EMSintobj *));                   
             dextext_intobjs[num_dextext_intobjs - 1] = tmp_intobj;

             l_edges = (GRobjid *) om$realloc(ptr = (IGRchar *) l_edges,
                                   size = num_dextext_intobjs *
                                          sizeof(GRobjid));
             if(l_loc == EMScvint_middle)
                l_edges[num_dextext_intobjs - 1] = l_edgeid;
             else
                l_edges[num_dextext_intobjs - 1] = NULL_OBJID;

             r_edges = (GRobjid *) om$realloc(ptr = (IGRchar *) r_edges,
                                   size = num_dextext_intobjs *
                                          sizeof(GRobjid));
             if(r_loc == EMScvint_middle)
                r_edges[num_dextext_intobjs - 1] = r_edgeid;
             else
                r_edges[num_dextext_intobjs - 1] = NULL_OBJID;
            }
          }
       }  
       if(options == DEL_EXTEND) {
       sts = EMgetendpts_xyz(&msg_loc,
                             &sfenv->md_env.matrix_type,
                             sfenv->md_env.matrix,
                             &tmp_intobj->this_xyzintobj,
                             tmp_intobj->reversed,
                             1,
                             stpt,
                             endpt);
             EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);       

       degenerate = EMdegenerate_data(&tmp_intobj->this_xyzintobj, TRUE, NULL);

       if(BSdistptpt(&msg_loc, stpt, endpt) < dis_tol && degenerate)
         {
          if(!num_del_intobjs) {
             del_intobjs = (struct EMSintobj **) om$malloc(size = sizeof(struct
                                                 EMSintobj *));
             fwd_intobjs = (struct EMSintobj **) om$malloc(size = sizeof(struct
                                                 EMSintobj *));
             bwd_intobjs = (struct EMSintobj **) om$malloc(size = sizeof(struct
                                                 EMSintobj *));
             del_intobjs[num_del_intobjs] = tmp_intobj;
             fwd_intobjs[num_del_intobjs] = tmp_intobj->fwd;
             bwd_intobjs[num_del_intobjs] = tmp_intobj->bwd;
             num_del_intobjs++;
            }
          else {
             num_del_intobjs++;
             del_intobjs = (struct EMSintobj **) om$realloc(ptr =
                           (IGRchar *)del_intobjs, size = num_del_intobjs *
                                                   sizeof(struct EMSintobj *));             
             fwd_intobjs = (struct EMSintobj **) om$realloc(ptr = 
                           (IGRchar *)fwd_intobjs, size = num_del_intobjs *
                                                   sizeof(struct EMSintobj *));
             bwd_intobjs = (struct EMSintobj **) om$realloc(ptr =
                           (IGRchar *)bwd_intobjs, size = num_del_intobjs *
                                                   sizeof(struct EMSintobj *));
             del_intobjs[num_del_intobjs - 1] = tmp_intobj;
             fwd_intobjs[num_del_intobjs - 1] = tmp_intobj->fwd;
             bwd_intobjs[num_del_intobjs - 1] = tmp_intobj->bwd;
            }  
          } 
       }
         tmp_intobj = tmp_intobj->next;
     }	
         loc_inters = loc_inters->next;
  }
 
    if(options == DEL_EXTEND) {
    for(i = 0; i < num_del_intobjs; i++) {
        in_world = TRUE;
        uv_tol = 0.0;
        ptolbas.is_valid = FALSE;
        ptolbas.in_world = FALSE;
        ptolbas.mattyp   = &(sfenv->md_env.matrix_type);
        ptolbas.mat      = sfenv->md_env.matrix;

        sts = om$send (msg = message EMSsubbs.EMpartolbasis(
                              &msg_loc, &sfenv->md_env.matrix_type,
                              sfenv->md_env.matrix, &in_world, FALSE,
                              &ptolbas.tol),
                       targetid = del_intobjs[i]->this_obj_node->this_obj.objid,
                       targetos = del_intobjs[i]->this_obj_node->this_obj.osnum,
                       senderid = NULL_OBJID);
              EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);
              EFextract_par(BSTOLLENVEC, ptolbas.tol, &uv_tol, &msg_loc);
        ptolbas.is_valid = TRUE;

        sts = EMgetendpts_xyz(&msg_loc,
                              &sfenv->md_env.matrix_type,
                              sfenv->md_env.matrix,
                              &del_intobjs[i]->this_xyzintobj,
                              del_intobjs[i]->reversed,
                              1,
                              stpt_xyz,
                              endpt_xyz);
              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

        sts = EMgetendpts_uv(&msg_loc,
                             &del_intobjs[i]->this_uvintobj,
                             del_intobjs[i]->reversed, 1,
                             stpt_uv, endpt_uv);
              EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, wrapup);
              stpt_uv[2] = endpt_uv[2] = NULL;

        /*  Deleting degen intobjs having 'fwd', 'bwd' guys. */

        if(del_intobjs[i]->fwd && del_intobjs[i]->bwd) {
           
         /*  Deleting degen intobjs having overlapping 'fwd', 'bwd' guys. */
 
           if((fwd_intobjs[i]->props & EMSintobj_overlap) &&
              (bwd_intobjs[i]->props & EMSintobj_overlap))
           {
               more_info = (struct EMSsfintedpar *)
                           del_intobjs[i]->more_info;
               l_loc =     del_intobjs[i]->reversed ? more_info->next->intloc :
                           more_info->intloc;
               r_loc =     del_intobjs[i]->reversed ? more_info->intloc :
                           more_info->next->intloc;  
               
               /* Deletable without any doubts */

               if(l_loc != EMScvint_middle && r_loc != EMScvint_middle) {
                  EMdelintobj(&msg_loc, del_intobjs[i]);
                  continue;
               }

               /* Pull the 'bwd' guy to the appropriate end */

               else if(l_loc == EMScvint_middle && r_loc != EMScvint_middle)
               {
               tmp_intobj = bwd_intobjs[i];
               OM_BLOCK_MOVE(endpt_uv, extndpt_uv, sizeof(IGRpoint));
               OM_BLOCK_MOVE(endpt_xyz, extndpt_xyz, sizeof(IGRpoint));
               extend_loc = tmp_intobj->reversed ? BEGIN : END;
               }  
 
               /* Pull the 'fwd' guy to the appropriate end */

               else if(l_loc != EMScvint_middle && r_loc == EMScvint_middle)
               {
               tmp_intobj = fwd_intobjs[i];
               OM_BLOCK_MOVE(stpt_uv, extndpt_uv, sizeof(IGRpoint));
               OM_BLOCK_MOVE(stpt_xyz, extndpt_xyz, sizeof(IGRpoint));
               extend_loc = tmp_intobj->reversed ? END : BEGIN;  
               }
           }
           
           /* case of only overlapping 'fwd' guy  */

           else if((fwd_intobjs[i]->props & EMSintobj_overlap) &&
                  !(bwd_intobjs[i]->props & EMSintobj_overlap))
                {
                tmp_intobj = bwd_intobjs[i]; 
                OM_BLOCK_MOVE(endpt_uv, extndpt_uv, sizeof(IGRpoint)); 
                OM_BLOCK_MOVE(endpt_xyz, extndpt_xyz, sizeof(IGRpoint));
                extend_loc = tmp_intobj->reversed ? BEGIN : END;
                }

          /* case of only overlapping 'bwd' guy  */

           else if(!(fwd_intobjs[i]->props & EMSintobj_overlap) &&
                    (bwd_intobjs[i]->props & EMSintobj_overlap))
                {
                tmp_intobj = fwd_intobjs[i];
                OM_BLOCK_MOVE(stpt_uv, extndpt_uv, sizeof(IGRpoint));
                OM_BLOCK_MOVE(stpt_xyz, extndpt_xyz, sizeof(IGRpoint));
                extend_loc = tmp_intobj->reversed ? END : BEGIN;
                }
        }

        /* I have only a 'bwd' guy */

        else if(!del_intobjs[i]->fwd && del_intobjs[i]->bwd) {
                tmp_intobj = bwd_intobjs[i];
                OM_BLOCK_MOVE(endpt_uv, extndpt_uv, sizeof(IGRpoint));
                OM_BLOCK_MOVE(endpt_xyz, extndpt_xyz, sizeof(IGRpoint));
                extend_loc = tmp_intobj->reversed ? BEGIN : END;
        }
        
        /* I have only a 'bwd' guy */

        else if(del_intobjs[i]->fwd && !del_intobjs[i]->bwd) {
                tmp_intobj = fwd_intobjs[i];
                OM_BLOCK_MOVE(stpt_uv, extndpt_uv, sizeof(IGRpoint));
                OM_BLOCK_MOVE(stpt_xyz, extndpt_xyz, sizeof(IGRpoint));
                extend_loc = tmp_intobj->reversed ? END : BEGIN;
        }

        /* I have no trailing or leading guys.  No headache of pulling! */

        else if(!del_intobjs[i]->fwd && !del_intobjs[i]->bwd) {
                EMdelintobj(&msg_loc, del_intobjs[i]);
                continue;
                }
        
      /* Pulling of 'fwd','bwd' guys deemed fit for pulling above */  

        sts = om$send(msg = message EMSedge.EMextend_geom
                     (&msg_loc, extndpt_uv, &extend_loc, FALSE, NULL, NULL,
                      NULL, &ptolbas, NULL, NULL, NULL,
                      sfenv->md_env.matrix, 
                      &sfenv->md_env.matrix_type),
              targetid = tmp_intobj->this_uvintobj.data.object->objid,
              targetos = tmp_intobj->this_uvintobj.data.object->osnum,
              senderid = NULL_OBJID);
              EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, wrapup);

        sts = EMextend_object(&msg_loc, tmp_intobj->this_xyzintobj.data.object,
                              extndpt_xyz, &extend_loc, dis_tol, 
                              sfenv, FALSE);
              EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, wrapup);

     /* Update the corresponding incidence info */
          
              more_info = (extend_loc == BEGIN ? 
                          (struct EMSsfintedpar *)tmp_intobj->more_info :
                        ((struct EMSsfintedpar *)tmp_intobj->more_info)->next);
              EMgetincinfo (&msg_loc, 
                            tmp_intobj->this_uvintobj.data.object->osnum,
                            &tmp_intobj->this_uvintobj,
                            (extend_loc == BEGIN ? FALSE : TRUE), NULL,
                            &(sfenv->md_env.matrix_type),
                            sfenv->md_env.matrix,
                            tmp_intobj->this_obj_node->this_obj.objid,
                            dis_tol, ptolbas.tol,
                            more_info);
              EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

              EMpost_process_incident_info(&msg_loc,
                    (struct EMSsfintedpar **)&more_info,
                    &ptolbas,
                    tmp_intobj->this_uvintobj.data.object->osnum);
              EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrapup);

              EMdelintobj(&msg_loc, del_intobjs[i]);
              }

              EMcmpinters(&msg_loc, inters);

              EMstring_coinc_intobjs(&msg_loc, &sfenv->md_env.matrix_type,
                                     sfenv->md_env.matrix, inters);
              EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);
           }

        /*
           Time for refining the incidence info of intobjs after
           the above deletion of degenerate guys.
        */

        if(options == DEEXTEND_EXTEND) {
           IGRpoint ed_begin_xyzpt, ed_end_xyzpt, ed_begin_uvpt,
                    ed_end_uvpt;
           IGRboolean start_end_is_over, extend;

           for(i = 0; i < num_dextext_intobjs; i++) {
           extend = FALSE;
           start_end_is_over = FALSE;
           ptolbas.is_valid = FALSE;
           ptolbas.in_world = FALSE;
           ptolbas.mattyp   = &(sfenv->md_env.matrix_type);
           ptolbas.mat      = sfenv->md_env.matrix;
           sts = om$send (msg = message EMSsubbs.EMpartolbasis(
                                &msg_loc, &sfenv->md_env.matrix_type,
                                sfenv->md_env.matrix, &in_world, FALSE,
                                &ptolbas.tol),
                                targetid = 
                          dextext_intobjs[i]->this_obj_node->this_obj.objid,
                                targetos =
                          dextext_intobjs[i]->this_obj_node->this_obj.osnum,
                                senderid = NULL_OBJID);
                 EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);
           ptolbas.is_valid = TRUE;

        sts = EMgetendpts_xyz(&msg_loc,
                              &sfenv->md_env.matrix_type,
                              sfenv->md_env.matrix,
                              &dextext_intobjs[i]->this_xyzintobj,
                              FALSE,
                              1,
                              stpt_xyz,
                              endpt_xyz);
              EMerr_hndlr (EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

        sts = EMgetendpts_uv(&msg_loc,
                             &dextext_intobjs[i]->this_uvintobj,
                             FALSE, 1,
                             stpt_uv, endpt_uv);
              EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, wrapup);
              stpt_uv[2] = endpt_uv[2] = NULL;

        more_info = (struct EMSsfintedpar *)dextext_intobjs[i]->more_info;
        l_loc = more_info->intloc;
        r_loc = more_info->next->intloc;

        for(j = 0; j < 2; j++) {
        tmp_ed = NULL_OBJID;
        tmp_ed = (j == 0 ? l_edges[i] : r_edges[i]);
        tmp_loc = (j == 0 ? l_loc : r_loc);
        if(tmp_loc != EMScvint_middle)
        continue;

        if(!IF_NULL_OBJID(tmp_ed)) {
        sts = om$send(msg = message EMSedge.EMxyz_endpt(&msg_loc, NULL,
                            &sfenv->md_env, NULL, NULL, 
                            ed_begin_xyzpt, ed_end_xyzpt, NULL),
              senderid = NULL_OBJID,
              targetid = tmp_ed,
              targetos = dextext_intobjs[i]->this_obj_node->this_obj.osnum);
              EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_EdgeError, wrapup);

        sts = om$send(msg = message EMSedge.EMendpts(&msg_loc, ed_begin_uvpt,
                      ed_end_uvpt, NULL, NULL, NULL),
              senderid = NULL_OBJID,
              targetid = tmp_ed,
              targetos = dextext_intobjs[i]->this_obj_node->this_obj.osnum);
           EMerr_hndlr(!(1&sts), *msg, EMS_E_EdgeError, wrapup);

              dist[0] = BSdistptpt(&msg_loc, stpt_xyz, ed_begin_xyzpt);
              dist[1] = BSdistptpt(&msg_loc, stpt_xyz, ed_end_xyzpt);
              dist[2] = BSdistptpt(&msg_loc, endpt_xyz, ed_begin_xyzpt);
              dist[3] = BSdistptpt(&msg_loc, endpt_xyz, ed_end_xyzpt);
    
        if(dextext_intobjs[i]->props & EMSintobj_overlap) {
           if(l_loc != EMScvint_middle || r_loc != EMScvint_middle)
           {

           /*
              My start and end coincide with my left or right edge's
              corresponding ends.
           */
           if(dist[0] < dis_tol && dist[3] < dis_tol) {
              if(dist[0] > dist[3] && l_loc == EMScvint_middle) {
                 extend = TRUE;
                 OM_BLOCK_MOVE(ed_begin_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                 OM_BLOCK_MOVE(ed_begin_uvpt, extndpt_uv, sizeof(IGRpoint));
                 extend_loc = BEGIN;
               }
              else {
                 extend = TRUE;
                 OM_BLOCK_MOVE(ed_end_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                 OM_BLOCK_MOVE(ed_end_uvpt, extndpt_uv, sizeof(IGRpoint));
                 extend_loc = END;    
                }
              }
        
           /*
              My start and end coincide with my left or right edge's
              correspondingly opposite ends.
           */
           else if(dist[1] < dis_tol && dist[2] < dis_tol) {
              if(dist[1] > dist[2]) {     
                 extend = TRUE;
                 OM_BLOCK_MOVE(ed_end_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                 OM_BLOCK_MOVE(ed_end_uvpt, extndpt_uv, sizeof(IGRpoint));
                 extend_loc = BEGIN;
                }
              else {
                 extend = TRUE;
                 OM_BLOCK_MOVE(ed_begin_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                 OM_BLOCK_MOVE(ed_begin_uvpt, extndpt_uv, sizeof(IGRpoint));
                 extend_loc = END;
                }
              }
           }

           /* 
             I have to extend my-self at both ends.
           */

           else if(l_loc == EMScvint_middle && r_loc == EMScvint_middle)
                {
           if(dist[0] < dis_tol && dist[3] < dis_tol) {
              if(!start_end_is_over) {
                extend = TRUE;
                OM_BLOCK_MOVE(ed_begin_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                OM_BLOCK_MOVE(ed_begin_uvpt, extndpt_uv, sizeof(IGRpoint));
                extend_loc = BEGIN;
                start_end_is_over = TRUE;
                }
              else if(start_end_is_over) {
                extend = TRUE;
                OM_BLOCK_MOVE(ed_end_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                OM_BLOCK_MOVE(ed_end_uvpt, extndpt_uv, sizeof(IGRpoint));
                extend_loc = END;
              }
           }
           else if(dist[1] < dis_tol && dist[2] < dis_tol) {
              if(!start_end_is_over) {
                extend = TRUE;
                OM_BLOCK_MOVE(ed_end_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                OM_BLOCK_MOVE(ed_end_uvpt, extndpt_uv, sizeof(IGRpoint));
                extend_loc = BEGIN; 
                start_end_is_over = TRUE;
                }
              else if(start_end_is_over) {
                extend = TRUE;
                OM_BLOCK_MOVE(ed_begin_xyzpt, extndpt_xyz, sizeof(IGRpoint));
                OM_BLOCK_MOVE(ed_begin_uvpt, extndpt_uv, sizeof(IGRpoint));
                extend_loc = END;
              }
            }
         } 
      }

   /* Time now for non-overlapping guys to extend themselves */

   else if(dist[0] < dis_tol || dist[2] < dis_tol) {
           extend = TRUE;
           OM_BLOCK_MOVE(ed_begin_xyzpt, extndpt_xyz, sizeof(IGRpoint));
           OM_BLOCK_MOVE(ed_begin_uvpt, extndpt_uv, sizeof(IGRpoint));

           if(dist[0] < dis_tol)
           extend_loc = BEGIN;
           else if(dist[2])
           extend_loc = END;
        }       
        else if(dist[1] < dis_tol || dist[3] < dis_tol) {     
             extend = TRUE;
             OM_BLOCK_MOVE(ed_end_xyzpt, extndpt_xyz, sizeof(IGRpoint));
             OM_BLOCK_MOVE(ed_end_uvpt, extndpt_uv, sizeof(IGRpoint));

             if(dist[1] < dis_tol)
             extend_loc = BEGIN;
             else if(dist[3] < dis_tol)
             extend_loc = END;  
        }

        /* 
           If extendable!!
        */  

        if(extend) {
        sts = om$send(msg = message EMSedge.EMextend_geom
                     (&msg_loc, extndpt_uv, &extend_loc, FALSE, NULL, NULL,
                      NULL, &ptolbas, NULL, NULL, NULL,
                      sfenv->md_env.matrix,
                      &sfenv->md_env.matrix_type),
              targetid = dextext_intobjs[i]->this_uvintobj.data.object->objid,
              targetos = dextext_intobjs[i]->this_uvintobj.data.object->osnum,
              senderid = NULL_OBJID);
              EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, wrapup);

        sts = EMextend_object(&msg_loc, 
                              dextext_intobjs[i]->this_xyzintobj.data.object,
                              extndpt_xyz, &extend_loc, dis_tol,
                              sfenv, FALSE);
              EMerr_hndlr(EMSerror(msg_loc), *msg, msg_loc, wrapup);

        more_info = (extend_loc == BEGIN ?
                    (struct EMSsfintedpar *)dextext_intobjs[i]->more_info :
                ((struct EMSsfintedpar *)dextext_intobjs[i]->more_info)->next);
        EMgetincinfo (&msg_loc,
                      dextext_intobjs[i]->this_uvintobj.data.object->osnum,
                      &dextext_intobjs[i]->this_uvintobj,
                      (extend_loc == BEGIN ? FALSE : TRUE), NULL,
                      &(sfenv->md_env.matrix_type),
                      sfenv->md_env.matrix,
                      dextext_intobjs[i]->this_obj_node->this_obj.objid,
                      dis_tol, ptolbas.tol,
                      more_info);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

        EMpost_process_incident_info(&msg_loc,
                    (struct EMSsfintedpar **)&more_info,
                    &ptolbas,
                    dextext_intobjs[i]->this_uvintobj.data.object->osnum);
        EMerr_hndlr(!(msg_loc&1), *msg, msg_loc, wrapup);

        if(more_info->intloc == EMScvint_middle)
        more_info->intloc = (extend_loc == BEGIN) ? EMScvint_lfend :
                                                    EMScvint_rtend;
                   }
                } 
              }
           }
        }

wrapup :

if(del_intobjs) {
   om$dealloc(ptr = del_intobjs);
   del_intobjs = NULL;
   }
if(fwd_intobjs) {
   om$dealloc(ptr = fwd_intobjs);
   fwd_intobjs = NULL;
   }
if(bwd_intobjs) {
   om$dealloc(ptr = bwd_intobjs);
   bwd_intobjs = NULL;
   }
if(dextext_intobjs) {
   om$dealloc(ptr = dextext_intobjs);
   dextext_intobjs = NULL;
   }
if(l_edges) {
   om$dealloc(ptr = l_edges);
   l_edges = NULL;
   }
if(r_edges) {
   om$dealloc(ptr = r_edges);
   l_edges = NULL;
   }

return;
}

static void EMconnectDupOrgInts(orgint, dupint, mattyp, mat, tol, msg)

struct EMSinters **orgint, **dupint;
IGRshort *mattyp;
IGRmatrix mat;
IGRdouble tol;
IGRlong *msg;
{

    IGRlong msg_loc;
    IGRboolean found;
    IGRdouble mpar;
    IGRpoint ref_start, ref_middle,
             ref_stop;
    IGRpoint next_start, next_middle,
             next_stop;
    struct IGRbsp_curve *org_curve,
                        *dup_curve;
    struct EMSintobj *first_org_intobj,
                     *last_dup_intobj;
    struct EMSinters *loc_org_inters,
                     *loc_dup_inters;

    extern IGRlong EMgetvggeom();

    *msg = EMS_S_Success;

    loc_org_inters = *orgint;
    loc_dup_inters = *dupint;

    /* Refresh all the old data.*/

    while(loc_org_inters && loc_dup_inters) {
          first_org_intobj = loc_org_inters->cvs;
          last_dup_intobj = loc_dup_inters->cvs;
          
          while(first_org_intobj && last_dup_intobj)
          {
          if(first_org_intobj->other_intobj_node)
          first_org_intobj->other_intobj_node = NULL;

          if(last_dup_intobj->other_intobj_node)
          last_dup_intobj->other_intobj_node = NULL;

          first_org_intobj = first_org_intobj->next;
          last_dup_intobj = last_dup_intobj->next;
          }  
          
    loc_org_inters = loc_org_inters->next;
    loc_dup_inters = loc_dup_inters->next;
    }  

    loc_org_inters = *orgint;

    while(loc_org_inters) {
        for(first_org_intobj = loc_org_inters->cvs; first_org_intobj;
            first_org_intobj = first_org_intobj->next) {
            org_curve = NULL;
            found = FALSE;

            EMgetvggeom (&msg_loc, mattyp,
                         mat,
                         first_org_intobj->this_xyzintobj.data.object,
                         &org_curve, NULL);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

            BScvmidpt(org_curve, &mpar, ref_middle, &msg_loc);

            MAbcendpts(&msg_loc, org_curve, ref_start, ref_stop);

            loc_dup_inters = *dupint;
            while(loc_dup_inters) {
                 last_dup_intobj = loc_dup_inters->cvs;
            while(last_dup_intobj) {
            dup_curve = NULL;
  
            EMgetvggeom (&msg_loc, mattyp,
                         mat,
                         last_dup_intobj->this_xyzintobj.data.object,
                         &dup_curve, NULL);
            EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, wrapup);

            mpar = 0.0;
            BScvmidpt(dup_curve, &mpar, next_middle, &msg_loc);

            MAbcendpts(&msg_loc, dup_curve, next_start, next_stop);

            if(BSdistptpt(&msg_loc, ref_start, next_start) < tol &&
               BSdistptpt(&msg_loc, ref_stop, next_stop) < tol &&
               BSdistptpt(&msg_loc, ref_middle, next_middle) < tol)
               {
               found = TRUE;
               om$dealloc(ptr = dup_curve);
               break;
               }
               om$dealloc(ptr = dup_curve);
               last_dup_intobj = last_dup_intobj->next;
               }

            if(found) {
               if(!first_org_intobj->other_intobj_node)
               first_org_intobj->other_intobj_node = last_dup_intobj;

               if(!last_dup_intobj->other_intobj_node)
               last_dup_intobj->other_intobj_node = first_org_intobj;
               break;
                 }
               loc_dup_inters = loc_dup_inters->next;
              }
               om$dealloc(ptr = org_curve);
           }
               loc_org_inters = loc_org_inters->next;
         }
wrapup :
return;
}
end implementation Root;
