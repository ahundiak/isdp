/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This method extracts information from the
 *  IGDS type 5 element to aid in creating the
 *  IGE symbol library.
 */

class implementation COcvtclsl;

#include	"coimport.h"

method cvt_type5 ( IGRlong *msg; struct GRid *object_info )
	

{
    struct IGDS_cell_lib_header	*igdsclhdr;


	igdsclhdr = (struct IGDS_cell_lib_header *) me->cvt_bufs.ele_buf;

	/*
	 *  determine the type of cell library
 	 *  and set the cl_type used by the
 	 *  object translation routines
	 */

	if ( (igdsclhdr->header.level & 0xC0) == 0xC0 )
	{
	    /*
	     *  cell library is 3-D
	     *  construct 3-D floating point objects
	     */

	    me->IGDS_file_type = GU_3D;
	}
	else
	{
	    /*
	     *  cell library is 2-D
	     *  construct 2-D floating point objects
	     */

	    me->IGDS_file_type = GU_2I;
	}

	me->object_type = GU_3D;

return (OM_S_SUCCESS);
}

end implementation COcvtclsl;
