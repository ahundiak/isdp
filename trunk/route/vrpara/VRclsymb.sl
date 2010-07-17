/* $Id: VRclsymb.sl,v 1.2 2001/02/20 01:14:43 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara/VRclsymb.sl
 *
 * Description:
 *	"Change Active Center Line Symbology",0, VRChACeLSb

	override delete of CEO in order to keep form displayed & active

	override init of CEO so that self destruct if command occurrence
	is already out there. Don't want two commands changing the same
	global data.

	Form control of the persistant form is within the command and
	not under COB, due to problems with overriding delete and the
	management of several commands with persistant forms.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRclsymb.sl,v $
 *	Revision 1.2  2001/02/20 01:14:43  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/09  18:43:28  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.14  1996/05/14  14:20:34  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by hverstee for route240
#
# Revision 1.13  1996/04/01  18:01:54  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by msmanem for route240
#
# Revision 1.12  1996/02/27  10:31:04  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by ashankar for route240
#
# Revision 1.11  1996/02/04  07:26:22  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by ashankar for route240
#
# Revision 1.9  1996/01/19  10:23:06  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by ashankar for route240
#
# Revision 1.8  1996/01/17  14:46:54  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by r240_int for route240
#
# Revision 1.7  1995/12/26  15:45:04  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by yzhu for route240
#
# Revision 1.6  1995/12/08  21:23:52  pinnacle
# Replaced: vrpara/VRclsymb.sl for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
	?? ?? ??	??	Creation
        11/01/95	Shankar Added Toggle gadget in Centerline Symb
					Form. TR#179527674
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	01/19/96	tlb	Cast arg to ige$get_color_from_name
 *      04/01/96	msm	changed VRstrip_space to VR_strip_space
 *	10/09/97        law     TR179700484- Modified NOD interface to
 *                              prevent errors and crashes.
 *
 *************************************************************************/

class                VRclsymb
command_string       VRC_M_StAcCnSy,0,VRStAcCnSy 
product_name         "$ROUTE"
command_table	     "route.cmd"
start_state	     start
super_class	     CEO

/** form "VRCenterlSym",MAIN,2,"-1","-1" **/

specification

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "FI.h"
#include "FEI.h"

instance
{
	/* same as super class + */

   struct GRsymbology	clsymb;
   struct GRid		symb_id;
   char			delete_flag;
   long			status;

   /* Form control */

   char *		form_name;
   int			form_label;
   int			toggle_value;
   Form  		form_ptr;

   /* previous valid field values */

   int                  prev_weight, prev_style;
   short                prev_layer;
   short unsigned	prev_color;

  /* Flag for wakeup */
  IGRboolean		StyleFlag;
  IGRboolean		LayerFlag;

}

implementation

/****************************************************************************

		Implementation file for command object
	"Change Active Center Line Symbology",0, VRChACeLSb

***************************************************************************/

#include "DIdef.h"
#include "OMparameters.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "msmacros.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "adpdef.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "FI.h"
#include "FEI.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRclsymbf.h"
#include "VRclsymb.h"
#include "ex.h"
#include "go.h"
#include "griodef.h" 
#include "grio.h"
#include "griomacros.h"
#include "comiscmac.h"
#include "dpdls.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define MAIN 0
#define AS_DEBUG 1
#define NEG_ONE -1
#define MAX_FIELD 256
#define COMMAND_NAME ":IGENOD:VRclsymb_comm_id"
#define CLSYMB_NAME ":IGENOD:VRclsymb1"
#define FORM_NAME    "VRCenterlSym"
#define LAYER_BUTTON 21
#define COLOR_BUTTON 22
#define WEIGHT_BUTTON 23
#define STYLE_BUTTON  24
#define VR_CLSYMB_TOGGLE  12
#define POP_UP_BUTTONS 123

static Form previous_subform_ptr; 
static Form active_subform_ptr;
static Form color_form_ptr;
static Form weight_form_ptr;

static	int  	previous_gadget_label;
static 	IGRshort num_colors ;
static	IGRshort active_layer;
static struct 	IGRdisplay active_display;

/**********************************************************/

state_table

state start
	filter 	wfi

   on EX_FORM_FINISHED				state terminate

/* ****************************************************** */

