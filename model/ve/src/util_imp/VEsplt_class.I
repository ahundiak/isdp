
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES	1

#include <stdio.h>
#include <math.h>
#include <string.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"

#include "bs.h"
#include "bsparameters.h"

#include "msdef.h"
#include "gr.h"

#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "dpstruct.h"

#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
   
#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
#include "VEpr_hiding.h"

#include "bscvkttol2.h"
#include "bscveval.h"
#include "bsmdstptcv.h"
#include "bsprptonsf.h"
#include "bssfkttol2.h"
#include "bsxtractpar.h"
#include "bssfevaln.h"
#include "bssfeval.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEmap_curve_point_to_surface __((
					IGRdouble               u,
					struct IGRbsp_curve     *curve,
					struct IGRbsp_surface   *surf,
					IGRdouble               *uv_pt ));

static void VEprocess_parting_line_endpoint __((
					IGRdouble               *uv_pt,
					struct VEelement_header *element ));

static void VEget_uv_edge_tangent __((	IGRdouble               u,
					IGRdouble               v,
					struct VEelement_header *elem,
					IGRdouble               *tangent ));

static void VEget_edge_offset_point_and_normal __((
					struct VEelement_header *elem,
					IGRdouble               offset,
					IGRdouble               *start_pt,
					IGRdouble               *point,
					IGRdouble               *normal ));

static IGRuint VEdetermine_non_horizon_classification __((
					IGRdouble               z_norm1,
					IGRdouble               z_norm2,
					IGRdouble               dist_tol ));

static struct VEedge_header *VEsplit_and_classify_non_horizon_cusps __((
					struct VEedge_header    *edge,
					struct VEelement_header *elem ));

static struct VEedge_header *VEsplit_and_classify_non_horizon_shared __((
					struct VEedge_header    *edge,
					struct VEelement_header *elem ));

#if defined(__cplusplus)
}
#endif

#undef __
%endsafe

#if TIMING
extern IGRdouble  VEtime_ptloc;
extern IGRint     VEcount_ptloc;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

#define OFFSET_FACTOR 5

from EMSedge     import EMendpts;
from EMSloopset  import EMpt_location;

extern struct VEexecution_status VEexec_status;

extern IGRdouble sqrt();

/*--- VEmap_curve_point_to_surface -------------------------------------*/

static void VEmap_curve_point_to_surface( u, curve, surf, uv_pt )

	IGRdouble             u;
	struct IGRbsp_curve   *curve;
	struct IGRbsp_surface *surf;
	IGRdouble             *uv_pt;

/*
NAME
	VEmap_curve_point_to_surface (static)

DESCRIPTION
	This functions maps a U value on a curve to a UV point on a surface

PARAMETERS
	u (IN) - the U point to map
	curve (IN) - the curve to map from
	surf (IN) - the surface to map to
	uv_pt (OUT) - the mapped UV point

GLOBALS USED
	none

HISTORY
	02/20/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean on_surf;
	IGRlong    rc;
	IGRdouble  xyz_pt[3];

	BScveval( curve, u, 0, (IGRpoint *)xyz_pt, &rc );

	   BS_ERRCHK( rc, "VEmap_curve_point_to_surface: BScveval failed" );

	BSprptonsf( &rc, surf, xyz_pt, &uv_pt[0], &uv_pt[1], &on_surf );

	   BS_ERRCHK( rc, "VEmap_curve_point_to_surface: BSprptonsf failed" );

	}  /* VEmap_curve_point_to_surface */


/*-- VEprocess_parting_line_endpoint --------------------------------------*/

static void VEprocess_parting_line_endpoint( uv_pt, element )

	IGRdouble               *uv_pt;
	struct VEelement_header *element;

