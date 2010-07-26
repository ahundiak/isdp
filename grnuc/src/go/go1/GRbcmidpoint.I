/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRbspline

     METHOD NAME:  GRmidpoint

     Abstract:   This routine finds the midpoint of
		 the given graphics object.  If the
		 object is segmented, then the midpoint
		 of the selected segment is returned.
-----
%SC%    

     GRmidpoint(msg,matrix_type,matrix,ref_parms,midpoint)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of transformation matrix
     matrix	   IGRmatrix	  input transformation matrix
     *ref_parms	   GRparms	  parameters identifying segment

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     midpoint	  IGRpoint	 desired midpoint
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	MAbcmidpt

     Methods:  
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  
-----
%CH%

     CHANGE HISTORY:
	
	KMO     04/09/86 : Design date.
	KMO	04/09/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine will determine the midpoint of the input
	graphics object.  If the object is segmented and the
	desired segment is identified via the ref_parms, then
	the midpoint of the segment will be found.
----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcmidpt();

method GRmidpoint(IGRlong *msg; IGRshort *matrix_type;
	    	  IGRmatrix matrix; struct GRparms *ref_parms;
		  IGRpoint midpoint)

{
    IGRlong 		status;		/* return status for method	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/

/*
 *  initialize variables
 */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

/*
 *  get abstract geometry of object
 */

    GRgetabsg(msg,matrix_type,matrix,&buffer,i);

    if (1 & *msg)
    {
        /*
         *  find the midpoint of the 
         *  graphics object
         */

        if (! MAbcmidpt(msg,buffer,midpoint))
	{
	    status = OM_E_ABORT;
	    *msg = MSFAIL;
	}
	
    }
    else
    {
	status = OM_E_ABORT;
	*msg = MSFAIL;
    }


	
   
	return(status);

}

end implementation GRbspline;
