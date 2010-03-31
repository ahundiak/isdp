/*
NAME:
    EMshellsolid

ABSTRACT:
    This method creates a shell solid given the thickness, the side(s)
    towards which to shell and the surfaces to maintain "open".

    The EMconstruct_associative override is also included in this file, which
    simply ends up calling this method.

ARGUMENTS:

RETURN VALUES:

ALGORITHM:

NOTES:

KEYWORDS:

HISTORY:
 Jagan   : 05/29/95  :  Set the dpr_props bit of the original solid to
                       inactive after connecting it to the thinwall solid.
                       It fixes the TR 119422803
 ashok   : 06/16/94  : Integrated "mlk"s reported by Purify from EMS 4.
 ashok	 : 02/09/94  : Modified to check edge trimming (for open surfaces)
		       against cht_tol instead of lentol as fix for 
		       TR 119312569
 sudhakar: 01/28/94  : Modified to preserve 2.2 behaviour for solids of
                       revolution and projection. 
 sudhakar: 01/11/94  : Modified due to new args added to the function
                       EFget_edge_info().
 ashok   : 01/10/94  : Added new static function EFtrim_against_ed()
		       to generate intobjs from common edge between two
		       open surfaces (for TR 119312569)
 sudhakar: 01/05/94  : Modified due to extra arg. added to the function  call
                       "EFcvt_edge_to_cv()".
 ashok   : 12/31/93  : Modified the options to "EMintersect_surfaces"
                       to ensure that a double check is made with a
                       different tolerance and only closed groups are
                       returned. This fixed the TR# 119311735.
 ashok	 : 12/29/93  : Incorporated fix for TR 119313723.
 WBC     : 12/17/93  : Update the display_ids in the EMSdprparam object at
                       the end of the method if necessary.  Currently, if an
                       error is returned by certain method/function calls,
                       the display_ids may not be posted.
 sudhakar: 09/29/93  : Modified to handle 'pre-EMS 2.4' thinwall models.
 sudhakar: 09/24/93  : Modified code in 'EMconstruct_associative' to handle
                       an extra 'surface' parent. Pulled out the 'edge' parents.
                       Modified to deal with 'recompute info' with 'uv' data
                       for 'auto-dimensioning'.
 ashok   : 09/20/93  : Modified to call EMdisjointBoolean in case of void
		       thin-wall. Also delete offset solid if boolean fails.
 sampath : 09/07/93  : Fixed Problem with recompute of symmetric thin-wall.
 ashok   : 09/05/93  : Modified to erase open surfaces before boolean
		       processing. Also fixed a memory problem.
 ashok   : 09/01/93  : Enhanced logic for handling open-surfaces.
 sampath : 09/01/93  : Fixed a problem with undo of outward thin-wall during
		       recompute. The fix is to disconnect the solid from
		       the dpr state during EMconstruct_associative.
 ashok   : 08/15/93  : Added code to handle open-surfaces. If open-surfaces
		       are present we now handle the boolean specially by
		       generating the inters list for intersections between
		       the coincident surfaces and passing it down to the
		       lower level boolean function.
 Sudha   : 06/23/93  : Modified for BSprototype ansification
 Sudhakar: 21May'93  : Added code for handling thinwall from composite or
                       simple surface.
 Sudhakar: 03/15/93  : Modified for successful associative placement with
                       multiple thicknesses.
 Sudhakar: 01/08/93  : Modified for handling multiple thicknesses in non-
                       associative mode.
 Sudhakar: 01/20/93  : Modified arguments of EMoffset message.
 Tapadia : 09/24/92  : Fix for TR 119220155. Displaying the final DPR state
		       after the boolean operation to avoid showing the solid 
		       that will be differenced out

    SS   : 03/09/92  : Creation.
*/

class implementation EMSshslbool;

#include <string.h>
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"

#include "gr.h"         /* contains the new 'GRobjid_set' structure */
#include "grmacros.h"

#include "EMSopt.h"
#include "EMSprop.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "REshsolid.h"   /* contains the new 'EMSshell_solid' structure */
#include "emsimpdef.h"

/* includes for BS function prototypes */
#include "bschangepar.h"
#include "bsdistptpts.h"
#include "bsmdistptcv.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bspartofcv.h"
#include "bsgeom_cvsf.h"

%safe
static struct EMSintobj *EFtrim_against_ed();
%endsafe

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define FIRST  0
#define SECOND 1
#define START  0
#define STOP   1

#define COTHICK_PARAM 		0
#define INITIAL_SIZE		8

  extern IGRboolean    EFisAncestryValid();
extern GRclassid OPP_EMSsfdpr_class_id,
                 OPP_EMScompsurf_class_id,
                 OPP_EMSsfsolid_class_id,
                 OPP_EMSrevcompsf_class_id,
                 OPP_EMSprjcompsf_class_id,
		 OPP_EMSdpr_class_id ;
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from EMSdprparam import EMget_display_ids, EMput_display_ids;
from EMSsubbs import EMget_edges, EMpartolbasis;
from EMSloopset import EMlsparttrim;
from EMSedge import EMget_sf_edges, EMendpts, EMptproject, EMextractyourself;

/* TBD :
	1) CHANGE ARGUMENTS TO SEND IN GRobjid_set LIST FOR EFFICIENCY
*/

method EMshellsolid (IGRlong *msg; IGRushort options;
                     IGRshort *mattyp; IGRmatrix mat;
                     struct GRvg_construct *const_args;
                     GRobjid solidobj;
                     IGRdouble inward_thickness, outward_thickness;
                     IGRint num_mult_thickness;
                     IGRdouble *vals_mult_thickness;
                     IGRint *num_sfs_per_mult_thickness;
                     GRobjid *mult_thickness_sf_sets;
                     IGRint num_opensfs; GRobjid *opensfs;
                     IGRchar status_str[];
                     IGRint *num_dispsfs;
                     GRobjid **dispsfs)
                     