/*
NAME
	VEprocess_parting_line_endpoint (static)

DESCRIPTION
	This function takes the endpoint of a parting line, uv_pt, determines
	which edge in the loopset of an element it touches and adds a node to
	the temp list of that edge at the point where the parting line touches
	it.

PARAMETERS
	uv_pt (IN) - the UV value of the parting line endpoint
	element (IN/OUT) - the element whose edges are to be searched

GLOBALS USED
	none

HISTORY
	02/20/91  S.P. Rogers
	   Creation Date
*/
	
	{
	IGRlong               sts, msg, rc;
	IGRdouble             xyz_pt[3];
	IGRdouble             u_par;
	IGRdouble             dist;
	IGRdouble             knot_tol;
	IGRpoint              base_pt;
	struct EMSptloc_info  loc;
	struct EMSpartolbasis partol;
	struct VEedge_header  *real_edge;
	struct VEedge_header  *this_edge;
	struct IGRbsp_curve   *real_curve;

	loc.options = EMS_PTLOC_CLOSEST_EDGE;

	partol.tol      = 0.000001;
	partol.is_valid = TRUE;
	
	/* send EMpt_location to the loopset for this surface, */
	/* via the surface itself                              */

#if TIMING
	times( &VEs_time );
#endif
		    
	sts = om$send( msg          = message EMSloopset.EMpt_location( &msg,
		       	                                                uv_pt,
		       	                                                &loc,
		       	                                                &partol ),
		       senderid     = NULL_OBJID,
		       targetid     = element->loopset_id,
	               targetos     = element->env->osnum );
		       
#if TIMING
	times( &VEe_time );

	VEcount_ptloc++;
	VEtime_ptloc += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                    (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	   OM_ERRCHK( sts, "VEadd_split_points_to_edge: EMSloopset.EMpt_location send failed" );
	   MSG_ERRCHK( msg, "VEadd_split_points_to_edge: EMSloopset.EMpt_location failed" );
	   
	if ( (loc.location == EMS_L_ONEDGE) || (loc.location == EMS_L_ONVRTX) )
	   {
	   this_edge = element->edges;
	   while ( this_edge )
	      {
	      if ( this_edge->edge_id == loc.edge[0].edge_id )
	         {
	         if ( this_edge->gm_curve3d )
	            {
	            real_edge = this_edge;
	            real_curve = real_edge->gm_curve3d->bspcv;
	            }
	         else
	            {
	            real_edge = this_edge->shared_edge;
	            real_curve = real_edge->gm_curve3d->bspcv;
	            }

	         if ( real_edge->status & ALREADY_CLASSIFIED )
	            break;  /* edge has already been classified */

	         /* map UV space point to the curve we have for the edge */
	         BSsfeval( element->geom.gmsurf->bspsf,
	                   loc.edge[0].nst_pt.proj_pt[0], loc.edge[0].nst_pt.proj_pt[1],
	                   0, (IGRpoint *)xyz_pt, &rc );

	            BS_ERRCHK( rc, "VEprocess_parting_line_endpoint: BSsfeval failed" );

	         BSmdstptcv( real_curve, xyz_pt, &u_par, base_pt, &dist, &rc );

	            BS_ERRCHK( rc, "VEprocess_parting_line_endpoint: BSmdstptcv failed" );

	         if ( real_edge->temp_list == NULL )
		    VEinit_temp_list( real_edge );

	         BScvkttol2( real_curve->order, real_curve->knots, real_curve->num_poles,
	                     real_curve->poles, real_curve->weights, &knot_tol, &rc );

	         VEinsert_temp_node( u_par, real_edge, knot_tol );
	         break;
	         }

	      this_edge = this_edge->next;

	      }  /* end: while ( this_edge ) */

	   }  /* end: endpoint on an edge */

	}   /* VEprocess_parting_line_endpoint */


/*--- VEget_uv_edge_tangent --------------------------------------------*/

static void VEget_uv_edge_tangent( u, v, elem, tangent )

	IGRdouble               u, v;
	struct VEelement_header *elem;
	IGRdouble               *tangent;

/*
NAME
	VEget_uv_edge_tangent (static)

DESCRIPTION
	Given a uv point on one of the edges in a surface's loopset,
	this function finds the uv space tangent to the edge at
	that point.

PARAMETERS
	u (IN) - the u value of the UV point
	v (IN) - the v value of the UV point
	elem (IN) - the element whose surface contains the UV point
	tangent (OUT) - the edge tangent

GLOBALS USED
	none

HISTORY
	02/20/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               sts, msg;
	IGRdouble             uv_pt[2];
	struct EMSptloc_info  loc;
	struct EMSpartolbasis partol;

	uv_pt[0] = u;
	uv_pt[1] = v;

	loc.options = EMS_PTLOC_CLOSEST_EDGE;

	partol.tol      = 0.000001;
	partol.is_valid = TRUE;
	
	/* send EMpt_location to the loopset for this surface, */
	/* via the surface itself                              */

#if TIMING
	times( &VEs_time );
#endif
		    
	sts = om$send( msg          = message EMSloopset.EMpt_location( &msg,
		       	                                                uv_pt,
		       	                                                &loc,
		       	                                                &partol ),
		       senderid     = NULL_OBJID,
		       targetid     = elem->loopset_id,
	               targetos     = elem->env->osnum );
		       
#if TIMING
	times( &VEe_time );

	VEcount_ptloc++;
	VEtime_ptloc += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                    (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	   OM_ERRCHK( sts, "VEget_uv_edge_tangent: EMSloopset.EMpt_location send failed" );
	   MSG_ERRCHK( msg, "VEget_uv_edge_tangent: EMSloopset.EMpt_location failed" );
	   
	memcpy( tangent, loc.edge[0].nst_pt.tangent, 2 * sizeof( IGRdouble ) );

	}  /* VEget_uv_edge_tangent */


/*--- VEget_surface_point_and_normal --------------------------------------------------*/

static void VEget_surface_point_and_normal( surf, u, v, point, normal )

	struct IGRbsp_surface *surf;
	IGRdouble             u,v;
	IGRdouble             *point;
	IGRdouble             *normal;

/*
NAME
	VEget_surface_point_and_normal (static)

DESCRIPTION
	Given a surface from a solid and a UV point, this function determines
	the surface point and normal at that point and orients it so that it
	points away from the solid.

PARAMETERS
	surf (IN) - surface that contains UV point
	u (IN) - u value of UV point
	v (IN) - v value of UV point
	point (OUT) - XYZ value of UV point
	normal (OUT) - surface normal at UV point

GLOBALS USED
	none

HISTORY
	08/30/91    S.P. Rogers
	   Extracted from VEget_edge_offset_point_and_normal()
*/

	{
	IGRlong   rc;
	IGRint    num_normals;
	IGRvector normals[4];

	BSsfevaln( surf, u, v, 0, &num_normals, point, normals, &rc );

	   BS_ERRCHK( rc, "VEget_surface_point_and_normal: BSsfevaln failed" );

	memcpy( normal, normals[0], sizeof( IGRdouble ) * 3 );

	/* make sure surface normal points toward a hole */
	/* region of the solid                           */
	if ( surf->pos_orient )
	   {
	   normal[0] *= -1.0;
	   normal[1] *= -1.0;
	   normal[2] *= -1.0;
	   }

	}  /* VEget_surface_point_and_normal */


/*--- VEget_edge_offset_point_and_normal ----------------------------------------------*/

static void VEget_edge_offset_point_and_normal( elem, offset, start_pt, point, normal )

	struct VEelement_header *elem;
	IGRdouble               offset;
	IGRdouble               *start_pt;
	IGRdouble               *point;
	IGRdouble               *normal;

/*
NAME
	VEget_edge_offset_point_and_normal (static)

DESCRIPTION
	Given a surface and an XYZ point that is supposed to lie on one of the
	edges of the surface's loopset, this function calculates the XYZ point
	and normal of a point that is 'offset' distance in UV space from the
	UV location of the input point.  The offset is in the direction of the
	surface area.

PARAMETERS
	elem (IN) - surface element
	offset (IN) - UV space offset distance
	start_pt (IN) - XYZ space starting point
	point (OUT) - XYZ space offset point
	normal (OUT) - surface normal at offset point

GLOBALS USED
	none

HISTORY
	02/20/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    rc;
	IGRboolean on_surf;
	IGRdouble  edge_tan[2];
	IGRdouble  edge_norm[2];
	IGRdouble  surf_u, surf_v;
	IGRdouble  len;

	BSprptonsf( &rc, elem->geom.gmsurf->bspsf, start_pt, &surf_u, &surf_v, &on_surf );

	   BS_ERRCHK( rc, "VEget_edge_offset_point_and_normal: BSprptonsf failed" );

	VEget_uv_edge_tangent( surf_u, surf_v, elem, edge_tan );

	/* edge_tan is oriented so that area is to */
	/* its right and hole is to its left       */

	/* find UV space normal to edge_tan that points */
	/* toward the area of the surface               */
	edge_norm[0] = edge_tan[1];
	edge_norm[1] = -edge_tan[0];
	len = sqrt( edge_norm[0]*edge_norm[0] + edge_norm[1]*edge_norm[1] );
	if ( len != 0.0 )
	   {
	   edge_norm[0] = (edge_norm[0] / len) * offset;
	   edge_norm[1] = (edge_norm[1] / len) * offset;
	   }

	surf_u += edge_norm[0];
	surf_v += edge_norm[1];

	VEget_surface_point_and_normal( elem->geom.gmsurf->bspsf, surf_u, surf_v, point, normal );

	}  /* VEget_edge_offset_point_and_normal */


