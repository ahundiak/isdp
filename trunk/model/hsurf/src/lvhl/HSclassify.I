
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation Root;
 
#define CHECK_RETURN_CODES 1

#define DEBUG_LOCATE       0
#define DEBUG_XHATCH       0

#include <stdio.h>
#include <stdlib.h>
#include <values.h>
#include <FI.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "growner.h"
#include "dpstruct.h"
#include "exdef.h"
#include "exmacros.h"

#include "bs.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "hsurferrpriv.h"
#include "HStl_global.h"
#include "HSpvhl.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"
#include "HSplot.h"

%safe
#include "HSpr_lvhl.h"
%endsafe

from GRvg       import GRgenabsg;
from GRvg       import GRchgprops;
from GRvg       import GRgetsymb;
from GRowner    import GRget_number_components;
from GRowner    import GRget_components;
from GRaxhatch	import ASreturn_go;

/* 
 * Class-id's Needed For Element Classification 
 */
 
extern OMuword OPP_IGEwinsup_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRtext_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_GRreffile_class_id;
extern OMuword OPP_GRflxown_class_id;
extern OMuword OPP_GRclhdr_class_id;
extern OMuword OPP_GRsmhdr_class_id;
extern OMuword OPP_GRsmdfhdr_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_ACcpx_class_id;
extern OMuword OPP_ASnode_class_id;
extern OMuword OPP_AScontents_class_id;
extern OMuword OPP_GRdvattach_class_id;
extern OMuword OPP_EMSmassprop_class_id;
extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_EMSsffea_class_id;
extern OMuword OPP_GRaxhatch_class_id;
extern OMuword OPP_ASsource_class_id;
extern OMuword OPP_GRxhgg_class_id;
extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_SKcompcurve_class_id;
extern OMuword OPP_EMSasectvw_class_id;

%safe
/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSclassify.I */
static void HSturn_off_ref_file_display __((struct GRid *ref_grid, IGRboolean *turn_ref_files_off));

#if defined(__cplusplus)
}
#endif


#undef __

static	OM_S_CHANSELECT			channel1;
static	OM_S_OBJECT_LINKAGE		*linkage1 = NULL;
static	IGRint				linkage1_size = 0;
static	struct object_node_pool_info	*object_node_pool = NULL;
static	struct xhatch_node_pool_info	*xhatch_node_pool = NULL;
%endsafe

/*---HSpvhl_init_xhatch_object_node_pool------------------------------------*/

/*
NAME
	HSpvhl_init_xhatch_object_node_pool
	
DESCRIPTION
	Initialize memory pools for pvhl xhatch and object nodes.
	
HISORY
	06/04/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSpvhl_init_xhatch_object_node_pool(void)
#else
	void	HSpvhl_init_xhatch_object_node_pool()
#endif

	{
	struct object_node_pool_info	*onp;
	struct xhatch_node_pool_info	*xnp;

	/*
	 *  Initialize the object node pool.  If the first node in
	 *  the pool is NULL, then allocate one, else loop through
	 *  all the existing nodes and set the index to 0.
	 */
	 	
	if( object_node_pool == NULL )
		{
		object_node_pool = (struct object_node_pool_info *)malloc( sizeof( struct object_node_pool_info ) );
		
		object_node_pool->index = 0;
		object_node_pool->next = NULL;
		}
	else
		{
		onp = object_node_pool;
		while( onp != NULL )
			{
			onp->index = 0;
			onp = onp->next;
			}
		}

	/*
	 *  Initialize the xhatch node pool.  If the first node in
	 *  the pool is NULL, then allocate one, else loop through
	 *  all the existing nodes and set the index to 0.
	 */
	 	
	if( xhatch_node_pool == NULL )
		{
		xhatch_node_pool = (struct xhatch_node_pool_info *)malloc( sizeof( struct xhatch_node_pool_info ) );
		
		xhatch_node_pool->index = 0;
		xhatch_node_pool->next = NULL;
		}
	else
		{
		xnp = xhatch_node_pool;
		while( xnp != NULL )
			{
			xnp->index = 0;
			xnp = xnp->next;
			}
		}
	}
	
/*---HSpvhl_get_xhatch_node------------------------------------------*/

/*
NAME
	HSpvhl_get_xhatch_node
	
DESCRIPTION
	Get a xhatch node from the pvhl xhatch node pool
	
HISTORY
	06/04/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	struct xhatch_node_info		*HSpvhl_get_xhatch_node(void)
#else
	struct xhatch_node_info		*HSpvhl_get_xhatch_node()
#endif

	{
	struct xhatch_node_pool_info	*xnp;
	struct xhatch_node_info		*xni;

	/*
	 *  First the first pool that has some slots remaining
	 */
	 
	xnp = xhatch_node_pool;
	while( xnp->index >= XNP_MAX )
		xnp = xnp->next;

	/*
	 *  Get the available slot and increment the index
	 */
	 
	xni = &xnp->pool[xnp->index++];
	
	/*
	 *  If that was the last slot in the pool, then allocate
	 *  another one and attach it to the end of the existing pool
	 */
	 
	if( xnp->index >= XNP_MAX )
		{
		xnp->next = (struct xhatch_node_pool_info *)malloc( sizeof( struct xhatch_node_pool_info ) );
		xnp = xnp->next;
		xnp->next = NULL;
		xnp->index = 0;
		}
		
	return( xni );
	}

	
/*---HSpvhl_get_object_node------------------------------------------*/

/*
NAME
	HSpvhl_get_object_node
	
DESCRIPTION
	Get a object node from the pvhl object node pool
	
HISTORY
	06/04/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	struct object_node_info		*HSpvhl_get_object_node(void)
#else
	struct object_node_info		*HSpvhl_get_object_node()
#endif

	{
	struct object_node_pool_info	*onp;
	struct object_node_info		*oni;

	/*
	 *  First the first pool that has some slots remaining
	 */
	 
	onp = object_node_pool;
	while( onp->index >= ONP_MAX )
		onp = onp->next;

	/*
	 *  Get the available slot and increment the index
	 */
	 
	oni = &onp->pool[onp->index++];
	
	/*
	 *  If that was the last slot in the pool, then allocate
	 *  another one and attach it to the end of the existing pool
	 */
	 
	if( onp->index >= ONP_MAX )
		{
		onp->next = (struct object_node_pool_info *)malloc( sizeof( struct object_node_pool_info ) );
		onp = onp->next;
		onp->next = NULL;
		onp->index = 0;
		}

	oni->level = 9999;
			
	return( oni );
	}

/*---HSpvhl_set_object_level------------------------------------------*/

