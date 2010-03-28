/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRxformref - tranforms the contents of a reference view
Synopsis

	GRxformref(msg,mx_type,matrix,xform_matrix)

	IGRlong *msg		Completion code
	IGRshort *mx_type	type of environment matrix
	IGRmatrix matrix	environment matrix
	IGRmatrix xform_matrix  matrix to transform contents by

Description
	This method does a transformation of the viewing area of 
	a reference file view.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMmacros.h"

method GRxformref(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
	IGRmatrix xform_matrix )
{
    IGRchar	*ptr;		/* pointer to geometry			*/

    IGRlong	OMmsg;		/* return codes				*/

    IGRint	i,		/* loop index				*/
		dimension;

    struct GRmd_env local_env;
    struct IGRlbsys  lbsys,
		    new_lbsys;
    struct GRpost_info post_info;
    GRobjid	poly_objid;

    *msg = MSSUCC;		/* initialize return values		*/
    OMmsg = OM_S_SUCCESS;

    dimension = om$dimension_of(varray = me->filename);

    if ( dimension)
    {
        /* get the local bounded system definition of the reference file
         * attachment object
         */

	OMmsg = om$send (msg = message GRreffile.GRgetlbsys
		(msg,mx_type,matrix,&lbsys),
	    targetid = my_id);

	if (1 & OMmsg)
	{
	    /* transform the old local bounded system definition
	     */

/*	    origin[0] = lbsys.matrix[3];
	    origin[1] = lbsys.matrix[7];
	    origin[2] = lbsys.matrix[11];

	    lbsys.matrix[3] = 0.0;
	    lbsys.matrix[7] = 0.0;
	    lbsys.matrix[11] = 0.0;
*/	    
	    MAlbxform(msg,&lbsys,xform_matrix,&new_lbsys);

	    if ( 1 & *msg)
	    {
		/* set up local environment structure so that R-tree
		 * manipulations are not done
		 */

		for(i=0; i<16; ++i)
		{
		    local_env.md_env.matrix[i] = matrix[i];
		}
		/* for this method we don't want the design file
		 * limits to be exceeded, therefore the diagonal
		 * points are reset.
		 */

		for(i=0; i<3; ++i)
		{
		    new_lbsys.diag_pt1[i] = lbsys.diag_pt1[i];
		    new_lbsys.diag_pt2[i] = lbsys.diag_pt2[i];
		}
		local_env.md_env.matrix_type = *mx_type;
		local_env.md_id.objid = NULL_OBJID;
		local_env.md_id.osnum = OM_Gw_current_OS;

		post_info.construct_flag = FALSE;

/*	        new_lbsys.matrix[3] = origin[0];
	    	new_lbsys.matrix[7] = origin[1];
	    	new_lbsys.matrix[11] = origin[2];
*/		
	 	OMmsg = om$send (msg = message GRreffile.GRpostlbsys
			(msg,&local_env,&post_info,&new_lbsys),
	    	    targetid = my_id);

		if ( 1 & OMmsg & *msg)
		{
		    /* the new scan range for the reference file 
		     * display operations must be computed.  It
		     * will be changed due to the scale operation.
		     */

		    GRgetabsg(msg,mx_type,matrix,&ptr,i);
		    if ( 1 & *msg)
		    {
			poly_objid = NULL_OBJID;

		        GRgetranges(msg,&local_env,ptr,
				me->master_to_ref_matrix,&my_id,
				&poly_objid,me->range);
		    }
		}
	    }
  	}
    }


    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);

    return(OMmsg);
}

end  implementation GRreffile;
