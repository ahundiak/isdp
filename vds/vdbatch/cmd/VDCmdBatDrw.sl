/* $Id: VDCmdBatDrw.sl,v 1.1.1.1 2001/01/04 21:07:45 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/cmd/VDCmdBatDrw.sl
 *
 * Description:  Command object to submit batch processing of drawings.
 *               During locate of elements within a drawing view, the 
 *	         elements inside and overlapping drawing view are found.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdBatDrw.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:45  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.5  1997/04/08  20:48:00  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by kddinov for vds.241
#
# Revision 1.4  1997/04/02  23:09:38  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by kddinov for vds.241
#
# Revision 1.2  1997/03/17  23:01:10  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by kddinov for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.32  1996/06/12  11:13:04  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by apazhani for vds.240
#
# Revision 1.31  1996/06/07  12:27:58  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by apazhani for vds.240
#
# Revision 1.30  1996/06/07  05:59:44  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by rgade for vds.240
#
# Revision 1.29  1996/06/07  05:47:08  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by rgade for vds.240
#
# Revision 1.28  1996/06/06  23:14:00  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by v240_int for vds.240
#
# Revision 1.27  1996/06/04  05:37:10  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by apazhani for vds.240
#
# Revision 1.26  1996/05/20  10:17:04  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by rgade for vds.240
#
# Revision 1.25  1996/03/22  06:23:40  pinnacle
# Replaced: vdmdlv/func/VDdispMVfrm.I for:  by msbraju for vds.240
#
# Revision 1.24  1996/03/13  18:17:32  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by v240_int for vds.240
#
# Revision 1.23  1996/03/08  12:20:10  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by rgade for vds.240
#
# Revision 1.22  1996/02/23  23:31:16  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.21  1996/01/29  07:17:56  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by rgade for vds.240
#
# Revision 1.20  1995/12/07  15:37:02  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.18  1995/11/29  13:52:58  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by ksundar for vds.240
#
# Revision 1.17  1995/10/06  15:20:10  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.16  1995/09/29  19:50:50  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.15  1995/09/25  21:47:28  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by sundar for vds.240
#
# Revision 1.14  1995/09/14  17:57:10  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.13  1995/09/11  15:33:20  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by msbraju for vds.240
#
# Revision 1.12  1995/09/10  18:25:00  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.11  1995/08/31  21:47:12  pinnacle
# Replaced: ./vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.10  1995/08/17  12:52:14  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.9  1995/08/04  18:43:34  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.8  1995/08/04  14:20:08  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by msbraju for vds.240
#
# Revision 1.6  1995/08/02  12:36:20  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by msbraju for vds.240
#
# Revision 1.5  1995/08/01  18:59:20  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.4  1995/07/29  16:37:20  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/28  15:53:36  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/26  16:52:46  pinnacle
# Replaced: vdbatch/cmd/VDCmdBatDrw.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/25  21:01:14  pinnacle
# Created: vdbatch/cmd/VDCmdBatDrw.sl by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/13/1995	Raju		Creation
 *	08/17/95	ravi		ftp history distables.
 *	08/28/95	ravi		TR# 179527263.
 *	09/07/95	adz		TR# 179527391.
 *	09/28/95	adz		Set filter_objects macro.
 *	12/01/95	ravi		Adaption for Solaris.
 *	06/06/96	adz/shane	qsub: -x deleted (copy environment)
 *      06/08/96	ravi		Cleanup method TR#179600893
 *	April 97	kdd		product name EX_runname added to shell
 *
 * -------------------------------------------------------------------*/

/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */

command_string  VDC_M_BtchVisPrc,0,VDBatDrw
class		VDCmdBatDrw
super_class	COgrpevent
product_name    "$VDS"
command_table   "vds.cmd"


/* form used */
form		"VDbatchDrw",0,0,"-1","-1"
form		"VDbatchSub",1,0,"-1","-1"

start_state     start

/* ********************************************************** */
/*	SPECIFICATION AREA				      */
/* ********************************************************** */

specification

#define  FP_BAT         me^^CEO.forms[0].form_ptr
#define  FP_SUB         me^^CEO.forms[1].form_ptr

#include "growner.h"
#include "vdbatdrw.h"

instance
{

  IGRint			nbDv;
				/* No. of drawing views in the design file */

  variable struct GRid		dvlist[0];	   /* object ids of dwg views */
  variable GRname		dvnames[0];	   /* Names of drawing views */
  variable IGRlong		props[0];
				/* properties of dwg views (see vdbatdrw.h) */

  variable struct GRobj_env	solid[0];
				/* The solid i.e. to be used for locating
				 * objects inside and overlapping Dwg View.
				 * can be dwg view/solid/view vol/mdl view.
				 */

  variable char			setupFile[0][15];  /* setup file names */
  variable short		layer[0];
				/* layers for boolean operations */
  variable double		offset[0];
				/* offsets to be applied to solid while
				 * locating elements wrt solid.
				 */

  variable struct GRid		clippolyIds[0];   /* clipping polygons */
  variable VDdrwBatchInfo	batchInfo[0];
				/* batchInfo of dwg veiws after accepting
				 * sub form
				 */

  IGRboolean			fitTgl;
				/* toggle indicating whether dwg view
				 * should be fit during main form
				 */

  IGRint			activeDv;
				/* drawing view for which user is defining
				 * input currently.
				 */

  IGRboolean			processTgl;	/* TRUE  : Batch Processing
						 * FALSE : Interactive proc
						 */
  IGRchar			queue[15];	/* pipe queue name */
  IGRchar			login[10];	/* login on local system */
  IGRchar			passwd[10];	/* passwd for login */

  struct GRid			locateWin;	/* window to be used for
						 * locate process
						 */

  struct GRid			fitWin;		/* window to be used for
						 * fitting DwgView
						 */

  IGRdouble			oldDisplayDepths[2];
				/* display depths of locate window. Display
				 * depths of window are changed to height of
				 * solid during locate. Display depths are
				 * changed back to old dds at sleep.
				 */

  int				nbLocObj;
  struct GRobj_env		*locObjs;

}

/* ********************************************************** */
/*	IMPLEMENTATION AREA				      */
/* ********************************************************** */

implementation

/*
  Include Files
*/
#include <stdio.h>
#include <string.h>
#include <sys/time.h>			/* Time generator */
#include <sys/utsname.h>		/* Nodename	*/
#include <time.h>
#include <math.h>
#include <unistd.h>
#include "OMmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "grmacros.h"
#include "vdbatdrw.h"
#include "vdsmacros.h"
#include "vdprdmacros.h"
#include "v_drw.h"
#include "vdsetmacros.h"
#include "vdsollocdef.h"
#include "vderrmacros.h"
#include "vdbatdrwmac.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "detaildef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "UOMdef.h"
#include "grio.h"
#include "griomacros.h"
#include "UOMmacros.h"
#include "bserr.h"
#include "bsparameters.h"

#include "msdef.h"
#include "msmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "FI.h"

/*  prototype */
extern long VDselObjOfDV __((	long			*msg,
				struct GRid		*dvId,
				struct GRmd_env		*dvEnv,
				int			*nbObj,
				struct GRobj_env	*objects ));

extern char EX_runname[];

%safe
static  int x_pos = -1, y_pos = -1;
%endsafe

%safe
static  int NQS_batch_process_num = 1;
%endsafe

from GRvg         import   GRchgprops;
from GRgraphics   import   GRdisplay, GRgetrang;
from GRdrawview   import   GRget_drawing_attachment_id;
from GRdvattach   import   GRget_component_id;
from IGEgragad	  import   DPinquire;

from VDbatData	  import   VDretrieveData;
from VDbatData	  import   VDpostData;
from NDnode	  import   ASreturn_go;
from VDmdlview    import   VDmv_give_vv_qry;


/*
 * form gadgets
 */
#define  VD_BAT_DV_FLD		11
#define  VD_BAT_EDIT_TGL	17
#define  VD_BAT_SELECT_ALL	18
#define  VD_BAT_CLEAR_ALL	19
#define  VD_BAT_FIT_VIEW_TGL	23
#define  VD_BAT_UNITS_TXT	24
#define  VD_BAT_BOOLSOL_FLD	20


#define  VD_SUB_BATCH_TGL	11
#define  VD_SUB_QUEUE_FLD	12
#define  VD_SUB_LOGIN_FLD	13
#define  VD_SUB_PASSWD_FLD	14


#define  VD_BAT_HILITE_BTN	25
#define  VD_BAT_UNHILITE_BTN	26

/*
 * additional response status
 */
#define  VD_LOC_SOL		1001
#define  VD_PROCESS		1002
#define  VD_SUBFORM		1003

/* ********************************************************** */
/*      STATE TABLE AREA                                      */
/* ********************************************************** */

state_table

#include "VDmsg.h"
#define  VD_LOC_SOL		1001
#define  VD_PROCESS		1002
#define  VD_SUBFORM		1003


state start

  message_key		VD_M_BtchVisPrc
  execute               Cleanup( &me->ret )
  execute		VDgetDVlist ( &me->ret )
	on ERROR					state terminate

  execute		setInstanceAndForm( &me->ret )
	on ELSE						state loc_window

