
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:41:59 $
$Locker:  $

HISTORY

        Sudha   07/28/93        Modified for BSprototype ansification
*/

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "bs.h"
#include "bsparameters.h"
#include "bsxtractpar.h"

#include "ve.h"
#include "vedef.h"

/* prototype files */
#include "VEpr_debug.h"
	
/*---- VEvisib_list_debug ------------------------------------------------------*/

void VEvisib_list_debug( node )

	struct VEvisib_node *node;

/*
NAME
	VEvisib_list_debug

KEYWORD
	debug

DESCRIPTION
	This function prints the data from a visib list to standard error

PARAMETERS
	node (IN) - the head of the visib list

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	while ( node  )
	   {
	   fprintf( stderr, "         u = %18.16lf\n ",node->u );
	   if ( node->next )
	      {
	      fprintf( stderr, "          " );
	      switch ( node->visib )
	         {
	         case UNKNOWN         : fprintf( stderr, "UNKNOWN\n" ); break;
	       
	         case VISIBLE         : fprintf( stderr, "VISIBLE\n" ); break;
	      
	         case HIDDEN          : fprintf( stderr, "HIDDEN\n" );  break; 
	    
	         case OVERLAPPED      : fprintf( stderr, "OVERLAPPED\n" ); break;
	  
	         case DO_NOT_PROCESS  : fprintf( stderr, "DO NOT PROCESS\n" ); break;

	         case DEGENERATE_SPAN : fprintf( stderr, "DEGENERATE\n" ); break;

	         }
	      }
	   node = node->next;
           }  /* end: while */
        
	}  /* VEvisib_list_debug */



/*---- VEtemp_list_debug -------------------------------------------------------*/

void VEtemp_list_debug( node )

	struct VEtemp_node *node;

/*
NAME
	VEtemp_list_debug

KEYWORD
	debug

DESCRIPTION
	This function prints the data from a temp list to standard error

PARAMETERS
	node (IN) - the head of the temp list

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	while ( node )
	   {
	   fprintf( stderr, "         u = %18.16lf   ",node->u );
	   switch ( node->prev_visib )
	      {
	      case UNKNOWN        : fprintf( stderr, "U :" ); break;
	    
	      case VISIBLE        : fprintf( stderr, "V :" ); break;
	      
	      case HIDDEN         : fprintf( stderr, "H :" ); break; 
	   
	      case OVERLAPPED     : fprintf( stderr, "O :" ); break;
	   
	      case DO_NOT_PROCESS : fprintf( stderr, "D :" ); break;

	      }
	   switch ( node->next_visib )
	      {
	      case UNKNOWN        : fprintf( stderr, " U\n" ); break;
	       
	      case VISIBLE        : fprintf( stderr, " V\n" ); break;
	      
	      case HIDDEN         : fprintf( stderr, " H\n" ); break; 
	   
	      case OVERLAPPED     : fprintf( stderr, " O\n" ); break;
	   
	      case DO_NOT_PROCESS : fprintf( stderr, " D\n" ); break;

	      }
	   node = node->next;
           }  /* end: while */
        
	}  /* VEtemp_list_debug */


/*--- VEwrite_curve_type ----------------------------------------*/

void VEwrite_curve_type(struct BSgeom_bsp_curve *gmcurve,
			IGRboolean              new_line )

