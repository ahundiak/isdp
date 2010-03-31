class implementation EMSsubbs;

#include "OMmacros.h"
#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bssfeval.h"
#include "bscveval.h"
#include "bsalloccv.h"
#include "bsallocsf.h"
#include "bsmdistptcv.h"
#include "bsmdistptsf.h"
#include "bsreffilsrf.h"
#include "bsfilsfedit.h"
#include "bssfkttol2.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"


#define U0 		0
#define U1		1
#define NUM_SURFACES	5
#define UV_DIM		2
#define u		0
#define v		1

#define MAX_U_POLES_FOR_REFINED_FILLETS		7


%safe

static IGRlong fit_new_fillet( IGRlong* EMmsg,
           struct IGRbsp_surface *sf1, struct IGRbsp_surface  *sf2,
           struct IGRbsp_surface *fillet, IGRboolean u0_flow_on_fillet,
           IGRdouble pt1_uv[2], IGRdouble pt2_uv[2], IGRpoint pt1_xyz,
           IGRboolean nor1, IGRboolean nor2,
           IGRdouble radius, IGRdouble *input_rho,
           struct IGRbsp_surface **mod_fillet );

static IGRlong get_arc_app_end_pt( IGRlong *EMmsg,
           struct IGRbsp_surface *fillet, struct IGRbsp_surface *sf,
           IGRpoint pt_to_project, IGRint proj_iso_on_fil,
           IGRdouble sf_pt_uv[2], IGRpoint *sf_pt_xyz );

%endsafe

typedef	IGRdouble UV_PT[2];


/*
 * DESCRIPTION:
      This function refines two fillet surfaces to pass through a point on a
      surface.  The two fillet surfaces must be defined on three surfaces.
      Thus one of the three surfaces will be common to the two fillets, and
      the point through which the two fillets are being refined to pass
      through is on this surface.

 * OPTIONS:
      mod_fillet1, mod_fillet2,
      pts_uv, pts_xyz		Any of these (but not all) could be NULL.

 * INPUT:
      md_env		Module_environment.
      fillet1, fillet2  The two fillets, sharing a common surface, that are
                        to be refined. Must be objects or bspline surfaces.
      sf1, sf2, sf3     sf1, sf2 are the two surfaces defining fillet1.
                        sf2, sf3 are the two surfaces defining fillet2.
                        Must be objects or bspline surfaces.
      u0_flow_on_fillets [0] if TRUE then fillet1 u0 is on sf1 else
                             fillet1 u0 is on sf2
                         [1] if TRUE then fillet2 u0 is on sf3, else
                             fillet2 u0 is on sf2.
      rad1, rad2	Radii of fillet1 and fillet2, respectively.
      input_rho		The fillet conic section specifier.  Currently
                        not supported. Caller should pass in NULL in which
                        case the default BSRHO_VALUE is used.
      nor11             TRUE: fillet1 is on natural normal side of sf1.
                        FALSE : fillet1 is on opposite side of natural normal
                                of sf1.
      nor12             As above, for fillet1 on sf2.
      nor23             As above, for fillet2 on sf3.
      nor22             As above, for fillet2 on sf2.
      pt2 		The u,v parameters of a point on sf2 that is close to
                        the actual point through which the fillets are to
                        pass through.  This point must be close to the two
                        fillets appropriate iso edges (thus the minimum
                        distance between this point and the respective iso
                        edge of each fillet should yeild a unique point).

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      mod_fillet1,
      mod_fillet2       The modified fillet surfaces.
                        Memory will be allocated by this function.  The caller
                        should deallocate through a BSfreesf() call.
      pts_uv		The new fillet arcs end points on sf1, sf2, and
                        sf3, in parametric space.  The caller must allocate
                        memory for six doubles.
      pts_xyz		The xyz points corresponding to those in 'pts_uv'.
                        The caller must allocate memory for 3 IGRpoints.

 * ALGORITHM:
      Obtain the accurate circular fillet arcs, emanating from the visinity of
      pt2, on each fillet, such that both arcs share a common point on sf2
      (the common defining surface for the two fillets)  Reconstruct each
      fillet to pass through the corresponding new arc.

 * HISTORY:
      Janaka : 01/20/93 : Original.
      Sudha  : 07/06/93 : Modified for BSprototypes ansification
*/

