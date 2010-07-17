/* $Id: VRCOPipingi.I,v 1.5 2002/05/30 20:00:07 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRCOPipingi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCOPipingi.I,v $
 *	Revision 1.5  2002/05/30 20:00:07  louis
 *	Modified the livelookup switch to avoid a database query
 *	
 *	Revision 1.4  2001/04/17 23:03:26  anand
 *	JTS TR MP 4485
 *	
 *	Revision 1.3  2001/02/20 01:12:13  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 22:46:14  anand
 *	SP merge
 *	
# Revision 1.3  2000/11/28  21:34:40  pinnacle
# Replaced: route/vrco/VRCOPipingi.I for:  by lawaddel for Service Pack
#
# Revision 1.2  2000/11/22  21:24:28  pinnacle
# Replaced: route/vrco/VRCOPipingi.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/07/14  18:02:48  pinnacle
# Created: route/vrco/VRCOPipingi.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1997/12/08  14:23:48  pinnacle
# Replaced: vrco/VRCOPipingi.I for:  by apazhani for route
#
# Revision 1.2  1997/12/01  21:31:48  pinnacle
# Replaced: vrco/VRCOPipingi.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/08/20  08:39:20  pinnacle
# Replaced: vrco/VRCOPipingi.I for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/05/17  22:00:10  pinnacle
# Replaced: vrco/VRCOPipingi.I for:  by hverstee for route240
#
# Revision 1.4  1996/04/25  23:04:48  pinnacle
# Replaced: vrco/VRCOPipingi.I for:  by ashankar for route240
#
# Revision 1.3  1996/01/16  21:27:06  pinnacle
# Replaced: vrco/VRCOPipingi.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	12/08/97        Alwin   Modified VRFillForm to disable some gadgets
 *                              when a correction component is selected for
 *                              modification. CR179421374
 *	Nov 22 2k	Anand	CR 179902073
 *      11/28/00        law     TR MP4140 crashing with optcode selects
 *
 *************************************************************************/

class implementation VRCOPiping;

#include <stdio.h>
#include <stdlib.h>
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbStruct.h"
#include "VRcmd.h"
#include "VRMcForm.h"
#include "VRPid.h"
#include "acrepdef.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "VDSutil.h"
#include "vrco_pto.h"
/* Added fo CR179308634 - Livelookup of parts in db */
#include "vdbmacros.h"
#include "exmacros.h"
#include "VRact_params.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"

/* Below lines added by Anand for CR 179902073 */
#include "vrdbgmacros.h"
#include "VRdbcodlst.h"
/* Above lines added by Anand for CR 179902073 */
#include "VRPDBmac.h"
#include "VRPDBdef.h"
/* Above lines added by law for detecting live lookup without db query */

%safe
#include "VX_FIproto.h"
#include <math.h>
%endsafe

#define VR_OPTCODE_LIST_NUM  400
#define	AS_DEBUG
#define VR_MANAGE_TAG	2

