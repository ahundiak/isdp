/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME EMfreesf
 
     Abstract: 
         
       This function is to be used in conjunction with the EMallocsf
     function. It frees the memory allocated by EMallocsf.

-----
%SC%

     stat_func = EMfreesf (msg, srf);

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
                         
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
        SS  10/01/86 : Design date
        SCW 02/13/97 : Changed emsmacros inclusion to emsmacros_c

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------



----*/
/*EH*/



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
#include "msdef.h"
#include "emsdef.h"
#include <math.h>
#include "emsmacros_c.h"

IGRboolean EMfreesf (msg, srf)
IGRlong *msg;
struct IGRbsp_surface *srf;
{
  *msg = MSSUCC;

  free (srf->poles);
  free (srf->u_knots);
  free (srf->v_knots);
  if (srf->rational)
    free (srf->weights);
  free (srf);

  /*
   * Surface boundaries have been ignored
   * in the allocating function. Hence,
   * ignored here too.
   */

  return (TRUE);
}
