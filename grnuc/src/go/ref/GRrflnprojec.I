/* #######################    APOGEE COMPILED   ######################## */
/*\
Name	
	GRlnproject - project line on object

Synopsis

	GRlnproject(msg,matrix_type,matrix,line,ln_pt,
		proj_pt,t,proj_parms)
	
	IGRlong *msg		Completion code
	IGRshort *matrix_type	type of environment matrix
	IGRmatrix matrix	environment matrix
	struct IGRline *line	line to project
	IGRpoint ln_pt		projected point on line
	IGRpoint proj_pt	project point on object
	IGRdouble *t		t parameter of point on line
	struct GRparms *proj_parms	parameter information
				for point on object

Description

	This method projects the line on the clipping polygon
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

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
	    IGRmatrix matrix; struct IGRline *line;
	    IGRpoint ln_pt,proj_pt; IGRdouble *t;
	    struct GRparms *proj_parms) 

{
	IGRchar *ptr;

	IGRlong OMmsg;

	IGRint	msg1;
	IGRint  i;
	IGRint  indicator;

	IGRdouble vc[3];

	struct IGRrt_prism rp;
	struct IGRcv_prism *cv_prism;

	OMmsg = OM_S_SUCCESS;
	*msg =  MSSUCC;

	GRgetabsg(msg,matrix_type,matrix,&ptr,i);

	if ( 1 & *msg)
	{
	    /* for now use the BS locate functions to determine if 
	     * the line intersects the volume.
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

	        vc[0] = line->point1[0] - line->point2[0];
	        vc[1] = line->point1[1] - line->point2[1];
	        vc[2] = line->point1[2] - line->point2[2];
	    
	        BSlocrefvwl( &rp,line->point1,vc,&indicator,&msg1);
	 
	        if (msg1 == BSSUCC)
	        {
		    if (indicator)
		    {
		        for (i=0; i<3; ++i)
		        {
			    ln_pt[i] = proj_pt[i] = line->point1[i];
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
