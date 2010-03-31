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

#define START  0
#define STOP   1

#define EQUAL_TOL 0.000001
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }

extern double fabs();
/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from EMSedge import EMget_bcxyz_geom;


/*

   EMmarfiltantrim()

 * DESCRIPTION
       
    This function takes a fillet and generates EMSinters list by determining 
    tangent edges from each surf from a set of surfaces.  Then boundary is
    imposed by boolean.
    

 * Inputs

    options		- none

    fillet              - GRid of fillet to be trimmed
    num_surfs           - num of surfaces to be trimmed against
    elems               - array of GRlc_info for surfaces
    

 * Outputs

    msg			- Return codes
			  EMS_S_Success
				
    fillet              - trimmed fillet 


 * Algorithm

   Assumed that we need to impose only 1 edge from each surf from the input
   set of surfaces.

   Get edge geom for each edge to be imposed from each surf.  Generate inters 
   list with this geom & the fillet.  Trace the inters list.

   If logical start or stop is not on actual edge, error out.  This may change
   in future.

   Orient the curve based on whether the curve parametrization is increasing
   from logical start to stop and if we want it incrasing (need_u_incr) or
   decreasing (!need_u_incr).

   call EMimpose_boundary_w_intersection() to impose the intersection curve
   on the fillet.  (this function will trace the curve and do boolean).


 * HISTORY

    pac   : ???????? : creation.
*/

IGRlong EMmarfiltantrim( msg, options, active_md_env, 
                         num_surfs, elems, fillet, hot_v )

IGRlong				*msg;            /* o return code */      
IGRushort			options;         /* i see above */
struct GRmd_env                 *active_md_env;  /* i */
IGRint                          num_surfs;       /* i num of trim surfaces */
struct GRlc_info                *elems;          /* i array for trim surfaces */
struct GRid		        *fillet;         /* i/o fillet to be trimmed */
IGRdouble                       *hot_v;          /* i */

{
  IGRlong			ret0=OM_S_SUCCESS, stat;
  IGRushort                     world_opts, param_opts, trim_opts, trace_opts;
  IGRushort                     bool_opts;
  IGRint                        ii, is_curve_param_incr, curr_edge_indx;
  IGRdouble                     uv_point[2], logical_start, logical_stop;
  struct EMSintobj              *temp_ptr;
  struct EMSsfintedpar          *more_info;
  struct EMSsftracedata         sftrace;
  struct EMSinters              *fillet_inters=0;
  GRobjid                       logical_start_edge, logical_stop_edge;
  struct IGRbsp_surface         *curr_ele_surf=0, *fill_surf=0;
  struct GRid                   *curr_ele=0, curr_edge_id;
  struct IGRbsp_curve           *curr_edge_geom=0;
  IGRboolean                    is_u_incr, need_u_incr;

  IGRdouble                  p_range[4];
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;

  IGRboolean save_pathway_trim, save_pathway_orient;


IGRlong EMbef_filterm();
  extern void EMsfintedpar_free();


  /* 
   * data check 
   */

  MF_EMerr_hndlr( !( fillet && elems && num_surfs && hot_v ), 
                  *msg, EMS_E_InvalidData, ret_end );

ret0 = EMbef_filterm( msg, 0, active_md_env, fillet, hot_v );
MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
  
  ret0 = EMis_natsf(msg, fillet, p_range, &num_mineds, &mineds,
                    &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
  MEM_FREE(mineds); MEM_FREE(maxeds);  
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

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
  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);


  /*
   * generate inters list
   */

  world_opts = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
  param_opts = EMSINT_OUTPUT_PARAM | EMSINT_ORIENT_OUTPUT;
  trim_opts =  EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA;

  options = 0;
  options|= ECMF_NULL_OBJID_OK;
  fillet_inters = 0;
  
  for(ii=0; ii<num_surfs; ii++)
    {
    curr_ele = &elems[ii].located_obj;
    MEM_FREE(curr_ele_surf);
    curr_edge_geom = 0;

    /*
     *  get  surface
     */

    ret0 = EMgetvggeom ( msg,
                         &active_md_env->md_env.matrix_type,
                         active_md_env->md_env.matrix,
                         curr_ele, &curr_ele_surf, 0 );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);


    /*
     * get tan edge & geom
     */

    ret0 = ECfl_sf_edge(msg, active_md_env, curr_ele, fillet, curr_ele_surf,
                        fill_surf, 0, 0, &curr_edge_id, &curr_edge_indx,
                        &curr_edge_geom, uv_point);
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
   
    if(curr_edge_id.objid == NULL_OBJID)
      continue;
 
    ret0 = EMcvsfinters( msg, options, active_md_env, curr_edge_geom, 
                         fillet, fill_surf, &fillet_inters, &is_u_incr );
    MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);
    }

  if(! fillet_inters )
    MF_EMerr_hndlr (1, *msg, EMS_E_Fail, ret_end);