/*
NAME
	VEwrite_curve_type (static)

DESCRIPTION
	This function writes the type of a curve to stderr.

KEYWORD
	debug

PARAMETERS
	gmcurve (IN) - the curve whose type is to be written
	new_line (IN) - if TRUE, write new line also

GLOBALS USED
	none

HISTORY
	10/13/92    S.P. Rogers
	   Creation Date
*/

	{
	switch ( gmcurve->type )
	   {
	   case BSPOINT :
	      fprintf( stderr, "Point" ); break;
	   case BSLINE :
	      fprintf( stderr, "Line" ); break;
	   case BSCIRCLE :
	      fprintf( stderr, "Circle" ); break;
	   case BSELLIPSE :
	      fprintf( stderr, "Ellipse" ); break;
	    case BSPARAB_ARC :
	      fprintf( stderr, "Parabolic Arc" ); break;
	   case BSHYPER_ARC :
	      fprintf( stderr, "Hyperbolic Arc" ); break;
	   case BSCIRC_ARC :
	      fprintf( stderr, "Circular Arc" ); break;
	   case BSELLIP_ARC :
	      fprintf( stderr, "Elliptical Arc" ); break;
	   case BSGEN_BSP_CV :
	      fprintf( stderr, "General Bspline Curve" ); break;
	   case BSINF_LINE :
	      fprintf( stderr, "Infinite Line" ); break;
	   case BS3DLINESTR :
	      fprintf( stderr, "3-D Linestring" ); break;
	   case BS2DLINESTR :
	      fprintf( stderr, "2-D Linestring" ); break;
	   }

	if ( new_line )
	   fprintf( stderr, "\n" );

	}  /* VEwrite_curve_type */


/*---- VEedge_debug ------------------------------------------------------------*/

void VEedge_debug( edge )

	struct VEedge_header *edge;

