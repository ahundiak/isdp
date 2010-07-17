/* $Id: VRCOHvaci.I,v 1.2 2001/02/20 01:12:08 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRCOHvaci.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCOHvaci.I,v $
 *	Revision 1.2  2001/02/20 01:12:08  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/02/04  18:26:04  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/25  23:01:10  pinnacle
# Replaced: vrco/VRCOHvaci.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/16  21:26:48  pinnacle
# Replaced: vrco/VRCOHvaci.I for:  by r240_int for route240
#
 *
 * History:
 *
	10/24/1994	Lori 		CR#179422038  Update VRFillForm and 
					form_notification to include HVAC spec

 *	01/15/96	tlb		Add VX_FIproto.h, prototypes
 *  02/04/2000  Alwin	Added code to store the Material Class & thickness.
						CR179900696
 *************************************************************************/

class implementation VRCOHvac;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "igewindow.h"
#include "igrdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "VRchgattrdef.h"
#include "VRcmd.h"
#include "VRMcForm.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "VDSutil.h"
#include "vrtools_pto.h"
#include "vrco_pto.h"
#include "vrdbgmacros.h"
#include "VDmem.h"
#include "VRRwDimen.h"

%safe
#include "VX_FIproto.h"
#include <math.h>
%endsafe

#define	AS_DEBUG
#define VR_MANAGE_TAG	2

from	ACncpx		import	ACgive_structure;

/* ====================================================================	*/

