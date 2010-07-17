/*$Id: VRform.I,v 1.6 2001/04/17 23:03:26 anand Exp $  */

/* I/ROUTE
 *
 * File:        vrchgattr/VRform.I
 *
 * Description:
 *
 *	Implementation file for method initial_form_notification and 
 *	form_notification for the command Modify Component Design Parameters.
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRform.I,v $
 *	Revision 1.6  2001/04/17 23:03:26  anand
 *	JTS TR MP 4485
 *	
 *	Revision 1.5  2001/03/11 23:29:18  louis
 *	repaired tr3367 missing params so it remembers modifications
 *	
 *	Revision 1.4  2001/02/20 01:12:06  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.3  2001/02/09 17:24:15  louis
 *	TR3367-add missing params to additional param form
 *	
 *	Revision 1.2  2001/01/11 22:40:12  anand
 *	SP merge
 *	
# Revision 1.7  2000/11/27  17:20:42  pinnacle
# Replaced: route/vrchgattr/VRform.I for:  by aharihar for Service Pack
#
# Revision 1.6  2000/08/16  19:51:22  pinnacle
# Replaced: route/vrchgattr/VRform.I for:  by apazhani for Service Pack
#
# Revision 1.5  2000/07/21  13:42:52  pinnacle
# Replaced: route/vrchgattr/VRform.I for:  by apazhani for Service Pack
#
# Revision 1.4  2000/07/13  22:53:06  pinnacle
# Replaced: route/vrchgattr/VRform.I for:  by apazhani for Service Pack
#
# Revision 1.3  2000/06/27  21:11:54  pinnacle
# Replaced: route/vrchgattr/VRform.I for:  by lawaddel for Service Pack
#
# Revision 1.2  2000/05/11  22:17:42  pinnacle
# Replaced: route/vrchgattr/VRform.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/10  16:04:14  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.17  2000/03/20  17:14:50  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.16  2000/02/04  18:25:36  pinnacle
# (No comment)
#
# Revision 1.15  1999/11/05  19:59:36  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.14  1999/08/04  06:05:46  pinnacle
# Replaced: vrchgattr/VRform.I for: TR 179900778 by aharihar for route
#
# Revision 1.13  1999/07/22  21:38:10  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.12  1999/06/14  20:56:16  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.11  1999/05/21  09:56:06  pinnacle
# Replaced: vrchgattr/VRform.I for:  by sbilla for route
#
# Revision 1.10  1999/05/14  22:14:00  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.9  1999/05/11  04:49:46  pinnacle
# Replaced: vrchgattr/VRform.I for:  by sbilla for route
#
# Revision 1.8  1999/05/07  21:22:28  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.7  1999/05/03  18:32:58  pinnacle
# Replaced: vrchgattr/VRform.I for:  by apazhani for route
#
# Revision 1.6  1999/05/03  13:31:10  pinnacle
# Replaced: vrchgattr/VRform.I for:  by sbilla for route
#
# Revision 1.5  1998/11/06  22:44:44  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.4  1998/08/05  16:00:04  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.3  1998/06/26  22:57:18  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.2  1998/05/20  21:16:16  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.4  1998/04/25  18:56:22  pinnacle
# Replaced: vrchgattr/VRform.I for:  by kddinov for route
#
# Revision 1.3  1998/04/22  19:23:48  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.2  1998/01/14  18:30:16  pinnacle
# Replaced: vrchgattr/VRform.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1996/08/20  06:13:30  pinnacle
# Replaced: vrchgattr/VRform.I for:  by ashankar for route
#
# Revision 1.2  1996/08/19  09:18:14  pinnacle
# Replaced: vrchgattr/VRform.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.11  1996/05/22  13:37:58  pinnacle
# Replaced: vrchgattr/VRform.I for:  by hverstee for route240
#
# Revision 1.10  1996/05/14  22:47:20  pinnacle
# Replaced: vrchgattr/VRform.I for:  by hverstee for route240
#
# Revision 1.9  1996/04/24  14:24:40  pinnacle
# Replaced: vrchgattr/VRform.I for:  by ashankar for route240
#
# Revision 1.7  1996/04/04  16:57:54  pinnacle
# Replaced: vrchgattr/VRform.I for:  by r240_int for route240
#
# Revision 1.6  1996/03/13  22:18:12  pinnacle
# Replaced: vrchgattr/VRform.I for:  by hverstee for route240
#
# Revision 1.5  1996/02/29  11:44:28  pinnacle
# Replaced: vrchgattr/VRform.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/18  23:28:22  pinnacle
# Replaced: vrchgattr/VRform.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/16  20:47:20  pinnacle
# Replaced: vrchgattr/VRform.I for:  by r240_int for route240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      -----------------------------------------------------------------------
 *	08/19/94	  MM		Modifications done upon addition of
 *					a new shape VR_TRAY.
 *	10/24/94	  Lori		CR#179422038.  Modifications upon
 *					addition of user choice of material
 *					class (spec) for HVAC.
 *	01/15/96	tlb		Add VX_FIproto.h, prototypes
 *	01/17/96	tlb		Use VDfld_set_list_text
 *      02/29/96        Shankar         Added Fix for TR179600394. Added to
 *                                      code to disable some gadgets when
 *                                      sub-form comes up.
 *      01/12/98        law             CR179309874- New raceway shapes
 *      01/12/98        law             CR179700399-Link diameter/depth/width
 *      02/09/98        law             TR179800380-Check max-width vs width
 *                                                 - Also some duct wheel fixes
 *      05/19/98        law             TR179801054-more duct wheel fixes
 *      06/24/98        law             TR179801141-Add vendor to Rway form.
 *      07/25/98        LAW             Added tiers for raceway - CR179801144
 *      09/05/98        law             TR179801939-cleanup width/depth checks.
 *      05/03/99        Reddy           CR179900491 - Raceway Multi Tier design
 *      05/03/99        Alwin           TR179900485 - Copy Raceway Component
 *      05/07/99        law             CR179900491 - minor corrections
 *     May 31 1999      Anand           TR 179900632 - Checks in width/depth
 *     					check-boxes refuse to disappear!
 *      07/22/99        Anand(by law)   TR179900762 - partial fix to assign
 *      				double to Friction factor.
 *     Aug 04 1999      Anand           TR 179900778 - Added DBG printfs
 *     Nov 04 1999      law             TR179900932 - Form cleanup- ALSO
 *					large number of RWAY/HVAC filters for
 *                                      width/depth fields
 *     Feb 04 2000      Alwin           CR179900696 - Added code for setting the
 *					Material & Insulation information
 *     Mar 20 2000      law            tr179901167 delete fields for transitions
 *     May 10 2000      Alwin          CR179901312 Added Acoustic Insulation
 *					gadgets.
 *     Jun 27 2000      law          tr179901701 width/depth updating when
 *                                      not selected for update.
 *     Jul 13 2000      Alwin          CR179901661 Moved the ACST param from
 *					User Collector -> System Collector.
 *     Jul 21 2000      Alwin          CR179901615 Updated the Piping Insulation
 *					Thickness list for the change in 
 *					insulation type.
 *     Aug 16 2000      Alwin          TR179901861 Set the proper types for
 *					acoustic insulation related attributes.
 *     Nov 22 2000      Anand          CR 179902074
 *     Feb  9 2001      law            TR3367 Added missing params to additional
 *                                     parameters form.	
 *     Mar 11 2001      law            TR3367 repaired missing params
 ************************************************************************/

class implementation VRchgattr;


#include <stdio.h>
#include <stdlib.h>

#include "FI.h"
#include "FEI.h"
#include "AS_status.h"
#include "VRdef.h"
#include "vrparameters.h"
#include "VRattr_def.h"
#include "VRuserdef.h"
#include "VRchgattrdef.h"
#include "VRmacros.h"
#include "VRMcForm.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "VDDfEntCode.h"
#include "VDSutil.h"
#include "VRDbStruct.h"
#include "ACattrib.h"
#include "ACrg_collect.h" 
#include "vrchgatt_pto.h"
#include "vrpdu_pto.h"
#include "vrtools_pto.h"
#include "vrflow_pto.h"
#include "vrdbgmacros.h"
#include "VRRwDimen.h"

#include "VRdbcodlst.h" // Added by Anand for CR 179902074

/* TR179801054 reset temp buffers to safe */
%safe
#include "VX_FIproto.h"
static int VRform_shape = -1;
static double VRnoncirc_depth= -1.;
static double VRnoncirc_width= -1.;
%endsafe

extern int VRform_shape;
extern double VRnoncirc_depth;
extern  double VRnoncirc_width;

#define MAIN 		0
#define SUB  		1
#define AS_DEBUG 	1
#define MAX_FIELD 	256


/* Added by Anand for CR 179900491 */
#define D_RCWY_SIZE	718
#define W_RCWY_SIZE	720
/* Above #define pre-processor directives are required to circumvent the result
 * of a "brain damage". The gadget labels were common to forms for both HVAC
 * and Raceways. Why on earth should then one change the gadget labels for
 * Raceways alone? Created avoidable chaos.	- Anand for CR 1799000491 */

#define VR_N_TIERSP1_DB 	"cpt1_tiersp"
#define VR_N_NUMTIER1_IN        "no_tiers_1" 

from	ACrg_collect	import	ACrem_attribute,
				ACadd_attribute,
				ACadd_attribute_by_type,
				AClist_attribute,
				ACget_named_attribute,
				ACshow_data;
from	ACncpx	import		ACgive_structure;
from    VRGeneric       import  VRGetParams;

/*****************************************************************************

			initial_form_notification

*****************************************************************************/

/*+mo
  Overridden Message
        initial_form_notification from CEO 

  Abstract
        Description - why overridden
	This message needs to be implemented for every different form.

  Algorithm
      <Optional>

  Arguments
      <List of names>

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Status/Return Code
      status == OM_S_SUCCESS    if success.
      status == OM_E_INVARG	if form_ptr is NULL.

-mo*/


method initial_form_notification( int form_label, gadget_label; 
		double value; char * form_ptr )
{

/* KDD 4-98 single safe + static definition + initialization */
/*
        VRform_shape = -1;
        VRnoncirc_depth= -1.;
        VRnoncirc_width= -1.;
*/
	if ( form_ptr == NULL )	return( OM_E_INVARG ); 

	if ( form_ptr == me->form_ptr[MAIN] )
	{

#ifdef	MANAGE_IDS

	/*A access the data base for the Id list */
	if ( me->bPid && ( gadget_label ==  LINE_SEQ_NO || 
			gadget_label == LINE_NUMBER) )
	{
		struct ret_struct	ParamAttr;
		IGRint 			FootIndex = -1, retstatus;
		IGRint			IdList[VDS_LIST_OF_IDS];
		IGRchar			LineIdStr[10];
			
		/*C Get system name */
		status = 
		om$send( msg      = message ACncpx.ACgive_structure
					   ( &retstatus, 
					     &FootIndex, 
				       	     VR_N_SYST_NAME_AN,
	     			       	     &ParamAttr, 
					     &me->ModuleInfo),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );

		/*C unlock the previous unused id */
		if ( !me->bLineNumUsed && me->PrevLineNum != -1 )
		{
			status =
			VDUnLockID ( ParamAttr.var.text_st.text_string,
				(int)VD_C_PIPES, me->PrevLineNum );
		}/* end of unlock */

		/*C get the list of available line Ids */
		status = 
		VDGetListOfIDs( ParamAttr.var.text_st.text_string,
			(int)VD_C_PIPES, IdList );

		/*C set the associated list */
		for( i=0; i<VDS_LIST_OF_IDS; i++ )
		{
			sprintf( LineIdStr, "%05d", IdList[i] );
			VDfld_set_list_text( form_ptr, gadget_label, 
				i, 0, LineIdStr, FALSE);
		}
	} /* end access db for line Id list */

#endif
	switch( me->product )
	{
	case VR_PIPING :

	switch( gadget_label )
	{
		case PIPING_MAT_CLASS:
		FIg_set_state_on( form_ptr, SYMB_PIPING_MAT_CLASS );
		break;

		case NOM_PIPE_DIAM:
		FIg_set_state_on( form_ptr, SYMB_NOM_PIPE_DIAM );
		break;

		case LINE_SEQ_NO:
		FIg_set_state_on( form_ptr, SYMB_LINE_SEQ_NO );
		break;

		case FLUID_CODE:
		FIg_set_state_on( form_ptr, SYMB_FLUID_CODE );
		break;

		case HEAT_TRACING:
		FIg_set_state_on( form_ptr, SYMB_HEAT_TRACING );
		break;

		case INSULATION_THICKNESS:
		FIg_set_state_on( form_ptr, SYMB_INSULATION_THICKNESS );
		break;

		case INSULATION_TYPE:
		FIg_set_state_on( form_ptr, SYMB_INSULATION_TYPE );
		break;

		case BLOCK_NO:
		FIg_set_state_on( form_ptr, SYMB_BLOCK_NO );
		break;

		case OP_NORMAL_TEMP:
		FIg_set_state_on( form_ptr, SYMB_OP_NORMAL_TEMP );
		break;

		case OP_NORMAL_PRES:
		FIg_set_state_on( form_ptr, SYMB_OP_NORMAL_PRES );
		break;

		case DES_NORMAL_TEMP:
		FIg_set_state_on( form_ptr, SYMB_DES_NORMAL_TEMP );
		break;

		case DES_NORMAL_PRES:
		FIg_set_state_on( form_ptr, SYMB_DES_NORMAL_PRES );
		break;

		case APPROVAL_STATUS:
		FIg_set_state_on( form_ptr, SYMB_APPROVAL_STATUS );
		break;

		case CONSTRUC_STATUS:
		FIg_set_state_on( form_ptr, SYMB_CONSTRUC_STATUS );
		break;

		case PID_SCALE:
		FIg_set_state_on( form_ptr, SYMB_PID_SCALE );
		break;

		case SYSTEM_NAME:
		FIg_set_state_on( form_ptr, SYMB_SYSTEM_NAME );
		break;

		case UNIT_NUMBER:
		FIg_set_state_on( form_ptr, SYMB_UNIT_NUMBER );
		break;

		default: /*| Undefined Gadget */
		break;
	}/* end switch on Piping gadget label */
	break;
    		
	case VR_HVAC :
	case VR_CABLING :
		__DBGpr_com( " Entered the case VR_HVAC/VR_CABLING");
	switch( gadget_label )
	{
		IGRint ModifyAttr;
		/* CR179801144 Tier Needed here */


		case N_TIER_DG:
		FIg_set_state_on( form_ptr, SYMB_N_TIER_DG );
		break;

		case SP_TIER_DG:
		FIg_set_state_on( form_ptr, SYMB_SP_TIER_DG );
		break;

		case LINE_NUMBER:
		FIg_set_state_on( form_ptr, SYMB_LINE_NUMBER );
		break;

		case HVAC_MAT_CLASS:
		FIg_set_state_on( form_ptr, SYMB_HVAC_MAT_CLASS );
		break;

		case PRESS_CLASS:
		FIg_set_state_on( form_ptr, SYMB_PRESS_CLASS );
		break;

		case CONST_STATUS:
		FIg_set_state_on( form_ptr, SYMB_CONST_STATUS );
		break;

		case APPROVAL_STAT:
		FIg_set_state_on( form_ptr, SYMB_APPROVAL_STAT );
		break;

		case SIZE_METHOD:
		FIg_set_state_on( form_ptr, SYMB_SIZE_METHOD );
		break;

		case SERVICE:
		FIg_set_state_on( form_ptr, SYMB_SERVICE );
		break;

		case CIRCULAR_SHAPE:
		case RECTANGULAR_SHAPE:
		case OVAL_SHAPE:
		case RADIUS_SHAPE:
		case ELLP_SHAPE: /* new RW shape-CR179309874 */

		FIg_set_state_on( form_ptr, SYMB_SHAPE );
		break;

		case MAX_VELOCITY:
		FIg_set_state_on( form_ptr, SYMB_MAX_VELOCITY );
		break;

		case AIR_FLOW:
		FIg_set_state_on( form_ptr, SYMB_AIR_FLOW );
		break;

                /* Below added for CR179700399 - Link diameter/depth/width */
		case FRICTION:
		FIg_set_state_on( form_ptr, SYMB_FRICTION );
		break;

		case DUCT_THICK:
		FIg_set_state_on( form_ptr, SYMB_DUCT_THICK );
		break;

		case MAX_WIDTH:
		FIg_set_state_on( form_ptr, SYMB_MAX_WIDTH );
		break;

		case DUCT_MATER:
		FIg_set_state_on( form_ptr, SYMB_DUCT_MATER );
		break;

		case SYSTEM:
		FIg_set_state_on( form_ptr, SYMB_SYSTEM );
		break;
 
		case ZONE:
		FIg_set_state_on( form_ptr, SYMB_ZONE );
		break;
     
		case INSULA_MATER:
		FIg_set_state_on( form_ptr, SYMB_INSULA_MATER );
		break;

		case INSULA_THICK:
		FIg_set_state_on( form_ptr, SYMB_INSULA_THICK );
		break;

		case GAP:
		FIg_set_state_on( form_ptr, SYMB_GAP );
		break;

		case W_RCWY_SIZE:
		case W_SIZE:
		FIg_set_state_on( form_ptr, SYMB_W_SIZE );
		break;

		case D_RCWY_SIZE:
		case D_SIZE:
		if( (VRform_shape == VR_RECT) || (VRform_shape == VR_CIRC) )
		    FIg_set_state_off( form_ptr , SYMB_D_SIZE );
		else
		    FIg_set_state_on( form_ptr, SYMB_D_SIZE );
         	break;

		case THROAT_RADIUS:
		FIg_set_state_on( form_ptr, SYMB_THROAT_RADIUS );
		break;

		case CORNER_RADIUS:
		FIg_set_state_on( form_ptr, SYMB_CORNER_RADIUS );
		break;

		case TRANS_LENGTH: 
		FIg_set_state_on( form_ptr, SYMB_TRANS_LENGTH );
		break;

		case UNIT_NUMBER: 
		FIg_set_state_on( form_ptr, SYMB_UNIT_NUMBER );
		break;

		case PID_SCALE:
		FIg_set_state_on( form_ptr, SYMB_PID_SCALE );
		break;

		// added to set the state for acoustic insulation gadgets. Alwin
		case ACOUSTIC_MATERIAL:
		if( me->product == VR_HVAC )
			FIg_set_state_on( form_ptr, SYMB_ACOUSTIC_MATERIAL );
		break;

		case ACOUSTIC_THICK:
		if( me->product == VR_HVAC )
			FIg_set_state_on( form_ptr, SYMB_ACOUSTIC_THICK );
		break;

		default:
		/*| unknown gadget */
		break;
	}/* end switch on HVAC gadget label */

	default :
	/*| unknown product */
	break;
  	}/* end switch on product */	

	}

	return (OM_S_SUCCESS);

}/* end initial_form_notification */

