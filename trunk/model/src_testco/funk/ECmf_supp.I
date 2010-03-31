class implementation EMSsubbs;

#include "OMminimum.h"
#include <stdio.h>
#include "igrdef.h"          /* IGRBC, IGRBS, etc. */
#include "igrtypedef.h"      /* IGRshort, IGRlong, etc. */
#include "igetypedef.h"
#include "igr.h"             /* IGRbsp_curve, IGRbsp_surface, etc. */
#include "igrdp.h"           /* IGResbc, IGResbs, etc. */
#include "dpdef.h"           /* neccessary for dp$build_dis_buffer */ 
#include "dpmacros.h"        /* dp$build_dis_buffer, etc. */
#include "grdpbdef.h"        /* neccessary for gr$get_active_level */
#include "grdpbmacros.h"     /* gr$get_active_level, ... */
#include "dpstruct.h"        /* DPele_header, etc. */
#include "godef.h"           /* all this neccessary for GRsymbology */
#include "gr.h"              /* "   "    "          "   "           */
#include "go.h"              /* GRsymbology, etc. */
#include "dp.h"              /* GRbdhe, etc. */
#include "bserr.h"
#include "bsparameters.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "emserr.h"
#include "ECmsg.h"
#include "ECmf.h"
#include "ECmferr.h"
#include "ECmfopt.h"
#include "ECmfdef.h"

extern double fabs();
extern double BSlenvec();

#define NUM_RULE_LINES 5
#define EQUAL_TOL 0.000001

#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }

from EMSedge import EMinternalpt;

IGRlong ECmf_dispele ( msg, options, symb, is_curve, geom )
IGRlong            *msg;              /* i */
IGRushort          options;           /* i */
struct GRsymbology *symb;             /* i  symbology to apply to eles  */
IGRboolean         is_curve;          /* i  1 => ele is curve; 0=> surf */
void               *geom;             /* i  ele to display              */

/*
DESCRIPTION
  This function displays one element at a time given the curve/surface
  structure and symbology.

RETURN VALUES

NOTES
  If you want to display a point send "is_curve" = 1 and set
  geom.num_poles = 1.

EXAMPLES

HISTORY
       Author        Date              Description
       ------        ----              -----------
        pac        ????????            copied eddie's NCdispele

NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC NC */

