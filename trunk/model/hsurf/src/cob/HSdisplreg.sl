/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/


/*
	This file defines and implements the following commands:

	   Display Region 

	The command table entries for the commands should be:

	   "Display Region", HSDsRg, HSdisplreg, 0
*/

class              HSdisplreg
super_class        CEO_GSLOCATE 
command_string     HSM_M_DispReg,0,HSDsRg
status_display	   "HSWinRegion","-1","-1"
product_name       "$MODEL"
start_state        get_region


specification

#include "FI.h"
#include "OMtypes.h"
#include "dp.h"
#include "dpstruct.h"

instance
{
        IGRchar 		style;        /* region style */
        IGRint 			orig_style;   /* original style */
	Form 			form_ptr;
	struct  		GRevent point_1;
	struct  		GRevent *events[2];
	OMuword 		classid;  
	OM_S_OBJID		objid;
	OMuword			osnum;
        struct DPdit_range  	reg_rng;
	IGRint			switch1;
        IGRint                  save_restore;
        IGRint                  get_point2_on;
}


state_table

#include "hsmsg.h"
#include "OMtypes.h"
#include "exfi.h"
#include "grdpbmacros.h"

#define MY_DYN		200
#define PARALLEL       4005	
#define PERSPECTIVE    4006	
#define POINT1         4007
#define MIX_VISUAL     4008
 
implementation

#define CHECK_RETURN_CODES    0
#define MY_DYN		    200
#define PARALLEL           4005	
#define PERSPECTIVE        4006	
#define POINT1             4007
#define MIX_VISUAL         4008

#include "grdpbmacros.h"
#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "wl.h"
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
#include "exfi.h"
#include "exmacros.h"
#include "exdef.h"

#include "hsurferrpriv.h"
#include "hsmsg.h"
#include "hsmacdef.h"
#include "hswinmacros.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hsmacros.h"

#include "grio.h"
#include "griomacros.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "EMdtmacros.h"
#include "EMSdatumdef.h"

extern OMuword OPP_HSgragad_class_id;

from IGEgragad import DPshading_allowed;

at init 	do HSdisplreg_init()
at wakeup	do status_display_button(1)
at sleep	do status_display_button(0)

state *			/* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state get_region
   on EX_BACK_UP    state -


state get_region
   message_key 	HSM_M_DispReg 
   status_key   HS_I_StsDsForm 
   execute 	display_prompt1	
   execute     	set_form_defaults
   filter      	get_event

   on EX_DATA 
      do store_1st_event
      state have_1st_event

   on EX_FORM_FINISHED 
      do erase_form STATUS_FORM
      state . 

   on EX_BACK_UP
      state . 

state have_1st_event
   status 	" "
   execute  	point2_on

   on ELSE 	
      do which_state 
	on RETURN_CODE=PARALLEL
	   state get_2nd_event
    	on RETURN_CODE=PERSPECTIVE
           do point2_off
	   state get_region
    	on RETURN_CODE=MIX_VISUAL
           do point2_off
	   state get_region
        on RETURN_CODE=POINT1
           do point2_off
           state get_region

   state .

state get_2nd_event
   execute 	display_prompt2	
   dynamics 	MY_DYN
   filter	get_event

   on EX_DATA
      do point2_off
      do make_region
      do draw_region
      do reset_display 
      state get_region 

   on EX_FORM_FINISHED 
      do erase_form STATUS_FORM
      state . 


action which_state 
{
   *sts=me->switch1;
}



/*----- store_1st_event ------------------------------------------------------*/