/*
NAME
	HSpvhl_set_object_level
	
DESCRIPTION
	All occurances of an object within the xhatch structure(s) must
	have the level number of the nearest xhatch element
	
PARAMETERS
	elem	: objid, osnum of the element to match
	level	: active level
	
HISTORY
	06/04/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSpvhl_set_object_level( struct GRid *elem,
					   IGRint level )
#else
	void	HSpvhl_set_object_level( elem, level )

	struct GRid	*elem;
	IGRint		level;
#endif

	{
	struct object_node_pool_info	*onp;
	struct object_node_info		*oni;
	int				i;

	/*
	 *  Search the existing slots for one that has the
	 *  same objid, osnum as the object in the argument
	 *  list.  If found, return with the slot address
	 */
	 
	onp = object_node_pool;
	while( onp != NULL )
		{
		for( i=0; i<onp->index; i++ )
			{
			if( onp->pool[i].id.objid == elem->objid &&
			    onp->pool[i].id.osnum == elem->osnum )
				{
				oni = &onp->pool[i];

				if( level < oni->level )
					oni->level = level;
				}
			}
						
		onp = onp->next;
		}
	}

/*---HSpvhl_get_objects_of_type_on_channel---------------------------*/

/*
NAME
	HSpvhl_get_objects_of_type_on_channel
	
DESCRIPTION
	Look at the objects at the end of the specified channel
	of the specified object, and collect only those that
	are of the specified type.

PARAMETERS
	elem_id		:(IN) :  object id of the element
	elem_os		:(IN) :  space number of the element
	channel_name	:(IN) :  string containing the name of the channel
	req_classid	:(IN) :  class id of objects we are looking for
	list		:(OUT):  place to store id's of found objects
	count		:(OUT):  Number of objects in list
		
HISTORY
	06/03/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSpvhl_get_objects_of_type_on_channel( GRobjid elem_id,
						 GRspacenum elem_os,
						       char *channel_name,
						    OMuword req_classid,
						struct GRid **list,
						     IGRint *count )
#else
	void	HSpvhl_get_objects_of_type_on_channel( 
				elem_id, elem_os, 
				channel_name, 
				req_classid, 
				list, count )	
			
	GRobjid		elem_id;
	GRspacenum	elem_os;
	char		*channel_name;
	OMuword		req_classid;
	struct GRid	**list;
	IGRint		*count;
#endif

	{
	OMuword		elem_classid;
	IGRlong		sts, i;
	IGRint		chan_count;

	/*
	 *  Initialize the return values
	 */
	 
	*list = NULL;
	*count = 0;

	/*
	 *  Get the count of objects at the end of the channel
	 */
	 		
	om$make_chanselect( channame = channel_name,
			p_chanselect = &channel1 );
			
	sts = om$get_channel_count( osnum = elem_os,
				    objid = elem_id,
			     p_chanselect = &channel1,
				    count = (OMuint *)&chan_count );

	if( chan_count > 0 )
		{
			
		/*
		 *  Look up each channel for an ASsource class object
		 */

		if( linkage1_size < chan_count )
			{
			if( linkage1 != NULL ) free( linkage1 );
		
			linkage1 = (OM_S_OBJECT_LINKAGE *)malloc( chan_count * sizeof(OM_S_OBJECT_LINKAGE) );
			linkage1_size = chan_count;
			}

		/*
		 *  Get the objects at the end of the channel and see of any of them
		 *  are of the ASsource class.  
		 */
		 
		sts = om$get_channel_objects( objid = elem_id,
					      osnum = elem_os,
				       p_chanselect = &channel1,
					       list = linkage1,
					       size = chan_count,
					      count = (OMuint *)&chan_count );

		*list = (struct GRid *)malloc( sizeof( struct GRid ) * chan_count );

		/*
		 *  look at each object at the end of the channel.  If it is
		 *  of the requested type, add it to the list
		 */
		 		
		for( i=0; i<chan_count; i++ )
			{
			sts = om$get_classid( osnum = linkage1[i].osnum,
					      objid = linkage1[i].S_objid,
					  p_classid = &elem_classid );

			if( (sts & 1) && (elem_classid == req_classid || req_classid == 0) )
				{
				(*list)[*count].objid = linkage1[i].S_objid;
				(*list)[*count].osnum = linkage1[i].osnum;
				(*count)++;
				}
			}
		
		/*
		 *  If the count of objects of the requested type is zero, then
		 *  free the list array and return NULL
		 */
		 	
		if( *count == 0 )
			{
			free( *list );
			*list = NULL;
			}
		}
	}
	
/*---HSpvhl_match_first_object_on_channel---------------------------*/

/*
NAME
	HSpvhl_match_first_object_on_channel
	
DESCRIPTION
	Compare the first object at on the channel against 
	the given object

PARAMETERS
	elem_id		:(IN) :  object id of the element
	elem_os		:(IN) :  space number of the element
	channel_name	:(IN) :  string containing the name of the channel
	id		:(OUT):  id of first object on channel
		
HISTORY
	06/03/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSpvhl_match_first_object_on_channel( GRobjid elem_id,
						   GRspacenum elem_os,
							 char *channel_name,
						      GRobjid match_id,
						   GRspacenum match_os )
#else
	IGRint	HSpvhl_match_first_object_on_channel( 
				elem_id, elem_os, 
				channel_name, 
				match_id, match_os )
			
	GRobjid		elem_id;
	GRspacenum	elem_os;
	char		*channel_name;
	GRobjid		match_id;
	GRspacenum	match_os;
#endif

	{
	IGRlong		sts;
	struct GRid	id;

	/*
	 *  Get the count of objects at the end of the channel
	 */
	 		
	om$make_chanselect( channame = channel_name,
			p_chanselect = &channel1 );
			
	sts = om$get_objid_at_index( osnum = elem_os,
				     objid = elem_id,
			      p_chanselect = &channel1,
				     index = 0,
				 objidaddr = &id.objid,
				 osnumaddr = &id.osnum );
				 
	if( (sts & 1) && (match_id == id.objid && match_os == id.osnum ) )
		return( 1 );
	else
		return( 0 );
	}
	
/*---HSget_object_level----------------------------------------------*/

/*
NAME
	HSget_object_level
	
DESCRIPTION
	Given the objid, osnum of the object, return the
	level on which it resides

HISTORY
	05/21/92	M. LANIER
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSget_object_level( struct GRid *elem )
#else
	IGRint	HSget_object_level( elem )

	struct GRid	*elem;
#endif

	{
	IGRlong			msg;
	struct GRsymbology	symb;

	om$send( msg = message GRvg.GRgetsymb( &msg, &symb ),
	    senderid = NULL_OBJID,
	    targetid = elem->objid,
	    targetos = elem->osnum );

	return( (IGRint)symb.level );
	}
	
/*---HSpvhl_build_xhatch_node----------------------------------------*/

