
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1
#define DEBUG              0

#include <stdio.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "godef.h"
#include "go.h"

#include "dpstruct.h"

#include "bs.h"

#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emsdef.h"

#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "vemem.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

/* protoypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif
static void VEset_trimmed_bit __((	struct VEelement_header *elem,
					OM_S_OBJID              edge_id ));
#if defined(__cplusplus)
extern "C" }
#endif

#undef __
%endsafe

from EMSloopset import EMlsparttrim;

/* External Global Variables */
extern struct VEexecution_status    VEexec_status;


#if TIMING
extern IGRdouble  VEtime_trim;
extern IGRint     VEcount_trim;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif


/*--- VEset_trimmed_bit ------------------------------------------------------*/

static void VEset_trimmed_bit( elem, edge_id )

	struct VEelement_header *elem;
	OM_S_OBJID              edge_id;

/*
NAME
	VEset_trimmed_bit (static)

DESCRIPTION
	This function sets a bit in an edge header that indicates that
	a boundary trimmed a parting line given the id of the edge and
	a list of edges that contains the edge.

PARAMETERS
	elem (IN) - element whose edges are to be searched
	edge_id (IN) - the edge_id to look for in the edge list

GLOBALS USED
	none

HISTORY
	05/12/89    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *this_edge;

	this_edge = elem->edges;
	while ( this_edge )
	   {
	   if ( this_edge->edge_id == edge_id )
	      {
	      if ( this_edge->type == BOUNDARY )
	         {
	         this_edge->status |= TRIMMED_A_PARTING_LINE;
	         }

	      break;
	      }

	   this_edge = this_edge->next;
	   }
	}  /* VEset_trimmed_bit */

/*---- VEtrim_polyline ----------------------------------------------*/

struct VEedge_header *VEtrim_polyline( elem, edge, polyline, iso_flag )

	struct VEelement_header *elem;
	struct VEedge_header    *edge;
	struct IGRpolyline      *polyline;
	IGRint                  iso_flag;

