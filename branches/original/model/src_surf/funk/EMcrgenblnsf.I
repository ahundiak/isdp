 
class implementation EMSsubbs;

#include "bsparameters.h"
#include "bserr.h"
#include "bsgeom_cvsf.h"
#include "bstypes.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emssfintdef.h"
#include "emsinter.h"
#include "EMSrnd.h"
#include "prototypes/bsalloccv.h"
#include "prototypes/bsrev_cv.h"
#include "prototypes/bsblendsfs.h"
#include "prototypes/bscv_copy.h"
#include "prototypes/bsprptoncv.h"
#include "prototypes/bspartofcv.h"
#include "prototypes/bsdotp.h"
#include "prototypes/bssfarrevn.h"
#include "prototypes/bsfreecv.h"
#include "prototypes/bsfreesf.h"
#include "prototypes/bssf3o4cvtn.h"


from EMSedge import EMset_props;


#define U0	0
#define V1	1
#define U1	2
#define V0	3

#define XYZ_DIMENSION 3
#define UV_DIMENSION  2

#define NUM_NATURAL_EDGES	4

%safe
static IGRlong stitch_two_edges( IGRlong *EMmsg, GRobjid edge1,
                  GRobjid edge2, GRspacenum osnum );
static void get_cv_copy( IGRlong *EMmsg, struct IGRbsp_curve *cv1,
                         struct IGRbsp_curve **cv2 );
%endsafe


/* 
 * DESCRIPTION:

   Given a collection of curves that are position continuous such that:

      . They are ordered (and parameterized)in a cyclic order such that the
        begining of the first curve and the end of the last curve are
        coincident.
      . The only contact between any two curves are restricted to adjacent
        curves, and it occurs such that begining of one curve is coincident
        with the end of its previous neighbor.
      . None of the curves are cyclic.
   and optionally, a collection of surfaces each adjacent to a single input
   curve, this function generates the following composite surface.

      . Number of constituent surfaces of the composite are equal to the
        number of input curves.
      . In general, each constituent surface is a surface by four boundaries.
        Two of the boundaries are segments of exactly two input curves
        (and they have no common edges).  The remaining two boundaries of
        each surface are generated internally, and they have common edges
        with the neighboring constituent surfaces.
        As an example, consider the the ith, i-1 th, and the i+1 th curves.
        Suppose each of these curves are split at their mid points.
        Then considering the parametric direction of each curve, the first
        segment of the ith curve, and the second segment of the i-1 th curve
        forms two edges of the ith constituent surface.  The remaining two
        edges of the ith surface have common edges with the i-1 th and the
        i+1 th surfaces.
      . The constituent surfaces maintain tagency to the input surfaces
        along the input curves.
      . Optionally, the constituent surfaces may be consistantly oriented,
        with respect to an input vector.

 * OPTIONS:

   . oriented_normal		May be NULL.  If not, it is used to determine
                                the orientation of the constituents of the
                                composite surface.
   . tangent_sfs                Selective elements of this array may be NULL
                                (i.e. no tangency along certain input curves).
   . options			None.

   . comp_sf_GRid->objid	Can be NULL_OBJID, in which case, a new
                                instance of EMSgencompsf will be created.

   Any of the following OUTPUTs can be NULL.  For those that are not NULL,
   the user must allocate memory.

   . comp_sf_normal, comp_sf_center_pt,
     bnd_ed_objids, bnd_ed_geoms, blend_sf_geoms, mid_points

 * INPUTS:

   options         
   construct_list  - Construction environment information.
   num_cvs	   - Number of bounding curves ( >= 3 ).
   bnd_cvs	   - The bounding curves for the composite surface.  These
                     must:
                       . be bspline curves.
                       . Satisfy the assumptions stated in the DESCRIPTION.
   tangent_sfs     - unspecified elements of this array must be NULL.
   offset_dist     - A +/- distance from the composite surface mid point,
                     along the normal to the composite surface at that point.
                     If not known, should be set to 0.
   oriented_normal - A vector at the end of the first bounding curve.
                     This is used to orient each constituent surface of the
                     composite.

 * OUTPUTS:

   EMmsg           - EMS error code.
   return value    - OM errors.
   comp_sf_GRid    - composite surface to which the blends are attached. The
                     indexing of the new components are as follows (where
                     segments refer to the input curve sections after
                     being split at their mid points).
                       . The constituent surface bounded by the first segement
                         of the first input curve, and the second segment of
                         of the last curve is the first component.
                       . The second component is the surface bounded by the
                         second segment of the first curve, and the first
                         segment of the second curve.
                       . etc.

   comp_sf_normal  - The composite surface normal at its center point.
   comp_sf_center_pt
   bnd_ed_objids   - For each of the constituent surfaces, the bounding
                     edges that correspond to the appropriate segments of the
                     input curves.  These edges will maintain the cyclic
                     direction of the input curves (indexed as per 'bnd_cvs').
                     The caller should allocate space for 2*num_cvs.
   bnd_ed_geoms	   - The corresponding geometry of 'bnd_ed_objids', such that
                     they have the same orientation (indexed as per
                     'bnd_cvs').
                     The caller should allocate memory for the array to hold
                     2*num_cvs IGRbsp_curve pointers.  The elements of the
                     array should be set to NULL.  This functions will
                     allocate memory for the element curves.  Use BSfreecv()
                     on each element to free the memory allocated by this
                     function.
   blend_sf_objids - The objids of the composite constituents.  Associated
                     with each input bound curve will be two constituent
                     surfaces.  The caller should allocate space for
                     2*num_cvs GRobjid.
   mid_points	   - The mid point of each bounding curve.  The caller
                     should allocate space for num_cvs IGRpoint.
   
 * ALGORITHM:

   . Reverse the input bounding curves.  This ensures that the edges on the
     corrsponding blend surfaces would be oriented in the same direction as
     the input bounding curves.
   . Generate the blend surfaces.
   . If needed, orient the blend surfaces.
   . Create, objects and natural boundaries for the blend surfaces.  Also,
     establish the common edge connections between adjacent blend surfaces.
   . Generate the blend edge geometries, by splitting the (a copy) input
     bounding curves.

   NOTES:
     . All new objects are created in the object space of the construction
       environment.
     . This function always creates a composite with as many constituents as
       the number of input bounding curves.  In case of three or four edges,
       the caller may obtain a single surface by calling BSsf3o4cvtn() [if
       the input bound curves are ordered, then use EMcreate_3or4cv_blend_
       surface(), defined within this function].

   For detailes on each step, see STEPs within the code.

 * HISTORY:

   Janaka : 02/26/93 : Original.
   NP       05/27/93 : Funtction "EMmkintlist" is now called by a new
                       name, "EMmakeintlist", due to addition of two
                       new curve type parameters.
                       NOTE: TRY AND SET CURVE TYPES MEANINGFULLY IN
                             THE CALL (CURRENTLY SET TO NULL).
*/