/*****************************************************************************

				form_notification

*****************************************************************************/
/*+mo
  Overridden Message
        form_notification from CEO.

  Abstract
        <Description - why overridden>

  Algorithm
      <Optional>

  Arguments
      <List of names>

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_INVARG	if form_ptr is NULL;

-mo*/


method form_notification( int form_label, gadget_label; 
				double value; char * form_ptr )
{

  IGRlong	status = OM_S_SUCCESS;

  IGRlong		retmsg;
  IGRint		i;
  
  IGRchar		szText[MAX_FIELD];
  IGRdouble		dValue, max_depth = 0; /* TR179800380 */
  IGRboolean		ret_flag;

  IGRint		NbAttr=0;
  struct ACrg_coll	ListAttr[VR_MAX_ATTR], ColAttr; /*NEWADD*/
  /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
  IGRchar                tmpText[MAX_FIELD];
  int    int_conv;
  double dEquiDiam;
  double width_val,depth_val;
  /*ENDNEWADD*/

  extern int SMVA_enable();
  extern int SMVA_disable();

  IGRint	sel_flag=0, sel_flag1=0;
  IGRint	r_pos;
  IGRint	type;
  IGRint	row = 0, col = 0;
  IGRint	ModifyAttr=1;		/* Only used for the System form : tells
					   whether an attribute has to be modified
					   or not */
  int		num_rows;
  struct GRid	my_grid; /* CR179801144 */

  IGRint	mod_flag;
  struct ACrg_coll	TempAttr[VR_MAX_ATTR];
  IGRint	NbTemp;

  SetProc(VRform.form_notification); Begin 

  ex$message(in_buff = "",field=ERROR_FIELD);
  if ( form_ptr == NULL )
  {
     	__DBGpr_com(" no form_ptr set ");
	End
    	return( OM_E_INVARG ); 
  }
  dValue = 0.0;
  szText[0] = '\0';

  /* CR179801144 */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /* NEWADD for TR179800380 */
  if(VRform_shape < 0)
  {
	 ColAttr.desc.value.att_exp = -1; 

         strcpy(ColAttr.name, VR_N_SHAPE_IN);
         status =
            om$send( msg = message ACrg_collect.ACget_named_attribute
                        ( &retmsg, &ColAttr ),
                targetid = me->SysId.objid,
                targetos = me->SysId.osnum );
         as$status();

         VRform_shape = (int)ColAttr.desc.value.att_exp;
  }
  /* ENDNEWADD*/
  /*"form label %d gadget label %d\n", form_label, gadget_label */

  FIg_get_type( form_ptr, gadget_label, &type );

  /*"form label  : %d\n", form_label */
  __DBGpr_int(" gadget label", gadget_label);
  /*"gadget type : %d\n", type  */
  /*"Value       : %f\n", value */

/* quick fix for tr179900932 */
  if(me->product == VR_RWAY) 
  {

      if(gadget_label == SYMB_N_TIER_DG ||
	 gadget_label == SYMB_SP_TIER_DG ||
	 gadget_label == SYMB_CORNER_RADIUS ||
	 gadget_label == SYMB_W_SIZE ||
	 gadget_label == SYMB_D_SIZE)
      {
	  IGRint nusel_flag;
	  FIg_get_state( form_ptr, gadget_label, &nusel_flag);
	  if(!nusel_flag)
	  {
	      FIg_set_state_off( form_ptr, gadget_label);
	      gadget_label = 0;
	  }
      }
  }

  if ( type == FI_FIELD )
  {

	ModifyAttr = 1;

	FIfld_get_type( form_ptr, gadget_label, col, &type );

	if ( type == FI_DOUBLE || type == FI_INT )
	{
		FIfld_get_value( form_ptr, gadget_label, row, col,
				 &dValue, &sel_flag, &r_pos );
	}
	else if ( type == FI_ALPHA )	
	{
		FIfld_get_text( form_ptr, gadget_label,  row, col,
				MAX_FIELD, (unsigned char *) szText, 
				&sel_flag, &r_pos );
	}

  }
  else if ( type == FI_CHECKLIST )
  {
	FIg_get_state( form_ptr, gadget_label, &ModifyAttr );
	__DBGpr_int(" Gadget state", ModifyAttr);
  }
    #if 0
      printf( "product = %d\n", me->product );
      printf( "form label %d gadget label %d\n", form_label, gadget_label );
    #endif

  if ( form_ptr == me->form_ptr[MAIN] )
  {
	IGRdouble no_tiers,tier_sp;
	IGRint TModifyAttr;
	FIfld_set_text( form_ptr, MESSAGE, 0, 0, "", sel_flag );
	switch( gadget_label )
	{
		/* Tier processing for CR179801144 */
    		case FI_ACCEPT:
   		case FI_EXECUTE:

                /* NEWADD for TR179800380 */
                /* reset the width and depth even if redundant */

		if( me->product == VR_HVAC )
		{
		    FIfld_get_value( form_ptr, D_SIZE, row, col,
			    &depth_val, &sel_flag, &r_pos );
		    FIfld_get_value( form_ptr, W_SIZE, row, col,
			    &width_val, &sel_flag, &r_pos );
                    /***************************************************/
                    /* TR179901701 fix                                 */
                    /* The width/depth get put into the collection and */
                    /* are not removed if unchecked                    */
                    /***************************************************/
                    FIg_get_state( form_ptr, SYMB_D_SIZE, &TModifyAttr );
                    if(!TModifyAttr)
                    {
                        strcpy(ColAttr.name,VR_N_DEPTH1_DB );
                        ColAttr.desc.value.att_exp = -1;
                        status = om$send(
                               msg = message ACrg_collect.ACget_named_attribute
                                                         ( &retmsg, &ColAttr ),
                          targetid = me->SMoId.objid,
                          targetos = me->SMoId.osnum );
                        if(ColAttr.desc.value.att_exp > 0.0)
                        {
                           status =
                           om$send( msg = message ACrg_collect.ACrem_attribute
                                        ( &retmsg, VR_N_DEPTH1_DB ),
                                targetid = me->SMoId.objid,
                                targetos = me->SMoId.osnum );
                           status =
                           om$send( msg = message ACrg_collect.ACrem_attribute
                                        ( &retmsg, VR_N_DEPTH2_DB ),
                                targetid = me->SMoId.objid,
                                targetos = me->SMoId.osnum );
                       }
                   }
                   FIg_get_state( form_ptr, SYMB_W_SIZE, &TModifyAttr );
                   if(!TModifyAttr)
                   {
                        strcpy(ColAttr.name,VR_N_WIDTH1_DB );
                        ColAttr.desc.value.att_exp = -1;
                        status = om$send(
                               msg = message ACrg_collect.ACget_named_attribute
                                                         ( &retmsg, &ColAttr ),
                          targetid = me->SMoId.objid,
                          targetos = me->SMoId.osnum );
                        if(ColAttr.desc.value.att_exp > 0.0)
                        {
                           status =
                           om$send( msg = message ACrg_collect.ACrem_attribute
                                        ( &retmsg, VR_N_WIDTH1_DB ),
                                targetid = me->SMoId.objid,
                                targetos = me->SMoId.osnum );
                           status =
                           om$send( msg = message ACrg_collect.ACrem_attribute
                                        ( &retmsg, VR_N_WIDTH2_DB ),
                                targetid = me->SMoId.objid,
                                targetos = me->SMoId.osnum );
                        }
                   }
		}
		else if( me->product == VR_CABLING )
		{
		    __DBGpr_com( " Entered FI_ACCEPT/FI_EXECUTE ");

		    FIfld_get_value( form_ptr, D_RCWY_SIZE, row, col,
			    &depth_val, &sel_flag, &r_pos );
		    FIfld_get_value( form_ptr, W_RCWY_SIZE, row, col,
			    &width_val, &sel_flag, &r_pos );
		}
		FIfld_get_value( form_ptr, MAX_WIDTH, row, col,
				 &max_depth, &sel_flag, &r_pos );

		__DBGpr_dbl(" Depth",depth_val);
		__DBGpr_dbl(" Width",width_val);
		__DBGpr_dbl(" Max width/depth",max_depth );

                /* Modified for TR179801939 */
                if((me->product == VR_HVAC) &&
                    (depth_val > max_depth) && 
                    (max_depth > 0.0))
                {
		    FIg_set_state_on( form_ptr, SYMB_D_SIZE );
                    depth_val = max_depth;
                }
                else if((me->product == VR_RWAY) && 
                    (width_val > max_depth) && 
                    (max_depth > 0.0))
                { 
		    FIg_set_state_on( form_ptr, SYMB_W_SIZE );
                    width_val = max_depth;
                }
		NbAttr = 0; /* moved for CR179801144 */
                /* Below modified for TR179801939 */
                if(VRform_shape == VR_CIRC && me->product == VR_HVAC)
		{
                      struct ret_struct     ParamAttr;
                      IGRint                FootIndex = -1, retstatus;
		      FIfld_get_text( form_ptr, SIZE_COMP_METHOD, row, col,
                                 MAX_FIELD,
                                (unsigned char *) tmpText, &sel_flag, &r_pos );
		      dValue = 0;
		      if(!strncmp (tmpText,"Compute Width ",14))
                         width_val = depth_val;
		      else
                         depth_val = width_val;
                      /* Modified for TR179801939 */

                      status = VRCollvsForm(me->SysId,VR_N_WIDTH1_DB,
				&me->ModuleInfo,width_val,
				ListAttr,&NbAttr,&mod_flag);
		      if(mod_flag)
                      {
		         FIg_set_state_on( form_ptr, SYMB_W_SIZE );
                         strcpy(ListAttr[NbAttr].name,VR_N_WIDTH2_DB);
                         ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
                         ListAttr[NbAttr].desc.value.att_exp = width_val;
                         NbAttr++;
                      }
		      else
			 FIg_set_state_off( form_ptr, SYMB_W_SIZE );

                      status = VRCollvsForm(me->SysId,VR_N_DEPTH1_DB,
                                &me->ModuleInfo,depth_val,
                                ListAttr,&NbAttr,&mod_flag);
                      if(mod_flag)
                      {
                         FIg_set_state_on( form_ptr, SYMB_D_SIZE );
                         strcpy(ListAttr[NbAttr].name,VR_N_DEPTH2_DB);
                         ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
                         ListAttr[NbAttr].desc.value.att_exp = depth_val;
                         NbAttr++;

                      }
		      else
			 FIg_set_state_off( form_ptr, SYMB_D_SIZE );
		}
		else if( (VRform_shape == VR_RECT) && (me->product == VR_RWAY) )
                {
		    __DBGpr_com( " Processing for Raceways ");

		    /* CR179801144 rect processing needed here */
		    FIg_get_state( form_ptr, SYMB_N_TIER_DG, &TModifyAttr );
		    FIg_get_state( form_ptr, SYMB_SP_TIER_DG, &ModifyAttr );

		    if( TModifyAttr || ModifyAttr )
		    {
			IGRchar     AttrName_NoTier[25], AttrName_TierSp[25];

			__DBGpr_com("Calling VRRw_dimen_fields from VRforms.I-1 ");

			status = VRRw_dimen_fields( form_ptr, 0, NULL,
						    &me->ModuleInfo, 1,
						    NULL, 2, VRform_shape,
						    &me->RcwyCptInfo,
						    &me->SMoId );
			__DBGpr_com( " Calling VR_Build_Tier_Str ");

			VR_Build_Tier_Str( 1, 0, AttrName_TierSp, NULL);
			strcpy(ColAttr.name, AttrName_TierSp);

			__DBGpr_str(" Name of Attr to be queried",ColAttr.name);
			status = om$send(
			       msg = message ACrg_collect.ACget_named_attribute
							 ( &retmsg, &ColAttr ),
			  targetid = me->SMoId.objid,
			  targetos = me->SMoId.osnum );
			as$status( action = RET_STATUS );
			__DBGpr_str(" Attr string from ACrg_collect",
						  ColAttr.desc.value.att_txt );

			VR_Build_Tier_Str( 2, 0, AttrName_TierSp,
					   AttrName_NoTier);

			__DBGpr_str(" Tier spacing: Name of Attr",
							     AttrName_TierSp );
			__DBGpr_str(" Tier number: Name of Attr",
							     AttrName_NoTier );

			strcpy( ListAttr[NbAttr].name , AttrName_TierSp );
			ListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
			strcpy( ListAttr[NbAttr].desc.value.att_txt ,
				ColAttr.desc.value.att_txt);
			NbAttr++;

			strcpy( ListAttr[NbAttr].name , AttrName_NoTier );
			ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
			ListAttr[NbAttr].desc.value.att_exp =
						me->RcwyCptInfo.nb_tier;
			NbAttr++;

			strcpy( ListAttr[NbAttr].name , VR_N_WIDTH2_DB );
			ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
			ListAttr[NbAttr].desc.value.att_exp =
						me->RcwyCptInfo.width;
			NbAttr++;

			strcpy( ListAttr[NbAttr].name , VR_N_DEPTH2_DB );
			ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
			ListAttr[NbAttr].desc.value.att_exp =
						me->RcwyCptInfo.depth;
			NbAttr++;
			__DBGpr_int(" Num of Modified attr",NbAttr);
		    }
		}

		__DBGpr_dbl(" depth",depth_val);
		__DBGpr_dbl(" rcwy depth",me->RcwyCptInfo.depth);
		__DBGpr_dbl(" rcwy width",me->RcwyCptInfo.width);
		__DBGpr_dbl(" width",width_val);

		/* If the width and depth values are indicated as the
		 * same from the above four dbg printf statements, then
		 * the below two if conditions COULD be redundant.
		 *
		 * If they are different, then the below two if
		 * conditions WOULD need to be relocated exclusively for
		 * HVAC.
		 *
		 * In other words, the presence of the below two
		 * if-conditions is suspect.
		 *
		 * 				- Comment placed by Anand
		 * 				  while investigating for
		 * 				  another TR (June 1, 1999)  */

		FIg_get_state( form_ptr, SYMB_D_SIZE, &TModifyAttr );
		/* Below added for CR179801144 */
		if(TModifyAttr)
		{
		   ListAttr[NbAttr].desc.value.att_exp = depth_val;
		   ListAttr[NbAttr+1].desc.value.att_exp = depth_val;
		   strcpy( ListAttr[NbAttr].name , VR_N_DEPTH1_DB );
		   strcpy( ListAttr[NbAttr+1].name , VR_N_DEPTH2_DB );
		   ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
		   ListAttr[NbAttr+1].desc.type = AC_ATTRIB_DOUBLE;
		   NbAttr +=2;
		}
		FIg_get_state( form_ptr, SYMB_W_SIZE, &TModifyAttr );
		if(TModifyAttr)
		{
		   strcpy( ListAttr[NbAttr].name , VR_N_WIDTH1_DB );
		   ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
		   ListAttr[NbAttr].desc.value.att_exp = width_val;
		   NbAttr++;
		   strcpy( ListAttr[NbAttr].name , VR_N_WIDTH2_DB );
		   ListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
		   ListAttr[NbAttr].desc.value.att_exp = width_val;
		   NbAttr++;
		}
		if(NbAttr)
		{
#ifdef vdsDEBUG
	int DbgC;
	
	__DBGpr_int(" #### Num Attr #### ",NbAttr);
	for( DbgC=0 ; DbgC<NbAttr ; DbgC++ )
	{
	    __DBGpr_str(" Attrib name",ListAttr[DbgC].name );
	    if( ListAttr[DbgC].desc.type == AC_ATTRIB_DOUBLE )
		__DBGpr_dbl("Attrib value", ListAttr[DbgC].desc.value.att_exp);
	    else if( ListAttr[DbgC].desc.type == AC_ATTRIB_TEXT )
		__DBGpr_str("Attrib string",ListAttr[DbgC].desc.value.att_txt);
	}
#endif

		    status = VR$ModifyCollection 
			      (	p_msg 			= &retmsg,
				Operation 		= VR_MERGE_COLL,
				p_ParamsListToModify 	= ListAttr,
				NbParamsToModify 	= NbAttr,
				p_OutputCollectionId 	= &me->SMoId );
                }
		/* ENDNEWADD*/
		VRform_shape = -1; /* TR179800380 */
		if ( me->bPid ) me->bLineNumUsed = TRUE;

		// added for CR179901312. Alwin
		sel_flag = sel_flag1 = -1;
		FIg_get_state( form_ptr, SYMB_ACOUSTIC_THICK, &sel_flag);
		FIg_get_state( form_ptr, SYMB_INSULA_THICK, &sel_flag1);
		__DBGpr_int( " Selection field - Thermal ", sel_flag );
		__DBGpr_int( " Selection field - Insulation ", sel_flag1 );

		if( ( sel_flag || sel_flag1 ) && ( me->product == VR_HVAC ) )
		{
		  IGRdouble	acoustic_insul_thk=0.0;

		  /*
		   * CR 179901312. Parameter 'acst' is defined as the sum of the
		   * Thermal and Acoustic Insulation thicknesses, when Acoustic 
		   * Insulation is non_zero.
		   * i.e.
		   *    For acoustic_insul_thk > 0
		   *        acst = thermal_insul_thk + acoustic_insul_thk
		   *
		   *    For acoustic_insul_thk <= 0
		   *        acst = 0.0
		   */

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, "acst");
		  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[0].desc.value.att_exp = acoustic_insul_thk;

		  FIg_get_value(form_ptr, ACOUSTIC_THICK, &acoustic_insul_thk);
		  __DBGpr_dbl("Acoustic Insul. Thickness",acoustic_insul_thk);

		  if( acoustic_insul_thk > 0.0 )
		  {
			 IGRdouble      thermal_insul_thk = 0.0;
			 IGRdouble      acst = 0.0;

			 FIg_get_value( form_ptr, INSULA_THICK, &thermal_insul_thk );
			 __DBGpr_dbl( " Thermal Insulation Thickness ", thermal_insul_thk );

			 acst = thermal_insul_thk + acoustic_insul_thk;
			 ListAttr[0].desc.value.att_exp = acst;
		  }

		  __DBGpr_dbl( " acst value ", ListAttr[0].desc.value.att_exp );

		  status =
		  VR$ModifyCollection(
					 p_msg                  = &retmsg,
					 Operation              = VR_MERGE_COLL,
					 p_ParamsListToModify   = ListAttr,
					 NbParamsToModify       = NbAttr,
					 p_OutputCollectionId   = &me->SMoId );

		  // Delete the attribute from User Parameters collection.
		  status =
		  VR$ModifyCollection(
					 p_msg                  = &retmsg,
					 Operation              = VR_MERGE_COLL,
					 p_ParamsListToModify   = ListAttr,
					 NbParamsToModify       = NbAttr,
					 p_OutputCollectionId   = &me->UDeId );
		}

		me->my_ret = gadget_label;
		VRreset_gadget( me->product, form_ptr );
		FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
		FIfld_set_text( form_ptr, MESSAGE, row, col,
						"Values Stored", sel_flag );

		_put_response( resp = EX_FORM_FINISHED );
		End
		return OM_S_SUCCESS;

   		case FI_CANCEL:
			VRform_shape = -1; /* TR179800380 */
#ifdef	MANAGE_IDS
			if ( me->bPid )
			{
			  struct ret_struct	ParamAttr;
			  IGRint 		FootIndex = -1, retstatus;
			
			  /*C Get system name */
			  status = 
			  om$send( msg      = message ACncpx.ACgive_structure
					   ( &retstatus, 
					     &FootIndex, 
				       	     VR_N_SYST_NAME_AN,
	     			       	     &ParamAttr, 
					     &me->ModuleInfo),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			  as$status();

			  /*C unlock the previous unused id */
			  if ( !me->bLineNumUsed && me->PrevLineNum != -1 )
				status =
				VDUnLockID ( ParamAttr.var.text_st.text_string,
					(int)VD_C_PIPES, me->PrevLineNum );
			} /* end unlock */
#endif

      			me->my_ret = gadget_label;
     			VRreset_gadget( me->product, form_ptr );
      			FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
      			_put_response( resp = EX_FORM_FINISHED );
			End
      			return OM_S_SUCCESS;

      		case FI_RESET:
                        VRform_shape = -1; /* TR179800380 */
			/* -- Reset value in the form -- */
			status =
			om$send ( msg = message VRchgattr.VRUpdSysForm( &retmsg ),
				targetid = my_id );
        		as$status( action = RET_STATUS );

			/* -- Reset system modified attributes -- */
			status =
			om$send ( msg = message VRchgattr.VRResetAttr( VR_SYSTEM_ATTR ),
				targetid = my_id );
        		as$status( action = RET_STATUS );
 
                       /*NEWADD Correction related to CR179700399 included
                             with fix for TR179800380 */
                        if(me->product == VR_HVAC) /* TR179801939 */
                        {
                        FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
                        FIg_display( form_ptr, W_SIZE );
                          FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
                        FIg_display( form_ptr, D_SIZE );
			}
                        else if(me->product == VR_RWAY)
                        {
                        FIfld_set_mode(form_ptr, W_RCWY_SIZE, 0, FI_INSERT);
                        FIg_display( form_ptr, W_RCWY_SIZE );
			}
                        /*ENDNEWADD*/

			/* -- Update form format -- */
			VRFormatSysForm ( me->product, form_ptr, 1, me->bPid );
                        /* tr179901167-delete fields for transitions **/
			status =
			om$send ( msg = message VRchgattr.VRUpdSysForm( &retmsg ),
				targetid = my_id );
        		as$status( action = RET_STATUS );

			/* -- Pop Up the reset button -- */
        		FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

			End
      			return OM_S_SUCCESS;

		default:
			/*| undefined gadget */
			break;

	}
	
#ifdef	MANAGE_IDS

	/*A process the line Id number */
	if ( me->bPid && ( gadget_label ==  LINE_SEQ_NO || 
			gadget_label == LINE_NUMBER) )
	{
		/*A Verify unicity of LSN */
		struct ret_struct	ParamAttr;
		IGRint 			FootIndex = -1, retstatus;
		IGRdouble		dValue;
		IGRchar			*sEnd=NULL;

		/*C Verify that LNS is a value */
		dValue = strtod (szText, &sEnd);
		if ( strlen (sEnd) )
		{
       			ex$message( field   = ERROR_FIELD,
	    		in_buff = "LSN is ASCII => NO UNICITY CHECK" );
		}
		else
		{
			/*C Get system name */
			status = 
			om$send( msg      = message ACncpx.ACgive_structure
						   ( &retstatus, 
						     &FootIndex, 
					       	     VR_N_SYST_NAME_AN,
		     			       	     &ParamAttr, 
						     &me->ModuleInfo),
			targetid = me->SysId.objid,
			targetos = me->SysId.osnum );

			status =
			VDVerifyIfIDisUsed( ParamAttr.var.text_st.text_string,
				(int)VD_C_PIPES, (IGRint) dValue );
			if ( status == VDS_ID_IS_USED )
			{
				ex$message( field   = ERROR_FIELD,
			    	in_buff = "LSN ALREADY USED !!!" );
			}
			else
			{
				VDLockSelectedID ( ParamAttr.var.text_st.text_string,
				(int)VD_C_PIPES, (IGRint) dValue   );
				me->PrevLineNum = (int) dValue;
				me->bLineNumUsed = FALSE;
			}
		}
	} /* end process the line Id */

#endif

	FIfld_set_text( form_ptr, MESSAGE, 0, 0, "", sel_flag );
  	switch( me->product )
  	{
		case VR_PIPING :
			switch( gadget_label )
    			{

			/* -------- */
			/* - */ case      PIPING_MAT_CLASS:
			/* -------- */
			    /* Anand for CR 179902074 */
			    {
				IGRshort	nSpec=0;
				IGRint 		new_list_cnt=0, sel_index;
				IGRint 		sel_flag=0, unique_flg=0;
				IGRchar		*speclist;

				__DBGpr_str( " User Key-in text ", szText );

				/*| -- Get Spec Name List */
				status = VRget_spec_list( &retmsg, VR_PIPING,
							  &nSpec, &speclist,
							  NULL);
				CheckRC( status, retmsg );
				if( !status & 1 ) break;
				__DBGpr_int( " No. of Specs from DB ", nSpec );

				qsort( speclist, nSpec,
				       VR_MAX_SPEC_NAME_LEN, strcmp );

				/* Filter the DB ( Original ) Spec list as
				 * needed for the user */
				sel_index = -1;
				status =
				VDfrm_fld_set_sub_list( form_ptr,
							gadget_label,
							MESSAGE,
							speclist,
							VR_MAX_SPEC_NAME_LEN,
							(IGRint)nSpec,
							&new_list_cnt,
							0,
							&sel_index,
							&unique_flg );

				__DBGpr_int( " Unique Flag ", unique_flg );

				if( unique_flg == 1 )
				{
				    /* Unique match has been found out of User
				     * Keyed in string, so we need to proceed
				     * further. */

				    FIfld_get_text( form_ptr, gadget_label,
				    		    row, col, MAX_FIELD, 
						    (unsigned char *) szText,
						    &sel_flag, &r_pos );

				    __DBGpr_str( " Selected Spec ", szText );
				    FIg_enable( form_ptr, FI_EXECUTE );
				    FIg_enable( form_ptr, FI_ACCEPT );
				    NbAttr = 1;
				    strcpy( ListAttr[0].name,VR_N_CLASS_AN );
				    VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr,
							    NULL,
							    PIPING_MAT_CLASS,
							    NOM_PIPE_DIAM,
							    NOM_PIPE_DIAM,
							    UNIT_NUMBER );
				    break;
				}
				else if( sel_index < 0 ) 
				{
				    FIg_disable( form_ptr, FI_EXECUTE );
				    FIg_disable( form_ptr, FI_ACCEPT );
				    End
				    return status;
				}
				else
				    break;
			    }
			    /* Anand for CR 179902074 */

			/* -------- */
			/* - */ case SYMB_PIPING_MAT_CLASS:
			/* -------- */
		NbAttr = 1;
	 	strcpy( ListAttr[0].name,VR_N_CLASS_AN );
		VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL, 
				PIPING_MAT_CLASS, NOM_PIPE_DIAM, 
				NOM_PIPE_DIAM, UNIT_NUMBER );
	      	break;
			/* -------- */
			/* - */ case SYMB_NOM_PIPE_DIAM:
			/* - */ case      NOM_PIPE_DIAM:
			/* -------- */
		NbAttr = 2;
	 	strcpy( ListAttr[0].name,VR_N_GDIAMETER_DB );
	 	strcpy( ListAttr[1].name,VR_N_RDIAMETER_DB );
		VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL, 
				PIPING_MAT_CLASS, NOM_PIPE_DIAM, 
				NOM_PIPE_DIAM, UNIT_NUMBER );
		break;
			/* -------- */
			/* - */ case SYMB_LINE_SEQ_NO:
			/* - */ case      LINE_SEQ_NO:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_SEQ_NUMBER_AN );
	      	break;
			/* -------- */
			/* - */ case      FLUID_CODE:
			/* -------- */
		/* Below lines added by Anand for CR 179902074 */
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING,
						VR_P_FLUID_CODE_LSTNUM,
						form_ptr, FLUID_CODE,
						(IGRuchar *)szText );
		as$status( action = RET_STATUS );
		if( szText[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    End
		    return status;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",szText);
		    NbAttr = 1;
		    strcpy( ListAttr[0].name, VR_N_FLUID_CODE_AN );
		    break;
		}
		/* Above lines added by Anand for CR 179902074 */
			/* -------- */
			/* - */ case SYMB_FLUID_CODE:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_FLUID_CODE_AN );
	      	break;
			/* -------- */
			/* - */ case      HEAT_TRACING:
			/* -------- */
		/* Below lines added by Anand for CR 179902074 */
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING,
						VR_P_TRACE_TYPE_LSTNUM,
						form_ptr, HEAT_TRACING,
						(IGRuchar *)szText );
		as$status( action = RET_STATUS );
		if( szText[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    End
		    return status;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",szText);
		    NbAttr = 1;
		    strcpy( ListAttr[0].name, VR_N_TRACING_CODE_AN );
		    break;
		}
		/* Above lines added by Anand for CR 179902074 */
			/* -------- */
			/* - */ case SYMB_HEAT_TRACING:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_TRACING_CODE_AN );
	      	break;
			/* -------- */
			/* - */ case SYMB_INSULATION_THICKNESS:

				FIg_get_text( form_ptr, INSULATION_THICKNESS,
						szText );

			/* - */ case      INSULATION_THICKNESS:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_INSUL_THK_DB );

		__DBGpr_str( " Insulation Thickness text ", szText );

		// Alwin for CR179901615
		if( szText[0] != '\0' ) dValue = atof( szText );
		__DBGpr_dbl( " Insulation Thickness value", dValue );
	      	break;
			/* -------- */
			/* - */ case SYMB_INSULATION_TYPE:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_INSUL_TYPE_AN );

		// Alwin for CR179901615
		// Update the insulation thickness based on the selection.
		VRPGetInsulThkFromType( form_ptr, INSULATION_THICKNESS,
					szText );
		break;
			/* -------- */
			/* - */ case      INSULATION_TYPE:
			/* -------- */
		/* Below lines added by Anand for CR 179902074 */
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING,
						VR_P_INSUL_TYPE_LSTNUM,
						form_ptr, INSULATION_TYPE,
						(IGRuchar *)szText );
		as$status( action = RET_STATUS );
		if( szText[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    End
		    return status;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",szText);
		}
		/* Above lines added by Anand for CR 179902074 */

		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_INSUL_TYPE_AN );

		// Alwin for CR179901615
		// Update the insulation thickness based on the selection.
		VRPGetInsulThkFromType( form_ptr, INSULATION_THICKNESS,
					szText );
		break;
			/* -------- */
			/* - */ case SYMB_BLOCK_NO:
			/* - */ case      BLOCK_NO:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_ZONE_AN );
		break;
			/* -------- */
			/* - */ case SYMB_OP_NORMAL_TEMP:
			/* - */ case      OP_NORMAL_TEMP:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_OPER_TEMP_DB );
		break;
			/* -------- */
			/* - */ case SYMB_OP_NORMAL_PRES:
			/* - */ case      OP_NORMAL_PRES:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_OPER_PRESS_DB );
		break;
			/* -------- */
			/* - */ case SYMB_DES_NORMAL_TEMP:
			/* - */ case      DES_NORMAL_TEMP:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_DGN_TEMP_DB );
		break;
			/* -------- */
			/* - */ case SYMB_DES_NORMAL_PRES:
			/* - */ case      DES_NORMAL_PRES:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_DGN_PRESS_DB );
		break;
			/* -------- */
			/* - */ case      APPROVAL_STATUS:
			/* -------- */
		/* Below lines added by Anand for CR 179902074 */
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING, VR_P_APP_STS_LSTNUM,
						form_ptr, APPROVAL_STATUS,
						(IGRuchar *)szText );
		as$status( action = RET_STATUS );
		if( szText[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    End
		    return status;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",szText);
		}
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_APPRV_STAT_AN );
		break;
		/* Above lines added by Anand for CR 179902074 */
			/* -------- */
			/* - */ case SYMB_APPROVAL_STATUS:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_APPRV_STAT_AN );
		break;
			/* -------- */
			/* - */ case      CONSTRUC_STATUS:
			/* -------- */
		/* Below lines added by Anand for CR 179902074 */
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING,
						VR_P_CONST_STS_LSTNUM,
						form_ptr, CONSTRUC_STATUS,
						(IGRuchar *)szText );
		as$status( action = RET_STATUS );
		if( szText[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    End
		    return status;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",szText);
		}
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_CONSTR_STAT_AN );
		break;
		/* Above lines added by Anand for CR 179902074 */
			/* -------- */
			/* - */ case SYMB_CONSTRUC_STATUS:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_CONSTR_STAT_AN );
		break;
			/* -------- */
			/* - */ case SYMB_PID_SCALE :
			/* - */ case      PID_SCALE :
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_PID_SCALE_DB );
		break;
			/* -------- */
			/* - */ case SYMB_SYSTEM_NAME:
			/* - */ case      SYSTEM_NAME:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_SYST_NAME_AN );
		break;
			/* -------- */
			/* - */ case SYMB_UNIT_NUMBER:
			/* - */ case      UNIT_NUMBER:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_UNIT_AN );
		break;
			/* -------- */
			case MOD_LOAD_COMPONENT:
			/* -------- */

        	me->my_ret = MOD_LOAD_COMPONENT;
  		_put_response( resp = EX_FORM_FINISHED );
		End
    		return OM_S_SUCCESS;

			/* -------- */
			case MOD_USER_ATTR_BUTTON0:
			/* -------- */

		FIg_set_notify_off( form_ptr, gadget_label );
		status = om$send ( msg = message VRchgattr.VRUpdUsrForm ( &retmsg),
				targetid = my_id);
		if (!(status&1))
		{
			me->state = _terminate;
			End
			return OM_I_STOP_SENDING;
		}
		/* -- Display user form -- */
		FIf_display( me->form_ptr[SUB] );
		SMVA_disable( me->form_ptr[MAIN], 2, FI_ACCEPT, FI_EXECUTE );
		break;

			/* -------- */
			default:
			/* -------- */
		/*| Undefined Gadget */
		break;

			}/* end switch on PIPING gadgets */
			 /* ---------------------------- */

			break;
    			
    		case VR_HVAC :
    			switch( gadget_label )
     			{

			/* -------- */
			case SYMB_LINE_NUMBER:
			case LINE_NUMBER:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_SEQ_NUMBER_AN  );
		break;

			/* -------- */
			case SYMB_PRESS_CLASS:
			case PRESS_CLASS:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_PRESS_CLASS_AN );
		break;

			/* -------- */
			case SYMB_HVAC_MAT_CLASS:
			case HVAC_MAT_CLASS:
			/* -------- */
		NbAttr = 1;
	 	strcpy( ListAttr[0].name,VR_N_CLASS_AN );
		status = check_spec( &retmsg, me->product, szText, NULL );
		if( status != OM_S_SUCCESS )
		{
                     if(me->product == VR_HVAC) /* TR179801141 */
			FIfld_set_text( form_ptr, MESSAGE, 0, 0,
				"Mat. Class not found in DB", sel_flag );
                     else /* TR179801141-Add vendor to Rway form */
			FIfld_set_text( form_ptr, MESSAGE, 0, 0,
				"Vendor Code not found in DB", sel_flag );
			break;
		}

		// added by Alwin for CR179900696
		// based on the modifiaction update the duct material gadget
		VRUpdMaterial_InsulationList( form_ptr, TRUE, szText, DUCT_MATER );

		break;

			/* -------- */
			case SYMB_CONST_STATUS:
			case CONST_STATUS:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_CONSTR_STAT_AN );
		break;

			/* -------- */
			case SYMB_APPROVAL_STAT:
			case APPROVAL_STAT:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_APPRV_STAT_AN );
		break;

			/* -------- */
			case SYMB_SIZE_METHOD:
			case SIZE_METHOD:
			/* -------- */
		/*| SIZE METHOD ???? */
               /* NEWADD Correction related to CR179700399 included with fix for
                  TR179800380 */
               NbAttr = 1;
               strcpy( ListAttr[0].name , VR_N_SIZE_METHOD_AN );

               FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
                                (unsigned char *) tmpText, &sel_flag, &r_pos );
      if(!strncmp (tmpText,"Velocity",8))
      { IGRdouble dAirFlow, dVelocity, dEquiDiam;
               /* get air flow */
               FIfld_get_value(form_ptr,AIR_FLOW,row,col,&dAirFlow,&sel_flag,&r_pos );

               FIfld_get_value(form_ptr,MAX_VELOCITY,row,col,&dVelocity,&sel_flag,
                         &r_pos );

               VRnoncirc_depth = -1.0;
               VRnoncirc_width = -1.0;

               /*A convert Velocity from fpm to fps    */
               if ( VRenq_proj_units() == VR_IMPERIAL_UNITS )
                        dVelocity = dVelocity/60.;

               /* recompute Equiv diam */
               VREquiDiamFV ( dAirFlow, dVelocity, &dEquiDiam );

               /* set equiv diam in the form */
               FIfld_set_value( form_ptr, EQUIV_DIAM, row, col, dEquiDiam, sel_flag );

      }
      else
      { IGRdouble dAirFlow,dFriction, dEquiDiam;
            /* get air flow */
          FIfld_get_value(form_ptr,AIR_FLOW,row,col,&dAirFlow,&sel_flag,&r_pos );

          FIfld_get_value(form_ptr,FRICTION,row,col,&dFriction,&sel_flag,&r_pos );

          /* recompute Equiv diam */
          VREquiDiamFF ( dAirFlow, dFriction, &dEquiDiam );

             /* set equiv diam in the form */
          FIfld_set_value( form_ptr, EQUIV_DIAM, row, col, dEquiDiam, sel_flag );
      }
      FIg_display   (form_ptr, EQUIV_DIAM);
      FIfld_get_text( form_ptr, SIZE_COMP_METHOD, row, col, MAX_FIELD,
                                (unsigned char *) tmpText, &sel_flag, &r_pos );
      dValue = 0;
      if(strncmp (tmpText,"Enter ",6)) /* modified for TR179801939 */
      {
          status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,VRform_shape,
                 form_ptr,&ListAttr,&NbAttr,&mod_flag);


          if(mod_flag)
          {
	    ModifyAttr = 1;
          }
       }
       /*ENDNEWADD*/
		break;

			/* -------- */
			case SYMB_SERVICE:
			case SERVICE:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_SERVICE_AN );
		break;

			/* -------- */
			case SYMB_SHAPE:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		break;
                /* Below modified for CR179309874 - New raceway shapes */

			/* -------- */
			case RECTANGULAR_SHAPE:
			/* -------- */
			dValue = VR_OVAL;
                        VRform_shape = VR_OVAL; /* TR179800380 */
			NbAttr = 1;
			strcpy( ListAttr[0].name , VR_N_SHAPE_IN );

			/* Modify form for Oval shape */
			/* Added for CR179801144 */
			FIg_erase( form_ptr, N_TIER_DG);
			FIg_erase( form_ptr, SP_TIER_DG);
			FIg_erase( form_ptr, SYMB_N_TIER_DG);
			FIg_erase( form_ptr, SYMB_SP_TIER_DG);
                /* Below modified for CR179309874 - New raceway shapes */
			FIg_erase( form_ptr, RECTANGULAR_SHAPE );
			FIg_erase( form_ptr, CIRCULAR_SHAPE );
			FIg_erase( form_ptr, RADIUS_SHAPE );
 			FIg_erase( form_ptr, ELLP_SHAPE );
			FIg_display( form_ptr, OVAL_SHAPE );

			/* needs for depth */
			FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
			FIg_display( form_ptr, D_SIZE );
			/* no needs for corner radius */
			FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
			FIg_display( form_ptr, CORNER_RADIUS);
                        /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                        if( me->product == VR_HVAC )
                        {  /* Modified for TR179801939 */
                           status = VRchkwd(&me->ModuleInfo,me->product,
                                            me->SysId,VRform_shape,
                                         form_ptr,&ListAttr,&NbAttr,&mod_flag);


  		           if(mod_flag)
          		   {
	    			ModifyAttr = 1;
          		   }
                         } /* end of HVAC */
			break;

			/* -------- */
			case OVAL_SHAPE:
			/* -------- */
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                        if( me->product == VR_HVAC )
                        {
                FIfld_get_value( form_ptr, D_SIZE, row, col,
                              &VRnoncirc_depth, &sel_flag, &r_pos );
                FIfld_get_value( form_ptr, W_SIZE, row, col,
                              &VRnoncirc_width, &sel_flag, &r_pos );
                        }
                        else if( me->product == VR_RWAY )
                        {
                FIfld_get_value( form_ptr, D_RCWY_SIZE, row, col,
                              &VRnoncirc_depth, &sel_flag, &r_pos );
                FIfld_get_value( form_ptr, W_RCWY_SIZE, row, col,
                              &VRnoncirc_width, &sel_flag, &r_pos );
                        }

		dValue = VR_CIRC;
                VRform_shape = VR_CIRC;
                /* ENDNEWADD*/
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		ListAttr[0].desc.value.att_exp = dValue;

                /* Below modified for CR179309874 - New raceway shapes */
		/* Modify form for Circular shape */

		FIg_erase( form_ptr, OVAL_SHAPE );
		FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		FIg_erase( form_ptr, RADIUS_SHAPE );
		FIg_erase( form_ptr, ELLP_SHAPE );
		FIg_display( form_ptr, CIRCULAR_SHAPE );

                /* Below modified for CR179309874 - New raceway shapes */
		/* no need for depth */
                if( me->product == VR_HVAC )
	 {
	     FIfld_set_mode(form_ptr, D_SIZE, 0, FI_REVIEW);
	     FIg_erase   (form_ptr, D_SIZE );
	 }
                else if( me->product == VR_RWAY )
	 {
	     FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_REVIEW);
	     FIg_erase   (form_ptr, D_RCWY_SIZE );
	 }
	 FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);

                /*NEWADD Correction related to CR179700399 included
                with fix for TR179800380 */
                      int_conv = (int)dValue;
                if(me->product == VR_HVAC)
                {  /* modified for TR179801939 */
                    status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                 VRform_shape,form_ptr,&ListAttr,
                                 &NbAttr,&mod_flag);

                    if(mod_flag)
                    {
	                ModifyAttr = 1;
                    }
                } /* end HVAC */
                /*ENDNEWADD*/
		break;

			/* -------- */
			case CIRCULAR_SHAPE:
			/* -------- */
                       /*NEWADD Correction related to CR179700399 included
                            with fix for TR179800380 */
                        if(VRnoncirc_depth > 0.0)
                        {
 		           FIfld_set_value( form_ptr, D_SIZE, row, col,  
                               VRnoncirc_depth,sel_flag );
 		           FIfld_set_value( form_ptr, W_SIZE, row, col,  
                               VRnoncirc_width,sel_flag );
                        }
                        VRnoncirc_depth = -1.0;
                        VRnoncirc_width = -1.0;
	         dValue = VR_CORNER;
                        VRform_shape = VR_CORNER;
	         NbAttr = 1;
	         strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
                        /*ENDNEWADD*/

			/* Modify form for Corner shape */
                /* Below modified for CR179309874 - New raceway shapes */

			FIg_erase( form_ptr, CIRCULAR_SHAPE );
			FIg_erase( form_ptr, RECTANGULAR_SHAPE );
			FIg_erase( form_ptr, OVAL_SHAPE );
			FIg_erase( form_ptr, ELLP_SHAPE );
			FIg_display(form_ptr, RADIUS_SHAPE );

			/* needs for depth or corner radius */
                        FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
                        FIg_display   (form_ptr, D_SIZE );

	         FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_INSERT);
	         FIg_display   (form_ptr, CORNER_RADIUS);
                        /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                        if( me->product == VR_HVAC )
                        {  /* modified for tr179801939 */
                           status = VRchkwd(&me->ModuleInfo,me->product,
                                            me->SysId,VRform_shape,
                                         form_ptr,&ListAttr,&NbAttr,&mod_flag);

                           if(mod_flag)
                           {
	                       ModifyAttr = 1;
                           }
                        }
			break;
			/* -------- */
			case RADIUS_SHAPE:
			/* -------- */
		dValue = VR_RECT;
                VRform_shape = VR_RECT; /* TR179800380 */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_SHAPE_IN );

		/* Modify form for Rectangle shape */
                /* Below modified for CR179309874 - New raceway shapes */

		FIg_erase( form_ptr,  RADIUS_SHAPE );
		FIg_erase( form_ptr,  CIRCULAR_SHAPE );
		FIg_erase( form_ptr,  OVAL_SHAPE );
		FIg_erase( form_ptr, ELLP_SHAPE );
		FIg_display( form_ptr, RECTANGULAR_SHAPE );
		/* Below modified for tier processing - CR179801144 */
		/* needs for depth */
		   FIfld_set_mode(form_ptr, D_SIZE, 0, FI_REVIEW);
		   FIg_display   (form_ptr, D_SIZE );
                if(me->product == VR_RWAY)
		{
                          FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_REVIEW);
                          FIg_display( form_ptr, N_TIER_DG );
                          FIg_display( form_ptr, SP_TIER_DG );
                          FIg_display( form_ptr, SYMB_N_TIER_DG );
                          FIg_display( form_ptr, SYMB_SP_TIER_DG );
                          VR$DispCollAttr(
                               pForm   = form_ptr,
                               Gadget  = N_TIER_DG,
                               pCollId = &me->UsrId,
                               pAttrName = VR_N_NUMTIER1_IN );
                          as$status( action = RET_STATUS );
                          if(me->RcwyCptInfo.nb_tier < 1 ||
                             me->RcwyCptInfo.nb_tier > 10)
                          {
                             me->RcwyCptInfo.nb_tier = 1;
                             me->RcwyCptInfo.tier_sp[0] = VRnoncirc_depth;
                          }
                          FIfld_set_num_rows(form_ptr, N_TIER_DG,
                                                  me->RcwyCptInfo.nb_tier);
                          {
                            IGRint mm;
                            IGRchar temp_sp[20], temp_tn[3];
                            for (mm = 1; mm<me->RcwyCptInfo.nb_tier+1; mm++);
                            {
                              row = mm - 1;
                              sprintf(temp_sp,"%.2f",me->RcwyCptInfo.tier_sp[row]);
                              sprintf(temp_tn,"%d",mm);

                              FIfld_set_text(form_ptr,FRM_TIER_SP_1,row,0,
                                       temp_tn,sel_flag);
                              FIfld_set_text(form_ptr,FRM_TIER_SP_1,row,1,
                                       temp_sp,sel_flag);
                            }
                          }
		          FIg_display   (form_ptr, D_RCWY_SIZE );
		}

		FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
                /* Below modified for CR179309874 - New raceway shapes */
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                if( me->product == VR_HVAC )
                {  /* modified for tr179801939 */
                    status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                    if(mod_flag)
                    {
	                ModifyAttr = 1;
                    }
                }/*ENDNEWADD*/
		break;

