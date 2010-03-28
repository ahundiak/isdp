/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlbsys

     METHOD NAME:	GRdetplane

     Abstract: 	This method determines a plane from a graphics
		object.
	
-----
%SC%    

     GRdetplane(msg,matrix_type,matrix,plane)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MASDGENRAT if all points are
				      collinear
				    - MANONPLANAR if plane cannot be
				      found which contains all pts
				    - MSFAIL (severe) if failure
     *plane	   IGRplane	  plane 

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MApyfrlb
		MAdetplane

     Methods:	

		GRgenabsg		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method utilizes two math functions, the first one
	forms a polyline from the local bounded system (MApyfrlb)
	and the second determines the plane of that polyline
	(MAdetplane).

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MApyfrlb();
extern    IGRboolean    MAdetplane();

method GRdetplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  struct IGRplane *plane)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	struct IGRlbsys *lbsys;		/* pointer to local bounded sys	*/
	struct IGRpolyline py;		/* internal polyline		*/
        IGRdouble points[30];
	IGRdouble tol = 0.5;		/* plane tolerance		*/

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	
	GRgetabsg(&msg1,matrix_type,matrix,&absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	lbsys = (struct IGRlbsys *)absgptr;

	py.points = points;

	if (! (1 & MApyfrlb(&msg1,lbsys,&py)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	if (! (1 & MAdetplane(msg,&py.points[0],&py.num_points,&tol,plane)))
	{
	   OMmsg = OM_E_ABORT;
	}

	

wrapup:

	return(OMmsg);

}

end implementation GRlbsys;
