/* $Id: VRPlNozzle.sl,v 1.8 2002/04/10 15:04:37 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRPlNozzle.sl
 *
 * Description:
 *	Place Nozzle Command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPlNozzle.sl,v $
 *	Revision 1.8  2002/04/10 15:04:37  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.7  2001/03/01 16:47:56  anand
 *	"Regression" against TR 179901996.
 *	
 *	Revision 1.6  2001/02/20 01:12:28  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.5  2001/02/15 15:24:08  build
 *	Corrected debug related errors.
 *	
 *	Revision 1.4  2001/01/31 00:37:37  anand
 *	JTS CR MP 4457
 *	
 *	Revision 1.3  2001/01/20 19:28:31  build
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/11 23:45:42  anand
 *	SP merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.14  2000/11/18  00:02:08  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.13  2000/11/15  20:34:36  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.12  2000/11/10  16:48:16  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.11  2000/09/13  19:49:16  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by lawaddel for Service Pack
#
# Revision 1.10  2000/09/08  17:41:56  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.9  2000/09/08  16:04:44  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.8  2000/09/06  23:19:36  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.7  2000/08/17  18:47:40  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.6  2000/07/21  13:37:14  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.5  2000/07/13  23:22:30  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.4  2000/07/10  18:57:04  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.3  2000/05/12  22:21:50  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.2  2000/05/11  21:44:02  pinnacle
# Replaced: route/vrco/VRPlNozzle.sl for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/10  21:39:26  pinnacle
# Created: route/vrco/VRPlNozzle.sl by apazhani for Service Pack
#
# Revision 1.4  2000/02/10  19:25:40  pinnacle
# (No comment)
#
# Revision 1.3  1999/05/05  12:38:00  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.16  1998/04/20  16:15:08  pinnacle
# Replaced: vrco/VRPlNozzle.sl for: TR 179800961 by aharihar for route
#
# Revision 1.15  1998/04/12  07:58:40  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by apazhani for route
#
# Revision 1.14  1998/04/06  18:07:40  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by lawaddel for route
#
# Revision 1.13  1998/03/27  20:20:50  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by lawaddel for route
#
# Revision 1.10  1998/03/12  23:01:52  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by lawaddel for route
#
# Revision 1.9  1998/03/04  04:27:28  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by apazhani for route
#
# Revision 1.8  1998/02/25  07:55:04  pinnacle
# Replaced: vrco/VRPlNozzle.sl for: TR179800533 by aharihar for route
#
# Revision 1.7  1998/01/23  20:47:58  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by lawaddel for route
#
# Revision 1.6  1997/12/16  14:43:44  pinnacle
# Replaced: vrco/VRPlNozzle.sl for: Regression in 02.04.03.05 by aharihar for route
#
# Revision 1.5  1997/12/09  15:57:36  pinnacle
# Replaced: vrco/VRPlNozzle.sl for: Regression in 02.04.03.04 and TR 179602973 by aharihar for route
#
# Revision 1.4  1997/12/08  14:59:28  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by onayragu for route
#
# Revision 1.3  1997/11/20  18:18:54  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by lawaddel for route
#
# Revision 1.2  1997/10/08  14:51:00  pinnacle
# Replaced: vrco/VRPlNozzle.sl for: TR 179603675 by aharihar for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.13  1997/06/12  21:56:00  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.12  1997/05/19  20:54:14  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.11  1997/05/14  21:29:44  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.10  1997/05/02  13:39:36  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.9  1997/05/01  14:08:02  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.8  1997/04/28  22:57:22  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.7  1997/04/24  21:32:54  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.6  1997/03/19  22:11:16  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.5  1997/02/28  22:51:50  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by yzhu for route
#
# Revision 1.4  1996/11/15  17:28:18  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by r241_int for route
#
# Revision 1.3  1996/11/15  17:20:42  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by r241_int for route
#
# Revision 1.2  1996/08/20  06:40:06  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.21  1996/05/17  19:30:02  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by ashankar for route240
#
# Revision 1.20  1996/05/13  15:00:20  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by ashankar for route240
#
# Revision 1.19  1996/05/01  00:02:14  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by ashankar for route240
#
# Revision 1.18  1996/03/05  22:10:36  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by hverstee for route240
#
# Revision 1.17  1996/03/04  18:07:36  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by hverstee for route240
#
# Revision 1.16  1996/02/27  15:44:00  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by r240_int for route240
#
# Revision 1.15  1996/02/25  14:06:54  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by r240_int for route240
#
# Revision 1.14  1996/01/18  23:29:08  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by r240_int for route240
#
# Revision 1.13  1996/01/16  21:17:24  pinnacle
# Replaced: vrco/VRPlNozzle.sl for:  by r240_int for route240
#
 *
 * History:
 *	02/24/92	Karine 	Creation 
 *	10-13-94	Lori	Added PID scale factor for nozzles (TR179309027)
 *	11-29-95	yzhu	modify function VRChangeAttr and 
 *				VREvaluateNozzle for TR179528304.
 *	12/20/95	HF	TR # 179528590
 *				Remove  _put_response( resp = TERMINATE );
 *				in method init().
 *				Otherwise I/ROUTE will crash if the command:
 *				"Modify Piping Nozzle" is started by keyin
 *				while the user has not yet logged in into PDU.
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	01/17/96	tlb	Use VDfld_set_list_text
 *	11/15/96	Alwin	TR # 179603675.  Prep_g attribute getting bumped
 *				to 0 when the user changes spec on nozzle when
 *				the nozzle is in a placed macro.
 *      02/14/97	yzhu    CR 179528329 
 *	10/08/97	Anand	TR 179603675.  Prep_g attribute plonks to zero
 *				when the user changes spec on nozzle that lives
 *				in a placed macro.
 *	10/21/97	Anand	TR 179602973. User gets "type connect not
 *				implemented" when trying to place a nozzle
 *				the second time. Solution: Force execution of
 *				VRInit in State Start.
 *	12/16/97	Anand	Resolved some problems with Place Piping Nozzle
 *				command - involving cache (string lengths,
 *				updating Instance variable that points to cache)
 *      01/23/98        law     TR179702481- Create association of macro name
 *                              and shape.
 *	02/25/98	Anand	TR179800533. Unable to create user attributes
 *				that are strings. Checked return message,
 *				and status of ACget_named_attribute
 *      03/04/98        Alwin   Added a new method VREraseNozzle(), to erase the
 *                              phantom nozzle, placed at the Base Coor. Sys.
 *                              TR179525895
 *      03/27/98        law     No TR added details to error prints.
 *      04/02/98        law     No TR expanded end-standard fields
 *	Apr 20, 98	Anand	TR179800961. Geometry type field in form empty
 *				when executing Modify piping nozle. Populated
 *				field by fetching from collector.
 *      05/04/99    Reddy       Doble value comparision corrected
 *      02/10/2000  Alwin       CR179900696 - Added code to get Material &
 *				Insulation info from DB.
 *      05/10/2000  Alwin       CR179901312 - Modified to introduce the 
 *				Acoustic Insulation.
 *      05/12/2000  Alwin       CR179900995 - Modified to add a button to
 *				locate and copy parameters from DUCT.
 *      06/06/2000  Alwin       CR179901003 - Added methods to implement 
 *				Raceway Nozzle. They would be included for
 *				02.06.02.00 PLOAD I/ROUTE version.
 *      07/13/2000  Alwin       CR179901661 - ACST attribute has been moved to
 *				System parameters and won't be modifiable. 
 *      07/21/2000  Alwin       CR179901615 - Populated Piping Insulation 
 * 				Thicknesses from db for correspoding Insulation
 *				Type.
 *      08/17/2000  Alwin       CR179901873 - Added unit_number to the 
 *				Nozzle Params form.
 *      09/06/2000  Alwin       CR179901852 - Added COPY_PARAMS button on the
 *				Piping Nozzle form for Modify Piping Nozzle cmd.
 *      09/08/2000  Alwin       Backup the System & User Collector before 
 *				deleting the Evaluate Nozzle. Because when the
 *				Nozzle gets deleted it would delete the 
 *				collectors too. B'cas of the way they get 
 *				constructed.
 *      09/13/2000  Law         CR179901712 - Allow changing shape for pid
 *				hvac nozzles. Default macro names come from
 *				form field. 
 *      11/10/2000  Alwin       CR179901852 - Increased the insul_type - no. of
 *				characters from "4" --> "8"
 *      11/15/2000  Alwin       Found the problem, which was causing the system
 *				to crash.
 *      11/17/2000  Alwin       CR4117 : Removed the "trans_len" from the system
 *				collectors after copying.
 *       1/30/2001  Anand       JTS CR MP 4457: Search capability for spec
 *				field in Nozzle sub-form.
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *				
 *************************************************************************/

command_string		VRC_M_PlacePipingNozzle,0,VRPlPpNz
synonym			VRC_M_PlaceHvacNozzle,1,VRPlHvNz
synonym			VRC_M_PlaceRwayNozzle,2,VRPlRwNz
class			VRPlNozzle
super_class     	VDB_LOCATE
/* product_name		"$SPXR" */
product_name		"$ROUTE"
command_table		"route.cmd"

form "VRUserParam", 0,0,"-1","-1"

specification

#include <math.h>
#include "FI.h"
#include "VRdimdef.h"
#include "VRhvacstr.h"
#include "VRpipestr.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRco.h"
#include "VRdef.h"
#include "VRMath.h"
#include "VRattr_def.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "vrdbgmacros.h"

instance
{
  Form			form_ptr[2];	/* Nozzle main form               			*/
  Form			FormUser;	/* Nozzle User Attributes Form    			*/
  IGRchar		*NPrepString;   /* n_prep string codes array		*/
  IGRchar		*PressString;   /* pressure string codes array		*/
  IGRshort		Product;	/* Product			*/		
  IGRshort		*NPrepShort;    /* n_prep short codes array		*/
  IGRshort		*PressShort;    /* pressure short codes array		*/
  IGRchar		*form_name[2];	/* Pointer to the string of the form name 		*/
  IGRboolean		PidRep;		/* TRUE if PID representation */
  IGRboolean		Init;		/* To know if thwe whole system collection is initialized */
  IGRboolean		ModifyCommand;  /* TRUE if Modify Command 				*/
  IGRboolean		SystemChange;	/* TRUE if user has modify system parameters		*/
  IGRboolean		UserChange;	/* TRUE if user has modify user parameters		*/
  IGRboolean		MissingChange;	/* TRUE if user has modify missing parameters		*/
  IGRboolean		ScaleChange;	/* TRUE if user has modify Pid Scale     		*/
  IGRboolean		ExpChange;	/* TRUE if user has modify expression	*/
  struct VRGenInfo	CompInstance;	/* Nozzle's instance					*/
  struct  GRid		NozzleId;	/* Located Nozzle to modify	   			*/
  struct  GRid		CreaCompId;	/* Created Nozzle Id 		   			*/
  struct  GRid		SysParamId;	/* System Collection Id 	   			*/
  struct  GRid		UserParamId;	/* User Collection Id		   			*/
  struct  GRid		MissingParamsId;/* Missing Collection Id	   			*/
  struct  GRid		expressions[VRPNbNozAttr];
  struct  GRid		MissExp[VR_MAX_ATTR];
  struct  GRid		RefId;		/* Nozzle's attachement referencial			*/
  IGRint		NbMissing;	/* Nb of missing parameters after evaluate		*/
  IGRint		Size;
  /* Added for TR179702481 */
  IGRint                redefine_shape; /* Flag that the shape is redefined */
}

implementation

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "FI.h"
#include "FEI.h"
#include "FIdyn.h"
#include "AS_status.h"
#include "ACattrib.h"
#include "ACdyn_col.h"
#include "nddef.h"
#include "asmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "dpmacros.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "VRmsg.h"
#include "VRchgattrdef.h"
#include "VRparamdef.h"
#include "VRDbParamDef.h"
#include "VRact_params.h"
#include "VRcompdef.h"
#include "VRco.h"
#include "VRattr_def.h"
#include "VRdef.h"
#include "VRformdef.h"
#include "VRMcForm.h"
#include "VRnozzmacros.h"
#include "VRmacros.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRPid.h"
#include "acrepdef.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "VRdbcodlst.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "vrdbgmacros.h"
#include "vrinit_pto.h"
#include "vrpdu_pto.h"
#include "vrtools_pto.h"
#include "VRRwDimen.h"
#include "vrparameters.h"

#include "VRRDBdef.h"
#include "VRRDBmac.h"
#include "bsparameters.h"
#include "VDmem.h"
#include "VRNozzleForm.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG
#define	MAIN			0
#define	SUB			1
#define	NO_CHANGE		250
#define VR_MISSINGFORM_STATUS   1000
/* added by alwin */
#define RECTANGULAR 50
#define OVAL        43
#define CIRCULAR    44
/* Below added for TR179702481 */
#define CNOZ1        5
#define ONOZ1        4
#define RNOZ1        3
/* modified for cr179901712 due to conflict with another include file */
#define NZTYPE      72
#define NZSERVICE   31

  struct  hv_mac_shape                  /* Storage of macronames for shapes */
  {
     IGRchar macro_name[21];
  };


/* added by alwin */

%safe
static X_FormPosition 	= 0;
static Y_FormPosition 	= 0;
static ScreenFormNumber	= 0;
static int VR_TABLE_NOZZLE1;  
static int VR_NOZZLE1_INIT;  
static int ShapeGadget; /* Shows which of the SHAPE CODE is selected--Alwin */ 
/* 2 Added for TR179702481 */
static int Hv_Noz_init = 1; 
static struct hv_mac_shape Hv_Noz_macro[6];/* shape macroname storage */
%endsafe

from	ACrg_collect	import	AClist_attribute,
				ACget_named_attribute,
				ACset_list_attribute;
from	GRgraphics	import	GRdelete,
				GRdisplay, GRchgprops;
from	NDnode		import	NDdisplay, NDdelete, NDcopy, NDget_objects,
				NDplace, NDchg_state, NDchange_connect;
from	expression	import	create;

from	GRgencs	import	GRgetmatrix;
from	VRGeneric	import	VRGetParams;

extern GRclassid OPP_Gexp_class_id,
                 OPP_Gtext_exp_class_id,
		 OPP_ACdyn_col_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

state_table

#include	"VRmsg.h"
#include	"VRmacros.h"
#include 	"VRco.h"

#define	MAIN			0
#define	SUB			1
#define VR_MISSINGFORM_STATUS   1000

state *
on  EX_DATA.GRst_PERPEND_FROM                        state HaveError
on  EX_DATA.GRst_ANGLE_FROM                          state HaveError
on  EX_DATA.GRst_TANGENT_FROM                        state HaveError
on  EX_DATA.GRst_PERPEND_TO                          state HaveError
on  EX_DATA.GRst_ANGLE_TO                            state HaveError

