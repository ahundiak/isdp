
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

#include <alloca.h>

#include "OMerrordef.h"
#include "OMmacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"

#include "igr.h"
#include "igrdp.h"

#include "msdef.h"

#include "gr.h"
#include "grgs.h"

#include "godef.h"

#include "go.h"

#include "dp.h"
#include "dpstruct.h"
#include "dpdef.h"

#include "grdpbmacros.h"

#include "bs.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
%safe
#include "VEpr_marking.h"
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
%endsafe

from EMSsubbs   import EMgetRuleLineTable;
from EMSgradata import EMget_class_info;
from EMSgradata import EMgetGraphics;
from GRcoxhatch import GRxhget_gg;


/*---- VEmark_wireframe_cross_hatching --------------------------------------*/

void VEmark_wireframe_cross_hatching( element )

	struct VEelement_header *element;

/*
NAME
	VEmark_wireframe_cross_hatching

DESCRIPTION
	This function marks the cross-hatching of a wireframe element.  The
	cross-hatching is represented by a graphic group of line strings on
	the wireframe objects "notification" channel.  The line strings are
	retrieved from the graphic group, transformed to viewing coordinates
	and added to the wireframe element's list of edges.  The wireframe
	element is also flagged as having cross-hatching.  The line strings
	are transformed into viewing coordinates by placing them into a
	temporary element header and having the routines that transform an
	element into viewing coordinates do the job.

PARAMETERS
	element (IN) - the wireframe element that is to have its wireframe
	               cross-hatching marked

GLOBALS USED
	none

HISTORY
	08/08/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong                 sts;
	IGRlong                 msg;
	IGRint                  comp;
	IGRint                  object;
	IGRint                  num_components;
	OMuint                  num_channel_objects;
	IGRint                  linkage_size;
	struct VEelement_header temp_elem;
	struct VEedge_header    *new_edge;
	struct GRid             xhatch_gg;
	struct GRid             *comp_ids;
	OMuword                 coxhatch_classid;
	OMuword                 elem_classid;
	OM_S_OBJECT_LINKAGE     static_linkages[NUM_STATIC_LINKAGES];
	OM_S_OBJECT_LINKAGE     *linkages;
	OM_S_CHANSELECT         notify_channel;


	sts = om$get_classid( classname = "GRcoxhatch",
	                      p_classid = &coxhatch_classid );

	sts = om$make_chanselect( channame     = "GRnotify.notification",
	                          p_chanselect = &notify_channel );
	
	/* find out how many objects are on the notification channel */
	sts = om$get_channel_count( objid        = element->objid,
	                            osnum        = element->env->osnum,
	                            p_chanselect = &notify_channel,
	                            count        = &num_channel_objects );


	   OM_ERRCHK( sts, "VEmark_wf_crosshatching: om$get_channel_count failed" );

	/* get space to hold channel objects */
	if ( num_channel_objects > NUM_STATIC_LINKAGES )
	   {
	   /* static space for linkages isn't enough => */
	   /* allocate space to hold the linkages       */
	   linkages = (OM_S_OBJECT_LINKAGE *)
	                 malloc( num_channel_objects * sizeof( OM_S_OBJECT_LINKAGE ) );
	   linkage_size = num_channel_objects;
	   }
	else
	   {
	   linkages  = static_linkages;
	   linkage_size = NUM_STATIC_LINKAGES;
	   }

	sts = om$get_channel_objects( objid        = element->objid,
	                              osnum        = element->env->osnum,
	                              p_chanselect = &notify_channel,
	                              list         = linkages,
	                              size         = linkage_size,
	                              count        = &num_channel_objects );

	   OM_ERRCHK( sts, "VEmark_wf_crosshatching: om$get_channel_objects failed" );

	/* Check all objects on the notification channel to see if they */
	/* are wireframe cross-hatching objects                         */
	for ( object = 0; object < num_channel_objects; object++ )
	   {
	   /* see if this object is a wireframe cross-hatching object */
	   sts = om$get_classid( objid     = linkages[object].S_objid,
	                         osnum     = linkages[object].osnum,
	                         p_classid = &elem_classid );

	   OM_ERRCHK( sts, "VEmark_wf_crosshatching: om$get_classid failed" );

	   if ( om$is_ancestry_valid( subclassid   = elem_classid,
	                              superclassid = coxhatch_classid ) == OM_S_SUCCESS )
	      {
	      /* This is a cross-hatching object => get the the curves that   */
	      /* make up the cross-hatching graphic group and add them to the */
	      /* element's edge list                                          */
	      sts = om$send( mode     = OM_e_wrt_object,
	                     msg      = message GRcoxhatch.GRxhget_gg( &msg, &xhatch_gg ),
	                     targetid = linkages[object].S_objid,
	                     targetos = linkages[object].osnum,
	                     senderid = NULL_OBJID );

	      num_components = 0;
	      VEget_components( &xhatch_gg, &num_components, NULL );
	      comp_ids = (struct GRid *) alloca( num_components * sizeof( struct GRid ) );
	      VEget_components( &xhatch_gg, &num_components, comp_ids );

	      element->flags |= HAS_CROSS_HATCHING;

	      for ( comp = 0; comp < num_components; comp++ )
	         {
	         /* put information in a temporary element header */
	         /* so we can get the geometry of the cross-hatch */
	         /* curve in the viewing coordainte system        */
	         temp_elem.objid = comp_ids[comp].objid;
	         temp_elem.env   = element->env;
	         temp_elem.type  = CURVE;

	         /* VEget_element_geometry will return the geometry in viewing coords */
	         VEget_element_geometry( &temp_elem, element->env );

	         /* allocate and initialize edge header for this cross-hatching element */
	         new_edge          = VEalloc_edge_header();
	         new_edge->edge_id = temp_elem.objid;
	         new_edge->type    = WIREFRAME_CROSS_HATCH;
	         new_edge->gm_curve3d = VEalloc_geom_curve( 0, 0, 0, 0 );
	         new_edge->gm_curve3d->bspcv   = temp_elem.geom.curve;
	      
	         new_edge->visib_list = VEconstruct_visib_list( new_edge->gm_curve3d->bspcv, VISIBLE );

	         /* add new edge to element's edge list */
	         new_edge->next = element->edges;
	         element->edges = new_edge;

	         }  /* end: for ( comp ... ) */

	      }  /* end: if ( om$is_ancestry_valid(...) */

	   }  /* end: for ( object ... ) */

	if ( linkages != static_linkages )
	   {
	   /* free malloced array of object linkages */
	   free( (IGRchar *) linkages );
	   }

	}  /* VEmark_wireframe_cross_hatching */


