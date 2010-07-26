/*
 *  This method creates the contents of the symbol library.
 *  The elements of the cell library are read, translated
 *  to objects, and then constructed in the symbol library
 *  object space.
 */

class implementation COcvtclsl;

#include "exsysdep.h"
#include "coimport.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"

method cvt_next_ele ( IGRlong *msg; struct GRid *object_info )


{
    IGRlong	status;			/* return code value		*/
    IGRshort	*ele_ptr;		/* pointer to element buffer	*/
#ifdef BIG_ENDIAN
    IGRshort    direc = 0;
#endif

    /*
     *  Read design file and format element buffers
     *  until reaching the end of file.
     */

    if ( (status = GUget_next_ele ( msg, &me->cvt_bufs )) == TRUE )
    {

        /*
         *  Set pointer to element buffer.
         */

	    ele_ptr = (IGRshort *) me->cvt_bufs.ele_buf;

	/*
	 *  Calculate the element type.
 	 */

#ifdef BIG_ENDIAN
	me->cvt_bufs.ele_type = ( *ele_ptr & 0x007f ) ;
#else
	me->cvt_bufs.ele_type = ( *ele_ptr & 0x7f00 ) >> 8;
#endif

	/*
	 *  Process according to element type.
	 */

	switch ( me->cvt_bufs.ele_type )
	{
	    case GU_CELL_LIB_HEADER:

	    	status = om$send ( mode = OM_e_wrt_object,
			           msg = message COcvtclsl.cvt_type1
					 ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
		break;

	    case GU_CELL:

		status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvtclsl.cvt_type2
				         ( msg, object_info),
				   senderid = my_id,
				   targetid = my_id );
		break;

	    case GU_LINE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type3
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_LINE_STRING:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type4
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_GROUP_DATA:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvtclsl.cvt_type5 ( msg,
					 object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_SHAPE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type6
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_TEXT_NODE:
		break;

	    case GU_DIGITIZER:
	    	break;

	    case GU_DGN_FILE_HEADER:
		break;

	    case GU_LEVEL_SYMBOLOGY:
	    	break;

	    case GU_CURVE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type1113
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_CPX_STRING:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type1214
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
		break;

	    case GU_CONIC:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type1113
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_CPX_SHAPE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type1214
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
		break;

	    case GU_ELLIPSE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type15
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_ARC:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type16
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;

	    case GU_TEXT:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type17
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;
#ifndef IDRAW
	    case GU_SURFACE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type1819
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
		break;

	    case GU_SOLID:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type1819
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
		break;
#endif
	    case GU_BS_POLE:
#ifdef BIG_ENDIAN
		GRswap_type21_ele(me->cvt_bufs.ele_buf,direc);
#endif
	    	break;

	    case GU_POINT_STRING:
	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type22
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;
#ifndef IDRAW
	    case GU_CIRC_TRUNC_CONE:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type23
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
	    	break;
#endif
	    case GU_BS_SURF_HEADER:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type2427
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
 		break;

	    case GU_BS_SURF_BOUNDARY:
#ifdef BIG_ENDIAN
	     GRswap_type25_ele(me->cvt_bufs.ele_buf,direc);
#endif
	    	break;

	    case GU_BS_KNOT:
#ifdef BIG_ENDIAN
	     GRswap_type26_ele(me->cvt_bufs.ele_buf,direc);
#endif
	    	break;

	    case GU_BS_CURVE_HEADER:

	    	status = om$send ( mode = OM_e_wrt_object,
				   msg = message COcvigdsige.cvt_type2427
				   ( msg, object_info ),
				   senderid = my_id,
				   targetid = my_id );
		break;

	    case GU_BS_WEIGHT_FACTOR:
#ifdef BIG_ENDIAN
	     GRswap_type28_ele(me->cvt_bufs.ele_buf,direc);
#endif
	    	break;

	    default:
	    	break;

	}

    } /* end if still more design file */

    if ( *msg == GULAST_ELEMENT || *msg == GUREAD_ERROR ) 
    {
	status = FALSE;
    }

    return ( status );

}
end implementation COcvtclsl;
