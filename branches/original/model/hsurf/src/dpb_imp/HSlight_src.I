 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 0

#include <stdio.h>
#include <stdlib.h>

#include "igrtypedef.h"

#include "OMerrordef.h"
#include "igetypedef.h"

#include "gr.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcmacros.h"

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "hsurferrpriv.h"

#include "hsurf.h"
#include "hslight.h"
#include "hsmacdef.h"
#include "hsdef.h"
#include "hsmacros.h"

#include "OMminimum.h"

extern IGRint GRdpb_get __((IGRint *msg, IGRint parameter, 
          IGRint *sizbuf, IGRchar *buffer, IGRint *nret));	

extern IGRint GRget_window_matrix (
	IGRlong     *msg,
	GRspacenum  window_osnum,
	GRobjid     window_objid,
	IGRmatrix   matrix,
	IGRint      *ortho_view);
			    

%safe
#include "HSpr_dpb_imp.h"
%endsafe

#define DEBUG	0

from HSdpb2 import get_global_lights, set_global_lights,
	           get_ambient_light, set_ambient_light;

from HSlghtsrc import HSget_light, HSput_light;

from GRowner import GRadd_components, GRget_number_components, 
	GRget_components, GRremove_components;
from GRgraphics import GRdelete, GRconstruct;
from GRvg import GRgetsymb;

extern OMuword OPP_HSlghtsrc_class_id;

/*--- HSget_light_objid_and_os -----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRlong HSget_light_objid_and_os( int light_number,
				   OM_S_OBJID dpb_id,
				      OMuword dpb_os,
				   OM_S_OBJID *light_id,
				      OMuword *light_os )
#else
	IGRlong HSget_light_objid_and_os( light_number, dpb_id, dpb_os, light_id,
		light_os )

	int light_number;
	OM_S_OBJID dpb_id, *light_id;
	OMuword dpb_os, *light_os;
#endif

/*
NAME
	 HSget_light_objid_and_os

KEYWORD
	light_source

DESCRIPTION
	This function returns the object id and object space number given the
	light index

PARAMETERS
	light_number (IN) - Index of the light (1-8)
	dpb_id,dpb_os (IN) - Object id/object space number of Default Param-
		eter Block
	light_id, light_os (OUT) - Object id/object space number of light

GLOBALS USED
	none

RETURN VALUES
	OM_S_SUCCESS - The given light exists and its id and os should be valid
	not OM_S_SUCCESS - The light number does not exist and id and os invalid

HISTORY
	08/08/91 Created. -Trevor Mink
*/
{
	IGRlong    sts1 = OM_S_SUCCESS;
	OM_S_CHANSELECT to_lights;

	/* Get the channel objects of the dpb2 object */
	sts1 = om$make_chanselect( channame = "HSdpb2.to_light_sources", p_chanselect = &to_lights );

	OM_ERRCHK( sts1, "read_light_source: om$make_chanselect failed" );

	/* Get the object id of the light number (if not there sts1 will return OM_S_SUCCESS, NOT!) */
	sts1 = om$get_objid_at_index( osnum = dpb_os, objid = dpb_id, p_chanselect = &to_lights,
		index = light_number, objidaddr = light_id, osnumaddr = light_os );

#if DEBUG
	fprintf( stderr, "dpb_id = %d, dpb_os, = %d, index = %d, light_id = %d, light_os = %d\n",
		dpb_id, dpb_os, light_number, *light_id, *light_os );
#endif
	OM_ERRCHK( sts1, "read_light_source:  om$get_objid_at_index failed" );

	return( sts1 );

} /* HSget_light_objid_and_os */