#argsused

IGRlong EMcreate_blend_surface( EMmsg, options, construct_list, 
            num_cvs, bnd_cvs, tangent_sfs, oriented_normal, offset_dist,
            comp_sf_GRid, comp_sf_normal, comp_sf_center_pt, bnd_ed_objids,
            bnd_ed_geoms, blend_sf_objids, mid_points )

IGRlong 		*EMmsg;
IGRushort		options;
IGRint			num_cvs;
struct GRvg_construct	*construct_list;
struct GRid		*comp_sf_GRid;
GRobjid			*bnd_ed_objids, *blend_sf_objids;
IGRvector       	*comp_sf_normal, *oriented_normal;
IGRdouble	        offset_dist;
struct IGRbsp_curve	**bnd_ed_geoms, **bnd_cvs;
struct IGRbsp_surface	**tangent_sfs;
IGRpoint		*mid_points, *comp_sf_center_pt;
{
   IGRchar*	old_geometry;
   IGRboolean	on_curve;
   OMuint       next_component;
   IGRint       *index, i, j, k, m, n;
   IGRlong	msg, OM_stat, dum_inx;
   IGRdouble    mid_pt_param, u_param, v_param, dotp;
   IGRpoint	*loc_mid_points, loc_comp_sf_center_pt, dum_pt;
   IGRvector	loc_comp_sf_normal, blend_normal, loc_oriented_normal;
   GRobjid	blend_sf_objid, natural_ed_objids[4], this_edge, prev_edge,
                zeroth_blend_U0, *loc_bnd_ed_objids, *loc_blend_sf_objids;
   GRspacenum	default_osnum;

   OM_S_CHANSELECT to_components;

   struct IGRbsp_curve	 **loc_bnd_ed_geoms, **loc_split_cvs;
   struct IGRbsp_surface **loc_blend_sf_geoms, **loc_tangent_sfs;
   struct GRmd_env	 *env;
   struct GRid		 loc_comp_sf_GRid;

   extern GRclassid OPP_EMSgenbs_class_id, OPP_EMSgencompsf_class_id;


   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   old_geometry = construct_list->geometry;
   loc_comp_sf_GRid.objid = NULL_OBJID;
   loc_split_cvs = NULL;
   loc_blend_sf_geoms = NULL;
   loc_bnd_ed_geoms = NULL;

   /* Avoid compiler warnings. */
      loc_bnd_ed_objids =
      loc_blend_sf_objids = NULL;
      zeroth_blend_U0 = NULL_OBJID;

   env = construct_list->env_info;
   default_osnum = env->md_id.osnum;
   EMerr_hndlr( num_cvs < 3, *EMmsg, EMS_E_InvalidArg, wrapup );

   EMmake_chanselect( GRcmpowner_to_components, &to_components );

   /* Make a copy of the input bounding curves.  These are used in the
    * generation of the blend surfaces, and are subsequently split and
    * returned as the geometry of the blend surface edges.
    */
       loc_bnd_ed_geoms = ( struct IGRbsp_curve ** ) alloca
                               ( num_cvs * sizeof( struct IGRbsp_curve * ) );
       loc_tangent_sfs = ( struct IGRbsp_surface ** ) alloca
                             ( num_cvs * sizeof( struct IGRbsp_surface * ) );
       for( i = 0; i < num_cvs; i++ )
          loc_bnd_ed_geoms[i] = NULL;

       for( i = 0; i < num_cvs; i++ )
       {
          j = ( num_cvs - i ) % num_cvs;    
          get_cv_copy( &msg, bnd_cvs[j], &loc_bnd_ed_geoms[i] );
          EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_BSerror, wrapup );
          loc_tangent_sfs[i] = tangent_sfs[j];
       }

   /* STEP 0: Generate the blend surfaces. */
       index = ( IGRint * ) alloca( num_cvs * sizeof( IGRint ) );
       loc_mid_points = ( IGRpoint * ) alloca
                                 ( num_cvs * sizeof( IGRpoint ) );
       loc_blend_sf_geoms = ( struct IGRbsp_surface ** ) alloca
                        ( num_cvs * sizeof( struct IGRbsp_surface * ) );
       for( i = 0; i < num_cvs; i++ )
          loc_blend_sf_geoms[i] = NULL;

       /* Reverse the direction of parameterization of the bounding curves.
        * This ensures that the corresponding bounding edges of the blend
        * surfaces would have a consistant orientation with the input
        * bounding curves.
        */
           for( i = 0; i < num_cvs; i++ )
           {
              BSrev_cv( &msg, loc_bnd_ed_geoms[i] );
              EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
           }        

       BSblendsfs( num_cvs, loc_bnd_ed_geoms, loc_tangent_sfs, FALSE,
                   offset_dist, index, loc_mid_points,
                   loc_comp_sf_center_pt,
                   loc_comp_sf_normal, loc_blend_sf_geoms, &msg );

       EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   /* STEP 1:
    *
    * . Reverse each local blend curve (ensures orientation consistency with
    *   the blend surface edges), and extract the two segments,
    *   start -> mid-point, mid-point -> end.
    * . Orient each blend surface w.r.t. the 'oriented_normal'.
    * . Construct objects for each of the blend surfaces, and attach them
    *   to the composite surface.
    * . Generate natural boundary edges for each blend surface.  Stitch
    *   U0 iso edge of ith blend surface, with V0 iso edge of i-1th blend
    *   surface.  Also, set the reverse connect and tangent properties on
    *   these edge (ensured by construction).
    */
       if( oriented_normal )
          OM_BLOCK_MOVE( oriented_normal, loc_oriented_normal,
                         sizeof( IGRvector ) );

       if( comp_sf_GRid->objid == NULL_OBJID )
       {
          construct_list->geometry = NULL;
          OM_stat = om$construct( classid = OPP_EMSgencompsf_class_id,
                                  osnum = default_osnum,
                                  p_objid = &loc_comp_sf_GRid.objid,
                                  msg = message GRgraphics.GRconstruct(
                                          construct_list ) );
          EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );
          loc_comp_sf_GRid.osnum = default_osnum;
       }
       else
          OM_BLOCK_MOVE( comp_sf_GRid, &loc_comp_sf_GRid,
                         sizeof( struct GRid ) );

       OM_stat = om$get_channel_count( osnum = loc_comp_sf_GRid.osnum,
                                       objid = loc_comp_sf_GRid.objid,
                                       p_chanselect = &to_components,
                                       count        = &next_component );

       EMerr_hndlr( !(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup );
       dum_inx = next_component;

       if( bnd_ed_geoms )
       {
          loc_split_cvs = ( struct IGRbsp_curve ** ) alloca (
                              2 * num_cvs * sizeof( struct IGRbsp_curve * ) );
          for( i = 0; i < 2 * num_cvs; i++ )
             loc_split_cvs[i] = NULL;
       }

       if( bnd_ed_objids )
          loc_bnd_ed_objids = ( GRobjid * ) alloca(
                                2 * num_cvs * sizeof( GRobjid ) );

       if( blend_sf_objids )
          loc_blend_sf_objids = ( GRobjid * ) alloca(
                                  2 * num_cvs * sizeof( GRobjid ) );

       this_edge = prev_edge = NULL_OBJID;

       for( i = 0, k = 0, m = 2*num_cvs - 1; i < num_cvs; i++ )
       {
          /* Note that the order of traversal in the cyclic order
           * of input curves requires the blend surfaces to traversed in
           * the reverse order.
           */
             j = ( num_cvs - i ) % num_cvs;

          /* Split the bounding curves (those corresponding to the input bound
           * curves) of the appropriate edges of the blend surfaces.
           */
              if( bnd_ed_geoms )
              {
                 BSrev_cv( &msg, loc_bnd_ed_geoms[j] );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
                 /* Generate the parameter corresponding to the mid point of
                  * curve (following o.k. since the mid point is guaranteed to
                  * be on the curve).
                  */
                     BSprptoncv( &msg, loc_bnd_ed_geoms[j], loc_mid_points[j],
                                 &mid_pt_param, &on_curve );
                     EMerr_hndlr( msg != BSSUCC || on_curve == FALSE, *EMmsg,
                                  EMS_E_BSerror, wrapup );
              
                 BSalloccv( loc_bnd_ed_geoms[j]->order,
                            loc_bnd_ed_geoms[j]->num_poles +
                                     2 * loc_bnd_ed_geoms[j]->order - 1,
                            loc_bnd_ed_geoms[j]->rational, ( IGRshort ) 0,
                            &loc_split_cvs[k], &msg );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
                 BSpartofcv( &msg, loc_bnd_ed_geoms[j], 0.0, mid_pt_param/2.0,
                             mid_pt_param, loc_split_cvs[k] );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
                 k++;
                 BSalloccv( loc_bnd_ed_geoms[j]->order,
                            loc_bnd_ed_geoms[j]->num_poles +
                                     2 * loc_bnd_ed_geoms[j]->order - 1,
                            loc_bnd_ed_geoms[j]->rational, ( IGRshort ) 0,
                            &loc_split_cvs[k], &msg );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
                 BSpartofcv( &msg, loc_bnd_ed_geoms[j], mid_pt_param,
                             mid_pt_param + ( 1.0 - mid_pt_param )/2.0, 1.0,
                             loc_split_cvs[k++] );
                 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
             }


          /* Orient the surface */
             if( oriented_normal )
             {
   	        /* Obtain the blend patch normal:
                 *    . for the first blend at (1,1).
                 *    . the rest at (0,1).
                 */
   	           u_param = i ? 0.0 : 1.0;
                   v_param = i ? 1.0 : 0.0;
                   BSsfarrevn( &msg, loc_blend_sf_geoms[j],
		               ( IGRint ) 1, &u_param, ( IGRint ) 1,
		               &v_param, dum_pt, blend_normal );

                   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror,
                                wrapup );

                dotp = BSdotp( &msg, blend_normal, loc_oriented_normal );
	        loc_blend_sf_geoms[j]->pos_orient = dotp >= 0.0
                         			    ? TRUE : FALSE;
                /* Update the oriented normal for the next blend surface. */
                   u_param = 1.0;
                   v_param = 0.0;
                   BSsfarrevn( &msg, loc_blend_sf_geoms[j],
		               ( IGRint ) 1, &u_param, ( IGRint ) 1,
		               &v_param, dum_pt, loc_oriented_normal );

                   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror,
                                wrapup );

                   if( loc_blend_sf_geoms[j]->pos_orient == FALSE )
                      for( n = 0; n < XYZ_DIMENSION; n++ )
                         loc_oriented_normal[n] = -loc_oriented_normal[n];
             }

          /* Make an object for the blend surface, insert it into the
           * composite surface, and make natural boundaries for it.
           */
	    construct_list->geometry = ( IGRchar * )
                                          loc_blend_sf_geoms[j];
	    OM_stat = om$construct( classid = OPP_EMSgenbs_class_id,
                                    osnum = default_osnum,
                                    p_objid = &blend_sf_objid,
                                    msg     = message GRgraphics.GRconstruct
						( construct_list ) );
            EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );


            /* Connect this blend to the composite surface. */
               OM_stat = om$send( msg = message GRconnector.GRrigidconn(
					&msg,
                                        &loc_comp_sf_GRid,
					&dum_inx ),
                              senderid = NULL_OBJID,
                              targetid = blend_sf_objid,
                              targetos = default_osnum );

               EMerr_hndlr( !(1 & OM_stat & msg ), *EMmsg, msg, wrapup );
               dum_inx++;

            /* Make natural boundaries for blend surface. */
               OM_stat = om$send( msg = message EMSsurface.EMmk_nat_bdry(
				&msg,
			        &env->md_env,
				natural_ed_objids ),
			        senderid = NULL_OBJID,
			        targetid = blend_sf_objid,
                                targetos = default_osnum );

               EMerr_hndlr( !(1 & OM_stat & msg), *EMmsg, msg, wrapup );

            /* Establish the common edge connection, and set edge
             * properties.
             */
                if( i /* when 0 there is the single blend surface object */ )
                {
                   this_edge = natural_ed_objids[ U0 ];
                   OM_stat = stitch_two_edges( &msg, this_edge, prev_edge,
                                               default_osnum );
                   EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                EMS_E_EdgeError, wrapup );
                }
                else
                {
                   this_edge = NULL_OBJID;
                   zeroth_blend_U0 = natural_ed_objids[ U0 ];
                }

                /* Since no stitching was done on the first iteration, two
                 * connections must be done on the last.
                 */
                    if( i == ( num_cvs - 1 ) )
                    {
                       OM_stat = stitch_two_edges( &msg,
                                   natural_ed_objids[ V0 ], zeroth_blend_U0,
                                   default_osnum );
                       EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg,
                                    EMS_E_EdgeError, wrapup );
                    }
                prev_edge = natural_ed_objids[ V0 ];

          /* Collect the bounding edges and the blend surfaces (note that
           * there are two blend surfaces adjoining each input curve).
           */
             for( n = 0; n < 2; n++ )
             {
                if( bnd_ed_objids )
                   loc_bnd_ed_objids[m] = natural_ed_objids[ n ? U1 : V1 ];

                if( blend_sf_objids )
                   loc_blend_sf_objids[m] = blend_sf_objid;

                m = ( m+1 ) % ( 2 * num_cvs );
             }
       }     

   /* STEP 2: Assign output. */
       OM_BLOCK_MOVE( &loc_comp_sf_GRid, comp_sf_GRid,
                      sizeof( struct GRid ) );
       loc_comp_sf_GRid.objid = NULL_OBJID;

       if( bnd_ed_geoms )
       {
          OM_BLOCK_MOVE( loc_split_cvs, bnd_ed_geoms,
                         2 * num_cvs * sizeof( struct IGRbsp_curve * ) );
          for( i = 0; i < 2*num_cvs; i++ )
             loc_split_cvs[i] = NULL;
       }
          
       if( bnd_ed_objids )
          OM_BLOCK_MOVE( loc_bnd_ed_objids, bnd_ed_objids,
                         2 * num_cvs * sizeof( GRobjid ) );

       if( blend_sf_objids )
          OM_BLOCK_MOVE( loc_blend_sf_objids, blend_sf_objids,
                         2 * num_cvs * sizeof( GRobjid ) );

       if( mid_points )
          for( i = 0; i < num_cvs; i++ )
          {
             j = ( num_cvs - i ) % num_cvs;
             OM_BLOCK_MOVE( loc_mid_points[j], mid_points[i],
                            sizeof( IGRpoint ) );
          }

       if( comp_sf_normal )
          OM_BLOCK_MOVE( loc_comp_sf_normal, comp_sf_normal,
                         sizeof( IGRvector ) );

       if( comp_sf_center_pt )
          OM_BLOCK_MOVE( loc_comp_sf_center_pt, comp_sf_center_pt,
                         sizeof( IGRpoint ) );