/* Below modified for CR179700399 - link of diameter/width/depth */
/* Below modified for CR179309874 - New raceway shapes */
			/* -------- */
			case ELLP_SHAPE:
			/* -------- */
		dValue = VR_ELLIPSE;
                VRform_shape = VR_ELLIPSE; /* TR179800380 */
		NbAttr = 1;
		strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		FIg_erase( form_ptr,  RADIUS_SHAPE );
		FIg_erase( form_ptr,  CIRCULAR_SHAPE );
		FIg_erase( form_ptr,  OVAL_SHAPE );
		FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		FIg_display( form_ptr, ELLP_SHAPE );
		/* needs for depth */
		FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_INSERT);
		FIg_display   (form_ptr, D_RCWY_SIZE );
		break;


			/* -------- */
			case SYMB_MAX_VELOCITY:
			case MAX_VELOCITY:
			/* -------- */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_MAX_VELOC_DB);
		if ( VRenq_proj_units() == VR_IMPERIAL_UNITS )
			dValue = dValue/60;

/* Below modified for CR179700399 - link of diameter/width/depth */
		/* recompute Equiv diam */
		FIfld_get_text( form_ptr, SIZE_METHOD,  row, col,
				MAX_FIELD, (unsigned char *) szText, 
				&sel_flag, &r_pos );
                if(!strncmp (szText, "Velocity",8))
		  VRUpdEquiDiamFV ( form_ptr );
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                VRnoncirc_depth = -1.0;
                VRnoncirc_width = -1.0;
		/* modified for tr179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
	                ModifyAttr = 1;
                }/*ENDNEWADD*/

		break;