{
  IGRushort            offopts;
  IGRboolean           offin;
  IGRchar              dot[2];
  IGRint               i, j, k, ii, jj, kk;
  IGRlong              msg_loc, stat_OM;
  IGRdouble            thick;
  GRobjid              *p_obj, pos_solid=NULL_OBJID, neg_solid=NULL_OBJID;
  struct GRid          md_id, solid_grid;
  enum GRdpmode        dpmode;
  struct GRobjid_set   *spec_tk_sf_sets = NULL;
  IGRint               num_sfs, sf_index;
  struct EMSerror_help *errkey_list = NULL;
  GRobjid              *tmplist;
  IGRdouble            *vals_half_tk = NULL;
  IGRboolean           is_symmetric = FALSE, special_algo_only = FALSE,
                       tangent_mismatch = FALSE, open_gensf = FALSE;
  GRclassid            locobj_classid;
  IGRint               num_tgt_surfs=0;
  GRobjid              *tgt_surfs=NULL;

/* Memory pointers for intersection lists creation to handle open-surfaces */
  struct GRid	       *edges_inner=NULL, *edges_outer=NULL;
  struct IGRbsp_curve  *comm_edge_geom=NULL;
  GRobjid	       *surfs=NULL, *in_opensfs=NULL, *out_opensfs=NULL;
  struct EMSinters     *inters_in=NULL, *inters_out=NULL,
		       *int_inner=NULL, *int_outer=NULL;
  struct EMSsfintedpar *loc_edpars=NULL;  

  IGRboolean save_pathway_trim, save_pathway_orient;

  extern IGRboolean    EFis_member();
  extern void          EMget_tgt_surfaces(), EMsfintedpar_free();
  extern void          getsftype();

  IGRboolean           aflag;
  struct GRmd_env      display_env;

  gr$get_module_env(buffer = &display_env);
  aflag = pwIsActivationOn();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &md_id.objid);
  md_id.osnum = OM_Gw_current_OS;

  if (status_str)
    strcpy (dot, ".");

  /*
   * STAGE 1:
   * Compute the two operands for the difference operation that will
   * result in the shelled solid.
   */

  if (status_str)
    {
    strcat (status_str, dot);
    }

  offopts = ((options & EMSsfbool_opt_display) ? 
             EMS_opt_offsetS_display : NULL) |
            ((options & EMSsfbool_opt_HandleStop) ? 
             EMS_opt_offsetS_handlestop : NULL);

  /* 
   * Determine if 'symmetric' offset and find the 'half' thicknesses.
   */
  
  if((inward_thickness > 0 ) && (outward_thickness > 0.0))
    {
    /* It is the case of symmetric offset */
     is_symmetric = TRUE;

     if(num_mult_thickness)
      {
       vals_half_tk = (IGRdouble *) om$malloc (size = num_mult_thickness *
                                        sizeof(IGRdouble));
       EMerr_hndlr (!vals_half_tk, *msg, EMS_E_NoStackMemory, ret_end);
 
       for(j=0; j<num_mult_thickness; j++)
         vals_half_tk[j] = vals_mult_thickness[j]/2.0;
      }
    } /* end of if((inward....) */

  /* 
   *  Set data into a 'GRobjid_set' structure 
   */

  if(num_mult_thickness)
    {
     spec_tk_sf_sets = NULL;
     spec_tk_sf_sets = (struct GRobjid_set *) om$malloc(size =
                           num_mult_thickness * sizeof(struct GRobjid_set));
     EMerr_hndlr(!spec_tk_sf_sets, *msg, EMS_E_NoDynamicMemory, ret_end);

     num_sfs=0;
     for (j=0; j<num_mult_thickness; j++)
       {
        spec_tk_sf_sets[j].num_ids = num_sfs_per_mult_thickness[j];

	tmplist = NULL;
        tmplist = (GRobjid *) om$malloc(size =
                          num_sfs_per_mult_thickness[j] * sizeof(GRobjid));
        EMerr_hndlr(!tmplist, *msg, EMS_E_NoDynamicMemory, ret_end);

        for (k=0, sf_index=num_sfs; k<num_sfs_per_mult_thickness[j];
                                                    k++, sf_index++)
             tmplist[k] = mult_thickness_sf_sets[sf_index];
        num_sfs += num_sfs_per_mult_thickness[j];

        spec_tk_sf_sets[j].objids = tmplist;
       }
    } /* end of if(num_mult_thickness)... */

  /*
   * If the input happens to be a 2.2 model [ only solids of rev and 
   * proj.], then there is a possibility of the solid having the 
   * end caps open. Also an end-cap may be tangential to its
   * adjacent surface. This is not handled in the general offset
   * algorithm. Hence we need to sense this situation and use only
   * the specific algorithm.
   * TBD : The check for "tangent_mismatch" could be extended to
   *       all input solids, so that no such case enters the general
   *       offset code. 
   */

  solid_grid.objid = solidobj;
  solid_grid.osnum = OM_Gw_current_OS;
  stat_OM = om$get_classid(objid = solid_grid.objid,
                            osnum = solid_grid.osnum,
                            p_classid = &locobj_classid);
  EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  if(locobj_classid == OPP_EMSsfsolid_class_id)
  {
    IGRshort     props, sftype;
    IGRboolean  sfs_found;
    struct GRid tmpgrid;
    GRclassid   surf_classid;
    OM_S_CHANSELECT chan_to_comps;

    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

    /* 
     * get the object at index 0 of this "sfsolid" and determine
     * whether it is a an associative surface of projection or 
     * revolution.
     */
    stat_OM =  om$get_objid_at_index (objid = solid_grid.objid,
                                      osnum = solid_grid.osnum, 
                                      p_chanselect = &chan_to_comps, 
                                      index = 0,
                                      objidaddr = &tmpgrid.objid, 
                                      osnumaddr = &tmpgrid.osnum);
    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$get_classid(objid = tmpgrid.objid,
                             osnum = tmpgrid.osnum,
                             p_classid = &surf_classid);
    EMerr_hndlr(EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

    if((surf_classid == OPP_EMSrevcompsf_class_id) ||
       (surf_classid == OPP_EMSprjcompsf_class_id))
    {
       stat_OM = om$send(msg = message GRgraphics.GRgetprops
                                 (&msg_loc, &props),
                         targetid = solid_grid.objid,
                         targetos = solid_grid.osnum);
       EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
                         
#ifdef DEBUG
  printf(" For solid = %d props = %d\n", solid_grid.objid, props);
#endif

       /*
        * For each of the open surfaces, find all the tangent surfaces
        * and if any of the tangent surface is not an open surface
        * set the the "tangent_mismatch" flag.
        */
       for(ii=0; ii<num_opensfs && !tangent_mismatch; ii++)
       {
         if(!EFis_member(opensfs[ii], num_tgt_surfs, tgt_surfs))
         {
           num_tgt_surfs = 0;
           if(tgt_surfs) om$dealloc(ptr = tgt_surfs);
           tgt_surfs = NULL;
           EMget_tgt_surfaces(&msg_loc, opensfs[ii], solid_grid.osnum,
                              &tgt_surfs, &num_tgt_surfs, mattyp, mat);
           EMerr_hndlr(EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
         }
         else
            continue;

         if(num_tgt_surfs > 0)
         {
           for(jj=0; jj<num_tgt_surfs; jj++)
           {
             sfs_found = FALSE;
             for(kk=0; kk<num_opensfs && !sfs_found; kk++)
                if(tgt_surfs[jj] == opensfs[kk])
                   sfs_found = TRUE;
             if(!sfs_found) 
             {
               tangent_mismatch = TRUE;
#ifdef DEBUG
  printf("Tangent Mismatch found\n");
#endif 
               break;
             }
           } /* for (jj= 0;.... */
         }
       } /* for (ii=0;  ... */

       /*
        * Check if any of the open surfaces is a genbs surface.
        * If not so, we should try to force "special_algorithm" usage.
        */
       open_gensf = FALSE;
       for (ii=0; ii<num_opensfs; ii++)
       {
         getsftype(opensfs[ii], solid_grid.osnum, &sftype);
         if(sftype == BSGEN_BSP_SF)
            open_gensf = TRUE;
       }

       if((props & GRIS_ASSOCIATIVE) && !open_gensf) /* && tangent_mismatch) */
       {
#ifdef DEBUG
      printf("Info : It is an Associative solid of proj or rev\n");
#endif
         special_algo_only = TRUE;
       }

       if(tangent_mismatch && !(props & GRIS_ASSOCIATIVE))
       {
#ifdef DEBUG
 printf("EMshell_solid : Error - Tangent Mismatch. Cannot handle\n");
#endif
         *msg = EMS_E_Fail;
         goto ret_end;
       }
     } /* if((loc_objid==...      */
  } /* if(loc_objid == ....sfsolid... */
   
  /*
   * Find the Offset Solid(s) 
   */

  num_sfs = 0;
  for (i=FIRST, offin=FALSE, p_obj=&pos_solid, thick=outward_thickness;
       i<=SECOND;
       i++, offin=TRUE, p_obj=&neg_solid, thick=inward_thickness)
  {
       if (thick > 0.0)   /* Offset the solid */ 
       {
	 if(num_opensfs && !special_algo_only) 
                      /* Open surfaces present. Use general offset algo. */

            stat_OM = EFoffset_compsf(&msg_loc, solid_grid, offopts,
                      mattyp, mat, const_args, offin, thick,
                      num_mult_thickness, 
                      (is_symmetric ? vals_half_tk : vals_mult_thickness), 
                      spec_tk_sf_sets,
                      num_opensfs, opensfs, status_str, p_obj,
		      (offin ? &inters_in : &inters_out),
		      (num_sfs ? NULL:&num_sfs),
		      (num_sfs ? NULL : &surfs), errkey_list);

         else   /* let the solid offset itself anyway it wants */
         {
            if(tangent_mismatch)
                offopts |= EMS_opt_offsetS_special_algo_only;
            stat_OM = om$send(msg = message EMSsurface.EMoffset(&msg_loc,
				    offopts, mattyp, mat, const_args, offin,
				    thick, num_mult_thickness, 
                                    (is_symmetric ? vals_half_tk : 
				                    vals_mult_thickness), 
                      		    spec_tk_sf_sets, num_opensfs, opensfs,
				    status_str, p_obj, errkey_list),
			      targetid = solid_grid.objid,
			      targetos = solid_grid.osnum);
         }
         EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    
       }
       else
          *p_obj = solidobj;
  }

  /*
   * STAGE 2:
   * The second operand for the difference operation has been computed.
   * Perform the Boolean.
   */

  if(status_str) 
  {
    strcat (status_str, dot);
  }

  /* Pre-process to get the list of open-surfaces on the innermost solid.
     Because of 'zero' offset the corresponding open-surfaces of the "outer" 
     and "inner" solids are coincident. So a direct 'boolean difference' is 
     likely to fail. So we have to build the intersection lists (one for "outer"
     volume and the other for the "inner" volume) that would contain 
     intersections between the open-surfaces of "outer" with the adjacent 
     surfaces of the corresponding open-surfaces of "inner". 

  
   If there are no 'open' surfaces we perform a 'disjoint difference'
   between the outer and inner solids.

   Else (open-surfaces exist)
     For each open-surface
	 For each of its edges (take the edge on the inner solid's open-surf
				if the edge is convex; else take the edge of
				the outer solid's open surface. Lets call this
				the "current-edge" and the corresponding surface
				the "current-surface". We will call the other
				open-surface corresponding to the current-sf
				as the "other-surface").


	 Generate intersection curves (intobjs) from the current-edge.
	 For this we first trim the current-edge geometry w.r.t the
	 loopset of the other-surface. Then we generate the intobjs.

	 We do not generate an intobj on the current-surface to prevent
	 formation of sliver. Instead we generate the intobj corresponding
	 to the trimmed current-edge on its common edge surface.

	 The intobj on the other surface is obtained  by projecting the 
	 trimmed current_edge geometry on  to it. Orient the intobj based
	 on the REVERSE-CONNECT property.

	 Add the EMSintobjs to their appropriate EMSinters linked lists 
	 (one for 'inner' and one for 'outer')

     Trace the intersection lists.

     Call the boolean function passing the intersection-lists as input to 
     perform a 'differnce' operation. This should result in the 'thin-walled' 
     solid with the  desired 'open' surfaces.

  */

  if(!num_opensfs || (num_opensfs && special_algo_only)) 
                   /* No surface need to be opened or only special algo. */
  {
    /* THIS BLOCK can be modified to directly send the EMdisjointBoolean()
       message

       -Done.... 20-Sep-93 Ashok
    */
    if(num_opensfs && special_algo_only)
     
      stat_OM =  om$send (msg = message EMSsfboolean.EMboolean (&msg_loc,
                 mattyp, mat, pos_solid, 1, &neg_solid, const_args,
                 EMSbool_difference, options | EMSsfbool_opt_retryDisjoint,
                 status_str, NULL, NULL, dispsfs, num_dispsfs),
 		 targetid = my_id);

    else

      stat_OM = om$send (msg = message EMSsfboolean.EMdisjointBoolean(&msg_loc,
		 		       EMSbool_interiorD, options,
				       const_args, pos_solid, 1, &neg_solid),
			 targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  else /* Open surfaces present. Need to perform boolean with coincident
          surfaces */
  {
     IGRpoint		ed_start_pt, ed_stop_pt, split_pt1, split_pt2;
     IGRdouble		uv_pt1[2], uv_pt2[2], lentol, *pole_ptr, cht_tol;
     GRobjid		*in_opensfs_ptr=NULL, *out_opensfs_ptr=NULL,
			*int_edg_ptr = NULL;
     IGRboolean         found, is_free, is_cnvx, is_neut, world;
     struct EMSinters	*sf_inters1=NULL, *sf_inters2=NULL;
     IGRint		buf_siz_inner, buf_siz_outer, num_edges, num_edges2,
			num_adj, num_par, num_cvs;
     BSrc		rc;
     struct GRmd_env	*env;
     struct GRid	my_grid, tmp_sf_grid, comm_ed, comm_sf, adj_edges[2],
			int_edge, curr_edge;
     IGRushort		ed_props;
     struct EMSdataselect data, uv_data;
     struct EMSintobj	*p_intobj1=NULL, *p_intobj2=NULL;
     struct EMSsftracedata trace_outer, trace_inner;
     struct EMSsfintedpar *p_edpars=NULL, **ls_bdrys=NULL;
     struct EMSpartolbasis par_tol;
     struct EMSproj_info   proj_info;
     OM_S_CHANSELECT	to_ls;

     extern void		EFcvt_edge_to_cv(), EMsfinttrace_free();
     extern IGRlong		EFget_edge_info(), EMintersect_surfaces(),
				EMprojectpt(),
				EMboolean_surfaces_w_intersection();
     extern struct EMSintobj	*EFext_and_prj_cv(), *EMmakeintlist();
     extern struct EMSsfintedpar *EMsfintedpar_malloc();

     /* Initializations */
     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;
     env = const_args->env_info;
     par_tol.mattyp = &env->md_env.matrix_type;
     par_tol.mat = env->md_env.matrix;
     par_tol.in_world = TRUE;
     data.datatype = EMSdata_object;
     int_edge.osnum = OM_Gw_current_OS;
     tmp_sf_grid.osnum = OM_Gw_current_OS;
     EMmake_chanselect (EMSsubbs_to_loopset, &to_ls);
     BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
     BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);

     if(inters_in) /* either an inside or symmetric offset was performed.
		      we need to get the corresponding open-surfaces on
		      the inner solid */
     {
	in_opensfs = (GRobjid *) om$malloc(size = num_opensfs *
					   sizeof(GRobjid));
        EMerr_hndlr(!in_opensfs, *msg, EMS_E_NoDynamicMemory, ret_end);
     }

     if(inters_out) /* either an outside or symmetric offset was performed.
		       we need to get the corresponding open-surfaces on
		       the outer solid */
     {
	out_opensfs = (GRobjid *) om$malloc(size = num_opensfs *
					   sizeof(GRobjid));
        EMerr_hndlr(!out_opensfs, *msg, EMS_E_NoDynamicMemory, ret_end);
     }

     for(i=0; i<num_opensfs; i++)
     {
	  sf_inters1 = inters_in;
	  sf_inters2 = inters_out;
	  found = FALSE;
	  for(j=0; !found && j<num_sfs; j++,
		   sf_inters1=(inters_in ? sf_inters1->next : NULL),
		   sf_inters2=(inters_out ? sf_inters2->next : NULL))
	     if(opensfs[i] == surfs[j])
	     {
		if(inters_in) in_opensfs[i] = sf_inters1->this_obj.objid;
		if(inters_out) out_opensfs[i] = sf_inters2->this_obj.objid;
		found = TRUE;
	     }
          EMerr_hndlr(!found, *msg, EMS_E_Fail, ret_end);
     }
     in_opensfs_ptr = (in_opensfs ? in_opensfs : opensfs);
     out_opensfs_ptr = (out_opensfs ? out_opensfs : opensfs);

     if(inters_in)
     {
	EMinters_data_free(&msg_loc, inters_in, OM_K_MAXINT, NULL,
			   EMsfintedpar_free);
	EMinters_free(inters_in, OM_K_MAXINT);
     }
     if(inters_out)
     {
	EMinters_data_free(&msg_loc, inters_out, OM_K_MAXINT, NULL,
			   EMsfintedpar_free);
	EMinters_free(inters_out, OM_K_MAXINT);
     }
     inters_in = inters_out = NULL;

     buf_siz_inner = buf_siz_outer = INITIAL_SIZE;
     int_inner = int_outer = NULL;
     edges_inner = (struct GRid *) om$malloc(size = 
				   buf_siz_inner * sizeof(struct GRid));
     EMerr_hndlr(!edges_inner, *msg, EMS_E_NoDynamicMemory, ret_end);  
     edges_outer = (struct GRid *) om$malloc(size = 
				   buf_siz_outer * sizeof(struct GRid));
     EMerr_hndlr(!edges_outer, *msg, EMS_E_NoDynamicMemory, ret_end);

     loc_edpars = EMsfintedpar_malloc(&msg_loc, 2);

     for(i=0; i<num_opensfs; i++)
     {
	/* First erase the 'open' surfaces on both the inner and outer solids
	   as new loops would be created on them during the boolean operation
	*/
	dpmode = GRbe;
    if(aflag)
    {
	  stat_OM = om$send (msg = message GRgraphics.GRdisplay(&msg_loc, 
                                              &display_env.md_env.matrix_type,
                                              display_env.md_env.matrix,
	            				              &dpmode, 
                                              &display_env.md_id),
                         targetid = in_opensfs_ptr[i]);
	  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	  stat_OM = om$send (msg = message GRgraphics.GRdisplay(&msg_loc, 
                                              &display_env.md_env.matrix_type,
                                              display_env.md_env.matrix,
	            				              &dpmode, 
                                              &display_env.md_id),
		 	   targetid = out_opensfs_ptr[i]);
	  EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
	stat_OM = om$send (msg = message GRgraphics.GRdisplay(&msg_loc, mattyp,
					 mat, &dpmode, &md_id),
		 	   targetid = in_opensfs_ptr[i]);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	stat_OM = om$send (msg = message GRgraphics.GRdisplay(&msg_loc, mattyp,
					 mat, &dpmode, &md_id),
		 	   targetid = out_opensfs_ptr[i]);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

	num_edges = 0;
	stat_OM = om$send( msg = message EMSsubbs.EMget_edges(&msg_loc,
				    MAXINT, EMS_OPT_NONDEG, env, &edges_inner,
				    &buf_siz_inner, &num_edges),
			      targetid = in_opensfs_ptr[i]);
	EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

	num_edges2 = 0;
	stat_OM = om$send( msg = message EMSsubbs.EMget_edges(&msg_loc,
				    MAXINT, EMS_OPT_NONDEG, env, &edges_outer,
				    &buf_siz_outer, &num_edges2),
			      targetid = out_opensfs_ptr[i]);
	EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

       /* 
        * commented the following as for open surface case it is 
        * immaterial if they don't match, so no need to error --V.Srinivas
        *
	* if(num_edges != num_edges2)
	* {
	*    printf("EMshellsolid Error - Topology Mismatch\n");
	*    EMerr_hndlr (TRUE, *msg, EMS_E_Fail, ret_end);
	* }
        */

	for(j=0; j<num_edges; j++)
	{
	    curr_edge = edges_inner[j];
	    stat_OM = EFget_edge_info(&msg_loc, &env->md_env.matrix_type,
				      env->md_env.matrix, edges_inner[j], 
				      &comm_ed, &comm_sf, &ed_props, &is_free,
                                      &is_cnvx, &is_neut, NULL, NULL, NULL,
                                      NULL);
            EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg,
                        EMS_E_EdgeError,ret_end);

	    if(is_neut) continue;

/* Commented out this block as the edge shared by two opened surfaces also
   may contribute to the final topology. Fix for TR#119313723 (trace was
   returning open group). Ashok - 29/Dec/93
UN-COMMENTING 10/Jan/94 - Ashok */
	    found = FALSE;
	    for(k=0; !found && k<num_opensfs; k++)
	    {   
		if(k==i) continue;
		if(comm_sf.objid == in_opensfs_ptr[k]) found = TRUE;
	    }

/*	    if(!found) */

	    /* Move on to the next edge if the current edge is a common edge
	       between two open surfaces AND if it is closed */
	    if(found && (ed_props & EMED_XYZ_CLOSED)) continue;

	    {
	        if(!is_cnvx) /* Edge is not convex. So use the corresponding
			      edge on the open-surface of the 'outer' solid */
                {
		   curr_edge = edges_outer[j];
		   stat_OM = EFget_edge_info(&msg_loc, &env->md_env.matrix_type,
				        env->md_env.matrix, edges_outer[j],
				        &comm_ed, &comm_sf, &ed_props, &is_free,
				        &is_cnvx, &is_neut, NULL, NULL, 
                                        NULL, NULL);
		   EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg,
			       EMS_E_EdgeError,ret_end);
	        }
		comm_edge_geom = NULL;
		EFcvt_edge_to_cv(&msg_loc, (IGRushort)0, comm_ed, &comm_sf, 
			 	 &comm_edge_geom, &env->md_env);
	        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

		/* Store the end points of the edge geometry */
		pole_ptr = comm_edge_geom->poles;
		OM_BLOCK_MOVE(pole_ptr, ed_start_pt, 3 * sizeof(IGRdouble));
		OM_BLOCK_MOVE(&pole_ptr[(comm_edge_geom->num_poles - 1) * 3],
			      ed_stop_pt, 3 * sizeof(IGRdouble));
               /* Unweight the end-points if the curve is rational */
                if(comm_edge_geom->rational)
                    for(k=0; k<3; k++)
                    {
                       ed_start_pt[k] /= comm_edge_geom->weights[0];
                       ed_stop_pt[k]  /= 
                          comm_edge_geom->weights[comm_edge_geom->num_poles-1];
                    }

		loc_edpars->edgeid = loc_edpars->next->edgeid = comm_ed.objid;
		tmp_sf_grid.objid = (is_cnvx ? out_opensfs_ptr[i]:
						in_opensfs_ptr[i]);

/* BLOCK START - This block generates the intobj by projecting the curr-edge's
		 common-edge on to the open-surface on the other solid (inner
		 or outer as the case may be) and also sets its more_info
		 field to point to the incident edge info.  */

/*		p_edpars2 = NULL;
		ls_bdrys = &p_edpars2;
*/
	        if(ls_bdrys) om$dealloc(ptr = ls_bdrys);
	        ls_bdrys = NULL;
		if(found)
		{
		  struct GRid oth_edge;
		  oth_edge = (is_cnvx ? edges_outer[j] : edges_inner[j]);
		  p_intobj2 = EFtrim_against_ed(&msg_loc, tmp_sf_grid, oth_edge,
			      cht_tol, comm_edge_geom, &env->md_env,
			      (is_cnvx ? &int_outer : &int_inner),
			      &ls_bdrys, &num_cvs);
		}
		else
		{
		  p_intobj2 = EFext_and_prj_cv(&msg_loc, tmp_sf_grid,
			      tmp_sf_grid, NULL, NULL, comm_edge_geom, FALSE,
			      0.0, 0.0, &env->md_env,
			      (is_cnvx ? &int_outer : &int_inner),
			      FALSE, &ls_bdrys, &num_cvs);
		}
		om$dealloc(ptr = comm_edge_geom->poles);
		om$dealloc(ptr = comm_edge_geom->knots);
		if(comm_edge_geom->rational)
			om$dealloc(ptr = comm_edge_geom->weights);
		om$dealloc(ptr = comm_edge_geom);
		comm_edge_geom = NULL;
	        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
		if(!p_intobj2) continue;
#ifdef DEBUG
if(!(ls_bdrys))
printf("EMshell_solid - Error : Loopset Trim Info is NULL\n");
#endif
	        EMerr_hndlr(!(ls_bdrys), *msg, EMS_E_Fail, ret_end);
/* BLOCK END */

		/* Get the adjacent edges of the common edge */
		stat_OM = om$send(msg = message EMSedge.EMget_sf_edges(
				        &msg_loc, (IGRshort) 0, adj_edges,
				        &num_adj),
				  targetid = comm_ed.objid,
				  targetos = comm_ed.osnum);
		EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			       ret_end);
	        EMerr_hndlr((num_adj != 2), *msg, EMS_E_Fail, ret_end);

		for(k=0; k<num_cvs; k++, p_intobj2=p_intobj2->next)
		{
		   p_intobj2->more_info = (IGRchar *)ls_bdrys[k];

/* BLOCK START - This block computes the incident edge info for the intobj
		 (p_intobj1) generated by pushing curr_edge onto the common 
		 edge surface */

		   p_edpars = EMsfintedpar_malloc(&msg_loc, 2);

		   EMgetendpts_xyz(&msg_loc, &env->md_env.matrix_type,
			        env->md_env.matrix, &p_intobj2->this_xyzintobj,
				FALSE, 1, split_pt1, split_pt2);
	           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

		   /* If the edge was not trimmed, extract its entire geometry
		   */
		   if(k==0 &&
		      BSdistptpts(&rc, ed_start_pt,split_pt1) < cht_tol*cht_tol)
/*		      BSdistptpts(&rc, ed_start_pt, split_pt1) < lentol*lentol) */
		   {
		     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg_loc,
					     NULL, p_edpars->point, 
					     NULL, &p_edpars->edgepar, NULL),
				       targetid = adj_edges[0].objid,
                                       targetos = adj_edges[0].osnum);
	             EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			         ret_end);
		     p_edpars->intloc = EMScvint_rtend;
		     p_edpars->edgeid = adj_edges[0].objid;

		     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg_loc,
					     loc_edpars->point, NULL,
					     &loc_edpars->edgepar, NULL, NULL),
				       targetid = comm_ed.objid,
                                       targetos = comm_ed.osnum);
	             EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			         ret_end);
		     loc_edpars->intloc = EMScvint_lfend;

		   }
		   else  /* end was trimmed while projecting to other solid */
		   {
		     stat_OM = om$send(msg = message EMSsubbs.EMpratpt(&msg_loc,
					     &env->md_env.matrix_type,
					     env->md_env.matrix, split_pt1,
					     uv_pt1, &num_par),
			               targetid = comm_sf.objid,
				       targetos = comm_sf.osnum);
	             EMerr_hndlr(EMSerror(stat_OM&msg_loc), *msg, EMS_E_Fail, 
			         ret_end);
		     par_tol.is_valid = FALSE;
		     stat_OM = om$send(msg = message EMSedge.EMptproject(
					     &msg_loc, uv_pt1, (IGRint) 1,
					     &proj_info, NULL, &par_tol),
				       targetid = comm_ed.objid,
				       targetos = comm_ed.osnum);
	             EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			         ret_end);
		     p_edpars->edgepar = loc_edpars->edgepar = proj_info.param;
		     OM_BLOCK_MOVE(proj_info.proj_pt, p_edpars->point,
				   2 * sizeof(IGRdouble));
		     OM_BLOCK_MOVE(proj_info.proj_pt, loc_edpars->point,
				   2 * sizeof(IGRdouble));
		     p_edpars->intloc = loc_edpars->intloc = proj_info.location;
		     p_edpars->edgeid = comm_ed.objid;
		   }

		   if(k==num_cvs-1 &&
		      BSdistptpts(&rc, ed_stop_pt, split_pt2) < cht_tol*cht_tol)