action init
{
#include "DIdef.h"
  extern int           GRchg_adp_line_weight();
  extern int            COB_FI_form_notification();
  extern int  		COB_FI_initial_form_notification (); 
  struct GRid		VRclsymb_co;
  char			path_name[DI_PATH_MAX];
  int			type, rc;
  char 			str_ptr[DI_PATH_MAX];
  long			msg;
  struct GRid		VRclsymb_id;
  struct EX_var_list	var_list[2];
  OM_S_OBJID            mod_id;

  SetProc( init ); Begin
  /* delete by default */
  me->delete_flag = 1;
  me->form_ptr    = NULL;
  me->StyleFlag   = FALSE;
  me->LayerFlag   = FALSE;

  status = di$give_pathname( osnum 	= OM_Gw_TransOSnum_0,
			     pathname 	= path_name
			   );

  if( status != DIR_S_SUCCESS )
  {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_I_STOP_SENDING );
  }
  strcat( path_name, COMMAND_NAME );
  /*^fprintf( stderr, " Form path name is %s \n", path_name ); */

  status = di$translate ( objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &VRclsymb_co.objid,
			  p_osnum = &VRclsymb_co.osnum );

  if ( status != DIR_S_SUCCESS )
  {
    if ( status == DIR_W_NAME_NOT_FOUND )
    {

      /*^fprintf( stderr, "Couldn't find it, so trying to create my entry\n\n" ); */

      status = di$add_name( objname = path_name,
			    objid   = my_id,
			    osnum   = OM_Gw_TransOSnum_0 );

      if ( status != DIR_S_SUCCESS )
      {
         di$report_error( sts     = status,
                          comment = "Error : di$add_name" );
      }
      else
      {
        /*| name added starting initialisation */
	type = 0;
	strcpy( str_ptr , "" );
        status     = om$send( mode     = OM_e_wrt_message,
			      msg      = message CEO.init( type, str_ptr ),
			      targetid = my_id );
	as$status( action = RET_STATUS );

	/*| before name assign */
  	me->form_name = FORM_NAME ;
  	status = 0; 
  	/*| before call to FIf_new*/
	status = FIf_new ( me->form_label, me->form_name, 
				      COB_FI_form_notification, &me->form_ptr );

        __DBGpr_int( " me->form_ptr ", me->form_ptr);
  	if ( status )
 	{
    	  	me->form_ptr    = NULL;
    	  	me->state       = _terminate;
	  	me->delete_flag = 1;
	  	return ( OM_I_STOP_SENDING );
   	} 
	else
	{
     	  	/*"initialised %s ok\n", me->form_name */
     	  	/*** tell the form which cmd it's talking to ***/
     	  	status = FIf_set_cmd_oid_os (  me->form_ptr,
                                	 	my_id, OM_Gw_current_OS );
	  	if ( status )
      	  	{
	    		/*| didn't set_cmd ok */
    	    		me->state = _terminate;
	    		me->delete_flag = 1;
	    		return ( OM_I_STOP_SENDING );
      	  	}
     	  	status = FIf_set_initial_notification_routine ( me->form_ptr, 
					   COB_FI_initial_form_notification );
     	  	if ( status )
	  	{
	    		/*| didn't set initial ok */
    	    		me->state = _terminate;
	    		me->delete_flag = 1;
	    		return ( OM_I_STOP_SENDING );
      	  	}
	}

        status     = om$send( mode     = OM_e_wrt_message,
			      msg      = message VRclsymb.load_params( &msg ),
 			      targetid = my_id );
	as$status( action = RET_STATUS );

	/* -- Save current active parameters -- */
	gr$get_active_display( buffer = &active_display );
	gr$get_active_layer( buffer = &active_layer);

  	 me->delete_flag = 0;
       }
     }
    else
    {
         di$report_error( sts     = status,
                          comment = "  Unable to find my entry\n" );
    }
  }
 else if ( VRclsymb_co.objid != my_id )
  {
 	/*| CO id and my id not the same */
       me->state = _terminate;
/*       me->delete_flag = 1; */
  goto quit;
  }
  /*|  end my_init */

  me->status = ex$get_cur_mod( id = &mod_id,
                            osnum = &me->symb_id.osnum );

  status = di$give_pathname( osnum      = me->symb_id.osnum,
                                pathname   = path_name);

  if( status != DIR_S_SUCCESS )
  {
     di$report_error( sts = status,  comment = "error in give pathname" );
     return ( OM_I_STOP_SENDING );
  }
  strcat( path_name, CLSYMB_NAME );

  /*^fprintf( stderr, " Form path name is %s \n", path_name ); */

  status = di$translate ( objname = path_name,
                        osnum   = OM_Gw_TransOSnum_0,
                        p_objid = &VRclsymb_id.objid,
                        p_osnum = &VRclsymb_id.osnum );
  if ( status != DIR_S_SUCCESS )
  {
     if ( status == DIR_W_NAME_NOT_FOUND )
     {
         me->toggle_value = 1;
         FIg_set_state_on( me->form_ptr, VR_CLSYMB_TOGGLE );
         SMVA_disable( me->form_ptr, 8, COLOR, WEIGHT, STYLE,
                        LAYER, COLOR_BUTTON, WEIGHT_BUTTON,
                        STYLE_BUTTON, LAYER_BUTTON );
     }
     else
     {
        di$report_error( sts     = status,
                        comment = "  Unable to find my entry in dir\n" );
     }
  }
  else
  {
     me->toggle_value = 0;
     FIg_set_state_off( me->form_ptr, VR_CLSYMB_TOGGLE );
     SMVA_enable( me->form_ptr, 8, COLOR, WEIGHT, STYLE,
                        LAYER, COLOR_BUTTON, WEIGHT_BUTTON,
                        STYLE_BUTTON, LAYER_BUTTON );
  }
  FIf_display( me->form_ptr );

  /* color subform initialisation  */

  num_colors = 0;
  active_subform_ptr = 0;
  previous_gadget_label = 1;
  previous_subform_ptr = 0; 
  FIf_new(GRCOLOR_SUBFORM_LABEL, GRCOLOR_FORM_FILENAME,
				COB_FI_form_notification,&color_form_ptr);
      
  FIf_set_cmd_oid_os(color_form_ptr,my_id,OM_Gw_current_OS);

  FIf_set_initial_notification_routine(color_form_ptr,
					COB_FI_initial_form_notification); 

  GRdyncolorpal( &msg, GRCOLOR_PALETTE_LABEL, GRCOLOR_PALETTE_X1, GRCOLOR_PALETTE_Y1,
                 GRCOLOR_PALETTE_X2, GRCOLOR_PALETTE_Y2, color_form_ptr, &num_colors
	       );   
 
  var_list[0].var       = ADP_COLOR_NUM;
  var_list[0].var_value = ( IGRchar * ) &me->clsymb.display_attr.color;
  var_list[1].var       = ADP_END_LIST;
  status = GRupdate_adp( &msg, color_form_ptr, var_list, &rc );
       
  /*| dynamically create gadget group, set group to single select mode */

  FIg_new(me->form_ptr,FI_GROUP,POP_UP_BUTTONS);
  FIg_add_to_group(me->form_ptr,LAYER_BUTTON,POP_UP_BUTTONS);
  FIg_add_to_group(me->form_ptr, COLOR_BUTTON,POP_UP_BUTTONS);
  FIg_add_to_group(me->form_ptr, WEIGHT_BUTTON,POP_UP_BUTTONS);
  FIg_add_to_group(me->form_ptr, STYLE_BUTTON,POP_UP_BUTTONS);
  FIgrp_set_single_select_on(me->form_ptr,POP_UP_BUTTONS);

  /* weight subform initialisation routines */

  FIf_new(GRWEIGHT_SUBFORM_LABEL, GRWEIGHT_FORM_FILENAME,
				COB_FI_form_notification,&weight_form_ptr);
      
  FIf_set_cmd_oid_os(weight_form_ptr,my_id,OM_Gw_current_OS);

  FIf_set_initial_notification_routine(weight_form_ptr,
					COB_FI_initial_form_notification); 

  FIg_set_continuous_routine(weight_form_ptr,GRWEIGHT_SLIDER,
                                          &GRchg_adp_line_weight);

  var_list[0].var       = ADP_WEIGHT_NUM;
  var_list[0].var_value = ( IGRchar * ) &me->clsymb.display_attr.weight;
  var_list[1].var       = ADP_END_LIST;
  status = GRupdate_adp( &msg, weight_form_ptr, var_list, &rc );

  End

  goto quit;
}