/* Below added for CR179700399 - link of diameter/width/depth */
			/* -------- */
			case FRICTION:
		/* Added for TR179801939 */
                FIg_set_state_on( form_ptr, SYMB_FRICTION );
			case SYMB_FRICTION:
			/* -------- */
                        VRnoncirc_depth = -1.0;  /*TR179800380 */
                        VRnoncirc_width = -1.0;  /* TR179800380 */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_FRICTION_FACT_DB);

		/* recompute Equiv diam */
		FIfld_get_text( form_ptr, SIZE_METHOD,  row, col,
				MAX_FIELD, (unsigned char *) szText, 
				&sel_flag, &r_pos );
                if(!strncmp (szText, "Friction",8))
		  VRUpdEquiDiamFF ( form_ptr );
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                /* Could not get standard interface for checkoff to work?? */
		/* modified for TR179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
	                ModifyAttr = 1;
                }/*ENDNEWADD*/
		break;

			/* -------- */
			case SYMB_AIR_FLOW:
			case AIR_FLOW:
			/* -------- */

		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_FLOW_RATE_DB);

                me->dAirFlowSav = dValue;

/* Below modified for CR179700399 - link of diameter/width/depth */
		/* recompute Equiv diam */
		FIfld_get_text( form_ptr, SIZE_METHOD,  row, col,
				MAX_FIELD, (unsigned char *) szText, 
				&sel_flag, &r_pos );
                if(!strncmp (szText, "Velocity",8))
		  VRUpdEquiDiamFV ( form_ptr );
                else /* friction */
		  VRUpdEquiDiamFF ( form_ptr );
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                VRnoncirc_depth = -1.0;
                VRnoncirc_width = -1.0;
                   int_conv = VRform_shape;
                /*ENDNEWADD*/
		/* modified for tr179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
	                ModifyAttr = 1;
                }/*ENDNEWADD*/
		break;

			/* -------- */
			case SYMB_DUCT_THICK:
			case DUCT_THICK:
			/* -------- */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_DUCT_THICK_DB);
		break;

			/* -------- */
			case SYMB_MAX_WIDTH:
			case MAX_WIDTH:
			/* -------- */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_MAX_DEPTH_DB);
                /*NEWADD Correction related to CR179700399 included
                with fix for TR179800380 */
                ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
                ListAttr[0].desc.value.att_exp = dValue;
                VRnoncirc_depth = -1.0;
                VRnoncirc_width = -1.0;
                int_conv = VRform_shape;
	        ModifyAttr = 1;
                /*ENDNEWADD*/

		FIfld_get_value( form_ptr, D_SIZE, row, col,
				 &depth_val, &sel_flag, &r_pos );
		FIfld_get_value( form_ptr, W_SIZE, row, col,
				 &width_val, &sel_flag, &r_pos );
		FIfld_get_value( form_ptr, MAX_WIDTH, row, col,
				 &max_depth, &sel_flag, &r_pos );
                /* Modified for TR179801939 */
                if( (depth_val > max_depth) && (max_depth > 0.0) )
                {
		    FIg_set_state_on( form_ptr, SYMB_D_SIZE );
                    depth_val = max_depth;
                    NbAttr = 3;
	  	    strcpy(ListAttr[1].name, VR_N_DEPTH1_DB);
                    ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
                    ListAttr[1].desc.value.att_exp = depth_val;
		    strcpy(ListAttr[2].name, VR_N_DEPTH1_DB);
                    ListAttr[2].desc.type = AC_ATTRIB_DOUBLE;
                    ListAttr[2].desc.value.att_exp = depth_val;
		    FIfld_set_value( form_ptr, D_SIZE, row, col,  
					depth_val, sel_flag );
                }
		
               /* modified for tr179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

		break;

			/* -------- */
			case SYMB_DUCT_MATER:
			case DUCT_MATER:
			/* -------- */
		NbAttr = 2;
		strcpy(ListAttr[0].name, VR_N_DUCT_MATERIAL_AN);
		/*| DUCT MATERIAL???? */

		// added by Alwin for CR179900696
		// based on the duct material selection, its thickness would be updated
		VRUpdMaterial_InsulationThickness( form_ptr, TRUE, szText, DUCT_THICK );

		FIg_get_value( form_ptr, DUCT_THICK, &dValue );
		strcpy(ListAttr[1].name, VR_N_DUCT_THICK_DB);
		ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		ListAttr[1].desc.value.att_exp = dValue;
		FIg_set_state_on( form_ptr, SYMB_DUCT_THICK );

		break;

			/* -------- */
			case SYMB_SYSTEM:
			case SYSTEM:
			/* -------- */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_SYST_NAME_AN);
		break;

			/* -------- */
			case SYMB_ZONE:
			case ZONE:
			/* -------- */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_ZONE_AN);
		break;
     
            /* -------- */
            case SYMB_ACOUSTIC_MATERIAL:
            case ACOUSTIC_MATERIAL:
            /* -------- */
        NbAttr = 2;
        strcpy(ListAttr[0].name, VR_N_ACST_INSUL_TYPE_AN);
        ListAttr[0].desc.type = AC_ATTRIB_TEXT;

        // based on the acoustic material selection, its thickness would
        // be fetched from DB
        VRUpdMaterial_InsulationThickness( form_ptr, FALSE,
                                            szText, ACOUSTIC_THICK );

        FIg_get_value( form_ptr, ACOUSTIC_THICK, &dValue );

        strcpy(ListAttr[1].name, VR_N_ACST_INSUL_THK_DB);
        ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
        ListAttr[1].desc.value.att_exp = dValue;
        FIg_set_state_on( form_ptr, SYMB_ACOUSTIC_THICK );

	//added for CR179901661
	{
	   IGRdouble      dACST = 0.0;
	   IGRdouble      dThermalThickness=0.0;

	   if( dValue > 0.0 )
	   {
	     FIg_get_value( form_ptr, INSULA_THICK, &dThermalThickness );
	     dACST = dValue + dThermalThickness;
	   }
	   FIg_set_value( form_ptr, ACST, dACST );
	}
        break;

            /* -------- */
            case SYMB_ACOUSTIC_THICK:
            case ACOUSTIC_THICK:
            /* -------- */
        NbAttr = 1;
        strcpy(ListAttr[0].name, VR_N_ACST_INSUL_THK_DB);
        ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

	//added for CR179901661
	{
	   IGRdouble      dACST = 0.0;
	   IGRdouble      dThermalThickness=0.0;

	   if( dValue > 0.0 )
	   {
	     FIg_get_value( form_ptr, INSULA_THICK, &dThermalThickness );
	     dACST = dValue + dThermalThickness;
	   }
	   FIg_set_value( form_ptr, ACST, dACST );
	}
        break;

			/* -------- */
			case SYMB_INSULA_MATER:
			case INSULA_MATER:
			/* -------- */
		ModifyAttr = 1;
		NbAttr = 2;
		strcpy(ListAttr[0].name, VR_N_INSUL_TYPE_AN);

		// added by Alwin for CR179900696
		// based on the insulation selection, its thickness would be 
		// updated
		VRUpdMaterial_InsulationThickness( form_ptr, FALSE, 
											szText, INSULA_THICK );

		FIg_get_value( form_ptr, INSULA_THICK, &dValue );

		strcpy(ListAttr[1].name, VR_N_INSUL_THK_DB);
		ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		ListAttr[1].desc.value.att_exp = dValue;
		FIg_set_state_on( form_ptr, SYMB_INSULA_THICK );

		//added for CR179901661
		{
		   IGRdouble      dACST = 0.0;
		   IGRdouble      dAcousticThickness=0.0;

		   FIg_get_value( form_ptr, ACOUSTIC_THICK,&dAcousticThickness);
		   if( dAcousticThickness > 0.0 )
		   {
		     dACST = dValue + dAcousticThickness;
		   }
		   FIg_set_value( form_ptr, ACST, dACST );
		}
		break;

			/* -------- */
			case SYMB_INSULA_THICK:
			case INSULA_THICK:
			/* -------- */
		ModifyAttr = 1;
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_INSUL_THK_DB);

		//added for CR179901661
		{
		   IGRdouble      dACST = 0.0;
		   IGRdouble      dAcousticThickness=0.0;

		   FIg_get_value( form_ptr, ACOUSTIC_THICK,&dAcousticThickness);
		   if( dAcousticThickness > 0.0 )
		   {
		     FIg_get_value( form_ptr, INSULA_THICK, &dValue );
		     dACST = dValue + dAcousticThickness;
		   }
		   FIg_set_value( form_ptr, ACST, dACST );
		}
		break;

			/* -------- */
			case SYMB_GAP:
			case GAP:
			/* -------- */
		NbAttr = 1;
		strcpy(ListAttr[0].name, VR_N_CP_OFFSET_DB);
		break;
			/* -------- */
			case SYMB_UNIT_NUMBER:
			case      UNIT_NUMBER:
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_UNIT_AN );
		break;
			/* -------- */
			/* - */ case SYMB_PID_SCALE :
			/* - */ case      PID_SCALE :
			/* -------- */
		NbAttr = 1;
		strcpy( ListAttr[0].name, VR_N_PID_SCALE_DB );
		break;

			/* -------- */
			case SYMB_CORNER_RADIUS:
			case CORNER_RADIUS:
			/* -------- */

		strcpy(ListAttr[0].name, VR_N_CORN_RAD_DB);
		if ( dValue > 0 || gadget_label == SYMB_CORNER_RADIUS )	NbAttr=1;
		else
		{
                        NbAttr = 0;
			FIfld_set_text( form_ptr, MESSAGE, row, col,  
				" Corner Radius Should be Greater than 0 ",sel_flag );

			/* Get value from collection */
			ListAttr[0].desc.value.att_exp = 1.0;

			status =
			om$send( msg = message ACrg_collect.ACget_named_attribute
						( &retmsg, &ListAttr[0] ),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			as$status();

			FIfld_set_value( form_ptr, CORNER_RADIUS, row, col,  
					ListAttr[0].desc.value.att_exp, 
					sel_flag );
		}
                /*NEWADD Correction related to CR179700399 included
                    with fix for TR179800380 */
		/* modified for tr179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
	                ModifyAttr = 1;
                }/*ENDNEWADD*/
		break;
			/* -------- */

		/* Following case statement modified by Anand for TR 179900632.
		 * Incidentally, Jeff (who filed this TR) adds the following
		 * line in the TR note:
		 * "This TR is a result of a fix for TR 179801939." */

		/* Added for TR179801939 */
			case SYMB_W_SIZE:
		  FIg_get_state( form_ptr, SYMB_W_SIZE, &sel_flag );
		  __DBGpr_int("width check box checked?",sel_flag);

		  if( sel_flag )
		  {
		      NbAttr = 2;
		      FIfld_get_value( form_ptr, W_SIZE, row, col,
					       &width_val, &sel_flag, &r_pos );
		      strcpy(ListAttr[0].name, VR_N_WIDTH1_DB);
		      ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[0].desc.value.att_exp = width_val;
		      strcpy(ListAttr[1].name, VR_N_WIDTH2_DB);
		      ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[1].desc.value.att_exp = width_val;
		  }
		  else
		  {
		      /* Restore the original value from the collector 
		       * in the width field */

		      struct ACrg_coll CollAttr;

		      strcpy(CollAttr.name, VR_N_WIDTH1_DB);
		      CollAttr.desc.type = AC_ATTRIB_DOUBLE;

		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &CollAttr ),
			  targetid = me->SysId.objid,
			  targetos = me->SysId.osnum );
		      as$status();

		      FIfld_set_value( form_ptr, W_SIZE, row, col, 
				       CollAttr.desc.value.att_exp, sel_flag );

		  }
	          break;

			case W_SIZE:
			/* -------- */
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */

                VRnoncirc_depth = -1.0;
                VRnoncirc_width = -1.0;
                /* modified for TR179801939 */
		if ( dValue > 0 && me->product == VR_RWAY)
                {
                    IGRdouble max_width;
               	    NbAttr = 0;
                    FIfld_get_value( form_ptr, MAX_WIDTH, row, col,
                                           &max_width, &sel_flag, &r_pos );
                    if(dValue > max_width)
                    {
			dValue = max_width;
			FIfld_set_text(  form_ptr, MESSAGE, row, col,  
				" Width set to max_width", sel_flag );
			FIfld_set_value( form_ptr, W_SIZE, row, col,  
					max_width, sel_flag );
                    }
                }
		else if ( dValue > 0 && me->product == VR_HVAC)
               	    NbAttr = 0;
		else
		{
                        NbAttr = 0;
			/* -- Reset width -- */
			FIfld_set_text(  form_ptr, MESSAGE, row, col,  
				" Width Should Be Greater Than 0", sel_flag );

			status =
			om$send( msg = message ACrg_collect.ACget_named_attribute
					( &retmsg, &ListAttr[0] ),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			as$status( action = RET_STATUS );

			FIfld_set_value( form_ptr, W_SIZE, row, col,  
					ListAttr[0].desc.value.att_exp,sel_flag );
                        dValue = ListAttr[0].desc.value.att_exp;/*TR179800380*/
		}
		/* Modified for TR179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
	                ModifyAttr = 1;
                }
                break;
			/* -------- Added for CR179801144 */
			case SYMB_N_TIER_DG:
			case N_TIER_DG:
			case SYMB_SP_TIER_DG:
			case SP_TIER_DG:
			/* -------- */
		if(gadget_label == SYMB_N_TIER_DG ||
		   gadget_label == N_TIER_DG)
		{
		  FIfld_get_value( form_ptr, N_TIER_DG, row, col,
                                           &dValue, &sel_flag, &r_pos );

                  FIg_set_state_on( form_ptr, SYMB_N_TIER_DG );
		  strcpy(ListAttr[0].name, VR_N_NUMTIER1_IN);
                  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
                  ListAttr[0].desc.value.att_exp = dValue;
		  strcpy(ListAttr[1].name, VR_N_NUMTIER2_IN);
                  ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
                  ListAttr[1].desc.value.att_exp = dValue;
                  FIfld_get_value( form_ptr, SP_TIER_DG, row, col,
                                           &tier_sp, &sel_flag, &r_pos );
		  no_tiers = (IGRint) dValue;
                }
                else
		{
		  FIfld_get_value( form_ptr, SP_TIER_DG, row, col,
                                           &dValue, &sel_flag, &r_pos );
                  FIg_set_state_on( form_ptr, SYMB_SP_TIER_DG );
		  strcpy(ListAttr[0].name, VR_N_TIERSP1_DB);
                  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
                  ListAttr[0].desc.value.att_exp = dValue;
		  strcpy(ListAttr[1].name, VR_N_TIERSP2_DB);
                  ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
                  ListAttr[1].desc.value.att_exp = dValue;
                  FIfld_get_value( form_ptr, N_TIER_DG, row, col,
                                          &no_tiers, &sel_flag, &r_pos );
		  tier_sp = dValue;
		}
                /* Modified for TR179801939 */

                status = VRcomp_rw_tier_depth( NULL, my_grid,
				 no_tiers, tier_sp, &depth_val );
		FIfld_set_value( form_ptr, D_RCWY_SIZE, row, col,  
			depth_val, sel_flag );

                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);
		if( mod_flag )
                {
                        ModifyAttr = 1;
		}
		break;

		/* Following case statement modified
		 * by Anand for TR 179900632. */

			/* -------- */
			case SYMB_D_SIZE:
		  FIg_get_state( form_ptr, SYMB_D_SIZE, &sel_flag );
		  __DBGpr_int("depth check box checked?",sel_flag);

		  if( sel_flag )
		  {
		      NbAttr = 2;
		      FIfld_get_value( form_ptr, D_SIZE, row, col,
					&depth_val, &sel_flag, &r_pos );
		      strcpy(ListAttr[0].name, VR_N_DEPTH1_DB);
		      ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[0].desc.value.att_exp = depth_val;
		      strcpy(ListAttr[1].name, VR_N_DEPTH2_DB);
		      ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[1].desc.value.att_exp = depth_val;
		  }
		  else
		  {
		      /* Restore the original value from the collector 
		       * in the width field */

		      struct ACrg_coll CollAttr;

		      strcpy(CollAttr.name, VR_N_DEPTH1_DB);
		      CollAttr.desc.type = AC_ATTRIB_DOUBLE;

		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &CollAttr ),
			  targetid = me->SysId.objid,
			  targetos = me->SysId.osnum );
		      as$status();

		      FIfld_set_value( form_ptr, D_SIZE, row, col, 
				       CollAttr.desc.value.att_exp, sel_flag );

		  }
                  break;
			case D_SIZE:
			/* -------- */
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */

                VRnoncirc_depth = -1.0;
                VRnoncirc_width = -1.0;

		/* gets the max_depth from the database */
			/* -- Reset Depth -- */
		if ( dValue > 0 || gadget_label == SYMB_D_SIZE)
	            NbAttr = 0;
		else
		{
	            NbAttr = 0;
			FIfld_set_text( form_ptr, MESSAGE, row, col,  
				" Depth Should Be Greater Than 0", sel_flag );

			status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
						( &retmsg, &ListAttr[0] ),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			as$status( action = RET_STATUS );
                        dValue = ListAttr[0].desc.value.att_exp;/*TR179800380*/
			FIfld_set_value( form_ptr, D_SIZE, row, col,  
					ListAttr[0].desc.value.att_exp, sel_flag );
		}
                /* Modified for TR179801939 */
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
                        ModifyAttr = 1;
                }

		break;

			/* -------- */
			case SIZE_COMP_METHOD:
			/* -------- */
                /*NEWADD Correction related to CR179700399 included
                        with fix for TR179800380 */
                VRnoncirc_depth = -1.0;
                VRnoncirc_width = -1.0;
                dValue = 0.;
                NbAttr = 0;
                /* modified for TR179801939 */
                if (VRform_shape != VR_CIRC)
                {
                   FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
                   FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
                   FIg_display   (form_ptr, W_SIZE );
                   FIg_display   (form_ptr, D_SIZE );
                }
                else
                {
                  FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
                  FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
                  FIg_display   (form_ptr, W_SIZE ); /* Added for CR179801144*/
                  FIg_display   (form_ptr, D_SIZE ); /* Added for CR179801144*/
                }
                /* modified for TR179801939 */
  
                status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
                                     VRform_shape,form_ptr,&ListAttr,
                                     &NbAttr,&mod_flag);

                if(mod_flag)
                {
                        ModifyAttr = 1;
                }

		break;

			/* -------- */
			case SYMB_THROAT_RADIUS:
			case THROAT_RADIUS:
			/* -------- */
		strcpy(ListAttr[0].name, VR_N_THROAT_DB);


		if ( dValue > 0 || gadget_label == SYMB_THROAT_RADIUS)	NbAttr = 1;
		else
		{
			FIfld_set_text(  form_ptr, MESSAGE, row, col,  
				" Throat Radius Should be Greater than 0 ",sel_flag );

			status =
			om$send( msg = message ACrg_collect.ACget_named_attribute
					( &retmsg, &ListAttr[0] ),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			as$status( action = RET_STATUS );

			FIfld_set_value( form_ptr, THROAT_RADIUS, row, col,  
				ListAttr[0].desc.value.att_exp, sel_flag );
		}
		break;

			/* -------- */
			case SYMB_TRANS_LENGTH: 
			case TRANS_LENGTH: 
			/* -------- */

		strcpy(ListAttr[0].name, VR_N_TRANS_L_DB);

		if ( dValue > 0 || gadget_label == SYMB_TRANS_LENGTH)	NbAttr = 1;
		else
		{
			FIfld_set_text( form_ptr, MESSAGE, row, col,  
				" Transition Length Should be Greater than 0 ", sel_flag );
			status =
			om$send( msg = message ACrg_collect.ACget_named_attribute
					( &retmsg, &ListAttr[0] ),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			as$status( action = RET_STATUS );

			FIfld_set_value( form_ptr, TRANS_LENGTH, row, col,  
				ListAttr[0].desc.value.att_exp, sel_flag );
		}
		break;

			/* -------- */
			case MOD_LOAD_BUTTON:
			/* -------- */
		me->my_ret = MOD_LOAD_COMPONENT;
		_put_response( resp = EX_FORM_FINISHED );
		End
		return OM_S_SUCCESS;

			/* -------- */
			case MOD_USER_ATTR_BUTTON1:
			/* -------- */

		FIg_set_notify_off( form_ptr, gadget_label );
		status = om$send ( msg = message VRchgattr.VRUpdUsrForm (&retmsg),
				targetid = my_id);
		if (!(status&1))
		{
			me->state = _terminate;
			End
			return OM_I_STOP_SENDING;
		}
		/* -- Display user form -- */
		FIf_display( me->form_ptr[SUB] );
		SMVA_disable( me->form_ptr[MAIN], 2, FI_ACCEPT, FI_EXECUTE );
		break;


			/* -------- */
	 		default :
			/* -------- */
		/*| unknown gadget */
		break;

	    }/* end switch on HVAC gadgets */

	    break;
			 /* -------------------------- */
	/* Separate switch statement for VR_CABLING
	   created by Anand for CR  179900491       */

	case VR_CABLING :

	    __DBGpr_com( " Entered the Raceway  case ");

	    switch( gadget_label )
	    {

	      case SYMB_LINE_NUMBER:
	      case LINE_NUMBER:
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SEQ_NUMBER_AN  );
		  break;


	      case SYMB_HVAC_MAT_CLASS:
	      case HVAC_MAT_CLASS:
		  NbAttr = 1;
		  strcpy( ListAttr[0].name,VR_N_CLASS_AN );
		  status = check_spec( &retmsg, me->product, szText, NULL );
		  if( status != OM_S_SUCCESS )
		  {
		      /* TR179801141-Add vendor to Rway form */
		      FIfld_set_text( form_ptr, MESSAGE, 0, 0,
			      "Vendor Code not found in DB", sel_flag );

		  }
		  break;


	      case SYMB_CONST_STATUS:
	      case CONST_STATUS:
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_CONSTR_STAT_AN );
		  break;


	      case SYMB_APPROVAL_STAT:
	      case APPROVAL_STAT:
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_APPRV_STAT_AN );
		  break;


	      case SYMB_SHAPE:
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		  break;


	      case RECTANGULAR_SHAPE:
		  dValue = VR_OVAL;
		  VRform_shape = VR_OVAL; /* TR179800380 */
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SHAPE_IN );

		  /* Modify form for Oval shape */
		  /* Added for CR179801144 */
		  FIg_erase( form_ptr, N_TIER_DG);
		  FIg_erase( form_ptr, SP_TIER_DG);
		  FIg_erase( form_ptr, SYMB_N_TIER_DG);
		  FIg_erase( form_ptr, SYMB_SP_TIER_DG);
		  /* Below modified for CR179309874 - New raceway shapes */
		  FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		  FIg_erase( form_ptr, CIRCULAR_SHAPE );
		  FIg_erase( form_ptr, RADIUS_SHAPE );
		  FIg_erase( form_ptr, ELLP_SHAPE );
		  FIg_display( form_ptr, OVAL_SHAPE );

		  /* oval shape needs depth */
		  FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_INSERT);
		  FIg_display( form_ptr, D_RCWY_SIZE );

		  /* no needs for corner radius */
		  FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
		  FIg_display( form_ptr, CORNER_RADIUS);
		  break;


	      case OVAL_SHAPE:
		  /*NEWADD Correction related to CR179700399 included
		    with fix for TR179800380 */
		  FIfld_get_value( form_ptr, D_RCWY_SIZE, row, col,
			  &VRnoncirc_depth, &sel_flag, &r_pos );
		  FIfld_get_value( form_ptr, W_RCWY_SIZE, row, col,
			  &VRnoncirc_width, &sel_flag, &r_pos );

		  dValue = VR_CIRC;
		  VRform_shape = VR_CIRC;
		  /* ENDNEWADD*/
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[0].desc.value.att_exp = dValue;

		  /* Below modified for CR179309874 - New raceway shapes */
		  /* Modify form for Circular shape */

		  FIg_erase( form_ptr, OVAL_SHAPE );
		  FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		  FIg_erase( form_ptr, RADIUS_SHAPE );
		  FIg_erase( form_ptr, ELLP_SHAPE );
		  FIg_display( form_ptr, CIRCULAR_SHAPE );

		  /* Below modified for CR179309874 - New raceway shapes */
		  /* no need for depth */
		  FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_REVIEW);
		  FIg_erase   (form_ptr, D_RCWY_SIZE );
		  FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
		  break;


	      case CIRCULAR_SHAPE:

		  /*NEWADD Correction related to CR179700399 included
		    with fix for TR179800380 */
		  if(VRnoncirc_depth > 0.0)
		  {
		      FIfld_set_value( form_ptr, D_RCWY_SIZE, row, col,  
			      VRnoncirc_depth,sel_flag );
		      FIfld_set_value( form_ptr, W_RCWY_SIZE, row, col,  
			      VRnoncirc_width,sel_flag );
		  }
		  VRnoncirc_depth = -1.0;
		  VRnoncirc_width = -1.0;
		  dValue = VR_CORNER;
		  VRform_shape = VR_CORNER;
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		  /*ENDNEWADD*/

		  /* Modify form for Corner shape */
		  /* Below modified for CR179309874 - New raceway shapes */
		  FIg_erase( form_ptr, CIRCULAR_SHAPE );
		  FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		  FIg_erase( form_ptr, OVAL_SHAPE );
		  FIg_erase( form_ptr, ELLP_SHAPE );
		  FIg_display(form_ptr, RADIUS_SHAPE );

		  /* needs for depth or corner radius */
		  FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_INSERT);
		  FIg_display   (form_ptr, D_RCWY_SIZE );
		  FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_INSERT);
		  FIg_display   (form_ptr, CORNER_RADIUS);
		  break;


	      case RADIUS_SHAPE:

		  dValue = VR_ELLIPSE;
		  VRform_shape = VR_ELLIPSE; /* TR179800380 */
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
		  FIg_erase( form_ptr,  RADIUS_SHAPE );
		  FIg_erase( form_ptr,  CIRCULAR_SHAPE );
		  FIg_erase( form_ptr,  OVAL_SHAPE );
		  FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		  FIg_display( form_ptr, ELLP_SHAPE );
		  /* needs for depth */
		  FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_INSERT);
		  FIg_display   (form_ptr, D_RCWY_SIZE );
		  break;


	      case ELLP_SHAPE:

		  __DBGpr_com("ELLP_SHAPE");

		  dValue = VR_RECT;
		  VRform_shape = VR_RECT; /* TR179800380 */
		  NbAttr = 1;
		  strcpy( ListAttr[0].name , VR_N_SHAPE_IN );

		  /* Modify form for Rectangle shape */
		  /* Below modified for CR179309874 - New raceway shapes */

		  FIg_erase( form_ptr,  RADIUS_SHAPE );
		  FIg_erase( form_ptr,  CIRCULAR_SHAPE );
		  FIg_erase( form_ptr,  OVAL_SHAPE );
		  FIg_erase( form_ptr, ELLP_SHAPE );
		  FIg_display( form_ptr, RECTANGULAR_SHAPE );
		  /* Below modified for tier processing - CR179801144 */
		  /* needs for depth */
		  FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_REVIEW);
		  FIg_display( form_ptr, N_TIER_DG );
		  FIg_display( form_ptr, SP_TIER_DG );
		  FIg_display( form_ptr, SYMB_N_TIER_DG );
		  FIg_display( form_ptr, SYMB_SP_TIER_DG );
	          __DBGpr_com( " Goin to call VRDispCollAttr fn .");
		  VR$DispCollAttr( pForm	=	form_ptr,
				   Gadget	=	N_TIER_DG,
				   pCollId	=	&me->UsrId,
				   pAttrName	=	VR_N_NUMTIER1_IN );
		  as$status( action = RET_STATUS );
                          if(me->RcwyCptInfo.nb_tier < 1 ||
                             me->RcwyCptInfo.nb_tier > 10)
                          {
                             me->RcwyCptInfo.nb_tier = 1;
                             me->RcwyCptInfo.tier_sp[0] = VRnoncirc_depth;
                          }
                          FIfld_set_num_rows(form_ptr, N_TIER_DG,
                                                  me->RcwyCptInfo.nb_tier);
                          {
                            IGRint mm;
                            IGRchar temp_sp[20], temp_tn[3];
                            for (mm = 1; mm<me->RcwyCptInfo.nb_tier+1; mm++);
                            {
                              row = mm - 1;
                              sprintf(temp_sp,"%.2f",me->RcwyCptInfo.tier_sp[row
]);
                              sprintf(temp_tn,"%d",mm);

                              FIfld_set_text(form_ptr,FRM_TIER_SP_1,row,0,
                                       temp_tn,sel_flag);
                              FIfld_set_text(form_ptr,FRM_TIER_SP_1,row,1,
                                       temp_sp,sel_flag);
                            }
                          }
		  FIg_display   (form_ptr, D_RCWY_SIZE );

		  /* no needs for corner radius */
		  FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
		  break;


	      case SYMB_DUCT_THICK:
	      case DUCT_THICK:

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_DUCT_THICK_DB);
		  break;

	      case SYMB_MAX_WIDTH:
	      case MAX_WIDTH:

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_MAX_DEPTH_DB);

		  /*NEWADD Correction related to CR179700399 included
		    with fix for TR179800380 */

		  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[0].desc.value.att_exp = dValue;
		  VRnoncirc_depth = -1.0;
		  VRnoncirc_width = -1.0;
		  int_conv = VRform_shape;
		  ModifyAttr = 1;

		  /*ENDNEWADD*/

		  FIfld_get_value( form_ptr, D_RCWY_SIZE, row, col,
			  &depth_val, &sel_flag, &r_pos );
		  FIfld_get_value( form_ptr, W_RCWY_SIZE, row, col,
			  &width_val, &sel_flag, &r_pos );
		  FIfld_get_value( form_ptr, MAX_WIDTH, row, col,
			  &max_depth, &sel_flag, &r_pos );

		  /* Modified for TR179801939 */
		  if( (width_val > max_depth) &&  (max_depth > 0.0))
		  { 
		      FIg_set_state_on( form_ptr, SYMB_W_SIZE );
		      width_val = max_depth;
		      NbAttr = 3;
		      strcpy(ListAttr[1].name, VR_N_WIDTH1_DB);
		      ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[1].desc.value.att_exp = width_val;
		      strcpy(ListAttr[2].name, VR_N_DEPTH1_DB);
		      ListAttr[2].desc.type = AC_ATTRIB_DOUBLE;
		      ListAttr[2].desc.value.att_exp = width_val;
		      FIfld_set_value( form_ptr, W_RCWY_SIZE, row, col,  
			      width_val, 
			      sel_flag );
		  }

		  /* modified for tr179801939 */
		  status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
			  VRform_shape,form_ptr,&ListAttr,
			  &NbAttr,&mod_flag);

		  break;

	      case SYMB_DUCT_MATER:
	      case DUCT_MATER:

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_DUCT_MATERIAL_AN);
		  /*| DUCT MATERIAL???? */
		  break;

	      case SYMB_SYSTEM:
	      case SYSTEM:
	
		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_SYST_NAME_AN);
		  break;

	      case SYMB_ZONE:
	      case ZONE:
	
		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_ZONE_AN);
		  break;


	      case SYMB_INSULA_MATER:
	      case INSULA_MATER:

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_INSUL_TYPE_AN);
		  break;
	
	      case SYMB_INSULA_THICK:
	      case INSULA_THICK:

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_INSUL_THK_DB);
		  break;

	      case SYMB_GAP:
	      case GAP:

		  NbAttr = 1;
		  strcpy(ListAttr[0].name, VR_N_CP_OFFSET_DB);
		  break;

	      case SYMB_UNIT_NUMBER:
	      case      UNIT_NUMBER:

		  NbAttr = 1;
		  strcpy( ListAttr[0].name, VR_N_UNIT_AN );
		  break;

		  /* - */ case SYMB_PID_SCALE :
		  /* - */ case      PID_SCALE :

		  NbAttr = 1;
		  strcpy( ListAttr[0].name, VR_N_PID_SCALE_DB );
		  break;

	      case SYMB_CORNER_RADIUS:
	      case CORNER_RADIUS:

		  strcpy(ListAttr[0].name, VR_N_CORN_RAD_DB);
		  if ( dValue > 0 || gadget_label == SYMB_CORNER_RADIUS )	NbAttr=1;
		  else
		  {
		      NbAttr = 0;
		      FIfld_set_text( form_ptr, MESSAGE, row, col,  
			      " Corner Radius Should be Greater than 0 ",sel_flag );

		      /* Get value from collection */
		      ListAttr[0].desc.value.att_exp = 1.0;

		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
			      ( &retmsg, &ListAttr[0] ),
			      targetid = me->SysId.objid,
			      targetos = me->SysId.osnum );
		      as$status();

		      FIfld_set_value( form_ptr, CORNER_RADIUS, row, col,  
			      ListAttr[0].desc.value.att_exp, 
			      sel_flag );
		  }

		  status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
			  VRform_shape,form_ptr,&ListAttr,
			  &NbAttr,&mod_flag);

		  if(mod_flag)
		  {
		      ModifyAttr = 1;
		  }/*ENDNEWADD*/
		  break;

	      case SYMB_W_SIZE:

		  FIg_set_state_on( form_ptr, SYMB_W_SIZE );
		  NbAttr = 2;
		  FIfld_get_value( form_ptr, W_RCWY_SIZE, row, col,
			  &width_val, &sel_flag, &r_pos );
		  strcpy(ListAttr[0].name, VR_N_WIDTH1_DB);
		  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[0].desc.value.att_exp = width_val;
		  strcpy(ListAttr[1].name, VR_N_WIDTH2_DB);
		  ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[1].desc.value.att_exp = width_val;
		  break;

	      case W_RCWY_SIZE:

		  VRnoncirc_depth = -1.0;
		  VRnoncirc_width = -1.0;
		  if ( dValue > 0)
		  {
		      IGRdouble max_width;
		      NbAttr = 0;
		      FIfld_get_value( form_ptr, MAX_WIDTH, row, col,
			      &max_width, &sel_flag, &r_pos );
		      if(dValue > max_width)
		      {
			  dValue = max_width;
			  FIfld_set_text(  form_ptr, MESSAGE, row, col,  
				  " Width set to max_width", sel_flag );
			  FIfld_set_value( form_ptr, W_RCWY_SIZE, row, col,  
				  max_width, sel_flag );
		      }
		  }
		  else
		  {
		      NbAttr = 0;
		      /* -- Reset width -- */
		      FIfld_set_text(  form_ptr, MESSAGE, row, col,  
			      " Width Should Be Greater Than 0", sel_flag );

		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
			      ( &retmsg, &ListAttr[0] ),
			      targetid = me->SysId.objid,
			      targetos = me->SysId.osnum );
		      as$status( action = RET_STATUS );

		      FIfld_set_value( form_ptr, W_RCWY_SIZE, row, col,  
			      ListAttr[0].desc.value.att_exp,sel_flag );
		      dValue = ListAttr[0].desc.value.att_exp;/*TR179800380*/
		  }
		  
		  status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
			  VRform_shape,form_ptr,&ListAttr,
			  &NbAttr,&mod_flag);

		  if(mod_flag)
		  {
		      ModifyAttr = 1;
		  }
		  break;

	      case SYMB_N_TIER_DG:
	      case N_TIER_DG:
	      case SYMB_SP_TIER_DG:
	      case SP_TIER_DG:

	      /** CR179800491 Added event handling for the gadgets - Reddy **/
		{
		      IGRint             active_cpt ;
		      IGRint             proc_mode ;
		      IGRint             NbCpts ;
		      IGRint             j ;

		      proc_mode = 1 ;
		      active_cpt = 1 ;
		      NbCpts = 2 ;
	          __DBGpr_com( "Entered Num tiers/sp. of tiers ");	

		  if(gadget_label == SYMB_N_TIER_DG ||
			  gadget_label == N_TIER_DG)
		  {

		      __DBGpr_com( " Processing for Number of tiers ");

		      FIg_set_state_on(form_ptr, SYMB_N_TIER_DG );
		      FIg_set_state_on(form_ptr, SYMB_D_SIZE );
		      FIg_set_state_on(form_ptr, SYMB_SP_TIER_DG );

		      if(gadget_label == N_TIER_DG)
                      {
                         __DBGpr_com("Calling VRRw_dimen_fields from VRform.I-2");
			      VRRw_dimen_fields(  form_ptr, gadget_label, NULL,
			      NULL,NbCpts, &active_cpt, proc_mode, VRform_shape,
			      &me->RcwyCptInfo, NULL );
		      }
		  }
		  else
		  {
		      __DBGpr_com( " Processing for tier spacing");

		      FIg_set_state_on(form_ptr, SYMB_D_SIZE );
		      FIg_set_state_on(form_ptr, SYMB_SP_TIER_DG );

		      if(gadget_label == SP_TIER_DG)
                      {
			__DBGpr_com("Calling VRRw_dimen_fields from VRform.I3");
			      VRRw_dimen_fields(  form_ptr, gadget_label, NULL,
			      NULL,NbCpts, &active_cpt, proc_mode, VRform_shape,
			      &me->RcwyCptInfo, NULL );
                      }
		  }

		     __DBGpr_com( " Updated Raceway details....... ");
		     __DBGpr_int( " No. of tiers",me->RcwyCptInfo.nb_tier);
		     __DBGpr_dbl( " Width",me->RcwyCptInfo.width);
		     __DBGpr_dbl( " Depth",me->RcwyCptInfo.depth);
		     for( j=0 ; j<(me->RcwyCptInfo.nb_tier); j++)
		     __DBGpr_dbl("Tierspacing" ,me->RcwyCptInfo.tier_sp[j]); 

		      FIg_set_value(form_ptr,D_RCWY_SIZE,me->RcwyCptInfo.depth); 
	        }

		  break;

	      case SYMB_D_SIZE:

		if( (VRform_shape == VR_RECT) || (VRform_shape == VR_CIRC) ) 
		  FIg_set_state_off( form_ptr, SYMB_D_SIZE );

		if( (VRform_shape != VR_RECT) && (VRform_shape != VR_CIRC) ) 
		{
		  FIg_set_state_on( form_ptr, SYMB_D_SIZE );

		  NbAttr = 2;
		  FIfld_get_value( form_ptr, D_RCWY_SIZE, row, col,
			  &depth_val, &sel_flag, &r_pos );
		  strcpy(ListAttr[0].name, VR_N_DEPTH1_DB);
		  ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[0].desc.value.att_exp = depth_val;
		  strcpy(ListAttr[1].name, VR_N_DEPTH2_DB);
		  ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
		  ListAttr[1].desc.value.att_exp = depth_val;
		}
		  break;

	      case D_RCWY_SIZE:

		if( (VRform_shape != VR_RECT) && (VRform_shape != VR_CIRC) ) 
		{
		
		  VRnoncirc_depth = -1.0;
		  VRnoncirc_width = -1.0;

		  /* gets the max_depth from the database */
		  /* -- Reset Depth -- */
		  if ( dValue > 0 || gadget_label == SYMB_D_SIZE)
		      NbAttr = 0;
		  else
		  {
		      NbAttr = 0;
		      FIfld_set_text( form_ptr, MESSAGE, row, col,  
			      " Depth Should Be Greater Than 0", sel_flag );

		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
			      ( &retmsg, &ListAttr[0] ),
			      targetid = me->SysId.objid,
			      targetos = me->SysId.osnum );
		      as$status( action = RET_STATUS );
		      dValue = ListAttr[0].desc.value.att_exp;/*TR179800380*/
		      FIfld_set_value( form_ptr, D_RCWY_SIZE, row, col,  
			      ListAttr[0].desc.value.att_exp, sel_flag );
		  }
		  
		  status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
			  VRform_shape,form_ptr,&ListAttr,
			  &NbAttr,&mod_flag);

		  if(mod_flag)
		  {
		      ModifyAttr = 1;
		  }

		}
		  break;

	      case SIZE_COMP_METHOD:
	
		  VRnoncirc_depth = -1.0;
		  VRnoncirc_width = -1.0;
		  dValue = 0.;
		  NbAttr = 0;
		  
		  if (VRform_shape != VR_CIRC)
		  {
		      FIfld_set_mode(form_ptr, W_RCWY_SIZE, 0, FI_INSERT);
		      FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_INSERT);
		      FIg_display   (form_ptr, W_RCWY_SIZE );
		      FIg_display   (form_ptr, D_RCWY_SIZE );
		  }
		  else
		  {
		      FIfld_set_mode(form_ptr, W_RCWY_SIZE, 0, FI_INSERT);
		      FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_INSERT);
		      FIg_display   (form_ptr, W_RCWY_SIZE ); 
		      FIg_display   (form_ptr, D_RCWY_SIZE ); 
		  }

		  status = VRchkwd(&me->ModuleInfo,me->product,me->SysId,
			  VRform_shape,form_ptr,&ListAttr,
			  &NbAttr,&mod_flag);

		  if(mod_flag)
		  {
		      ModifyAttr = 1;
		  }

		  break;

	      case SYMB_THROAT_RADIUS:
	      case THROAT_RADIUS:
	
		  strcpy(ListAttr[0].name, VR_N_THROAT_DB);


		  if ( dValue > 0 || gadget_label == SYMB_THROAT_RADIUS)	NbAttr = 1;
		  else
		  {
		      FIfld_set_text(  form_ptr, MESSAGE, row, col,  
			      " Throat Radius Should be Greater than 0 ",sel_flag );

		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
			      ( &retmsg, &ListAttr[0] ),
			      targetid = me->SysId.objid,
			      targetos = me->SysId.osnum );
		      as$status( action = RET_STATUS );

		      FIfld_set_value( form_ptr, THROAT_RADIUS, row, col,  
			      ListAttr[0].desc.value.att_exp, sel_flag );
		  }
		  break;

	      case SYMB_TRANS_LENGTH: 
	      case TRANS_LENGTH: 

		  strcpy(ListAttr[0].name, VR_N_TRANS_L_DB);

		  if ( dValue > 0 || gadget_label == SYMB_TRANS_LENGTH)	NbAttr = 1;
		  else
		  {
		      FIfld_set_text( form_ptr, MESSAGE, row, col,  
			      " Transition Length Should be Greater than 0 ", sel_flag );
		      status =
		      om$send( msg = message ACrg_collect.ACget_named_attribute
			      ( &retmsg, &ListAttr[0] ),
			      targetid = me->SysId.objid,
			      targetos = me->SysId.osnum );
		      as$status( action = RET_STATUS );

		      FIfld_set_value( form_ptr, TRANS_LENGTH, row, col,  
			      ListAttr[0].desc.value.att_exp, sel_flag );
		  }
		  break;

              /* For TR179900485 - Replace Component Params button.Alwin*/
              /* Previously we're sharing this gadget form the Display Design
              Params form ( gadget no 20 ). Now this command has its own button
	      which does the Job. In this command we go through series of 
	      methods to do the Job. Whereas in the other command we just
              call a command "Copy Raceway Design Parameters" from the form
              level, by specifying the Command key in the button options. */

	      //case MOD_LOAD_BUTTON:
              case 23:
	
		  __DBGpr_com( " Involing Replace Component Params ..." );

		  /* -- Pop Up the Replace Params button */
		  FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

		  me->my_ret = MOD_LOAD_COMPONENT;
		  _put_response( resp = EX_FORM_FINISHED );
		  End
		  return OM_S_SUCCESS;

	      case MOD_USER_ATTR_BUTTON1:

		  FIg_set_notify_off( form_ptr, gadget_label );
		  status = om$send ( msg = message VRchgattr.VRUpdUsrForm (&retmsg),
			  targetid = my_id);
		  if (!(status&1))
		  {
		      me->state = _terminate;
		      End
		      return OM_I_STOP_SENDING;
		  }
		  /* -- Display user form -- */
		  FIf_display( me->form_ptr[SUB] );
		  SMVA_disable( me->form_ptr[MAIN], 2, FI_ACCEPT, FI_EXECUTE );
		  break;


	      default :

		  /*| unknown gadget */
		  break;

	    } /* end VR_CABLING switch */


 		default :

		/*| unknown product */
		break;

	}/* end Product switch */


	/* ------------------------------------------------------ */
	/* -- UpdateSystem  Collection with modified attribute -- */
	/* ------------------------------------------------------ */

	__DBGpr_int( " Modify Attr Value ", ModifyAttr );
	for (i=0; i<NbAttr; i++)
	{
		if (!ModifyAttr)
		{
			/* -- Remove attributes from modify collection -- */
			/*" Remove <%s> from list\n", ListAttr[i].name */
			status =
			om$send( msg = message ACrg_collect.ACrem_attribute
					( &retmsg, ListAttr[i].name ),
				targetid = me->SMoId.objid,
				targetos = me->SMoId.osnum );
		       	as$status( action = RET_STATUS );
		}
		else
		{
			/*" Add/Mod <%s> in list\n", ListAttr[i].name */
			status =
			om$send( msg = message ACrg_collect.ACget_named_attribute
						( &retmsg, &ListAttr[i] ),
				targetid = me->SysId.objid,
				targetos = me->SysId.osnum );
			__DBGpr_int( " Status of ACget_named_attr", status );
		       	as$status( action = RET_STATUS );
			
			__DBGpr_str( " Modified Attr Name ", ListAttr[i].name );
			/* Kludge */
			if (!(strcmp(ListAttr[i].name,VR_N_CLASS_AN)) && (me->product == VR_HVAC))
				ListAttr[i].desc.type = AC_ATTRIB_TEXT;

			/* Partial fix for TR179900762 */
			if (!(strcmp(ListAttr[i].name,VR_N_FRICTION_FACT_DB)) && (me->product == VR_HVAC))
                        {
                                ListAttr[i].desc.type = AC_ATTRIB_DOUBLE;
                        }

			if ( type != FI_CHECKLIST )
			{
				/*-- Get new attribute value from the form -- */

			    __DBGpr_str( " Attribute name ", ListAttr[i].name);
				if (ListAttr[i].desc.type == AC_ATTRIB_TEXT)
				{
					strcpy (ListAttr[i].desc.value.att_txt, szText );
				}
				else if (ListAttr[i].desc.type == AC_ATTRIB_DOUBLE)
				{
                                        /* Modified for TR179800380 */
					__DBGpr_dbl( " Value ", dValue );
                                        ListAttr[i].desc.value.att_exp = dValue;
				}
				else 
				{
				   __DBGpr_com( " Exiting - not expected " );
				   End
				   return OM_S_SUCCESS;
				}
			}

		}
	} /* end loop on attributes to change */

	if (ModifyAttr)
	{
		status =
		VR$ModifyCollection ( 	p_msg 			= &retmsg,
					Operation 		= VR_MERGE_COLL,
					p_ParamsListToModify 	= ListAttr,
					NbParamsToModify 	= NbAttr,
					p_OutputCollectionId 	= &me->SMoId );

	}/* end update attributes collection with list */

	VRprint_user_attr( &me->SMoId );

	End
	return status;


  } /* if MAIN form */

  else if( form_ptr == me->form_ptr[SUB] )
  {
  	switch ( gadget_label )
    	{
		IGRint	Length1, Length2;

		/* -------------- */
      		/* -- */ case USER_ATTR_FLD:
		/* -------------- */

/* definition of the columns number for the action to perform */

#define NAME_FLD	0
#define VALUE_FLD	1
#define MOD_FLD 	2
#define ADD_FLD 	3
#define DEL_FLD 	4
#define MAX_MARK	2

		/* -- Retrieve row and field modified by the user -- */
		/* 1- column */
		status =
		FImcf_get_active_col( form_ptr, gadget_label, &col, &r_pos );
		if( status != FI_SUCCESS ) as$status();

		/* 2- row */
		status =
		FIfld_get_active_row( form_ptr, gadget_label, &row, &r_pos );
		if( status != FI_SUCCESS ) as$status();

		/* -- Check attribute -- */
		FIfld_get_text_length ( form_ptr, gadget_label, row, 
							NAME_FLD, &Length1 );
		FIfld_get_text_length ( form_ptr, gadget_label, row, 
							VALUE_FLD, &Length2 );

		/* -- If not fully defined -- */
		if ( Length1 <= 1 || Length2 <= 1 )
		{
			/* -- Reset all marks -- */
			FIfld_set_text( form_ptr, gadget_label,  row, MOD_FLD,
					"", sel_flag);
			FIfld_set_text( form_ptr, gadget_label,  row, ADD_FLD,
					"", sel_flag);
			FIfld_set_text( form_ptr, gadget_label,  row, DEL_FLD,
					"", sel_flag);
			/* -- break -- */
			break;
		}

		/* -- If one of the 3 action fields -- */
		if (col >= 2)
		{
			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, col,
					MAX_FIELD, (unsigned char*)szText, 
					&sel_flag, &r_pos );

			Length1 = strlen( szText );

			sel_flag=0;
			/* -- If action was set -- */
			if (Length1>= 1)
			{
				/* -- Just reset it -- */
				FIfld_set_text( form_ptr, gadget_label,  row, col,
						"", sel_flag);
			}/* end reset action */
			/* -- else -- */
			else
			{
				/* -- Set it -- */
				FIfld_set_text( form_ptr, gadget_label,  row, col,
						"x", sel_flag);
				/* -- Switch on action selected -- */
				switch (col)
				{

				/* -- */case MOD_FLD:
					/* -- reset delete field -- */

				/* -- */case ADD_FLD:
					/* -- reset delete field -- */
				FIfld_set_text( form_ptr, gadget_label,  row, DEL_FLD,
						"", sel_flag);
				break;

				/* -- */ case DEL_FLD:
					/* -- reset addition field -- */
				FIfld_set_text( form_ptr, gadget_label,  row, MOD_FLD,
						"", sel_flag);
					/* -- reset modify field -- */
				FIfld_set_text( form_ptr, gadget_label,  row, ADD_FLD,
						"", sel_flag);
				break;

				}/* end switch on action */

			}/* end set action */

		}/* end action selection */

		break;


		/* -------------- */
		/* -- */ case FI_RESET:
		/* -------------- */

		/* -- Redisplay the attributes stored -- */

		status = om$send ( msg = message VRchgattr.VRUpdUsrForm (&retmsg),
				targetid = my_id);
		if (!(status&1))
		{
			me->state = _terminate;
			End
			return OM_I_STOP_SENDING;
		}

		break;

		/* -------------- */
		/* -- */ case FI_ACCEPT:
		/* -- */ case FI_EXECUTE:
		/* -------------- */

		/* -- Reset the collections -- */
		status = om$send ( msg = message VRchgattr.VRResetAttr (VR_USER_ATTR),
				targetid = my_id);

		/* -- Store marked attributes in the adequat collections -- */

		FIfld_get_max_num_rows( form_ptr, USER_ATTR_FLD, &num_rows );
		for ( row=0; row<num_rows; row++ )
		{
			IGRchar		szValue[MAX_FIELD];
			IGRchar		szMark[MAX_MARK];
			/* get its name */
			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, NAME_FLD,
					MAX_FIELD, (unsigned char*)szText, 
					&sel_flag, &r_pos );
			/* get its value */
			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, VALUE_FLD,
					MAX_FIELD, (unsigned char *)szValue, 
					&sel_flag, &r_pos );

			/*"Attribute[%d] <%s,%s>\n",row, szText, szValue*/

			/* -- If marked as ADD -- */
			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, ADD_FLD,
					MAX_MARK, (unsigned char*) szMark, 
					&sel_flag, &r_pos );
			if (szMark[0] == 'x')
			{
				/*| ADD IT */
				/* -- Add it to the Add collection -- */
				status =
				om$send( msg = message ACrg_collect.ACadd_attribute
						( &retmsg, szText, szValue ),
				targetid = me->UAdId.objid,
				targetos = me->UAdId.osnum );
				as$status(); 
			}

			/* -- If marked as MOD -- */
			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, MOD_FLD,
					MAX_MARK, (unsigned char*)szMark, 
					&sel_flag, &r_pos );
			if (szMark[0] == 'x')
			{
				struct ACrg_coll coll;

				/*| MOD IT */
				strcpy( coll.name, szText );

				status = 
				om$send( msg = message ACrg_collect.ACget_named_attribute
						( &retmsg, &coll ),
					targetid = me->UsrId.objid,
					targetos = me->UsrId.osnum );
                                /* TR3367 if not in user, then missing param */
                                if (!(status&1&retmsg))
                                {
                                   struct GRid MisParamId,UsrParamId,SysParamId;
                                   MisParamId.objid = NULL_OBJID;
                                   status = om$send( msg = message
                                                VRGeneric.VRGetParams(
                                                    &retmsg,&SysParamId,
                                                    &UsrParamId,&MisParamId),
                                        targetid = me->LocatedObjects[0].objid,
                                        targetos = me->LocatedObjects[0].osnum);
                                   status = om$send( msg = message 
                                              ACrg_collect.ACget_named_attribute
                                              ( &retmsg, &coll ),
                                        targetid = MisParamId.objid,
                                        targetos = MisParamId.osnum );
                                   as$status();
                                }

				/* -- Add it to the Mod collection -- */
				status =
				om$send( msg = message ACrg_collect.ACadd_attribute_by_type
				( &retmsg, (int)coll.desc.type, szText, szValue ),
				targetid = me->UMoId.objid,
				targetos = me->UMoId.osnum );
				as$status(); 
			}

			/* -- If marked as DEL -- */
			FIfld_get_text( form_ptr, USER_ATTR_FLD, row, DEL_FLD,
					MAX_MARK, (unsigned char*)szMark, 
					&sel_flag, &r_pos );
			if (szMark[0] == 'x')
			{
				/*| DEL IT */
				/* -- Add it to the Del collection -- */
				status =
				om$send( msg = message ACrg_collect.ACadd_attribute
						( &retmsg, szText, szValue ),
				targetid = me->UDeId.objid,
				targetos = me->UDeId.osnum );
				as$status(); 
			}


		}/* end loop on attributes */

		/* -- Reset FI_ button -- */
		FIg_set_state_off( form_ptr, gadget_label );

		/* -- Only FI_ACCEPT and FI_CANCEL must erase the form -- */
		if( gadget_label == FI_EXECUTE )
		{
			om$send ( msg = message VRchgattr.VRUpdUsrForm (&retmsg),
				targetid = my_id);
			break;
		}

		/* -------------- */
		/* -- */ case FI_CANCEL:
		/* -------------- */

        	/*| Erase and Reset the displayed form */
		FIf_erase( form_ptr );
		SMVA_enable( me->form_ptr[MAIN], 2, FI_ACCEPT, FI_EXECUTE );

		/*| Set button to off */
		switch( me->product )
		{
			case VR_PIPING :
				FIg_set_state_off( me->form_ptr[MAIN],
						MOD_USER_ATTR_BUTTON0 );
				FIg_set_notify_on( me->form_ptr[MAIN],
						MOD_USER_ATTR_BUTTON0 );
				break;

			case VR_HVAC:
			case VR_CABLING:
				FIg_set_state_off( me->form_ptr[MAIN],
						MOD_USER_ATTR_BUTTON1 );
				FIg_set_notify_on( me->form_ptr[MAIN],
						MOD_USER_ATTR_BUTTON1 );
				break;
		}

		/* -- Reset FI_ button -- */
		FIg_set_state_off( form_ptr, gadget_label );

		break;

		case SUB_COPY_PARAM :
		case SUB_ADD_TO_LIST :
        		me->my_ret = gadget_label;
        		_put_response( resp = EX_FORM_FINISHED );
			End
        		return OM_S_SUCCESS;

    	} /* END switch ( gadget_label ) */

  } /* me->form_ptr[SUB] */	

