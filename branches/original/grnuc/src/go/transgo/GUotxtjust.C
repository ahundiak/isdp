/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "transdef.h"
#include "gotextdef.h"


IGRint GUotextjust ( justification )

IGRshort	*justification;

{

    IGRlong	status;


    status = TRUE;

    /*
     *  Set the IGDS justification which is equivalent to
     *  the IGE justification.
     */

    switch ( *justification )
    {
	case LEFT_BASE:
	case LEFT_BOTTOM:
	    *justification = GUIGDS_L_BOTTOM;
	    break;
	case LEFT_CENTER:
	    *justification = GUIGDS_L_CENTER;
	    break;
	case LEFT_CAP:
	case LEFT_TOP:
	    *justification = GUIGDS_L_TOP;
	    break;
     	case CENTER_BASE:
     	case CENTER_BOTTOM:
	    *justification = GUIGDS_C_BOTTOM;
	    break;
	case CENTER_CENTER:
	    *justification = GUIGDS_C_CENTER;
	    break;
	case CENTER_CAP:
	case CENTER_TOP:	
	    *justification = GUIGDS_C_TOP;
	    break;
	case RIGHT_BASE:
	case RIGHT_BOTTOM:	
	    *justification = GUIGDS_R_BOTTOM;
	    break;
   	case RIGHT_CENTER:
	    *justification = GUIGDS_R_CENTER;
	    break;
	case RIGHT_CAP:
	case RIGHT_TOP:	
	    *justification = GUIGDS_R_TOP;
	    break;
	default:
	    *justification = GUIGDS_L_BOTTOM;
	    status = FALSE;
    }


	return ( status );

}