/*--- VEdetermine_non_horizon_classification ------------------------------------------------*/

static IGRuint VEdetermine_non_horizon_classification( z_norm1, z_norm2, dist_tol )

	IGRdouble z_norm1;
	IGRdouble z_norm2;
	IGRdouble dist_tol;

/*
NAME
	VEdetermine_non_horizon_classification (static)

DESCRIPTION
	Given the Z components of two normals, determine the classification of
	a non-horizon edge.

PARAMETERS
	z_norm1 (IN) - z component of first normal
	z_norm2 (IN) - z component of second normal
	dist_tol (IN) - distance tolerance

GLOBALS USED
	none

RETURN VALUES
	HIDDEN_NON_PROFILE - if edge is along line of sight OR one normal is
	                     perpindicular to the line of sight and the other
	                     points away from the viewer OR both normals point
	                     away from the viewer
	VISIBLE_PROFILE - if one normal is perpindicular to the line of sight
	                  and the other points toward the viewer OR if the
	                  edge is really a horizon edge
	VISIBLE_NON_PROFILE - if both normals point toward the viewer

HISTORY
	08/30/91    S.P. Rogers
	   Extracted from VEsplit_and_classify_non_horizon_shared
*/

	{
	if ( fabs(z_norm1) < dist_tol )
	   {
	   if ( fabs(z_norm2) < dist_tol )
	      return( HIDDEN_NON_PROFILE );  /* edge along line of sight */
	   else if ( z_norm2 < 0.0 )
	      return( VISIBLE_PROFILE );
	   else
	      return( HIDDEN_NON_PROFILE );
	   }
	else if ( fabs(z_norm2) < dist_tol )
	   {
	   if ( z_norm1 < 0.0 )
	       return( VISIBLE_PROFILE );
	   else
	       return( HIDDEN_NON_PROFILE );
	   }
	else if ( (z_norm1 < 0.0) && (z_norm2 < 0.0) )
	   return( VISIBLE_NON_PROFILE );
	else if ( (z_norm1 > 0.0) && (z_norm2 > 0.0) )
	   return( HIDDEN_NON_PROFILE );
	else
	   {
	   if ( VEreport_errors )
	      fprintf( stderr, "PANIC: horizon in non-horizon: %20.15lf %20.15lf\n", z_norm1, z_norm2 );
	   return( VISIBLE_PROFILE );
	   }

	}  /* VEdetermine_non_horizon_classification */


