/* #######################    APOGEE COMPILED   ######################## */
/*\
Name	
	GRptproject - project point on object

Synopsis

	GRptproject(msg,matrix_type,matrix,point,
		proj_pt,proj_parms)
	
	IGRlong *msg		Completion code
	IGRshort *matrix_type	type of environment matrix
	IGRmatrix matrix	environment matrix
	IGRpoint point		point to project
	IGRpoint proj_pt	project point on object
	struct GRparms *proj_parms	parameter information
				for point on object

Description

	This method projects the point on the clipping polygon
	or on the local bounded system defining the attachment
	depending on the ref_properties on the object.

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
#include "bserr.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRptproject(IGRlong *msg; IGRshort *matrix_type;
	    IGRmatrix matrix; IGRpoint point,proj_pt; 
	    struct GRparms *proj_parms) 

{
	IGRchar *ptr;

	IGRlong OMmsg;

	IGRint	msg1;
	IGRint  i;
	IGRint  indicator;

	struct IGRrt_prism rp;
	struct IGRcv_prism *cv_prism;

	OMmsg = OM_S_SUCCESS;
	*msg =  MSSUCC;

	GRgetabsg(msg,matrix_type,matrix,&ptr,i);

	if ( 1 & *msg)
	{
	    /* for now use the BS locate functions to determine if 
	     * the point is in the volume.
	     */

	    cv_prism = (struct IGRcv_prism *)ptr;
	    if ((cv_prism->curve.order == 2) && 
		(!cv_prism->curve.rational))
	    {
	    				/* form right prism for now	*/
	        for (i=0; i<16; ++i)
	    	{
		    rp.matrix[i] = cv_prism->matrix[i];
	    	}
	        rp.height = cv_prism->height;
	        rp.polygon.points = cv_prism->curve.poles;
	        rp.polygon.num_points = cv_prism->curve.num_poles;

	        BSlocrefvwp( &rp,point,&indicator,&msg1);
	 
	        if (msg1 == BSSUCC)
	        {
		    if (indicator)
		    {
		        for (i=0; i<3; ++i)
		        {
			    proj_pt[i] = point[i];
		        }
		        proj_parms->u = proj_parms->v = 0;
		    }
	    	}
	    	else
	    	{
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		}
	    }
	}

     

     return(OMmsg);

}
end implementation GRreffile;
