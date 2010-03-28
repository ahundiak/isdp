/* #######################    APOGEE COMPILED   ######################## */
/*\
Name	
	GRputsavevw - gets the saved view information and
		places it in the reference file instance.

Synopsis

	GRputsavevw(msg,input_lbsys,view_id,ref_id,
		ref_osnum,ref_to_master,master_to_ref,
		levels,vw_rotation,vw_origin,vw_volume,
		is_skew)

	IGRlong		*msg;		
	struct IGRlbsys *input_lbsys;
	struct GRid	*view_id;
	GRobjid		*ref_id;
	GRspacenum	*ref_osnum;
	IGRmatrix	ref_to_master;
	IGRmatrix	master_to_ref;
	IGRint		*levels;
	IGRmatrix	vw_rotation;
	IGRdouble	*vw_origin;
	IGRdouble	*vw_volume;
	IGRboolean	*is_skew;

Description
	This function retrieves the information about a saved
	view and places it in the instance data of the
	GRreffile graphics object.  The instance pointers
	are input arguments to this function.

Diagnostics
	This method has the following possible return codes:
	
	MSSUCC - Successful completion
	GRVIEWNOTFOUND - the requested saved view not found
	MSFAIL - error occurred, failure of the function

Notes
	None

History
	MAS	03/30/87	Design Date
\*/


#include "grimport.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "dp.h"
#include "dperr.h"
#include "referr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "gr.h"

extern    IGRboolean    MAinvmx();
extern    IGRboolean    MAmulmx();

	#argsused
IGRint  GRputsavevw(msg,input_lbsys,view_id,ref_id,
	ref_osnum,ref_to_master,master_to_ref,
	levels,vw_rotation,vw_origin,vw_volume,is_skew)

IGRlong		*msg;		
struct IGRlbsys *input_lbsys;
struct GRid	*view_id;
GRobjid		*ref_id;
GRspacenum	*ref_osnum;
IGRmatrix	ref_to_master;
IGRmatrix	master_to_ref;
IGRint		*levels;
IGRmatrix	vw_rotation;
IGRdouble	*vw_origin;
IGRdouble	*vw_volume;
IGRboolean	*is_skew;

{

    IGRshort mx_size;			/* matrix size			*/

    IGRlong i,				/* loop index			*/
	OMmsg;

    IGRlong returned_bytes;		/* for view structure		*/
    IGRlong error;

    IGRint  view_type;
					
    struct  var_list vw_list[3];	/* arguments for view info	*/
    struct  DPsavevw vw_struct;
     
    IGRmatrix  	tmatrix1,		/* working matrices		*/
		tmatrix2;
					
					/* initialize return values	*/
    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    vw_list[0].var = SAV_VW_STRUCT;
    vw_list[0].var_ptr = (IGRchar *)&vw_struct;	
    vw_list[0].num_bytes = sizeof(struct DPsavevw);
    vw_list[0].bytes_returned = &returned_bytes;

    vw_list[1].var = VIEW_TYPE;
    vw_list[1].var_ptr = (IGRchar *)&view_type;
    vw_list[1].num_bytes = sizeof (IGRint);
    vw_list[1].bytes_returned = &returned_bytes;
     
    vw_list[2].var = END_PARAM;

    dp$inq_set_gragad( 
	    msg = msg,
	    osnum = *ref_osnum,
	    gragad_objid = view_id->objid,
	    which_error = &error,
	    var_list = vw_list);

    if  (! ( 1 & *msg))
    {
	*msg = GRVIEWNOTFOUND;
	OMmsg = OM_E_ABORT;
    }
    else
    {
	for (i=0; i<32; ++i)
	{
	    levels[i] = vw_struct.levels[i];
  	}
	if (vw_struct.flags & AXIS_WLD_ALIGN)
	{
	    *is_skew = 0;
	}
	else
	{
	    *is_skew = 1;
	}
        mx_size = 4;
	MAtrnmx(msg,&mx_size,vw_struct.rotation,vw_rotation);

        MAlswcmx(msg,vw_struct.origin,vw_rotation, tmatrix1);

	if (view_type == TYPE_GRAGAD)
	{
	    /* adjust the origin of the view to be the center of view
	     */

	    IGRint    	num = 2;

	    IGRdouble 	tmp_vol[6],
			parm = 0.5;

	    struct IGRline line;
					   /* transform to world coords	*/
	    MAptsxform(msg,&num,tmatrix1,vw_struct.vw_volume,tmp_vol);

	    line.point1 = tmp_vol;
	    line.point2 = &tmp_vol[3];	    
					    /* get new origin		*/
	    MAptattparm(msg,&parm,&line,vw_origin);
	   			    /* transform to new	local coods	*/
  	    MAwclsmx(msg,vw_origin,vw_rotation,tmatrix1);
				    
	    MAptsxform(msg,&num,tmatrix1,tmp_vol,vw_volume);
	}	    				    
        else
	{
            for (i=0; i<3; ++i)
            {
	    	vw_volume[i] = vw_struct.vw_volume[i];
	    	vw_volume[i+3] = vw_struct.vw_volume[i+3];
	    	vw_origin[i] = vw_struct.origin[i];
	    }
	}

        MAwclsmx(msg,vw_origin,vw_rotation, tmatrix2);

        /* form matrix to transform from reference file 
         * coordinates to master file coordinates
   	 * input_lbsys->matrix - translation and scale from
	 *			    master file
         * tmatrix2 - from world to local coordinates in
         *		  reference file
         */
				
        MAmulmx(msg,&mx_size,&mx_size,&mx_size,input_lbsys->matrix,
		tmatrix2,ref_to_master);

        /* form matrix to transform from master file to 
	 * reference file coordinates.
	 */

        if (! MAinvmx(msg,&mx_size,ref_to_master,master_to_ref))
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
        }
    }					

    return( OMmsg );
}

