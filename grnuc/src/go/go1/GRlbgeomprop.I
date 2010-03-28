/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRlbsys
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

class implementation GRlbsys;


#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgeomprops(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
		   struct GRprops *properties)

{
    struct IGRlbsys *lbsys;		/* local bounded system	      */
    IGRchar *ptr;			/* abstract geometry pointer  */
    IGRlong OMmsg;			/* OM return code	      */

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    GRgetabsg(msg,mat_type,matrix,&ptr,i);

    if( *msg & 1 )
    {
    	lbsys = (struct IGRlbsys *)ptr;

    	properties->type         = GRLBSYS;
    	properties->subtype      = GRLBSYS;
    	properties->closed       = 0;
    	properties->phy_closed   = 1;
    	properties->is_segmented = 1;
    	if (lbsys->diag_pt1[2] == lbsys->diag_pt2[2])
    	{
	    properties->planar      = 1;
    	}
    	else
    	{
      	    properties->planar      = 0;
    	}	
    }
    else
    {
    	OMmsg = OM_E_ABORT;
    }

    

    return( OMmsg );

}

end implementation GRlbsys;