wrapup:

   construct_list->geometry = old_geometry;

   if( comp_sf_GRid->objid == NULL_OBJID && 
       loc_comp_sf_GRid.objid != NULL_OBJID )
   {
      OM_stat = om$send( msg = message Root.delete( ( IGRint ) 0 ),
                         targetid = loc_comp_sf_GRid.objid,
                         targetos = loc_comp_sf_GRid.osnum,
                         senderid = NULL_OBJID );
      if( !( 1 & OM_stat ) )
       *EMmsg = EMS_E_Fail;
   }
   
   if( loc_split_cvs )
      for( i = 0; i < num_cvs*2; i++ )
         if( loc_split_cvs[i] )
            BSfreecv( &msg, loc_split_cvs[i] );

  if( loc_blend_sf_geoms )
      for( i = 0; i < num_cvs; i++ )
         if( loc_blend_sf_geoms[ i ] )
            BSfreesf( &msg, loc_blend_sf_geoms[ i ] );

   if( loc_bnd_ed_geoms )
      for( i = 0; i < num_cvs; i++ )
         if( loc_bnd_ed_geoms[i] )
            BSfreecv( &msg, loc_bnd_ed_geoms[i] );
   
   EMWRAPUP( *EMmsg, OM_stat, "EMcreate_blend_surface" );
   return( OM_stat );
}


