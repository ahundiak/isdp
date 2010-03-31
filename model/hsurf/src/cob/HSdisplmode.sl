
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/


/*
	This file defines and implements the following commands:

	   Set window display mode 

*/

class              HSdisplmode
super_class        HSwindow
command_string     HSM_M_ChgDispMode,0,HSTgVDsMd
status_display	   "HSWinRegion","-1","-1"
product_name       "$MODEL"
start_state        get_window


specification

instance
	{
        IGRchar style;   /* active shading style */
	IGRint save_restore;
	}

state_table

#include "hsmsg.h"
#include "OMtypes.h"
#include "ODE.h"
#include "dpdef.h"

#define TOGGLE_WINDOW	4000

implementation

#define CHECK_RETURN_CODES 0
#define TOGGLE_WINDOW	4000

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "tools.h"
#include "stdio.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "msdef.h"

#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "msmacros.h"

#include "FI.h"
#include "HSswdmform.h"
#include "exmacros.h"
#include "exdef.h"

#include "hsurferrpriv.h"
#include "hsmsg.h"
#include "hsmacdef.h"
#include "hswinmacros.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hsmacros.h"

extern OMuword OPP_HSgragad_class_id;

at init
   do initialize_instance

state *			/* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state get_window
   on EX_BACK_UP    state -


state get_window
   message_key HSM_M_ChgDispMode
   execute     status_display_button(1)
   status_key  HS_I_StsDsForm 
   execute     display_shad_symb
   execute     set_form_defaults
   filter      get_event

   on EX_DATA or EX_STRING
      do status_display_button(0)
      do get_selected_window( sts, 0, 0, 1, 0 )
         on SUCCESS
	    do update_display_mode 
	       on RETURN_CODE = TOGGLE_WINDOW
	          state toggle_window
	       on ELSE
	  	  state .
	    state .
         on ELSE
            state .
      state .

   on EX_FORM_FINISHED 
      do status_display_button(0)
      do erase_form STATUS_FORM
      state get_window

   on EX_BACK_UP
      do status_display_button(0)
      state . 


state toggle_window
   prompt_key HS_P_TogWin
   status     " "
   filter     get_event
   
   on EX_RJT_MOVEON
      do cvrt_to_wireframe
      state get_window

   on ELSE
      do print_message
      state get_window


/*--- display_shad_symb ------------------------------------------------*/

action display_shad_symb 

/*
NAME
	HSdisplmode.display_shad_symb

DESCRIPTION
	This action loads and displays the prompt message for the
	Set Window Display Mode command.

PARAMTERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/


	{
        Form       form_ptr;
        IGRint     display_status;
	IGRint     msg_no = 0;

        form_ptr = me->status_display_form_ptr;
        FIf_is_displayed( form_ptr, &display_status );

        if (!display_status)
	    hs$get_last_styles(	last_shading_style = &me->style,
			  	last_region_style = NULL );

	switch ( me->style )
	   {
	   case HS_STYLE_CONSTANT:

   	      msg_no = HS_P_SelForConst;
	      break;

	   case HS_STYLE_SMOOTH:

	      msg_no = HS_P_SelForSmooth;
	      break;

	   case HS_STYLE_WIREFRAME:

	      msg_no = HS_P_SelForWire;
	      break;

	   case HS_STYLE_RASTER:

	      msg_no = HS_P_SelForRHL;
	      break;

	   case HS_STYLE_FILLED_RASTER :

	      msg_no = HS_P_SelForFRHL;
	      break;

	   }

	ex$message( msgnumb = msg_no, buff=me->prompt );
	ex$message( in_buff=me->prompt, field = PROMPT_FIELD, 
	            justification = RIGHT_JUS );
	}


/*--- set_form_defaults ------------------------------------------------*/

action set_form_defaults

/*
NAME
	HSdisplmode.set_form_defaults

DESCRIPTION
	This action gets the active values for shading style, and 
	sends an update to put the check mark in the appropriate box. 

PARAMTERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	IGRlong  msg;
	char     *form_ptr;

	form_ptr = me->status_display_form_ptr;

	/* Make correct buttons and text for this form be shown */
	FIg_erase( form_ptr, DR_TITLE );
	FIg_display( form_ptr, SWDM_TITLE );

	FIg_erase( form_ptr, STEREO_TOG );

	/* update the check marks to reflect the instance variable */
	*sts = om$send( targetid = my_id,
                msg = message HSdisplmode.set_check_marks( &msg ) );

	}  /* set_form_defaults */


