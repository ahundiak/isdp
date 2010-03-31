
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#define CHECK_RETURN_CODES 1

#define BETTER_CROSS_TOL 1e-3

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "gr.h"
#include "godef.h"
#include "go.h"
#include "dpstruct.h"

#include "bsparameters.h"
#include "bs.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_marking.h"
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"

#include "bsfndsfcsp.h"
#include "bschangepar.h"
#include "bsxtractpar.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEfind_sharp_knots __((
				struct IGRbsp_surface *surf,
				IGRint                *num_u,
				IGRint                *num_v,
				IGRdouble             **sharp_u_knots,
				IGRdouble             **sharp_v_knots ));

#if defined(__cplusplus)
}
#endif

#undef __


/*---- VEfind_sharp_knots ----------------------------------------------------------*/

static void VEfind_sharp_knots( surf, num_u, num_v, sharp_u_knots, sharp_v_knots )

	struct IGRbsp_surface *surf;
	IGRint                *num_u;
	IGRint                *num_v;
	IGRdouble             **sharp_u_knots;
	IGRdouble             **sharp_v_knots;

/*
NAME
	VEfind_sharp_knots (static)

DESCRIPTION
	This function finds the knot values where a surface has cusp lines.
	The memory used to store the sharp knots is obtained from a special
	memory management function and is not supposed to be freed.

PARAMETERS
	surf (IN) - the surface whose sharp knots are to be found
	num_u (OUT) - the number of sharp knots in u
	num_v (OUT) - the number of sharp knots in v
	sharp_u_knots (OUT) - array of sharp knots in u
	sharp_v_knots (OUT) - array of sharp knots in v

GLOBALS USED
	none

NOTES
	The sharp_u_knots and sharp_v_knots arrays are allocated from
	temporary storage and are only valid until the next call to this
	function or the next call to VEget_sharp_knot_storage().  These
	arrays should not be freed by the caller.

HISTORY
	09/18/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong   rc;
	IGRdouble old_cross_tol;
	IGRint    sharp_u_size;
	IGRint    sharp_v_size;
	IGRdouble *sharp_u_buffer;
	IGRdouble *sharp_v_buffer;


	(*num_u) = (*num_v) = 0;

	sharp_u_size = surf->u_num_poles - surf->u_order + 1;
	sharp_v_size = surf->v_num_poles - surf->v_order + 1;

	/* get storage for knots */
	VEget_sharp_knot_storage( sharp_u_size, sharp_v_size,
	                          &sharp_u_buffer, &sharp_v_buffer );

	/* change cross_tol to a realistic value, so only true cusps will be found */
	BSxtractpar( &rc, BSTOLCOLLINVEC, &old_cross_tol );
	BSchangepar( &rc, BSTOLCOLLINVEC, BETTER_CROSS_TOL );
	BSchangepar( &rc, BSTOLSQCOLLINVEC, BETTER_CROSS_TOL * BETTER_CROSS_TOL );
	
	/* find the sharp knots (cusps on surface) */
	BSfndsfcsp( surf, num_u, sharp_u_buffer, num_v, sharp_v_buffer, &rc );

	      BS_ERRCHK( rc, "VEfind_sharp_knots: BSfndsfcsp failed" );

	/* restore cross_tol */
	BSchangepar( &rc, BSTOLCOLLINVEC, old_cross_tol );
	BSchangepar( &rc, BSTOLSQCOLLINVEC, old_cross_tol * old_cross_tol );

	*sharp_u_knots = sharp_u_buffer;
	*sharp_v_knots = sharp_v_buffer;

	}  /* VEfind_sharp_knots */


/*---- VEmark_sharps_and_rules -----------------------------------------*/

struct VEedge_header *VEmark_sharps_and_rules( elem )

	struct VEelement_header *elem;    /* pointer to element header          */

