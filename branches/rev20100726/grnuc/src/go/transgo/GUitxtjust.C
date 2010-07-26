/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function determines the text justification 
 *  and the origin for the text object given an
 *  IGDS text element.
 */

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "fontdef.h"
#include "font.h"
#include "igrdp.h"
#include "gotext.h"
#include "gotextdef.h"
#include "igr.h"
#include "madef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"

IGRint GUitxtjust ( msg, justification, origin, txt_extents, 
		    rot_matrix, scale_factor )

IGRlong		*msg;
IGRshort	*justification;
IGRdouble	origin[3];
struct extents	*txt_extents;
IGRmatrix	rot_matrix;
IGRdouble	*scale_factor;

{

    IGRlong	status;
    IGRlong	num_points;
    IGRdouble 	height;
    IGRdouble	length;
    IGRdouble	origin_xform[4];



    num_points = 1;  
    origin_xform[0] = 0;
    origin_xform[1] = 0;
    origin_xform[2] = 0;
    origin_xform[3] = 1.0;

    /*
     *	Compute the height and the length of the text string.
     */

    height = txt_extents->cap - txt_extents->base;
    length = txt_extents->right - txt_extents->left;
    height *= *scale_factor;
    length *= *scale_factor;


    if ( height < 0 || length < 0 )
    {
	status = FALSE;
	goto wrap_up;
    }

    /*
     *  Set the IGE justification which is equivalent to
     *  the IGDS justification.  Calculate the IGE origin,
     *  given the IGDS origin and justification. The IGDS
     *  is stored differently for text created by mirroring 
     *  another text object. These may be identified by the
     *  negative value of the txt_extents->left. The origin 
     *  in their case has to be calculated differently.
     */

    if (txt_extents->left < 0)
    {
	switch ( *justification )
	{
	   case GUIGDS_L_TOP:
		*justification = LEFT_CAP;
		origin_xform[0] -= length; 
		origin_xform[1] += height;		
		break;

	   case GUIGDS_L_CENTER:
		*justification = LEFT_CENTER; 
		origin_xform[0] -= length; 
		origin_xform[1] += height/2;		
		break;

	   case GUIGDS_L_BOTTOM:
		*justification = LEFT_BASE;
		origin_xform[0] -= length;
		break;

	   case GUIGDS_C_TOP:
		*justification = CENTER_CAP;
		origin_xform[0] -= length/2; 
		origin_xform[1] += height;
		break;

	   case GUIGDS_C_CENTER:
		*justification = CENTER_CENTER;
		origin_xform[0] -= length/2;
		origin_xform[1] += height/2;		
		break;

	   case GUIGDS_C_BOTTOM:
		*justification = CENTER_BASE;
		origin_xform[0] -= length/2;
		break;

	   case GUIGDS_R_TOP:
		*justification = RIGHT_CAP;
		origin_xform[1] += height; 
		break;

	   case GUIGDS_R_CENTER:
		*justification = RIGHT_CENTER;
		origin_xform[1] += height/2;
		break;

	   case GUIGDS_R_BOTTOM:
		*justification = RIGHT_BASE;
		break;

	   default:
		*justification = LEFT_BASE;
		origin_xform[0] -= length; 

	}
    }
    else
    {
         switch ( *justification )
         {
	    case GUIGDS_L_TOP:
	    	*justification = LEFT_CAP;
	    	origin_xform[1] = height;
	    	break;

	    case GUIGDS_L_CENTER:
	   	*justification = LEFT_CENTER;
	    	origin_xform[1] = ( height / 2 );
	    	break;

	    case GUIGDS_L_BOTTOM:
	    	*justification = LEFT_BASE;
	    	break;

     	    case GUIGDS_C_TOP:
	    	*justification = CENTER_CAP;
	    	origin_xform[0] = ( length / 2 );
	    	origin_xform[1] = height;
	    	break;

	    case GUIGDS_C_CENTER:
	    	*justification = CENTER_CENTER;
	    	origin_xform[0] = ( length / 2 );
	    	origin_xform[1] = ( height / 2 );
	    	break;

	    case GUIGDS_C_BOTTOM:
	    	*justification = CENTER_BASE;
	    	origin_xform[0] = ( length / 2 );
	    	break;

	    case GUIGDS_R_TOP:
	    	*justification = RIGHT_CAP;
	    	origin_xform[0] = length;
	    	origin_xform[1] = height;
	    	break;

     	    case GUIGDS_R_CENTER:
	    	*justification = RIGHT_CENTER;
	    	origin_xform[0] = length;
	    	origin_xform[1] = ( height / 2 );
	    	break;

	    case GUIGDS_R_BOTTOM:
	   	*justification = RIGHT_BASE;
	    	origin_xform[0] = length;
	    	break;

	    default:
	    	*justification = LEFT_BASE;

	}
    }

    /*
     *  Adjust the origin for rotated text.
     */

    status = MAptsxform ( msg, &num_points, rot_matrix, origin_xform, 
			  origin_xform );

    origin[0] += origin_xform[0];
    origin[1] += origin_xform[1];
    origin[2] += origin_xform[2];

    status = TRUE;


    wrap_up:
	return ( status );

}


	    
