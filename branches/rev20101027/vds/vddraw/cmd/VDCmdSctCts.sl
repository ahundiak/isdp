/* $Id: VDCmdSctCts.sl,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/cmd/VDCmdSctCts.sl
 *
 * Description:
 *
 * Dependencies:
 *		Slic File
 *		$EXNUC/bin/slic VDCmdSctCts.sl
 *		OUTPUT: VDCmdSctCts.S  and VDCmdSctCtsi.I
 *
 * Revision History:
 *	$Log: VDCmdSctCts.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/10/25  13:04:26  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by v241_int for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.25  1996/03/29  10:15:42  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by ksundar for vds.240
#
# Revision 1.24  1995/12/08  14:09:52  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by v240_int for vds.240
#
# Revision 1.23  1995/09/29  19:49:52  pinnacle
# Replaced: ./vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
# Revision 1.22  1995/08/16  22:48:20  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
# Revision 1.21  1995/08/16  22:45:18  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
# Revision 1.20  1995/08/07  20:19:40  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
# Revision 1.19  1995/07/29  15:10:46  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
# Revision 1.18  1995/07/01  17:57:02  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
# Revision 1.17  1995/06/27  18:23:22  pinnacle
# Replaced: vddraw/cmd/VDCmdSctCts.sl for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/01/95	adz		creation date
 *	06/04/95	msb		add depth control.
 *	06/06/95	adz		Changed list checking routine.
 *	08/16/95	adz		Invalid message key.
 *	09/28/95	adz		Change the Filter function for macro.
 *
 ***************************************************************************/

/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_GnVolCts, 3, VDSctCts
class		VDCmdSctCts
super_class	"VDCmdMVel"
product_name	"$VDS"
command_table	"vds.cmd"

/*
 * form used
 */
form		"VDsectCts",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

/*
    Instance contains solid object and old display depths. Old display
    depths are not currently used.
*/
#define  FPvol		me^^CEO.forms[0].form_ptr

instance
{
	/*
	 * destination level for the object.
	 */
	short			objLevel ;

	/*
	 * support file to use.
	 */
	GRname			objASCII ;

	/*
	 * Compute based of solid.
	 */
	int			objCompute ;

	/*
	 * offset value;
	 */
	double			volOffset ;

}

/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "bserr.h"
#include "bsparameters.h"
#include "FI.h"
/*
#define  VDS_DBG
*/

#include "griodef.h"
#include "UOMdef.h"
#include "grio.h"
#include "griomacros.h"
#include "UOMmacros.h"
#include "vdsollocdef.h"
#include "vdsetmacros.h"
#include "vderrmacros.h"
#include "v_drw.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define  VD_RP_INSIDE  1
#define  VD_NO_OBJECTS 500

/* form gadget of MV form */
#define	 VD_LIST_FLD		15
#define  VD_OFFSET_FLD		17
#define  VD_OFFSET_TXT		18
#define  VD_INSIDE_FLD  	20
#define  VD_INSIDE_OVERLAP_FLD	21
#define  VD_OVERLAP_FLD		22
#define	 VD_LEVEL_NAME		40
#define	 VD_LEVEL_FIELD		41
#define  VD_SUPP_NAME		42
#define	 VD_SUPP_FIELD		43
#define  VD_COMP_FIELD		45

from  VDmdlview import	VDmv_display_solid;


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "grmsg.h"
#include "VDmsg.h"
#define  VD_NO_OBJECTS 500

state start

    message_key		VD_M_GnVolCts
    execute		check_mvs_created( &me->ret )

	on SUCCESS					state getOldLocCrit
	on ELSE						state terminate


state getOldLocCrit

    status		" "

	on ELSE
		do construct_graphics_set
		do start_transition_for_graphics_set
		do build_old_locate_criteria
		do end_transition_for_graphics_set	state get_window


state get_window

    message_key		VD_M_GnVolCts
    prompt_key		VD_P_VolCtsIdWn
    mask		"GRm_DATA | GRm_BACK_UP"
    filter		get_event

	on EX_DATA	do store_window			state select_mv
	on ELSE         state terminate


state select_mv

    message_key		VD_M_GnVolCts
    prompt_key		VD_P_SelMV
    display_form	0
    filter		get_event

	on EX_BACK_UP
                do erase_form   0
                                        state get_window

	on EX_FORM_FINISHED

		do erase_form	0
		do construct_graphics_set
		do start_transition_for_graphics_set
		do set_old_locate_criteria
		do generate_right_prism_from_mv
		do generate_select_set_from_right_prism
		do process_mv_contents
		do end_transition_for_graphics_set
		do use_set_for_volume_cut
		   on RETURN_CODE = "TERMINATE"
							state terminate
		   on RETURN_CODE = "EX_BACK_UP"
							state get_window
		   on RETURN_CODE = "VD_NO_OBJECTS"
			do status_key GR_E_EleNotFnd
							state get_window
		   on SUCCESS
			do status_key VD_S_ProcessFinished
							state terminate
 		   on ERROR
			do status_key VD_S_InvProcessing
							state terminate
							state terminate