/*--- HSget_light ------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HSget_light( struct HS_light_source *light,
					    int light_number )
#else
	int HSget_light( light, light_number )
	struct HS_light_source *light;
	int light_number;
#endif

/*
NAME
	HSget_light

KEYWORD
	light_source

DESCRIPTION
	This function finds the appropriate HSlghtsrc object (if it exists) and
	gets the instance data and returns it in 'light'. It returns a status of
	zero (unsuccessful) or non-zero (successful).

PARAMETERS
	light (OUT) - Structure containing light source description
	light_number (IN) - Index of light source (1-8)

GLOBALS USED
	none

RETURN VALUES
	OM_S_SUCCESS - Light source found and returned
	FALSE - The light did not exist but has been created. It is given the
		default initialization
	Anything else - Error returned by HSlghtsrc.HSget_light method

HISTORY
	08/08/91 Created. -Trevor Mink
*/
{
	IGRlong    sts1 = OM_S_SUCCESS;
	IGRint	   msg;
	OM_S_OBJID dpb_id, light_id;
	OMuword    dpb_os, light_os;
	int i;

	HSget_dpb_super( &dpb_id, &dpb_os );

	sts1 = HSget_light_objid_and_os( light_number, dpb_id, dpb_os, &light_id, &light_os );

	if( sts1 == OM_S_SUCCESS )
	{
		sts1 = om$send( msg = message HSlghtsrc.HSget_light( &msg, light ),
			targetid = light_id, targetos = light_os, senderid = NULL_OBJID );

		OM_ERRCHK( sts1, "read_light_source:  HSlghtsrc.HSget_light send failed" );
		return( sts1 );
	}
	else
	{
		light->red =
		light->green =
		light->blue =
		light->flags = 0;

		for( i = 0; i < 3; i++ )
		{
			light->location[i] =
			light->target[i] =
			light->direction[i] = 0.0;
		}
		light->radius =
		light->angle = 0.0;

		return( FALSE );
	}

} /* HSget_light */

