/* $Id: VDCmdMVel.sl,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* I/VDS
 *
 * File:	vdpocket/cmd/VDCmdMVel.sl
 *
 * Description:
 *		Pocket menu command to select elements inside,
 *		overlapping, inside & overlapping  model views.
 *		When me->mytype == 3,  Generate Volume Cuts object
 *		is active which is subclassed from this command.
 *
 * Dependencies:
 *
 *
 * Revision History:
 *	$Log: VDCmdMVel.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:00  cvs
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
# Revision 1.11  1996/04/19  05:05:40  pinnacle
# Replaced: vdpocket/cmd/VDCmdMVel.sl for:  by msbraju for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08-16-1994	Raju		Creation date
 *
 */

/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_ElBndMV,0,VDElBndMV
class		VDCmdMVel
super_class	COgrpevent
product_name	"$VDS"
command_table	"vds.cmd"

/* form used
*/
form		"VDselMdlvw",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

/*
    Instance contains solid object and old display depths. Old display
    depths are not currently used.
*/
#define  FP	me^^CEO.forms[0].form_ptr


instance
{
 struct  GRobj_env	mv;
 int			num_mdlv;
 struct  GRid		*mv_list;
 struct  GRmd_env	*mv_env_list;
 struct  GRobj_env	offset_solid;
 IGRboolean		off_sol_constructed;
 char			rlnNeeded;
 double			cht;
 long			stack_empty;
 int			last_sel_mdlv;    /* for display purposes only */

 IGRint		      criteria_flag_old;
 struct GRmd_env      locate_env_old;
 struct GRlc_locate   attributes_old;		 /* locate attributes  */

 OM_S_CLASSLIST	      locate_rtree_thing_old;    /* actual CLASSLIST thing */
 OM_S_CLASSLIST	      locate_eligible_thing_old; /* actual CLASSLIST thing */

 OMuword	      eligibleClassList[3] ;
 OMuword	      rtreeClassList[1] ;

 IGRdouble	      oldDisplayDepths[2];
				/* display depths of locate window. Display
				 * depths of window are changed to height of
				 * solid during locate. Display depths are
				 * changed back to old dds at sleep.
				 */
}

/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "FI.h"
#include "vdsollocdef.h"
#include "vdvvoldef.h"
/* #define  VDS_DBG */
#include "vderrmacros.h"

#include "griodef.h"
#include "UOMdef.h"
#include "grio.h"
#include "griomacros.h"
#include "UOMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grmsg.h"
#include "VDmsg.h"
#include "VDmem.h"


#define  VD_RP_INSIDE  1
#define  VD_SENTINAL_VAL   -999999.0

%safe
#include "VX_FIproto.h"
static  char  rlnNeeded0 = VD_EL_INSIDE;
static  double  stored_offset_db0 = VD_SENTINAL_VAL;
static  char  rlnNeeded3 = VD_EL_INSIDE_OVERLAP;
static  double  stored_offset_db3 = VD_SENTINAL_VAL;
%endsafe


/* form gadget of MV form */
#define	 VD_LIST_FLD		15
#define  VD_OFFSET_FLD		17
#define  VD_OFFSET_TXT		18
#define  VD_INSIDE_FLD  	20
#define  VD_INSIDE_OVERLAP_FLD	21
#define  VD_OVERLAP_FLD		22

from  NDnode	import  ASreturn_go;
from  VDmdlview import	VDmv_display_solid,
			VDmv_give_vv_qry;
from  VDviewvol import  VDvv_give_solid;
from  IGEgragad	import  DPinquire;

from  GRgraphics import GRdelete;
from  GRgraphics import GRdisplay;
from  GRgraphics import GRchgprops;


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "grmsg.h"
#include "VDmsg.h"

state start

	message_key	VD_M_ElBndMV
	execute		check_mvs_created( &me->ret )

	on SUCCESS					state getOldLocCrit
	on ELSE						state terminate


state getOldLocCrit

	message_key	VD_M_ElBndMV
	status		" "
	on ELSE do construct_graphics_set
		do start_transition_for_graphics_set
		do build_old_locate_criteria
		do end_transition_for_graphics_set	state get_window


state get_window

	message_key	VD_M_ElBndMV
	prompt_key	VD_P_BVPIdLocWin
	mask            "GRm_DATA | GRm_BACK_UP"
	filter		get_event

	on EX_DATA
		do store_window				state select_mv
	on ELSE						state terminate


state select_mv

	message_key	VD_M_ElBndMV
	display_form	0
	prompt_key	VD_P_SelMV
	filter		get_event

	on EX_FORM_FINISHED				state process_mv