at init    do   set_instance
	   do	set_level_and_support

at wakeup  do	set_form_and_instance
	   do	show_level_and_support
	   do   get_win_display_depths

at sleep   do   set_old_display_depths


/*
 * LIST OF LOCAL ACTIONS 
 */

action set_level_and_support
{
	me->objLevel	= 1000 ;
	me->objASCII[0] = '\0';
	me->objCompute	= FALSE ;
	me->volOffset   = 0.0 ;

	*sts = MSSUCC ;
	status = OM_S_SUCCESS ;
	goto quit ;
}

action show_level_and_support
{
	/*
	 * display the known information.
	 */

	FIg_set_value( FPvol, VD_LEVEL_FIELD, (double) me->objLevel );
	FIg_set_text ( FPvol, VD_SUPP_FIELD, me->objASCII );

	/* 
	 * Button is taken from form.
	 * FIg_set_state( FPvol, VD_COMP_FIELD, me->objCompute );
	 */
	FIg_set_state( FPvol, VD_INSIDE_OVERLAP_FLD, TRUE );

	*sts = MSSUCC;
	status = OM_S_SUCCESS ;
	goto quit ;
}

action form_notification
{
enum	GRdpmode	dpmode;
int			ii,
			Compute,
			sel_flag ;
double			dbValue;
GRname			strValue ;
GRname			stsMess ;
long			msg;
VD_drwMacInfo		*drwMacInfo;


  FIg_set_text( FPvol, FI_MSG_FIELD, "" );
  drwMacInfo = NULL ;

  switch ( gadget_label )
  {

    case VD_LEVEL_FIELD :

	FIg_get_value(	FPvol, gadget_label, &dbValue );
	me->objLevel = (short) dbValue ;
	break ;

    case VD_SUPP_FIELD :

	FIg_get_text(	FPvol, gadget_label, strValue );
	strcpy(	me->objASCII, strValue );

        if( strlen( me->objASCII )){

		/*
		 * Add section cut info to parser.
		 */
                VD_drwExecSectAddFunctions();

                if( ! VD_drw_init_from_drawing_setup(   me->objASCII,
                                                        &drwMacInfo )){

                        /*
                         * The setup file is not found.
                         */
                        sprintf( stsMess, "File: '%s' error or not found",
							me->objASCII );
  			FIg_set_text( FPvol, FI_MSG_FIELD, stsMess );
			UI_status( stsMess );

			/*
			 * clean-up the form.
			 */
			me->objASCII[0] = '\0';
			FIg_set_text( FPvol, gadget_label, me->objASCII );
		}
		else{
                        /*
                         * The setup file is found.
                         */
                        sprintf( stsMess, "File: '%s' correct",me->objASCII );
  			FIg_set_text( FPvol, FI_MSG_FIELD, stsMess );
			UI_status( stsMess );
		}

                VD_drwExecSectRmFunctions();

                VD_drwFreeExtractMacInfo( drwMacInfo ) ;
	}

	break ;

    case VD_COMP_FIELD :

	/*
	 * Button is taken from form.
	 *
	 * FIg_get_state( FPvol, gadget_label, &Compute );
	 * if( Compute )	me->objCompute 	= TRUE ;
	 * else			me->objCompute	= FALSE ;
	 * 
	 * FIg_set_state( FPvol, gadget_label, me->objCompute );
	 */

	 me->objCompute	= FALSE ;

	break ;

    case FI_ACCEPT:

	FIg_set_state ( FPvol, FI_ACCEPT, FALSE );

	for ( ii=0; ii < me->num_mdlv; ii++ )
	{
	  FIfld_get_select ( FPvol, VD_LIST_FLD, ii, 0, &sel_flag);

	  if ( sel_flag )
	  {
	    FIfld_set_select ( FPvol, VD_LIST_FLD, ii, 0, FALSE );
	    FIfld_set_select ( FPvol, VD_LIST_FLD, ii, 1, FALSE );
	    FIfld_set_select ( FPvol, VD_LIST_FLD, ii, 2, FALSE );

	    dpmode = GRbdhe;
	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mv_list[ii].objid,
		  targetos = me->mv_list[ii].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg, VD_VERBOSE );
	    break;
	  }
	}

	if ( ii < me->num_mdlv )
	{
	   me->mv.obj_id = me->mv_list[ii];
	   me->mv.mod_env = me->mv_env_list[ii];
	   _put_response ( resp = EX_FORM_FINISHED );
	}
	else
	{
	   int response = EX_BACK_UP;

	   status = ex$putque(
			    msg		= &msg,
			    pos		= FRONT,
			    response	= &response );
	}
	break;


    case FI_CANCEL:

	for ( ii=0; ii < me->num_mdlv; ii++ )
	{
	  FIfld_get_select ( FPvol, VD_LIST_FLD, ii, 0, &sel_flag);

	  if ( sel_flag )
	  {
	    dpmode = GRbdhe;
	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mv_list[ii].objid,
		  targetos = me->mv_list[ii].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg, VD_VERBOSE );
	    break;
	  }
	}
	FIg_set_state_off ( FPvol, FI_CANCEL );
	{
	   int response = EX_BACK_UP;

	   status = ex$putque(
			    msg		= &msg,
			    pos		= FRONT,
			    response	= &response );
	}
	break;

    default:

	status =
	om$send( msg = message VDCmdMVel.form_notification(	form_label,
								gadget_label,
								value,
								form_ptr ),
		mode = OM_e_wrt_message ,
		targetid = my_id );

   } 	/* switch ( gadget_label ) */

   goto quit ;
}	/* form_notification */