state loc_window

  message_key		VD_M_BtchVisPrc
  prompt_key		VD_P_BVPIdLocWin
  status_key		VD_S_BVPLocateWin
  mask			"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP "
  filter		get_event

  on EX_RJT_MOVEON or EX_BACK_UP			state terminate
  on EX_DATA		do storeWindowAndDepths		state fit_window


state fit_window

  message_key		VD_M_BtchVisPrc
  prompt_key		VD_P_BVPIdFitWin
  status_key		VD_S_BDPFitWinInfo
  mask			"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP "
  filter		get_event

  on EX_BACKUP					state loc_window
  on EX_RJT_MOVEON				state form_oper1
  on DATA		do storeFitWindow	state check_fitWin


state check_fitWin

  message_key		VD_M_BtchVisPrc
  execute		checkFitWin
	on SUCCESS					state form_oper1
	on ELSE						state fit_window


state form_oper1

  display_form		0
  erase_form		1
  message_key		VD_M_BtchVisPrc
  prompt_key		VD_P_BDPPerfromOp
  status		""
  filter		get_event

  on GR_UNKNOWN_TYPE.VD_LOC_SOL				state loc_solid
  on EX_DATA or EX_RJT_MOVEON				state .
  on EX_BACK_UP
	do erase_form 0					state fit_window
  on GR_UNKNOWN_TYPE.VD_SUBFORM				state form_oper2
  on EX_FORM_FINISHED					state terminate


state form_oper2

  erase_form		0
  display_form		1
  message_key		VD_M_BtchVisPrc
  prompt_key		VD_P_BDPPerfromOp
  status		""
  filter		get_event

  on EX_BACK_UP
	do erase_form 1					state form_oper1
  on GR_UNKNOWN_TYPE.VD_PROCESS				state start_proc
  on EX_DATA or EX_RJT_MOVEON				state .
  on EX_FORM_FINISHED					state terminate


state loc_solid

  erase_form		0
  message_key		VD_M_BtchVisPrc
  prompt_key		VD_P_BVPIdSolid
  accept_key            VD_P_AccRej
  relocate_key		VD_S_BDPSolidNotFound
  locate_class          "+EMSsolid"
  locate_properties     " LC_DP_ONLY | LC_LC_ONLY | LC_RW "
  locate_owner          " LC_RIGID_COMP | LC_RIGID_OWNER |
                          LC_FLEX_COMP | LC_FLEX_OWNER | LC_REF_OBJECTS "
  locate_display        " ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
			  ALL_WINDOWS | LC_ERASE_ALL "
  mask                  " GRm_STRING | GRm_DATA | GRm_RJT_MOVEON |
			  GRm_OBJID | GRm_BACK_UP "
  filter		locate

  on EX_BACK_UP						state -
  on EX_OBJID or EX_RJT_MOVEON				state .
  on EX_DATA
	do storeSolid
							state -
  on ELSE						state terminate


state start_proc

  message_key		VD_M_BtchVisPrc
  execute		VDstartProcess ( &me->ret )

	  on RETURN_CODE = "MSSUCC"			state submit
	  on ELSE					state terminate


state submit

  message_key		VD_M_BtchVisPrc
  on ELSE		do VDsubmitBatch  ( &me->ret )
							 state terminate



at sleep  do set_old_display_depths
at delete do save_form_pos

action  VDgetDVlist		  extern
action  VDstartProcess		  extern

/*
 * **********************************************************
 *	ACTION DEFINITIONS
 * **********************************************************
 */
