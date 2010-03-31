/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRbspline
     METHOD NAME:  EMgetpoles

     Abstract: 

	This method retrieves poles from simple B-spline curve object.
     That is, the curve is not an extended curve.

-----
%SC%    



-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *mat_type IGRshort         defined constant matrix type.
      *mat      IGRmatrix        to current module coords conversion matrix.
      *start	IGRlong		 starting index of the pole required
      *needed   IGRlong		 number of points needed
      bufsize   IGRlong		 buffer size in bytes

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
				    - MSSUCC if successful
      				    - MSFAIL (severe) if failure
      *sent	  IGRlong	number of points sent
      *points	  IGRdouble         points
      *is_reg     IGRboolean    TRUE if the matrix of points returned is
                                    regular. Always TRUE in the case of
                                    curve poles.
                                FALSE if not.
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  
		GRgetabsg
     Methods:
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

#define debug 0

method EMgetpoles(IGRlong 		*msg;
		  IGRshort 		*mat_type;
                  IGRmatrix		mat;
		  IGRlong		*start;
		  IGRlong		*needed;
	  	  IGRdouble		*points;
		  IGRlong		bufsize;
		  IGRlong		*sent;
                  IGRboolean            *is_reg)
{
    IGRlong             	status, i, j, k, f_r_o_m, t_o;
    IGRchar			*char_ptr;
    struct IGRbsp_curve		*curve;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;
    *is_reg = TRUE;

    GRgetabsg(msg, mat_type, mat, &char_ptr, i);
    if(*msg == MSSUCC)status = OM_S_SUCCESS;
 
    curve = (struct IGRbsp_curve*)char_ptr;
    
    if(curve->num_poles < *start)
     { *sent = 0; return(OM_S_SUCCESS);}

    else if( (curve->num_poles - *start) < *needed )
     { *sent = curve->num_poles - *start;}

    else
     { *sent = *needed;}

    f_r_o_m = *start;
    t_o   = *start + *sent;
    j    = 0;
    for (i=3*f_r_o_m; i<3*t_o; i++) points[j++] = curve->poles[i];

    if(curve->rational)	/* Unweight the poles */
     {
       j = 0;
       for(i=f_r_o_m; i<t_o; i++)
	{
	  points[j++] /= curve->weights[i];
	  points[j++] /= curve->weights[i];
	  points[j++] /= curve->weights[i];
	}
     }

    return(status);
}

end implementation GRbspline;
