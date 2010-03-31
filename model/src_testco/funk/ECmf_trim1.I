class implementation EMSsubbs;

#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "emssfintdef.h"
#include "ECmsg.h"
#include "emserr.h"
#include "ECmfdef.h"
#include "ECmf.h"
#include "ECmfopt.h"
#include "ECmferr.h"

#include "bssfkttol2.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"

#define START  0
#define STOP   1

#define EQUAL_TOL 0.000001
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }

extern double fabs();
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from EMSedge import EMinternalpt, EMget_bcxyz_geom;


/*

   EMmarfiltrim()

 * DESCRIPTION
       
    This function takes a fillet and generates EMSinters list by interesecting 
    it against a set of surfaces.  The intersection curve is oriented in this
    function so that the fillet can be optionally trimmed by imposing boundary.
    

 * Inputs

    options		
                        - BDRY_IMPOSED (ECmfdef.h)
                          trim the fillet by imposing boundary

    fillet              - GRid of fillet to be trimmed
    num_surfs           - num of surfaces to be trimmed against
    elems               - array of GRlc_info for surfaces
    
 * Outputs

    msg			- Return codes
			  EMS_S_Success
				
    fil_inters          - EMS inters list (optional pass NULL if not required)
    fillet              - trimmed fillet (trimming optional: see options above)

    NOTE:  it doesn't make ANY sense to call this function if you make both 
           optional.

 * Algorithm

   Intersect fillet with each surface and generate inters list.
   If trimming against only 1 surface, we don't get sfintedpar from intersect-
   surfaces.  In that case, use parttrim message to get sfintedpar info.

   Trace the inters list and remove multiple intersections if any.  This is
   to make sure we have only 1 uniform group of curves.  Unwanted intersections
   are decided based on the 'V' end other than the marching end of fillet.  The 
   marching 'V' end is same as function parameter need_u_incr.

   If logical start or stop is not on actual edge, error out.  This may change
   in future.

   Orient the curve based on whether the curve parametrization is increasing
   from logical start to stop and if we want it incrasing (need_u_incr) or
   decreasing (!need_u_incr).

   call EMimpose_boundary_w_intersection() to impose the intersection curve
   on the fillet.  (this function will trace the curve and do boolean).


 * HISTORY

    pac   : 01/13/93 : creation.
    pac   : 01/27/93 : for a single trim surface, use natural surface.
                       make sure we check validity of edges in more_info.
    pac   : 02/05/93 : don't need PUSH_BADCOINC in trim_opts
    pac   : 02/17/93 : weed out unwanted intersections
    pac   : 07/11/93 : impose portion moved within loop for EMspflimpose
                       (takes care of really flat spheres)

    NP    : 05/27/93 : Funtction "EMmkintlist" is now called by a new
                        name, "EMmakeintlist", due to addition of two
                        new curve type parameters.
                        NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN
                              THE CALL (CURRENTLY SET TO NULL).
    Sudha  :07/02/93  : Modified for BSprototypes ansification
    Aditya :07/17/95  : Fix for TR#119418334. Intel abort because edge_geom
                        declared on stack was being freed along with inters
                        list. Now mallocing it.

*/

IGRlong EMmarfiltrim( msg, options, active_md_env, hot_v,
                      num_surfs, elems, fillet, fil_inters )

IGRlong				*msg;            /* o return code */      
IGRushort			options;         /* i see above */
struct GRmd_env                 *active_md_env;  /* i */
IGRdouble                       *hot_v;          /* i */
IGRint                          num_surfs;       /* i num of trim surfaces */
struct GRlc_info                *elems;          /* i array for trim surfaces */
struct GRid		        *fillet;         /* i/o fillet to be trimmed */
struct EMSinters                **fil_inters;    /* o EMSinters list */

