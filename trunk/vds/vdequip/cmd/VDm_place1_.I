/* $Id: VDm_place1_.I,v 1.2 2001/02/14 17:50:36 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/cmd / VDm_place1_.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_place1_.I,v $
 *	Revision 1.2  2001/02/14 17:50:36  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/10/12  20:18:22  pinnacle
# tr179900807
#
# Revision 1.3  1999/03/05  04:40:36  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by ssranade for vds
#
# Revision 1.2  1999/01/04  21:44:32  pinnacle
# TR_179802417: Changed READ_PDU to READ_PDU_REV (definition of 30)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.9  1998/02/12  19:24:34  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by impd for vds
#
# Revision 1.8  1998/02/12  19:19:22  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by impd for vds
#
# Revision 1.7  1998/01/03  19:34:16  pinnacle
# string.h
#
# Revision 1.6  1997/12/31  21:27:52  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds
#
# Revision 1.5  1997/12/31  14:38:06  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds
#
# Revision 1.4  1997/12/30  15:46:18  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds
#
# Revision 1.3  1997/12/29  18:15:14  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds
#
# Revision 1.2  1997/10/30  22:15:22  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.8  1996/11/07  21:54:02  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by v241_int for vds.241
#
# Revision 1.7  1996/10/24  21:37:42  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by msmanem for vds.241
#
# Revision 1.6  1996/10/08  13:19:58  pinnacle
# Incorporated fix for TR#179603183.
#
# Revision 1.5  1996/10/06  04:41:46  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by msmanem for vds.241
#
# Revision 1.2  1996/08/07  15:53:48  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.12  1996/05/15  19:14:48  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by azuurhou for vds.240
#
# Revision 1.11  1996/05/15  16:00:56  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds.240
#
# Revision 1.10  1996/05/09  21:23:44  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds.240
#
# Revision 1.9  1996/05/09  19:58:36  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds.240
#
# Revision 1.8  1996/05/09  19:37:22  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds.240
#
# Revision 1.7  1996/05/09  13:34:10  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by kddinov for vds.240
#
# Revision 1.6  1996/05/02  15:21:18  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1996/02/19  10:07:24  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by rchennup for vds.240
#
# Revision 1.4  1996/02/05  12:19:36  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by rgade for vds.240

# Revision 1.3  1995/09/25  23:26:12  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by sundar for vds.240
#
# Revision 1.2  1995/09/25  22:54:12  pinnacle
# Replaced: vdequip/cmd/VDm_place1_.I for:  by sundar for vds.240
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
 *      09/15/90                        creation
 *      11/08/94
 *      11/14/94
 *      11/1/95         msm             Modifications to add PME options
 *      09/25/95        sundar
 *      02/05/96        rgade
 *      02/19/96        rchennup
 *      05/02/95        HF              Roll-back of fix for    TR 179800317
 *                                      due to new              TR 179801483
 *                                      Restore to previous version of
 *                                      "method prompt_macro"
 *                                      FIX for both TR's is in
 *                                      "COm_place execute method" of ASSOC
 *                                      file : COm_place3.I
 *      05/09/96        kdd[1.7]        Check if libraries are mounted.
 *      05/09/96        kdd[1.8]        Corrections to the memory mangmnt _FREE
 *      05/09/96        kdd[1.9-10]     Corrections to the memory mngmnt _MALLOC
 *      05/09/96        kdd[1.11]      	VDCheck_Lib_Path$VDS/vdassoc/dir_macro.I
 *      07/29/96        kdd             Merge the versions 1.5 - 1.12
 *	09/18/96	msm		fix TR #179603072
 *	10/03/96	msm		Disallow place equipment from placement
 *					list if file is frozen or revised.
 *      10/07/96        mra             Check if default PME data is set, before
 *                                      trying to place equipment from PME.
 *      10/30/97        ah              enum warning message
 *
 *	12-97		kdd		Place VDequipment from PID selection.
 *	01/03/97	ah		Added string.h for CLIX
 *	01/04/99	ejm		TR_179802417: gadget "Read PDU Review"
 *					has conversion factor number, instead;
 *					conflicts with COm_place.wakeup defini-
 *					tion of "SCALE_FACT"; replaced READ_PDU
 *					with READ_PDU_REV
 * 	Mar 5 99	Rajendra	TR # 1798002545 If connected to SIR,
 * 					hide PME buttons on the form.
 *	08/26/99	ejm		TR_179900807: Now call VdsRisSqlDblToStr
 *					  to retain exponential numbers and to  
 *					  remove trailing zeroes before
 *					  displaying double attribute values.
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation VDm_place;

/*
#define vdserrDEBUG	1
#define vdsDEBUG	1
*/

#include "OMprimitives.h"
#include "coparadef.h"
#include "coparamac.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exdef.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "nddef.h"
#include "acdef.h"
#include "acmacros.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "FI.h"
#include "string.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "asmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"

#include "expmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "PDUerror.h"
#include "VDSequipdef.h"
#include "VDSutil.h"
#include "VDdebug.h"
#include "VDmem.h"
#include "VDPdef.h"
#include "VDPdm2.h"
#include "execmsg.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"
#include "vdreporterr.h"
#include "vdparmacros.h"
#include "vdbmacros.h"
#include "VDToolsDef.h"
#include "VDAttribMac.h"
#include "vdprdmacros.h"

//  lc$locate requirements
#include        "OMlimits.h"
#include        "OMminimum.h"
#include        "igrtypedef.h"
#include        "igetypedef.h"
#include        "igrdp.h"
#include        "igr.h"
#include        "godef.h"
#include        "gr.h"
#include        "go.h"
#include        "dp.h"
#include        "ex.h"
#include        "griodef.h"
#include        "grio.h"
#include        "lcdef.h"
#include        "lc.h"
#include        "lcmacros.h"
#include        "exmacros.h"


#define MAX_WORD        81  
#define MAX_WHERE_SIZE  300
 
#define ERROR_BOX 1

#define AS_DEBUG

#define READ_PDU_REV 30

from	ACdb_info	import	ACset_db_info;
from	NDnode		import	NDchg_state;
from	ACconst		import	ACmplace_from_def;
from	GRvg		import	GRputname;
from	NDnode		import	ASreturn_go;
from	NDnode		import	NDdelete;
from	FIdirform	import	update;

%safe
static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;

static VDactive_equip_lib = -1,
       VDactive_family = -1,
       VDactive_part = -1;

static char VDactive_catalog[macro_MAX_CHAR];
static char VDactive_macro[macro_MAX_CHAR];
static char VDactive_lib[macro_MAX_CHAR];
static char VDactive_EqpLib[64];
static char VDactive_EqpFam[64];
static char VDactive_EqpPart[64];
static char VDactive_EqpPartRev[64];
%endsafe

extern  struct ACdef_param ACglobal_place;
extern	GRclassid	OPP_ACrg_collect_class_id;
extern GRclassid        OPP_VDequipment_class_id;

extern int 	VD_PDU_present;

extern int	VDPPreldLstForm_notif();

from	ACrg_collect	import	ACadd_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;
from	ACrg_collect	import	AClist_attribute;
from	ACrg_collect	import	ACget_attribute_at_index;
from	ACrg_collect	import	ACchg_prop_mgr;
from	VDPEqBuffer	import	VDPsetEquipList;
from  VDSroot         import  VDGetParamsId;

/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/

VDm_place_router(form_label,label,value,form_ptr)
int form_label,label;
IGRdouble value;
char *form_ptr;
/*.VDm_router*/
{
 int status;
 struct GRid cmd_obj;
 unsigned int	cmd_oid;
 unsigned short cmd_os;

        SetProc(VDm_place_router ); Begin

 FIf_get_cmd_oid_os(form_ptr,&cmd_oid,&cmd_os);
 cmd_obj.objid = (GRobjid)cmd_oid;
 cmd_obj.osnum = (GRspacenum)cmd_os;
 if(cmd_obj.osnum == 0)
  {
   if(label != FORM_ABORT)
    {
     ex$message(msgnumb = AS_S_FoNoAc);
    }
   else om$send(msg = message COm_place.delete_form(),
	        senderid = NULL_OBJID,
	        targetid = cmd_obj.objid,
	        targetos = OM_Gw_TransOSnum_0);
  }
 else
  {
   status = om$send(msg = message VDm_place.form_notification
				              (form_label,label,value,form_ptr),
		  senderid = NULL_OBJID,
		  targetid = cmd_obj.objid,
		  targetos = cmd_obj.osnum);
   if (status != PDU_WARNING && status != OM_S_SUCCESS ) as$status();
  }
	End
 return(1);
}

VDm_place_select(form_label,label,value,form_ptr)
int form_label,label;
IGRdouble value;
char *form_ptr;