/*
NAME
	VEedge_debug

KEYWORD
	debug

DESCRIPTION
	This function prints the data from an edge to standard error

PARAMETERS
	edge (IN) - the edge to print

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint      i;
	
	fprintf( stderr, "  Edge type:               " );
	switch ( edge->type )
	   {
	   case NATURAL :
	   
	      fprintf( stderr, "Natural edge" );
	      if ( ( edge->gm_curve3d == NULL ) || ( edge->status & WAS_A_DUMMY ) )
	         fprintf( stderr, " - Dummy\n" );
	      else if ( edge->shared_edge )
	         fprintf( stderr, " - Real\n" );
	      else
	         fprintf( stderr, "\n" );
	      break;
	      
	   case SHARP :
	   
	      fprintf( stderr, "Sharp edge\n" );
	      break;
	      
	   case MESH :
	   
	      fprintf( stderr, "Mesh line\n" );
	      break;
	      
	   case BOUNDARY :
	   
	      fprintf( stderr, "Boundary" );
	      if ( ( edge->gm_curve3d == NULL ) || ( edge->status & WAS_A_DUMMY ) )
	         fprintf( stderr, " - Dummy\n" );
	      else if ( edge->shared_edge )
	         fprintf( stderr, " - Real\n" );
	      else
	         fprintf( stderr, "\n" );
	      break;

	   case HORIZON_EDGE :
	   
	      fprintf( stderr, "Horizon Edge\n" );
	      break;

	   case HORIZON_CURVE :
	   
	      fprintf( stderr, "Horizon Curve\n" );
	      break;

	   case STANDALONE :
	   
	      fprintf( stderr, "Standalone curve\n" );
	      break;
	      
	   case SINGLE_POINT :
	   
	      fprintf( stderr, "Single point\n" );
	      break;
	   }

	if ( edge->gm_curve3d )
	   {
	   fprintf( stderr, "  3D Curve type:           " );
	   VEwrite_curve_type( edge->gm_curve3d, TRUE );
	   }
	if ( edge->gm_curve2d )
	   {
	   fprintf( stderr, "  2D Curve type:           " );
	   VEwrite_curve_type( edge->gm_curve2d, TRUE );
	   }

	fprintf( stderr, "  Edge id:                 %d\n", edge->edge_id );
	fprintf( stderr, "  Saved Cv/Cv Id:          %d\n", edge->saved_cvcv_id );

	fprintf( stderr, "  Shared elem pointer:     %X\n", edge->shared_elem );
	fprintf( stderr, "  Shared edge pointer:     %X\n", edge->shared_edge );
	if ( edge->shared_edge )
	   {
	   fprintf( stderr, "  Linked elem:             %d\n", edge->shared_elem->objid );
	   fprintf( stderr, "  Linked edge:             %d\n", edge->shared_edge->edge_id );
	   }
	   
	if ( edge->gm_curve3d )
	   fprintf( stderr, "  3D Order, Num poles:     %d,%d\n",
	            edge->gm_curve3d->bspcv->order, edge->gm_curve3d->bspcv->num_poles );
	if ( edge->gm_curve2d )
	   fprintf( stderr, "  2D Order, Num poles:     %d,%d\n",
	            edge->gm_curve2d->bspcv->order, edge->gm_curve2d->bspcv->num_poles );

	fprintf( stderr, "  Stroked curve pointer:   %X\n", edge->stroked_gmcurve );
	if ( edge->stroked_gmcurve )
	   {
	   fprintf( stderr, "    Stroked Curve type:        " );
	   VEwrite_curve_type( edge->stroked_gmcurve, TRUE );
	   fprintf( stderr, "    Stroked num poles:  %d\n", edge->stroked_gmcurve->bspcv->num_poles );
	   }

	fprintf( stderr, "  Range:               %14.7lf %14.7lf %14.7lf\n",
	                 edge->range[XMIN], edge->range[YMIN], edge->range[ZMIN] );
	fprintf( stderr, "                       %14.7lf %14.7lf %14.7lf\n",
	                 edge->range[XMAX], edge->range[YMAX], edge->range[ZMAX] );

	fprintf( stderr, "  Classification:            " );
	switch ( edge->status & EDGE_CLASSIFICATION )
	   {
	   case VISIBLE_PROFILE :
	      fprintf( stderr, "VISIBLE PROFILE\n" );
	      break;
	   case VISIBLE_NON_PROFILE :
	      fprintf( stderr, "VISIBLE NON-PROFILE\n" );
	      break;
	   case HIDDEN_NORMAL_FLIP :
	      fprintf( stderr, "HIDDEN NORMAL FLIP\n" );
	      break;
	   case HIDDEN_NON_PROFILE :
	      fprintf( stderr, "HIDDEN NON-PROFILE\n" );
	      break;
	   }

	fprintf( stderr, "  Already classified?        %s\n", 
	         (edge->status & ALREADY_CLASSIFIED) ? "YES" : "NO" );

	fprintf( stderr, "  Using dummy geometry?      %s\n", 
	         (edge->status & USING_DUMMY_GEOMETRY) ? "YES" : "NO" );

	fprintf( stderr, "  Totally overlapped?        %s\n", 
	         (edge->status & TOTALLY_OVERLAPPED) ? "YES" : "NO" );

	fprintf( stderr, "  Totally invisible?         %s\n", 
	         (edge->status & TOTALLY_INVISIBLE) ? "YES" : "NO" );

	fprintf( stderr, "  Real shared edge?          %s\n", 
	         (edge->status & REAL_SHARED_EDGE) ? "YES" : "NO" );
	         
	fprintf( stderr, "  Was a dummy?               %s\n", 
	         (edge->status & WAS_A_DUMMY) ? "YES" : "NO" );
	         
	fprintf( stderr, "  Collinear edge?            %s\n",
	         (edge->status & COLLINEAR_EDGE) ? "YES" : "NO" );

	fprintf( stderr, "  Has saved cvcv-int data?   %s\n",
	         (edge->status & HAS_SAVED_INT_DATA) ? "YES" : "NO" );
	         
	if ( edge->status & (WAS_A_DUMMY | REAL_SHARED_EDGE) )
	   fprintf( stderr, "  Different Edge Type?       %s\n",
	            (edge->status & DIFFERENT_EDGE_TYPES) ? "YES" : "NO" );
	   
	fprintf( stderr, "  Use double projection?     %s\n",
	         (edge->status & USE_DOUBLE_PROJECTION) ? "YES" : "NO" );

	fprintf( stderr, "  Has self overlaps?         %s\n",
	         (edge->status & HAS_SELF_OVERS) ? "YES" : "NO" );

	fprintf( stderr, "  Trimmed a parting line?    %s\n",
	         (edge->status & TRIMMED_A_PARTING_LINE) ? "YES" : "NO" );

	fprintf( stderr, "  Split from planar parent?  %s\n",
	         (edge->status & TRIMMED_A_PARTING_LINE) ? "YES" : "NO" );

	fprintf( stderr, "  Tangent Edge?  %s\n",
	         (edge->status & EDGE_IS_TANGENT) ? "YES" : "NO" );

	fprintf( stderr, "  Constant U Iso Curve?      %s\n",
	         (edge->status & CONSTANT_U_ISOCURVE) ? "YES" : "NO" );

	fprintf( stderr, "  Constant V Iso Curve?      %s\n",
	         (edge->status & CONSTANT_V_ISOCURVE) ? "YES" : "NO" );

	if ( edge->status & EDGE_IS_ISOCURVE )
	   fprintf( stderr, "  Iso Parameter:             %18.16lf\n", edge->iso_parm );

	if ( ( edge->num_sh_spans ) && ( edge->sh_spans) && ( edge->gm_curve3d ) )
	   {
	   fprintf( stderr, "\n    Self-hidden spans:\n\n" );
	   for ( i = 0; i < edge->num_sh_spans; i++ )
	      {
	      fprintf( stderr, "   %18.16lf : %18.16lf\n",
	               edge->sh_spans[i*2], edge->sh_spans[i*2+1] );
	      }
	   }
	   
	fprintf( stderr, "\n    Visibility list:\n\n" );
	VEvisib_list_debug( edge->visib_list );
	
	if ( edge->temp_list )
	   {
	   fprintf( stderr, "\n    Temporary list:\n\n" );
	   VEtemp_list_debug( edge->temp_list );
	   }

	fprintf( stderr, "\n\n\n" );

	}  /* VEedge_debug */

