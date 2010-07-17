/* $Id: VRPppara.sl,v 1.6 2001/05/29 15:21:04 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara/VRPppara.sl
 *
 * Description:
 *	Display Piping Parameters Form
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRPppara.sl,v $
 *	Revision 1.6  2001/05/29 15:21:04  anand
 *	Service pack complained of message keys for products besides Route at product
 *	startup. Replaced message keys for this file with the hard-coded Command name
 *	taken from $ROUTE/config/english/messages/src
 *	
 *	Revision 1.5  2001/04/17 23:15:27  anand
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/04/03 20:32:09  anand
 *	TR JTS 4485
 *	
 *	Revision 1.3  2001/02/20 01:14:35  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 16:38:57  anand
 *	SP Merge
 *	
# Revision 1.5  2000/10/16  14:51:10  pinnacle
# Replaced: route/vrpara/VRPppara.sl for:  by aharihar for Service Pack
#
# Revision 1.4  2000/07/21  13:40:02  pinnacle
# Replaced: route/vrpara/VRPppara.sl for:  by apazhani for Service Pack
#
# Revision 1.3  2000/05/08  15:17:14  pinnacle
# Replaced: route/vrpara/VRPppara.sl for:  by apazhani for Service Pack
#
# Revision 1.2  2000/04/14  22:26:52  pinnacle
# Replaced: route/vrpara/VRPppara.sl for:  by aharihar for Service Pack
#
# Revision 1.1  2000/04/10  22:36:40  pinnacle
# Created: route/vrpara/VRPppara.sl by apazhani for Service Pack
#
# Revision 1.1  2000/04/10  18:35:06  pinnacle
# initial revision
#
# Revision 1.2  1999/10/01  06:34:04  pinnacle
# Replaced: vrpara/VRPppara.sl for:  by svngidug for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/14  20:56:30  pinnacle
# Replaced: vrpara for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/24  19:02:52  pinnacle
# Replaced: vrpara/VRPppara.sl for:  by ashankar for route240
#
# Revision 1.3  1996/01/17  14:47:28  pinnacle
# Replaced: vrpara/VRPppara.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:23:14  pinnacle
# Replaced: vrpara/VRPppara.sl for:  by r240_int for route240
#
 *
 * History:
 *      10/24/94        Lori    CR#179422038 Update call to VRGetAttrFromDB
 *				to include product information
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      01/17/97        law     Restore units right of boxes TR179603395
 *      10/01/99        Satish  Added code to update the fluid code field
 *				to the default fluid code when the piping
 *				material class is selected.
 *      10/04/2000      Alwin   Added the search engine for Spec Name gadget
 *     Apr 14 2000      Anand   Modified for Service Pack
 *     May 08 2000      Alwin   Modified to disable/enable accept&run button's
 *				for invalid spec_name.
 *     Oct 16 2000      Anand   CR 179902072 - Called newly implemented fn
 *				VRkeyFltrInCDLdbFlds for alpha-numeric fields
 *				with associative lists.
 *	01/11/2001	Anand	Merging for Pload
 *************************************************************************/

/* Service pack complained about message keys for products besides Route
command_string       VRC_M_DisplayPpDgPr,0,VRDsPpDgPr
 */
command_string       "Display Piping Design Parameters Form",0,VRDsPpDgPr
class                VRPppara
super_class          VRActParam
product_name         "$ROUTE_PATH"
command_table	     "route.cmd"

specification

/************************************************************************

	Specification file for command object
        Display Piping Design Parameters Form

************************************************************************/


implementation


#include <stdlib.h>
#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "bsvalues.h"
#include "FI.h"
#include "FEI.h"
#include "AS_status.h"
#include "VRdef.h"
#include "VRact_params.h"
#include "VRchgattrdef.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRMcForm.h"
#include "vrparameters.h"
#include "VRmsg.h"
#include "VRPid.h"
#include "VDSutil.h"
#include "VDDfEntCode.h"

#include "vrchgatt_pto.h"
#include "vrinit_pto.h"
#include "vrtools_pto.h"

#include "VRDbStruct.h"
#include "dberror.h"
#include "ms.h"
#include "msmacros.h"
#include "VRDbTbl.h"
#include "VRDbCache.h"
#include "vrpdu_pto.h"
#include "VRdbcodlst.h" // Added by Anand
#include "VRPDBdef.h"
#include "VRPDBmac.h"
#include "vrdbgmacros.h"
#include "VDfrm.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define  AS_DEBUG 1