action form_notification
{
long			sts1, msg;
int			ii, sel_flag, r_pos;
double			value;
struct GRid		dataObj;
int			num_vvol_sel, num_mv_sel;
struct GRid		*vvol_ids = NULL,  *mv_ids = NULL;
struct GRmd_env		*vvol_envs = NULL, *mv_envs = NULL;
char			tmpstr[81];
IGRshort		set ;
IGRshort		property ;
enum GRdpmode		mode;
char			name[30];
IGRboolean		editTgl;
int			count;
VD_drwMacInfo		*drwMacInfo = NULL;
char			stsMsg[DI_PATH_MAX],
			qname[DI_PATH_MAX];
FILE			*fp = NULL;
char			type[UOM_K_MAX_TYPE], uomName[20];
IGRshort		flag = 0, num_defaults;
GRIOalias_name		default_units[3];
double			db_offset;
IGRboolean		procType;
struct GRobj_env	off_solid;
char			setupFile[DI_PATH_MAX];
struct utsname		utsName;
int                     num_qry, nb_tot_root;
int                     nb_root_fnd, num_vvol;
struct GRid             *qry_list = NULL ;


   status = OM_S_SUCCESS ;

   FIg_set_text ( form_ptr, FI_MSG_FIELD, "" );

   if ( form_ptr == FP_BAT )
   {
      switch ( gadget_label )
      {
	case VD_BAT_EDIT_TGL :

	    /* toggle between edit and select */
	    dp$erase_hilite ( msg = &msg );
	    me->activeDv = -1;

	    FIg_get_state ( FP_BAT, VD_BAT_EDIT_TGL, (int *) &editTgl );
	    if ( editTgl ){
		/* User selected edit  mode */

		__DBGpr_com(" Check State in EDIT ");

		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 0, FI_SINGLE_SELECT );
		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 1, FI_INSERT );
		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 2, FI_INSERT );
		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 3, FI_INSERT );
		SMVA_enable ( FP_BAT, 3, VD_BAT_BOOLSOL_FLD,
					 VD_BAT_HILITE_BTN,
					 VD_BAT_UNHILITE_BTN );

		SMVA_disable ( FP_BAT, 2, VD_BAT_SELECT_ALL,
					  VD_BAT_CLEAR_ALL   );
		if ( me->fitWin.objid != NULL_OBJID )
			FIg_enable ( FP_BAT, VD_BAT_FIT_VIEW_TGL );
	    }
	    else
	    {
		/*
		 * User selected select  mode
		 * check if all the setup files are OK 
		 */

		__DBGpr_com(" Checking Setup files " );

		msg = MSSUCC;

		sts1 = VD_drwExecConfigAddFunctions();
		if( !(sts1 & 1)) {
			VD_drwExecConfigRmFunctions(); 
			FIg_set_state ( FP_BAT, VD_BAT_EDIT_TGL, TRUE );
			msg = MSFAIL;
			break;
		}

		__DBGpr_int(" Number DV ", me->nbDv );


		/*
		 * People do have the habbit of not reading the drawing.doc
		 * which indicates that support files are not allowed
		 * with relative paths.
		 * Example:	../tmp/setup
		 *		/usr/aaa/setup	
		 *
		 * Everything will be truncated. (Ad:09/08/95).
		 */

		for( ii=0; ii<me->nbDv; ii++){

			IGRchar		*s0Ptr = NULL ;
			GRname		setBuf ;

			*setupFile = '\0';
			FIfld_get_text ( FP_BAT, VD_BAT_DV_FLD, ii, 1, 
					 DI_PATH_MAX-1,
					 (unsigned char *) setupFile,
					 &sel_flag, &r_pos );
			__DBGpr_str(" SetupFile ", setupFile );

			s0Ptr = strrchr( setupFile, '/' );
			if( s0Ptr )	strcpy( setBuf, ++s0Ptr );
			else		strcpy( setBuf, setupFile );

			FIfld_pos_cursor( FP_BAT, VD_BAT_DV_FLD, ii, 0,
					  1, 0, 0, 0 );

			FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, ii, 1, 
					 setBuf, sel_flag );
			__DBGpr_str(" SetupFile1", setBuf );
		}

		for (ii=0; ii<me->nbDv; ii++){

			*setupFile = '\0';
			FIfld_get_text ( FP_BAT, VD_BAT_DV_FLD, ii, 1, 
					 DI_PATH_MAX-1,
					 ( unsigned char *) setupFile,
					 &sel_flag, &r_pos );
			__DBGpr_str(" SetupFile ", setupFile );

			
			if( strlen( setupFile )){
		  	   if( ! VD_drw_init_from_drawing_setup(
						setupFile, &drwMacInfo )){
				sprintf( stsMsg,
					 "Setup file '%s' error or not found",
					 setupFile );
				FIg_set_text( FP_BAT, FI_MSG_FIELD, stsMsg );
				UI_status( stsMsg );
				msg = MSFAIL;
				break;
			   } 
			   VD_drwFreeExtractMacInfo( drwMacInfo );
			} /* if ( strlen(setupFile) ) */
			else
			{
			    sprintf( stsMsg,
				 "Setup file not defined for dwgView %d",ii+1 );
			    FIg_set_text( FP_BAT, FI_MSG_FIELD, stsMsg );
			    msg = MSFAIL;
			    break;
			}
		} /* for (ii=0; ii<me->nbDv; ii++) */

		VD_drwExecConfigRmFunctions();

		if ( msg == MSFAIL ){
		   __DBGpr_com(" Set State to EDIT ");
		   FIg_set_state ( FP_BAT, VD_BAT_EDIT_TGL, TRUE );
		   break;
		}

		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 0, FI_MULTI_SELECT );
		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 1, FI_REVIEW );
		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 2, FI_REVIEW );
		FIfld_set_mode ( FP_BAT, VD_BAT_DV_FLD, 3, FI_REVIEW );
		SMVA_disable ( FP_BAT, 3, VD_BAT_BOOLSOL_FLD,
					  VD_BAT_HILITE_BTN,
					  VD_BAT_UNHILITE_BTN  );

		SMVA_enable (  FP_BAT, 2, VD_BAT_SELECT_ALL,
					  VD_BAT_CLEAR_ALL   );

		if ( me->fitWin.objid != NULL_OBJID )
			FIg_disable ( FP_BAT, VD_BAT_FIT_VIEW_TGL );
	    }
	    for( ii=0; ii< me->nbDv; ii++ )
		  FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, FALSE );
	    FIg_display ( FP_BAT, VD_BAT_DV_FLD );
	    break;

	case VD_BAT_HILITE_BTN :
	    if ( me->activeDv == -1 ){
		FIg_set_text ( FP_BAT, FI_MSG_FIELD, "No DwgView Selected" );
		break;
	    }

	    /*
	     * Get Setup file from line
	     */
	    msg = MSSUCC;
	    *setupFile = '\0' ;
	    FIfld_get_text( FP_BAT, VD_BAT_DV_FLD, me->activeDv, 1, 
			    DI_PATH_MAX-1,
			    ( unsigned char *) setupFile, &sel_flag, &r_pos );

	    if( strlen(setupFile) ){
		  sts1 = VD_drwExecConfigAddFunctions();
	          if( !(sts1 & 1)) {
			VD_drwExecConfigRmFunctions(); 
			msg = MSFAIL;
			break;
	    	  }
		  
		  if( ! VD_drw_init_from_drawing_setup(	setupFile,
							&drwMacInfo )){
			sprintf( stsMsg, "Setup file '%s' error or not found",
								setupFile );
			FIg_set_text( FP_BAT, FI_MSG_FIELD, stsMsg );
			UI_status( stsMsg );
			msg = MSFAIL;
		  } 
		  VD_drwFreeExtractMacInfo( drwMacInfo );
		  VD_drwExecConfigRmFunctions();
	    } /* if ( strlen(setupFile) ) */
	    else{
		sprintf( stsMsg,
			 "Setup file not defined for dwgView %d",
			 me->activeDv+1 );
		FIg_set_text( FP_BAT, FI_MSG_FIELD, stsMsg );
		msg = MSFAIL;
	    }
	    if ( msg == MSFAIL ) break;

	    FIfld_get_value( FP_BAT, VD_BAT_DV_FLD, me->activeDv, 3, &value,
			     &sel_flag, &r_pos );

	    /* convert offset to database units */

	    /* get default units */
	    strcpy ( type, GRIO_DISTANCE );
	    co$get_default_units(
			msg		= &msg,
			table_name	= type,
			osnum		= me->ModuleInfo.md_id.osnum,
			flag		= &flag,
			num_defaults	= &num_defaults,
			default_units	= default_units  );
	    strcpy( uomName, default_units[0] );

	    /* convert to database units */
	    sts1 = uom$cvt_value_to_value(
				  msg	     	     = &msg,
				  unit_type	     = type,
 				  osnum		   = me->ModuleInfo.md_id.osnum,
				  alias_to_cvt_from  = uomName,
				  alias_to_cvt_to    = NULL,
				  num_vals	     = 1,
				  values_in	     = &value,
				  values_out	     = &db_offset);
	    VDS_ERR_HNDLR ( "uom$cvt", sts1, msg, VD_VERBOSE, quit );

	    sts1 = vd$drw_solids_from_data(
				   msg		=  &msg,
				   dv_sol	= &me->solid[me->activeDv],
				   props	= me->props[me->activeDv],
				   offset	= db_offset,
				   offset_sol	= &off_solid );
	    VDS_ERR_HNDLR ( "VDdrw_offSol", sts1, msg, VD_VERBOSE, quit );

            num_qry = 0 ;
 
            if ( me->props[me->activeDv] & VD_MDLV  )
            {
              sts1 = om$send( msg = message VDmdlview.VDmv_give_vv_qry( &msg,
                                        &nb_tot_root,
                                        &nb_root_fnd,
                                        &num_vvol,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        &num_qry,
                                        &qry_list,
                                        NULL,
                                        NULL,
                                        NULL ),
                        targetid = me->solid[me->activeDv].obj_id.objid,
                        targetos = me->solid[me->activeDv].obj_id.osnum );

	      VDS_ERR_HNDLR ( "VDmv_give_vv_qry", sts1, msg, VD_VERBOSE, quit );
             }

	    /*
	     * get objects which are inside and overlapping offset solid
	     */
	    me->nbLocObj = 0;
	    if ( me->locObjs ) { free( me->locObjs );  me->locObjs = NULL; }
	    sts1 = VDlocateWithSolid2 (	&msg,
					1,
					&off_solid.obj_id,
					&off_solid.mod_env,
					num_qry,
					qry_list,
					VD_EL_INSIDE_OVERLAP,
					VD_LIST_OF_OBJS,
					&me->locateWin,
					"Processing",
					&me->located_chansel,
					my_id,
					&me->nbLocObj,
					&me->locObjs );
	    _FREE( qry_list ) ;

	    /*
	     * set display depths to old display depths before
	     * doing anything like testing return status.
	     */
	    {
	      long msg1;

	      status = _VD_SEND_MY( VDCmdBatDrw.set_old_display_depths( &msg1));
	      VDS_ERR_RPT ( "set_old_dds", status, msg1, VD_VERBOSE );
	    }

	    if(! ( sts1 & msg & 1  )){
	      UI_status("Error LOCATE WITH SOLID\n");
	      VDS_ERR_HNDLR( "VDlocateWithSolid2", sts1, msg, VD_VERBOSE,quit);
	    }

	    /*
	     * remove objects which do not belong to this drawing view
	     */
	    if ( me->nbLocObj )
	    {
	      sts1 = VDselObjOfDV( &msg,
				   &me->dvlist[me->activeDv],
				   &me->ModuleInfo,
				   &me->nbLocObj,
				   (struct GRobj_env *) me->locObjs );
	      VDS_ERR_HNDLR( "VDselObjOfDV", sts1, msg, VD_VERBOSE, quit );
	    }

	    if ( me->nbLocObj )
	    {

		IGRint			tp2d1_tp3d0	= 1 ,
					wkCount		= 0 ,
					dpCount		= 0 ;
		struct	GRobj_env	*wkList,
					*dpList ;

		wkList	= NULL ;
		dpList  = 0 ;

		sts1 =
		vd$filter_objects(	msg	= &msg,
					iCount	= me->nbLocObj,
					iList	= me->locObjs,
					oCount	= &wkCount,
					oList	= &wkList );
		if( !(sts1 & msg & 1)){
			_FREE( wkList );
			dpList  = me->locObjs ;
			dpCount	= me->nbLocObj ;
		}
		else{
		  sts1 =
		  VDdrw_FilterSelectList( &msg,	wkCount,
						wkList,
						setupFile,
						tp2d1_tp3d0,
						&dpCount );
		  if( !(sts1 & msg & 1)) dpCount = wkCount ;
		  dpList = wkList ;
		}
		sprintf( stsMsg, " Total %d object[s] found ", dpCount );
		UI_status( stsMsg );
		FIg_set_text ( FP_BAT, FI_MSG_FIELD, stsMsg );

	        if ( dpCount )
		{
		   dp$erase_hilite ( msg = &msg );
		   ACset_disthruref();
		   sts1 = vd_$bulk_display(
					dpmode  = GRhd,
					count   = dpCount,
					objenvs = dpList );
		   ACreset_disthruref ();
		}
		_FREE( wkList );

	    } /* if ( me->nbLocObj ) */

	    sts1 = gr$delete_object( msg	= &msg,
				     md_env	= &off_solid.mod_env,
				     object_id	= &off_solid.obj_id );
	    VDS_ERR_HNDLR("delete_obj", sts1, msg, VD_VERBOSE, quit );

	    ex$message ( field = PROMPT_FIELD,
			 justification = RIGHT_JUS,
			 in_buff = "Perform form operations", );

	    break;

	case VD_BAT_UNHILITE_BTN :
	    dp$erase_hilite ( msg = &msg );
	    if ( me->activeDv != -1 )
	    {
		sts1 = gr$display_object (
			  object_id = &me->dvlist[me->activeDv],
			  mode	    = GRhhd );
	    }
	    _FREE( me->locObjs );
	    me->locObjs=NULL;
	    me->nbLocObj = 0;

	    break;
 

	case VD_BAT_SELECT_ALL :
	    /* user selected all drawing views for extraction */
	    for( ii=0; ii< me->nbDv; ii++ )
	    {
		FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, TRUE );

		property = GRIS_DISPLAYABLE ;
		set = 1 ;	/* set property */
		sts1 =
		_VD_SEND_OBJN(	me->clippolyIds[ii],
				GRvg.GRchgprops ( &msg, &set, &property));
		VDS_ERR_CONTINUE ( "form_notif", sts1, msg, VD_VERBOSE );

		/* Display the clipping polygon */

		mode = GRhd    ; 	  /* highlight draw  */
		sts1 =
		vd_$bulk_display(	count	= 1,
					dpmode	= GRhhd,
					grids	= &me->clippolyIds[ii],
					theEnv	= &me->ModuleInfo );
		VDS_ERR_CONTINUE ( "form_notif", sts1, msg, VD_VERBOSE );

		set = 0 ;	/* remove property */
		sts1 =
		_VD_SEND_OBJN(	me->clippolyIds[ii],
				GRvg.GRchgprops( &msg, &set, &property));
		VDS_ERR_CONTINUE ( "form_notif", sts1, msg, VD_VERBOSE );
	    }
	    break;

	case VD_BAT_CLEAR_ALL :
	    /* 
	     * user unselected all dwg views for extraction
	     */
	    dp$erase_hilite ( msg = &msg );
	    for( ii=0; ii< me->nbDv; ii++ )
	    {
		FIfld_get_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, &sel_flag );

		if ( sel_flag )
		  FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, FALSE );
	    }
	    break;

	case VD_BAT_FIT_VIEW_TGL :
	    /*
	     * if tgl is on, when a dwg is selected, it is fit in all windows
	     */
	    FIg_get_state ( FP_BAT, VD_BAT_FIT_VIEW_TGL, (int *) &me->fitTgl );
	    break;

	case VD_BAT_BOOLSOL_FLD :
	   /*
	    * user selected one of the options (dwg view/solid/view vol/mdl
	    * view) for selecting solid for locating elements of dwg view
	    */
	   if ( me->activeDv == -1 )
	   {
		FIg_set_text ( FP_BAT, FI_MSG_FIELD,
					"No Drawing View Selected" );
		break;
	   }

	   FIg_get_text ( FP_BAT, VD_BAT_BOOLSOL_FLD, tmpstr );
	   if ( strcmp( tmpstr, "Drawing View") )
           {
              FIg_set_text ( FP_BAT, FI_MSG_FIELD,
                          "This option will produce non-associative output ." );
           }
	   if ( !strcmp( tmpstr, "Drawing View") )
	   {
		me->props[me->activeDv] =
		  (me->props[me->activeDv]& ~(VD_SOLID | VD_VV | VD_MDLV ));
		me->props[me->activeDv] |= VD_DV;
		me->solid[me->activeDv].obj_id = me->dvlist[me->activeDv];
		me->solid[me->activeDv].mod_env = me->ModuleInfo;

		sprintf ( name, "%s[DwgView]", me->dvnames[me->activeDv] );
		FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, me->activeDv,
							0, name, TRUE );
		FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, me->activeDv,
								0, TRUE );
	   }
	   else if ( !strcmp( tmpstr, "Solid") )
	   {
		_put_response ( resp = VD_LOC_SOL );
	   }
	   else if ( !strcmp( tmpstr, "View Volume") )
	   {
		num_vvol_sel = 0;
		sts1 = VDdispVVform(	&msg,
				(IGRboolean) TRUE,
				&num_vvol_sel,
				&vvol_ids,
				&vvol_envs,
				NULL,
				NULL );
/*		if ( !(sts1 & msg & 1) ) break; / * there may not be vvols */
/*		__DBGpr_int("no of vvol selected", num_vvol_sel); */

		if ( num_vvol_sel && vvol_ids && vvol_envs )
		{
		   me->solid[me->activeDv].obj_id  = vvol_ids[0];
		   me->solid[me->activeDv].mod_env = vvol_envs[0];

		  me->props[me->activeDv] =
		    (me->props[me->activeDv]& ~(VD_DV | VD_SOLID | VD_MDLV ));
		  me->props[me->activeDv] |= VD_VV;
		  sprintf ( name, "%s[ViewVol]", me->dvnames[me->activeDv]);
		  FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, me->activeDv,
							0, name, TRUE );
		  FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, me->activeDv,
								0, TRUE );
		}

		if ( vvol_ids ) free ( vvol_ids );
		if ( vvol_envs ) free ( vvol_envs );
	   }
	   else if ( !strcmp( tmpstr, "Model View") )
	   {
		num_mv_sel = 0;
		sts1 = VDdispMVform( &msg,
				(IGRboolean) TRUE,
				&num_mv_sel,
				&mv_ids,
				&mv_envs,
				NULL,
				NULL );
		
/*		if ( !(sts1 & msg & 1) ) break; / * there may not be mdlViews */
/*		__DBGpr_int("no of mv selected", num_mv_sel); */

		if ( num_mv_sel && mv_ids && mv_envs )
		{
		   me->solid[me->activeDv].obj_id  = mv_ids[0];
		   me->solid[me->activeDv].mod_env = mv_envs[0];
		   sprintf ( name, "%s[ModelView]", me->dvnames[me->activeDv]);
		   FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, me->activeDv,
							0, name, TRUE );
		   FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, me->activeDv,
								0, TRUE );
		   me->props[me->activeDv] =
		     (me->props[me->activeDv]& ~(VD_DV | VD_SOLID | VD_VV ));
		   me->props[me->activeDv] |= VD_MDLV;
		}

		if ( mv_ids ) free ( mv_ids );
		if ( mv_envs ) free ( mv_envs );
	   }

	   break;

	case VD_BAT_DV_FLD :
	   /*
	    *  user selected/unselected one of the drawing views in edit
	    *  mode/select mode
	    */
	   dp$erase_hilite ( msg = &msg );
	   me->activeDv = -1;
	   FIg_get_state ( FP_BAT, VD_BAT_EDIT_TGL, (int *) &editTgl );
	   for ( ii=0; ii < me->nbDv; ii++ )
	   {
		FIfld_get_select( FP_BAT, VD_BAT_DV_FLD, ii, 0, &sel_flag);

		if ( sel_flag )
		{
		  if ( editTgl )  me->activeDv = ii;

		  if( editTgl && me->fitTgl && me->fitWin.objid != NULL_OBJID )
		  {
		     sts1 =  vd$vw_fit_object (
				object	  = &me->dvlist[me->activeDv],
				factor    = 1.0 ,
				md_env    = &me->ModuleInfo ,
				ggid      = &me->fitWin ,
				num_ggid  = 1 );
		  }

		  property = GRIS_DISPLAYABLE ;
		  set = 1 ;	/* set property */
		  sts1 =
		  _VD_SEND_OBJN(me->clippolyIds[ii],
				GRvg.GRchgprops ( &msg, &set, &property));
		  VDS_ERR_CONTINUE ( "form_notif", sts1, msg, VD_VERBOSE );

		  /* Display the clipping polygon */
		  sts1 = gr$display_object (  object_id = &me->clippolyIds[ii],
					      mode	= GRhhd );
		  VDS_ERR_CONTINUE ( "form_notif", sts1, MSSUCC, VD_VERBOSE );

		  set = 0 ;	/* remove property */
		  sts1 =
		  _VD_SEND_OBJN(me->clippolyIds[ii],
				GRvg.GRchgprops( &msg, &set, &property));
		  VDS_ERR_CONTINUE ( "form_notif", sts1, msg, VD_VERBOSE );
		} /* if ( sel_flag ) */
	  }  /* for (ii=0; ii<me->nbDv; ii++) */

	  break;

	case FI_EXECUTE :

	   FIg_get_state ( FP_BAT, VD_BAT_EDIT_TGL, (int *) &editTgl );
	   if ( editTgl )
	   {
	     FIg_set_text(FP_BAT,FI_MSG_FIELD, "Please change to SELECT mode");
	     break;
	   }

	   dp$erase_hilite ( msg = &msg );

	   /*
	    * validation of input data  
	    * check if setup files exist
	    */
	   sts1 = VD_drwExecConfigAddFunctions();
	   if( !(sts1 & 1)) {
		VD_drwExecConfigRmFunctions(); 
		msg = MSFAIL;
		break;
	   }

	   count = 0;
	   msg = MSSUCC;

	   __DBGpr_int(" Number DV ", me->nbDv );

	   for (ii=0; ii<me->nbDv; ii++){

	     FIfld_get_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, &sel_flag );
	     if ( sel_flag ){

		count++;
		FIfld_get_text ( FP_BAT, VD_BAT_DV_FLD, ii, 1, 
				 DI_PATH_MAX-1, (unsigned char *) setupFile,
				 &sel_flag, &r_pos );
		if ( strlen(setupFile) )
		{
		  if( ! VD_drw_init_from_drawing_setup(	setupFile,
							&drwMacInfo ))
		  {
			sprintf( stsMsg, "Setup file '%s' error or not found",
								setupFile );
			FIg_set_text( FP_BAT, FI_MSG_FIELD, stsMsg );
			UI_status( stsMsg );
			msg = MSFAIL;
			break;
		  } 
		  VD_drwFreeExtractMacInfo( drwMacInfo );
		} /* if ( strlen(setupFile) ) */
		else
		{
			sprintf( stsMsg,
				 "Setup file not defined for dwgView %d",ii+1 );
			FIg_set_text( FP_BAT, FI_MSG_FIELD, stsMsg );
			msg = MSFAIL;
			break;
		}
	     } /* if ( sel_flag ) */
	   } /* for (ii=0; ii<me->nbDv; ii++) */

	   VD_drwExecConfigRmFunctions();

	   if ( msg == MSFAIL ) break;

	   if( !count ){
	     FIg_set_text( FP_BAT, FI_MSG_FIELD, "No Drawing Views Selected" );
	     break;
	   }

	   sts1 = om$vla_set_dimension( varray = me->batchInfo,
					size   = me->nbDv	);

	   VDbat_InitBatchInfo( me->nbDv, me->batchInfo );

	   for( ii=0; ii<me->nbDv; ii++)
	   {
		me->batchInfo[ii].dv		 = me->dvlist[ii];
		me->batchInfo[ii].props		 = me->props[ii];
		me->batchInfo[ii].solid.obj_id   = me->solid[ii].obj_id;
		me->batchInfo[ii].solid.mod_env  = me->solid[ii].mod_env;

		FIfld_get_text ( FP_BAT, VD_BAT_DV_FLD, ii, 1, 15,
				 (unsigned char *)setupFile, &sel_flag, 
				 &r_pos );
		strncpy ( me->batchInfo[ii].setupFile, setupFile, 14 );
		me->batchInfo[ii].setupFile[14] = '\0';

		FIfld_get_value ( FP_BAT, VD_BAT_DV_FLD, ii, 2, &value,
				  &sel_flag, &r_pos );
		me->batchInfo[ii].layer = (short) value;

		FIfld_get_value ( FP_BAT, VD_BAT_DV_FLD, ii, 3, &value,
				  &sel_flag, &r_pos );

		/* convert offset to database units */
		
		/* get default units */
		strcpy ( type, GRIO_DISTANCE );
		co$get_default_units(
			msg		= &msg,
			table_name	= type,
			osnum		= me->ModuleInfo.md_id.osnum,
			flag		= &flag,
			num_defaults	= &num_defaults,
			default_units	= default_units  );
		strcpy( uomName, default_units[0] );

		/* convert to database units */
		sts1 = uom$cvt_value_to_value(
				  msg	     	     = &msg,
				  unit_type	     = type,
				  osnum		   = me->ModuleInfo.md_id.osnum,
				  alias_to_cvt_from  = uomName,
				  alias_to_cvt_to    = NULL,
				  num_vals	     = 1,
				  values_in	     = &value,
				  values_out	     = &db_offset);
 		VDS_ERR_CONTINUE ( "uom$cvt", sts1, msg, VD_VERBOSE );

		me->batchInfo[ii].offset = db_offset;


		FIfld_get_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, &sel_flag );
		if ( sel_flag )
		  me->batchInfo[ii].props |= VD_EXTR_EXTR;
		else
		  me->batchInfo[ii].props &= ~VD_EXTR_EXTR;

		me->batchInfo[ii].procSts = VD_B_drwInitialSts;

	   } /* for(ii=0; ii<me->nbDv; ii++) */

	   /*
	    * Save the internal strcuture.
	    */
	   sts1 = VDgetBatDataObj ( &msg, &dataObj );

	   sts1 =
	   _VD_SEND_OBJ(dataObj,
			VDbatData.VDpostData (	&msg,
						me->nbDv,
						me->batchInfo,
						NULL, NULL, NULL,
						NULL, NULL ));
	   VDS_ERR_HNDLR("VDpostData", sts1, msg, VD_VERBOSE, quit );

	   /* get available pipe queues and set them in submit form */
	   system( "qstat -p | awk -F@ '/@/{ print $1 }'>/usr/tmp/QList");

	   /* get count of queues */
	   fp = fopen ( "/usr/tmp/QList", "r" );
	   if( fp == NULL )
	   {
		printf ( "Can not open file /usr/tmp/QList\n");
		FIg_set_text ( FP_BAT, FI_MSG_FIELD,
					"Error getting pipe queue list" );
		msg = MSFAIL;
		break;
	   }

	   /* count no. of lines */
	   count = 0;
	   while ( fgets( stsMsg, 80, fp ) ) count++;

	   rewind ( fp );

	   FIfld_set_list_num_rows ( FP_SUB, VD_SUB_QUEUE_FLD, 0, count );
	   for ( ii=0; ii<count; ii++ )
	   {
		fscanf( fp, "%s", qname );
		VDfld_set_list_text ( FP_SUB, VD_SUB_QUEUE_FLD, ii, 0, qname,
				      FALSE );
	   }
	   fclose(fp);

	   FIf_get_location ( FP_BAT, &x_pos, &y_pos );
	   FIf_set_location ( FP_SUB, x_pos, y_pos );
	   _put_response ( resp = VD_SUBFORM);

	   break;

	case FI_CANCEL :
	   dp$erase_hilite ( msg = &msg );
	   _put_response ( resp = EX_FORM_FINISHED);
	   break;
     }
   }
   else if ( form_ptr == FP_SUB )
   {
      switch ( gadget_label )
      {
	case VD_SUB_BATCH_TGL :

	   FIg_get_state ( FP_SUB, VD_SUB_BATCH_TGL, (int *) &procType );
	   if ( procType == 0 )
	   {	
		me->processTgl = VD_BATCH_PROC;
		SMVA_enable ( FP_SUB, 3, VD_SUB_QUEUE_FLD,
					 VD_SUB_LOGIN_FLD,
					 VD_SUB_PASSWD_FLD );
	   }
	   else
	   {
		me->processTgl = VD_INTER_PROC;
		SMVA_disable( FP_SUB, 3, VD_SUB_QUEUE_FLD,
					 VD_SUB_LOGIN_FLD,
					 VD_SUB_PASSWD_FLD );
	   }

	   break;

	case FI_ACCEPT :

	   if( me->processTgl == VD_BATCH_PROC ){

	     FIg_get_text ( FP_SUB, VD_SUB_QUEUE_FLD, me->queue );
	     FIg_get_text ( FP_SUB, VD_SUB_LOGIN_FLD, me->login );
	     FIg_get_text ( FP_SUB, VD_SUB_PASSWD_FLD, me->passwd );

	     if ( me->queue[0] == '\0' ){
	       FIg_set_text( FP_SUB, FI_MSG_FIELD, "Queue name not defined" );
	       break;
	     }

	     if ( me->login[0] == '\0' ){
	       FIg_set_text( FP_SUB, FI_MSG_FIELD, "Login not defined" );
	       break;
	     }

	     if ( me->passwd[0] == '\0' )
	     {
	       FIg_set_text( FP_SUB, FI_MSG_FIELD, "Password not defined" );
	       break;
	     }

	    /*
	     * get the node name.
	     */
	     if( uname( &utsName ) == -1 ){
		/*
		 * Could not find system name.
		 */
		UI_status(" Can't find system name ");
		printf("%s[%d] : uname error\n",__FILE__,__LINE__ );
		break;
	     }

	     __DBGpr_str(" sysname ", utsName.sysname );
	     __DBGpr_str(" nodename", utsName.nodename );
  
	     FIg_set_text( FP_SUB, FI_MSG_FIELD, "Checking Login... Wait ");

#ifdef ENV5
	     /*
	      * The ftp option "-h" does not exist on INTEL_SOLARIS.
	      */
	     sprintf( tmpstr,
		    "(echo user %s %s) | ftp -h -ni %s | grep \"logged in\"",
		    me->login, me->passwd, utsName.nodename );
#else
	     sprintf( tmpstr,
		    "(echo user %s %s) | ftp -niv %s | grep \"logged in\"",
		    me->login, me->passwd, utsName.nodename );
#endif

	     sts1 = system( tmpstr );
	     if(sts1 != 0){
		FIg_set_text( FP_SUB, FI_MSG_FIELD, "Login failed" );
		FIf_cvrt_to_perm_win ( FP_SUB );
		break;
             }
	     else
		FIg_set_text( FP_SUB, FI_MSG_FIELD, "Login successsful" );

	   } /* End pre BATCH_PROCESS checking. */

	   sts1 = _VD_SEND_MY(	VDCmdBatDrw.set_locate_criteria( &msg ));
	   VDS_ERR_HNDLR( "set_locate_cirteria", sts1, msg, VD_VERBOSE, quit);

	   FIf_erase ( FP_SUB );

	   sts1 = VDgetBatDataObj ( &msg, &dataObj );

	   sts1 =
	   _VD_SEND_OBJ(dataObj,
			VDbatData.VDpostData (	&msg,
						me->nbDv,
						me->batchInfo,
						me->queue,
						me->login,
						me->passwd,
						&me->processTgl,
						&me->locateWin ));
	   VDS_ERR_HNDLR("VDpostData", sts1, msg, VD_VERBOSE, quit );

           /* remove the QList file */
           unlink("/usr/tmp/QList");

	   _put_response ( resp = VD_PROCESS );

	   break;

	case FI_CANCEL :
           unlink("/usr/tmp/QList");
	   _put_response ( resp = EX_FORM_FINISHED );
	   break;
      }
   }
   else
   {
	printf("Error\n");
   }


} /* action form_notification */

