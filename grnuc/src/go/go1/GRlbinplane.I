/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlbsys

     METHOD NAME:	GRinplane

     Abstract: 	This method determines the relationship between a
		local bounded system and a plane.  This relation-
		ship indicates whether or not the system lies in
		the plane.
	
-----
%SC%    

     GRinplane(msg,matrix_type,matrix,plane,tolerance,rel)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *plane	   IGRplane	  input plane 
     *tolerance	   IGRdouble	  accuracy required to determine if 
				  the lbsys lies in the plane
				  (allowable distance from plane)

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *rel	   IGRshort	 value representing the relation
				 between the lbsys and plane--
				    +1 - lbsys in plane
				    -1 - lbsys not in plane

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAlbinpl

     Methods:	
		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	SDG     05/12/86 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method utilizes a math function (MAlbinpl) that will 
	determine the relationship between the local bounded system 
	and plane.

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAlbinpl();

method GRinplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct IGRplane *plane; IGRdouble *tolerance; 
		IGRshort *rel)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local return code		*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	struct IGRlbsys *lbsys;		/* pointer to lbsys		*/

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

	if (! (1 & MAlbinpl(&msg1,lbsys,plane,tolerance,rel)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;	
	}

	

wrapup:
	
	return(OMmsg);

}

end implementation GRlbsys;