#define  MAX_FIELD 	 256

#define MAIN 0
#define SUB 1

from 	ACrg_collect	import 		ACget_named_attribute,
					ACset_list_attribute,
					ACadd_list_attribute;
from	ACncpx		import		ACgive_structure;

/**********************************************************/
/*********************************************************/

state_table

#include "VRchgattrdef.h"

state start

	execute VRInitAttr (VR_SYSTEM_ATTR|VR_USER_ATTR)
	execute VRDispForm (VR_SYSTEM_ATTR)
	execute VRUpdSysForm ()
	on ELSE		state terminate

/*********************************************************/
/*********************************************************/

action VRSetProduct
{
 me->Product		= VR_PIPING;
 me->CommandName	= COMM_NAME_PIPING;
 me->form_name[MAIN] 	= "VRPpDgPar" ;
 me->form_name[SUB] 	= "VRUserParam" ;
}

/*********************************************************/

action VRUpdSysForm()

{

	/*C display the attributes in the Sys form */
	status = VRUpdALLSysForm( me->Product, 
			me->form_ptr[MAIN],&me->SysId );
	as$status( action = RET_STATUS );

	/* -- Display scale if Representation active is PID -- */

	if ( bVR_IS_PID_ACTIVE )
	{
		FIg_display( me->form_ptr[MAIN], PID_SCALE );
		FIg_display( me->form_ptr[MAIN], PID_SCALE_LABEL );
	}
	else
	{
		FIg_erase( me->form_ptr[MAIN], PID_SCALE );
		FIg_erase( me->form_ptr[MAIN], PID_SCALE_LABEL );
	}

	/* ------------------------------- */
	/* -- Initialize gadget's lists -- */
	/* ------------------------------- */

	VRGetAttrFromDB( me->form_ptr[MAIN], me->Product );

  return (OM_S_SUCCESS);

}/* end VRUpdSysForm */

/*********************************************************/

action	initial_form_notification
{

#ifdef	MANAGE_IDS
	status =
	om$send( msg      = message VRActParam.initial_form_notification(
			form_label,gadget_label, value, form_ptr),
		mode = OM_e_wrt_message,
		targetid = my_id );
       	as$status( action = RET_STATUS );		
#endif
}

/*********************************************************/

/*********************************************************/

action form_notification( int form_label; int gadget_label;
			  double value;	  char * form_ptr )