/*.VDm_place_select*/
{
 extern struct GRid *ACpath_grid;
 int row,pos;
 struct	GRid	cmd_obj;
 IGRlong	sts;
 unsigned int	cmd_oid;
 unsigned short cmd_os;

	SetProc(VDm_place_select ); Begin

if( label == FORM_ABORT || label == FORM_ACCEPT)
 {
/* KDD 10-97: Ultimately gets back to form_notification: ACCEPT_SELECTION */
    COm_place_select(form_label,label,value,form_ptr);
    goto wrapup;
 }

 switch(label)
 {

  case EQUIP_LIB : /*| display the possible catalog */
  FIfld_get_active_row(form_ptr,label,&row,&pos);
  VDactive_equip_lib = row;
  VDactive_family = -1;
  VDactive_part	= -1;
  break;	/*1*/

  case FAMILY : /*| display the possible release of this equipement */
  FIfld_get_active_row(form_ptr,label,&row,&pos);
  VDactive_family = row;
  VDactive_part	= -1;
  break;	/*2*/

  case PART: /*| Display static and dynamics attributes for the part name*/
  FIfld_get_active_row(form_ptr,label,&row,&pos);
  VDactive_part = row;
  break;	/*3*/

  default :
	printf(" cas defaut de VDm_place_select\n");
	printf(" on sort \n");
	return	OM_S_SUCCESS;
 }

 FIf_get_cmd_oid_os(form_ptr,&cmd_oid,&cmd_os);
 cmd_obj.objid = (GRobjid)cmd_oid;
 cmd_obj.osnum = (GRspacenum)cmd_os;
 sts = om$send(	msg	 = message VDm_place.VDm_display_select(),
			senderid = NULL_OBJID,
			targetid = cmd_obj.objid,
			targetos = cmd_obj.osnum );
	as$status( sts = sts, action = RET_STATUS );

wrapup:
	End
return	OM_S_SUCCESS;
}

method get_form_name(char *form_name)
{
    SetProc( get_form_name : VDm_place1_.I  ); Begin

  if (IsPmeEnabled())
    strcpy(form_name,"VDPlEqui");
  else
    strcpy(form_name,"VDPlEqui.O");

End;
  return OM_S_SUCCESS;
}


method init (int type; char *string_ptr )
{
 int status;
 char form_name[80];
 int FORM = 0;

	SetProc(init : VDm_place1_.I); Begin

 status = om$send(msg = message COpara.init(type,string_ptr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);

  /* Initialize form */

 status = om$send(msg = message COm_place.get_form_name(form_name),
		  targetid = my_id);
 if(!(status&1)) return OM_W_ABORT;

 FIf_new( FORM, form_name , VDm_place_router, &me->form_ptr);
 if(!me->form_ptr) return OM_W_ABORT;

 if(x_memo != -1)
  {
   FIf_set_location(me->form_ptr,x_memo,y_memo);
   FIf_set_screen(me->form_ptr,s_memo);
  }

 if (!VD_PDU_present)
 {
   /*Non-PDU version executing*/
   FIg_delete(me->form_ptr,17);		     /* Delete "or" text */
   FIg_delete(me->form_ptr,20);		     /* Delete "Read PDU Review" button */
   FIg_set_location(me->form_ptr,11,10,40);  /* Move "Select from Data Base" button*/
   FIg_set_location(me->form_ptr,14,10,67);  /* Move "Options" button*/
   FIg_set_location(me->form_ptr,16,10,94);  /* Move "Naming" button*/
 }

 // Rajendra Mar 5 TR # 179802545
 // If connected to SIR hide PME button!
 if ( !strcmp(form_name, "VDPlEqui") && ( WhichAim() == SIR ))
 {
   FIg_erase(me->form_ptr, 25 );
 } 
 
 FIf_display(me->form_ptr);

  /* Initialize instances */

  me->form_option_ptr = NULL;
  me->form_select_ptr = NULL;
  me->user_form_ptr = NULL;
  me->form_names_ptr = NULL;
  me->Preloaded_items_form = NULL;
  me->macro_name[0] = 0;
  me->macro_id.objid = NULL_OBJID;
  me->macro_id.osnum = 0;
  me->macro_type = (enum poss_macro)-1;
  me->def_id.objid = NULL_OBJID;
  me->hdr_name[0] = 0;
  me->hdr.objid = NULL_OBJID;
  me->def_hdr.objid = NULL_OBJID;
  me->def_window.objid = NULL_OBJID;

  me->Nb_Max_Temp = 0;
  me->index_to_locate = -1;

/* 12-97 KDD attributed coming from a located PID equipment */ 
  me->PIDNumUsrAttr 	= 0;
  me->PIDUsrAttr 	= NULL;
  me->PIDNumAddAttr 	= 0;
  me->PIDAddAttr 	= NULL;
  me->LocatedPID.objid 	= NULL_OBJID;

  /* Initialize default options */

  me->hdr_symb   = ACglobal_place.symb;
  me->hdr_type   = ACglobal_place.hdr_type;
  me->hdr_scroll = ACglobal_place.hdr_scroll;
  me->hdr_def    = ACglobal_place.hdr_def;
  strcpy(me->search_path,ACglobal_place.search_path);

  me->dyn_dup	= NULL;
  me->equip_lib_index	= -1;
  me->family_index	= -1;
  me->part_index	= -1;

  /* Initialise the PME Equipment List */

  /* Initialise chanselect to connect grset */ 

   status = om$make_chanselect (
      channame = "COm_place.located_graphics",
      p_chanselect = &me->located_chansel );
   as$status();

	End
  return(status);
}

method wakeup ( IGRint n )
{
 int status;

	SetProc(wakeup : VDm_place1_.I); Begin

 if( me->form_select_ptr != NULL) FIf_display(me->form_select_ptr);
  
 status = om$send(msg = message COm_place.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 UI_message("Place Equipment");

	End
 return (status);
}

method sleep(int n )
{
  int status;
  char *save_select;

	SetProc(sleep : VDm_place1_.I); Begin

/* I don't want select sub form to be deleted */
  save_select = me->form_select_ptr;
  me->form_select_ptr = NULL;
    
  status = om$send(msg = message COm_place.sleep(n),
			targetid = my_id,
			mode = OM_e_wrt_message); 

  me->form_select_ptr = save_select;
  if(me->form_select_ptr) FIf_erase(me->form_select_ptr);
  if(me->Preloaded_items_form) FIf_erase(me->Preloaded_items_form);

	End
  return( status );
}   

method delete(int n)
{
 int status;

	SetProc(delete : VDm_place1_.I); Begin

 if( me->form_select_ptr != NULL )
  {
   FIf_delete(me->form_select_ptr);
// FIf_erase (me->form_select_ptr);	// THIS CAN NEVER BE OK ; AFTER FIf_delete() the pointer is invalid !!!
   me->form_select_ptr = NULL;
  }

 if( me->Preloaded_items_form != NULL )
  {
   FIf_delete(me->Preloaded_items_form);
// FIf_erase (me->Preloaded_items_form);// THIS CAN NEVER BE OK ; AFTER FIf_delete() the pointer is invalid !!!
   me->Preloaded_items_form = NULL;
  }

 /*| free memory */
  _FREE(me->dyn_dup );

  if ( me->PIDUsrAttr) { _FREE(me->PIDUsrAttr); me->PIDUsrAttr = NULL;} 
  if ( me->PIDAddAttr) { _FREE(me->PIDAddAttr); me->PIDAddAttr = NULL;}
  me->PIDNumUsrAttr =0;
  me->PIDNumAddAttr =0;
  me->LocatedPID.objid  = NULL_OBJID;


 status = om$send(msg = message COm_place.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
	End
 return(status);
}

method form_notification(int form_label,label;double value; char *fp)
{
 long 		status=OM_S_SUCCESS;
 IGRboolean  	bPmeData = FALSE;
 IGRlong     	msg = MSSUCC;

char    	response_data[256]; 
int     	response, num = 0, NumSysAtt = 0, NumDynAttr = 0,
		i, dyn_len, stat_len;
 
struct ACrg_coll        Collection[8], *p_coll, 
			*SysAtt = NULL, 
			*DynAttr = NULL;

struct GRid		UsrParId, MisParId, SysParId;

  char      	table[MAX_WORD],
            	select[MAX_WHERE_SIZE],
            	search[MAX_WHERE_SIZE],
            	order[MAX_WORD],
            	n_attr,
		classname[256],
		*p_str,
            	**buffer;

  IGRint                NumCollection;
  IGRlong               retcode;
struct GRevent          event1, event2;
struct GRlc_locate      attributes;
OM_S_CLASSLIST          classlist;
OMuword                 class[2]; 
//OMuword		dummy1;
IGRlong                 eventsize;
 
 


	SetProc( VDm_place.form_notification ); Begin

	/*| initialization */
	status	= ~0;
	UsrParId.objid = MisParId.objid = SysParId.objid = NULL_OBJID;

	VDactive_EqpLib[0] = '\0';
	VDactive_EqpFam[0] = '\0';
	VDactive_EqpPart[0] = '\0';
	VDactive_EqpPartRev[0] = '\0';

__DBGpr_int("label      ", label); 
 
 switch (label)
  {
    case FI_SELECT_FROM_PID: {
	if ( *fp != *me->form_ptr) break;

/*--------------------------------- CR179701029 --------------------------------
# KDD 10-97. 
* New button "Select from PID" on "VDPlEqui" and "VDPlEqui.O" forms.
* This selection will drive "VDPlEqui1" form with parameters from located PID.
* The button is FI_SELECT_FROM_PID, the form is me->form_ptr.
*
* Set VDactive_lib, VDactive_family, VDactive_part, VDactive_part_rev.
* Method VDm_display_select will handle the selection process itself. 
------------------------------------------------------------------------------*/

/*---- 12-97 KDD  Disable PID Selection if not running Route ----*/
  	if ( !vd$prd_get_product_info( run_name = "Route" ))  {
		vd$report_error(error = "Route is not running");
	        FIg_set_state_off (me->form_ptr, FI_SELECT_FROM_PID);
	    	FIg_disable (me->form_ptr, FI_SELECT_FROM_PID); 
		break;
	}

/*------------------------
# Locate PID Equipment. EX_DATA = 1, EX_OBJID is odd.  
------------------------*/
    	class[0] = (OMuword) OPP_VDequipment_class_id;

	status = om$get_classid ( classname = "VREquipment", 
			          p_classid = &class[1] ); 

	if ( !(status & OM_S_SUCCESS) ) { classlist.w_count = 1; }
	else                            { classlist.w_count = 2; }
			 

    	classlist.w_flags = OM_CLST_subclass;
    	classlist.p_classes= class;

    	attributes.properties =   LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY;
    	attributes.owner_action = LC_RIGID_COMP | LC_RIGID_OWNER |
				  LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS;


    	eventsize = sizeof (struct GRevent);

    	retcode = lc$locate( rc			= &msg,
			     event1		= &event1,
			     event2		= &event2,
			     eventsize		= &eventsize,
			     mask1		= GRm_DATA  | GRm_STRING ,
                             mask2              = GRm_DATA  | GRm_OBJID ,
			     acc_prompt		= "Accept/Reject",
			     locate_prompt	= "Locate PID Equipment",
			     relocate_prompt	= "Equipment not found", 
			     display_flag	= ALL_WINDOWS | ELEM_HILIGHT |
						  NO_PROJ_ACCEPT_POINT, 
			     response		= &response, 
			     response_data	= response_data,
			     attributes		= &attributes,
			     stack		= &me->locate_stack,
			     eligible_classes	= &classlist);

    	FIg_set_state_off (me->form_ptr, FI_SELECT_FROM_PID); 
    	UI_prompt("");
    	UI_status("");

    	me->LocatedPID = event2.located_object[0].located_obj;

    	if ((me->LocatedPID.objid == NULL_OBJID) || !(msg & retcode & 1)) break;
			 
__DBGpr_obj("Located Object", me->LocatedPID);


/*---------------------
# Retrieve attributes from the located equipment. 
*
# Store the Dyn + Usr (VDequipment) or Usr + Add (VREquipment) attributes.
* VDequipment: 	Dyn = all_params - "stat:"
* 		Usr = vd$getUsrAttributes
*
* VREquipment:	Usr = VRGeneric.VRGetParams( , , &UsrParId, )
*		Add = Usr - Mis
*		      where Mis = VRGeneric.VRGetParams( , , , &MisParId) 
*
* Note: VRGeneric.VRGetParams == VDSroot.VDGetParamsId
----------------------*/

	if ( me->PIDUsrAttr) { _FREE(me->PIDUsrAttr); me->PIDUsrAttr = NULL;}
        if ( me->PIDAddAttr) { _FREE(me->PIDAddAttr); me->PIDAddAttr = NULL;}
        me->PIDNumUsrAttr =0;
        me->PIDNumAddAttr =0;

        om$get_classname( osnum         = me->LocatedPID.osnum,
                          objid         = me->LocatedPID.objid,
                          classname     = classname);

        if ( !strcmp(classname,"VDequipment") ) {
           vd$get_params(  sts          = &msg,
                           object       = &me->LocatedPID,
                           md_env       = &event2.located_object[0].module_info,
                           count        = &NumDynAttr,
                           plist        = &DynAttr)
 
	   SysAtt = _MALLOC( NumDynAttr, struct ACrg_coll); 

           /* remove "stat_attr:" & "dyn_attr:" from attribute names*/
           dyn_len  = strlen("dyn_attr:");
           stat_len  = strlen("stat_attr:");
	   NumSysAtt = 0; 
 
           for ( i = 0; i < NumDynAttr; i++){
               	if ( (p_str = strstr(DynAttr[i].name, "stat_attr:")) != NULL ) {
			   SysAtt[ NumSysAtt ] = DynAttr[i];
			   strcpy( SysAtt[ NumSysAtt ].name, p_str + stat_len);
			   NumSysAtt++;

                           DynAttr[i] = DynAttr[ NumDynAttr - 1];
			   NumDynAttr--;
			   i--; 
			   continue;
		}
 
               if ( (p_str = strstr(DynAttr[i].name, "dyn_attr:")) != NULL )
                           strcpy( p_str, p_str + dyn_len);
           }
 
	   SysAtt = _REALLOC( SysAtt, NumSysAtt, struct ACrg_coll); 

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_MERGE_COLL,
                                p_ParamsListToModify  = DynAttr,
                                NbParamsToModify      = NumDynAttr,
                                OutParList            = &me->PIDUsrAttr,
                                OutNumPar             = &me->PIDNumUsrAttr );

	   vd$getUsrAttributes( sts	= &msg,
                             object	= me->LocatedPID,
                             md_env 	= &event2.located_object[0].module_info,
                             nbAttrs	= &me->PIDNumAddAttr,
                             att 	= &me->PIDAddAttr)

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_SUBSTR_COLL,
                                p_ParamsListToModify  = me->PIDAddAttr,
                                NbParamsToModify      = me->PIDNumAddAttr,
                                OutParList            = &me->PIDUsrAttr,
                                OutNumPar             = &me->PIDNumUsrAttr );
        }
        else if ( !strcmp(classname,"VREquipment") ) {
           status = om$send( msg     = message VDSroot.VDGetParamsId
                                       (&msg, &SysParId, &UsrParId, &MisParId),
                        targetid = me->LocatedPID.objid,
                        targetos = me->LocatedPID.osnum );
 

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_MERGE_COLL,
                                p_InputCollectionId   = &SysParId,
                                OutParList            = &SysAtt,
                                OutNumPar             = &NumSysAtt );


           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_MERGE_COLL,
                                p_InputCollectionId   = &UsrParId,
                                OutParList            = &me->PIDAddAttr,
                                OutNumPar             = &me->PIDNumAddAttr );

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_MERGE_COLL,
                                p_InputCollectionId   = &MisParId,
                                OutParList            = &me->PIDUsrAttr,
                                OutNumPar             = &me->PIDNumUsrAttr );

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_UPDATE_COLL,
                                p_ParamsListToModify  = me->PIDAddAttr,
                                NbParamsToModify      = me->PIDNumAddAttr,
                                OutParList            = &me->PIDUsrAttr,
                                OutNumPar             = &me->PIDNumUsrAttr );

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_SUBSTR_COLL,
                                p_ParamsListToModify  = me->PIDUsrAttr,
				NbParamsToModify      = me->PIDNumUsrAttr,
                                OutParList            = &me->PIDAddAttr,
                                OutNumPar             = &me->PIDNumAddAttr );
        }