/*
 * DESCRIPTION:
     Establish common edge connection between 'edge1', 'edge2', and
     set tangent and reverse connect properties for both edges,
     subordinate property for 'edge2'.

 * OPTIONS:
     None.

 * INPUT:
     edge1, edge2, osnum

 * OUTPUT:
     EMmsg	  EMS errors.
     return value OM errors.

 * ALGORITHM:
     Trivial.

 * HISTORY:
     Janaka : 03/03/93 : Original.
*/

static IGRlong stitch_two_edges( IGRlong *EMmsg, GRobjid edge1,
                  GRobjid edge2, GRspacenum osnum )
{
   IGRushort	ed_props;
   IGRlong      msg, OM_stat;

   OM_S_CHANSELECT	to_common_edge;

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   EMmake_chanselect( EMSedge_to_common_edge, &to_common_edge );

   OM_stat = om$send( msg = message Root.connect(
				       to_common_edge,
                                       ( IGRint ) 0,
                                       edge2,
                                       osnum,
                                       to_common_edge,
                                       ( IGRint ) 0 ),
                      senderid = NULL_OBJID,
                      targetid = edge1,
                      targetos = osnum );
   EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_EdgeError, wrapup );

   ed_props = EMED_TANGENT | EMED_REVERSE_CONNECT;
   OM_stat = om$send( msg = message EMSedge.EMset_props(
                                          &msg, ed_props, EMS_O_ON ),
                      targetid = edge1,
                      senderid = NULL_OBJID,
                      targetos = osnum );
   EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError, wrapup );

   ed_props |= EMED_SUBORDINATE;
   OM_stat = om$send( msg = message EMSedge.EMset_props(
                                         &msg, ed_props, EMS_O_ON ),
                      targetid = edge2,
                      senderid = NULL_OBJID,
                      targetos = osnum );
   EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_EdgeError, wrapup );

wrapup:

   EMWRAPUP( *EMmsg, OM_stat, "stitch_two_edges" );
   return( OM_stat );
}