quit :

  End
  return OM_S_SUCCESS;

} /* end form_notification method */

/*****************************************************************************

				VRUpdUsrForm

*****************************************************************************/

/*+mi
  Private Message
        VRUpdUsrForm

  Abstract
        Description - 
	This the form notification method for the user form.

  Algorithm
      <Optional>

  Arguments
      <List of names>

  Notes/Remarks
      <Optional>

  Examples
      <Optional>

  Status/Return Code
      status == OM_S_SUCCESS    if success.
      status == OM_E_INVARG     if form_ptr is NULL.

-mo*/

method	VRUpdUsrForm ( int *msg )
{
  IGRint		status = OM_S_SUCCESS;
  IGRint		sel_flag=0;
  IGRint		i,NbAttr;
  IGRlong		retmsg;
  struct ACrg_coll	ListAttr[VR_MAX_ATTR];
  struct GRid SysParamId,UsrParamId,MisParamId;
  IGRint misparinlst;

  extern int	COB_FI_form_notification();

	*msg = MSSUCC;

	/*| prepare sub form */
	if( me->form_ptr[SUB] == NULL )
	{
		/* -- create sub form -- */
		status = FI_SUCCESS;

		status = FIf_new ( SUB, me->form_name[SUB],
						COB_FI_form_notification,
						&me->form_ptr[SUB] );

		if ( status != FI_SUCCESS )
		{
			me->form_ptr[SUB] = NULL;
			return OM_E_ABORT;
		}

		/*** tell the form which cmd it's talking to ***/

		status = FIf_set_cmd_oid_os
			( me->form_ptr[SUB], my_id, OM_Gw_current_OS );

		if( status != FI_SUCCESS ) return OM_E_ABORT;


	} /* end create sub form */

	/* --------------------------------------- */
	/* -- Update field with user collection -- */
	/* --------------------------------------- */

	/* -- Update user collection with the others -- */
        /**** Modified for TR3367 **********/
        misparinlst = FALSE;
        MisParamId.objid = NULL_OBJID;
        if(me->NumOfLocatedObjects == 1)
        {

                status = om$send( msg      = message VRGeneric.VRGetParams(
                                   &retmsg,&SysParamId,&UsrParamId,&MisParamId),
                                targetid = me->LocatedObjects[0].objid,
                                targetos = me->LocatedObjects[0].osnum);

                        /* -- Modify attributes -- */
                if(MisParamId.objid != NULL_OBJID)
                {
                   status =
                     VR$ModifyCollection (   p_msg      = &retmsg,
                                        Operation  = VR_UPDATE_COLL,
                                        p_InputCollectionId  = &me->UMoId,
                                        p_OutputCollectionId = &MisParamId );
                   as$status ();
                   misparinlst = TRUE;
                }
        }

        /* Modified for tr3367 */
	status =
	VR$ModifyCollection ( 	p_msg			= &retmsg,
				Operation		= VR_UPDATE_COLL,
				p_InputCollectionId	= &me->UMoId,
				p_OutputCollectionId	= &me->UsrId );

	status =
	VR$ModifyCollection ( 	p_msg			= &retmsg,
				Operation		= VR_MERGE_COLL,
				p_InputCollectionId	= &me->UAdId,
				p_OutputCollectionId	= &me->UsrId );

	status =
	VR$ModifyCollection ( 	p_msg			= &retmsg,
				Operation		= VR_MERGE_COLL,
				p_InputCollectionId	= &me->UDeId,
				p_OutputCollectionId	= &me->UsrId );

	status =
	VR$DispCollAttr(pForm   = me->form_ptr[SUB],
			Gadget  = USER_ATTR_FLD,
		 	pCollId = &me->UsrId );
	as$status( action = RET_STATUS );

	status =
	om$send( msg = message ACrg_collect.AClist_attribute
				( &retmsg, VR_MAX_ATTR, ListAttr, &NbAttr ),
		targetid = me->UsrId.objid,
		targetos = me->UsrId.osnum );
	as$status();

	/* -- update the the action fields -- */
	for( i=0; i<NbAttr; i++ )
	{
		/*"Attr[%d] <%s>\n",i, ListAttr[i].name */

		/* -- if attribute belong to the modify collection -- */
		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute
					( &retmsg, &ListAttr[i] ),
			targetid = me->UMoId.objid,
			targetos = me->UMoId.osnum );
	       	if (status&1&retmsg)
		{
			FIfld_set_text( me->form_ptr[SUB], USER_ATTR_FLD,
					i, MOD_FLD, "x", sel_flag);
		}

		/* -- if attribute belong to the add collection -- */
		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute
					( &retmsg, &ListAttr[i] ),
			targetid = me->UAdId.objid,
			targetos = me->UAdId.osnum );
	       	if (status&1&retmsg)
		{
			FIfld_set_text( me->form_ptr[SUB], USER_ATTR_FLD,
					i, ADD_FLD, "x", sel_flag);
		}

		/* -- if attribute belong to the delete collection -- */
		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute
					( &retmsg, &ListAttr[i] ),
			targetid = me->UDeId.objid,
			targetos = me->UDeId.osnum );
	       	if (status&1&retmsg)
		{
			FIfld_set_text( me->form_ptr[SUB], USER_ATTR_FLD,
					i, DEL_FLD, "x", sel_flag);
		}

	}/* end loop on attributes */
        /******* tr3367 ********/
        if(misparinlst)
        {
           IGRint sel_flag, init_row, row, mis_numb;
           IGRchar tmp_txt[MAX_FIELD];
           struct ACrg_coll mis_attributes[VR_MAX_ATTR];

           om$send( msg      = message ACrg_collect.AClist_attribute
                                        (       &retmsg, VR_MAX_ATTR,
                                                mis_attributes, &mis_numb ),
                 senderid = NULL_OBJID,
                 targetid = MisParamId.objid,
                 targetos = MisParamId.osnum );

           as$status( action = RET_STATUS );
           init_row = NbAttr;
           sel_flag = 0;
           for ( row=0; row< mis_numb; row++, init_row++ )
           {
                FIfld_set_text
                       ( me->form_ptr[SUB], USER_ATTR_FLD, init_row, 0,
                             mis_attributes[row].name, sel_flag );

                if( mis_attributes[row].desc.type == AC_ATTRIB_DOUBLE )
                {
                        /*|type is AC_ATTRIB_DOUBLE */
                        sprintf( tmp_txt, "%f",
                                    mis_attributes[row].desc.value.att_exp );
                        FIfld_set_text(  me->form_ptr[SUB], USER_ATTR_FLD,
                            init_row, 1, tmp_txt, sel_flag );
                }
                else
                {
                        FIfld_set_text
                        ( me->form_ptr[SUB], USER_ATTR_FLD, init_row, 1,
                                     mis_attributes[row].desc.value.att_txt,
                          sel_flag
                        );
                }
                status =
                om$send( msg = message ACrg_collect.ACget_named_attribute
                                        ( &retmsg, &mis_attributes[row] ),
                        targetid = me->UMoId.objid,
                        targetos = me->UMoId.osnum );
                if (status&1&retmsg)
                {
                        FIfld_set_text( me->form_ptr[SUB], USER_ATTR_FLD,
                                        init_row, MOD_FLD, "x", sel_flag);
                }

           }

        }