from    VRGeneric       import  VRGetStatus;
from	ACncpx		import	ACgive_structure;
from	ACrg_collect	import	ACget_named_attribute;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				method status_disp ( momo 26-03-1992 )

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method status_disp()
{

/* CR179308634  ****** LIVELOOKUP Variables *******/
#define LLP_FLG 299
char    **results;
char    query[200];
int     rows;
IGRint  gadget_label;
IGRlong	status;

extern int COB_FI_form_notification();

/* CR179308634  ****** ADD LIVELOOKUP *******/
/*** 05/30/02 - law - redesigned on-switch to avoid Db query ***/
if(me->ReplaceCommand && !bVR_IS_PID_ACTIVE)
{
IGRlong msg;
IGRint notlvlkup;
IGRshort spec_nbr,row_no,NumComp;
struct ACrg_coll    Attr;
struct VRPDB_comps    *CompPtr=NULL;

        me->proc_livelook = FALSE;

        /***** Get the active spec_no *****/
        strcpy(Attr.name, VR_N_CLASS_AN);
        status = om$send(msg = message ACrg_collect.ACget_named_attribute
                                                               ( &msg, &Attr ),
                        senderid = NULL_OBJID,
                        targetid = me->SysParamId.objid,
                        targetos = me->SysParamId.osnum );
        as$status( action = RET_STATUS );
        __DBGpr_str(" Spec nam",Attr.desc.value.att_txt);

        status = VR$PDB_SNUM( p_nam = Attr.desc.value.att_txt,
                                  p_num = &spec_nbr );
        as$status( action = RET_STATUS );
        __DBGpr_int("spec_num from spec_name ",spec_nbr);

        /***** Set the cache for spec no and get the piping comps ****/
        VR$PDB_SET ( p_msg = &msg ,
                                 spec  = spec_nbr);
        status=VR$PDA_COMP(p_num = &NumComp, p_ptr = &CompPtr);
        /**** Loop through comps to find non-zero fam-code ****/
        notlvlkup = 1;
        for( row_no=0 ; row_no<NumComp && notlvlkup ; row_no++ )
        {
           if(CompPtr[row_no].data.famcode)
           {
             notlvlkup = 0;
           }
        }
        if(!notlvlkup)
        {
           me->proc_livelook = TRUE;
           if(me->new_live)
           {
              FIf_new ( 999, "VRPlvlkfrm", COB_FI_form_notification,
                                           &me->status_display_form_ptr);
              FIf_set_cmd_oid_os(
                    me->status_display_form_ptr, my_id, OM_Gw_current_OS );
              me->new_live = FALSE;
           }
           if(me->first_entry)
           {
              status = VRPlvlkup(me->first_entry,&gadget_label,
                                      me->status_display_form_ptr,&me->OB);
              me->first_entry = FALSE;

           }
           /******* Kill all buttons on main form *********/
           FIg_disable(me->FormPtr,PCODE);
           FIg_disable(me->FormPtr,PPMC);
           FIg_disable(me->FormPtr,PPID);
           FIg_disable(me->FormPtr,PHEAT_TRAC);
           FIg_disable(me->FormPtr,PCONST_STS);
           FIg_disable(me->FormPtr,PCMP_NB);
           FIg_disable(me->FormPtr,PNOTES);
           FIg_disable(me->FormPtr,PMTOFLAG);
           FIg_disable(me->FormPtr,PDIA_NOM);
           FIg_disable(me->FormPtr,PDIA_RED);
           FIg_disable(me->FormPtr,POPTION);
           FIg_disable(me->FormPtr,FI_RESET);
           FIg_disable(me->FormPtr,FI_EXECUTE);
           FIg_disable(me->FormPtr,FI_ACCEPT);
           FIg_disable(me->FormPtr,FI_CANCEL);
           FIg_disable(me->FormPtr,PLOAD_USER);
           FIg_disable(me->FormPtr,PLOAD_FROM);

        }

}
  /*| call status_disp method with respect to message */
  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message super_cmd.status_disp(),
                    targetid = my_id);
  as$status( action = RET_STATUS );

  if( me->ReplaceCommand && !me->proc_livelook) /* mod - CR179308634 */
  {
  	FIg_erase  ( me->status_display_form_ptr, 19 );
  	FIg_erase  ( me->status_display_form_ptr, 28 );
  	FIg_display( me->status_display_form_ptr, 24 );
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
IGRshort		ret_flag;
IGRdouble		RValue, GValue;
IGRchar			err_msg[100];
struct	ACrg_coll	Collection;
/* Added for CR179308634 - Livelookup of parts in db */
IGRlong retcode;
char text_string[80];
int NbAttr;
struct  ACrg_coll  NewListAttr[10];

status = OM_S_SUCCESS;

  if (!form_ptr)	return OM_S_SUCCESS;
  strcpy( err_msg, "" );
  status = FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
    
  if( form_ptr == me->status_display_form_ptr && me->ReplaceCommand )
  {
     /* CR179308634 - Livelookup of parts in database */
     if(me->proc_livelook)
     {
        if( gadget_label == FI_CANCEL )
        {
           FIg_set_state_off( me->status_display_form_ptr, FI_CANCEL );
           me->proc_livelook = FALSE;

           FIf_erase(me->status_display_form_ptr );

           FIf_display(me->FormPtr);

           status = VRPlvlkup(1,&gadget_label,
                                      me->status_display_form_ptr,&me->OB);

           me->form_requested = 0;
           FIg_enable(me->FormPtr,PCODE);
           FIg_enable(me->FormPtr,PPMC);
           FIg_enable(me->FormPtr,PPID);
           FIg_enable(me->FormPtr,PHEAT_TRAC);
           FIg_enable(me->FormPtr,PCONST_STS);
           FIg_enable(me->FormPtr,PCMP_NB);
           FIg_enable(me->FormPtr,PNOTES);
           FIg_enable(me->FormPtr,PMTOFLAG);
           FIg_enable(me->FormPtr,PDIA_NOM);
           FIg_enable(me->FormPtr,PDIA_RED);
           FIg_enable(me->FormPtr,POPTION);
           FIg_enable(me->FormPtr,FI_RESET);
           FIg_enable(me->FormPtr,FI_EXECUTE);
           FIg_enable(me->FormPtr,FI_ACCEPT);
           FIg_enable(me->FormPtr,FI_CANCEL);
           FIg_enable(me->FormPtr,PLOAD_USER);
           FIg_enable(me->FormPtr,PLOAD_FROM);
           _put_response( resp = EX_BACK_UP );
           return OM_S_SUCCESS;
        }
        else if(gadget_label == FI_ACCEPT)
        {
           FIg_set_state_off( me->status_display_form_ptr, FI_ACCEPT );
           me->proc_livelook = FALSE;

           VR$active_params( operation       = VR_RETRIEVE,
                             VRproduct          = me->Product,
                             act_param_id       = &me->SysParamId,
                             status       = status );

           me->bTagNumUsed = TRUE;

           strcpy(me->CmpAABBCCcode,me->OB.loc_cmp_code);
           FIg_set_text( me->FormPtr, PCODE,me->OB.loc_cmp_code);

           me->CmpOption = (int)atoi(me->OB.opt_code_num);
           FIg_set_text( me->FormPtr, POPTION,me->OB.opt_code_des);

           strcpy( me->CmpNumber,me->OB.comp_num_fld);
           FIg_set_text( me->FormPtr, PCMP_NB,me->OB.comp_num_fld);

           NbAttr = 0;

           /* -- Set Green Diameter -- */
           /* Get PP_DIAM */
           strcpy( NewListAttr[NbAttr].name, VR_N_GDIAMETER_DB );
                   NewListAttr[NbAttr].desc.type          = AC_ATTRIB_DOUBLE;
                   NewListAttr[NbAttr].desc.value.att_exp = me->OB.default_Gdia;
           status = VRUpdateParameterBox( &msg, &NewListAttr[NbAttr], &me->SysParamId);
           sprintf(text_string,"%lf",me->OB.default_Gdia);
           FIg_set_text( me->FormPtr, PDIA_NOM,text_string);
           NbAttr ++;


           /* -- Set Red Diameter -- */
           strcpy( NewListAttr[NbAttr].name, VR_N_RDIAMETER_DB );
                   NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
                   NewListAttr[NbAttr].desc.value.att_exp= me->OB.default_Rdia ;
           status = VRUpdateParameterBox( &msg, &NewListAttr[NbAttr], &me->SysParamId);
           sprintf(text_string,"%lf",me->OB.default_Rdia);
           FIg_set_text( me->FormPtr, PDIA_RED,text_string);
           NbAttr ++;

           strcpy( NewListAttr[NbAttr].name, VR_N_CLASS_AN);
                   NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
           strcpy( NewListAttr[NbAttr].desc.value.att_txt,me->OB.spec_nam_txt);
           status = VRUpdateParameterBox( &msg, &NewListAttr[NbAttr], &me->SysParamId);
           FIg_set_text( me->FormPtr, PPMC,me->OB.spec_nam_txt);
           NbAttr ++;

           as$status ();
           /* Took out option code processing here */

           /* -- get the code corresponding the text -- */
           status = 
             VR$ModifyCollection(   p_msg                   = &retcode,
                                    Operation               = VR_UPDATE_COLL,
                                    p_ParamsListToModify    = NewListAttr,
                                    NbParamsToModify        = NbAttr,
                                    p_OutputCollectionId    = &me->SysParamId );
           as$status();
           as$status( sts = retcode );

           FIf_erase(me->status_display_form_ptr );
           status = VRPlvlkup(1,&gadget_label,
                                      me->status_display_form_ptr,&me->OB);
           me->form_requested = 0;
/*           FIf_display( me->FormPtr ); */
           FIg_enable(me->FormPtr,PCODE);
           FIg_enable(me->FormPtr,PPMC);
           FIg_enable(me->FormPtr,PPID);
           FIg_enable(me->FormPtr,PHEAT_TRAC);
           FIg_enable(me->FormPtr,PCONST_STS);
           FIg_enable(me->FormPtr,PCMP_NB);
           FIg_enable(me->FormPtr,PNOTES);
           FIg_enable(me->FormPtr,PMTOFLAG);
           FIg_enable(me->FormPtr,PDIA_NOM);
           FIg_enable(me->FormPtr,PDIA_RED);
           FIg_enable(me->FormPtr,POPTION);
           FIg_enable(me->FormPtr,FI_RESET);
           FIg_enable(me->FormPtr,FI_EXECUTE);
           FIg_enable(me->FormPtr,FI_ACCEPT);
           FIg_enable(me->FormPtr,FI_CANCEL);
           FIg_enable(me->FormPtr,PLOAD_USER);
           FIg_enable(me->FormPtr,PLOAD_FROM);
          _put_response( resp = EX_FORM_FINISHED );

           me->ret = VRALL_OK;
           goto quit;
       }
       else /* form_ptr == me->status_display_form_ptr&&me->proc_livelook */
       {
           status = VRPlvlkup(me->first_entry,&gadget_label,form_ptr,&me->OB);
           return OM_S_SUCCESS;
       }
     }
     else /* !proc_livelook */
     {
	/*| status display */
  	switch( gadget_label )
    	{
		case FI_CANCEL:
        		FIf_erase( form_ptr );
			me->form_requested = 0;
		 	break;

		case P_REDUCER_BUTTON :
			strcpy( me->szActivePocketMenuName, PREDUCERPKTMNU );
			break;

		case VALVE_BUTTON :
			strcpy( me->szActivePocketMenuName, PVALVEPKTMNU );
		 	break;

		case ENDPIPE_BUTTON :
			strcpy( me->szActivePocketMenuName, PPIPEENDSPKTMNU );
		 	break;

		case P_ELBOW_BUTTON :
			strcpy( me->szActivePocketMenuName, PELBOWPKTMNU );
		 	break;

		case P_TEE_BUTTON :
			strcpy( me->szActivePocketMenuName, PTEEPKTMNU );
		 	break;

		case FLANGE_BUTTON :
			strcpy( me->szActivePocketMenuName, PFLANGEPKTMNU );
		 	break;

		case SPECIALITY:
			strcpy( me->szActivePocketMenuName, PSPECIALPKTMNU );
			break;

		case INSTRUMENT:
			strcpy( me->szActivePocketMenuName, PINSTRUPKTMNU );
			break;

		case CONNECTOR:
			strcpy( me->szActivePocketMenuName, PCONNECPKTMNU );
			break;
      	}
	if( gadget_label != FI_CANCEL )
	{
		VRChangePocketMenu (me->szActivePocketMenuName);
  		_put_response( resp = EX_POCKET );
	}
     }
  }
  else if (form_ptr == (Form) me->FormPtr)
  {
    switch ( gadget_label ) 
    {
	case PCODE :
		/*| Updating AABBCC code */
		FIg_get_text ( form_ptr, gadget_label, me->CmpAABBCCcode);
		/*"CmpAABBCCcode = <%s> \n", me->CmpAABBCCcode */
		if ( me->CmpAABBCCcode[0] )
		{
		   /*A update the comp num field accordingly */
		   status = 
			om$send ( msg	= message VRCOProduct.VRSetIdManData( 
					&msg ),
				        targetid = my_id);
			as$status ();

			VRGetOptionCode( &msg, me->CmpAABBCCcode, 
					 &me->SysParamId, POPTION, 
					 me->FormPtr, &me->ModuleEnv);
			if (!(msg & 0x01) )	me->CmpAABBCCcode[0] = 0;
		}
	break;

	case PPMC :
	    /* Below lines added by Anand for CR 179902073 */
	{
	    IGRshort		nSpec=0;
	    IGRint 		new_list_cnt=0, sel_index;
	    IGRint 		sel_flag=0, unique_flg=0;
	    IGRchar		*speclist;

	    FIg_get_text ( form_ptr, gadget_label, text_string );
	    __DBGpr_str( " User Key-in text ", text_string );

	    /*| -- Get Spec Name List */
	    status = VRget_spec_list ( &msg, VR_PIPING, &nSpec , 
							&speclist, NULL);
	    CheckRC( status, msg );
	    if( !status & 1 ) break;
	    __DBGpr_int( " No. of Specs from DB ", nSpec );

	    qsort( speclist, nSpec, VR_MAX_SPEC_NAME_LEN, strcmp );

	    /* Filter the DB ( Original ) Spec list as needed for the user */
	    sel_index = -1;
	    status = VDfrm_fld_set_sub_list( form_ptr,
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
		/* Unique match has been found out of User Keyed in string, so
		   we need to proceed further. */
		FIg_get_text ( form_ptr, gadget_label, 
						Collection.desc.value.att_txt);

		FIg_enable( form_ptr, FI_EXECUTE );
		FIg_enable( form_ptr, FI_ACCEPT );
		/*| Updating collection VR_N_CLASS_AN */
		strcpy ( Collection.name , VR_N_CLASS_AN ); 
		Collection.desc.type = AC_ATTRIB_TEXT;
		VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL,
					PPMC, PDIA_NOM, PDIA_RED, 1 );
		status = VRUpdateParameterBox ( &msg, &Collection,
						&me->SysParamId );
		as$status ();

		//added for ETL2780
		status = VRGetOptionCode( &msg, me->CmpAABBCCcode, 
					  &me->SysParamId, POPTION, 
					  me->FormPtr, &me->ModuleEnv);
		if( !(msg & 1) )
		    UI_status( "Option Code update failed" );

		break;
	    }
	    else if( sel_index < 0 ) 
	    {
		FIg_disable( form_ptr, FI_EXECUTE );
		FIg_disable( form_ptr, FI_ACCEPT );
		return status;
	    }
	    /* Above lines added by Anand for CR 179902073 */
	}

	case PPID :
		/*| -- Set Pid Scale Factor -- */
		FIg_get_value( form_ptr , PPID, &Collection.desc.value.att_exp);
		strcpy( Collection.name, VR_N_PID_SCALE_DB );
      		Collection.desc.type = AC_ATTRIB_DOUBLE;
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();



	case PHEAT_TRAC :
		/* Below lines added by Anand for CR 179902073 */
		FIg_get_text ( form_ptr, gadget_label, text_string );
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING,
						VR_P_TRACE_TYPE_LSTNUM,
						form_ptr, PHEAT_TRAC,
						(IGRuchar *)text_string );
		as$status( action = RET_STATUS );
		if( text_string[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    break;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",text_string);
		/* Above lines added by Anand for CR 179902073 */

		    /*| Updating collection heat_tracing */
		    strcpy( Collection.name , VR_N_TRACING_CODE_AN ); 
		    Collection.desc.type = AC_ATTRIB_TEXT;
		    strcpy( Collection.desc.value.att_txt, text_string );
		    status = VRUpdateParameterBox( &msg, &Collection,
						   &me->SysParamId );
		    as$status ();
		    break;
		}


	case PCONST_STS :	
		/* Below lines added by Anand for CR 179902073 */
		FIg_get_text ( form_ptr, gadget_label, text_string );
		status = VRkeyFltrInCDLdbFlds ( VR_PIPING,
						VR_P_CONST_STS_LSTNUM,
						form_ptr, PCONST_STS,
						(IGRuchar *)text_string );
		as$status( action = RET_STATUS );
		if( text_string[0] == '\0' )
		{
		    FIg_disable( form_ptr, FI_EXECUTE );
		    FIg_disable( form_ptr, FI_ACCEPT );
		    break;
		}
		else
		{
		    FIg_enable( form_ptr, FI_ACCEPT );
		    FIg_enable( form_ptr, FI_EXECUTE );
		    __DBGpr_str(" Text in field",text_string);
		/* Above lines added by Anand for CR 179902073 */

		    /*| Updating collection const_sts */
		    strcpy ( Collection.name , VR_N_CONSTR_STAT_AN ); 
		    Collection.desc.type = AC_ATTRIB_TEXT;
		    strcpy( Collection.desc.value.att_txt, text_string );
		    status = VRUpdateParameterBox( &msg, &Collection,
						   &me->SysParamId );
		    as$status ();
		    break;
		}

	case PCMP_NB :
		/*| Updating instance component_number */
		FIg_get_text ( form_ptr, gadget_label,me->CmpNumber);

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

	case PNOTES :
		/*| Updating instance szNotes */
		FIg_get_text ( form_ptr, gadget_label, me->CmpNotes);
	break;

	case PMTOFLAG :
		/*| Updating instance cNoMtoFlag */
		FIg_get_state ( form_ptr, gadget_label, &Value);
		if (Value)
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

	case PDIA_NOM :
		strcpy ( Collection.name , VR_N_GDIAMETER_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL,
			PPMC, PDIA_NOM, PDIA_RED, 1 );
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		FIg_get_value ( form_ptr, PDIA_RED, &RValue);

		/* -- Be sure that Green diameter is greater than Red -- */
		if( RValue > Collection.desc.value.att_exp )
		{	
			ex$message( field   = ERROR_FIELD,
                       	    	    in_buff = "Green diameter should be greater than red !" );
			FIg_set_value ( form_ptr, PDIA_RED, Collection.desc.value.att_exp);

			/* -- Update the Red Diameter in collection -- */
			strcpy ( Collection.name , VR_N_RDIAMETER_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();		
		}
		strcpy ( Collection.name, VR_N_GDIAMETER_DB );
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();

		//added for ETL2780
		status = VRGetOptionCode( &msg, me->CmpAABBCCcode, 
				&me->SysParamId, POPTION, 
				me->FormPtr, &me->ModuleEnv);
		if( !(msg & 1) ) UI_status( "Option Code update failed" );
	break;

	case PDIA_RED :
		/*| Updating collection VR_N_RDIAMETER_DB */
		strcpy ( Collection.name , VR_N_RDIAMETER_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr, NULL,
			PPMC, PDIA_NOM, PDIA_RED, 1 );
		FIg_get_value ( form_ptr, gadget_label, &Collection.desc.value.att_exp);
		FIg_get_value ( form_ptr, PDIA_NOM, &GValue);

		/* -- Be sure that Green diameter is greater than Red -- */		
		if( Collection.desc.value.att_exp > GValue )
		{	
			ex$message( field   = ERROR_FIELD,
                       	    	    in_buff = "Green diameter should be greater than red !" );
			FIg_set_value ( form_ptr, gadget_label , GValue);

			/* -- Update the Red Diameter in collection -- */
			strcpy ( Collection.name , VR_N_GDIAMETER_DB ); 
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			Collection.desc.value.att_exp = GValue; 
			status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
			as$status ();
		}
		strcpy ( Collection.name , VR_N_RDIAMETER_DB ); 
		status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
		as$status ();

		//added for ETL2780
		status = VRGetOptionCode( &msg, me->CmpAABBCCcode, 
				&me->SysParamId, POPTION, 
				me->FormPtr, &me->ModuleEnv);
		if( !(msg & 1) ) UI_status( "Option Code update failed" );
		break;

	case POPTION :
		/* -- get the opt_code corresponding to the option text -- */
	        {
                  /*** TR-MP4140 increase i_lname to 80 characters ***/
  		  IGRint	o_code;
  		  IGRchar	i_lname[81], p_error[30];

		  FIg_get_text ( form_ptr, gadget_label,i_lname);
  		  status = vd$get_alias (    p_msg	= &msg,
		    			 product	= PIPING,
		    			 type		= VR_OPTCODE_LIST_NUM,
		    			 i_lname	= i_lname,
		    			 o_code		= &o_code,
		    			 p_error	= p_error	);
	          if ( status != OM_S_SUCCESS )
		    me->CmpOption = (IGRshort)atoi(i_lname);
		  else
		    me->CmpOption = (IGRshort) o_code;

                  /* TR-MP4140 - update CmpAABBCCcode ***/
                  FIg_get_text ( form_ptr, PCODE, me->CmpAABBCCcode);
                  strcpy ( Collection.name , VR_N_CLASS_AN );
                  Collection.desc.type = AC_ATTRIB_TEXT;
                  FIg_get_text ( form_ptr, PPMC,
                                Collection.desc.value.att_txt);
                  status = VRUpdateParameterBox( &msg, &Collection,
                                &me->SysParamId);


		  if( me->CmpAABBCCcode[0] == '\0' )
			VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr,
				NULL, PPMC, PDIA_NOM, PDIA_RED, POPTION );
		  else
			VRCheckSpecVsDiamInPDB( &ret_flag, form_ptr,
				me->CmpAABBCCcode, PPMC, PDIA_NOM, PDIA_RED, POPTION );
		}
		break;

	case PLOAD_FROM :
		me->lRet = VRLOC_CMP;
		FIg_set_state_off (form_ptr, PLOAD_FROM);
		_put_response( resp = EX_FORM_FINISHED );
		break;

	case FI_RESET:
		/*| FI_RESET => Recover old instances */
	    	VRGetParamBoxClone( &msg, &me->SavSysParamId, &me->SysParamId);
	    	VRGetParamBoxClone( &msg, &me->SavUserParamId, &me->UsrParamId);

		if( me->SavMissParamId.objid != NULL_OBJID ) 
    			VRGetParamBoxClone( &msg, &me->SavMissParamId, &me->MissParamId);
 		else  	me->MissParamId.objid = NULL_OBJID;

    		status = 
		om$send ( msg      = message VRCOProduct.VRRestoreForm( &msg ),
		          targetid = my_id);
    		as$status ();
		FIg_set_state_off (form_ptr, FI_RESET);
		break;

	case FI_CANCEL:
		if( me->FormPtr && ! me->ReplaceCommand &&
			me->SysParamId.objid != NULL_OBJID )
	    	{
	    		status = FIf_erase (form_ptr);
	    		FIf_is_displayed (me->FormUser, &VStatus);
	    		if (VStatus)
				if (me->FormUser)  FIf_erase (me->FormUser);

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
	  	FIg_set_state_off (form_ptr, FI_ACCEPT);
		FIg_get_text ( form_ptr, PCODE, me->CmpAABBCCcode );
		if( me->CmpAABBCCcode[0] == '\0' )
		{
	  		strcpy( err_msg, "ERROR : Component Code is not defined" );
	  		FIg_set_text( form_ptr, FI_MSG_FIELD, err_msg );
	  		break;
		}
		if ( me->PrevTagNum != -1 ) me->bTagNumUsed = TRUE;

		_put_response( resp = EX_FORM_FINISHED);

		FIf_is_displayed (me->FormUser, &VStatus);
	    	if (VStatus)
		{
			FIf_erase (me->FormUser);
			FIg_set_state_off( me->FormPtr, PLOAD_USER );
		}
		break;

	case PLOAD_USER :
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
} /* end if me->FormPtr */
else
{
    /*| Dealing with UserParam form */
    switch ( gadget_label )
	{
  case FI_CANCEL: 
	/*| FI_CANCEL */
	FIg_set_state_off( me->FormPtr, PLOAD_USER );
	FIg_set_state_off( me->FormUser, FI_CANCEL );
	FIf_erase( form_ptr );
	break;

  case FI_EXECUTE:
	/*| FI_EXECUTE */
	status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, &me->UsrParamId, &me->MissParamId );
	as$status();

        if ( status == FI_SUCCESS )
          _put_response( resp = EX_FORM_FINISHED);

	/*^ VRprint_user_attr( &me->UsrParamId ); */

	FIg_set_state_off( me->FormUser, FI_EXECUTE );
	break;

case FI_RESET:
	/*| FI_RESET */
	FIg_set_state_off( me->FormUser, FI_RESET );
	break;

case FI_ACCEPT: 
	status = VRBuildUserFromForm( form_ptr, USER_ATTR_FLD, &me->UsrParamId, &me->MissParamId );
	as$status();
	/*| Erase the displayed form */
	status = FIf_erase( form_ptr );

	if ( status == FI_SUCCESS )
	{
	    	/*| Set button to off */
	    	FIg_set_state_off( me->FormPtr, PLOAD_USER );
	    	FIg_set_state_off( me->FormUser, FI_ACCEPT );
                _put_response( resp = EX_FORM_FINISHED );
	}
	else
	{
	    	/*| got bad return from erase_form */
	    	as$status( action = RET_STATUS );
	}

	break;
   } /* END switch ( gadget_label ) */

} /* end if */

quit :

return	OM_S_SUCCESS;

} /* end method form_notification */

