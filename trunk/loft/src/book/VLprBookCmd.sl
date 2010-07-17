/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLprBookCmd

     ABSTRACT   : I/LOFT loft book generation command

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLprBookCmd.
		  This command prepares data for LoftBook.


     CHANGE HISTORY : 	file created 	10-AUG-1994     Marc Fournier
			file modified	06-OCT-1994	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_PREP_LOFTBOOK, 0, VLPrLoBo
command_table	"vl.cmd"
class		VLprBookCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLprepBook", 0, 0, "-1", "-1"

start_state	START

specification

instance {
	IGRchar		UserPath[DI_PATH_MAX];
	IGRint		DirIndex;
}

implementation

#include        <stdio.h>
#include        <string.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
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
#include        "godef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "FI.h"
#include        "ACattrib.h"
#include        "msmacros.h"
#include        "grmacros.h"
#include        "macro.h"

#include	"vlmsg.h"
#include	"vlbook.h"
#include	"vlconnect.h"
#include	"vlglobals.h"
#include	"vlmiscmacros.h"

from	GRgraphics	import	GRchgname;

extern	GRclassid	OPP_VLconnect_class_id;
extern  IGRboolean 	VLcheckInDirectory();

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vlbook.h"

/******************************************************************************/
state START
	execute			VLtoggleCommand (&me->ret)
	
	on ELSE							state WAIT_FORM
/******************************************************************************/
state WAIT_FORM
	message_key		VL_S_PREP_LOFTBOOK
	status			" "
        prompt                  " "
        filter                  get_event
	
	on EX_FORM_FINISHED					state terminate
	on GR_UNKNOWN_TYPE.VL_BOOK_SELECT			state TO_ADD
/******************************************************************************/
state TO_ADD
	execute			VLfreeList ( &me->ret, 1)
	execute			VLfillLocate (&me->ret)

	on ELSE							state IN_ADD
/******************************************************************************/
state IN_ADD
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  |
                                 LC_REF_OBJECTS"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state AFTER_ADD
        on EX_RJT_MOVEON                                        state TO_ADD
        on EX_DATA              do VLstoreResponse (&me->ret)
                                do VLstoreLocate (&me->ret)
                                do VLputInDir (&me->ret)	state AFTER_ADD
        on EX_OBJID             do VLstoreResponse (&me->ret)   state FROM_ADD
/******************************************************************************/
state FROM_ADD
	status_key              VL_S_PROCESS
        prompt                  " "
        execute                 VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)
        execute                 VLgrpInDir (&me->ret)

        on ELSE                                                 state AFTER_ADD
/******************************************************************************/
state AFTER_ADD
	execute			VLendProcess (&me->ret, VL_PREP_BOOK_ADD)

	on ELSE							state WAIT_FORM