__DBGpr_int("\nSys  attributes SysAtt        ", NumSysAtt);
for (i = 0; i < NumSysAtt; i++ )
{
if ( SysAtt[i].desc.type == AC_ATTRIB_DOUBLE )
  { __DBGpr_dbl(SysAtt[i].name, SysAtt[i].desc.value.att_exp); }
else
  { __DBGpr_str(SysAtt[i].name, SysAtt[i].desc.value.att_txt); }
}




__DBGpr_int("\nUsr  attributes me->PIDUsrAttr", me->PIDNumUsrAttr);
for (i = 0; i < me->PIDNumUsrAttr; i++ )
{
if ( me->PIDUsrAttr[i].desc.type == AC_ATTRIB_DOUBLE )
  { __DBGpr_dbl(me->PIDUsrAttr[i].name, me->PIDUsrAttr[i].desc.value.att_exp); }
else
  { __DBGpr_str(me->PIDUsrAttr[i].name, me->PIDUsrAttr[i].desc.value.att_txt); }
}



__DBGpr_int("\nAdd  attributes me->PIDAddAttr", me->PIDNumAddAttr);
for (i = 0; i < me->PIDNumAddAttr; i++ )
{
if ( me->PIDAddAttr[i].desc.type == AC_ATTRIB_DOUBLE )
 { __DBGpr_dbl(me->PIDAddAttr[i].name, me->PIDAddAttr[i].desc.value.att_exp); }
else
 { __DBGpr_str(me->PIDAddAttr[i].name, me->PIDAddAttr[i].desc.value.att_txt); }
}


