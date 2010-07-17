/* $Id: VRCORwayi.I,v 1.3 2001/02/20 01:12:21 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRCORwayi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCORwayi.I,v $
 *	Revision 1.3  2001/02/20 01:12:21  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 22:46:22  anand
 *	SP merge
 *	
# Revision 1.2  2000/05/10  15:03:38  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.7  2000/02/07  21:46:28  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by lawaddel for route
#
# Revision 1.6  1999/11/05  19:56:22  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by lawaddel for route
#
# Revision 1.5  1999/05/30  15:20:30  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by apazhani for route
#
# Revision 1.4  1999/04/30  21:21:22  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by apazhani for route
#
# Revision 1.3  1999/04/19  17:20:06  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by apazhani for route
#
# Revision 1.2  1998/08/05  15:59:50  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/12/23  15:58:44  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/02/04  06:59:24  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/16  21:27:30  pinnacle
# Replaced: vrco/VRCORwayi.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      12/02/97        law     CR179603118-fixed accept/execute on sub form
 *      07/25/98        LAW     Added tiers for raceway - CR179801144
 *      04/19/99        Alwin   Modified the design the of Raceway Tiers to
 *				Multi Tiers
 *      05/01/99        Alwin   Displayed the attributes for shape transitions
 *      05/30/99        Alwin   Commented the call to VRDelOldTierAttrs()
 *      11/5/99         law	form cleanup
 *      02/07/00        law     tr179900976-regression for component replace
 *      May 9 2k        Anand   Removed FIg_erase calls to Corner Radius related
 *                              fields for all Raceway forms - TR 179901473
 *
 *************************************************************************/
class implementation VRCORway;

#include <stdio.h>
#include <string.h>
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
#include "VRcmd.h"
#include "VRMcForm.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "vrtools_pto.h"
#include "vrco_pto.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
#include <math.h>
%endsafe

#define	AS_DEBUG

from	ACncpx		import	ACgive_structure;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method status_disp

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
  	FIg_erase  ( me->status_display_form_ptr, 19 );
  	FIg_erase  ( me->status_display_form_ptr, 24 );
  	FIg_display( me->status_display_form_ptr, 28 );
  }

  FIf_display( me->status_display_form_ptr );

  return OM_S_SUCCESS;
}
/* ====================================================================	*/

