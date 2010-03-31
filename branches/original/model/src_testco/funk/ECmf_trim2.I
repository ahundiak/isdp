class implementation EMSsubbs;

#include "memory.h"
#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "ECmsg.h"
#include "EMSmsgdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "emssfintdef.h"
#include "emserr.h"
#include "ECmfdef.h"
#include "ECmf.h"
#include "EMSprop.h"

#include "bssfkttol2.h"
#include "bsmdistptsf.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

extern double fabs();

%safe
static IGRlong qq_impose_this_edge();
%endsafe

#define EQUAL_TOL 0.000001
#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;
#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }

from EMSedge import EMxyz_endpt;
from EMSedge import EMinternalpt;

/*

 * DESCRIPTION
       
    This function finds 'intersection' between two fillets and imposes it on
    both fillets.

 * Inputs

    options		- 
    fillet0             - IGRbsp_surface of first fillet
    fillet1             - IGRbsp_surface of second fillet
    v_rem0              - V value of edge to remove in fillet0
    v_rem1              - V value of edge to remove in fillet1
    
 * Outputs

    msg			- Return codes
				EMS_S_Success
    inters              - EMSinters list of curve-surface intersection

ALGO


 * HISTORY

   pac       ????????  wrote it 
   Sudha     07/02/93  Modified for BSprototypes ansification
*/

IGRlong EMflflimpose( msg, options, active_md_env, 
		      fillet0_info, fillet1_info )

IGRlong				*msg;                  
IGRushort			options;

struct GRmd_env                 *active_md_env;    /* i */
struct ele_stack                *fillet0_info;     /* i fillet0 stack info */
struct ele_stack                *fillet1_info;     /* i fillet1 stack info */

{
  IGRlong			stat;
  IGRint                        hot_edge1, free0=0, free1=0;
  IGRushort                     trace_opts, bool_opts;
  struct GRlc_info              l_ele0, l_ele1;
  struct EMSinters              *fillet0_inters=0, *fillet1_inters=0;

  IGRdouble                  p_range[4];
  IGRdouble                  min_bnd_hot_v, max_bnd_hot_v;
  IGRint                     num_mineds, num_maxeds;
  struct GRid                *mineds=0, *maxeds=0;

  /*
   * Initialize 
   */

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  options = options;  /* keep apogee quiet !! */

  /* data check */
  EMerr_hndlr( !( fillet0_info && fillet1_info && active_md_env ), 
	       *msg, EMS_E_InvalidData, ret_end );


  /* get surfaces if not available */
  if( !fillet0_info->objs_surf )
    {
    free0 =1;
    stat = EMgetvggeom( msg,
			&active_md_env->md_env.matrix_type,
			active_md_env->md_env.matrix,
			&fillet0_info->ele_grid,
			&fillet0_info->objs_surf,
			NULL
		      );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
    }
  /* if no surf, get it */

  if( !fillet1_info->objs_surf )
    {
    free1 =1;
    
    stat = EMgetvggeom( msg,
			&active_md_env->md_env.matrix_type,
			active_md_env->md_env.matrix,
			&fillet1_info->ele_grid,
			&fillet1_info->objs_surf,
			NULL
		      );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
    }
  /* if no surf, get it */


  /*
   * orientation for portion of fillet1 to keep
   */

  p_range[0] = 0;
  p_range[1] = 1;
  p_range[2] = 0;
  p_range[3] = 1;
  stat = EMis_natsf(msg, &fillet1_info->ele_grid, p_range, &num_mineds, &mineds,
                    &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
  EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  if( fabs(fillet1_info->hot_edge - min_bnd_hot_v) < EQUAL_TOL )
    hot_edge1 = 1;
  else
    hot_edge1 = 0;

  stat = qq_isoimpose(msg, active_md_env, &fillet0_info->ele_grid, 
               &fillet1_info->ele_grid,
               fillet0_info->objs_surf, fillet1_info->objs_surf, 
               &fillet0_info->hot_edge, hot_edge1 );
  
  if(*msg == EMS_E_Fail)
    {
    IGRdouble d_hot_edge1 = (IGRdouble) hot_edge1;
      l_ele0.located_obj.objid = fillet0_info->ele_grid.objid;
      l_ele0.located_obj.osnum = fillet0_info->ele_grid.osnum;
      stat = EMmarfiltrim( msg, 0, active_md_env, &d_hot_edge1,
                           1, &l_ele0, &fillet1_info->ele_grid, 
                           &fillet1_inters );
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      l_ele1.located_obj.objid = fillet1_info->ele_grid.objid;
      l_ele1.located_obj.osnum = fillet1_info->ele_grid.osnum;
      stat = EMmarfiltrim( msg, 0, active_md_env, &fillet0_info->hot_edge,
                           1, &l_ele1, &fillet0_info->ele_grid, 
                           &fillet0_inters );
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      /*
       *  impose boundaries (do boolean)
       */

      trace_opts = EMS_SFINT_MUSTORIENT |
               EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
               EMS_SFINT_CHTTRACETOL;

      bool_opts = EMSsfbool_opt_SingleTopology | EMSsfbool_opt_noredraw;
 
      dp$display( msg = &stat, oids = &fillet0_info->ele_grid, mode = GRbe );

      dp$display( msg = &stat, oids = &fillet1_info->ele_grid, mode = GRbe );

      /*
       * fillet0
       */

      stat = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                              active_md_env,
                                              fillet0_info->ele_grid.objid,
                                              fillet0_inters, NULL_OBJID,
                                              NULL, NULL);
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);