#argsused

IGRlong	EMtwo_fillet_refine( EMmsg, options, md_env,
             fillet1, fillet2, rad1, rad2, input_rho, sf1, sf2, sf3,
             u0_flow_on_fillets, nor11, nor12, nor22, nor23,
             pt2, mod_fillet1, mod_fillet2, pts_uv, pts_xyz )

IGRlong			*EMmsg;
IGRushort		options;
struct GRmd_env		*md_env;
struct EMSdataselect	*fillet1, *fillet2, *sf1, *sf2, *sf3;
IGRdouble		rad1, rad2, *input_rho, pt2[2];
UV_PT			*pts_uv;
IGRboolean		u0_flow_on_fillets[2],
                        nor11, nor12, nor22, nor23;
struct IGRbsp_surface	**mod_fillet1, **mod_fillet2;
IGRpoint		*pts_xyz;
{
   IGRboolean   sf_geom_constructed[5], BSstatus;
   IGRshort	i;
   IGRlong	OM_stat, msg;
   IGRdouble	knot_tol[3], loc_pts[3][2];
   IGRpoint	intersect_pt, pt2_xyz;

   struct BSgeom_bsp_surf	sf_info[5];


   /* STEP 0: Initialization. */
      *EMmsg = EMS_S_Success;
      OM_stat = OM_S_SUCCESS;
      EMerr_hndlr( input_rho, *EMmsg, EMS_E_InvalidArg, wrapup );

   /* STEP 1: Get fillets and surfaces related information. */

      for( i = 0; i < NUM_SURFACES; i++ )
      {
         sf_info[i].bspsf = NULL;
         sf_geom_constructed[i] = FALSE;
      }

      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, fillet1,
                      &sf_info[0], &sf_geom_constructed[0] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, fillet2,
                      &sf_info[1], &sf_geom_constructed[1] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, sf1,
                      &sf_info[2], &sf_geom_constructed[2] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, sf2,
                      &sf_info[3], &sf_geom_constructed[3] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, sf3,
                      &sf_info[4], &sf_geom_constructed[4] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );

      for( i = 0; i < 3; i++ )
      {
            BSsfkttol2( sf_info[i+2].bspsf->u_order,
		        sf_info[i+2].bspsf->v_order,
                        sf_info[i+2].bspsf->u_knots,
		        sf_info[i+2].bspsf->v_knots,
                        sf_info[i+2].bspsf->u_num_poles,
		        sf_info[i+2].bspsf->v_num_poles,
                        sf_info[i+2].bspsf->poles,
		        sf_info[i+2].bspsf->weights,
                        &knot_tol[i],
		        &msg );

           EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      }

      BSsfeval( sf_info[3].bspsf, pt2[0], pt2[1], ( IGRint ) 0, &pt2_xyz,
                &msg );
      EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

      /* Generate the approximate arc end point on 'sf1' */
         OM_stat = get_arc_app_end_pt( &msg, sf_info[0].bspsf,
                      sf_info[2].bspsf, pt2_xyz, 
                      u0_flow_on_fillets[0] == TRUE ? U1 : U0,
                      loc_pts[0], NULL );
      /* Generate the approximate arc end point on 'sf2' */
         OM_stat = get_arc_app_end_pt( &msg, sf_info[1].bspsf,
                      sf_info[4].bspsf, pt2_xyz,
                      u0_flow_on_fillets[1] == TRUE ? U1 : U0,
                      loc_pts[2], NULL );
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

      OM_BLOCK_MOVE( pt2, loc_pts[1], UV_DIM * sizeof( IGRdouble ) );

   /* STEP 2: Get the correct circular arcs for the two fillets. */
      BSfilsfedit( &sf_info[3], &sf_info[2], &sf_info[4],
                   rad1, rad2,
                   nor12, nor22, nor11, nor23,
                   knot_tol[0], knot_tol[1], knot_tol[2],
                   &loc_pts[1][u], &loc_pts[1][v], &loc_pts[0][u],
                   &loc_pts[0][v], &loc_pts[2][u], &loc_pts[2][v],
                   intersect_pt, &BSstatus, &msg );
      EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   /* STEP 3:
    *   Refine each of the fillets, such that the circular arc defined by
    *   loc_pts[1],loc_pts[0] is on fillet1, and the circular arc defined by
    *   loc_pts[1],loc_pts[2] is on fillet2.
    */
       /* Do fillet1 */
          if( mod_fillet1 )
          {
             OM_stat = fit_new_fillet( &msg,
                  sf_info[3].bspsf, sf_info[2].bspsf, sf_info[0].bspsf,
                  u0_flow_on_fillets[0] == TRUE ? FALSE : TRUE,
                  loc_pts[1], loc_pts[0], intersect_pt,
                  nor12, nor11, rad1, NULL, mod_fillet1 );
             EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail,
                          wrapup );
          }

       /* Do fillet2 */
          if( mod_fillet2)
          {
             OM_stat = fit_new_fillet( &msg,
                  sf_info[3].bspsf, sf_info[4].bspsf, sf_info[1].bspsf,
                  u0_flow_on_fillets[1] == TRUE ? FALSE : TRUE,
                  loc_pts[1], loc_pts[2], intersect_pt,
                  nor22, nor23, rad2, NULL, mod_fillet2 );
             EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail,
                          wrapup );
          }

   /* STEP 4: Assign output. */
      if( pts_uv )
         OM_BLOCK_MOVE( loc_pts, pts_uv, UV_DIM*3*sizeof( IGRdouble ) );

      if( pts_xyz )
         for( i = 0; i < 3; i++ )
         {
            BSsfeval( sf_info[i+2].bspsf, loc_pts[i][u], loc_pts[i][v], 0,
                      pts_xyz, &msg );
            EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
            pts_xyz++;
         }