/*		      BSdistptpts(&rc, ed_stop_pt, split_pt2) < lentol*lentol) */
		   {
		     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg_loc,
					     p_edpars->next->point, NULL,
					     &p_edpars->next->edgepar, NULL,
					     NULL),
				       targetid = adj_edges[1].objid,
                                       targetos = adj_edges[1].osnum);
	             EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			         ret_end);
		     p_edpars->next->intloc = EMScvint_lfend;
		     p_edpars->next->edgeid = adj_edges[1].objid;

		     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg_loc,
					     NULL, loc_edpars->next->point, 
					     NULL, &loc_edpars->next->edgepar,
					     NULL),
				       targetid = comm_ed.objid,
                                       targetos = comm_ed.osnum);
	             EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			         ret_end);
		     loc_edpars->next->intloc = EMScvint_rtend;
		   }
		   else  /* end was trimmed while projecting to other solid */
		   {
		     stat_OM = om$send(msg = message EMSsubbs.EMpratpt(&msg_loc,
					   &env->md_env.matrix_type,
					   env->md_env.matrix, split_pt2,
					   uv_pt2, &num_par),
			               targetid = comm_sf.objid,
				       targetos = comm_sf.osnum);
	             EMerr_hndlr(EMSerror(stat_OM&msg_loc), *msg, EMS_E_Fail, 
			         ret_end);

		     par_tol.is_valid = FALSE;
		     stat_OM = om$send(msg = message EMSedge.EMptproject(
					     &msg_loc, uv_pt2, (IGRint) 1,
					     &proj_info, NULL, &par_tol),
				       targetid = comm_ed.objid,
				       targetos = comm_ed.osnum);
	             EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			         ret_end);
		     p_edpars->next->edgepar = loc_edpars->next->edgepar =
					       proj_info.param;
		     OM_BLOCK_MOVE(proj_info.proj_pt, p_edpars->next->point,
				   2 * sizeof(IGRdouble));
		     OM_BLOCK_MOVE(proj_info.proj_pt, loc_edpars->next->point,
				   2 * sizeof(IGRdouble));
		     p_edpars->next->intloc = loc_edpars->next->intloc =
					      proj_info.location;
		     p_edpars->next->edgeid = comm_ed.objid;
		   }