{
    /* local variables */
  IGRlong ret0 = OM_S_SUCCESS, ret1;
  IGRchar  *geometry;
  IGRchar  *ele_spec_att;
  IGRshort type;
  IGRpoint point;
  IGRshort *level;
  struct IGRdisplay *display_att;
  IGRshort ActiveLevel;
  struct IGRdisplay ActiveDisplay;
  enum GRdpmode mode;
  IGRint    u_bounds[ NUM_RULE_LINES ], v_bounds[ NUM_RULE_LINES ];
  IGRdouble u_rules[ NUM_RULE_LINES ],  v_rules[ NUM_RULE_LINES ];

  struct IGResbc curve_attr;
  struct IGResps ptset_attr;
  struct IGResqbs surface_attr;
  struct IGRpointset point_set;

  struct DPele_header buffer;

  options = options;

#ifdef REALLY_DEBUG
  printf(( "NCdispele: entering, is_curve = %d\n", is_curve ));
#endif

/*
 *  Get the active symbology if "symb" not specified
 */
  if ( ! symb ) {
     IGRlong byt_in, byt_out;

     byt_in = sizeof( struct IGRdisplay );
     ret0 = gr$get_active_display( msg = &ret1, sizbuf = &byt_in,
                                   buffer = &ActiveDisplay, nret = &byt_out );
     EMerr_hndlr (EMSerror (ret0 & ret1), ret0, OM_E_ABORT, ret_error_exit);

     byt_in = sizeof( IGRshort );
     ret0 = gr$get_active_level( msg = &ret1, sizbuf = &byt_in,
                                 buffer = &ActiveLevel, nret = &byt_out );
     EMerr_hndlr (EMSerror (ret0 & ret1), ret0, OM_E_ABORT, ret_error_exit);

     level = &ActiveLevel;
     display_att = &ActiveDisplay;
  }
  else {
     level = &symb->level;
     display_att = &symb->display_attr;
  };
/*
 *  Build the display buffer header and display element
 */
  if (is_curve) {
     struct IGRbsp_curve *cv = ( struct IGRbsp_curve * ) geom;

     if (cv->num_poles == 1) {
#ifdef REALLY_DEBUG
        printf(( "NCdispele: building point attributes\n" ));
#endif
        type = IGRPS;
        point[0] = cv->poles[0];
        point[1] = cv->poles[1];
        point[2] = cv->poles[2];
        point_set.num_points = 1;
        point_set.points = point;
        ptset_attr.is_connected = FALSE;
        ele_spec_att = ( IGRchar * ) &ptset_attr;
        geometry = ( IGRchar * ) &point_set;
     }
     else {
#ifdef REALLY_DEBUG
        printf(( "NCdispele: building curve attributes\n" ));
#endif
        type = IGRBC;
        curve_attr.is_polydis = FALSE;   /* no polygon display   */
        curve_attr.is_curvedis = TRUE;   /* curve is displayable */
        ele_spec_att = ( IGRchar * ) &curve_attr;
        geometry = geom;
     }
  }
  else {
     struct IGRbsp_surface *sf = ( struct IGRbsp_surface * ) geom;
     int i;
     IGRshort uord = sf->u_order - 1, vord = sf->v_order - 1;
     IGRlong  unp = sf->u_num_poles, vnp = sf->v_num_poles;
     IGRdouble *u_knots = sf->u_knots, *v_knots = sf->v_knots;
     IGRdouble u_delta, v_delta;

#ifdef REALLY_DEBUG
     printf(( "NCdispele: building surface attributes\n" ));
#endif
     type = IGRQS;

     u_delta = (u_knots[ unp ] - u_knots[ uord ]) / (NUM_RULE_LINES - 1 );
     v_delta = (v_knots[ vnp ] - v_knots[ vord ]) / (NUM_RULE_LINES - 1 );
     u_rules[ 0 ] = u_knots[ uord ];
     v_rules[ 0 ] = v_knots[ vord ];
     for (i=1; (i < (NUM_RULE_LINES - 1)); i++) {
         u_rules[ i ] = u_rules[ i - 1 ] + u_delta; 
         v_rules[ i ] = v_rules[ i - 1 ] + v_delta;
     };
     u_rules[ (NUM_RULE_LINES - 1) ] = u_knots[ unp ];
     v_rules[ (NUM_RULE_LINES - 1) ] = v_knots[ vnp ];

     for (i=0; (i < NUM_RULE_LINES); i++) {
         u_bounds[ i ] = 0;
         v_bounds[ i ] = 0;
     };

     surface_attr.u_rules = NUM_RULE_LINES;  /* # u rule lines */
     surface_attr.v_rules = NUM_RULE_LINES;  /* # v rule lines */
     surface_attr.is_polydis = FALSE;          /* no polygon display     */
     surface_attr.is_surfdis = TRUE;           /* surface is displayable */
     surface_attr.is_slowdis = FALSE;          /* fast display */
     surface_attr.type = 0;                    /* ignored */
     surface_attr.rules_specified = TRUE;
     surface_attr.u_rule_values = u_rules;
     surface_attr.v_rule_values = v_rules;
     surface_attr.u_num_bound = u_bounds;
     surface_attr.v_num_bound = v_bounds;
     surface_attr.u_bdrys = NULL;
     surface_attr.v_bdrys = NULL;
     ele_spec_att = ( IGRchar * ) &surface_attr;
     geometry = geom;
  };
/*
 *  Build the display buffer header
 */
  ret0 = dp$build_dis_buffer( buffer = &buffer, type = type,
                              level = level, display_att = display_att,
                              ele_spec_att = ele_spec_att,
                              geometry = geometry
                            );
  EMerr_hndlr (EMSerror(ret0), ret0, ret0, ret_error_exit);
#ifdef REALLY_DEBUG
  printf(( "NCdispele: after dp$build_dis_buffer\n" ));
#endif
/*
 *  Display element object by buffer
 */
  mode = GRbehd;
  dp$display( msg = &ret0, mode = mode, num_elem = 1, buffer = &buffer );
  EMerr_hndlr (EMSerror(ret0), ret0, ret0, ret_error_exit);
#ifdef REALLY_DEBUG
  printf(( "NCdispele: after dp$display\n" ));
#endif

ret_error_exit:
#ifdef REALLY_DEBUG
  printf(( "NCdispele: returning, ret0 = %d\n", ret0 ));
#endif

  *msg = ret1;
  EMWRAPUP (*msg, ret0, "ECmf_dispele");
  return( ret0 );

}
/* ECmf_dispele */