state main

   on CMD_TYPE = 0 do	message_key	VR_M_PlacePipingNozzle	state start
   on CMD_TYPE = 1 do	message_key	VR_M_PlaceHvacNozzle	state start
   on CMD_TYPE = 2 do	message_key	VR_M_PlaceRwayNozzle	state start

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state start

	execute		VRinit(&me->ret)
	prompt_key	VR_P_ChgPar
	dynamics	off
	filter		get_event

        on EX_DATA						state .

        on GR_UNKNOWN_TYPE.VR_MISSINGFORM_STATUS		state .

	on EX_FORM_FINISHED
		do VRChangeAttr(&me->ret)	

		on RETURN_CODE = NO_CHANGE			
			do VREvaluateNozzle(&me->ret)		
			do VREraseNozzle( &me->ret )
			state Place

		on RETURN_CODE = VRUSERPARAM	
			do VRUpdateMissing (&me->ret)		state .

		on RETURN_CODE = VRNOT_OK 			state .

		state Place

	on EX_BACK_UP or EX_RJT_MOVEON	
		do VRDeleteNozzle(&me->ret)			state .

	on EX_RESET
		do VRDeleteNozzle(&me->ret)			state .
	
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state Place
	
        execute                 VREraseNozzle
	prompt_key		VR_P_IdentifyReferencial
	dynamics		off
	locate_eligible		"GRgencs"
	locate_owner         	"LC_RIGID_COMP|LC_FLEX_COMP|LC_REF_OBJECTS"
 	filter			locate	


	on EX_BACK_UP or EX_RJT_MOVEON				state -

	on EX_DATA
		do VRGetRef(&me->ret)
		on RETURN_CODE = VRNOT_OK			state .

		do VRInsertNozzle (&me->ret)		
		on RETURN_CODE = VRNOT_OK			state -

		state terminate

        on EX_RESET
		do VRDeleteNozzle(&me->ret)			state start

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state HaveError
   
	status_key		VR_S_InvDataType

	on ELSE							state -
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action init
{
  extern int    	COB_FI_form_notification();
  extern int    	COB_FI_initial_form_notification();
  IGRint		i, j;
  IGRlong		retmsg, msg;
  IGRshort		listsize, *code_num,listsize1;
  IGRchar 		*speclist, *codelist, *codelist1;
  IGRdouble		*npdlist, *npdlist1;
  IGRchar 		Cnpdlist[VR_MAX_NPDLIST_SIZE][10];
  struct  GRid 		vdssymb_id;
  struct  VDSsymb	vdssymb;
  int			vr_table_nozzle1 = 0;
  IGRdouble             nominal_size;
  IGRchar               text[20];
  IGRchar               pressure_class[10];
  IGRchar               end_condition[10];
  IGRchar               end_standard[20] ; /* law 04/02/98 */
  IGRint                SelFlag, r_pos;


  SetProc( VRPlNozzle_init ); Begin

  me->form_ptr[0] = NULL;
  me->form_ptr[1] = NULL;	    
  me->FormUser	  = NULL;
  me->Size 	  = 0;
  me->CreaCompId.objid = NULL_OBJID ; 

  /* CR179528329 */
  status = VRNozzle_table_check( &msg, &vr_table_nozzle1, NULL);
  if(  vr_table_nozzle1 ) {
	VR_TABLE_NOZZLE1 = 1;
  }
  else { 
	VR_TABLE_NOZZLE1 = 0;
  }
/* Code deleted here for CR179901712 */

  /*| call VDB_LOCATE.init method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VDB_LOCATE.init( type, str_ptr ),
                    targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated)
  {
    End
    return (status);
  }

  /*| call VRinit_products to load the macro object spaces */
  status = VRinit_products();
  as$status( action = RET_STATUS );

  me->FormUser	  = me->forms [0].form_ptr;

  __DBGpr_int(" type (zero for piping, one for HVAC)",type);

  switch( type )
  {
    case 0 : me->Product   = VR_PIPING;
	     me->form_name[0] = "VRNozzle";
	     me->form_name[1] = "VRNozzAttr";
             break;
    case 1 : me->Product   = VR_HVAC;
	     me->form_name[0] = "VRHNozzle";
	     me->form_name[1] = "VRHNozzAttr";
             break;
    case 2 : me->Product   = VR_RWAY;
	     me->form_name[0] = "VRRNozzle";
	     me->form_name[1] = "VRRNozzAttr";
             break;
    default: End
	     return OM_E_ABORT;
  }

  __DBGpr_int("  me->Product  ",me->Product);
  __DBGpr_str("  me->form_name[0]", me->form_name[0] );
  __DBGpr_str("  me->form_name[1]", me->form_name[1] );

  if (! me->ModifyCommand )
  {
      /*| --- get representation to know if we are in PID --- */
      vdssymb_id.osnum = me->ModuleInfo.md_id.osnum;
      vd$symbology(	msg	= &retmsg,
		   symb_id	= &vdssymb_id,
		   symb	= &vdssymb);
      as$status();
      me->PidRep = FALSE;

      me->PidRep = bVR_IS_PID( vdssymb.representation );

      // We can't place PID Raceway Nozzles.
      if( me->PidRep && ( me->Product == VR_RWAY ) )
      {
	  UI_status( "Raceway - PID Nozzles not supported !!!" );
	  End
	  return OM_E_ABORT;
      }
  }

  if(VdsRisAttach() != OM_S_SUCCESS)
  {	
  	me->CreaCompId.objid 	    = NULL_OBJID;
	ex$message( 	field	= ERROR_FIELD, 
			msgnumb	= VR_E_DbShortErrMsg );
	End
        return OM_E_ABORT ;
  }

  /*| ----- Set Form Ptr ----- */
  status = FIf_new ( MAIN, me->form_name[MAIN], COB_FI_form_notification,
		     					&me->form_ptr[MAIN]);

  /*| ----- Set Cmd Oid-Os ----- */
  FIf_set_cmd_oid_os( me->form_ptr[MAIN], my_id, OM_Gw_current_OS );

  /*| ----- Set InitialFormNotification ----- */
  FIf_set_initial_notification_routine ( me->form_ptr[MAIN], 
					     COB_FI_initial_form_notification);
  status = FI_SUCCESS;
  
  /*| ----- Set User Form Ptr ----- */
  status = FIf_new ( SUB, me->form_name[SUB], COB_FI_form_notification,
		     					&me->form_ptr[SUB]);

  /*| ----- Set Cmd Oid-Os ----- */
  FIf_set_cmd_oid_os( me->form_ptr[SUB], my_id, OM_Gw_current_OS );

  /*| ----- Set InitialFormNotification ----- */
  FIf_set_initial_notification_routine ( me->form_ptr[1], 
					     COB_FI_initial_form_notification);

 
  /*| ----- Set Form Configuration ----- */
  /*"X_FormPosition = %d\n", X_FormPosition */
  /*"Y_FormPosition = %d\n", Y_FormPosition */

  if( X_FormPosition && Y_FormPosition )
  	FIf_set_location( me->form_ptr[0], X_FormPosition, Y_FormPosition );
  if( ScreenFormNumber ) FIf_set_screen( me->form_ptr[0], ScreenFormNumber );
  
  ex$message( field = ERROR_FIELD, in_buff = "Processing ..");

  /* CR179528329 */ 
  if(  VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING ) {
        FIg_display( me->form_ptr[0],  RESET_BTN );
  }
  else if (!VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
        FIfld_set_mode( me->form_ptr[0],NOMINAL_SIZE, 0, FI_INSERT);
        FIfld_set_mode( me->form_ptr[0],END_COND, 0, FI_INSERT);
        FIfld_set_mode( me->form_ptr[0],PRESSURE_CLASS, 0, FI_INSERT);
        FIfld_set_mode( me->form_ptr[0],END_STAND, 0, FI_INSERT);
        FIg_erase( me->form_ptr[0], RESET_BTN );
  }
 
  /* CR 179601978 */
  if (! me->ModifyCommand )
  {
     if (me->Product   == VR_PIPING ) {
        FIg_display( me->form_ptr[0],  PLC_PIPING_NOZ );
        FIg_erase( me->form_ptr[0],  MOD_PIPING_NOZ );
     }
     else if( me->Product   == VR_HVAC )
     {
        FIg_display( me->form_ptr[0],  PLC_HVAC_NOZ );
        FIg_erase( me->form_ptr[0],  MOD_HVAC_NOZ );
     }
     else if( me->Product == VR_RWAY )
     {
        FIg_display( me->form_ptr[0],  PLC_RWAY_NOZ );
        FIg_erase( me->form_ptr[0],  MOD_RWAY_NOZ );
     }
  } 
  else {
     if (me->Product   == VR_PIPING ) {
        FIg_erase( me->form_ptr[0],  PLC_PIPING_NOZ );
        FIg_display( me->form_ptr[0],  MOD_PIPING_NOZ );
        FIg_display( me->form_ptr[0],  COPY_PARAMS_BTN );
     }
     else if( me->Product   == VR_HVAC )
     {
        FIg_erase( me->form_ptr[0],  PLC_HVAC_NOZ );
        FIg_display( me->form_ptr[0],  MOD_HVAC_NOZ );
        FIg_display( me->form_ptr[0],  COPY_PARAMS_BTN );
     }
     else if( me->Product == VR_RWAY )
     {
        FIg_erase( me->form_ptr[0],  PLC_RWAY_NOZ );
        FIg_display( me->form_ptr[0],  MOD_RWAY_NOZ );
     }
  }
  /* Added for CR179901712 */
  if(me->Product == VR_HVAC && Hv_Noz_init)
  {
       int FIstatus;
       int sel_flag;
       Hv_Noz_init = 0;
       sel_flag = 0;
        if( !me->PidRep )
        {
         int ishape;
           /* Get the default macronames from the first 3 in the list */
            for(ishape = 0; ishape < 3; ishape++)
            {
               FIfld_get_list_text(me->form_ptr[0], NZTYPE, ishape,0,12,
                        (unsigned char *)Hv_Noz_macro[ishape].macro_name,&sel_flag);
            }
           /* Define the number of lines to be 3 */
            FIfld_set_list_num_rows(me->form_ptr[0], NZTYPE, 0, 3);
        }
        else
        {
           char macname[12];
           /* Get the fourth line from the list in the form */
           FIfld_get_list_text(me->form_ptr[0], NZTYPE, 3,0,12,
                      (unsigned char *)(&macname[0]),&sel_flag);
           strcpy(Hv_Noz_macro[0].macro_name,macname);
           /* Put the value in the first line */
               FIfld_set_list_text(me->form_ptr[0], NZTYPE, 0, 0,
                      (unsigned char *)Hv_Noz_macro[0].macro_name,0);
           /* change the number of lines to 1 */
            FIfld_set_list_num_rows(me->form_ptr[0], NZTYPE, 0, 1);
                FIg_set_text( me->form_ptr[0], NZTYPE,
                           Hv_Noz_macro[0].macro_name);

           /* Put the value in the field */
           /* Load the macroname into all 3 macro shapes -CR179901712 */
           strcpy(Hv_Noz_macro[1].macro_name,Hv_Noz_macro[0].macro_name);
           strcpy(Hv_Noz_macro[2].macro_name,Hv_Noz_macro[0].macro_name);
           me->redefine_shape = 0;
        }
  }

  /* ------  DATA BASE ACCESS AND FILL FIELDS  ----------- */

  if( me->Product == VR_PIPING || me->Product == VR_HVAC )
  {
  /*| -- Get Spec Name List and initialize form -- */
  status = VRget_spec_list (&retmsg, me->Product, &listsize , &speclist, NULL); 
  /* Added by Anand for JTS CR MP 4457 */
  qsort( speclist, listsize, VR_MAX_SPEC_NAME_LEN, strcmp );
  /* Added by Anand for JTS CR MP 4457 */
  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( me->form_ptr[1], SPEC_NAME, 0, listsize );
  	for(i=0,j=0 ; i<listsize*VR_MAX_SPEC_NAME_LEN ; i+=VR_MAX_SPEC_NAME_LEN)
	{
       		if (speclist [i])
		{
         		VDfld_set_list_text( me->form_ptr[1], SPEC_NAME, j, 0, &speclist[i], FALSE);
			j++ ;
		}
	}
  }

  /*| -- Get Nominal Size List and initialize form -- */
  /* CR179528329 */
  if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
            VRget_npd_list_from_nozzle1 (&retmsg, me->Product, "NOZZLE1",
                                &listsize1, &npdlist1,NULL);

            for( i = 0; i<listsize1; i++)
                sprintf(Cnpdlist[i], "%lg", npdlist1[i]);

            FIfld_set_list_num_rows( me->form_ptr[0], NOMINAL_SIZE,
                                        0,listsize1 );
            for(i=0; i<listsize1; i++)
            VDfld_set_list_text( me->form_ptr[0], NOMINAL_SIZE, i,
                0, Cnpdlist[i], FALSE);
  }
  else {
  	status = 
        VRget_npd_list (&retmsg, me->Product, "NOZZLE",  
				&listsize , &npdlist, NULL);
        if ( status & 1 )
  	{
	 for( i = 0; i<listsize; i++)
  	    sprintf(Cnpdlist[i], "%lg", npdlist[i]);
  	
	 FIfld_set_list_num_rows( me->form_ptr[0], NOMINAL_SIZE, 0,listsize );
  	 for(i=0; i<listsize; i++)
           VDfld_set_list_text( me->form_ptr[0], NOMINAL_SIZE, i, 0, 
		Cnpdlist[i], FALSE);
        } 
  }

  /*| -- Get Insul Type List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_INSUL_TYPE_LSTNUM, 
    				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for insul type",listsize);

  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( me->form_ptr[1], INSUL_TYPE, 0, listsize );
  	for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[1], INSUL_TYPE, j, 0, 
					     &codelist[i], FALSE);
			j++ ; 
       		}
  	}
  }

  /*| -- Get Tracing Type List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_TRACE_TYPE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for trace type",listsize);

  if ( status & 1 )
  {
	FIfld_set_list_num_rows( me->form_ptr[1], TRACING_TYPE, 0, listsize );
  	for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[1], TRACING_TYPE, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /*| -- Get Fluid Code List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_FLUID_CODE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for fluid code",listsize);

  if ( status & 1 ) 
  {
  	FIfld_set_list_num_rows( me->form_ptr[1], FLUID, 0, listsize );
  	
	for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[1], FLUID, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /*| -- Get Paint Type List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_PAINT_TYPE_LSTNUM,  
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for paint type",VR_SHORT_CODETEXT_SIZE);

  if ( status & 1 )
  {
	FIfld_set_list_num_rows( me->form_ptr[1], PAINT_TYPE, 0, listsize );
	for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[1], PAINT_TYPE, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /*| -- Get Weight Group List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_WEIGHT_GRP_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for Weight Group",VR_SHORT_CODETEXT_SIZE);

  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( me->form_ptr[1], WEIGHT_GRP, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[1], WEIGHT_GRP, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
   }

  /*| -- Get Change no List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_CHANGE_NO_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for Change no list ",listsize);

  if ( status & 1 )
  {
	FIfld_set_list_num_rows( me->form_ptr[1], WEIGHT_GRP, 0, listsize );
	for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[1], CHANGE_NO, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /*| -- Get Pressure Class List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_PRES_CLASS_LSTNUM, 
				 &listsize , &me->PressString, &me->PressShort,
				 NULL);

  __DBGpr_int(" listsize for  Pressure Class",listsize);

  if ( status & 1 )
  {
        /* CR179528329 */
        if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
           status = VRget_field_list_set ( &retmsg, me->Product,
                                           "pressure_class",
                                           listsize , me->PressString,
                                           &listsize1 , &codelist1,
                                           NULL);
           if ( status & 1 ) {
             FIfld_set_list_num_rows( me->form_ptr[0], PRESSURE_CLASS, 0,
                                        (listsize1));
        /******** law 04/02/98 *********/
	     for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;
                                                   i+=VR_SHORT_CODETEXT_SIZE)
             {
       		 if (codelist1[i])
       		 {
		   __DBGpr_str(" codelist",&codelist1[i]);
                   VDfld_set_list_text( me->form_ptr[0], PRESSURE_CLASS,
                                    j, 0, &codelist1[i], FALSE);
                   j++;
                 } 
             }
           }
           /* law - No TR - added detail to print */
	   else {
              printf(" Table NOZZLE1-pressure class is not correct\n");
	   }
        }
        else {	
          FIfld_set_list_num_rows( me->form_ptr[0], PRESSURE_CLASS, 0, 
					listsize );
          for(  i=0 , j=0  ;  i < listsize*VR_SHORT_CODETEXT_SIZE  ;
					i += VR_SHORT_CODETEXT_SIZE  )
          {
       		if (me->PressString[i])
       		{
			__DBGpr_str(" PressString",&me->PressString[i]);
		 	VDfld_set_list_text( me->form_ptr[0], PRESSURE_CLASS, 
                                    j, 0, &me->PressString[i], FALSE);
			j++;
       		}
  	  }
	}
  }

  /*| -- Get Nozzle Service List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_NOZ_SRV_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for Nozzle Service",listsize);

  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( me->form_ptr[0], NZSERVICE, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[0], NZSERVICE, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /*| -- Get End Condition List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_END_COND_LSTNUM, 
				 (IGRshort *)&me->Size , &me->NPrepString, 
				 &me->NPrepShort, NULL);

  __DBGpr_int(" listsize for End Condition",me->Size);

  if ( status & 1 )
  {
	/* CR179528329 */
        if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
           status = VRget_field_list_set ( &retmsg, me->Product,
                                           "end_condition",
                                           me->Size, 
					   me->NPrepString,
                                           &listsize1 , &codelist1,
                                           NULL);
           if ( status & 1 ) {
             FIfld_set_list_num_rows( me->form_ptr[0],  END_COND, 0,
                                        (listsize1));
             /******* law 04/02/98 **********/
             for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
             {
       		 if (codelist1[i] && codelist1[i] != ' ')
       		 {
		   __DBGpr_str(" codelist",&codelist1[i]);
                   VDfld_set_list_text( me->form_ptr[0],  END_COND,
                                    j, 0, &codelist1[i], FALSE);
                    j++;
                 }
             }
           }
           /* law - No TR - added detail to print */
           else {
              printf(" Table NOZZLE1-end condition is not correct\n");
           }
        }
        else {
  	FIfld_set_list_num_rows( me->form_ptr[0], END_COND, 0, me->Size );
        for(i=0,j=0;i<me->Size*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (me->NPrepString[i] && me->NPrepString[i] != ' ')
       		{
			__DBGpr_str(" codelist", &me->NPrepString[i]);
			VDfld_set_list_text( me->form_ptr[0], END_COND, j, 0,
					     &me->NPrepString[i], FALSE);
			j++;
       		}
  	}
        }
  }

  /*| -- Get Schdl/Thick ovrd List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_SCHED_THK_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for Schdl/Thick ovrd List",listsize);

  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( me->form_ptr[0], SCHDL_THK, 0, listsize );
  	FIfld_set_list_num_rows( me->form_ptr[1], SCHDL_THK_OVRD, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
		        __DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[0], SCHDL_THK, j,
						0, &codelist[i], FALSE);
			VDfld_set_list_text( me->form_ptr[1], SCHDL_THK_OVRD, 
						j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /*| -- Get End Standard List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_END_STD_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for  End Standard List",listsize);

  if ( status & 1 )
  {
        /* CR179528329 */
        if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
           status = VRget_field_list_set ( &retmsg, me->Product,
                                           "end_standard",
                                           listsize,
                                           codelist,
                                           &listsize1 , &codelist1,
                                           NULL);
           if ( status & 1 ) {
             FIfld_set_list_num_rows( me->form_ptr[0],  END_STAND, 0,
                                        (listsize1));
           
             /******* law 04/02/98 ********/
             for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;
                                                 i+=VR_SHORT_CODETEXT_SIZE)
             {
       		 if (codelist1[i])
       		 {
		   __DBGpr_str(" codelist",&codelist1[i]);
                   VDfld_set_list_text( me->form_ptr[0],  END_STAND,
                                    j, 0, &codelist1[i], FALSE);
                   j++;
                 }
             }
           }
           /* law - No TR - added detail to print */
           else {
              printf(" Table NOZZLE1 codelist is not correct\n");
           }
        }
        else {
  	FIfld_set_list_num_rows( me->form_ptr[0], END_STAND, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
			__DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[0], END_STAND, j,
						0, &codelist[i], FALSE);
			j++;
       		}
  	}
        }
  }

  /*| -- Get Approval Status List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_APP_STS_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for Approval Status List",listsize);

  if ( status & 1 )
  {
  	FIfld_set_list_num_rows( me->form_ptr[0], APPRV_STS, 0, listsize );
  	FIfld_set_list_num_rows( me->form_ptr[1], APPRO_STS, 0, listsize );
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
                        __DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[0], APPRV_STS, j, 0, &codelist[i], FALSE);
			VDfld_set_list_text( me->form_ptr[1], APPRO_STS, j, 0, &codelist[i], FALSE);
			j++;
       		}	
  	}
  }

  /*| -- Get Constrained Status List and initialize form -- */
  status = VRget_code_list_set ( &retmsg, me->Product, VR_P_CONST_STS_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);

  __DBGpr_int(" listsize for Constr Status List",listsize);

  if ( status & 1 )
  {
	FIfld_set_list_num_rows( me->form_ptr[0], CONST_STS, 0, (listsize - 1));
  	FIfld_set_list_num_rows( me->form_ptr[1], CONSTR_STS, 0,(listsize - 1));
        for(i=0,j=0;i<listsize*VR_SHORT_CODETEXT_SIZE;i+=VR_SHORT_CODETEXT_SIZE)
  	{
       		if (codelist [i])
       		{
                        __DBGpr_str(" codelist",&codelist[i]);
			VDfld_set_list_text( me->form_ptr[0],
				CONST_STS, j, 0, &codelist[i], FALSE);
			VDfld_set_list_text( me->form_ptr[1], 
				CONSTR_STS, j, 0, &codelist[i], FALSE);
			j++;
       		}
  	}
  }

  /* CR179528329 for macro_name filed */
  if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
     status = VRget_macro_list_set ( &retmsg, me->Product,
                                          "macro_name",
                                           &listsize1 , &codelist1,
                                           NULL);
     if ( status & 1 ) {
             FIfld_set_list_num_rows( me->form_ptr[0],  NZTYPE, 0, (listsize1));

        /******* law 04/02/98 ************/
        for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;
                                                   i+=VR_SHORT_CODETEXT_SIZE)
             {
       		 if (codelist1[i]) {
                        __DBGpr_str(" codelist",&codelist1[i]);
                 	VDfld_set_list_text( me->form_ptr[0],  NZTYPE,
                                    j, 0, &codelist1[i], FALSE);
                        j++;
                 }
             }
     }
           /* law - No TR - added detail to print */
     else {
              printf(" Table NOZZLE1 macroname is not correct\n");
     }
  }

  if( me->Product == VR_HVAC )
  {
	 IGRchar	insul_type[2];

	 /* 
	  * To update the Thermal Insulation list, send insul_type = "T".
	  * To update the Acoustical Insulation list, send insul_type = "A"
	  * CR179901312 Alwin
	  */
	 strcpy( insul_type, "T" );
	 VRUpdMaterial_InsulationList( me->form_ptr[1], NULL, 
					insul_type, INSUL_MATERIAL );

	 strcpy( insul_type, "A" );
	 VRUpdMaterial_InsulationList( me->form_ptr[1], NULL, 
					insul_type, ACOUSTICAL_MATERIAL );
  }
  
  }/* end if product is VR_PIPING */

  ex$message( field = ERROR_FIELD, in_buff = "Processing ...");

  /* ----- Initialisation for modify command ----- */
  me->SysParamId.objid 	    = NULL_OBJID;
  me->UserParamId.objid     = NULL_OBJID;
  me->MissingParamsId.objid = NULL_OBJID;
  me->MissingChange	    = FALSE; 
  me->UserChange	    = FALSE;
  me->SystemChange	    = FALSE;
  me->ExpChange 	    = FALSE;
  me->ScaleChange           = FALSE;

  /* To know if the whole collection has been initialized. Here it hasn't */
  me->Init = TRUE;

  for( i=0; i<VRPNbNozAttr; i++ )
  {
	me->expressions[i].objid = NULL_OBJID;
	me->expressions[i].osnum = me->ModuleInfo.md_id.osnum;
  }

  for( i=0; i<VR_MAX_ATTR; i++ )
  {
	me->MissExp[i].objid = NULL_OBJID;
	me->MissExp[i].osnum = me->ModuleInfo.md_id.osnum;
  }

  if( !me->ModifyCommand )
  {
  	status = om$send( msg      = message VRPlNozzle.VRinit( &retmsg ),
                    targetid = my_id );
  	as$status( action = RET_STATUS );

        /* CR179528329 */
        if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) 
	{
            FIfld_get_text( me->form_ptr[0], END_STAND, 0, 0, 20,
                  (unsigned char *)end_standard, &SelFlag, &r_pos );

            FIfld_get_text( me->form_ptr[0], END_COND, 0, 0, 9,
                  (unsigned char *)end_condition, &SelFlag, &r_pos );

            FIfld_get_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0, 9,
                  (unsigned char *)pressure_class, &SelFlag, &r_pos );


            FIfld_get_text(me->form_ptr[0], NOMINAL_SIZE, 0, 0, 9,
                   (unsigned char *)text, &SelFlag, &r_pos);

            nominal_size = atof(text);
            if( nominal_size != 0 &&
                 strcmp( end_condition, "EMPTY") &&
                 strcmp( pressure_class, "EMPTY")&&
                 strcmp( end_standard, "EMPTY") )
            {
                 /* for NOMINAL_SIZE */
                 sprintf(Cnpdlist[0], "%lg", nominal_size);
                 FIfld_set_list_num_rows( me->form_ptr[0], NOMINAL_SIZE,
                                        0,1);
                 VDfld_set_list_text( me->form_ptr[0], NOMINAL_SIZE, 0,
                        0, Cnpdlist[0], FALSE);

                 /* for END_STAND */
                 FIfld_set_list_num_rows( me->form_ptr[0],  END_STAND, 0,
                                        1);
                 VDfld_set_list_text( me->form_ptr[0], END_STAND,
                                    0, 0, end_standard, FALSE);

                 /* for END_COND */
                 FIfld_set_list_num_rows( me->form_ptr[0],  END_COND, 0,
                                        1);
                 VDfld_set_list_text( me->form_ptr[0], END_COND,
                                    0, 0, end_condition, FALSE);
  
                 /* for PRESSURE_CLASS */
                 FIfld_set_list_num_rows( me->form_ptr[0], PRESSURE_CLASS, 0,
                                        1);
                 VDfld_set_list_text( me->form_ptr[0], PRESSURE_CLASS,
                                    0, 0, pressure_class, FALSE);
             }
        }

	if( me->PidRep )   /* erase the expression label column */
		FIg_erase( me->form_ptr[0], 111 );
	else               /* erase the PID fields */
	{
		FIg_erase( me->form_ptr[0], NOZ_PID_SCALE);
		FIg_erase( me->form_ptr[0], NOZ_PID_SCALE_TXT);
	}
  	FIf_display( me->form_ptr[0]);
  }

 
  ex$message( field = ERROR_FIELD, in_buff = "                 ");
  End
  return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRinit
{
  IGRint		i;
  struct ACrg_coll      attributes[VR_MAX_ATTR];
  IGRlong               msg;
  IGRint 		nb_of_attributes, SelFlag, r_pos;
  IGRchar		txt[9], name[2],  Name[VR_MAX_CHAR];
  struct GRid		CollectId,TempCollectId, UserParamId;

  IGRdouble             nominal_size;
  IGRchar               text[20];
  IGRchar               pressure_class[10];
  IGRchar               end_condition[10];
  IGRchar               end_standard[20] ; /****** law 04/02/98 ****/
  IGRchar               Cnpdlist[VR_MAX_NPDLIST_SIZE][10];

  #define DEFAULT_TYPE "nozz1"

  SetProc( VRinit ); Begin
  me->CreaCompId.objid 	    = NULL_OBJID;
  me->NbMissing		    = 0;

  /*| ----- Initialise User Collection ----- */
  if ( me->UserParamId.objid == NULL_OBJID && !me->ModifyCommand )
  {
	UserParamId.osnum = me->ModuleInfo.md_id.osnum;
 	VR$active_params( VRproduct      = me->Product,
                    	  mode           = VR_USER_MODE,
                    	  act_param_id   = &UserParamId,
  	      	    	  status         = msg );
	
	status = om$send( msg      = message NDnode.NDcopy( &msg ,0, 
						&me->ModuleInfo,
						&me->ModuleInfo,
						&me->UserParamId),
                      	  senderid = NULL_OBJID,
                      	  targetid = UserParamId.objid,
                      	  targetos = UserParamId.osnum  );
    	as$status( action = RET_STATUS );
  }

  /*| ----- Initialize System Collection ----- */
  if ( me->SysParamId.objid == NULL_OBJID && !me->ModifyCommand )
  {
	CollectId.osnum = me->ModuleInfo.md_id.osnum;
  	VR$active_params( VRproduct 	= me->Product,
			  operation 	= VR_INIT,
			  mode 		= VR_NOZZLE_MODE,
                          act_param_id	= &CollectId,
                          status 	= status );
        as$status( action = RET_STATUS );
  
  	VRprint_user_attr( &CollectId );

        if( me->Product == VR_HVAC )
        {
	   struct ACrg_coll ShapeCodeCol;

           strcpy( ShapeCodeCol.name, VR_N_SHAPE_IN );
           ShapeCodeCol.desc.type = AC_ATTRIB_DOUBLE;
	   ShapeCodeCol.desc.value.att_exp = (IGRdouble) ShapeGadget;

           status = VR$ModifyCollection(  p_msg                 = &msg,
                                          Operation             = VR_MERGE_COLL,
                                          p_ParamsListToModify  = &ShapeCodeCol,
                                          NbParamsToModify      = 1,
                                          p_OutputCollectionId  = &CollectId);
        }

	status = om$send( msg      = message NDnode.NDcopy( &msg ,0, 
							&me->ModuleInfo,
							&me->ModuleInfo,
							&me->SysParamId),
                      	  senderid = NULL_OBJID,
                      	  targetid = CollectId.objid,
                      	  targetos = CollectId.osnum  );
    	as$status( action = RET_STATUS );

	if( me->Product != VR_RWAY )
	    VRInitNozPid( &me->SysParamId, me->Product, &me->ModuleInfo);
  }

  /* ----- Initialization with default collection or with the located 
	   object's one ----- */
  strcpy( name, " ");
  status = om$send( msg      = message ACrg_collect.AClist_attribute
		( &msg, VR_MAX_ATTR, attributes, &nb_of_attributes ),
                    senderid = me->SysParamId.objid,
                    targetid = me->SysParamId.objid,
                    targetos = me->SysParamId.osnum) ;
  as$status( action = RET_STATUS ) ;
  as$status( action = RET_STATUS, sts = msg ) ;
  
  /*"number of attributes = %d \n",nb_of_attributes*/

  if( !me->ModifyCommand ) me->CompInstance.nStatus = VR_OUT_MACRO;

/*
   "VR_OUT_MACRO should be read as WITHOUT_MACRO. Meaning, that if the
    user does not key-in any expressions there is no need to store them
    inside a macro. But if expressions have been entered, they are kept
    inside a macro set as parent of the nozzle, replacing the standard
    collection."
*/

  __DBGpr_int( " No. of Attributes ", nb_of_attributes );

  /* ----- Initialization of the fields ----- */
  for( i=0 ; i<nb_of_attributes ; i++ )
  {
	// Initialize the Raceway Nozzle Main and Attribute form
	if( me->Product == VR_RWAY )
	{
	   __DBGpr_str( " Attribute Name ", attributes[i].name );

	   if ( !strcmp( attributes[i].name, VR_N_DUCT_MATERIAL_AN))
		FIg_set_text( me->form_ptr[1], RWAY_NOZ_TRAY_MATERIAL, 
			   attributes[i].desc.value.att_txt);

	   if ( !strcmp( attributes[i].name, VR_N_DUCT_THICK_DB))
		FIg_set_value( me->form_ptr[1], RWAY_NOZ_TRAY_THICK, 
				attributes[i].desc.value.att_exp);

	   if ( !strcmp( attributes[i].name, VR_N_SYST_NAME_AN))
		   FIg_set_text( me->form_ptr[1], SYSTEM_NAME,
			   attributes[i].desc.value.att_txt );

	   if ( !strcmp( attributes[i].name, VR_N_THROAT_DB))
		   FIg_set_value( me->form_ptr[1], RWAY_NOZ_THROAT_RAD,
			   attributes[i].desc.value.att_exp );

	   if ( !strcmp( attributes[i].name, VR_N_TRANS_L_DB))
		   FIg_set_value( me->form_ptr[1], RWAY_NOZ_TRANS_LEN,
			   attributes[i].desc.value.att_exp );

	   if ( !strcmp( attributes[i].name, VR_N_CORN_RAD_DB))
		   FIg_set_value( me->form_ptr[1], RWAY_NOZ_CORN_RAD,
			   attributes[i].desc.value.att_exp );

	     if ( !strcmp( attributes[i].name, VR_N_UNIT_AN ) )
		   FIg_set_text( me->form_ptr[1], RWAY_NOZ_UNIT,
			   attributes[i].desc.value.att_txt );

	     if ( !strcmp( attributes[i].name, VR_N_ZONE_AN ) )
		   FIg_set_text( me->form_ptr[1], RWAY_NOZ_ZONE,
			   attributes[i].desc.value.att_txt );

	     if ( !strcmp( attributes[i].name, VR_N_APPRV_STAT_AN))
		     FIg_set_text( me->form_ptr[0], APPRV_STS,
			     attributes[i].desc.value.att_txt );

	     if ( !strcmp( attributes[i].name, VR_N_CONSTR_STAT_AN))
		     FIg_set_text( me->form_ptr[0], CONST_STS,
			     attributes[i].desc.value.att_txt );
	     continue;
	}

	{
	     /*| Nozzle OUT of macro */
	     if ( !strcmp( attributes[i].name, VR_N_TAG_NUMBER_AN ))
		FIfld_set_text( me->form_ptr[0], TAG_NUMBER, 0, 0, 
		     attributes[i].desc.value.att_txt, FALSE);

	     if ( !strcmp( attributes[i].name, VR_N_SERVICE_AN ))
	     FIfld_set_text( me->form_ptr[0],NZSERVICE, 0, 0, 
		     attributes[i].desc.value.att_txt, FALSE);

	     if ( !strcmp( attributes[i].name, VR_N_GDIAMETER_DB))
	     {
		 if ( (fabs(attributes[i].desc.value.att_exp) < VRGetTol(VR_DIST_TOL)) 
				     && VR_TABLE_NOZZLE1)
			   VR_NOZZLE1_INIT = 1;
		 else if( ( fabs(attributes[i].desc.value.att_exp - 15.0)<VRGetTol(VR_DIST_TOL))
				     && VR_TABLE_NOZZLE1)
			   VR_NOZZLE1_INIT = 2;
		 else 
			   VR_NOZZLE1_INIT = 0;
		     sprintf( txt, "%f", attributes[i].desc.value.att_exp );
		     FIfld_set_text( me->form_ptr[0], NOMINAL_SIZE, 0, 0, 
			 txt, FALSE);
	     }
     
	     if ( !strcmp( attributes[i].name, VR_N_WIDTH1_DB))
		     FIg_set_value( me->form_ptr[0], WIDTH, 
			     attributes[i].desc.value.att_exp);

	     if ( !strcmp( attributes[i].name, VR_N_DEPTH1_DB))
		     FIg_set_value( me->form_ptr[0], DEPTH, 
			     attributes[i].desc.value.att_exp);

	     if ( !strcmp( attributes[i].name, VR_N_PREPS_G_IN ))
	     if( me->Product == VR_PIPING ) {
		     /* CR179528329      */
		     if ( VR_NOZZLE1_INIT > 1 && VR_TABLE_NOZZLE1    ) {
			 if( strcmp( attributes[i].desc.value.att_txt,
				     "FF") == 0)
			   VR_NOZZLE1_INIT ++;
		     }
		     FIfld_set_text( me->form_ptr[0], END_COND, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
	     }
	     else
		     FIfld_set_text( me->form_ptr[0], END_PREP, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);


	     if ( !strcmp( attributes[i].name, VR_N_RATINGS_G_DB) && 
			     me->Product == VR_PIPING ) {
		 /* CR179528329      */
		 if ( VR_NOZZLE1_INIT > 1 && VR_TABLE_NOZZLE1    ) {
			 if( strcmp( attributes[i].desc.value.att_txt,
				     "125#") == 0)
			   VR_NOZZLE1_INIT ++;
		 }
		 FIfld_set_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0,
				  attributes[i].desc.value.att_txt, FALSE);
	     }
	     if ( !strcmp( attributes[i].name, VR_N_PRESS_CLASS_AN))
	     FIg_set_text( me->form_ptr[1], HPRESSURE_CLASS, 
			     attributes[i].desc.value.att_txt);

	     if ( !strcmp( attributes[i].name, VR_N_THICK_OVER_AN))
	     {
		     FIfld_set_text( me->form_ptr[0], SCHDL_THK, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
		     FIfld_set_text( me->form_ptr[1], SCHDL_THK_OVRD, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
	     }
 
	     if ( !strcmp( attributes[i].name, VR_N_END_STD_G_IN )) {
		/* CR179528329      */
		 if ( VR_NOZZLE1_INIT > 1 && VR_TABLE_NOZZLE1    ) {
			 if( strcmp( attributes[i].desc.value.att_txt,
				     "B16.5") == 0)
			   VR_NOZZLE1_INIT ++;
		 }
		 FIfld_set_text( me->form_ptr[0], END_STAND, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
	     }
	     if ( !strcmp( attributes[i].name, VR_N_APPRV_STAT_AN))
	     {
		     FIfld_set_text( me->form_ptr[0], APPRV_STS, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
		     FIfld_set_text( me->form_ptr[1], APPRO_STS, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
	     }

	     if ( !strcmp( attributes[i].name, VR_N_CONSTR_STAT_AN))
	     {
		     FIfld_set_text( me->form_ptr[0], CONST_STS, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
		     FIfld_set_text( me->form_ptr[1], CONSTR_STS, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);
	     }

	     if ( !strcmp( attributes[i].name, VR_N_FLOW_RATE_DB))
		     FIg_set_value( me->form_ptr[0], NOZZLE_AIRFLOW, 
			     attributes[i].desc.value.att_exp);

	     if ( !strcmp( attributes[i].name, VR_N_MACRO_NAME_AN ))
		     FIfld_set_text( me->form_ptr[0], 72, 0, 0, 
			     attributes[i].desc.value.att_txt, FALSE);

	     // for CR179901873
	     if ( !strcmp( attributes[i].name, VR_N_UNIT_AN ))
		     FIg_set_text( me->form_ptr[1], NOZ_UNIT_NUMBER,
			     attributes[i].desc.value.att_txt );

	     if ( me->PidRep )  
	     {
		     if ( !strcmp ( attributes[i].name, VR_N_PID_SCALE_DB ))
			     FIfld_set_value( me->form_ptr[0], 
				     NOZ_PID_SCALE, 0, 0, 
				     attributes[i].desc.value.att_exp, 
				     FALSE);
	     }

	}

	if ( !strcmp( attributes[i].name, VR_N_TRACING_CODE_AN ) && 
			me->Product == VR_PIPING )
	FIfld_set_text( me->form_ptr[1], TRACING_TYPE, 0, 0, 
				attributes[i].desc.value.att_txt, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_SEQ_NUMBER_AN))
	{
		/*"set the seqnum = %s\n", attributes[i].desc.value.att_txt */
		FIfld_set_text( me->form_ptr[1], SEQ_NUMBER, 0, 0, 
			attributes[i].desc.value.att_txt, FALSE);
	}

	if ( !strcmp( attributes[i].name, VR_N_SYST_NAME_AN))
		FIfld_set_text( me->form_ptr[1], SYSTEM_NAME, 0, 0, 
			attributes[i].desc.value.att_txt, FALSE);


	if ( !strcmp( attributes[i].name, VR_N_SPEC_GRAV_DB))
		FIfld_set_value( me->form_ptr[1], SPECIFIC_GRAV, 0, 0, 
			attributes[i].desc.value.att_exp, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_ZONE_AN ) )
	{
	   if( me->Product == VR_PIPING )
	      FIfld_set_text( me->form_ptr[1], ZONE_NB, 0, 0, 
		      attributes[i].desc.value.att_txt, FALSE);
	   else 
	      FIfld_set_text( me->form_ptr[1], ZONE, 0, 0, 
		      attributes[i].desc.value.att_txt, FALSE);
	}

	if ( !strcmp( attributes[i].name, VR_N_OPER_TEMP_DB ) )
		FIfld_set_value( me->form_ptr[1], OPER_TEMP, 0, 0, 
			attributes[i].desc.value.att_exp, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_OPER_PRESS_DB ) )
		FIfld_set_value( me->form_ptr[1], OPER_PRESSURE, 0, 0, 
			attributes[i].desc.value.att_exp, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_DGN_TEMP_DB ) )
		FIfld_set_value( me->form_ptr[1], DGN_TEMP, 0, 0, 
			attributes[i].desc.value.att_exp, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_DGN_PRESS_DB ) )
		FIfld_set_value( me->form_ptr[1], DGN_PRESS, 0, 0, 
			attributes[i].desc.value.att_exp, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_CLASS_AN ))
	  FIfld_set_text( me->form_ptr[1], SPEC_NAME, 0, 0, 
			   attributes[i].desc.value.att_txt, FALSE);
	  
	if ( ( !strcmp(attributes[i].name, VR_N_INSUL_TYPE_AN) ) && 
	     ( me->Product == VR_PIPING ) )
	{
	    FIfld_set_text( me->form_ptr[1], INSUL_TYPE, 0, 0, 
			 attributes[i].desc.value.att_txt, FALSE);

	    // Update the insulation thickness. CR179901615 Alwin
	    __DBGpr_str( " Insulation Type ", attributes[i].desc.value.att_txt);

	    VRPGetInsulThkFromType( me->form_ptr[1], INSUL_THIK, 
			attributes[i].desc.value.att_txt );
	}

	if ( !strcmp( attributes[i].name, VR_N_PAINT_CODE_AN ))
	FIfld_set_text( me->form_ptr[1], PAINT_TYPE, 0, 0, 
				attributes[i].desc.value.att_txt, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_FLUID_CODE_AN ))
	FIfld_set_text( me->form_ptr[1],FLUID, 0, 0,
				attributes[i].desc.value.att_txt, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_WEIGHT_GRP_IN ))
	FIfld_set_text( me->form_ptr[1], WEIGHT_GRP, 0, 0, 
				 attributes[i].desc.value.att_txt, FALSE);

	if ( !strcmp( attributes[i].name, VR_N_CHG_REQ_NUM_IN))
	FIfld_set_text( me->form_ptr[1], CHANGE_NO, 0, 0, 
			attributes[i].desc.value.att_txt, FALSE);
	
	if ( !strcmp( attributes[i].name, VR_N_FLOW_RATE_DB))
	FIg_set_value( me->form_ptr[1], AIR_FLOW, 
			attributes[i].desc.value.att_exp);

	if ( !strcmp( attributes[i].name, VR_N_SIZE_METHOD_AN))
	FIg_set_text( me->form_ptr[1], SIZING_METHOD, 
			attributes[i].desc.value.att_txt);

	if ( !strcmp( attributes[i].name, VR_N_MAX_VELOC_DB))
	FIg_set_value( me->form_ptr[1], MAX_VELOCITY, 
			attributes[i].desc.value.att_exp);

	if ( !strcmp( attributes[i].name, VR_N_MAX_DEPTH_DB))
	FIg_set_value( me->form_ptr[1], MAX_DEPTH, 
			attributes[i].desc.value.att_exp);

	if (me->Product == VR_HVAC)
	{
           if ( !strcmp( attributes[i].name, VR_N_SHAPE_IN ))
           {
              FIg_unhilite( me->form_ptr[0], CIRCULAR );
              FIg_unhilite( me->form_ptr[0], RECTANGULAR );
              FIg_unhilite( me->form_ptr[0], OVAL );      
              FIg_enable( me->form_ptr[0], DEPTH );

              switch( (IGRlong) attributes[i].desc.value.att_exp )
              {
                   case VR_RECT :
                          FIg_hilite ( me->form_ptr[0], RECTANGULAR );
                          ShapeGadget = 0;
                          break;

                   case VR_OVAL :
                          FIg_hilite ( me->form_ptr[0], OVAL );
                          ShapeGadget = 1;
                          break;

                   case VR_CIRC :
                          FIg_hilite ( me->form_ptr[0], CIRCULAR );
                          FIg_disable( me->form_ptr[0], DEPTH );
                          ShapeGadget = 2;
                          break;

                   default :
                          /* Added for TR179702481 */
                          FIg_hilite ( me->form_ptr[0], RECTANGULAR );
                          ShapeGadget = 0;
                          break;

              }
              FIfld_set_text( me->form_ptr[0], NZTYPE, 0, 0,
                        Hv_Noz_macro[ShapeGadget].macro_name,FALSE);
           }

	   if ( !strcmp( attributes[i].name, VR_N_MACRO_NAME_AN ))
	   {
	     if( attributes[i].desc.value.att_txt[0] == '\0' ) 
		FIfld_set_text( me->form_ptr[0], NZTYPE, 0, 0, 
				DEFAULT_TYPE, FALSE);
	     else 	
		FIfld_set_text( me->form_ptr[0], NZTYPE, 0, 0, 
			attributes[i].desc.value.att_txt, FALSE);

	     status =
	     om$send( msg= message VRPlNozzle.VR_Assign_Shape( &msg ),
				      targetid = my_id );
	     as$status();
	   }

	   if ( !strcmp( attributes[i].name, VR_N_DUCT_MATERIAL_AN))
	   FIg_set_text( me->form_ptr[1], DUCT_MATERIAL, 
			   attributes[i].desc.value.att_txt);

	   if ( !strcmp( attributes[i].name, VR_N_DUCT_THICK_DB))
	   FIg_set_value( me->form_ptr[1], DUCT_THICK, 
			   attributes[i].desc.value.att_exp);

	   if ( !strcmp( attributes[i].name, VR_N_INSUL_TYPE_AN))
	   FIg_set_text( me->form_ptr[1], INSUL_MATERIAL, 
			   attributes[i].desc.value.att_txt);

	   if ( !strcmp( attributes[i].name, VR_N_INSUL_THK_DB))
	   FIg_set_value( me->form_ptr[1], HINSUL_THICK, 
			   attributes[i].desc.value.att_exp);

	   if ( !strcmp( attributes[i].name, VR_N_ACST_INSUL_TYPE_AN))
	   FIg_set_text( me->form_ptr[1], ACOUSTICAL_MATERIAL, 
			   attributes[i].desc.value.att_txt);

	   if ( !strcmp( attributes[i].name, VR_N_ACST_INSUL_THK_DB))
	   FIg_set_value( me->form_ptr[1], ACOUSTICAL_THICK, 
			   attributes[i].desc.value.att_exp);

	   if ( !strcmp( attributes[i].name, VR_N_ACST_DB))
	   FIg_set_value( me->form_ptr[1], ACST, 
			   attributes[i].desc.value.att_exp);
	} //HVAC loop ends
  }
  /* CR179528329      */
  if ( (VR_NOZZLE1_INIT == 1 || VR_NOZZLE1_INIT == 5) &&
		me->Product   == VR_PIPING ) { 
 	 FIfld_get_text( me->form_ptr[0], NZTYPE, 0, 0, 30, 
                             (unsigned char *) Name, &SelFlag, &r_pos );
         if( Name[0] == '\0') {
             FIfld_set_text( me->form_ptr[0], NOMINAL_SIZE, 0, 0,
                                "0.00000", FALSE);
             FIfld_set_text( me->form_ptr[0], END_COND, 0, 0,
                                "EMPTY", FALSE);
             FIfld_set_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0,
                                "EMPTY", FALSE);
             FIfld_set_text( me->form_ptr[0], END_STAND, 0, 0,
                                "EMPTY", FALSE);
	 }
  } 
  if( !me->ModifyCommand )
  {
	TempCollectId.osnum = me->ModuleInfo.md_id.osnum;
	VR$active_params( VRproduct      = me->Product,
        	          act_param_id   = &TempCollectId,
  	      		  status         = msg );

	/*| Before VRNozUpdateForm */
	VRNozUpdateForm( me->Product, me->form_ptr[1], &TempCollectId );
  }
  else
	VRNozUpdateForm( me->Product, me->form_ptr[1], &me->SysParamId );

  __DBGpr_com( " before me->ModifyCommand ");
  if( me->ModifyCommand && ( !(me->CompInstance.nStatus & VR_OUT_MACRO)) )
  {
      if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) 
      {
            FIfld_get_text( me->form_ptr[0], END_STAND, 0, 0, 20,
                  (unsigned char *)end_standard, &SelFlag, &r_pos );

            FIfld_get_text( me->form_ptr[0], END_COND, 0, 0, 9,
                  (unsigned char *)end_condition, &SelFlag, &r_pos );

            FIfld_get_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0, 9,
                  (unsigned char *)pressure_class, &SelFlag, &r_pos );


            FIfld_get_text(me->form_ptr[0], NOMINAL_SIZE, 0, 0, 9,
                   (unsigned char *)text, &SelFlag, &r_pos);

            nominal_size = atof(text);
            if( nominal_size != 0 &&
                 strcmp( end_condition, "EMPTY") &&
                 strcmp( pressure_class, "EMPTY")&&
                 strcmp( end_standard, "EMPTY") )
            {
                /* for NOMINAL_SIZE */
                 sprintf(Cnpdlist[0], "%lg", nominal_size);
                 FIfld_set_list_num_rows( me->form_ptr[0], NOMINAL_SIZE, 0,1);
                 VDfld_set_list_text( me->form_ptr[0], NOMINAL_SIZE, 0,
                        0, Cnpdlist[0], FALSE);

                 /* for END_STAND */
                 FIfld_set_list_num_rows( me->form_ptr[0],  END_STAND, 0, 1);
                 VDfld_set_list_text( me->form_ptr[0], END_STAND,
                                    0, 0, end_standard, FALSE);

                 /* for END_COND */
                 FIfld_set_list_num_rows( me->form_ptr[0],  END_COND, 0, 1);
                 VDfld_set_list_text( me->form_ptr[0], END_COND,
                                    0, 0, end_condition, FALSE);


                 /* for PRESSURE_CLASS */
                 FIfld_set_list_num_rows( me->form_ptr[0], PRESSURE_CLASS,0,1);
                 VDfld_set_list_text( me->form_ptr[0], PRESSURE_CLASS,
                                    0, 0, pressure_class, FALSE);
 
             }
      }
  }

  if( me->Product == VR_RWAY )
  {
    // Initialize the Nozzle Main Form
    status = om$send( msg = message VRPlNozzle.VRRwInitMainForm( &msg ),
			targetid = my_id );
    as$status();

    if( status & OM_E_ABORT )
    {
	// Mainly because Raceway Nozzle Table not found in DB
	//_put_response( resp = TERMINATE );
	UI_status( "Raceway Table not loaded !!!" );
	End
	return OM_E_ABORT;
    }

    // Initialize the Nozzle Attributes Form
    status = om$send( msg = message VRPlNozzle.VRRwInitAttrForm( &msg ),
			targetid = my_id );
    as$status();
  }

  if( me->UserParamId.objid != NULL_OBJID )
  {
	  /* ----- Update User Parameters form ----- */
	  status = VR$DispCollAttr( pForm   = me->FormUser,
					Gadget  = USER_ATTR_FLD,
					pCollId = &me->UserParamId );
	  as$status( action = RET_STATUS );
  }

  End
  return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRDisplayForm
{
   FIg_display( me->form_ptr[0], MISSING_GRP);
   return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VR_Assign_Shape
{
   IGRint not_found;
   IGRchar macro_name[20];
   IGRint Nb_shapes = 3;
   IGRint indx;
   IGRint                SelFlag, r_pos;

   FIfld_get_text( me->form_ptr[0], NZTYPE, 0, 0, 20,
                   (unsigned char *)macro_name, &SelFlag, &r_pos);
   not_found = 1;
   me->redefine_shape = 1;
/********** CR179901712 *** macroname drives the shapes here **************/
/******* put in conditional here for pid *********************************/
if( !me->PidRep )
{

   for(indx=0;indx<Nb_shapes && not_found;indx++)
   {
     if (!strcmp(macro_name,Hv_Noz_macro[indx].macro_name))
     {
       not_found = 0;
       FIg_unhilite( me->form_ptr[0], RECTANGULAR);
       FIg_unhilite( me->form_ptr[0], CIRCULAR);
       FIg_unhilite( me->form_ptr[0], OVAL);
       me->redefine_shape = 0;
       switch (indx)
       {
         case ONOZ1 :
           indx = 1;
         case VR_OVAL :
           FIg_hilite( me->form_ptr[0], OVAL);
           break;
         case CNOZ1 :
           indx = 2;
         case VR_CIRC :
           FIg_hilite( me->form_ptr[0], CIRCULAR);
           break;
         case RNOZ1 :
           indx = 0;
         case VR_RECT :
         default :
           FIg_hilite( me->form_ptr[0], RECTANGULAR);
           break;
       }
     }

     if(not_found)
     {
        FIg_set_text( me->form_ptr[0], FI_MSG_FIELD,
                        "SELECT SHAPE FOR NEW MACRO NAME");
     }
     else
     {
        FIg_set_text( me->form_ptr[0], FI_MSG_FIELD,
                        " ");
        /* Store the shape code in the instance and collection */
        ShapeGadget = indx;
        strcpy(Hv_Noz_macro[indx].macro_name,macro_name);
     }
   }
}
else /************ PID  mode *******/
{
   /******* CR179901712 need a PID trap here ****************/
   if (strcmp(macro_name,Hv_Noz_macro[0].macro_name))
   {
      for(indx=0;indx<Nb_shapes;indx++)
      {
        strcpy(Hv_Noz_macro[indx].macro_name,macro_name);
      }
   }
}

return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action VRChangeAttr
{
  IGRlong			msg;
  IGRint			i,NbCollect, Type,NbOldUser;
  struct	ACrg_coll	Collection[VR_MAX_ATTR], User[VR_MAX_ATTR], Missing[VR_MAX_ATTR];
        /* law 04/02/98 */
  IGRchar			text[80], Stext[80], Gtext[13],endtext[20],
				ExpName[80],*ValueEnd;
  IGRchar			Name[VR_MAX_CHAR], Value[VR_MAX_CHAR];
  IGRint			SelFlag, r_pos, row, num_rows;
  IGRint			length0,length1, length2;
  IGRdouble			value,dValue;
  IGRshort			retval;
  struct 	GRid		TempMissingId, ActSysId, ActSysIdNew;
  IGRboolean			Change = FALSE;

  SetProc( VRChangeAttr ); Begin
  me->ret = OM_S_SUCCESS;

  TempMissingId.objid = NULL_OBJID;

  /*"Init = %d\n",me->Init*/
  if ( !me->SystemChange && !me->UserChange && !me->MissingChange )
  {
	if( !me->Init)
	{
  		status = om$send( msg      = message VRPlNozzle.VREvaluateNozzle( &msg ),
                    	  	  targetid = my_id );
  		as$status();
		me->ret = NO_CHANGE;
        	return OM_S_SUCCESS;
	}
	else
	{
		/*| We must initialize the whole nozzle's collection */
		me->SystemChange = TRUE;
		me->UserChange   = TRUE;
		me->Init 	 = FALSE;
	}
  }
  else
  {
	if ( me->Init)
	{
		/*| We must initialize the whole nozzle's collection */
		me->SystemChange = TRUE;
		me->UserChange   = TRUE;
		me->Init 	 = FALSE;
	}
  }

  /* ---------------------------------- */
  /* ----- Modify User Collection ----- */
  /* ---------------------------------- */

  if ( me->UserChange )
  {
  	/*| ----- Modify User Collection ----- */
	FIfld_get_num_rows( me->FormUser, USER_ATTR_FLD, &num_rows );
  	/*" got %d rows\n", num_rows */
  	for ( row=0; row<num_rows; row++ )
  	{
  		length0 = 0;
		length1 = 0;
        	FIfld_get_text_length( me->FormUser, USER_ATTR_FLD, row, 
								0, &length0 );
        	FIfld_get_text_length( me->FormUser, USER_ATTR_FLD, row, 
								1, &length1 );
        	if( length1 < 2 ) length1 = 10;
		if ( length0 >1 )
        	{
			struct ACrg_coll coll;
        		FIfld_get_text( me->FormUser, USER_ATTR_FLD, row, 
					0, length0, (unsigned char *) Name, 
					&SelFlag, &r_pos );
			FIfld_get_text( me->FormUser, USER_ATTR_FLD, row, 
					1, length1, (unsigned char *) Value, 
					&SelFlag, &r_pos);
			/* The value needs to be stored either as a double or as
			   a text */

			strcpy( User[row].name, Name);	

       			strcpy( coll.name, Name );

       			status =
          		om$send( msg = message ACrg_collect.ACget_named_attribute
                                            ( &msg, &coll ),
                              targetid = me->UserParamId.objid,
                              targetos = me->UserParamId.osnum );
      
       			if( ! (status & msg) )
// Both should be checked. Status alone not enough. - Anand for TR179800533 */
       			{
         			dValue = strtod ( Value, &ValueEnd );
         			if (strlen (ValueEnd) != 0)
         			{
               			  User[row].desc.type = AC_ATTRIB_TEXT;
               			  strcpy( User[row].desc.value.att_txt, Value);
         			}
         			else
         			{
               			  User[row].desc.type = AC_ATTRIB_DOUBLE;
               			  User[row].desc.value.att_exp = dValue;
         			}
       			}
       			else
       			{
          			User[row].desc.type = coll.desc.type;
          			if ( User[row].desc.type == AC_ATTRIB_TEXT )
               			  strcpy( User[row].desc.value.att_txt, Value);
          			else
          			{
               			  dValue = strtod ( Value, &ValueEnd );
               			  User[row].desc.value.att_exp = dValue;
          			}
       			}
		}
		else
		num_rows = row;
   	}

	if(  me->UserParamId.objid != NULL_OBJID )
	{
		status = om$send( msg = message ACrg_collect.AClist_attribute
			( &msg, VR_MAX_ATTR, NULL, &NbOldUser ),
                    	  	senderid = me->UserParamId.objid,
                    	  	targetid = me->UserParamId.objid,
                    	  	targetos = me->UserParamId.osnum) ;
  		as$status( action = RET_STATUS ) ;
  		as$status( action = RET_STATUS, sts = msg ) ;
		
		if ( num_rows < NbOldUser )
		{
			/*| Less User Attr than before */
			me->UserParamId.objid = NULL_OBJID;
		}
	}

  	status = VR$ModifyCollection( 	p_msg                   = &msg,
                                	Operation               = VR_MERGE_COLL,
					p_ParamsListToModify    = User,
         				NbParamsToModify        = num_rows,
                                	p_OutputCollectionId    = &me->UserParamId );
  	as$status();
  	as$status( sts = msg );

  	VRprint_user_attr( &me->UserParamId );
	me->ret = VRUSERPARAM;
	me->UserChange = FALSE;
  }

  /* ------------------------------------- */
  /* ----- Modify Missing Collection ----- */
  /* ------------------------------------- */

  if ( me->MissingChange )
  {
	/*| ----- Modify Missing Collection ----- */
	FIfld_get_num_rows( me->form_ptr[0], MISSING, &num_rows );
  	/*" got %d rows\n", num_rows */
	value = 0;
	ExpName[0] = '\0';
	Value[0]   = '\0';
	for ( i=0; i<num_rows; i++ )
	{
		me->MissExp[i].objid = NULL_OBJID;
		me->MissExp[i].osnum = me->ModuleInfo.md_id.osnum;
	}
  	for ( row=0; row<num_rows; row++ )
  	{
  		length0 = 0;
		length1 = 0;
		length2 = 0;
        	FIfld_get_text_length( me->form_ptr[0], MISSING, row, 
								0, &length0 );
        	FIfld_get_text_length( me->form_ptr[0], MISSING, row, 
								1, &length1 );
        	FIfld_get_text_length( me->form_ptr[0], MISSING, row, 
								2, &length2 );
		/*"length0 = %d length1 = %d length2 = %d\n", length0,length1,length2 */
        	if( length1 < 2 ) length1 = 10;
		if ( length0 >1 )
        	{
        		FIfld_get_text( me->form_ptr[0], MISSING, row, 
					0, length0, (unsigned char *) Name, 
					&SelFlag, &r_pos );
			strcpy( Missing[row].name, Name);
			FIfld_get_text( me->form_ptr[0], MISSING, row, 
					2, length2, (unsigned char *) ExpName, 
					&SelFlag, &r_pos );

			FIfld_get_type( me->form_ptr[0], MISSING, 1, &Type );
			if ( Type == AC_ATTRIB_TEXT )
/*
			if( length2 > 1 )
*/
			{
				Missing[row].desc.type = AC_ATTRIB_TEXT;
				FIfld_get_text( me->form_ptr[0], MISSING, row, 
						1, length1, 	
						(unsigned char *) Value, 
						&SelFlag, &r_pos);

				/* if the expression exist so we return its
				/* value
				/**/
				if( !me->PidRep )
				{
					VRBuildExp( &msg, ( IGRchar )EXP_TEXT, 
						    ExpName, Value, NULL, 
						    &me->MissExp[row],
						    &me->ModuleInfo );
				}
				if( msg == MSFAIL )
				{
				  IGRchar text[100];

				strcpy( text, "Expression already exists !!" );
				FIg_set_text( me->form_ptr[0], FI_MSG_FIELD, 
									text );
				UI_status( text );
     				FIfld_set_text(  me->form_ptr[0], MISSING, row, 1, Value, FALSE );
				}

 				strcpy( Missing[row].desc.value.att_txt, Value );
			}
			else
			{
				Missing[row].desc.type = AC_ATTRIB_DOUBLE;
				FIfld_get_value(me->form_ptr[0], MISSING, row, 1,&value, &SelFlag, &r_pos);

				/* if the expression exist so we return its
				/* value
				/**/
				if( !me->PidRep )
				{
					VRBuildExp( &msg,( IGRchar )EXP_DOUBLE,ExpName, 
					    	    NULL, &value, &me->MissExp[row],
					    	    &me->ModuleInfo );

				}
				if( msg == MSFAIL )
				{
				  IGRchar text[100];

				strcpy( text, "Expression already exists !!" );
				FIg_set_text( me->form_ptr[0], FI_MSG_FIELD, 
									text );
				UI_status( text );
				FIfld_set_value(  me->form_ptr[0], MISSING, row, 1, value, FALSE );
				}

				Missing[row].desc.value.att_exp = value;
			}
		}
		else
		num_rows = row;
   	}
	
  	status = VR$ModifyCollection( 	p_msg                   = &msg,
                                	Operation               = VR_MERGE_COLL,
					p_ParamsListToModify    = Missing,
         				NbParamsToModify        = num_rows,
                                	p_OutputCollectionId    = &me->MissingParamsId );
  	as$status();
  	as$status( sts = msg );

	/*| -- Place collection to give expressions as parents -- */
 	{
		IGRlong			lConstructionListMsg;
  		struct GRvg_construct 	ConstructionList;
		struct 	GRas	   	assoc_list;
		struct 	ACcol_info  	SysParamFunc;

		ConstructionList.msg		= &lConstructionListMsg;
  		ConstructionList.env_info	= (struct GRmd_env *) &me->ModuleInfo;
  		ConstructionList.newflag	= FALSE;
  		ConstructionList.level		= me->ActiveLevel;
  		ConstructionList.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  		ConstructionList.geometry	= 0;
  		ConstructionList.display	= &me->ActiveDisplay;
  		ConstructionList.class_attr	= NULL;
  		ConstructionList.name		= 0;

		SysParamFunc.pl_fct_name[0] = '\0';
		strcpy( SysParamFunc.cp_fct_name, "VRGenericLink" );

		assoc_list.as_attr        = ( IGRchar *) &SysParamFunc;
		assoc_list.num_parents    = num_rows;
		assoc_list.go_objid.objid = NULL_OBJID;
		assoc_list.parents        = me->MissExp;


 		status =  NDduplicate_root(num_rows,me->MissExp);
 		as$status(action = RET_STATUS);

		/*| -- Place missing collection -- */
		status = 
		om$send( msg	   = message NDnode.NDplace( &assoc_list, 
						     &me->ModuleInfo, 
				       ( IGRchar * ) &ConstructionList),
		 	 senderid = NULL_OBJID,
		 	 targetid = me->MissingParamsId.objid,
		 	 targetos = me->MissingParamsId.osnum ) ;
		as$status ();
  	}


  	/*^ VRprint_user_attr( &me->MissingParamsId );*/

	me->ret 	  = VRUSERPARAM;
	me->MissingChange = FALSE;
  }

  /* ------------------------------------ */
  /* ----- Modify System Collection ----- */
  /* ------------------------------------ */
  if ( me->SystemChange )
  {
  	/*| ----- Modify System Collection ----- */

	__DBGpr_com( " Modify System Collection " );
  	if( ! me->ModifyCommand ) me->CompInstance.nStatus = VR_OUT_MACRO;

	FIfld_get_text( me->form_ptr[0], TAG_NUMBER, 0, 0, 12, 
			(unsigned char *) text, &SelFlag, &r_pos );
	strcpy( Collection[0].name, VR_N_TAG_NUMBER_AN );
	Collection[0].desc.type = AC_ATTRIB_TEXT;
	strcpy( Collection[0].desc.value.att_txt, text );

	strcpy( me->CompInstance.szNumber,text); 

	if( me->Product == VR_PIPING )
	{
		NbCollect = 31;
	
		FIfld_get_text( me->form_ptr[0], NZSERVICE, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
		strcpy( Collection[1].name, VR_N_SERVICE_AN );
		Collection[1].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[1].desc.value.att_txt, text );

		FIfld_get_text( me->form_ptr[0], NOMINAL_SIZE, 0, 0, 9,
			     (unsigned char *) text, &SelFlag, &r_pos);
		strcpy( Collection[2].name, VR_N_GDIAMETER_DB );
		Collection[2].desc.type = AC_ATTRIB_DOUBLE;
		Collection[2].desc.value.att_exp = atof(text);

		FIfld_get_text( me->form_ptr[0], END_COND, 0, 0, 9, 
			(unsigned char *) text, &SelFlag, &r_pos );
		strcpy( Collection[3].name, VR_N_PREPS_G_IN);
		Collection[3].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[3].desc.value.att_txt, text );
	 
		FIfld_get_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0,9,
			 (unsigned char *) text, &SelFlag, &r_pos );
		strcpy( Collection[4].name, VR_N_RATINGS_G_DB);
		Collection[4].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[4].desc.value.att_txt, text );

		FIfld_get_text( me->form_ptr[0], SCHDL_THK, 0, 0, 9, 
			(unsigned char *) text, &SelFlag, &r_pos );
		strcpy( Collection[5].name, VR_N_SCH_THK_G_AN);
		Collection[5].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[5].desc.value.att_txt, text );

		FIfld_get_text( me->form_ptr[0], END_STAND, 0, 0, 20, 
			(unsigned char *) endtext, &SelFlag, &r_pos );
		strcpy( Collection[6].name, VR_N_END_STD_G_IN);
		Collection[6].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[6].desc.value.att_txt, endtext );

		// insulation type can be of 8 characters length
  		FIfld_get_text( me->form_ptr[1], INSUL_TYPE, 0, 0, 9, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
  		strcpy( Collection[7].name, VR_N_INSUL_TYPE_AN);
  		Collection[7].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[7].desc.value.att_txt, Stext );  

  		FIfld_get_text( me->form_ptr[1], TRACING_TYPE, 0, 0, 5, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
  		strcpy( Collection[8].name, VR_N_TRACING_CODE_AN);
  		Collection[8].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[8].desc.value.att_txt, Stext );  

		FIfld_get_text( me->form_ptr[0], APPRV_STS, 0, 0, 5, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
	 	strcpy( Collection[9].name, VR_N_APPRV_STAT_AN);
	  	Collection[9].desc.type = AC_ATTRIB_TEXT;
	  	strcpy( Collection[9].desc.value.att_txt, Stext );

	  	FIfld_get_text( me->form_ptr[0], CONST_STS, 0, 0, 5, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
	  	strcpy( Collection[10].name, VR_N_CONSTR_STAT_AN);
	  	Collection[10].desc.type = AC_ATTRIB_TEXT;
	  	strcpy( Collection[10].desc.value.att_txt, Stext );

  		FIfld_get_text( me->form_ptr[0], NOMINAL_SIZE, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
  		strcpy( Collection[11].name, VR_N_RDIAMETER_DB );
  		Collection[11].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[11].desc.value.att_exp = atof(text);

  		FIfld_get_text( me->form_ptr[1], FLUID, 0, 0, 5, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
  		strcpy( Collection[12].name, VR_N_FLUID_CODE_AN);
  		Collection[12].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[12].desc.value.att_txt, Stext );

/* Going to set Collection[13] */
		if( !(me->CompInstance.nStatus & VR_OUT_MACRO) && !me->PidRep )
		{
			FIfld_get_text( me->form_ptr[0], EXP_END_COND, 0, 0, 9,
				(unsigned char *) text, &SelFlag, &r_pos );

/* Added by Anand for TR 179603675 */

/* For the case of a nozzle that lives in a placed macro, the code tries   */
/* to read the input for to the end condition from the EXP_END_COND field  */
/* If the user does not have an associative expression to enter, the string*/
/* corresponding to the input for end condition gets set to NULL.	   */

			if( text[0] == '\0' )
			{

/* If that happens, read the nozzle's end condition from the END_COND field.*/

				FIfld_get_text( me->form_ptr[0], END_COND, 0,
						0, 9, (unsigned char *) text,
						&SelFlag, &r_pos );
			}
		}
		else
			FIfld_get_text( me->form_ptr[0], END_COND, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );

		__DBGpr_str(" End condition",text);
  		strcpy( Collection[13].name, VR_N_PREP_G_IN);
  		Collection[13].desc.type = AC_ATTRIB_DOUBLE;

		__DBGpr_com(" Before resetting me->NPrepString,me->NPrepShort");
		for( i=0 ; i < me->Size ; i=i+1)
		{
		  __DBGpr_str(" me->NPrepString",&me->NPrepString[i]);
		  __DBGpr_int(" me->NPrepShort ",me->NPrepShort[i]);
		}

		/* -- Get End Condition List and re-initialize me pointer -- */
		status = VRget_code_list_set ( &msg, me->Product,
				 VR_P_END_COND_LSTNUM, (IGRshort *)&me->Size ,
				 &me->NPrepString, &me->NPrepShort, NULL);

		VRGetEquiShort( me->NPrepString, me->NPrepShort, me->Size,
							text, &retval ); 	

		__DBGpr_com(" After resetting me->NPrepString,me->NPrepShort");
		for( i=0 ; i < me->Size ; i=i+1)
		{
		  __DBGpr_str(" me->NPrepString",&me->NPrepString[i]);
		  __DBGpr_int(" me->NPrepShort ",me->NPrepShort[i]);
		}

		value = (IGRdouble) retval;
  		Collection[13].desc.value.att_exp = value;

  		FIfld_get_text( me->form_ptr[1], SPEC_NAME, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
  		strcpy( Collection[14].name, VR_N_CLASS_AN);
  		Collection[14].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[14].desc.value.att_txt, text );

  		FIfld_get_text( me->form_ptr[1], PAINT_TYPE, 0, 0, 5, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
  		strcpy( Collection[15].name, VR_N_PAINT_CODE_AN);
  		Collection[15].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[15].desc.value.att_txt, Stext ); 

  		FIfld_get_text( me->form_ptr[1], WEIGHT_GRP, 0, 0, 13, 
				(unsigned char *) Gtext, &SelFlag, &r_pos );
  		strcpy( Collection[16].name, VR_N_WEIGHT_GRP_IN);
  		Collection[16].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[16].desc.value.att_txt, Gtext ); 

  		FIfld_get_text( me->form_ptr[1], CHANGE_NO, 0, 0, 13, 
				(unsigned char *) Gtext, &SelFlag, &r_pos );
  		strcpy( Collection[17].name, VR_N_CHG_REQ_NUM_IN);
  		Collection[17].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[17].desc.value.att_txt, Gtext ); 

  		FIfld_get_text( me->form_ptr[1], SEQ_NUMBER, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
  		strcpy( Collection[18].name, VR_N_SEQ_NUMBER_AN);
  		Collection[18].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[18].desc.value.att_txt, text );

  		FIfld_get_text( me->form_ptr[1], ZONE_NB, 0, 0, 5, 
				(unsigned char *) Stext, &SelFlag, &r_pos );
  		strcpy( Collection[19].name, VR_N_ZONE_AN);
  		Collection[19].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[19].desc.value.att_txt, Stext );

  		FIfld_get_text( me->form_ptr[1], SCHDL_THK_OVRD, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
  		strcpy( Collection[20].name, VR_N_THICK_OVER_AN);
  		Collection[20].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[20].desc.value.att_txt, text );

		text[0] = '\0';
  		FIg_get_text( me->form_ptr[1], INSUL_THIK, text );
		value = atof( text );
  		strcpy( Collection[21].name, VR_N_INSUL_THK_DB);
  		Collection[21].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[21].desc.value.att_exp = value ;

  		FIfld_get_value( me->form_ptr[1], OPER_TEMP, 0, 0, &value, &SelFlag, &r_pos );
  		strcpy( Collection[22].name, VR_N_OPER_TEMP_DB);
  		Collection[22].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[22].desc.value.att_exp = value;

  		FIfld_get_value( me->form_ptr[1], OPER_PRESSURE, 0, 0, &value, &SelFlag, &r_pos );
  		strcpy( Collection[23].name, VR_N_OPER_PRESS_DB);
  		Collection[23].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[23].desc.value.att_exp = value;

  		FIfld_get_value( me->form_ptr[1], DGN_TEMP, 0, 0, &value, &SelFlag, &r_pos );
  		strcpy( Collection[24].name, VR_N_DGN_TEMP_DB);
  		Collection[24].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[24].desc.value.att_exp = value;

  		FIfld_get_value( me->form_ptr[1], DGN_PRESS, 0, 0, &value, &SelFlag, &r_pos );
  		strcpy( Collection[25].name, VR_N_DGN_PRESS_DB);
  		Collection[25].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[25].desc.value.att_exp = value;

  		FIfld_get_value( me->form_ptr[1], SPECIFIC_GRAV, 0, 0, &value, &SelFlag, &r_pos );
  		strcpy( Collection[26].name, VR_N_SPEC_GRAV_DB);
  		Collection[26].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[26].desc.value.att_exp = value;

		FIfld_get_text( me->form_ptr[0], NZTYPE, 0, 0, 12, 
				(unsigned char *) text, &SelFlag, &r_pos );
                strcpy( Collection[27].name, VR_N_MACRO_NAME_AN);
                Collection[27].desc.type = AC_ATTRIB_TEXT;
                strcpy( Collection[27].desc.value.att_txt, text );
                /*"macro name = %s\n", Collection[27].desc.value.att_txt */

  		FIfld_get_text( me->form_ptr[1], SYSTEM_NAME, 0, 0, 13, 
				(unsigned char *) Gtext, &SelFlag, &r_pos );
  		strcpy( Collection[28].name, VR_N_SYST_NAME_AN);
  		Collection[28].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[28].desc.value.att_txt, Gtext );

		{
		  IGRshort	nNbPressureClass = 0;

		  FIfld_get_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0, 9, 
				  (unsigned char *) text, &SelFlag, &r_pos );
		  strcpy( Collection[29].name, VR_N_RATING_G_DB);
		  Collection[29].desc.type = AC_ATTRIB_DOUBLE;

		  /*| -- Get Pressure Class List and initialize form -- */
		  status = VRget_code_list_set ( &msg, me->Product,
				   VR_P_PRES_CLASS_LSTNUM, &nNbPressureClass,
				   &me->PressString, &me->PressShort, NULL);

		  VRGetEquiShort( me->PressString, me->PressShort, 
					    nNbPressureClass, text, &retval ); 	

		  __DBGpr_com(" After resetting  me->PressString,me->PressShort");
		  for( i=0 ; i < nNbPressureClass ; i=i+1)
		  {
		    __DBGpr_str(" me->PressString",&me->PressString[i]);
		    __DBGpr_int(" me->PressShort ",me->PressShort[i]);
		  }

		  value = (IGRdouble) retval;
		  Collection[29].desc.value.att_exp = value;
		}

		// CR179901873
		text[0] = '\0';
  		FIg_get_text( me->form_ptr[1], NOZ_UNIT_NUMBER, text );
  		strcpy( Collection[30].name, VR_N_UNIT_AN);
  		Collection[30].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[30].desc.value.att_txt, text );

		if ( me->PidRep )  /* added to get PID scale */
		{
			FIfld_get_value( me->form_ptr[0], NOZ_PID_SCALE, 0, 0, &value, &SelFlag, &r_pos );
			if (value == NULL) value = 1;
  			strcpy( Collection[NbCollect].name, VR_N_PID_SCALE_DB );
  			Collection[NbCollect].desc.type = AC_ATTRIB_DOUBLE;
  			Collection[NbCollect].desc.value.att_exp = value;
			NbCollect++;
		}
	}
	else if( me->Product == VR_HVAC )
	{
		IGRdouble 	therm_insul_thk=0.0, acst_insul_thk=0.0;
		struct ACrg_coll ListAttr;

                NbCollect = 26;

		FIfld_get_text( me->form_ptr[0], NZSERVICE, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
		strcpy( Collection[1].name, VR_N_SERVICE_AN );
		Collection[1].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[1].desc.value.att_txt, text );

		FIg_get_value( me->form_ptr[0], WIDTH, &value );
		strcpy( Collection[2].name, VR_N_WIDTH1_DB);
		strcpy( Collection[4].name, VR_N_WIDTH2_DB);
		Collection[2].desc.type = AC_ATTRIB_DOUBLE;
		Collection[4].desc.type = AC_ATTRIB_DOUBLE;
		Collection[2].desc.value.att_exp = value;
		Collection[4].desc.value.att_exp = value;

		FIg_get_value( me->form_ptr[0], DEPTH, &value );
		strcpy( Collection[3].name, VR_N_DEPTH1_DB);
		strcpy( Collection[5].name, VR_N_DEPTH2_DB);
		Collection[3].desc.type = AC_ATTRIB_DOUBLE;
		Collection[5].desc.type = AC_ATTRIB_DOUBLE;
		Collection[3].desc.value.att_exp = value;
		Collection[5].desc.value.att_exp = value;

		FIg_get_value( me->form_ptr[0], NOZZLE_AIRFLOW, &value );
		strcpy( Collection[6].name, VR_N_FLOW_RATE_DB);
		Collection[6].desc.type = AC_ATTRIB_DOUBLE;
		Collection[6].desc.value.att_exp = value;

		FIfld_get_text( me->form_ptr[0], END_PREP, 0, 0, 9, 
			(unsigned char *) text, &SelFlag, &r_pos );
		strcpy( Collection[7].name, VR_N_PREP_G_IN);
		strcpy( Collection[8].name, VR_N_PREPS_G_IN);  
		Collection[7].desc.type = AC_ATTRIB_DOUBLE;
		Collection[8].desc.type = AC_ATTRIB_TEXT;
		VRGetEquiShort( me->NPrepString, me->NPrepShort, 
					me->Size, text, &retval ); 	
		value = (IGRdouble) retval;
		Collection[7].desc.value.att_exp = value;
		strcpy( Collection[8].desc.value.att_txt, text);

  		FIg_get_text( me->form_ptr[1], SPEC_NAME, text );
  		strcpy( Collection[9].name, VR_N_CLASS_AN);
  		Collection[9].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[9].desc.value.att_txt, text);
		
		FIg_get_text( me->form_ptr[1], HPRESSURE_CLASS, text );
  		strcpy( Collection[10].name, VR_N_PRESS_CLASS_AN);
  		Collection[10].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[10].desc.value.att_txt, text);

		FIg_get_text( me->form_ptr[1], SIZING_METHOD, text );
  		strcpy( Collection[11].name, VR_N_SIZE_METHOD_AN );
  		Collection[11].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[11].desc.value.att_txt, text);

		FIg_get_value( me->form_ptr[1], AIR_FLOW, &value );
  		strcpy( Collection[12].name, VR_N_FLOW_RATE_DB );
  		Collection[12].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[12].desc.value.att_exp = value;

		FIg_get_value( me->form_ptr[1], MAX_VELOCITY, &value );
  		strcpy( Collection[13].name, VR_N_MAX_VELOC_DB );
  		Collection[13].desc.type = AC_ATTRIB_DOUBLE;
		Collection[13].desc.value.att_exp = value;
	
		FIg_get_value( me->form_ptr[1], MAX_DEPTH, &value );
  		strcpy( Collection[14].name, VR_N_MAX_DEPTH_DB );
  		Collection[14].desc.type = AC_ATTRIB_DOUBLE;
		Collection[14].desc.value.att_exp = value;

		FIg_get_text( me->form_ptr[1], DUCT_MATERIAL, text );
  		strcpy( Collection[15].name, VR_N_DUCT_MATERIAL_AN );
  		Collection[15].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[15].desc.value.att_txt, text);

		FIg_get_value( me->form_ptr[1], DUCT_THICK, &value );
  		strcpy( Collection[16].name, VR_N_DUCT_THICK_DB );
  		Collection[16].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[16].desc.value.att_exp = value;

		FIg_get_text( me->form_ptr[1], INSUL_MATERIAL, text );
  		strcpy( Collection[17].name, VR_N_INSUL_TYPE_AN );
  		Collection[17].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[17].desc.value.att_txt, text);

		FIg_get_value(me->form_ptr[1], HINSUL_THICK, &therm_insul_thk );
  		strcpy( Collection[18].name, VR_N_INSUL_THK_DB );
  		Collection[18].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[18].desc.value.att_exp = therm_insul_thk;

		FIg_get_text( me->form_ptr[1], ZONE, text );
  		strcpy( Collection[19].name, VR_N_ZONE_AN );
  		Collection[19].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[19].desc.value.att_txt, text);

		FIfld_get_text( me->form_ptr[0], NZTYPE, 0, 0, 12, 
				(unsigned char *) text, &SelFlag, &r_pos );
                strcpy( Collection[20].name, VR_N_MACRO_NAME_AN);
		Collection[20].desc.type = AC_ATTRIB_TEXT;
		strcpy( Collection[20].desc.value.att_txt, text );
                /*"macro name = %s\n", Collection[20].desc.value.att_txt */

		strcpy( Collection[21].name, VR_N_SHAPE_IN);
		Collection[21].desc.type = AC_ATTRIB_DOUBLE;
		{
		    struct ACrg_coll ShapeCode;

		    strcpy( ShapeCode.name, VR_N_SHAPE_IN);

		    /* get current SHAPE CODE */
		    status = 
		    om$send( msg = message ACrg_collect.ACget_named_attribute
					    ( &msg, &ShapeCode ),
				       senderid = NULL_OBJID,
				       targetid = me->SysParamId.objid,
				       targetos = me->SysParamId.osnum);

		    Collection[21].desc.value.att_exp = 
						ShapeCode.desc.value.att_exp;
		}

		// adding the Acoustic Insulation Material and Thickness to the
		// collector list. CR179901312 Alwin

		FIg_get_text( me->form_ptr[1], ACOUSTICAL_MATERIAL, text );
  		strcpy( Collection[22].name, VR_N_ACST_INSUL_TYPE_AN );
  		Collection[22].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[22].desc.value.att_txt, text);

		FIg_get_value(me->form_ptr[1],ACOUSTICAL_THICK,&acst_insul_thk);
  		strcpy( Collection[23].name, VR_N_ACST_INSUL_THK_DB );
  		Collection[23].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[23].desc.value.att_exp = acst_insul_thk;

		/*
		 * Add the "acst" parameter to the System parameters Collection,
		 * to hide to prevent user modifying the value.
		 * Remove the "acst" defined in the User Parameters collection.
		 * Alwin for CR179901661
		 */

		if( acst_insul_thk > 0.0 )
		   acst_insul_thk = therm_insul_thk + acst_insul_thk;

		strcpy( Collection[24].name, VR_N_ACST_DB );
  		Collection[24].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[24].desc.value.att_exp = acst_insul_thk;

		status = VR$ModifyCollection(
				p_msg                   = &msg,
                               	Operation               = VR_SUBSTR_COLL,
				p_ParamsListToModify    = &Collection[24],
       				NbParamsToModify        = 1,
                               	p_OutputCollectionId    = &me->UserParamId );

		text[0] = '\0';
  		FIg_get_text( me->form_ptr[1], NOZ_UNIT_NUMBER, text );
  		strcpy( Collection[25].name, VR_N_UNIT_AN);
  		Collection[25].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[25].desc.value.att_txt, text );

		if ( me->PidRep )  /* added to get PID scale */
		{
			FIg_get_value( me->form_ptr[0], NOZ_PID_SCALE,&value);
			if (value == NULL) value = 1;
  			strcpy( Collection[NbCollect].name, VR_N_PID_SCALE_DB );
  			Collection[NbCollect].desc.type = AC_ATTRIB_DOUBLE;
  			Collection[NbCollect].desc.value.att_exp = value;
			NbCollect++;
		}
	}
	else if( me->Product == VR_RWAY )
	{
	    IGRshort	nShape=-1;

	    // Retrieve the attributes information Raceway form and set it to
	    // System collector
		NbCollect = 17;

		FIg_get_text( me->form_ptr[0], RWAY_NOZ_WIDTH, text );
		__DBGpr_str( " Width Text ", text );
		value = atof( text );
		strcpy( Collection[1].name, VR_N_WIDTH1_DB);
		Collection[1].desc.type = AC_ATTRIB_DOUBLE;
		Collection[1].desc.value.att_exp = value;

		strcpy( Collection[2].name, VR_N_WIDTH2_DB);
		Collection[2].desc.type = AC_ATTRIB_DOUBLE;
		Collection[2].desc.value.att_exp = value;

		FIg_get_text( me->form_ptr[0], RWAY_NOZ_DEPTH, text );
		__DBGpr_str( " Depth Text ", text );
		value = atof( text );
		strcpy( Collection[3].name, VR_N_DEPTH1_DB);
		Collection[3].desc.type = AC_ATTRIB_DOUBLE;
		Collection[3].desc.value.att_exp = value;

		strcpy( Collection[4].name, VR_N_DEPTH2_DB);
		Collection[4].desc.type = AC_ATTRIB_DOUBLE;
		Collection[4].desc.value.att_exp = value;

  		FIg_get_text( me->form_ptr[0], RWAY_NOZ_SHAPE, text );

                if(     !strcmp( text, "Rectangular"))nShape = 0;
                else if(!strcmp( text, "Oval" ) )     nShape = 1;
                else if(!strcmp( text, "Circular" ) ) nShape = 2;
		else if(!strcmp( text, "Corner Radius" ) ) nShape = 3;
		else nShape = 4; //Ellipse

		strcpy( Collection[5].name, VR_N_SHAPE_IN);
		Collection[5].desc.type = AC_ATTRIB_DOUBLE;
		Collection[5].desc.value.att_exp = (IGRdouble) nShape;

  		FIg_get_text( me->form_ptr[0], SPEC_NAME, text );
  		strcpy( Collection[6].name, VR_N_CLASS_AN);
  		Collection[6].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[6].desc.value.att_txt, text);
		
		FIg_get_text( me->form_ptr[1], RWAY_NOZ_TRAY_MATERIAL, text );
  		strcpy( Collection[7].name, VR_N_DUCT_MATERIAL_AN );
  		Collection[7].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[7].desc.value.att_txt, text);

		FIg_get_value( me->form_ptr[1], RWAY_NOZ_TRAY_THICK, &value );
  		strcpy( Collection[8].name, VR_N_DUCT_THICK_DB );
  		Collection[8].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[8].desc.value.att_exp = value;

		FIg_get_value( me->form_ptr[1], RWAY_NOZ_THROAT_RAD, &value );
  		strcpy( Collection[9].name, VR_N_THROAT_DB );
  		Collection[9].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[9].desc.value.att_exp = value;

		FIg_get_value( me->form_ptr[1], RWAY_NOZ_TRANS_LEN, &value );
  		strcpy( Collection[10].name, VR_N_TRANS_L_DB );
  		Collection[10].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[10].desc.value.att_exp = value;

		FIg_get_value( me->form_ptr[1], RWAY_NOZ_CORN_RAD, &value );
  		strcpy( Collection[11].name, VR_N_CORN_RAD_DB );
  		Collection[11].desc.type = AC_ATTRIB_DOUBLE;
  		Collection[11].desc.value.att_exp = value;

		FIg_get_text( me->form_ptr[0], APPRV_STS, text );
  		strcpy( Collection[12].name, VR_N_APPRV_STAT_AN );
  		Collection[12].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[12].desc.value.att_txt, text);

		FIg_get_text( me->form_ptr[0], CONST_STS, text );
  		strcpy( Collection[13].name, VR_N_CONSTR_STAT_AN );
  		Collection[13].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[13].desc.value.att_txt, text);

		FIg_get_text( me->form_ptr[1], SYSTEM_NAME, text );
  		strcpy( Collection[14].name, VR_N_SYST_NAME_AN );
  		Collection[14].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[14].desc.value.att_txt, text);

		FIg_get_text( me->form_ptr[1], RWAY_NOZ_UNIT, text );
  		strcpy( Collection[15].name, VR_N_UNIT_AN );
  		Collection[15].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[15].desc.value.att_txt, text);

		FIg_get_text( me->form_ptr[1], RWAY_NOZ_ZONE, text );
  		strcpy( Collection[16].name, VR_N_ZONE_AN );
  		Collection[16].desc.type = AC_ATTRIB_TEXT;
  		strcpy( Collection[16].desc.value.att_txt, text);
	}

	__DBGpr_obj(" SysParamId", me->SysParamId );
	__DBGpr_int(" NbCollect ", NbCollect);
	for( i=0 ; i < NbCollect ; i=i+1 )
	{
	  __DBGpr_int(" index",i);
	  __DBGpr_str(" Collection name",Collection[i].name);
	  if( Collection[i].desc.type == AC_ATTRIB_TEXT )
	     __DBGpr_str(" Collector string", Collection[i].desc.value.att_txt);

	  if( Collection[i].desc.type == AC_ATTRIB_DOUBLE )
	     __DBGpr_dbl(" Collector value", Collection[i].desc.value.att_exp);
	}
  
	/*| Update System Collection */
  	status = VR$ModifyCollection( 	p_msg                   = &msg,
                                	Operation               = VR_MERGE_COLL,
					Type			= VR_DYN_COLL,
					p_ParamsListToModify    = Collection,
         				NbParamsToModify        = NbCollect,
                                	p_OutputCollectionId    = &me->SysParamId );
  	as$status();
  	as$status( sts = msg );

	if ( me->PidRep  && me->ScaleChange && !(me->ModifyCommand))
	{
	  /* get the active system collection, different */
	  /* from nozzle collection                      */
	  ActSysId.objid = NULL_OBJID;
	  ActSysId.osnum = me->ModuleInfo.md_id.osnum;
	  VR$active_params(operation = VR_RETRIEVE, 
			 mode = VR_SYSTEM_MODE,
			 update_flag = VR_NOUPDATE,
			 VRproduct = me->Product,
			 act_param_id = &ActSysId, 
			 status = status);
	  	
	  /* copy the system collection */
	  ActSysIdNew.objid = NULL_OBJID;
	  ActSysIdNew.osnum = ActSysId.osnum;
	  status = VR$ModifyCollection(   p_msg                   = &msg,
					Operation               = VR_MERGE_COLL,
					p_InputCollectionId	= &ActSysId,
					p_OutputCollectionId    = &ActSysIdNew);
	  
	  as$status();
	  as$status( sts = msg );

	  /* update the system collection */
	  status = VR$ModifyCollection(   
			    p_msg                   = &msg,
			    Operation               = VR_MERGE_COLL,
			    p_ParamsListToModify    = &Collection[NbCollect-1],
			    NbParamsToModify        = 1,
			    p_OutputCollectionId     = &ActSysIdNew);
	  as$status();
	  as$status( sts = msg );

	  /* make the new system collection the active collection */
	  VR$active_params(operation = VR_REPLACE,
			 update_flag = VR_NOUPDATE,
			VRproduct = me->Product,
			act_param_id = &ActSysIdNew,
			status = status);


	}
