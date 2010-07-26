/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRconic	
     METHOD NAME:   GRgenabsg

     Abstract: 
		This method generates the abstract data representation 
		for a conic object and places the data in the standard 
		buffer (abstract data cache).  

-----
%SC%    

     GRgenabsg(msg,matrix_type,matrix,absgptr)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type IGRshort	 type of the transformation matrix
     matrix	  IGRmatrix	 local-to-world transformation matrix

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

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:


     Methods:			None.

-----
%RL%

     RELATIONS REFERENCED:	None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	REJ	01/28/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method converts the conic object into a B-spline 
	representation and places it in the cache.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    GRargenabsg();

method GRgenabsg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		 IGRchar **absgptr)
{
	IGRlong	   OMmsg;		/* OM return status		*/

	struct IGRarc arc;		/* working arc			*/


	*msg = MSSUCC;			/* initialize return codes	*/
	OMmsg = OM_S_SUCCESS;

	OMmsg = om$send(msg = message GRconic.GRgetarc(
		msg,matrix_type,matrix,&arc),
	    targetid = my_id);

	if (1 & OMmsg & *msg)
	{		
  					/* put the geometry in the cache*/
	    if (!GRargenabsg(msg,matrix_type,matrix,&my_id,&arc,absgptr))
	    {
		OMmsg = OM_E_ABORT;
		*msg = MSFAIL;
	    }
	}

	

	return (OMmsg);
}

end implementation GRconic;