/*---- VEelement_debug ---------------------------------------------------------*/

void VEelement_debug( element )


	struct VEelement_header *element;

/*
NAME
	VEelement_debug

KEYWORD
	debug

DESCRIPTION
	This function prints the data from an element to standard error

PARAMETERS
	element (IN) - the element to print

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *cur_edge;

	fprintf( stderr, "\n\n********* ELEMENT DEBUG **********\n\n" );

	fprintf( stderr, "Element ID,OS:       %d,%d\n", element->objid, element->env->osnum );
	fprintf( stderr, "Parent ID:           %d\n", element->parent_id );
	fprintf( stderr, "Loopset ID:          %d\n", element->loopset_id );
	fprintf( stderr, "Type:                " );
	switch ( element->type )
	   {
	   case SURFACE :
	   
	      fprintf( stderr, "Surface - " );
	      if ( element->geom.gmsurf )
	         {
	         switch( element->geom.gmsurf->type )
	            {
	            case BSGEN_BSP_SF :
	               fprintf( stderr, "General\n" ); break;
	            case BSRECT_PLANE:
	               fprintf( stderr, "Rectangular Plane\n" ); break;
	            case BSINF_PLANE:
	               fprintf( stderr, "Infinite Plane\n" ); break;
	            case BSFULL_CYL :
	               fprintf( stderr, "Cylinder\n" ); break;
	            case BSFULL_CONE :
	               fprintf( stderr, "Cone\n" ); break;
	            case BSSPHERE :
	               fprintf( stderr, "Sphere\n" ); break;
	            case BSTORUS :
	               fprintf( stderr, "Torus\n" ); break;
	            case BSPART_CYL :
	               fprintf( stderr, "Partial Cylinder\n" ); break;
	            case BSPART_CONE :
	               fprintf( stderr, "Partial Cone\n" ); break;
	            case BSSF_OF_PROJ :
	               fprintf( stderr, "Surface Of Projection\n" ); break;
	            case BSSF_OF_REV:
	               fprintf( stderr, "Surface Of Revoluion\n" ); break;
	            default:
	               fprintf( stderr, "Unknown\n" ); break;
	            }  /* end: switch */
	         }
	      else
	         fprintf( stderr, "\n" );
	      break;
	      
	   case CURVE :
	   
	      fprintf( stderr, "Curve\n" );
	      break;
	      
	   case POINT :
	   
	      fprintf( stderr, "Point\n" );
	      break;
	   }

	fprintf( stderr, "Range:                %14.7lf %14.7lf %14.7lf\n",
	                    element->range[XMIN], element->range[YMIN], element->range[ZMIN] );
	fprintf( stderr, "                      %14.7lf %14.7lf %14.7lf\n",
	                    element->range[XMAX], element->range[YMAX], element->range[ZMAX] );

	fprintf( stderr, "U-range:             %12.10lf %12.10lf\n",
	         element->u_range[0], element->u_range[1] );

	fprintf( stderr, "V-range:             %12.10lf %12.10lf\n",
	         element->v_range[0], element->v_range[1] );

	fprintf( stderr, "Has Boundaries?      %s\n", 
	         (element->flags & HAS_BOUNDARIES) ? "YES" : "NO" );

	fprintf( stderr, "All Edges Invisible? %s\n", 
	         (element->flags & ALL_EDGES_INVISIBLE) ? "YES" : "NO" );

	fprintf( stderr, "Has cross hatching?  %s\n\n",
	         (element->flags & HAS_CROSS_HATCHING) ? "YES" : "NO" );

	cur_edge = element->edges;
	while ( cur_edge )
	   {
	   VEedge_debug( cur_edge );
	   cur_edge = cur_edge->next;
	   }

	}  /* VEelement_debug */