IGRlong ECmf_march_end(msg, opts, active_md_env, tan_length,
                       march_arrow, prev_ele, curr_ele, march_side)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *active_md_env;
IGRdouble tan_length;
IGRpoint march_arrow[2];
struct ele_stack *prev_ele, *curr_ele;
IGRboolean *march_side;
{
  IGRlong rc, stat;
  IGRdouble fillub, fillvb, fillue, fillve, mdist, uv_point[2];
  IGRint ii, edge_indx;
  IGRpoint fillpt;
  struct GRid *fil_grid, edge_id;
  struct IGRbsp_surface *fil_surf;
  struct IGRbsp_surface *l_surf=0;
  IGRboolean free_surf=0;
  IGRpoint tanpoints[3];

  opts = opts;
  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  rc = BSSUCC;
  EMerr_hndlr( !(curr_ele && march_side), *msg, EMS_E_InvalidData, ret_end );

  fil_surf = curr_ele->objs_surf;
  fil_grid = &curr_ele->ele_grid;

  /* get sf if necessary */
  if(! fil_surf)
    {
    free_surf = 1;
    stat = EMgetvggeom ( msg,
                         &active_md_env->md_env.matrix_type,
                         active_md_env->md_env.matrix,
                         fil_grid, &l_surf, 0 );
    MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);
    }
  else
    {
    free_surf = 0;
    l_surf = fil_surf;
    }

  /* SPH specific */
  if( prev_ele && (prev_ele->elem_type == SPH_ELEMENT) )
    {
    stat = ECfl_sf_edge(msg, active_md_env, 
                        &prev_ele->ele_grid, &curr_ele->ele_grid, 
                        prev_ele->objs_surf, curr_ele->objs_surf,
                        &prev_ele->elem_type, 0, &edge_id, &edge_indx, 0,
                        &uv_point);
    MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

    if(edge_id.objid == NULL_OBJID)
      {
      *march_side = -1;
      goto ret_end;
      }

    stat = om$send( msg = message EMSsubbs.EMsftanorm(msg,
                  &active_md_env->md_env.matrix_type,
                  active_md_env->md_env.matrix, 0,
                  1, &uv_point[0], 1, &uv_point[1],
                  0.5*tan_length, 0, 1, 0, (IGRdouble *)tanpoints, 0),
                  senderid = NULL_OBJID,
                  targetid = prev_ele->ele_grid.objid,
                  targetos = prev_ele->ele_grid.osnum);
    MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

    if( ! ( (fabs(uv_point[1]-0.0) < EQUAL_TOL) ||
            (fabs(uv_point[1]-1.0) < EQUAL_TOL) ) )
      for(ii=0; ii<3; ii++)
        tanpoints[2][ii] = tanpoints[0][ii];

    if( fabs(uv_point[1]-0.0) < EQUAL_TOL)
      {
      IGRvector temp_vec;
      IGRdouble temp_len;
      IGRint iii;
      IGRlong rc=BSSUCC;

      BSmkvec (&rc, temp_vec, tanpoints[2], tanpoints[1]);
      MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
      temp_len = BSlenvec(&rc, temp_vec);
      MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
      BSnorvec(&rc, temp_vec);
      MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );
      for(iii=0; iii<3; iii++)
        tanpoints[2][iii] = tanpoints[1][iii] + temp_len * temp_vec[iii];
      }

    memcpy(march_arrow[0], tanpoints[1], sizeof(IGRpoint));
    memcpy(march_arrow[1], tanpoints[2], sizeof(IGRpoint));
    }

  /* prev_ele was a fillet */

  BSmdistptsf( &rc, l_surf, march_arrow[0], &fillub, &fillvb,
               fillpt, &mdist );
  MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );

  BSmdistptsf( &rc, l_surf, march_arrow[1], &fillue, &fillve,
               fillpt, &mdist );
  MF_EMerr_hndlr ( rc != BSSUCC, *msg, EMS_E_BSerror, ret_end );


  if((fillve - fillvb) > 0)
    *march_side = 1;
  else
    *march_side = 0;