/*
NAME
	HSpvhl_build_xhatch_node
	
DESCRIPTION
	Build a structure containing, keying on the solid boundary
	loop of a cross hatch element (or muliple cross hatch elements
	if they happen to share the same solid boundary loop).  
	
ALGORITM
	Look up the objects GRnotify.notification channel looking for
	a GRaxhatch class object.  
	
	If found see if this is the solid boundary loop for the cross 
	hatch element.
	
	If not found, loop up the objects GRconnector.to_owners channel
	looking for a GRxhgg class object.  If found ignore this object,
	it will be picked up later, else add this object to the xhatch
	list as a non-xhatch object.
	
	If a GRaxhatch class object was found, look to see if this
	was the solid boundary loop of the cross hatch object.  If it
	is not, then ignore, we will pick it up later as well.
	
	If it is the solid boundary loop, the create an xhatch_node
	for it, then look down the NDfather.father channel of the
	GRaxhatch object to the the hole loops then up the
	GRcmpowner.to_components channel to the GRxhgg class object
	then down the GRcmpowner.to_components to get the xhatch lines.
	
	Build all these into a structure with the solid boundary loop
	as the root node, plus a link list of hole boundary loops and
	another link list of xhatch line objects.  Also include the
	level of the solid object.
	
	When building nodes for the hole and xhatch line objects,
	min test the level of the active solid boundary loop with the
	level in the object node returned by the HSpvhl_get_object_node
	function.  The purpose here is of the hole is share by
	multiple cross hatch elements, we what the level of the
	nearest one.  Then during the 2nd pass, we will only send
	the hole curve to the tiler when the nearest cross hatch
	element is being processed.  This prevents the object from
	going into the tiler more than once and getting overlapping
	overrides.
	
HISTORY
	06/04/92	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSpvhl_build_xhatch_node( struct GRobj_env *obj_info,
				   struct xhatch_node_info **xhatch_top )
#else
	void	HSpvhl_build_xhatch_node( obj_info, xhatch_top )

	struct GRobj_env	*obj_info;
	struct xhatch_node_info	**xhatch_top;
#endif

	{
	OMuword			elem_classid;
#	if DEBUG_XHATCH
	IGRchar			classname[50];
#	endif

	IGRint			i, j, k, l;
	struct xhatch_node_info	*xhatch;
	struct object_node_info	*xobj;
	struct GRid		*as_list, *xhgg_list, *ax_list, *axas_list, *asgo_list, *xh_list, *xhl_list;
	IGRint			 as_count, xhgg_count, ax_count, axas_count, asgo_count, xh_count, xhl_count;

	/*
	 *  Classify the object as
	 *    (1)  A xhatch boundary
	 *         (a)  The solid loop
	 *         (b)  One of the hole loops
	 *    (2)  A xhatch line
	 *    (3)  Something else
	 */
	 

#	if DEBUG_XHATCH
	fprintf( stderr, "HSpvhl_build_xhatch_node\n" );

	om$get_classname( osnum = obj_info->obj_id.osnum,
	                  objid = obj_info->obj_id.objid,
	                  classname = classname );

	fprintf( stderr, "  Object %d:%d - %s\n", obj_info->obj_id.objid, obj_info->obj_id.osnum, classname );