/*---- VEactive_list_debug -----------------------------------------------*/

void VEactive_list_debug( list )

	struct VEelement_header *list;
	
/*
NAME
	VEactive_list_debug

KEYWORD
	debug

DESCRIPTION
	This function prints the data from an active list to standard error

PARAMETERS
	list (IN) - the active list to print

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	struct VEelement_header *elem;
	
	
	elem = list;

	while ( elem )
	   {
	   fprintf( stderr, "     %5d,%2d     (%17.12lf,%17.12lf)   (%17.12lf,%17.12lf)\n",
	            elem->objid, elem->env->osnum,
	            elem->range[XMIN], elem->range[YMIN], elem->range[XMAX], elem->range[YMAX] );

	   elem = elem->next;

	   }  /* end: while */

	fprintf( stderr, "\n" );
	
	}  /* VEactive_list_debug */



/*--- VEsaved_int_list_debug ------------------------------------------*/

void VEsaved_int_list_debug( list )

	struct VEsaved_int_node *list;
	
/*
NAME
	VEsaved_int_list_debug

KEYWORD
	debug

DESCRIPTION
	This function prints the data from a saved intersection list
	to standard error.

PARAMETERS
	list (IN) - the saved intersection list to print

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRshort i;
	IGRdouble *ints;
	IGRdouble *overs;
	
	while ( list )
	   {
	   fprintf( stderr, "\n\nIntersection Info\n\n" );
	   fprintf( stderr, "  Ids:         %d:%d\n", list->id0, list->id1 );
	   fprintf( stderr, "  Buffer size: %d\n", list->buffer_size );
	   fprintf( stderr, "  Ints left:   %d\n", list->ints_left );
	   fprintf( stderr, "  Num int:     %d\n", list->num_int );
	   ints = list->buffer;
	   overs = &(list->buffer[list->num_int*2]);
	   for ( i = 0; i < list->num_int; i++ )
	      fprintf( stderr, "               %lf    %lf\n",
	               ints[i], ints[i+list->num_int] );
	               
	   fprintf( stderr, "  Num over:    %d\n", list->num_over );
	   for ( i = 0; i < list->num_over; i++ )
	      fprintf( stderr, "               %lf:%lf    %lf:%lf\n",
	               overs[i*2], overs[i*2+1],
	               overs[i*2+(list->num_over*2)],
	               overs[i*2+(list->num_over*2) + 1] );
	   	   
	   list = list->next;
	   }  /* end: while */
	   
	}  /* VEsaved_int_list_debug */
	

/*--- VElog_mult_proj_data ----------------------------------------------*/

void VElog_mult_proj_data( 	struct VEelement_header *hiding_element,
				IGRint                  proj_count,
				IGRpoint                *points,
				IGRint                  num_vecs,
				IGRpoint                *vecs,
				IGRboolean              bi_directional,
				IGRint                  alloc )
	                   
	