{
  IGRlong		retmsg;
  IGRint		i;

  IGRchar		szText[MAX_FIELD];
  IGRdouble		dValue;

  IGRint		NbAttr=0;
  IGRshort		ret_flag;
  struct ACrg_coll	ListAttr[VR_MAX_ATTR];

  IGRint	sel_flag=0;
  IGRint	r_pos;
  IGRint	type;
  IGRint	row = 0, col = 0;
  int		num_rows;
  int		length;

  struct VRPDB_spec_key YY;           /* Added for CR179602460 */
  struct VRPDB_spec     XX;           /* Added for CR179602460 */ 
  IGRshort              NN = 0;       /* Added for CR179602460 */
  IGRlong               mesg;         /* Added for CR179602460 */

  SetProc( Md form_notification ); Begin 

  ex$message(in_buff = "",field=ERROR_FIELD);
  if ( form_ptr == NULL )
  {
     	/*| no form_ptr set */
    	return( OM_E_INVARG ); 
  }

  dValue = 0.0;
  szText[0] = '\0';

  /*"form label %d gadget label %d\n", form_label, gadget_label */

  FIfld_get_type( form_ptr, gadget_label, col, &type );
  if ( type == FI_DOUBLE || type == FI_INT )
  {
	FIfld_get_value( form_ptr, gadget_label, row, col,
			 &dValue, &sel_flag, &r_pos );
  }
  else if ( type == FI_ALPHA )	
  {
	FIfld_get_text( form_ptr, gadget_label,  row, col, MAX_FIELD, 
				(unsigned char *) szText, &sel_flag, &r_pos );
  }
  else
  {
	/*|Type of gadget not defined*/
	/*|Probably Text, Button or a Symbol*/
  }
  FIfld_set_text( form_ptr, MESSAGE, 0, 0, "", sel_flag );

if ( form_ptr == me->form_ptr[MAIN] )
 {
  switch( gadget_label )
   {
		/* -------- */
        	/* - */  case FI_ACCEPT:
		/* -------- */
	me->bLineNumUsed = TRUE;

	/* -- Store the active parameters -- */
	VR$active_params(	operation	= VR_REPLACE,
				update_flag	= VR_NOUPDATE,
				act_param_id	= &(me->SysId),
				status		= status );
	as$status();
	ex$message(msgnumb=VR_S_ValuesStored,field=ERROR_FIELD);
	me->delete_flag = 1;

	/* forget about this working collection */
	me->SysId.objid = NULL_OBJID;

	status =
	om$send ( msg     = message VRPppara.delete( 0 ),
			targetid = my_id );

	return status;

		/* -------- */
		/* - */  case FI_CANCEL:
		/* -------- */
	/*A free the unused ids */
	status =
	om$send ( msg     = message VRActParam.VRUnLockId(),
			targetid = my_id );
	as$status();

	me->delete_flag = 1;
	status =
	om$send ( msg     = message VRPppara.delete( 0 ),
			targetid = my_id );
	return status;


		/* -------- */
		/* - */  case FI_EXECUTE:
		/* -------- */

	me->bLineNumUsed = TRUE;
	
	/* -- Store the active parameters -- */
	VR$active_params(	operation	= VR_REPLACE,
				update_flag	= VR_NOUPDATE,
	    			act_param_id	= &(me->SysId),
	    			status		= status );
	as$status( action = RET_STATUS );
	
	ex$message(msgnumb=VR_S_ValuesStored,field=ERROR_FIELD);
	FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );

	/* -- Reinitialize the working collections -- */
	status =
	om$send ( msg   = message VRPppara.VRInitAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );

	return status; 

		/* -------- */
		/* - */  case FI_RESET:
		/* -------- */


	/* -- Forget all changes -- */
	status =
	om$send ( msg   = message VRPppara.VRDeleteAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	/* -- Reinitialize the working collections -- */
	status =
	om$send ( msg   = message VRPppara.VRInitAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );
	as$status( action = RET_STATUS );

        /* TR179603395 law-17Jan97 */
        status = om$send( msg      = message VRActParam.VRDispForm
                                ( VR_SYSTEM_ATTR ),
                          targetid = my_id );
        as$status( action = RET_STATUS );

	status =
	om$send( msg      = message VRActParam.VRUpdSysForm (),
	 	 targetid = my_id );
       	as$status( action = RET_STATUS );
       	FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
      	return OM_S_SUCCESS;

		/* -------- */
		/* - */  case LOAD_COMPONENT:
		/* -------- */

	FIbtn_set_auto_pop_up_on( form_ptr, LOAD_COMPONENT );
	return OM_S_SUCCESS;

		/* -------- */
		/* - */  case PIPING_MAT_CLASS:
		/* -------- */

	/* added for CR179900958. Alwin */
	{
	    IGRshort		nSpec=0;
	    IGRint 		new_list_cnt=0, sel_index;
	    IGRint 		sel_flag=0, unique_flg=0;
	    IGRchar		*speclist;

	    __DBGpr_str( " User Key-in text ", szText );

	    /*| -- Get Spec Name List */
	    status = VRget_spec_list ( &retmsg, VR_PIPING, &nSpec , 
							&speclist, NULL);
	    CheckRC( status, retmsg );
	    if( !status & 1 ) break;
	    __DBGpr_int( " No. of Specs from DB ", nSpec );

	    /* Below call to qsort added by Anand for CR 179902072 */
	    qsort( speclist, nSpec, VR_MAX_SPEC_NAME_LEN, strcmp );

	    /* Filter the DB ( Original ) Spec list as needed for the user */
	    sel_index = -1;
	    status = VDfrm_fld_set_sub_list(form_ptr,
					    gadget_label,
					    MESSAGE,
					    speclist,
					    VR_MAX_SPEC_NAME_LEN,
					    (IGRint)nSpec,
					    &new_list_cnt,
					    0,
					    &sel_index,
					    &unique_flg   );

	    __DBGpr_int( " Unique Flag ", unique_flg );

	    if( unique_flg == 1 )
	    {
		/* Unique match has been found out of User Keyed in string, so
		   we need to proceed further. */

		FIfld_get_text( form_ptr, gadget_label,  row, col, MAX_FIELD, 
				(unsigned char *) szText, &sel_flag, &r_pos );
		__DBGpr_str( " Selected Spec ", szText );
		FIg_enable( form_ptr, FI_EXECUTE );
		FIg_enable( form_ptr, FI_ACCEPT );
	    }
	    else if( sel_index < 0 ) 
	    {
		FIg_disable( form_ptr, FI_EXECUTE );
		FIg_disable( form_ptr, FI_ACCEPT );
		End
		return status;
	    }
	}
	/* added for CR179900958. Alwin */

	__DBGpr_com( " Inside Piping material class case ");

	NbAttr = 1;
	VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL, PIPING_MAT_CLASS,
				NOM_PIPE_DIAM, NOM_PIPE_DIAM, 1 );
 	strcpy( ListAttr[0].name,VR_N_CLASS_AN );

       /* Code below added by Satish for CR179602460 */

       /*************************************************************\
       * CR179602460 requires the fluid code field to be set to the  *
       * default fluid code of the selected spec_name. The value of  *
       * the default fluid code is read from piping_spec table and   *
       * the field is populated as soon as the piping material class *
       * is selected.			- Satish for CR179602460     *
       \*************************************************************/
 
       /* The specname is already read into szText */
       __DBGpr_str( " Spec_name is ", szText);
         strcpy (YY.spec_name, szText );
         YY.spec_no = VRPDB_UNDEF;
 
       /* Get the row corresponding to the spec_name into structure XX */
         VR$PDB_SPEC (p_msg = &mesg,
                     keyin = &YY,
                     p_num = &NN,
                     p_rec = &XX);
         if ((mesg != MSSUCC) || (NN == 0)) return (OM_E_ABORT);
 
       /* Get the fluid code from the d_fld field of the data structure */
       __DBGpr_str( " fluid code ",XX.data.d_fld);
 
       /* Set the text of the fluid code gadget to sztmp */
       FIg_set_text(form_ptr, FLUID_CODE, XX.data.d_fld); 
 
       /* Use a separate element of ListAttr to store modified FLUID_CODE*/
       ListAttr[1].desc.type = AC_ATTRIB_TEXT;
       strcpy( ListAttr[1].name, VR_N_FLUID_CODE_AN); 
       strcpy (ListAttr[1].desc.value.att_txt, XX.data.d_fld);

       /* Call VR$ModifyCollection to update the modified field */
       status =
       VR$ModifyCollection(  p_msg                = &retmsg,
                             Operation            = VR_UPDATE_COLL,
                             p_ParamsListToModify = &ListAttr[1],
                             NbParamsToModify     = NbAttr,
                             p_OutputCollectionId = &me->SysId );

       /* Above code added by Satish for CR179602460 */

      	break;

		/* -------- */
		/* - */  case NOM_PIPE_DIAM:
		/* -------- */
	NbAttr = 2;
	VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL, PIPING_MAT_CLASS,
				NOM_PIPE_DIAM, NOM_PIPE_DIAM, 1 );
 	strcpy( ListAttr[0].name,VR_N_GDIAMETER_DB );
 	strcpy( ListAttr[1].name,VR_N_RDIAMETER_DB );
	break;

		/* -------- */
		/* - */  case LINE_SEQ_NO:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_SEQ_NUMBER_AN );

