/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlinear
     METHOD NAME: GRgetsfsize

     Abstract: 
		This method returns the array sizes needed for the
	subform information for reviewing an element.

-----
%SC%    

     GRgetsfsize(msg,mat_type,matrix,form_dimension,label_dimension)

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

     *form_dimension IGRlong	the dimension of the subform array
     *label_dimension IGRlong	the dimension of the gadget label
				array.

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
	
	MAS	03/23/88 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "revieweledef.h"

method GRgetsfsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	IGRlong *form_dimension, *label_dimension)
{
  IGRlong OMmsg;			/* OM return code	      */

  IGRint action = 0;
  struct IGRpolyline py;

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  OMmsg = om$send ( 
	msg = message GRlinear.GRgetpolyline
	    (msg,mat_type,matrix,&action, &py ),
       	targetid = my_id);

  if( *msg & 1 )
  {
   	*form_dimension = GRLINEAR_FORM_FIXED_SIZE + py.num_points; 

	*label_dimension = 2;
  }
  else
  {
      OMmsg = OM_E_ABORT;
  }

  return( OMmsg );
}
end implementation GRlinear;