{
  IGRlong			ret0, msg_loc, stat, num_inters=0, ms_loc;
  IGRushort                     world_opts, param_opts, trim_opts, trace_opts;
  IGRushort                     bool_opts;
  IGRint                        ii, is_curve_param_incr;
  IGRdouble                     vvv, logical_start, logical_stop;
  struct EMSdataselect          trim_surf;
  struct EMSintobj              *temp_ptr;
  struct EMSsfintedpar          *more_info;
  struct EMSsftracedata         sftrace;
  struct EMSinters              *fillet_inters=0;
  struct EMSsfintedpar          *bdry_parms=0;
  IGRint                        num;
  GRobjid                       logical_start_edge, logical_stop_edge;
  struct IGRbsp_surface         *fill_surf=0;
  struct EMSintobj              *tmp_intobj=0, **keep_intobjs=0;
  IGRint                        num_intobjs_to_keep; 
  IGRboolean                    delete_it, are_identical;
  IGRpoint                      ref_pt;
  IGRboolean                    need_u_incr; 

  IGRdouble                  p_range[4];
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;

  IGRboolean save_pathway_trim, save_pathway_orient;

  extern void EMsfintedpar_free();
  sftrace.num_grps = 0;
  sftrace.num_subgrps_grp = NULL;
  sftrace.num_elems_subgrp = NULL;
  sftrace.elems = NULL;
  sftrace.subgrp_rev = NULL;
  sftrace.elem_rev = NULL;
  sftrace.grp_closed = NULL;
  sftrace.subgrp_closed = NULL;

  /* 
   * data check 
   */

  EMerr_hndlr( !( fillet && elems && num_surfs && hot_v ), 
                  msg_loc, EMS_E_InvalidData, ret_end );

ret0 = EMbef_filterm( msg, 0, active_md_env, fillet, hot_v );
EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
  
  ret0 = EMis_natsf(msg, fillet, p_range, &num_mineds, &mineds,
                    &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
  MEM_FREE(mineds); MEM_FREE(maxeds);
  EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  if( fabs(*hot_v - min_bnd_hot_v) < EQUAL_TOL )
    need_u_incr = 0;
  else
    need_u_incr = 1;


  /*
   *  get fillet surface
   */

  ret0 = EMgetvggeom ( msg,
                       &active_md_env->md_env.matrix_type,
                       active_md_env->md_env.matrix,
                       fillet, &fill_surf, 0 );
  EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);


  /*
   * generate inters list
   */

  world_opts = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
  param_opts = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT;

  if(num_surfs == 1)
    trim_opts = 0;
  else
    trim_opts =  EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA;

  num_inters = 0;
  
  for(ii=0; ii<num_surfs; ii++)
    {
    trim_surf.datatype = EMSdata_object;
    trim_surf.data.object = &elems[ii].located_obj;
/*
    ret0 = EMintersect_surfaces (&msg_loc,
                                 fillet, &active_md_env->md_env,
                                 1, &trim_surf, &active_md_env->md_env,
                                 0, world_opts, param_opts, trim_opts,
                                 0, &num_inters, &fillet_inters, 
                                 0, 0, 0, 0, 0, 0);
*/

    save_pathway_trim = _pathway_trim;
    save_pathway_orient = _pathway_orient;
    _pathway_trim = 0;
    _pathway_orient = 0;

    ret0 = om$send( msg = message EMSsurface.EMsfsfint( &msg_loc,
                    &active_md_env->md_env.matrix_type,
                    active_md_env->md_env.matrix, 0,
                    &trim_surf, &active_md_env->md_env,
                    world_opts, param_opts, trim_opts,
                    &num_inters, &fillet_inters, 0 ),
                    senderid = NULL_OBJID,
                    targetid = fillet->objid,
                    targetos = fillet->osnum );

    _pathway_trim = save_pathway_trim;
    _pathway_orient = save_pathway_orient;


    EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);
    }

#ifdef DEBUG
  if(0)
    prtinters(fillet_inters);
#endif

  if(!fillet_inters)
    EMerr_hndlr (1, ret0, OM_E_ABORT, ret_end);
    