state process_mv

	message_key	VD_M_ElBndMV
	erase_form   0
	on ELSE do construct_graphics_set
		do start_transition_for_graphics_set
		do set_old_locate_criteria
		do generate_right_prism_from_mv
		do generate_select_set_from_right_prism
		do process_mv_contents
		do end_transition_for_graphics_set
		do define_active_select_set
                   on RETURN_CODE = "MSFAIL"
				do status_key GR_E_EleNotFnd
							state terminate
		do put_select_set_on_queue
							state terminate

at init    do  set_instance
at wakeup  do  set_form_and_instance
	   do  get_win_display_depths
at sleep   do  free_memory
	   do  set_old_display_depths
at delete  do  clean_up

/* do  error_box(" init1 " ) */

/*
  Sets instance partly.
*/
action  set_instance
{

/*
 if ( me->mytype == 0 )
	me->rlnNeeded = VD_EL_INSIDE;
 else if ( me->mytype == 3 )
	me->rlnNeeded = VD_EL_INSIDE_OVERLAP;
*/

 status = OM_S_SUCCESS;

 if ( me->mytype == 0 )
	me->rlnNeeded = rlnNeeded0;
 else if ( me->mytype == 3 )
	me->rlnNeeded = rlnNeeded3;

 me->stack_empty = ex$is_cmd_stack_empty() ?  TRUE : FALSE;

 me->window_id.objid = NULL_OBJID;
 me->mv.obj_id.objid = NULL_OBJID;
 me->offset_solid.obj_id.objid = NULL_OBJID;

 goto quit;


}

/*
  Sets rest of the instance and form
*/
action set_form_and_instance
{
long			msg;
int			num_mdlv, ii;
struct GRid		*mdlv_id_list = NULL;
struct GRmd_env		*mdlv_env_list = NULL;
char			**mdlv_name_list = NULL,
			**mdlv_desc_list = NULL,
			filename[15];


#ifdef VDS_DBG
 FIf_cvrt_to_perm_win(FP);
#endif

 status = OM_S_SUCCESS;

 if ( me->mytype != 3 && me->stack_empty ) goto quit;

 me->num_mdlv = 0;
 me->mv_list = NULL;
 me->mv_env_list = NULL;

 status = VDgetMVlist ( &msg, &num_mdlv, &mdlv_id_list, &mdlv_env_list,
			&mdlv_name_list, &mdlv_desc_list  );
 VDS_ERR_HNDLR( "VDgetMVlist", status, msg, VD_VERBOSE, quit );
 if ( num_mdlv == 0 ) goto quit;

 FIfld_set_max_num_rows( FP, VD_LIST_FLD, num_mdlv );
 FIfld_set_num_rows ( FP, VD_LIST_FLD, num_mdlv );

 for(ii=0; ii<num_mdlv; ii++)
 {
     FIfld_set_text ( FP, VD_LIST_FLD, ii, 0, mdlv_name_list[ii], FALSE );
     FIfld_set_text ( FP, VD_LIST_FLD, ii, 1, mdlv_desc_list[ii], FALSE );

     FIfld_set_select( FP, VD_LIST_FLD, ii, 0, FALSE );
     FIfld_set_select( FP, VD_LIST_FLD, ii, 1, FALSE );

     status = VDget_filename_from_os (  mdlv_id_list[ii].osnum,  filename );
     if ( !(1&status) ) continue;
     FIfld_set_text ( FP, VD_LIST_FLD, ii, 2, filename, FALSE );
     FIfld_set_select( FP, VD_LIST_FLD, ii, 2, FALSE );
 }


 me->last_sel_mdlv = -1;
 me->num_mdlv = num_mdlv;
 me->mv_list  = mdlv_id_list;
 me->mv_env_list = mdlv_env_list;

 VDfree_str_list ( mdlv_name_list, num_mdlv );
 VDfree_str_list ( mdlv_desc_list, num_mdlv );

 /* set offset field */
 {
   GRIOalias_name	default_units[3];
   IGRshort		flag = 0, num_defaults;
   char			type[UOM_K_MAX_TYPE], name[20];
   IGRdouble		chtol_db, chtol_def;

   BSEXTRACTPAR ( &msg, BSTOLCHRDHT, chtol_db );

   strcpy ( type, GRIO_DISTANCE );
   co$get_default_units(msg		= &msg,
			table_name	= type,
			osnum		= me->ModuleInfo.md_id.osnum,
			flag		= &flag,
			num_defaults	= &num_defaults,
			default_units	= default_units );
   strcpy( name, default_units[0] );

   status = uom$cvt_value_to_value(msg	     = &msg,
			  unit_type	     = type,
			  osnum		     = me->ModuleInfo.md_id.osnum,
			  alias_to_cvt_from  = NULL,
			  alias_to_cvt_to    = name,
			  num_vals	     = 1,
			  values_in	     = &chtol_db,
			  values_out	     = &chtol_def);
   me->cht = chtol_def;

   FIg_set_text ( FP, VD_OFFSET_TXT, name );

   if ( me->mytype == 0 )
   {
       if ( stored_offset_db0 == VD_SENTINAL_VAL )
       {
           if ( me->rlnNeeded == VD_EL_INSIDE )
	        FIg_set_value( FP, VD_OFFSET_FLD, 10*chtol_def);
           else
	        FIg_set_value( FP, VD_OFFSET_FLD, 0.0);
       }
       else
       {
	  double  offset_def;

		status = VDdet_conv_int_ext ( stored_offset_db0,
					      &offset_def,
					      me->ModuleInfo.md_id.osnum );
	        FIg_set_value( FP, VD_OFFSET_FLD, offset_def);
	}
   }

   if ( me->mytype == 3 )
   {
       if ( stored_offset_db3 == VD_SENTINAL_VAL )
       {
           if ( me->rlnNeeded == VD_EL_INSIDE )
	        FIg_set_value( FP, VD_OFFSET_FLD, 10*chtol_def);
           else
	        FIg_set_value( FP, VD_OFFSET_FLD, 0.0);
       }
       else
       {
	  double  offset_def;

		status = VDdet_conv_int_ext ( stored_offset_db3,
					      &offset_def,
					      me->ModuleInfo.md_id.osnum );
	        FIg_set_value( FP, VD_OFFSET_FLD, offset_def);
	}
   }

   if ( me->rlnNeeded == VD_EL_INSIDE )
	FIg_set_state( FP, VD_INSIDE_FLD, 1);
   else if ( me->rlnNeeded == VD_EL_INSIDE_OVERLAP )
	FIg_set_state( FP, VD_INSIDE_OVERLAP_FLD, 1);
   else
	FIg_set_state( FP, VD_OVERLAP_FLD, 1);
 }

 goto quit;


}