/*---------------------
# Retrieve attributes from located PID equipment. 
----------------------*/
    	strcpy( Collection[0].name,"eqp_family" );
    	Collection[1].desc.type = AC_ATTRIB_TEXT;
    	strcpy( Collection[0].desc.value.att_txt, "");

    	strcpy( Collection[1].name, "eqp_partrev");
    	Collection[1].desc.type = AC_ATTRIB_TEXT;
    	strcpy( Collection[1].desc.value.att_txt, "");

    	strcpy( Collection[2].name, "eqp_partno");
    	Collection[2].desc.type = AC_ATTRIB_TEXT;
    	strcpy( Collection[2].desc.value.att_txt, "");

    	NumCollection = 3;

    	p_coll = & Collection[0];

    	VD$ModifyCollection(    p_msg                 = &retcode,
    	                        Operation             = VD_UPDATE_COLL,
    	                        p_ParamsListToModify  = SysAtt,
    	                        NbParamsToModify      = NumSysAtt,
    	                        OutNumPar             = &NumCollection,
    	                        OutParList            = &p_coll );

    	strcpy( VDactive_EqpFam    , Collection[0].desc.value.att_txt);
    	strcpy( VDactive_EqpPartRev, Collection[1].desc.value.att_txt);
    	strcpy( VDactive_EqpPart   , Collection[2].desc.value.att_txt);

__DBGpr_str("EquipFam	", VDactive_EqpFam  ); 
__DBGpr_str("EquipPart	", VDactive_EqpPart); 
__DBGpr_str("EquipRev	", VDactive_EqpPartRev); 

/*----------------
# Get the Equipment library, using the template in vdutil/VDSequip_ut.C 
-----------------*/
	if ( (strlen(VDactive_EqpPart)    == 0) || 
	     (strlen(VDactive_EqpPartRev) == 0) || 
	     (strlen(VDactive_EqpFam  )   == 0) ) { 

		vd$report_error( error = "Family, Part or Revision missing");
                break;
        }

        sprintf( select, "%s", "p_macropartno");
        sprintf( table , "%s", "pdmparamloc");
        sprintf( search, "%s = '%s' and %s = '%s'",
                 "p_macrocat","pdmlibraries","n_catalogname", VDactive_EqpFam); 
        sprintf( order , "%s", "p_macropartno");
        n_attr = 1;
        msg = vdb$RisSelect(  select       =       select,
                              table_name   =       table,
                              where        =       search,
                              order        =       order,
                              group        =       NULL,
                              numselect    =       n_attr,
                              p_numrows    =       &num,
                              p_buffer     =       &buffer );

	if ( !(msg&1) || (num == 0) ){ 
	   vd$report_error( error = "Equipment Library not found", mode = 2);
	   break;
	}

	strcpy( VDactive_EqpLib, buffer[ 0 ] ); 

__DBGpr_str("EquipLib	", VDactive_EqpLib); 

/*--------------------------
# Drive the form VDPlEqui1 (me->form_select_ptr). Copied from DEF_SELECTION.
--------------------------*/
	if( me->form_select_ptr == NULL )
          FIf_new( (int)fp,"VDPlEqui1", VDm_place_select,&me->form_select_ptr);
 
       	if(!me->form_select_ptr) return OM_W_ABORT;
 
       	FIf_set_cmd_oid_os(me->form_select_ptr,my_id,OM_Gw_current_OS);
       	FIf_display( me->form_select_ptr );

       	VDactive_equip_lib = me->equip_lib_index;
       	VDactive_family    = me->family_index;
       	VDactive_part      = me->part_index;
 
       	status = om$send(  msg      = message VDm_place.VDm_display_select(),
                           targetid = my_id );

	break;
    }
/*---------------------- End CR179701029 --------------------*/
 
    case FORM_RESTART: 
     /*|Form restart*/
        VDactive_equip_lib = me->equip_lib_index = -1;
        VDactive_family = me->family_index = -1;
        VDactive_part = me->part_index = -1;
        if(me->form_select_ptr != NULL)
        {
          status = om$send(msg	 = message VDm_place.VDm_display_select(),
				targetid = my_id );
	  as$status();
        }

          status = om$send(msg = message COm_place.form_notification
					(form_label,label,value,fp),
  		     targetid = my_id,
		     mode = OM_e_wrt_message);
           as$status();

	if ( me->PIDUsrAttr) { _FREE(me->PIDUsrAttr); me->PIDUsrAttr = NULL;} 
	if ( me->PIDAddAttr) { _FREE(me->PIDAddAttr); me->PIDAddAttr = NULL;}
	me->PIDNumUsrAttr =0;
	me->PIDNumAddAttr =0;
	me->LocatedPID.objid  = NULL_OBJID;

       break;	/*4*/

    case DEF_SELECTION :
     {
       UI_prompt(" ");
       if (VDSverify_login() != PDM_S_SUCCESS)
       {  
           UI_status("User is not logged in to Database");
           break;
       }
       if (VDSverify_project() != OM_S_SUCCESS)
       {
           UI_status("User not Selected Project");
           break;
       }

       if( me->form_select_ptr == NULL )
	      FIf_new( (int)fp,"VDPlEqui1", VDm_place_select,&me->form_select_ptr);

       if(!me->form_select_ptr) return OM_W_ABORT;

       FIf_set_cmd_oid_os(me->form_select_ptr,my_id,OM_Gw_current_OS);
       FIf_display( me->form_select_ptr );
       VDactive_equip_lib = me->equip_lib_index;
       VDactive_family = me->family_index;
       VDactive_part = me->part_index;

	status = om$send(	msg	 = message VDm_place.VDm_display_select(),
				targetid = my_id );
	as$status();

        if ( me->PIDUsrAttr) { _FREE(me->PIDUsrAttr); me->PIDUsrAttr = NULL;}
        if ( me->PIDAddAttr) { _FREE(me->PIDAddAttr); me->PIDAddAttr = NULL;}
        me->PIDNumUsrAttr =0;
        me->PIDNumAddAttr =0;
	me->LocatedPID.objid  = NULL_OBJID;

      break;	/*5*/
    }

    /* Placement of Preloaded Equipments for PME */

    case PRELOADED_EQUIPMENT :
    {
	if( IsPmeEnabled() == FALSE )
	{
           UI_status("PME server connection required");
           break;
	}

	UI_prompt(" ");
        if (VDSverify_login() != PDM_S_SUCCESS)
        {  
            UI_status("User is not logged in to Database");
            break;
        }

        bPmeData = VDPIsPmeDataSet( &msg );

        if( bPmeData == FALSE )
        {
          UI_status( "Default PME data is not set" );
          break;
        }

	/* Initialise Preloaded List Buffer */

	status = om$send (  msg = message VDm_place.init_pme_buffer (),
                        targetid = my_id );
  	if ( status != OM_S_SUCCESS )
	{
		goto wrapup;
	}

	me->PMobid[0] = '\0';

	if ( me->Preloaded_items_form == NULL )
		FIf_new( (int)fp,"VDPEqPreload", VDPPreldLstForm_notif, &me->Preloaded_items_form );
	if (!me->Preloaded_items_form ) return OM_W_ABORT;

	FIf_set_cmd_oid_os(me->Preloaded_items_form,my_id,OM_Gw_current_OS);

	status = VDPInitialiseForm( me->Preloaded_items_form );
	FIf_display( me->Preloaded_items_form );

	FIg_set_state( fp, PRELOADED_EQUIPMENT, 0 );

        if ( me->PIDUsrAttr) { _FREE(me->PIDUsrAttr); me->PIDUsrAttr = NULL;}
        if ( me->PIDAddAttr) { _FREE(me->PIDAddAttr); me->PIDAddAttr = NULL;}
        me->PIDNumUsrAttr =0;
        me->PIDNumAddAttr =0;
	me->LocatedPID.objid  = NULL_OBJID;

        break;
    }


    case READ_PDU_REV :
    {
	UI_prompt(" ");

	status = om$send( msg	   = message VDm_place.VDm_read_pdu_part(),
			  targetid = my_id );
 	if(!(status&1))
         {
          FIg_set_state_off(fp,READ_PDU_REV);
          break;
         }

	/*| load macro_lib */
	/*" VDactive_lib : %s\n", VDactive_lib */
	status = ac$construct_path(	mode	= AC_ADD_PATH,
					name	= VDactive_lib );
        if(status != OM_S_SUCCESS)
        {
           UI_status("Error : Macro library not mounted");
           FIg_set_state_off(fp,READ_PDU_REV);
           break;	/*6*/
        }
        strcpy( me->macro_name, VDactive_macro );

	status = om$send(msg = message COm_place.set_action_and_state
					(STO_MAC,WAIT_TEM),
			  targetid = my_id);

        FIg_set_state_off(fp,READ_PDU_REV);

        if ( me->PIDUsrAttr) { _FREE(me->PIDUsrAttr); me->PIDUsrAttr = NULL;}
        if ( me->PIDAddAttr) { _FREE(me->PIDAddAttr); me->PIDAddAttr = NULL;}
        me->PIDNumUsrAttr =0;
        me->PIDNumAddAttr =0;
	me->LocatedPID.objid  = NULL_OBJID;

        break;	/*7*/
    }

    case ACCEPT_SELECTION :

       if(VDactive_part >= 0)
	{

	/*| load macro_lib */
	/*" VDactive_lib : %s\n", VDactive_lib */
	status = ac$construct_path(	mode	= AC_ADD_PATH,
					name	= VDactive_lib );
        if(status != OM_S_SUCCESS)
        {
           UI_status("Error : Macro library not mounted");
           goto wrapup;  
        }

         me->equip_lib_index = VDactive_equip_lib;
         me->family_index = VDactive_family;
         me->part_index = VDactive_part;

	 strcpy( me->macro_name, VDactive_macro );
	 status = om$send(msg = message COm_place.set_action_and_state
					(STO_MAC,WAIT_TEM),
			  targetid = my_id);
        }
       else 
        {
	 UI_status("Part to place is not defined");
        }

    wrapup:
	/*| display off form */
	FIg_set_state( fp, DEF_SELECTION, 0 );
	if ( me->form_select_ptr != NULL )
	{
	    FIf_erase( me->form_select_ptr );
	    FIf_delete( me->form_select_ptr );
	    me->form_select_ptr = NULL;
	}

     break;	/*8*/
   
     default :
        status = om$send(msg = message COm_place.form_notification
					(form_label,label,value,fp),
  		     targetid = my_id,
		     mode = OM_e_wrt_message);
     as$status();
     if(label == FORM_EXEC) FIg_set_state_off(fp,FORM_EXEC);
   
  }

 if ( SysAtt ) _FREE (SysAtt); 
 if ( DynAttr ) _FREE (DynAttr); 

 End
 return status;
}


