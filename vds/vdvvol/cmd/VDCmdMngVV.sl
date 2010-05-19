/****************************************************************************

	Filename:	VDCmdMngVV.sl
	Author:		Raju MSB
	Type:		Slic File
	Process by:	$EXNUC/bin/slic -C VDCmdMngVV.sl
	Output:		VDCmdMngVV.S  and VDCmdMngVVi.I

	Description:
	  Command Object to create, modify and delete view volumes

	History:
	Raju    Nov 05, 1994    Creation date

 ****************************************************************************/


/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_MngVV, 0, VDmngVV
class		VDCmdMngVV
super_class	CEO_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"

/* form used */
form		"VDMngVwVol",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

#define  FP_MGR		me^^CEO.forms[0].form_ptr

#include "growner.h"
#include "vdvvoldef.h"

#define  VD_INIT_DIM	10

instance
{

  int		      	num_vvol;
  variable struct GRid	vvol_ids[VD_INIT_DIM];
  variable char		vvol_names[VD_INIT_DIM][VD_MAX_VOL_NAME_LEN];
  variable char		vvol_desc[VD_INIT_DIM][VD_MAX_VOL_DESC_LEN];
  variable char		vvol_used[VD_INIT_DIM];

  int			mod_vol_nb;
  char			mod_vol_name[VD_MAX_VOL_NAME_LEN];
  int			hilited_vol_nb;

  struct  GRobj_env	solid;

}


/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "FI.h"
#include "asmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griomacros.h"

#include "coparamac.h"
#include "grdpbmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "nddef.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "vderrmacros.h"
#include "vdvvolmacros.h"
#include "vdvvoldef.h"

%safe
#include "VX_FIproto.h"
  static int x_pos = -1,y_pos = -1;
%endsafe

extern  OMuword   OPP_NDnode_class_id;
extern  OMuword   OPP_VDviewvol_class_id;


from  VDviewvol  import   VDvv_give_name_desc;
from  NDnode	 import   NDget_objects;
from  VDviewvol  import   VDvv_give_solid;
from  VDviewvol  import   VDvv_display_solid;
from  GRgraphics import   GRdisplay;

/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "VDmsg.h"
#include "vdvvoldef.h"

state start
  message_key	      VD_M_MngVV
  execute	      highlight_solid ( 0 )
  display_form	      0
    on ELSE	      state form_operations

state form_operations
  prompt_key	        VD_P_FormOp
  filter		get_event
  on EX_FORM_FINISHED   state terminate
  on GR_UNKNOWN_TYPE.VD_LOC_SOLID  state locate_solid

state locate_solid
  prompt_key	      VD_P_LocSolBk
  relocate_key	      VD_E_SolNtFnd
  locate_owner        "LC_RIGID_COMP | LC_RIGID_OWNER |
		       LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS"
  locate_eligible     "+EMSsolid"
  mask                "GRm_DATA | GRm_OBJID |
		       GRm_STRING | GRm_RESET | GRm_BACK_UP"
  filter	      locate
     on EX_DATA or EX_STRING
		do check_and_store_solid
		   on ERROR     state .
		state form_oper1
     on EX_OBJID      state .
     on EX_RJT_MOVEON state .
     on EX_BACK_UP    state form_oper1

state form_oper1
   execute		enable_crt_gadgets
   on ELSE		state form_operations


at init     do  create_vol_mgr_if_not_created
	    do  init_instance
	    do  get_vvol_list
	    do  set_manag_form
at wakeup   do  hilite_selected_solid
at sleep    do  erase_hilited_solid
at delete   do  save_form_pos
	    do  erase_hilited_solid

/****************************************************************************/
/*	ACTION  form_notification					*****/
/****************************************************************************/

action  form_notification	extern
action  highlight_solid ( int vvol_nb ) extern

action  check_and_store_solid
{
long			msg, sts1;
char			vvol_solid;
int			ii, num_vvol;
struct  GRid		*vvol_id_list = NULL,
			solid_id;
enum  GRdpmode		dpmode;
struct GRmd_env		solid_env;


    status = OM_S_SUCCESS;

    me->solid.obj_id.objid  = me->event1.located_object[0].located_obj.objid;
    me->solid.obj_id.osnum  = me->event1.located_object[0].located_obj.osnum;
    me->solid.mod_env       = me->event1.located_object[0].module_info;

    __DBGpr_obj( "Solid object", me->solid.obj_id );

    sts1 = vd$get_vvol_list ( msg	= &msg,
			      num_vvol  = &num_vvol,
			      vvol_ids  = &vvol_id_list );
    vvol_solid = FALSE;
    for ( ii=0; ii<num_vvol; ii++)
    {
	sts1 = om$send( msg = message VDviewvol.VDvv_give_solid (
					&msg, &solid_id, &solid_env ),
			targetid = vvol_id_list[ii].objid,
			targetos = vvol_id_list[ii].osnum );
	if ( !(sts1&1) ) continue; /* the file may not be active */
	VDS_ERR_RPT ( "VDviewvol.VDvv_give_solid", sts1, msg, VD_VERBOSE );

	if ( solid_id.objid == me->solid.obj_id.objid &&
	     solid_id.osnum == me->solid.obj_id.osnum    )
	{
	   vvol_solid = TRUE;
	   break;
	}
    }
    if ( vvol_id_list ) free (vvol_id_list);

    if ( vvol_solid )
    {
      *sts = MSFAIL;
      ex$message ( in_buff = "Located Solid is already another View Volume",
		   field   = ERROR_FIELD,
		   justification = CENTER_JUS );

      dpmode = GRbdhe;
      sts1 = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->solid.mod_env.md_env.matrix_type,
					me->solid.mod_env.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
			targetid = me->solid.obj_id.objid,
			targetos = me->solid.obj_id.osnum  );
      me->solid.obj_id.objid = NULL_OBJID;
    }
    else
        *sts = MSSUCC;

    goto quit;

}