method form_notification ( IGRint form_label ; IGRint gadget_label ; 
			   IGRdouble value ; IGRchar * form_ptr )
{
IGRlong			msg,status;
IGRint			VStatus, Value;
IGRchar			szText [20], err_msg[100];
struct	ACrg_coll	Collection;


  SetProc( Md form_notification ); Begin

  if( !form_ptr )    return OM_S_SUCCESS;

  /* -- If dynamic search message don't remove it --- */
  FIg_get_text( form_ptr, FI_MSG_FIELD, err_msg );
  if( err_msg[0] != '/' )	strcpy( err_msg, "" );

  FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
	
  if( form_ptr == me->status_display_form_ptr && me->ReplaceCommand )
  {
	/*| status display */

  	switch( gadget_label )
    	{
		case FI_CANCEL:
        		FIf_erase( form_ptr );
			me->form_requested = 0;
		 	break;

		case H_ELBOW_BUTTON :
			strcpy( me->szActivePocketMenuName, HELBOWPKTMNU );
			break;

		case H_TEE_BUTTON :
			strcpy( me->szActivePocketMenuName, HTEEPKTMNU );
		 	break;

		case H_OFFSET_BUTTON:
			strcpy( me->szActivePocketMenuName, HOFFSETPKTMNU );
		 	break;

		case ENDDUCT_BUTTON:
			strcpy( me->szActivePocketMenuName, HDUCTENDSPKTMNU );
		 	break;

		case H_REDUCER_BUTTON:
			strcpy( me->szActivePocketMenuName, HREDUCERPKTMNU );
		 	break;

		case DEVICE_BUTTON:
			strcpy( me->szActivePocketMenuName, HDEVICEPKTMNU );
		 	break;

		case TERMINATION:
			strcpy( me->szActivePocketMenuName, HTDEVICEPKTMNU );
		 	break;
		default: break;
      	}
	if( gadget_label != FI_CANCEL )
	{
	        VRChangePocketMenu (me->szActivePocketMenuName);
	 	_put_response( resp = EX_POCKET );
	}
  }
  else if (form_ptr == me->FormPtr)
  {
    switch( gadget_label )
    {
    	case HCODE :
		/*| Updating szAABBCC instance */
		FIg_get_text ( form_ptr, gadget_label, me->CmpAABBCCcode);
		if ( strlen(me->CmpAABBCCcode) > 0 )
		{
		  /*A update the comp num field accordingly */
		  status = 
		  om$send ( msg	= message VRCOProduct.VRSetIdManData( 
					&msg ),
				targetid = my_id);
		  as$status ();
		}
	break;

    	case HCONST_STS :	
		/*| Updating collection const_sts */
		strcpy ( Collection.name , VR_N_CONSTR_STAT_AN ); 
		Collection.desc.type = AC_ATTRIB_TEXT;
		FIg_get_text ( form_ptr, gadget_label, Collection.desc.value.att_txt);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HVMC :	

		{
		  IGRint				nbParams=0;
		  IGRint				nbMaterialClass=0;
		  IGRchar				spec_name[24];
		  struct	ACrg_coll	TempCollection[3];

		  __DBGpr_com( " Reached HVMC " );

		  /*| Updating collection material class*/
		  strcpy ( TempCollection[nbParams].name , VR_N_CLASS_AN ); 
		  TempCollection[nbParams].desc.type = AC_ATTRIB_TEXT;
		  FIg_get_text ( form_ptr, gadget_label, spec_name ); 
		  strcpy( TempCollection[nbParams].desc.value.att_txt, spec_name );

		  status = check_spec( &msg, VR_HVAC,  spec_name );
		  if( status != OM_S_SUCCESS )
		  {
			  FIg_set_text( form_ptr, FI_MSG_FIELD, 
					"Mat. Class not found in DB" );
		  }

		  nbParams++;

		  // added by alwin for CR179900696
		  // Get Material list from the DB and pickup the first material class
		  // and use that for finding out the Material thickness

		  // Get the Nb of Material classes
		  status = VRHGet_Material_Insulation_ClassInfo( &msg, spec_name,
							&nbMaterialClass, NULL, NULL, NULL );

		  if( nbMaterialClass )
		  {
			  // Get the Material list from the DB
			  IGRint		i;
			  IGRchar       **material_class=NULL;
			  IGRdouble		dMaterialThickness=0.0;
			  IGRchar		szMaterialClass[25];

			  material_class = _CALLOC( nbMaterialClass, IGRchar* );
			  if( !material_class ) return OM_E_NODYNMEM;

			  for( i=0; i<nbMaterialClass; i++ )
			  {
				material_class[i] = _CALLOC( 25, IGRchar );
				if( !material_class[i] ) return OM_E_NODYNMEM;
			  }

			  // Get the Nb of Material classes
			  status = VRHGet_Material_Insulation_ClassInfo( &msg, spec_name,
								NULL, material_class, NULL, NULL );

			  strcpy( szMaterialClass, material_class[0] );
			  _LOOPFREE( material_class, nbMaterialClass );

			  __DBGpr_str( "Material Class used ", szMaterialClass );

			  // Pick up the first from the list and findout the thickness
			  // and set it to the Object.
			  VRHGet_Material_Insulation_Thickness( &msg, 
								szMaterialClass, &dMaterialThickness,
								NULL, NULL );
			  __DBGpr_dbl( "Material Thickness ", dMaterialThickness );

			  strcpy( TempCollection[nbParams].name, VR_N_DUCT_MATERIAL_AN );
			  TempCollection[nbParams].desc.type = AC_ATTRIB_TEXT;
			  strcpy( TempCollection[nbParams].desc.value.att_txt, szMaterialClass );
			  nbParams++;
			  strcpy( TempCollection[nbParams].name, VR_N_DUCT_THICK_DB );
			  TempCollection[nbParams].desc.type = AC_ATTRIB_DOUBLE;
			  TempCollection[nbParams].desc.value.att_exp = dMaterialThickness;
			  nbParams++;
		  }

		  VR$ModifyCollection(p_msg = &status,
					  Operation = VR_MERGE_COLL,
					  p_ParamsListToModify = TempCollection,
					  NbParamsToModify = nbParams,
					  p_OutputCollectionId = &me->SysParamId);
		}

/*
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId); */
		as$status ();
	break;

    	case HCMP_NB :
		/*| Updating instance component_number */
		FIg_get_text ( form_ptr, gadget_label, me->CmpNumber);

#ifdef	MANAGE_IDS
		if ( bVR_IS_PID_ACTIVE && me->CmpBehavior == VR_MANAGE_TAG )
		{
			/*A Verify unicity of CompNum */
			struct ret_struct	ParamAttr;
			IGRint 			FootIndex = -1, retstatus;
			IGRdouble		dValue;
			IGRchar			*sEnd=NULL;

			dValue = strtod (me->CmpNumber, &sEnd);
			if ( strlen (sEnd) )
			{
           			ex$message( field   = ERROR_FIELD,
			    	in_buff = "Comp Num is ASCII => NO UNICITY CHECK" );
			}
			else
			{
				/*C Get system name */
				status = 
				om$send( msg      = message 
					ACncpx.ACgive_structure( &retstatus, 
						     &FootIndex, 
					       	     VR_N_SYST_NAME_AN,
		     			       	     &ParamAttr, 
						     &me->ModuleInfo),
					targetid = me->SysParamId.objid,
					targetos = me->SysParamId.osnum );

				retstatus = VDLockSelectedID ( 
					ParamAttr.var.text_st.text_string,
					me->CmpCat, (IGRint) dValue   );
				if ( retstatus == VDS_ID_IS_USED )
				{
					ex$message( field   = ERROR_FIELD,
				    	in_buff = "Comp Num is ALREADY USED !!!" );
				} else if ( retstatus&1 )
				{
					me->PrevTagNum = (int) dValue;
					me->bTagNumUsed = FALSE;
				}
			}
		}/* end verify unicity */
#endif
	break;

    	case HNOTES :
		/*| Updating instance szNotes */
		FIg_get_text ( form_ptr, gadget_label, me->CmpNotes);
	break;

    	case HMTOFLAG :
		/*| Updating instance cNoMtoFlag */
		FIg_get_state ( form_ptr, gadget_label, &Value);
		if( Value )
		{
	    		/*| Toggle state on */
	    		me->CmpNoMtoFlag = '1';
		}
		else
		{
	    		/*| Toggle state off */
	    		me->CmpNoMtoFlag = ' ';
		}
	break;

    	case HWIDTH_G :
		/*| Updating collection VR_N_WIDTH1_DB */
		strcpy ( Collection.name , VR_N_WIDTH1_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HDEPTH_G :
		/*| Updating collection VR_N_DEPTH1_DB */
		strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HWIDTH_R :
		/*| Updating collection VR_N_WIDTH2_DB */
		strcpy ( Collection.name , VR_N_WIDTH2_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HDEPTH_R :
		/*| Updating collection VR_N_DEPTH2_DB */
		strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HCORNER_RAD :
		/*| Updating collection VR_N_CORN_RAD_DB */
		strcpy ( Collection.name , VR_N_CORN_RAD_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HLOAD_FROM :
		me->lRet = VRLOC_CMP;
		FIg_set_state_off (form_ptr, HLOAD_FROM);
		_put_response( resp = EX_FORM_FINISHED );
	break;

	case HVSYM_SCALE :
		/*C Set Sym Scale Factor */
		FIg_get_value( form_ptr , HVSYM_SCALE, &Collection.desc.value.att_exp);
		strcpy( Collection.name, VR_N_PID_SCALE_DB );
      		Collection.desc.type = AC_ATTRIB_DOUBLE;
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case FI_RESET :
		VRGetParamBoxClone( &msg, &me->SavSysParamId, &me->SysParamId);
		VRGetParamBoxClone( &msg, &me->SavUserParamId, &me->UsrParamId);
			
		if( me->SavMissParamId.objid != NULL_OBJID ) 
			VRGetParamBoxClone( &msg, &me->SavMissParamId, &me->MissParamId);
		else	me->MissParamId.objid = NULL_OBJID;

		status = 
    		om$send( msg	   = message VRCOProduct.VRFillForm
						(	&msg,
							&me->CompId, 
							&me->SysParamId, 
							&me->ModuleEnv ),
            		targetid = my_id);
		FIg_set_state_off (form_ptr, FI_RESET);
	break;

    	case FI_CANCEL :
		if( me->FormPtr && !me->ReplaceCommand &&
			me->SysParamId.objid != NULL_OBJID )
		{
	    		me->form_requested = 0;
	    		status = FIf_erase (form_ptr);

	    		FIf_is_displayed (me->FormUser, &VStatus);
	    		if (VStatus)
				if (me->FormUser) FIf_erase (me->FormUser);

#ifdef	MANAGE_IDS
			if ( bVR_IS_PID_ACTIVE )
			{
				struct ret_struct	ParamAttr;
				IGRint 			FootIndex = -1, 
							retstatus;

				/*C Get system name */
				status = 
				om$send( msg      = 
				message ACncpx.ACgive_structure
				   ( &retstatus, 
				     &FootIndex, 
			       	     VR_N_SYST_NAME_AN,
			       	     &ParamAttr, 
				     &me->ModuleEnv ),
				targetid = me->SysParamId.objid,
				targetos = me->SysParamId.osnum );
				as$status();

				/*C unlock the previous unused id */
				if ( !me->bTagNumUsed && me->PrevTagNum != -1 )
				{
				  status =
				  VDUnLockID ( 
				   ParamAttr.var.text_st.text_string,
				   me->CmpCat, me->PrevTagNum );
				  as$status();
				}/* end of unlock */
			}
#endif

		}
		FIg_set_state_off (form_ptr, FI_CANCEL);
		_put_response( resp = TERMINATE );

	break;

    	case FI_EXECUTE :
    	case FI_ACCEPT :
		FIg_set_state_off (form_ptr, gadget_label);
		FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
		FIg_get_text ( form_ptr, HCODE, me->CmpAABBCCcode );
		if( me->CmpAABBCCcode[0] == '\0' )
		{
	  		strcpy( err_msg, "ERROR : Component Code is not defined" );
	  		FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
	  		break;
		} 
		if ( me->PrevTagNum != -1 ) me->bTagNumUsed = TRUE;

		if( me->ReplaceCommand )
		{
			status = VRBuildUserFromForm( me->FormUser, USER_ATTR_FLD,
					&me->UsrParamId, &me->MissParamId );
			as$status();
			
		}
		FIf_is_displayed (me->FormUser, &VStatus);
	    	if (VStatus)
		{
			if (me->FormUser) FIf_erase (me->FormUser);
			FIg_set_state_off( me->FormPtr, PLOAD_USER );
	    	}		me->lRet = VRALL_OK;
		_put_response( resp = EX_FORM_FINISHED );
	break;

    	case HAIR_FLOW :
		strcpy ( Collection.name , VR_N_FLOW_RATE_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HTHROAT_RAD:
		strcpy ( Collection.name , VR_N_THROAT_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HSHAPE:
		/*"Shape case SysParamId <%d>\n", me->SysParamId.objid */
		strcpy ( Collection.name , VR_N_SHAPE_IN ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_text ( form_ptr, gadget_label, szText);
		VRGetShapeCode ( szText, &Value );
		/*"Shape got from field %d\n", Value */
		Collection.desc.value.att_exp = (IGRdouble) Value;
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
		if (VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv))
		{
  			VR$DispCollAttr ( pForm 	= me->FormPtr,
		    			  pCollId	= &me->SysParamId,
		    			  Gadget	= HDEPTH_G,
		    			 pAttrName 	= VR_N_DEPTH1_DB);

  			VR$DispCollAttr ( pForm 	= me->FormPtr,
		    			  pCollId	= &me->SysParamId,
		    			  Gadget	= HDEPTH_R,
		    			 pAttrName 	= VR_N_DEPTH2_DB);
		 }
	break;

    	case HTRANS_L:
		/*| Updating collection VR_N_TRANS_L_DB */
		strcpy ( Collection.name , VR_N_TRANS_L_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

    	case HLOAD_USER :
		FIf_display( me->FormUser );
		{
			IGRint NbParamInList;
			struct GRid ParamList[2];

			/* ADDED by momo 27-03-1992 to update user form */
			ParamList[0] = me->UsrParamId;
			if( me->MissParamId.objid != NULL_OBJID )
			{
				/*| add miss param in the form */
				ParamList[1] = me->MissParamId;
				NbParamInList = 2;
			}
			else NbParamInList = 1;

			VRUpgradeUserForm(	me->FormUser, NbParamInList,
						ParamList, USER_ATTR_FLD );
		}
	break;

    	default :
	break;
    }
  } 
  else
  {
    	/*| Dealing with UserParam form */
    	switch( gadget_label )
	{
    		case FI_CANCEL: 
			/*| FI_CANCEL */
			FIg_set_state_off( me->FormPtr, HLOAD_USER );
			FIg_set_state_off( me->FormUser, FI_CANCEL );
			FIf_erase( form_ptr );
		break;

    		case FI_EXECUTE:
			/*| FI_EXECUTE */
			status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, &me->UsrParamId, &me->MissParamId );
			as$status();

			if ( status == FI_SUCCESS )
				_put_response( resp = EX_FORM_FINISHED);
			FIg_set_state_off( me->FormUser, FI_EXECUTE );
		break;

    		case FI_RESET:
			/*| FI_RESET */
			FIg_set_state_off( me->FormUser, FI_RESET );
		break;

   		 case FI_ACCEPT: 
			status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, &me->UsrParamId, &me->MissParamId );
			as$status();

			FIf_erase( form_ptr );
			FIg_set_state_off( me->FormPtr, HLOAD_USER );
	    		FIg_set_state_off( me->FormUser, FI_ACCEPT );
			_put_response( resp = EX_FORM_FINISHED );
		break;

    	}

  } /* end if */

quit :

  End
  return OM_S_SUCCESS;

} /* end method form_notification */

from	ACrg_collect	import	ACadd_list_attribute;

/* ***************** VRFillForm () ***********************************	*/
method VRFillForm ( IGRlong *ret; struct GRid *CompId;
		    struct GRid *SysParamId; struct GRmd_env *MdEnv )
{

IGRlong				status;	
IGRchar				szCode [15];
struct ret_struct		ParamAttr;
IGRint 				FootIndex = -1, msg, Shape;

  *ret	= MSSUCC;

  if (!me->FormPtr || SysParamId->objid == NULL_OBJID )	
		return OM_S_SUCCESS;

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HWIDTH_G,
		    pAttrName 	= VR_N_WIDTH1_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HDEPTH_G,
		    pAttrName 	= VR_N_DEPTH1_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HWIDTH_R,
		    pAttrName 	= VR_N_WIDTH2_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HDEPTH_R,
		    pAttrName 	= VR_N_DEPTH2_DB);

  status = 
  om$send( msg      = message ACncpx.ACgive_structure( &msg, &FootIndex,
						       VR_N_SHAPE_IN, 
						       &ParamAttr, MdEnv ),
		    targetid = SysParamId->objid,
		    targetos = SysParamId->osnum );
  Shape = (IGRint) ParamAttr.var.root_pm_st.value;
  VRGetShapeString ( Shape, szCode );
  FIg_set_text( me->FormPtr, HSHAPE, szCode);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HCONST_STS,
		    pAttrName 	= VR_N_CONSTR_STAT_AN);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HVMC,
		    pAttrName 	= VR_N_CLASS_AN);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HEQUI_DIA,
		    pAttrName 	= VR_N_EQUIV_DIA_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HTRANS_L,
		    pAttrName 	= VR_N_TRANS_L_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HAIR_FLOW,
		    pAttrName 	= VR_N_FLOW_RATE_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HTHROAT_RAD,
		    pAttrName 	= VR_N_THROAT_DB);

  FIg_set_text( me->FormPtr, HCODE, 	me->CmpAABBCCcode);

  FIg_set_text( me->FormPtr, HNOTES, 	me->CmpNotes);

  FIg_set_text( me->FormPtr, HCMP_NB, 	me->CmpNumber);

  if( me->CmpNoMtoFlag == '1' )
	FIg_set_state ( me->FormPtr, HMTOFLAG, TRUE);
  else
	FIg_set_state ( me->FormPtr, HMTOFLAG, FALSE);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= HCORNER_RAD,
		    pAttrName 	= VR_N_CORN_RAD_DB);
  status = 
  VR$DispCollAttr ( pForm 	= me->FormPtr,
	    	  pCollId	= SysParamId,
	    	  Gadget	= HVSYM_SCALE,
	    	  pAttrName 	= VR_N_PID_SCALE_DB );		

  /*C add symb scale if not found */
  if ( !( status&1 ) )
  {
	IGRlong			retmsg;
	struct ACrg_coll	AttrList;

	strcpy(AttrList.name, VR_N_PID_SCALE_DB);
	AttrList.desc.type = AC_ATTRIB_DOUBLE;
	AttrList.desc.value.att_exp = 1.;
		
	status = om$send( msg      = message 
		ACrg_collect.ACadd_list_attribute( 
			&retmsg, 1, &AttrList ),
		senderid = NULL_OBJID,
		targetid = SysParamId->objid,
		targetos = SysParamId->osnum );
	as$status( action = RET_STATUS );

	status=
	VR$DispCollAttr ( pForm = me->FormPtr,
	    	  pCollId	= SysParamId,
	    	  Gadget	= HVSYM_SCALE,
	    	  pAttrName 	= VR_N_PID_SCALE_DB );		
  }

  if ( bVR_IS_PID( me->cRep ) )
  {
	FIg_display( me->FormPtr, HVSYM_SCALE );
	FIg_display( me->FormPtr, HVSYM_SCALE_TXT );
  }
  else
  {
	FIg_erase( me->FormPtr, HVSYM_SCALE );
	FIg_erase( me->FormPtr, HVSYM_SCALE_TXT );
  }

  return OM_S_SUCCESS;

} /* end method VRFillForm */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method status_disp ( momo 26-03-1992 )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method status_disp()
{
  IGRlong	status;

  /*| call status_disp method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message super_cmd.status_disp(),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  if( me->ReplaceCommand )
  {
	  FIg_erase  ( me->status_display_form_ptr, 24 );
	  FIg_erase  ( me->status_display_form_ptr, 28 );
	  FIg_display( me->status_display_form_ptr, 19 );
  }

  FIf_display( me->status_display_form_ptr );

  return OM_S_SUCCESS;

}
/* ==================================================================== */

method VRDisplayMessage  (IGRlong *ret)
{

*ret = MSSUCC;

switch (me->mytype)
    {
case VR_HVACTRANSITION_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacTransition);
    break;
case VR_HVACREDUCER_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacReducer);
    break;
case VR_HVACMISC_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacMisc);
    break;
case VR_HVACTERMDEV_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacTermDev);
    break;
case VR_HVACDEV_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacDev);
    break;
case VR_HVACENDS_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertDuctEnds);
    break;
case VR_HVACOFFSET_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacOffset);
    break;
case VR_HVACSPLIT_INSERTION:
    ex$message( field   = MESSAGE_FIELD,
		msgnumb = VRC_M_InsertHvacSplit);
    break;
default:
    ex$message( field   = MESSAGE_FIELD,
		in_buff = "Unknown Message");
    }

return OM_S_SUCCESS;

} /* end method VRDisplayMessage */
end implementation VRCOHvac;
