
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/


/*
	This file defines and implements the following commands:

	   Toggle Shading Accuracy Mode

	The command table entries for the commands should be:

	   "Toggle Shading Accuracy Mode", HSshdacctgl, HSshdacctgl, 0
*/


class              HStogshdacc
super_class        CEO_LOCATE
command_string     HSM_M_TogShdAccMode,0,HSTgShAcMd
product_name       "$MODEL"
start_state        start

state_table

#include "hsmsg.h"

implementation

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


state *			/* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state start
   on EX_BACK_UP    state -

state start

   message_key HSM_M_TogShdAccMode
   execute     toggle_accuracy_mode

   on ELSE
	state terminate


/*--- toggle_accuracy_mode ------------------------------------------------*/

action toggle_accuracy_mode

/*
DESCRIPTION
	This action toggles the shading accuracy mode stored in the HSdpb between
	WINDOW TOLERANCE and ACTIVE ACCURACY.
*/

	{
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

	}  /* toggle_accuracy_mode */