action  erase_hilited_solid
{
long		msg;
enum GRdpmode	dpmode;


   /* unhilite highlighted view volume (if any) */
   if ( me->num_vvol > 0 && me->hilited_vol_nb > -1 &&
		me->hilited_vol_nb < me->num_vvol )
   {
	dpmode = GRbdhe;
	status = om$send( msg = message VDviewvol.VDvv_display_solid (
							&msg, &dpmode ),
			targetid = me->vvol_ids[me->hilited_vol_nb].objid,
			targetos = me->vvol_ids[me->hilited_vol_nb].osnum );
	VDS_ERR_RPT ( "VDviewvol.VDvv_display_solid", status, msg, VD_VERBOSE );
	me->hilited_vol_nb = -1;
   }

   goto quit;

}

action  hilite_selected_solid
{


   /* unhilite highlighted view volume (if any) */
   if ( me->num_vvol > 0 && me->hilited_vol_nb > -1 &&
		me->hilited_vol_nb < me->num_vvol )
   {
	status = om$send( msg = message VDCmdMngVV.highlight_solid (
							me->hilited_vol_nb ),
			targetid = my_id );
   }

   goto quit;

}

action  get_vvol_list
{

OMuint		  	num_vvol;
OM_S_CHANSELECT	  	to_components,
			to_listeners;
OM_S_OBJECT_LINKAGE	*vvols = NULL;
long			msg, sts1;
struct  GRid		VolMgr, TmpId, solid;
struct  GRmd_env	solid_env;
char			vvol_name[VD_MAX_VOL_NAME_LEN],
			vvol_desc[VD_MAX_VOL_DESC_LEN],
			vvol_used;
int			ii, jj, count;

   status = OM_S_SUCCESS;

   sts1 = VDget_vol_mgr ( NULL, &VolMgr );

   sts1 = om$make_chanselect (  channame = "GRcmpowner.to_components",
				p_chanselect = &to_components );

   sts1 = om$get_channel_count( objid		=   VolMgr.objid,
				osnum		=   VolMgr.osnum,
				p_chanselect	=   &to_components,
				count		=   &num_vvol );

   __DBGpr_int( "No. of vvols", num_vvol );

   vvols = (OM_S_OBJECT_LINKAGE *) malloc(num_vvol *
						sizeof(OM_S_OBJECT_LINKAGE) );

   sts1 = om$get_channel_objects( objid		=  VolMgr.objid,
				  osnum		=  VolMgr.osnum,
				  p_chanselect	=  &to_components,
				  list		=  vvols,
				  size		=  num_vvol,
				  count		=  &num_vvol );

   if ( num_vvol > VD_INIT_DIM )
   {
      sts1 = om$vla_set_dimension( varray	=  me->vvol_ids,
				   size		=  num_vvol );

      sts1 = om$vla_set_dimension( varray	=  me->vvol_names,
				   size		=  num_vvol );

      sts1 = om$vla_set_dimension( varray	=  me->vvol_desc,
				   size		=  num_vvol );

      sts1 = om$vla_set_dimension( varray	=  me->vvol_used,
				   size		=  num_vvol );
   }

   for( ii=0; ii<num_vvol; ii++ )  me->vvol_used[ii] = FALSE;
   om$make_chanselect ( channame = "GRnotify.notification",
			p_chanselect = &to_listeners );

   me->num_vvol = 0;
   for ( ii=0; ii < num_vvol; ii++ )
   {
      sts1 = om$send (	msg = message VDviewvol.VDvv_give_solid (
						&msg,
						&solid,
						&solid_env ),
			targetid = vvols[ii].S_objid,
			targetos = vvols[ii].osnum );
      /*  sts1&1 != 1 => solid is in reference file and ref file is not
       *  attached at this moment.
       */
      if ( !(sts1&1) ) continue;
      VDS_ERR_CONTINUE("VDviewvol.VDvv_give_solid", sts1, msg, VD_VERBOSE );

      sts1 = om$send ( msg = message VDviewvol.VDvv_give_name_desc (
						&msg,
						vvol_name,
						vvol_desc   ),
		       targetid = vvols[ii].S_objid,
		       targetos = vvols[ii].osnum );
      VDS_ERR_CONTINUE("VDviewvol.VDvv_give_name_desc", sts1, msg, VD_VERBOSE );
/*
      printf(" name[%d] = [%s]\n", ii, vvol_name);
      printf(" desc[%d] = [%s]\n", ii, vvol_desc);
*/
      me->vvol_ids[me->num_vvol].objid = vvols[ii].S_objid;
      me->vvol_ids[me->num_vvol].osnum = vvols[ii].osnum;
      strcpy ( me->vvol_names[me->num_vvol], vvol_name );
      strcpy ( me->vvol_desc[me->num_vvol],  vvol_desc );
      me->num_vvol += 1;

      count = 0;
      sts1 = om$send ( msg = message NDnode.NDget_objects (
						ND_CHILDREN,
						NULL,
						0,
						NULL,
						0,
						OM_K_MAXINT,
						&count ),
			 targetid = vvols[ii].S_objid,
			 targetos = vvols[ii].osnum );
      VDS_ERR_CONTINUE("NDnode.NDget_objects", sts1, 1, VD_VERBOSE);
      if ( count > 0 )	me->vvol_used[me->num_vvol-1] = TRUE;
   }

   /*
    * sort view vols by name
    */
   for( ii=0; ii< me->num_vvol-1; ii++ )
      for ( jj=ii+1;  jj< me->num_vvol; jj++ )
	  if ( strcmp( me->vvol_names[ii], me->vvol_names[jj]) > 0 )
	  {
	     strcpy ( vvol_name, me->vvol_names[ii] );
	     strcpy ( vvol_desc, me->vvol_desc[ii] );
	     TmpId = me->vvol_ids[ii];
	     vvol_used = me->vvol_used[ii];

	     strcpy ( me->vvol_names[ii], me->vvol_names[jj] );
	     strcpy ( me->vvol_desc[ii], me->vvol_desc[jj] );
	     me->vvol_ids[ii] = me->vvol_ids[jj];
	     me->vvol_used[ii] = me->vvol_used[jj];

	     strcpy ( me->vvol_names[jj], vvol_name );
	     strcpy ( me->vvol_desc[jj], vvol_desc );
	     me->vvol_ids[jj] = TmpId;
	     me->vvol_used[jj] = vvol_used;
	  } /* if strcmp( */

   if ( vvols ) free ( vvols );

   goto quit;

}