/*
 * DESCRIPTION:
      Given a collection of closed curves (possibly unordered) in model space,
      and a collection of surfaces (optional) each adjacent to a curve, this
      function constructs a composite surface bounded by the input curves,
      with tangency to the adjacent surfaces.
      (it is really is a wraper for EMcreate_blend_surface(), which
      accepts an ordered collection of closed curves).

      NOTE: For OPTIONS, INPUT and OUTPUT, see EMcreate_blend_surface(), in
            this file.

 * ALGORITHM:
      . Trace the input curves to determine model space continuity.  Using
        the trace elements, establish a correlation between the ordered
        (i.e. traced) curves, and the input curves.  Also record whether
        each curve is reversed within the trace.
      . Utilizing the traced input curves, call EMcreate_blend_surface().
      . Format the output.

 * HISTORY:
      Janaka : 03/03/93 : Original.
*/

#argsused

IGRlong EMget_blend_sf( EMmsg, options, construct_list, num_cvs, bnd_cvs,
            tangent_sfs, oriented_normal, offset_dist, comp_sf_GRid,
            comp_sf_normal, comp_sf_center_pt, bnd_ed_objids,
            bnd_ed_geoms, blend_sf_objids, mid_points )

IGRlong			*EMmsg;
IGRushort		options;
struct GRvg_construct   *construct_list;
IGRint			num_cvs;
struct IGRbsp_curve	**bnd_cvs, **bnd_ed_geoms;
struct IGRbsp_surface	**tangent_sfs;
IGRdouble		offset_dist;
struct GRid		*comp_sf_GRid;
IGRvector		*comp_sf_normal, *oriented_normal;
IGRpoint		*comp_sf_center_pt, *mid_points;
GRobjid			*bnd_ed_objids, *blend_sf_objids;
{
   IGRboolean	*cv_reversed;
   IGRshort	mat_type;
   IGRint	i, j, *indicies, inx;
   IGRlong	OM_stat, msg;
   IGRdouble    basis_tol, *matrix;
   IGRpoint     *loc_mid_points;
   GRobjid	*loc_bnd_ed_objids, *loc_blend_sf_objids;

   struct IGRbsp_curve		**ordered_bnd_cvs, **loc_bnd_ed_geoms;
   struct IGRbsp_surface	**ordered_tangent_sfs;
   struct EMSinters		*inters_list;
   struct EMSdataselect 	xyz_data;
   struct EMSsftracedata	trace_data;
   struct GRmd_env		*env;
   struct GRid			object_a;
   struct EMSintobj		*tmp_intobj;

   extern struct EMSintobj	*EMmakeintlist();
   extern void  		EMinters_free();
   extern void			EMsfinttrace();
   extern IGRlong		EMcreate_blend_surface();



   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   env = construct_list->env_info;
   mat_type = env->md_env.matrix_type;
   matrix = env->md_env.matrix;
   inters_list = NULL;
   trace_data.num_grps = 0;	/* So that memory inside trace data
                                 * can be safely deallocated.
                                 */
   ordered_bnd_cvs = NULL;
   loc_bnd_ed_geoms = NULL;
   BSEXTRACTPAR( &msg, BSTOLLENVEC, basis_tol );

   /* STEP 0:
    *
    * Make an inters list out of the input curves, and trace that list.
    * This will result in a single EMSinters node (with a NULL_OBJID).
    */
       object_a.objid = NULL_OBJID;
       for( i = 0; i < num_cvs; i++ )
       {
          xyz_data.datatype = EMSdata_curve3d;
          xyz_data.data.curve = bnd_cvs[i];
          EMmakeintlist( &msg, &inters_list, NULL, &object_a, NULL, NULL, NULL,
                       0, 0, &xyz_data, NULL, NULL, FALSE, FALSE, NULL, NULL,
                       0, 0, NULL, NULL, TRUE, FALSE );
          EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
       }
       
       EMsfinttrace( &msg, &mat_type, matrix, inters_list, NULL, &basis_tol,
            &trace_data.num_grps, &trace_data.num_subgrps_grp,
            &trace_data.num_elems_subgrp, &trace_data.elems,
            &trace_data.subgrp_rev, &trace_data.elem_rev,
            &trace_data.grp_closed, &trace_data.subgrp_closed );
       EMerr_hndlr( !( 1 & msg ) || trace_data.num_grps != 1 ||
                    trace_data.num_subgrps_grp[0] != 1 ||
                    trace_data.num_elems_subgrp[0][0] != num_cvs ||
                    trace_data.grp_closed[0] == FALSE,
                    *EMmsg, EMS_E_Fail, wrapup );

   /* STEP 1:
    *
    * . Using the trace data, form a list of bound curves.  Also, establish
    *   the correspondence between this list and 'bnd_cvs', and whether
    *   each element in the ordered list is reversed.  Latter is useful
    *   for formatting the output.
    */
       cv_reversed = ( IGRboolean * ) alloca(
                                         num_cvs * sizeof( IGRboolean ) );
       ordered_bnd_cvs = ( struct IGRbsp_curve ** ) alloca(
                            num_cvs * sizeof( struct IGRbsp_curve * ) );
       indicies = ( IGRint * ) alloca( num_cvs * sizeof( IGRint ) );
       ordered_tangent_sfs = ( struct IGRbsp_surface ** ) alloca
                              ( num_cvs * sizeof( struct IGRbsp_surface * ) );

       for( i = 0; i < num_cvs; i++ )
       {
          ordered_bnd_cvs[i] = NULL;
          cv_reversed[i] = FALSE;
          ordered_tangent_sfs[i] = NULL;
       }

       /* NOTE: The trace progresses in both directions from the first trace
        * element (i.e. from 'bnd_cvs[0]').  Thus the first element in the
        * traced elements need not be the element from which the trace began.
        * Determine the 'bnd_cvs[0]' within the traced elements (need to do
        * this since 'oriented_normal' is specified for the that curve, at its
        * parametric start).
        */
          get_cv_copy( &msg, bnd_cvs[0], &ordered_bnd_cvs[0] );
          EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
          ordered_tangent_sfs[0] = tangent_sfs[0];
          indicies[0] = 0;
          cv_reversed[0] = FALSE;
          for( tmp_intobj = trace_data.elems[0][0], i = 0; i < num_cvs;
               tmp_intobj = tmp_intobj->next, i++ )

             if( tmp_intobj->this_xyzintobj.data.curve == bnd_cvs[0] )
                break;

       /* NOTE: If a subgroup was closed, then its elements should be cyclic
        * (i.e. the last element should point to the start of the list).
        * However, this is not the case.  Thus when traversing a closed
        * subgroup's elements, it is possible to fall off the end!!.
        */

       for( tmp_intobj = tmp_intobj->next, i = 1; i < num_cvs;
            tmp_intobj = tmp_intobj->next ? tmp_intobj->next
                                          : trace_data.elems[0][0], i++ )
       {
          get_cv_copy( &msg, tmp_intobj->this_xyzintobj.data.curve,
                       &ordered_bnd_cvs[i] );
          EMerr_hndlr( !( 1 &msg ), *EMmsg, EMS_E_Fail, wrapup );

          /* Get the index into 'bnd_cvs' corresponding to the current
           * curve.
           */
              for( j = 0; j < num_cvs; j++ )
                 if( tmp_intobj->this_xyzintobj.data.curve == bnd_cvs[j] )
                 {
                    indicies[i] = j;
                    break;
                 }

          ordered_tangent_sfs[i] = tangent_sfs[j];

          if( trace_data.elem_rev[0][0][i] == TRUE )
          {
             BSrev_cv( &msg, ordered_bnd_cvs[i] );
             EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
             cv_reversed[i] = TRUE;
          }
       }

   /* STEP 2: Generate the composite surface. */
         loc_bnd_ed_objids = bnd_ed_objids
                ? ( GRobjid * ) alloca( 2 * num_cvs * sizeof( GRobjid ) )
                : NULL;
         loc_bnd_ed_geoms = bnd_ed_geoms
                ? ( struct IGRbsp_curve ** ) alloca
                      ( 2 * num_cvs * sizeof( struct IGRbsp_curve * ) )
                : NULL;
         loc_blend_sf_objids = blend_sf_objids
                ? ( GRobjid * ) alloca( 2 * num_cvs * sizeof( GRobjid ) )
                : NULL;
         loc_mid_points = mid_points
                ? ( IGRpoint * ) alloca( num_cvs * sizeof( IGRpoint ) )
                : NULL;

         for( i = 0; i < 2 * num_cvs; i++ )
            loc_bnd_ed_geoms[i] = NULL;

         OM_stat = EMcreate_blend_surface( &msg, options, construct_list,
                     num_cvs, ordered_bnd_cvs, ordered_tangent_sfs,
                     oriented_normal, offset_dist, comp_sf_GRid,
                     comp_sf_normal, comp_sf_center_pt,
                     loc_bnd_ed_objids, loc_bnd_ed_geoms, loc_blend_sf_objids,
                     loc_mid_points );
         EMerr_hndlr( !( 1 & OM_stat & msg ), *EMmsg, EMS_E_Fail, wrapup );

   /* STEP 3: Assign output. */
         if( bnd_ed_objids || bnd_ed_geoms || blend_sf_objids || mid_points )
            /* i is the index into 'indicies' array.
             * j is the index into the edge objects array, as obtained
             *   from the blend function.
             */

            for( i = 0, j = 0; i < num_cvs; i++ )
            {
                /* Get the index into the output arrays. */
                   inx = indicies[i] * 2;

                if( bnd_ed_objids )
                {
                   bnd_ed_objids[ inx ] =
                             cv_reversed[i] ? loc_bnd_ed_objids[ j+1 ]
                                            : loc_bnd_ed_objids[ j ];
                   bnd_ed_objids[ inx + 1 ] =
                             cv_reversed[i] ? loc_bnd_ed_objids[ j ]
                                            : loc_bnd_ed_objids[ j+1 ];
                }

                if( bnd_ed_geoms )
                {
                   bnd_ed_geoms[ inx ] =
                             cv_reversed[i] ? loc_bnd_ed_geoms[ j+1 ]
                                            : loc_bnd_ed_geoms[ j ];
                   bnd_ed_geoms[ inx + 1 ] =
                             cv_reversed[i] ? loc_bnd_ed_geoms[ j ]
                                            : loc_bnd_ed_geoms[ j+1 ];

                   loc_bnd_ed_geoms[j] =
                   loc_bnd_ed_geoms[j+1] = NULL;
                }

                if( blend_sf_objids )
                {
                   blend_sf_objids[ inx ] =
                             cv_reversed[i] ? loc_blend_sf_objids[ j+1 ]
                                            : loc_blend_sf_objids[ j ];

                   blend_sf_objids[ inx + 1 ] =
                             cv_reversed[i] ? loc_blend_sf_objids[ j ]
                                            : loc_blend_sf_objids[ j+1 ];
                }

                if( mid_points )
                   OM_BLOCK_MOVE( loc_mid_points[i], mid_points[ inx/2 ],
                                  sizeof( IGRpoint ) );

                j += 2;
         }

wrapup:

   if( inters_list )   EMinters_free( inters_list, MAXINT );
      
   EMsfinttrace_free( &msg, trace_data.num_grps,
         trace_data.num_subgrps_grp, trace_data.num_elems_subgrp,
         trace_data.elems, trace_data.subgrp_rev, trace_data.elem_rev,
         trace_data.grp_closed, trace_data.subgrp_closed );

   if( ordered_bnd_cvs )
      for( i = 0; i < num_cvs; i++ )
         if( ordered_bnd_cvs[i] )
            BSfreecv( &msg, ordered_bnd_cvs[i] );

   if( loc_bnd_ed_geoms )
      for( i = 0; i < 2 * num_cvs; i++ )
         if( loc_bnd_ed_geoms[i] )
            BSfreecv( &msg, loc_bnd_ed_geoms[i] );

   EMWRAPUP( *EMmsg, OM_stat, "EMget_blend_sf" );
   return( OM_stat );
}