method prompt_macro()
{

	SetProc(prompt_macro ); Begin

 UI_prompt(" Select equipment from data base ");
 me->Entry_Request	= PROMPT;
	End
 return  OM_S_SUCCESS;
} 

method pro_template()
{
 int status;

	SetProc(pro_template : VDm_place1_); Begin

 /*| Verify if this template is static or dynamics */
 if(me->template_type[me->index_to_locate]&VD_DYNAMICS)
  {
   status = om$send(msg = message COm_place.pro_template(),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
  }
 else
  {
   me->state = WAIT_TEM; 
   me->action = NEXT_TEMP;
   me->Entry_Request = NOTHING;
  }
	End
 return OM_S_SUCCESS;
}

method VDm_display_select()

{
 /* get and display catalog */
 int i;
 int select;

 int                    nb_equip_cat=0;
 char                   **equip_cat_list, **macro_lib_partno, **macro_lib_rev;

 int                    nb_family=0;
 char                   **family_name;

 int                    nb_parts=0;
 char                   **part_names, **revision_names;
 char			text[80];
 char 			macro_file[80];





 IGRlong		sts;
 struct	ACrg_coll	my_att;	
 IGRlong			msg;
 IGRint			nb_stat, nb_dyn;
 struct	GRid		cur_mod;

 long                   status;

	SetProc(VDm_display_select ); Begin

	/* Add initialization if the query fails to avoid bad deallocation */
	part_names 	= NULL;
	revision_names 	= NULL;
	equip_cat_list	= NULL;
	macro_lib_partno= NULL;
	macro_lib_rev   = NULL;
	family_name	= NULL;
	

	/*| Get and display catalog of equipements */

	/*" VDactive_equip_lib	: %d\n", VDactive_equip_lib */
	/*" VDactive_family	: %d\n", VDactive_family */
	/*" VDactive_part	: %d\n", VDactive_part */

	/*| av VDSget_equip_cat */
	if( VDSget_equip_cat( "equipment", &nb_equip_cat, 
				&equip_cat_list, &macro_lib_partno,
                              &macro_lib_rev) != 1 ){

		UI_status("Bad connection with database");
                /*| Error VDSget_equip_cat */
		goto wrapup;
	}
/*^
	printf(" nb_equip_cat : %d\n", nb_equip_cat );
	for( i=0; i<nb_equip_cat; i++ ){

		printf(" row[%d] --> equip_cat_list : %s", 
					i, equip_cat_list[i] );
		printf("\t macro_lib_partno : %s", macro_lib_partno[i] );
		printf("\t macro_lib_partno : %s\n", macro_lib_partno[i] );
	}
*/

	FIfld_set_num_rows( me->form_select_ptr, EQUIP_LIB, nb_equip_cat );
	select = FALSE;

	/*" VDactive_equip_lib : %d\n", VDactive_equip_lib */
	if( nb_equip_cat == 1 ) VDactive_equip_lib = 0;
	for(i=0; i<nb_equip_cat; i++ ){

/* 12-97 KDD Match+Select library row i with VDactive_EqpLib */
           if(!strcmp(VDactive_EqpLib, equip_cat_list[i])) VDactive_equip_lib=i;

		if(VDactive_equip_lib == i) select = TRUE;
		else		        select = FALSE;
		/*"  equip_cat_list[%d] = %s, select = %d\n", i, equip_cat_list[i], select */
		FIfld_set_text( me->form_select_ptr, EQUIP_LIB, i, 0, equip_cat_list[i], select );
	}

        UI_status("");
	/*| If calatog selected display contains of the catalog */

	/*" VDactive_equip_lib : %d\n", VDactive_equip_lib */
	if( VDactive_equip_lib >= 0 ){

		/*| av VDSget_families */
		if( VDSget_families( macro_lib_partno[VDactive_equip_lib], 
                                     macro_lib_rev[VDactive_equip_lib], 
				     &nb_family, &family_name) != 1 ){

			UI_status("Bad connection with database");
                        /*| Error in VDSget_families \n*/
			goto wrapup;

		}
/*******
*       Check if the library is mounted.
*******/
                status= VDCheck_Lib_Path (macro_lib_partno[VDactive_equip_lib]);
                if ( !(status & 1)) {
                   UI_status(" Macro library not mounted");

                   FIfld_set_num_rows( me->form_select_ptr, FAMILY,     0 );
                   FIfld_set_num_rows( me->form_select_ptr, PART,       0 );
                   FIfld_set_num_rows( me->form_select_ptr, ATTRIBUTES, 0 );

                   goto wrapup;
                }

/*^
		printf(" nb_family : %d\n", nb_family );
		for( i=0; i<nb_family; i++ )
			printf(" family_name[%d] : %s\n", i, family_name[i] );
*/
		FIfld_set_num_rows( me->form_select_ptr, FAMILY, nb_family );
		FIfld_set_num_rows( me->form_select_ptr, PART, 0 );
		FIfld_set_num_rows( me->form_select_ptr, ATTRIBUTES, 0 );
		if( nb_family ==1 ) VDactive_family = 0;
		for(i=0 ; i<nb_family; i++ ) {

/* 12-97 KDD Match+Select EqpFam row i with VDactive_EqpFam */
                        if (!strcmp(VDactive_EqpFam, family_name[i])) 
					VDactive_family=i;

			if( VDactive_family == i )	select = TRUE;
			else				select = FALSE;

			 FIfld_set_text( me->form_select_ptr, FAMILY, i, 0,
						family_name[i], select );
		}
	}/*end get family*/
        else {
            FIfld_set_num_rows( me->form_select_ptr, FAMILY, 0 );
	    FIfld_set_num_rows( me->form_select_ptr, PART, 0 );
	    FIfld_set_num_rows( me->form_select_ptr, ATTRIBUTES, 0 ); 
        }

        UI_status("Processing ......");
	/*| If family selected get and display possible parts */

	/*" VDactive_family : %d\n", VDactive_family */
	if( VDactive_family>= 0 ){

		/*| VDSget_family_parts */
		if( VDSget_family_parts( family_name[VDactive_family], 
				&nb_parts, &part_names, &revision_names) !=1 ){

                        UI_status("Bad connection with database");
			/*|Error in VDSget_family_parts\n*/
			goto wrapup;

		}
/*^
		printf(" nb_parts : %d\n", nb_parts );
		for( i=0; i<nb_parts; i++ ){
			printf(" row[%d] --> part_names : %s", i, part_names[i] );
			printf("\t revision_names : %s\n", revision_names[i] );
		}
*/
		FIfld_set_num_rows( me->form_select_ptr, PART, nb_parts );
		FIfld_set_num_rows( me->form_select_ptr, ATTRIBUTES, 0 );

                if( nb_parts == 1 ) VDactive_part = 0;
		for ( i=0; i<nb_parts; i++ ) {
/* 12-97 KDD Match+Select Part+Rev row i with VDactive_EqpPart */
                        if ((!strcmp(VDactive_EqpPart,    part_names[i])) && 
			    (!strcmp(VDactive_EqpPartRev, revision_names[i])) )
					VDactive_part=i;

			if( VDactive_part == i )	select = TRUE;
			else				select = FALSE;

			FIfld_set_text( me->form_select_ptr, PART, i, 0, part_names[i], select );
			FIfld_set_text( me->form_select_ptr, PART, i, 1, 
						revision_names[i], select );
		}
	}/*end select part*/
        else     /* VDactive_family < 0 */
        {
            FIfld_set_num_rows( me->form_select_ptr,PART,0);
            FIfld_set_num_rows( me->form_select_ptr,ATTRIBUTES,0);
        }  

        UI_status("Processing ......");
	/*| If part selected get and display attributes */

	/*" VDactive_part : %d\n", VDactive_part */
	if( VDactive_part >= 0 ){


		/*| set db_info structure */

		strcpy(	me->db_info.catalog, equip_cat_list[VDactive_equip_lib]);
		strcpy(	me->db_info.part_num, part_names[VDactive_part] );
		strcpy(	me->db_info.revision, revision_names[VDactive_part] );
		me->db_info.quantity	= -1;
/*^
		printf(" VDactive_family : %d\n", VDactive_family );
		printf(" VDactive_part : %d\n", VDactive_part );
		printf(" family_names[%d] : %s\n", VDactive_family, 
					family_name[VDactive_family] );
		printf(" part_names[%d] : %s\n", VDactive_part, 
					part_names[VDactive_part] );
		printf(" revision_names[%d] : %s\n", VDactive_part, 
					revision_names[VDactive_part] );
*/
		macro_file[0] = '\0';


		/*| set macro name */
		strcpy( VDactive_lib, macro_lib_partno[VDactive_equip_lib] );
		strcpy( VDactive_catalog,family_name[VDactive_family]);

		/*| get curent os */
		ex$get_cur_mod(	id	= &cur_mod.objid,
				osnum	= &cur_mod.osnum );

		/*| rg_collection static */
		me->stat_box.osnum	= cur_mod.osnum;
		sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
					osnum	= me->stat_box.osnum,
					p_objid = &me->stat_box.objid );
		as$status( sts = sts  , action = RET_STATUS);
		/*" stat_box : id/os = (%d/%d)\n", me->stat_box.objid, me->stat_box.osnum */

		sts = om$send(	msg	 = message NDnode.NDchg_state
						(ND_DEL_NO_CH | ND_WAIT_DEL,
						ND_DEL_NO_CH | ND_WAIT_DEL),
				targetid = me->stat_box.objid,
				targetos = me->stat_box.osnum );
		as$status( sts = sts  , action = RET_STATUS);
		UI_status("Processing.......");

		/*| DYN att */
		me->dyn_box.osnum	= cur_mod.osnum;
		sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
					osnum	= me->dyn_box.osnum,
					p_objid = &me->dyn_box.objid );
		as$status( sts = sts  , action = RET_STATUS);
		/*" dyn_box : id/os = (%d/%d)\n", me->dyn_box.objid, me->dyn_box.osnum */

		sts = om$send(	msg	 = message NDnode.NDchg_state
						(ND_DEL_NO_CH | ND_WAIT_DEL,
						ND_DEL_NO_CH | ND_WAIT_DEL),
				targetid = me->dyn_box.objid,
				targetos = me->dyn_box.osnum );
		as$status( sts = sts  , action = RET_STATUS);
		UI_status("Retrieval of attributes in progress ....");

		/*| set box with atttr */
		sts = VDset_select_att(	family_name[VDactive_family],
					part_names[VDactive_part],
					revision_names[VDactive_part],
					&me->stat_box,
					&me->dyn_box );
		as$status( sts = sts  , action = RET_STATUS);

		/*| display att in form */
		sts = om$send(	msg	 = message ACrg_collect.AClist_attribute(
						&msg,
						0,
						NULL,
						&nb_stat ),
				targetid = me->stat_box.objid,
				targetos = me->stat_box.osnum );
		as$status( sts = sts  , action = RET_STATUS);

		sts = om$send(	msg	 = message ACrg_collect.AClist_attribute(
						&msg,
						0,
						NULL,
						&nb_dyn ),
				targetid = me->dyn_box.objid,
				targetos = me->dyn_box.osnum );
		as$status( sts = sts  , action = RET_STATUS);

		/*| SC att */
		FIfld_set_num_rows( me->form_select_ptr, ATTRIBUTES, 
							nb_stat+nb_dyn );

		for( i=0; i<nb_stat; i++ ){

			sts = om$send(	msg	 = message 
					ACrg_collect.ACget_attribute_at_index(
							&msg,
							i,
							&my_att ),
					targetid = me->stat_box.objid,
					targetos = me->stat_box.osnum );
			as$status( sts = sts  , action = RET_STATUS);

			FIfld_set_text( me->form_select_ptr, ATTRIBUTES, 
						i, 0, my_att.name, FALSE );

			if( my_att.desc.type == AC_ATTRIB_DOUBLE )
			{
			/* sprintf( text, "%f", my_att.desc.value.att_exp ); */
			  // TR179900807
			    VdsRisSqlDblToStr(my_att.desc.value.att_exp, text);
			}
			else	strcpy( text, my_att.desc.value.att_txt );

			FIfld_set_text( me->form_select_ptr, ATTRIBUTES, 
						i, 1, text, FALSE );
		}

		for( i=0; i<nb_dyn; i++ ){

			sts = om$send(	msg	 = message 
					ACrg_collect.ACget_attribute_at_index(
							&msg,
							i,
							&my_att ),
				targetid = me->dyn_box.objid,
				targetos = me->dyn_box.osnum );
			as$status( sts = sts  , action = RET_STATUS);

			FIfld_set_text( me->form_select_ptr, ATTRIBUTES, 
						i, 2, my_att.name, FALSE );
		}

		/*| store check in value in static box */
		strcpy( my_att.name, "mac_name" );
		my_att.desc.type	= AC_ATTRIB_TEXT;
		strcpy( my_att.desc.value.att_txt, VDactive_macro );
		sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute(
						&msg, 
						1,
						&my_att ),
				targetid = me->stat_box.objid,
				targetos = me->stat_box.osnum );
		as$status( sts = sts  , action = RET_STATUS);
		as$status( sts = msg  , action = RET_STATUS);


		/*| lock static box */
		sts = om$send(	msg	 = message ACrg_collect.ACchg_prop_mgr( 
						AC_BOX_LOCKED | AC_BOX_CACHE,
						AC_BOX_LOCKED | AC_BOX_CACHE ),
				targetid = me->stat_box.objid,
				targetos = me->stat_box.osnum );
		as$status( sts = sts  , action = RET_STATUS);

                UI_status("");
	}
        else
          FIfld_set_num_rows( me->form_select_ptr, ATTRIBUTES,0);
        