return OM_S_SUCCESS;

}/* end VRUpdUsrForm */
/* Inserted to detect a modification of a form field value TR179801939 */
IGRint VRchkwd(MdInfo,product,sysobj,shp_cd,form_ptr,Listattr,NbAttr,ModifyAttr)

struct GRmd_env *MdInfo;
IGRint product;
struct GRid sysobj;
IGRint shp_cd;
char * form_ptr;
struct ACrg_coll *Listattr;
IGRint *NbAttr;
IGRint *ModifyAttr;

{
  IGRdouble width_val,depth_val,dValue;
  IGRint    status, mod_flag, NbTemp;
  int row,col,sel_flag,r_pos, locndx;
  struct ACrg_coll      TempAttr[VR_MAX_ATTR];

  mod_flag = 0;
  *ModifyAttr = 0;
  if(product == VR_RWAY)
  {


        sel_flag = row = col = 0;
        FIfld_get_value( form_ptr,W_RCWY_SIZE, row, col,&width_val,&sel_flag,&r_pos);
        FIfld_get_value( form_ptr,D_RCWY_SIZE, row, col,&depth_val,&sel_flag,&r_pos);

  }
  else if(product == VR_HVAC)
  {
	dValue = 0.0;
        NbTemp = 0;
        status = VRHvupd_wd(form_ptr,shp_cd,&width_val,&depth_val,&dValue,
                                                   &NbTemp,&TempAttr[0]);
  }

         locndx = *NbAttr;
          status = VRCollvsForm(sysobj,VR_N_WIDTH1_DB,
				MdInfo,width_val,
				Listattr,&locndx,&mod_flag);
          if(mod_flag)
          {
	    *ModifyAttr = 1;
	    FIg_set_state_on( form_ptr, SYMB_W_SIZE );
            strcpy(Listattr[locndx].name,VR_N_WIDTH2_DB);
            Listattr[locndx].desc.type = AC_ATTRIB_DOUBLE;
            Listattr[locndx].desc.value.att_exp = width_val;
            locndx++;
          }
          else
            FIg_set_state_off( form_ptr, SYMB_W_SIZE );
          status = VRCollvsForm(sysobj,VR_N_DEPTH1_DB,
				MdInfo,depth_val,
				Listattr,&locndx,&mod_flag);
          if(mod_flag)
          {
	    *ModifyAttr = 1;
	    FIg_set_state_on( form_ptr, SYMB_D_SIZE );
            strcpy(Listattr[locndx].name,VR_N_DEPTH2_DB);
            Listattr[locndx].desc.type = AC_ATTRIB_DOUBLE;
            Listattr[locndx].desc.value.att_exp = depth_val;
	    locndx++;
          }
          else
            FIg_set_state_off( form_ptr, SYMB_D_SIZE );

          *NbAttr = locndx;

return(OM_S_SUCCESS);
}
/* Inserted to detect a modification of a form field value TR179801939 */
IGRint VRCollvsForm(sysobj,CollId,MdInfo,field_value,CollAttr,Collndx,Modflag)
struct GRid sysobj;
IGRchar *CollId;
struct GRmd_env *MdInfo;
IGRdouble field_value;
struct  ACrg_coll  *CollAttr;
IGRint *Collndx;
IGRint *Modflag;
{
struct ret_struct ParamAttr;
IGRint FootIndex = -1, retstatus;
IGRdouble orig_value;
IGRint locndx;
IGRint status;

  *Modflag = 0;
  status =
      om$send( msg      = message ACncpx.ACgive_structure
                                           ( &retstatus,
                                             &FootIndex,
                                             CollId,
                                             &ParamAttr,
                                             MdInfo),
				senderid = NULL_OBJID,
                                targetid = sysobj.objid,
                                targetos = sysobj.osnum );
  as$status();

  orig_value = ParamAttr.var.root_pm_st.value;
  if( ( (orig_value-field_value) * (orig_value-field_value)) > BSBASISVAL)
  {
      if(CollAttr)
      {
         locndx = *Collndx;
         strcpy(CollAttr[locndx].name,CollId);
         CollAttr[locndx].desc.type = AC_ATTRIB_DOUBLE;
         CollAttr[locndx].desc.value.att_exp = field_value;
         *Collndx = locndx + 1;
      }
      *Modflag = 1;
  }
return(status);
}/* end VRCollvsForm */