method form_notification ( IGRint form_label ; IGRint gadget_label ; 
				IGRdouble value ; IGRchar * form_ptr )
{
IGRlong			msg, status;
IGRint			VStatus, Value;
IGRchar			szText [20], err_msg[100];
struct	ACrg_coll	Collection;
IGRdouble		no_tier,sp_tier,depth_val; /* CR179801144 */
struct GRid		my_grid;                   /* CR179801144 */
IGRdouble		corner_rad;                /* tr179900932 */

  SetProc( Md form_notification ); Begin

  if (!form_ptr)
  {
     End
     return OM_S_SUCCESS;
  }

  /* load my_grid for CR179801144 tier processing */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  strcpy( err_msg, "" );
  status = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
  if( form_ptr == me->status_display_form_ptr && me->ReplaceCommand )
  {
  	switch( gadget_label )
    	{
		case FI_CANCEL:
        		FIf_erase( form_ptr );
			me->form_requested = 0;
		 	break;

		case R_ELBOW_BUTTON :
			strcpy( me->szActivePocketMenuName, HELBOWPKTMNU );
		 	break;

		case R_TEE_BUTTON :
			strcpy( me->szActivePocketMenuName, HTEEPKTMNU );
		 	break;

		case R_OFFSET_BUTTON:
			strcpy( me->szActivePocketMenuName, HOFFSETPKTMNU );
		 	break;

		case R_REDUCER_BUTTON:
			strcpy( me->szActivePocketMenuName, HREDUCERPKTMNU );
		 	break;
      	}
	if( gadget_label != FI_CANCEL )
	{
		VRChangePocketMenu (me->szActivePocketMenuName);
   		_put_response( resp = EX_POCKET );
	}
  }
  else if (form_ptr == me->FormPtr)
  {
   switch ( gadget_label ) 
   {
	case HCODE :
		FIg_get_text ( form_ptr, gadget_label, me->CmpAABBCCcode);

                /* AAAA added by alwin for Raceway Enhancement */
                if( ( me->Product == VR_RWAY ) &&
                    ( me->CmpAABBCCcode[0] != '\0' ) )
                {
                   IGRint direct_index, i, LocalCmpNbCpts;
                   IGRchar spec_name[20];
                   struct ret_struct Attr;

                   FIg_display( form_ptr, 29 );
                   FIg_get_text ( form_ptr, HSHAPE, szText);
                   VRGetShapeCode ( szText, &Value );

                   Attr.var.text_st.text_string[0] = '\0';
                   status =
                   om$send ( msg = message ACncpx.ACgive_structure
                        ( (int*) &msg, &direct_index, VR_N_CLASS_AN,
                              &Attr, &me->ModuleInfo ),
                        targetid = me->SysParamId.objid,
                        targetos = me->SysParamId.osnum );
                   as$status();

                   __DBGpr_str( " Vendor name ", Attr.var.text_st.text_string );

                   strcpy( spec_name, Attr.var.text_st.text_string );

                   /* Get the number of the connect point for the
                   comp_code keyed in. */
                   __DBGpr_com( " Calling the fn VRGetComp_NbCpt ...");
                   status = VRGetComp_NbCpt( &msg, VR_RWAY, Value,
                                        spec_name, me->CmpAABBCCcode,
                                        &LocalCmpNbCpts );

                   FIg_set_text( form_ptr, ACTIVE_CPT_INDEX, "2" );

                   FIg_disable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
                   FIg_disable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );

                   if( msg & MSFAIL )
                   {
                      FIg_erase ( form_ptr, 29 );
                      UI_status( " Component not found in DB " );
                      FIg_set_text( form_ptr, MESSAGE,
                                "Component's code query failed " );
                      break;
                   }

                   __DBGpr_int( " Nb. of Connect Pts.", LocalCmpNbCpts );

		   /****
                   if( Value != VR_RECT )
                   {
                      FIg_erase ( form_ptr, 29 );
                      break;
                   }
		   ****/

                   //if( LocalCmpNbCpts  > me->CmpNbCpts )
                   if( LocalCmpNbCpts  > 2 )
                   {
                     FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );

                     // assign the Cpt 0 information to all the other
                     // connect points. If the user wants let him
                     //modify as he wishes
                     for( i=me->CmpNbCpts; i<LocalCmpNbCpts; i++ )
                     {
                       IGRint j;

                       me->RwCptData[i].width = me->RwCptData[0].width;
                       me->RwCptData[i].depth = me->RwCptData[0].depth;
                       me->RwCptData[i].nb_tier = me->RwCptData[0].nb_tier;

                       for( j=0; j<me->RwCptData[i].nb_tier; j++ )
                       {
                         me->RwCptData[i].tier_sp[j] =
                                          me->RwCptData[0].tier_sp[j];
                       }
                     }
                   }
                   else if( LocalCmpNbCpts < 2 )
                   {
                     FIg_erase( form_ptr, FRM_NO_TIER_2 );
                     FIg_erase( form_ptr, FRM_TIER_SP_2 );
                   }
                   me->CmpNbCpts = LocalCmpNbCpts;
                }
                break;

        case FRM_WIDTH_1 :
        case FRM_WIDTH_2 :
        case FRM_DEPTH_1 :
        case FRM_DEPTH_2 :
        case FRM_NO_TIER_1 :
        case FRM_NO_TIER_2 :
        case FRM_TIER_SP_1 :
        case FRM_TIER_SP_2 :
        case INCREASE_ACTIVE_CPT_INDEX :
        case DECREASE_ACTIVE_CPT_INDEX :
        {
            IGRint proc_mode, active_cpt;

            FIg_get_text ( form_ptr, HSHAPE, szText);
            VRGetShapeCode ( szText, &Value );

            __DBGpr_com( " Calling1 the Fn VRRw_dimen_fields ... " );
            proc_mode = 1; //for Storing the information in the instance
            active_cpt = 2;
            __DBGpr_int( " Nb. of Connect points ", me->CmpNbCpts );
            status =
            VRRw_dimen_fields( form_ptr, gadget_label,
                                NULL, &me->ModuleInfo, me->CmpNbCpts,
                                &active_cpt, proc_mode, Value,
                                me->RwCptData, &me->SysParamId );
        }
        break;
        /* AAAA added by alwin for Raceway Enhancement */

	case HCONST_STS :	
		strcpy ( Collection.name , VR_N_CONSTR_STAT_AN ); 
		Collection.desc.type = AC_ATTRIB_TEXT;
		FIg_get_text ( form_ptr, gadget_label, Collection.desc.value.att_txt);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

	case HCMP_NB :
		FIg_get_text ( form_ptr, gadget_label, me->CmpNumber);
	break;

	case HNOTES :
		FIg_get_text ( form_ptr, gadget_label, me->CmpNotes);
	break;

	case HMTOFLAG :
		FIg_get_state ( form_ptr, gadget_label, &Value);
		if (Value)
	    		me->CmpNoMtoFlag = '1';
		else
	    		me->CmpNoMtoFlag = ' ';
	break;

	case HWIDTH_G :
		strcpy ( Collection.name , VR_N_WIDTH1_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

/* following peice of code is not being used any more, b'cas we have changed the
gadget lables and more over we've redesigned the entire Raceway tier stuff
again. Alwin*/
#if 0
	/* Tiers added for CR179801144 */
	case RN_TIER_CM1 :
		   FIg_get_value ( form_ptr, RN_TIER_CM1, &no_tier);
		   strcpy ( Collection.name , VR_N_NUMTIER1_IN ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = no_tier;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
	break;
	case RN_TIER_CM2 :
		   FIg_get_value ( form_ptr, RN_TIER_CM2, &no_tier);
		   strcpy ( Collection.name , VR_N_NUMTIER2_IN ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = no_tier;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
	break;
	case RSP_TIER_CM1 :
		   FIg_get_value ( form_ptr, RSP_TIER_CM1, &sp_tier);
		   strcpy ( Collection.name , VR_N_TIERSP1_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = sp_tier;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
	break;
	case RSP_TIER_CM2 :
		   FIg_get_value ( form_ptr, RSP_TIER_CM2, &sp_tier);
		   strcpy ( Collection.name , VR_N_TIERSP2_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = sp_tier;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
	break;
#endif

	case HDEPTH_G :
		strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

	case HWIDTH_R :
		strcpy ( Collection.name , VR_N_WIDTH2_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

	case HDEPTH_R :
		strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

	case HLOAD_FROM :
    		me->lRet	= VRLOC_CMP;
		_put_response( resp = EX_FORM_FINISHED);
		FIg_set_state_off (form_ptr, HLOAD_FROM);
	break;

	case FI_RESET :
		VRGetParamBoxClone ( &msg, &me->SavSysParamId, &me->SysParamId);
	   	VRGetParamBoxClone ( &msg,&me->SavUserParamId, &me->UsrParamId);

   		if( me->SavMissParamId.objid != NULL_OBJID ) VRGetParamBoxClone ( &msg,&me->SavMissParamId, &me->MissParamId );
		else 					     me->MissParamId.objid = NULL_OBJID;

	    	status =
		om$send ( msg      = message VRCOProduct.VRRestoreForm( &msg),
			  targetid = my_id);
	    	as$status ();
		FIg_set_state_off (form_ptr, FI_RESET);
	break;

	case FI_CANCEL :
		if( !me->ReplaceCommand )
		{
	    		FIf_erase (form_ptr);
	    		FIf_is_displayed (me->FormUser, &VStatus);
	    		if (VStatus)
			{
				if (me->FormUser)	FIf_erase (me->FormUser);
				FIg_set_state_off( me->FormPtr, PLOAD_USER );
			}
	 	}
		_put_response( resp = TERMINATE );

	break;

	case FI_ACCEPT :
	{
		FIg_get_text ( form_ptr, HCODE, me->CmpAABBCCcode );
		if( me->CmpAABBCCcode[0] == '\0' )
		{
	  		strcpy( err_msg, "ERROR : Component Code is not defined" );
	  		FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
	  		FIg_set_state_off (form_ptr, FI_ACCEPT);
	  		break;
		} 
/*** quick fix for tr179900932 ***/
		   FIg_get_value ( form_ptr, RCORNRAD, &corner_rad);

		   strcpy ( Collection.name , VR_N_CORN_RAD_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = corner_rad;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
		   as$status ();
                /* added by alwin for Raceway Multi Tier enhancement */
                //if( me->Product == VR_RWAY )
                {
                   IGRint proc_mode, shape_code;

                   // delete the old attributes, before populating the new
                   //attributes in the collector
		   /* Now all the old tier attributes are deleted using the 
		   PPL and its not handled in the code. */
		   /* Commenting this function call, as this doesn't help us
		   in any way, instead leading errors and confusion. Alwin 
                   * status = VRDelOldTierAttrs( me->CompId, &me->ModuleInfo );
		   ****/

                   FIg_get_text ( form_ptr, HSHAPE, szText);
                   status = VRGetShapeCode( szText, &shape_code );

                   /* Call this function with the option proc_mode = 2 to
                   transfer the information from the instance to the Collector*/
/**** Moved the filter  to here ***/
                if( me->Product == VR_RWAY )
                   {
                   proc_mode = 2;
            __DBGpr_com( " Calling2 the Fn VRRw_dimen_fields ... " );
                   status = VRRw_dimen_fields( NULL, NULL, NULL,
                                &me->ModuleInfo, me->CmpNbCpts, NULL,
                                proc_mode, shape_code,
                                me->RwCptData, &me->SysParamId );
                   }
                }
                /* added by alwin for Raceway Multi Tier enhancement */

#ifdef OLDER_DESIGN
		/* CR179801144 Compute depth for tier processing */
		FIg_get_text ( form_ptr, HSHAPE, szText);
		if(!strncmp(szText,"Rectangular",11))
		{
		   IGRint       row = 0, col = 0, sel_flag = 0;
		   FIg_get_value ( form_ptr, RN_TIER_CM1, &no_tier);
		   FIg_get_value ( form_ptr, RSP_TIER_CM1, &sp_tier);

                   status = VRcomp_rw_tier_depth(&me->ModuleEnv, my_grid,
                                 no_tier, sp_tier, &depth_val );

		   FIfld_set_value(form_ptr, RDEPTH_G, row, col,
					depth_val,sel_flag);
		   strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = depth_val;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
		   as$status ();
		   FIg_get_value ( form_ptr, RN_TIER_CM2, &no_tier);
		   FIg_get_value ( form_ptr, RSP_TIER_CM2, &sp_tier);

                   status = VRcomp_rw_tier_depth(&me->ModuleEnv, my_grid,
                                 no_tier, sp_tier, &depth_val );

		   strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = depth_val;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
		   as$status ();
		   FIfld_set_value(form_ptr, RDEPTH_R, row, col,
					depth_val,sel_flag);
		}
#endif

		_put_response( resp = EX_FORM_FINISHED );

		if( !me->ReplaceCommand )
		{
	    		FIf_is_displayed (me->FormUser, &VStatus);
	    		if (VStatus)
			{
				if (me->FormUser)  FIf_erase (me->FormUser);
				FIg_set_state_off( me->FormPtr, PLOAD_USER );
			}
		}
		FIg_set_state_off (form_ptr, FI_ACCEPT);
	}
	break;

	case FI_EXECUTE :
		FIg_get_text ( form_ptr, RCODE, err_msg );
		if( err_msg[0] == '\0' )
		{
	  		strcpy( err_msg, "ERROR : Component Code is not defined" );
	  		FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
	  		FIg_set_state_off (form_ptr, FI_EXECUTE);
	  		break;
		} 
		_put_response( resp = EX_FORM_FINISHED );
		FIg_set_state_off (form_ptr, FI_EXECUTE);
		/* CR179801144 Compute depth for tier processing */
		FIg_get_text ( form_ptr, HSHAPE, szText);

                /* added by alwin for Raceway Multi Tier enhancement */
/**** Someone took the RWAY filter off this block of code ***/
//                if( me->Product == VR_RWAY )
                {
                   IGRint proc_mode;
                   IGRint shape_code;

                   // delete the old attributes, before populating the new
                   //attributes in the collector
/**** Deleting this call
                   status = VRDelOldTierAttrs( me->CompId, &me->ModuleInfo );
****/

                   FIg_get_text ( form_ptr, HSHAPE, szText);
                   status = VRGetShapeCode( szText, &shape_code );

                   /* Call this function with the option proc_mode = 2 to
                   transfer the information from the instance to the Collector*/
/**** Moved the filter to here ***/
                if( me->Product == VR_RWAY )
                   {
                   proc_mode = 2;
            __DBGpr_com( " Calling3 the Fn VRRw_dimen_fields ... " );
                   status = VRRw_dimen_fields( NULL, NULL, NULL,
                                &me->ModuleInfo, me->CmpNbCpts, NULL,
                                proc_mode, shape_code,
                                me->RwCptData, &me->SysParamId );
                   }
                }
/*** quick fix for tr179900932 ***/
		   FIg_get_value ( form_ptr, RCORNRAD, &corner_rad);

		   strcpy ( Collection.name , VR_N_CORN_RAD_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = corner_rad;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
		   as$status ();

#ifdef OLDER_DESIGN
		if(!strncmp(szText,"Rectangular",11))
		{
		   IGRint       row = 0, col = 0, sel_flag = 0;
		   FIg_get_value ( form_ptr, RN_TIER_CM1, &no_tier);
		   FIg_get_value ( form_ptr, RSP_TIER_CM1, &sp_tier);

                   status = VRcomp_rw_tier_depth(&me->ModuleEnv, my_grid,
                                 no_tier, sp_tier, &depth_val );

		   strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = depth_val;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
		   as$status ();
		   FIfld_set_value(form_ptr, RDEPTH_G, row, col,
					depth_val,sel_flag);

		   FIg_get_value ( form_ptr, RN_TIER_CM2, &no_tier);
		   FIg_get_value ( form_ptr, RSP_TIER_CM2, &sp_tier);

                   status = VRcomp_rw_tier_depth(&me->ModuleEnv, my_grid,
                                 no_tier, sp_tier, &depth_val );

		   strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
		   Collection.desc.type = AC_ATTRIB_DOUBLE;
		   Collection.desc.value.att_exp = depth_val;
		   status = VRUpdateParameterBox( &msg, &Collection, 
                                                  &me->SysParamId);
		   FIfld_set_value(form_ptr, RDEPTH_R, row, col,
					depth_val,sel_flag);
		   as$status ();
		}
#endif
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

	case HEQUI_DIA:
		strcpy ( Collection.name , VR_N_EQUIV_DIA_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();
	break;

	case HSHAPE:
	{
		/* below modified for CR179801144 */
		IGRdouble depth_val;
		struct ret_struct		ParamAttr;
		IGRint 				FootIndex = -1, retstatus;

                //erase the Multi Tier Gadget group. We need to display this
                //only for Rectangular shape. Alwin
                FIg_erase( me->FormPtr, 29 );

		strcpy ( Collection.name , VR_N_SHAPE_IN ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		FIg_get_text ( form_ptr, gadget_label, szText);
		VRGetShapeCode ( szText, &Value );
		Collection.desc.value.att_exp = (IGRdouble) Value;
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();

		if (VRCircularTreatment (me->Product, &me->SysParamId, &me->ModuleEnv))
		{
  			VR$DispCollAttr ( pForm 	= me->FormPtr,
		    	  		  pCollId	= &me->SysParamId,
		    	  		  Gadget	= FRM_DEPTH_1,
		    	  		  pAttrName 	= VR_N_DEPTH1_DB);

  			VR$DispCollAttr ( pForm 	= me->FormPtr,
		    	  		  pCollId	= &me->SysParamId,
		    	  		  Gadget	= FRM_DEPTH_2,
		    	  		  pAttrName 	= VR_N_DEPTH2_DB);

			FIfld_set_mode( me->FormPtr, FRM_DEPTH_1, 0, FI_REVIEW);
			FIfld_set_mode( me->FormPtr, FRM_DEPTH_2, 0, FI_REVIEW);
			FIg_display( me->FormPtr, FRM_DEPTH_1);
			FIg_display( me->FormPtr, FRM_DEPTH_2);

			strcpy ( Collection.name , VR_N_NUMTIER1_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			Collection.desc.value.att_exp = (IGRdouble) 1.;
			status = VRUpdateParameterBox( &msg, &Collection,
					 &me->SysParamId);
			as$status ();
			strcpy ( Collection.name , VR_N_NUMTIER2_IN ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			Collection.desc.value.att_exp = (IGRdouble) 1.;
			status = VRUpdateParameterBox( &msg, &Collection,
					 &me->SysParamId);
			as$status ();
		}
		else if (!strcmp(szText,"Rectangular"))
		{
                    IGRint NbCpts, active_cpt, proc_mode;

		    __DBGpr_com( " entered the Rectangular treatment " );
                    NbCpts = 2;
                    if( me->CmpNbCpts > 2 )
                       NbCpts = me->CmpNbCpts;

                    __DBGpr_com( " Calling the Fn VRRw_dimen_fields ... " );
                    proc_mode = 0; // zero for Initialization
            __DBGpr_com( " Calling4 the Fn VRRw_dimen_fields ... " );
                    status =
                    VRRw_dimen_fields( NULL, NULL, NULL, &me->ModuleInfo,
                                            NbCpts, NULL, proc_mode, VR_RECT,
                                            me->RwCptData, &me->SysParamId );

                    proc_mode = 1; // one for Displaying the Instance data
                    active_cpt = 2;
            __DBGpr_com( " Calling5 the Fn VRRw_dimen_fields ... " );
                    status = VRRw_dimen_fields( me->FormPtr, NULL, NULL,
                                            &me->ModuleInfo, NbCpts,
                                            &active_cpt, proc_mode, VR_RECT,
                                            me->RwCptData, &me->SysParamId );

                    //Display the Multi Tier Gadget group
                    FIg_display( me->FormPtr, 29 );
		}
                else if( !strncmp( szText, "Rect-", 5 ) )
                {
                    __DBGpr_com( " Rectangular-??? treatment " );
                    FIg_display( me->FormPtr, FRM_TIER_SP_1 );
                    FIg_display( me->FormPtr, FRM_NO_TIER_1 );
                }
                else if(!strncmp(szText,"Corner R",8))
                {
                    status =
                    om$send( msg      = message ACncpx.ACgive_structure(
                                            &retstatus, &FootIndex,
                                            VR_N_CORN_RAD_DB,  &ParamAttr,
                                            &me->ModuleEnv),
                             targetid = me->SysParamId.objid,
                             targetos = me->SysParamId.osnum );

                    FIg_set_value( me->FormPtr, RCORNRAD,
                                        ParamAttr.var.root_pm_st.value );
                    FIg_display(me->FormPtr, RCORNRAD);
                    FIg_display(me->FormPtr, RCORNRAD_LBL);
                }
	}
	break;

	case HTRANS_L:
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

			ParamList[0] = me->UsrParamId;
			if( me->MissParamId.objid != NULL_OBJID )
			{
				ParamList[1] = me->MissParamId;
				NbParamInList = 2;
			}
			else NbParamInList = 1;

			VRUpgradeUserForm( me->FormUser, NbParamInList, ParamList, USER_ATTR_FLD );
		}
	break;

	default :
	break;
    }
}
else
{
    switch ( gadget_label )
    {
	case FI_CANCEL: 
		FIg_set_state_off( me->FormPtr, HLOAD_USER );
		FIg_set_state_off( me->FormUser, FI_CANCEL );
		FIf_erase( form_ptr );
	break;

	case FI_EXECUTE:
		status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, &me->UsrParamId, &me->MissParamId );
		as$status();
		/*printf("deleted finished-execute\n"); CR179603118 */
/*		_put_response( resp = EX_FORM_FINISHED); */
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
		/* printf("deleted finished-accept\n"); CR179603118 */
/*		_put_response( resp = EX_FORM_FINISHED); */
	break;
   }
}

quit :

End
return	OM_S_SUCCESS;

} /* end method form_notification */

/* ***************** VRFillForm () ***********************************	*/

method VRFillForm ( IGRlong *ret; struct GRid *CompId;
		    struct GRid *SysParamId; struct GRmd_env *MdEnv )
{
IGRlong				status;
IGRchar				szCode [15];
struct ret_struct		ParamAttr;
IGRint 				FootIndex = -1, retstatus, Shape;

  SetProc( Md VRFillForm ); Begin 

  *ret	= MSSUCC;

  if (!me->FormPtr || SysParamId->objid == NULL_OBJID )
  {
      End
      return OM_S_SUCCESS;
  }

  //changed the gadget labels for the following four gadgets. Alwin
  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= FRM_WIDTH_1,
		    pAttrName 	= VR_N_WIDTH1_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= FRM_DEPTH_1,
		    pAttrName 	= VR_N_DEPTH1_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= FRM_WIDTH_2,
		    pAttrName 	= VR_N_WIDTH2_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= FRM_DEPTH_2,
		    pAttrName 	= VR_N_DEPTH2_DB);

  status = om$send( msg = message ACncpx.ACgive_structure( &retstatus, 
				&FootIndex, VR_N_SHAPE_IN, 
				&ParamAttr, MdEnv ),
	   targetid = SysParamId->objid,
	   targetos = SysParamId->osnum );
  Shape 	= (IGRint) ParamAttr.var.root_pm_st.value;
  VRGetShapeString ( Shape, szCode );
  FIg_set_text( me->FormPtr, RSHAPE, szCode);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= RCONST_STS,
		    pAttrName 	= VR_N_APPRV_STAT_AN);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= REQUI_DIA,
		    pAttrName 	= VR_N_EQUIV_DIA_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= RTRANS_L,
		    pAttrName 	= VR_N_TRANS_L_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= RAIR_FLOW,
		    pAttrName 	= VR_N_FLOW_RATE_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= RTHROAT_RAD,
		    pAttrName 	= VR_N_THROAT_DB);
/*** Quick fix for tr179900932 ***/
  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= RCORNRAD,
		    pAttrName 	= VR_N_CORN_RAD_DB);

  FIg_set_text( me->FormPtr, RCODE, 	me->CmpAABBCCcode);

  FIg_set_text( me->FormPtr, RNOTES, 	me->CmpNotes);

  FIg_set_text( me->FormPtr, RCMP_NB, 	me->CmpNumber);

  if( me->CmpNoMtoFlag  == '1' )
	FIg_set_state ( me->FormPtr, RMTOFLAG, TRUE);
  else
	FIg_set_state ( me->FormPtr, RMTOFLAG, FALSE);

  //added by alwin for Raceway Multi Tier enhancements
  {
      IGRint active_cpt=2, proc_mode;

      /* This mayn't be a valid assumption logically. Mainly this could be
      b'cas user would've located a 'dangle' to change it to any other component
      so it's better from our side to display both sides with same attributes*/
      if( me->CmpNbCpts == 0 ) me->CmpNbCpts = 2;

      __DBGpr_com( " Calling6 the Fn VRRw_dimen_fields to Initialize... " );
      proc_mode = 0; // zero for Initialization
      status = VRRw_dimen_fields( NULL, NULL, NULL, &me->ModuleInfo,
                                  me->CmpNbCpts, NULL, proc_mode, Shape,
                                  me->RwCptData, &me->SysParamId );

      proc_mode = 1; // one for Displaying the Instance data
      active_cpt = 2;
      __DBGpr_com( " Calling7 the Fn VRRw_dimen_fields to Initialize... " );
      status = VRRw_dimen_fields( me->FormPtr, NULL, NULL,
                                  &me->ModuleInfo,
                                  me->CmpNbCpts, &active_cpt,
                                  proc_mode, Shape,
                                  me->RwCptData, &me->SysParamId );
         /* Change related to TR179900976- regression for replacement     */
         /* Kludge to correct form display dutring replace of shape trans */
         FIg_set_value( me->FormPtr, FRM_WIDTH_1, me->RwCptData[0].width);
         FIg_set_value( me->FormPtr, FRM_DEPTH_1, me->RwCptData[0].depth);

      /* to handle the shape transition components which has Rectangular
      end at the first connect point */
      if( ( Shape ==  VR_RECT_OVAL ) || ( Shape ==  VR_RECT_CIRC ) ||
          ( Shape ==  VR_RECT_CORN ) || ( Shape ==  VR_RECT_ELLP ) )
      {
         IGRint j;

         __DBGpr_int( " Nb. of Tiers ", me->RwCptData[0].nb_tier );

         FIfld_set_num_rows( me->FormPtr, FRM_TIER_SP_1,
                                me->RwCptData[0].nb_tier );
         FIg_set_value( me->FormPtr, FRM_NO_TIER_1, me->RwCptData[0].nb_tier);

         for( j=0; j<me->RwCptData[0].nb_tier; j++ )
         {
           IGRint  sel_flag;
           IGRchar index_str[20];

           sprintf( index_str, "%d", j+1 );
           __DBGpr_str( " Index string ", index_str );
           FIfld_set_text( me->FormPtr, FRM_TIER_SP_1, j, 0,index_str,sel_flag);

           sprintf( index_str, "%f", me->RwCptData[0].tier_sp[j] );
           __DBGpr_str( " Spacing string ", index_str );
           FIfld_set_text( me->FormPtr, FRM_TIER_SP_1, j, 1,index_str,sel_flag);
         }
      }

      switch( Shape )
      {
        case VR_RECT :
           /* display the Multi Tier gadget group */
           FIg_display( me->FormPtr, 29 );

           FIfld_set_mode( me->FormPtr, FRM_DEPTH_1, 0, FI_REVIEW);
           FIfld_set_mode( me->FormPtr, FRM_DEPTH_2, 0, FI_REVIEW);
           FIg_display( me->FormPtr, FRM_DEPTH_1 );
           FIg_display( me->FormPtr, FRM_DEPTH_2 );
        break;

        case VR_RECT_OVAL:
        case VR_RECT_CIRC:
        case VR_RECT_CORN:
        case VR_RECT_ELLP:
          /* erase the Multi Tier group and later display the needed gadgets */
          FIg_erase( me->FormPtr, 29 );

          FIg_display( me->FormPtr, FRM_NO_TIER_1 );
          FIg_display( me->FormPtr, FRM_TIER_SP_1 );
          FIg_display( me->FormPtr, RN_TIER_CMTEXT);
          FIg_display( me->FormPtr, RSP_TIER_CMTEXT);

	  FIfld_set_mode( me->FormPtr, FRM_DEPTH_1, 0, FI_REVIEW);
	  FIg_display( me->FormPtr, FRM_DEPTH_1 );
          if( Shape == VR_RECT_CIRC )
          {
           FIfld_set_mode( me->FormPtr, FRM_DEPTH_2, 0, FI_REVIEW);
           FIg_display( me->FormPtr, FRM_DEPTH_2 );
          }
        break;

        default:
          FIg_erase( me->FormPtr, 29 );

          if( Shape == VR_CIRC )
          {
           FIfld_set_mode( me->FormPtr, FRM_DEPTH_1, 0, FI_REVIEW);
           FIfld_set_mode( me->FormPtr, FRM_DEPTH_2, 0, FI_REVIEW);
           FIg_display( me->FormPtr, FRM_DEPTH_1 );
           FIg_display( me->FormPtr, FRM_DEPTH_2 );
          }

          if( Shape == VR_CORNER )
          {
             FIg_display(me->FormPtr, RCORNRAD);
             FIg_display(me->FormPtr, RCORNRAD_LBL);
          }
        break;
      }
  }

End
return	OM_S_SUCCESS;

} /* end method VRFillForm */

/* ==================================================================== */

method VRDisplayMessage  (IGRlong *ret)
{

*ret = MSSUCC;

switch (me->mytype)
{
	case VR_RWAYREDUCER_INSERTION:
    		ex$message( field   = MESSAGE_FIELD,
			    msgnumb = VRC_M_InsertRwayReducer);
    	break;
	case VR_RWAYMISC_INSERTION:
    		ex$message( field   = MESSAGE_FIELD,
			    msgnumb = VRC_M_InsertRwayMisc);
    	break;
	case VR_RWAYOFFSET_INSERTION:
    		ex$message( field   = MESSAGE_FIELD,
			    msgnumb = VRC_M_InsertRwayOffset);
    	break;
	case VR_RWAYSPLIT_INSERTION:
    		ex$message( field   = MESSAGE_FIELD,
			    msgnumb = VRC_M_InsertRwaySplit);
    	break;
	default:
    		ex$message( field   = MESSAGE_FIELD,
			    in_buff = "Unknown Message");
    }

return OM_S_SUCCESS;

} /* end method VRDisplayMessage */

end implementation VRCORway;
