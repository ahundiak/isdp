/* $Id: VDCmdSlEl.sl,v 1.1.1.1 2001/01/04 21:09:00 cvs Exp $  */

/* I/VDS
 *
 * File:	vdpocket/cmd/VDCmdSlEl.sl
 *
 * Description:
 *		Pocket menu command to select elements inside,
 *		overlapping, inside & overlapping  a solid.
 *
 * Dependencies:
 *
 *
 * Revision History:
 *	$Log: VDCmdSlEl.sl,v $
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
# Revision 1.13  1996/05/02  12:36:02  pinnacle
# Replaced: vdpocket/cmd/VDCmdSlEl.sl for:  by v240_int for vds.240
#
# Revision 1.12  1996/05/01  21:30:36  pinnacle
# Replaced: vdpocket/cmd/VDCmdSlEl.sl for:  by yzhu for vds.240
#
# Revision 1.11  1996/04/19  05:06:08  pinnacle
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

command_string	VDC_M_ElBndSol,0,VDElBndSol
class		VDCmdSlEl
super_class	COgrpevent
product_name	"$VDS"
command_table	"vds.cmd"
status_display  "VDOfsetSol","-1","-1"


start_state start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

instance
{
 struct  GRobj_env    located_obj;
 struct  GRobj_env    offset_solid;
 IGRboolean	      off_sol_constructed;
 char		      rlnNeeded;
 double		      cht;
 long		      stack_empty;
 IGRboolean	      dv;

 IGRint		      criteria_flag_old;
 struct GRmd_env      locate_env_old;
 struct GRlc_locate   attributes_old;		 /* locate attributes  */

 OM_S_CLASSLIST	      locate_rtree_thing_old;    /* actual CLASSLIST thing */
 OM_S_CLASSLIST	      locate_eligible_thing_old; /* actual CLASSLIST thing */

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

#include <math.h>
#include "OMmacros.h"
#include "vdsollocdef.h"
#include "vderrmacros.h"
#define  VD_SENTINAL_VAL	-999999.0
#define  VD_RP_INSIDE  1
#define  VD_OFFSET_FLD		12
#define  VD_OFFSET_TXT		13
#define  VD_INSIDE_FLD  	20
#define  VD_INSIDE_OVERLAP_FLD	21
#define  VD_OVERLAP_FLD		22

#include "griodef.h"
#include "UOMdef.h"
#include "grio.h"
#include "griomacros.h"
#include "UOMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "FI.h"
#include "exmacros.h"
#include "VDmsg.h"
#include "dpdef.h"
#include "dpmacros.h"

from  GRgraphics   import  GRdisplay;
from  GRgraphics   import  GRdelete;
from  GRgraphics   import  GRgetrang;
from  IGEgragad	   import  DPinquire;

extern GRclassid  OPP_EMSsolid_class_id;

%safe
#include "VX_FIproto.h"
static char	rlnNeeded = VD_EL_INSIDE;
static double	stored_offset_db = VD_SENTINAL_VAL;
%endsafe


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "grmsg.h"
#include "VDmsg.h"

state start

  execute check_cmd_stack
	on SUCCESS					state realStart

	status_key VD_E_CmdStkEpt
	on ELSE						state terminate


state realStart

  on CMD_TYPE = 0
	do message_key	VD_M_ElBndSol			 state getOldLocCrit


state getOldLocCrit

  status	" "
    on ELSE     do construct_graphics_set
		do start_transition_for_graphics_set
		do build_old_locate_criteria
		do end_transition_for_graphics_set	state locate_solid


state locate_solid

  message_key		VD_M_ElBndSol
  prompt_key		VD_P_LocSolDV
  relocate_key		VD_S_SolDVNotFnd
  locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER |
			 LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  locate_eligible	"+EMSsolid, GRdrawview"
  mask			"GRm_DATA | GRm_OBJID | GRm_RESET "
  filter		locate

     on EX_OBJID					state .
     on EX_DATA
	do GetSolObj( &me->ret )			state start_proc
     on ELSE						state terminate


state  start_proc

  message_key		VD_M_ElBndSol
  status		"Processing..."

	on ELSE
		do construct_graphics_set
		do start_transition_for_graphics_set
		do set_old_locate_criteria
		do generate_right_prism_from_solid
		do generate_select_set_from_right_prism
		do process_solid_contents
		do end_transition_for_graphics_set
		do define_active_select_set
                   on RETURN_CODE = "MSFAIL"
                	do status_key GR_E_EleNotFnd
							state terminate
		do put_select_set_on_queue
							state terminate