action store_1st_event 
{
  struct  gragad_inst win_inst;
  struct  var_list    info[2];
  IGRboolean          flag;
  IGRlong             bytes_returned;
  IGRlong             which_error;
  IGRint              msg;
  char 	              message1[100];
  IGRchar             title_msg[50];
  struct var_list     hs_var_list[2];
  WLuint16	      lscreen_no;
  WLuint32            context_no;
  struct WLcontext_info WLcontext_info;
  struct HStotal_window_instance	total_instance;
  IGRchar             HSmessage[310], HSmsg1[60], HSmsg2[60];



  *sts = OM_S_SUCCESS;

  me->point_1 = me->event1;
  me->events[0] = &me->event1;

  me->objid = me->event1.event.button.objid;
  me->osnum = me->event1.event.button.osnum;

   om$get_classid( p_classid = &me->classid,
      objid     = me->objid,
      osnum     = me->osnum );

   if ( om$is_ancestry_valid( subclassid = me->classid,
   superclassid = OPP_HSgragad_class_id ) == OM_S_SUCCESS )
   {
      hs_var_list[0].var             = HS_TOTAL_INSTANCE;
      hs_var_list[0].var_ptr         = (IGRchar *) &total_instance;
      hs_var_list[0].num_bytes       =
      sizeof( struct HStotal_window_instance);
      hs_var_list[0].bytes_returned  = &bytes_returned;
      hs_var_list[1].var             = END_PARAM;
      
      hs$get_window_instance_data( msg = &msg,
         win_id = me->objid,
         win_os = me->osnum,
         which_error = &which_error,
         var_list = hs_var_list );
      
      me->orig_style = total_instance.shading_style;
   }
   else
   {
      me->orig_style = HS_STYLE_WIREFRAME;
   }

   /* Check to see if illegaly trying to draw with a different visual type */
   switch (me->orig_style)
   {
      case HS_STYLE_SMOOTH:
      case HS_STYLE_CONSTANT:
      case HS_STYLE_WIREFRAME:
         {
            switch (me->style)
            {
               case HS_STYLE_RASTER:
               case HS_STYLE_FILLED_RASTER:
                  {
                     /* if original window is TRUE_color, can't draw indexed raster */
                     WLget_window_base_context( me->point_1.event.button.window, &context_no );
                     WLget_context_info( context_no, &WLcontext_info);
                     if (WLcontext_info.base_cmap_type & WL_CMAP_TRUE_COLOR)
                     {
                        ex$message( msgnumb = HS_W_WarnTitle, buff = title_msg );
                        ex$message( msgnumb = HS_W_CantMixVisuals, buff = HSmsg1 );
                        ex$message( msgnumb = HS_W_HidAndFilHidUseInd, buff = HSmsg2 );

			sprintf(HSmessage,"%s\n%s", HSmsg1, HSmsg2); 
			FI_message_box( FI_CURRENT_SCREEN, -1, -1, title_msg, FI_RED, "swiss742", 36.0,
                          HSmessage, FI_BLACK, "swiss742", 
                          18.0, FI_LEFT_JUSTIFIED, 40 );

                        me->switch1 = MIX_VISUAL;
                        goto wrapup;
                     }
                     break;
                  }
            }
            break;
         }
      case HS_STYLE_RASTER:
      case HS_STYLE_FILLED_RASTER:
         {
            switch (me->style)
            {
               case HS_STYLE_SMOOTH:
               case HS_STYLE_CONSTANT:
             /*case HS_STYLE_WIREFRAME: We will allow wireframe in raster and just draw indexed.  This will     */
                                     /* possibly be slightly different than TC wire frame window becuase best   */
                                     /* match wireframe elements, but will match the raster colors for elements */
                  {
                     /* if window is raster it is Indexed.  Cannot draw True color in this window */
                     WLget_window_screen( me->point_1.event.button.window, &lscreen_no );
                     CMget_active_context( lscreen_no, &context_no );
                     WLget_context_info( context_no, &WLcontext_info);

                     if (WLcontext_info.base_cmap_type & WL_CMAP_TRUE_COLOR)
                     {
                        ex$message( msgnumb = HS_W_WarnTitle, buff = title_msg );
                        ex$message( msgnumb = HS_W_CantMixVisuals, buff = HSmsg1 );
                        ex$message( msgnumb = HS_W_HidAndFilHidUseInd, buff = HSmsg2 );

			sprintf(HSmessage,"%s\n%s", HSmsg1, HSmsg2); 
			FI_message_box( FI_CURRENT_SCREEN, -1, -1, title_msg, FI_RED, "swiss742", 36.0,
                          HSmessage, FI_BLACK, "swiss742", 
                          18.0, FI_LEFT_JUSTIFIED, 40 );

                        me->switch1 = MIX_VISUAL;
                        goto wrapup;
                     }
                     break;
                  }
            }
            break;
         }
   }

  info[0].var             = GRAGAD_INST_STRUCT;
  info[0].var_ptr         = (char *)&win_inst;
  info[0].num_bytes       = sizeof( struct gragad_inst );
  info[0].bytes_returned  = &bytes_returned;

  info[1].var		  = END_PARAM;
  dp$inq_set_gragad(   msg             = &msg,
                       inq0_set1       = 0,
                       osnum           = me->osnum,
                       gragad_objid    = me->objid,
                       which_error     = &which_error,
                       var_list        = info );

  if (win_inst.gragad.flags & IS_PERSP)  
  {
     ex$message( msgnumb = HS_W_NoExecPersp, buff = message1 );
     ex$message( msgnumb = HS_W_WarnTitle, buff = title_msg );

     FI_message_box( FI_CURRENT_SCREEN, -1, -1,
                         title_msg, FI_RED, "swiss742", 36.0,
                         message1, FI_BLACK, "swiss742", 18.0,
                         FI_LEFT_JUSTIFIED, 40 );
      me->switch1 = PERSPECTIVE;
      goto wrapup;
  }
  else
  {
     /* see if shading is allowed for this window */
     om$send( msg = message IGEgragad.DPshading_allowed( &flag ),
	      targetid = me->objid,
	      targetos = me->osnum );

     if ( flag )
     {
        me->switch1 = PARALLEL;
     }
     else
     {
        ex$message( msgnumb = HS_E_NoShading );
	sleep( 2 );
        me->switch1 = POINT1;
        goto wrapup;
     }
  }
wrapup:
  _move_on
}


