
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/


/*
	This file defines and implements the following commands:

	   Change active shading accuracy

	The command table entries for the commands should be:

	   "Change Active Shading Accuracy", HSSShAc, HSactive, 0
*/


class              HSactive
super_class        CEO_LOCATE
command_string     HSM_M_ChgActShdAcc,0,HSSShAc
product_name       "$MODEL"
start_state        start

specification

instance
	{
	IGRlong accuracy;
	}

state_table


#include "hsmsg.h"

implementation

#define CHECK_RETURN_CODES 1

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "stdio.h"

#include "OMerrordef.h"

#include "msdef.h"
#include "msmacros.h"

#include "dpdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsmsg.h"

#include "hsmacdef.h"
#include "hsmacros.h"

at wakeup
   do get_dpb_props

state *			/* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state start
   on EX_BACK_UP    state -

state start
   message_key HSM_M_ChgActShdAcc
   prompt_key HS_P_EntShdAcc
   execute display_current_value
   filter get_event

      on VALUE.GRst_DEFAULT or EX_RJT_MOVEON
         state .

      on SCALAR
         do process_accuracy_keyin
            on SUCCESS
               do display_current_value
               do set_dpb_props
	       state terminate
            on ELSE
               state .
         state .


/*--- get_dpb_props --------------------------------------------------*/

action get_dpb_props

/*
DESCRIPTION
	Get the shading accuracy and store it in my instance data
*/

	{
	*sts = OM_S_SUCCESS;

	hs$get_shading_accuracy( accuracy = &me->accuracy );

	}  /* get_dpb_props */


/*--- display_current_value -----------------------------------------------*/

action display_current_value

/*
DESCRIPTION
	Display the current shading accuracy in the message strip
*/

	{
	/* display the current shading accuracy */
	ex$message( msgnumb = HS_I_AccIs, type = "%d", var = `me->accuracy` );

	return( OM_S_SUCCESS );

	}  /* display_current_value */


/*--- set_dpb_props ---------------------------------------------------*/

action set_dpb_props

/*
DESCRIPTION
	Set the shading accuracy to that which is stored in my instance data
*/

	{
	*sts = OM_S_SUCCESS;

	hs$set_shading_accuracy( accuracy = me->accuracy );

	}  /* set_dpb_props */


/*--- process_accuracy_keyin --------------------------------------------------*/

action process_accuracy_keyin

/*
DESCRIPTION
	Process an accuracy keyin from the user and store a valid accuracy
	in my instance data
*/

	{
        IGRlong accuracy;

	accuracy = (IGRlong) me->event1.event.value;
	if ( (accuracy >= 1) && (accuracy <= 15) )
	   {
	   /* user entered a valid accuracy */
	   *sts = OM_S_SUCCESS;
	   me->accuracy = accuracy;
	   }
	else
	   {
	   /* Shading Accuracy out of valid range */
	   *sts = OM_W_WARNING;
	   ex$message( msgnumb = HS_E_InvAcc );
	   sleep( 3 );
	   }

	}  /* process_accuracy_keyin */