/* BLOCK END */

/* BLOCK START - This block generates the other intobj (p_intobj) by extracting
		 a portion of the common edge. */

                   /* Obtain the surface tolerance before creating the 
                      extracted edge */
                   world = TRUE;
                   stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis 
                                            (&msg_loc,
                                            &env->md_env.matrix_type, 
                                            env->md_env.matrix,
                                            &world, FALSE, &par_tol.tol),
                                      senderid = NULL_OBJID,
                                      targetos = comm_sf.osnum,
                                      targetid = comm_sf.objid);
                   EMerr_hndlr(!(1 & stat_OM & msg_loc), 
                                       *msg, EMS_E_SurfaceError,ret_end);
                   par_tol.in_world = TRUE;
                   par_tol.is_valid = TRUE;

		   int_edg_ptr = &int_edge.objid;
		   stat_OM = om$send(msg = message EMSedge.EMextractyourself(
					   &msg_loc,
/*				           (num_edges==1? NULL : loc_edpars), */
				           (ed_props & EMED_OPEN ? loc_edpars :
								   NULL),
					   NULL, 1, &int_edg_ptr,
					   NULL, NULL, FALSE,
					   (IGRushort)EMImpBnd_NoInputDelete,
					   NULL, &par_tol),
				     targetid = comm_ed.objid,
				     targetos = comm_ed.osnum);
	           EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail,
			       ret_end);

		   data.data.object = &int_edge;
		   EMmkintdata(&msg_loc, &data, NULL, NULL, FALSE, NULL,
			       const_args, TRUE, NULL, NULL, &uv_data);

	           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

		   p_intobj1 = EMmakeintlist(&msg_loc, (is_cnvx ? &int_inner :
							          &int_outer),
			       NULL, &comm_sf, NULL, NULL, NULL, NULL, NULL,
			       &p_intobj2->this_xyzintobj, &uv_data, NULL,
			       FALSE, FALSE, (IGRchar *)p_edpars, NULL, 0, 0,
			       NULL, NULL, TRUE, FALSE);
	           EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