wrapup:

   for( i = 0; i < NUM_SURFACES; i++ )
      if( sf_geom_constructed[i] == TRUE )
         om$dealloc( ptr = sf_info[i].bspsf );

   EMWRAPUP( *EMmsg, OM_stat, "EMtwo_fillet_refine" );
   return( OM_stat );
}



/*
 * DESCRIPTION:
      Given a fillet (f) and three surfaces (s1, s2, s3) such that two of the
      surfaces (s1, s2) are the defining surfaces of the fillet, find the
      exact circular arc that is emanating fron the intersection point of
      f, s1, s3.
      Optionally, modify the fillet to include the newly created circular arc
      (consequently, the caller may use this function repeatedly to find one
      or more such circular arcs, and trivially perform a call to
      BSreffilsf() to modify the fillet to pass through all the arcs.  This
      will result in a single modification of the fillet, as opposed to
      mutiple modifications, during each and every call to this function).

 * OPTIONS:
     1. mod_fillet	This may be NULL. This option is typically used to
                        obtain the accurate arc end points without refining
                        the fillet to pass through that arc.
     2. arc_begin_pt_uv,
        arc_end_pt_uv,
        arc_begin_pt_xyz Any one or all could be NULL.  Typically used, if
                         'mod_fillet' is not NULL.

     NOTE: 1 AND all of 2 cannot be NULL.

 * INPUT:
      options		None.
      fillet            
      sf1, sf2		The defining surfaces for the fillet.
      sf3               The constraining surface on which one of the ends of
                        the arc must lie on.
      app_pt_on_sf1     A point on sf1 that is close to one end of the arc
                        that is to be generated.  This point must be close to
                        the approrpiate iso edge on the fillet such that the
                        minimum distance between this point and the fillet iso
                        should yeild a unique point.
      radius		Fillet radius.
      input_rho		The conic section specifier for the fillet.  Currently
                        not supported, thus passed in as NULL by the caller
                        (in which case BSRHO_VALUE is used).
      nor1              if fillet is on the natural normal side of sf1 then
                        TRUE, else FALSE.
      nor2              if fillet is on the natural normal side of sf2 then
                        TRUE, else FALSE.
      u0_flow_on_fillet TRUE: fillet u0 is on sf1, else it is on sf2.

 * OUTPUT:
      EMmsg		EMS error.
      return value	OM errors.

      For the following, memory must be allocated by the caller.
         arc_begin_pt_xyz  Refined xyz point corresponding to 'app_pt_on_sf1'.
         arc_begin_pt_uv   New fillet arc begin point on surface sf1.
         arc_end_pt_uv     New fillet arc end point on surface sf2.
      
      mod_fillet	The new fillet.

 * ALGORITHM:
      Quite trivial.

 * HISTORY:
      Janaka : 01/22/93 : Original.
 */