action  set_manag_form
{
int ii;


   /*
    *  sets list on the form.
    *  unselects last row.
    *  select and display is done by highlight_solid.
    */

   status = OM_S_SUCCESS;

   *sts = MSSUCC;

   FIfld_set_max_num_rows( FP_MGR, VD_VVOL_LIST_FLD, me->num_vvol );
   FIfld_set_num_rows ( FP_MGR, VD_VVOL_LIST_FLD, me->num_vvol );

   for ( ii=0; ii<me->num_vvol; ii++)
   {
     FIfld_set_text ( FP_MGR, VD_VVOL_LIST_FLD, ii, 0, me->vvol_names[ii],
		      FALSE );
     FIfld_set_text ( FP_MGR, VD_VVOL_LIST_FLD, ii, 1, me->vvol_desc[ii],
		      FALSE );
     if ( me->vvol_used[ii] )
	FIfld_set_text ( FP_MGR, VD_VVOL_LIST_FLD, ii, 2, "y", FALSE );
     else
	FIfld_set_text ( FP_MGR, VD_VVOL_LIST_FLD, ii, 2, "", FALSE );
   }

   if ( me->num_vvol > 0 )
   {
      FIfld_set_select( FP_MGR, VD_VVOL_LIST_FLD, me->num_vvol-1, 0, FALSE );
      FIfld_set_select( FP_MGR, VD_VVOL_LIST_FLD, me->num_vvol-1, 1, FALSE );
   }

   FIg_display ( FP_MGR, VD_VVOL_LIST_FLD );

   FIg_enable  ( FP_MGR, FI_ACCEPT );
   FIg_disable ( FP_MGR, FI_CANCEL );
   FIg_disable ( FP_MGR, FI_EXECUTE );

   if(x_pos != -1 && y_pos != -1)
     FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

   goto quit;

}

action  save_form_pos
{

  status = OM_S_SUCCESS;

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

  *sts = MSSUCC;

  goto quit;

}


action create_vol_mgr_if_not_created
{
struct GRid  VolMgr;

     status = VDget_vol_mgr ( NULL, &VolMgr );

     if ( !(status&1) )  status = VDcrt_vol_mgr();

     goto quit;
}

action init_instance
{

   status = OM_S_SUCCESS;

   me->hilited_vol_nb = -1;

   goto quit;
}

action 	enable_crt_gadgets
{

   status = OM_S_SUCCESS;

   FIg_enable ( FP_MGR, FI_CANCEL );
   FIg_enable ( FP_MGR, FI_EXECUTE );

   goto quit;

}
