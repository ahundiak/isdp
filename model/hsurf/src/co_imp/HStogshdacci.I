class implementation HStogshdacc;



/*#include "hsurf_import.h"*/
#include "stdlib.h"
#include "math.h"
#include "igrtypedef.h"

#include "stdio.h"

#include "OMerrordef.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "hsurferrpriv.h"
#include "hsmsg.h"
#include "hsmacdef.h"

/*-----------------------
 *  for functions
 *     HSget_accuracy_mode
 *     HSset_accuracy_mode
 */
 
#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "hslight.h"
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*--------------------------*/



#define _start 0

method toggle_accuracy_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRint acc_mode, new_acc_mode;
	IGRint message_no;

	*sts = OM_S_SUCCESS;

	HSget_accuracy_mode( &acc_mode );

	switch ( acc_mode )
	   {
	   case HS_ACCURACY_MODE_WINDOW:

	      /* toggle to active accuracy */
	      new_acc_mode = HS_ACCURACY_MODE_ACTIVE;
	      message_no = HS_I_AccModeIsAct;
	      break;

	   case HS_ACCURACY_MODE_ACTIVE:

	      /* toggle to window tolerance */
	      new_acc_mode = HS_ACCURACY_MODE_WINDOW;
	      message_no = HS_I_AccModeIsWinTol;
	      break;

	   default:

	      /* unknown state => set to window tolerance */
	      new_acc_mode = HS_ACCURACY_MODE_WINDOW;
	      message_no = HS_I_AccModeIsWinTol;
	      break;

	   }  /* end: switch */

	ex$message( msgnumb = message_no );

	HSset_accuracy_mode( new_acc_mode );

	ex$message( msgnumb       = HS_I_UpdShdWin,
	            justification = CENTER_JUS,
	            field         = KEYIN_FIELD );
	sleep( 3 );
	ex$message( field = KEYIN_FIELD, in_buff = "" );

	quit:
  return OM_S_SUCCESS;
}

end implementation HStogshdacc;