#	endif

	om$get_classid( osnum = obj_info->obj_id.osnum,
	                objid = obj_info->obj_id.objid,
		    p_classid = &elem_classid );
		    
	xhatch = NULL;
	
	if( elem_classid == OPP_SKmgr_class_id )
		{
		HSpvhl_get_objects_of_type_on_channel( 
			obj_info->obj_id.objid, 
			obj_info->obj_id.osnum, 
			"GRcmpowner.to_components", 
			0,
			&as_list, 
			&as_count );
			
		if( as_count > 0 )
			{
	
			/*
			 *  Get the GRaxhatch objects at the end of the 
			 *  NDchildren.children channel.
			 */
		 
			for( i=0; i<as_count; i++ )
				{
#				if DEBUG_XHATCH
				fprintf( stderr, "    GRconnector.to_owner: %d %d: ", as_list[i].objid, as_list[i].osnum );
				om$get_classname( osnum = as_list[i].osnum,
				                  objid = as_list[i].objid,
				                  classname = classname );

				fprintf( stderr, "  %s\n", classname );
#				endif

				/*
				 *  Get all the GRaxhatch class elements at the end
				 *  of the NDchildren.children channel
				 */
			 
				HSpvhl_get_objects_of_type_on_channel( 
					as_list[i].objid, 
					as_list[i].osnum, 
					"NDchildren.children", 
					OPP_GRaxhatch_class_id,
					&ax_list, 
					&ax_count );
			
				/*
				 *  For each GRaxhatch class element found, see if the
				 *  boundary loop is the solid boundary loop
				 */
			 	
				for( j=0; j<ax_count; j++ )
					{
#					if DEBUG_XHATCH
					fprintf( stderr, "      GRaxhatch: %d %d\n", ax_list[j].objid, ax_list[j].osnum );
#					endif

					if( HSpvhl_match_first_object_on_channel( 
							ax_list[j].objid, 
							ax_list[j].osnum, 
							"NDfather.father", 
							as_list[i].objid,
							as_list[i].osnum ) )
						{
					
						/* 
						 *  If the xhatch node is NULL, then create on using the
						 *  current solid boundary loop object
						 */
					 
						if( xhatch == NULL )
							{
							xhatch = HSpvhl_get_xhatch_node();
						
							memcpy( &xhatch->id, obj_info, sizeof( struct GRobj_env ) );

							xhatch->id.obj_id.objid = as_list[i].objid;
							xhatch->next = *xhatch_top;
							xhatch->holes = NULL;
							xhatch->lines = NULL;
							xhatch->xhatch_object = TRUE;
							xhatch->level = HSget_object_level( &obj_info->obj_id );
						
#							if DEBUG_XHATCH
							fprintf( stderr, "level: %d\n", xhatch->level );
#							endif

							*xhatch_top = xhatch;
							}

						/*-----------------------------------------------------------------------------
						 *  The object is the solid boundary loop for this
						 *  cross hatch header.  Collect all the ASsource
						 *  class objects for this xhatch header
						 */
					 
						HSpvhl_get_objects_of_type_on_channel( 
							ax_list[j].objid, 
							ax_list[j].osnum, 
							"NDfather.father", 
							OPP_SKcompcurve_class_id,
							&axas_list, 
							&axas_count );

						/*
						 *  For each ASsource class object, get its geometry
						 *  objects and add them to the hole list of the
						 *  xhatch node
						 */
					 
						for( k=0; k<axas_count; k++ )
							{
							if( !(as_list[j].objid == axas_list[k].objid &&
							      as_list[j].osnum == axas_list[k].osnum) )
								{
#								if DEBUG_XHATCH
									fprintf( stderr, "        SKcompcurve: %d %d\n", axas_list[k].objid, axas_list[k].osnum );
#								endif

								xobj = HSpvhl_get_object_node();
								
								xobj->next = xhatch->holes;
								xobj->id.objid = axas_list[k].objid;
								xobj->id.osnum = axas_list[k].osnum;
									
        	                                                HSpvhl_set_object_level( &axas_list[k], xhatch->level );
							
								xhatch->holes = xobj;
								}
							}
						
						/*-----------------------------------------------------------------------------
						 *  The object is the solid boundary loop for this
						 *  cross hatch header.  Collect all the ASsource
						 *  class objects for this xhatch header
						 */
					 
						HSpvhl_get_objects_of_type_on_channel( 
							ax_list[j].objid, 
							ax_list[j].osnum, 
							"NDfather.father", 
							OPP_ASsource_class_id,
							&axas_list, 
							&axas_count );

						/*
						 *  For each ASsource class object, get its geometry
						 *  objects and add them to the hole list of the
						 *  xhatch node
						 */

						for( k=0; k<axas_count; k++ )
							{
#							if DEBUG_XHATCH
								fprintf( stderr, "        ASsource: %d %d\n", axas_list[k].objid, axas_list[k].osnum );
#							endif

							if( !(as_list[j].objid == axas_list[k].objid &&
							      as_list[j].osnum == axas_list[k].osnum) )
								{
								HSpvhl_get_objects_of_type_on_channel( 
									axas_list[k].objid, 
									axas_list[k].osnum, 
									"ASsource.listeners", 
									0,
									&asgo_list, 
									&asgo_count );

								for( l=0; l<asgo_count; l++ )
									{
#									if DEBUG_XHATCH
									fprintf( stderr, "          Geometry: %d %d\n", asgo_list[l].objid, asgo_list[l].osnum );
#									endif

									xobj = HSpvhl_get_object_node();
								
									xobj->next = xhatch->holes;
									xobj->id.objid = asgo_list[l].objid;
									xobj->id.osnum = asgo_list[l].osnum;
								
									HSpvhl_set_object_level( &asgo_list[l], xhatch->level );
									
									xhatch->holes = xobj;
									}
								}
							}
						
						/*---------------------------------------------------------------------------- 
						 *  Collect the GRxhgg objects going after the xhatch line
						 *  objects
						 */
					 
						 
						HSpvhl_get_objects_of_type_on_channel( 
							ax_list[j].objid, 
							ax_list[j].osnum, 
							"GRcmpowner.to_components", 
							OPP_GRxhgg_class_id,
							&xh_list, 
							&xh_count );

						/*
						 *  For each GRxhgg class object, get its the objects
						 *  on the GRcmpowner.to_components channel  and add 
						 *  them to the hole list of the xhatch node
						 */
					 
						for( k=0; k<xh_count; k++ )
							{
#							if DEBUG_XHATCH
							fprintf( stderr, "        GRxhgg: %d %d\n", xh_list[k].objid, xh_list[k].osnum );
#							endif

							HSpvhl_get_objects_of_type_on_channel( 
								xh_list[k].objid, 
								xh_list[k].osnum, 
								"GRcmpowner.to_components", 
								0,
								&xhl_list, 
								&xhl_count );
							
							for( l=0; l<xhl_count; l++ )
								{
#								if DEBUG_XHATCH
								fprintf( stderr, "          Geometry: %d %d\n", xhl_list[l].objid, xhl_list[l].osnum );
#								endif

								xobj = HSpvhl_get_object_node();
							
								xobj->next = xhatch->lines;
								xobj->id.objid = xhl_list[l].objid;
								xobj->id.osnum = xhl_list[l].osnum;
							
								HSpvhl_set_object_level( &xhl_list[l], xhatch->level );
									
								xhatch->lines = xobj;
								}
							}
						}
					}
				}
			}
		return;
		}

	/*
	 *  If there are any ASsource class objects at the end of
	 *  the GRnotify.notification channel, then this is a boundary
	 *  loop
	 */

	HSpvhl_get_objects_of_type_on_channel( 
		obj_info->obj_id.objid, 
		obj_info->obj_id.osnum, 
		"GRnotify.notification", 
		OPP_ASsource_class_id,
		&as_list, 
		&as_count );
		
	if( as_count > 0 )
		{
	
		/*
		 *  Get the GRaxhatch objects at the end of the 
		 *  NDchildren.children channel.
		 */
		 
		for( i=0; i<as_count; i++ )
			{
#			if DEBUG_XHATCH
			fprintf( stderr, "    ASsource: %d %d\n", as_list[i].objid, as_list[i].osnum );				
#			endif

			/*
			 *  Get all the GRaxhatch class elements at the end
			 *  of the NDchildren.children channel
			 */
			 
			HSpvhl_get_objects_of_type_on_channel( 
				as_list[i].objid, 
				as_list[i].osnum, 
				"NDchildren.children", 
				OPP_GRaxhatch_class_id,
				&ax_list, 
				&ax_count );
			
			/*
			 *  For each GRaxhatch class element found, see if the
			 *  boundary loop is the solid boundary loop
			 */
			 	
			for( j=0; j<ax_count; j++ )
				{
#				if DEBUG_XHATCH
				fprintf( stderr, "      GRaxhatch: %d %d\n", ax_list[j].objid, ax_list[j].osnum );
#				endif

				if( HSpvhl_match_first_object_on_channel( 
						ax_list[j].objid, 
						ax_list[j].osnum, 
						"NDfather.father", 
						as_list[i].objid,
						as_list[i].osnum ) )
					{
					
					/* 
					 *  If the xhatch node is NULL, then create on using the
					 *  current solid boundary loop object
					 */
					 
					if( xhatch == NULL )
						{
						xhatch = HSpvhl_get_xhatch_node();
						
						memcpy( &xhatch->id, obj_info, sizeof( struct GRobj_env ) );
						
						xhatch->next = *xhatch_top;
						xhatch->holes = NULL;
						xhatch->lines = NULL;
						xhatch->xhatch_object = TRUE;
						xhatch->level = HSget_object_level( &obj_info->obj_id );
						
#						if DEBUG_XHATCH
						fprintf( stderr, "level: %d\n", xhatch->level );
#						endif

						*xhatch_top = xhatch;
						}

					/*
					 *  The object is the solid boundary loop for this
					 *  cross hatch header.  Collect all the ASsource
					 *  class objects for this xhatch header
					 */
					 
					HSpvhl_get_objects_of_type_on_channel( 
						ax_list[j].objid, 
						ax_list[j].osnum, 
						"NDfather.father", 
						OPP_ASsource_class_id,
						&axas_list, 
						&axas_count );

					/*
					 *  For each ASsource class object, get its geometry
					 *  objects and add them to the hole list of the
					 *  xhatch node
					 */
					 
					for( k=1; k<axas_count; k++ )
						{
#						if DEBUG_XHATCH
						fprintf( stderr, "        ASsource: %d %d\n", axas_list[k].objid, axas_list[k].osnum );
#						endif

						HSpvhl_get_objects_of_type_on_channel( 
							axas_list[k].objid, 
							axas_list[k].osnum, 
							"ASsource.listeners", 
							0,
							&asgo_list, 
							&asgo_count );

						for( l=0; l<asgo_count; l++ )
							{
#							if DEBUG_XHATCH
							fprintf( stderr, "          Geometry: %d %d\n", asgo_list[l].objid, asgo_list[l].osnum );
#							endif

							xobj = HSpvhl_get_object_node();
							
							xobj->next = xhatch->holes;
							xobj->id.objid = asgo_list[l].objid;
							xobj->id.osnum = asgo_list[l].osnum;
							
							HSpvhl_set_object_level( &asgo_list[l], xhatch->level );
								
							xhatch->holes = xobj;
							}
						}
						
					/* 
					 *  Collect the GRxhgg objects going after the xhatch line
					 *  objects
					 */
					 
					 
					HSpvhl_get_objects_of_type_on_channel( 
						ax_list[j].objid, 
						ax_list[j].osnum, 
						"GRcmpowner.to_components", 
						OPP_GRxhgg_class_id,
						&xh_list, 
						&xh_count );

					/*
					 *  For each GRxhgg class object, get its the objects
					 *  on the GRcmpowner.to_components channel  and add 
					 *  them to the hole list of the xhatch node
					 */
					 
					for( k=0; k<xh_count; k++ )
						{
#						if DEBUG_XHATCH
						fprintf( stderr, "        GRxhgg: %d %d\n", xh_list[k].objid, xh_list[k].osnum );
#						endif

						HSpvhl_get_objects_of_type_on_channel( 
							xh_list[k].objid, 
							xh_list[k].osnum, 
							"GRcmpowner.to_components", 
							0,
							&xhl_list, 
							&xhl_count );
							
						for( l=0; l<xhl_count; l++ )
							{
#							if DEBUG_XHATCH
							fprintf( stderr, "          Geometry: %d %d\n", xhl_list[l].objid, xhl_list[l].osnum );
#							endif

							xobj = HSpvhl_get_object_node();
							
							xobj->next = xhatch->lines;
							xobj->id.objid = xhl_list[l].objid;
							xobj->id.osnum = xhl_list[l].osnum;
							
							HSpvhl_set_object_level( &xhl_list[l], xhatch->level );
								
							xhatch->lines = xobj;
							}
						}

					}	
				}
				
			if( ax_list ) free( ax_list );			
			}
	
		free( as_list );
		}
	else
		{
			
		/*
		 *  If there are GRxhgg class objects at the end
		 *  of the GRconnector.to_owners channel, then this
		 *  is a xhatch line
		 */
		 
		HSpvhl_get_objects_of_type_on_channel( 
			obj_info->obj_id.objid, 
			obj_info->obj_id.osnum, 
			"GRconnector.to_owners", 
			OPP_GRxhgg_class_id,
			&xhgg_list, 
			&xhgg_count );

		if( xhgg_count > 0 )
			{
			free( xhgg_list );
			}
		else
			{
			xhatch = HSpvhl_get_xhatch_node();
						
			memcpy( &xhatch->id, obj_info, sizeof( struct GRobj_env ) );
						
			xhatch->next = *xhatch_top;
			xhatch->holes = NULL;
			xhatch->lines = NULL;
			xhatch->xhatch_object = FALSE;
			xhatch->level = HSget_object_level( &obj_info->obj_id );
						
#			if DEBUG_XHATCH
			fprintf( stderr, "level: %d\n", xhatch->level );
#			endif

			*xhatch_top = xhatch;
			}
		}
	}