wrapup :

	/*| free memory */
    for(i=0;i<nb_parts;i=i+1) {
	  _FREE( part_names[i] );
	  _FREE( revision_names[i] );
       }
    _FREE(part_names);
    _FREE(revision_names);

    for(i=0;i<nb_family;i=i+1)
       {
	  _FREE(family_name[i]);
       }
    _FREE( family_name);
    for(i=0;i<nb_equip_cat;i=i+1)
       {
	  _FREE( equip_cat_list[i]);
	  _FREE( macro_lib_partno[i]);
	  _FREE( macro_lib_rev[i]);
       }
    _FREE( equip_cat_list);
    _FREE( macro_lib_partno);
    _FREE( macro_lib_rev);

	End
return	1;
}

method VDm_read_pdu_part()
  /* get equipment part from PDU review */
{
  char             partid[65];
  char             revision[65];
  IGRlong          sts;
  struct ACrg_coll my_att;        
  IGRlong          msg;
  struct GRid      cur_mod;

	SetProc(VDm_read_pdu_part ); Begin

  /*Call refresh form function */
  sts = read_equip_pdu_review(VDactive_catalog,partid,revision,VDactive_lib);
/*  as$status( sts = sts  , action = RET_STATUS);*/
  if(!(sts&1)) return(sts);

  /*| set db_info structure */

  strcpy(me->db_info.catalog,  VDactive_catalog);
  strcpy(me->db_info.part_num, partid );
  strcpy(me->db_info.revision, revision );
  me->db_info.quantity         = -1;

  /*| get curent os */
  ex$get_cur_mod(id    = &cur_mod.objid,
                 osnum = &cur_mod.osnum );

  /*| rg_collection static */
  me->stat_box.osnum        = cur_mod.osnum;
  sts = om$construct(classid = OPP_ACrg_collect_class_id,
                     osnum   = me->stat_box.osnum,
                     p_objid = &me->stat_box.objid );
  as$status( sts = sts  , action = RET_STATUS);
  /*" stat_box : id/os = (%d/%d)\n", me->stat_box.objid, me->stat_box.osnum */

  sts = om$send(msg      = message NDnode.NDchg_state(
                                                   ND_DEL_NO_CH | ND_WAIT_DEL,
                                                   ND_DEL_NO_CH | ND_WAIT_DEL),
                targetid = me->stat_box.objid,
                targetos = me->stat_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);

  /*| DYN att */
  me->dyn_box.osnum = cur_mod.osnum;
  sts = om$construct(classid = OPP_ACrg_collect_class_id,
                     osnum   = me->dyn_box.osnum,
                     p_objid = &me->dyn_box.objid );
  as$status( sts = sts  , action = RET_STATUS);
  /*" dyn_box : id/os = (%d/%d)\n", me->dyn_box.objid, me->dyn_box.osnum */

  sts = om$send(msg      = message NDnode.NDchg_state(
                                                   ND_DEL_NO_CH | ND_WAIT_DEL,
                                                   ND_DEL_NO_CH | ND_WAIT_DEL),
                targetid = me->dyn_box.objid,
                targetos = me->dyn_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);

  /*| set box with atttr */
  sts = VDset_select_att( VDactive_catalog,
                          partid,
                          revision,
                          &me->stat_box,
                          &me->dyn_box );
  as$status( sts = sts  , action = RET_STATUS);

  /*| store check in value in static box */
  strcpy( my_att.name,               "mac_name" );
  my_att.desc.type                   = AC_ATTRIB_TEXT;
  strcpy( my_att.desc.value.att_txt, VDactive_macro );

  sts = om$send( msg      = message ACrg_collect.ACadd_list_attribute(&msg, 
                                                                      1,
                                                                      &my_att ),
                 targetid = me->stat_box.objid,
                 targetos = me->stat_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);
  as$status( sts = msg  , action = RET_STATUS);

  /*| lock static box */
  sts = om$send( msg         = message ACrg_collect.ACchg_prop_mgr( 
                                                AC_BOX_LOCKED | AC_BOX_CACHE,
                                                AC_BOX_LOCKED | AC_BOX_CACHE ),
                 targetid = me->stat_box.objid,
                 targetos = me->stat_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);

  UI_status("");

	End
  return OM_S_SUCCESS;
}

