/* $Id: VDCmdLcNm.sl,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/cmd / VDCmdLcNm.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdLcNm.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/05/12  13:51:04  pinnacle
# ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1995/11/10  08:39:36  pinnacle
# Replaced: vdlocate/cmd/VDCmdLcNm.sl for:  by rgade for vds.240
#
# Revision 1.6  1995/11/08  14:59:06  pinnacle
# Replaced: vdlocate/cmd/VDCmdLcNm.sl for:  by yzhu for vds.240
#
# Revision 1.5  1995/10/26  20:17:50  pinnacle
# Replaced: vdlocate/cmd/VDCmdLcNm.sl for:  by yzhu for vds.240
#
# Revision 1.3  1995/10/17  18:05:56  pinnacle
# Replaced: vdlocate/cmd/VDCmdLcNm.sl for:  by yzhu for vds.240
#
# Revision 1.2  1995/08/07  23:15:40  pinnacle
# Replaced: vdlocate/cmd/VDCmdLcNm.sl for:  by azuurhou for vds.240
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
 *      05/11/99        ylong           TR179802375      
 * -------------------------------------------------------------------*/

/*\
Description
   This is the command class for generating a select set by selecting
   the individual elements that should be in the set.  The select set is
   placed on the input queue.

History
   10-09-91 Genesis at ISDC
\*/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */

command_string  VDC_M_LocName, 0, VDLcNm
class           VDCmdLcNm
super_class     CEO_GSLOCATE				/* CEO_GSLOCATE */
product_name    "$VDS"
command_table   "vds.cmd"

start_state	start

/* --------------------------------------------------------------------- */
/* SPECIFICATION AREA */


specification

#include "VDmsg.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "VDSpathdef.h"
#include "VDStextdef.h"
#include "VDmsg.h"

instance
{
	struct GRid		gs_id;
	struct GRmd_env		act_env;	

	IGRchar			expr_dir[DI_PATH_MAX];	
	IGRint			del_flag;
	IGRchar			*my_form_ptr;

	IGRint			disp_index;
	struct	VDStextset	disp_text;
	struct	VDStextlist	text_list;

	IGRchar			event_str[DI_PATH_MAX];

}

/* --------------------------------------------------------------------- */
/* IMPLEMENTATION AREA */
implementation

#include <stdio.h>
#include <string.h>
/*
#define vdsDEBUG        1
#define vdserrDEBUG     1
*/

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "OMmacros.h"
#include "exdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "asmacros.h"
#include "VDSudp_mac.h"

#include "exmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "COBmacros.h"

#include "FI.h"
#include "AS_status.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "EC_S.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#define	INSIDE          1
#define OUTSIDE         0
#define LO_COLOR        0
#define HI_COLOR        512
#define LO_STYLE        0
#define HI_STYLE        8
#define LO_WEIGHT       0
#define HI_WEIGHT       32
#define WEIGHT_DEFINED  1
#define COLOR_DEFINED   2
#define STYLE_DEFINED   4

/* #define AS_DEBUG	1  */


%safe
static int 	x_memo = -1,
       		y_memo = -1,
       		exist_CO;

%endsafe

/* --------------------------------------------------------------------- */
/* STATES AREA */

state_table

#include	"grmessage.h"
#include	"griodef.h"
#include	"msdef.h"
#include	"lcdef.h"
#include	"VDmsg.h"
#include	"VDStextdef.h"

state *
	on  EX_DATA.GRst_PERPEND_FROM				state HaveError
	on  EX_DATA.GRst_ANGLE_FROM				state HaveError
	on  EX_DATA.GRst_TANGENT_FROM				state HaveError
	on  EX_DATA.GRst_PERPEND_TO				state HaveError
	on  EX_DATA.GRst_ANGLE_TO				state HaveError

/* ======================================================================== */

state start
	on ELSE	state terminate  

/* ======================================================================== */
state HaveError
   	status_key	VD_E_InvData
   	on ELSE							state -

/* ======================================================================== */