/* Remove the width_2 and depth_2 attributes from the system collection -
these attributes were spuriously brought over from the active collection,
and the easiest course is just to remove them form this collection. */
	{

	     struct ACrg_coll Coll[2];

	     strcpy( Coll[0].name, VR_N_WIDTH2_DB);
	     Coll[0].desc.type = AC_ATTRIB_DOUBLE;
	     strcpy( Coll[1].name, VR_N_DEPTH2_DB);
	     Coll[1].desc.type = AC_ATTRIB_DOUBLE;

	     NbCollect = 2;
	     status = VR$ModifyCollection(   
			p_msg                   = &msg,
			Operation               = VR_SUBSTR_COLL,
			Type                    = VR_DYN_COLL,
			p_ParamsListToModify    = Coll,
			NbParamsToModify        = NbCollect,
			p_OutputCollectionId    = &me->SysParamId );
	     as$status();
	}
        as$status();
        as$status( sts = msg );

	VRprint_user_attr( &me->SysParamId );

	me->ScaleChange  = FALSE;
	me->SystemChange = FALSE;
  	me->ret 	 = VRUSERPARAM;
  }

  /* ----- Keep the current missing collection ----- */
 if( me->MissingParamsId.objid != NULL_OBJID )
  {
  	TempMissingId.osnum = me->ModuleInfo.md_id.osnum;
  	status = VR$ModifyCollection( 
			p_msg                   = &msg,
                        Operation               = VR_MERGE_COLL,
			p_InputCollectionId     = &me->MissingParamsId,
                        p_OutputCollectionId    = &TempMissingId );
  }
  
  __DBGpr_int( " Me--> ret ", me->ret );

  __DBGpr_com( " Evaluating the Nozzle ... " );
  status = 
  om$send( msg      = message VRPlNozzle.VREvaluateNozzle( &msg ),
           targetid = my_id );
  as$status();

  /* ----- Check wether the missing collection as been changed ----- */
  if( TempMissingId.objid != NULL_OBJID && me->MissingParamsId.objid != NULL_OBJID )
  	status = VRTestColl( &msg, &TempMissingId, &me->MissingParamsId, &Change );

  if ( Change )		
  {
         /* yzhu: here we considered the evaluation of nozzle for modifing 
                  process.
          */  
        if(me->ModifyCommand == TRUE && me->ret != VRNOT_OK) {
			me->ret  = NO_CHANGE;
         }
        if(me->ModifyCommand == TRUE && me->ret == VRNOT_OK) {
                /* back to init state*/
                me->SystemChange = TRUE;
                me->UserChange   = TRUE;
                me->MissingChange   = TRUE;
        }
	 End
	 return OM_S_SUCCESS;
  }
  
  if(me->ModifyCommand == FALSE && me->ret == VRNOT_OK) {
                me->SystemChange = TRUE;
                me->UserChange   = TRUE;
                me->MissingChange   = FALSE;
  }
  
  if ( me->Init )	me->Init = FALSE;

  End	
  return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action form_notification
{
  IGRchar			text[30], macro_name[20]; /* law 04/02/98 */
  IGRint			SelFlag, r_pos;
  IGRchar			mess[30];
  IGRchar			ExpValue[20];  /* law 04/02/98 */
  IGRlong			msg, status1;
  IGRint                        NoText = FALSE;
  IGRdouble			nominal_size;
  IGRdouble			value1;
  IGRchar			pressure_class[10];
  IGRchar			end_condition[10];
  IGRchar			end_standard[20] ; /**** law 04/02/98 ***/
  IGRshort              	listsize1;
  IGRchar               	*codelist1;
  IGRchar               	*condlist,*stanlist,*preslist;
  IGRdouble             	*npdlist1, *sizelist;
  IGRchar               	Cnpdlist[VR_MAX_NPDLIST_SIZE][10];
  IGRint			i,j;
  IGRshort			size_num = 0, cond_num = 0,
				stan_num = 0, pres_num = 0;
  IGRchar                       shapetxt[30]; /* Added for TR179702481 */
 
  SetProc( form_notification ); Begin 

  __DBGpr_int(" gadget label ", gadget_label );

  if( ( me->Product == VR_RWAY) && ( form_ptr != me->FormUser)  )
  {
     /*
      * I don't want to mess around with this form_notification, instead
      * would write a separate method to handle form_notification for
      * Raceway Nozzle alone. So its clean and easy to debug in the later
      * stages.
      */
      status = om$send( msg = message VRPlNozzle.VRRwayNozzFN( &msg,
				gadget_label, form_ptr ),
			    targetid = my_id );

      End
      return ( OM_S_SUCCESS );
  }

  if( form_ptr == me->form_ptr[1] )
  {
	switch( gadget_label )
	{
		case SPEC_NAME :
		{
		    IGRshort		nSpec=0;
		    IGRint 		new_list_cnt=0, sel_index;
		    IGRint 		sel_flag=0, unique_flg=0;
		    IGRchar		*speclist;

		    /*| -- Get Spec Name List */
		    status = VRget_spec_list ( &msg, me->Product, &nSpec , 
						&speclist, NULL);
		    CheckRC( status, msg );
		    if( !status & 1 ) break;
		    __DBGpr_int( " No. of Specs from DB ", nSpec );

		    qsort( speclist, nSpec, VR_MAX_SPEC_NAME_LEN, strcmp );

	    /* Filter the DB ( Original ) Spec list as needed for the user */
		    sel_index = -1;
		    status = VDfrm_fld_set_sub_list( me->form_ptr[1],
						     SPEC_NAME, -1, speclist,
						     VR_MAX_SPEC_NAME_LEN,
						     (IGRint) nSpec,
						     &new_list_cnt, 0,
						     &sel_index, &unique_flg );

		    __DBGpr_int( " Unique Flag ", unique_flg );

		    if( unique_flg == 1 )
		    {
			/* Unique match has been found out of User Keyed in
			 * string, so we need to proceed further. */

			FIg_get_text( me->form_ptr[1], gadget_label, text );
			__DBGpr_str( " Selected Spec ", text );
			FIg_enable( me->form_ptr[1], FI_ACCEPT );
		    }
		    else if( sel_index < 0 ) 
		    {
			FIg_disable( me->form_ptr[1], FI_ACCEPT );
			End
			return status;
		    }

		    if( me->Product == VR_HVAC )
		    {
			// added by alwin for CR179900696
			/* Call this function to update the Material
			 * list...from db */
			VRUpdMaterial_InsulationList( form_ptr, TRUE, text,
								DUCT_MATERIAL);
		    }
		    me->SystemChange = TRUE;
		    me->UserChange   = TRUE;
		    break;
		}

		case DUCT_MATERIAL : // same as INSUL_TYPE of PIPING

			 FIg_get_text( me->form_ptr[1], gadget_label, text );

			 if( me->Product == VR_HVAC )
			 {
			   // Call this function to update the Material 
			   // thickness...from db
			   VRUpdMaterial_InsulationThickness(form_ptr, TRUE, text, DUCT_THICK );
			 }
			 else if( me->Product == VR_PIPING )
			 {
			    // Call this function to update the Insulation 
			    // thickness list from db. CR179901615 Alwin
			    __DBGpr_str( " Insulation type ", text );
			    VRPGetInsulThkFromType( form_ptr, INSUL_THIK,
							text );
			 }
			me->SystemChange = TRUE;
			me->UserChange   = TRUE;
			break;

		case INSUL_MATERIAL     :

			 FIg_get_text( me->form_ptr[1], gadget_label, text );

			 if( me->Product == VR_HVAC )
			 {
			   IGRdouble dAcstThk=0.0, dACST = 0.0;

			   //Call this function to update the Insulation thickness...from db
			   VRUpdMaterial_InsulationThickness(form_ptr, FALSE, text, HINSUL_THICK );
                           FIg_get_value( form_ptr, ACOUSTICAL_THICK,
                                                &dAcstThk );

                           if( dAcstThk > 0.0 )
                           {
                             IGRdouble dThermalThk=0.0;

                             // Fetch the Thermal Insulation thickness
                             FIg_get_value( form_ptr, PAINT_TYPE,
                                                  &dThermalThk );
                             dACST = dAcstThk + dThermalThk;
                           }
                           FIg_set_value( form_ptr, ACST, dACST );
			 }
			me->SystemChange = TRUE;
			me->UserChange   = TRUE;
			break;

		// added by Alwin for CR179901312
		case ACOUSTICAL_MATERIAL :
			 FIg_get_text( me->form_ptr[1], gadget_label, text );

			 if( me->Product == VR_HVAC )
			 {
			   //Call this function to update the Insulation thickness...from db
			   VRUpdMaterial_InsulationThickness( form_ptr, FALSE, 
						text, ACOUSTICAL_THICK );

			 }
		
		case ACOUSTICAL_THICK :
		case PAINT_TYPE     : // case HDUCT_THICK :
			 if( me->Product == VR_HVAC )
			 {
			   IGRdouble dAcstThk=0.0, dACST = 0.0;

			   FIg_get_value( form_ptr, ACOUSTICAL_THICK, 
						&dAcstThk );

			   if( dAcstThk > 0.0 )
			   {
			     IGRdouble dThermalThk=0.0;

			     // Fetch the Thermal Insulation thickness
			     FIg_get_value( form_ptr, PAINT_TYPE, 
						  &dThermalThk );
			     dACST = dAcstThk + dThermalThk;
			   }
			   FIg_set_value( form_ptr, ACST, dACST );
			 }
			me->SystemChange = TRUE;
			me->UserChange   = TRUE;
			break;
		
		case NOZ_UNIT_NUMBER:
		case SCHDL_THK_OVRD :
		case SYSTEM_NAME    :
		case SEQ_NUMBER     :
		case FLUID          :
		case ZONE_NB        :
		case APPRO_STS      :
		case CONSTR_STS     :
		case WEIGHT_GRP     :
		case CHANGE_NO      :
		case DUCT_THICK	    : 
		case ZONE	    :  
			FIfld_get_text( me->form_ptr[1], gadget_label, 0, 0, 13,
				      (unsigned char *)text, &SelFlag, &r_pos);

			me->SystemChange = TRUE;
			me->UserChange   = TRUE;
			/*"gadget = %s \n",text*/
		break;

  		case FI_ACCEPT:
			strcpy( mess, "                            " );
			FIfld_set_text( me->form_ptr[0], 10, 0, 0, mess, FALSE);
			FIbtn_set_auto_pop_up_on( me->form_ptr[1], gadget_label );
			FIbtn_set_auto_pop_up_on( me->form_ptr[0], NOZZLE_ATTR );
			FIf_erase( me->form_ptr[1] );
    		break;

  		case FI_CANCEL:
			me->SystemChange = FALSE;
			FIbtn_set_auto_pop_up_on( me->form_ptr[0], gadget_label );
			FIbtn_set_auto_pop_up_on( me->form_ptr[0], NOZZLE_ATTR );
   			FIf_erase( me->form_ptr[1]);
  		break;
	}
  }
  else if ( form_ptr == me->form_ptr[0])
  {
        /* Added for TR179702481 */
        FIg_set_text( me->form_ptr[0], FI_MSG_FIELD,
                        " ");
        if(me->redefine_shape)
        {
          me->redefine_shape = 0;

          if(ShapeGadget < 0 || ShapeGadget > 2)
            ShapeGadget = 0;

          if(gadget_label != NZTYPE && me->Product == VR_HVAC)
          {
            FIfld_get_text( me->form_ptr[0], NZTYPE, 0, 0, 30,
                                 (unsigned char *)shapetxt, &SelFlag, &r_pos );
            if(gadget_label == CIRCULAR)
              strcpy(Hv_Noz_macro[2].macro_name,shapetxt);
            else if(gadget_label == RECTANGULAR)
              strcpy(Hv_Noz_macro[0].macro_name,shapetxt);
            else if(gadget_label == OVAL)
              strcpy(Hv_Noz_macro[1].macro_name,shapetxt);
            else
              strcpy(Hv_Noz_macro[ShapeGadget].macro_name,shapetxt);
          }
        }
  	switch( gadget_label )
  	{
                /* Following modified by TR179702481 */
                /* added by alwin */
                case RECTANGULAR    :
                     FIg_hilite( form_ptr, gadget_label );
                     FIg_unhilite( form_ptr, CIRCULAR );
                     FIg_unhilite( form_ptr, OVAL );
                     FIg_enable( form_ptr, DEPTH );
                     ShapeGadget = 0;
                     if(me->Product == VR_HVAC)
                        FIfld_set_text( me->form_ptr[0],NZTYPE, 0, 0,
                                     Hv_Noz_macro[ShapeGadget].macro_name,
                                       FALSE);
                     me->SystemChange = TRUE;
                     break;

                case OVAL           :
                     FIg_hilite( form_ptr, gadget_label );
                     FIg_unhilite( form_ptr, CIRCULAR );
                     FIg_unhilite( form_ptr, RECTANGULAR );
                     FIg_enable( form_ptr, DEPTH );
                     ShapeGadget = 1;
                     if(me->Product == VR_HVAC)
                        FIfld_set_text( me->form_ptr[0],NZTYPE, 0, 0,
                                     Hv_Noz_macro[ShapeGadget].macro_name,
                                       FALSE);
                     me->SystemChange = TRUE;
                     break;

                case CIRCULAR       :
                     FIg_hilite( form_ptr, gadget_label );
                     FIg_unhilite( form_ptr, RECTANGULAR );
                     FIg_unhilite( form_ptr, OVAL );
                     FIg_disable( form_ptr, DEPTH );
                     ShapeGadget = 2;
                     if(me->Product == VR_HVAC)
                        FIfld_set_text( me->form_ptr[0],NZTYPE, 0, 0,
                                     Hv_Noz_macro[ShapeGadget].macro_name,
                                       FALSE);
                     me->SystemChange = TRUE;
                     break;
                /* added by alwin */

		case NOZ_PID_SCALE		:
		        me->ScaleChange = TRUE;
		case NOMINAL_SIZE	:
		case END_COND 		:
		case END_STAND		:
		case PRESSURE_CLASS	:
                
                /* CR179528329 */
		if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
                   /****** law 04/02/98 ********/
                   FIfld_get_text( me->form_ptr[0], END_STAND, 0, 0, 20,
                          (unsigned char *)end_standard, &SelFlag, &r_pos );

                   FIfld_get_text( me->form_ptr[0], END_COND, 0, 0, 9,
                          (unsigned char *)end_condition, &SelFlag, &r_pos );
                
		   FIfld_get_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0, 9,
                         (unsigned char *)pressure_class, &SelFlag, &r_pos );
             
 
                   FIfld_get_text(me->form_ptr[0], NOMINAL_SIZE, 0, 0, 9,
				(unsigned char *)text, &SelFlag, &r_pos);

                   nominal_size = atof(text); 
		   __DBGpr_dbl(" nominal_size",nominal_size);

		   FIfld_set_text( me->form_ptr[0], 10, 0, 0,
                                     "please wait...", FALSE);
	           status1 = VRupdate_field_list_set (
      				&msg, 
				me->Product,
      				nominal_size,
      				end_condition,
      			        pressure_class,
      				end_standard,
      			        &size_num, &sizelist,
      				&cond_num, &condlist,
      				&pres_num, &preslist,
      				&stan_num, &stanlist,
                                macro_name,
      				NULL);
		  FIfld_set_text( me->form_ptr[0], 10, 0, 0,
                                     " ", FALSE);
                  if( status1 & 1)
		  { 
                    /* for NOMINAL_SIZE */

                    FIfld_set_list_num_rows( me->form_ptr[0], NOMINAL_SIZE,
                                        0,size_num );
		    for(i=0; i<size_num; i++)
		    {
		      sprintf(Cnpdlist[i], "%lg", sizelist[i]);
            	      VDfld_set_list_text( me->form_ptr[0], NOMINAL_SIZE, i,
                  	0, Cnpdlist[i], FALSE);
			__DBGpr_str(" Nominal size",Cnpdlist[i]);
		    }
   			
                    /* for END_STAND */ 
                    FIfld_set_list_num_rows( me->form_ptr[0],  END_STAND, 0,
                                        (stan_num));
                       /****** law 04/02/98 *******/
                    for(i=0,j=0;i<stan_num*VR_SHORT_CODETEXT_SIZE;
                                                    i+=VR_SHORT_CODETEXT_SIZE)
                    {
			   __DBGpr_str(" END_STAND list",&stanlist[i]);
                           if (stanlist[i]) {
                            VDfld_set_list_text( me->form_ptr[0], END_STAND,
                                    j, 0, &stanlist[i], FALSE);
                            j++;
			   }
                        }

                    /* for END_COND */ 
                    FIfld_set_list_num_rows( me->form_ptr[0],  END_COND, 0,
                                       (cond_num));
                       /****** law 04/02/98 *******/
                    for(i=0,j=0;i<cond_num*VR_SHORT_CODETEXT_SIZE;
                                                    i+=VR_SHORT_CODETEXT_SIZE)
                    {
			   __DBGpr_str(" END_COND",&condlist[i]);
                           if (condlist[i]) {
                            VDfld_set_list_text( me->form_ptr[0], END_COND,
                                    j, 0, &condlist[i], FALSE);
                            j++;
			   }
                     }


                    /* for  PRESSURE_CLASS */ 
         	    FIfld_set_list_num_rows( me->form_ptr[0],  PRESSURE_CLASS, 
			0, (pres_num));
                       /****** law 04/02/98 *******/
                    for(i=0,j=0;i<pres_num*VR_SHORT_CODETEXT_SIZE;
                                                    i+=VR_SHORT_CODETEXT_SIZE)
                    {
			   __DBGpr_str(" PRESSURE_CLASS",&preslist[i]);
                 	   if (preslist[i]) 
			   {
                            VDfld_set_list_text( me->form_ptr[0], 
						 PRESSURE_CLASS,
                                    j, 0, &preslist[i], FALSE);
                   	    j++;
			   }
                     }
                     /* update macro_name */
                     if( strcmp( macro_name, "<blank>") ) { 
		        FIfld_set_text( me->form_ptr[0], NZTYPE, 0, 0,
                                     macro_name, FALSE);
                     }
                  } /* if */ 
	        }   /* if(VR_TABLE_NOZZLE1) */

		case NZTYPE		:
                   /* Added for TR179702481 */
                   if(me->Product == VR_HVAC)
                   {
                      status =
                      om$send( msg= message VRPlNozzle.VR_Assign_Shape( &msg ),
                               targetid = my_id );
                      as$status();
                   }
		case TAG_NUMBER		:
		case NZSERVICE		:
		case SCHDL_THK 		:
		case APPRV_STS		:
		case CONST_STS		:
			me->SystemChange = TRUE;
			me->UserChange = TRUE;
		break;

		case RESET_BTN: /* CR179528329 :reset to initial list*/
                  if(VR_TABLE_NOZZLE1 && me->Product   == VR_PIPING) {
                    /* for end_condition */ 
                    status1 = VRget_field_list_set ( &msg, me->Product,
                                           "end_condition",
                                           NULL,
                                           NULL,
                                           &listsize1 , &codelist1,
                                           NULL);
                    if ( status1 & 1 ) {
                      FIfld_set_list_num_rows( me->form_ptr[0],  END_COND, 0,
                                        (listsize1));
                       /****** law 04/02/98 *******/
                    for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;
                                                    i+=VR_SHORT_CODETEXT_SIZE)
                    {
                        if (codelist1[i]) {
                           VDfld_set_list_text( me->form_ptr[0],  END_COND,
                                    j, 0, &codelist1[i], FALSE);
                 	   j++;
                        }
                      }
		      FIfld_set_text( me->form_ptr[0], END_COND, 0, 0,
				 		"EMPTY", FALSE);
                    }
                    /* for end_standard */
                    status1 = VRget_field_list_set ( &msg, me->Product,
                                           "end_standard",
                                           NULL,
                                           NULL,
                                           &listsize1 , &codelist1,
                                           NULL);
                    if ( status1 & 1 ) {
                      FIfld_set_list_num_rows( me->form_ptr[0],  END_STAND, 0,
                                        (listsize1));
                       /****** law 04/02/98 *******/
                    for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;
                                                    i+=VR_SHORT_CODETEXT_SIZE)
                    {
                        if (codelist1[i]) {
                         VDfld_set_list_text( me->form_ptr[0],  END_STAND,
                                    j, 0, &codelist1[i], FALSE);
                           j++;
                        }
                      }
		      FIfld_set_text( me->form_ptr[0], END_STAND, 0, 0,
				 		"EMPTY", FALSE);
                    }

      		    /* for pressure_class */
                    status1 = VRget_field_list_set ( &msg, me->Product,
                                           "pressure_class",
                                           NULL,
                                           NULL,
                                           &listsize1 , &codelist1,
                                           NULL);
                    if ( status1 & 1 ) {
                      FIfld_set_list_num_rows( me->form_ptr[0],
					 PRESSURE_CLASS, 0,
                                         (listsize1));
                       /****** law 04/02/98 *******/
                      for(i=0,j=0;i<listsize1*VR_SHORT_CODETEXT_SIZE;
                                                    i+=VR_SHORT_CODETEXT_SIZE)
                      {
                        if (codelist1[i]) {
                           VDfld_set_list_text( me->form_ptr[0], 
				PRESSURE_CLASS, j, 0, &codelist1[i], FALSE);
                           j++;
                        }
                      }
		      FIfld_set_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0,
				 		"EMPTY", FALSE);
                    }

                    /* for nominal_size */
                    status1= VRget_npd_list_from_nozzle1 
				(&msg, me->Product, "NOZZLE1",
                                 &listsize1, &npdlist1,NULL);

                    if ( status1 & 1 ) {
            	      for( i = 0; i<listsize1; i++)
                		sprintf(Cnpdlist[i], "%f", npdlist1[i]);
            		
                      FIfld_set_list_num_rows( me->form_ptr[0], NOMINAL_SIZE,
                                        0,listsize1 );
                      for(i=0; i<listsize1; i++)
            	       VDfld_set_list_text( me->form_ptr[0], NOMINAL_SIZE, i,
                        	0, Cnpdlist[i], FALSE);
                    
			value1 = 0;
                        sprintf(text, "%f", value1);
		        FIfld_set_text( me->form_ptr[0], NOMINAL_SIZE, 0, 0,
				 		text, FALSE);
                    }
                    /* for macro_name */
		    FIfld_set_text( me->form_ptr[0], NZTYPE, 0, 0, " ", FALSE);

                    /* erase missing group fileds */
                    FIg_erase( me->form_ptr[0], MISSING_GRP );
                  }
	
		break;
                /********** law 04/02/98 **********/
		case EXP_END_STAND :
			ExpValue[0] = '\0';
			FIfld_get_text( me->form_ptr[0],gadget_label,0,0,20,
				      (unsigned char *)text, &SelFlag,&r_pos );
			VRCheckExp( &msg, text, ExpValue, &me->ModuleInfo  );
			if( !ExpValue[0] )	break;

			FIfld_set_text( me->form_ptr[0], END_STAND, 0, 0,
				 		ExpValue, FALSE);
			break;

		case EXP_TAG_NUMBER	:
		case EXP_SERVICE	:
		case EXP_END_COND	:
		case EXP_NOM_SIZE	:
		case EXP_SCH_THK	:
		case EXP_PRESSURE	:
			ExpValue[0] = '\0';
			FIfld_get_text( me->form_ptr[0],gadget_label,0,0,9,
				      (unsigned char *)text, &SelFlag,&r_pos );
			VRCheckExp( &msg, text, ExpValue, &me->ModuleInfo  );
			if( !ExpValue[0] )	break;

			switch( gadget_label )
			{
				case EXP_TAG_NUMBER :
				FIfld_set_text( me->form_ptr[0], TAG_NUMBER, 0, 0,
				 		ExpValue, FALSE);
				break;
		
				case EXP_SERVICE   :
				FIfld_set_text( me->form_ptr[0], NZSERVICE, 0, 0,
				 		ExpValue, FALSE);
				break;

				case EXP_NOM_SIZE  :
				FIfld_set_text( me->form_ptr[0], NOMINAL_SIZE, 0, 0,
			 		ExpValue, FALSE);
				break;

				case EXP_END_COND  :
				FIfld_set_text( me->form_ptr[0], END_COND, 0, 0,
				 		ExpValue, FALSE);
				break;			

				case EXP_PRESSURE  :
				if( me->Product == VR_PIPING )
				FIfld_set_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0,
				 		ExpValue, FALSE);
				break;

				case EXP_SCH_THK :
				FIfld_set_text( me->form_ptr[0], SCHDL_THK, 0, 0,
				 		ExpValue, FALSE);
				break;

			}
		break;

		case NOZZLE_ATTR:
			FIbtn_set_auto_pop_up_off( me->form_ptr[0], gadget_label);
			if( me->form_ptr[1]  != NULL )
				FIf_display ( me->form_ptr[1] );
		break;

        	case USER_ATTR:
			FIf_display( me->FormUser );
		break;

		case MISSING :

			me->MissingChange = TRUE;
		break;

  		case FI_ACCEPT:
			strcpy( mess, "                            " );
			FIfld_set_text( me->form_ptr[0], 10, 0, 0, mess, FALSE);

                       
			/* check if the Exp_name in the missing para form
			 * is not text.
			 * Note:  5a, a5--> ok
			 *        555   --> not ok
			 */
			 if(me->MissingChange) 
			 {

			   IGRint num_rows = 0, row, length2,num = 0;
			   IGRdouble numstr;
			   IGRchar ExpName[VR_MAX_CHAR],
					   CharStr[VR_MAX_CHAR];

			   FIfld_get_num_rows( me->form_ptr[0], MISSING,
												&num_rows );
			   ExpName[0] = '\0';
			   for ( row=0; row<num_rows; row++ ) {

				 length2 = 0;
				 FIfld_get_text_length( me->form_ptr[0], MISSING,
									  row, 2, &length2 );

				 if( length2 > 1 ) {
				   FIfld_get_text( me->form_ptr[0], MISSING, row, 2,
							  length2, (unsigned char *) ExpName, 
		  						&SelFlag, &r_pos );

				   num = 0;
				   num = sscanf( ExpName, "%g%c", &numstr, CharStr);
				   if(num == 1) {
					 sprintf( mess, "Exp_name in row %d is not text",
							   row+1 );
					 FIfld_set_text( me->form_ptr[0], 10,
							  0, 0, mess, FALSE);
					 NoText = TRUE;
					 break;
				   }
				 }
			   }
			}
			if( !me->ModifyCommand )
			{
                                /** CR179901712 PID patches needed here **/
				FIg_get_text( me->form_ptr[0], NZTYPE, text);
				if ( text[0] == '\0')
				{
					strcpy( mess, "Macro Name must be specified" );
					FIfld_set_text( me->form_ptr[0], 10, 0, 0, mess, FALSE);
					break;
				}


			}

			/* added by alwin */
			{ /* Updating the Collector with the present SHAPE
				 CODE, which the user has changed */

				  struct ACrg_coll ShapeCodeCol;

				  strcpy( ShapeCodeCol.name, VR_N_SHAPE_IN );
				  ShapeCodeCol.desc.type = AC_ATTRIB_DOUBLE;
				  ShapeCodeCol.desc.value.att_exp = (IGRdouble)ShapeGadget;
				  status = VR$ModifyCollection(
					 p_msg                   = &msg,
					 Operation               = VR_MERGE_COLL,
					 p_ParamsListToModify    = &ShapeCodeCol,
					 NbParamsToModify        = 1,
					 p_OutputCollectionId    = &me->SysParamId);
			}

			FIbtn_set_auto_pop_up_on( me->form_ptr[0], gadget_label );

			if ( me->MissingChange && NoText )  { 
			   _put_response (resp = VR_MISSINGFORM_STATUS);
			}
			else {
			 VR_NOZZLE1_INIT = 1;
			_put_response( resp = EX_FORM_FINISHED );
            }
    		break;

  		case FI_CANCEL:
			FIbtn_set_auto_pop_up_off( me->form_ptr[0], FI_CANCEL );
    			FIf_erase( me->form_ptr[0] );
			FIf_erase( me->form_ptr[1] );
			FIf_erase( me->FormUser );
			me->MissingChange = FALSE;
			me->SystemChange  = FALSE;
			me->ScaleChange   = FALSE;
			_put_response( resp = TERMINATE );
  		break;

		// added for CR179900995 
  		case COPY_PARAMS_BTN:
		{
		    IGRlong		retmsg;
		    struct GRid DuctId, PipeId; 

		    UI_status( " " );
		    DuctId.objid = NULL_OBJID;
		    PipeId.objid = NULL_OBJID;

		    if( me->Product == VR_PIPING )
		    {
			struct GRid	SysId;

			FIf_display( me->form_ptr[1] );
			status = VRCopyPipeParams( &retmsg, &PipeId );
			__DBGpr_obj( " Component/Nozzle ObjectId ", PipeId );

			// Get the System Parameters Id
			status = 
			om$send( msg = message VRGeneric.VRGetParams( 
						      &retmsg, &SysId, 
						      NULL, NULL ),
						targetid = PipeId.objid,
						targetos = PipeId.osnum );

			// Update the form with values from SysId
			status = VRFillUpNozzleAttrForm(me->form_ptr[1],
						me->Product, SysId );

			me->SystemChange = TRUE;
			UI_message( "Modify Piping Nozzle" );
			UI_prompt( "Change Parameters" );
		    }
		    else if( me->Product == VR_HVAC )
		    {
		      status = VRCopyDuctParams( &retmsg, &DuctId );

		      if( ( retmsg & 1) && (DuctId.objid != NULL_OBJID) )
		      {
			 struct GRid SysId, UsrId;
			 struct ACrg_coll TempColl;

			 __DBGpr_obj( " Located Duct Id ", DuctId );
			 status = 
			 om$send( msg = message VRGeneric.VRGetParams( 
						      &retmsg, &SysId, 
						      &UsrId, NULL ),
						targetid = DuctId.objid,
						targetos = DuctId.osnum );

			 // Copy the Params to the instance data so that 
			 // we set it to
			 // the Nozzle during the placement
			 status = VR$ModifyCollection(
				     p_msg           	= &retmsg,
				     p_InputCollectionId = &SysId,
				     p_OutputCollectionId= &me->SysParamId );

			 status = VR$ModifyCollection(
				     p_msg           	= &retmsg,
				     p_InputCollectionId = &UsrId,
				     p_OutputCollectionId= &me->UserParamId );

			 UI_message( "Modify HVAC Nozzle" );
			 UI_prompt( "Change Parameters" );
			 UI_status( "Copied Params from Duct ..." );

			 status = 
			 om$send( msg = message VRPlNozzle.VRinit( &retmsg ),
						targetid = my_id );

			 /* We need to force it to read the values, 
			 otherwise the new values won't be come into effect*/
			 me->SystemChange = me->UserChange = TRUE;

                         /*
                          * In the process of copying the entire "System"
                          * collection of Duct, we also copy the "trans_len"
                          * attribute to the nozzle. Whereas for nozzle, this is
                          * a "Missing attibute" and is placed in the Missing
                          * Params collector. So after copying remove the
                          * attribute from the System's collecor. CR4117
			  * Deleting the attribute is preffered b'cas, this
			  * is easier approach and faster thing to do.
                          * Alwin*/

                         // Remove the attribute trans_len from System collector
                         strcpy( TempColl.name, VR_N_TRANS_L_DB );
                         status = VR$ModifyCollection(
                                     p_msg       = &retmsg,
                                     Operation   = VR_SUBSTR_COLL,
                                     p_ParamsListToModify = &TempColl,
                                     NbParamsToModify = 1,
                                     p_OutputCollectionId= &me->SysParamId );
		      } 
		      else
			{ __DBGpr_com( " Some thing went wrong in locating " ); }
		    }
		    FIg_set_state_off( form_ptr, gadget_label );
		}
  		break;

  		default:
    			/*"gadget_label %d unknown\n", gadget_label */
    		break;
	}

	/*"SysChange = %d\n", me->SystemChange */
  }
  else if( form_ptr == me->FormUser )
  {
     	switch ( gadget_label )
    	{
      		case USER_ATTR_FLD:
			me->UserChange = TRUE;
        	break;

      		case FI_EXECUTE:
		case FI_ACCEPT :
			FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
			FIbtn_set_auto_pop_up_on( me->form_ptr[0], USER_ATTR );
			FIf_erase( me->FormUser );
        	break;

		case FI_CANCEL:
			FIbtn_set_auto_pop_up_on( me->form_ptr[0], USER_ATTR);
			FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
			FIf_erase( me->FormUser); 
			me->UserChange = FALSE;
  		break;
    	}
  }
  
  End
  return ( OM_S_SUCCESS );
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VREvaluateNozzle 
{
  IGRlong 			retcode, msg;
  IGRint			nEvalCompTopo;
  IGRint			NbMissingParams;
  struct	ACrg_coll	*p_MissingParamsList;

  SetProc( Md VREvaluateNozzle ); Begin 

  me->ret = VRALL_OK;

  /*  we need to evaluate the nozzle for modifing process */
  if( me->ModifyCommand)
  {
  	IGRint                NbMissing; 
  	struct  VRGenInfo     CompInstance;   
  	struct  GRid          CreaCompId;
  	struct  GRid          SysParamId; 
  	struct  GRid          UserParamId;
  	struct  GRid          MissingParamsId;
	struct  GRmd_env      ModuleInfo;
        int                   retmsg; 
 
 	me->CompInstance.Attr.Comp.Desc.nItemNum  = VR_NOZZLE;
  	me->CompInstance.Attr.Nozz.dSecAngle      = 0;
  	me->CompInstance.nNbAttr                  = 3;

  	status = VR$SetCompInstanceInfo( p_msg           = &retcode,
                                   CmpStatus       = VR_SYSTEM | VR_OUT_MACRO,
                                   CmpNumber       = me->CompInstance.szNumber,
                                   MdEnvOsnum      = me->ModuleInfo.md_id.osnum,
                                   p_CmpGenInfo    = &me->CompInstance );

        me->MissingParamsId.osnum  = me->ModuleInfo.md_id.osnum;

  	/*| ----- EVALUATE NOZZLE ----- */
        /* keep previous parameters */
        NbMissing       = me->NbMissing;
        MissingParamsId = me->MissingParamsId; 
        SysParamId      = me->SysParamId; 
        UserParamId     = me->UserParamId; 
        CreaCompId      = me->CreaCompId;
        CompInstance    = me->CompInstance;
        ModuleInfo 	= me->ModuleInfo;

        VRprint_user_attr( &me->SysParamId );

	__DBGpr_com( " Evaluating the Nozzle ... " );
        NbMissingParams = 0;
        status = VR$EvaluateNozz( p_msg               = &retcode,
                            Product             = me->Product,
                            p_Instance          = &me->CompInstance,
                            p_SysParamsId       = &me->SysParamId,
                            p_UsrParamsId       = &me->UserParamId,
                            p_MssParamsId       = &me->MissingParamsId,
                            p_ComponentId       = &me->CreaCompId,
                            p_NbCpts            = &nEvalCompTopo,
                            p_NbMissingParams   = &NbMissingParams,
                            p_AddrMissings      = &p_MissingParamsList,
                            p_MdEnv             = &me->ModuleInfo );

	__DBGpr_obj( " Created Nozzle Id ", me->CreaCompId );

  	if( me->CreaCompId.objid != NULL_OBJID )
  	{
        retmsg = om$send ( msg      = message GRgraphics.GRdelete(
                                                        &msg, &me->ModuleInfo),
                           senderid = my_id,
                           targetid = me->CreaCompId.objid,
                           targetos = me->CreaCompId.osnum);
        as$status( sts = retmsg );
  	}

        /* back to previous parameters */
        me->NbMissing       = NbMissing;
        me->MissingParamsId = MissingParamsId;
        me->SysParamId      = SysParamId;
        me->UserParamId     = UserParamId;
        me->CreaCompId      = CreaCompId;
        me->CompInstance    = CompInstance;
        me->ModuleInfo 	    = ModuleInfo;

  	if (!(status & 0x01) || !(retcode & 0x01)) {
        
          /*| ----- Error in status of VREvaluate MissingParam ------ */
           ex$message( field   = ERROR_FIELD,
                    msgnumb = VR_E_ErrorEvaluation );
           FIfld_set_text( me->form_ptr[0], 10, 0, 0,
                   " Wrong macro name or wrong parameters are used", FALSE);

          me->ret = VRNOT_OK;
		  __DBGpr_com( " Error during Evaluation !!!" );
		  End
          return OM_S_SUCCESS;
        }

	End
 	return OM_S_SUCCESS;  
  }

  /*| ----- Initialize nozzle instance for evaluate ----- */
  me->CompInstance.Attr.Comp.Desc.nItemNum  = VR_NOZZLE;
  me->CompInstance.Attr.Nozz.dSecAngle      = 0;
  me->CompInstance.nNbAttr		    = 3;
  
  status = VR$SetCompInstanceInfo( p_msg           = &retcode,
         			   CmpStatus	   = VR_SYSTEM | VR_OUT_MACRO,
				   CmpNumber	   = me->CompInstance.szNumber,
				   MdEnvOsnum      = me->ModuleInfo.md_id.osnum,
                                   p_CmpGenInfo    = &me->CompInstance );


  if( !me->ModifyCommand)	NbMissingParams = 0;

  me->MissingParamsId.osnum  = me->ModuleInfo.md_id.osnum;

  /*| ----- EVALUATE NOZZLE ----- */
  NbMissingParams = 0;
  status = VR$EvaluateNozz( p_msg		= &retcode,			
			    Product		= me->Product,
			    p_Instance		= &me->CompInstance,
			    p_SysParamsId	= &me->SysParamId,
			    p_UsrParamsId	= &me->UserParamId,
			    p_MssParamsId	= &me->MissingParamsId,
			    p_ComponentId	= &me->CreaCompId,
			    p_NbCpts		= &nEvalCompTopo,
	 		    p_NbMissingParams	= &NbMissingParams,
			    p_AddrMissings	= &p_MissingParamsList,
			    p_MdEnv		= &me->ModuleInfo );
  __DBGpr_int( " NbMissing Parameters ", NbMissingParams );

  __DBGpr_obj( " Created Nozzle Id ", me->CreaCompId );

  if ( !me->NbMissing )	me->NbMissing = NbMissingParams;

  if (!(status & 0x01) || !(retcode & 0x01))
  {
    	/*| ----- Error in status of VREvaluate MissingParam ------ */
    	ex$message( field   = ERROR_FIELD,
	    	    msgnumb = VR_E_ErrorEvaluation );
        FIfld_set_text( me->form_ptr[0], 10, 0, 0,
                   " Wrong macro name or wrong parameters are used", FALSE);
	
	/*| ----- Delete Component evaluated ----- */
        status = 
	om$send ( msg = message GRgraphics.GRdelete( &msg, &me->ModuleInfo),
		       	   senderid = my_id,
		       	   targetid = me->CreaCompId.objid,
		       	   targetos = me->CreaCompId.osnum);
	as$status();

    	me->ret = VRNOT_OK;
	End
    	return OM_S_SUCCESS;
  }

  /* Create or modify missing collection after the evaluated return values */
  __DBGpr_int( " Nb. of Missing Parameters ", NbMissingParams );
  if( NbMissingParams )
  {
	IGRint 		i;

	// Delete the Evaluated Nozzle. B'cas after the modification we would
	// evaluate again that time we can construct again. Alwin
	/***
	IGRint cn_type;
	cn_type = ND_COMP;
	nd$wait_batch( type       = GR_DELETED,
                       l_object   = &me->CreaCompId,
		       l_obj_info = &cn_type,
               	       nb_obj     = 1 );
	***/

	// Take a backup of the System & User Colletor, otherwise we would
	// loose them, once if we delete the Nozzle. B'cas Collectors would
	// kill themselves when they don't childrens. Alwin

	struct GRid	tempSysParamId, tempUserParamId;

        status = om$send( msg      = message NDnode.NDcopy( &msg ,0,
                                                        &me->ModuleInfo,
                                                        &me->ModuleInfo,
                                                        &tempSysParamId ),
                          senderid = NULL_OBJID,
                          targetid = me->SysParamId.objid,
                          targetos = me->SysParamId.osnum  );
        as$status( action = RET_STATUS );

        status = om$send( msg      = message NDnode.NDcopy( &msg ,0,
                                                        &me->ModuleInfo,
                                                        &me->ModuleInfo,
                                                        &tempUserParamId ),
                          senderid = NULL_OBJID,
                          targetid = me->UserParamId.objid,
                          targetos = me->UserParamId.osnum  );
        as$status( action = RET_STATUS );

	// Now that we've backed up the Collectors we can delete the Nozzle.
        status = 
	om$send ( msg = message GRgraphics.GRdelete( &msg, &me->ModuleInfo),
		       	   senderid = my_id,
		       	   targetid = me->CreaCompId.objid,
		       	   targetos = me->CreaCompId.osnum);
	as$status();

	me->SysParamId = tempSysParamId;
	me->UserParamId = tempUserParamId;

	status = 
	om$construct( 	classid = OPP_ACdyn_col_class_id,
    		        p_objid = &me->MissingParamsId.objid,
		        osnum   = me->MissingParamsId.osnum,
		     msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));                
      	as$status( action = RET_STATUS ); 

  	status = 
	om$send( msg      = message ACrg_collect.ACset_list_attribute
			     ( &retcode, NbMissingParams, p_MissingParamsList ),
                 senderid = NULL_OBJID,
                 targetid = me->MissingParamsId.objid,
                 targetos = me->MissingParamsId.osnum );
  	as$status( action = RET_STATUS );

        for( i=0 ; i < NbMissingParams ; i=i+1 )
        {
          __DBGpr_int(" index",i);
          __DBGpr_str(" Collection name", p_MissingParamsList[i].name);
          if( p_MissingParamsList[i].desc.type == AC_ATTRIB_TEXT )
             __DBGpr_str(" Collector string", p_MissingParamsList[i].desc.value.att_txt);

          if( p_MissingParamsList[i].desc.type == AC_ATTRIB_DOUBLE )
             __DBGpr_dbl(" Collector value", p_MissingParamsList[i].desc.value.att_exp);
        }

  	me->ret = VRUSERPARAM;
  }

  End
  return OM_S_SUCCESS;
}
/* ====================================================================	*/