/*--- HSput_light ------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	int HSput_light( struct HS_light_source *light,
					    int light_number,
				    struct GRid *window_id )
#else
	int HSput_light( light, light_number, window_id )
	struct HS_light_source *light;
	int light_number;
	struct GRid *window_id;
#endif

/*
NAME
	HSput_light

KEYWORD
	light_source

DESCRIPTION
	This function puts the light source data from 'light' into the appro-
	priate HSlghtsrc object (which it creates if necessary) and assigns the
	abstract geometry based upon the 'window_id' passed in (identity matrix
	for 'window_id' == NULL. In addition, it erases the pre-existing light
	(if indeed it did exist) and displays the new light.

PARAMETERS
	light (IN) - Description of the light source
	light_number (IN) - The index at which to add the light source (1-8)
	window_id (IN) - If not null

GLOBALS USED
	none

RETURN VALUES
	0 - Unsuccessful
	Non-zero - Successful

HISTORY
	08/08/91 Created. -Trevor Mink
	04/21/92 Modified to place lights with active style, weight, layer
		(and color if on Edge II) -Yvonne Chu
*/
{
	IGRlong    sts1 = OM_S_SUCCESS, msg, om_msg, bytes_req, bytes, cons_msg;
	OM_S_OBJID dpb_id, light_id;
	OMuword    dpb_os, light_os;
	OM_S_CHANSELECT to_lights, to_dpb;
	int i, count;
	struct GRid old_objects[10], lite;
	struct GRmd_env master;
	IGRdouble *array_of_matrices;
	struct GRvg_construct cons_args;
	IGRint size = 2;
	IGRshort level;
	struct IGRdisplay attributes;
	long sizbuf, nret;
	struct GRsymbology symb, light_symb;
	struct IGRlbsys lbs;

	HSget_dpb_super( &dpb_id, &dpb_os );
	/* get the current module environment */
	bytes_req = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = (IGRint *) &msg,
	                   sizbuf = (IGRint *) &bytes_req,
	                   buffer = (IGRchar *) &master,
	                   nret   = (IGRint *) &bytes );

	/* Get the channel objects of the dpb2 object */
	sts1 = om$make_chanselect( channame = "HSdpb2.to_light_sources", p_chanselect = &to_lights );
	OM_ERRCHK( sts1, "store_light_sources: om$make_chanselect failed" );

	/* Get the object id of the light number (if not there, sts1 will return OM_S_SUCCESS, NOT!) */
	sts1 = om$get_objid_at_index( osnum = dpb_os, objid = dpb_id, p_chanselect = &to_lights,
		index = light_number, objidaddr = &light_id, osnumaddr = &light_os );

	if( sts1 != OM_S_SUCCESS )
	{
		/* fill in part of the construct structure */
		cons_args.msg        = &cons_msg;
		cons_args.newflag    = FALSE;
		cons_args.properties = GRIS_LOCATABLE /* | GRNOT_IN_RTREE */;
		cons_args.class_attr = NULL;
		cons_args.name       = NULL;

		/* We have the current module environment */
		cons_args.env_info   = &master;

		sizbuf = sizeof( struct IGRdisplay );
       		gr$get_active_display(  msg     = (IGRint *) &msg,
                               		sizbuf = (IGRint *) &sizbuf,
                               		buffer = (IGRchar *) &attributes,
                               		nret   = (IGRint *) &nret );

		attributes.color  = DPGRID_COLOR;
		cons_args.display = &attributes;

		gr$get_active_level( msg = (IGRint *) &msg,
				     sizbuf = (IGRint *) &size, 
				     buffer = (IGRchar *) &level,
				     nret = (IGRint *) &bytes );
		cons_args.level = level;

#if DEBUG
		fprintf(stderr, "HSput_light: attributes.color 	%d\n", attributes.color);
		fprintf(stderr, "	      attributes.style 	%d\n", attributes.style);
		fprintf(stderr, "	      attributes.weight %d\n", attributes.weight);
		fprintf(stderr, "	      cons_args.layer 	%d\n", cons_args.level);
#endif
		light_symb.display_attr.style  = attributes.style;
		light_symb.display_attr.weight = attributes.weight;
		light_symb.level 	       = cons_args.level;

		if( window_id )
		{
			GRget_window_matrix( &msg, window_id->osnum, 
				window_id->objid, lbs.matrix, NULL );
		}
		else
		{
			/* Default to the identity matrix */
			for( i = 0; i < 15; i++ ) lbs.matrix[i] = 0.0;
			lbs.matrix[0] = 1.0;
			lbs.matrix[5] = 1.0;
			lbs.matrix[10] = 1.0;
			lbs.matrix[15] = 1.0;
		}
		cons_args.geometry = (char *)&lbs;

		/* Construct a light source object and connect it to the HSdpb2 object */
		sts1 = om$construct( msg = message GRgraphics.GRconstruct( &cons_args ),
			osnum = dpb_os, classid = OPP_HSlghtsrc_class_id,
			p_objid = &light_id );
#if DEBUG
		fprintf( stderr, "light_id = %d, dpb_os, = %d", light_id, dpb_os );
#endif
		OM_ERRCHK( sts1, "read_light_source: om$construct of HSlghtsrc failed" );

		sts1 = om$make_chanselect( channame = "HSlghtsrc.to_dpb", p_chanselect = &to_dpb );

		OM_ERRCHK( sts1, "read_light_source: om$make_chanselect for HSdpb2 failed" );

		sts1 = om$send( msg      = message Root.connect( to_dpb, light_number /* Channel slot */,
			dpb_id, dpb_os, to_lights, NULL ),
			senderid = NULL_OBJID, targetid = light_id, targetos = dpb_os );
		OM_ERRCHK( sts1, "read_light_source:  Root.connect failed" );

		if( sts1 != OM_S_SUCCESS ) return( FALSE );
	}
	else
	{
		sts1 = om$send( targetid = light_id,
			 	targetos = dpb_os,
				senderid = NULL_OBJID,
				msg = message GRvg.GRgetsymb(&msg, &symb) );

#if DEBUG
		fprintf(stderr, "HSput_light: symb.color 	%d\n",symb.display_attr.color);
		fprintf(stderr, "	      symb.style 	%d\n",symb.display_attr.style);
		fprintf(stderr, "	      symb.weight 	%d\n",symb.display_attr.weight);
		fprintf(stderr, "	      symb.layer 	%d\n",symb.level);
#endif
		light_symb.display_attr.style  = symb.display_attr.style;
		light_symb.display_attr.weight = symb.display_attr.weight;
		light_symb.level 	       = symb.level;

		/**************************************/
		/* Erase the object from the display. */
		lite.objid = light_id;
		lite.osnum = master.md_id.osnum;

		array_of_matrices = master.md_env.matrix;
		om_msg = dp$display( msg = &msg,
			osnum = master.md_id.osnum,
			objid = master.md_id.objid,
			mode = GRbehe,
			oids = &lite,
			mtx_type = &(master.md_env.matrix_type),
			matrix = &array_of_matrices);

		/**************************************************/
		/* Get rid of all components of pre-existing cell */
		sts1 = om$send( msg = message GRowner.GRget_number_components( &msg, &count ),
			targetid = light_id, targetos = dpb_os, senderid = NULL_OBJID );
		OM_ERRCHK( sts1, "store_light_sources:  GRowner.GRget_number_components send failed" );

		sts1 = om$send( msg = message GRowner.GRget_components( &msg, &master,
			old_objects, 10, &count, 0, count-1 ),
			targetid = light_id, targetos = dpb_os, senderid = NULL_OBJID );
		OM_ERRCHK( sts1, "store_light_sources:  GRowner.GRget_components send failed" );

		for( i = 0; i < count; i++ )
		{
			sts1 = om$send(	msg = message GRgraphics.GRdelete( &msg, &master ),
				targetid = old_objects[i].objid, targetos = dpb_os, senderid = NULL_OBJID );
			OM_ERRCHK( sts1, "store_light_sources:  GRowner.GRdelete send failed" );
		}
		/**************************************************/
	}
	sts1 = om$send( msg = message HSlghtsrc.HSput_light( (IGRint *)&msg, light,
		light_symb ),
		targetid = light_id, targetos = dpb_os, senderid = NULL_OBJID );
	OM_ERRCHK( sts1, "store_light_sources:  HSlghtsrc.HSput_light send failed" );

	if( sts1 == OM_S_SUCCESS )
	{
		lite.objid = light_id;
		lite.osnum = master.md_id.osnum;

		array_of_matrices = master.md_env.matrix;
		om_msg = dp$display (msg = &msg,
			osnum = master.md_id.osnum,
			objid = master.md_id.objid,
			mode = GRbdhd,
			oids = &lite,
			mtx_type = &(master.md_env.matrix_type),
			matrix = &array_of_matrices);
	}

	return( sts1 == OM_S_SUCCESS );

} /* HSput_light */