/*--------------------------------------------------------------------------
action : set_locate_criteria

  Action to set the locate criteria as that of Associative
Visualization Process.  This is needed because while locating elements wrt
dwg view, the locate process looks the following values in addition to the
input sent to the locate macro.
----------------------------------------------------------------------------*/
action set_locate_criteria
{

   *sts = MSSUCC;
   status = OM_S_SUCCESS ;

   me->locate_env = me->ModuleInfo;

   me->attributes.classes[0]	= '\0';
   me->attributes.properties	= 0x11;
   me->attributes.owner_action	= 0x6f;

   me->locate_rtree_thing.w_count		= 0;
   me->locate_rtree_thing.w_flags		= 0;
   me->locate_rtree_thing.p_classes		= NULL;


   /*
    * allocate space for and copy the rtree and eligible classids
    */
/*
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
*/

   me->locate_eligible_thing.w_count	= 3;
   me->locate_eligible_thing.w_flags	= 1;

   if (me->locate_eligible_thing.w_count)
   {
        status = om$vla_set_dimension(varray = me->eligible_classids,
                                    size = me->locate_eligible_thing.w_count);

	status =
	om$get_classid(	classname	= "ACncpx" ,
			p_classid	= &me->eligible_classids[0] );

	status =
	om$get_classid(	classname	= "GRclhdr" ,
			p_classid	= &me->eligible_classids[1] );

	status =
	om$get_classid(	classname	= "GRsmhdr" ,
			p_classid	= &me->eligible_classids[2] );

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

  goto quit ;
}

/*--------------------------------------------------------------------------
action :  setInstanceAndForm

  This action gets data from VDbatData object and sets it in the form.

----------------------------------------------------------------------------*/
action setInstanceAndForm
{
  long			msg, sts1;
  struct GRid		dataObj;
  IGRlong		nbDv;
  VDdrwBatchInfo	*batchInfo = NULL;
  char			name[30],
			tmpstr[30];
  int			ii, jj;
  IGRboolean		found;
  GRIOalias_name	default_units[3];
  IGRshort		flag = 0, num_defaults;
  char			type[UOM_K_MAX_TYPE];
  double		offset_def;
  GRname		locdvname;
  struct GRid		locdvlist;

  SetProc( VDCmdBatDrw_setInstance ); Begin 

  status = OM_S_SUCCESS ;

  __DBGpr_int("Number DrawVw ", me->nbDv );

  for( ii=0; ii<me->nbDv-1; ++ii ){

      for ( jj=ii+1; jj<me->nbDv; ++jj ) 

	if ( me->dvlist[ jj ].objid < me->dvlist[ ii ].objid )
	{
		locdvlist = me->dvlist[ ii ];
		me->dvlist[ii] = me->dvlist[jj];
		me->dvlist[jj] = locdvlist;
		strcpy ( locdvname, me->dvnames[ii] );
		strcpy ( me->dvnames[ii], me->dvnames[jj] );
		strcpy ( me->dvnames[jj], locdvname );
	}
  }

  sts1 = om$vla_set_dimension( varray =  me->props,	size	=  me->nbDv  );
  sts1 = om$vla_set_dimension( varray =  me->solid,	size	=  me->nbDv  );
  sts1 = om$vla_set_dimension( varray =  me->setupFile, size	=  me->nbDv  );
  sts1 = om$vla_set_dimension( varray =  me->layer,	size	=  me->nbDv  );
  sts1 = om$vla_set_dimension( varray =  me->offset,	size	=  me->nbDv  );
  sts1 = om$vla_set_dimension( varray =  me->clippolyIds, size=  me->nbDv  );

  sts1 = VDgetBatDataObj ( &msg, &dataObj );
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, msg, VD_VERBOSE, wrapup );

  /*
   * get data from previous extraction.
   */
  sts1 =
  _VD_SEND_OBJ(	dataObj,
		VDbatData.VDretrieveData(	&msg,
						&nbDv,
						&batchInfo,
						NULL,
						me->login,
						NULL,
						&me->processTgl,
						NULL ));
  VDS_ERR_HNDLR ( "VDgetBatDataObj", sts1, msg, VD_VERBOSE, wrapup );

  FIfld_set_max_num_rows( FP_BAT, VD_BAT_DV_FLD, me->nbDv );
  FIfld_set_num_rows ( FP_BAT, VD_BAT_DV_FLD, me->nbDv );

  strcpy ( type, GRIO_DISTANCE );
  co$get_default_units(	msg		= &msg,
			table_name	= type,
			osnum		= me->ModuleInfo.md_id.osnum,
			flag		= &flag,
			num_defaults	= &num_defaults,
			default_units	= default_units );
  VDS_ERR_HNDLR ( "co$get_def_units", 1, msg, VD_VERBOSE, wrapup );

  /*
   * set units in form
   */
  strcpy( name, default_units[0] );
  FIg_set_text ( FP_BAT, VD_BAT_UNITS_TXT, name );

  for(ii=0; ii<me->nbDv; ii++)
  {
    found = FALSE;
    for( jj=0; jj<nbDv; jj++ )
    {
	if ( me->dvlist[ii].objid == batchInfo[jj].dv.objid &&
	     me->dvlist[ii].osnum == batchInfo[jj].dv.osnum    )
	{
	   found = TRUE;
	   break;
	}
    }

    if ( found )
    {
	me->solid[ii] = batchInfo[jj].solid;
	strcpy ( me->setupFile[ii], batchInfo[jj].setupFile );
	me->layer[ii]   =  batchInfo[jj].layer;
	/* convert offset from database units to active units */

	strcpy( name, default_units[0] );

	sts1 = uom$cvt_value_to_value(msg	     = &msg,
				  unit_type	     = type,
				  osnum		   = me->ModuleInfo.md_id.osnum,
				  alias_to_cvt_from  = NULL,
                                  alias_to_cvt_to    = name,
                                  num_vals	     = 1,
                                  values_in	     = &batchInfo[jj].offset,
				  values_out	     = &offset_def);
	VDS_ERR_CONTINUE ( "uom$cvt", sts1, msg, VD_VERBOSE );

	me->offset[ii]  =  offset_def;
	me->props[ii]   =  batchInfo[jj].props;

	if ( me->props[ii] & VD_DV ){		strcpy ( tmpstr, "DwgView" ); }
	else if ( me->props[ii] & VD_SOLID ){	strcpy ( tmpstr, "Solid" ); }
	else if ( me->props[ii] & VD_VV ){	strcpy ( tmpstr, "ViewVol" ); }
	else{					strcpy ( tmpstr, "ModelView" );}
    }
    else
    {
	me->props[ii]   	=  VD_DV | VD_EXTR_NEW;
	me->solid[ii].obj_id 	=  me->dvlist[ii];
	me->solid[ii].mod_env	=  me->ModuleInfo;
	strcpy( tmpstr, "DrwView" );
	strcpy ( me->setupFile[ii], "visual" );
	me->layer[ii]		=  1001;
	me->offset[ii]		=  0.0;
    }

    if ( me->dvnames[ii][0] == '\0' )
	  sprintf( me->dvnames[ii], "DwgView_%d", ii );
    sprintf ( name, "%s[%s]", me->dvnames[ii], tmpstr );

    FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, ii, 0, name, FALSE );
    FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, ii, 0, FALSE );
    FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, ii, 1, me->setupFile[ii], FALSE );
    FIfld_set_value ( FP_BAT, VD_BAT_DV_FLD, ii, 2, (double) me->layer[ii],
		      FALSE );
    FIfld_set_value ( FP_BAT, VD_BAT_DV_FLD, ii, 3, me->offset[ii], FALSE );

    if ( me->props[ii] & VD_EXTR_NEW )
	FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, ii, 4, "New", FALSE );
    else if ( me->props[ii] & VD_EXTR_OK )
	FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, ii, 4, "Okay", FALSE );
    else if ( me->props[ii] & VD_EXTR_ERR )
	FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, ii, 4, "Error", FALSE );

  }

  FIg_disable ( FP_BAT, VD_BAT_SELECT_ALL );
  FIg_disable ( FP_BAT, VD_BAT_CLEAR_ALL );
  me->activeDv = -1;

  /*
   * get clipping polygon of drawing view
   */
  {
    OM_S_CHANSELECT 	poly_chan   ;
    OM_S_OBJECT_LINKAGE	list_clippoly[1]; /* unique */
    OMuint		count_poly  ;

    struct GRid		da_id    ;	  /* GRid of drawing view attachment */
    struct GRid		da_ref_ids[1]   ; /* GRid of reference file object   */
    IGRint		da_ref_types[1] ;


    om$make_chanselect(	channame 	= "GRreffile.to_clip",
			p_chanselect 	= &poly_chan	) ;

    for(ii=0; ii<me->nbDv; ii++)
    {
      /* Get drawing view attachment component */
      sts1 = om$send( msg = message GRdrawview.GRget_drawing_attachment_id
						( &msg, &da_id),
		senderid = NULL_OBJID,
		targetid = me->dvlist[ii].objid, 
		targetos = me->dvlist[ii].osnum	) ;

      /* Get model attachment (reference file object) component */
      sts1 = om$send( msg = message GRdvattach.GRget_component_id 
		    (&msg, GR_DV_REFFILE, 1, &da_ref_ids[0], &da_ref_types[0]),
		senderid = NULL_OBJID,
		targetid = da_id.objid,
		targetos = da_id.osnum	) ;

      sts1 = om$get_channel_objects(
				 osnum 		= da_ref_ids[0].osnum,
				 objid		= da_ref_ids[0].objid,
				 p_chanselect 	= &poly_chan,
                        	 list		= list_clippoly,
                        	 size		= 1,
				 count		= &count_poly	) ;

      me->clippolyIds[ii].objid = list_clippoly[0].S_objid ;
      me->clippolyIds[ii].osnum = list_clippoly[0].osnum   ;
    }
  }  /* get clipping polygons of drawing views */

  if ( me->processTgl == VD_INTER_PROC )
  {
	FIg_set_state ( FP_SUB, VD_SUB_BATCH_TGL, TRUE );
	SMVA_disable( FP_SUB, 3, VD_SUB_QUEUE_FLD,
				 VD_SUB_LOGIN_FLD,
				 VD_SUB_PASSWD_FLD );
  }

  me->locateWin.objid	= NULL_OBJID;
  me->fitWin.objid	= NULL_OBJID;

  if(x_pos != -1 && y_pos != -1) FIf_set_location ( FP_BAT, x_pos, y_pos );
  if(x_pos != -1 && y_pos != -1) FIf_set_location ( FP_SUB, x_pos, y_pos );

  me->fitTgl = FALSE;
  FIg_disable ( FP_BAT, VD_BAT_FIT_VIEW_TGL );

  if ( me->login[0] ) FIg_set_text ( FP_SUB, VD_SUB_LOGIN_FLD, me->login );
  me->passwd[0] = '\0';
  FIg_set_text ( FP_SUB, VD_SUB_PASSWD_FLD, "" );

  me->queue[0] = '\0';
  FIg_set_text ( FP_SUB, VD_SUB_QUEUE_FLD, "" );


	wrapup:
		_FREE( batchInfo );
		End ;

		goto quit ;

} /* action setInstanceAndForm */