/*
NAME
	VEtrim_polyline

DESCRIPTION
	This function trims an edge that can be represented as a polyline
	in uv-space against the loopset of a surface.

PARAMETERS
	elem (IN) - the element that owns the edge to be trimmed
	edge (IN) - the edge to be trimmed
	polyline (IN) - polyline definition of the edge to be trimmed
	iso_flag (IN) - flag indicating whether the edge is constant in
	                U, constant in V, or neither

RETURN VALUES
	A linked list of edges representing the trimmed portins of the edge
	is returned

NOTES
	The edge header passed in will be freed by this function, so it
	will not be valid when this function returns.

GLOBALS USED
	none

HISTORY
	S.P. Rogers  9/17/87  Creation Date
*/

	{
	IGRshort              trim_options;
	IGRlong               sts;
	IGRlong               msg;
	IGRint                num_bdrys;
	IGRint                span_num;
	IGRdouble             u0, u1;
	IGRdouble             u_start;
	IGRdouble             u_end;
	IGRdouble             *knots;
	struct EMSdataselect  uv_data;
	struct EMSpypoint     *this_point;
	struct EMSpypoint     *next_point;
	struct EMSpypoint     *bdrys;
	struct EMSpartolbasis partol;
        struct EMSsfintedpar  *int_info;
        struct EMSsfintedpar  *this_info;
	struct VEedge_header  *head;
	struct VEedge_header  *tail;
	struct VEedge_header  *new_edge;


#if DEBUG
	{
	IGRint i;
	fprintf( stderr, "Iso flag: %d\n", iso_flag );
	fprintf( stderr, "Polyline to trim:\n" );
	for ( i = 0; i < polyline->num_points; i++ )
	   {
	   fprintf( stderr, " %lf %lf\n", polyline->points[i*2], polyline->points[i*2 + 1] );
	   }
	}
#endif

	/* To save time, I'm not calculating the parametric tolerance */
	/* used by the trim method.  In the future, a field should be */
	/* added to the element header that contains this tolerance   */
	/* so it will only have to be calculated once.                */
	partol.tol      = 1e-8;
	partol.is_valid = TRUE;

	uv_data.datatype  = EMSdata_poly2d;
	uv_data.data.poly = polyline;

	/* have the trimming methods interpret boundaries (edges) as area */
	/* i.e., If the polyline that is being trimmed lies on a seam or  */
	/* boundary, it is treated as being in the area of the surface    */
	trim_options = EMS_INTER_BDRYISAREA;

	/* trim the polyline */

#if TIMING
	times( &VEs_time );
#endif
		    
        bdrys = NULL;
        int_info = NULL;

	sts = om$send( mode         = OM_e_wrt_object,
		       msg          = message EMSloopset.EMlsparttrim( &msg,
	                                                               &uv_data,
	                                                               &partol,
	                                                               trim_options,
	                                                               &num_bdrys,
	                                                               &bdrys,
		    	                                               &int_info ),
		       senderid     = NULL_OBJID,
		       targetid     = elem->loopset_id,
	               targetos     = elem->env->osnum );
		       
#if TIMING
	times( &VEe_time );

	VEcount_trim++;
	VEtime_trim += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                   (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif
	
	   OM_ERRCHK( sts, "VEtrim_polyline: EMSloopset.EMlsparttrim send failed" );
	   MSG_ERRCHK( msg, "VEtrim_polyline: EMSsubbs.EMpassloop failed" );


#if DEBUG
	{
	struct EMSpypoint *temp;

	fprintf( stderr, "Trim info:\n\n" );
	temp = bdrys;
	while ( temp != NULL )
	   {
	   fprintf( stderr, "span_inx, param, u, v: %d %lf %lf %lf\n",
	            temp->span_inx, temp->param, temp->point[0], temp->point[1] );

	   temp = temp->next;
	   }
	}
#endif

	/* use the boundary points to split out the visible */
	/* portions of the edge                             */
	head = tail = NULL;
	if ( num_bdrys != 0 )  /* (num_bdrys == 0) => edge was entirely in a hole region */
	   {
	   this_point = bdrys;
           this_info = int_info;
	   while ( this_point != NULL
                && this_point->props != EMS_PYPT_EMPTY)
	      {
	      next_point = this_point->next;
	      switch ( iso_flag )
	         {
	         case CONST_U_POLY :

	            /* the input polyline is constant in u, so the edge's */
	            /* clip parameters are the v values of the boundary   */
	            /* points in uv space                                 */
	            u_start = this_point->point[1];
	            u_end   = next_point->point[1];
	            break;

	         case CONST_V_POLY :

	            /* the input polyline is constant in v, so the edge's */
	            /* clip parameters are the u values of the boundary   */
	            /* points in uv space                                 */
	            u_start = this_point->point[0];
	            u_end   = next_point->point[0];
	            break;

	         default :

	            {
	            /* the input polyline is a general polyline so the     */
	            /* edge's clip parameters will have to be interpolated */
	            knots = edge->gm_curve3d->bspcv->knots;
	            span_num = this_point->span_inx;
	            u0 = knots[ span_num + 1];
	            u1 = knots[ span_num + 2];
	            u_start = u0 + (u1 - u0) * this_point->param;
	
	            span_num = next_point->span_inx;
	            u0 = knots[ span_num + 1];
	            u1 = knots[ span_num + 2];
	            u_end = u0 + (u1 - u0) * next_point->param;
	            };

	         }  /* end: switch( iso_flag ) */

              if ( (edge->type == HORIZON_EDGE) || (edge->type == HORIZON_CURVE) || (edge->type == SHARP) )
                 VEset_trimmed_bit( elem, this_info->edgeid );

	      /* create and initialize edge header for the visible segment */
	      new_edge = VEedge_split( edge, u_start, u_end );
	      if ( new_edge != NULL )
	         {
	         /* edge split succeeded */
	         new_edge->edge_id = VEexec_status.VEunique_edge_id--;

	         /* add new edge to list */
	         if ( tail == NULL )
	            {
	            head = tail = new_edge;
	            }
	         else
	            {
	            tail->next = new_edge;
	            tail = new_edge;
	            }
	         }

	      this_point = next_point->next;
              this_info = this_info->next;

	      }  /* end: while ( this_point != NULL ) */

	   /* free trim info */
           EMpypoint_free( bdrys, NULL );

           EMsfintedpar_free( int_info, NULL );

	   }  /* end: if ( num_bdrys != 0 ) */


	/* free the edge header and visib_list of the original edge */
	VEfree_visib_node_list( edge->visib_list );
	VEfree_edge_header( edge );
	
	return( head );

	}  /* VEtrim_polyline */


/*--- VEdetermine_point_visib_by_triming ----------------------------------*/

IGRshort VEdetermine_point_visib_by_triming( elem, u_val, v_val )

	struct VEelement_header *elem;
	IGRdouble               u_val;
	IGRdouble               v_val;

/*
NAME
	VEdetermine_point_visib_by_trimming

DESCRIPTION
	This function determines the visibility of a point on a surface
	by trimming.

PARAMETERS
	elem (IN) - the element whose point visibility is to be determined
	u_val (IN) - the u parameter of the point to test
	v_val (IN) - the v parameter of the point to test

RETURN VALUES
	VISIBLE - if the point is in a solid region of the surface
	HIDDEN - if the point is in a hole region of the surface

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRshort              trim_options;
	IGRshort              vis_info;
	IGRlong               sts;
	IGRlong               msg;
	IGRint                num_bdrys;
	IGRdouble             stack_points[4];
	struct EMSdataselect  uv_data;
	struct EMSpypoint     *this_point;
	struct EMSpypoint     *bdrys;
        struct EMSsfintedpar  *int_info;
	struct EMSpartolbasis partol;
	struct IGRpolyline    polyline;


	/* To save time, I'm not calculating the parametric tolerance */
	/* used by the trim method.  In the future, a field should be */
	/* added to the element header that contains this tolerance   */
	/* so it will only have to be calculated once.                */
	partol.tol      = 1e-8;
	partol.is_valid = TRUE;

	polyline.num_points = 2;
	polyline.points = stack_points;
	polyline.points[0] = 0.0;
	polyline.points[1] = 0.0;
	polyline.points[2] = u_val;
	polyline.points[3] = v_val;	
	
	uv_data.datatype  = EMSdata_poly2d;
	uv_data.data.poly = &polyline;

	/* have the trimming methods interpret boundaries (edges) as area */
	/* i.e., If the polyline that is being trimmed lies on a seam or  */
	/* boundary, it is treated as being in the area of the surface    */
	trim_options = EMS_INTER_BDRYISAREA;

	/* trim the polyline */

#if TIMING
	times( &VEs_time );
#endif
		    
	bdrys = NULL;
	int_info = NULL;
	sts = om$send( msg          = message EMSloopset.EMlsparttrim( &msg,
	                                                               &uv_data,
	                                                               &partol,
	                                                               trim_options,
	                                                               &num_bdrys,
	                                                               &bdrys,
		    	                                               &int_info ),
		       senderid     = NULL_OBJID,
		       targetid     = elem->loopset_id,
	               targetos     = elem->env->osnum );
		       
#if TIMING
	times( &VEe_time );

	VEcount_trim++;
	VEtime_trim += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                   (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif
	
	   OM_ERRCHK( sts, "VEtrim_polyline: EMSloopset.EMlsparttrim send failed" );
	   MSG_ERRCHK( msg, "VEtrim_polyline: EMSsubbs.EMpassloop failed" );


	/* use the boundary points to split out the visible */
	/* portions of the edge                             */
	if ( num_bdrys == 0 )
	   return( VISIBLE );  /* polyline entirely in a hole region */
	else
	   {
	   this_point = bdrys;
	   while ( this_point->next != NULL )
	      {
	      this_point = this_point->next;
	      }  /* end: while ( this_point != NULL ) */

	   vis_info = (this_point->param == 1.0) ? HIDDEN : VISIBLE;

	   /* free trim info */
           EMpypoint_free( bdrys, NULL );
           EMsfintedpar_free( int_info, NULL );

	   return( vis_info );
	   }  /* end: else */

	}  /* VEdetermine_point_visib_by_triming */

end implementation Root;