/* ----------------------------------------------------
/* Description
/*    This action will initialise the form environment.
/* 
/* Notes
/* ---------------------------------------------------- */
action init
/*.init*/
{
extern void	COB_FI_form_notification();
extern void	COB_FI_initial_form_notification ();
struct GRid	VDSpath_co;
char		path_name[DI_PATH_MAX],str_ptr[DI_PATH_MAX], form_name[DI_PATH_MAX];
long		sizebuf, sts, nret, msg;


  SetProc( VDCmdLcNm.init ); Begin

  status = OM_S_SUCCESS ;
  me->del_flag = FALSE;

  me->text_list.num_textset = 0;
  me->text_list.inc_textset = 0;
  me->text_list.max_textset = 0;
  me->text_list.text = NULL;

  exist_CO = 1;
  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = &msg,
                      sizbuf  = &sizebuf,
                      buffer  = &me->act_env,
                      nret    = &nret);
  if(!(msg & 1)){
	printf("ERROR gr$get_module_env\n");
     	me->del_flag = TRUE;
     	return ( OM_I_STOP_SENDING );
  }
  /*"act_env: %d, %d\n",me->act_env.md_id.objid,me->act_env.md_id.osnum*/

  status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );
  if( status != DIR_S_SUCCESS ){
     di$report_error( sts = status,  comment = "error in give pathname" );	
     me->del_flag = TRUE;
     return ( OM_I_STOP_SENDING );
  }
  strcat( path_name, ":IGENOD:VDSpath_text_id" );
  /*" Form pathname<%s> \n", path_name */

  status = di$translate ( objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &VDSpath_co.objid,
			  p_osnum = &VDSpath_co.osnum );

  if( status != DIR_S_SUCCESS ){


    if( status == DIR_W_NAME_NOT_FOUND ){

      /*| create my entry */
      status = di$add_name( objname = path_name,
			    objid   = my_id,
			    osnum   = OM_Gw_TransOSnum_0 );

      if( status != DIR_S_SUCCESS ){
         di$report_error( sts     = status,
                          comment = "Error : di$add_name" );
      }
      else{
        /*| name added starting initialisation */
	type = 0;
	str_ptr[0] = '\0';
        status     = om$send( 	msg	 = message CEO_GSLOCATE.init( type, str_ptr ),
				mode	 = OM_e_wrt_message,
				targetid = my_id );
	if(!(status & 1)){
		printf("error CEO_LOCATE.init\n");
		me->del_flag = 1;
		as$status( );
     		return ( OM_I_STOP_SENDING );
     	}

	/*| name assign */
  	strcpy( form_name, "VDLocName" );
  	status = 0; 
	me->my_form_ptr = NULL;
  	/*| call to FIf_new */
	status = FIf_new ( 0, form_name, COB_FI_form_notification,
                     	   &me->my_form_ptr );

  	if( status != FI_SUCCESS ){
	  /*" error %d in FIfnew of [%s]\n", status, form_name */
	  me->my_form_ptr = NULL;
	  me->state = _terminate;
	  me->del_flag = TRUE;
	  return ( OM_I_STOP_SENDING );
   	} 
	else{
     	  /*" initialised [%s] ok\n", form_name */
     	  /*** tell the form which cmd it's talking to ***/
     	  status = FIf_set_cmd_oid_os (  me->my_form_ptr,
                                	 my_id, OM_Gw_current_OS );
	  if ( status )
      	   {
	    /*| didn't set_cmd ok */
    	    me->state = _terminate;
	    me->del_flag = TRUE;
	    return ( OM_I_STOP_SENDING );
      	   }
     	  status = FIf_set_initial_notification_routine ( me->my_form_ptr,
                                COB_FI_initial_form_notification );
     	  if( status ){
	    /*| didn't set initial ok */
    	    me->state = _terminate;
	    me->del_flag = TRUE;
	    return ( OM_I_STOP_SENDING );
      	   }
	}
   
        status = om$send(msg = message  VDCmdLcNm.VDSinit_select_form
							( &sts),
			targetid = my_id );
	as$status( );
	if(!(status & sts & 1)){
		printf("error VDCmdLcNm.VDSinit_select_form\n");
		me->del_flag = 1;
     		return ( OM_I_STOP_SENDING );
     	}
        status = om$send( msg = message  VDCmdLcNm.VDSdisplay_select_form
							( &sts),
			targetid = my_id );
	as$status( );
	if(!(status & sts & 1)){
		printf("error VDCmdLcNm.VDSdisplay_select_form\n");
		me->del_flag = 1;
     		return ( OM_I_STOP_SENDING );
     	}
      }
    }
    else{ /* status == DIR_W_NAME_NOT_FOUND */
	di$report_error(sts     = status,
			comment = "  Unable to find my entry\n" );
    }
  } 
  else if ( VDSpath_co.objid != my_id )
  {
    __DBGpr_com(" VDSpath_co.objid != my_id ");
    /*| CO id and my id not the same */
    /*"CO id: %d, %d\n",VDSpath_co.objid,VDSpath_co.osnum*/
    me->state = _terminate;
    /* modify by yz 10/17/95 for tr179526022 
    	me->del_flag = TRUE;
    */
    return( OM_I_STOP_SENDING );
  }

  End
  goto quit ;
} 


