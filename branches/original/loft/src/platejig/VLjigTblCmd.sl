/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLjigTblCmd

     ABSTRACT   : construction of a table showing carateristic dimensions
		  of plate-jigs group.

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLjigTblCmd.
		  This command creates a dimension table.


     CHANGE HISTORY : 	file created 	17-MAR-1993	Marc Fournier
		      	file modified	26-MAR-1993	Marc Fournier
		      	file modified	17-JUN-1993     Marc Fournier
		      	file upgraded	14-APR-1994     Marc Fournier
		      	file modified	27-MAY-1994     Marc Fournier
			file modified	06-OCT-1994     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_JIG_TABLE, 0, VLCrJiTa
command_table	"vl.cmd"
class		VLjigTblCmd
super_class	VLtpl2dCmd
product_name	"$LOFT"

start_state	MANAGER

specification

instance {	struct	GRobj_env	Manager;	}

implementation

#include        <stdio.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "nddef.h"
#include        "dpmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "FI.h"
#include	"macro.h"
#include	"vsplatedef.h"

#include	"vlmsg.h"
#include	"vltablejig.h"
#include	"vluserkey.h"
#include	"vlmiscmacros.h"

extern  GRclassid       OPP_VLjigTbl_class_id;

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vltemplate.h"

/******************************************************************************/
state MANAGER
	message_key		VL_S_JIG_TABLE
	prompt_key		VL_P_GROUP
	accept_key		VL_M_GROUP
	locate_eligible		"VLjigMgr"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  |
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_DATA		do VLstoreLocate (&me->ret)
				do VLstoreManager(&me->ret)	state COOR_SYS
/******************************************************************************/
state COOR_SYS
	prompt_key              VL_P_GROUND_COOR_SYS
        accept_key              VL_M_GROUND_COOR_SYS
        locate_eligible         "+GRgencs"
        locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state MANAGER
        on EX_DATA 		do VLstoreLocate (&me->ret)
                                do VLstoreCoorSyst (&me->ret)	state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
	execute			VLcomputeJigTable (&me->ret)
				on RETURN_CODE = VL_S_SUCCESS
                                        do status_key VL_S_SUCCESS
								state MANAGER
				on ELSE
                                        do status_key VL_E_FAILURE
								state MANAGER
/******************************************************************************/
action wakeup {

        /* Execute method wakeup of upper class */
        me->ret = om$send ( msg      = message VLlocateCmd.wakeup (pos),
                            mode     = OM_e_wrt_message,
                            targetid = my_id );
        as$status(sts = me->ret);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action sleep {

	/* Execute method sleep of upper class */
	me->ret = om$send ( msg      = message VLlocateCmd.sleep (pos),
			    mode     = OM_e_wrt_message,
			    targetid = my_id );
	as$status(sts = me->ret);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action VLstoreManager {

        me->Manager = me->Loc_env;
        *sts = OM_S_SUCCESS;

        status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action VLcomputeJigTable {

	struct	GRid		Tmp[MACRO_T_FTEMP];

	/* Get coordinate system */
	as$make_source ( go_grid = me->GrdCsys.obj_id,
                         mod_env = &me->GrdCsys.mod_env,
                         as_os   = me->Current.md_id.osnum,
                         as_grid = &Tmp[IDX_T_CSYS] );

	/* Get platejig manager */
	as$make_source ( go_grid = me->Manager.obj_id,
                         mod_env = &me->Manager.mod_env,
                         as_os   = me->Current.md_id.osnum,
                         as_grid = &Tmp[IDX_T_PJIG] );

	/* Construct, place, name & change state of the VLjigTbl macro */
        status = vl$placeLoftMacro ( msg        = sts,
                                     classid    = OPP_VLjigTbl_class_id,
                                     MacName    = MACRO_T_JIGS,
                                     number     = MACRO_T_FTEMP,
                                     template   = Tmp,
                                     Env        = &me->Current,
                                     MatchKey   = TABLE_JIG_KEY,
                                     CobName    = "VLjigTblCmd",
                                     mode       = OM_e_wrt_parent,
                                     MatchId    = &Tmp[IDX_T_PJIG],
                                     CommonName = T_JIGS_NAME,
                                     CobMyId    = my_id );
        as$status ( msg    = "vl$placeLoftMacro(VLjigTbl)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	*sts = VL_S_SUCCESS;

wrapup:
	goto quit;
}
/******************************************************************************/