/*--- VEsplit_and_classify_non_horizon_cusps --------------------------------*/

static struct VEedge_header *VEsplit_and_classify_non_horizon_cusps( edge, elem )

	struct VEedge_header    *edge;
	struct VEelement_header *elem;

/*
NAME
	VEsplit_and_classify_non_horizon_cusps (static)

DESCRIPTION
	Given an cusp edge that has nodes in its temp list that indicate where
	the classification could change, split the edge at the nodes and
	classify each piece separately.

PARAMETERS
	edge (IN/OUT) - nonhorizon cusp edge
	elem (IN/OUT) - element to which 'edge' belongs

GLOBALS USED
	none

RETURN VALUES
	A linked list of the split and classified edges is returned.

HISTORY
	8/29/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 rc;
	IGRdouble               offset;
	IGRdouble               point[3], norm1[3], norm2[3];
	IGRdouble               dist_tol;
	IGRdouble               u1, v1, u2, v2;
	struct VEtemp_node      *this_temp;
	struct VEedge_header    *split_edge;
	struct VEedge_header    *head, *tail;
	struct IGRbsp_surface   *surf;

	head = tail = NULL;

	BSxtractpar( &rc, BSTOLLENVEC, &dist_tol );

	surf = elem->geom.gmsurf->bspsf;
	BSsfkttol2( surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
	            surf->u_num_poles, surf->v_num_poles, surf->poles, surf->weights,
	            &offset, &rc );

	   BS_ERRCHK( rc, "VEsplit_and_classify_non_horizon_cusps: BSsfkttol2 failed" );

	offset *= OFFSET_FACTOR;

	if ( ! edge->temp_list )
	   VEinit_temp_list( edge );

	this_temp = edge->temp_list;
	while ( this_temp->next )
	   {
	   split_edge = VEedge_split( edge, this_temp->u, this_temp->next->u );
	   split_edge->status &= ~EDGE_CLASSIFICATION;
	   VEfind_curve_range( split_edge->gm_curve3d->bspcv, split_edge->range );

	   /* find two offset points from the cusp */
	   if ( edge->status & CONSTANT_U_ISOCURVE )
	      {
	      u1 = edge->iso_parm - offset;
	      if ( u1 < surf->u_knots[surf->u_order - 1] )
	         u1 = surf->u_knots[surf->u_num_knots - surf->u_order] - offset;
	      v1 = (this_temp->next->u + this_temp->u) * 0.5;

	      u2 = edge->iso_parm + offset;
	      if ( u2 > surf->u_knots[surf->u_num_knots - surf->u_order] )
	         u2 = surf->u_knots[surf->u_order - 1] + offset;
	      v2 = v1;
	      }
	   else
	      {
	      u1 = (this_temp->next->u + this_temp->u) * 0.5;
	      v1 = edge->iso_parm - offset;
	      if ( v1 < surf->v_knots[surf->v_order - 1] )
	         v1 = surf->v_knots[surf->v_num_knots - surf->v_order] - offset;

	      u2 = u1;
	      v2 = edge->iso_parm + offset;
	      if ( v2 > surf->v_knots[surf->v_num_knots - surf->v_order] )
	         v2 = surf->v_knots[surf->v_order - 1] - offset;
	      }

	   VEget_surface_point_and_normal( surf, u1, v1, point, norm1 );
	   VEget_surface_point_and_normal( surf, u2, v2, point, norm2 );

	   split_edge->status |= VEdetermine_non_horizon_classification( norm1[2], norm2[2], dist_tol );

	   if ( head == NULL )
	      head = split_edge;
	   else
	      tail->next = split_edge;

	   tail = split_edge;

	   this_temp = this_temp->next;
	   }  /* end: while ( this_temp->next ) */

	return( head );

	}  /* VEsplit_and_classify_non_horizon_cusps */


