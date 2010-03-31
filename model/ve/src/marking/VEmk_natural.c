
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

#define  CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_utilfnc.h"
#include "VEpr_marking.h"

	     
/*---- VEgen_natural_edges -----------------------------------------------*/

struct VEedge_header *VEgen_natural_edges( surf )

	struct IGRbsp_surface  *surf;

/*
NAME
	VEgen_natural_edges

DESCRIPTION
	Generate the natural edges for a surface

PARAMETERS
	surf (IN) - surface whose natural edges are to be generated

RETURN VALUES
	A pointer to the linked list of natural edges of the surface is
	returned.

GLOBALS USED
	none

HISTORY
	09/16/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble             min_u, max_u, min_v, max_v;   /* surface edge knot values */
	struct VEedge_header  *new_edge;
	struct VEedge_header  *head;
	struct VEedge_header  *tail;
	
	head = tail = NULL;

	/* set the knot values of the surface edges */
	min_u = surf->u_knots[ surf->u_order - 1 ];
	max_u = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	min_v = surf->v_knots[ surf->v_order - 1 ];
	max_v = surf->v_knots[ surf->v_num_knots - surf->v_order ];
	
	if (! surf->u_phy_closed )
	   {
	   /* generate surface edges in constant u */
	   new_edge = VEconstruct_iso_edge( surf, CONST_U_POLY, min_u, NATURAL );
	   VEadd_edges_to_list( new_edge, &head, &tail );

	   new_edge = VEconstruct_iso_edge( surf, CONST_U_POLY, max_u, NATURAL );
	   VEadd_edges_to_list( new_edge, &head, &tail );

	   }  /* end: surface not physically closed in u */


	if (! surf->v_phy_closed )
	   {
	   /* generate surface edges in constant v */
	   new_edge = VEconstruct_iso_edge( surf, CONST_V_POLY, min_v, NATURAL );
	   VEadd_edges_to_list( new_edge, &head, &tail );

	   new_edge = VEconstruct_iso_edge( surf, CONST_V_POLY, max_v, NATURAL );
	   VEadd_edges_to_list( new_edge, &head, &tail );

	   }  /* end: surface not physically closed in u */

	return( head );
	
	}  /* VEgen_natural_edges */
