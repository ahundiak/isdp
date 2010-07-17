/*
	I/STRUCT
*/
#include <string.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "adpdef.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
int VScheckStyle( style ) int style ; {

	/*
	 * Check that style number is valid.
	 */
	return GR_LO_STYLE <= style && style <= GR_HI_STYLE ;

} /* VScheckStyle */
/*----------------------------------------------------------------------------*/
int VScheckWeight( weight ) int weight ; {
	
	/*
	 * Check that weight number is valid.
	 */
	return GR_LO_WEIGHT <= weight && weight <= GR_HI_WEIGHT ;

} /* VScheckWeight */
/*----------------------------------------------------------------------------*/
int VScheckColor( color, val ) const VSexecRes *color ; int *val ; {

	/*
	 * Checks that color name or number is valid.
	 * Returns
	 * *val = VS_K_DRW_INV_CLR_NUM invalid color number	rc = FALSE
	 * *val = VS_K_DRW_INV_CLR_NAM invalid color name	rc = FALSE
	 * *val = the color number				rc = TRUE
	 */
	int rc ;

	if( VS_string == color->type ) {
		short	co ;

		rc = ige$get_color_from_name(	name	= color->_sval,
						color	= &co ) ;
		*val = rc ? co : VS_K_DRW_INV_CLR_NAM ;
	} else {
		int co = VSdrwIntVal( color ) ;

		rc = GR_LO_COLOR <= co && co <= GR_HI_COLOR ;
		*val = rc ? co : VS_K_DRW_INV_CLR_NUM ;
	}

	return rc ;

} /* VScheckColor */
/*----------------------------------------------------------------------------*/
int VScheckLayer( layer ) int layer ; {

	/*
	 * Check that layer number is valid.
	 */
	return GR_LO_LAYER <= layer && layer <= GR_HI_LAYER ;

} /* VScheckStyle */
/*----------------------------------------------------------------------------*/

