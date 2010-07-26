/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRvg
     METHOD NAME: GRvggetexgeom

     Abstract: This method gets the extended abstract geometry of
	      the object.

-----
%SC%    

     GRvggetexgeom(msg,mat_type,matrix,geometry)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure due storage
				 (cache) allocation.

     *geometry	  IGRchar	 pointer to place to put extended
				 geometry. Storage must already be
				 allocated.     
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	
     Methods:
	     GRvggetgeom
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	RDH     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method simply sends a message to the object to get its
geometry.

----*/
/*EH*/

class implementation GRvg;
#include "grimport.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetexgeom(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		   IGRchar *geometry)
{
  IGRlong OMmsg;

  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom(msg,mat_type, 
			matrix,geometry),
                  senderid = my_id,
                  targetid = my_id);

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRvg;
