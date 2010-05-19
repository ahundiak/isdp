/* $Id: VDCmdRep.sl,v 1.2 2001/10/24 21:12:39 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrep/cmd / VDCmdRep.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRep.sl,v $
 *	Revision 1.2  2001/10/24 21:12:39  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/22  23:51:18  pinnacle
# Replaced: ./vdrep/cmd/VDCmdRep.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * History:
 *
 * adz	01/31/94  Revision for I/EMS  3.0
 *
 */
command_string       VDC_M_StAcErSy, 0, VDStAcErSy
command_table        "vds.cmd"
class                VDCmdRep
product_name         "$VDS_PATH"
start_state          start
super_class          VDS_LOCATE


/*******************************************************************/

specification

/****************************************************************************

		Specification file for command object
              "Set Active Error Symbology ",0, VDStAcErSy

	override delete of CEO in order to keep form displayed & active

	override init of CEO so that self destruct if command occurrence
	is already out there. Don't want two commands changing the same
	global data.

	Form control of the persistant form is within the command and
	not under COB, due to problems with overriding delete and the
	management of several commands with persistant forms.

****************************************************************************/

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "FI.h"
#include "FEI.h"
#include "VDSsymb_def.h"

instance
{
	/* same as super class + */

   struct VDSsymb       vdssymb;     /* change to pointer to char */
   struct GRid		symb_id;
   char			delete_flag;
   char			operation;
   int			status;
   /* Form control */

   char *		form_name;
   int			form_label;
   Form  		form_ptr;

   /* previous valid field values */

   int                  prev_weight,
                        prev_style;
   short                prev_layer;
   unsigned  char       prev_layer_name[15]; 
}

implementation

/****************************************************************************

		Implementation file for command object
        "Set Active Error Symbology ",0, VDStAcErSy

***************************************************************************/

#include "OMparameters.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "msmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "adpdef.h"
#include "dpmacros.h"
#include "dperr.h"
#include "VDCmdRep.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"

#include "AS_status.h"
#include "AS_debug.h"
#include "FI.h"
#include "FEI.h"
#include "dpdls.h"
#include "grpgendef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ex.h"
#include "go.h"
#include "griodef.h" 
#include "grio.h"
#include "griomacros.h"
#include "comiscmac.h"
#include "grmessage.h"

#define		MAIN			0
#define		MAX_FIELD		256
#define		COMMAND_NAME		":IGENOD:VDCmdRep_comm_id"
#define		FORM_NAME		"VDErrorSymb"
#define		MAX_STRLEN		64;

#define		VDS_STYLE_FORM_FILENAME	"GRDefineLine"

extern IGRushort dp_bit_pattern[MAX_STYLES];
extern IGRint GRnumber_conversion();


Form    previous_subform_ptr; 
Form    active_subform_ptr;
Form    color_form_ptr;
Form    weight_form_ptr;
Form    style_form_ptr;
int     previous_gadget_label;
static  IGRshort num_colors ;
struct  IGRdisplay active_display;

/* from CEO	import form_notification; **/


/**********************************************************/

state_table

#define MAIN 0

state start

   on CMD_TYPE = 0				state terminate

/*
 **************************************************************************
 */