/*---- VEmark_surface_cross_hatching ------------------------------------------------------*/

void VEmark_surface_cross_hatching( element )

	struct VEelement_header *element;

/*
NAME
	VEmark_surface_cross_hatching

DESCRIPTION
	This function marks the cross-hatching of a surface element.  The only
	surfaces that can be cross-hatched are planes.  The cross-hatching is
	represented by a special cross-hatching rule line object that is on
	the element's "to_helpers" channel.  The cross-hatching elements are
	retrieved in a manner similar to rule lines for a surface and are
	added to the element's list of edges.  The surface element is also
	flagged as having cross-hatching.

PARAMETERS
	element (IN) - the surface that is to have its cross-hatching marked

GLOBALS USED
	none

HISTORY
	08/17/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               sts;
	IGRlong               EMmsg;
	IGRint                object;
	OMuint                num_channel_objects;
	IGRint                linkage_size;
	struct IGResqbs       *rlt;
	struct VEedge_header  *rule_lines;
	struct VEedge_header  *head;
	struct VEedge_header  *tail;
	struct IGRbsp_surface *rlt_surf;
	OMuword               cross_hatch_classid;
	OMuword               obj_classid;
	IGRdouble             static_rlt[ STATIC_RLT_SIZE / 8 ];
	OM_S_OBJECT_LINKAGE   static_linkages[NUM_STATIC_LINKAGES];
	OM_S_OBJECT_LINKAGE   *linkages;
	OM_S_CHANSELECT       helper_channel;


	if ( ! element->geom.gmsurf->bspsf->planar )
	   return;  /* can only cross-hatch planes */

	head = tail = NULL;

	sts = om$make_chanselect( channame     = "EMSrequester.to_helpers",
	                          p_chanselect = &helper_channel );

	/* get cross-hatching from EMSgradata objects */

	sts = om$get_classid( classname = "EMSchatch",
	                      p_classid = &cross_hatch_classid );

	sts = om$get_channel_count( objid        = element->objid,
	                            osnum        = element->env->osnum,
	                            p_chanselect = &helper_channel,
	                            count        = &num_channel_objects );

	   OM_ERRCHK( sts, "VEmk_sf_cross_hatching: om$get_channel_count failed" );

	if ( num_channel_objects > NUM_STATIC_LINKAGES )
	   {
	   /* static space for linkages isn't enough => */
	   /* allocate space to hold the linkages       */
	   linkages = (OM_S_OBJECT_LINKAGE *)
	                malloc( num_channel_objects * sizeof( OM_S_OBJECT_LINKAGE ) );
	   linkage_size = num_channel_objects;
	   }
	else
	   {
	   linkages  = static_linkages;
	   linkage_size = NUM_STATIC_LINKAGES;
	   }

	sts = om$get_channel_objects( objid        = element->objid,
	                              osnum        = element->env->osnum,
	                              p_chanselect = &helper_channel,
	                              list         = linkages,
	                              size         = linkage_size,
	                              count        = &num_channel_objects );

	   OM_ERRCHK( sts, "VEmk_sf_cross_hatching: om$get_channel_objects failed" );

	/* process each object on the channel individually */
	for ( object = 0; object < num_channel_objects; object++ )
	   {
	   om$get_classid( objid     = linkages[object].S_objid,
	                   osnum     = linkages[object].osnum,
	                   p_classid = &obj_classid );

	         OM_ERRCHK( sts, "VEmk_sf_cross_hatching: om$get_classid failed" );

	   if ( obj_classid == cross_hatch_classid )
	      {
	      /* this object is a cross-hatching object => get its rule line table */
	      rlt_surf = NULL;
	      sts = om$send( mode     = OM_e_wrt_object,
	                     msg      = message EMSgradata.EMgetGraphics( &EMmsg,
	                                                                  (IGRchar *) static_rlt,
	                                                                  STATIC_RLT_SIZE,
	                                                                  &rlt,
	                                                                  NULL,
	                                                                  NULL,
	                                                                  NULL,
	                                                                  element->geom.gmsurf->bspsf,
	                                                                  &rlt_surf ),
	                     senderid = NULL_OBJID,
	                     targetid = linkages[object].S_objid,
	                     targetos = linkages[object].osnum );

	         OM_ERRCHK( sts, "VEmk_sf_cross_hatching: EMSgradata.EMgetGraphics send failed" );
	         MSG_ERRCHK( EMmsg, "VEmk_sf_cross_hatching: EMSgradata.EMgetGraphics failed" );

	      /* construct list of edges from RLT */
	      rule_lines = VEprocess_RLT( rlt, rlt_surf, TRUE, 0, NULL, 0, NULL );

	      VEadd_edges_to_list( rule_lines, &head, &tail );

	      if ( rlt != (struct IGResqbs *) static_rlt )
	         {
	         /* method allocated rlt => free it */
	         free( (IGRchar *) rlt );
	         }
	         
	      if ( rlt_surf != element->geom.gmsurf->bspsf )
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

	if ( head != NULL )
	   {
	   element->flags |= HAS_CROSS_HATCHING;
	   tail->next = element->edges;
	   element->edges = head;
	   }

	}  /* VEmark_surface_cross_hatching */

end implementation Root;
