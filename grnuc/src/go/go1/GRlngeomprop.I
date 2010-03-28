/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlinear
     METHOD NAME: GRgeomprops

     Abstract: This method returns the geometry properties of an
  	       object.

-----
%SC%    

    GRgeomprops(msg,mat_type,matrix,properties)

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
					MSFAIL - failure to get 
				 abstract geometry.

     *properties  GRprops	 geometric properties.

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     none.
     Methods:
	     GRgenabsg
	     
-----
%RL%

     RELATIONS REFERENCED:  none.
			  
-----
%NB%

     NOTES:  none.
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     04/05/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the abstract data of the object to find set the
 properties for output. It also assigns the type to be GRLN.

----*/
/*EH*/

class implementation GRlinear;


#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgeomprops(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
		   struct GRprops *properties)

{
  struct IGRbsp_curve *bc;		/* abstract geometry pointer  */
  IGRchar *ptr;				/* abstract geometry pointer  */
  IGRlong OMmsg;			/* OM return code	      */

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  GRgetabsg(msg,mat_type,matrix,&ptr,i);

  if( *msg & 1 )
    {
      bc = (struct IGRbsp_curve *)ptr;

      properties->type         = GRCURVE;
      properties->subtype      = GRLN;
      properties->closed       = 0;
      properties->phy_closed   = bc->phy_closed;
      properties->is_segmented = 1;
      properties->planar       = bc->planar;
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRlinear;