/*----- dynamics ------------------------------------------------------*/

action dynamics	/* (int dynamics; int *sts) */
{
  struct IGRdisplay ActiveDisplay;
  IGRlong NumberOfBytes, BytesReceived;
  IGRint mode;

  switch (dynamics)
  {
	case MY_DYN:

	        NumberOfBytes = sizeof( ActiveDisplay );
		gr$get_active_display( 	msg = sts,
					sizbuf = &NumberOfBytes,
					buffer = &ActiveDisplay,
					nret = &BytesReceived );
		ems$ref_plane_lock(	msg = sts,
					options = EMS_REF_PLANE_LOCK_INQ,
					mode = &mode);

		if (mode==EMS_REF_PLANE_LOCK_ON)
			{
			ems$ref_plane_lock(	msg = sts,
					options = EMS_REF_PLANE_LOCK_OFF | EMS_REF_PLANE_LOCK_SET);
			}

		DYrbblock( me->events, &ActiveDisplay );

		if (mode==EMS_REF_PLANE_LOCK_ON)
			{
			ems$ref_plane_lock(	msg = sts,
					options = EMS_REF_PLANE_LOCK_ON | EMS_REF_PLANE_LOCK_SET);
			}

		break;

	default:
		status = om$send( targetid = my_id, 
				  msg = message CEO.dynamics(dynamics, sts),
				  /* dummy method */
				  mode = OM_e_wrt_message );
		break;
  }
}


/*---HSdisplreg_init---------------------------------------------------*/

action HSdisplreg_init
        {

        me->form_ptr = (Form)me->status_display_form_ptr;
        me->status_display_form_ptr = NULL;
        me->save_restore = TRUE;
        me->get_point2_on = FALSE;

        }


/*--- display_prompt1 --------------------------------------------------*/

