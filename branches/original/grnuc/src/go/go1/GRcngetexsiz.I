/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRgetexsize

     Abstract: This method returns the size in bytes of the internal
	      format (B-spline curve) of the extended geometry of the 
	      conic object.

-----
%SC%    

     GRgetexsize(msg,mat_type,matrix,ex_size)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     mat_type	  IGRshort	 type of matrix
     matrix 	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful

     ex_size	  IGRlong	 size of extended geometry in bytes.
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

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
	
	RDH     05/01/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method calls a macro to determine the size of a rational 
B-spline curve of order 3 with 7 poles and no boundaries.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"

method GRgetexsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRlong *ex_size)

{
  IGRlong	OMmsg;

/*
 * initialize return codes
 */

  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;


  GRbc_size(3,7,TRUE,0,*ex_size);

	

  return( OM_S_SUCCESS );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;