if(0)
{
struct EMSintobj *tmp_cv;
for(tmp_cv=fillet_inters->cvs; tmp_cv!=NULL; tmp_cv=tmp_cv->next)
 prtbspc(tmp_cv->this_xyzintobj.data.curve);
}

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

  ret0 = EMintersect_surfaces (msg, NULL, &active_md_env->md_env,
                0, NULL, NULL, trace_opts, NULL, NULL, NULL, NULL, NULL,
                &fillet_inters, NULL, &sftrace, NULL, NULL, NULL, NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  MF_EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  if(sftrace.num_grps != 1)
    MF_EMerr_hndlr (1, ret0, OM_E_ABORT, ret_end);

  /*
   * if logical start & logical stop are not on valid edges, error out
   * are we going to change this in future giving option to extend the curve
   * to desired/nearest edges?
   */

  temp_ptr  = fillet_inters->cvs;
  more_info = (struct EMSsfintedpar *) temp_ptr->more_info;
  if(!more_info) 
    MF_EMerr_hndlr (1, *msg, EMS_E_Fail, ret_end);
  logical_start_edge = temp_ptr->reversed ? more_info->next->edgeid :
                                            more_info->edgeid;

  if( (logical_start_edge == NULL_OBJID) )
    MF_EMerr_hndlr (1, *msg, EMS_E_Fail, ret_end);

  while (temp_ptr->next != NULL)
    temp_ptr = temp_ptr->next;

  more_info = (struct EMSsfintedpar *) temp_ptr->more_info;
  if(!more_info) 
    MF_EMerr_hndlr (1, *msg, EMS_E_Fail, ret_end);
  logical_stop_edge = temp_ptr->reversed ? more_info->edgeid :
                                           more_info->next->edgeid;

  if( (logical_stop_edge == NULL_OBJID) )
    MF_EMerr_hndlr (1, *msg, EMS_E_Fail, ret_end);


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

/*
  temp_ptr  = fillet_inters->cvs;
*/
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


  /*
   *  do boolean
   */

  trace_opts = EMS_SFINT_MUSTORIENT |
               EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
               EMS_SFINT_CHTTRACETOL;

  bool_opts = EMSsfbool_opt_SingleTopology | EMSsfbool_opt_noredraw;

  dp$display( msg = &stat, oids = fillet, mode = GRbe );

  ret0 = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                          active_md_env,
                                          fillet->objid,
                                          fillet_inters, NULL_OBJID,
                                          NULL, NULL);

  dp$display( msg = &stat, oids = fillet, mode = GRbd );

  MF_EMerr_hndlr (EMSerror (stat), ret0, OM_E_ABORT, ret_end);

ret_end:

  MEM_FREE(curr_ele_surf);
  MEM_FREE(fill_surf);
  if(fillet_inters)
    {
    IGRlong msg_loc;
/* fix for mlk */
    EMinters_data_free (&msg_loc, fillet_inters,MAXINT,NULL,EMsfintedpar_free);
    EMinters_free (fillet_inters, 0);
    }

  EMWRAPUP (*msg, ret0, "EMmarfiltantrim");
  return ret0;

}
/* EMmarfiltantrim */


/*
 * later extend to handle multiple edges at the other end (to be saved end or
 * the one which is not extended
 */

IGRlong EMbef_filterm( msg, options, active_md_env, fillet, hot_v )