action  get_win_display_depths
{
struct var_list		var_list[2];
IGRlong			which_error,
			ret_bytes,
			msg;

    *sts = MSSUCC;
    if ( me->window_id.objid == NULL_OBJID ) goto quit;

    /*
     * get display depths of window.
     */
    var_list[0].var = WLD_DISPLAY_DEPTHS;
    var_list[0].var_ptr = (IGRchar *)me->oldDisplayDepths;
    var_list[0].num_bytes = sizeof(IGRdouble)*2;
    var_list[0].bytes_returned = &ret_bytes;

    var_list[1].var = END_PARAM;

    status = om$send(	msg = message IGEgragad.DPinquire
				( &msg, &which_error, var_list),
			targetid = me->window_id.objid,
			targetos = me->window_id.osnum);
    VDS_ERR_RPT ( "IGEgragad.DPinquire", status, msg, VD_VERBOSE );

#ifdef VDS_DBG
    printf("me->oldDisplayDepths : [%lf,%lf]\n", me->oldDisplayDepths[0],
						 me->oldDisplayDepths[1] );
#endif
    
   goto quit;

}

action check_mvs_created
{

 status = OM_S_SUCCESS;

 if ( me->mytype != 3 && me->stack_empty )
 {
    ex$message (  msgnumb = VD_E_CmdStkEpt,
		  field   = ERROR_FIELD,
		  justification = CENTER_JUS );
    *sts = MSFAIL;
    goto quit;
 }

 if ( me->num_mdlv == 0 )
 {
    ex$message (  in_buff = "No model views defined",
		  field   = ERROR_FIELD,
		  justification = CENTER_JUS );
    *sts = MSFAIL;
    goto quit;
 }

 *sts = MSSUCC;

 goto quit;

}

action store_window
{
long	msg;

   me->window_id.objid = me->event1.event.button.objid;
   me->window_id.osnum = me->event1.event.button.osnum;

    status = om$send ( msg = message VDCmdMVel.get_win_display_depths( &msg ),
		       targetid = my_id );
    VDS_ERR_RPT("VDCmdSlEl.get_win_display_depths", status, msg, VD_VERBOSE);


   *sts = MSSUCC;

   goto quit;

}


