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

	This method projects the point on the clipping polygon.
	The projection will be to the defining polygon of the
	curve prism defining the clipping polygon.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.
        dhm     07/01/92        ANSI conversion.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "bserr.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "refpriv.h"

extern    IGRboolean    MAptbcproj();

method GRptproject(IGRlong *msg; IGRshort *matrix_type;
	    IGRmatrix matrix; IGRpoint point,proj_pt; 
	    struct GRparms *proj_parms) 
{
    IGRchar	*ptr;

    IGRlong 	OMmsg;			/* return codes			*/

    IGRdouble	points[200];		/* points for transform		*/
    IGRdouble	dist1,			/* distance between projected pts*/
		dist2,
		curve_pt1[3],		/* projected points		*/
		curve_pt2[3],
		u1,			/* parameters of projected points*/
		u2,
		tol,
		*pole_ptr,
		*saved_ptr;
    IGRint 	i;			/* loop index			*/

    struct IGRcv_prism  *prism;


    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    GRgetprism(msg,matrix_type,matrix,&ptr,i);

    if (1 & *msg)
    {					/* form front face 		*/
        prism = (struct IGRcv_prism *) ptr;

	if (prism->curve.num_poles > 101)
	{
	    pole_ptr = (IGRdouble *) om$malloc(
		size = (prism->curve.num_poles * 3 * sizeof(IGRdouble)));
	}
	else
	{
	    pole_ptr = points;
	}
        
	MArptsxform(msg,&prism->curve.num_poles,
		&prism->curve.rational,
		prism->curve.weights,prism->matrix,
		prism->curve.poles,pole_ptr);

	if ( 1 & *msg)
	{
	    saved_ptr = prism->curve.poles;
	    prism->curve.poles = pole_ptr;
	    tol = 0.000000001;

	    if ( MAptbcproj(msg,point,&prism->curve,&tol,curve_pt1,&u1))
	    {
	        prism->curve.poles = saved_ptr;

				/* do the other face		*/
	        if (prism->curve.rational)
	        {
		    for (i=0; i<prism->curve.num_poles; ++i)
	            {		/* height must be weighted	*/
		        prism->curve.poles[i*3+2] += 
			    prism->height / prism->curve.weights[i];
		    }
	    	}
	    	else
	    	{
		    for (i=0; i<prism->curve.num_poles; ++i)
	            {		/* insert height 		*/
		    	prism->curve.poles[i*3+2] += prism->height;
		    }
	    	}

	    	MArptsxform(msg,&prism->curve.num_poles,
		    &prism->curve.rational,
		    prism->curve.weights,prism->matrix,
		    prism->curve.poles,pole_ptr);

	    	prism->curve.poles = pole_ptr;
		
	    	if (MAptbcproj(msg,point,&prism->curve,&tol,curve_pt2,&u2))
		{
	    	    /* determine which of the projected points is closer
	     	     * to the input point
	     	     */
	
	    	    MA2pt2dis(msg,point,curve_pt1,&dist1);
	            MA2pt2dis(msg,point,curve_pt2,&dist2);
	    	    if (dist1 < dist2)
	    	    {
		      	proj_pt[0] = curve_pt1[0];
		    	proj_pt[1] = curve_pt1[1];
		    	proj_pt[2] = curve_pt1[2];
		    	proj_parms->u = u1;
	    	    }
	    	    else
	    	    {
		        proj_pt[0] = curve_pt2[0];
		    	proj_pt[1] = curve_pt2[1];
		    	proj_pt[2] = curve_pt2[2];
		    	proj_parms->u = u2;
	            }
		}
		else			/* project failed		*/
		{
		    OMmsg = OM_E_ABORT;
		}

		/* the cache has been corrupted by the addition of the
		 * height to the z componet. Delete the pointer.
		 */
		
		GRabsg_del_all();
     	    }
    	    else
    	    {
		OMmsg = OM_E_ABORT;
    	    }
	}
	else				/* transform failed		*/
	{
	    OMmsg = OM_E_ABORT;
	}
    }
    else
    {
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}

end implementation GRclippoly;