action VRInsertNozzle
{
  IGRlong			msg, lConstructionListMsg;
  struct GRvg_construct 	ConstructionList;
  enum GRdpmode			Mode;
  IGRchar			text[20], exp[20];  /* law 04/02/98 */
  IGRint			i, SelFlag, r_pos;
  IGRint			VRNbNozAttr;
  IGRdouble 			value=0; 

  SetProc( VRInsertNozzle ); Begin

  /*| ----- Fill in ConstructionList structure ----- */
  ConstructionList.msg		= &lConstructionListMsg;
  ConstructionList.env_info	= (struct GRmd_env *) &me->ModuleInfo;
  ConstructionList.newflag	= FALSE;
  ConstructionList.level	= me->ActiveLevel;
  ConstructionList.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  ConstructionList.geometry	= 0;
  ConstructionList.display	= &me->ActiveDisplay;
  ConstructionList.class_attr	= NULL;
  ConstructionList.name		= 0;

  /*| ----- Place Nozzle or replace an old one ----- */

  for( i=0; i<VRPNbNozAttr; i++ ) me->expressions[i].objid = NULL_OBJID;

  if( !me->PidRep )
  {
	FIfld_get_text( me->form_ptr[0], EXP_TAG_NUMBER, 0, 0, 9,
				(unsigned char *) text, &SelFlag, &r_pos );
  	FIfld_get_text( me->form_ptr[0],TAG_NUMBER,0,0,9,
				(unsigned char *) exp,&SelFlag, &r_pos );

  	/* "TAG_NUMBER expname  = <%s>\n", text */
  	/* "TAG_NUMBER expvalue = <%s>\n", exp  */

	  VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL, 
  	      			&me->expressions[0],&me->ModuleInfo  );

	  FIfld_get_text( me->form_ptr[0], EXP_SERVICE, 0, 0, 9,
				(unsigned char *) text, &SelFlag, &r_pos );
	  FIfld_get_text( me->form_ptr[0],NZSERVICE,0,0,9,
				(unsigned char *) exp,&SelFlag, &r_pos );

	  /* "SERVICE expname  = <%s>\n", text */
	  /* "SERVICE expvalue = <%s>\n", exp  */

	  VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL, 
  	      			&me->expressions[1],&me->ModuleInfo  );

	  if( me->Product == VR_PIPING )
	  {
	  	FIfld_get_text( me->form_ptr[0],NOMINAL_SIZE,0,0,9,
				(unsigned char *) text,&SelFlag,&r_pos );

	  	value = atof(text);
	  	FIfld_get_text( me->form_ptr[0], EXP_NOM_SIZE, 0, 0, 9, 
				(unsigned char *)text, &SelFlag, &r_pos );

	  	/* "NOMINAL_SIZE expname  = <%s>\n", text */
	  	/* "NOMINAL_SIZE expvalue = <%lg>\n", value*/
	
		VRBuildExp( &msg, ( IGRchar )EXP_DOUBLE, text, NULL, &value,
			    &me->expressions[2], &me->ModuleInfo  );

	  	FIfld_get_text( me->form_ptr[0], EXP_END_COND, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );
	  	FIfld_get_text( me->form_ptr[0], END_COND, 0, 0, 9, 
				(unsigned char *) exp, &SelFlag, &r_pos );

	  	/* "END_COND expname  = <%s>\n", text */
	  	/* "END_COND expvalue = <%s>\n", exp  */
	
	  	VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL, &me->expressions[3],
 		      	    &me->ModuleInfo  );

 	 	FIfld_get_text( me->form_ptr[0], EXP_PRESSURE, 0, 0, 9, 
				(unsigned char *) text, &SelFlag,&r_pos );
 	 	FIfld_get_text( me->form_ptr[0], PRESSURE_CLASS, 0, 0, 9, 
				(unsigned char *) exp, &SelFlag, &r_pos );

 	 	/* "PRESSURE expname  = <%s>\n", text*/
 	 	/* "PRESSURE expvalue = <%s>\n", exp */

  		VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL, &me->expressions[4],
  		      	    &me->ModuleInfo  );

  		FIfld_get_text( me->form_ptr[0], EXP_SCH_THK, 0, 0, 9,
				(unsigned char *) text, &SelFlag, &r_pos );
  		FIfld_get_text( me->form_ptr[0], SCHDL_THK, 0, 0, 9, 
				(unsigned char *) exp, &SelFlag, &r_pos );
	
  		/* "SCH_THK expname  = <%s>\n", text*/
  		/* "SCH_THK expvalue = <%s>\n", exp */

  		VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL, &me->expressions[5],
		      	    &me->ModuleInfo  );

                /******** law 04/02/98 *********/
  		FIfld_get_text( me->form_ptr[0], EXP_END_STAND, 0, 0, 20, 
				(unsigned char *) text, &SelFlag, &r_pos );
  		FIfld_get_text( me->form_ptr[0], END_STAND, 0, 0, 20, 
				(unsigned char *) exp, &SelFlag, &r_pos );

  		/* "END_STAN expname  = <%s>\n", text*/
  		/* "END_STAN expvalue = <%s>\n", exp */

  		VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL, &me->expressions[6],
	      		    &me->ModuleInfo  );
  	}
  	else if( me->Product == VR_HVAC )
  	{
  		FIg_get_value( me->form_ptr[0],WIDTH, &value );
  		FIfld_get_text( me->form_ptr[0], EXP_WIDTH, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );

  		/* "WIDTH expname  = <%s>\n", text */
  		/* "WIDTH expvalue = <%f>\n", value*/
	
		VRBuildExp( &msg, ( IGRchar )EXP_DOUBLE, text, NULL, &value,
			    &me->expressions[2], &me->ModuleInfo  );

  		FIg_get_value( me->form_ptr[0],DEPTH, &value );
  		FIfld_get_text( me->form_ptr[0], EXP_DEPTH, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );

  		/* "DEPTH expname  = <%s>\n", text*/
  		/* "DEPTH expvalue = <%f>\n", value*/
	
		VRBuildExp( &msg, ( IGRchar )EXP_DOUBLE, text, NULL, &value,
			    &me->expressions[3], &me->ModuleInfo  );

  		FIg_get_value( me->form_ptr[0],NOZZLE_AIRFLOW, &value );
  		FIfld_get_text( me->form_ptr[0], EXP_AIR_FLOW, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );

  		/* "AIR_FLOW expname  = <%s>\n", text*/
  		/* "AIR_FLOW expvalue = <%f>\n", value*/
	
		VRBuildExp( &msg, ( IGRchar )EXP_DOUBLE, text, NULL, &value,
			    &me->expressions[4], &me->ModuleInfo  );
	
  		FIg_get_text( me->form_ptr[0], END_PREP, exp );
  		FIfld_get_text( me->form_ptr[0], EXP_END_PREP, 0, 0, 9, 
				(unsigned char *) text, &SelFlag, &r_pos );

  		/* "END_PREP expname  = <%s>\n", text */
  		/* "END_PREP expvalue = <%f>\n", exp  */
	
		VRBuildExp( &msg, ( IGRchar )EXP_TEXT, text, exp, NULL,
			    &me->expressions[5], &me->ModuleInfo  );
  	}
  } // if( !me->PidRep ) ends here

  if( me->Product == VR_PIPING )	VRNbNozAttr = VRPNbNozAttr;
  else if( me->Product == VR_HVAC )	VRNbNozAttr = VRHNbNozAttr;


  if( !me->ModifyCommand )  
  {
	struct 	GRas	   	assoc_list;
	struct 	ACcol_info  	SysParamFunc;


 	/*| -- Place collection to give expressions as parents -- */

	SysParamFunc.pl_fct_name[0] = '\0';
	
	if( !me->PidRep && (me->Product != VR_RWAY) )
	{
		if( me->Product == VR_PIPING )
			strcpy( SysParamFunc.cp_fct_name, "VRNozSysLink" );
		else if( me->Product == VR_HVAC )
			strcpy( SysParamFunc.cp_fct_name, "VRHNozSysLink" );

		assoc_list.as_attr        = ( IGRchar *) &SysParamFunc;
		assoc_list.num_parents    = VRNbNozAttr;
		assoc_list.go_objid.objid = NULL_OBJID;
		assoc_list.parents        = me->expressions;

		status =  NDduplicate_root(VRNbNozAttr,me->expressions);
		as$status(action = RET_STATUS);
	
		/*| -- Place system collection -- */
		status = 
		om$send( msg	   = message NDnode.NDplace
					( &assoc_list, &me->ModuleInfo, 
					       ( IGRchar * ) &ConstructionList),
		 	 senderid = NULL_OBJID,
		 	 targetid = me->SysParamId.objid,
		 	 targetos = me->SysParamId.osnum ) ;
		as$status ();
	}
	
/* -- Orient nozzle -- */
	{
		IGRmatrix	       Matrix;
		struct     ACrg_coll   scale_fact;
	        status =
	        om$send( msg      = message GRgencs.GRgetmatrix( &msg, Matrix ),
	            targetid = me->event1.located_object[0].located_obj.objid,
	            targetos = me->event1.located_object[0].located_obj.osnum );
	  	as$status ();
	  	as$status ( sts = msg );

		status =
		VR$OrientComp(  p_retmsg 	= &msg,
		          	p_CmpId		= &me->CreaCompId,
				Matrix		= Matrix,
		     	  	p_MdEnv		= &me->ModuleInfo);
	  	as$status ();
	  	as$status ( sts = msg );

	}


	/* -- Connect nozzle to CS -- */

	status = VR$PlaceNozz ( p_msg 		= &msg,
		          	p_ComponentId	= &me->CreaCompId,
		     	  	p_Instance	= &me->CompInstance,
			  	p_RefId		= &me->RefId,
		     	  	p_CnstList	= &ConstructionList,
		     	  	p_MdEnv		= &me->ModuleInfo);
  	as$status ();
  	as$status ( sts = msg );
  }
  else
  {
	IGRint		cn_type=ND_COMP, NbTemp;
	struct	GRid	list[VRPNbNozAttr];

	om$send( msg      = message NDnode.NDget_objects
				( ND_ROOT, list, VRNbNozAttr, NULL, 0,
				  OM_K_MAXINT, &NbTemp
				),
		 targetid = me->SysParamId.objid,
		 targetos = me->SysParamId.osnum );
	as$status();

	if ( NbTemp > 0 )
	{
   	  	om$send( msg      = message NDnode.NDchange_connect
				(  VRNbNozAttr, list, me->expressions ),
		 		targetid = me->SysParamId.objid,
		 		targetos = me->SysParamId.osnum );
		as$status();
	}
	
	nd$wait_batch( type       = GR_GEOM_POSTED,
                       l_object   = &me->NozzleId,
		       l_obj_info = &cn_type,
               	       nb_obj     = 1 );
  }

  if (! me->ModifyCommand )
    {
      if (!(status & 0x01))
	{
	  status = om$send ( msg 	    = message GRgraphics.GRdelete( &msg, &me->ModuleInfo),
			    senderid = my_id,
			    targetid = me->CreaCompId.objid,
			    targetos = me->CreaCompId.osnum);
	  as$status();

	  return OM_E_ABORT;
	}
      else 
	{
	  Mode = GRbd;
	  status = om$send( msg      = message GRgraphics.GRdisplay( &msg, 
								    &me->ModuleInfo.md_env.matrix_type,
								    me->ModuleInfo.md_env.matrix, 
								    &Mode, 
								    &me->ModuleInfo.md_id ),
			   targetid = me->CreaCompId.objid, 
			   targetos = me->CreaCompId.osnum );
	  as$status();

	/* ----- Place the new nozzle coll in the directory to be the active nozzle coll ----- */
	  VR$active_params( operation    = VR_REPLACE,
			   VRproduct    = me->Product,
			   mode 	       = VR_NOZZLE_MODE,
			   act_param_id = &me->SysParamId,
			   status       = status );
	  as$status( action = RET_STATUS );
	
	/* ----- Initialization for another placement ----- */
	  me->CreaCompId.objid 	  = NULL_OBJID;
	  me->SysParamId.objid 	  = NULL_OBJID;
	  me->UserParamId.objid 	  = NULL_OBJID;
	  me->MissingParamsId.objid = NULL_OBJID;
	  me->NozzleId.objid	  = NULL_OBJID;
	  me->NbMissing		  = 0;
	  me->Init		  = TRUE;
	}
    }
  if ( me->ModifyCommand ) 
  {
	FIf_erase( me->form_ptr[0] );
	FIf_erase( me->form_ptr[1] );
  }

  if( me->form_ptr[0] ) FIg_erase(me->form_ptr[0], MISSING_GRP);

  End	