method write_form ()
{
IGRlong		sts;
int		i, j;

	SetProc(write_form : VDm_place1_); Begin

/* 12-97 KDD update templates with the attributes from the located equipment */
  for (i = 0; i < me->Nb_Max_Temp; i++ ) {
  for (j = 0; j < me->PIDNumUsrAttr; j++ ) {
 
      if (strcmp(me->PIDUsrAttr[ j ].name, me->dup[i].prompt)) continue;
 
__DBGpr_str( "matching attribute", me->PIDUsrAttr[ j ].name);
 
      switch ( me->PIDUsrAttr[ j ].desc.type ) { 
      case AC_ATTRIB_DOUBLE:
          me->Temp_Value[i].type = double_type;
          me->dup[i].type        = double_type;

          me->Temp_Value[i].var.root_pm_st.value =
                                me->PIDUsrAttr[ j ].desc.value.att_exp;
          break;
 
      case AC_ATTRIB_TEXT:
          me->Temp_Value[i].type = text_type;
          me->dup[i].type        = text_type;

          strcpy( me->Temp_Value[i].var.text_st.text_string,
	                        me->PIDUsrAttr[ j ].desc.value.att_txt);
          break;
      }
 
      break;
  }
  }

	sts = om$send(	msg	 = message COm_place.write_form(),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

	End
return	OM_S_SUCCESS;
}

method get_default_template()
{
IGRlong			sts;
IGRlong			i, j;
IGRlong			msg;
struct	ACrg_coll	my_att;
IGRint			previous_size, nb_alloc, nb_dyn_att;

	SetProc(get_default_template : VDm_place1_.I); Begin

	me->nb_tot_dyn = 0;
	nb_alloc = macro_MAX;

/*^
	printf(" nb_max_temp : %d\n", me->Nb_Max_Temp );
	printf(" nb_min_var_temp : %d\n", me->Nb_Min_Var_Temp );
	printf(" nb_max_var_temp : %d\n", me->Nb_Max_Var_Temp );
*/
	sts = om$send(	msg	 = message ACrg_collect.AClist_attribute
					( &msg, 0, NULL, &nb_dyn_att ),
			targetid = me->dyn_box.objid,
			targetos = me->dyn_box.osnum );
	as$status( sts = sts );

	/*| allocation des dyn_dup */
	/*| free old dyn_dup */
	_FREE(me->dyn_dup );

	me->dyn_dup = _MALLOC( (nb_dyn_att + me->Nb_Max_Temp), struct sup );
	if( me->dyn_dup == NULL ){
		UI_status(" Not enougth memory");
		sts = 0;
		goto	wrapup;
	}

//printf("nb_dyn_att = %d, me->Nb_Max_Temp = %d\n",nb_dyn_att, me->Nb_Max_Temp);
	
	/*| out static */
	for( i=0; i<me->Nb_Max_Temp; i++ )
	{
		strcpy( my_att.name, me->dup[i].prompt );
		sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
						( &msg, &my_att ),
				targetid = me->stat_box.objid,
				targetos = me->stat_box.osnum );
		as$status( sts = sts );

		if( !(msg&1)){

			/*| dyn template --> need */
			me->dyn_dup[me->nb_tot_dyn++] = me->dup[i];

		}
	}

//printf("me->nb_tot_dyn = %d, nb_alloc = %d\n", me->nb_tot_dyn, nb_alloc );

__DBGpr_int("me->nb_tot_dyn     ", me->nb_tot_dyn    );

	/*| add new dynamics */
	for( i=0; i<nb_dyn_att; i++ )
	{
		sts = om$send(	msg	 = message ACrg_collect.ACget_attribute_at_index
						( &msg, i, &my_att ),
				targetid = me->dyn_box.objid,
				targetos = me->dyn_box.osnum );
		as$status( sts = sts );

		for( j=0; j<me->Nb_Max_Temp; j++ )
			if( ! strcmp( my_att.name, me->dup[j].prompt ))	break;

		if( j == me->Nb_Max_Temp ) {

			/*| add attrib */
			strcpy( me->dyn_dup[me->nb_tot_dyn].prompt, my_att.name );

			if( my_att.desc.type == AC_ATTRIB_DOUBLE ){
				me->dyn_dup[me->nb_tot_dyn].type = double_type;
				me->Temp_Value[	me->nb_tot_dyn].type = double_type;
				me->Temp_Value[	me->nb_tot_dyn].var.root_pm_st.
					value = my_att.desc.value.att_exp;
			} else {

				me->dyn_dup[me->nb_tot_dyn].type = text_type;
				me->Temp_Value[	me->nb_tot_dyn].type = text_type;
				strcpy( me->Temp_Value[	me->nb_tot_dyn].
					var.text_st.text_string, 
						my_att.desc.value.att_txt );
			  }

/* --- CORRECTION PL June 1st 1994 : realloc instead of error ----

			if(me->nb_tot_dyn >= macro_MAX)
			 {
			  printf("Equipment error\n");
			  return OM_W_ABORT;
			 }
*/
			
			if(me->nb_tot_dyn + 1 >= nb_alloc)	// HF:02/12/98 TR#179800520 (added +1 to me->nb_tot_dyn)
			{
				/* realloc enough space for template */

//printf("\ti = %d, j = %d, me->nb_tot_dyn = %d, nb_alloc = %d\n", i,j, me->nb_tot_dyn, nb_alloc );

       				nb_alloc = nb_alloc+10;

       				sts =om$send(msg = message COm_place.realloc_template(
							nb_alloc),
					     targetid = my_id);
       				as$status( sts = sts , action = goto wrapup);

       				/* don't forget to realloc me->template_type */

 				previous_size = om$dimension_of(varray = me->template_type);
 				if(previous_size < nb_alloc) {
 
 			  	sts = om$vla_set_dimension(varray = me->template_type,
                               				size = nb_alloc);
         		  	as$status( sts = sts , action = goto wrapup);

				}
			}

/* --- END CORRECTION PL June 1st 1994 : realloc instead of error ---- */

			me->nb_tot_dyn++;
		}
	}
/*^
	printf(" nb dyn temp : %d\n", me->nb_tot_dyn );
	for( i=0; i<me->nb_tot_dyn; i++ )
		printf(" me->dyn_dup[%d].prompt = %s; \t type = %x\n", i, 
				me->dyn_dup[i].prompt, me->dyn_dup[i].type );
*/


	/*| set new context */
	me->Nb_Max_Temp		= me->nb_tot_dyn;
	me->Nb_Min_Var_Temp	= me->nb_tot_dyn;
	me->Nb_Max_Var_Temp	= me->nb_tot_dyn;


	me->dup = me->dyn_dup;

	for( i=0; i<me->nb_tot_dyn; i++ ){
		me->template_type[i] 	= VD_DYNAMICS;
		me->Temp_Elig[i].objid	= NULL_OBJID;
		me->Temp_List[i].objid	= NULL_OBJID;
		me->Temp_Value[i].type	= me->dup[i].type;
	}

	sts = om$send(	msg	 = message COm_place.get_default_template(),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

wrapup : ;

	/*| destruction of dyn box */
	sts = om$send(	msg	 = message NDnode.NDdelete
					( &me->ModuleInfo ),
			targetid = me->dyn_box.objid,
			targetos = me->dyn_box.osnum );
	as$status( sts = sts );

	End
return	sts;
}

/* ******************* FCT VDset_select_att () ************************	*/

VDset_select_att( fam, part, rev, sbox, dbox )

IGRchar		*fam;
IGRchar		*part;
IGRchar		*rev;
struct	GRid	*sbox;
struct	GRid	*dbox;

{
IGRlong			sts, msg;
/*struct	ACrg_coll	my_att;*/
IGRint			nb_stat;
struct	VDSatt_family	*stat_attr;
IGRint			nb_dyn;
struct	VDSatt_family	*dyn_attr;
IGRint			i;

	SetProc(VDset_select_att ); Begin

	/*| initialization */
	nb_stat	= 0;
	nb_dyn	= 0;
	stat_attr	= NULL;
	dyn_attr	= NULL;

	/*| call ch fct */
	sts = VDSget_attr( fam, part, rev, "EQUIP", &nb_stat, &stat_attr,
				&nb_dyn, &dyn_attr);
        if(!(sts & 1))
        {
/*           UI_status("Bad connection with database");*/
           goto wrapup;
        } 

	strcpy(VDactive_macro,fam);
	for( i=0; i<nb_stat; i++)
	{
		if(!strcmp(stat_attr[i].attr.name,"p_macro"))
		{
			strcpy(VDactive_macro, stat_attr[i].attr.desc.value.att_txt );
		  	break;
		}
	}

	for( i=0; i<nb_stat; i++ ){

		sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute
						( &msg, 1, &stat_attr[i].attr ),
				senderid = NULL_OBJID,
 				targetid = sbox->objid,
 				targetos = sbox->osnum );
 		as$status( sts = sts );
	}

	for( i=0; i<nb_dyn; i++ ){

		sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute
						( &msg, 1, &dyn_attr[i].attr ),
				senderid = NULL_OBJID,
 				targetid = dbox->objid,
 				targetos = dbox->osnum );
 		as$status( sts = sts );
	}