#if 0
  /*
   * trace the inters list to make sure we have one group
   */

  trace_opts = EMS_SFINT_MUSTORIENT |
               EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
               EMS_SFINT_CHTTRACETOL;

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  ret0 = EMintersect_surfaces (&msg_loc, NULL, &active_md_env->md_env,
                0, NULL, NULL, trace_opts, NULL, NULL, NULL, NULL, NULL,
                &fillet_inters, NULL, &sftrace, NULL, NULL, NULL, NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  EMerr_hndlr (EMSerror (ret0 & msg_loc), msg_loc, EMS_E_Fail, ret_end);

  if(sftrace.num_grps != 1)
    EMerr_hndlr (1, ret0, OM_E_ABORT, ret_end);
#endif

  /*
   * WE will have to set sfintedpar info if !trim_opts
   */

  if(!trim_opts)
    for(temp_ptr=fillet_inters->cvs; temp_ptr != NULL; temp_ptr=temp_ptr->next)
      {
      ret0 = om$send( msg = message EMSsubbs.EMparttrim( &msg_loc,
                          &active_md_env->md_env.matrix_type,
                          &active_md_env->md_env.matrix[0],
                          &temp_ptr->this_uvintobj,
                          NULL, &num, NULL,
                          &bdry_parms ),
                          senderid = NULL_OBJID,
                          targetid = fillet->objid,
                          targetos = fillet->osnum );
      EMerr_hndlr( num!=1 || EMSerror( msg_loc & ret0 ), msg_loc, EMS_E_Fail, 
                   ret_end );
      temp_ptr->more_info = (char *) bdry_parms;
      }

  /*
   * weed out multiple intersections based on ref pt
   * ref pt is generated for other end of hot_v edge
   */

  vvv = (IGRdouble) (need_u_incr^1);

  BSsfeval(fill_surf, 0.5, vvv, 0, (IGRpoint *)ref_pt, &stat);
  EMerr_hndlr (stat != BSSUCC, *msg, EMS_E_BSerror, ret_end);

#ifdef DEBUG
fprintf(stderr, "ref_pt %4.6f, %4.6f %4.6f\n", ref_pt[0], ref_pt[1], ref_pt[2]);
fflush(stderr);
#endif

  ret0 = EMweed_out_inters(msg, 0, active_md_env, ref_pt, fillet_inters,
                           &num_intobjs_to_keep, &keep_intobjs, &are_identical);
  EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  if(!are_identical)
    /* Remove the extraneous intersections from the inters lists. */
    for( tmp_intobj = fillet_inters->cvs; tmp_intobj != NULL;
         tmp_intobj = tmp_intobj->next )

      {
      delete_it = 1;
      for(ii=0; ii<num_intobjs_to_keep; ii++)
        if( tmp_intobj == keep_intobjs[ii] )
          {
          delete_it = 0;
          break;
          }
      if(delete_it)
        {
        /* Delete this intobj and its counter part, and make
         * necessary changes to the corresponding EMSinters
         * nodes.
         */
        EMdelintobj( msg, tmp_intobj );
        EMerr_hndlr( !( 1 & *msg ), ret0, OM_E_ABORT, ret_end);
        }
      } /* for fillet_inters->cvs */

  /*
   * if logical start & logical stop are not on valid edges, error out
   * are we going to change this in future giving option to extend the curve
   * to desired/nearest edges?
   */

  temp_ptr  = fillet_inters->cvs;
  more_info = (struct EMSsfintedpar *) temp_ptr->more_info;
  if(!more_info) 
    EMerr_hndlr (1, msg_loc, EMS_E_Fail, ret_end);
  logical_start_edge = temp_ptr->reversed ? more_info->next->edgeid :
                                            more_info->edgeid;

  if( (logical_start_edge == NULL_OBJID) )
    EMerr_hndlr (1, msg_loc, EMS_E_Fail, ret_end);

  while (temp_ptr->next != NULL)
    temp_ptr = temp_ptr->next;

  more_info = (struct EMSsfintedpar *) temp_ptr->more_info;
  if(!more_info) 
    EMerr_hndlr (1, msg_loc, EMS_E_Fail, ret_end);
  logical_stop_edge = temp_ptr->reversed ? more_info->edgeid :
                                           more_info->next->edgeid;

  if( (logical_stop_edge == NULL_OBJID) )
    EMerr_hndlr (1, msg_loc, EMS_E_Fail, ret_end);


  /*
   *  orient curve:  if logical start has higher U parameter than logical stop,
   *  and if need_u_incr, toggle reveresed flag ( the curve orienation) 
   *  and vice versa.
   */

  temp_ptr  = fillet_inters->cvs;
  more_info = (struct EMSsfintedpar *) temp_ptr->more_info;
  logical_start = temp_ptr->reversed ? more_info->next->point[0] : 
                                       more_info->point[0];

  while (temp_ptr->next != NULL)
    temp_ptr = temp_ptr->next;

  temp_ptr  = fillet_inters->cvs;
  more_info = (struct EMSsfintedpar *) temp_ptr->more_info;
  logical_stop  = temp_ptr->reversed ? more_info->point[0] : 
                                       more_info->next->point[0];

#ifdef DEBUG
fprintf(stderr, "start %4.4f stop %4.4f\n", logical_start, logical_stop);
#endif

  is_curve_param_incr = logical_start < logical_stop ? 1:0;
  

  if( ( need_u_incr && (!is_curve_param_incr)) ||
      (!need_u_incr &&   is_curve_param_incr) )
    {
    temp_ptr = fillet_inters->cvs;
    do{
      temp_ptr->reversed = temp_ptr->reversed ^ 1;
      temp_ptr = temp_ptr->next;
      } while(temp_ptr != 0);
    }


  if(! (options & BDRY_IMPOSED) )
    goto ret_end;


  /*
   *  do boolean
   */

  trace_opts = EMS_SFINT_MUSTORIENT |
               EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
               EMS_SFINT_CHTTRACETOL;

  bool_opts = EMSsfbool_opt_SingleTopology | EMSsfbool_opt_noredraw;

  dp$display( msg = &stat, oids = fillet, mode = GRbe );

  ret0 = EMimpose_boundary_w_intersection(&msg_loc, trace_opts, bool_opts,
                                          active_md_env,
                                          fillet->objid,
                                          fillet_inters, NULL_OBJID,
                                          NULL, NULL);

  dp$display( msg = &ret0, oids = fillet, mode = GRbd );

  EMerr_hndlr (EMSerror (ret0 & msg_loc), ret0, OM_E_ABORT, ret_end);

ret_end:

  /* fix for mlk */
  EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
     sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
     sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);
 
  if(keep_intobjs)
    {
    om$dealloc(ptr = keep_intobjs);
    keep_intobjs = NULL;
    }
  if(fill_surf)
    {
 /* fix for mlk */
    om$dealloc(ptr = fill_surf);
    fill_surf = NULL;
    }
  if(fil_inters)
    *fil_inters = fillet_inters;
  else
    {
/* fix for mlk */
    EMinters_data_free (&ms_loc, fillet_inters,MAXINT,NULL,EMsfintedpar_free);
  
    EMinters_free (fillet_inters, 0);
    }

  *msg = msg_loc;
  EMWRAPUP (*msg, ret0, "EMmarfiltrim");
  return ret0;

}
/* EMmarfiltrim */