IGRint VRFormatSysForm ( IGRint 	Product, 
			Form 		pForm, 
			IGRint 		ChgAttrFlag, 
			IGRboolean 	bPidFlag )
{


	VR$DispFormUnits( pForm = pForm );

	if (ChgAttrFlag)
	{
		/* -- Erase active attributes TITLE -- */
		FIg_erase	( pForm, 301 );

		/* -- Display TITLE + CHECK LIST -- */
		FIg_display	( pForm, 300 );
	}

	if (Product == VR_PIPING || Product == VR_HVAC )
	{
		if (bPidFlag) 
		{
			/* Display Pid gadgets */
			FIg_display( pForm, PID_SCALE );
			FIg_display( pForm, SYMB_PID_SCALE );
		}
		else
		{
			/* Erase Pid gadgets */
			FIg_erase( pForm, PID_SCALE );
			FIg_erase( pForm, SYMB_PID_SCALE );
		}
	}/* end Piping P&ID management */

	/* -- Reinitialize the popup lists -- */
	VRGetAttrFromDB( pForm, Product );

return OM_S_SUCCESS;


}/* VRFormatSysForm */


IGRint VRUpdEquiDiamFV ( pForm )
Form	pForm;
{
	IGRdouble 	dAirFlow, dVeloc, dEquiDiam;
	IGRint		row = 0, col = 0, sel_flag=0, r_pos;

	/* get air flow */
	FIfld_get_value(pForm,AIR_FLOW,row,col,
		&dAirFlow,&sel_flag,&r_pos );

	/* get maximum air velocity */
	FIfld_get_value(pForm,MAX_VELOCITY,row,col,
			&dVeloc,&sel_flag,&r_pos );

	/* covert the max velocity from fpm in to fps	*/
	if ( VRenq_proj_units() == VR_IMPERIAL_UNITS )
		dVeloc = dVeloc/60;

	/* recompute Equiv diam */
	VREquiDiamFV ( dAirFlow, dVeloc, &dEquiDiam );
/* Below added for CR179700399 - link of diameter/width/depth */

	/* set equiv diam in the form */
	FIfld_set_value(pForm, EQUIV_DIAM, row, col,
			dEquiDiam, sel_flag );

	return OM_S_SUCCESS;

}/* end VRUpdEquiDiam */
/* Function added for CR179700399 - link of diameter/width/depth */
IGRint VRUpdEquiDiamFF ( pForm )
Form	pForm;
{
	IGRdouble 	dAirFlow, dFriction, dEquiDiam;
	IGRint		row = 0, col = 0, sel_flag=0, r_pos;

	/* get air flow */
	FIfld_get_value(pForm,AIR_FLOW,row,col,
		&dAirFlow,&sel_flag,&r_pos );

	/* get maximum air velocity */
	FIfld_get_value(pForm,FRICTION,row,col,
			&dFriction,&sel_flag,&r_pos );

	/* recompute Equiv diam */
	VREquiDiamFF ( dAirFlow, dFriction, &dEquiDiam );

	/* set equiv diam in the form */
	FIfld_set_value(pForm, EQUIV_DIAM, row, col,
			dEquiDiam, sel_flag );

	return OM_S_SUCCESS;

}/* end VRUpdEquiDiam */

end implementation VRchgattr;