/*--- HSturn_off_ref_file_display ----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HSturn_off_ref_file_display( struct GRid *ref_grid,
						  IGRboolean *turn_ref_files_off )
#else
	static void HSturn_off_ref_file_display( ref_grid, turn_ref_files_off )

	struct GRid *ref_grid;
	IGRboolean  *turn_ref_files_off;
#endif

/*
NAME
	HSturn_off_ref_file_display

DESCRIPTION
	This function turns off the display of a reference file if it is
	attached directly to the master file (i.e., nested attachments 
	will not be turned off ).  Nested files won't display, however,
	because the top level attachment will be turned off.

PARAMETERS
	ref_grid (IN) - the GRid of the ref. file
	turn_ref_files_off (OUT) - set to TRUE, if the ref. file was turned off

GLOBALS USED
	VEmaster_env
	VEexec_status

HISTORY
	xx/xx/xx   S.P. Rogers
	   Creation Date
	02/10/92    S.P. Rogers
	   Added prologue comment
	02/13/92    S.P. Rogers
	   Pulled from VE code to HSURF code
*/

	{
	IGRlong  sts;
	IGRlong  msg;
	IGRshort action;
	IGRshort clear_mask;
	OM_S_OBJID mod_id;
	OMuword    mod_osnum;

	/* see if reference file attachment is directly to the master file */
	ex$get_cur_mod( id = &mod_id, osnum = &mod_osnum );

	if ( ref_grid->osnum == mod_osnum )
	   {
	   *turn_ref_files_off = TRUE;  /* indicate one was turned off */

	   /* turn off the display of the reference file */
	   action = 0;  /* clear bits */
	   clear_mask = GRIS_DISPLAYABLE;
	   sts = om$send( mode     = OM_e_wrt_object,
	                  msg      = message GRvg.GRchgprops( &msg, &action, &clear_mask ),
	                  senderid = NULL_OBJID,
	                  targetid = ref_grid->objid,
	                  targetos = ref_grid->osnum );

	      OM_ERRCHK( sts, "HSturn_off_ref_file_display: GRchgprops send failed" );
	      MSG_ERRCHK( msg, "HSturn_off_ref_file_display: GRchgprops failed" );
	   }

	}  /* HSturn_off_ref_file_display */


