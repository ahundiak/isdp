
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:00 $
$Locker:  $
*/

class implementation Root;


#define CHECK_RETURN_CODES 1
#define DEBUG              0

#define STATIC_RLT_SIZE     1024
#define NUM_STATIC_LINKAGES 10

#include <stdio.h>
#include <stdlib.h>

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "bs.h"

#include "EMSmsgdef.h"

#include "vedef.h"
#include "ve.h"
#include "veerr.h"

/* prototype files */
#include "VEpr_marking.h"
#include "VEpr_utilfnc.h"


from EMSsubbs   import EMgetRuleLineTable;
from EMSgradata import EMget_class_info;
from EMSgradata import EMgetGraphics;

/*---- VEis_parm_sharp -------------------------------------------------------------*/

static IGRboolean VEis_parm_sharp(
   IGRdouble parm,
   IGRdouble *sharp_knots,
   IGRint    num_sharp )

/*
NAME
	VEis_parm_sharp (static)

DESCRIPTION
	Determine if a parameter value is in an array of sharp knots

PARAMETERS
	parm (IN) - parameter to test
	sharp_knots (IN) - array of sharp knots
	num_sharp (IN) - number of knots in the sharp knot array

RETURN VALUES
	TRUE - if 'parm' is in the sharp knot array
	FALSE - otherwise

GLOBALS USED
	none

HISTORY
	09/16/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRint ii;

	for ( ii = 0; ii < num_sharp; ii++ )
	   {
	   if ( parm == sharp_knots[ii] )
	      {
	      return( TRUE );
	      }
	   }

	return( FALSE );
	}  /* VEis_parm_sharp */


/*---- VEprocess_clip_points ----------------------------------------------*/

static struct VEedge_header *VEprocess_clip_points(
   struct VEedge_header *rule_line,
   IGRint               num_bounds,
   IGRdouble            *bounds )

/*
NAME
	VEprocess_clip_points (static)

DESCRIPTION
	This function takes an edge header and a clip point array for a rule
	line and returns a linked list of edge headers that represent the solid
	portions of the rule line.

PARAMETERS
	rule_line (IN) - the rule line whose clip points are to be processed
	num_bounds (IN) - number of clip points
	bounds (IN) - array of clip points

RETURN VALUES
	A linked list of edge headers that represent the solid portions of
	the rule line is returned.

GLOBALS USED
	none

NOTES
	The rule line edge header passed in to the function is freed by
	this function.  

HISTORY
	01/06/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRint               ii;
	IGRint               last;
	struct VEedge_header *new_edge;
	struct VEedge_header *list;


	list = NULL;

	last = num_bounds * 2 - 1;
	
	if ( bounds[0] != 0.0 )
	   {
	   /* solid region from 0.0 to bounds[0] */
	   list = VEedge_split( rule_line, 0.0, bounds[0] );
	   }
	   
	for ( ii = 1; ii < last; ii += 2 )
	   {
	   /* solid region from bounds[ii] to bounds[ii+1] */
	   new_edge = VEedge_split( rule_line, bounds[ii], bounds[ii+1] );
	   if ( new_edge != NULL )
	      {
	      new_edge->next = list;
	      list = new_edge;
	      }
	   }
	   
	if ( bounds[last] != 1.0 )
	   {
	   /* solid region from bounds[last] to 1.0 */
	   new_edge = VEedge_split( rule_line, bounds[last], 1.0 );
	   if ( new_edge != NULL )
	      {
	      new_edge->next = list;
	      list = new_edge;
	      }
	   }

	VEfree_visib_node_list( rule_line->visib_list );
	VEfree_edge_header( rule_line );

	return( list );
	}


/*---- VEprocess_RLT ------------------------------------------------------*/