/* BLOCK END */

	           p_intobj1->other_intobj_node = p_intobj2;
	           p_intobj2->other_intobj_node = p_intobj1;

		   if(!(ed_props & EMED_REVERSE_CONNECT))
		     p_intobj2->reversed = (p_intobj2->reversed ? FALSE : TRUE);

		   EMconvert_to_edge(&msg_loc, p_intobj2, OM_Gw_current_OS);
		} /* for(k=num_cvs; ....) */
	    } /* if(!found) */
	} /* for(j=0; j<num_edges; j++) */
     } /* for(i=0; i<num_opensfs;.... */

     /* Trace the inters-lists int_inner and  int_outer */

     for(i=FIRST; i<=SECOND; i++)
     {
       save_pathway_trim = _pathway_trim;
       save_pathway_orient = _pathway_orient;
       _pathway_trim = 0;
       _pathway_orient = 0;

       stat_OM = EMintersect_surfaces(&msg_loc, NULL, &env->md_env, 0, NULL,
				      &env->md_env, 
				      EMS_SFINT_SKIPSFINT | EMS_SFINT_MUSTCLOSE |
				      EMS_SFINT_DOUBLECHECK,
/*EMS_SFINT_CHTTRACETOL,*/
/*				      EMS_SFINT_SKIPSFINT, */
/*				      EMS_SFINT_SKIPSFINT | EMS_SFINT_NOREFINE,*/
				      NULL, NULL, NULL, NULL, NULL, 
				      (i==FIRST ? &int_outer : &int_inner),
				      NULL,
				      (i==FIRST ? &trace_outer : &trace_inner), 
				      NULL, NULL, NULL, NULL);
       _pathway_trim = save_pathway_trim;
       _pathway_orient = save_pathway_orient;

       EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
     }