/*----------------------------------------------------------------------------
action : storeSolid

  This action stores solid located for using it during locate process.
It also changes name in dwg view filed to [Solid] and sets corresponding
bits.
----------------------------------------------------------------------------*/
action storeSolid
{
long	msg;
char	name[30];

   status = OM_S_SUCCESS ;

   me->solid[me->activeDv].obj_id  = me->event1.located_object[0].located_obj;
   me->solid[me->activeDv].mod_env = me->event1.located_object[0].module_info;

   dp$erase_hilite ( msg = &msg );

   me->props[me->activeDv] = 
		  (me->props[me->activeDv]& ~(VD_DV | VD_VV | VD_MDLV ));
   me->props[me->activeDv] |= VD_SOLID;

   sprintf ( name, "%s[Solid]", me->dvnames[me->activeDv] );
   FIfld_set_text ( FP_BAT, VD_BAT_DV_FLD, me->activeDv, 0, name , TRUE);
   FIfld_set_select ( FP_BAT, VD_BAT_DV_FLD, me->activeDv, 0, TRUE );

   goto quit ;

} /* action storeSolid */

/*----------------------------------------------------------------------------
action : storeWindowAndDepths

  This stores window and its display depths. This window is used in the
locate process. Display depths of window are set to these dds once the
command is exited.
----------------------------------------------------------------------------*/
action storeWindowAndDepths
{
struct var_list		var_list[2];
IGRlong			which_error,
			ret_bytes,
			msg;

  *sts = MSSUCC;
  status = OM_S_SUCCESS ;

  me->locateWin.objid = me->event1.event.button.objid;
  me->locateWin.osnum = me->event1.event.button.osnum;

  /*
   * get display depths of window and store them as old display depths.
   */
  var_list[0].var	= WLD_DISPLAY_DEPTHS;
  var_list[0].var_ptr	= (IGRchar *)me->oldDisplayDepths;
  var_list[0].num_bytes = sizeof(IGRdouble)*2;
  var_list[0].bytes_returned = &ret_bytes;

  var_list[1].var = END_PARAM;

  status = om$send(	msg = message IGEgragad.DPinquire
				( &msg, &which_error, var_list),
			targetid = me->locateWin.objid,
			targetos = me->locateWin.osnum);
  VDS_ERR_RPT ( "IGEgragad.DPinquire", status, msg, VD_VERBOSE );


#ifdef VDS_DBG
    printf("me->oldDisplayDepths : [%lf,%lf]\n", me->oldDisplayDepths[0],
						 me->oldDisplayDepths[1] );
#endif

  goto quit ;

}