/* ----------------------------------------------------
/* Description
/* 	delete the SelectSet form from the screen
/*	and cleans the allocated memory
/* ---------------------------------------------------- */
action delete
/*.delete*/
{
int	sts;

  SetProc( VDCmdLcNm.delete); Begin
  /*" my_id is %d\n", my_id */
  status = OM_S_SUCCESS ;
  if ( me->my_form_ptr != NULL )
     FIf_get_location(me->my_form_ptr,&x_memo,&y_memo);

  if( me->del_flag ){

    if( me->text_list.text != NULL ){
      /*| delete memory of the textset list */
      	free( me->text_list.text );
	me->text_list.text = NULL;
    }

    if( me->my_form_ptr != NULL ){
      /*| delete the form */
      FIf_delete( me->my_form_ptr );
      me->my_form_ptr = NULL;
    }

    /*| delete the active graphic set */
    status = gr$gsdissolve( msg	    = (long *)&sts,
                   	  object_id = &me->gs_id );
    if( sts != MSSUCC){
	om$report_error( sts = status );
    }
    
    if(exist_CO){
    	status = om$send( 	msg      = message CEO_GSLOCATE.delete ( 0 ),
		    	mode	 = OM_e_wrt_message,
			targetid = my_id );
    	if(!(status & 1)){
		printf("error CEO.delete\n");
		as$status( );
     		return ( OM_I_STOP_SENDING );
    	}
   }
   exist_CO = 0;

  }

  End
  goto quit ;
}

/* ----------------------------------------------------
/* Description
/*    This action will construct a graphcis set.
/* 
/* Notes
/*    This action sets up the following local instance data:
/*       -  me->gs_id
/* ---------------------------------------------------- */
action VDSconstruct_graphics_set			extern



/* ----------------------------------------------------
/* Description
/*    This action define the graphics set as the active select set.
/* 
/* Notes
/*    This action depends upon the following local instance data:
/*       -  me->gs_id
/* ---------------------------------------------------- */
action VDSselect_graphics_set				extern


/* ----------------------------------------------------
/* Description
/*    This action will put the select set onto the event queue.
/* Notes
/*    This action depends upon the following local instance data:
/*       -  me->gs_id
/*       -  me->window_id
/* ---------------------------------------------------- */
action VDSput_setqueue					extern

/* ----------------------------------------------------
/* Description
/*    This action will do the foolowing actions
/*	- construction of the graphic set
/*	- build active locate criteria
/*	- graphic set post processing
/*	- evaluate total string
/*	- put result in event queue
/*  --------------------------------------------------- */
action VDSevaluate_active_event				extern

/* ----------------------------------------------------
/* Description
/*    This action will push the accept event onto the event queue.
/*  --------------------------------------------------- */
action VDSevaluate_string(	int *sts;
				struct GRid **list_id; 
				struct GRmd_env **env_list; 
				int  *nb_list;
				int  *max_list)
							extern

/* ----------------------------------------------------
/* Description
/*    This action will initialise the form environment
/*    and read the information from a reference directory
/* ---------------------------------------------------- */
action VDSinit_select_form				extern



/* ----------------------------------------------------
/* Description
/* 	add a list of textsets to the list, and update 
/*	the form. If the name of a set already exist in 
/*	the list, the set is overriden only if option = 1. 
/* ---------------------------------------------------- */
action VDSadd_textsets(
			long			*sts;
			struct VDStextlist	list;
			int			act_nb;
			int			option;)

