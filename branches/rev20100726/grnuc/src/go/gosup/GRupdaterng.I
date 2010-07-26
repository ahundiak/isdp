/* #######################    APOGEE COMPILED   ######################## */
/*
 *--------------------------------------------------------------------
 *               F U N C T I O N   D E S C R I P T I O N
 *--------------------------------------------------------------------
 *
 *	This function is a utility tool to perform all the
 *	necessary adjustment when the range of an object
 *	changes.  This adjustment includes R-tree update and
 *	maintenance and update of the range in the object.
 *	All of the post methods make use of this function.
 * 	This function is not called from the post routines
 *  	if the object is being constructed.
 *
 */

class implementation GRvg;


#include "grimport.h"
#include "godef.h"
#include "madef.h"
#include "gopriv.h"
#include "OMmacros.h"
#include "msdef.h"

from GRmodule import GRmdremove,GRmdaddwrng;

long GRupdaterng(msg,md_info,post_info,objid,properties,old_range,new_range)

    long		*msg;		/*  return code		   	*/
    struct GRmd_env	*md_info;	/*  environment info	    	*/
    struct GRpost_info  *post_info;	/*  processing control info 	*/
    GRobjid		*objid;		/*  pntr to my_id	    	*/ 
    unsigned short	*properties;	/*  pntr to me->properties  	*/
    GRrange		old_range;	/*  range before altered	*/
    GRrange		new_range;	/*  range after altered  	*/
{

    long		i;
    long		OMmsg;
    IGRboolean		range_flag;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    if ( post_info->construct_flag)
    {
	goto wrapup;
    }

    if  ( !   (IF_NULL_OBJID(md_info->md_id.objid) ||
	      (*properties & GRNOT_IN_RTREE)) )
    {
	/*
 	 *  compare range values to see if they are different
 	 */

	GRrange_check(old_range,new_range,range_flag,i)

	/*
	 *  if the range has changed, perform R-tree update
	 */

	if ( !range_flag )
	{
	    /*  
	     *  delete the old object from the R-tree
	     */

	    OMmsg = GRownerrem(msg,md_info,objid,&md_info->md_id.osnum,
			old_range);

	    if ( 1 & OMmsg & *msg)
	    {
	    	/*
	     	 *  add the updated object to the R-tree
	     	 */

	         OMmsg = GRowneradd(msg,md_info,objid,
			&md_info->md_id.osnum,new_range);
		
	    }
	}
    }

wrapup:
    return(OMmsg);
}

end implementation GRvg;