/*--- VEsplit_and_classify_non_horizon_shared --------------------------------------------------*/

static struct VEedge_header *VEsplit_and_classify_non_horizon_shared( edge, elem )

	struct VEedge_header    *edge;
	struct VEelement_header *elem;

/*
NAME
	VEsplit_and_classify_non_horizon_shared (static)

DESCRIPTION
	Given an edge that has nodes in its temp list that indicate where the
	classification could change, split the edge at the nodes and classify
	each piece separately.

PARAMETERS
	edge (IN/OUT) - real shared edge
	elem (IN/OUT) - element to which 'edge' belongs

GLOBALS USED
	none

RETURN VALUES
	A linked list of the split and classified edges is returned.

HISTORY
	02/20/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 rc;
	IGRdouble               xyz_pt[3];
	IGRdouble               u_par;
	IGRdouble               offset1, offset2;
	IGRdouble               pt1[3], pt2[3], norm1[3], norm2[3];
	IGRdouble               dist_tol;
	struct VEtemp_node      *this_temp;
	struct VEedge_header    *prev_dummy, *dummy;
	struct VEedge_header    *split_edge;
	struct VEedge_header    *head, *tail;
	struct VEelement_header *dummy_elem;
	struct IGRbsp_surface   *surf;

	head = tail = NULL;

	dummy_elem = edge->shared_elem;
	dummy = edge->shared_edge;

	if ( VEfind_other_shared_edge( dummy->edge_id, dummy, dummy_elem, &prev_dummy, &dummy ) )
	   {
	   BSxtractpar( &rc, BSTOLLENVEC, &dist_tol );

	   surf = elem->geom.gmsurf->bspsf;
	   BSsfkttol2( surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
	               surf->u_num_poles, surf->v_num_poles, surf->poles, surf->weights,
	               &offset1, &rc );

	      BS_ERRCHK( rc, "VEsplit_and_classify_non_horizon_shared: BSsfkttol2 (1) failed" );

	   surf = dummy_elem->geom.gmsurf->bspsf;
	   BSsfkttol2( surf->u_order, surf->v_order, surf->u_knots, surf->v_knots,
	               surf->u_num_poles, surf->v_num_poles, surf->poles, surf->weights,
	               &offset2, &rc );

	      BS_ERRCHK( rc, "VEsplit_and_classify_non_horizon_shared: BSsfkttol2 (2) failed" );

	   offset1 *= OFFSET_FACTOR;
	   offset2 *= OFFSET_FACTOR;

	   if ( ! edge->temp_list )
	      VEinit_temp_list( edge );

	   this_temp = edge->temp_list;
	   while ( this_temp->next )
	      {
	      split_edge = VEedge_split( edge, this_temp->u, this_temp->next->u );
	      split_edge->status &= ~EDGE_CLASSIFICATION;
	      VEfind_curve_range( split_edge->gm_curve3d->bspcv, split_edge->range );

	      u_par = (this_temp->next->u + this_temp->u) * 0.5;

	      BScveval( (struct IGRbsp_curve *)edge->gm_curve3d, u_par, 0, 
				(IGRpoint *)xyz_pt, &rc );

	         BS_ERRCHK( rc, "VEsplit_and_classify_non_horizon_shared: BScveval failed" );

	      VEget_edge_offset_point_and_normal( elem, offset1, xyz_pt, pt1, norm1 );
	      VEget_edge_offset_point_and_normal( dummy_elem, offset2, xyz_pt, pt2, norm2 );

	      split_edge->status |= VEdetermine_non_horizon_classification( norm1[2], norm2[2], dist_tol );

	      if ( head == NULL )
	         head = split_edge;
	      else
	         tail->next = split_edge;

	      tail = split_edge;

	      this_temp = this_temp->next;
	      }  /* end: while ( this_temp->next ) */

	   }  /* end: if */

	VEcreate_dummies_for_split_pieces( elem, head, dummy, dummy_elem );

	return( head );

	}  /* VEsplit_and_classify_non_horizon_shared */


