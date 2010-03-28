/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRgetsize

     Abstract: This method returns the size in bytes of the internal
	       format (B-spline curve) of the geometry of the object.

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
	
	RDH     03/26/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method gets the B-spline curve geometry of the object and 
then calls GRbc_size to find the size.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetsize(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRlong *size)

{
  struct IGRbsp_curve *bc;		/* pointer for geometry	      */

  IGRchar *ptr;
  IGRlong OMmsg;			/* OM return code	      */



  *msg = MSSUCC;

  OMmsg = OM_S_SUCCESS;

  GRgetabsg(msg,mat_type,matrix,&ptr,i);
 
  if( *msg & 1 )
    {
      bc = (struct IGRbsp_curve *) ptr;

      GRbc_size(bc->order,bc->num_poles,bc->rational,bc->num_boundaries,
            *size);
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRbspline;
