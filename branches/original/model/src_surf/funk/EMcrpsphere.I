/*

 * DESCRIPTION
       
    This function returns the partial sphere between three surfaces specified.

 * Inputs

    options		- ECMF_MATL_SIDE: sph patch on the material side
                          0             : sph patch on the non-material side
    const_list	        - The instance of GRvg_construct, carrying the
			  packet of information concerning the module,
			  active display parameters, etc.
    radius              - radius of the sphere
    ref_pt              - Optional.  If specified as an xyz point in model
                          space, AND if multiple sph. patches are returned by
                          math, filter out and keep only 1 patch
    pt0, pt1, pt2       - Optional, pts of contact on the 3 surfaces 
    sf0, sf1, sf2       - 3 surfaces to find ball position
    sf0_id, sf1_id, sf2_id  - Optional, GRids of the 3 input surfaces

 * Outputs

    msg			- Return codes
				EMS_S_Success
				EMS_I_SurfaceError
    sph_id	        - struct GRid of spheres.
    sph	                - Optional, bspline geometry (IGRbsp_surface) of sphere
    side_cvs[3]         - Optional, 3 arcs (IGRbsp_curve) imposed on the sphere

 * HISTORY

    nikesh: 11/19/92 : creation.
    pac   : 01/12/93 : call boolean to impose boundary
    pac   : 01/12/93 : don't need EMS_SFINT_PUSHBADCOINC in trace_opts
    Sudha : 07/06/93 : Modified for BSprototypes ansification
    pac   : ???????? : added optional ref point to filter out multiple patches.
*/

class implementation EMSsubbs;

#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsconic.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "ECmsg.h"
#include "EMSlmdef.h"
#include "emssfintdef.h"
#include "emserr.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSrnd.h"
#include "dp.h"
#include "dpmacros.h"
#include "ECmfdef.h"
#include "ECmfopt.h"

#include "bstrposfint.h"
#include "bssfkttol2.h"
#include "bssfarrevn.h"
#include "bsrev_cv.h"
#include "bspsph3pts.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsalloccv.h"

#define MEM_FREE( addr ) if ( addr ) { free ( addr ) ; addr = 0 ; }

%safe
static IGRlong                qq_get_bsgeom();  
static IGRlong                qq_orient_sph(); 
%endsafe

extern double BSdistptpt();
from EMSloopset import EMgetrange;
from EMSlinedge import EMleinit;
from EMSedge import EMreplace_edge;
from EMSloop import EMset_props;

IGRlong EMcrpsphere( msg, options, const_list, 
                     radius, ref_pt,
                     pt0, pt1, pt2,
                     sf0, sf1, sf2, 
                     sf0_id, sf1_id, sf2_id,
                     sph_id, 
                     sphere,
                     side_cvs )