#ifdef	MANAGE_IDS

	if ( bVR_IS_PID_ACTIVE)
	{
		/*A Verify unicity of LSN */
		struct ret_struct	ParamAttr;
		IGRint			FootIndex = -1, retstatus;
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
	}/* end verify unicity */
#endif

	break;

		/* -------- */
		/* - */  case FLUID_CODE:
		/* -------- */

	/* Below lines added by Anand for CR 179902072 */
	status = VRkeyFltrInCDLdbFlds ( VR_PIPING, VR_P_FLUID_CODE_LSTNUM,
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
	}
	/* Above lines added by Anand for CR 179902072 */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_FLUID_CODE_AN );
	break;

		/* -------- */
		/* - */  case HEAT_TRACING:
		/* -------- */

	/* Below lines added by Anand for CR 179902072 */
	status = VRkeyFltrInCDLdbFlds ( VR_PIPING, VR_P_TRACE_TYPE_LSTNUM,
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
	}
	/* Above lines added by Anand for CR 179902072 */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_TRACING_CODE_AN );
      	break;

		/* -------- */
		/* - */  case INSULATION_THICKNESS:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_INSUL_THK_DB );

	// Convert the insulation thickness text to value for storage sake
	dValue = atof( szText );
	__DBGpr_dbl( " Insulation Thickness Value", dValue );
      	break;

		/* -------- */
		/* - */  case INSULATION_TYPE:
		/* -------- */

	/* Below lines added by Anand for CR 179902072 */
	status = VRkeyFltrInCDLdbFlds ( VR_PIPING, VR_P_INSUL_TYPE_LSTNUM,
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
	/* Above lines added by Anand for CR 179902072 */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_INSUL_TYPE_AN );

	// To update the insulation thickness list. Alwin CR179901615
	VRPGetInsulThkFromType( form_ptr, INSULATION_THICKNESS, szText );
	break;

		/* -------- */
		/* - */  case BLOCK_NO:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_ZONE_AN );
	break;
      	 
		/* -------- */
		/* - */  case OP_NORMAL_TEMP:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_OPER_TEMP_DB );
	break;

		/* -------- */
		/* - */  case OP_NORMAL_PRES:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_OPER_PRESS_DB );
	break;

		/* -------- */
		/* - */  case DES_NORMAL_TEMP:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_DGN_TEMP_DB );
	break;

		/* -------- */
		/* - */  case DES_NORMAL_PRES:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_DGN_PRESS_DB );
	break;


		/* -------- */
		/* - */  case USER_ATTR_BUTTON:
		/* -------- */

	
	status =
	om$send( msg = message VRActParam.VRUpdUsrForm (),
	      	    	  targetid = my_id );
       	as$status( action = RET_STATUS );
	status = om$send( msg      = message VRActParam.VRDispForm
				( VR_USER_ATTR ),
	      	    	  targetid = my_id );
       	as$status( action = RET_STATUS );
	break;

		/* -------- */
		/* - */  case LINE_ID:
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_LINE_ID_AN );
	break;

		/* -------- */
		/* - */  case APPROVAL_STATUS:
		/* -------- */

	/* Below lines added by Anand for CR 179902072 */
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
	/* Above lines added by Anand for CR 179902072 */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_APPRV_STAT_AN );
	break;

		/* -------- */
		/* - */  case CONSTRUC_STATUS:
		/* -------- */

	/* Below lines added by Anand for CR 179902072 */
	status = VRkeyFltrInCDLdbFlds ( VR_PIPING, VR_P_CONST_STS_LSTNUM,
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
	/* Above lines added by Anand for CR 179902072 */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_CONSTR_STAT_AN );
	break;

		/* -------- */
		/* - */  case PID_SCALE :
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_PID_SCALE_DB );
	break;
		/* -------- */
		/* - */  case SYSTEM_NAME :
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_SYST_NAME_AN );
	break;

		/* -------- */
		/* - */  case UNIT_NUMBER :
		/* -------- */

	NbAttr = 1;
	strcpy( ListAttr[0].name, VR_N_UNIT_AN );
	break;

