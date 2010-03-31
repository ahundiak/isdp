 /*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include "wl.h"

#include "igrtypedef.h"
#include "OMminimum.h"

#include "hsmacros.h"
#include "hsdef.h"
#include "hsmachine.h"
#include "hsmacdef.h"
#include "hsmacros.h"

#include "HStl_global.h"

#include "igewindef.h"
#include "igewinmacros.h"

#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "igrdp.h"

#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "dpgraphics.h"
#include "hslight.h"
#include "hsurf.h"

#ifdef X11
struct vlt_slot
  {
   unsigned long pixel;
   unsigned short red;
   unsigned short green;
   unsigned short blue;
   char           flags;
   char           pads;
   };
#endif

#include "HSpr_dpb_imp.h"

/*---------------------------
 *  for function
 *     build_phys_tbl
 */
 
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"
#include "HSpr_co_func.h"

/*--------------------------*/


/*--- HSgetMachineInfo ---------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSgetMachineInfo( IGRint *NumPlanes,
			       IGRint *TermType,
			       IGRint *Max_C_S )
#else
	void HSgetMachineInfo( NumPlanes, TermType, Max_C_S )

	IGRint *NumPlanes, *TermType, *Max_C_S;
#endif

	{
	IGRint          vs_no;
	IGRint          temp_num_planes;
#ifndef X11
	struct scr_info screen_info[MAX_SCREENS];

	/* base everything on the RIGHT VIRTUAL screen */
	ige$inq_term_info( vs_no = &vs_no );

	Inq_screen_info( screen_info );

	if ( (screen_info[vs_no].vsi_flags & VSI_TRC_ABILITY) &&
	     (tiling_parms.processing_mode & HS_PMODE_USE_EDGE2) )
	   {
	   if (TermType) *TermType = EDGEII_TRC;
	   if (NumPlanes) *NumPlanes = EDGEII_TRC_NUM_PLANES;
	   if (Max_C_S) *Max_C_S = EDGEII_TRC_COLOR_SLOTS;
	   }
	else
	   {
#endif
	   ige$inq_term_info( num_of_planes = &temp_num_planes );

	   if (NumPlanes) 
		*NumPlanes = temp_num_planes;

	   switch ( temp_num_planes )
	      {
	      case GS_NUM_PLANES:
	         if (TermType) *TermType = GS;
	         if (Max_C_S) *Max_C_S = GS_COLOR_SLOTS;
	         break;

	      case GXGZ_NUM_PLANES:
	         if (TermType) *TermType = GXGZ;
	         if (Max_C_S) *Max_C_S = GXGZ_COLOR_SLOTS;
	         break;

	      case TURQ_NUM_PLANES:
	         if (TermType) *TermType = TURQ;
	         if (Max_C_S) *Max_C_S = TURQ_COLOR_SLOTS;
	         break;
	      }

#ifndef X11
	   }
#endif

} /* HSgetMachineInfo */