IGRlong				*msg;                  
IGRushort			options;
struct GRvg_construct		*const_list;
IGRdouble			radius;                  /* i */
IGRdouble                       *ref_pt;                 /* i optional */
IGRpoint			*pt0, *pt1, *pt2;        /* i optional */
struct IGRbsp_surface		*sf0, *sf1, *sf2;        /* i optional */
struct GRid			*sf0_id, *sf1_id, *sf2_id;  /* i */
struct GRid		        *sph_id;                 /* o */
struct IGRbsp_surface		**sphere;                /* o optional */
struct IGRbsp_curve		*side_cvs[];            /* o optional */
  {
  IGRlong			stat, mloc;
  IGRdouble                     offset[3];   /* offset of each input s/f */
  IGRpoint                      *l_center=0, *center=NULL;  /* sph center */
  IGRpoint			*l_pt0=0, *l_pt1=0, *l_pt2=0;  
  IGRboolean                    filter_center, is_convex, impose_arc3,
                                nat_nor[3];
  IGRdouble                     lp_range[4], knot_tol[3], sph_knottol,
                                *uu0=0, *vv0=0, *uu1=0, *vv1=0, *uu2=0, *vv2=0,
                                *buffer=NULL, dist, min_dist;

  struct IGRbsp_surface		*sph=NULL;     /* sphere geometry */
  struct IGRbsp_surface		*sf[3];        /* array of input surfaces */
  struct GRid			*sf_id[3];     /* array if input s/f ids */
  struct BSgeom_bsp_surf        *sf_geom[3];   /* array of 3 i/p s/fs */
  struct IGRbsp_curve		*arcs[3];      /* the 3 arc bdrys of sph */ 
  GRobjid                       natural_edges[4];/* initial edges of sph patch*/
  OM_S_CHANSELECT               to_loopset;
  IGRint                        index, ii, num;
  struct EMSinters              *inters;
  IGRushort                     trace_opts, bool_opts;

  /*
   * Initialize 
   */

  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  /* data check */
  EMerr_hndlr( !( const_list && sph_id ), *msg, EMS_E_InvalidData, wrapup );
  EMerr_hndlr( !( sf0_id && sf1_id && sf2_id ), *msg, EMS_E_InvalidData, wrapup );

  sf_id[0] = sf0_id;
  sf_id[1] = sf1_id;
  sf_id[2] = sf2_id;

  sf[0] = sf0;
  sf[1] = sf1;
  sf[2] = sf2;

  sf_geom[0] = NULL;
  sf_geom[1] = NULL;
  sf_geom[2] = NULL;

  arcs[0] = NULL;
  arcs[1] = NULL;
  arcs[2] = NULL;

  offset[0] = 0.0;
  offset[1] = 0.0;
  offset[2] = 0.0;

  inters = NULL;

  /* get surface struct BSgeom_bsp_surf */
  for( ii = 0; ii < 3; ii ++ )
    {
    sf_geom[ii] = (struct BSgeom_bsp_surf *) 
                   om$malloc( size = sizeof(struct BSgeom_bsp_surf) );
    stat = qq_get_bsgeom( msg, (IGRushort)0, const_list, 
                          sf_id[ii], sf[ii], sf_geom[ii] );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, wrapup );
    }
  /* for ii */

  is_convex = options == ECMF_MATL_SIDE ? 0x01 : 0x00;

  for( ii = 0; ii < 3; ii ++ )
    {

    if(is_convex && sf_geom[ii]->bspsf->pos_orient)
      nat_nor[ii] = 1;
    if(is_convex && !sf_geom[ii]->bspsf->pos_orient)
      nat_nor[ii] = 0;
    if(!is_convex && sf_geom[ii]->bspsf->pos_orient)
      nat_nor[ii] = 0;
    if(!is_convex && !sf_geom[ii]->bspsf->pos_orient)
      nat_nor[ii] = 1;

    }
  /* for ii */

  EMmake_chanselect( EMSsubbs_to_loopset, &to_loopset );

  for( ii = 0; ii < 3; ii ++ )
    {
    /* get the range of surface sf0 */
    stat = om$send( msg = message EMSsubbs.EMgetuvrange( msg, lp_range ),
                                  targetid = sf_id[ii]->objid,
                                  targetos = sf_id[ii]->osnum,
                                  senderid = NULL_OBJID );
                      
    EMerr_hndlr( !( stat & *msg & 1 ), *msg, EMS_E_OMerror, wrapup );
                                  
    sf_geom[ii]->urange[0] = lp_range[0];
    sf_geom[ii]->vrange[0] = lp_range[1];
    sf_geom[ii]->urange[1] = lp_range[2];
    sf_geom[ii]->vrange[1] = lp_range[3];
    }
  /* for ii */

  for( ii = 0; ii < 3; ii ++ )
    {
    BSsfkttol2(sf_geom[ii]->bspsf->u_order,
               sf_geom[ii]->bspsf->v_order,
               sf_geom[ii]->bspsf->u_knots,
               sf_geom[ii]->bspsf->v_knots,
               sf_geom[ii]->bspsf->u_num_poles,
               sf_geom[ii]->bspsf->v_num_poles,
               sf_geom[ii]->bspsf->poles,
               sf_geom[ii]->bspsf->weights,
               knot_tol+ii, &mloc);

    EMerr_hndlr( ( mloc != BSSUCC ), *msg, EMS_E_BSerror, wrapup);
    }
  /* for ii */

  /* if contact points are not provided, get them */

  filter_center = 0;
  if( !( pt0 && pt1 && pt2 ) )
    {
    BStrposfint( sf_geom[0], sf_geom[1], sf_geom[2], 
                 sf_geom[0]->urange, sf_geom[0]->vrange, 
                 sf_geom[1]->urange, sf_geom[1]->vrange, 
                 sf_geom[2]->urange, sf_geom[2]->vrange, 
                 radius, nat_nor[0], nat_nor[1], nat_nor[2],
                 knot_tol[0], knot_tol[1], knot_tol[2], 
                 &num, &center, &pt0, &pt1, &pt2, 
                 &uu0, &vv0, &uu1, &vv1, &uu2, &vv2, &mloc );
#ifdef DEBUG    
    if( mloc != BSSUCC )
      printf( "EMcrp: failure in BStrposfint\n" );
#endif
    EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

    if( ref_pt && (num > 1) ) /* filter out & keep only 1 center */
      {
      filter_center = 1;
      min_dist = MAXDOUBLE;
      index = 0;

      for( ii = 0; ii < num; ii++ )
        {
        dist = BSdistptpt( &mloc, ref_pt, center[ii] );
        EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

        if( dist < min_dist )
          {
          min_dist = dist;
          index = ii;
          }
        }/* for */
      
      l_center = &center[index];
      l_pt0 = &pt0[index];
      l_pt1 = &pt1[index];
      l_pt2 = &pt2[index];
      }
    /* filter out & keep only 1 center */
      if(uu0)
	om$dealloc(ptr = uu0);
      if(uu1)
	om$dealloc(ptr = uu1);
      if(vv0)
	om$dealloc(ptr = vv0);
      if(vv1)
	om$dealloc(ptr = vv1);
      if(vv2)
	om$dealloc(ptr = vv2);
      if(uu2)
	om$dealloc(ptr = uu2);

    }
  /* if ! 3 pts */

  if(! filter_center)
    {
    l_center = center;
    l_pt0 = pt0;
    l_pt1 = pt1;
    l_pt2 = pt2;
    }

  /* allocate memory for the arcs */
  for( ii = 0; ii < 3; ii ++ )
    {
    BSalloccv( ( IGRshort ) 3,
               BSCIRCLE_NUM_POLES_MAX,
               TRUE,
               ( IGRshort ) 0,
               &arcs[ ii ],
               &mloc
             );

    EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_NoDynamicMemory, wrapup );
    }
  /* for ii */

  /*
   * Obtain memory for the poles, knots and weights of the spherical
   * patch.
   */
  num = /* Space for the partial sphere's poles */

        ( BSCIRCLE_NUM_POLES_MAX * BSCIRCLE_NUM_POLES_MAX * 3 +

        /* space for the partial sphere's weights */

          BSCIRCLE_NUM_POLES_MAX * BSCIRCLE_NUM_POLES_MAX +

        /* space for u_knots and v_knots */

          ( BSCIRCLE_NUM_POLES_MAX + 3 ) * 2 );

  buffer = ( IGRdouble * ) om$malloc( size = num * sizeof( IGRdouble ) );

  EMerr_hndlr( ! buffer , *msg, EMS_E_NoDynamicMemory, wrapup );

  ii = 0;

  sph = ( struct IGRbsp_surface * ) om$malloc( size = sizeof( struct IGRbsp_surface ) );
  sph->poles = &buffer[ ii ];
  ii += BSCIRCLE_NUM_POLES_MAX * BSCIRCLE_NUM_POLES_MAX * 3;

  sph->weights = &buffer[ ii ];
  ii += BSCIRCLE_NUM_POLES_MAX * BSCIRCLE_NUM_POLES_MAX;

  sph->u_knots = &buffer[ ii ];
  ii += BSCIRCLE_NUM_POLES_MAX + 3;

  sph->v_knots = &buffer[ ii ];
  buffer = NULL;

  BSpsph3pts( *l_center,
              *l_pt0, *l_pt1, *l_pt2,
              sph,
              arcs,
              &impose_arc3,
              &mloc );

  EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

  stat = qq_orient_sph( msg, options, uu0, vv0, sf_geom[0]->bspsf, sph ); 
  EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_BSerror, wrapup );

  /*
   * Determine the knot tolerance for the spherical vertex patch.
   */
  BSsfkttol2( sph->u_order,
              sph->v_order,
              sph->u_knots,
              sph->v_knots,
              sph->u_num_poles,
              sph->v_num_poles,
              sph->poles,
              sph->weights,
              &sph_knottol,
              &mloc );

  EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

  /*
   * construct a graphic object out of the spherical patch
   */
  const_list->geometry = ( IGRchar *) sph;
  sph_id->osnum = const_list->env_info->md_id.osnum;
  stat = om$construct( classname = "EMSpsphere",
                       osnum = sph_id->osnum,
                       p_objid   = &sph_id->objid,
                       msg       = message GRgraphics.GRconstruct
                                   ( const_list )
                     );
  EMerr_hndlr( !( 1 & stat ), *msg, EMS_E_OMerror, wrapup );

  /*
   * Make natural boundaries for the vertex patch.
   */
  stat = om$send( msg = message EMSsurface.EMmk_nat_bdry(
                                msg,
                                &const_list->env_info->md_env,
                                natural_edges ),
                                targetos = sph_id->osnum,
                                senderid = NULL_OBJID,
                                targetid = sph_id->objid );

  EMerr_hndlr( !(1 & stat & *msg), *msg, EMS_E_OMerror, wrapup );

  /*
   * The following notes have been extracted from EMrndsphbln.I
   *
   * At this point, the geometry and the topology of the spherical patch is
   * established.  The remaining work is as follows.
   *
   * 1 it is possible that arc3 does not form a natural boundary of the 
       spherical  patch (i.e. the patch extends beyond arc3, which is between 
       points 2 and 3).  If so,  impose that arc as the boundary of the 
       spherical patch between points 2 and 3
   *
   *   NOTE:
   *   The correspondence between, the array of arcs and the array of 
       natural edges of that patch is as follows.
   *   arcs[ 0 ] -> natural_edges[ 3 ], V=0
   *   arcs[ 1 ] -> natural_edges[ 1 ], V=0
   *   arcs[ 2 ] -> natural_edges[ 2 ], U=1
   *   Note that U=0 edge on the spherical patch is degenerate in XYZ space.
   *
   *   Since arc three is parameterized from second point to the third on
   *   the spherical patch, its direction needs to be reversed prior to
   *   imposing it, so that when it is mapped onto the UV space of the patch,
   *   its orientation will be correct with respect to the other edges in
   *   that space.
   *
   * 2 On imposing arc3, it is possible that the corresponding ends on arcs
   *   one and two are not coincident with those of arc3.  Make necessary
   *   corrections to the appropriate ends of arcs 1 and 2.
   *
   */
  /*
   * Re-orient arcs 3, so that it matches the orientation
   * of the natural edges in UV space.
   * The arcs at this stage are guaranteed to be bsp curves.
   */

  BSrev_cv( &mloc, arcs[2] );
  EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

  if( impose_arc3 )
    {
    stat = EMcvsfinters( &mloc, NULL, const_list->env_info, 
                         arcs[2], sph_id, sph, &inters, NULL );
    
    EMerr_hndlr( !( mloc & stat & 1 ), *msg, EMS_E_Fail, wrapup );

    /*
     * I am told the curve is already oriented, just do the boolean to impose
     */

    trace_opts = EMS_SFINT_MUSTORIENT |
                 EMS_SFINT_MUSTNOAMBIGUOUS | EMS_SFINT_SKIPSFINT |
                 EMS_SFINT_CHTTRACETOL;

    bool_opts = EMSsfbool_opt_SingleTopology | EMSsfbool_opt_noredraw;

    dp$display(msg = &stat, oids = sph_id, mode = GRbe);

    stat = EMimpose_boundary_w_intersection(&mloc, trace_opts, bool_opts,
                                            const_list->env_info,
                                            sph_id->objid, inters, NULL_OBJID,
                                            NULL, NULL);
    EMerr_hndlr ( EMSerror (stat & mloc), *msg, EMS_E_Fail, wrapup );

    }
  /* if arc to be imposed */
    
  if( side_cvs )
    {
    for( ii = 0; ii < 3; ii++ )
      side_cvs[ii] = arcs[ii], arcs[ii] = NULL;
    }
  /* if side_cvs */


  if( sphere )
    {
    *sphere = sph;
    }
  /* if sphere */