/*

   EMspflimpose() 

 * DESCRIPTION
       
    This function finds 'intersection' between a fillet and a corner spherical
    patch and imposes it on the fillet.


 * INPUTS

    options		- future
    active_md_env       - usual env info
    sph_info->objs      - GRid of spherical patch
    sph_info->objs_surf - IGRbsp_surface of the patch (optional, pass NULL)
    fil_info->objs      - GRid of intersecting fillet
    fil_info->objs_surf - IGRbsp_surface of the fillet (optional, pass NULL)
    fil_info->hot_edge  - v value of the edge which will be removed
    toggle_v_edge        - toggle the above v value
                          1: when current ele is fillet & prev is a sph. patch
                          0: when current ele is sph. patch & prev is a fillet
                 
    
    NOTE: rest of the fields in these structures can be NULL/have dummy values.

 * OUTPUTS

    msg			- Return codes
			  EMS_S_Success or appropriate EMS error code
				
   fil_info->objs       - fillet is modified (boundary imposed)


 * ALGORITHM

   Corner sphrical patch has 3 edges.  Find min dist from midpt of each edge 
   to the fillet.  If dist < cht tol, impose this edge (of sph. patch) on the 
   fillet.  To impose: extract edge geometry, build cv - fillet surface inters
   list, orient the curve, and impose the curve by boolean operation.

   logic behind orientation:
   v value of filet edge which is reomved is used as input.  if v==1, then
   the curve to be imposed should be parameterized in increasing_u dir, else
   (i.e. if v==0) the curve should be parameterized in decreasing_u dir.


 * HISTORY

    pac   : 01/13/93 : creation.
    pac   : 02/05/93 : don't need PUSH_BADCOINC in trim_opts
*/