/*
 * DESCRIPTION:
      Allocate memory for cv2 and copy cv1 into cv2.
*/

static void get_cv_copy( IGRlong *EMmsg, struct IGRbsp_curve *cv1,
                         struct IGRbsp_curve **cv2 )
{
   IGRlong	msg;

   *EMmsg = EMS_S_Success;

    BSalloccv( cv1->order, cv1->num_poles, cv1->rational,
              ( IGRshort ) 0, cv2, &msg );
    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_NoDynamicMemory, wrapup );
    BScv_copy( &msg, cv1, *cv2 );
    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

wrapup: ;
}




/*
 * DESCRIPTION:
    Given, 3 or 4 ordered, position continuous curves in model space, this
    function constructs a singel blend surface with the input curves as its
    boundaries.  Tangency along the boundaries may be specified. In case of
    3 bounding curves, the V1 natural edge is always degenrate. Optionally,
    it orients the surface created.

    NOTE: Probably should have integrated it with EMget_blend_sf().

 * OPTIONS:
    tangent_sf_geoms	Could be NULL. In case of not NULL, some of the
                        elements of the array could be NULL (there will
                        be no tangency along the corresponding bounding
                        curves).
    oriented_normal	Could be NULL. If so, the blend surface is not
                        oriented.
    comp_sf_GRid	comp_sf_GRid->objid could be NULL_OBJID.  If so, a
                        new composite surface is created.  Else the new
                        blend surface is catanated to the existing
                        composite surface.

    bnd_ed_ids,
    blend_sf_id		Could be NULL

 * INPUT:
    options		none.
    construct_list
    num_cvs		Number of input bounding curves.
    bnd_cvs		An array of 3 or 4 bounding curves in model space.
                        These must have position continuity within bastol.
    tangent_sf_geoms    An array of surface geometries indicating tangency
                        requirements along each of the bounding curves. There
                        should be a one-to-one correspondence between this
                        array, and 'bnd_cvs' array.  Also see OPTIONS.
    oriented_normal     The tangent surface normal at the end of the first
                        bound curve.  This is used to orient the blend
                        surface.
    comp_sf_GRid

 * OUTPUT:
    EMmsg		EMS errors.
    return values	OM errors.

    Caller must allocate memory for the following.
     comp_sf_GRid	If comp_sf_GRID->objid == NULL, a new composite is
                        created, and the new blend surface placed in it. Else,
                        the new blend surface is catanated to the existing
                        composite.
                        NOTE: On error, if a composite was passed into this
                              function, then it is possible that the composite
                              may have some additional elements (those
                              attached prior to error are not cleaned out).


     On error, following will retain their entry value.
      bnd_ed_ids	The natural edge objids for the new blend surface.
                        This array has a one-to-one correspondence with
                        'bnd_cvs' array. If 'num_cvs == 3' the V1 natural
                        edge will always be degenerate (and will not be placed
                        in this array).
                 
      blend_ed_geoms
      blend_sf_id
      blend_sf_geoms

 * ALGORITHM:
    Quite simple. Follow the STEPs.

 * HISTORY:
    Janaka: 06-10-93: Original.
 */