/*-- VEsplit_and_classify_non_horizon_edges ------------------------------------*/

void VEsplit_and_classify_non_horizon_edges( elem_list )

	struct VEelement_header *elem_list;

/*
NAME
	VEsplit_and_classify_non_horizon_edges

DESCRIPTION
	Given a list of elements from a solid, this function splits and
	classifies all non-horizon edges.  The locations at which to split
	the edges are found by recording where the endpoints of the parting
	lines touch the other edges of the element.  Each edge is split at
	these points and the split pieces are classified.

PARAMETERS
	elem_list (IN/OUT) - solid whose non-horizon edges are to be classified

GLOBALS USED
	VEexec_status.VEabort - set if user presses stop sign

NOTES
	This function assumes that horizon edge classification has already been
	performed on the edges.  Therefore, it only processes edges whose
	ALREADY_CLASSIFIED status bit is not set.

HISTORY
	02/20/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 sts, msg, rc;
	IGRboolean              on_surf;
	IGRdouble               xyz[3];
	IGRdouble               beg_pt[2], end_pt[2];
	struct VEedge_header    *this_edge, *next_edge;
	struct VEedge_header    *head, *tail;
	struct VEedge_header    *new_edges;
	struct VEelement_header *this_elem;
	struct IGRbsp_curve     *curve;

	/* find where the parting lines touch the other edges */
	this_elem = elem_list->next_in_solid;  /* skip solid header */
	while ( this_elem )
	   {
	   VEupdate_heartbeat();
	   if ( IGEstop() )
	      {
	      VEexec_status.VEabort = TRUE;
	      break;
	      }

	   this_edge = this_elem->edges;
	   while ( this_edge )
	      {
	      if ( this_edge->type == HORIZON_EDGE )
	         {
	         /* get beginning and ending points of the parting line in UV space */
	         sts = om$send( msg      = message EMSedge.EMendpts( &msg, beg_pt, end_pt, NULL, NULL, NULL ),
	                        senderid = NULL_OBJID,
	                        targetid = this_edge->edge_id,
	                        targetos = this_elem->env->osnum );

	         /* mark the edges that touch the beginning and ending points */
	         VEprocess_parting_line_endpoint( beg_pt, this_elem );
	         VEprocess_parting_line_endpoint( end_pt, this_elem );
	         }  /* end: if */
	      else if ( this_edge->type == HORIZON_CURVE )
	         {
	         /* map endpoints of curve to surface */
	         BScveval( this_edge->gm_curve3d->bspcv, 0.0, 0, (IGRpoint *)xyz, &rc );
	         if ( rc == BSSUCC )
	            {
	            BSprptonsf( &rc, this_elem->geom.gmsurf->bspsf, xyz, &beg_pt[0], &beg_pt[1], &on_surf );
	            if ( rc == BSSUCC )
	               {
	               VEprocess_parting_line_endpoint( beg_pt, this_elem );
	               }
	            }

	         BScveval( this_edge->gm_curve3d->bspcv, 1.0, 0, (IGRpoint *)xyz, &rc );
	         if ( rc == BSSUCC )
	            {
	            BSprptonsf( &rc, this_elem->geom.gmsurf->bspsf, xyz, &end_pt[0], &end_pt[1], &on_surf );
	            if ( rc == BSSUCC )
	               {
	               VEprocess_parting_line_endpoint( end_pt, this_elem );
	               }
	            }

                 }

	      else if ( (this_edge->type == SHARP) && ((this_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )
	         {
	         curve = this_edge->gm_curve3d->bspcv;
	         VEmap_curve_point_to_surface( curve->knots[ curve->order - 1 ], curve,
	                                       this_elem->geom.gmsurf->bspsf, beg_pt );
	         VEmap_curve_point_to_surface( curve->knots[ curve->num_knots - curve->order ], curve,
	                                       this_elem->geom.gmsurf->bspsf, end_pt );

	         /* mark the edges that touch the beginning and ending points */
	         VEprocess_parting_line_endpoint( beg_pt, this_elem );
	         VEprocess_parting_line_endpoint( end_pt, this_elem );
	         }

	      this_edge = this_edge->next;
	      }  /* end: while ( this_edge ) */

	   this_elem = this_elem->next_in_solid;
	   }  /* end: while ( this_elem ) */

	if ( ! VEexec_status.VEabort )
	   {
	   /* split and classify the edges */
	   this_elem = elem_list->next_in_solid;  /* skip solid header */
	   while ( this_elem )
	      {
	      VEupdate_heartbeat();
	      if ( IGEstop() )
	         {
	         VEexec_status.VEabort = TRUE;
	         break;
	         }

	      /* loop over all edges for this_elem and classify  */
	      /* the edges that have not already been classified */
	      head = tail = NULL;
	      this_edge = this_elem->edges;
	      while ( this_edge )
	         {
	         next_edge = this_edge->next;
	         this_edge->next = NULL;
	         new_edges = this_edge;
	         if ( ! (this_edge->status & ALREADY_CLASSIFIED) )
	            {
	            /* this_edge hasn't been classified yet */
	            if ( this_edge->status & REAL_SHARED_EDGE )
	               {
	               new_edges = VEsplit_and_classify_non_horizon_shared( this_edge, this_elem );
	               VEfree_temp_node_list( this_edge->temp_list );
	               VEfree_visib_node_list( this_edge->visib_list );
	               VEfree_edge_header( this_edge );
	               }
	            else if ( (this_edge->type == SHARP) || (this_edge->type == MESH) )
	               {
	               new_edges = VEsplit_and_classify_non_horizon_cusps( this_edge, this_elem );
	               VEfree_temp_node_list( this_edge->temp_list );
	               VEfree_visib_node_list( this_edge->visib_list );
	               VEfree_edge_header( this_edge );
	               }
	            else if ( (this_edge->type == HORIZON_EDGE) || (this_edge->type == HORIZON_CURVE) )
	               {
	               /* These edges can only classify as VISIBLE NON-PROFILE or  */
	               /* HIDDEN NON-PROFILE.  I am temporarily going to classify  */
	               /* them as VISIBLE NON-PROFILE and let the self hiding code */
	               /* determine which are really hidden.  Eventually we will   */
	               /* want to write routines that we determine this with split */
	               /* and classify logic.                                      */
	               this_edge->status &= ~EDGE_CLASSIFICATION;
	               this_edge->status |= VISIBLE_NON_PROFILE;
	               }

	            } /* end: if ( ! (this_edge->status & ALREADY_CLASSIFIED) ) */

	         /* update list of split/classified edges */
	         VEadd_edges_to_list( new_edges, &head, &tail );

	         this_edge = next_edge;
	         }  /* end: while ( this_edge ) */

	      /* replace edge list with the list of split/classified edges */
	      this_elem->edges = head;
	      this_elem = this_elem->next_in_solid;
	      }  /* end: while ( this_elem ) */
	   }

	}  /* VEsplit_and_classify_non_horizon_edges */


end implementation Root;