IGRlong EMspflimpose( msg, options, active_md_env, 
                      sph_info, fil_info, toggle_v_edge)

IGRlong				*msg;            /* o return code */      
IGRushort			options;         /* i see above */
struct GRmd_env                 *active_md_env;  /* i */
struct ele_stack                *sph_info;       /* i sph_patch stack info */
struct ele_stack                *fil_info;       /* i fillet stack info */
IGRboolean                      toggle_v_edge;   /* i see above */

{
  IGRint ii, ll, intersect=0, array_size=0, num_edges=0, ret0=OM_S_SUCCESS;
  IGRdouble pt_on_edge[2], chttol, to_u, to_v, min_dist;
  IGRpoint from_pt, to_pt;
  struct EMSpartolbasis pt_edge_tol;
  struct GRid *fillet=0, *sph_patch=0, *edges=0;
  IGRint we_need_increasing_u, free_l_sph_surf=0, free_l_fill_surf=0;
  struct IGRbsp_surface *l_sph_surf, *l_fill_surf;
  struct EMSinters *inters=0;
  struct IGRbsp_curve *edge_geom;
  IGRboolean is_u_increasing;
  struct EMSintobj *temp_ptr;
  IGRushort trace_opts, bool_opts;
  IGRlong EMcvsfinters();

  IGRdouble                  p_range[4];
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;

  options = options;

  /* 
   * data check 
   */

  MF_EMerr_hndlr( !( sph_info && fil_info ), 
                  *msg, EMS_E_InvalidData, ret_end );

  /*
   *  init local pointers
   */

  sph_patch = &sph_info->ele_grid;
  fillet    = &fil_info->ele_grid;

    edge_geom = (struct IGRbsp_curve *)om$malloc(size=sizeof(struct IGRbsp_curve));
  edge_geom->poles = NULL;
  edge_geom->knots = NULL;
  edge_geom->weights = NULL;

  p_range[0] = 0;
  p_range[1] = 1;
  p_range[2] = 0;
  p_range[3] = 1;
  ret0 = EMis_natsf(msg, fillet, p_range, &num_mineds, &mineds,
                    &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  if( fabs(fil_info->hot_edge - min_bnd_hot_v) < EQUAL_TOL )
    we_need_increasing_u = toggle_v_edge ? 1 : 0; 
  else
    we_need_increasing_u = toggle_v_edge ? 0 : 1; 


  /*
   * if surface geometry is not passed in, get it
   */

  if(sph_info->objs_surf)
    l_sph_surf = sph_info->objs_surf;
  else
    {
    free_l_sph_surf = 1;
    ret0 = EMgetvggeom ( msg,
                         &active_md_env->md_env.matrix_type,
                         active_md_env->md_env.matrix,
                         sph_patch, &l_sph_surf, 0 );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
    }

  if(fil_info->objs_surf)
    l_fill_surf = fil_info->objs_surf;
  else
    {
    free_l_fill_surf = 1;
    ret0 = EMgetvggeom ( msg,
                         &active_md_env->md_env.matrix_type,
                         active_md_env->md_env.matrix,
                         fillet, &l_fill_surf, 0 );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
    }


  /*
   * get edges of sperical patch
   */

  ret0= om$send(msg = message EMSsubbs.EMget_edges(msg, MAXINT,
                EMS_OPT_NON_DEG_SEAM_XYZCLSD, active_md_env, &edges,
                &array_size, &num_edges),
                senderid = NULL_OBJID,
                targetid = sph_patch->objid,
                targetos = sph_patch->osnum);
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  BSEXTRACTPAR (msg, BSTOLLENVEC, pt_edge_tol.tol);
  MF_EMerr_hndlr (*msg != BSSUCC, ret0, OM_E_ABORT, ret_end);
  *msg = EMS_S_Success;

  pt_edge_tol.is_valid = TRUE;

  BSEXTRACTPAR (msg, BSTOLCHRDHT, chttol);
  MF_EMerr_hndlr (*msg != BSSUCC, ret0, OM_E_ABORT, ret_end);
  *msg = EMS_S_Success;

  intersect = 0;
  for(ii=0; ii<num_edges; ii++)
    {

    /*
     * get midpt of each edge
     */

    ret0 = om$send (msg = message EMSedge.EMinternalpt (msg,
                    1, 0, pt_on_edge, NULL, &pt_edge_tol),
                    senderid = NULL_OBJID,
                    targetid = edges[ii].objid,
                    targetos = edges[ii].osnum);
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

    /*
     * get mindist of this pt from fillet
     */

    if(fabs(pt_on_edge[1] - 0.0) < EQUAL_TOL)
      pt_on_edge[1] = 0.0;
    if(fabs(pt_on_edge[0] - 0.0) < EQUAL_TOL)
      pt_on_edge[0] = 0.0;

    BSsfeval(l_sph_surf, pt_on_edge[0], pt_on_edge[1], 0, (IGRpoint *)from_pt, msg);
    MF_EMerr_hndlr (*msg != BSSUCC, ret0, OM_E_ABORT, ret_end);
    *msg = EMS_S_Success;

    BSmdistptsf(msg, l_fill_surf, from_pt, &to_u, &to_v, to_pt, &min_dist);
    MF_EMerr_hndlr (*msg != BSSUCC, ret0, OM_E_ABORT, ret_end);
    *msg = EMS_S_Success;

    /*
     * if mindist is within chttol, we impose this edge on fillet
     */

    if( min_dist <= chttol)
      intersect = 1;
    else
      continue;

  /*
   *  impose edges[ii] on fillet
   */

  if(inters)
    EMinters_free (inters, 0);
  inters = 0;

  /*
   * Extract the edge geometry.  In the following call, specification of
   * FALSE ensuares that the orientation of the xyz geometry would
   * correspond to the logical orientation of the edge.
   */

  ret0 = om$send( msg = message EMSedge.EMget_bcxyz_geom(
                        msg,
                        &active_md_env->md_env,
                        sph_patch, l_sph_surf,
                        0, MAXINT, FALSE, NULL,
                        edge_geom ),
                        senderid = NULL_OBJID,
                        targetos = edges[ii].osnum,
                        targetid = edges[ii].objid);
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  /*
   * build inters list
   */

  ret0 = EMcvsfinters( msg, 0, active_md_env,
                       edge_geom, fillet, l_fill_surf, &inters,
                       &is_u_increasing );
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  if(!inters)
    {
#ifdef REALLY_DEBUG
    fprintf(stderr, "EMspflimpoe: NULL inters list from EMcvsfinters\n");
    fflush(stderr);
#endif
    goto ret_end;
    }

  /*
   * check orientation of curve to be imposed
   */

  if( ( we_need_increasing_u && (! is_u_increasing)) ||
      (!we_need_increasing_u && is_u_increasing) )
    {
    temp_ptr = inters->cvs;
    do{
      temp_ptr->reversed = temp_ptr->reversed ^ 1;
      temp_ptr = temp_ptr->next;
      } while(temp_ptr != 0);
    }

  /*
   * do boolean
   */

  trace_opts = EMS_SFINT_MUSTORIENT |
               EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
               EMS_SFINT_CHTTRACETOL;

  bool_opts = EMSsfbool_opt_SingleTopology | EMSsfbool_opt_noredraw;

  dp$display( msg = &ret0, oids = &fil_info->ele_grid, mode = GRbe );

  ret0 = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                          active_md_env,
                                          fillet->objid, inters, NULL_OBJID,
                                          NULL, NULL);
/*
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
*/

  if(! EMSerror (ret0 & *msg) )
    break;

    } /* for num_edges */

  if(!intersect)
    goto ret_end;

  for(ll=0; ll<3; ll++)
    if(sph_info->open_edges[ll].objid == edges[ii].objid)
       sph_info->open_edges[ll].objid =  NULL_OBJID;

  for(ll=0; ll<3; ll++)
    if(sph_info->marked_edges[ll] == -1)
      {
      sph_info->marked_edges[ll] = pt_on_edge[1];
      break;
      }
  sph_info->hot_edge = pt_on_edge[1];

ret_end:

  dp$display( msg = &ret0, oids = &fil_info->ele_grid, mode = GRbd );

  MEM_FREE(edges);
  if(free_l_fill_surf)
    MEM_FREE(l_fill_surf);
  if(free_l_sph_surf)
    MEM_FREE(l_sph_surf);

  if(inters)
    EMinters_free (inters, 0);

  EMWRAPUP (*msg, ret0, "EMspflimpose");
  return ret0;

} /* EMspflimpose */


