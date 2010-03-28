/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function determines which views should be in full 
 *  mode and set up the window min and max values accordingly
 *
 *  If a view is not in full mode, assign the proper quad
 *  mode values to the window min and max variables
 */

#include "grimport.h"
#include "igrtypedef.h"
#include "transdef.h"

void    GUiget_window_min_max ( view_num, screen1, screen2, min_x, min_y,
			       max_x, max_y )

IGRchar		*view_num;   /* IGDS view number being constructed     */
IGRchar		*screen1;    /* IGDS setting for full mode in screen1  */
IGRchar		*screen2;    /* IGDS setting for full mode in screen2  */
IGRdouble	*min_x;	     /* min x uor value for independent window */
IGRdouble	*min_y;      /* min y uor value for independent window */
IGRdouble	*max_x;      /* max x uor value for independent window */
IGRdouble	*max_y;      /* max y uor value for independent window */

{
	if (( *view_num == *screen1 ) || ( *view_num == *screen2 ))
	{
	    *min_x = GU_FULL_MIN_X;
	    *min_y = GU_FULL_MIN_Y;
	    *max_x = GU_FULL_MAX_X;
	    *max_y = GU_FULL_MAX_Y;
	}
	else
	{
	    if (( *view_num == 1 ) || ( *view_num == 5 ))
	    {
		*min_x = GU_QUAD1_MIN_X;
		*min_y = GU_QUAD1_MIN_Y;
		*max_x = GU_QUAD1_MAX_X;
		*max_y = GU_QUAD1_MAX_Y;
	    }
	    else if (( *view_num == 2 ) || ( *view_num == 6 ))
	    {
		*min_x = GU_QUAD2_MIN_X;
		*min_y = GU_QUAD2_MIN_Y;
		*max_x = GU_QUAD2_MAX_X;
	   	*max_y = GU_QUAD2_MAX_Y;
	    }
	    else if (( *view_num == 3 ) || ( *view_num == 7 ))
	    {
		*min_x = GU_QUAD3_MIN_X;
		*min_y = GU_QUAD3_MIN_Y;
		*max_x = GU_QUAD3_MAX_X;
		*max_y = GU_QUAD3_MAX_Y;
	    }
	    else if (( *view_num == 4 ) || ( *view_num == 8 ))
	    {
		*min_x = GU_QUAD4_MIN_X;
		*min_y = GU_QUAD4_MIN_Y;
		*max_x = GU_QUAD4_MAX_X;
		*max_y = GU_QUAD4_MAX_Y;
	    }
	}	
}
