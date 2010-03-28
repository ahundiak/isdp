/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlbsys
     METHOD NAME: GRgetsize

     Abstract: This method returns the size in bytes of the
	       geometry of the object.

-----
%SC%    

     GRgetsize(msg,mat_type,matrix,size)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 type of matrix
     matrix 	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure due to
				 storage allocation.

     *size	  IGRlong	 size of geometry in bytes.
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
	
	MAS     11/13/87 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method returns the size of the local bounded system geometry.
----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRlong *size)

{

  *msg = MSSUCC;

  *size = sizeof(struct IGRlbsys);

	

  return( OM_S_SUCCESS );
}

end implementation GRlbsys;