wrapup :

	/*| free memory */
	_FREE( stat_attr );
	_FREE( dyn_attr );
	End
return	sts;
}


method VDPsetSelectedPart( IGRlong *msg; IGRchar *CatalogName; IGRchar *PartNumber; IGRchar *PartRev; IGRchar	*PMobid )
{
  IGRlong          sts;
  struct ACrg_coll my_att;        
  struct GRid      cur_mod;

    SetProc( VDPsetSelectedPart ); Begin

  *msg = MSSUCC;

  sts = IsEquipmentPart( msg, CatalogName, PartNumber, PartRev );
  if( !(sts&*msg&1) )
      return OM_E_ABORT;

  strcpy( VDactive_catalog, CatalogName );

  /*| set db_info structure */

  strcpy(me->db_info.catalog,  CatalogName);
  strcpy(me->db_info.part_num, PartNumber );
  strcpy(me->db_info.revision, PartRev );
  me->db_info.quantity         = -1;
  strcpy( me->PMobid, PMobid );

  /*| get curent os */
  ex$get_cur_mod(id    = &cur_mod.objid,
                 osnum = &cur_mod.osnum );

  /*| rg_collection static */
  me->stat_box.osnum        = cur_mod.osnum;
  sts = om$construct(classid = OPP_ACrg_collect_class_id,
                     osnum   = me->stat_box.osnum,
                     p_objid = &me->stat_box.objid );
  as$status( sts = sts  , action = RET_STATUS);
  /*" stat_box : id/os = (%d/%d)\n", me->stat_box.objid, me->stat_box.osnum */

  sts = om$send(msg      = message NDnode.NDchg_state(
                                                   ND_DEL_NO_CH | ND_WAIT_DEL,
                                                   ND_DEL_NO_CH | ND_WAIT_DEL),
                targetid = me->stat_box.objid,
                targetos = me->stat_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);

  /*| DYN att */
  me->dyn_box.osnum = cur_mod.osnum;
  sts = om$construct(classid = OPP_ACrg_collect_class_id,
                     osnum   = me->dyn_box.osnum,
                     p_objid = &me->dyn_box.objid );
  as$status( sts = sts  , action = RET_STATUS);
  /*" dyn_box : id/os = (%d/%d)\n", me->dyn_box.objid, me->dyn_box.osnum */

  sts = om$send(msg      = message NDnode.NDchg_state(
                                                   ND_DEL_NO_CH | ND_WAIT_DEL,
                                                   ND_DEL_NO_CH | ND_WAIT_DEL),
                targetid = me->dyn_box.objid,
                targetos = me->dyn_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);

  /*| set box with atttr */
  sts = VDset_select_att( CatalogName,
                          PartNumber,
                          PartRev,
                          &me->stat_box,
                          &me->dyn_box );
  as$status( sts = sts  , action = RET_STATUS);

  /*| store check in value in static box */
  strcpy( my_att.name,               "mac_name" );
  my_att.desc.type                   = AC_ATTRIB_TEXT;
  strcpy( my_att.desc.value.att_txt, VDactive_macro );

  VDSget_eqp_library ( VDactive_macro, VDactive_lib );
  sts = om$send( msg      = message ACrg_collect.ACadd_list_attribute(msg, 
                                                                      1,
                                                                      &my_att ),
                 targetid = me->stat_box.objid,
                 targetos = me->stat_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);
  as$status( sts = *msg  , action = RET_STATUS);

  /*| lock static box */
  sts = om$send( msg         = message ACrg_collect.ACchg_prop_mgr( 
                                                AC_BOX_LOCKED | AC_BOX_CACHE,
                                                AC_BOX_LOCKED | AC_BOX_CACHE ),
                 targetid = me->stat_box.objid,
                 targetos = me->stat_box.osnum );
  as$status( sts = sts  , action = RET_STATUS);

  UI_status("");

  /*| load macro_lib */
  /*" VDactive_lib : %s\n", VDactive_lib */
  sts = ac$construct_path(	mode	= AC_ADD_PATH,
				name	= VDactive_lib );
  if(sts != OM_S_SUCCESS)
  {
     UI_status("Error : Macro library not mounted");
  }
  strcpy( me->macro_name, VDactive_macro );

  sts = om$send(msg = message COm_place.set_action_and_state
					(STO_MAC,WAIT_TEM),
			  targetid = my_id);
End;
  return OM_S_SUCCESS;
}

method init_pme_buffer()
{
    IGRlong		msg = MSSUCC, status = OM_S_SUCCESS;
    struct GRid		Buf,DirId;
    OMuword		curOs;
    IGRchar		DirName[DI_PATH_MAX],
			ListName[DI_PATH_MAX];
    IGRchar             PlacementCtx[VDPNAME_LEN];
    IGRchar             ContextId[VDPOBID_LEN];
    IGRboolean		ListExist=FALSE;
    IGRint		fileState=0;
    IGRchar		errmsg[256];
    extern GRclassid    OPP_VDPEqBuffer_class_id;

    SetProc ( VDm_place.init_pme_buffer ); Begin

    Buf.objid = NULL_OBJID;
    ex$get_cur_mod( osnum = &curOs );

    /* Get the Placement Context */
    status = VDPGetPlacementContext( &msg, PlacementCtx, ContextId );
    __CheckRC( status, msg, "VDPGetPlacementContext", wrapup );

    status = VDPGetFileState( &msg, curOs, &fileState );
    if( !(status & 1))
    {
	return OM_E_ABORT;
    }
    if( fileState == VDP_FILE_REVISED )
    {
        strcpy(errmsg,"The current design file is revised in PME. It should also be revised in PDU. ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
	return OM_E_ABORT;
    }
    else if( fileState == VDP_FILE_FROZEN )
    {
        strcpy(errmsg,"The current design file is frozen in PME. It should  be revised before further executing PME commands ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
	return OM_E_ABORT;
    }

    /* get directory path name */

    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );

    __CheckRC( status, 1, "di$give_pathname", wrapup );
    __DBGpr_str( "Path name", DirName );

    strcat( DirName, PME_GLOBAL_DIR );

    status =
    di$translate ( objname = DirName,
                   p_objid = &DirId.objid,
                   p_osnum = &DirId.osnum ) ;

    __DBGpr_obj( "Dir Id", DirId );

    /*A create PME_GLOBAL if it does not exist     */
    if ( status != DIR_S_SUCCESS )
    {
        DirId.objid = NULL_OBJID;

        status =
        di$mkdir( dirname = DirName,
                  p_dirid = &DirId.objid,
                  p_osnum = &DirId.osnum );

        __DBGpr_obj( "Dir Id", DirId );

         if( status != DIR_S_SUCCESS )
        {
             /*A Cannot create directory*/
             di$report_error( sts = status ) ;
             goto    wrapup;
        }
    }
    else
    {
        sprintf( ListName,"%s%s",DirName,PME_EQP_LIST );
        __DBGpr_str( "Equipment Buffer name", ListName );

        status =
        di$translate  ( objname = ListName,
                        p_objid = &Buf.objid,
                        p_osnum = &Buf.osnum ) ;

        __DBGpr_obj( "Equipment Buffer Id", Buf );

        if( status == DIR_S_SUCCESS )
                ListExist = TRUE;
        else
                ListExist = FALSE;
    }

    /* If List does not exist create the object and add it to NOD */

    if( !ListExist )
    {
        Buf.osnum = curOs;

        status =
        om$construct (  classid = OPP_VDPEqBuffer_class_id,
                        p_objid = &(Buf.objid),
                        osnum   = Buf.osnum,
                        msg = message VDPEqBuffer.VDPsetEquipList( &msg) );
        __CheckRC( status, msg,"om$construct", wrapup );
        __DBGpr_obj ( "EqpBuffer Id ", Buf );

        sprintf( ListName,"%s%s",DirName,PME_EQP_LIST );
        __DBGpr_str( "Equipment Buffer name", ListName );
        status =
        di$add_name ( objname = ListName,
                      osnum   = Buf.osnum,
                      objid   = Buf.objid );
        __CheckRC( status, 1, "di$add_name", wrapup );
    }

wrapup :
    End
    return status;
}


end implementation VDm_place;
