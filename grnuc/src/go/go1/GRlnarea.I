/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlinear

     METHOD NAME: GRarea

     Abstract: 	This method determines the area of a closed, planar
		linear object.
		
-----
%SC%    

	GRarea(msg, mat_type, matrix, area)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type     IGRshort	  type of input matrix
     matrix	   IGRmatrix	  local to world transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				   - MSSUCC if successful     
				   - MSFAIL (severe) if other error
     *area	  IGRdouble	 the area of the object

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   MApyarea
		GRgetabsg

     Methods:   none.

-----
%RL%

     RELATIONS REFERENCED:	None.

-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	KMO     02/09/87 : Design date.
	KMO	03/26/87 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method gets the B-spline representation of the
 	object and determines if the object is closed and
	planar.  If so, then a polyline is formed and the
	area of the polyline is calculated.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MApyarea();

method  GRarea( IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	        IGRdouble *area )
{
	IGRlong		        OMmsg;	/*  OM return status		*/
	IGRchar		        *ptr;	/*  abstract geometry pointer	*/
	struct IGRbsp_curve	*curve; /*  internal repres. pointer	*/
	struct IGRpolyline	polyline; /* internal polyline		*/
	IGRlong			retmsg;	/*  internal return status	*/

/*
 *  initialize completion codes
 */
	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

/*
 *  get the internal representation of the object
 */

	GRgetabsg ( &retmsg, mat_type, matrix, &ptr, i );

	if ( ! (1 & retmsg))
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
	
	curve = (struct IGRbsp_curve *)ptr;

/*
 *  if the object is planar and closed, calculate the area
 */

	if ( curve->planar && curve->phy_closed )
	{
	
	    polyline.num_points = curve->num_poles;
	    polyline.points = curve->poles;

	    if (! MApyarea ( msg, &polyline, area ))
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }
	}
	else
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}

wrapup:
	

	return (OMmsg);

}

end implementation GRlinear;