ret_end:

  if(free_surf)
    MEM_FREE(l_surf);

  EMWRAPUP (*msg, stat, "ECmf_march_end");
  return( stat );
  
}
/* ECmf_march_end*/

ECmf_open_edges(msg, opts, active_md_env, prev_ele, curr_ele)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *active_md_env;
struct ele_stack *prev_ele, *curr_ele;
{
  IGRlong rc, stat;
  struct GRid *edges=0;
  IGRint aa, bb, ii, ll, array_size=0, num_edges=0;
  IGRdouble pt_on_edge[2];
  struct EMSpartolbasis pt_edge_tol;
  struct ele_stack *ele;

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  rc = BSSUCC;

  MF_EMerr_hndlr( !curr_ele, *msg, EMS_E_InvalidData, ret_end );

  BSEXTRACTPAR (&rc, BSTOLLENVEC, pt_edge_tol.tol);
  MF_EMerr_hndlr (rc != BSSUCC, stat, OM_E_ABORT, ret_end);

  pt_edge_tol.is_valid = TRUE;

  for(aa=0; aa<2; aa++)
    {
    if(!aa)
      ele = curr_ele;
    else
      ele = prev_ele;

    if(! ele) /* skip aa==1 part for first ele where prev_ele==0 */
      break;

    if(ele->elem_type == FIL_ELEMENT)
      {
      if(! aa)
        for(ll=0; ll<3; ll++)
          ele->open_edges[ll].objid = NULL_OBJID;
      }
/***************/
    else /* find which edge to be unmarked */
      {
      for(ll=2; ll>0; ll--)
        if(ele->marked_edges[ll] != -1)
          {
          ele->hot_edge = ele->marked_edges[ll];
          ele->marked_edges[ll] = -1;
          break;
          }
      }

    MEM_FREE(edges);
    array_size = 0;
    num_edges  = 0;

    stat= om$send(msg = message EMSsubbs.EMget_edges(msg, MAXINT,
                  EMS_OPT_NON_DEG_SEAM_XYZCLSD, active_md_env, 
                  &edges, &array_size, &num_edges),
                  senderid = NULL_OBJID,
                  targetid = ele->ele_grid.objid,
                  targetos = ele->ele_grid.osnum);
    MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);
 