      /*
       * fillet1
       */

      stat = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                              active_md_env,
                                              fillet1_info->ele_grid.objid,
                                              fillet1_inters, NULL_OBJID,
                                              NULL, NULL);
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      }
    /* else go ahead for intersection */

  EMerr_hndlr (EMSerror (*msg), stat, OM_E_ABORT, ret_end);
  
ret_end:

  if(fillet1_info)
    {dp$display( msg = &stat, oids = &fillet1_info->ele_grid, mode = GRbd );}
  if(fillet0_info)
    {dp$display( msg = &stat, oids = &fillet0_info->ele_grid, mode = GRbd );}

  if( free0 )
    MEM_FREE( fillet0_info->objs_surf );
  if( free1 )
    MEM_FREE( fillet1_info->objs_surf );

  MEM_FREE(mineds);
  MEM_FREE(maxeds);

  EMWRAPUP (*msg, stat, "EMflflimpose");
  return stat;

}
/* EMflflimpose */


/*
 * extract iso curves at specified V par values for prev fillet.
 * impose it on curr fillet.  to impose curve, first make inters list and 
 * then do boolean
 * pac 
 */

IGRint qq_isoimpose(     msg, active_md_env, 
                         fill_id0, fill_id1, 
                         fill_surf0, fill_surf1, 
                         vpar0, fill1_uincr )

IGRlong                  *msg;                       /* O */ 
struct GRmd_env          *active_md_env;
struct GRid              *fill_id0, *fill_id1;       /* I,O curves may be 
                                                        imposed */
struct IGRbsp_surface    *fill_surf0, *fill_surf1;   /* I */
IGRdouble                *vpar0;                     /* I */
IGRboolean               fill1_uincr;                /* I */
{

  IGRlong                rc=BSSUCC, ret0=OM_S_SUCCESS;
  IGRshort               option;
  IGRushort              trace_opts, bool_opts;
  IGRboolean             tst_planar, is_u_increasing;
  struct IGRbsp_curve    *isocv0=0;
  struct EMSinters       *inters=0;
  struct EMSintobj       *temp_ptr=0;



  /*
   * data check
   */

  EMerr_hndlr( !( fill_id0 && fill_id1 && vpar0 && fill_surf0 && fill_surf1),
                  *msg, EMS_E_InvalidData, ret_end );


  /*
   * allocate space for isocurve
   */

  BSalloccv( fill_surf0->u_order, fill_surf0->u_num_poles, fill_surf0->rational,
             NULL, &isocv0, &rc);
  EMerr_hndlr( (rc != BSSUCC), *msg, BSNOMEMORY, ret_end );

  /*
   * get isocurve
   */

  option = 2; /* in_v_dir */
  tst_planar = 0;

  BSconstprcv( &rc, fill_surf0, &option, vpar0, &tst_planar, isocv0);
  EMerr_hndlr( (rc != BSSUCC), *msg, EMS_E_BSerror, ret_end );

  /* Linestring post does not handle weights */
  if((isocv0->order == 2) && isocv0->rational)
    {
    BSunwght_p( &rc, isocv0->poles, isocv0->weights,
                &isocv0->num_poles, isocv0->poles);
    EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
    }


  /*
   * generate inters list, orient the curve and do boolean
   */

  ret0 = EMcvsfinters( msg, 0, active_md_env, isocv0, fill_id1, fill_surf1, 
                       &inters, &is_u_increasing );
  EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

  /*
   * check orientation of curve to be imposed
   */

  if( ( fill1_uincr && (! is_u_increasing)) ||
      (!fill1_uincr && is_u_increasing) )
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

  dp$display( msg = &ret0, oids = fill_id1, mode = GRbe );

  ret0 = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                          active_md_env,
                                          fill_id1->objid, inters, NULL_OBJID,
                                          NULL, NULL);
  EMerr_hndlr (EMSerror (ret0 & *msg), ret0, OM_E_ABORT, ret_end);

ret_end:

  dp$display( msg = &ret0, oids = fill_id1, mode = GRbd );

  if(isocv0)
    BSfreecv(&rc, isocv0);
  if(inters)
    EMinters_free (inters, 0);

  return ret0;

}
/* qq_isoimpose */