/*
NAME
	VEmark_sharps_and_rules

DESCRIPTION
	Generate the sharp edges and mesh lines for a surface

PARAMETERS
	elem (IN) - the element that is to have its sharp edges and
	            rule lines generated

RETURN VALUES
	A pointer to the linked list of sharp edges and rule lines
	is returned.

GLOBALS USED
	none

HISTORY
	09/15/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean            marking_rules = FALSE;
	IGRint                ii;
	IGRlong               num_u_sharp;
	IGRlong               num_v_sharp;
	IGRdouble             min_u, max_u, min_v, max_v;
	IGRdouble             parm;
	IGRdouble             *sharp_u_knots;
	IGRdouble             *sharp_v_knots;
	IGRdouble             points[4];

	struct IGRpolyline    polyline;
	struct IGRbsp_surface *surf;
	struct VEedge_header  *new_edge;
	struct VEedge_header  *rule_lines;
	struct VEedge_header  *head;
	struct VEedge_header  *tail;
	

	head = tail = NULL;
	surf = elem->geom.gmsurf->bspsf;

	/* set up polyline structure for trimming 2 point polylines */
	polyline.num_points = 2;
	polyline.points = points;

	/* set the knot values of the surface edges */
	min_u = surf->u_knots[ surf->u_order - 1 ];
	max_u = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	min_v = surf->v_knots[ surf->v_order - 1 ];
	max_v = surf->v_knots[ surf->v_num_knots - surf->v_order ];
	

	              /* ############ SHARP EDGES ############# */

	num_u_sharp = 0;
	num_v_sharp = 0;
	if ( !surf->planar )
	   {
	   VEfind_sharp_knots( surf, (IGRint *)&num_u_sharp, (IGRint *)&num_v_sharp,
	                             &sharp_u_knots, &sharp_v_knots );

	   /* look at sharp edges that are constant in u */
	   for ( ii = 0; ii < num_u_sharp; ii++ )
	      {
	      parm = sharp_u_knots[ii];
	      /* create edge header for sharp edge */
	      new_edge = VEconstruct_iso_edge( surf, CONST_U_POLY, parm, SHARP );

	      if ( new_edge )
	         {
	         if ( elem->flags & HAS_BOUNDARIES )
	            {
	            /* define 2 point polyline for edge */
	            points[0] = parm; points[1] = min_v;
	            points[2] = parm; points[3] = max_v;
	            new_edge = VEtrim_polyline( elem, new_edge, &polyline, CONST_U_POLY );
	            }

	         VEadd_edges_to_list( new_edge, &head, &tail );
	         }  /* end: if ( new_edge ) */

	      }  /* end: for */

	   /* look at sharp edges that are constant in v */
	   for ( ii = 0; ii < num_v_sharp; ii++ )
	      {
	      parm = sharp_v_knots[ii];
	      /* create edge header for sharp edge */
	      new_edge = VEconstruct_iso_edge( surf, CONST_V_POLY, parm, SHARP );

	      if ( new_edge )
	         {
	         if ( elem->flags & HAS_BOUNDARIES )
	            {
	            /* define 2 point polyline for edge */
	            points[0] = min_u; points[1] = parm;
	            points[2] = max_u; points[3] = parm;
	            new_edge = VEtrim_polyline( elem, new_edge, &polyline, CONST_V_POLY );
	            }

	         VEadd_edges_to_list( new_edge, &head, &tail );
	         }  /* end: if ( new_edge ) */

	      }  /* end: for */

	   }  /* end: if (! surf->planar ) */



	              /* ############ RULE LINES ############# */

	if ( marking_rules )
	   {
	   rule_lines = VEmark_rule_lines( elem->objid, elem->env->osnum, surf,
	                                   num_u_sharp, sharp_u_knots,
	                                   num_v_sharp, sharp_v_knots );
	                                 
	   VEadd_edges_to_list( rule_lines, &head, &tail );
	   
	   }  /* end: if ( marking_rules) */

	return( head );
	
	}  /* VEmark_sharps_and_rules */