/*********************************************************/

action wakeup
{
  int			row=0, col=0, sel_flag=0;
  IGRshort		temp_layer;
  char			path_name[DI_PATH_MAX];
  struct EX_var_list	var_list[2];
  struct GRid		VRclsymb_id;
  struct IGRdisplay	temp_display;
  OM_S_OBJID            mod_id;

  SetProc ( wakeup ); Begin
  if ( me->StyleFlag )
  {
	/*| -- Get new style from temporary changed attributes -- */
  	gr$get_active_display(  buffer = &temp_display );
	if( temp_display.style != active_display.style )
	{
		me->clsymb.display_attr.style   = temp_display.style;
		var_list[0].var       		= ADP_STYLE_NUM;
  		var_list[0].var_value 		= ( IGRchar * ) &me->clsymb.display_attr.style;
  		var_list[1].var       		= ADP_END_LIST;

		me->StyleFlag = FALSE;
 		FIfld_set_value( me->form_ptr, STYLE, row, col,
			 	(double)me->clsymb.display_attr.style, sel_flag );
		gr$put_active_display( buffer = &active_display );
		}
 }
 else
 gr$get_active_display( buffer = &active_display );
	
  if ( me->LayerFlag )
  {
  	gr$get_active_layer( buffer = &temp_layer );
	if( temp_layer != active_layer )
	{
		me->clsymb.level   = temp_layer;
 		FIfld_set_value( me->form_ptr, LAYER, row, col,
			 	 (double)me->clsymb.level, sel_flag );

		me->LayerFlag = FALSE;
		gr$put_active_layer( buffer = &active_layer );
	}
  }
  else
  gr$get_active_layer( buffer = &active_layer );

  gr$get_active_display( buffer = &active_display );
  gr$get_active_layer( buffer = &active_layer );

/*law  status = di$give_pathname( osnum      = me->symb_id.osnum, */
  status = di$give_pathname( osnum      = OM_Gw_TransOSnum_0,
				pathname   = path_name);
  if( status != DIR_S_SUCCESS )
  {
     di$report_error( sts = status,  comment = "error in give pathname" );
     return ( OM_I_STOP_SENDING );
  }
  strcat( path_name, COMMAND_NAME );

  /*^fprintf( stderr, " Form path name is %s \n", path_name ); */
  status = di$translate ( objname = path_name,
			osnum   = OM_Gw_TransOSnum_0,
			p_objid = &VRclsymb_id.objid,
			p_osnum = &VRclsymb_id.osnum );
  if ( VRclsymb_id.objid != my_id )
  {
 	/*| CO id and my id not the same */
goto quit;
  }
  me->status = ex$get_cur_mod( id = &mod_id,
                            osnum = &me->symb_id.osnum );

  status = di$give_pathname( osnum      = me->symb_id.osnum,
                                pathname   = path_name);

  if( status != DIR_S_SUCCESS )
  {
     di$report_error( sts = status,  comment = "error in give pathname" );
     return ( OM_I_STOP_SENDING );
  }
  strcat( path_name, CLSYMB_NAME );

  /*^fprintf( stderr, " Form path name is %s \n", path_name ); */
  status = di$translate ( objname = path_name,
			osnum   = me->symb_id.osnum,
			p_objid = &VRclsymb_id.objid,
			p_osnum = &VRclsymb_id.osnum );

  if (me->toggle_value)
  {
     FIg_set_state_on( me->form_ptr, VR_CLSYMB_TOGGLE );
     SMVA_disable( me->form_ptr, 8, COLOR, WEIGHT, STYLE,
		LAYER, COLOR_BUTTON, WEIGHT_BUTTON,
		STYLE_BUTTON, LAYER_BUTTON );
  }
  else
  {

     FIg_set_state_off( me->form_ptr, VR_CLSYMB_TOGGLE );
     SMVA_enable( me->form_ptr, 8, COLOR, WEIGHT, STYLE,
			LAYER, COLOR_BUTTON, WEIGHT_BUTTON,
			STYLE_BUTTON, LAYER_BUTTON );
  }

  End

  goto quit;
}