action	use_set_for_volume_cut
{
IGRint			objCount  = 0 ,
			objCount1 = 0 ;
struct	GRobj_env	*objList ,
			*newList ;
struct	GRid		drw3dVw ;
IGRint			nret,
			newCount ;
IGRlong			response;
char			response_data[1024];
GRname			sts_mess ;
struct GRevent		inEvent;
IGRboolean		batch1_inter0 = FALSE ;

	SetProc( use_set_for_volume_cut ); Begin

	*sts = MSSUCC ;

	objList	= NULL ;
	newList	= NULL ;
	newCount = 0 ;

	FIg_get_value(	 FPvol, VD_OFFSET_FLD, &me->volOffset );

	__DBGpr_dbl(" volOffset ", me->volOffset );

	status =
	gr$gsinqcount(	msg		= sts,
			count		= &objCount,
			object_id	= &me->gs_id );

	if( ! objCount ){
		*sts =  VD_NO_OBJECTS;
		goto wrapup;
	}

	objList = _MALLOC( objCount, struct GRobj_env );

	if( ! objList ){
		*sts = MSFAIL ;
		goto wrapup ;
	}

	status =
	gr$gsget_objects(msg		= sts,
			array		= objList,
			size		= objCount * sizeof(struct GRobj_env),
			count		= &objCount1,
			object_id	= &me->gs_id );

	/*
	 * Check the input buffer.
	 */
	status =
	vd$filter_objects(	msg	= sts,
				iList	= objList,
				iCount	= objCount1,
				oList	= &newList,
				oCount	= &newCount );
	if( status & *sts & 1 ){
		/*
	 	 * take the new list.
		 */
		_FREE( objList );
		objList = newList ;
		objCount1 = newCount ;
		newList	= NULL ;
	}

	sprintf( sts_mess, "Totally %d object selected ", objCount1 );
	UI_status( sts_mess );
	
	status =
	vd_$bulk_display( dpmode  = GRhd,
			  count   = objCount1,
			  objenvs = objList    );

	do 
	{
	  status =
	  co$getevent( msg	   = sts,
		     event_mask    = 
			(long) (GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP),
		     prompt	   = "Accept set/Reject",
		     value_type	   = GRIO_SCALAR,
		     mode	   = EX_LINE_MODE,
		     nbytes	   = &nret,
		     response	   = &response,
		     response_data = response_data,
		     event	   = &inEvent );
	} while (    response != EX_RJT_MOVEON && response != EX_BACK_UP
		  && response != TERMINATE && response != EX_DATA
		  && response != CLEAR_STACK );

	status =
	vd_$bulk_display( dpmode  = GRbdhe,
			  count   = objCount1,
			  objenvs = objList    );

	/*
	 * disconnect the objects from the input event queue (GRsvset).
	 */
	status =
	gr$gsempty(	msg		= sts,
			p_chanselect	= &me->located_chansel );

	if ( response != EX_DATA )
	{
	    me->last_sel_mdlv = -1;
	    me->mv.obj_id.objid = NULL_OBJID;
	    status = om$send ( msg = message VDCmdSctCts.clean_up ( sts ),
			       targetid = my_id );
	    if ( response == TERMINATE || response == CLEAR_STACK )
			*sts = TERMINATE;
	    else	*sts = EX_BACK_UP;
	    goto wrapup;
	}

	status =
	VD_crtSectionObjects(	sts,
				&me->ModuleInfo,
				&me->mv,
				me->volOffset,
				me->objCompute,
				me->objLevel,
				NULL,
				me->objASCII,
				objCount1,
				objList,
				batch1_inter0,
				&drw3dVw );

	if(!(  status & *sts & 1 )){
		*sts = MSFAIL ;
		goto wrapup ;
	}
	else
		*sts = MSSUCC;

wrapup:

	_FREE( objList );
	_FREE( newList );
	End
	goto quit ;
}

