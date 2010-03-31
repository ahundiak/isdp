/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME EMallocsf
 
     Abstract: 
       
        The motivation for this function was to have an alternate call
     list for allocating a surface (as opposed to the call list on
     the function BSallocsf). This function accepts the number of poles
     and the number of knots as opposed to the number of poles and the
     order.

-----
%SC%

     EMallocsf (u_num_knots, v_num_knots, u_num_poles, v_num_poles,
                rational, num_boundaries, srf, msg);

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
        SCW 02/13/9  : Changed emsmacros inclusion to emsmacros_c

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
#include "emserr.h"

void EMallocsf (u_num_knots, v_num_knots, u_num_poles, v_num_poles,
                rational, num_boundaries, srf, msg)
IGRlong u_num_knots, v_num_knots;
IGRlong u_num_poles, v_num_poles;
IGRboolean rational;
IGRshort num_boundaries;
struct IGRbsp_surface **srf;
IGRlong *msg;
{
  *msg = MSSUCC;

  *srf = (struct IGRbsp_surface *) malloc (sizeof (struct IGRbsp_surface));
  EMerr_hndlr (*srf == NULL, *msg, MSNOMEM, ret_end);

  (*srf)->poles = (IGRdouble *) malloc (u_num_poles * v_num_poles *
                   sizeof (IGRdouble) * 3);
  EMerr_hndlr ((*srf)->poles == NULL, *msg, MSNOMEM, ret_end);

  (*srf)->u_knots = (IGRdouble *) malloc (u_num_knots * sizeof (IGRdouble));
  EMerr_hndlr ((*srf)->u_knots == NULL, *msg, MSNOMEM, ret_end);

  (*srf)->v_knots = (IGRdouble *) malloc (v_num_knots * sizeof (IGRdouble));
  EMerr_hndlr ((*srf)->v_knots == NULL, *msg, MSNOMEM, ret_end);

  if (rational)
    {
    (*srf)->weights = (IGRdouble *) malloc (u_num_poles * v_num_poles *
                       sizeof (IGRdouble));
    EMerr_hndlr ((*srf)->weights == NULL, *msg, MSNOMEM, ret_end);
    }

  /*
   * Ignore boundaries for now.
   */

ret_end:;
}