    ll=0;
    for(ii=0; ii<num_edges; ii++)
      {
      /*
       * get midpt of an edge
       */

      stat = om$send (msg = message EMSedge.EMinternalpt (msg,
                      1, 0, pt_on_edge, NULL, &pt_edge_tol),
                      senderid = NULL_OBJID,
                      targetid = edges[ii].objid,
                      targetos = edges[ii].osnum);
      MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

      if(ele->elem_type == FIL_ELEMENT)
        {
        if( (fabs(pt_on_edge[0] - 0.0) < EQUAL_TOL) ||
            (fabs(pt_on_edge[0] - 1.0) < EQUAL_TOL)    )
          continue;  /* skip U0 & U1 edges */

        if( (fabs(pt_on_edge[1] - ele->hot_edge)) < EQUAL_TOL )
          {
          if(! aa) /* save open edge for curr ele */
            {
            ele->open_edges[ll].objid = edges[ii].objid;
            ele->open_edges[ll++].osnum = edges[ii].osnum;
            }
          else /* remove open edge for prev ele */
            {
            for(bb=0; bb<2; bb++)
              if(ele->open_edges[bb].objid == edges[ii].objid)
                ele->open_edges[bb].objid = NULL_OBJID;
            }
          }
        else if(opts&FIRST_ELE)
          {
          if(! aa) /* only for curr ele store other edge too */
            {
            ele->open_edges[ll].objid = edges[ii].objid;
            ele->open_edges[ll++].osnum = edges[ii].osnum;
            }
          }
        /* opts&FIRST_ELE */
        }
      /* FIL_ELEMENT */
      else /* ele->elem_type == SPH_ELEMENT */
        {
        if(opts&FIRST_ELE)
          {
          ele->open_edges[ii].objid = edges[ii].objid;
          ele->open_edges[ii].osnum = edges[ii].osnum;
          ele->marked_edges[ii] = -1;
          }
        else if( ((fabs(pt_on_edge[1] - ele->hot_edge)) < EQUAL_TOL) ||
                 (ele->open_edges[ii].objid != NULL_OBJID) )
          {
          ele->open_edges[ii].objid = edges[ii].objid;
          ele->open_edges[ii].osnum = edges[ii].osnum;
          }
        }
      /* SPH_ELEMENT */

      }
    /* for num_edges */

    }
  /* for aa */

ret_end:

  MEM_FREE(edges);

  EMWRAPUP (*msg, stat, "ECmf_open_edges");
  return( stat );
  
}
/* ECmf_open_edges*/

ECmf_update_edge(msg, opts, active_md_env, ele, edge)
IGRlong *msg;
IGRushort opts;
struct GRmd_env *active_md_env;
struct ele_stack *ele;
struct GRid *edge;
{
  IGRlong rc, stat;
  IGRdouble pt_on_edge[2];
  struct EMSpartolbasis pt_edge_tol;

/*
  IGRint ii;
  IGRboolean found;
*/

  opts = opts;
  active_md_env = active_md_env;
  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;
  rc = BSSUCC;

  MF_EMerr_hndlr( !(ele && edge), *msg, EMS_E_InvalidData, ret_end );

#if 0
  found = 0;
  for(ii=0; ii<3; ii++)
    if(ele->open_edges[ii].objid == edge->objid) 
      found = 1;

  if(! found)
    for(ii=0; ii<3; ii++)
      if(ele->open_edges[ii].objid == NULL_OBJID)
        ele->open_edges[ii].objid = edge->objid;

  if(! (opts&FIL_ELEMENT) ) /* update hot edge only for fillet*/
    goto ret_end;
#endif

  BSEXTRACTPAR (&rc, BSTOLLENVEC, pt_edge_tol.tol);
  MF_EMerr_hndlr (rc != BSSUCC, stat, OM_E_ABORT, ret_end);

  pt_edge_tol.is_valid = TRUE;

  /*
   * get midpt 
   */

  stat = om$send (msg = message EMSedge.EMinternalpt (msg,
                  1, 0, pt_on_edge, NULL, &pt_edge_tol),
                  senderid = NULL_OBJID,
                  targetid = edge->objid,
                  targetos = edge->osnum);
  MF_EMerr_hndlr (EMSerror (stat & *msg), stat, OM_E_ABORT, ret_end);

  ele->hot_edge = pt_on_edge[1];

ret_end:
 
  return stat;

}
/* ECmf_update_edge */

end implementation EMSsubbs;