/*----------------------------------------------------------------------------
action : storeFitWindow

  This stores window which is used for fitting current drawing view if
fit toggle is on.
----------------------------------------------------------------------------*/
action storeFitWindow
{

  *sts = MSSUCC;
  status = OM_S_SUCCESS ;

  me->fitWin.objid = me->event1.event.button.objid;
  me->fitWin.osnum = me->event1.event.button.osnum;

  goto quit ;
}

/*----------------------------------------------------------------------------
action : checkFitWin

	Checks to see that fit window and locate window are not same.  

----------------------------------------------------------------------------*/
action checkFitWin
{

  status = OM_S_SUCCESS ;

  if ( me->fitWin.objid == me->locateWin.objid )
  {
	me->fitWin.objid = NULL_OBJID;
	*sts		 = MSFAIL;
  }
  else
  {
	*sts = MSSUCC;
	me->fitTgl = TRUE;
	FIg_enable ( FP_BAT, VD_BAT_FIT_VIEW_TGL );
  }

  goto quit ;
}

/*----------------------------------------------------------------------------
action : set_old_display_depths

  This action sets the old display depths of window when exiting the command.
-----------------------------------------------------------------------------*/
action set_old_display_depths
{
IGRdouble	depths[6] = {0,0,0,0,0,0};
long		msg;

  status = OM_S_SUCCESS ;

  *sts = MSSUCC;
  if ( me->locateWin.objid == NULL_OBJID ) goto quit;

  depths[2] = me->oldDisplayDepths[0];
  depths[5] = me->oldDisplayDepths[1];

  status = dp$view_vol( msg		= &msg,
			gg_id		= &me->locateWin,
			display_depths	= depths,
			update		= FALSE	);
  VDS_ERR_RPT("dp$view_vol", status, msg, VD_VERBOSE );

  dp$erase_hilite ( msg = &msg );

  UI_status ( "" );

  FIf_erase ( FP_SUB );
}