/*--- HSget_global_lights ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_global_lights( struct HS_light_source lights[MAX_LIGHTS],
				  struct HS_light_source *ambient )
#else
	void HSget_global_lights( lights, ambient )
	struct HS_light_source lights[MAX_LIGHTS];
	struct HS_light_source *ambient;
#endif

/*
NAME
	HSget_global_lights

KEYWORD
	light_source

DESCRIPTION
	This function return all 8 regular light sources and/or the ambient
		light specification

PARAMETERS
	lights (OUT) - If not null, Array of 8 structures to place light source
		descriptions
	ambient (OUT) - If not null, ambient light description is put here

GLOBALS USED
	none

RETURN VALUES
	none

HISTORY
	--/--/-- Created. -???
	08/08/91 Changed to get lights one at a time from HSget_light.
		-Trevor Mink
*/
{
	IGRlong    sts = OM_S_SUCCESS;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;
	int i;
#if FALSE
	OM_S_CLASSLIST class;

	class.w_count = 1;
	class.w_flags = 0;
	class.p_classes[0] = OPP_HSlghtsrc_class_id;

	lc$add_class( name = "Light Source", classes = class );
#endif
	if ( lights )
	{
		for( i = 0; i < MAX_LIGHTS; i++ )
		{
			(void)HSget_light( &(lights[i]), i );
		}
	}

	if ( ambient )
	{
		HSget_dpb_super( &dpb_id, &dpb_os );

		sts = om$send( msg      = message HSdpb2.get_ambient_light( ambient ),
	                  targetid = dpb_id,
	                  targetos = dpb_os,
	                  senderid = NULL_OBJID );

		OM_ERRCHK( sts, "HSget_global_lights:  HSdpb get_ambient_light send failed" );
	}

} /* HSget_global_lights */

/*--- HSset_global_lights ------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_global_lights( struct HS_light_source lights[MAX_LIGHTS],
				    struct HS_light_source *ambient )
#else
	IGRint HSset_global_lights( lights, ambient )

	struct HS_light_source lights[MAX_LIGHTS];
	struct HS_light_source *ambient;
#endif

/*
NAME
	HSset_global_lights

KEYWORD
	light_source

DESCRIPTION
	This function stores all 8 regular light sources and/or the ambient
		light specification

PARAMETERS
	lights (IN) - If not null, array of 8 light sources are created (if
		necessary) and stored as 8 seperate objects
	ambient (IN) - If not null, ambient light decription is stored

GLOBALS USED
	none

RETURN VALUES
	0 - Successful
	Non-zero - An error occurred either in HSput_light or in
		HSdpb2.set_ambient_light

HISTORY
	--/--/-- Created. -???
	08/08/91 Changed to put lights one at a time using HSput_light
		-Trevor Mink
*/
{
	IGRlong    sts = OM_S_SUCCESS;
	OM_S_OBJID dpb_id;
	OMuword    dpb_os;
	int i;

	if ( lights )
	{
		for( i = 0; i < MAX_LIGHTS; i++ )
		{
			sts = HSput_light( &(lights[i]), i, (struct GRid *)NULL );
		}
	}
	if( sts ) sts = OM_S_SUCCESS;

	if( ambient )
	{
		HSget_dpb_super( &dpb_id, &dpb_os );

		sts = om$send( msg      = message HSdpb2.set_ambient_light( *ambient ),
	                  targetid = dpb_id,
	                  targetos = dpb_os,
	                  senderid = NULL_OBJID );

		OM_ERRCHK( sts, "HSset_global_lights:  HSdpb set_ambient_light send failed" );
	}
	return( (sts == OM_S_SUCCESS) ? 0 : 1 );

} /* HSset_global_lights */

end implementation Root;