wrapup:

  /* since sf0, sf1, sf2 are optional inputs, free'em if reqd. */
  if( sf0 )
    sf_geom[0]->bspsf = sf[0] = NULL;
  else
    {
    if( sf_geom[0] )
      {
      if(sf_geom[0]->bspsf)
        om$dealloc(ptr = sf_geom[0]->bspsf);
      sf_geom[0]->bspsf = NULL;
      }
    if( sf[0] )
      {
      BSfreesf( &mloc, sf[0] );
      }
    }
  if( sf1 )
    sf_geom[1]->bspsf = sf[1] = NULL;
  else
    {
    if( sf_geom[1] )
      {
      if(sf_geom[1]->bspsf)
        om$dealloc(ptr = sf_geom[1]->bspsf);
      sf_geom[1]->bspsf = NULL;
      }
    if( sf[1] )
      BSfreesf( &mloc, sf[1] );
    }
  if( sf2 )
    sf_geom[2]->bspsf = sf[2] = NULL;
  else
    {
    if( sf_geom[2] )
      {
      if(sf_geom[2]->bspsf)
        om$dealloc(ptr = sf_geom[2]->bspsf);
      sf_geom[2]->bspsf = NULL;
      }
    if( sf[2] )
      BSfreesf( &mloc, sf[2] );
    }
  for( ii = 0; ii < 3; ii ++ )
    {
    MEM_FREE( sf_geom[ii] );
    BSfreecv( &mloc, arcs[ii] );
    }
  MEM_FREE( buffer )

  if(EMSerror(stat & *msg))
    {
    IGRlong unused;
    om$send( msg = message GRgraphics.GRdelete( &unused, const_list->env_info),
             senderid = NULL_OBJID,
             targetos = sph_id->osnum,
             targetid = sph_id->objid);
    dp$display(msg = &unused, oids = sph_id, mode = GRbe);
    }
  else
    dp$display(msg = &stat, oids = sph_id, mode = GRbd);


  if(l_center)
   {
/* fix for mlk */
   om$dealloc(ptr = l_center);
   l_center = NULL;
   }
  return stat;
  }
