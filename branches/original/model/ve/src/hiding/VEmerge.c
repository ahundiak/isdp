
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#include <stdio.h>
#include <math.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

#include "igrdp.h"
#include "dpstruct.h"

#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_hiding.h"
#include "VEpr_utilfnc.h"

#include "bscvkttol2.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEcreate_and_insert_vnode __((
					IGRdouble           u_val,
					IGRshort            visibility,
					struct VEvisib_node *prev_vnode ));

static void VEinsert_visib __((		IGRdouble           u_left, 
					IGRdouble           u_right,
					IGRshort            temp_visib,
					struct VEvisib_node *start_visib,
					IGRdouble           knot_tol ));

#if defined(__cplusplus)
}
#endif

#undef __


/*--- VEcreate_and_insert_vnode ----------------------------------------*/

static void VEcreate_and_insert_vnode(	IGRdouble           u_val,
					IGRshort            visibility,
					struct VEvisib_node *prev_vnode )
  
/*
NAME
	VEcreate_and_insert_vnode (static)

DESCRIPTION
	This function allocates and inserts a visib node
	with a given parameter into a visib list

PARAMETERS
	u_val (IN) - the parameter at which to create the
	             visibility node
	visibility (IN) - the visibility of the visib node
	prev_vnode (IN) - the visib node previous to the
	                  one that is being created

GLOBALS USED
	none

HISTORY
	xx/xx/xx    P.R. Slubicki
	   Creation Date
*/

	{
	struct VEvisib_node *new_vnode;
  
	/* Create the new vnode. */
	new_vnode = VEalloc_visib_node(u_val);
	new_vnode->visib = visibility;
  
	/* Insert the new vnode. */
	new_vnode->next = prev_vnode->next;
	prev_vnode->next = new_vnode;
	} /* end VEcreate_and_insert_vnode */    


/*--- VEinsert_visib -----------------------------------------------------------*/

static void VEinsert_visib(	IGRdouble           u_left,
				IGRdouble           u_right,
				IGRshort            temp_visib,
				struct VEvisib_node *start_visib,
				IGRdouble           knot_tol )
  
/*
NAME
	VEinsert_visib (static)

DESCRIPTION
	This function inserts a visiblity region into a
	visib list.

PARAMETERS
	u_left (IN) - the start parameter of the visibility region
	u_right (IN) - the end parameter of the visibility region
	temp_visib (IN) - the visibility of the region
	start_visib (IN) - the visib list to add the region to
	knot_tol (IN) - the knot tolerance to use

GLOBALS USED
	none

HISTORY
	xx/xx/xx    P.R. Slubicki
	   Creation Date
*/

	{
	IGRboolean last_changed;
	IGRshort   prev_visib = UNKNOWN;
	struct VEvisib_node *visib_srch, *visib_srch_prev;
  
	visib_srch = start_visib->next;
	visib_srch_prev = start_visib;
	while ( (u_left - visib_srch->u) > knot_tol )
	   {
	   visib_srch = visib_srch->next;
	   visib_srch_prev = visib_srch_prev->next;
	   }
    
	last_changed = FALSE;
	if ( fabs( u_left - visib_srch->u ) <= knot_tol )
	   {
	   if ( temp_visib > visib_srch->visib )
	      {
	      prev_visib = visib_srch->visib;
	      visib_srch->visib = temp_visib;
	      last_changed = TRUE;
	      }
	   visib_srch = visib_srch->next;
	   visib_srch_prev = visib_srch_prev->next;
	   }
	else if ( fabs( u_left - visib_srch_prev->u ) <= knot_tol )
	   {
	   if ( temp_visib > visib_srch_prev->visib )
	      {
	      prev_visib = visib_srch_prev->visib;
	      visib_srch_prev->visib = temp_visib;
	      last_changed = TRUE;
	      }
	   }
	else /* if visib_srch_prev->u < u_left < visib_srch->u */
	   {
	   if ( temp_visib > visib_srch_prev->visib )
	      {
	      prev_visib = visib_srch_prev->visib;
	      VEcreate_and_insert_vnode( u_left, temp_visib, visib_srch_prev );
	      last_changed = TRUE;
	      visib_srch_prev = visib_srch_prev->next;
	      }
	   }
    
	if ( visib_srch )
	   {
	   while ( (u_right - visib_srch->u) > knot_tol )
	      {
	      last_changed = FALSE;
	      if ( temp_visib > visib_srch->visib )
	         {
	         prev_visib = visib_srch->visib;
	         visib_srch->visib = temp_visib;
	         last_changed = TRUE;
	         }
	      visib_srch = visib_srch->next;
	      visib_srch_prev = visib_srch_prev->next;
	      }
    
	   if ( !(fabs( u_right - visib_srch->u ) <= knot_tol) && (last_changed) )
	      VEcreate_and_insert_vnode( u_right, prev_visib, visib_srch_prev );
	   }

	} /* VEinsert_visib */