#argsused

IGRlong EMcreate_3or4cv_blend_surface( EMmsg, options, construct_list, 
            num_cvs, bnd_cvs, tangent_sf_geoms, oriented_normal,
            comp_sf_GRid, bln_ed_ids, bln_ed_geoms, bln_sf_id )

IGRlong 		*EMmsg;
IGRushort		options;
IGRint			num_cvs;
struct GRvg_construct	*construct_list;
struct GRid		*comp_sf_GRid;
GRobjid			*bln_ed_ids, *bln_sf_id;
IGRvector       	*oriented_normal;
struct IGRbsp_curve	**bnd_cvs, **bln_ed_geoms;
struct IGRbsp_surface	**tangent_sf_geoms;
{
 IGRchar*	old_geom;
 IGRint		i, j, k;
 IGRlong	msg, OM_stat, dum_inx;
 IGRdouble	u_param, v_param, dotp;
 IGRpoint	dum_pt;
 IGRvector	sf_normal;
 OMuint         next_component;
 GRspacenum	os;
 GRobjid	loc_bln_sf_id, loc_bln_ed_ids[4], tmp_id;

 OM_S_CHANSELECT	to_components;

 extern GRclassid OPP_EMSgenbs_class_id, OPP_EMSgencompsf_class_id;

 struct IGRbsp_curve	**loc_bnd_cvs, **loc_bln_ed_geoms;
 struct IGRbsp_surface  *loc_bln_sf_geom, **loc_tangent_sf_geoms;
 struct GRid		loc_comp_sf_GRid;
 struct GRmd_env	*md_env;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 EMmake_chanselect( GRcmpowner_to_components, &to_components );
 md_env = construct_list->env_info;
 os = md_env->md_id.osnum;
 old_geom = construct_list->geometry;
 loc_bln_sf_geom = NULL;

 loc_bnd_cvs = ( struct IGRbsp_curve ** ) alloca
                            ( num_cvs * sizeof( struct IGRbsp_curve * ) );
 for( i = 0; i < num_cvs; i++ )
  loc_bnd_cvs[i] = bnd_cvs[i];

 if( tangent_sf_geoms )
  loc_tangent_sf_geoms = tangent_sf_geoms;
 else
 {
  loc_tangent_sf_geoms = ( struct IGRbsp_surface ** ) alloca
                          ( num_cvs * sizeof( struct IGRbsp_surface * ) );

  for( i = 0; i < num_cvs; i++ )
   loc_tangent_sf_geoms[i] = NULL;
 }

 loc_bln_ed_geoms = NULL;
 if( bln_ed_geoms )
 {
  loc_bln_ed_geoms = ( struct IGRbsp_curve ** ) alloca
                          ( num_cvs * sizeof( struct IGRbsp_curve * ) );

  for( i = 0; i < num_cvs; i++ )
   loc_bln_ed_geoms[i] = NULL;
 }

 loc_comp_sf_GRid.objid = NULL_OBJID;
 loc_bln_sf_id = NULL_OBJID;

 EMerr_hndlr( num_cvs != 3 && num_cvs != 4, *EMmsg, EMS_E_InvalidArg,
              wrapup );


 /* STEP 1:
  *
  * The u direction of the blend surface will be in the direction of
  * the first bounding curve.  In order to ensure direction consistency
  * between the input bounding curves, and the edges of the blend, reverse
  * the direction of the first curve prior to making the blend (math will
  * sort others out). Then, create the single blend surface, and do other
  * conventinal stuff such as making a natural loop, etc.
  */
    loc_bnd_cvs[0] = NULL;
    get_cv_copy( &msg, bnd_cvs[0], &loc_bnd_cvs[0] );
    EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
    BSrev_cv( &msg, loc_bnd_cvs[0] );
    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

