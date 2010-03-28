/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "madef.h"

extern    IGRboolean    MAoptsxform();

IGRboolean GRgentransutil(msg,mx_type,matrix,num_points,in_points,
			  out_points,flag)

IGRlong 	*msg; 			/* return message		*/
IGRshort 	*mx_type; 		/* matrix type			*/
IGRmatrix 	matrix;			/* environment matrix		*/
IGRlong 	*num_points; 		/* number of poles		*/
IGRdouble	*in_points;		/* input points			*/
IGRdouble	*out_points;		/* output points		*/
IGRshort	*flag;			/* out_points not set, use 
					   in_points(matrix is identity)*/
{
	IGRlong msg1;			/* local message		*/


	*msg = MSSUCC;			/* initialize to success	*/


	if (*mx_type != MAIDMX)
	{
	  if (! MAoptsxform(&msg1,num_points,mx_type,matrix,
			       in_points,out_points))
	  {				/* an error occurred		*/
	    *msg = MSFAIL;		/* set error message		*/
	  }
	  *flag = 0;
	}
	else
	{
	  *flag = 1;
	}

	return (*msg == MSSUCC);

}