at init    do set_instance
at wakeup  do set_status_disp_form
	   do get_win_display_depths
at sleep   do set_old_display_depths
at delete  do clean_up

action  set_instance
{

/*
   if ( me->mytype == 0 )
	me->rlnNeeded = VD_EL_INSIDE;
   else if ( me->mytype == 1 )
	me->rlnNeeded = VD_EL_INSIDE_OVERLAP;
   else
	me->rlnNeeded = VD_EL_OVERLAP;
*/

   status = OM_S_SUCCESS;

   me->rlnNeeded = rlnNeeded;

   me->window_id.objid		 = NULL_OBJID;
   me->offset_solid.obj_id.objid = NULL_OBJID;
   me->off_sol_constructed	 = FALSE;
   me->stack_empty		 = ex$is_cmd_stack_empty() ?  TRUE : FALSE;

   *sts = MSSUCC;

   goto quit;

}


action check_cmd_stack
{
  status = OM_S_SUCCESS;
  *sts = me->stack_empty ? MSFAIL : MSSUCC;
  goto quit;
}

action set_status_disp_form
{
long		msg;
GRIOalias_name	default_units[3];
IGRshort	flag = 0, num_defaults;
char		type[UOM_K_MAX_TYPE], name[20];
IGRdouble	chtol_db, chtol_def;

	status = OM_S_SUCCESS;
	*sts = MSSUCC;

	BSEXTRACTPAR ( &msg, BSTOLCHRDHT, chtol_db );

	strcpy ( type, GRIO_DISTANCE );
	co$get_default_units(	msg		= &msg,
				table_name	= type,
				osnum		= me->ModuleInfo.md_id.osnum,
				flag		= &flag,
				num_defaults	= &num_defaults,
				default_units	= default_units );

	strcpy( name, default_units[0] );

	status = uom$cvt_value_to_value(msg	     = &msg,
				  unit_type	     = type,
				  osnum		   = me->ModuleInfo.md_id.osnum,
				  alias_to_cvt_from  = NULL,
                                  alias_to_cvt_to    = name,
                                  num_vals	     = 1,
                                  values_in	     = &chtol_db,
                                  values_out	     = &chtol_def);
	me->cht = chtol_def;

	FIg_set_text ( 	me->status_display_form_ptr, VD_OFFSET_TXT, name );

	if ( stored_offset_db == VD_SENTINAL_VAL )
	{
	   if ( me->rlnNeeded == VD_EL_INSIDE )
	      FIg_set_value(me->status_display_form_ptr, VD_OFFSET_FLD, 
			 10*chtol_def);
	   else
	      FIg_set_value(me->status_display_form_ptr, VD_OFFSET_FLD, 0.0);
	}
	else
	{
	   double  offset_def;

	      status = VDdet_conv_int_ext( stored_offset_db, &offset_def,
					   me->ModuleInfo.md_id.osnum );
	      FIg_set_value(me->status_display_form_ptr, VD_OFFSET_FLD,
	 		    offset_def);
	}

	status = om$send ( msg = message CEO_LOCATE.status_display_button
								( 1 ),
			   targetid = my_id );

	if ( me->rlnNeeded == VD_EL_INSIDE )
	  FIg_set_state(me->status_display_form_ptr, VD_INSIDE_FLD, 1);
	else if ( me->rlnNeeded == VD_EL_INSIDE_OVERLAP )
	  FIg_set_state(me->status_display_form_ptr, VD_INSIDE_OVERLAP_FLD, 1);
	else
	  FIg_set_state(me->status_display_form_ptr, VD_OVERLAP_FLD, 1);

	goto quit;


}