#ifdef DEBUG
if(!trace_outer.num_grps)
  printf("EMshell_solid : Error - Zero outer groups\n");
if(!trace_inner.num_grps)
  printf("EMshell_solid : Error - Zero inner groups\n");
#endif

     EMerr_hndlr(!trace_outer.num_grps, *msg, EMS_E_Fail, ret_end);
     EMerr_hndlr(!trace_inner.num_grps, *msg, EMS_E_Fail, ret_end);

     for(i=0; i<trace_outer.num_grps; i++)
     {
#ifdef DEBUG
if(!trace_outer.grp_closed[i])
  printf("EMshell_solid : Error - Traced Group Not Closed\n");
#endif
           EMerr_hndlr(!trace_outer.grp_closed[i], *msg, EMS_E_Fail, ret_end);
     }
     for(i=0; i<trace_inner.num_grps; i++)
     {
#ifdef DEBUG
if(!trace_inner.grp_closed[i])
  printf("EMshell_solid : Error - Traced Group Not Closed\n");
#endif
           EMerr_hndlr(!trace_inner.grp_closed[i], *msg, EMS_E_Fail, ret_end);
     }
 
     /* Perform the Boolean Difference */

     stat_OM = EMboolean_surfaces_w_intersection(&msg_loc, &my_grid,
		EMSbool_difference, env, pos_solid, 1, &neg_solid,
		int_outer, int_inner, &trace_outer, &trace_inner, NULL, NULL,
		NULL, num_dispsfs, dispsfs, status_str);
     EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

     /* Free the trace data structures */
     EMsfinttrace_free(&msg_loc,
			trace_outer.num_grps, trace_outer.num_subgrps_grp,
			trace_outer.num_elems_subgrp, trace_outer.elems,
			trace_outer.subgrp_rev, trace_outer.elem_rev,
			trace_outer.grp_closed, trace_outer.subgrp_closed);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
     EMsfinttrace_free(&msg_loc,
			trace_inner.num_grps, trace_inner.num_subgrps_grp,
			trace_inner.num_elems_subgrp, trace_inner.elems,
			trace_inner.subgrp_rev, trace_inner.elem_rev,
			trace_inner.grp_closed, trace_inner.subgrp_closed);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
     if(ls_bdrys) om$dealloc(ptr = ls_bdrys);

  } /* else of if(!num_opensfs) */


  /* Finally, display the shell solid */

  {
  dpmode = GRbd;
  if(aflag)
  stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
                     &display_env.md_env.matrix_type, display_env.md_env.matrix,
           	     &dpmode, &display_env.md_id), 
                     targetid = my_id);
  else
  stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc, mattyp, mat,
           	                   &dpmode, &md_id), targetid = my_id);
  }
ret_end:
#ifndef KEEP_SURFS_ON_ERR
  if(EMSerror(*msg))
  {
    IGRlong sts;
    for (i=FIRST, p_obj=&pos_solid, thick=outward_thickness;
         i<=SECOND && thick > 0.0 && (*p_obj != NULL_OBJID);
         i++, p_obj=&neg_solid, thick=inward_thickness)

             sts  = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                             const_args->env_info),
                           targetid = *p_obj);
  }
#endif

  if(vals_half_tk) om$dealloc(ptr = vals_half_tk);
  if(spec_tk_sf_sets)
     for(i=0; i<num_mult_thickness; i++)
       if(spec_tk_sf_sets[i].objids)
           om$dealloc(ptr = spec_tk_sf_sets[i].objids);
  if(spec_tk_sf_sets) om$dealloc(ptr = spec_tk_sf_sets);

  if(in_opensfs) om$dealloc(ptr = in_opensfs);
  if(out_opensfs) om$dealloc(ptr = out_opensfs);
  if(surfs) om$dealloc(ptr = surfs);
  if(edges_inner)om$dealloc(ptr = edges_inner);
  if(edges_outer)om$dealloc(ptr = edges_outer);
  if(loc_edpars)EMsfintedpar_free(loc_edpars, MAXINT);
  if(int_inner)
  {
     EMinters_data_free(&msg_loc, int_inner, OM_K_MAXINT, NULL,
			EMsfintedpar_free);
     EMinters_free(int_inner, MAXINT);
  }
  if(int_outer)
  {
     EMinters_data_free(&msg_loc, int_outer, OM_K_MAXINT, NULL,
			EMsfintedpar_free);
     EMinters_free(int_outer, MAXINT);
  }
  if(inters_in)
  {
     EMinters_data_free(&msg_loc, inters_in, OM_K_MAXINT, NULL, NULL);
     EMinters_free(inters_in, MAXINT);
  }
  if(inters_out)
  {
     EMinters_data_free(&msg_loc, inters_out, OM_K_MAXINT, NULL, NULL);
     EMinters_free(inters_out, MAXINT);
  }
  if(tgt_surfs) om$dealloc(ptr = tgt_surfs);

  EMWRAPUP (*msg, stat_OM, "EMshslbool");
  return (stat_OM);
}


method EMconstruct_associative (IGRlong *msg; IGRushort options;
                                GRobjid old_objid;
                                IGRint num_parents; IGRchar *parent_info;
                                IGRint type; IGRchar *recomp_info;
                                struct GRvg_construct  *const_list)
{
  IGRboolean recompute,
             update_display_ids = FALSE;
  IGRchar status_str[GR_MAX_CHAR];
  IGRushort bool_opts;
  IGRuint *param_type;
  IGRint i, j, solid_inx, num_opensfs, display_count;
  IGRlong msg_loc, stat_OM;
  IGRdouble curr_cht = 0.0;
  GRobjid *display_ids, *opensfs, tmp_param;
  struct GRmd_env *md_env;
  union EMSparent_info *param;
  struct EMSshell_solid *ashell;
  struct mult_tk_surfs_views *s_views;
  IGRboolean is_symmetric, inward, post_220; 
  IGRint num_mult_tks, *num_sfs = NULL;
  IGRint parent_index, sfs_index = 0;
  IGRdouble common_thickness, inthick, outthick;
  IGRdouble *vals_mult_thickness = NULL;
  GRobjid *mult_thickness_sf_list = NULL;
  struct GRid ownerGRid;
  IGRlong     owner_index=OM_K_MAXINT;

  extern IGRlong EMput_in_the_ssi_table();


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  display_ids = NULL;
  EMerr_hndlr (num_parents < 2, *msg, EMS_E_InvalidArg, ret_end); 

 /* Expand the Recompute Info into standard form */

  if(recomp_info)
  {
    /* Post-EMS 2.2 Thinwall Model */ 
     ashell = (struct EMSshell_solid *)recomp_info;

     is_symmetric = ashell->is_symmetric;
     inward       = ashell->inward;
     num_mult_tks = ashell->num_mult_tks;

     s_views = ashell->sfs_views;
     post_220 = TRUE;
  }
  else
  {
    /* EMS 2.2 or earlier Thinwall Model */
     is_symmetric = FALSE;
     inward = TRUE;
     num_mult_tks = 0;
     s_views = NULL;
     post_220 = FALSE;
  }

  if(num_mult_tks)
    { 
     num_sfs  = (IGRint *) alloca (num_mult_tks * sizeof(IGRint));
     EMerr_hndlr (!num_sfs, *msg, EMS_E_NoStackMemory, ret_end);
     for (i=0; i<num_mult_tks; i++)
        num_sfs[i] = s_views[i+1].num_sfs_per_mult_tks;
    }

 /*
  * Obtain my parameter information in an understandable
  * format
  */

  param_type = (IGRuint *) alloca (num_parents * sizeof (IGRint));
  EMerr_hndlr (!param_type, *msg, EMS_E_NoStackMemory, ret_end);

  parent_index = 0;

  /* Thickness values : Common and Specific */
  param_type[parent_index] = EMSdistance;
  parent_index++;

