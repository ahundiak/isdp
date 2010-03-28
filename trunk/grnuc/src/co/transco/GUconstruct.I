/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

/*
 *  This function will fill in the construct data structure
 *  and construct an object in a given object space.
 */

#include "coimport.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "msmacros.h"

IGRboolean GUconstruct ( buffer, object_info, class_name, p_level, p_symbology,
			 p_props, class_attr, scale_factor, current_env )

IGRchar		*buffer;    	/*  B-spline representation of object */
struct GRid	*object_info;	/*  object space identification	      */
IGRchar		class_name[];	/*  name of class to construct object */
IGRchar         *p_level;		/*  level to contain object	      */
short           *p_symbology;	/*  display symbology for object      */
short           *p_props;		/*  properties for element	      */
IGRchar		*class_attr;
IGRdouble	*scale_factor;
struct GRmd_env *current_env;

{

	IGRlong			status;
 	struct IGRdisplay	display;
	struct GRvg_construct 	const_lis;
	IGRlong			msg;
        IGRmatrix		scale_matrix;
        struct GRmd_env		new_env;
        IGRshort		num_rc = 4;
	short unsigned          props;
	short unsigned          symbology;
	char unsigned           level;

	/*
	 *  initialize construction buffer
	 */

	level = *p_level;
	props = *p_props;
	symbology = *p_symbology;

	const_lis.msg = &msg;
	const_lis.env_info = &new_env;
	const_lis.newflag = FALSE;
	const_lis.level = (level & 0x3f);

	/*
	 *  Set up the properties word.
	 */

	const_lis.properties = 0;

	/*
	 *  Set the planar bit.
	 */

	if ( props & 0x2000 )
	{
	    const_lis.properties |= GRIS_PLANAR;
	}
/* -----------------------------------------------------------------------*/
/*									  */
/*      The following code is added by Mohan to take care of              */
/*      the view-independent text related problems in conversion          */
/*      from IGDS to EMS.      						  */
/*									  */
/* -----------------------------------------------------------------------*/

	if ( props & 0x1000 )
	{
	    const_lis.properties |= GRIS_VIEW_INDEP;
	}
/* ----------------------------------------------------------------------- */

	/*
	 *  Set read-only bit.
	 */

	/*
	 *  Set new bit.
	 */
	
	if ( props & 0x0200 )
	{
	    const_lis.properties |= GRIS_NEW;
	}

	/*
	 *  Set modified bit.
	 */

	if ( props & 0x0400 )
	{
	    const_lis.properties |= GRIS_MODIFIED;
	}

	/*
	 *  Set the locatable and component properties.
	 */

	const_lis.properties |= GRIS_LOCATABLE;

	/*
	 *  Set the displayble properties bit. For reference files this
	 *  bit is not set, so that the clipping polygon is not 
	 *  displayed in EMS.
	 */

	if (strcmp(class_name,"GRreffile"))
	{
		if ( !((props & 0x000f) == 2 || (props & 0x000f) == 6) )
		{
	 	   const_lis.properties |= GRIS_DISPLAYABLE;
		}
	}

	const_lis.geometry = buffer;
	const_lis.display = &display;
	const_lis.class_attr = class_attr;
	const_lis.name = 0;
	
	/*
	 *  set up display structure
	 */

	display.color = (((unsigned short)(symbology & 0xFF00) >> 8) + 1);
        if (display.color == 255)
	{
	   display.color = 0;
	}
	display.weight = ((unsigned char)(symbology & 0x00F8) >> 3);
	display.style = symbology & 0x0007;

	/*
         *  set-up scale matrix for IGDS to IGE working units
         */

	scale_matrix[0] = *scale_factor;
	scale_matrix[1] = 0.0;
	scale_matrix[2] = 0.0;
	scale_matrix[3] = 0.0;
	scale_matrix[4] = 0.0;
	scale_matrix[5] = *scale_factor;
	scale_matrix[6] = 0.0;
	scale_matrix[7] = 0.0;
	scale_matrix[8] = 0.0;
	scale_matrix[9] = 0.0;
	scale_matrix[10] = *scale_factor;
	scale_matrix[11] = 0.0;
	scale_matrix[12] = 0.0;
	scale_matrix[13] = 0.0;
	scale_matrix[14] = 0.0;
	scale_matrix[15] = 1.0;

        new_env = *current_env;
   
        MAmulmx ( &msg, &num_rc, &num_rc, &num_rc, current_env->md_env.matrix,
		  scale_matrix, new_env.md_env.matrix );

        MAtypemx ( &msg, new_env.md_env.matrix,
		   &new_env.md_env.matrix_type );

	/* 
	 *  construct object
	 */

	status = om$construct ( osnum = object_info->osnum,
				classname = class_name,
				p_objid = &object_info->objid,
				msg = message GRgraphics.GRconstruct
					( &const_lis ) );

	if ( ! (status & 1) )
	{
	    /*
	     *  error constructing object
	     *  print error message and exit
	     */

	    return (FALSE);
	}

	else
 
	{
	    return (TRUE);
	}

}

end implementation GRvg;
