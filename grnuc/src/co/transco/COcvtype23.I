/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function  converts an IGDS cone to an OSA cone (currently
 *  the conversion is made to a bspline surface).
 *  The new object will be added to the R-tree.
 */

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "OMmacros.h"
#include "gocmacros.h"

from GRgraphics import GRchgprops;

method cvt_type23 (IGRlong *msg; struct GRid *object_info)
{
	struct IGDS_cone	*igdscone;

	IGRchar			class_name[80];	/* class name for object     */
	IGRshort		i;		/* loop counter		     */
	IGRlong			status;
	struct IGRcone		cone;
	IGRlong			cone_array[16];
	IGRlong			long_quat;
	IGRlong			temp_long;
	IGRdouble		quaternions[4];
	IGRchar			*internal_pntr;
	struct IGRbsp_surface	*surf;
	struct IGResbs		class_attr;
	struct GUcommon_header_info element;	/* GUgetname info	     */
	IGRint			has_link;
	IGRchar			name[257];	/* element's name	     */
	IGRshort		set = 1;
	IGRshort		props;
	IGRchar			*typeface = NULL;
	IGRchar			*charmap = NULL;
	
/*
 *  Cast buffer to the IGDS element cone structure.
 */
#ifdef BIG_ENDIAN
   GRswap_type23_ele(me->cvt_bufs.ele_buf);
#endif
igdscone = (struct IGDS_cone *) me->cvt_bufs.ele_buf;

/*
 *  initialize pointer to information
 *  of cone
 */
 
internal_pntr = &igdscone->cone_data;

/*
 *  Extract quaternions from the IGDS element and
 *  form the rotation matrix from them.
 */

for ( i = 0; i < 4; ++i )
{

    OM_BLOCK_MOVE( internal_pntr, &temp_long, 4);

    GUswapint ( &temp_long, &long_quat );
    quaternions[i] = (IGRdouble) long_quat;
    internal_pntr += 4;
}
    
GUquat_to_rotmx ( quaternions, cone.rot_matrix );

OM_BLOCK_MOVE( internal_pntr, cone_array, 64 );

/*
 *  convert base origin
 */

fltvax_to_flt32 ( 3, cone_array, cone.base_origin );

/*
 *  convert base radius 
 */

fltvax_to_flt32 ( 1, &(cone_array[6]), &cone.base_radius );

/*
 *  convert top origin
 */

fltvax_to_flt32 ( 3, &(cone_array[8]), cone.top_origin );

/*
 *  convert top radius 
 */

fltvax_to_flt32 ( 1, &(cone_array[14]), &cone.top_radius );

/*
 *  Convert IGDS cone element into an OSA bspline
 *  surface object.
 */

surf = (struct IGRbsp_surface *) me->cvt_bufs.bs_buf;
surf->poles = (IGRdouble *) (GRalign_double (surf + 1));
surf->u_knots = &surf->poles[6 * MAELPOLE_SIZE];
surf->v_knots = &surf->u_knots[MAELKNOT_SIZE];
surf->weights = &surf->v_knots[4];

status = MAcntobs ( msg, &cone, surf );
if ( !status )
{
    goto leave;
}

/*
 *  Set up class attributes for the object.	
 */

class_attr.u_rules = 2;
class_attr.v_rules = 10;
class_attr.is_polydis = 0;
class_attr.is_surfdis = 1;
class_attr.is_slowdis = 0;
class_attr.type = 0;
	    
strcpy ( class_name, "EMSgenbs" );

/*
   Check the user data linkage for an element name.
*/
	element = igdscone->header;
	has_link = GUattr_link (msg, &igdscone->header, name,
			&igdscone->header.symbology, typeface, charmap);

/* 
 *  Construct OSA object.
 */

	status = GUconstruct ( me->cvt_bufs.bs_buf, object_info, 
	      class_name, &igdscone->header.level,
	      &igdscone->header.symbology, &igdscone->header.properties,
	      &class_attr, &me->scale_factor, &me->current_env );

	if (has_link & HAS_FILLED_TYPE)
	{
	   props = 0;
	   props |= GRFILLED_DISPLAY;
	   status = om$send (msg = message GRgraphics.GRchgprops (msg, &set,
								&props),
			     targetid = object_info->objid,
			     targetos = object_info->osnum);
	}
/* 
 *  Enter the IGDS element's name into the translated element's
 *  data structure.
 */
	if (has_link & HAS_NAME_TYPE)
	{
	  GUputname(msg, name, object_info, &me->current_env);
 	}

leave: return (status);

}


end implementation COcvigdsige;