/*--- set_check_marks ------------------------------------------------*/

action set_check_marks

/*
NAME
	HSdisplmode.set_check_marks

DESCRIPTION
	This routine updates the check list.  It makes sure there is only
	one check in the box desired ( ie.  it erases 4 checks and places
	one.

PARAMTERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	IGRlong		msg;
	Form		form_ptr;	

        form_ptr = me->status_display_form_ptr;

	if (me->style == HS_STYLE_CONSTANT)
	   FIg_set_state_on( form_ptr, CONST_CYL );
	else
	   FIg_set_state_off( form_ptr, CONST_CYL);

	if (me->style == HS_STYLE_SMOOTH)
	   FIg_set_state_on( form_ptr, SMOOTH_CYL );
	else
	   FIg_set_state_off( form_ptr, SMOOTH_CYL );

	if (me->style == HS_STYLE_RASTER)
	   FIg_set_state_on( form_ptr, RAST_CYL );
	else
	   FIg_set_state_off( form_ptr, RAST_CYL );

	if (me->style == HS_STYLE_FILLED_RASTER)
	   FIg_set_state_on( form_ptr, RVRAST_CYL );
	else
	   FIg_set_state_off( form_ptr, RVRAST_CYL );

	if (me->style == HS_STYLE_WIREFRAME)
	   FIg_set_state_on( form_ptr, WIRE_CYL );
	else
	   FIg_set_state_off( form_ptr, WIRE_CYL );

	if (!me->save_restore)
           status = om$send( targetid = my_id,
                          msg = message HSdisplmode.display_shad_symb(&msg) );

	}  /* set_check_marks */


/*--- adjust_form_buttons --------------------------------------------------*/

action adjust_form_buttons

/*
NAME
	HSdisplmode.adjust_form_buttons

DESCRIPTION
	This routine erases/displays some of the gadgets on the form
	to reflect what is currently supported.

PARAMTERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	} /* adjust_form_buttons */


/*--- form_notification ------------------------------------------------*/

action form_notification

/*
NAME
	HSdisplmode.form_notification

DESCRIPTION
	This is the form notification routine for the Set Window
	Display Mode command.

PARAMTERS
	form_label (IN) - the label of the form that had input
	gadget_label (IN) - the label of the gadget that had input
	value (IN) - the value of the gadget

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	IGRlong  msg;
	char     *form_ptr;

	form_ptr = me->status_display_form_ptr;

	switch ( gadget_label )
	   {
	   case CVRT_TO_WINDOW:

	      me->save_restore = FALSE;

	      status = om$send( targetid = my_id,
	       	          msg = message HSdisplmode.display_shad_symb(&msg));
	      break;

	   case CONST_CYL:

	      me->style = HS_STYLE_CONSTANT;

	      status = om$send( targetid = my_id,
	       	          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;

	   case SMOOTH_CYL:

	      me->style = HS_STYLE_SMOOTH;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;
      
	   case WIRE_CYL:

	      me->style = HS_STYLE_WIREFRAME;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;

	   case RAST_CYL:

	      me->style = HS_STYLE_RASTER;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break; 

	   case RVRAST_CYL:

	      me->style = HS_STYLE_FILLED_RASTER;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;

	   case CANCEL:

	     FIg_set_state_off( form_ptr, SAVE );
	     FIg_set_state_off( form_ptr, CANCEL );

	     hs$get_last_styles(last_shading_style = &me->style,
			  	last_region_style = NULL );

             _put_response( resp=EX_FORM_FINISHED );
	     FIf_erase( form_ptr );
	     break;

	   case SAVE:

	     hs$set_last_styles( last_shading_style = &me->style, 
				 last_region_style = NULL);

	     FIg_set_state_off( form_ptr, SAVE );
	     FIg_set_state_off( form_ptr, CANCEL );

             _put_response( resp=EX_FORM_FINISHED );
	     FIf_erase( form_ptr );
	     break;

	   }  /* end: switch */

	}  /* form_notification */

/*--- update_display_mode --------------------------------------------------*/

action update_display_mode