  if(post_220)
  {
    if(num_mult_tks)
       {
        /* Specific Thickness Objects */
        for (i=0, j=parent_index; i< num_mult_tks; i++, j++)
          {
           param_type[j] = EMSdistance;
          }
        parent_index += num_mult_tks;
       }

    /* Surface Objects : Common and Multiple Surface Objects */

    param_type[parent_index] = EMSgrid;
    parent_index++;

    if(num_mult_tks)
       {
        sfs_index = 0;
        for (i=0; i< num_mult_tks; i++)
         {
          for(j=sfs_index; j<sfs_index+num_sfs[i]; j++)
           {
            param_type[parent_index+j] = EMSgrid;
           }
          sfs_index    += num_sfs[i];
         }
        parent_index += sfs_index; /* 'sfs_index' has count of no. of surfs.
                                      It is used later in tha code */
       } /* End of -  if(num_mult_tks) */
  } /* End of if(post_220).. */

  /* Open Surface Objects  */ 
  for (i=parent_index; i<num_parents-1; i++)
  {
    param_type[i] = EMSgrid;
  }

  num_opensfs = num_parents-parent_index-1;

  solid_inx = num_parents-1;
  param_type[solid_inx] = EMSgrid;
  parent_index++;

  param = (union EMSparent_info *) alloca (num_parents *
           sizeof (union EMSparent_info));
  EMerr_hndlr (!param, *msg, EMS_E_NoStackMemory, ret_end);

  stat_OM = om$send (msg = message EMSassoc.EMget_parent_info (&msg_loc,
              NULL, num_parents, parent_info, param_type, param),
              targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  parent_index = 0;

  common_thickness = param[parent_index].value;

  parent_index++;

  if(post_220)
  {
    if(num_mult_tks)
       {
        /* Get Thickness Values */
        vals_mult_thickness = (IGRdouble *) alloca(num_mult_tks *
                                              sizeof(IGRint));
        EMerr_hndlr (!vals_mult_thickness, *msg, EMS_E_NoStackMemory, ret_end);
    
        for (i=0, j=parent_index; i< num_mult_tks; i++, j++)
          {
           vals_mult_thickness[i] = param[j].value;
          }
        parent_index += num_mult_tks;
       } /* End of -  if(num_mult_tks) */

    /* Get Surface Objids */
     
    parent_index++;  /* Skip the common thickness surface id */

    if(num_mult_tks)
       {
        mult_thickness_sf_list = (GRobjid *) alloca(sfs_index *
                                               sizeof(GRobjid));
        EMerr_hndlr (!mult_thickness_sf_list, *msg,
                                       EMS_E_NoStackMemory, ret_end);

        for (i=0, j=parent_index; i< sfs_index; i++, j++)
         {
          mult_thickness_sf_list[i] = param[j].grobj.grid.objid;
         }
        parent_index += sfs_index;
       } /* End of -  if(num_mult_tks) */
  } /* End of -  if(post_220)  */

 /* Get Open Surface Objids */
  opensfs = NULL;
  if (num_opensfs)
    {
    opensfs = (GRobjid *) alloca (num_opensfs * sizeof (GRobjid));
    EMerr_hndlr (!opensfs, *msg, EMS_E_NoStackMemory, ret_end);

    for (i=parent_index, j=0; i<num_parents-1; i++, j++)
      opensfs[j] = param[i].grobj.grid.objid;
    }

  md_env = const_list->env_info;
  ex$message(msgnumb = EMS_I_Processing, buff = status_str);
  bool_opts = EMSsfbool_opt_display | EMSsfbool_opt_retryDisjoint;

  recompute = options & EMSasconst_recompute;
  if (recompute)
    {
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, curr_cht);
    BSchangepar (&msg_loc, BSTOLCHRDHT, ME.EMSsfboolean->cht);

    display_count = 0;
    EFsend_to_param (&msg_loc, message EMSdprparam.EMget_display_ids (&msg_loc,
     &display_count, &display_ids, NULL), my_id, OM_Gw_current_OS,
     &tmp_param, NULL); 
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    update_display_ids = TRUE;

   /*  TBD - Get rid of 'orient-yourself' and merge the two disconnections. */

    if(!inward && !is_symmetric)
    {
     stat_OM = om$send(msg = message EMSsolid.EMorient_yourself
                                        (&msg_loc, NULL, md_env),
                             targetid = param[solid_inx].grobj.grid.objid);
     if (!(1 & stat_OM & msg_loc)) goto ret_end;

     /* Disconnect the solid if it is  outward offset. The solid will be
	connected at proper index  in the boolean operation - Sampath 1/sep/93
     */
     ownerGRid.objid = my_id;
     ownerGRid.osnum = OM_Gw_current_OS;
     stat_OM = om$send (
            msg = message GRconnector.GRdisconn (
                  &msg_loc,
                  &ownerGRid),
                  targetid = param[solid_inx].grobj.grid.objid,
                  targetos = param[solid_inx].grobj.grid.osnum
                  );
      if (!(1 & stat_OM & msg_loc)) goto ret_end;
    }

    /* Disconnect the orginal solid from thin-wall object */

    if(is_symmetric)
    {
     ownerGRid.objid = my_id;
     ownerGRid.osnum = OM_Gw_current_OS;
     stat_OM = om$send (
            msg = message GRconnector.GRdisconn (
                  &msg_loc,
                  &ownerGRid),
                  targetid = param[solid_inx].grobj.grid.objid,
                  targetos = param[solid_inx].grobj.grid.osnum
                  );
      if (!(1 & stat_OM & msg_loc)) goto ret_end;
    }
    bool_opts |= EMSsfbool_opt_noredraw;
    }
  else
    bool_opts |= EMSsfbool_opt_HandleStop;

 /* Set up the common thickness values */
  inthick = outthick = 0.0;

  if(inward)
      inthick = common_thickness;
  else
      outthick = common_thickness;

  if(is_symmetric)
    {
      inthick = common_thickness/2.0;
      outthick = common_thickness/2.0;
    }