/* ***************** VRFillForm () ***********************************	*/

method VRFillForm ( IGRlong *ret; struct GRid *CompId;
		    struct GRid *SysParamId; struct GRmd_env *MdEnv )
{

IGRlong			status;	

*ret	= MSSUCC;

  if (!me->FormPtr || SysParamId->objid == NULL_OBJID )
	return OM_S_SUCCESS;

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= PDIA_NOM,
		    pAttrName 	= VR_N_GDIAMETER_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= PDIA_RED,
		    pAttrName 	= VR_N_RDIAMETER_DB);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= PPMC,
		    pAttrName 	= VR_N_CLASS_AN);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= PHEAT_TRAC,
		    pAttrName 	= VR_N_TRACING_CODE_AN);

  VR$DispCollAttr ( pForm 	= me->FormPtr,
		    pCollId	= SysParamId,
		    Gadget	= PCONST_STS,
		    pAttrName 	= VR_N_APPRV_STAT_AN);

  if ( bVR_IS_PID( me->cRep ) )
  {
  	VR$DispCollAttr ( pForm 	= me->FormPtr,
		    	  pCollId	= SysParamId,
		    	  Gadget	= PPID,
		    	  pAttrName 	= VR_N_PID_SCALE_DB );		

		FIg_display( me->FormPtr, PPID );
		FIg_display( me->FormPtr, PPID_TXT );
  }
  else
  {
		FIg_erase( me->FormPtr, PPID );
		FIg_erase( me->FormPtr, PPID_TXT );
  }

  FIg_set_text( me->FormPtr, PCODE, 	me->CmpAABBCCcode );

  FIg_set_text( me->FormPtr, PNOTES, 	me->CmpNotes);

  FIg_set_text( me->FormPtr, PCMP_NB, 	me->CmpNumber );

  if( me->CmpNoMtoFlag == '1' )
	FIg_set_state ( me->FormPtr, PMTOFLAG, TRUE);
  else
	FIg_set_state ( me->FormPtr, PMTOFLAG, FALSE);

  /* -- display the text corresponding to the option code -- */
  {
	IGRlong	msg;
	IGRchar	sz80OptCode[81];
	IGRchar	p_error[30];

        /*** TR-MP4140 initialize o_lname to NULL for no-match ***/
        sz80OptCode[0] = '\0';
	status =
	vd$get_alias (  p_msg	= &msg,
			product	= PIPING,
			type	= VR_OPTCODE_LIST_NUM,
			i_code	= me->CmpOption,
			o_lname	= sz80OptCode,
			p_error	= p_error	);

	if ( !(status&1) || !strlen(sz80OptCode) ) 
		sprintf(sz80OptCode, "%d", me->CmpOption );   
	FIg_set_text( me->FormPtr, POPTION, sz80OptCode);
  }

  /* BEGIN - added by alwin for CR179421374 */
  /* Need to disable the some gadgets in case if user selects a correction
     component to modify. Since he's allowed to modify only the "option_code".
     So disable the other gadgets like "spec_name, comp_code, size_g, size_r"*/
 
  {
     IGRshort nStatus;
     IGRlong    msg;
 
     status = om$send ( msg = message VRGeneric.VRGetStatus( &msg, &nStatus ),
                                    targetid = me->CompId.objid,
                                    targetos = me->CompId.osnum );
 
     if( nStatus & VR_CORRECTION )
     {
       FIg_disable( me->FormPtr, PCODE );
       FIg_disable( me->FormPtr, PPMC );
       FIg_disable( me->FormPtr, PDIA_NOM );
       FIg_disable( me->FormPtr, PDIA_RED );
     }
     else
     {
       FIg_enable( me->FormPtr, PCODE );
       FIg_enable( me->FormPtr, PPMC );
       FIg_enable( me->FormPtr, PDIA_NOM );
       FIg_enable( me->FormPtr, PDIA_RED );
     }
  }
  /* End - added by alwin for CR179421374 */

return	OM_S_SUCCESS;

} /* end method VRFillForm */

/* ==================================================================== */

method VRDisplayMessage  (IGRlong *ret)
{

*ret = MSSUCC;

me->ActiveMessageField = 0;

switch (me->mytype)
    {
case VR_VALVE_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingValve;
    break;
case VR_FLANGE_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingFlange;
    break;
case VR_REDUCER_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingReducer;
    break;
case VR_MISC_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingMisc;
    break;
case VR_ECCRED_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingEccRed;
    break;
case VR_CONNECTOR_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingConnector;
    break;
case VR_INSTRUMENT_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingInstrument;
    break;
case VR_SPECIALTY_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipingSpecialty;
    break;
case VR_PIPEENDS_INSERTION:
    me->ActiveMessageField = VRC_M_InsertPipeEnds;
    break;
    } /* end switch */

if (me->ActiveMessageField != 0)
{
    	ex$message( field   = MESSAGE_FIELD,
		    msgnumb = me->ActiveMessageField);
}

return OM_S_SUCCESS;

} /* end method VRDisplayMessage */

end implementation VRCOPiping;
