
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/


#include <stdio.h>

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

#include "bsxtractpar.h"

/* External Global Variables */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEinit_temp_lists __((	struct VEelement_header *element ));

#if defined(__cplusplus)
}
#endif

#undef __


#define Z_RANGES_OVERLAP   0
#define DOM_ELEM_IN_FRONT  1
#define PASS_ELEM_IN_FRONT 2

#define COMPARE_EDGES                                                                          \
	                                                                                       \
	if ( ((dom_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) ||                  \
             ((pass_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE) )                  \
	   {                                                                                   \
	   pseudo_int = ( (! VEexec_parms.VEtracing) &&                                        \
	                  (dom_element->flags & pass_element->flags & ALL_EDGES_INVISIBLE) );  \
	   VEcompare_edges( dom_edge, pass_edge,                                               \
	                    dom_element, pass_element,                                         \
	                    dom_elem_can_hide_pass_elem,                                       \
	                    pass_elem_can_hide_dom_elem,                                       \
	                    pseudo_int, self_hiding );                                         \
	   }                                                                                   \


#define COMPARE_EDGES_DOM_IN_FRONT                                                             \
	                                                                                       \
	if ( (dom_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE )                     \
	   {                                                                                   \
	   pseudo_int = ( (! VEexec_parms.VEtracing) &&                                        \
	                  (pass_edge->status & (TOTALLY_OVERLAPPED | TOTALLY_INVISIBLE)) );    \
	   VEdisjoint_z_compare_edges( dom_edge, pass_edge,                                    \
	                               dom_element, pass_element,                              \
	                               dom_elem_can_hide_pass_elem,                            \
	                               pseudo_int );                                           \
	   }                                                                                   \


#define COMPARE_EDGES_PASS_IN_FRONT                                                            \
	                                                                                       \
	if ( (pass_edge->status & EDGE_CLASSIFICATION) == VISIBLE_PROFILE )                    \
	   {                                                                                   \
	   pseudo_int = ( (! VEexec_parms.VEtracing) &&                                        \
	                  (dom_edge->status & (TOTALLY_OVERLAPPED | TOTALLY_INVISIBLE)) );     \
	   VEdisjoint_z_compare_edges( pass_edge, dom_edge,                                    \
	                               pass_element, dom_element,                              \
	                               pass_elem_can_hide_dom_elem,                            \
	                               pseudo_int );                                           \
	   }                                                                                   \


/*--- VEinit_temp_lists ------------------------------------------*/

static void VEinit_temp_lists( element )

	struct VEelement_header *element;

/*
NAME
	VEinit_temp_lists (static)

DESCRIPTION
	This function initializes the temp-lists of all edges of an
	element with endpoint nodes.

PARAMETERS
	element (IN) - the element whose edges are to have their
	               temp-lists initialized

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *edge;
	struct IGRbsp_curve  *cv;

	edge = element->edges;
	while ( edge )
	   {
	   if ( (edge->gm_curve3d) &&
	        !(edge->status & TOTALLY_OVERLAPPED) &&
	        (edge->temp_list == NULL) )
	      {
	      cv = edge->gm_curve3d->bspcv;
	      edge->temp_list = VEalloc_temp_node( cv->knots[cv->order - 1] );
	      edge->temp_list->next = VEalloc_temp_node( cv->knots[cv->num_knots - cv->order] );
	      }

	   edge = edge->next;
	   } /* end: while ( edge ) */

	}  /* VEinit_temp_lists */


/*--- VEset_element_visiblity_status -----------------------------------------*/

void VEset_element_visibility_status( element )

	struct VEelement_header *element;

/*
NAME
	VEset_element_visibility_status

DESCRIPTION
	This function updates the ALL_EDGES_INVISIBLE bit in an element's
	flags word.

PARAMETERS
	element (IN) - the element whose flag is to be set

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean           all_edges_invisible;
	struct VEedge_header *this_edge;
	
	if ( element->flags & ALL_EDGES_INVISIBLE )
	   return;
	   
	all_edges_invisible = TRUE;
	this_edge = element->edges;
	while ( this_edge )
	   {
	   if ( ! (this_edge->status & (TOTALLY_INVISIBLE | TOTALLY_OVERLAPPED) ) )
	      {
	      all_edges_invisible = FALSE;
	      break;
	      }
	   this_edge = this_edge->next;
	   }  /* end: while */
	   
	if ( all_edges_invisible )
	   element->flags |= ALL_EDGES_INVISIBLE;

	}  /* VEset_element_visibility_status */
	 
	
/*--- VEcomp_surfs  --------------------------------------------*/

void VEcomp_surfs( struct VEelement_header *dom_element,
		   struct VEelement_header *pass_element,
		   IGRboolean              doing_hiding,
		   IGRboolean              self_hiding )

/*
NAME
	VEcomp_surfs

DESCRIPTION
	This function compares two elements resolving both their visiblity
	and overlaps with respect to each other.

PARAMETERS
	dom_element (IN) - one of the elements to compare
	pass_element (IN) - the other element to compare
	doing_hiding (IN) - TRUE, if hiding is being done
	self_hiding (IN) - TRUE, if self-hiding is being done

GLOBALS USED
	VEexec_status	
	
HISTORY
	xx/xx/xx    P.R. Slubicki
	   Creation Date
*/

	{
	BSrc                 rc;
	IGRboolean           dom_edge_is_dummy = FALSE;
	IGRboolean           pass_edge_is_dummy = FALSE;
	IGRboolean           dom_elem_can_hide_pass_elem;
	IGRboolean           pass_elem_can_hide_dom_elem;
	IGRboolean           pseudo_int;
	IGRshort             elem_z_range_status;
	IGRdouble            default_cht, mod_cht;
	struct VEedge_header *dom_edge, *pass_edge, *real_dom_edge, *real_pass_edge;
	IGRdouble            *dom_range, *pass_range;

	if ( IGEstop() )
	   {
	   /* the user has requested that VE abort processing */
	   VEexec_status.VEabort = TRUE;
	   return;
	   }

	/* Update the hearbeat of the process to let the */
	/* user know that processing is still occuring.  */
	VEupdate_heartbeat();
	
	BSxtractpar( &rc, BSTOLCHRDHT,  &default_cht );
	mod_cht = default_cht * 2.0;

	dom_range = dom_element->range;
	pass_range = pass_element->range;
	if ( (dom_range[XMIN] > (pass_range[XMAX] + mod_cht) ) ||
	     (dom_range[XMAX] < (pass_range[XMIN] - mod_cht) ) ||
	     (dom_range[YMIN] > (pass_range[YMAX] + mod_cht) ) ||
	     (dom_range[YMAX] < (pass_range[YMIN] - mod_cht) ) )
	   return;  /* ranges don't overlap in XY space */

	dom_elem_can_hide_pass_elem = (dom_element->type == SURFACE) && (doing_hiding);
	pass_elem_can_hide_dom_elem = (pass_element->type == SURFACE) && (doing_hiding);

	/* Determine the status of the Z-extents of the element's range boxes */
	elem_z_range_status = Z_RANGES_OVERLAP;
	if ( (dom_range[ZMIN] < (pass_range[ZMIN] - mod_cht)) &&
	     (dom_range[ZMAX] < (pass_range[ZMIN] - mod_cht)) )
	   elem_z_range_status = DOM_ELEM_IN_FRONT;
	else if ( (pass_range[ZMIN] < (dom_range[ZMIN] - mod_cht)) &&
	          (pass_range[ZMAX] < (dom_range[ZMIN] - mod_cht)) )
	   elem_z_range_status = PASS_ELEM_IN_FRONT;
	   
	/* Initialize the "temp-lists" with endpoint nodes. */
	if ( elem_z_range_status != DOM_ELEM_IN_FRONT )
	   VEinit_temp_lists( dom_element );

	if ( elem_z_range_status != PASS_ELEM_IN_FRONT )
	   VEinit_temp_lists( pass_element );

	/* Compare each edge in dom_element (dom_edge) to each edge in       */
	/* pass_element. Process the dominant edge's "temp list"             */
	/* after it has been compared against all the edges in pass_element. */
	/* The same holds for all the edges in pass_element (pass_edge).     */

	dom_edge = dom_element->edges;
	while ( dom_edge )
	   {
	   if ( ! DUMMY_EDGE_FROM_SOLID( dom_element, dom_edge ) )
	      {
	      /* If dom_edge is a dummy shared edge, then assign its curve pointer */
	      /* to its partner's curve pointer. After processing dom_edge, I need */
	      /* to reassign its curve pointer to NULL. I will do the same for     */
	      /* pass_edge below.                                                  */
	      if (dom_edge->gm_curve3d == NULL)
	         {
	         dom_edge_is_dummy = TRUE;
	         dom_edge->gm_curve3d = dom_edge->shared_edge->gm_curve3d;
	         dom_edge->gm_curve2d = dom_edge->shared_edge->gm_curve2d;
	         real_dom_edge = dom_edge->shared_edge;
	         }
	      else
	         real_dom_edge = dom_edge;

	      pass_edge = pass_element->edges;
	      while ( pass_edge )
	         {
	         if ( ! DUMMY_EDGE_FROM_SOLID( pass_element, pass_edge ) )
	            {
	            if (pass_edge->gm_curve3d == NULL)
	               {
	               pass_edge_is_dummy = TRUE;
	               pass_edge->gm_curve3d = pass_edge->shared_edge->gm_curve3d;
	               pass_edge->gm_curve2d = pass_edge->shared_edge->gm_curve2d;
	               real_pass_edge = pass_edge->shared_edge;
	               }
	            else
	               real_pass_edge = pass_edge;

	            if ( (! (dom_edge->shared_edge == pass_edge)) &&
	                 (! SIBLINGS_FROM_PLANAR_PARENT( real_dom_edge, real_pass_edge )) )
	               {
	               /* we are not comparing a real shared edge to its corresponding */
	               /* dummy and we are not comparing two edges split from the same */
	               /* planar parent edge                                           */
	               if ( !( (dom_edge->range[XMIN] > pass_edge->range[XMAX] + mod_cht) ||
	                       (dom_edge->range[XMAX] < pass_edge->range[XMIN] - mod_cht) ||
	                       (dom_edge->range[YMIN] > pass_edge->range[YMAX] + mod_cht) ||
	                       (dom_edge->range[YMAX] < pass_edge->range[YMIN] - mod_cht) ) )
	                  {
	                  /* Curves overlap in XY space */

	                  /* Compare the two edges */
	                  switch ( elem_z_range_status )
	                     {
	                     case DOM_ELEM_IN_FRONT :
	                     
	                        COMPARE_EDGES_DOM_IN_FRONT;
	                        break;

	                     case PASS_ELEM_IN_FRONT :
	                     
	                        COMPARE_EDGES_PASS_IN_FRONT;
	                        break;

	                     default :
	                     
	                        /* check Z ranges of edges to see if VEdisjoint_z_compare_edges */
	                        /* can be called                                                */
	                        if ( (dom_edge->range[ZMIN] < (pass_edge->range[ZMIN] - mod_cht)) &&
	                             (dom_edge->range[ZMAX] < (pass_edge->range[ZMIN] - mod_cht)) )
	                           {
	                           COMPARE_EDGES_DOM_IN_FRONT;
	                           }
	                        else if ( (pass_edge->range[ZMIN] < (dom_edge->range[ZMIN] - mod_cht)) &&
	                                  (pass_edge->range[ZMAX] < (dom_edge->range[ZMIN] - mod_cht)) )
	                           {
	                           COMPARE_EDGES_PASS_IN_FRONT;
	                           }
	                        else
	                           {
	                           COMPARE_EDGES;
	                           }

	                        break;
	                        
	                     }  /* end: switch */

	                  } /* end: if dom_edge and pass_edge are in the same range */

	               }  /* end: if */

	            if (pass_edge_is_dummy)
	               {
	               pass_edge->gm_curve3d = NULL;
	               pass_edge->gm_curve2d = NULL;
	               pass_edge_is_dummy = FALSE;
	               }
        
	            }  /* end: if ( ! DUMMY_EDGE_FROM_SOLID ... ) */

	         pass_edge = pass_edge->next;
	         } /* end: while ( pass_edge ) */

	      if (dom_edge_is_dummy)
	         {
	         dom_edge->gm_curve3d = NULL;
	         dom_edge->gm_curve2d = NULL;
	         dom_edge_is_dummy = FALSE;
	         }

	      }  /* end: if ( ! DUMMY_EDGE_FROM_SOLID ... ) */

	   dom_edge = dom_edge->next;
	   } /* end: while ( dom_edge ) */

	} /* VEcomp_surfs */