#argsused

IGRlong EMsingle_fillet_refine( EMmsg, options, md_env, fillet,
                sf1, sf2, sf3, app_pt_on_sf1, u0_flow_on_fillet, radius,
                input_rho, nor1, nor2, mod_fillet, arc_begin_pt_xyz,
                arc_begin_pt_uv, arc_end_pt_uv )

IGRlong			*EMmsg;
IGRushort		options;
struct GRmd_env		*md_env;
struct EMSdataselect	*fillet, *sf1, *sf2, *sf3;
IGRdouble		app_pt_on_sf1[2], radius, *input_rho,
                        *arc_begin_pt_uv, *arc_end_pt_uv;
IGRpoint                *arc_begin_pt_xyz;
IGRboolean		nor1, nor2, u0_flow_on_fillet;
struct IGRbsp_surface	**mod_fillet;
{
   IGRboolean	sf_geom_constructed[5], BSstatus;
   IGRshort	i;
   IGRlong	OM_stat, msg;
   IGRdouble	knot_tol[3], pt1[2], pt2[2], pt3[2],
                min_dist;
   IGRpoint	intersect_pt, pt1_xyz, pt2_xyz, dum_pt;

   struct BSgeom_bsp_surf	sf_info[5];


   /* STEP 0: Initialization. */
      OM_stat = OM_S_SUCCESS;
      *EMmsg = EMS_S_Success;
      EMerr_hndlr( input_rho ||
                   ( !arc_begin_pt_xyz && !arc_begin_pt_uv && !arc_end_pt_uv
                     && !mod_fillet ), 
                   *EMmsg, EMS_E_InvalidArg, wrapup );

      OM_BLOCK_MOVE( app_pt_on_sf1, pt1, 2*sizeof( IGRdouble ) );


   /* STEP 1:  Get surface information on input fillets and surfaces. */

