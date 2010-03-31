/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
		
 	This method extracts the 4 corner poles of a surface. It gets the
     geomerty of the surface in the abstract buffer and calls -
	 EMsfget4pols() sending the pointer to this geometry as input.


NOTES
=====
	
   	If caller has the geomerty of the surface then call EMsfget4pols()
     directly.


ARGUMENTS
=========
	
    VARIABLE				MODE	DESCRIPTION
    --------                ----	-----------
   	EMmsg					Output	Method return status.
									1)EMS_S_Success if sucess.
									2)EMS_E_SurfaceError if GRgetabsg()
									  fails.
                        			3)EMS_E_OMError if call to 
									 EMsfget4pols() does not go through.

   	poles_buff				Output		4 corner poles of the surface.

	grmdenv_info			Input		Module info.


HISTORY
=======
	
	SAM		20-Oct-87	Creation.
        NP              24-Aug-92       Modified for ANSI compliance. Typecast
					"&surf" in GRgetabsg call.
*/

class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
/* includes for GRgetabsg macro */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef gocmacros_include
# include "gocmacros.h"
# endif

/* end of GRgetabsg includes    */

#include <stdio.h>
#include "emsmacros.h"
#include "OMmacros.h"

method EMss4poles(IGRlong *EMmsg; IGRpoint *poles_buff;
				  struct GRmdenv_info *grmdenv_info)
{
IGRlong mthd_stat;
IGRlong   OM_stat, num_bytes, EMgetsf4pols(), our_dumdum;
struct IGRbsp_surface *surf;

/*
 * Initialize
 */
 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;


 GRgetabsg (&mthd_stat, &(grmdenv_info-> matrix_type), 
			grmdenv_info->matrix, (IGRchar **)&surf, our_dumdum);
  EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

/*

 OM_stat = om$send(msg = message GRvg.GRgetsize (
					&mthd_stat,
					&(grmdenv_info->matrix_type),
					grmdenv_info->matrix,
					&num_bytes),
				  targetid = my_id);
 EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_InvalidArg, wrapup);

 surf = (struct IGRbsp_surface *) om$malloc (size = num_bytes);
 EMerr_hndlr(!surf, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 OM_stat = om$send (msg = message GRvg.GRgetgeom (
					 &mthd_stat,  
					 &(grmdenv_info->matrix_type),
					 grmdenv_info->matrix,
					 ( IGRchar *) surf),
					targetid = my_id);
 EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_InvalidArg, wrapup);
 */


 OM_stat = EMgetsf4pols(surf, poles_buff);
 EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 wrapup:
	if(surf) GRabsg_del(surf);
    return(OM_stat);
}
end implementation EMSsubbs;