/*
NAME
	VElog_mult_proj_data

KEYWORD
	debug

DESCRIPTION
	This function prints the data required by the math group
	to debug a multiple point projection problem.

PARAMETERS
	hiding_element (IN) - the hiding element
	proj_count (IN) - the number of projections
	points (IN) - the array of projection points
	num_vecs (IN) - number of projection vectors
	vecs (IN) - the array of projection vectors
	bi_directional (IN) - bi-directional projection flag
	alloc (IN) - pre-allocation size for results

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint    i;
	IGRlong   rc;
	IGRdouble base_tol;
	IGRdouble dist_tol;

	BSxtractpar( &rc, BSTOLBASIS, &base_tol );
	BSxtractpar( &rc, BSTOLLENVEC, &dist_tol );
	
	fprintf( stderr, "\n---------------------------------------------------------\n" );
	fprintf( stderr, "Base tol:  %20.16lf\n", base_tol );
	fprintf( stderr, "Dist tol:  %20.16lf\n", dist_tol );
	
	fprintf( stderr, "\nNumber of projection points: %d\n", proj_count );
	fprintf( stderr, "Points:\n\n" );
	for ( i = 0; i< proj_count; i++ )
	   {
	   fprintf( stderr, "   %20.14lf  %20.14lf %20.14lf\n",
	            points[i][0], points[i][1], points[i][2] );
	   }


	fprintf( stderr, "\n" );
	fprintf( stderr, "Number of projection vectors: %d\n", num_vecs );
	fprintf( stderr, "Vectors:\n\n" );
	for ( i = 0; i< num_vecs; i++ )
	   {
	   fprintf( stderr, "   %20.14lf  %20.14lf %20.14lf\n",
	            vecs[i][0], vecs[i][1], vecs[i][2] );
	   }

	
	fprintf( stderr, "\n" );
	fprintf( stderr, "U-range:         %12.8lf  %12.8lf\n",
	         hiding_element->u_range[0], hiding_element->u_range[1] );
	fprintf( stderr, "V-range:         %12.8lf  %12.8lf\n",
	         hiding_element->v_range[0], hiding_element->v_range[1] );
	         
	fprintf( stderr, "Bi-directional:  %d\n", bi_directional );
	fprintf( stderr, "Allocation:      %d\n", alloc );
	
	fprintf( stderr, "\n" );
	fprintf( stderr, "Surface:\n\n" );
	VEdebug_surface( hiding_element->geom.gmsurf->bspsf, TRUE );

	fprintf( stderr, "\n---------------------------------------------------------\n" );

	}  /* VElog_mult_proj_data */


/*--- VElog_mult_proj_output ----------------------------------------------*/

void VElog_mult_proj_output( proj_count,
	                     num,
	                     proj_pts,
	                     uv_par )

	IGRint      proj_count;
	IGRint      *num;
	IGRpoint    *proj_pts;
	IGRdouble   *uv_par;
	
/*
NAME
	VElog_mult_proj_data

KEYWORD
	debug

DESCRIPTION
	This function prints the data required by the math group
	to debug a multiple point projection problem.

PARAMETERS
	proj_count (IN) - the number of projections
	num (IN) - array of the number of hits for each projection point
	proj_pts (IN) - array of hit points
	uv_par (IN) - array of hit parameters

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRint i;
	IGRint j;
	IGRint index = 0;
		
	fprintf( stderr, "\n---------------------------------------------------------\n" );
	fprintf( stderr, "Output from BSmjptssf ...\n" );

	for ( i = 0; i < proj_count; i++ )
	   {
	   fprintf( stderr, "\n   From point: %d  %d hits\n\n", i, num[i] );
	   for ( j = 0; j < num[i]; j++, index++ )
	      {
	      fprintf( stderr, "      (%20.15lf,%20.15lf,%20.15lf) - (%20.15lf,%20.15lf)\n",
	               proj_pts[index][0], proj_pts[index][1], proj_pts[index][2],
	               uv_par[index*2], uv_par[index*2+1] );
	      }

	   }

	fprintf( stderr, "\n---------------------------------------------------------\n" );

	}  /* VElog_mult_proj_output */
	