/*
NAME
	HSdisplmode.update_display_mode

DESCRIPTION
	This action updates the display mode of all the selected windows.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	IGRint		     msg;
	OMuword              classid;
        IGRint               ii;
	struct var_list	     hs_var_list[2];
	IGRlong		     ret_bytes;
	IGRlong		     which_error;
	struct HStotal_window_instance	total_instance;
	Form		     form_ptr;
        int		     display_status;
 
	*sts = 0;

	form_ptr = me->status_display_form_ptr;
	FIf_is_displayed( form_ptr, &display_status ); 

	if (!display_status)	/* form is not up */	
          hs$get_last_styles(   last_shading_style = &me->style,
				last_region_style = NULL);

	for ( ii = 0; ii < me->num_win_ids; ii++ )
	   {
	   om$get_classid( p_classid = &classid,
	                   objid     = me->win_ids[ii].objid,
	                   osnum     = me->win_ids[ii].osnum );

	   /* check if original display mode is shading */

	   if ( om$is_ancestry_valid( subclassid = classid,
	               superclassid = OPP_HSgragad_class_id ) == OM_S_SUCCESS )
	      {
	      /* check if new display mode is wireframe */

	      if ( me->style == HS_STYLE_WIREFRAME )
		{

	   	/* window display mode changed from shading to wireframe */

	        hs$convert_shading_window_to_wireframe( msg = &msg,
	                                      win_id = me->win_ids[ii].objid,
	                                      win_os = me->win_ids[ii].osnum );
		}
	      else
		{
	   	/* update shading window if shading style is changed */

        	hs_var_list[0].var             = HS_TOTAL_INSTANCE;
        	hs_var_list[0].var_ptr         = (IGRchar *) &total_instance;
        	hs_var_list[0].num_bytes       = sizeof( struct HStotal_window_instance);
        	hs_var_list[0].bytes_returned  = &ret_bytes;
        	hs_var_list[1].var             = END_PARAM;

	   	hs$get_window_instance_data( msg = &msg,
	                                win_id = me->win_ids[ii].objid,
	                                win_os = me->win_ids[ii].osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

		if( total_instance.shading_style == me->style )
		  {
        	       if (me->num_win_ids > 1)
		       {
           	           *sts=0;
		           ex$message( msgnumb = HS_I_DsMdUnChg, 
				field = ERROR_FIELD );
		           sleep(2);
		       }
        	       else
		       {
           		   *sts=TOGGLE_WINDOW;
		       }
		  }
		else
		  {
	   	  total_instance.shading_style = me->style;

	   	  hs$set_window_instance_data( msg = &msg,
	                                win_id = me->win_ids[ii].objid,
	                                win_os = me->win_ids[ii].osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

		  dp$gen_update( msg   = &msg,
	                   	 osnum = me->win_ids[ii].osnum,
	                   	 objid = me->win_ids[ii].objid );

		  } /* else update shading window if style is changed */	

		} /* else new display mode is shading */

	      } /* if original display mode is shading */

	   else /* original display mode is wireframe */
	      {
	      /* check if new display mode is shading */

	      if ( me->style != HS_STYLE_WIREFRAME )
	        {
	        hs$convert_wireframe_window_to_shading( msg = &msg,
	                                     win_id = me->win_ids[ii].objid,
	                                     win_os = me->win_ids[ii].osnum,
					     shading_style = me->style );
	 	}
	      else
		{
		  ex$message( msgnumb = HS_I_DsMdUnChg, field = ERROR_FIELD );
		  sleep(2);
		}
	      }  /* end: else (not a VE window) */

	   } /* for ii=0 ii<me->num_win_ids */

	}  /* update_display_mode */


/*--- cvrt_to_wireframe ----------------------------------------------------*/

action cvrt_to_wireframe

/*
NAME
	HSdisplmode.cvrt_to_wireframe

DESCRIPTION
	This action converts a window to wireframe

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	IGRint msg;

	hs$convert_shading_window_to_wireframe( msg = &msg,
	                                     win_id = me->win_ids[0].objid,
	                                     win_os = me->win_ids[0].osnum );
	} /* cvrt_to_wireframe */


/*--- print_message --------------------------------------------------------*/

action print_message

/*
NAME
	HSdisplmode.print_message

DESCRIPTION
	This action prints the display mode unchanged message

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	ex$message( msgnumb = HS_I_DsMdUnChg, field = ERROR_FIELD );
	sleep(2);
	} /* print_message */


/*--- initialize_instance --------------------------------------------------*/

action initialize_instance

/*
NAME
	HSdisplmode.initialize_instance

DESCRIPTION
	This action initializes the instance data of the command

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/91  Unknown
	   Creation Date
*/

	{
	me->save_restore = TRUE;
	}
