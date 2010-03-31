
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <FI.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "dpstruct.h"
#include "exmacros.h"
#include "godef.h"

#include "hsurferrpriv.h"
#include "hsurf.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "HSlvhl.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSplot.h"

%safe
#include "HSpr_lvhl.h"
%endsafe
 
from GRgraphics import GRcopy;
from GRvg       import GRchglevel;

/*---HSlvhl_copy_text--------------------------------------------------------------*/

/*
 * DESCRIPTION
 *    This function copies a text object to the text output level in
 *    the master file.
 */

#if defined(__STDC__) || defined(__cplusplus)
	void HSlvhl_copy_text( OM_S_OBJID text_id,
				  OMuword text_os,
				IGRdouble *matrix,
				 IGRshort matrix_type,
			  struct GRmd_env *master_env )
#else
	void HSlvhl_copy_text( text_id, text_os, matrix, matrix_type, master_env )
	
	OM_S_OBJID	text_id;
	OMuword		text_os;
	IGRdouble	*matrix;
	IGRshort	matrix_type;
	struct GRmd_env	*master_env;
#endif

	{
	IGRlong		sts, msg;
	GRobjid		new_id;   
	struct GRmd_env	text_env;

	text_env.md_id.osnum = text_os;
	ex$get_modid( mod_osnum = text_os, mod_id = &text_env.md_id.objid );

	text_env.md_env.matrix_type = matrix_type;
	memcpy( text_env.md_env.matrix, matrix, sizeof(IGRdouble)*16 );

	sts = om$send( msg = message GRgraphics.GRcopy( 
					&msg, 
					&text_env, 
					master_env, 
					&new_id ),
					
		  targetid = text_id, 
		  targetos = text_os, 
		  senderid = NULL_OBJID );

	OM_ERRCHK( sts, "HSlvhl_copy_text: GRgraphics.GRcopy send failed" );
	MSG_ERRCHK( msg, "HSlvhl_copy_text: GRgraphics.GRcopy failed" );

	sts = om$send( msg = message GRvg.GRchglevel( 
					&msg, 
					(IGRshort *)&HSlvhl.text_layer ),
		  targetid = new_id, 
		  targetos = master_env->md_id.osnum, 
		  senderid = NULL_OBJID );

	OM_ERRCHK( sts, "HSlvhl_copy_text: GRvg.GRchglevel send failed" );
	MSG_ERRCHK( msg, "HSlvhl_copy_text: GRvg.GRchglevel failed" );
	}

end implementation Root;