/*.VDSadd_textsets*/
{
int		i,resp,no_disp ,added;
 
 SetProc( VDCmdLcNm.VDSadd_textsets ); Begin
 status = OM_S_SUCCESS ;
 *sts = MSSUCC;
 no_disp = 0;

/*| fill instance text_list */

 for(i=0;i<list.num_textset;i++){
	resp = VDSadd_in_textset_list(	&me->text_list,
					&list.text[i],
					option ,
					&added);
	if( ! resp ){
	      printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	      *sts = MSFAIL; goto wrapup;
	}
  	if(added == 0 && i == act_nb) no_disp = 1;
 }

/*| fill instance disp_text */
if(no_disp == 0){
 strcpy( me->disp_text.select, list.text[act_nb].select );
 strcpy( me->disp_text.prefix, list.text[act_nb].prefix );
 strcpy( me->disp_text.expres, list.text[act_nb].expres );
 strcpy( me->disp_text.suffix, list.text[act_nb].suffix );
}
/*| Update form */

 resp = VDSfill_textset_list(	&me->text_list,
				me->my_form_ptr, 
				VDS_SELECT_FLD );
 if( ! resp ){
	  printf(" ERROR: fct VDSfill_textset_list failed \n");
	  *sts = MSFAIL; goto wrapup;
 }
    

 /*| display the text in the fields */
 resp = FIg_set_text( me->my_form_ptr, VDS_EXPRES_FLD, me->disp_text.expres );
 if( resp != FI_SUCCESS ){ *sts = MSFAIL; goto wrapup;}

 resp = FIg_set_text( me->my_form_ptr, VDS_PREFIX_FLD, me->disp_text.prefix );
 if( resp != FI_SUCCESS ){ *sts = MSFAIL; goto wrapup; }

 resp = FIg_set_text( me->my_form_ptr, VDS_SUFFIX_FLD, me->disp_text.suffix );
 if( resp != FI_SUCCESS ){ *sts = MSFAIL; goto wrapup; }

 resp = FIg_set_text( me->my_form_ptr, VDS_SELECT_FLD, me->disp_text.select );
 if( resp != FI_SUCCESS ){ *sts = MSFAIL; goto wrapup; }


  *sts = MSSUCC;
  End
  return( OM_S_SUCCESS );

wrapup:
  *sts = MSFAIL;
  End
  goto quit ;
}

/* ----------------------------------------------------
/* Description
/* 	display the SelectSet form on the screen
/* ---------------------------------------------------- */
action VDSdisplay_select_form
{
/*.VDSdisplay_select_form*/

  SetProc( VDCmdLcNm.VDSdisplay_select_form ); Begin
  *sts = MSSUCC;

  /*| display the text in the fields */
  status = FIg_set_text( me->my_form_ptr, VDS_EXPRES_FLD, me->disp_text.expres );
  if( status != FI_SUCCESS ){
	  me->state = _terminate; return( OM_I_STOP_SENDING );
  }
  status = FIg_set_text( me->my_form_ptr, VDS_PREFIX_FLD, me->disp_text.prefix );
  if( status != FI_SUCCESS ){
	  me->state = _terminate; return( OM_I_STOP_SENDING );
  }
  status = FIg_set_text( me->my_form_ptr, VDS_SUFFIX_FLD, me->disp_text.suffix );
  if( status != FI_SUCCESS ){
	  me->state = _terminate; return( OM_I_STOP_SENDING );
  }
  status = FIg_set_text( me->my_form_ptr, VDS_SELECT_FLD, me->disp_text.select );
  if( status != FI_SUCCESS ){
	  me->state = _terminate; return( OM_I_STOP_SENDING );
  }
  
  FIg_set_state_off( me->my_form_ptr, FI_CANCEL );
  FIg_set_state_off( me->my_form_ptr, FI_RESET );
  FIg_set_state_off( me->my_form_ptr, FI_EXECUTE );
  FIg_set_state_off( me->my_form_ptr, FI_ACCEPT );
  
  FIg_set_state_off( me->my_form_ptr, VDS_READ_BUT );
  FIg_set_state_off( me->my_form_ptr, VDS_WRITE_BUT );
  FIg_set_state_off( me->my_form_ptr, VDS_ACTIVE_BUT );

  if(x_memo != -1 || y_memo != -1) 
		FIf_set_location(me->my_form_ptr,x_memo,y_memo);

  /* display the form on the screen */
  status = FIf_display( me->my_form_ptr );

  End
  goto quit ;
}
/* ----------------------------------------------------
/* Description
/* 	fill the instances with the expressions found 
/*	in the directory VDS_EXPR_DIR
/* ---------------------------------------------------- */
action VDSfill_instances(long *sts)
{
/*.VDSfill_instances*/
  int		resp;
  struct GRid	tmp_id;

  IGRchar	expr_dir[DI_PATH_MAX];

  SetProc( VDCmdLcNm.VDSfill_instances ); Begin
  *sts = MSSUCC;

  /*| get_cur_mod */
  status = ex$get_cur_mod(   id = &tmp_id.objid,
			  osnum = &tmp_id.osnum );

  /*| give pathname */
  status = di$give_pathname(osnum  = tmp_id.osnum ,
 			  pathname = expr_dir );
  if( status != DIR_S_SUCCESS ){
	printf("error di$give_pathname\n");goto wrapup;
  }
  /*" active file <%s> \n", expr_dir */

  strcat( expr_dir, VDS_EXPR_DIR );
  /*" expr_dir : <%s> \n", expr_dir */
  strcpy(me->expr_dir,expr_dir);
  
  resp = VDSread_expr_dir(	&me->text_list, 
				me->expr_dir, 
				&(me->act_env) );
  if( ! resp ){
	  printf(" ERROR: fct VDSread_expr_dir failed\n");
	  goto wrapup;
  }
  resp = VDSget_select_text(	&me->text_list, 
				&me->disp_text, 
				me->expr_dir, 
				&(me->act_env) );
  if( ! resp ){
	    printf(" ERROR: fct VDSget_select_text failed\n");
	    goto wrapup;
  }

  End
  return( OM_S_SUCCESS );

wrapup:
  *sts = MSFAIL;
  End
  goto quit ;
}

