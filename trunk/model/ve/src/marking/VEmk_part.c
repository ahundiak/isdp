
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#define CHECK_RETURN_CODES      1
#define LOG_GROUPS_FOR_UV_PLOT  0
#define LOG_DATA_FOR_MATH_GROUP 0

#define UVRANGE_TOL 0.0000001

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igr.h"

#include "gr.h"
#include "godef.h"
#include "go.h"
#include "dpstruct.h"

#include "bs.h"
#include "bsisfprtlns.h"
#include "bsparameters.h"

#include "ve_timing.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_marking.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"

#include "bschrdlkts.h"
#include "bsptlnplan.h"
#include "bssfpartrg.h"

/* External Variables */
extern struct VEexecution_status VEexec_status;
extern struct VEwindow_info      VEwin_info;

#if TIMING
extern IGRdouble  VEtime_part;
extern IGRint     VEcount_part;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif


/*---- VEmark_parting_lines -----------------------------------------------*/

struct VEedge_header *VEmark_parting_lines( elem )

/*
NAME
	VEmark_parting_lines

DESCRIPTION
	Calculate and mark all the parting lines for a surface

PARAMETERS
	elem (IN) - the element whose parting lines are to be marked

RETURN VALUES
	A pointer to the linked list of parting line edges is
	returned.

GLOBALS USED
	VEexec_status

HISTORY
	02/23/87    S.P. Rogers
	   Creation Date
*/

	struct VEelement_header *elem;

	{
	BSrc                  rc;
	IGRint                i;
	IGRint                code;
	IGRint                num_knots;
	IGRint                num_groups;
	IGRdouble             normal[3];
	struct BSpartgrp      *groups;
	struct BSpartgrp      *temp_group;
	struct VEedge_header  *new_line;
	struct VEedge_header  *head;
	struct VEedge_header  *tail;
	struct IGRpolyline    polyline;
	struct IGRbsp_curve   *curve;
	struct IGRbsp_surface *surf;
   IGRdouble            z_vector[3];

	surf = elem->geom.gmsurf->bspsf;
	
	if ( (surf->planar) ||
	     ((elem->u_range[1] - elem->u_range[0]) < UVRANGE_TOL) ||
	     ((elem->v_range[1] - elem->v_range[0]) < UVRANGE_TOL) )
	   return( NULL );  /* no parting lines on planar surfaces or surfaces */
	                    /* whose u or v range collapses                    */

	VEupdate_heartbeat();

#if LOG_DATA_FOR_MATH_GROUP
	VElog_parting_line_data( surf, elem->u_range, elem->v_range );
#endif

	num_groups = 0;
	head = tail = NULL;

	/* find the parting lines for this surface */
#if TIMING
	times( &VEs_time );
#endif
   z_vector[0] = VEwin_info.VErot_matrix[2][0];
   z_vector[1] = VEwin_info.VErot_matrix[2][1];
   z_vector[2] = VEwin_info.VErot_matrix[2][2];
	BSsfpartrg( surf,
               z_vector,
	            elem->u_range,
	            elem->v_range,
	            1,
	            &num_groups,
	            &groups,
	            &rc );

#if TIMING
	times( &VEe_time );

	VEcount_part++;
	VEtime_part += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) -
	                   (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif

	   BS_ERRCHK( rc, "VEmark_parting_lines: BSsfpartrg failed" );
	
#if LOG_GROUPS_FOR_UV_PLOT
	{
	IGRint j,k;
	struct BSpartgrp *group;
	
	fprintf( stderr, "num_groups %d\n", num_groups );
	group = groups;
	for ( j = 0; j < num_groups; j++ )
	   {
	   fprintf( stderr, "group %d num_pts %d\n", j, group->num );
	   for ( k = 0; k < group->num; k++ )
	      fprintf( stderr, "  %lf %lf\n", group->par[k][0], group->par[k][1] );

	   group = group->next;
	   }
	}
#endif

	if ( rc == BSSUCC )
	   {
	   /* process each group as a separate edge */
	   for ( i = 0; i < num_groups; i++ )
	      {
	      new_line = VEalloc_edge_header();

	      if ( ! new_line )
	         continue;

	      new_line->type    = HORIZON_CURVE;
	      new_line->edge_id = VEexec_status.VEunique_edge_id--;
	      new_line->status  = 0;

	      /* allocate memory for curve structure */
	      new_line->gm_curve3d = VEalloc_geom_curve( 0, 0, 0, 0 );

	      if ( ! new_line->gm_curve3d )
	         {
	         VEfree_edge_header( new_line );
	         continue;
	         }

	      new_line->gm_curve3d->bspcv = curve = (struct IGRbsp_curve *)
	                                               malloc( sizeof( struct IGRbsp_curve ) );

	      if ( ! new_line->gm_curve3d->bspcv )
	         {
	         free( (IGRchar *) new_line->gm_curve3d );
	         new_line->gm_curve3d = NULL;
	         VEfree_edge_header( new_line );
	         continue;
	         }

	      /* allocate memory for knots */
	      num_knots = groups->num + 2;
	      curve->knots = (IGRdouble *) malloc( num_knots * sizeof( IGRdouble ) );

	      if ( ! curve->knots )
	         {
	         free( (IGRchar *) curve );
	         free( (IGRchar *) new_line->gm_curve3d );
	         new_line->gm_curve3d = NULL;
	         VEfree_edge_header( new_line );
	         continue;
	         }

	      curve->num_poles      = groups->num;
	      curve->order          = 2;
	      curve->periodic       = FALSE;
	      curve->non_uniform    = TRUE;
	      curve->num_knots      = num_knots;
	      curve->rational       = FALSE;
	      curve->weights        = NULL;
	      curve->planar         = FALSE;
	      curve->phy_closed     = FALSE;
	      curve->num_boundaries = 0;
	      curve->bdrys          = NULL;
	      
	      /* assign pole pointer */
	      curve->poles = (IGRdouble *) groups->pts;
	              
	      /* space knots with respect to arc length between poles */
	      BSchrdlkts( &rc,
	      	          &curve->num_poles,
	      	          curve->poles,
	      	          &curve->order,
	      	          &curve->periodic,
	      	          curve->knots );

	         BS_ERRCHK( rc, "VEmark_parting_lines: BSchrdlkts failed" );

	      new_line->visib_list = VEconstruct_visib_list( curve, VISIBLE );

	      /* check the planarity of the parting line */
	      BSptlnplan( curve->num_poles,
	                  curve->rational,
	                  (IGRpoint *)curve->poles,
	                  curve->weights,
	                  &code,
	                  normal,
	                  &rc );
	                  
	         BS_ERRCHK( rc, "VEmark_parting_lines: BSptlnplan failed" );

	      switch ( code )
	         {
	         case 1 : case 2 : case 4 :
	            /* parting line collapses to a point, line or is non-planar */
	            curve->planar = FALSE;
	            break;
	            
	         case 3 :
	            /* parting line is planar */
	            curve->planar = TRUE;
	            break;

	         }  /* end: switch */
	         
	      if ( elem->flags & HAS_BOUNDARIES )
	         {
	         /* trim the parting line */
	         polyline.num_points = groups->num;
	         polyline.points = (IGRdouble *) groups->par;
	         new_line = VEtrim_polyline( elem, new_line, &polyline, GENERAL_POLY );
	         }
	         
	      /* update list of parting lines */
	      VEadd_edges_to_list( new_line, &head, &tail );

	      temp_group = groups;
	      groups = groups->next;

	      /* free uv array in group header */
	      free( (IGRchar *) temp_group->par );
	      
	      /* free parting group header */
	      free( (IGRchar *) temp_group );
	      
	      }  /* end for ... */

	   }  /* end: if ( rc == BSSUCC ) */

	return( head );
	
	}  /* VEmark_parting_lines */