action form_notification
{
 enum GRdpmode		dpmode;
 int			ii, sel_flag, row, pos;
 long			msg;
 short			action, props;
 struct GRid		solbool;
 double			def_offset;


  status = OM_S_SUCCESS;

  FIg_set_text( FP, FI_MSG_FIELD, "" );

  switch ( gadget_label )
  {
    case VD_LIST_FLD:
	FIfld_get_active_row ( FP, VD_LIST_FLD, &row, &pos );
	if ( row >= me->num_mdlv )  break;
	if ( row == me->last_sel_mdlv )
	{
	    /* clicked on row which was selected before (now unselecting) */
/*
	    dpmode = GRbdhe;

	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mv_list[row].objid,
		  targetos = me->mv_list[row].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg, VD_VERBOSE );
*/
	    dp$erase_hilite ( msg = &msg );

	    me->last_sel_mdlv = -1;
	}
	else
	{
	    /* clicked on a new row */
	    dpmode = GRbdhe;
	    if ( me->last_sel_mdlv != -1 )
	    {
/*
	      status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mv_list[me->last_sel_mdlv].objid,
		  targetos = me->mv_list[me->last_sel_mdlv].osnum,
		  senderid = NULL_OBJID );
	      VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg,VD_VERBOSE);
*/
	      dp$erase_hilite ( msg = &msg );
	    }

	    dpmode = GRhd;

	    status = om$send( msg = message NDnode.ASreturn_go (
					&solbool,
					NULL,
					NULL ),
		  targetid = me->mv_list[row].objid,
		  targetos = me->mv_list[row].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_HNDLR("NDnode.ASreturn_go",status,1, VD_VERBOSE, quit );

	    action = 1;
	    props = GRIS_DISPLAYABLE;
	    status = om$send ( msg = message GRgraphics.GRchgprops (
					&msg, &action, &props ),
			targetid = solbool.objid,
			targetos = solbool.osnum );
	    VDS_ERR_HNDLR("GRgraphics.GRchgprops",status,msg,VD_VERBOSE,quit);

	    ACset_disthruref();
	    status = om$send ( msg = message GRgraphics.GRdisplay (
				&msg,
				&(me->mv_env_list[row].md_env.matrix_type),
				me->mv_env_list[row].md_env.matrix,
				&dpmode,
				&me->ModuleInfo.md_id ),
		  targetid = solbool.objid,
		  targetos = solbool.osnum  );
	    ACreset_disthruref ();

	    action = 0;
	    props = GRIS_DISPLAYABLE;
	    status = om$send ( msg = message GRgraphics.GRchgprops ( 
					&msg, &action, &props ),
			targetid = solbool.objid,
			targetos = solbool.osnum );
	    VDS_ERR_HNDLR("GRgraphics.GRchgprops",status,msg,VD_VERBOSE,quit);
/*
	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mv_list[row].objid,
		  targetos = me->mv_list[row].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid", status,msg,VD_VERBOSE );
*/
	    me->last_sel_mdlv = row;
	}
	break;

     case FI_ACCEPT:
     case FI_CANCEL:
	for ( ii=0; ii < me->num_mdlv; ii++ )
	{
	  FIfld_get_select ( FP, VD_LIST_FLD, ii, 0, &sel_flag);
	  if ( sel_flag )
	  {
/*
	    dpmode = GRbdhe;
	    status = om$send( msg = message VDmdlview.VDmv_display_solid (
						&msg, &dpmode ),
		  targetid = me->mv_list[ii].objid,
		  targetos = me->mv_list[ii].osnum,
		  senderid = NULL_OBJID );
	    VDS_ERR_RPT("VDmdlview.VDmv_display_solid",status,msg, VD_VERBOSE );
*/
	    dp$erase_hilite ( msg = &msg );
	    break;
	  }
	}


	if ( gadget_label == FI_ACCEPT && ii < me->num_mdlv )
	{
	   me->mv.obj_id = me->mv_list[ii];
	   me->mv.mod_env = me->mv_env_list[ii];
	}

	if ( me->mv.obj_id.objid != NULL_OBJID )
	{
	   _put_response ( resp = EX_FORM_FINISHED );
	}
	else
	{
	   int response = TERMINATE;

	   status = ex$putque(
			    msg		= &msg,
			    pos		= FRONT,
			    response	= &response );
	}
	break;

     case VD_INSIDE_FLD:
	me->rlnNeeded = VD_EL_INSIDE;
	if ( me->mytype == 0 && stored_offset_db0 == VD_SENTINAL_VAL )
			FIg_set_value( FP, VD_OFFSET_FLD, 10.0 * me->cht );
	if ( me->mytype == 3 && stored_offset_db3 == VD_SENTINAL_VAL )
			FIg_set_value( FP, VD_OFFSET_FLD, 10.0 * me->cht );
	break;

     case VD_INSIDE_OVERLAP_FLD:
	me->rlnNeeded = VD_EL_INSIDE_OVERLAP;
	if ( me->mytype == 0 && stored_offset_db0 == VD_SENTINAL_VAL )
			FIg_set_value( FP, VD_OFFSET_FLD, 0.0 );
	if ( me->mytype == 3 && stored_offset_db3 == VD_SENTINAL_VAL )
			FIg_set_value( FP, VD_OFFSET_FLD, 0.0 );
	break;

     case VD_OVERLAP_FLD:
	me->rlnNeeded = VD_EL_OVERLAP;
	if ( me->mytype == 0 && stored_offset_db0 == VD_SENTINAL_VAL )
			FIg_set_value( FP, VD_OFFSET_FLD, 0.0 );
	if ( me->mytype == 3 && stored_offset_db3 == VD_SENTINAL_VAL )
			FIg_set_value( FP, VD_OFFSET_FLD, 0.0 );
	break;

     case VD_OFFSET_FLD:
	FIg_get_value ( FP, VD_OFFSET_FLD, &def_offset );
	if ( me->mytype == 0 )
		VDdet_conv_ext_int(  def_offset, &stored_offset_db0,
				     me->ModuleInfo.md_id.osnum );
	if ( me->mytype == 3 )
		VDdet_conv_ext_int(  def_offset, &stored_offset_db3,
				     me->ModuleInfo.md_id.osnum );
	break;
  } /* switch ( gadget_label ) */

  goto quit;

}


action  generate_right_prism_from_mv
{
long			msg;
struct GRid		solbool;
struct GRmd_env 	solbool_env, tmp_env;
struct GRvg_construct	cst;
struct IGRdisplay	disp;
int			sizbuf, NoBytesRet;
double			def_offset, db_offset, chtol;
char			type[UOM_K_MAX_TYPE], name[20];
IGRshort		flag = 0, num_defaults;
GRIOalias_name		default_units[3];
GRobjid			off_solid;
double			wld_to_lcl_mx[16];



     if ( me->mv.obj_id.objid == NULL_OBJID )
     {
	*sts = MSSUCC;
	goto quit;
     }

     status = om$send ( msg = message NDnode.ASreturn_go (
					&solbool,
					&(solbool_env.md_env.matrix_type),
					solbool_env.md_env.matrix ),
			targetid = me->mv.obj_id.objid,
			targetos = me->mv.obj_id.osnum  );
     VDS_ERR_HNDLR( "NDnode.ASreturn_go", status, 1, VD_VERBOSE, quit );
     solbool_env = me->mv.mod_env;

     /*
      * get offset from status display form
      */
     FIg_get_value ( FP, VD_OFFSET_FLD, &def_offset );

     /* get default units */
     strcpy ( type, GRIO_DISTANCE );
     co$get_default_units(msg		= &msg,
			table_name	= type,
			osnum		= me->ModuleInfo.md_id.osnum,
			flag		= &flag,
			num_defaults	= &num_defaults,
			default_units	= default_units );
     strcpy( name, default_units[0] );

     /* convert to database units */
     status = uom$cvt_value_to_value(msg	     = &msg,
				  unit_type	     = type,
				  osnum		   = me->ModuleInfo.md_id.osnum,
				  alias_to_cvt_from  = name,
				  alias_to_cvt_to    = NULL,
				  num_vals	     = 1,
				  values_in	     = &def_offset,
				  values_out	     = &db_offset);

     BSEXTRACTPAR ( &msg, BSTOLCHRDHT, chtol );
     if ( fabs( db_offset ) < chtol * 2.0 )
     {
	me->offset_solid.obj_id  = solbool;
	me->offset_solid.mod_env = solbool_env;
	goto VD_SET_RPARGS;
     }

     /* construct an offset solid outside range tree */
     sizbuf = sizeof ( IGRshort );
     gr$get_active_layer(msg    = &msg,
		   sizbuf = &sizbuf,
		   buffer = &(cst.level),
		   nret   = &NoBytesRet );

     sizbuf = sizeof ( struct IGRdisplay );
     gr$get_active_display(msg    = &msg,
		   sizbuf = &sizbuf,
		   buffer = &disp,
		   nret   = &NoBytesRet );

     tmp_env = me->ModuleInfo;
     tmp_env.md_id.objid = NULL_OBJID;

     cst.msg      = &msg;
     cst.env_info = &tmp_env;
     cst.display  = &disp;
     cst.geometry = NULL;
     cst.newflag  = FALSE;
     cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
     cst.class_attr = NULL;
     cst.name       = NULL;

     /*
      * construct a solid outside range tree which is an offset solid by
      * given offset.
      */
     status = VDoffsetSolid( &msg, &solbool, &solbool_env, &cst, db_offset,
			     &off_solid );
     VDS_ERR_RPT ( "VDoffsetSolid", status, msg, VD_VERBOSE );
     if ( status & msg & 1 )
     {
	me->offset_solid.obj_id.objid  = off_solid;
	me->offset_solid.obj_id.osnum  = tmp_env.md_id.osnum;
	me->offset_solid.mod_env       = tmp_env;
	me->off_sol_constructed	       = TRUE;
     }
     else
     {
	ex$message (field =  ERROR_FIELD,
		    justification = CENTER_JUS,
		    in_buff = "offsetting solid failed; using original solid" );

	printf("WARNING : offsetting solid failed; using original solid\n");
	me->offset_solid.obj_id  = solbool;
	me->offset_solid.mod_env = solbool_env;
     }

VD_SET_RPARGS:

   me->layers_defined = FALSE;

/*
   if ( me->mytype == 3 )
   {
	int i;

	for (i=0; i < DP_NUM_OF_LEVELS; i++)
	{
		me->layers_mask[i/32] |= (1<<(i % 32));
	}
	me->layers_defined = TRUE;
   }
*/

   me->rp_action_args.clip_flag = FALSE;
   me->rp_action_args.gs_id = me->gs_id;
   me->rp_action_args.sv_id = me->sv_id;

   /*
    *  Set up arguments based on type.
    */
   switch (me->rlnNeeded)
   {
      case VD_EL_INSIDE:
      {
	me->prism_attr = GO_INSIDE;
	me->rp_action_args.rp_relation = GO_INSIDE;
	me->inside_outside = VD_RP_INSIDE;
      }
      break;

      case VD_EL_INSIDE_OVERLAP:
      {
	me->prism_attr = GO_INSIDE | GO_OVERLAP;
	me->rp_action_args.rp_relation = GO_INSIDE | GO_OVERLAP;
	me->inside_outside = VD_RP_INSIDE;
      }
      break;

      case VD_EL_OVERLAP:
      {
	/* 
	 * give inside also because prism created may be bigger than
	 * actual solid
	 */
	me->prism_attr = GO_OVERLAP | GO_INSIDE;
	me->rp_action_args.rp_relation = GO_OVERLAP | GO_INSIDE;
	me->inside_outside = VD_RP_INSIDE;
      }
      break;
   }

   /*
    *  build prism form solid
    *
    */
   status = om$vla_set_dimension(varray = me->prism_poles,
				 size = 5 * 3);
   me->right_prism.polygon.points = &me->prism_poles[0];

/*
   status = VDget_gadget_id1 ( &msg, &me->window_id );
   VDS_ERR_HNDLR( "VDget_gadget_id1", status, msg, VD_VERBOSE, quit );
*/

   status = GRbuild_prism_helper ( &msg, &me->window_id, NULL, NULL,
		NULL, NULL, NULL, NULL, wld_to_lcl_mx, NULL);
   VDS_ERR_HNDLR( "GRbuild_prism_helper", status, msg, VD_VERBOSE, quit );

   /*
    * set display depths of window as follows:
    *   Get current display depths of window.
    *	Get display depths for making the solid to display in widnow.
    *   min. display depth = max. of (current min. depth, min depth of solid).
    *   max. display depth = min. of (current max. depth, max depth of solid).
    * Idea is to make the display depths equal to range of solid so that
    * locate will be faster.
    *
    * Also get prism coordinates.
    */
   status = VDbuild_right_prism1 (
		&msg, &me->offset_solid.obj_id, 
		&me->offset_solid.mod_env, wld_to_lcl_mx,
		&me->window_id, &me->prism_type, &me->right_prism );
   VDS_ERR_HNDLR( "VDbuild_right_prism1", status, msg, VD_VERBOSE, quit );

   status = GRbuild_prism_helper ( &msg, &me->window_id, NULL, NULL,
		NULL, NULL, NULL, me->right_prism.matrix, NULL, NULL);
   VDS_ERR_HNDLR( "GRbuild_prism_helper", status, msg, VD_VERBOSE, quit );

   goto quit;

}

action  process_mv_contents
{
long		msg;
int		NbObj, ii;
struct GRmd_env tmp_env;
int		nb_tot_root, nb_root_fnd, nb_vvol, nb_qry;
struct GRid	*qry_ids = NULL, *vvol_ids = NULL, *mdlv_solids = NULL;
char		sts_str[50];


   if ( me->mv.obj_id.objid == NULL_OBJID )
   {
	*sts = MSSUCC;
	goto quit;
   }

   ex$message ( in_buff = "Processing model view contents ..",
		field   = ERROR_FIELD,
		justification = CENTER_JUS );

   status = om$send ( msg = message VDmdlview.VDmv_give_vv_qry (
							&msg,
							&nb_tot_root,
							&nb_root_fnd,
							&nb_vvol,
							&vvol_ids,
							NULL,
							NULL,
							NULL,
							&nb_qry,
							&qry_ids,
							NULL,
							NULL,
							NULL ),
			targetid = me->mv.obj_id.objid,
			targetos = me->mv.obj_id.osnum  );
   VDS_ERR_HNDLR("VDmdlview.VDmv_give_vv_qry",status,msg, VD_VERBOSE, quit );

   mdlv_solids = _MALLOC( nb_vvol, struct GRid );
   for( ii=0; ii<nb_vvol; ii++)
   {
      status = om$send ( msg = message VDviewvol.VDvv_give_solid (
						&msg,
						&mdlv_solids[ii],
						&tmp_env ),
			 targetid = vvol_ids[ii].objid,
			 targetos = vvol_ids[ii].osnum  );
      if ( msg == VD_VVOL_SOLID_DELETED  || !(status&msg&1) )
      {
	mdlv_solids[ii].objid = NULL_OBJID;
	mdlv_solids[ii].osnum = me->ModuleInfo.md_id.osnum;
      }
   }

   status= VDlocateWithSolid1( &msg,
				1,
				&me->offset_solid.obj_id,
				&me->offset_solid.mod_env,
				nb_qry,
				qry_ids,
				me->rlnNeeded,
				VD_LOCATE_WITH_SOLID,
				&NbObj,
				NULL,
				"Processing model view contents ..",
				&me->gs_id,
				nb_vvol,				
				mdlv_solids );
   VDS_ERR_RPT( "VDlocateWithSolid1", status, msg, VD_VERBOSE );
   if ( (status & msg & 1) && ( NbObj > 0 ) )
   {
	sprintf( sts_str, "%d object(s) located", NbObj );
	ex$message (	field = ERROR_FIELD,
			justification = CENTER_JUS,
			in_buff = sts_str );
	*sts = MSSUCC;
   }
   else
	*sts = MSFAIL;

   if ( qry_ids ) free ( qry_ids );
   if ( vvol_ids )  free ( vvol_ids );
   _FREE ( mdlv_solids );

   goto quit;

}

action free_memory
{
struct GRid		*mdlv_ids = NULL;
struct GRmd_env		*mdlv_envs = NULL;


    status = OM_S_SUCCESS;

    if ( me->num_mdlv )
    {
	mdlv_ids = me->mv_list;
	mdlv_envs = me->mv_env_list;
	free ( mdlv_ids );
	free ( mdlv_envs );
    }

   goto quit;

}

action set_old_display_depths
{
IGRdouble	depths[6] = {0,0,0,0,0,0};
long		msg;

   *sts = MSSUCC;
   if ( me->window_id.objid == NULL_OBJID ) goto quit;

   depths[2] = me->oldDisplayDepths[0];
   depths[5] = me->oldDisplayDepths[1];

   status = dp$view_vol( msg		= &msg,
			 gg_id		= &me->window_id,
			 display_depths	= depths,
			 update		= FALSE	);
   VDS_ERR_RPT("dp$view_vol", status, msg, VD_VERBOSE );

   goto quit;

}

action define_active_select_set
{
IGRint count;

   status = gr$gsinqcount (msg = sts, count = &count, 
            object_id = &me->gs_id);
   /*
    *  Only add if at atleast one element exists.
    */
   if (count > 0 )
   {
      /*
       *  Define the graphics set as the active select set.
       */
      status = gr$gsput_select_set (msg = sts, mod_env = &me->ModuleInfo,
               select_set_id = &me->gs_id);
      *sts = MSSUCC;
   }
   else
      *sts = MSFAIL;

   goto quit;

}

action clean_up
{
long		 msg;
struct GRmd_env  tmpEnv;

   tmpEnv = me->ModuleInfo;
   tmpEnv.md_id.objid = NULL_OBJID;


   if ( me->off_sol_constructed &&
	me->offset_solid.obj_id.objid != NULL_OBJID )
   {
      status = om$send ( msg = message GRgraphics.GRdelete ( &msg,
							     &tmpEnv ),
			 targetid = me->offset_solid.obj_id.objid,
			 targetos = me->offset_solid.obj_id.osnum );
      me->off_sol_constructed = FALSE;
      me->offset_solid.obj_id.objid = NULL_OBJID;
   }

   /*
    * store the relation selected by user in static variables
    */
   if ( me->mytype == 0 )
	rlnNeeded0 = me->rlnNeeded;
   else if ( me->mytype == 3 )
	rlnNeeded3 = me->rlnNeeded;

   goto quit;

}

action set_old_locate_criteria
{
OMuword        GRgraphics_classid;
IGRint         i;

   if (!(me->criteria_flag_old & GSPUT_LOCATE_ENV))
   {
      me->locate_env = me->ModuleInfo;
   }
   else
   {
      me->locate_env = me->locate_env_old;
   }

   if (!(me->criteria_flag_old & GSPUT_ATTRIBUTES))
   {
      strcpy (me->attributes.classes,"GRgraphics");
      me->attributes.properties = LC_LC_ONLY |
                                  LC_RW |
                                  LC_DP_ONLY |
                                  IGN_MOD_BIT |
                                  IGN_PLANAR_BIT;

      me->attributes.owner_action =  LC_RIGID_OWNER | 
                                     LC_FLEX_COMP;
   }
   else
   {
      me->attributes = me->attributes_old;
   }

   status = om$get_classid (classname = "GRgraphics",
			    p_classid = &GRgraphics_classid);

   if (!(me->criteria_flag_old & GSPUT_RTREE_CLASSES))
   {
	me->locate_rtree_thing.w_count = 1;
	me->locate_rtree_thing.w_flags = OM_CLST_subclass;
   }
   else
   {
	me->locate_rtree_thing = me->locate_rtree_thing_old;
   }

   if (!(me->criteria_flag_old & GSPUT_ELIGIBLE_CLASSES))
   {
	me->locate_eligible_thing.w_count = 1;
	me->locate_eligible_thing.w_flags = OM_CLST_subclass;
   }
   else
   {
	me->locate_eligible_thing = me->locate_eligible_thing_old;
   }

   /*
    * allocate space for and copy the rtree and eligible classids
    */
   if (me->locate_rtree_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->rtree_classids,
                                    size = me->locate_rtree_thing.w_count);

      if (me->criteria_flag_old & GSPUT_RTREE_CLASSES)
      {
         for (i = 0; i < (IGRint)me->locate_rtree_thing_old.w_count; ++i)
         {
            me->rtree_classids[i] = me->locate_rtree_thing_old.p_classes[i];
         }
      }
      else
      {
         me->rtree_classids[0] = GRgraphics_classid;
      }
   }

   if (me->locate_eligible_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->eligible_classids,
                                    size = me->locate_eligible_thing.w_count);

      if (me->criteria_flag_old & GSPUT_ELIGIBLE_CLASSES)
      {
	if ( me->mytype != 3 )
	{
         for (i = 0; i < (IGRint)me->locate_eligible_thing_old.w_count; ++i)
         {
          me->eligible_classids[i] = me->locate_eligible_thing_old.p_classes[i];
         }
	}
	else
         for (i = 0; i < (IGRint)me->locate_eligible_thing_old.w_count; ++i)
         {
          me->eligible_classids[i] = me->eligibleClassList[i];
	 }
      }
      else
      {
         me->eligible_classids[0] = GRgraphics_classid;
      }
   }

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   me->locate_rtree = &me->locate_rtree_thing;
   me->locate_eligible = &me->locate_eligible_thing;