/*

 * DESCRIPTION
       
   This function finds 'intersection' between fillet0 (current fillet) and 
   fillet 1 (previous fillet) and imposes it on fillet1.  fillet0 is not 
   extended since it is generated by rolling on another fillet

 * Inputs

   options		- 
    
 * Outputs

   msg			- EMS return code

ALGO

   TBD   

UPDATE OPEN EDGES TOO

 * HISTORY

   pac     
*/

IGRlong EMflflimpose2( msg, options, const_list, degen_opt,
		       fillet0_info, fillet1_info )

IGRlong				*msg;                  
IGRushort			options;
struct GRvg_construct           *const_list;       /* i */
IGRushort                       degen_opt;         /* i */
struct ele_stack                *fillet0_info;     /* i fillet0 stack info */
struct ele_stack                *fillet1_info;     /* i fillet1 stack info */

{
  IGRlong			rc, stat;
  IGRint                        ii, free0=0, free1=0;
  struct GRmd_env               *active_md_env;

  IGRint                        array_size, num_edges;
  struct GRid                   *edges=0;
  IGRdouble                     uv_point[2];
  struct EMSpartolbasis         pt_edge_tol;
  IGRboolean                    impose;

  IGRboolean                    tst_planar;
  IGRdouble                     vpar;
  IGRshort                      option;
  struct IGRbsp_curve           *isocv=0;

  IGRdouble                     *fill1_hot_v;
  IGRboolean                    uincr, is_u_increasing;
  struct EMSinters              *inters=0;
  struct EMSintobj              *temp_ptr=0;
  IGRushort                     trace_opts, bool_opts;

  IGRdouble                     p_range[4];
  IGRdouble                     min_bnd_hot_v, max_bnd_hot_v;
  IGRint                        num_mineds, num_maxeds;
  struct GRid                   *mineds=0, *maxeds=0;

  /* data check */
  EMerr_hndlr( !( fillet0_info && fillet1_info && const_list ), 
	       *msg, EMS_E_InvalidData, ret_end );

  /*
   * Initialize 
   */

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  rc   = BSSUCC;
  options = options;  /* keep apogee quiet !! */
  active_md_env = const_list->env_info;  


  /* if no surf, get it */
  if( !fillet0_info->objs_surf )
    {
    free0 =1;
    stat = EMgetvggeom( msg, &active_md_env->md_env.matrix_type,
			active_md_env->md_env.matrix,
			&fillet0_info->ele_grid, 
                        &fillet0_info->objs_surf, NULL );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
    }
  /* if no surf, get it */

  /* if no surf, get it */
  if( !fillet1_info->objs_surf )
    {
    free1 =1;
    stat = EMgetvggeom( msg, &active_md_env->md_env.matrix_type,
			active_md_env->md_env.matrix,
			&fillet1_info->ele_grid, 
                        &fillet1_info->objs_surf, NULL );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, ret_end );
    }
  /* if no surf, get it */


  /*
   * find hot edge for fillet1
   */

  fill1_hot_v = &fillet1_info->hot_edge;

  stat = EMis_natsf(msg, &fillet1_info->ele_grid, p_range, &num_mineds, &mineds,
                    &num_maxeds, &maxeds, &min_bnd_hot_v, &max_bnd_hot_v);
  EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  MEM_FREE(mineds); MEM_FREE(maxeds);

  if( fabs(*fill1_hot_v - min_bnd_hot_v) < EQUAL_TOL )
    uincr = 0;
  else
    uincr = 1;


  /*
   * find which V edge of fl0 to impose on fl1
   */

  if(degen_opt == EMSfillet_v0_is_degenerate)
    {
    vpar = 1.0;
    goto extract_impose;
    }
  else if(degen_opt == EMSfillet_v1_is_degenerate)
    {
    vpar = 0.0;
    goto extract_impose;
    }

  /* since we didn't have a degen edge, check both V0 & V1 edges */

  /*
   * get edges
   */

  array_size = 0;
  num_edges  = 0;
  edges      = 0;

  stat= om$send(msg = message EMSsubbs.EMget_edges(msg, MAXINT,
                EMS_OPT_NON_DEG_SEAM_XYZCLSD, active_md_env, &edges,
                &array_size, &num_edges),
                senderid = NULL_OBJID,
                targetid = fillet0_info->ele_grid.objid,
                targetos = fillet0_info->ele_grid.osnum);
  EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  BSEXTRACTPAR (&rc, BSTOLLENVEC, pt_edge_tol.tol);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
  pt_edge_tol.is_valid = TRUE;

  impose = 0;
  for(ii=0; ii<num_edges; ii++)
    {

    /*
     * get endpoints for V0 or V1 edge 
     */

    stat = om$send (msg = message EMSedge.EMinternalpt (msg,
                          1, 0, uv_point, NULL, &pt_edge_tol),
                    senderid = NULL_OBJID,
                    targetid = edges[ii].objid,
                    targetos = edges[ii].osnum);
    EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

    if(fabs(uv_point[1] - 0.0) < EQUAL_TOL) /* V0 edge */
      {
      stat = qq_impose_this_edge(msg, fillet0_info->objs_surf, 
                                 fillet1_info->objs_surf, &edges[ii], &impose);
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      if(impose)
        {
        vpar = 0.0;
        break;
        }
      }
    /* V0 edge */
    else if(fabs(uv_point[1] - 1.0) < EQUAL_TOL) /* V1 edge */
      {
      stat = qq_impose_this_edge(msg, fillet0_info->objs_surf,
                                 fillet1_info->objs_surf, &edges[ii], &impose);
      EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      if(impose)
        {
        vpar = 1.0;
        break;
        }
      }
    /* V1 edge */

    }
  /* for(ii=0; ii<num_edges; ii++) */

  if(! impose)
    EMerr_hndlr (1, stat, OM_E_ABORT, ret_end);
    