/*********************************************************/

action sleep
{
  SetProc( sleep ); Begin
  status = OM_S_SUCCESS;

  /* -- Get new style from temporary changed attributes -- */
  gr$put_active_display( buffer = &active_display );

  /* -- Get new layer from temporary changed attributes -- */
  gr$put_active_layer( buffer = &active_layer );
  End 

  goto quit;
}

/*********************************************************/

action load_params
{
  OM_S_OBJID		mod_id;

  SetProc( load_params ); Begin
  status = OM_S_SUCCESS;

  me->status = ex$get_cur_mod( id = &mod_id,
			    osnum = &me->symb_id.osnum );

  VR$symbology(  return_code = &( me->status ),
  		  symb_id     = &( me->symb_id ),
  		  symb	      = &( me->clsymb ) );

  me->status    = om$send( targetid = my_id,
			   mode   = OM_e_wrt_message,
			   msg    = message VRclsymb.update_form( &status,
							    &(me->symb_id) ) );
  End

  goto quit;
}

action update_form( int * sts; struct GRid * symb_id )
{

  Form			form_ptr;
  int			row=0;
  int			col=0;
  int			sel_flag=0;
  char			text[12];

  SetProc( update_form ); Begin
  if ( symb_id != NULL )
  {
	me->symb_id.objid = symb_id->objid;
	me->symb_id.osnum = symb_id->osnum;
  }

  if ( me->form_ptr != NULL )	form_ptr = me->form_ptr;
  else
  {
     	me->state = _terminate;
     	me->delete_flag = 1;
     	return( OM_I_STOP_SENDING );
  }

  me->prev_layer       =  me->clsymb.level;
  me->prev_weight      =  me->clsymb.display_attr.weight;
  me->prev_color      =  me->clsymb.display_attr.color;
  me->prev_style       =  me->clsymb.display_attr.style;

  /*" Set Layer \n"*/
  FIfld_set_value( form_ptr, LAYER, row, col, (double)me->clsymb.level,
		   sel_flag );

  
  /*" Set Weight\n"*/
  FIfld_set_value( form_ptr, WEIGHT, row, col,
		   (double)me->clsymb.display_attr.weight,
		   sel_flag );

  /*" Set Style\n"*/
  FIfld_set_value( form_ptr, STYLE, row, col,
		   (double)me->clsymb.display_attr.style,
		   sel_flag );

  /*" Set Colour \n"*/
  status = 0;
  status = ige$get_name_from_color ( color = me->clsymb.display_attr.color, 
			             name  = text );
  if ( !status )
  {
    	/*"get name failed with %d\n", me->clsymb.display_attr.color */
	if ( me->clsymb.display_attr.color < GR_LO_COLOR ||
			me->clsymb.display_attr.color > GR_HI_COLOR )
	{
    	   strcpy( text, "red" );
    	   ige$get_color_from_name( 
			color = (short *)&(me->clsymb.display_attr.color),
			name  = text );
	}
	else
	   sprintf( text, "%d", me->clsymb.display_attr.color );
   }

  row=0;
  col=0;
  sel_flag = 0;
  /*" setting color with text %s\n", text*/
  FIfld_set_text( form_ptr, COLOR, row, col,  
		         text,
			 sel_flag ); 
  End

  goto quit;

} /* update_form */