action display_prompt1
	{
        Form            form_ptr;
        int             display_status;

        form_ptr = me->form_ptr;
        FIf_is_displayed( form_ptr, &display_status );

        if (!display_status)
        {
            hs$get_last_styles( last_shading_style = NULL,
                                last_region_style = &me->style );
        }

	switch ( me->style )
	   {
	   case HS_STYLE_CONSTANT:

	     	ex$message( msgnumb = HS_P_SelPt1Const, buff = me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_SMOOTH:

		ex$message( msgnumb = HS_P_SelPt1Smooth, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_WIREFRAME:

		ex$message( msgnumb = HS_P_SelPt1Wire, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_RASTER:

		ex$message( msgnumb = HS_P_SelPt1RHL, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_FILLED_RASTER :

		ex$message( msgnumb = HS_P_SelPt1FRHL, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   }

	}	 


/*--- display_prompt2 --------------------------------------------------*/

action display_prompt2
{
   Form            form_ptr;
   int             display_status;

   form_ptr = me->form_ptr;
   FIf_is_displayed( form_ptr, &display_status );

   if (!display_status)
   {
         hs$get_last_styles( last_shading_style = NULL,
                                last_region_style = &me->style );
   }

   switch ( me->style )
   {
	   case HS_STYLE_CONSTANT:

	     	ex$message( msgnumb = HS_P_SelPt2Const, buff = me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_SMOOTH:

		ex$message( msgnumb = HS_P_SelPt2Smooth, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_WIREFRAME:

		ex$message( msgnumb = HS_P_SelPt2Wire, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_RASTER:

		ex$message( msgnumb = HS_P_SelPt2RHL, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;

	   case HS_STYLE_FILLED_RASTER :

		ex$message( msgnumb = HS_P_SelPt2FRHL, buff=me->prompt );
                ex$message( in_buff = me->prompt, field = PROMPT_FIELD,
                   justification = RIGHT_JUS );
	      	break;
   }
}


/*--- set_form_defaults ------------------------------------------------*/

action set_form_defaults

{
	/* 
		This routine gets the active values for shading style, and sends an 
  	  update to put the check mark in the appropriate box. 
	*/
	long   msg;

	me->status_display_form_ptr = (char *)me->form_ptr; 

	/* Make correct buttons and text for this form be shown */
	*sts = om$send(	targetid = my_id,
			msg      = message HSdisplreg.adjust_form_buttons( &msg ) );

	/* update the check marks to reflect the instance variable */
	*sts = om$send( targetid = my_id,
	                msg      = message HSdisplreg.set_check_marks( &msg ) );

}  /* set_form_defaults */


/*--- set_check_marks ------------------------------------------------*/

action set_check_marks

{
	/*  
	  This routine updates the check list.  It makes sure there is only
	  one check in the box desired ( ie.  it erases 4 checks and places
	  one.
	*/

	IGRlong		   msg;

	if (me->style == HS_STYLE_CONSTANT)
	   FIg_set_state_on( me->form_ptr, CONST_CYL );
	else
	   FIg_set_state_off( me->form_ptr, CONST_CYL );

	if (me->style == HS_STYLE_SMOOTH)
	   FIg_set_state_on( me->form_ptr, SMOOTH_CYL );
	else
	   FIg_set_state_off( me->form_ptr, SMOOTH_CYL );

	if (me->style == HS_STYLE_RASTER)
	   FIg_set_state_on( me->form_ptr, RAST_CYL );
	else
	   FIg_set_state_off( me->form_ptr, RAST_CYL );

	if (me->style == HS_STYLE_FILLED_RASTER)
	   FIg_set_state_on( me->form_ptr, RVRAST_CYL );
	else
	   FIg_set_state_off( me->form_ptr, RVRAST_CYL );

	if (me->style == HS_STYLE_WIREFRAME)
	   FIg_set_state_on( me->form_ptr, WIRE_CYL );
	else
	   FIg_set_state_off( me->form_ptr, WIRE_CYL );

        if (!me->save_restore)
        {
           if (!me->get_point2_on)
              *sts = om$send( targetid = my_id,
                        msg = message HSdisplreg.display_prompt1( &msg ) );
            else
              *sts = om$send( targetid = my_id,
                        msg = message HSdisplreg.display_prompt2( &msg ) );
        }

}  /* set_check_marks */


/*--- adjust_form_buttons --------------------------------------------------*/

action adjust_form_buttons
{
	FIg_erase( me->form_ptr, SWDM_TITLE );
	FIg_display( me->form_ptr, DR_TITLE );

	FIg_erase( me->form_ptr, STEREO_TOG );

} /* adjust_form_buttons */


/*--- form_notification ------------------------------------------------*/

action form_notification

{
	/* 
	  This routine is where the Forms Interface sends back data from
	  the user hitting a data point on an object on the form.  The
	  gadget number is returned in the form_data structure.

	  Note: gadget labels are stored in the include file HSforms.h
	*/

	IGRlong msg;

	switch ( gadget_label )
	   {
	   case CVRT_TO_WINDOW:

              me->save_restore = 0;

              status = om$send( targetid = my_id,
                          msg = message HSdisplreg.display_prompt1(&msg));
	      break;

	   case CONST_CYL:

	      me->style = HS_STYLE_CONSTANT;

		status = om$send( targetid = my_id,
	        	          msg      = message HSdisplreg.set_check_marks( &msg ) );
	      break;

	   case SMOOTH_CYL:

	      me->style = HS_STYLE_SMOOTH;

		status = om$send( targetid = my_id,
		                  msg      = message HSdisplreg.set_check_marks( &msg ) );
	      break;
      
	   case WIRE_CYL:

	      me->style = HS_STYLE_WIREFRAME;

		status = om$send( targetid = my_id,
		                  msg      = message HSdisplreg.set_check_marks( &msg ) );
	      break;

	   case RAST_CYL:

	      me->style = HS_STYLE_RASTER;

		status = om$send( targetid = my_id,
		                  msg      = message HSdisplreg.set_check_marks( &msg ) );
	      break; 

	   case RVRAST_CYL:

	      me->style = HS_STYLE_FILLED_RASTER;

		status = om$send( targetid = my_id,
		                  msg      = message HSdisplreg.set_check_marks( &msg ) );
	      break;

	   case CANCEL:

             FIg_set_state_off( form_ptr, SAVE );
             FIg_set_state_off( form_ptr, CANCEL );
             FIg_set_state_off( form_ptr, EXECUTE );

             hs$get_last_styles(last_shading_style = NULL,
                                last_region_style = &me->style);

             _put_response( resp=EX_FORM_FINISHED );

	     break;

	   case SAVE:

             FIg_set_state_off( form_ptr, SAVE );
             FIg_set_state_off( form_ptr, CANCEL );
             FIg_set_state_off( form_ptr, EXECUTE );

	     hs$set_last_styles( last_shading_style = NULL, 
				 last_region_style = &me->style );

             _put_response( resp=EX_FORM_FINISHED );

	     break;

	   case EXECUTE:

             FIg_set_state_off( form_ptr, SAVE );
             FIg_set_state_off( form_ptr, CANCEL );
             FIg_set_state_off( form_ptr, EXECUTE );

	     hs$set_last_styles( last_shading_style = NULL,
				 last_region_style = &me->style );

             _put_response( resp=EX_FORM_FINISHED );

	     break;

	   }  /* end: switch */

}  /* form_notification */


/*----- make_region ----------------------------------------------------------*/

action make_region 
{

        struct DPdit_range   tmp_rng;
  	struct  gragad_inst win_inst;
  	struct  var_list    info[2];
  	IGRlong bytes_returned;
  	IGRlong which_error;
  	IGRint  msg;
  	info[0].var             = GRAGAD_INST_STRUCT;
  	info[0].var_ptr         = (char *)&win_inst;
  	info[0].num_bytes       = sizeof( struct gragad_inst );
  	info[0].bytes_returned  = &bytes_returned;
  	info[1].var             = END_PARAM;

  	dp$inq_set_gragad(   msg             = &msg,
                       inq0_set1       = 0,
                       osnum           = me->osnum,
                       gragad_objid    = me->objid,
                       which_error     = &which_error,
                       var_list        = info );

	me->events[0] = &me->point_1;
 	me->events[1] = &me->event1;

	tmp_rng.xlo = (int)((win_inst.gragad.wld_to_viewport[0][0] * me->events[0]->event.button.x) +
			(win_inst.gragad.wld_to_viewport[0][1] * me->events[0]->event.button.y) +
			(win_inst.gragad.wld_to_viewport[0][2] * me->events[0]->event.button.z) +
			(win_inst.gragad.wld_to_viewport[0][3]));

	tmp_rng.ylo = (int)((win_inst.gragad.wld_to_viewport[1][0] * me->events[0]->event.button.x) +
			(win_inst.gragad.wld_to_viewport[1][1] * me->events[0]->event.button.y) +
			(win_inst.gragad.wld_to_viewport[1][2] * me->events[0]->event.button.z) +
			(win_inst.gragad.wld_to_viewport[1][3]));

	tmp_rng.xhi = (int)((win_inst.gragad.wld_to_viewport[0][0] * me->events[1]->event.button.x) +
			(win_inst.gragad.wld_to_viewport[0][1] * me->events[1]->event.button.y) +
			(win_inst.gragad.wld_to_viewport[0][2] * me->events[1]->event.button.z) +
			(win_inst.gragad.wld_to_viewport[0][3]));

	tmp_rng.yhi = (int)((win_inst.gragad.wld_to_viewport[1][0] * me->events[1]->event.button.x) +
			(win_inst.gragad.wld_to_viewport[1][1] * me->events[1]->event.button.y) +
			(win_inst.gragad.wld_to_viewport[1][2] * me->events[1]->event.button.z) +
			(win_inst.gragad.wld_to_viewport[1][3]));


	me->reg_rng.xlo = ((tmp_rng.xlo < tmp_rng.xhi)? 
						tmp_rng.xlo : tmp_rng.xhi);
	me->reg_rng.ylo = ((tmp_rng.ylo < tmp_rng.yhi)? 
						tmp_rng.ylo : tmp_rng.yhi);
	me->reg_rng.xhi = ((tmp_rng.xlo < tmp_rng.xhi)? 
						tmp_rng.xhi : tmp_rng.xlo); 
	me->reg_rng.yhi = ((tmp_rng.ylo < tmp_rng.yhi)? 
						tmp_rng.yhi : tmp_rng.ylo); 

	me->reg_rng.xlo+=me->reg_rng.xlo%2;
	me->reg_rng.ylo+=me->reg_rng.ylo%2;
	me->reg_rng.xhi+=me->reg_rng.xhi%2;
	me->reg_rng.yhi+=me->reg_rng.yhi%2;
        if (me->reg_rng.xlo == me->reg_rng.xhi)
        {
           me->reg_rng.xhi += 2;
        }
        if (me->reg_rng.ylo == me->reg_rng.yhi)
        {
           me->reg_rng.yhi += 2;
        }
}


/*----- draw_region ----------------------------------------------------------*/

action draw_region 

/*
DESCRIPTION
	This action toggles the display mode of all the selected windows.
*/

{
	IGRint		     msg;
	struct var_list	     hs_var_list[2];
	IGRlong		     ret_bytes;
 	IGRlong		     which_error;
	struct HStotal_window_instance	total_instance;
  	IGRint		     x_dit,y_dit;
        Form                 form_ptr;
        int                  display_status;
	WLuint16	     lscreen_no;
	IGRint		     type;

        form_ptr = (Form)me->status_display_form_ptr;
        FIf_is_displayed( form_ptr, &display_status );

        if (!display_status)
        {
           hs$get_last_styles(  last_shading_style = NULL,
                                last_region_style = &me->style );
        }

	HSset_region_update( TRUE );
	HSset_region_xy_minmax(me->reg_rng.xlo,me->reg_rng.ylo,
				me->reg_rng.xhi,me->reg_rng.yhi);
	HSset_region_style( me->style );
	WLget_window_screen( me->point_1.event.button.window, &lscreen_no );
{
/*
 *  Need to pass in the logical window number to HScheck_hardware_support,
 *  not the hardware window number.  Changed 10/20/95.  Mike Lanier
 */
WLuint32 lwin_no;
WLget_logical_window( me->point_1.event.button.window, &lwin_no );
	type = HScheck_hardware_support( lscreen_no, lwin_no, FALSE );
}
	HSset_region_hardware_type( type );

	if ( me->orig_style != HS_STYLE_WIREFRAME )
	{
	   HSset_region_original_style( me->orig_style );

	   if (me->style != HS_STYLE_WIREFRAME)
	   {
        	hs_var_list[0].var             = HS_TOTAL_INSTANCE;
        	hs_var_list[0].var_ptr         = (IGRchar *) &total_instance;
        	hs_var_list[0].num_bytes       = sizeof( struct HStotal_window_instance);
        	hs_var_list[0].bytes_returned  = &ret_bytes;
        	hs_var_list[1].var             = END_PARAM;

	   	hs$get_window_instance_data( msg = &msg,
	                                win_id = me->objid,
	                                win_os = me->osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

	   	total_instance.shading_style = me->style;

	   	hs$set_window_instance_data( msg = &msg,
	                                win_id = me->objid,
	                                win_os = me->osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

	    }
	 }
	 else /* ancestry valid?  NO */
	 {
	      HSset_region_original_style( me->orig_style );
 	      if ( me->style != HS_STYLE_WIREFRAME )
 	      { 
 	     	 x_dit=me->reg_rng.xhi-me->reg_rng.xlo+1;
 	     	 y_dit=me->reg_rng.yhi-me->reg_rng.ylo+1;
 	     	
 	         hs$convert_wireframe_window_to_shading( 
 					msg = &msg,
 	                               	win_id = me->objid,
 	                               	win_os = me->osnum, 
 				     	update = FALSE, 
 					shading_style = me->style,
 					x_dits = x_dit,
 					y_dits = y_dit  );
 	      }
	}  /* end: else (not a VE window) */
	/* every case calls dp$gen_update the same */
        dp$gen_update( msg   = &msg,
                     osnum = me->osnum,
                     objid = me->objid,
                     range = &me->reg_rng );
	HSset_region_update( FALSE );
}  /* draw_region */


/*----- reset_display --------------------------------------------------------*/

action reset_display 
{
	IGRint   	  msg;
        struct var_list   hs_var_list[2];
        IGRlong           ret_bytes;
        IGRlong           which_error;
        struct HStotal_window_instance  total_instance;

	if( me->style != HS_STYLE_WIREFRAME )
	{
	    if( me->orig_style == HS_STYLE_WIREFRAME )
	    {
			hs$convert_shading_window_to_wireframe( 
				msg = &msg,
	                       	win_id = me->objid,
	                       	win_os = me->osnum,
				update = FALSE );
	    }
	    else
	    {
        	hs_var_list[0].var             = HS_TOTAL_INSTANCE;
        	hs_var_list[0].var_ptr         = (IGRchar *) &total_instance;
        	hs_var_list[0].num_bytes       = 
					sizeof( struct HStotal_window_instance);
        	hs_var_list[0].bytes_returned  = &ret_bytes;
        	hs_var_list[1].var             = END_PARAM;

	   	hs$get_window_instance_data( msg = &msg,
	                                win_id = me->objid,
	                                win_os = me->osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

	   	total_instance.shading_style = me->orig_style;

	   	hs$set_window_instance_data( msg = &msg,
	                                win_id = me->objid,
	                                win_os = me->osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

	    }
	}
}

    

action point2_on
{
  me->get_point2_on = TRUE;
}


action point2_off
{
  me->get_point2_on = FALSE;
}