default:
	 /*| Undefined Gadget */
   	 break;

  }/* end switch (gadget label ) */

  /* ----------------------------------------------- */
  /* -- Update Collection with modified attribute -- */
  /* ----------------------------------------------- */

  __DBGpr_com( "About to update the modified fields");
  for (i=0; i<NbAttr; i++)
  {
	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ListAttr[i] ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );

	if (ListAttr[i].desc.type == AC_ATTRIB_TEXT)
	{
		strcpy (ListAttr[i].desc.value.att_txt, szText );
	}
	else if (ListAttr[i].desc.type == AC_ATTRIB_DOUBLE)
	{
		ListAttr[i].desc.value.att_exp = dValue;
	}
	else return OM_S_SUCCESS;

  } /* end loop on attributes to change */
  __DBGpr_com( "Got all the modified fields");

  status =
  VR$ModifyCollection( 	p_msg 			= &retmsg,
			Operation 		= VR_UPDATE_COLL,
			p_ParamsListToModify 	= ListAttr,
			NbParamsToModify 	= NbAttr,
			p_OutputCollectionId 	= &me->SysId );
  __DBGpr_com( " Updated the modified attributes of the main form");
  End
  return status;

 } /* me->form_ptr[MAIN] */

else if ( form_ptr == me->form_ptr[SUB] )
 {
	/*| User Attributes Form */
  switch ( gadget_label )
  {

    case USER_ATTR_FLD:

	/*|Get the text string just for debug*/


	status = FIfld_get_text( form_ptr, gadget_label, (int)value, 0,
				MAX_FIELD, (unsigned char *) szText, 
				&sel_flag, &r_pos );
	status = FIfld_get_text(  form_ptr, gadget_label,  (int)value, 1,
				MAX_FIELD,   (unsigned char *) szText, 
				&sel_flag, &r_pos );
/*
	status = FIfld_get_text(  form_ptr, gadget_label,  (int)value, 2,
				MAX_FIELD,   (unsigned char *) szText, 
				&sel_flag, &r_pos );
	printf ("Type[%d]  = %s\n",(int)value, szText );
*/

       break;

    case FI_CANCEL:     /* Member of group   */

	FIg_set_state_off( form_ptr, gadget_label );
	/*| Erase and RESET the displayed form */

	status = FIf_erase( me->form_ptr[SUB] );

	/*| Enable & Set button to off */
	FIg_set_state_off( me->form_ptr[MAIN], USER_ATTR_BUTTON );
	FIg_set_notify_on( me->form_ptr[MAIN], USER_ATTR_BUTTON );

        break;

    case FI_EXECUTE:
    case FI_ACCEPT: 

	/* Reset working collection */
	status =
	om$send( msg = message ACrg_collect.ACset_list_attribute
			( &retmsg, 0, ListAttr ),
		targetid = me->UsrId.objid,
		targetos = me->UsrId.osnum );
       	as$status( action = RET_STATUS );

	FIfld_get_num_rows( form_ptr, USER_ATTR_FLD, &num_rows );

	for ( row=0; row<num_rows; row++ )
	{
		IGRchar	szValue[MAX_FIELD];

		/* Get name's length */
		length = 0;
		FIfld_get_text_length (form_ptr, USER_ATTR_FLD, row, 0,&length);
		/* if length <=1 => name not specified => forget */
		if (length > 1 )
		{

		FIfld_get_text( form_ptr, USER_ATTR_FLD, row, 0, length,
				(unsigned char *) szText, &sel_flag, &r_pos );


     		FIfld_get_text( form_ptr, USER_ATTR_FLD, row, 1, MAX_FIELD,
     				(unsigned char *) szValue, &sel_flag, &r_pos );
		VRAsciiToAttr ( szText, szValue, ListAttr );
		status =
		om$send( msg = message ACrg_collect.ACadd_list_attribute
			( &retmsg, 1, ListAttr ),
			targetid = me->UsrId.objid,
			targetos = me->UsrId.osnum );
	       	as$status( action = RET_STATUS );

		}
	}

	VR$active_params( operation		= VR_REPLACE,
			  update_flag		= VR_NOUPDATE,
                          VRproduct             = VR_PIPING,
	    		  act_param_id		= &(me->UsrId),
			  mode			= VR_USER_MODE,
	    		  status		= status );
        as$status( action = RET_STATUS );

        FIg_set_state_off( form_ptr, gadget_label );

	/* -- Reinitialize the working collections -- */
	status =
	om$send ( msg   = message VRPppara.VRInitAttr( VR_USER_ATTR ),
		targetid = my_id );
	as$status();
        /*| Erase the displayed form */
	if ( gadget_label ==  FI_ACCEPT )
	{
		status = FIf_erase( form_ptr );
 		/*| Set button to off */
       		FIg_set_state_off( me->form_ptr[MAIN], USER_ATTR_BUTTON );
       		FIg_set_notify_on( me->form_ptr[MAIN], USER_ATTR_BUTTON );
	}

       break;

  } /* END switch ( gadget_label ) */

} /* me->form_ptr[SUB] */	


else
 {
   /*| Unknow form_ptr] */
   return ( OM_E_INVARG );
 }

   return (OM_S_SUCCESS);

} /* end form_notification */


