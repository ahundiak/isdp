/* #######################    APOGEE COMPILED   ######################## */
class implementation COcvigdsige;

#include "coimport.h"
#include "msdef.h"

/*
 *  This function will get the active design
 *  parameters from the IGDS type 9 element
 *  and place them in the DPB.
 */

method cvt_type5 (IGRlong *msg; struct GRid *object_info)

{
    IGRchar			*ele_ptr;
    IGRlong			status;


    status = TRUE;

    ele_ptr = (IGRchar *) me->cvt_bufs.ele_buf;

    /*
     *  Determine how to process the type5 by
     *  its level.
     */

    switch ( *ele_ptr )
    {
	case 1:
	
	    status = COcvt_type5lv1 ( msg, ele_ptr );
	
	    break;
	case 3:
	    
	    status = COcvt_type5lv3 ( msg, ele_ptr, &me->IGDS_file_type, 
			              &me->scale_factor, object_info );
	    
	    break;
 
	case 9:
	
	    status = COcvt_type5lv9 ( msg, ele_ptr, &me->IGDS_file_type, 
				      &me->scale_factor, object_info,
							 &me->current_env );
	
	    break;

	default:
	    break;
	
    }


    return ( status );
}

end implementation COcvigdsige;