/* EMcrpsphere */


/* given the surface id, this function gets geometry */
static IGRlong qq_get_bsgeom( msg, options, const_list, sf_id, sf, sf_geom )  
IGRlong                 *msg;                  
IGRushort               options;
struct GRvg_construct	*const_list;       /* i */
struct GRid             *sf_id;             /* i GRid of the input surface */
struct IGRbsp_surface   *sf;               /* i optional */
struct BSgeom_bsp_surf  *sf_geom;         /* o */
  {
  IGRlong            stat;
  IGRshort           *mattyp;
  IGRdouble          *mat=NULL;
  struct GRmd_env    *md_env=NULL;
  extern IGRlong     EMgetvggeom();
  extern void        getsftype();

  options = options; /* make apogee happy */
  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  md_env = const_list->env_info;
  mattyp = &md_env->md_env.matrix_type;
  mat = &md_env->md_env.matrix[0];

  if( !sf )
    {
    stat = EMgetvggeom( msg,
                        mattyp,
                        mat, 
                        sf_id,
                        ( IGRchar ** ) &sf,
                        NULL
                      );
    EMerr_hndlr( !( *msg & stat & 1 ), *msg, EMS_E_SurfaceError, wrapup );
    }
  /* if no IGRbsp_surface */

  sf_geom->bspsf = sf;
  getsftype( sf_id->objid, md_env->md_id.osnum, &sf_geom->type );
  sf_geom->bounded = TRUE;
  sf_geom->urange[0] = sf_geom->vrange[0] = 0.0;
  sf_geom->urange[1] = sf_geom->vrange[1] = 1.0;
  sf_geom->sfgen_cv = NULL;
  sf_geom->geom_prop = FALSE;

wrapup:

  return stat;
  }