action save_form_pos
{

  status = OM_S_SUCCESS;

  FIf_get_location( FP_BAT, &x_pos, &y_pos);

  goto quit;

}

/*----------------------------------------------------------------------------
action : VDsubmitBatch

  This action creates a random named file contining list of setup files.
Gets working directory and design filename. Prepares the file which need to
be submitted to pipe-queue. Prepares system command which submits the
request and executes it.

-----------------------------------------------------------------------------*/
action VDsubmitBatch
{
  long			msg;
  int			sts1 ;
  int			count ;
  char			sysAction[DI_PATH_MAX];
  char			sysInfo[DI_PATH_MAX];
  char			dgnName[DI_PATH_MAX];
  char			setFile[DI_PATH_MAX];
  char			pwdName[DI_PATH_MAX];
  char			*fName = "/usr/tmp/batfile" ;
  FILE			*fPntr = NULL ;
  int			srandVal ;
  struct timeval	tv;
  struct timezone	tz ;
  struct utsname	utsName;
  struct EX_var_list	exvar[3];
  int			varsize[2] ;

  int			nb_arg;
  char			*tmp[8];
  char			tmp_dir[]={"/tmp/"};
  char			NQS_error_file[128];
  char			NQS_output_file[128];
  char			VDMoveFile[]={"batch/VDMoveFile.sh"}; 
  char			time_stamp[128];
  IGRchar		product_path[DI_PATH_MAX];


  status = OM_S_SUCCESS ;
  if( me->processTgl != VD_BATCH_PROC )	goto quit ;

  /*
   * create the random support file for all the needed setup files.
   * file with all needed setup files.
   */
  srandVal = gettimeofday( &tv, &tz );
  srandVal = tv.tv_usec % 100000 ;
  srand( srandVal );
  srandVal = rand ();
  sprintf( setFile, "bat%d.lst", srandVal );

  /*
   * Create the file and store the information. See ( VDbatControl.I ).
   */
  status = VDbat_CrtSetupLstFile( &msg, setFile, &count );
  if( ! (status & msg & 1 )){
	UI_status( " Error creation Batch setup list file ");
	goto quit ;
  }

  if( ! count ){
	UI_status( " No Drawing-View Preprocessed for Batch ");
	goto quit ;
  }

  /*
   * Check if file realy exist.
   */
  if( access( setFile, F_OK )){
	sprintf( sysInfo, "Can't find file %s", setFile );
	UI_status( sysInfo );
	goto quit ;
  }
  
  /*
   * Get working directory and filename.
   */
  varsize[0]		= sizeof( pwdName ) ;
  varsize[1]		= sizeof( dgnName );

  exvar[0].var		= EX_WORKING_DIR ;
  exvar[0].var_value	= pwdName ; 
  exvar[0].num_bytes	= &(varsize[0]);
  exvar[1].var		= EX_CUR_FILENAME ;
  exvar[1].var_value	= dgnName ;
  exvar[1].num_bytes	= &(varsize[1]);
  exvar[2].var		= EX_END_PARAM ;

  status =
  ex$global(	mode	= EX_INQ ,
		var	= exvar ,
		which_error = &sts1 );
  if(!( status & 1 )) {
	UI_status(" Can't find PWD / design file names " );
	goto quit ;
  }

  /*
   * get the node name.
   */
  if( uname( &utsName ) == -1 ){
	/*
	 * Could not find system name.
	 */
	UI_status(" Can't find system name ");
	goto quit ;
  }

  __DBGpr_str(" sysname ", utsName.sysname );
  __DBGpr_str(" nodename", utsName.nodename );
  
  /*
   * Be sure the support file is deleted.
   */
  sprintf( sysAction, "rm -f %s", fName );
  sts1 = system( sysAction );
  if( sts1 != 0 ){
	sprintf( sysInfo, "Can't remove file %s", fName );
	UI_status( sysInfo );
	goto quit ;
  }

  if( (fPntr = (FILE *) fopen( fName, "w+x" )) == NULL ){
	sprintf( sysInfo, "Can't open file: %s\n", fName );
	UI_status( sysInfo );
        goto quit ;
  }

  /*
   * write the shell script information.
   * The script need to test if VDS product exist on the server. When this is
   *	not the case a mail needs to be returned to local system.
   * 
   * KDD 4/97 Product name added to the shell parameters. TR179700768.
   *
   *	VDbatchDrw.sh <node_name> <user_name> <passwd>
   *				<drw_dir> <drw_file> <setup_file> <prod_name>
   */

  fprintf(fPntr, "#!/bin/ksh\n" );
  fprintf(fPntr, "#  @$-q %s\n", me->queue );
  fprintf(fPntr, "#  @$\n" );

  fprintf(fPntr, "VDS=`echopath Vds`\n"); 
  fprintf(fPntr, "if [ \"$VDS\" = \"\" ] ;then \n");
  fprintf(fPntr, "if [ `uname -s`  = \"CLIX\" ] ;then \n");
  fprintf(fPntr,
	" mailx -s \"Product I/VDS not found on server\" \"%s@%s\" <<+\n",
				me->login,
                                utsName.nodename );
  fprintf(fPntr, "\n" );
  fprintf(fPntr, "Your batch visualization process has failed. Please\n" );
  fprintf(fPntr, "perform following steps:" );
  fprintf(fPntr, "1. Preprocessed objects in the design file should be \n" );
  fprintf(fPntr, "   deleted by the user. Select the 'set' input generator \n");
  fprintf(fPntr, "   from the pocket menu.\n" );
  fprintf(fPntr, "2. In a local window keyin 'rm *.lst' to delete the  \n" );
  fprintf(fPntr, "   local batch .lst file" );
  fprintf(fPntr, "3. To perform the visualization process you can either: \n" );
  fprintf(fPntr, "   a. Resubmit the batch process to a different queue. \n" );
  fprintf(fPntr, "      --- or --- \n" );
  fprintf(fPntr, "   b. Run 'Local' interactive visualization process. \n" );
  fprintf(fPntr, "\n" );
  fprintf(fPntr, "+\n" );
  fprintf(fPntr, " exit 1\n" );
  fprintf(fPntr, "else\n");
  fprintf(fPntr, "echo \"I/VDS not found\">/dev/console\n");
  fprintf(fPntr, " exit 1\n" );
  fprintf(fPntr, "fi\n");
  fprintf(fPntr, "fi\n");

/********* KDD March 97
* Move dgnName & setFile, from pwdName to tmp_dir (because of permissions & NQS)
*  
*  fprintf(fPntr, "$VDS/batch/VDbatchDrw.sh \\\n%s %s %s \\\n%s %s %s \n",
*				utsName.nodename,
*				me->login,
*				me->passwd,
*				pwdName,
*				dgnName,
*				setFile );
***********/
  sprintf(sysAction, "cp %s/%s %s/%s\n", pwdName, dgnName, tmp_dir, dgnName);
  system(sysAction);

  sprintf(sysAction, "cp %s/%s %s/%s\n", pwdName, setFile, tmp_dir, setFile);
  system(sysAction);

  sprintf(time_stamp, "%s/%s", tmp_dir, setFile); 

  fprintf(fPntr, "$VDS/batch/VDbatchDrw.sh \\\n%s %s %s \\\n%s %s %s \n",
                                utsName.nodename,
                                me->login,
                                me->passwd,
                                tmp_dir,
                                dgnName,
                                setFile); 

/* As of Ad Zuurhout's request only Vds is capable of batch processing */
/*				EX_runname ); */

  fclose( fPntr );

  /*
   * First save the module and then setup list of reference information.
   * Then inform the server about your process.
   */
  status = EX_save_module( active_module_num, TRUE );

  /*
   * Call the process.
   */
  sprintf(NQS_error_file,  "/tmp/VDbatch%-d.e", NQS_batch_process_num);
  sprintf(NQS_output_file, "/tmp/VDbatch%-d.o", NQS_batch_process_num);
  NQS_batch_process_num++; 

/***** KDD March 1997 
*  sprintf( sysAction, " qsub -ke -ko -s /bin/ksh -q %s %s", me->queue, fName );
*****/
  sprintf( sysAction, " qsub -o %s -e %s -s /bin/ksh -q %s %s", 
	   NQS_output_file, NQS_error_file, me->queue, fName );

  sts1 = system( sysAction );
  if( sts1 != 0 ){
	sprintf( sysInfo, "ERROR: Can not execute: %s", sysAction );
	UI_status( sysInfo );
	goto quit ;
  }

  sprintf( sysInfo, " echo \"I/VDS-BATCH : %s \" >>/dev/console ", sysAction );
  system( sysInfo );

/***** KDD March 1997
* The forked script will loop until NQS_error_file gets back, with a 
* time stamp newer than setFile. 
* If NQS fails this process will stop when you exit the design session. 
*****/
  sts1 = vd$prd_get_product_info( logo      = VD_PROD_LOGO_VDS, 
				  conf_path = product_path);

  if ( !(sts1&1) ) {
        sprintf(sysInfo,"ERROR: Path not found: %s", VD_PROD_LOGO_VDS);
        printf("%s\n", sysInfo );
	UI_status(sysInfo);
        goto quit; 
  }
  if ( (strlen(product_path) + strlen(VDMoveFile) + 1) >= DI_PATH_MAX ) {
        sprintf(sysInfo,"ERROR: Long name:%s/%s", product_path, VDMoveFile);
        printf("%s\n", sysInfo );
	UI_status(sysInfo);
        goto quit; 
  }
	
  strcat(product_path, "/"); 
  strcat(product_path, VDMoveFile); 

  nb_arg = 6;
  tmp[0] = product_path;
  tmp[1] = tmp_dir;
  tmp[2] = pwdName;
  tmp[3] = NQS_error_file;
  tmp[4] = time_stamp;
  tmp[5] = dgnName;

  if ( !ex$fork(  num_entry = nb_arg, argu = tmp )) {

    sprintf(sysInfo, "copy %s from %s to %s\n", dgnName, tmp_dir, pwdName);
    UI_status(sysInfo);
    printf("ERROR: Can not fork: %s\n", product_path);
    printf("%s\n", sysInfo);
  }

}