/*

 * DESCRIPTION
       
    This function creates EMSinters list, given a surface and a curve to impose.

 * Inputs

    options		- 
    curve               - IGRbsp_curve to be imposed on surface
    sf_id               - GRid of surface to impose upon
    sf_geom             - IGRbsp_surface 
    
 * Outputs

    msg			- Return codes
				EMS_S_Success
				EMS_I_SurfaceError
    inters              - EMSinters list of curve-surface intersection
    u_increases         - 1, if startu < endu else 0

 * HISTORY

    nikesh: 12/31/92 : creation.
    pac     01/27/93   make sure edges in more_info are valid edges
    pac     02/05/93   let boolean handle validity of edges in more_info
                       just set *u_increases by looking at uvdata
    pac     02/18/93   WE should handle *HERE* validity of edges in more_info
                       try to get incident edges and set edge objids
*/


IGRlong EMcvsfinters( msg, options, active_md_env,
                     curve, sf_id, sf_geom, inters, u_increases )

IGRlong				*msg;                  
IGRushort			options;

struct GRmd_env                 *active_md_env;  /* i */
struct IGRbsp_curve		*curve;          /* i curve to impose */
struct GRid		        *sf_id;          /* i GRid of surface */
struct IGRbsp_surface		*sf_geom;        /* i surface geom */
struct EMSinters                **inters;        /* o */
IGRboolean                      *u_increases;    /* o optional, T if upar 
                                                      increases along curve */
{
  IGRlong			ii, stat, mloc;
  struct EMSdataselect          xyzdata, uvdata;
  IGRdouble                     cht, knot_tol, uvpt[2], dumpt[2];
  IGRboolean                    is_sf_planar=EMS_O_Unknown, onsurf, reversed;
  struct EMSsfintedpar          *tmp_ptr, *bdry_parms, *logical_parms;
  IGRint                        num;


  /*
   * Initialize 
   */

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  bdry_parms = NULL;

  /* data check */
  EMerr_hndlr( !( curve && sf_id && sf_geom && inters ), *msg, EMS_E_InvalidData, wrapup );

  BSEXTRACTPAR ( &mloc, BSTOLCHRDHT, cht );

  BSsfkttol2 ( sf_geom->u_order, sf_geom->v_order, sf_geom->u_knots, 
               sf_geom->v_knots, sf_geom->u_num_poles, sf_geom->v_num_poles, 
               sf_geom->poles, sf_geom->weights, &knot_tol, &mloc );
  EMerr_hndlr ( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

  xyzdata.datatype = EMSdata_curve3d;
  xyzdata.data.curve = curve;

  EMmapcvxyz_to_uv( &mloc, NULL, sf_geom, &xyzdata, cht, knot_tol, 
                    &is_sf_planar, &uvdata, &onsurf );
  EMerr_hndlr( EMSerror( mloc ), *msg, EMS_E_Fail, wrapup );

  stat = om$send( msg = message EMSsubbs.EMparttrim( &mloc,
                        &active_md_env->md_env.matrix_type, 
                        &active_md_env->md_env.matrix[0],
                        &uvdata,
                        NULL, &num, NULL,
                        &bdry_parms ),
                        senderid = NULL_OBJID,
                        targetid = sf_id->objid,
                        targetos = sf_id->osnum ); 
                        
  EMerr_hndlr( num!=1 || !( mloc & stat & 1 ), *msg, EMS_E_Fail, wrapup );

  for(tmp_ptr=bdry_parms; tmp_ptr!=NULL; tmp_ptr=tmp_ptr->next)
    {
    if( fabs(tmp_ptr->point[0] - 0.0) < EQUAL_TOL )
      tmp_ptr->point[0] = 0.0;
    if( fabs(tmp_ptr->point[1] - 0.0) < EQUAL_TOL )
      tmp_ptr->point[1] = 0.0;
    }

  EMmakeintlist( &mloc, inters, NULL, sf_id, NULL, NULL, NULL,
                 NULL, NULL, &xyzdata, &uvdata, NULL, 0, 0,
                 (struct EMsfintedpar *)bdry_parms, NULL,
                 NULL, NULL, NULL, NULL, TRUE, FALSE );
  EMerr_hndlr( !( mloc & 1 ), *msg, EMS_E_Fail, wrapup );

  if(!inters)
    {
#ifdef REALLY_DEBUG
    fprintf(stderr, "EMspflimpoe: NULL inters list from EMmkintlist\n");
    fflush(stderr);
#endif
    *msg = EMS_E_Fail;
    goto wrapup;
    }

#if 0
  if( (*inters)->cvs->this_uvintobj.datatype == EMSdata_poly2d )
    polyfile( (*inters)->cvs->this_uvintobj.data.poly->num_points,
              (*inters)->cvs->this_uvintobj.data.poly->points );
#endif

  /*
   * if logical start & logical stop are not on valid edges, error out
   * are we going to change this in future giving option to extend the curve
   * to desired/nearest edges?
   */

  reversed = (*inters)->cvs->reversed;
  for (ii=START; ii<=STOP; ii++)
    {
    if (ii == START)
      logical_parms = reversed ? bdry_parms->next : bdry_parms;
    else
      logical_parms = reversed ? bdry_parms : bdry_parms->next;

#ifdef REALLY_DEBUG
  fprintf(stderr, "%d) logical_edge %d\n", ii, logical_parms->edgeid);
#endif

    if( (logical_parms->edgeid == NULL_OBJID) &&
          (! (options & ECMF_NULL_OBJID_OK)) )
      {
      EMgetendpts_uv (msg, &uvdata, reversed, 1,
       ii == START ? uvpt : dumpt, ii == START ? dumpt : uvpt);
      EMerr_hndlr (!( *msg & 1), *msg, EMS_E_Fail, wrapup);

#if 0
if(ii == START)
 {
 fprintf(stderr, "start pt %4.6f %4.6f\n", uvpt[0], uvpt[1]);
 fflush(stderr);
 }
else
 {
 fprintf(stderr, "end pt %4.6f %4.6f\n", uvpt[0], uvpt[1]);
 fflush(stderr);
 }
#endif
 
      if( fabs(uvpt[0] - 0.0) < EQUAL_TOL )
        uvpt[0] = 0.0;
      if( fabs(uvpt[1] - 0.0) < EQUAL_TOL )
        uvpt[1] = 0.0;

      EMgetincinfo (msg, sf_id->osnum, NULL_OBJID, TRUE, uvpt, 
                    &active_md_env->md_env.matrix_type,
                    active_md_env->md_env.matrix,
                    sf_id->objid, cht, knot_tol, logical_parms);
      EMerr_hndlr (!( *msg & 1), *msg, EMS_E_Fail, wrapup);

      if( (logical_parms->edgeid == NULL_OBJID) )
        EMerr_hndlr (1, *msg, EMS_E_Fail, wrapup);

      }
    /* if( (logical_parms->edgeid == NULL_OBJID) ) */

    if( (logical_parms->edgeid == NULL) )
      {
fprintf(stderr, "ECcvsfinters: UNEXPECTED NULL VALUE FOR EDGEID\n");
fflush(stderr);
      EMerr_hndlr (1, *msg, EMS_E_Fail, wrapup);
      }

    }
  /* for (ii=START; ii<=STOP; ii++) */

  if( u_increases && bdry_parms )
    {
    *u_increases = bdry_parms->point[0] < bdry_parms->next->point[0] ? 1 : 0;
    }
  /* if u_increases */

wrapup:
  EMWRAPUP (*msg, stat, "EMcvsfinters");
  return stat;
}
/* EMcvsfinters */

end implementation EMSsubbs;