action init
{
extern void     GRchg_adp_line_weight();
extern void     COB_FI_form_notification();
extern void 	COB_FI_initial_form_notification (); 
struct GRid	VDCmdRep_co;
char		path_name[DI_PATH_MAX];
int		type;
char 		str_ptr[DI_PATH_MAX];
IGRlong		msg;

  /* delete by default */
  me->delete_flag = 1;
  me->form_ptr = NULL;

  status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

  if( status != DIR_S_SUCCESS )
  {
    di$report_error( sts = status,  comment = "error in give pathname" );	
    return ( OM_I_STOP_SENDING );
  }

  strcat( path_name, COMMAND_NAME );

  status = di$translate ( objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &VDCmdRep_co.objid,
			  p_osnum = &VDCmdRep_co.osnum );

  if ( status != DIR_S_SUCCESS )
  {
    if ( status == DIR_W_NAME_NOT_FOUND )
    {

     /*
      * fprintf(" Couldn't find it, so trying to create my entry\n\n" );
      */

 
      status = di$add_name( objname = path_name,
			    objid   = my_id,
			    osnum   = OM_Gw_TransOSnum_0 );

      if ( status != DIR_S_SUCCESS ){
         di$report_error( sts     = status,
                          comment = "Error : di$add_name" );
      }
      else{

        /*| name added starting initialisation */
	type = 0;
	strcpy( str_ptr , "" );
        status     = om$send(   targetid = my_id,
				mode   = OM_e_wrt_message,
				msg    = message CEO.init( type, str_ptr ) );
	as$status( action = RET_STATUS );

  	me->form_name = FORM_NAME ;
  	status = 0; 
	status = FIf_new ( me->form_label,
                     	   me->form_name,
                     	   COB_FI_form_notification,
                     	   &me->form_ptr );
  	if ( status ){

    	  me->form_ptr = NULL;
    	  me->state  = _terminate;
	  me->delete_flag = 1;
	  return ( OM_I_STOP_SENDING );
   	} 
	else{

     	  /*** tell the form which cmd it's talking to ***/
     	  status = FIf_set_cmd_oid_os (  me->form_ptr,
                                	 my_id, OM_Gw_current_OS );
	  if ( status )
      	   {
    	    me->state = _terminate;
	    me->delete_flag = 1;
	    return ( OM_I_STOP_SENDING );
      	   }
     	  status = FIf_set_initial_notification_routine ( me->form_ptr,
                                COB_FI_initial_form_notification );
     	  if ( status )
	   {
    	    me->state = _terminate;
	    me->delete_flag = 1;
	    return ( OM_I_STOP_SENDING );
      	   }
	 }
         status     = om$send(  msg = message VDCmdRep.load_params( &msg ),
				targetid = my_id );
	 as$status( action = RET_STATUS );
  	 me->delete_flag = 0;
	 FIf_display( me->form_ptr );
	}
     }
    else
    {
         di$report_error( sts     = status,
                          comment = "  Unable to find my entry\n" );
    }
  }
  else if ( VDCmdRep_co.objid != my_id )
  {
    /* CO id and my id not the same */
    me->delete_flag = 1;
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }


   /*
    * color subform initialisation
    */
   num_colors = 0;
   active_subform_ptr = 0;
   previous_gadget_label = 1;
   previous_subform_ptr = 0; 

   status = FIf_new(	GRCOLOR_SUBFORM_LABEL,
			GRCOLOR_FORM_FILENAME,
			COB_FI_form_notification,
			&color_form_ptr);
   if ( status ) {
     printf(" FIf_new: GRCOLOR_SUBFORM_LABEL: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }
      
   status = FIf_set_cmd_oid_os(color_form_ptr,my_id,OM_Gw_current_OS);
   if ( status ) {
     printf(" FIf_set_cmd_oid_os: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }

   FIf_set_initial_notification_routine(color_form_ptr,
					COB_FI_initial_form_notification); 
   if ( status ) {
     printf(" FIf_set_initial_notification_routine: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }


   /*
    * dynamic creation of color palette
    *	./co/adpco/GRdynclrpal.C
    */
   GRdyncolorpal(	&msg,
			GRCOLOR_PALETTE_LABEL,
			GRCOLOR_PALETTE_X1,
			GRCOLOR_PALETTE_Y1,
			GRCOLOR_PALETTE_X2,
			GRCOLOR_PALETTE_Y2,
			color_form_ptr,
			&num_colors);   
   if( msg != MSSUCC ){
     printf(" GRdyncolorpal: %d \n", msg );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }
	

   /*"number of active colors %d \n",num_colors */ 

   active_display.color =  me->vdssymb.VDSerror.display_attr.color;

   /*
    * update color sub_form
    *   ./co/adpco/GRupdclrform.C
    */
   GRupdcolorform(	&msg,
			active_display.color,
			num_colors,
			color_form_ptr );
       
   /* dynamically create gadget group, set group to single select mode */

   FIg_new(me->form_ptr,FI_GROUP,POP_UP_BUTTONS);
   FIg_add_to_group(me->form_ptr, SET_ADP_LAYER_BUTTON,POP_UP_BUTTONS);
   FIg_add_to_group(me->form_ptr, SET_ADP_COLOR_BUTTON,POP_UP_BUTTONS);
   FIg_add_to_group(me->form_ptr, SET_ADP_WEIGHT_BUTTON,POP_UP_BUTTONS);
   FIg_add_to_group(me->form_ptr, SET_ADP_STYLE_BUTTON,POP_UP_BUTTONS);
   FIgrp_set_single_select_on(me->form_ptr,POP_UP_BUTTONS);

   /*
    * weight subform initialisation routines
    */
   status = FIf_new(	GRWEIGHT_SUBFORM_LABEL,
			GRWEIGHT_FORM_FILENAME,
			COB_FI_form_notification,
			&weight_form_ptr);
   if ( status ) {
     printf(" FIf_new(GRWEIGHT_SUBFORM_LABEL: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }
      
   status = FIf_set_cmd_oid_os(weight_form_ptr,my_id,OM_Gw_current_OS);
   if ( status ) {
     printf(" FIf_set_cmd_oid_os: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }

   status = FIf_set_initial_notification_routine(weight_form_ptr,
					COB_FI_initial_form_notification); 
   if ( status ) {
     printf(" FIf_set_initial_notification_routine: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }

   status = FIg_set_continuous_routine(weight_form_ptr,GRWEIGHT_SLIDER,
                                          GRchg_adp_line_weight);
   if ( status ) {
     printf(" FIf_set_continuous_routine: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }

   active_display.weight = me->vdssymb.VDSerror.display_attr.weight;

   GRupdweightform(&msg,active_display.weight,weight_form_ptr);

   /*
    * style subform initialisation routines
    */
   status = FIf_new(	GRSTYLE_SUBFORM_LABEL,
			VDS_STYLE_FORM_FILENAME,
			COB_FI_form_notification,
			&style_form_ptr);
   if ( status ) {
     printf(" FIf_new(GRSTYLE_SUBFORM_LABEL: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }
      
   status = FIf_set_cmd_oid_os(style_form_ptr,my_id,OM_Gw_current_OS);
   if ( status ) {
     printf(" FIf_set_cmd_oid_os: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }

   status = FIf_set_initial_notification_routine(style_form_ptr,
				COB_FI_initial_form_notification); 
   if ( status ) {
     printf(" FIf_set_initial_notification_routine: %d \n", status );
     me->form_ptr = NULL;
     me->state  = _terminate;
     me->delete_flag = 1;
     return ( OM_I_STOP_SENDING );
   }

   /*
    * create the outfit of the form.
    */
   {
     IGRuchar *p_mask;
     IGRdouble tmp_dbl;
     IGRuchar style_mask[STYLE_MASK_SIZE];
     char pattern_buff[20], buf[256];
     IGRint ii, jj, kk, sts, alpha, (*func)();
     struct GRmd_env mod;

     gr$get_module_env(buffer = &mod);
 
     func = GRnumber_conversion;
     alpha = FALSE; ii = LO_STYLE; jj = HI_STYLE;
     p_mask = style_mask;
     msg = GR_E_InvSt;
     sts = GRparse_multiple_entry_keyin(buf, p_mask, func, alpha,
                                                   ii, jj, mod.md_id.osnum);
 
     FIg_erase(style_form_ptr,11);
     FIg_erase(style_form_ptr,14);
     FIg_erase(style_form_ptr,15);
     FIg_erase(style_form_ptr,16);
     for ( ii = 19; ii < 36; ii++) FIg_erase(style_form_ptr,ii);
     /*
      * Set the number of rows.
      */
     FIfld_set_max_num_rows(style_form_ptr, LINESTYLE_FIELD, MAX_STYLES);

     /*
      * Get the linestyle patterns.
      */

     for ( ii = 0; ii < MAX_STYLES; ii++)
     {
       DPinq_style(ii, &dp_bit_pattern[ii]);
     }

     /*
      * Set the linestyle field with the index and the corresponding
      * linestyle pattern.
      */

     for( ii = 0; ii < MAX_STYLES; ii++ )
     {
       tmp_dbl = (IGRdouble) ii;
       FIfld_set_value(style_form_ptr, LINESTYLE_FIELD, ii, 0, tmp_dbl, FALSE);
       DPpattern(dp_bit_pattern[ii], pattern_buff);
       FIfld_set_text(style_form_ptr, LINESTYLE_FIELD, ii, 1, pattern_buff, FALSE);
     }
 
     FIfld_get_text(style_form_ptr, STYLE_FIELD, 0, 0, BUFSIZ,
                           (unsigned char *) buf, &ii, &jj );
     COactgad(buf, style_form_ptr, style_mask,
            STYLE_MASK_SIZE, STYLE_SYMB, LO_STYLE, HI_STYLE,
            mod.md_id.osnum, STYLE_FORM, LO_STYLE, HI_STYLE);


   }

   active_display.style =  me->vdssymb.VDSerror.display_attr.style;

   /* GRupdstyleform(&msg,active_display.style,style_form_ptr);  */
   FIg_set_state_on(style_form_ptr,
			active_display.style + GRSTYLE_FIRST_CHECKLIST);
} 


/*********************************************************/

action load_params
{
OM_S_OBJID	mod_id;

  me->operation = RETRIEVE;
  me->status = ex$get_cur_mod( id = &mod_id, osnum = &me->symb_id.osnum );

  me->status = vd$symbology(	msg	= sts,
				symb_id	= &( me->symb_id ),
				symb	= &( me->vdssymb) );

  me->status =
  om$send(msg = message VDCmdRep.update_form( sts, &(me->symb_id)),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
}

action save_params
{
  me->operation	= STORE;

  me->status = vd$symbology(	msg	  = sts,
				operation = me->operation,
				symb_id   = &( me->symb_id ),
				symb	  = &( me->vdssymb) );
}

action update_form( long * sts; struct GRid * symb_id )
{
Form	form_ptr;
int	col = 0, row = 0;
int	sel_flag = 0;
IGRchar text[12];
IGRlong	msg, buffersize;
struct  GRid  module_grid;
IGRshort      num_levels;
IGRchar    info_string[64];
 
  if ( symb_id != NULL ){
    me->symb_id.objid = symb_id->objid;
    me->symb_id.osnum = symb_id->osnum;
  }

  if( me->form_ptr != NULL )	form_ptr = me->form_ptr;
  else{
    me->state = _terminate;
    me->delete_flag = 1;
    return( OM_I_STOP_SENDING );
  }

  /*
   * Save previous values in instances.
   */
  me->prev_layer  = me->vdssymb.VDSerror.level; 
  me->prev_weight = me->vdssymb.VDSerror.display_attr.weight;
  me->prev_style  = me->vdssymb.VDSerror.display_attr.style;

  /*
   * set level number and name (is given)
   */
  FIfld_set_value( form_ptr, SET_ADP_LAYER_NUM, row, col,
		   (double)me->vdssymb.VDSerror.level,
		   sel_flag );

  strcpy(text,"");
  ex$get_cur_mod(id    = &module_grid.objid,
                 osnum = &module_grid.osnum);
  
  buffersize   = MAX_STRLEN;
  dp$levels_number_to_name(msg       = &msg,
                           name      = text, 
                           number    = me->vdssymb.VDSerror.level,
                           ret_num_lev = &num_levels,
                           size_name_buffer = &buffersize,
                           mod_objid = module_grid.objid,
                           osnum     = module_grid.osnum);

  if ((msg == DPAMBIGUOUS) && (num_levels == 1)) {
      ex$message(msgnumb = GR_I_ActLyNo, buff = info_string);
      strcpy((char *) me->prev_layer_name,text);
      FIfld_set_text(form_ptr,SET_ADP_MSG_FIELD,row,col,info_string,sel_flag);
  }
  else if (!(msg & 1) || (num_levels  > 1)) {
       text[0] = NULL_CHAR;   
  }

  FIfld_set_text( form_ptr, SET_ADP_LAYER_NAME,row,col,text,sel_flag ); 

  /*
   * set error weight and style
   */
  FIfld_set_value( form_ptr, SET_ADP_WEIGHT_NUM, row, col,
		   (double)me->vdssymb.VDSerror.display_attr.weight,
		   sel_flag );

  FIfld_set_value( form_ptr, SET_ADP_STYLE_NUM, row, col,
		   (double)me->vdssymb.VDSerror.display_attr.style,
		   sel_flag );

  /*
   * set error color and color name
   */
  status =
  ige$get_name_from_color( color = me->vdssymb.VDSerror.display_attr.color, 
			   name  = text );
  if( status == FALSE ){ strcpy(text,""); } 

  row=0;
  col=0;
  sel_flag = 0;
  FIfld_set_text( form_ptr, SET_ADP_COLOR_NAME,row,col,text,sel_flag ); 
  FIfld_set_value(form_ptr, SET_ADP_COLOR_NUM, row, col,
		   (double)me->vdssymb.VDSerror.display_attr.color,
		   sel_flag );
}


action delete
{
  if( me->delete_flag ){
    
    if( me->form_ptr != NULL ) FIf_delete( me->form_ptr );

    status = om$send( targetid = my_id,
			mode   = OM_e_wrt_message,
			msg    = message CEO.delete ( 0 ));
    return ( OM_S_SUCCESS );
  }
  else{
    return ( OM_S_SUCCESS );
  }
}

action form_notification
{
  struct GRevent event;
  IGRchar	text[MAX_FIELD];
  IGRint	sel_flag;
  IGRint	r_pos;
  IGRint	type;
  IGRint	row = 0, col = 0;
  IGRint	num_char;
  IGRlong       buffersize;
  IGRlong       form_mask;
  IGRdouble  	value;
  int   	temp_double;
  char		error = 0;
  IGRshort      active_layer;
  IGRshort      num_levels;
  struct  GRid  module_grid; 
  IGRlong   msg;
  IGRchar     info_string[64];

  switch (form_label)
  {
    case MAIN :

      /*
       * main form  routine
       */
      if ( me->form_ptr == NULL  || me->form_ptr != form_ptr ){
        me->state = _terminate;
        me->delete_flag = 1;
        return ( OM_I_STOP_SENDING );
      }

      num_char = MAX_FIELD;

      /*
       * check the button on the main form
       */
      switch(gadget_label)
      {
        /*| ascertain whether a button has been pressed */ 
        case SET_ADP_LAYER_BUTTON:
        case SET_ADP_COLOR_BUTTON:
        case SET_ADP_WEIGHT_BUTTON:
        case SET_ADP_STYLE_BUTTON:
        case EXIT_SAVE:
        case EXIT_NOSAVE:  
            /*|   non input form gadgets  */
           break;
        default: 

        FIfld_get_type( form_ptr, gadget_label, col, &type );
        if( type == FI_DOUBLE || type == FI_INT )
        {
          FIfld_get_value(form_ptr,gadget_label,row,col,&value,
						&sel_flag,&r_pos );
        }
        else if( type == FI_ALPHA )	
        {
          FIfld_get_text(form_ptr,gadget_label,row,col,num_char,text,
						&sel_flag,&r_pos );
        }

      } /* end switch gadget_label */

      switch(gadget_label)
      {
        case SET_ADP_WEIGHT_NUM: 

          FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col, "", sel_flag);

          if( value >= GR_LO_WEIGHT && value <= GR_HI_WEIGHT )
          {
            /*
	     * Valid weight entered
	     */
            me->vdssymb.VDSerror.display_attr.weight = value;
            GRupdweightform(	&msg,
				me->vdssymb.VDSerror.display_attr.weight,
				weight_form_ptr); 
            me->prev_weight  = me->vdssymb.VDSerror.display_attr.weight;
            error = 0;
          }
          else{
            FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col,  
		                     "Invalid Weight Entered", sel_flag );
            me->vdssymb.VDSerror.display_attr.weight = me->prev_weight;
            FIfld_set_value( form_ptr, SET_ADP_WEIGHT_NUM, row, col,  
		             (double)me->vdssymb.VDSerror.display_attr.weight,
			     sel_flag );  
	    error = 1;
          }

          break;

        case SET_ADP_LAYER_NAME:

          FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col, "", sel_flag);

          ex$get_cur_mod(	id = &module_grid.objid,
                             osnum = &module_grid.osnum);
          /*
	   * printf("layer name %s  \n", text );
	   */
          active_layer = NULL;
          dp$levels_name_to_number(msg = &msg,
                                   name = text,
                                   number = &active_layer,
                                   mod_objid = module_grid.objid,
                                   osnum = module_grid.osnum);

          if( msg & 1){

            me->vdssymb.VDSerror.level = (double)active_layer; 
	    /*
	     * printf(" active layer d %d", active_layer );
	     */
            FIfld_set_value( form_ptr, SET_ADP_LAYER_NUM, row, col,  
		         	(double)me->vdssymb.VDSerror.level,
				 sel_flag );

            me->prev_layer = me->vdssymb.VDSerror.level; 
            strcpy((char *) me->prev_layer_name,text);
          } 
          else if( active_layer == NULL ){
            /*
	     * no such layer number
	     */
            ex$message(	msgnumb = GR_E_InvLy,
			buff    = text);

            FIfld_set_text(form_ptr, SET_ADP_MSG_FIELD,row,col,text,sel_flag);
            FIfld_set_text(form_ptr, SET_ADP_LAYER_NAME, row, col,
					me->prev_layer_name,sel_flag); 
          } 
          else{
            strcpy(text,"The active layer has multiple names");
            FIfld_set_text(form_ptr,SET_ADP_MSG_FIELD,row,col,text,sel_flag);
            FIfld_set_text(form_ptr,SET_ADP_LAYER_NAME,row,col,
				me->prev_layer_name,sel_flag); 
          }

          break;

        case SET_ADP_LAYER_NUM: 

          FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD,row,col,"",sel_flag);

          if( value > GR_LO_LAYER && value <= GR_HI_LAYER ){

            me->vdssymb.VDSerror.level = value; 
            me->prev_layer = me->vdssymb.VDSerror.level; 

            /*
	     * printf(" me->prev layer %d \n",me->prev_layer );
             * printf("me-> vdssymb.VDSerror.level %d \n",me->vdssymb.VDSerror.level);
             * VDSprint_symb(&(me->vdssymb));
	     */

            error = 0; 

	    ex$get_cur_mod(	id    = &module_grid.objid,
				osnum = &module_grid.osnum);
  
	    buffersize   = MAX_STRLEN;

	    dp$levels_number_to_name(
			msg       = &msg,
                        name      = text, 
                        number    = me->vdssymb.VDSerror.level,
                        ret_num_lev = &num_levels,
                        size_name_buffer = &buffersize,
                        mod_objid = module_grid.objid,
                        osnum     = module_grid.osnum);

	    if( (msg == DPAMBIGUOUS) && (num_levels == 1) ){

	      ex$message(	msgnumb = GR_I_ActLyNo,
                 		buff    = info_string);

		FIfld_set_text(form_ptr,SET_ADP_MSG_FIELD,row,col,
					info_string,sel_flag);
     	    }
	    else if (!(msg & 1) || (num_levels  > 1) ){
	      text[0] = NULL_CHAR;  
	      me->prev_layer_name[0] = NULL_CHAR;
	    }

	    FIfld_set_text( form_ptr, SET_ADP_LAYER_NAME, row, col, text, sel_flag ); 

          } 
          else{
	    /*
	     * Invalid layer value enetered by the user.
	     */
            FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col,  
				"Invalid Layer Value Entered", sel_flag );

            me->vdssymb.VDSerror.level = me->prev_layer;
            /*
	     * printf("me-> vdssymb.VDSerror.level %d \n",
	     *			me->vdssymb.VDSerror.level); 
	     */
            FIfld_set_value( form_ptr, SET_ADP_LAYER_NUM, row, col, 
				(double)me->vdssymb.VDSerror.level,
				sel_flag );
	    error = 1;
          }

          break;

        case SET_ADP_STYLE_NUM: 

          FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col,"", sel_flag );

          if( value >= GR_LO_STYLE && value <= GR_HI_STYLE ){

            me->vdssymb.VDSerror.display_attr.style = value;
            me->prev_style = me->vdssymb.VDSerror.display_attr.style;

	    /*
	     * Following fonction doesn't exists in 2.0.
	     * Replace by it's extension
	     */
            /* GRupdstyleform(&msg,me->vdssymb.VDSerror.display_attr.style,
				style_form_ptr); */

	    FIg_set_state_on( style_form_ptr,
				   me->vdssymb.VDSerror.display_attr.style 
					+ GRSTYLE_FIRST_CHECKLIST );     
            error = 0;
          }
          else {
	    /*
	     * error input value
	     */
            FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col,  
		 	       "Invalid Line Style Entered",
				 sel_flag );
            me->vdssymb.VDSerror.display_attr.style = me->prev_style; 
        
            FIfld_set_value( form_ptr, SET_ADP_STYLE_NUM, row, col,  
		         (double)me->vdssymb.VDSerror.display_attr.style,
			 sel_flag );
	    error = 1;
          }

          break;

        case SET_ADP_COLOR_NUM:

          FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD,row,col,"",sel_flag);

          temp_double = value;

          if( (temp_double   >= GR_LO_COLOR) &&
              (temp_double   <= GR_HI_COLOR)){

            active_display.color = temp_double; 
            me->vdssymb.VDSerror.display_attr.color  = active_display.color;

            status = 
 	    ige$get_name_from_color(
			color = me->vdssymb.VDSerror.display_attr.color,
			name = text);
            if( status == FALSE ) { strcpy( text, "" ); }
            FIfld_set_text(form_ptr,SET_ADP_COLOR_NAME,row,col,text,sel_flag);
          }
          else{
	    /*
	     * Invalid color value given.
	     */
            FIfld_set_text(form_ptr,SET_ADP_MSG_FIELD,row,col,
                                   "Color Not Known",sel_flag);
            FIfld_set_value(form_ptr,SET_ADP_COLOR_NUM,row,col,
                     (double)me->vdssymb.VDSerror.display_attr.color,sel_flag); 
          }

	  /*
           * Update the color form.
	   */
          GRupdcolorform(&msg,active_display.color,num_colors,
                                                color_form_ptr);
          break;

        case SET_ADP_COLOR_NAME:

          FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col,"", sel_flag );

          status = ige$get_color_from_name(
			color = (IGRshort *) &active_display.color,
			name = text );

          if( status == TRUE ){
            /* ok get color from name */ 
            me->vdssymb.VDSerror.display_attr.color = active_display.color;
            FIfld_set_value(form_ptr,SET_ADP_COLOR_NUM,row,col,
                	(double)me->vdssymb.VDSerror.display_attr.color,
			sel_flag); 
          }
          else{
            /*
	     * Invalid error message
	     */
            FIfld_set_text(form_ptr,SET_ADP_MSG_FIELD,row,col,
                                   "Color Not Known",sel_flag);

	    status = 
            ige$get_name_from_color(color=active_display.color,name = text);
            if( status == FALSE ) text[0] = '\0';
            FIfld_set_text(form_ptr,SET_ADP_COLOR_NAME,row,col,text,sel_flag);
          } 
                
          /*
	   * printf(" display attr.color %d \n",active_display.color );
	   */
          GRupdcolorform(&msg,active_display.color,num_colors,color_form_ptr);
                
          break;

        case SET_ADP_WEIGHT_BUTTON:

        case SET_ADP_STYLE_BUTTON:

        case SET_ADP_COLOR_BUTTON: 
	  /*
	   * erase the existing subform if active
	   */
          if( previous_subform_ptr != 0 )
                     FIf_erase( previous_subform_ptr );
 
          switch(gadget_label)
          {
            case SET_ADP_WEIGHT_BUTTON:
              active_subform_ptr = weight_form_ptr;
              break;
            case SET_ADP_STYLE_BUTTON:
              active_subform_ptr = style_form_ptr;
              break;
            case SET_ADP_COLOR_BUTTON:
              active_subform_ptr = color_form_ptr;
              break;
          }    

          FIf_get_attr( active_subform_ptr, &form_mask );

          if( ! (form_mask & FI_SAVE_RESTORE )){
            form_mask |= FI_SAVE_RESTORE;
            FIf_set_attr(active_subform_ptr,form_mask);
          }
                
          if( previous_gadget_label == gadget_label ){
              previous_gadget_label = 0; 
            FIg_set_state_off(me->form_ptr,gadget_label); 
          }
          else{  
	    FIg_set_state_off( active_subform_ptr, FI_ACCEPT );
	    FIg_set_state_off( active_subform_ptr, FI_CANCEL );
            FIf_display(active_subform_ptr);
            previous_gadget_label = gadget_label;
            previous_subform_ptr = active_subform_ptr; 
          }

          break;

        case SET_ADP_LAYER_BUTTON:

          if( active_subform_ptr != 0 ){ 
            FIf_erase(active_subform_ptr);
            active_subform_ptr = 0;
          }
         
          FIg_set_state_off(me->form_ptr,SET_ADP_LAYER_BUTTON);
          event.response = EX_CMD_KEY;
          buffersize = 7;

          ex$putque(	msg      = &msg,
                        response = &event.response,
                        byte     = &buffersize,
                        buffer   = "GRSALy");
  
          break;
          
        case EXIT_NOSAVE:
        case EXIT_SAVE:

          /*
	   * before message to save params
	   */
          status = om$send(  targetid = my_id,
				/*mode   = OM_e_wrt_message, */ 
				msg = message VDCmdRep.save_params( &msg ));
	  as$status( );

          /*
	   * exit case statement
	   */
          FIf_delete( color_form_ptr );
          FIf_delete( style_form_ptr );
          FIf_delete( weight_form_ptr );

          switch(gadget_label)
          {
            case EXIT_NOSAVE:

              /*
	       * exit no save
	       */
              break;

            case EXIT_SAVE:

              /*
	       * exit save
	       */
              FIbtn_set_auto_pop_up_on( form_ptr, EXIT_SAVE );
              FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col,  
			       "Values Stored", sel_flag );
              me->delete_flag = 1;			
              status = om$send( targetid = my_id,
				  mode     = OM_e_wrt_message,
				  msg      = message VDCmdRep.delete( 0 ) );
              return ( status );
          }

          break; 

        default:

	  break;
       } /* end switch gadget label  me->form_label */
       
       break;

    /*
     * COLOR SUB_FORM USER INTERFACE CONTROL
     */

    case   GRCOLOR_SUBFORM_LABEL:

      switch(gadget_label){
 
        case GRCOLOR_BACKGROUND_BUTTON: 

          active_display.color = 0;
          GRupdcolorform(&msg,active_display.color, num_colors,color_form_ptr);
          break; 
          
        case FI_ACCEPT:

          FIg_set_state_off(me->form_ptr,SET_ADP_COLOR_BUTTON);
          me->vdssymb.VDSerror.display_attr.color = active_display.color;   
	  status = 
          ige$get_name_from_color(color = active_display.color,name = text);
	  if( status == FALSE ) text[0] = '\0';
          FIfld_set_value(me->form_ptr,SET_ADP_COLOR_NUM,row,col,
               (double)me->vdssymb.VDSerror.display_attr.color,sel_flag);             
          FIfld_set_text(me->form_ptr,SET_ADP_COLOR_NAME,row,col,text,sel_flag);
          FIf_erase(color_form_ptr);

          active_subform_ptr = 0;
          previous_subform_ptr = 0;
          previous_gadget_label = 0;

        break;

      case FI_CVT_TO_PERM_WIN: 
        /* forms interface software converts the save and
                  restore window to a permanent window */
        break;

      default:

        active_display.color = (short unsigned)
				 (gadget_label - GRCOLOR_PALETTE_LABEL);
	status =
        ige$get_name_from_color(color = active_display.color, name = text);
	if( status == FALSE ) text[0] ='\0';
        break;
      }

      break;

    /*
     * WEIGHT SUB_FORM USER INTERFACE CONTROL
     */

    case GRWEIGHT_SUBFORM_LABEL:

      switch( gadget_label ){
        
	case FI_ACCEPT:
          /*| accept weight subform */
          me->prev_weight = me->vdssymb.VDSerror.display_attr.weight;
          status = FIfld_set_value(me->form_ptr,SET_ADP_WEIGHT_NUM,row,col,
			(double)me->vdssymb.VDSerror.display_attr.weight,
			sel_flag);             
          if (!status) {
	    /*
	     * weight field not updated
	     */
	  }

          FIg_set_state_off(me->form_ptr,SET_ADP_WEIGHT_BUTTON);
          FIf_erase(weight_form_ptr);
          active_subform_ptr = 0; 
          previous_subform_ptr = 0; 
          previous_gadget_label = 0;

          break;

        case GRWEIGHT_FIELD:
        case GRWEIGHT_SLIDER:

          switch(gadget_label){

            case GRWEIGHT_FIELD:

              FIfld_get_value(weight_form_ptr,gadget_label,row,col,
                                  &value,&sel_flag,&r_pos);  
              if(( value >= GR_LO_WEIGHT) && (value <= GR_HI_WEIGHT)){
                me->vdssymb.VDSerror.display_attr.weight = (double)value;
                active_display.weight = me->vdssymb.VDSerror.display_attr.weight;
              }
              break;

            case GRWEIGHT_SLIDER:
              FIg_get_value(weight_form_ptr,gadget_label,&value); 
              me->vdssymb.VDSerror.display_attr.weight = (double)value;
              active_display.weight = me->vdssymb.VDSerror.display_attr.weight;
                      
              break;
          } /*  slider / weight field switch statemet */ 

	  /*
	   * update weight form
	   */
          GRupdweightform(&msg,active_display.weight,weight_form_ptr);

          break;

        default:

          break; 
      }  /* end weight subform switch statement */

      break;

    /*
     * STYLE SUB_FORM USER INTERFACE CONTROL
     */
    case GRSTYLE_SUBFORM_LABEL:

      switch (gadget_label){

        case FI_ACCEPT:
          FIg_set_state_off(me->form_ptr,SET_ADP_STYLE_BUTTON); 
          FIf_erase(style_form_ptr); active_subform_ptr = 0;
          previous_subform_ptr = 0;
          previous_gadget_label = 0;
          FIfld_set_value(me->form_ptr,SET_ADP_STYLE_NUM,row,col,
		(double)me->vdssymb.VDSerror.display_attr.style,sel_flag);
          me->prev_style = me->vdssymb.VDSerror.display_attr.style;
          break;

        case FI_CVT_TO_PERM_WIN:
          break;

        default:

          gadget_label -= GRSTYLE_FIRST_CHECKLIST;

          if( ( gadget_label >= GR_LO_STYLE) && 
              ( gadget_label <= GR_HI_STYLE)) 
            active_display.style = (IGRuchar) gadget_label;

          me->vdssymb.VDSerror.display_attr.style = active_display.style; 

	  /* Following fonction doesn't exists in 2.0.
	     Replace by it's extension
	   */
          FIg_set_state_on(style_form_ptr,
			  active_display.style + GRSTYLE_FIRST_CHECKLIST);   

          break; 
        }   /* end style subform switch statement */

        break;

  } /* end form_notification  switch statement */

  /*
   * clear the message field.
   */
  if ( ! error )
	FIfld_set_text( form_ptr, SET_ADP_MSG_FIELD, row, col, " ", sel_flag );
}

