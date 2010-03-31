/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/* 
DESCRIPTION
===========
		
 	This function extracts the 4 corner poles of a surface.


NOTES
=====
	
   	This function is also called by a method EMss4poles.I.
	 Call this function if you have the surface geometry.
	 Call the method if you have a surface object.


ARGUMENT
========
	
    VARIABLE					MODE	DESCRIPTION
    --------                    ----    -----------
   	surf						INPUT	Pointer to surface geometry.
	poles_buff					OUTPUT  4 corner poles of the surface.
	

RETURN VALUE
============
		
    OM_stat				EMS_S_Success if sucess
                        EMS_E_SurfaceError if pointer to surface geomerty
                         is null.


HISTORY
=======
	
	SAM	20-Oct-87	Creation.
        SCW     13-Feb-1997     included emsmacros_c.h rather than emsmacros.h
*/

# include "OMminimum.h"
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "OMmacros.h"
# include <math.h>
# include "emsmacros_c.h"
# include "EMSmsgdef.h"


IGRlong EMgetsf4pols(surf, poles_buff)

struct IGRbsp_surface 	*surf;
IGRpoint		*poles_buff;
{
 IGRint			sizept = sizeof(IGRpoint), i, j, index[4];
 
 if(!surf) return(EMS_E_SurfaceError);

 index[3] = 0; 
 index[2] = surf->u_num_poles -1;
 index[1] = surf->u_num_poles * (surf->v_num_poles - 1);
 index[0] = surf->u_num_poles * surf->v_num_poles - 1;

 OM_BLOCK_MOVE(&surf->poles[index[3]], poles_buff, sizept);
 OM_BLOCK_MOVE(&surf->poles[3 * index[2]], &poles_buff[1][0], sizept);
 OM_BLOCK_MOVE(&surf->poles[3 * index[1]], &poles_buff[2][0], sizept);
 OM_BLOCK_MOVE(&surf->poles[3 * index[0]], &poles_buff[3][0], sizept);
 
 if(surf->rational)
 {
  for(i= 0; i<=3; i++)
  {
   for(j = 0; j<=2; j++)
	  { poles_buff[i][j] /= surf->weights[index[i]]; }
  }
 }

  return(EMS_S_Success);
}