      for( i = 0; i < NUM_SURFACES; i++ )
      {
         sf_info[i].bspsf = NULL;
         sf_geom_constructed[i] = FALSE;
      }

      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, fillet,
                      &sf_info[0], &sf_geom_constructed[0] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );

      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, sf1,
                      &sf_info[1], &sf_geom_constructed[1] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, sf2,
                      &sf_info[2], &sf_geom_constructed[2] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );
      OM_stat = EMget_sf_BSgeom_info( &msg, md_env, sf3,
                      &sf_info[3], &sf_geom_constructed[3] );
      EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_SurfaceError,
                   wrapup );

      for( i = 0; i < 3; i++ )
         if( sf_info[ i+1 ].type == BSGEN_BSP_SF )
         {
           BSsfkttol2( sf_info[i+1].bspsf->u_order,
		       sf_info[i+1].bspsf->v_order,
                       sf_info[i+1].bspsf->u_knots,
		       sf_info[i+1].bspsf->v_knots,
                       sf_info[i+1].bspsf->u_num_poles,
		       sf_info[i+1].bspsf->v_num_poles,
                       sf_info[i+1].bspsf->poles,
		       sf_info[i+1].bspsf->weights,
                       &knot_tol[i],
   		       &msg );

           EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         }

      /* Obtain the approximate arc end point on sf2 */
         BSsfeval( sf_info[1].bspsf, pt1[0], pt1[1], ( IGRint ) 0, &pt1_xyz,
                   &msg );
         EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
         OM_stat = get_arc_app_end_pt( &msg, sf_info[0].bspsf,
                           sf_info[2].bspsf, pt1_xyz,
                           u0_flow_on_fillet == TRUE ? U0 : U1,
                           pt2, &pt2_xyz );
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

      /* Generate pt3 on sf3 */
         if( sf_info[3].type == BSGEN_BSP_SF )
         {
            BSmdistptsf( &msg, sf_info[3].bspsf, pt1_xyz, &pt3[0], &pt3[1],
                         dum_pt, &min_dist );
            EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
         }

   /* STEP 2: Get the correct circular arcs for the two fillets. */
      BSfilsfedit( &sf_info[1], &sf_info[2], &sf_info[3],
                   radius, ( IGRdouble ) 0.0,
                   nor1, FALSE, nor2, FALSE,
                   knot_tol[0], knot_tol[1], knot_tol[2],
                   &pt1[0], &pt1[1], &pt2[0], &pt2[1], &pt3[0], &pt3[1],
                   intersect_pt, &BSstatus, &msg );
      EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

      /* For single fillet refinement, 'intersect_pt' is undefined.
       * Force it to be the refined point on 'sf_info[1]'.
       */
         BSsfeval( sf_info[1].bspsf, pt1[u], pt1[v], (IGRint ) 0,
                   &intersect_pt, &msg );
         EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );


   /* STEP 3:
    *   Refine the fillet, such that the circular arc defined by
    *   pt1,pt2 is on fillet.
    */
       if( mod_fillet )
       {
          OM_stat = fit_new_fillet( &msg, sf_info[1].bspsf,
                         sf_info[2].bspsf, sf_info[0].bspsf,
                         u0_flow_on_fillet,
                         pt1, pt2, intersect_pt, nor1, nor2,
                         radius, NULL, mod_fillet );
          EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );
       }

   /* Assign output. */
      if( arc_begin_pt_xyz )
         OM_BLOCK_MOVE( intersect_pt, arc_begin_pt_xyz, sizeof( IGRpoint ) );
      if( arc_begin_pt_uv )
         OM_BLOCK_MOVE( pt1, arc_begin_pt_uv, 2*sizeof( IGRdouble ) );
      if( arc_end_pt_uv )
         OM_BLOCK_MOVE( pt2, arc_end_pt_uv, 2*sizeof( IGRdouble ) );

wrapup:

   for( i = 0; i < NUM_SURFACES; i++ )
      if( sf_geom_constructed[i] == TRUE )
         om$dealloc( ptr = sf_info[i].bspsf );

   EMWRAPUP( *EMmsg, OM_stat, "EMsingle_fillet_refine" );
   return( OM_stat );
}

      

/*
 * DESCRIPTION:
      Given a fillet 'f', a model space point 'p' that is close to either u0
      or u1 fillet iso edges, the defining surface 's' of the fillet such that
      point 'p' is on the other defining surface of the fillet, this function
      determines the point on 's' that is on the opposing end (from point 'p')
      of the fillet arc extracted from the visinity of point 'p'.

 * OPTIONS:
      sf_pt_xyz		Could be NULL.

 * INPUT:
      fillet		Fillet surface;
      sf		A defining surface of the fillet, on which the arc
                        end point is found.
      pt_to_project	A model space point close to either u0 or u1 of fillet
                        (closeness MUST be such that, the minimum distance
                        evaluation from this point onto the appropriate fillet
                        iso edge should yeild a unique point).
      proj_iso_on_fil   Either fillet u0 or u1.  'pt_to_project' is projected
                        onto this fillet iso edge.

 * OUTPUT:
      EMmsg		EMS errors.
      return value      OM errors.
      sf_pt_uv          (u,v) of the fillet arc approximate end point on 'sf'.
      sf_pt_xyz         Model space point of the preceding.

 * ALGORITHM:
      . Extract the geometry of the fillet u-constant iso edge to which the
        'pt_to_project' is to be projected on.
      . Project 'pt_to_project' onto the preceding curve. Let it be p1.
      . Extract the fillet v-constant iso edge at v(p1).
      . Obtain the end point of the preceding v-constant iso edge, which is
        at the opposing end from p1.  Project that point onto 'sf'.

 * HISTORY:
      Janaka : 01/26/93 : Original.
 */

