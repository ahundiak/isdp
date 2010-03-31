/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRsubbc
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
    dhm     02/22/88 : Added GR_NOTIFY_LISTENERS
    dhm     06/09/88 : Took out GR_INQUIRED notification.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the abstract data of the object to find set the
 properties for output. It also assigns the type to be GRSC.

----*/
/*EH*/

class implementation GRsubbc;

#include "EMS.h"
# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

#include "godef.h"
# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

/*#include "grdef.h"*/
#include "madef.h"

method GRgeomprops(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
		   struct GRprops *properties)

{
  struct IGRbsp_curve *bc;		/* abstract geometry pointer  */
  IGRchar *ptr;				/* abstract geometry pointer  */
  IGRint i;				/* index		      */
  IGRlong OMmsg;			/* OM return code	      */

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  GRgetabsg(msg,mat_type,matrix,&ptr,i);

  if( *msg & 1 )
    {
      bc = (struct IGRbsp_curve *)ptr;

      properties->type         = GRCURVE;
      properties->subtype      = GRSC;
      properties->closed       = 0;
      properties->phy_closed   = bc->phy_closed;
      properties->is_segmented = 0;
      properties->planar       = bc->planar;
    }
  else
    {
      OMmsg = OM_E_ABORT;
    }

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRsubbc;