/*--- VEmerge_visibs ---------------------------------------------------------*/  

void VEmerge_visibs( edge )

	struct VEedge_header *edge;
  
/*
NAME
	VEmerge_visibs

DESCRIPTION
	This function merges the visibilities on the temp list
	of an edge into the visib list.

PARAMETERS
	edge (IN) - the edge whose visibility lists are to
	            be merged

GLOBALS USED
	none

HISTORY
	xx/xx/xx    P.R. Slubicki
	   Creation Date
*/

	{
	IGRboolean visible_region;
	IGRdouble  knot_tol;
	BSrc       rc;
	struct VEtemp_node  *temp_ptr;
	struct VEvisib_node *visib_ptr, *visib_prev_ptr;
	struct IGRbsp_curve *curve;
  
	curve = edge->gm_curve3d->bspcv;
	BScvkttol2( curve->order, curve->knots,
	            curve->num_poles, curve->poles, curve->weights,
	            &knot_tol, &rc );

	visib_ptr = edge->visib_list;
	temp_ptr = edge->temp_list;
	while ( temp_ptr->next )
	   {
	   if ( (temp_ptr->next_visib != VISIBLE) &&
	        (temp_ptr->next_visib != UNKNOWN) )
	      {
	      VEinsert_visib( temp_ptr->u, temp_ptr->next->u,
                     temp_ptr->next_visib, visib_ptr, knot_tol );
	      }

	   temp_ptr = temp_ptr->next;
	   } /* end while */
    
	VEfree_temp_node_list( edge->temp_list ); 
	edge->temp_list = NULL;
    
	/* Simplify the visib-list. */
	visib_prev_ptr = edge->visib_list;
	visib_ptr = visib_prev_ptr->next;
	while ( visib_ptr->next )
	   {
	   if ( visib_prev_ptr->visib == visib_ptr->visib )
	      {
	      visib_prev_ptr->next = visib_ptr->next;
	      VEfree_visib_node( visib_ptr );
	      visib_ptr = visib_prev_ptr->next;
	      }
	   else
	      {
	      visib_prev_ptr = visib_ptr;
	      visib_ptr = visib_ptr->next;
	      }
	   } /* end while */

	/* Set the edge's status. */
	visib_ptr = edge->visib_list;
	if ( (visib_ptr->visib == OVERLAPPED) &&
	     (visib_ptr->next->next == NULL) )
	   {
	   edge->status |= TOTALLY_OVERLAPPED;
	   }
	else
	   {
	   visible_region = FALSE;
	   while ( (visib_ptr->next) && (!visible_region) )
	      {
	      if ( visib_ptr->visib == VISIBLE )
	         visible_region = TRUE;
	      visib_ptr = visib_ptr->next;
	      } /* end while */

	   if ( !visible_region )
	      edge->status |= TOTALLY_INVISIBLE;
	   } /* end else */
    
	} /* VEmerge_visibs */