  stat_OM = om$send (msg = message EMSshslbool.EMshellsolid (&msg_loc,
      bool_opts, &md_env->md_env.matrix_type, md_env->md_env.matrix,
      const_list, param[solid_inx].grobj.grid.objid,
      inthick, outthick, num_mult_tks, vals_mult_thickness,
      num_sfs, mult_thickness_sf_list,  
      num_opensfs, opensfs, status_str,
      recompute ? &display_count : NULL,
      recompute ? &display_ids : NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if(is_symmetric)
  {
        IGRboolean  action = FALSE;
        IGRushort mask = EMSIS_ACTIVE_STATE;
        EMput_in_the_ssi_table(is_symmetric,
                               param[solid_inx].grobj.grid.objid,
                               param[solid_inx].grobj.grid.osnum,
                               md_env, &my_id);

     /* Connect the orginal solid to the thin-wall object. This makes
        thin-wall recomputable for symmetric offset. */

     ownerGRid.objid = my_id;
     ownerGRid.osnum = OM_Gw_current_OS;
     stat_OM = om$send(msg = message GRconnector.GRrigidconn(&msg_loc,
                              &ownerGRid, &owner_index),
                              targetid = param[solid_inx].grobj.grid.objid);
      if (!(1 & stat_OM & msg_loc)) goto ret_end;
     /* Set the dpr_props bit of the original solid inactive 
        if it is in DPR tree- Jagan */

      if( EFisAncestryValid(&msg_loc,
                            param[solid_inx].grobj.grid.objid, 
                            param[solid_inx].grobj.grid.osnum, 
                            OPP_EMSdpr_class_id,FALSE))
      {

          stat_OM = om$send(msg = message EMSdpr.EMsetprops(msg, &action,
                            &mask),
                            targetid = param[solid_inx].grobj.grid.objid,
                            targetos = param[solid_inx].grobj.grid.osnum
                             );
          if(!(1 & stat_OM & msg_loc)) goto ret_end;
		
      }
    }

  if (recompute)
    {
    BSchangepar (&msg_loc, BSTOLCHRDHT, curr_cht);

    om$send (msg = message EMSdprparam.EMput_display_ids (&msg_loc,
     display_count, display_ids, NULL), targetid = tmp_param);
    display_ids = NULL;
    update_display_ids = FALSE;
    }

ret_end:

  /* post the display_ids to the EMSdprparam object if necessary */

  if (update_display_ids)
  {
    om$send (msg = message EMSdprparam.EMput_display_ids (&msg_loc,
     display_count, display_ids, NULL), targetid = tmp_param);
  }

  EMWRAPUP (*msg, stat_OM, "EMshslbool.EMconstruct_assoc");
  return (stat_OM);
}

static struct EMSintobj *EFtrim_against_ed(msg, sf_grid, against_edge, tol,
			      trim_geom, env_info, inters, ls_bdrys, num_cvs)
IGRlong			*msg;
struct GRid		sf_grid, against_edge;
IGRdouble		tol;
struct IGRbsp_curve	*trim_geom;
struct GRmdenv_info	*env_info;
struct EMSinters	**inters;
struct EMSsfintedpar	***ls_bdrys;
IGRint			*num_cvs;
{
  IGRlong		msg_loc;
  BSrc			rc;
  IGRint		num_ret;
  IGRshort		k, n;
  IGRboolean		trim[2], stat_func;
  IGRdouble		*pole_ptr, cv_start_pt[3], cv_stop_pt[3],
			ed_start_pt[3], ed_stop_pt[3], *pars=NULL, dist,
			*intpars=NULL, par1, par2;
  struct IGRbsp_curve	*edge_geom=NULL, *p_curve=NULL;
  struct EMSsfintedpar	**p_bdrys=NULL;
  struct EMSintobj	*p_intobj=NULL, *tmp_intobj=NULL;

  extern void                EFcvt_edge_to_cv();
  extern struct EMSintobj    *EFext_and_prj_cv();

		*msg = EMS_S_Success;
		msg_loc = EMS_S_Success;
		trim[0] = trim[1] = FALSE;
		par1 = par2 = 0.0; /* inhibit spurious compilation warning */
		*num_cvs = 0;
		/* Get the end points of the incoming curve  geometry */
		pole_ptr = trim_geom->poles;
		OM_BLOCK_MOVE(pole_ptr, cv_start_pt, 3 * sizeof(IGRdouble));
		OM_BLOCK_MOVE(&pole_ptr[(trim_geom->num_poles - 1) * 3],
			      cv_stop_pt, 3 * sizeof(IGRdouble));
               /* Unweight the end-points if the curve is rational */
                if(trim_geom->rational)
                    for(k=0; k<3; k++)
                    {
                       cv_start_pt[k] /= trim_geom->weights[0];
                       cv_stop_pt[k]  /= 
                          trim_geom->weights[trim_geom->num_poles-1];
                    }
		EFcvt_edge_to_cv(&msg_loc, (IGRushort)0, against_edge, &sf_grid,
				 &edge_geom, env_info);
	        EMerr_hndlr(EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

		/* Get the minimum distance of cv_start_pt from edge_geom */
		BSmdistptcv(edge_geom, cv_start_pt, &k, &n, &pars, &dist,
			    &intpars, &rc);
		EMerr_hndlr((rc!=BSSUCC), *msg, EMS_E_BSerror, ret_end);
		if(pars) om$dealloc(ptr = pars); pars = NULL;
		if(intpars) om$dealloc(ptr = intpars); intpars = NULL;
		if(dist > tol) trim[START] = TRUE;

		/* Get the minimum distance of cv_stop_pt from edge_geom */
		BSmdistptcv(edge_geom, cv_stop_pt, &k, &n, &pars, &dist,
			    &intpars, &rc);
		EMerr_hndlr((rc!=BSSUCC), *msg, EMS_E_BSerror, ret_end);
		if(pars) om$dealloc(ptr = pars); pars = NULL;
		if(intpars) om$dealloc(ptr = intpars); intpars = NULL;
		if(dist > tol) trim[STOP] = TRUE;

		if(!trim[START] && !trim[STOP]) goto ret_end;

		/* Get the end points of the edge geometry */
		pole_ptr = edge_geom->poles;
		OM_BLOCK_MOVE(pole_ptr, ed_start_pt, 3 * sizeof(IGRdouble));
		OM_BLOCK_MOVE(&pole_ptr[(edge_geom->num_poles - 1) * 3],
			      ed_stop_pt, 3 * sizeof(IGRdouble));
                /* Unweight the end-points if the curve is rational */
                if(edge_geom->rational)
                    for(k=0; k<3; k++)
                    {
                       ed_start_pt[k] /= edge_geom->weights[0];
                       ed_stop_pt[k]  /= 
                          edge_geom->weights[edge_geom->num_poles-1];
                    }
		if(trim[0])
		{
		/* Project ed_start_pt onto the incoming curve to be trimmed */
		  BSmdistptcv(trim_geom, ed_start_pt, &k, &n, &pars, &dist,
			      &intpars, &rc);
		  EMerr_hndlr((rc!=BSSUCC || n==0), *msg, EMS_E_BSerror,
			      ret_end);
		  par1 = pars[0];
		  if(pars) om$dealloc(ptr = pars); pars = NULL;
		  if(intpars) om$dealloc(ptr = intpars); intpars = NULL;
		}
		if(trim[1])
		{
		/* Project ed_stop_pt onto trim_geom */
		  BSmdistptcv(trim_geom, ed_stop_pt, &k, &n, &pars, &dist,
			      &intpars, &rc);
		  EMerr_hndlr((rc!=BSSUCC || n==0), *msg, EMS_E_BSerror,
			       ret_end);
		  par2 = pars[0];
		  if(pars) om$dealloc(ptr = pars); pars = NULL;
		  if(intpars) om$dealloc(ptr = intpars); intpars = NULL;
		}
		*ls_bdrys = (struct EMSsfintedpar **) om$malloc(size =
			     2 * sizeof(struct EMSsfintedpar *));
		for(k=START; k<=STOP; k++)
		{
		   if(!trim[k]) continue;
		   p_curve = NULL;
		   BSalloccv(trim_geom->order,
			     (trim_geom->num_poles)+2*((trim_geom->order)-1),
			     trim_geom->rational, 0 , &p_curve, &rc);
		   EMerr_hndlr((rc!=BSSUCC), *msg, EMS_E_BSerror, ret_end);
		   stat_func = BSpartofcv(&rc, trim_geom, k==START ? 0.0:par2,
					  0.0, k==START ? par1:1.0, p_curve);
		   EMerr_hndlr((rc!=BSSUCC), *msg, EMS_E_BSerror, ret_end);
		   tmp_intobj = NULL;
		   num_ret = 0;
		   tmp_intobj = EFext_and_prj_cv(&msg_loc, sf_grid, sf_grid,
			        NULL, NULL, p_curve, FALSE, 0.0, 0.0,
			        env_info, inters, FALSE, &p_bdrys, &num_ret);
		   stat_func = BSfreecv(&rc, p_curve);
		   if(num_ret == 0) continue;
	           EMerr_hndlr((EMSerror(msg_loc) || num_ret != 1),
				*msg, EMS_E_Fail, ret_end);
		   if(p_intobj)
		   {
			p_intobj->next = tmp_intobj;
			(*ls_bdrys)[1] = p_bdrys[0];
		   }
		   else
		   {
			p_intobj = tmp_intobj;
			(*ls_bdrys)[0] = p_bdrys[0];
		   }
		   (*num_cvs)++;
		   if(p_bdrys) om$dealloc(ptr = p_bdrys);
		   p_bdrys = NULL;

		} /* for(k=START; k<=STOP; k++) */
ret_end:
		if(edge_geom)
		{
		  om$dealloc(ptr = edge_geom->poles);
		  om$dealloc(ptr = edge_geom->knots);
		  if(edge_geom->rational)
			om$dealloc(ptr = edge_geom->weights);
		  om$dealloc(ptr = edge_geom);
		}
		if(p_bdrys) om$dealloc(ptr = p_bdrys);
		if(!(*num_cvs) && *ls_bdrys)
		   om$dealloc(ptr = *ls_bdrys);
		return(p_intobj);
}
end implementation EMSshslbool;