struct VEedge_header *VEprocess_RLT( struct IGResqbs       *rlt,
				     struct IGRbsp_surface *surf,
				     IGRboolean            cross_hatching,
				     IGRint                num_u_sharp,
				     IGRdouble             *sharp_u,
				     IGRint                num_v_sharp,
				     IGRdouble             *sharp_v )

/*
NAME
	VEprocess_RLT

DESCRIPTION
	This function takes a rule line table with clip points and creates
	a linked-list of edges that represent the clipped rule lines.

PARAMETERS
	rlt (IN) - the rule line table to process
	surface (IN) - the surface to which the rule line table belongs
	cross_hatching (IN) - TRUE, if rule lines represent cross hatching
	num_u_sharp (IN) - number of sharp u knots on the surface
	sharp_u (IN) - array of sharp u knots
	num_v_sharp (IN) - number of sharp v knots on the surface
	sharp_ (IN) - array of sharp v knots

RETURN VALUES
	A linked list of edges that represent the clipped rule lines is
	returned.

GLOBALS USED
	none

HISTORY
	01/04/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRint               rules;
	IGRdouble            parm;
	IGRdouble            min_u, max_u, min_v, max_v;
	struct VEedge_header *new_edge;
	struct VEedge_header *head;
	struct VEedge_header *tail;


	head = tail = NULL;

	/* set the knot values of the surface edges */
	min_u = surf->u_knots[ surf->u_order - 1 ];
	max_u = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	min_v = surf->v_knots[ surf->v_order - 1 ];
	max_v = surf->v_knots[ surf->v_num_knots - surf->v_order ];

	/* constant u rule lines */
	for ( rules = 0; rules < rlt->u_rules; rules++ )
	   {
	   parm = rlt->u_rule_values[rules];
	   /* only mark rule lines that are cross hatching lines or normal */
	   /* rules lines that don't lie on a surface edge or a sharp edge */
	   if ( cross_hatching ||
	      ( ( parm != min_u ) &&
	        ( parm != max_u ) &&
	        ( !VEis_parm_sharp( parm, sharp_u, num_u_sharp ) ) ) )
	      {
	      /* create edge header for mesh line */
	      new_edge = VEconstruct_iso_edge( surf, CONST_U_POLY, parm, MESH );

	      if ( new_edge )
	         {
	         if ( rlt->u_num_bound[rules] != 0 )
	            {
	            new_edge = VEprocess_clip_points( new_edge,
	                                              rlt->u_num_bound[rules],
	                                              rlt->u_bdrys[rules] );
	            }

	         VEadd_edges_to_list( new_edge, &head, &tail );
	         }  /* end: if ( new_edge ) */

	      }  /* end: rule line isn't sharp or a surface edge */

	   }  /* end: for */

	/* constant v rule lines */
	for ( rules = 0; rules < rlt->v_rules; rules++ )
	   {
 	   parm = rlt->v_rule_values[rules];
	   /* only mark rule lines that are cross hatching lines or normal */
	   /* rules lines that don't lie on a surface edge or a sharp edge */
	   if ( cross_hatching ||
	      ( ( parm != min_v ) &&
	        ( parm != max_v ) &&
	        ( !VEis_parm_sharp( parm, sharp_v, num_v_sharp ) ) ) )
	      {
	      /* create edge header for mesh line */
	      new_edge = VEconstruct_iso_edge( surf, CONST_V_POLY, parm, MESH );

	      if ( new_edge )
	         {
	         if ( rlt->v_num_bound[rules] != 0 )
	            {
	            new_edge = VEprocess_clip_points( new_edge,
	                                              rlt->v_num_bound[rules],
	                                              rlt->v_bdrys[rules] );
	            }

	         VEadd_edges_to_list( new_edge, &head, &tail );
	         }  /* end: if ( new_edge ) */

	      }  /* end: rule line isn't sharp or a surface edge */

	   }  /* end: for */

	return( head );

	}  /* VEprocess_RLT */


/*---- VEmark_rule_lines ------------------------------------------------------*/