/*
   status = om$send ( msg = message COgrpevent.build_locate_criteria ( sts ),
		      mode = OM_e_wrt_message,
		      targetid = my_id );
*/
   goto quit;

}


action build_old_locate_criteria
{


  if ( me->mytype != 3 )
  {
    status = gr$gsget_locate_criteria (
			msg = sts,
			locate_env = &me->locate_env_old,
			criteria_flag = &me->criteria_flag_old,
			attributes = &me->attributes_old,
			rtree_classes = &me->locate_rtree_thing_old,
			eligible_classes = &me->locate_eligible_thing_old );
    VDS_ERR_RPT( "get_loc_criteria", status, *sts, VD_VERBOSE );
  }
  else
  {
	/*
	 * hard coding the locate criteria of A V P
	 */

	me->criteria_flag_old = 0xf;
	me->locate_env_old = me->ModuleInfo;
	me->attributes_old.classes[0]    = '\0';
	me->attributes_old.properties = 0x11;
	me->attributes_old.owner_action = 0x6f;

	status =
	om$get_classid(	classname	= "ACncpx" ,
			p_classid	= &me->eligibleClassList[0] );

	status =
	om$get_classid(	classname	= "GRclhdr" ,
			p_classid	= &me->eligibleClassList[1] );

	status =
	om$get_classid(	classname	= "GRsmhdr" ,
			p_classid	= &me->eligibleClassList[2] );


	me->locate_eligible_thing_old.w_count	= 3 ;
	me->locate_eligible_thing_old.w_flags	= 1;
	me->locate_eligible_thing.p_classes	= me->eligibleClassList ;

	me->locate_rtree_thing_old.w_count	= 0;
	me->locate_rtree_thing_old.w_flags	= 0;
	me->locate_rtree_thing.p_classes	= NULL;

  }

  *sts = MSSUCC;

  goto quit;

}

