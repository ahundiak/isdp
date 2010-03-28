/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
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
	
	MAS	03/23/88    Design date.
        jhw     01/313/90   Change from a geom check to class check.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "revieweledef.h"
#include "mapriv.h"

method GRgetsfsize( IGRlong     *msg; 
                    IGRshort    *mat_type; 
                    IGRmatrix   matrix;
	            IGRlong     *form_dimension, 
                                *label_dimension )
{
    IGRlong OMmsg;			/* OM return code	      */
    OMuword classid;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$get_classid ( objid = my_id,
                             p_classid = &classid );

    if (OMmsg & 1)
    {
        if ( om$is_ancestry_valid(subclassid = classid,
                                  superclassname = "GRellarc" ) == OM_S_SUCCESS )
        {
	    *form_dimension = GRELLARC_FORM_FIXED_SIZE;
        }
        else if ( om$is_ancestry_valid(subclassid = classid,
                                       superclassname = "GRcirarc") == OM_S_SUCCESS )
        {
	    *form_dimension = GRCIRARC_FORM_FIXED_SIZE;
        }
        else if ( om$is_ancestry_valid(subclassid = classid,
                                       superclassname = "GRellipse") == OM_S_SUCCESS )
        {
	    *form_dimension = GRELLIPSE_FORM_FIXED_SIZE;
        }
        else if ( om$is_ancestry_valid(subclassid = classid,
                                       superclassname = "GRcircle") == OM_S_SUCCESS )
        {
	    *form_dimension = GRCIRCLE_FORM_FIXED_SIZE;
        }
        else 
        {
            *msg = MSFAIL;
            OMmsg = OM_I_INVANCESTRY;
        }

        *label_dimension = 1;
    }

    return( OMmsg );
}
end implementation GRconic;