/* ----------------------------------------------------
/* Description
/*    This action will do the intreaction with the
/*    form VDSelectSet
/* ---------------------------------------------------- */
action	form_notification
/*
 *	int	form_label	: the label of the form
 *	int	gadget_label	: the label of the gadget
 *	double	fld_value	: the value of the gadget
 *	Form	form_ptr	: pointer to the form
 */
/*.form_notification*/	
{
  
IGRchar		err_msg[DI_PATH_MAX];
IGRchar		tmp_select[DI_PATH_MAX];
IGRchar		trunc_str[DI_PATH_MAX];
IGRint		i, resp, reset, option, sel_flag, r_pos;
IGRlong		sts;

 SetProc( VDCmdLcNm.form_notification ); Begin
/*
 * clean up the message area ( if used )
 */

  me->del_flag = FALSE;

  /* " gadget_label : %d\n", gadget_label */

  UI_message("");
  UI_status("");

  strcpy( err_msg, " " );
  status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
  if( status != FI_SUCCESS )	me->del_flag = TRUE;

  /*^
	VDSshow_textset_list( &me->text_list );
	printf("\ndisp_text ...............\n");
	printf(" select: <%s>\n", me->disp_text.select); 
	printf(" prefix: <%s>\n", me->disp_text.prefix );
	printf(" expres: <%s>\n", me->disp_text.expres );
	printf(" suffix: <%s>\n", me->disp_text.suffix );
   */
   
  switch ( gadget_label )
  {
  case	1000:
	/* TR179802375 by ylong
         * This is called for the retrieve file process. Used in function
	 * VDdelete_LocateByName()
	 */
	me->del_flag = TRUE;
	break;

  case FI_CANCEL:
	/*| FI_CANCEL_BUT */
/*	_put_response(resp = EX_BACK_UP); */

        _put_response(  resp = EX_FORM_FINISHED );
	me->del_flag = TRUE;
    break;

  case FI_RESET:
	/*| FI_RESET_BUT */
	
	/*| copy the old values */

	 status = om$send( msg = message VDCmdLcNm.VDSfill_instances
					( &sts ),
			  targetid = my_id );

	 if( ! (status & 1) ){
	  printf(" ERROR: action VDSfill_instances failed\n");
	  me->del_flag = TRUE; break;
	}

	resp = VDSfill_textset_list(	&me->text_list,
					me->my_form_ptr, 
					VDS_SELECT_FLD );
	if( ! resp ){
	  printf(" ERROR: fct VDSfill_textset_list failed \n");
	  me->del_flag = TRUE; break; 
	}
    

	/* display the text in the fields */
	status = FIg_set_text( me->my_form_ptr, VDS_EXPRES_FLD, me->disp_text.expres );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	status = FIg_set_text( me->my_form_ptr, VDS_PREFIX_FLD, me->disp_text.prefix );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	status = FIg_set_text( me->my_form_ptr, VDS_SUFFIX_FLD, me->disp_text.suffix );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	status = FIg_set_text( me->my_form_ptr, VDS_SELECT_FLD, me->disp_text.select );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	FIg_set_state_off( me->my_form_ptr, gadget_label );

	status = FIf_display( me->my_form_ptr );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
     break;

  case FI_EXECUTE:
  case FI_ACCEPT:
	/*| FI_EXE_ACC_BUT */

	/*| save the value into the directory system */
	resp = VDSwrite_expr_dir(	&me->text_list,
					me->expr_dir );
	if( ! resp ){
	  printf(" ERROR: fct VDSwrite_exp_dir failed\n");
	  me->del_flag = TRUE; break;
	}

	resp = VDSset_active_textset(	&me->text_list, 
					me->expr_dir,
					me->disp_text.select );
	if( ! resp ){
	  printf(" ERROR: fct VDSset_active_textset failed \n");
	  me->del_flag = TRUE; break;
	}
	  
	FIg_set_state_off( me->my_form_ptr, gadget_label );

	if( gadget_label == FI_ACCEPT ){
	  /*| exit from command object */
          _put_response(  resp = EX_FORM_FINISHED );
	  me->del_flag = TRUE;
          break;
	}

	if( gadget_label == FI_EXECUTE ){

	  resp = VDSfill_textset_list(	&me->text_list,
					me->my_form_ptr, 
					VDS_SELECT_FLD );
	  if( ! resp ){
	    printf(" ERROR: fct VDSfill_textset_list failed \n");
	    me->del_flag = TRUE; break;
	  }

	  /* display the text in the fields */
	  status = FIg_set_text( me->my_form_ptr,VDS_SELECT_FLD,me->disp_text.select );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	  status = FIg_set_text( me->my_form_ptr,VDS_PREFIX_FLD,me->disp_text.prefix );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	  status = FIg_set_text( me->my_form_ptr,VDS_EXPRES_FLD,me->disp_text.expres );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	  status = FIg_set_text( me->my_form_ptr,VDS_SUFFIX_FLD,me->disp_text.suffix );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
	}
    break;

  case VDS_ACTIVE_BUT:
	/*| VDS_ACTIVE_VDSevaluate_event_string */
	
	/*" select: <%s>\n", me->disp_text.select */
	/*" prefix: <%s>\n", me->disp_text.prefix */
	/*" expres: <%s>\n", me->disp_text.expres */
	/*" suffix: <%s>\n", me->disp_text.suffix */
	if(ex$is_cmd_stack_empty()){
		ex$message(msgnumb = VD_E_CmdStkEpt);
		FIg_set_state_off( me->my_form_ptr, gadget_label );
		break;
	}
	/*| set if the fields are given */
	if(( me->disp_text.prefix[0] == '\0') &&
	   ( me->disp_text.select[0] == '\0') &&
	   ( me->disp_text.expres[0] == '\0') &&
	   ( me->disp_text.suffix[0] == '\0' )){

	  /*| give error message */
	  ex$message(msgnumb = VD_W_LocNoExpDef , buff = err_msg);
	  status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
	  if( status != FI_SUCCESS )	me->del_flag = TRUE;
	  FIg_set_state_off( me->my_form_ptr, gadget_label );
	  break;
	}
	else{
	  status = om$send( msg = message VDCmdLcNm.VDSevaluate_active_event
					( &sts ),
			  targetid = my_id );
	  if( ! (status & 1) ){
	  	printf(" ERROR: action VDCmdLcNm.VDSevaluate_active_event\n");
	  	me->del_flag = TRUE; break;
	  }
	}
	if(me->my_form_ptr) FIg_set_state_off( me->my_form_ptr, gadget_label );
    break;

  case VDS_SELECT_FLD:
	/*| VDS_SELECT_FLD */
      
	/* get the text information */

	status = FIfld_get_text( me->my_form_ptr, VDS_SELECT_FLD, 0,0,
				DI_PATH_MAX,tmp_select, &sel_flag, &r_pos );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	/*"tmp_select: <%s>\n",tmp_select*/
	EXP_strip(tmp_select);
	/*"tmp_select: <%s>\n",tmp_select*/

	/* test the length of the select string */
	if( VDS_SELECT_MAX < strlen( tmp_select )){
	  /* give warning message */
          ex$message(msgnumb = VD_W_LocSelTrunc , buff = err_msg);
	  status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
	  
	  strncpy( trunc_str, tmp_select, VDS_SELECT_MAX );
	  trunc_str[VDS_SELECT_MAX] = '\0';
	  strcpy( tmp_select, trunc_str );
	}
	/*" select: <%s>\n", tmp_select */
	
	reset = FALSE;
	if( tmp_select[0] == '\0' ){
	  reset = TRUE;
	  /*| set active textset structure to init values */
	  resp = VDSset_null_list_entry( &me->text_list, me->disp_text.select );
	  if( ! resp ){
	    printf(" ERROR: fct VDSset_null_list_entry failed\n");
	    me->del_flag = TRUE; break;
	  }

	  /* reset display structure */
	  resp = VDSset_null_text(	&me->disp_text );
	  if( ! resp ){
	    printf(" ERROR: fct VDSset_null_text failed\n");
	    me->del_flag = TRUE; break;
	  }
	}
 	else{
	  resp = FALSE;
	  /*| find the reference in the list */
	  for( i=0; i<me->text_list.num_textset; i++ ){
	    /*" select[%d] : <%s>\n", i, me->text_list.text[i].select */
	    if( strcmp( me->text_list.text[i].select, tmp_select ) == 0 ){

	      strcpy( me->disp_text.select, me->text_list.text[i].select );
	      strcpy( me->disp_text.prefix, me->text_list.text[i].prefix );
	      strcpy( me->disp_text.expres, me->text_list.text[i].expres );
	      strcpy( me->disp_text.suffix, me->text_list.text[i].suffix );
	
	      resp = TRUE;
	      reset = TRUE;
	      break;
    	    }
	  }
	  if( ! resp ){
	    /* test latest expression in list */
	    strcpy( me->disp_text.select, tmp_select );
	    option = 1;
	    resp = VDSadd_in_textset_list(	&me->text_list,
						&me->disp_text,
						option,
						NULL );
	    if( ! resp ){
	      printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	      me->del_flag = TRUE; break;
	    }
	  }
	}

	if( reset ){
	    FIfld_set_active_char( me->my_form_ptr, VDS_PREFIX_FLD, 0, 0, 0 );
	    FIfld_set_active_char( me->my_form_ptr, VDS_EXPRES_FLD, 0, 0, 0 );
	    FIfld_set_active_char( me->my_form_ptr, VDS_SUFFIX_FLD, 0, 0, 0 );
	}
 
	resp = VDSfill_textset_list(	&me->text_list,
					me->my_form_ptr, 
					VDS_SELECT_FLD );
	if( ! resp ){
	  printf(" ERROR: fct VDSfill_textset_list failed \n");
	  me->del_flag = TRUE; break;
	}

	/* display the text in the fields */
	FIfld_set_active_char( me->my_form_ptr, VDS_SELECT_FLD, 0, 0, 0 );
	status = FIg_set_text( me->my_form_ptr,VDS_SELECT_FLD,me->disp_text.select );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	status = FIg_set_text( me->my_form_ptr,VDS_PREFIX_FLD,me->disp_text.prefix );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	status = FIg_set_text( me->my_form_ptr,VDS_EXPRES_FLD,me->disp_text.expres );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	status = FIg_set_text( me->my_form_ptr,VDS_SUFFIX_FLD,me->disp_text.suffix );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
    break;

  case VDS_EXPRES_FLD:
	/* get the text information */
	status = FIfld_get_text( me->my_form_ptr, VDS_EXPRES_FLD, 0, 0, 
				 DI_PATH_MAX,me->disp_text.expres, &sel_flag, &r_pos );
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
	/*"me->disp_text.expres: <%s>\n",me->disp_text.expres*/
         EXP_strip(me->disp_text.expres);
	/*"me->disp_text.expres: <%s>\n",me->disp_text.expres*/

	/* test the length of the select string */
	if( VDS_EXPRES_MAX < strlen( me->disp_text.expres )){
	  /* give warning message */
          ex$message(msgnumb = VD_W_LocExTrunc , buff = err_msg);
	  status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
	  
	  strncpy( trunc_str, me->disp_text.expres, VDS_EXPRES_MAX );
	  trunc_str[VDS_EXPRES_MAX] = '\0';
	  strcpy( me->disp_text.expres, trunc_str );
	}
	/*" VDS_EXPRES_FLD : %s \n", me->disp_text.expres */
	
	/* test latest expression in list */	
	option = 1;
	resp = VDSadd_in_textset_list(	&me->text_list,
					&me->disp_text,
					option,
					NULL);
	if( ! resp ){
	  printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	  me->del_flag = TRUE; break;
	}
    break;

  case VDS_PREFIX_FLD:
	/* get the text information */
	status = FIfld_get_text( me->my_form_ptr, VDS_PREFIX_FLD,0, 0,DI_PATH_MAX, 
				 me->disp_text.prefix, &sel_flag, &r_pos);
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	/*"me->disp_text.prefix: <%s>\n",me->disp_text.prefix*/
         EXP_strip(me->disp_text.prefix);
	/*"me->disp_text.prefix: <%s>\n",me->disp_text.prefix*/

	/* test the length of the select string */
	if( VDS_PREFIX_MAX < strlen( me->disp_text.prefix )){
	  /* give warning message */
          ex$message(msgnumb = VD_W_LocPrefTrunc, buff = err_msg); 
	  status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
	  
	  strncpy( trunc_str, me->disp_text.prefix, VDS_PREFIX_MAX );
	  trunc_str[VDS_PREFIX_MAX] = '\0';
	  strcpy( me->disp_text.prefix, trunc_str );
	}
        /*" VDS_PREFIX_FLD : %s \n", me->disp_text.prefix */

	/* test latest expression in list */	
	option = 1;
	resp = VDSadd_in_textset_list(	&me->text_list,
					&me->disp_text,
					option,
					NULL );
	if( ! resp ){
	  printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	  me->del_flag = TRUE; break;
	}

    break;

  case VDS_SUFFIX_FLD:
	/* get the text information */
	status = FIfld_get_text( me->my_form_ptr, VDS_SUFFIX_FLD, 0, 0,
			DI_PATH_MAX,me->disp_text.suffix ,&sel_flag, &r_pos);
	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }

	/*"me->disp_text.suffix: <%s>\n",me->disp_text.suffix*/
         EXP_strip(me->disp_text.suffix);
	/*"me->disp_text.suffix: <%s>\n",me->disp_text.suffix*/

	/* test the length of the select string */
	if( VDS_SUFFIX_MAX < strlen( me->disp_text.suffix )){
	  /* give warnig message */
	  ex$message(msgnumb = VD_W_LocSufTrunc, buff = err_msg);
	  status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
	  if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
	  
	  strncpy( trunc_str, me->disp_text.suffix, VDS_SUFFIX_MAX );
	  trunc_str[VDS_SUFFIX_MAX] = '\0';
	  strcpy( me->disp_text.suffix, trunc_str );
	}
	/*" VDS_SUFFIX_FLD : %s \n", me->disp_text.suffix */

	/* test latest expression in list */
	option = 1;	
	resp = VDSadd_in_textset_list(	&me->text_list,
					&me->disp_text,
					option,
					NULL );
	if( ! resp ){
	  printf(" ERROR: fct VDSadd_in_textset_list failed\n");
	  me->del_flag = TRUE; break;
	}
    break;

  case VDS_WRITE_BUT:
	/*| VDS_WRITE_BUT */
	FIg_set_state_off( me->my_form_ptr, gadget_label );

/*	strcpy( err_msg, " Write Button is not implemented " );
/*	status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
/*	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break; }
/* */
	
    break;

  case VDS_READ_BUT:
	/*|  VDS_READ_BUT */
	FIg_set_state_off( me->my_form_ptr, gadget_label );

/* 	strcpy( err_msg, " Read Button is not implemented" );
/*	status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
/*	if( status != FI_SUCCESS ){ me->del_flag = TRUE; break;	}
/* */
     break;

  default:
    break;
  } /* END switch ( g_label ) */

  /*" del_flag : %d \n", me->del_flag */
  /*^
	VDSshow_textset_list( &me->text_list );
   */

  if( me->del_flag ){
    	status = om$send( msg      = message VDCmdLcNm.delete ( 0 ),
		    	  mode	   = OM_e_wrt_message,
			  targetid = my_id );
	if(!(status & 1)){
		printf("error VDCmdLcNm.delete \n");
		me->del_flag = 1;
     		return ( OM_I_STOP_SENDING );
     	}
  }

  End
  goto quit ;

} /* END notification_routine() */

