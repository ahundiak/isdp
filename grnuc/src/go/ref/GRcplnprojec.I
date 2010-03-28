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
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "refpriv.h"

extern    IGRboolean    MAbclnproj();

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
	    IGRmatrix matrix; struct IGRline *line;
	    IGRpoint ln_pt,proj_pt; IGRdouble *t;
	    struct GRparms *proj_parms) 
{

    IGRchar	*ptr,
		*saved_ptr;

    IGRlong 	OMmsg;			/* return codes			*/

    IGRint 	i;			/* loop index			*/

    IGRdouble	points[303],		/* points for transform		*/
		tol,			/* tolerance for projection	*/
    		dist1,			/* distance between projected pts*/
		dist2,
		curve_pt1[3],		/* projected points		*/
		curve_pt2[3],
		line_pt1[3],
		line_pt2[3],
		u1,			/* parameters of projected points*/
		u2,
		t1,
		t2,
		*pole_ptr;

    struct IGRcv_prism  *prism;


    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    tol = 0.01;	

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
	    saved_ptr = (IGRchar *)prism->curve.poles;
	    prism->curve.poles = pole_ptr;

	    if ( MAlnbcproj(msg,line,&prism->curve,&tol,
			line_pt1,curve_pt1,&t1,&u1))
	    {			
				/* restore pole pointer		*/
	        prism->curve.poles = (IGRdouble *)saved_ptr;

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
		
	    	if ( MAlnbcproj(msg,line,&prism->curve,&tol,
			line_pt2,curve_pt2,&t2,&u2))
		{
	    	    /* determine which of the projected points is closer
	     	     * to the input line
	     	     */
	
	    	    MA2pt2dis(msg,line_pt1,curve_pt1,&dist1);
	            MA2pt2dis(msg,line_pt2,curve_pt2,&dist2);
	    	    if (dist1 < dist2)
	    	    {
		      	proj_pt[0] = curve_pt1[0];
		    	proj_pt[1] = curve_pt1[1];
		    	proj_pt[2] = curve_pt1[2];
		      	ln_pt[0] = line_pt1[0];
		    	ln_pt[1] = line_pt1[1];
		    	ln_pt[2] = line_pt1[2];
		    	proj_parms->u = u1;
			*t = t1;
	    	    }
	    	    else
	    	    {
		        proj_pt[0] = curve_pt2[0];
		    	proj_pt[1] = curve_pt2[1];
		    	proj_pt[2] = curve_pt2[2];
		        ln_pt[0] = line_pt2[0];
		    	ln_pt[1] = line_pt2[1];
		    	ln_pt[2] = line_pt2[2];
			*t = t2;
		    	proj_parms->u = u2;
	            }
		}
		else			/* project failed		*/
		{
		    OMmsg = OM_E_ABORT;
		}

		/* the cache has been corrupted by the addition of the
		 * height to the z component. Delete the pointer.
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

    	if (prism->curve.num_poles > 101)
    	{
	    om$dealloc(ptr = pole_ptr);
    	}
    }
    else
    {
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}

end implementation GRclippoly;