action  get_win_display_depths
{
struct var_list		var_list[2];
IGRlong			which_error,
			ret_bytes,
			msg;

    status = OM_S_SUCCESS;
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

action  GetSolObj
{
long			msg;
enum  GRdpmode		dpmode;
struct IGRdisplay	disp;
struct GRvg_construct	cst;
struct GRid		locObj, solid;
struct GRmd_env		locObjEnv, solid_env, tmp_env;
int			sizbuf,
			NoBytesRet;
double			def_offset, db_offset, chtol;
char			type[UOM_K_MAX_TYPE], name[20];
IGRshort		flag = 0, num_defaults;
GRIOalias_name		default_units[3];
GRobjid			off_solid;
GRclassid		locObjClassid;
GRrange			range;
IGRboolean		world;
IGRchar                 msg_str[80];

    *sts = MSSUCC;

    me->located_obj.obj_id    = me->event1.located_object[0].located_obj;
    me->located_obj.mod_env   = me->event1.located_object[0].module_info;

    me->window_id.objid   = me->event1.event.button.objid;
    me->window_id.osnum   = me->event1.event.button.osnum;
    __DBGpr_obj( "Window id", me->window_id );
    status = om$send ( msg = message VDCmdSlEl.get_win_display_depths( &msg ),
		       targetid = my_id );
    VDS_ERR_RPT("VDCmdSlEl.get_win_display_depths", status, msg, VD_VERBOSE);

    locObj     = me->event1.located_object[0].located_obj;
    locObjEnv  = me->event1.located_object[0].module_info;

    dpmode = GRbdhe;
    status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&locObjEnv.md_env.matrix_type,
					locObjEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		       targetid = locObj.objid,
		       targetos = locObj.osnum  );

    ex$message ( field = PROMPT_FIELD,
		 justification = CENTER_JUS,
		 in_buff = "" );

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
   cst.properties = 0;
   cst.class_attr = NULL;
   cst.name       = NULL;

   status = om$get_classid ( osnum     = locObj.osnum,
			     objid     = locObj.objid,
			     p_classid = &locObjClassid   );
   if ( !(status & 1) ) { *sts = MSFAIL; goto quit; }

   me->dv = FALSE;
   if ( om$is_ancestry_valid (	subclassid   = locObjClassid,
				superclassid = OPP_EMSsolid_class_id ) ==
							OM_S_SUCCESS )
   {
	solid = locObj;
	solid_env = locObjEnv;
   }
   else
   {
	me->dv = TRUE;
	world = 1;
	status = om$send ( msg = message GRgraphics.GRgetrang (
					&msg,
					&locObjEnv.md_env.matrix_type,
					locObjEnv.md_env.matrix,
					&world,
					range ),
			  targetid = locObj.objid,
			  targetos = locObj.osnum  );

	status = VDconstruct_box(  &msg, range, &range[3], &cst, &solid );
        if ( !(status & msg & 1) ) { *sts = MSFAIL; goto quit; }
	solid_env = tmp_env;
   }


  /*
   * get offset from status display form
   */
  FIg_get_value ( me->status_display_form_ptr, VD_OFFSET_FLD, &def_offset );

  /* get default units */
  strcpy ( type, GRIO_DISTANCE );
  co$get_default_units(	msg		= &msg,
			table_name	= type,
			osnum		= me->ModuleInfo.md_id.osnum,
			flag		= &flag,
			num_defaults	= &num_defaults,
			default_units	= default_units );
  strcpy( name, default_units[0] );

  /* convert to database units */
  status = uom$cvt_value_to_value(msg	     	     = &msg,
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
	me->offset_solid.obj_id  = solid;
	me->offset_solid.mod_env = solid_env;
	goto quit;
  }

  /*
   * construct a solid outside range tree which is an offset solid by
   * given offset.
   */
  status = VDoffsetSolid( &msg, &solid, &solid_env, &cst, db_offset,
			   &off_solid );
#ifdef VDS_DBG
  VDS_ERR_RPT ( "VDoffsetSolid", status, msg, VD_VERBOSE );
#endif

  if ( status & msg & 1 )
  {
	me->offset_solid.obj_id.objid  = off_solid;
	me->offset_solid.obj_id.osnum  = tmp_env.md_id.osnum;
	me->offset_solid.mod_env       = tmp_env;
	me->off_sol_constructed	       = TRUE;

	if ( me->dv )
	{
	   status = om$send ( msg = message GRgraphics.GRdelete ( &msg,
								  &solid_env ),
			   targetid = solid.objid,
			   targetos = solid.osnum );
	   VDS_ERR_RPT ( "GRgraphics.GRdelete", status, msg, VD_VERBOSE );
	}
  }
  else
  {
        msg_str[0] = '\0';
        sprintf( msg_str,"Offsetting solid '%f' failed, using default",
                                def_offset);

	ex$message (field =  ERROR_FIELD,
		    justification = CENTER_JUS,
		    in_buff = msg_str );

	printf("WARNING : %s\n", msg_str);
	me->offset_solid.obj_id  = solid;
	me->offset_solid.mod_env = solid_env;
	if ( me->dv ) me->off_sol_constructed = TRUE;
        sleep(2);

  }

  goto quit;


}