return	OM_S_SUCCESS;

} /* end method VRInsertNozzle */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VRUpdateMissing
{
  IGRlong			rc;
  struct 	ACrg_coll       VRattributes[VR_MAX_ATTR];
  IGRint			NbMissing;
  IGRint			sel_flag = 0, row;

  /* 
   * In the case of Raceway Nozzle we're not supposed to have any Missing 
   * Pararmeters during the Evaluation time. Because we ourselves have created 
   * the needed params in the Missing Params Collector ( which are nothing but 
   * params needed for the Grpahics construction ( d1, b1, t1, etc ). No 
   * surprises accepted and they don't have to displayed and they won't be 
   * processed. This is expectation from the Customer. For more information 
   * regarding this contact Rod Banach. Alwin
   */ 
  if( me->Product == VR_RWAY ) return OM_S_SUCCESS;

  /*"MissingParamsId = %d \n", me->MissingParamsId.objid*/

  if( me->MissingParamsId.objid == NULL_OBJID ) return OM_S_SUCCESS;

  if( me->ModifyCommand && ( !(me->CompInstance.nStatus & VR_OUT_MACRO) ) )
  {
	/*| --- nozzle in macro --- */
	FIg_erase( me->form_ptr[0], MISSING_GRP );
	return OM_S_SUCCESS;
  }

  status = om$send( msg = message ACrg_collect.AClist_attribute( &rc,VR_MAX_ATTR, VRattributes,
                                                        	 &NbMissing ),
                senderid = NULL_OBJID,
                targetid = me->MissingParamsId.objid,
                targetos = me->MissingParamsId.osnum );
  as$status( action = RET_STATUS );

  if ( NbMissing && !me->NbMissing )	me->NbMissing = NbMissing;

  /*| ----- Fill form for missing Parameters ----- */
  for ( row = 0; row< NbMissing; row++ )
  {
     /* init missing attribute name */
     FIfld_set_text(  me->form_ptr[0], MISSING, row, 0, VRattributes[row].name, sel_flag );

     /* init missing exp name */
     FIfld_set_text(  me->form_ptr[0], MISSING, row, 2, "", sel_flag );

     if ( VRattributes[row].desc.type == AC_ATTRIB_DOUBLE )
     {
	FIfld_set_value(  me->form_ptr[0], MISSING, row, 1, VRattributes[row].desc.value.att_exp,
 			  sel_flag );
     }
     else if ( VRattributes[row].desc.type == AC_ATTRIB_TEXT )
     {
	FIfld_set_text( me->form_ptr[0], MISSING, row, 1, VRattributes[row].desc.value.att_txt, sel_flag );
     }
  }

  me->MissingChange = TRUE;

  FIg_display( me->form_ptr[0], MISSING_GRP);

}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VRGetRef
{
  IGRlong		msg;
  IGRint		NbChild, i;
  GRclassid     	obj_class;
  struct GRid		RefId, *ChildId;
  extern GRclassid	OPP_VRNozzle_class_id;

  me->ret = VRALL_OK;

  /* ----- Get located referencial and create a source to work on ----- */
  RefId	= me->event1.located_object[0].located_obj;

  status = as$make_source( go_grid      = RefId,
                	   mod_env 	= &me->event1.located_object[0].module_info,
			   as_os        = me->ModuleInfo.md_id.osnum,
                	   as_grid      = &me->RefId);
  as$status ();

  /*"ASsource Located Ref Id  = %d/%d\n", me->RefId.objid, me->RefId.osnum*/
  
  status = dp$erase_hilite ( msg   = &msg,
			     osnum = me->ModuleInfo.md_id.osnum);

  /*| ----- See if a nozzle is already connected to located referencial ----- */
  NbChild = 0;
  status = om$send( msg      = message NDnode.NDget_objects( ND_CHILDREN | ND_IN_BUF, NULL, 0, 
							     &ChildId, 0, OM_K_MAXINT, &NbChild 
							   ),
                      targetid =  me->RefId.objid,
		      targetos =  me->RefId.osnum);
  as$status();
  /*"Nb Child = %d \n",NbChild*/

  for( i=0; i<NbChild; i++ )
  {
        /*"nozzle Id = %d %d\n", ChildId[i].objid,  ChildId[i].osnum*/
	status = om$get_classid( osnum     = ChildId[i].osnum,
                                 objid     = ChildId[i].objid,
                               	 p_classid = &obj_class );

      	if( om$is_ancestry_valid( subclassid   = obj_class,
            			  superclassid = OPP_VRNozzle_class_id ) == OM_S_SUCCESS )
	{	
		ex$message( field   = ERROR_FIELD,
			    msgnumb = VR_E_InvalidReferencial );
		me->ret = VRNOT_OK;
	}
  }

   return OM_S_SUCCESS;
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VRDeleteNozzle
{
  IGRlong	msg;

  /*| Delete Component */
  /* This check is very much necessary, B'cas when the user REJECTS/MOVES ON
     when the form is up; control comes here to Delete the nozzle. By that
     time it wasn't created. This leads to UNIX window errors.-Alwin*/
  if( me->CreaCompId.objid != NULL_OBJID )
  {
      status = om$send ( msg      = message GRgraphics.GRdelete ( 
                                            &msg, &me->ModuleInfo ),
		     senderid = my_id,
		     targetid = me->CreaCompId.objid,
		     targetos = me->CreaCompId.osnum);
      as$status ();
  }

  if ( me->MissingParamsId.objid != NULL_OBJID )
  {
  	/*| Delete Missing */
  	status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
		    	  targetid = me->MissingParamsId.objid,
		    	  targetos = me->MissingParamsId.osnum);
  	as$status( action = RET_STATUS );
  }

  me->CreaCompId.objid 	    = NULL_OBJID;
  me->MissingParamsId.objid = NULL_OBJID;

  return OM_S_SUCCESS;
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action delete
{
  IGRlong msg, sts;

  SetProc( VRPlNozzle_delete ); Begin

  if (!(me->VDB_terminated))
  {
  if(  me->form_ptr[0] != NULL ){
    FIf_get_location( me->form_ptr[0], &X_FormPosition, &Y_FormPosition );
    FIf_get_screen( me->form_ptr[0], &ScreenFormNumber );
    /*"X_FormPosition = %d\n", X_FormPosition */
    /*"Y_FormPosition = %d\n", Y_FormPosition */
    FIf_erase ( me->form_ptr[0] );
  }

  if( me->form_ptr[1] != NULL )
  	FIf_erase ( me->form_ptr[1] );

  if( me->FormUser != NULL )
	FIf_erase ( me->FormUser );

  /*| get form configuration */
  
  if( me->CreaCompId.objid != NULL_OBJID )
  {
	/*| Delete Component */
  	status =
	om$send ( msg      = message GRgraphics.GRdelete ( &msg, &me->ModuleInfo),
		     senderid = my_id,
		     targetid = me->CreaCompId.objid,
		     targetos = me->CreaCompId.osnum);
  	as$status ();
  }
  }

  sts = om$send ( mode     = OM_e_wrt_message,
		  msg      = message CEO_LOCATE.delete( f_defer_flag),
		  targetid = my_id);
  as$status( sts = sts, action = RET_STATUS );

  End 
  return OM_S_SUCCESS;
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action wakeup
{

  struct ACrg_coll PidScale;
  IGRlong  msg;

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message CEO_LOCATE.wakeup( pos ),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  if (me->VDB_terminated) goto quit;

  if ( !me->ModifyCommand )
    {
      if ( bVR_IS_PID_ACTIVE )
	{
	  VRInitNozPid( &me->SysParamId, me->Product, &me->ModuleInfo); 
	  strcpy( PidScale.name, VR_N_PID_SCALE_DB);

	  /* get current PID scale factor */
	  status = om$send( msg = 
			   message ACrg_collect.ACget_named_attribute
			   ( &msg, &PidScale ),
			   senderid = NULL_OBJID,
			   targetid = me->SysParamId.objid,
			   targetos = me->SysParamId.osnum);
	  
	  FIfld_set_value( me->form_ptr[0], NOZ_PID_SCALE, 0, 0, PidScale.desc.value.att_exp, FALSE);
	  FIg_display( me->form_ptr[0], NOZ_PID_SCALE_TXT);
	  FIg_display(me->form_ptr[0],NOZ_PID_SCALE);
	  me->PidRep = TRUE;
	  
	}
      else
	{
	  FIg_erase( me->form_ptr[0], NOZ_PID_SCALE);
	  FIg_erase( me->form_ptr[0], NOZ_PID_SCALE_TXT);
	}
    }
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
  
action VREraseNozzle
{
   /* added by alwin ...to prevent the phantom nozzles appearing on the screen.
  This problem can be reproduced when, there is nothing on the screen; and when
  you try to Place a Nozzle, Initially after evaluation the nozzle is
  temporarily placed at the Base Co-ordinates System. And you can see the
  small graphics on the screen which on fitting will occupy  the whole screen;
  which the CERT people call it a Phantom Nozzle. Alwin */
 
  /* As this graphics is of no use and moreover it leads to confusion, so it's
  display can be erased */
 
  __DBGpr_obj( " Created Nozzle Id ",  me->CreaCompId );
 
  if( me->CreaCompId.objid != NULL_OBJID )
  {
      IGRshort  action, props;
      IGRlong   retcode;
 
        props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        action = 0;
        status = om$send ( msg = message GRgraphics.GRchgprops(
                                                &retcode,
                                                &action,
                                                &props ),
                           targetid = me->CreaCompId.objid,
                           targetos = me->CreaCompId.osnum );
        as$status();
  }
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

action VRRwayNozzFN( IGRlong *msg; IGRint gadget_label; IGRchar *form_ptr )
{
   IGRint			i, j, row, col, selflag;
   IGRint			ListSize;
   IGRshort			vendor_no, NbRows;
   IGRdouble			dValue, dValue_depth, *SizeList=NULL;
   IGRchar			szText[20];
   struct VRRDB_rwaynozz	*RwSpec=NULL;

   SetProc( Md VRRwayNozzFN ); Begin 

   *msg = MSFAIL;

   // Main Form
   if( form_ptr == me->form_ptr[0] )
   {
      IGRshort	nShape =-1;

      ListSize = 0;
      FIg_get_text( form_ptr, SPEC_NAME, szText );
      __DBGpr_str( " Vendor Name ", szText );

      FIg_set_text( form_ptr, MESSAGE, "Processing ... " );
      status = VR$RDB_SNUM(	p_nam	= szText,
				p_num	= &vendor_no );

      __DBGpr_int( " Vendor No. ", vendor_no );

      NbRows = 0;
      status = VR$RDA_RWAYNOZZ(
		      p_msg	= msg,
		      p_num	= &NbRows,
		      p_ptr 	= &RwSpec );

      switch( gadget_label )
      {
	  case SPEC_NAME:
	  {
		IGRint		ShapeList[10]; //assuming 

		for( i=0; i<NbRows; i++ )
		{
		   if( RwSpec[i].vendor_no == vendor_no )
		   {
		      IGRboolean	bFound = FALSE;

		      for( j=0; j<ListSize && !bFound; j++ )
		      {
			if( fabs(RwSpec[i].shape-ShapeList[j]) < BSBASISVAL )
			  bFound = TRUE;
		      }

		      if( !bFound )
		      {
			ShapeList[ListSize] = RwSpec[i].shape;

			if( ShapeList[ListSize] == VR_RECT ) 
				strcpy( szText, "Rectangular" );
			else if( ShapeList[ListSize] == VR_OVAL ) 
				strcpy( szText, "Oval" );
			else if( ShapeList[ListSize] == VR_CIRC ) 
				strcpy( szText, "Circular" );
			else if( ShapeList[ListSize] == VR_CORNER ) 
				strcpy( szText, "Corner Radius" );
			else if( ShapeList[ListSize] == VR_ELLIPSE ) 
				strcpy( szText, "Ellipse" );
			VDfld_set_list_text( form_ptr, RWAY_NOZ_SHAPE, 
						ListSize, 0, szText, FALSE);
			ListSize++;
		      }
		   }
		}
		FIfld_set_list_num_rows(form_ptr, RWAY_NOZ_SHAPE, 0, ListSize );

		FIg_enable( form_ptr, RWAY_NOZ_SHAPE );
		FIg_disable( form_ptr, RWAY_NOZ_WIDTH );
		FIg_disable( form_ptr, RWAY_NOZ_DEPTH );
		FIg_disable( form_ptr, RWAY_NOZ_MACRONAME );
		FIg_disable( form_ptr, TAG_NUMBER );
		FIg_set_text( form_ptr, MESSAGE, "Select Nozzle Shape" );
		break;
	  }

	  case RWAY_NOZ_SHAPE:
		FIg_get_text( form_ptr, gadget_label, szText );

		if( 	!strcmp( szText, "Rectangular"))nShape = VR_RECT;
		else if(!strcmp( szText, "Oval" ) ) 	nShape = VR_OVAL;
		else if(!strcmp( szText, "Circular" ) ) nShape = VR_CIRC;
		else if(!strcmp( szText, "Corner Radius" ) ) nShape = VR_CORNER;
		else nShape = VR_ELLIPSE; 

		SizeList = _MALLOC( NbRows, IGRdouble );
		__CheckPtr( SizeList, "Memory Allocation failed", quit );

		for( i=0; i<NbRows; i++ )
		{
		   if( 	( RwSpec[i].vendor_no == vendor_no ) &&
			( RwSpec[i].shape == nShape ) )
		   {
		      IGRboolean	bFound = FALSE;

		      for( j=0; j<ListSize && !bFound; j++ )
		      {
			if( fabs(RwSpec[i].width-SizeList[j]) < VRGetTol(VR_DIST_TOL) )
			  bFound = TRUE;
		      }

		      if( !bFound )
		      {
			__DBGpr_int( " List Size ", ListSize );
			SizeList[ListSize] = RwSpec[i].width;
			__DBGpr_dbl( " Width ", SizeList[ListSize] );
			sprintf( szText, "%f", SizeList[ListSize] );
			VDfld_set_list_text( form_ptr, RWAY_NOZ_WIDTH, 
						ListSize, 0, szText, FALSE);
			ListSize++;
		      }
		   }
		} // i loop ends here

		__DBGpr_int( " WIDTH - List Size ", ListSize );
		if( ListSize > 0 ) 
		{ 
		  FIg_enable( form_ptr, RWAY_NOZ_WIDTH );
		  FIg_set_text( form_ptr, MESSAGE, "Select Nozzle Width" );
		} 

		FIfld_set_list_num_rows(form_ptr, RWAY_NOZ_WIDTH, 0, ListSize );
	        _FREE( SizeList );

		FIg_disable( form_ptr, RWAY_NOZ_DEPTH );
		FIg_disable( form_ptr, RWAY_NOZ_MACRONAME );
		FIg_disable( form_ptr, TAG_NUMBER );
		break;

          case RWAY_NOZ_WIDTH:
		FIg_get_text( form_ptr, RWAY_NOZ_SHAPE, szText );

                if(     !strcmp( szText, "Rectangular"))nShape = VR_RECT;
                else if(!strcmp( szText, "Oval" ) )     nShape = VR_OVAL;
                else if(!strcmp( szText, "Circular" ) ) nShape = VR_CIRC;
                else if(!strcmp( szText, "Corner Radius" ) ) nShape = VR_CORNER;
                else nShape = VR_ELLIPSE; //Ellipse

                FIg_get_text( form_ptr, RWAY_NOZ_WIDTH, szText );
		dValue = atof( szText );

		__DBGpr_dbl( " Width Value ", dValue );
		__DBGpr_int( " Shape Code ", nShape );

		// Check for circularity. If the shape happens to be Circular
		// then we shouldn't allow the user to select depth.
		//	DEPTH = WIDTH
		if( nShape == VR_CIRC )
		{
		   FIg_set_text( form_ptr, RWAY_NOZ_DEPTH, szText );
		   FIfld_set_list_num_rows(form_ptr, RWAY_NOZ_DEPTH, 0, 0 );
		   FIg_enable( form_ptr, TAG_NUMBER );
		   FIg_enable( form_ptr, FI_ACCEPT );
		   break;
		}

		SizeList = _MALLOC( NbRows, IGRdouble );
		__CheckPtr( SizeList, "Memory Allocation failed", quit );

                for( i=0; i<NbRows; i++ )
                {
                   if(  ( RwSpec[i].vendor_no == vendor_no ) &&
                        ( RwSpec[i].shape == nShape ) &&
			( fabs(RwSpec[i].width - dValue) < VRGetTol(VR_DIST_TOL) ) )
                   {
		      IGRboolean	bFound = FALSE;

		      for( j=0; j<ListSize && !bFound; j++ )
		      {
			if( fabs(RwSpec[i].depth-SizeList[j]) < VRGetTol(VR_DIST_TOL) )
			  bFound = TRUE;
		      }

		      if( !bFound )
		      {
			__DBGpr_int( " List Size ", ListSize );
			SizeList[ListSize] = RwSpec[i].depth;
			__DBGpr_dbl( " Depth ", RwSpec[i].depth );
			sprintf( szText, "%f", SizeList[ListSize] );
			VDfld_set_list_text( form_ptr, RWAY_NOZ_DEPTH, 
						ListSize, 0, szText, FALSE);
			ListSize++;
		      }
                   }
                } // i loop ends here
	        _FREE( SizeList );

		__DBGpr_int( " DEPTH - List Size ", ListSize );

		if( ListSize > 0 ) 
		{ 
		  FIg_enable( form_ptr, RWAY_NOZ_DEPTH );
		  FIg_set_text( form_ptr, MESSAGE, "Select Nozzle Depth" );
		} 

		FIfld_set_list_num_rows(form_ptr, RWAY_NOZ_DEPTH, 0, ListSize );

		FIg_disable( form_ptr, TAG_NUMBER );
                break;

          case RWAY_NOZ_DEPTH:
                FIg_get_text( form_ptr, gadget_label, szText );
		dValue_depth = atof( szText );
                FIg_get_text( form_ptr, RWAY_NOZ_WIDTH, szText );
		dValue = atof( szText );
		FIg_get_text( form_ptr, RWAY_NOZ_SHAPE, szText );

		if( dValue_depth < VRGetTol(VR_DIST_TOL) ) break;

                if(     !strcmp( szText, "Rectangular"))nShape = VR_RECT;
                else if(!strcmp( szText, "Oval" ) )     nShape = VR_OVAL;
                else if(!strcmp( szText, "Circular" ) ) nShape = VR_CIRC;
                else if(!strcmp( szText, "Corner Radius" ) ) nShape = VR_CORNER;
                else nShape = VR_ELLIPSE; //Ellipse

                for( i=0; i<NbRows; i++ )
                {
                   if(  ( RwSpec[i].vendor_no == vendor_no ) &&
                        ( RwSpec[i].shape == nShape ) &&
			( fabs(RwSpec[i].width - dValue) < VRGetTol(VR_DIST_TOL) )  &&
			( fabs(RwSpec[i].depth - dValue_depth) < VRGetTol(VR_DIST_TOL) ) )
                   {
			FIg_enable( form_ptr, TAG_NUMBER );
			FIg_enable( form_ptr, FI_ACCEPT );
			break;
                   }
                } // i loop ends here
		FIg_set_text( form_ptr, MESSAGE, "" );
		break;

	  case FI_CANCEL:
		me->SystemChange = FALSE;
		FIf_erase( me->FormUser );
		FIf_erase( me->form_ptr[1] );
		FIf_erase( me->form_ptr[0] );
		_put_response( resp = TERMINATE );
		break;

//	  When the user checks form we need to fetch the selected nozzle's
//	  Remaining parameters from the DB and update the missing parameters
//	  collection, so that evalutaion won't complain about them and instead
//	  would proceed further with the placement. 
	  
//	  For the future, in case if the Customer modified the Database layout
//	  we need to modify the Structure so that Cache content would be valid 
//	  and also modification  is required in the Missing Params collection 
//	  as done below. 

	  case FI_ACCEPT:
		me->SystemChange = TRUE;
                FIg_get_text( form_ptr, RWAY_NOZ_DEPTH, szText );
                dValue_depth = atof( szText );

		if( dValue_depth < VRGetTol(VR_DIST_TOL) ) 
		{
		  FIg_set_text( form_ptr, MESSAGE, "Depth not specified" );
		  break;
		}

                FIg_get_text( form_ptr, RWAY_NOZ_WIDTH, szText );
                dValue = atof( szText );

		if( dValue < VRGetTol(VR_DIST_TOL) ) 
		{
		  FIg_set_text( form_ptr, MESSAGE, "Width not specified" );
		  break;
		}

		szText[0] = '\0';
                FIg_get_text( form_ptr, RWAY_NOZ_SHAPE, szText );

		if( szText == '\0' || ( strcmp(szText, " ") == 0 ) )
		{
		  FIg_set_text( form_ptr, MESSAGE, "Shape not specified" );
		  break;
		}

                if(     !strcmp( szText, "Rectangular"))nShape = VR_RECT;
                else if(!strcmp( szText, "Oval" ) )     nShape = VR_OVAL;
                else if(!strcmp( szText, "Circular" ) ) nShape = VR_CIRC;
                else if(!strcmp( szText, "Corner Radius" ) ) nShape = VR_CORNER;
                else nShape = VR_ELLIPSE; //Ellipse

		if( nShape == VR_CIRC )dValue_depth = 0.0; //Circular: depth = 0

                for( i=0; i<NbRows; i++ )
                {
                   if(  ( RwSpec[i].vendor_no == vendor_no ) &&
                        ( RwSpec[i].shape == nShape ) &&
                        ( fabs(RwSpec[i].width - dValue) < VRGetTol(VR_DIST_TOL) )  &&
                        ( fabs(RwSpec[i].depth - dValue_depth) < VRGetTol(VR_DIST_TOL) ) )
                   {
		      IGRlong			NbAttr=4;
		      struct ACrg_coll		ListAttr[10];

		      strcpy( ListAttr[0].name, "d1" );
		      ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[0].desc.value.att_exp = RwSpec[i].d1;

		      strcpy( ListAttr[1].name, "t1" );
		      ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[1].desc.value.att_exp = RwSpec[i].t1;

		      strcpy( ListAttr[2].name, "b1" );
		      ListAttr[2].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[2].desc.value.att_exp = RwSpec[i].b1;

		      strcpy( ListAttr[3].name, "f1" );
		      ListAttr[3].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[3].desc.value.att_exp = RwSpec[i].f1;

		      me->MissingParamsId.osnum = me->ModuleInfo.md_id.osnum;
		      status = om$construct(   
				classid = OPP_ACdyn_col_class_id,
				p_objid = &me->MissingParamsId.objid,
				osnum   = me->MissingParamsId.osnum,
		           	msg = message NDnode.NDchg_state
					( ~0, ND_DEL_NO_CH ) );
		      as$status( action = RET_STATUS );

		      status =
		      om$send( msg = message ACrg_collect.ACset_list_attribute
				     ( msg, NbAttr, ListAttr ),
			       senderid = NULL_OBJID,
			       targetid = me->MissingParamsId.objid,
			       targetos = me->MissingParamsId.osnum );
		      as$status( action = RET_STATUS );

		      FIf_erase( me->FormUser );
		      FIf_erase( me->form_ptr[1] );
		      FIf_erase( me->form_ptr[0] );
		      _put_response( resp = EX_FORM_FINISHED );
		      End
		      return OM_S_SUCCESS;
                   }
                } // i loop ends here
		break;

	  case RESET_BTN:
	  case FI_RESET:
		__DBGpr_com( " Initializes the form " );
                /*** should have crashed here-msg was being passed as value
                     instead of a pointer                         ***/
		status = 
		om$send( msg = message VRPlNozzle.VRRwInitMainForm( msg ),
					targetid = my_id );
		break;

	  case NOZZLE_ATTR:
		  FIbtn_set_auto_pop_up_off( form_ptr, gadget_label );
		  if( me->form_ptr[1]  != NULL )
			  FIf_display ( me->form_ptr[1] );
	  break;

	  case USER_ATTR:
		  FIf_display( me->FormUser );
	  break;

          default:
		FIg_set_text( form_ptr, MESSAGE, "" );
		__DBGpr_com( " Unknown gadget - Do nothing " );
		break;
      }
   } // form_ptr == me->form_ptr[0] loops ends here
   else if( form_ptr == me->form_ptr[1] )
   {
      switch( gadget_label )
      {
	  case FI_CANCEL:
	  case FI_ACCEPT:
		me->SystemChange = TRUE;
		FIf_erase( me->form_ptr[1] );
		FIbtn_set_auto_pop_up_on( me->form_ptr[0], NOZZLE_ATTR );
		break;

          default:
		__DBGpr_com( " Unknown gadget - Do nothing " );
		break;
      }
   }// form_ptr == me->form_ptr[1] loops ends here

   End
}

action VRRwInitAttrForm( IGRlong *msg )
{
    IGRint			i;
    IGRshort			NbRows=0;
    IGRshort			spec_no;
    IGRshort			ListSize=0;
    IGRshort 			NumCDL=0;
    IGRlong			retcode=MSSUCC;
    struct VRRDB_cdl		*CodeList=NULL;

    SetProc( Md VRRwInitAttrForm ); Begin 

    /* 
     * To initialization of Raceway Nozzle Attributes Form Gadgets 
     */

    // Populate the SYSTEM class from CL 125
    status = VR$RDB_CDL( p_msg = &retcode,
                         nlist = VR_R_SYSTEM_CLASS_LSTNUM,
                         p_num = &NumCDL);

    __DBGpr_int( " No. of Codelist entries for 125", NumCDL );

    if( NumCDL > 0 )
    {
        FIfld_set_list_num_rows( me->form_ptr[1], SYSTEM, 0, NumCDL );

        CodeList =  _MALLOC( NumCDL, struct VRRDB_cdl );
	__CheckPtr( CodeList, "Memory Allocation failed", quit );

        VR$RDB_CDL( p_msg = &retcode,
                        nlist = VR_R_SYSTEM_CLASS_LSTNUM,
                        p_num = &NumCDL,
                        p_rec = CodeList );

        for( i=0; i<NumCDL; i++ )
        {
            __DBGpr_str( " Code List Short Text ", CodeList[i].stxt );
            VDfld_set_list_text( me->form_ptr[1], SYSTEM_NAME, i, 0,
                                 CodeList[i].stxt, FALSE);
        }
        _FREE( CodeList );
    }

    // Populate the MATERIAL class from CL 145
    NumCDL = 0;
    status = VR$RDB_CDL( p_msg = &retcode,
			 nlist = VR_R_MATERIAL_CLASS_LSTNUM,
			 p_num = &NumCDL);

    __DBGpr_int( " No. of Codelist entries for 145", NumCDL );

    if( NumCDL > 0 )
    {
	FIfld_set_list_num_rows( me->form_ptr[1], RWAY_NOZ_TRAY_MATERIAL, 
				0, NumCDL );

	CodeList =  _MALLOC( NumCDL, struct VRRDB_cdl );
	__CheckPtr( CodeList, "Memory Allocation failed", quit );

	VR$RDB_CDL( p_msg = &retcode,
			nlist = VR_R_MATERIAL_CLASS_LSTNUM,
			p_num = &NumCDL,
			p_rec = CodeList );

	for( i=0; i<NumCDL; i++ )
	{
	    __DBGpr_str( " Code List Long Text ", CodeList[i].ltxt );
	    VDfld_set_list_text( me->form_ptr[1], RWAY_NOZ_TRAY_MATERIAL, i, 0,
				 CodeList[i].ltxt, FALSE);
	}
	_FREE( CodeList );
    }

    End
}

action VRRwInitMainForm( IGRlong *msg )
{
    IGRint			i, j, *SpecList=NULL;
    IGRshort			NbRows=0;
    IGRshort			spec_no;
    IGRshort			ListSize=0;
    IGRlong			retcode;
    struct VRRDB_rwaynozz	*RwSpec=NULL;

    SetProc( Md VRRwInitMainForm ); Begin 

    /*
     * To initialization of Raceway Nozzle Main Form Gadgets 
     */
    status = VR$RDA_RWAYNOZZ ( 	p_num = &NbRows,
				p_msg = &retcode,
				p_ptr = &RwSpec );

    as$status( action = RET_STATUS );
    if( !retcode & 1 )
    {
       *msg = MSFAIL;
       __DBGpr_com( "Raceway Nozzle Table not found" );
       UI_status( "Raceway Nozzle Table not found" );
       End
       return OM_E_ABORT;
    }

    if( NbRows > 0 )
    {
	SpecList = _MALLOC( NbRows, IGRint );
	__CheckPtr( SpecList, "Memory Allocation failed", quit );
    }

    for( i=0; i<NbRows; i++ )
    {
      IGRboolean        bFound = FALSE;
      IGRchar           spec_name[10];

      for( j=0; j<ListSize && !bFound; j++ )
      {
        if( RwSpec[i].vendor_no == SpecList[j] )
          bFound = TRUE;
      }

      if( !bFound )
      {
	SpecList[ListSize] = RwSpec[i].vendor_no;

        // Get the Spec_Name corresponding to this spec_no
        status = VR$RDB_SNAM(   num = RwSpec[i].vendor_no,
                                p_nam = spec_name );
        __DBGpr_str( " Vendor Name ", spec_name );

        VDfld_set_list_text( me->form_ptr[0], SPEC_NAME, ListSize, 0,
                                spec_name, FALSE);
        ListSize++;
      }
    }
    _FREE( SpecList );
    FIfld_set_list_num_rows( me->form_ptr[0],  SPEC_NAME, 0, ListSize );

    if( ListSize > 0 ) 
	FIg_set_text( me->form_ptr[0], MESSAGE, "Select Vendor Code" );

    if( me->ModifyCommand )
    {
	IGRint			nb_of_attributes=0;
	IGRlong			retcode;
	struct ACrg_coll      	attributes[VR_MAX_ATTR];

	status = om$send( msg      = message ACrg_collect.AClist_attribute
		      ( &retcode, VR_MAX_ATTR, attributes, &nb_of_attributes ),
			  senderid = me->SysParamId.objid,
			  targetid = me->SysParamId.objid,
			  targetos = me->SysParamId.osnum) ;
	as$status( action = RET_STATUS ) ;

	for( i=0; i<nb_of_attributes; i++ )
	{
	     if ( !strcmp( attributes[i].name, VR_N_TAG_NUMBER_AN ))
		FIg_set_text( me->form_ptr[0], TAG_NUMBER, 
			attributes[i].desc.value.att_txt );

	     if ( !strcmp( attributes[i].name, VR_N_CLASS_AN ))
	        FIg_set_text( me->form_ptr[0], SPEC_NAME,
				attributes[i].desc.value.att_txt );
	  
	     if ( !strcmp( attributes[i].name, VR_N_SHAPE_IN ))
	     {
		 IGRshort	nShape=-1;
		 IGRchar	szShape[15];

		 nShape = (IGRshort) attributes[i].desc.value.att_exp;

		 if( nShape == VR_RECT ) strcpy( szShape, "Rectangular" );
		 else if( nShape == VR_OVAL ) strcpy( szShape, "Oval" );
		 else if( nShape == VR_CIRC ) strcpy( szShape, "Circular" );
		 else if( nShape == VR_CORNER )strcpy( szShape,"Corner Radius");
		 else strcpy( szShape, "Ellipse" );

		 FIg_set_text( me->form_ptr[0], RWAY_NOZ_SHAPE, szShape );
	     }

	     if ( !strcmp( attributes[i].name, VR_N_WIDTH1_DB))
		     FIg_set_value( me->form_ptr[0], RWAY_NOZ_WIDTH, 
			     attributes[i].desc.value.att_exp);

	     if ( !strcmp( attributes[i].name, VR_N_DEPTH1_DB))
		     FIg_set_value( me->form_ptr[0], RWAY_NOZ_DEPTH, 
			     attributes[i].desc.value.att_exp);

	     if ( !strcmp( attributes[i].name, VR_N_APPRV_STAT_AN))
		     FIg_set_text( me->form_ptr[0], APPRV_STS,
			     attributes[i].desc.value.att_txt );

	     if ( !strcmp( attributes[i].name, VR_N_CONSTR_STAT_AN))
		     FIg_set_text( me->form_ptr[0], CONST_STS,
			     attributes[i].desc.value.att_txt );
	}
	FIg_set_text( me->form_ptr[0], MESSAGE, "Modify Parameters..." );
        FIg_erase( me->form_ptr[0],  PLC_RWAY_NOZ );
        FIg_display( me->form_ptr[0],  MOD_RWAY_NOZ );
    }
    else
    {
	FIg_disable( me->form_ptr[0], TAG_NUMBER );
	FIg_disable( me->form_ptr[0], RWAY_NOZ_MACRONAME );
	FIg_disable( me->form_ptr[0], RWAY_NOZ_DEPTH );
	FIg_disable( me->form_ptr[0], RWAY_NOZ_WIDTH );
	FIg_disable( me->form_ptr[0], RWAY_NOZ_SHAPE );

        FIg_display( me->form_ptr[0],  PLC_RWAY_NOZ );
        FIg_erase( me->form_ptr[0],  MOD_RWAY_NOZ );
    }

    End
}