/*---HSget_components-------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_components( struct GRid *elem,
			   struct GRmd_env *object_env,
				    IGRint *num_components,
			       struct GRid **comp_ids )
#else
	void HSget_components( elem, object_env, num_components, comp_ids )

	struct GRid	*elem;
	struct GRmd_env	*object_env;
	IGRint		*num_components;
	struct GRid	**comp_ids;
#endif

/*
DESCRIPTION
	This function gets the components owned by an object of class GRowner.
	It returns the components in an array that it has malloced so the
	caller is responsible for freeing the array when he is through with it.

HISTORY
	S.P. Rogers	02/03/88  Creation Date
	Mike L.		05/17/91  Copied form LVHL
*/

	{
	IGRlong	sts;
	IGRlong	msg;
	IGRint	buf_size;

	/* 
	 * get the number of components 
	 */
	 
	*num_components = 0;
	sts = om$send( msg = message GRowner.GRget_number_components( 
							&msg,
							num_components ),
		  senderid = NULL_OBJID,
		  targetid = elem->objid,
		  targetos = elem->osnum );

	OM_ERRCHK( sts, "HSget_components: GRget_number_components send failed" );
	MSG_ERRCHK( msg, "HSget_components: GRget_number_components failed" );

	/* 
	 * allocate array for component ids 
	 */
	 
	buf_size = *num_components;
	*comp_ids = (struct GRid *)malloc( *num_components * sizeof( struct GRid ) );

	sts = om$send( msg = message GRowner.GRget_components( 
							&msg,
							object_env,
							*comp_ids,
							buf_size,
							num_components,
							0, 99999 ),
		  senderid = NULL_OBJID,
		  targetid = elem->objid,
		  targetos = elem->osnum );

	OM_ERRCHK( sts, "HSget_components: GRget_components send failed" );
	MSG_ERRCHK( msg, "HSget_components: GRget_components failed" );

	}  /* HSget_components */

%safe
static IGRint	HSpvhl_last_object = 0;
%endsafe