/* qq_get_bsgeom */


/* this function orients the spherical patch based on the orientation of 
   the input surfaces */
static IGRlong qq_orient_sph( msg, options, uu, vv, sf, sph )
IGRlong                *msg;     /* i */
IGRushort              options;  /* i */
IGRdouble              *uu, *vv; /* i par values */
struct IGRbsp_surface  *sf;      /* i one of the input surfaces */
struct IGRbsp_surface  *sph;     /* io sph patch with pos_orient set */
  {
  IGRlong              stat, mloc;
  IGRvector            vector1,
                       vector2;
  IGRpoint             pt_on_srf;
  IGRdouble            temp1,
                       temp2;
  IGRint               ii;

  options = options; /* make apogee happy */
  *msg = EMS_S_Success;
  stat = OM_S_SUCCESS;

  /*
   * Obtain the vertex patch normal at (0,0)
   */
  
  EMerr_hndlr( !( sf && sph ), *msg, EMS_E_BSerror, wrapup );
  temp1 = temp2 = 0.0;
  BSsfarrevn( &mloc,
              sph,
              ( IGRint ) 1,
              &temp1,
              ( IGRint ) 1,
              &temp2,
              pt_on_srf,
              vector1 );

  EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

  /* 
   * Obtain the normal at the intersection point on the first
   * surface.
   */
  BSsfarrevn( &mloc,
              sf,
              ( IGRint ) 1,
              uu,
              ( IGRint ) 1,
              vv,
              pt_on_srf,
              vector2 );

  EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

  /*
   * if the pos orient is false reverse the normal vector.
   */
  if( sf->pos_orient == FALSE )
    for( ii = 0; ii < 3; ii++ )
      vector2[ ii ] = -vector2[ ii ];

  /*
   * Orient the vertex patch normal.
   */
  temp1 = BSdotp( &mloc, vector1, vector2 );
  EMerr_hndlr( mloc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

  sph->pos_orient = temp1 > 0.0 ? TRUE : FALSE;

wrapup:
  return stat;
  }
/* qq_orient_sph */


end implementation EMSsubbs;