static IGRlong get_arc_app_end_pt( IGRlong *EMmsg,
           struct IGRbsp_surface *fillet, struct IGRbsp_surface *sf,
           IGRpoint pt_to_project, IGRint proj_iso_on_fil,
           IGRdouble sf_pt_uv[2], IGRpoint *sf_pt_xyz )
{
   IGRboolean	test_planarity;
   IGRshort	k, n, loc_opts, i;
   IGRlong	OM_stat, msg;
   IGRdouble	extract_param, *cv_params, *intpars, min_dist, bas_tol,
                uv[2];
   IGRpoint     fil_arc_start_pt, fil_arc_end_pt, dum_pt;
   
   struct IGRbsp_curve	*iso_edge_geom;


   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   BSEXTRACTPAR( &msg, BSTOLLENVEC, bas_tol );
   iso_edge_geom = NULL;
   cv_params = NULL;
   intpars = NULL;

   BSalloccv( fillet->v_order, fillet->v_num_poles, fillet->rational,
             ( IGRshort ) 0, &iso_edge_geom, &msg );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
   loc_opts = 1;			/* u constant curve */
   extract_param = proj_iso_on_fil;
   BSconstprcv( &msg, fillet, &loc_opts, &extract_param,
                &test_planarity, iso_edge_geom );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   BSmdistptcv( iso_edge_geom, pt_to_project, &k, &n, &cv_params,
                &min_dist, &intpars, &msg );
   EMerr_hndlr( msg != BSSUCC || n != 1, *EMmsg, EMS_E_BSerror, wrapup );
   BScveval( iso_edge_geom, *cv_params, ( IGRint ) 0,
             &fil_arc_start_pt, &msg );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   BSfreecv( &msg, iso_edge_geom );
   iso_edge_geom = NULL;

   /* Project the fillet start xyz point onto the fillet to obtain the
    * v parameter on the fillet at which the constant v iso is to be
    * extracted.
    */
       BSmdistptsf( &msg, fillet, fil_arc_start_pt, &uv[0],
                    &uv[1], dum_pt, &min_dist );
       EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   BSalloccv( fillet->u_order, fillet->u_num_poles, fillet->rational,
             ( IGRshort ) 0, &iso_edge_geom, &msg );
   loc_opts = 2;
   BSconstprcv( &msg, fillet, &loc_opts, &uv[1], &test_planarity,
                iso_edge_geom );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   OM_BLOCK_MOVE( iso_edge_geom->poles, fil_arc_end_pt,
                  sizeof( IGRpoint ) );
   if( iso_edge_geom->rational && iso_edge_geom->weights != NULL )
      for( i = 0; i < 3; i++ )
         fil_arc_end_pt[i] /= iso_edge_geom->weights[0];

   if( EMis_geomequal_3dpt ( fil_arc_start_pt, fil_arc_end_pt, bas_tol )
           == TRUE )
   {
      OM_BLOCK_MOVE( 
         &iso_edge_geom->poles[ (iso_edge_geom->num_poles - 1) * 3 ],
         fil_arc_end_pt,
         sizeof( IGRpoint ) );
      if( iso_edge_geom->rational && iso_edge_geom->weights != NULL )
         for( i = 0; i < 3; i++ )
            fil_arc_end_pt[i] /= iso_edge_geom->weights[
                                         iso_edge_geom->num_poles - 1 ];
   }

   BSmdistptsf( &msg, sf, fil_arc_end_pt, &sf_pt_uv[0], &sf_pt_uv[1],
                ( sf_pt_xyz ? *sf_pt_xyz : dum_pt ), &min_dist );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

wrapup:

   if( iso_edge_geom )
      BSfreecv( &msg, iso_edge_geom );
   if( cv_params )
      free( ( void * ) cv_params );
   if( intpars )
      free( ( void * ) intpars );

   EMWRAPUP( *EMmsg, OM_stat, "get_arc_app_end_pts" );
   return( OM_stat );
} 



