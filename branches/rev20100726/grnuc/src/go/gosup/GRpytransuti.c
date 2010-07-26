/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "msdef.h"
#include "madef.h"

extern    IGRboolean    MAplpytobc();
extern    IGRboolean    MAoptsxform();

IGRboolean GRpytransutil(msg,mx_type,matrix,num_points,in_points,
			 properties,out_points,curve)

IGRlong 	*msg; 			/* return message		*/
IGRshort 	*mx_type; 		/* matrix type			*/
IGRmatrix 	matrix;			/* environment matrix		*/
IGRlong 	*num_points; 		/* number of poles		*/
IGRdouble	*in_points;		/* input points			*/
unsigned short	*properties;		/* properties			*/
IGRdouble	*out_points;		/* output points		*/
struct IGRbsp_curve *curve;		/* output curve			*/

{
	IGRlong	msg1;			/* local message		*/

	struct IGRpolyline py;		/* polyline structure		*/


	*msg = MSSUCC;			/* initialize to success	*/

	py.num_points = *num_points;

	if (*mx_type != MAIDMX)
	{
	  if (! MAoptsxform(&msg1,num_points,mx_type,matrix,
			       in_points,out_points))
	  {				/* an error occurred		*/
	    *msg = MSFAIL;		/* set error message		*/
	  }
	  else
	  {
	    py.points = out_points;
	  } 
	}
	else
	{
	  py.points = in_points;
	}

	if (*msg == MSSUCC)
	{
	  if (MAplpytobc(&msg1,&py,curve))
	  {
	    curve->planar = *properties & GRIS_PLANAR;
	  }
	  else
	  {
	    *msg = MSFAIL;
	  }
	}

	return (*msg == MSSUCC);

}

