
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation NCVdpb;

/*
!!!!!!!!!!!!!!!!!!!!! DELETE THIS CLASS FOR HSURF 2.0 !!!!!!!!!!!!!

DESCRIPTION
	Implementation of the NC Verification parameter block.

HISTORY
	09/20/88	Created.		C. M. Jablonski
	04/11/91	Apogee compliance	R. Druzynski
*/

#include <stdio.h>
#include <stdlib.h>

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "exmacros.h"

#include "hsncdef.h"
#include "hsncmacros.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "hslight.h"
#include "hsurf.h"

%safe
#include "HSpr_dpb_imp.h"
%endsafe

/*--- wake_up ----------------------------------------------------------*/

method wake_up ()

/* 
 * DESCRIPTION:
 * Creates HSNCdpb, copies all relevant information into it, and
 * then deletes self.
 *
 * HISTORY:
 *		08/11/88	Created			C. M. Jablonski
 */

	{
	IGRlong		       sts;
	OM_S_OBJID	       mod_id;
	OMuword		       mod_osnum;
	OM_S_OBJID	       super_id;
	OMuword		       super_osnum;

	sts = ex$get_cur_mod( osnum = &mod_osnum, id = &mod_id );

	/* Create an HSNCdpb object for this module */
	sts = ex$get_super( mod_id      = mod_id,
	                    mod_osnum   = mod_osnum,
	                    super_name  = "HSNCdpb",
	                    create      = 1,
	                    super_class = "HSNCdpb",
	                    super_id    = &super_id,
	                    super_osnum = &super_osnum );

	/* Copy the display mode from the current NCVdpb to the new HSNCdpb */
	if (me->mode_flag & 0x0010)
		hsnc$put_verification_parameters( display_mode = HSNC_SIMULATION );
	else if (me->mode_flag & 0x0020)
		hsnc$put_verification_parameters( display_mode = HSNC_SWVOL_TOOL );
	else
		hsnc$put_verification_parameters( display_mode = HSNC_SWVOL );

	/* Copy the simulation speed from the current NCVdpb to the new HSNCdpb */
	hsnc$put_verification_parameters( simulation_speed = ((IGRint)(me->mode_flag & 0x000f) + 1) );

	/* Copy the shading style from the current NCVdpb to the new HSNCdpb */
	if (me->mode_flag & 0x0040)
		hsnc$put_verification_parameters( shading_style = HSNC_SMOOTH_SHADED );
	else
		hsnc$put_verification_parameters( shading_style = HSNC_CONSTANT_SHADED );

	/* Have the NCVdpb delete itself */
	om$send( msg      = message Root.delete( 0 ),
		 targetid = my_id );

	return(OM_S_SUCCESS);
	}


end implementation NCVdpb;