extract_impose:

  option = 2; /* in_v_dir */
  tst_planar = 0;

  /*
   * get isocurve
   */

  BSalloccv(fillet0_info->objs_surf->u_order, 
            fillet0_info->objs_surf->u_num_poles, 
            fillet0_info->objs_surf->rational,
            NULL, &isocv, &rc);
  EMerr_hndlr( (rc != BSSUCC), *msg, BSNOMEMORY, ret_end );

  BSconstprcv(&rc, fillet0_info->objs_surf, &option, &vpar, &tst_planar, isocv);
  EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

  /* Linestring post does not handle weights */
  if((isocv->order == 2) && isocv->rational)
    {
    BSunwght_p( &rc, isocv->poles, isocv->weights,
                &isocv->num_poles, isocv->poles);
    EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
    }


  /*
   * build inters list
   */

  inters = 0;
  stat = EMcvsfinters( msg, 0, active_md_env, isocv, &fillet1_info->ele_grid, 
                       fillet1_info->objs_surf, &inters, &is_u_increasing );
  EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);
 
  /*
   * check orientation of curve to be imposed
   */

  if( ( uincr && (! is_u_increasing)) ||
      (!uincr && is_u_increasing) )
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

  dp$display( msg = &stat, oids = &fillet1_info->ele_grid, mode = GRbe );

  stat = EMimpose_boundary_w_intersection(msg, trace_opts, bool_opts,
                                          active_md_env,
                                          fillet1_info->ele_grid.objid, 
                                          inters, NULL_OBJID, NULL, NULL);
  EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);


  /* 
   * set hot edge for fillet 0
   */
  
  fillet0_info->hot_edge = (! vpar) ? 1.0 : 0.0;

ret_end:

  dp$display( msg = &stat, oids = &fillet1_info->ele_grid, mode = GRbd );

  if( free1 ) MEM_FREE( fillet1_info->objs_surf );
  if( free0 ) MEM_FREE( fillet0_info->objs_surf );

  MEM_FREE(edges);
  MEM_FREE(mineds); MEM_FREE(maxeds);

  if(inters)
    EMinters_free (inters, 0);
  if(isocv)
    BSfreecv(&rc, isocv);

  EMWRAPUP (*msg, stat, "EMflflimpose2");
  return stat;

}
/* EMflflimpose2 */

static IGRlong qq_impose_this_edge(msg, fill0_sf, fill1_sf, edge_grid, impose)
IGRlong *msg;
struct IGRbsp_surface *fill0_sf, *fill1_sf;
struct GRid *edge_grid;
IGRboolean *impose;
{
  IGRlong stat=OM_S_SUCCESS, rc=BSSUCC;
  IGRdouble chttol, fillu, fillv, min_dist1, min_dist2;
  IGRpoint to_pt, beginpt, endpt;

  *impose = 0;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, chttol);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  stat = om$send(msg = message EMSedge.EMxyz_endpt(msg, 0, 0, 0, 0,
                       (IGRdouble *) beginpt, (IGRdouble *) endpt, &fill0_sf),
                 senderid = NULL_OBJID,
                 targetid = edge_grid->objid,
                 targetos = edge_grid->osnum);
  EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  BSmdistptsf(&rc, fill1_sf, beginpt, &fillu, &fillv, to_pt, &min_dist1);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  BSmdistptsf(&rc, fill1_sf, endpt, &fillu, &fillv, to_pt, &min_dist2);
  EMerr_hndlr (rc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

  if( (min_dist1 <= chttol) && (min_dist2 <= chttol) )
    *impose = 1;

ret_end:
  return stat;

}
/* qq_impose_this_edge */

end implementation EMSsubbs;
