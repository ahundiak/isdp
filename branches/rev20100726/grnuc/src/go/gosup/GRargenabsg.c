/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	GRargenabsg
 
     Abstract:

		This method function generates the abstract 
	data for any geometry that can be expressed as a generic 
	arc geometry.

-----
%SC%

     VALUE = GRargenabsg(msg,matrix_type,matrix,my_id,arc,
			 absgptr)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *matrix_type IGRshort	 type of the transformation matrix
     matrix	  IGRmatrix	 local-to-world transformation 
     *my_id	  GRobjid	 object id of graphics object
     *arc	  IGRarc	 generic arc structure

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				      due to allocation problems
     **absgptr    IGRchar	 pointer to abstract geometry 

     VALUE (IGRboolean) = TRUE	    - if successful
			  FALSE	    - if an error occurred
 
-----
%MD%

     MODULES INVOKED:

			MAartobc
			MArptsxform
			GRabsg_alloc

-----
%NB%

     NOTES:		None.

-----
%CH%
     CHANGE HISTORY:
	
	REJ  01/07/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

	Call function MAartobc to obtain the B-spline rep.
	of the given arc.  Then allocate space in the abstract
	geometry cache,  partition the buffer allocated,  and
	copy the B-spline representation into the buffer.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h"
#include "msdef.h"

extern    IGRboolean    MAartobc();
extern    IGRchar    *GRabsg_alloc();
extern    IGRboolean    MAeltobc();

IGRboolean GRargenabsg(msg,matrix_type,matrix,my_id,arc,absgptr)

IGRlong		  *msg;			/* output - completion code	*/
IGRshort	  *matrix_type;		/* input - type of matrix	*/
IGRmatrix  	  matrix;		/* input - transformation	*/
GRobjid		  *my_id;		/* input - object id		*/
struct IGRarc	  *arc;			/* input - arc to put in cache	*/
IGRchar		  **absgptr;		/* output - pointer to entry	*/
					/* 	    in cache		*/

{

	IGRboolean status;		/* function return		*/
	IGRlong    msg1;		/* working completion code	*/
	IGRint	   i;			/* loop counter			*/
	IGRlong    nbytes;		/* number of bytes to allocate	*/
	struct	   IGRbsp_curve bsparc;	/* B-spline arc			*/
	struct     IGRbsp_curve *curve;	/* working curve pointer	*/
	struct     GRabsg_hdr absg_hdr; /* struct for allocation	*/

	IGRdouble  poles[21];		/* poles for curve		*/
	IGRdouble  knots[10];		/* knots for curve		*/
	IGRdouble  weights[7];		/* weights for curve		*/
	

	*msg = MSSUCC;			/* initialize to success	*/
	status = TRUE;

/*
 *  Convert the given arc into B-spline representation 
 */
	bsparc.poles = poles;
	bsparc.knots = knots;
	bsparc.weights = weights;
	
	if ((arc->start_angle == 0.0) && 	/* ellipse		*/
	    (arc->sweep_angle == 2.0 * PI))
	{
	  status = MAeltobc(&msg1,arc,&bsparc);
	  if (! status)				/* an error occurred	*/
	  {
	    *msg = MSFAIL;
	    goto wrapup;
	  }
	}
	else					/* arc			*/
	{
	  status = MAartobc(&msg1,arc,&bsparc);
	  if (! status)				/* an error occurred	*/
	  {
	    *msg = MSFAIL;
	    goto wrapup;
	  }
	}
/*
 *  Calculate the number of bytes necessary to hold the B-spline curve
 *  and allocate a buffer for the curve.
 */
	GRbc_size(bsparc.order,bsparc.num_poles,bsparc.rational,0,nbytes);

	absg_hdr.id.objid = *my_id;
	absg_hdr.id.osnum = OM_Gw_current_OS;
	absg_hdr.geometry_size = nbytes;
	absg_hdr.matrix_type = *matrix_type;

	for (i=0; i<16; ++i)
	{
	    absg_hdr.matrix[i] = matrix[i];	
	}

	curve = (struct IGRbsp_curve *) GRabsg_alloc (&msg1,&absg_hdr);

	if (! (1 & msg1))		/* error allocating		*/
	{
	  *msg = MSFAIL;		/* set error message		*/
	  goto wrapup;			/* return with error		*/
	}
	*curve = bsparc;		/* copy curve struct to buffer	*/
	
/*
 *  Partition the given buffer to hold the curve 
 */
	GRbc_partition(curve,curve->order,curve->num_poles,
		curve->rational,0);
/*
 *  Move the poles, knots, and weights into the cache buffer. 
 */
	for (i = 0; i < 3 * bsparc.num_poles; i++)
	{
	  curve->poles[i] = bsparc.poles[i];
	}

	for (i = 0; i < bsparc.num_knots; i++)
	{
	  curve->knots[i] = bsparc.knots[i];
	}

	for (i = 0; i < bsparc.num_poles; i++)
	{
	  curve->weights[i] = bsparc.weights[i];
	}

	*absgptr = (IGRchar *) curve;	/* set return pointer		*/

wrapup:

	return (status);
}