/*---------------------------------------------------------------------------
  action: Cleanup
  
  This action deletes the unprocessed copied section objects in batch mode.
----------------------------------------------------------------------------*/


action Cleanup
{

 struct GRid		dataObj;
 long			msg,sts1;
 IGRlong		nbDv;
 VDdrwBatchInfo         *batchInfo,info ;
 IGRboolean             batch1_inter0;
 struct GRmd_env	modEnv;
 int			sizbuf,NoBytesRet;
 IGRint			i;
 
 
	status = OM_S_SUCCESS;

 	sts1 = VDgetBatDataObj( &msg, &dataObj );
 	sts1 =
        _VD_SEND_OBJ(dataObj,
                       VDbatData.VDretrieveData ( &msg,
                                                &nbDv,
                                                &batchInfo,
                                                NULL, NULL, NULL,
                                                &batch1_inter0, NULL ));
        VDS_ERR_HNDLR("VDretrieveData", sts1, msg, VD_VERBOSE, quit ); 
  	sizbuf = sizeof ( struct GRmd_env );
  	gr$get_module_env(
                   msg    = &msg,
                   sizbuf = &sizbuf,
                   buffer = &modEnv,
                   nret   = &NoBytesRet );
 	for( i=0; i<nbDv; i++ ) 
 	{
   	   sts1 =
           VDdrw_CleanupProcess( &msg, &modEnv, i, VD_O_drw2d, batch1_inter0 );
           __CheckRC( sts1, msg, "VDdrw_CleanupProcess", wrapup );
   
    	   sts1 =
           VDdrw_CleanupProcess( &msg, &modEnv, i, VD_O_drw3d, batch1_inter0 );
           __CheckRC( sts1, msg, "VDdrw_CleanupProcess", wrapup ); 
        
           /* Set the drw3dVw name to null */ 
            
           info.drw3dVw[0]='\0';
           sts1 =
           vd$drw_batch_info( msg = &msg, index = i, info = &info ,
                                   set_inq = VD_B_drw_SET,
                                   type = VD_B_drw_3dVw  );
            

 	} 
   
wrapup:

}