struct VEedge_header *VEmark_rule_lines( surf_id, surf_os, surf,
	                                 num_u_sharp, sharp_u, num_v_sharp, sharp_v )


	IGRint                 surf_id;
	IGRint                 surf_os;
	struct IGRbsp_surface  *surf;
	IGRint                 num_u_sharp;
	IGRdouble              *sharp_u;
	IGRint                 num_v_sharp;
	IGRdouble              *sharp_v;

/*
NAME
	VEmark_rule_lines

DESCRIPTION
	Generate and return a linked list of edge headers that represent the
	rule lines for a surface.

PARAMETERS
	surf_id (IN) - the object id of the surface whose rule lines are to
	               be marked
	surf_os (IN) - the object space number of the surface
	surface (IN) - the surface to which the rule line table belongs
	num_u_sharp (IN) - number of sharp u knots on the surface
	sharp_u (IN) - array of sharp u knots
	num_v_sharp (IN) - number of sharp v knots on the surface
	sharp_ (IN) - array of sharp v knots

RETURN VALUES
	A linked list of edges that represent the clipped rule lines is
	returned.

GLOBALS USED
	none

HISTORY
	12/31/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               sts;
	IGRlong               EMmsg;
	IGRint                ii;
	OMuint                chan_count;
	IGRint                linkage_size;
	struct IGResqbs       *rlt;
	struct VEedge_header  *rule_lines;
	struct VEedge_header  *head;
	struct VEedge_header  *tail;
	struct IGRbsp_surface *rlt_surf;
	OMuword               gradata_classid;
	OMuword               cross_hatch_classid;
	OMuword               obj_classid;
	IGRdouble             static_rlt[ STATIC_RLT_SIZE / 8 ];
	OM_S_OBJECT_LINKAGE   static_linkages[NUM_STATIC_LINKAGES];
	OM_S_OBJECT_LINKAGE   *linkages;
	OM_S_CHANSELECT       helper_channel;

	head = tail = NULL;

	sts = om$make_chanselect( channame     = "EMSrequester.to_helpers",
	                          p_chanselect = &helper_channel );

	   OM_ERRCHK( sts, "VEmark_rule_lines: om$make_chanselect failed" );

	/* see if there are EMSgradata (rule line) objects for this surface */
	EMmsg = EMS_I_NoResponse;
	sts = om$send( mode         = OM_e_wrt_object,
	               msg          = message EMSgradata.EMget_class_info( &EMmsg, NULL, NULL ),
	               senderid     = surf_id,
	               p_chanselect = &helper_channel,
	               targetos     = surf_os );

	   OM_ERRCHK( sts, "VEmark_rule_lines: EMSgradata.EMget_class_info failed" );

	if ( EMmsg == EMS_I_NoResponse )
	   {
	   /* there were no EMSgradata objects for this */
	   /* surface => get the RLT from the surface   */
	   sts = om$send( mode = OM_e_wrt_object,
	                  msg  = message EMSsubbs.EMgetRuleLineTable( &EMmsg,
	                                                              FALSE,
	                                                              NULL, NULL,
	                                                              surf,
	                                                              NULL, NULL,
	                                                              (IGRchar *) static_rlt,
	                                                              STATIC_RLT_SIZE,
	                                                              &rlt ),
	                  senderid = NULL_OBJID,
	                  targetid = surf_id,
	                  targetos = surf_os );


	      OM_ERRCHK( sts, "VEmark_rule_lines: EMSsubbs.EMgetRuleLineTable send failed" );
	      MSG_ERRCHK( EMmsg, "VEmark_rule_lines: EMSsubbs.EMgetRuleLineTable failed" );

	   /* construct list of edges from RLT */
	   head = VEprocess_RLT( rlt, surf, FALSE,
	                         num_u_sharp, sharp_u, num_v_sharp, sharp_v );

	   if ( rlt != (struct IGResqbs *) static_rlt )
	      {
	      /* method allocated memory, so it must be freed */
	      free( (IGRchar *) rlt );
	      }
	   }
	else
	   {
	   /* get rule lines from EMSgradata objects */
	   sts = om$get_classid( classname = "EMSgradata",
	                         p_classid = &gradata_classid );

	   sts = om$get_classid( classname = "EMSchatch",
	                         p_classid = &cross_hatch_classid );

	   sts = om$get_channel_count( objid        = surf_id,
	                               osnum        = surf_os,
	                               p_chanselect = &helper_channel,
	                               count        = &chan_count );

	      OM_ERRCHK( sts, "VEmark_rule_lines: om$get_channel_count failed" );

	   if ( chan_count > NUM_STATIC_LINKAGES )
	      {
	      /* static space for linkages isn't enough => */
	      /* allocate space to hold the linkages       */
	      linkages = (OM_S_OBJECT_LINKAGE *)
	                   malloc( chan_count * sizeof( OM_S_OBJECT_LINKAGE ) );
	      linkage_size = chan_count;
	      }
	   else
	      {
	      linkages  = static_linkages;
	      linkage_size = NUM_STATIC_LINKAGES;
	      }

	   sts = om$get_channel_objects( objid        = surf_id,
	                                 osnum        = surf_os,
	                                 p_chanselect = &helper_channel,
	                                 list         = linkages,
	                                 size         = linkage_size,
	                                 count        = &chan_count );

	      OM_ERRCHK( sts, "VEmark_rule_lines: om$get_channel_objects failed" );

	   /* process each object on the channel individually */
	   for ( ii = 0; ii < chan_count; ii++ )
	      {
	      om$get_classid( objid     = linkages[ii].S_objid,
	                      osnum     = linkages[ii].osnum,
	                      p_classid = &obj_classid );

	         OM_ERRCHK( sts, "VEmark_rule_lines: om$get_classid failed" );

	      if ( obj_classid == gradata_classid )
	         {
	         /* this object is a rule line object => get its rule line table */
	         rlt_surf = NULL;
	         sts = om$send( mode     = OM_e_wrt_object,
	                        msg      = message EMSgradata.EMgetGraphics( &EMmsg,
	                                                                     (IGRchar *) static_rlt,
	                                                                     STATIC_RLT_SIZE,
	                                                                     &rlt,
	                                                                     NULL,
	                                                                     NULL,
	                                                                     NULL,
	                                                                     surf,
	                                                                     &rlt_surf ),
	                        senderid = NULL_OBJID,
	                        targetid = linkages[ii].S_objid,
	                        targetos = linkages[ii].osnum );

	            OM_ERRCHK( sts, "VEmark_rule_lines: EMSgradata.EMgetGraphics send failed" );
	            MSG_ERRCHK( EMmsg, "VEmark_rule_lines: EMSgradata.EMgetGraphics failed" );

	         /* construct list of edges from RLT */
	         rule_lines = VEprocess_RLT( rlt, rlt_surf, FALSE,
	                                     num_u_sharp, sharp_u, num_v_sharp, sharp_v );

	         VEadd_edges_to_list( rule_lines, &head, &tail );

	         if ( rlt != (struct IGResqbs *) static_rlt )
	            {
	            /* method allocated rlt => free it */
	            free( (IGRchar *) rlt );
	            }
	         
	         if ( rlt_surf != surf )
	            {
	            /* method allocated memory for surface => free it */
	            free( (IGRchar *) rlt_surf );
	            }

  	         }  /* end: if */
 
	      }  /* end: for */

	   if ( linkages != static_linkages )
	      {
	      /* free array of object linkages because there */
	      /* wasn't enough static space                  */
	      free( (IGRchar *) linkages );
	      }

	   }  /* end: else */

	return( head );

	}  /* VEmark_rule_lines */

end implementation Root;