action delete
{
   SetProc( delete ); Begin
   if ( me->form_ptr != NULL )	{
       __DBGpr_int( " me->form_ptr", me->form_ptr );
       FIf_erase( me->form_ptr );
/*       FIf_delete( me->form_ptr ); */
   }
   status = om$send( targetid = my_id,
		      mode   = OM_e_wrt_message,
		      msg    = message CEO.delete ( 0 ));
   End

  goto quit;

} /* delete */


action form_notification
{
  struct GRevent 	event;
  struct IGRdisplay	display;
  IGRchar		text[MAX_FIELD];
  IGRchar		text_stripped[MAX_FIELD];
  IGRint		sel_flag;
  IGRint		r_pos;
  IGRint		type;
  IGRint		row = 0, col = 0;
  IGRint		num_char;
  IGRlong       	buffersize;
  IGRlong       	form_mask;
  IGRdouble  		value;
  char			error=0;
  int			rc;
  long			msg;
  struct EX_var_list	var_list[2];
  char			path_name[DI_PATH_MAX];
  struct GRid		VRclsymb_id;

  SetProc( form_notification ); Begin
  switch (form_label)
   {
    	case MAIN :
        	/*| main form routine */
       		if ( me->form_ptr == NULL || me->form_ptr != form_ptr )
          	{
           		/*| error with form_ptr */
            		me->state = _terminate;
            		me->delete_flag = 1;
            		return ( OM_I_STOP_SENDING );
          	}
        	else 
          	{
           		/*| form_ptr ok */
          	}

          	num_char = MAX_FIELD;

         	/*"form label %d  gadget label %d\n", form_label, gadget_label  */

       		switch(gadget_label)
        	{
         		case LAYER_BUTTON:
         		case COLOR_BUTTON:
         		case WEIGHT_BUTTON:
         		case STYLE_BUTTON:
			case VR_CLSYMB_TOGGLE:
           		break;
         		default: 

         		FIfld_get_type( form_ptr, gadget_label, col, &type );

         		if ( type == FI_DOUBLE || type == FI_INT )
            		{
             			FIfld_get_value( form_ptr, gadget_label, row, col,
		        		 	 &value, &sel_flag, &r_pos );

	     			/*" value is %d, %f \n", value, value */
            		}
           		else if ( type == FI_ALPHA )	
            		{
             			FIfld_get_text( form_ptr, gadget_label, row,col,
		       				num_char, (unsigned char *)text,
						 &sel_flag, &r_pos );
            		}
          		else
	    			/*| TYPE OF GADGET NOT DEFINED probably a button*/;
        	} /* end switch */

         	switch(gadget_label)
         	{  
          		case WEIGHT: 
             			FIfld_set_text( form_ptr, MESSAGE, row, col,  "", 
						sel_flag );
             			if ( value >= GR_LO_WEIGHT && value <= GR_HI_WEIGHT )
                 		{
                 			me->clsymb.display_attr.weight = value;
  		 			var_list[0].var       = ADP_WEIGHT_NUM;
		 			var_list[0].var_value = ( IGRchar * ) &me->clsymb.display_attr.weight;
		 			var_list[1].var       = ADP_END_LIST;
		 			status = GRupdate_adp( &msg, weight_form_ptr, 
								var_list, &rc );

                 			me->prev_weight  = me->clsymb.display_attr.weight;
                 			/*| Valid weight entered  */
                 			/*^fprintf(stderr,"value of valid weight %d \n",
						   me->prev_weight); */ 
                 			/*^fprintf(stderr,"me-< disp at wt %d \n",
						   me->clsymb.display_attr.weight); */ 

                 			error = 0;
                		}
               			else
                		{
	                   		FIfld_set_text( form_ptr, MESSAGE, row, col,  
		                     			"Invalid Weight Entered",
			                            	sel_flag );
                  			me->clsymb.display_attr.weight = me->prev_weight;
                  			/*^fprintf(stderr,"me-< disp at wt %d \n",me->clsymb.display_attr.weight); */ 
 
                  			FIfld_set_value( form_ptr, WEIGHT, row, col,  
		         				(double)me->clsymb.display_attr.weight,
			 				sel_flag );  
	          			error = 1;
                		}
     				break;

         		case LAYER: 
            			FIfld_set_text( form_ptr, MESSAGE, row, col,  "", sel_flag );

            			if ( value > GR_LO_LAYER && value <= GR_HI_LAYER) 
               			{ 
					me->clsymb.level = value; 
                 			me->prev_layer = me->clsymb.level; 
                 			error =0; 
               			} 
                		else 
               			{ 
                			FIfld_set_text( form_ptr, MESSAGE, row, col,  
		        				"Invalid Layer Value Entered",
			 				sel_flag );
                			me->clsymb.level = me->prev_layer;
                			/*^fprintf(stderr,"me-> clsymb.level %d \n",me->clsymb.level); */ 
                			FIfld_set_value( form_ptr, LAYER, row, col,  
		         				 (double)me->clsymb.level,
			 				 sel_flag );
	        			error = 1;
                		}
             		break;

          		case STYLE: 
               			FIfld_set_text( form_ptr, MESSAGE, row, col,  "", sel_flag );
               			if ( value >= GR_LO_STYLE && value <= GR_HI_STYLE)
                  		{
                   		me->clsymb.display_attr.style = ( IGRuchar )value;
                   		me->prev_style = me->clsymb.display_attr.style; 
  		   			var_list[0].var       = ADP_STYLE_NUM;
		   			var_list[0].var_value = ( IGRchar * ) &me->clsymb.display_attr.style;
		   			var_list[1].var       = ADP_END_LIST;
                   			error = 0;
                  		}
                		else
                  		{
                   			FIfld_set_text( form_ptr, MESSAGE, row, col,  
		        				"Invalid Line Style Entered",
			 				sel_flag );
                   			me->clsymb.display_attr.style = me->prev_style; 
                   			/*^fprintf(stderr,"prev style %d \n",me->prev_style); */
                   			/*^fprintf(stderr,"me-> clsymb.display_attr.style %d \n",me->clsymb.display_attr.style); */ 
                   			FIfld_set_value( form_ptr, STYLE, row, col,  
		         				 (double)me->clsymb.display_attr.style,
			 				 sel_flag );
	           			error = 1;
                  		}
             		break;

          case COLOR:
             FIfld_set_text( form_ptr, MESSAGE, row, col,  "", sel_flag ); 

             VR_strip_space( text, text_stripped ); 

	     if ( VRlocate_pattern( text_stripped, "yellowYellowYELLOW4") >= 0 )
	     {
	      	strcpy( text, "yellow" );
	     }
	     else if ( VRlocate_pattern( text_stripped, "greenGreenGREEN3" ) >= 0 )
	     {
	       	strcpy( text, "green" );
	     }
	     else if ( VRlocate_pattern( text_stripped, "redRedRED2" ) >=0 )
	     {
	       	strcpy( text, "red" );
	     }
	     else if ( VRlocate_pattern( text_stripped, "blueBlueBLUE1" ) >=0 )
	     {
	       	strcpy( text, "blue" );
	     }
             status = 0;
             status = ige$get_color_from_name( 
			name = text, 
			color = (short *)&(me->clsymb.display_attr.color));
             /*^fprintf(stderr,"name of selected color %s \n",text); */ 
              if ( !status )
                 {
                  FIfld_set_text( form_ptr, MESSAGE, row, col,  
		                             "Color Not Known",
		                                 	 sel_flag );
                  status = ige$get_name_from_color ( 
					color = me->clsymb.display_attr.color, 
					name  = text );
		  if ( !status&1 )
			sprintf( text, "%d", me->clsymb.display_attr.color );

                  FIfld_set_text( form_ptr, COLOR, row, col,  text, sel_flag );
	          error = 1;
                 }   
                else
                 {
                  display.color 	= me->clsymb.display_attr.color;
  		  var_list[0].var       = ADP_COLOR_NUM;
		  var_list[0].var_value = ( IGRchar * ) &display.color;
		  var_list[1].var       = ADP_END_LIST;
		  status = GRupdate_adp( &msg, color_form_ptr, var_list, &rc );
                  }

             break;

          case VR_CLSYMB_TOGGLE:
		if (  me->toggle_value )
		{
                   me->toggle_value = 0;
                   FIg_set_state_off( me->form_ptr, VR_CLSYMB_TOGGLE );
                    /* Enable other gadgets */
                   SMVA_enable( me->form_ptr, 8, COLOR, WEIGHT, STYLE,
					LAYER, COLOR_BUTTON, WEIGHT_BUTTON,
					STYLE_BUTTON, LAYER_BUTTON );
                }
                else
                {
                     /** delete the clsymb object in directory subsystem */
		  me->toggle_value = 1;
                  FIg_set_state_on( me->form_ptr,VR_CLSYMB_TOGGLE );
                  SMVA_disable( me->form_ptr, 8, COLOR, WEIGHT, STYLE,
					LAYER, COLOR_BUTTON, WEIGHT_BUTTON,
					STYLE_BUTTON, LAYER_BUTTON );
                }
                break;

          case WEIGHT_BUTTON:
          case COLOR_BUTTON: 
          	if (previous_subform_ptr !=  0) FIf_erase(previous_subform_ptr);
 
               	switch(gadget_label)
                {
                 	case WEIGHT_BUTTON:
                      		active_subform_ptr = weight_form_ptr;
				value = me->clsymb.display_attr.weight;

                            	GRupdweightform( &msg,
                                                 me->clsymb.display_attr.weight,
                                                 active_subform_ptr);
                      		FIg_set_state_off(active_subform_ptr,FI_ACCEPT); 
                    	break;
                 	case COLOR_BUTTON:
                      		active_subform_ptr = color_form_ptr;
                      	break;
                }    
                 
                FIf_get_attr(active_subform_ptr,&form_mask);

                if (! (form_mask & FI_SAVE_RESTORE)) 
                {
                	form_mask |= FI_SAVE_RESTORE;
                    	FIf_set_attr(active_subform_ptr,form_mask);
                }
                
                if (previous_gadget_label == gadget_label)
                {
                        previous_gadget_label = 0; 
                      	FIg_set_state_off(me->form_ptr,gadget_label); 
                }
                else
                {  
                   	FIf_display(active_subform_ptr);
                   	previous_gadget_label = gadget_label;
                 	previous_subform_ptr  = active_subform_ptr; 

                }
                break;

          case STYLE_BUTTON:
		me->StyleFlag = TRUE;
                if (active_subform_ptr != 0)
                { 
                     	FIf_erase(active_subform_ptr);
                     	active_subform_ptr = NULL;
                }
                FIg_set_state_off(me->form_ptr,STYLE_BUTTON);
		event.response = EX_CMD_KEY;
                buffersize = 9;
                ex$putque( msg      = &msg,
                           response = (IGRint *)&event.response,
                           byte     = &buffersize,
                           buffer   = "GRDfLnSt");
         	break;

          case LAYER_BUTTON:
		me->LayerFlag = TRUE;
                if (active_subform_ptr != 0)
                { 
                    	FIf_erase(active_subform_ptr);
                     	active_subform_ptr = 0;
                }
                FIg_set_state_off(me->form_ptr,LAYER_BUTTON);
		 
                event.response = EX_CMD_KEY;
                buffersize = 7;
                ex$putque( msg      = &msg,
                           response = &event.response,
                           byte     = &buffersize,
                           buffer   = "GRSALy");
               	break;
          
          case EXIT_NOSAVE:
          case EXIT_SAVE:
           	FIf_delete(color_form_ptr);
           	FIf_delete(weight_form_ptr);

          switch(gadget_label)
          {
            	case EXIT_NOSAVE:
             		FIbtn_set_auto_pop_up_on( form_ptr, EXIT_NOSAVE );
             		FIf_delete( form_ptr );
			_put_response( resp = EX_FORM_FINISHED );
             		return ( status );

          	case EXIT_SAVE:
			if( me->toggle_value )
			{
	   status = di$give_pathname( osnum = me->symb_id.osnum,
						pathname        = path_name);
			   if( status != DIR_S_SUCCESS )
			   {
		  	     di$report_error( sts = status,
				comment = "error in give pathname" );
		  	     return ( OM_I_STOP_SENDING );
			   }
			   strcat( path_name, CLSYMB_NAME );

			   /*^fprintf( stderr, " Form path name is %s \n", */
			   /* path_name ); */

			   status = di$translate ( objname = path_name,
					osnum     = me->symb_id.osnum,
					p_objid = &VRclsymb_id.objid,
					p_osnum = &VRclsymb_id.osnum );
			   if( status == DIR_S_SUCCESS )
			   {
			      om$send(msg = message Root.delete(1),
					targetid = VRclsymb_id.objid,
					targetos = VRclsymb_id.osnum,
					senderid = NULL_OBJID );
                	   }
/* Deleted since we dont care if its there - law-
			   else
			   {
                     	       di$report_error( sts     = status,
			         comment = "Unable to find my entry in dir\n" );
			   }
*/
			}
			else
			{
  	     		  VR$symbology(   return_code = &( me->status ),
   		 			operation   = STORE,
 		  			symb_id     = &( me->symb_id ),
  		  			symb	    = &( me->clsymb ) );
             		  FIfld_set_text( form_ptr, MESSAGE, row, col,  
		       			"Values Stored", sel_flag );
			}

/*             		FIbtn_set_auto_pop_up_on( me->form_ptr, EXIT_SAVE ); */
	FIf_delete( me->form_ptr );

			_put_response( resp = EX_FORM_FINISHED );
             		return ( status );
            }

            break; 
            default:
	     	/*^printf( "gadget_label %d unknown\n", gadget_label ); */
	   break;

         } /* end switch gadget label  me-> form_label */
       break;

    	case   GRCOLOR_SUBFORM_LABEL:
       		/*| form_label = color sub form */
        
		/*^fprintf(stderr," gadget label %d",gadget_label); */ 
         	switch(gadget_label)
         	{ 
            		case GRCOLOR_BACKGROUND_BUTTON: 
               		{ 
                  		display.color  	      = 0;
  		  		var_list[0].var       = ADP_COLOR_NUM;
		  		var_list[0].var_value = ( IGRchar * ) &display.color;
		  		var_list[1].var       = ADP_END_LIST;
		  		status = GRupdate_adp( &msg, color_form_ptr, var_list, &rc );
                	} 
                  	break; 
          
           		case FI_ACCEPT:
             		{	
              			/*| COLOR SUBFORM LABEL ACCEPTED */
              			FIg_set_state_off(me->form_ptr,COLOR_BUTTON);
              			status = ige$get_name_from_color(
					color =  me->clsymb.display_attr.color,
							name  = text);
				if( ! status&1 )
				{
				   text[0] = '\0';
				   sprintf( text, "%d",
						me->clsymb.display_attr.color );
				}

              			FIfld_set_text(me->form_ptr,COLOR,row,col,text,sel_flag);
              			/*^fprintf(stderr,"selected color = %s \n",text); */ 
              			FIf_erase(color_form_ptr);
              			active_subform_ptr = 0;
              			previous_subform_ptr = 0;
              			previous_gadget_label = 0;
             		}
            		break;

            		case FI_CVT_TO_PERM_WIN: 
                 		/* forms interface software converts the save and
                    		    restore window to a permanent window */
                 	break;

            		default:
                	{  
              			/*^stderr,"gadget_label %d \n",gadget_label */ 
                 		me->clsymb.display_attr.color = 
			( IGRushort ) (gadget_label - GRCOLOR_PALETTE_LABEL);

            			status = ige$get_name_from_color(
					color = me->clsymb.display_attr.color, 
							name = text);
				if ( ! status&1 )
				{
					text[0] = '\0';
					sprintf( text, "%d",
						me->clsymb.display_attr.color );
				}

				FIfld_set_text(me->form_ptr,
						COLOR,row,col,text,sel_flag);
             			/*^fprintf(stderr," color %s \n ",text); */
              		break;
                	} 

      		} /* color subform switch statement */
            	break;

            	case GRWEIGHT_SUBFORM_LABEL:
              	switch(gadget_label)
               	{
                	case FI_ACCEPT:
                  		/*| accept weight subform */
                  		FIg_set_state_on(weight_form_ptr,FI_ACCEPT);
                  		me->prev_weight = me->clsymb.display_attr.weight;
                  		status = FIfld_set_value(me->form_ptr,WEIGHT,
							row,col,
                  					(double)me->clsymb.display_attr.weight,sel_flag);             
                  		/*"update weight value %d \n",me->clsymb.display_attr.weight */
                  		FIg_set_state_off(me->form_ptr,WEIGHT_BUTTON);
                  		FIf_erase(weight_form_ptr);
                  		active_subform_ptr = 0; 
                		previous_subform_ptr = 0; 
                  		previous_gadget_label = 0;
                  	break;
                	case GRWEIGHT_FIELD:
                	case GRWEIGHT_SLIDER:
                 		switch(gadget_label)
                 		{
                   		case GRWEIGHT_FIELD:
                      			FIfld_get_value(weight_form_ptr,gadget_label,row,col,
                                  			&value,&sel_flag,&r_pos);  
                      			/*^fprintf(stderr,"value of grweight_filed %d \n",value); */ 
                      			if(( value >= GR_LO_WEIGHT) && (value <= GR_HI_WEIGHT))
                        		{
                         			me->clsymb.display_attr.weight = (double)value;
                         			/*^fprintf(stderr,"me->clsymb.disp attr wt %d \n",me->clsymb.display_attr.weight); */ 
                         			display.weight = me->clsymb.display_attr.weight;
                      				/*" active display.weight %d",active_display.weight */  
                        		}
                      		break;
                    		case GRWEIGHT_SLIDER:
                       			FIg_get_value(weight_form_ptr,gadget_label,&value); 
                       			/*"slider value %d \n",value */
                       			me->clsymb.display_attr.weight = (double)value;
                       			display.weight = me->clsymb.display_attr.weight;
                      
                  		break;
                		} /*  slider / weight field switch statemet */ 
                  		/*| update weight form \n */
  		 		var_list[0].var       = ADP_WEIGHT_NUM;
		 		var_list[0].var_value = ( IGRchar * ) &display.weight;
		 		var_list[1].var       = ADP_END_LIST;
		 		status = 
				GRupdate_adp( &msg, weight_form_ptr, var_list, &rc );
                  	break;
                	default:
                  	break; 
               }  /* end weight subform switch statement */
            break;
  }   /* end form_notification  switch statement */
 
	if ( ! error )	/* clear message field */
	          FIfld_set_text( form_ptr, MESSAGE, row, col,  " ", sel_flag );

  End 

  goto quit;

 } /* end method */

