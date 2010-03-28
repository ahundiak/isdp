/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRcurve
     METHOD NAME:  GRendpoint

     Abstract: 
		This method determines the endpoint of the 
		object which lies closest to the given
		boreline.
-----
%SC%    

     GRendpoint(msg,matrix_type,matrix,boreline,endpoint)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type IGRshort	 type of input transformation matrix
     matrix	  IGRmatrix	 input transformation matrix
     *boreline	  struct IGRline line referencing closest endpoint

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     endpoint	  IGRpoint	 endpoint of object nearest boreline
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	MAptlnproj
		MA2pt2dis

     Methods:	GRendpts
-----
%RL%

     RELATIONS REFERENCED:  none.
				
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
	
	KMO     03/13/86 : Design date.
	KMO	04/09/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine finds the both endpoints of the graphic
	object.  The endpoint closest to the input boreline
	is returned as the desired endpoint.
----*/
/*EH*/

class implementation GRcurve;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRendpoint(IGRlong *msg; IGRshort *matrix_type;
		  IGRmatrix matrix; struct IGRline *boreline;
		  IGRpoint endpoint)

{
    IGRlong		status;		/* return status for method 	*/
    IGRpoint		startpt;	/* start point of object	*/
    IGRpoint		endpt;		/* end point of object		*/
    IGRlong		mamsg;		/* message from math routine	*/
    IGRdouble		t;		/* storage for t-parameter	*/
    IGRshort		i;		/* loop counter			*/
    IGRpoint		proj_pt;	/* projected point on boreline	*/
    IGRdouble		distance1;	/* distance between start point	*/
					/* and boreline			*/
    IGRdouble		distance2;	/* distance between end point	*/
					/* and boreline			*/

/*
 *  initialize return variables
 */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

/*
 *  determine both endpoints of the
 *  graphic object
 */

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRcurve.GRendpts(msg,    
				matrix_type,matrix,startpt,    
				endpt),
                     senderid = my_id,
                     targetid = my_id);

    if (1 & status & *msg )
    {
	/*
	 *  project start point onto
	 *  given boreline, and determine
	 *  distance between the start
	 *  point and the projected point
	 */

	MAptlnproj(&mamsg,startpt,boreline,proj_pt,&t);

	MA2pt2dis(&mamsg,startpt,proj_pt,&distance1);

	/*
	 *  project end point onto
	 *  given boreline, and determine
	 *  distance between the end
	 *  point and the projected point
 	 */

	MAptlnproj(&mamsg,endpt,boreline,proj_pt,&t);

	MA2pt2dis(&mamsg,endpt,proj_pt,&distance2);

	/*
	 *  determine which endpoint is closest
	 *  to the given boreline
	 */
	
	if ( distance1 <= distance2 )
	{
	    for ( i=0; i<3; ++i )
	    {
		/*
		 *  return start point as
		 *  the closest endpoint
		 */

		endpoint[i] = startpt[i];
	    }
        }
	else
	{
	    for ( i=0; i<3; ++i )
	    {
		/*
		 *  return end point as
		 *  the closest endpoint
		 */

		endpoint[i] = endpt[i];
	    }
    	}
    }

	

	return(status);
}

end implementation GRcurve;