/******************************************************************************/
action init {

	/* Execute method init of upper class */
        me->ret = om$send ( msg = message VLprBookCmd.init ( type, str_ptr),
                            mode = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Generate directories (if needed) */
	status = VLgenerateDirectories ( &me->Current, me->UserPath );
        as$status ( msg    = "VLgenerateDirectories()",
                    action = GOTO_VALUE,
                    value  = quit );

	/* Initialize directory index */
	me->DirIndex = -1;

	/* Initialize form */
	FIf_reset (me->forms[0].form_ptr);

	/* Initialize directories field */
	FIfld_set_num_rows ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			     VL_PREP_BOOK_ROW);

	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_AFT, 0, VL_BOOK_SYN_AFT, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_BSL, 0, VL_BOOK_SYN_BSL, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_CTL, 0, VL_BOOK_SYN_CTL, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_FWD, 0, VL_BOOK_SYN_FWD, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_HUL, 0, VL_BOOK_SYN_HUL, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_MID, 0, VL_BOOK_SYN_MID, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_ORI, 0, VL_BOOK_SYN_ORI, FALSE);

	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_BUT, 0, VL_BOOK_SYN_BUT, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_BTK, 0, VL_BOOK_SYN_BTK, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_DCK, 0, VL_BOOK_SYN_DCK, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_FOB, 0, VL_BOOK_SYN_FOB, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_FOS, 0, VL_BOOK_SYN_FOS, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_FRM, 0, VL_BOOK_SYN_FRM, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_KNK, 0, VL_BOOK_SYN_KNK, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_LON, 0, VL_BOOK_SYN_LON, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_SEA, 0, VL_BOOK_SYN_SEA, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_STA, 0, VL_BOOK_SYN_STA, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_STM, 0, VL_BOOK_SYN_STM, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_STN, 0, VL_BOOK_SYN_STN, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_TGT, 0, VL_BOOK_SYN_TGT, FALSE);
	FIfld_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_DIR,
			 VL_BOOK_IDX_WTL, 0, VL_BOOK_SYN_WTL, FALSE);

	FIfld_set_num_rows ( me->forms[0].form_ptr, VL_PREP_BOOK_DATA, 0);

	/* Initialize <station method> field */
	FIfld_set_list_text ( me->forms[0].form_ptr, VL_PREP_BOOK_STA, 0, 0,
			      VLPB_STATION1, TRUE );
	FIfld_set_list_text ( me->forms[0].form_ptr, VL_PREP_BOOK_STA, 1, 0,
			      VLPB_STATION2, TRUE );

	/* Display form */
	FIf_display (me->forms[0].form_ptr);

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action wakeup {

	IGRdouble	value=0.0;

	/* Execute method init of upper class */
        me->ret = om$send ( msg = message VLprBookCmd.wakeup (pos),
                            mode = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_STATION, &value),
                  targetid = my_id);

	/* Update <station method> field */
	switch ((IGRint) value) {

		case 0:	FIg_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_STA,
				       VLPB_STATION1 );
			break;

		case 1:	FIg_set_text ( me->forms[0].form_ptr, VL_PREP_BOOK_STA,
				       VLPB_STATION2 );
			break;
	}

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action form_notification {

		IGRint		i, sel=0;
		IGRlong		msg;
		IGRchar		name[80];
		IGRdouble	val;

	FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG, " " );

	switch (gadget_label) {

		case VL_PREP_BOOK_DIR:

			/* Scan for directory index */
			me->DirIndex = -1;
			for ( i=0; i<VL_PREP_BOOK_ROW; i++) {
				FIfld_get_select ( form_ptr, gadget_label, i, 0,
						   &sel );
				if (sel == 1) { me->DirIndex = i; break; }
			}

			/* Put elements in multifield */
			VLputElemInMultiField ( me->DirIndex, me->UserPath,
						&me->Current, form_ptr,
						VL_PREP_BOOK_DATA );

			/* Change <Add> to <Generate> if stations */
			if (me->DirIndex == VL_BOOK_IDX_STA) {
				FIg_erase       ( form_ptr, VL_PREP_BOOK_ADD );
				FIg_set_on_text ( form_ptr, VL_PREP_BOOK_ADD,
				       	          "Generate" );
				FIg_set_off_text( form_ptr, VL_PREP_BOOK_ADD,
				       	          "Generate" );
				FIg_display     ( form_ptr, VL_PREP_BOOK_ADD );
			}
			else {	FIg_erase       ( form_ptr, VL_PREP_BOOK_ADD );
				FIg_set_on_text ( form_ptr, VL_PREP_BOOK_ADD,
				       	          "Add" );
				FIg_set_off_text( form_ptr, VL_PREP_BOOK_ADD,
				       	          "Add" );
				FIg_display     ( form_ptr, VL_PREP_BOOK_ADD );
			}

			goto quit;

		case VL_PREP_BOOK_DATA:

			dp$erase_hilite (msg = &msg);

			if (me->DirIndex == -1)
				FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG,
					       VLPB_NO_DATA );
			else	VLdisplayReal ( me->DirIndex, me->UserPath,
						&me->Current, form_ptr,
						VL_PREP_BOOK_DATA, GRhd );

			goto quit;

		case VL_PREP_BOOK_ADD:

			if (me->DirIndex == -1) {
				FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG,
					       VLPB_NO_ADD );
        			om$send ( msg = message VLprBookCmd.VLendProcess
						( &msg, VL_PREP_BOOK_ADD),
				  	  targetid = my_id );
			}
			else if (me->DirIndex == VL_BOOK_IDX_STA) {

				VLdeleteAllMultiField ( me->DirIndex,
						        me->UserPath,
							&me->Current );

				om$send ( msg = message VLlocateCmd.VLgetGlobals
                                  		( &msg, NAM_G_STATION, &val),
	                                  targetid = my_id);

				status = VLcreateDispStations ( me->DirIndex,
						                me->UserPath,
							        &me->Current,
							        (IGRint) val,
								form_ptr );

        			om$send ( msg = message VLprBookCmd.VLendProcess
						( &msg, VL_PREP_BOOK_ADD),
				  	  targetid = my_id );
			}
			else {	_put_response (resp = VL_BOOK_SELECT);
				COm_make_command_active ( my_id,
							  OM_Gw_current_OS );
			}
			goto quit;

		case VL_PREP_BOOK_DEL:
			if (me->DirIndex == -1)
				FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG,
					       VLPB_NO_DEL );
			else	VLdelElemInMultiField ( me->DirIndex,
						        me->UserPath,
							&me->Current,
							form_ptr,
							VL_PREP_BOOK_DATA );
        		om$send ( msg = message VLprBookCmd.VLendProcess
						( &msg, VL_PREP_BOOK_DEL),
				  targetid = my_id );
			goto quit;

		case VL_PREP_BOOK_ALL:
			if (me->DirIndex == -1)
				FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG,
					       VLPB_NO_DEL );
			VLdeleteAllMultiField ( me->DirIndex,
					        me->UserPath,
						&me->Current );
        		om$send ( msg = message VLprBookCmd.VLendProcess
						( &msg, VL_PREP_BOOK_ALL),
				  targetid = my_id );
			goto quit;

		case VL_PREP_BOOK_TITLE:
		case VL_PREP_BOOK_MSG:
			FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG, VLPB_NO_SEL);
			goto quit;

		case VL_PREP_BOOK_STA:
			val = 0.0;
			FIg_get_text ( form_ptr, VL_PREP_BOOK_STA, name);
			if (!strcmp(name,VLPB_STATION2))	val = 1.0;
			om$send ( msg = message VLlocateCmd.VLmodGlobals
                                  	( &msg, NAM_G_STATION, val),
                                  targetid = my_id);
			goto quit;

		case VL_PREP_BOOK_PUT:
			if (me->DirIndex == -1)
				FIg_set_text ( form_ptr, VL_PREP_BOOK_MSG,
					       VLPB_NO_PUT );
			else	VLputqueueElemInMultiField ( me->DirIndex,
							     me->UserPath,
						             &me->Current,
							     form_ptr,
						             VL_PREP_BOOK_DATA);
			goto quit;

		case FI_ACCEPT:
			FIf_erase (form_ptr);
			_put_response ();
			goto quit;
	}
}
/******************************************************************************/
action VLputInDir (	IGRlong	*msg	)
{
	struct	GRid	occ_id, tmp_id;
		IGRchar	name[DI_PATH_MAX], path[DI_PATH_MAX], resu[DI_PATH_MAX];

	/* Retrieve directory name */
	strcpy ( name, VLindexToDirName(me->DirIndex) );

	/* Build directory path */
	path[0] = '\0';
	sprintf ( path, "%s:%s", me->UserPath, name );

	/* Check in not already in directory */
	if ( ! VLcheckInDirectory ( &me->Loc_env.obj_id, &me->Current,
				    path, name) )	goto quit;

	/* Initialize */
	tmp_id.objid = occ_id.objid = NULL_OBJID;
	tmp_id.osnum = occ_id.osnum = me->Current.md_id.osnum;

	/* Make source on locate object */
	as$make_source ( go_grid = me->Loc_env.obj_id,
			 mod_env = &me->Loc_env.mod_env,
			 as_os   = tmp_id.osnum,
			 as_grid = &tmp_id );

	/* Find a name for source object */
        status = om$send ( msg = message VLprBookCmd.VLnameOccurence
					( &me->ret, path, name, resu),
                           mode     = OM_e_wrt_parent,
                           targetid = my_id );
	as$status ( msg    = "VLprBookCmd.VLnameOccurence",
                    test   = !(status & 1 & me->ret),
                    action = GOTO_VALUE,
                    value  = quit );

	/* Construct and place the "loft_connect" macro */
	status = vl$placeLoftMacro ( msg	= msg,
				     classid	= OPP_VLconnect_class_id,
				     MacName	= MACRO_VC_DEF,
				     number	= MACRO_VC_TEMP,
				     template	= &tmp_id,
				     Env	= &me->Current,
				     ChgState	= FALSE,
				     occ_id	= &occ_id );
	as$status ( msg    = "vl$placeLoftMacro(VLconnect)",
		    test   = (!(status & 1 & (*msg))),
                    action = GOTO_VALUE,
                    value  = quit );

	/* Give name to occurence */
	sprintf ( path, "%s:%s", path, resu);
	status = om$send ( msg = message GRgraphics.GRchgname 
					( &me->ret, &me->Current, path),
			   targetid = occ_id.objid,
			   targetos = occ_id.osnum );
	as$status ( msg    = "GRgraphics.GRchgname",
                    test   = !(status & 1 & me->ret),
                    action = GOTO_VALUE,
                    value  = quit );
}
/******************************************************************************/
action VLgrpInDir (	IGRlong	*msg	)
{
		IGRint	i;
		IGRchar	name[DI_PATH_MAX];

	/* Retrieve directory name */
	strcpy ( name, VLindexToDirName(me->DirIndex) );

	/* Loop on grset */
	for ( i=0; i<me->Cnt1; i++) {

		/* As a single locate on element i */
		me->Loc_env = me->Lst1[i];

		/* Put it in the directories */
        	status = om$send ( msg = message VLprBookCmd.VLputInDir (msg),
	                           targetid = my_id );
		as$status ( msg    = "VLprBookCmd.VLputInDir",
	                    action = GOTO_VALUE,
	                    value  = quit );
	}

	goto quit;
}
/******************************************************************************/
action	VLfillLocate (	IGRlong	*msg	)
{
	IGRint	sts;
	IGRchar	class[2*OM_K_MAXCLASS_LEN], Pbuf[80], Abuf[80];

	switch (me->DirIndex) {

                case VL_BOOK_IDX_AFT:
			ex$message ( msgnumb = VL_P_BOOK_AFT, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_AFT, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_BSL:
			ex$message ( msgnumb = VL_P_BOOK_BSL, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_BSL, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_CTL:
			ex$message ( msgnumb = VL_P_BOOK_CTL, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_CTL, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_FWD:
			ex$message ( msgnumb = VL_P_BOOK_FWD, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_FWD, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_HUL:
			ex$message ( msgnumb = VL_P_BOOK_HUL, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_HUL, buff = Abuf);
			strcpy ( class, "EMSsubbs");
			break;
                case VL_BOOK_IDX_MID:
			ex$message ( msgnumb = VL_P_BOOK_MID, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_MID, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_ORI:
			ex$message ( msgnumb = VL_P_BOOK_ORI, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_ORI, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;

                case VL_BOOK_IDX_BUT:
			ex$message ( msgnumb = VL_P_BOOK_BUT, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_BUT, buff = Abuf);
			strcpy ( class, "VLbutLine");
			break;
                case VL_BOOK_IDX_BTK:
			ex$message ( msgnumb = VL_P_BOOK_BTK, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_BTK, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_DCK:
			ex$message ( msgnumb = VL_P_BOOK_DCK, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_DCK, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_FOB:
			ex$message ( msgnumb = VL_P_BOOK_FOB, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_FOB, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_FOS:
			ex$message ( msgnumb = VL_P_BOOK_FOS, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_FOS, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_FRM:
			ex$message ( msgnumb = VL_P_BOOK_FRM, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_FRM, buff = Abuf);
			strcpy ( class, "SMframe,SMInfPlane");
			break;
                case VL_BOOK_IDX_KNK:
			ex$message ( msgnumb = VL_P_BOOK_KNK, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_KNK, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_LON:
			ex$message ( msgnumb = VL_P_BOOK_LON, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_LON, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_SEA:
			ex$message ( msgnumb = VL_P_BOOK_SEA, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_SEA, buff = Abuf);
			strcpy ( class, "VLseaLine");
			break;
                case VL_BOOK_IDX_STA:
			ex$message ( msgnumb = VL_P_BOOK_STA, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_STA, buff = Abuf);
			strcpy ( class, "SMInfPlane");
			break;
		case VL_BOOK_IDX_STM:
			ex$message ( msgnumb = VL_P_BOOK_STM, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_STM, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_STN:
			ex$message ( msgnumb = VL_P_BOOK_STN, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_STN, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_TGT:
			ex$message ( msgnumb = VL_P_BOOK_TGT, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_TGT, buff = Abuf);
			strcpy ( class, "GRcurve");
			break;
                case VL_BOOK_IDX_WTL:
			ex$message ( msgnumb = VL_P_BOOK_WTL, buff = Pbuf);
			ex$message ( msgnumb = VL_M_BOOK_WTL, buff = Abuf);
			strcpy ( class, "VLwatLine");
			break;
                default:
			strcpy ( class, " ");
			strcpy ( Pbuf,  " ");
			strcpy ( Abuf,  " ");
			break;
	}

	/* Modify locate prompt */
        me->ret = om$send ( msg = message VLprBookCmd.prompt (Pbuf),
                            mode = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

	/* Modify accept prompt */
	strcpy ( me->acc_prompt, Abuf);

	/* Modify eligible class */
        me->ret = om$send ( msg = message VLprBookCmd.action
				( _locate_class, (IGRint)class, &sts ),
                            mode = OM_e_wrt_parent,
      	                    targetid = my_id );
        as$status(sts = me->ret);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action VLendProcess (IGRlong	*msg; IGRint	gadget_label	)
{
	/* Set <Add> or <DELETE> button off */
	FIg_set_state_off ( me->forms[0].form_ptr, gadget_label);

	/* Rename list */
	VLrenameInDir ( me->DirIndex, me->UserPath);

	/* Put elements in multifield */
	VLputElemInMultiField ( me->DirIndex, me->UserPath, &me->Current,
				me->forms[0].form_ptr, VL_PREP_BOOK_DATA );

	/* Erase hilited objects */
	dp$erase_hilite (msg = msg);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