/*---HSclassify_located_object-------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSclassify_located_object( struct GRid *elem,
				    struct GRmd_env *object_env,
					  IGRmatrix matrix,
					   IGRshort *matrix_type,
					struct GRid *fence_grid,
					     IGRint break_into_components,
					     IGRint (*object_preprocessor)(IGRshort object_os, 
									 IGRboolean is_symbol),
					       void (*surface_processor)(),
					       void (*curve_processor)(),
					       void (*text_copy)( OM_S_OBJID text_id, 
								     OMuword text_os, 
								   IGRdouble *matrix, 
								    IGRshort matrix_type, 
							     struct GRmd_env *master_env ),
					    IGRchar *general_info,
					 IGRboolean *turn_ref_files_off )
#else
	void HSclassify_located_object( 
				elem, 
				object_env,
				matrix, 
				matrix_type,
				fence_grid,
				break_into_components,
				object_preprocessor,
				surface_processor,
				curve_processor,
				text_copy,
				general_info,
				turn_ref_files_off )

	struct GRid		*elem;
	struct GRmd_env		*object_env;
	IGRmatrix		matrix;
	IGRshort		*matrix_type;
	struct GRid		*fence_grid;
	IGRint			break_into_components;
	IGRint			(*object_preprocessor)();
	void			(*surface_processor)();
	void			(*curve_processor)();
	void			(*text_copy)();
	IGRchar			*general_info;
	IGRboolean		*turn_ref_files_off;
#endif

/*
NAME
	HSclassify_located_object

DESCRIPTION
	This function classifies a located object and performs the functions
	necessary to process the object.

	Following is a list of classes and the functions performed:

	   Composite Surface/Curve or Solid:       Get each component and
	                                           create sort records for them

	   Surface, Curve, or Point:               Create a sort record for it

	   Reference File Header:                  Turn off the display of the ref. file
	                                           if required by user

	   Graphic Group or Cell:                  Get each component and call
	                                           VEclassify_located_object recursively
	                                           on them

	   Symbol Header:                          Build a new environment matrix for
	                                           the symbol, get each component and
	                                           call VEclassify_located_object recursively

PARAMETERS
	elem (IN) - the element to classify
	object_env (IN) - the module environment of the element
	matrix (IN) - the matrix of the element's environment
	matrix_type (IN) - the type of 'matrix'
	fence_grid (IN) - object id of the fence
	break_into_components (IN) - if TRUE, break composites into components
	object_preprocessor (IN) - object preprocessing function
	surface_processor (IN) - surface processing function
	curve_processor (IN) - curve processing function
	text_copy (IN) - text copy function
	general_info (IN) - general information
	turn_ref_files_off (IN) -f TRUE, turn ref. display off

GLOBALS USED
	various class ids

HISTORY
	02/03/88    S.P. Rogers
	   Creation Date
	05/17/91    Mike L.
	   Copied for LVHL
	02/10/92    S.P. Rogers
	   Changed to pass symbols directly to the surface processor
	09/04/92    S.P. Rogers
	   Added code to process Cross section views
*/

	{
	OMuword		elem_classid, comp_classid;
	IGRshort	curve_comp_type;
	IGRboolean	is_solid;
	IGRlong		sts;
	IGRint		comp_count;
	IGRint		comps;
	struct GRid	*comp_ids;
	
#	if DEBUG_LOCATE
		{
		IGRchar classname[50];

		om$get_classname( osnum = elem->osnum,
		                  objid = elem->objid,
		                  classname = classname );

		fprintf( stderr, "   Classifying %d:%d - %s\n", elem->objid, elem->osnum, classname );
		}
#	endif

	/* 
	 * find out if this object was created by previous VE processing
	 * if it was do not use it.  !!! Need new way to do this in 2.0.1 !!! - SRo
	 */

		{
			
		/* 
		 * get the classid of this object 
		 */
		 
		sts = om$get_classid( osnum = elem->osnum,
				      objid = elem->objid,
				  p_classid = &elem_classid );

		if( (om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_EMSasectvw_class_id ) == OM_S_SUCCESS ) )
			{
			/*
			 * This object is a cross section view which contains solids that
			 * need to be processed
			 */

			HSget_components( elem, object_env, &comp_count, &comp_ids );

#			if DEBUG_LOCATE
				fprintf( stderr, "      Cross section view header: %d components\n", comp_count );
#			endif

			for( comps=0; comps<comp_count; comps++ )
				{
				/*
				 * Only process the components that are solids
				 */
				om$get_classid( osnum = comp_ids[comps].osnum,
					        objid = comp_ids[comps].objid,
					    p_classid = &comp_classid );

				if( om$is_ancestry_valid( 
						subclassid = comp_classid,
					      superclassid = OPP_EMScompsurf_class_id ) == OM_S_SUCCESS ) 
					{
					HSclassify_located_object( 
						&comp_ids[comps], 
						object_env,
						matrix, 
						matrix_type,
						fence_grid,
						break_into_components,
						object_preprocessor,
						surface_processor,
						curve_processor,
						text_copy,
						general_info,
						turn_ref_files_off );
					}
					
				}  /* end: for ( comps < comp_count ) */

			/* 
			 * free array of component GRid's 
			 */
			 
			if( comp_ids )
				free( (IGRchar *)comp_ids );

			}
		else if( (om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_GRflxown_class_id ) == OM_S_SUCCESS ) ||
			 (elem_classid == OPP_GRclhdr_class_id) ||
			 (elem_classid == OPP_GRsmdfhdr_class_id) )
			{
				
			/* 
			 * The located object is a flexible grouping (graphic group), cell 
			 * header, or a symbol definition header => get each component and 
			 * classify them individually because they can be nested. 
			 */
			 
			HSget_components( elem, object_env, &comp_count, &comp_ids );

#			if DEBUG_LOCATE
				fprintf( stderr, "      Cell/Symbol definition header: %d components\n", comp_count );
#			endif

			if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
				{
				tiling_parms.processing_mode &= ~HS_PMODE_PVHL_OBJECT_END;
				HSpvhl_last_object = 1;
				}
			else
				{
				HSpvhl_last_object = 0;
				}
			
			for( comps=0; comps<comp_count; comps++ )
				{
				if( HSpvhl_last_object != 0 && comps == (comp_count-1) )
					HSpvhl_last_object = 3;
					
				HSclassify_located_object( 
					&comp_ids[comps], 
					object_env,
					matrix, 
					matrix_type,
					fence_grid,
					break_into_components,
					object_preprocessor,
					surface_processor,
					curve_processor,
					text_copy,
					general_info,
					turn_ref_files_off );
					
				}  /* end: for ( comps < comp_count ) */

			/* 
			 * free array of component GRid's 
			 */
			 
			if( comp_ids )
				free( (IGRchar *)comp_ids );

			}  /* end: object was a grouping object */

		else if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_GRsmhdr_class_id ) == OM_S_SUCCESS )
			{
				
#			if DEBUG_LOCATE
				fprintf( stderr, "      Symbol header\n" );
#			endif

			/* Pass the symbol directly to the surface processor so all */
	                /* of its matrices and layer control logic will be handled  */
	                /* correctly.                                               */
			if( (*object_preprocessor)( elem->osnum, TRUE ) )
				(*surface_processor)( 
						elem, 
						matrix_type, 
						matrix, 
						object_env, 
						TRUE,
						general_info );

			}  /* end: the object was a symbol header */

		else if( (om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_ACcpx_class_id ) == OM_S_SUCCESS) ||
			 (om$is_ancestry_valid( 
			 	subclassid = elem_classid,
			      superclassid = OPP_AScontents_class_id ) == OM_S_SUCCESS) ||
			 (om$is_ancestry_valid( 
			 	subclassid = elem_classid,
			      superclassid = OPP_ASnode_class_id ) == OM_S_SUCCESS) )
			{
				
			/* 
			 * element is an associative object that could own geometry => get
			 * its components and  classify them individually
			 */
			 
			HSget_components( elem, object_env, &comp_count, &comp_ids );
			
#			if DEBUG_LOCATE
				fprintf( stderr, "      Associative Complex: %d components\n", comp_count );
#			endif

			if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
				{
				tiling_parms.processing_mode &= ~HS_PMODE_PVHL_OBJECT_END;
				HSpvhl_last_object = 1;
				}
			else
				{
				HSpvhl_last_object = 0;
				}
			
			for( comps=0; comps<comp_count; comps++ )
				{
				if( HSpvhl_last_object != 0 && comps == (comp_count-1) )
					HSpvhl_last_object = 3;
					
				HSclassify_located_object( 
					&comp_ids[comps], 
					object_env, 
					matrix, matrix_type,
					fence_grid,
					break_into_components,
					object_preprocessor,
					surface_processor,
					curve_processor,
					text_copy,
					general_info,
					turn_ref_files_off );
					
				}  /* end: for ( comps < comp_count ) */

			/* 
			 * free array of component GRid's 
			 */
			 
			if( comp_ids )
				free( (IGRchar *)comp_ids );

			}  /* end: object was an associative complex */

		else if( om$is_ancestry_valid( 
			subclassid = elem_classid,
		      superclassid = OPP_SKmgr_class_id ) == OM_S_SUCCESS )
			{

			/* 
			 * SKmgr is an ancestor => object is a profile, get components
			 * and classify them individually
			 */

			HSget_components( elem, object_env, &comp_count, &comp_ids );

#			if DEBUG_LOCATE
				fprintf( stderr, "      Profile (SKmgr): %d components\n", comp_count );
#			endif

			if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
				{
				tiling_parms.processing_mode &= ~HS_PMODE_PVHL_OBJECT_END;
				HSpvhl_last_object = 1;
				}
			else
				{
				HSpvhl_last_object = 0;
				}
			
			for( comps=0; comps<comp_count; comps++ )
				{
				if( HSpvhl_last_object != 0 && comps == (comp_count-1) )
					HSpvhl_last_object = 3;
					
				HSclassify_located_object( 
					&comp_ids[comps], 
					object_env, 
					matrix, matrix_type,
					fence_grid,
					break_into_components,
					object_preprocessor,
					surface_processor,
					curve_processor,
					text_copy,
					general_info,
					turn_ref_files_off );
					
				}  /* end: for ( comps < comp_count ) */

			/* 
			 * free array of component GRid's 
			 */
			 
			if( comp_ids )
				free( (IGRchar *)comp_ids );

			}
			 
		else if( om$is_ancestry_valid( 
			subclassid = elem_classid,
		      superclassid = OPP_EMScomposite_class_id ) == OM_S_SUCCESS )
			{

			/* 
			 * EMScomposite is an ancestor 
			 */
			 
			if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_EMSmassprop_class_id ) == OM_S_SUCCESS )
				return;  /* object is a mass properties object => ignore it */

			/* 
			 * The object is a solid, composite surface or composite curve. 
			 */
			 
			if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_GRcompcurve_class_id ) == OM_S_SUCCESS )
				curve_comp_type = TRUE;
			else if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_EMScompsurf_class_id ) == OM_S_SUCCESS )
				curve_comp_type = FALSE;
			else
				return;  /* composite object that isn't made up of curves/surfaces */

			/*if( (curve_comp_type) && (!VEexec_parms.VEprocessing_wireframe) )
				return;*/   /* user wants to ignore wireframe elements */

			is_solid = (om$is_ancestry_valid( 
					subclassid = elem_classid,
				      superclassid = OPP_EMSsolid_class_id ) == OM_S_SUCCESS) ||
				   (om$is_ancestry_valid( 
					subclassid = elem_classid,
				      superclassid = OPP_EMSsffea_class_id ) == OM_S_SUCCESS);


			if( is_solid && !break_into_components )
				{

				/* 
				 * make one entry for solid 
				 */
					 
#				if DEBUG_LOCATE
					fprintf( stderr, "      Solid\n" );
#				endif

				if( (*object_preprocessor)( elem->osnum, FALSE ) )
					(*surface_processor)( 
							elem, 
							matrix_type, 
							matrix, 
							object_env, 
							TRUE,
							general_info );
				}
			else
				{
						
				/* 
				 * get the components of this composite and process 
				 * them individually 
				 */

				HSget_components( elem, object_env, &comp_count, &comp_ids );
					 
#				if DEBUG_LOCATE
					if( curve_comp_type )
						fprintf( stderr, "      Composite curve: %d components\n", comp_count );
					else
						fprintf( stderr, "      Composite surface: %d components\n", comp_count );
#				endif


				if( tiling_parms.processing_mode & HS_PMODE_PVHL_OBJECT_END )
					{
					tiling_parms.processing_mode &= ~HS_PMODE_PVHL_OBJECT_END;
					HSpvhl_last_object = 1;
					}
				else
					{
					HSpvhl_last_object = 0;
					}
			
				for( comps=0; comps<comp_count; comps++ )
					{
					if( HSpvhl_last_object != 0 && comps == (comp_count-1) )
						HSpvhl_last_object = 3;
					
					HSclassify_located_object( 
						&comp_ids[comps], 
						object_env, 
						matrix, matrix_type,
						fence_grid,
						break_into_components,
						object_preprocessor,
						surface_processor,
						curve_processor,
						text_copy,
						general_info,
						turn_ref_files_off );
							
					}  /* end: for ( comps < comp_count ) */

	 			/* 
	 			 * free array of component GRid's 
	 			 */
	 				 
				if( comp_ids )
					free( (IGRchar *)comp_ids );

				}

			}  /* end: else */

		else if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_EMSsurface_class_id ) == OM_S_SUCCESS )
			{
				
			/* 
			 * EMSsurface is an ancestor
			 *
			 * The object is a surface
			 */
			 
#			if DEBUG_LOCATE
				fprintf( stderr, "      Surface\n" );
#			endif

			if( (*object_preprocessor)( elem->osnum, FALSE ) )
				(*surface_processor)( 
						elem, 
						matrix_type, 
						matrix, 
						object_env, 
						FALSE,
						general_info );
			
			}  /* end: EMSsurface is an ancestor */

		else if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_GRbspline_class_id ) == OM_S_SUCCESS )
			{
				
			/* 
			 * GRbspline is an ancestor => element is wireframe
			 */
			 
			/*if( !(VEexec_parms.VEprocessing_wireframe) )
				return;*/   /* user wants to ignore wireframe elements */

			if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_GRpoint_class_id ) == OM_S_SUCCESS )
				{
					
				/* 
				 * GRpoint is an ancestor 
				 */

#				if DEBUG_LOCATE
					fprintf( stderr, "      Point\n" );
#				endif

				if( HSpvhl_last_object == 3 )
					tiling_parms.processing_mode |= HS_PMODE_PVHL_OBJECT_END;
					
				if( (*object_preprocessor)( elem->osnum, FALSE ) )
					(*curve_processor)( 
							elem, 
							matrix_type, 
							matrix, 
							object_env,
							general_info  );

				tiling_parms.processing_mode &= ~(HS_PMODE_PVHL_OBJECT_BEGIN |
								  HS_PMODE_PVHL_OBJECT_END   |
								  HS_PMODE_PVHL_NEW_LOOP);
								  
				}  /* end: GRpoint is an ancestor */

			else if( (elem->objid != fence_grid->objid) || 
			         (elem->osnum != fence_grid->osnum) )
				{

				/* 
				 * The object is a curve and not the fence object =>  
				 * create sort record 
				 */
				 
#				if DEBUG_LOCATE
					fprintf( stderr, "      Curve\n" );
#				endif

				if( HSpvhl_last_object == 3 )
					tiling_parms.processing_mode |= HS_PMODE_PVHL_OBJECT_END;
					
				if( (*object_preprocessor)( elem->osnum, FALSE ) )
					(*curve_processor)( 
							elem, 
							matrix_type, 
							matrix, 
							object_env,
							general_info  );

				tiling_parms.processing_mode &= ~(HS_PMODE_PVHL_OBJECT_BEGIN |
								  HS_PMODE_PVHL_OBJECT_END   |
								  HS_PMODE_PVHL_NEW_LOOP);

				}  /* end: element is a curve */

			}  /* end: GRbspline is an ancestor */

		else if( om$is_ancestry_valid( 
				subclassid = elem_classid,
			      superclassid = OPP_GRtext_class_id ) == OM_S_SUCCESS )
			{
				
			/* 
			 * GRtext is an ancestor => do nothing (because output is always 
			 * planar) 
			 */
			 
#			if DEBUG_LOCATE
				fprintf( stderr, "      Text\n" );
#			endif

			(*text_copy)(
				elem->objid,
				elem->osnum,
				matrix,
				*matrix_type,
				object_env );
				
			}  /* end: GRtext is an ancestor */

		else if( (elem_classid == OPP_GRreffile_class_id) ||
			 (elem_classid == OPP_GRdvattach_class_id) )
			{

			/* 
			 * the element is a reference file or drawing view attachment 
			 */
			 
#			if DEBUG_LOCATE
				fprintf( stderr, "      Reference File/Drawing View Attachment\n" );
#			endif

			if ( turn_ref_files_off )
				{
				HSturn_off_ref_file_display( elem, turn_ref_files_off );
				}

			}  /* end:  element is a reference file */

		else
			{

			/* 
			 * this element is unclassifiable 
			 */
			 
#			if DEBUG_LOCATE
				fprintf( stderr, "      Unclassifiable object\n" );
#			endif
			}
		}  /* end: if ( curve created by VE ) */

	} /* VEclassify_located_objects */

end implementation Root;