action form_notification
{
double   offset_def;

#ifdef VDS_DBG
  FIf_cvrt_to_perm_win ( form_ptr );
#endif

  status = OM_S_SUCCESS;

  switch ( gadget_label )
  {
     case FI_ACCEPT:
	FIf_erase ( form_ptr );
	me->form_requested = 0;
	break;

     case VD_OFFSET_FLD:
	FIg_get_value( me->status_display_form_ptr, VD_OFFSET_FLD, &offset_def);
	status = VDdet_conv_ext_int ( offset_def, &stored_offset_db,
				      me->ModuleInfo.md_id.osnum );
	break;

     case VD_INSIDE_FLD:
	me->rlnNeeded = VD_EL_INSIDE;
	if ( stored_offset_db == VD_SENTINAL_VAL )
		FIg_set_value(  me->status_display_form_ptr, VD_OFFSET_FLD,
	 			10.0 * me->cht );
	break;

     case VD_INSIDE_OVERLAP_FLD:
	me->rlnNeeded = VD_EL_INSIDE_OVERLAP;
	if ( stored_offset_db == VD_SENTINAL_VAL )
		FIg_set_value( me->status_display_form_ptr, VD_OFFSET_FLD, 0.0);
	break;

     case VD_OVERLAP_FLD:
	me->rlnNeeded = VD_EL_OVERLAP;
	if ( stored_offset_db == VD_SENTINAL_VAL )
		FIg_set_value( me->status_display_form_ptr, VD_OFFSET_FLD, 0.0);
	break;
  }

  goto quit;

}

action generate_right_prism_from_solid 
{
long		msg;
double		wld_to_lcl_mx[16];



   me->layers_defined = FALSE;
   me->rp_action_args.clip_flag = FALSE;
   me->rp_action_args.gs_id = me->gs_id;
   me->rp_action_args.sv_id = me->sv_id;

   /*
    *  Set up arguments based on type.
    */
   switch ( me->rlnNeeded )			/* (me->mytype) */
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

action process_solid_contents
{
long		msg;
int   		NbObj;
char		sts_str[50];


  status = VDlocateWithSolid1(
			&msg,
			1,
			&me->offset_solid.obj_id,
			&me->offset_solid.mod_env,
			0,				/* num_qry */
			NULL,				/* qry_list */
			me->rlnNeeded,			/* me->mytype */
			VD_LOCATE_WITH_SOLID,
			&NbObj,
			NULL,
			"Processing...",
			&me->gs_id,
			1,
			&me->located_obj.obj_id );
  VDS_ERR_RPT( "VDlocateWithSolid", status, msg, VD_VERBOSE );

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

action clean_up
{
long		 msg;

   if ( me->off_sol_constructed &&
	me->offset_solid.obj_id.objid != NULL_OBJID )
   {
      status = om$send ( msg = message GRgraphics.GRdelete ( 
					&msg,
					&me->offset_solid.mod_env ),
			 targetid = me->offset_solid.obj_id.objid,
			 targetos = me->offset_solid.obj_id.osnum );
   }

   rlnNeeded = me->rlnNeeded;

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
         for (i = 0; i < (IGRint)me->locate_eligible_thing_old.w_count; ++i)
         {
          me->eligible_classids[i] = me->locate_eligible_thing_old.p_classes[i];
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

   *sts = MSSUCC;

   goto quit;
}


action build_old_locate_criteria
{

   status = gr$gsget_locate_criteria (
			msg = sts,
			locate_env = &me->locate_env_old,
			criteria_flag = &me->criteria_flag_old,
			attributes = &me->attributes_old,
			rtree_classes = &me->locate_rtree_thing_old,
			eligible_classes = &me->locate_eligible_thing_old );
   VDS_ERR_RPT( "get_loc_criteria", status, *sts, VD_VERBOSE );

   *sts = MSSUCC;

   goto quit;

}
