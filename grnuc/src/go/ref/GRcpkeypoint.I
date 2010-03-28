/* #######################    APOGEE COMPILED   ######################## */
/*\
Name	
	GRkeypoint - keypoint of object

Synopsis

 	GRkeypoint(msg,matrix_type, matrix,
	  	boreline, keypoint, key_parm)

	IGRlong *msg		Completion code
	IGRshort *matrix_type	type of environment matrix
	IGRmatrix matrix	environment matrix
	struct IGRline *boreline line to project
	IGRpoint keypoint	keypoint
	struct GRparms *key_parm 
				parameter information for 
				keypoint

Description

	This method projects the line on the clipping polygon
	to determine the closest keypoint.

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
#include "mapriv.h"
#include "refpriv.h"

extern    IGRboolean    MAbclnproj();

method GRkeypoint(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
    struct IGRline *boreline; IGRpoint keypoint; struct GRparms *key_parm)
{

    IGRchar	*ptr,
		*saved_ptr;

    IGRlong 	OMmsg,			/* return codes			*/
		num1,
		num2;

    IGRint 	i;			/* loop index			*/

    IGRboolean  b_stat;

    IGRdouble	points[303],		/* points for transform		*/
    		dist1,			/* distance between projected pts*/
		dist2,
		curve_pt1[3],		/* projected points		*/
		curve_pt2[3],
		line_pt1[3],
		line_pt2[3],
		t1,
		t2,
		*pole_ptr;

    struct IGRcv_prism  *prism;
    struct IGRpointset ps;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    key_parm->polygon_inx = 0;
    key_parm->leaf_id.objid = my_id;
    key_parm->leaf_id.osnum = OM_Gw_current_OS;

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

	    b_stat = MAbcunweight(msg,&(prism->curve));

	    ps.num_points = prism->curve.num_poles;
	    ps.points = prism->curve.poles;

	    if ( MAlnpsproj(msg,boreline,&ps,
			line_pt1,curve_pt1,&t1,&num1))
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

	    	b_stat = MAbcunweight(msg,&(prism->curve));

	    	ps.num_points = prism->curve.num_poles;
	    	ps.points = prism->curve.poles;

	    	if ( MAlnpsproj(msg,boreline,&ps,
			line_pt2,curve_pt2,&t2,&num2))
		{
	    	    /* determine which of the projected points is closer
	     	     * to the input line
	     	     */
	
	    	    MA2pt2dis(msg,line_pt1,curve_pt1,&dist1);
	            MA2pt2dis(msg,line_pt2,curve_pt2,&dist2);
	    	    if (dist1 <= dist2)
	    	    {
		      	keypoint[0] = curve_pt1[0];
		    	keypoint[1] = curve_pt1[1];
		    	keypoint[2] = curve_pt1[2];
		    	key_parm->u = 
			  prism->curve.knots[num1+prism->curve.order-2];
	    	    }
	    	    else
	    	    {
		        keypoint[0] = curve_pt2[0];
		    	keypoint[1] = curve_pt2[1];
		    	keypoint[2] = curve_pt2[2];
		    	key_parm->u = 
			  prism->curve.knots[num2+prism->curve.order-2];
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