IGRlong				*msg;            /* o return code */      
IGRushort			options;         /* i see above */
struct GRmd_env                 *active_md_env;  /* i */
struct GRid		        *fillet;         /* i/o fillet to be trimmed */
IGRdouble                       *hot_v;           /* i */
{
  IGRlong                    rc=BSSUCC, stat=OM_S_SUCCESS;
  IGRboolean                 is_u_incr, need_u_incr;
  IGRushort                  trace_opts, bool_opts;
  GRobjid                    dumobjs[4];
  struct GRid                *the_edge=0;
  struct IGRbsp_curve        *edge_geom=NULL;
  struct IGRbsp_surface      *fill_surf=0;
  OM_S_CHANSELECT            to_loopset;
  struct EMSinters           *inters=0;
  struct EMSintobj           *temp_ptr;


  IGRdouble                  p_range[4];
  IGRdouble                  check_v, min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;
  extern void EMsfintedpar_free();

  *msg = EMS_S_Success;
  options = options;

  /* 
   * data check 
   */

  MF_EMerr_hndlr( !(fillet && hot_v), *msg, EMS_E_InvalidData, ret_end );

  stat = EMgetvggeom ( msg,
                       &active_md_env->md_env.matrix_type,
                       active_md_env->md_env.matrix,
                       fillet, &fill_surf, 0 );
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  
  stat = EMis_natsf(msg, fillet, p_range, &num_mineds, &mineds,
                    &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  if( fabs(*hot_v - max_bnd_hot_v) < EQUAL_TOL )
    {
    the_edge = mineds;
    need_u_incr = 0;
    check_v = min_bnd_hot_v;
    }
  else
    {
    the_edge = maxeds;
    need_u_incr = 1;
    check_v = max_bnd_hot_v;
    }


  /*
   * Save the edge geometry.  In the following call, specification of
   * FALSE ensuares that the orientation of the xyz geometry would
   * correspond to the logical orientation of the edge.
   */

  edge_geom =(struct IGRbsp_curve *)om$malloc(size=sizeof(struct IGRbsp_curve));
  edge_geom->poles = NULL;
  edge_geom->knots = NULL;
  edge_geom->weights = NULL;

  stat = om$send( msg = message EMSedge.EMget_bcxyz_geom( msg,
                        &active_md_env->md_env, fillet, fill_surf,
                        0, MAXINT, FALSE, NULL, edge_geom ),
                        senderid = NULL_OBJID,
                        targetos = the_edge->osnum,
                        targetid = the_edge->objid);
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);


  dp$display( msg = &rc, oids = fillet, mode = GRbe );


  /*
   * delete old loopset
   */

  stat = om$make_chanselect( channame = "EMSsubbs.to_loopset",
                             p_chanselect = &to_loopset );
  MF_EMerr_hndlr(!(stat & 1), stat, stat, ret_end);

  stat = om$send( msg = message Root.delete(0), senderid = fillet->objid,
                  p_chanselect = &to_loopset, targetos = fillet->osnum );
  MF_EMerr_hndlr(!(stat & 1), stat, stat, ret_end);


  /*
   * make new loopset
   */
 
  stat = om$send( msg = message EMSsurface.EMmk_nat_bdry( msg, 
                                &active_md_env->md_env, dumobjs ),
                        senderid = NULL_OBJID,
                        targetid = fillet->objid,
                        targetos = fillet->osnum );
  MF_EMerr_hndlr( !(*msg & stat & 1), stat, OM_E_ABORT, ret_end );


  /* if the other end is a natural edge, no need no impose */
  if( (fabs(check_v - 0.0) < EQUAL_TOL) || (fabs(check_v - 1.0) < EQUAL_TOL) )
    goto reset_hot_v;


  /*
   * impose saved geometry at the other end
   */

  stat = EMcvsfinters( msg, 0, active_md_env,
                       edge_geom, fillet, fill_surf, &inters, &is_u_incr );
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  if(!inters)
    {
#ifdef DEBUG
    fprintf(stderr, "EMbef_filterm: NULL inters list from EMcvsfinters\n");
    fflush(stderr);
    goto ret_end;
#endif
    }

  /*
   * check orientation of curve to be imposed
   */

  if( ( need_u_incr && (! is_u_incr)) || (!need_u_incr && is_u_incr) )
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

  stat = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                          active_md_env,
                                          fillet->objid, inters, NULL_OBJID,
                                          NULL, NULL);
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);


reset_hot_v:

  /*
   * reset hot_v
   */

  *hot_v = need_u_incr? 0.0 : 1.0;

ret_end:

  dp$display( msg = &rc, oids = fillet, mode = GRbd );

  MEM_FREE(mineds); MEM_FREE(maxeds);  
  MEM_FREE(fill_surf);

/* fix for mlk */
  if(edge_geom->poles )
    {
    om$dealloc(ptr = edge_geom->poles );
    edge_geom->poles= NULL;
    }
  if(edge_geom->weights)
    {
    om$dealloc(ptr = edge_geom->weights );
    edge_geom->weights = NULL;
    }
  if(edge_geom->knots)
    {
    om$dealloc(ptr = edge_geom->knots );
    edge_geom->knots = NULL;
    }

  if(inters)
    {
    IGRlong msg_loc;
/* fix for mlk */
    EMinters_data_free (&msg_loc, inters, MAXINT, NULL, EMsfintedpar_free);
    EMinters_free (inters, 0);
    }

  EMWRAPUP (*msg, stat, "EMbef_filterm");
  return stat;

}
/* EMbef_filterm */

end implementation EMSsubbs;