/*
 * DESCRIPTION:
      This function accepts the end points of an accurate fillet arc, and
      refits the input fillet to pass through that new fillet arc.

 * OPTIONS:
      None.

 * INPUT:
      sf1, sf2		The two defining surfaces of the fillet.
      fillet            The input fillet.  This is untouched.
      u0_flow_on_fillet	If U0 of fillet is on sf1, then TRUE, else FALSE.
      pt1_uv		Fillet arc end point on sf1.
      pt2_uv		Fillet arc end point on sf2.
      pt1_xyz		The model space point corresponding to pt1_uv.
      nor1              If fillet is on natural normal side of sf1, then TRUE,
                        else FALSE.
      nor2		As aboce, on sf2.
      radius            fillet radius.
      input_rho		Conic section specifier for the fillet.  Currently
                        passed in as NULL.

 * OUTPUT:
      EMmsg		EMS errors.
      return value	OM errors.
      mod_fillet	A new fillet surface that includes the input fillet
                        arc.  Memory is allocated by this function.

 * ALGORITHM:
      Trivial.

 * HISTORY:
      Janaka : 02/11/93 : Original.
 */

static IGRlong fit_new_fillet( IGRlong* EMmsg,
           struct IGRbsp_surface *sf1, struct IGRbsp_surface  *sf2,
           struct IGRbsp_surface *fillet, IGRboolean u0_flow_on_fillet,
           IGRdouble pt1_uv[2], IGRdouble pt2_uv[2], IGRpoint pt1_xyz,
           IGRboolean nor1, IGRboolean nor2,
           IGRdouble radius, IGRdouble *input_rho,
           struct IGRbsp_surface **mod_fillet )

{
   IGRint	numu0, numu1;
   IGRlong	OM_stat, msg;
   IGRdouble	*pts_on_u0, *pts_on_u1;
   IGRdouble    *u0_params, *v0_params, *u1_params, *v1_params,
                *u0_opp_params, *v0_opp_params, *u1_opp_params,
                *v1_opp_params, rho_value;


   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   EMerr_hndlr( input_rho, *EMmsg, EMS_E_InvalidArg, wrapup );

   /* Establish the rho value for the fillet */
      BSEXTRACTPAR( &msg, BSRHO_VALUE, rho_value );

   BSallocsf( fillet->u_order, fillet->v_order,
              /* safe number for any refined fillet (see Sherry C.
               * for detailes).
               */
                 ( IGRlong ) MAX_U_POLES_FOR_REFINED_FILLETS,
              fillet->v_num_poles + 1, fillet->rational, 0, mod_fillet,
              &msg );

   numu0 = numu1 = 0;
   pts_on_u0 = pts_on_u1 = NULL;
   u0_params = v0_params = u1_params = v1_params = NULL;
   u0_opp_params = v0_opp_params = u1_opp_params = v1_opp_params = NULL;

   if( u0_flow_on_fillet == TRUE )
   {
      numu0 = 1;
      pts_on_u0 = &pt1_xyz[0];
      u0_params = &pt1_uv[0];
      v0_params = &pt1_uv[1];
      u0_opp_params = &pt2_uv[0];
      v0_opp_params = &pt2_uv[1];
   }
   else
   {
      numu1 = 1;
      pts_on_u1 = &pt1_xyz[0];
      u1_params = &pt1_uv[0];
      v1_params = &pt1_uv[1];
      u1_opp_params = &pt2_uv[0];
      v1_opp_params = &pt2_uv[1];
   }

   BSreffilsrf( u0_flow_on_fillet == TRUE ? sf1 : sf2,
                u0_flow_on_fillet == TRUE ? sf2 : sf1,
                fillet,                
                u0_flow_on_fillet == TRUE ? nor1 : nor2,
                u0_flow_on_fillet == TRUE ? nor2 : nor1,
                radius, rho_value,
                numu0, ( IGRpoint * ) pts_on_u0, u0_params, v0_params,
                u0_opp_params, v0_opp_params,
                numu1, ( IGRpoint * ) pts_on_u1, u1_params, v1_params,
                u1_opp_params, v1_opp_params,
                 *mod_fillet, &msg );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "fit_new_fillet" );
   return( OM_stat );
}

end implementation EMSsubbs;
