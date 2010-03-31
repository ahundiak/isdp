/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD

     CLASS  NAME:  GRbspline
     METHOD NAME:  EMgetbcdef

     Abstract: 
	This method returns the bspline template.
-----
%SC%    

     message GRbspline.EMgetbcdef (&msg, &crv)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
       *crv       struct	 curve pointer to the template
                   IGRbsp_curve
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  

     Methods:  GRgetabsg

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

-----
%CH%

     CHANGE HISTORY:
	
	gk	6/18/86 : design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRbspline;

#include "EMS.h"
#include <stdio.h>

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
/*#include "grdef.h"*/
/*#include "mapriv.h"*/
#include "madef.h"
#include "OMmacros.h"

method EMgetbcdef(IGRlong 		*msg;
		 struct IGRbsp_curve	*crv)
{
    IGRshort			matrix_type;
    IGRlong			msg_loc;
    IGRmatrix			some_matrix;
    IGRchar			*loc_char_ptr;
    IGRlong			i;
    void                        EMidmatrix();

    *msg = MSSUCC;
    EMidmatrix (&msg_loc, &matrix_type, some_matrix);

    GRgetabsg(msg, &matrix_type, some_matrix, &loc_char_ptr, i);

    i = sizeof(struct IGRbsp_curve);
    OM_BLOCK_MOVE(loc_char_ptr, crv, i);

    crv->poles   = NULL;
    crv->knots   = NULL;

    crv->bdrys   = NULL;
    crv->weights = NULL;

    return(OM_S_SUCCESS);
}

end implementation GRbspline;

