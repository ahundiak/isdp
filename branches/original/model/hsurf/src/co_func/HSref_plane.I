/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

class implementation Root;

#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMtypes.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"

#include "gr.h"

#include "dpdef.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"

#include "EMdtmacros.h"
#include "EMSdatumdef.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

%safe
#include "HSpr_co_func.h"
%endsafe

from EMSdatpln import EMget_pln_info;

/*--- HSsetup_ref_plane_for_window -------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsetup_ref_plane_for_window( OM_S_OBJID win_id,
					      OMuword win_os )
#else
	void HSsetup_ref_plane_for_window( win_id, win_os )

	OM_S_OBJID win_id;
	OMuword    win_os;
#endif

/*
NAME
	HSsetup_ref_plane_for_window

DESCRIPTION
	This function will set up the instance data (i.e., construction
	plane matrix) in an IGEgragad to use the active datum plane.  If
	ref. plane lock is on, it will also set the flags word in the
	IGEgragad to indicate that the construction plane matrix should
	be used.

PARAMETERS
	win_id (IN) - the object id of the IGEgragad
	win_os (IN) - the object space number of the IGEgragad

GLOBALS USED
	none

HISTORY
	02/18/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong         msg;
	IGRint          ii;
	IGRint          ref_plane_lock_mode;
	IGRdouble       xdir[3], ydir[3], zdir[3], origin[3];
	IGRdouble       mx[16];
	IGRint          flags[2];
	IGRlong         num_bytes, error;
	struct GRid     datum_plane;
	struct var_list var_list[3];
  

	ems$get_active_datum_plane( msg = &msg, datpln = &datum_plane );
	if ( datum_plane.objid != NULL_OBJID )
	   {
	   om$send( msg = message EMSdatpln.EMget_pln_info( &msg,
	                                                    NULL,
	                                                    NULL,
	                                                    xdir,
	                                                    ydir,
	                                                    zdir,
	                                                    origin,
	                                                    NULL ),
	            targetid = datum_plane.objid,
	            targetos = datum_plane.osnum,
	            senderid = NULL_OBJID );

	   /* build construction plane matrix for IGEgragad */
	   for ( ii = 0; ii < 16; ii++ )
	      mx[ii] = 0.0;

	   mx[0] = mx[5] = mx[10] = mx[15] = 1.0;
	   for ( ii = 0; ii < 3; ii++ )
	      {
	      mx[0+ii] = xdir[ii];
	      mx[4+ii] = ydir[ii];
	      mx[8+ii] = zdir[ii];
	      mx[3+ii*4] = origin[ii];
	      }

	   var_list[0].var = GRAGAD_FLAGS;
	   var_list[0].var_ptr = (IGRchar *) flags;
	   var_list[0].num_bytes = sizeof( IGRint ) * 2;
	   var_list[0].bytes_returned = &num_bytes;

	   var_list[1].var = CONSTRUCT_PLANE;
	   var_list[1].var_ptr = (IGRchar *) mx;
	   var_list[1].num_bytes = sizeof( IGRdouble ) * 16;
	   var_list[1].bytes_returned = &num_bytes;
 
	   var_list[2].var = END_PARAM;

	   flags[0] = CONST_PL_DEF | CONST_PLANE_ON | VALID_ALT_INV;
	   flags[1] = CONST_PL_DEF;

	   /* enable ref plane if lock is on */
	   ems$ref_plane_lock( msg = &msg,
	                       options = EMS_REF_PLANE_LOCK_INQ,
	                       mode = &ref_plane_lock_mode );

	   if ( ref_plane_lock_mode == EMS_REF_PLANE_LOCK_ON )
	      flags[1] |= CONST_PLANE_ON | VALID_ALT_INV;

	   dp$inq_set_gragad( msg          = &msg,
	                      inq0_set1    = 1,
	                      which_error  = &error,
	                      var_list     = var_list,
	                      osnum        = win_os,
	                      gragad_objid = win_id,
	                      calc_info    = 1,
	                      update       = 0 );

	   }  /* end: if ( datpln != NULL_OBJID ) */

	}  /* HSsetup_ref_plane_for_window */

end implementation Root;