    BSsf3o4cvtn( num_cvs, loc_bnd_cvs, loc_tangent_sf_geoms,
                 &loc_bln_sf_geom, &msg );
    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );     

    /* Orient the surface */
       if( oriented_normal )
       {
        /* Obtain the blend surface normal at (0,0). */
           u_param = 0.0;
           v_param = 0.0;
           BSsfarrevn( &msg, loc_bln_sf_geom, ( IGRint ) 1, &u_param,
                       ( IGRint ) 1, &v_param, dum_pt, sf_normal );

           EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

           dotp = BSdotp( &msg, sf_normal, *oriented_normal );
           loc_bln_sf_geom->pos_orient = dotp >= 0.0 ? TRUE : FALSE;
       }

    /* Make an object for the blend surface, insert it into the
     * composite surface, and make natural boundaries for it.
     */
       construct_list->geometry = ( IGRchar * ) loc_bln_sf_geom;
       OM_stat = om$construct( classid = OPP_EMSgenbs_class_id,
                               osnum = os,
                               p_objid = &loc_bln_sf_id,
                               msg     = message GRgraphics.GRconstruct
   						( construct_list ) );
       EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );
       tmp_id = loc_bln_sf_id;

    /* Make natural boundaries for blend surface. */
       OM_stat = om$send( msg = message EMSsurface.EMmk_nat_bdry(
				&msg, &md_env->md_env, loc_bln_ed_ids ),
		          senderid = NULL_OBJID,
			  targetid = loc_bln_sf_id,
                          targetos = os );	

       EMerr_hndlr( !(1 & OM_stat & msg), *EMmsg, msg, wrapup );

    /* Connect this blend to the composite surface. */
       if( comp_sf_GRid->objid == NULL_OBJID )
       {
        construct_list->geometry = NULL;
        OM_stat - om$construct( classid = OPP_EMSgencompsf_class_id,
                                osnum = os,
                                p_objid = &loc_comp_sf_GRid.objid,
                                msg = message GRgraphics.GRconstruct(
                                        construct_list ) );
        EMerr_hndlr( !( 1 & OM_stat ), *EMmsg, EMS_E_OMerror, wrapup );
        loc_comp_sf_GRid.osnum = os;
       }
       else
        OM_BLOCK_MOVE( comp_sf_GRid, &loc_comp_sf_GRid,
                       sizeof( struct GRid ) );

       OM_stat = om$get_channel_count( osnum = loc_comp_sf_GRid.osnum,
                                   objid = loc_comp_sf_GRid.objid,
                                   p_chanselect = &to_components,
                                   count        = &next_component );

       EMerr_hndlr( !(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup );
       dum_inx = next_component;

       OM_stat = om$send( msg = message GRconnector.GRrigidconn
  				     ( &msg, &loc_comp_sf_GRid, &dum_inx ),
                          senderid = NULL_OBJID,
                          targetid = loc_bln_sf_id,
                          targetos = os );

       EMerr_hndlr( !(1 & OM_stat & msg ), *EMmsg, msg, wrapup );
       loc_bln_sf_id = NULL_OBJID;

    /* Blend edge geometries is merely a copy of the input curve. */
       if( bln_ed_geoms )
        for( i = 0; i < num_cvs; i++ )
        {
         get_cv_copy( &msg, bnd_cvs[i], &loc_bln_ed_geoms[i] );
         EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
        }

 /* STEP 2: Assign output. */

    if( bln_sf_id )
     *bln_sf_id = tmp_id;

    if( bln_ed_ids )
     for( i = 2, j = 0, k = 0; k < NUM_NATURAL_EDGES; i++, k++ )
     {
      /* If num_cvs == 3, then V1 would be the degenerate edge.
       * Avoid placing it in the output list.
       */
         if( num_cvs == 3 && (i+1)%NUM_NATURAL_EDGES == V1 )
          continue;
     
      bln_ed_ids[j] = loc_bln_ed_ids[ (i+1)%NUM_NATURAL_EDGES ];
      ++j;
     }

    if( comp_sf_GRid->objid == NULL_OBJID )
       OM_BLOCK_MOVE( &loc_comp_sf_GRid, comp_sf_GRid,
                      sizeof( struct GRid ) );
    loc_comp_sf_GRid.objid = NULL_OBJID;

    if( bln_ed_geoms )
    {
     OM_BLOCK_MOVE( loc_bln_ed_geoms, bln_ed_geoms,
                    num_cvs*sizeof( struct IGRbsp_curve * ) );
     for( i = 0; i < num_cvs; i++ )
      loc_bln_ed_geoms[i] = NULL;

     loc_bln_ed_geoms = NULL;
    }


wrapup:

 construct_list->geometry = old_geom;

 if( comp_sf_GRid->objid == NULL_OBJID && 
       loc_comp_sf_GRid.objid != NULL_OBJID )
 {
  OM_stat = om$send( msg = message Root.delete( ( IGRint ) 0 ),
                     targetid = loc_comp_sf_GRid.objid,
                     targetos = loc_comp_sf_GRid.osnum,
                     senderid = NULL_OBJID );
  if( !( 1 & OM_stat ) )
   *EMmsg = EMS_E_Fail;
 }

 if( loc_bln_sf_id != NULL_OBJID )
 {
  OM_stat = om$send( msg = message Root.delete( ( IGRint ) 0 ),
                     targetid = loc_bln_sf_id,
                     targetos = os,
                     senderid = NULL_OBJID );
  if( !( 1 & OM_stat ) )
   *EMmsg = EMS_E_Fail;
 }

 /* Only the 0th curve is locally made */
    if( loc_bnd_cvs[0] && loc_bnd_cvs[0] != bnd_cvs[0] )
     BSfreecv( &msg, loc_bnd_cvs[0] );

 if( loc_bln_sf_geom )
  BSfreesf( &msg, loc_bln_sf_geom );

 if( loc_bln_ed_geoms )
  for( i = 0; i < num_cvs; i++ )
   if( loc_bln_ed_geoms[i] )
    BSfreecv( &msg, loc_bln_ed_geoms[i] );


 EMWRAPUP( *EMmsg, OM_stat, "EMcreate_3or4cv_blend_surface" );
 return( OM_stat );
}




end implementation EMSsubbs;
