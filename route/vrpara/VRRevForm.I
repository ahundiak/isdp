/* $Id: VRRevForm.I,v 1.2 2001/02/20 01:14:37 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara / VRRevForm.I
 *
 * Description:
	This file contains the form notification routines
		  for the "Review Attributes( VRRevAttr ) command.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRevForm.I,v $
 *	Revision 1.2  2001/02/20 01:14:37  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/04/30  09:07:00  pinnacle
# Replaced: vrpara/VRRevForm.I for:  by sbilla for route
#
# Revision 1.3  1999/04/20  12:09:32  pinnacle
# Replaced: vrpara/VRRevForm.I for:  by sbilla for route
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
# Revision 1.2  1996/01/17  14:47:34  pinnacle
# Replaced: vrpara/VRRevForm.I for:  by r240_int for route240
#
 *
 * History:
 *	08/11/93	Manyam	creation
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      04/19/99        Reddy   Added new cases for retrieving tier information
 *			for Raceways -- CR179900491
 *************************************************************************/
class implementation VRRevAttr;

#include	<stdio.h>
#include	"igrdef.h"
#include	"dpdef.h"
#include	"dpmacros.h"
#include	"vrparameters.h"
#include	"VRRevdef.h"
#include	"VRchgattrdef.h"
#include	"VRMcForm.h"
#include	"FI.h"
#include	"AS_status.h"
#include	"VRattr_def.h"
#include	"ACrg_collect.h"
#include	"VRDbTbl.h"
#include	"VRdimdef.h"
#include	"vdbmacros.h"
#include	"vrtools_pto.h"

#include	"VRRwDimen.h"
#include	"vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

from	VRGeneric	import	VRGetModel;
from	ACrg_collect	import	AClist_attribute,
				ACset_list_attribute,
				ACadd_list_attribute;

/*C		form_notification		*/

method form_notification( int form_label, gadget_label; 
				double value; char * form_ptr )
{
  	IGRlong		status = OM_S_SUCCESS, retmsg;

	SetProc( form_notification ); Begin 

	ex$message(in_buff = "",field=ERROR_FIELD);
	if ( form_ptr == NULL ) return( OM_E_INVARG );

  	if ( form_ptr == me->form_ptr[MAIN_FORM] )
  	{
		IGRint		TmpIndex;

		switch( gadget_label )
		{
    			case FI_ACCEPT:	
   			case FI_CANCEL:
				/*A erase the form	*/
				_put_response( resp = EX_FORM_FINISHED );
        			return OM_S_SUCCESS;

			case STAT_ATTR_BUTTON:
			case USR_ATTR_BUTTON:
				/*A display the subforms */
				FIg_set_notify_off( form_ptr, gadget_label );
				status = 
				om$send ( msg = message 
					VRRevAttr.VRSetParamForm( &retmsg,
					gadget_label ),
					targetid = my_id);
				if (!(status&1))
				{
					me->state = _terminate;
					return OM_I_STOP_SENDING;
				}

				/*C Display Proper Attr form */
				FIf_display( me->form_ptr[SUB_FORM] );
				break;

			case COND_ATTR_BUTTON: /* No action, in static.... */
				break;

			case NEXT:
			case PREVIOUS:
				/*A process the next or previous object 
				    and update the form accordingly	*/

				/*C change the cmp index in the instance */
				/* "me->CurCmpIndex = %d \n",
						me->CurCmpIndex*/
				
				TmpIndex = me->CurCmpIndex;

				/*C check for the validity */
				if ( gadget_label == NEXT ) 
				{
					/*C there is no next component	*/
					if ( me->CurCmpIndex+1 == 
							me->NumOfObjects )
						return OM_S_SUCCESS;
					me->CurCmpIndex++;

				} else {
					/* there is no previous cmp */
					if ( me->CurCmpIndex == 0 )
						return OM_S_SUCCESS;
					me->CurCmpIndex--;
				}

				/*C dehighlight the reviewed component	*/
				dp$display(msg = &retmsg, 
				oids = &me->LocatedObjects[TmpIndex].obj_id, 
				mode = GRhe );

				/*"me->CurCmpIndex = %d \n",
						me->CurCmpIndex*/
	
				/*C erase the sub form */
				if( me->form_ptr[SUB_FORM] != NULL ) 
					FIf_erase( me->form_ptr[SUB_FORM] );

				/*C get the data from the next object */
				status = 
				om$send ( msg = message 
					VRRevAttr.VRProcessNextObj( ),
					targetid = my_id);

				/*C setup the sys form */
				status = 
				om$send ( msg = message 
					VRRevAttr.VRUpdSysForm( ),
					targetid = my_id);
				
				break;
			
		    case INCREASE_ACTIVE_CPT_INDEX :
		    case DECREASE_ACTIVE_CPT_INDEX :

		    /********************   CR179900491- Begin  **************/

		      {	
			IGRchar 	cpt_index[10];
			IGRint  	actual_cpt,active_cpt;
			IGRchar 	active_cpt_index_fld[3];
			IGRint  	sel_flag , i , j;
			
		     __DBGpr_com( " case:  Increase/Decrease of index");

		       FIg_set_state_off( form_ptr, gadget_label);
		       FIg_get_text(form_ptr,ACTIVE_CPT_INDEX,cpt_index);
		       active_cpt = atoi(cpt_index);

		       if( gadget_label == INCREASE_ACTIVE_CPT_INDEX )
		       {
			   FIg_enable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
			   active_cpt++ ; 
		       }
		       else
		       {
			   FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
			   active_cpt-- ; 
		       }

		       FIg_erase(form_ptr , ACTIVE_CPT_INDEX);
		       sprintf( cpt_index, "%d", active_cpt );
		       FIg_set_text( form_ptr, ACTIVE_CPT_INDEX, cpt_index );
		       FIg_display( form_ptr, ACTIVE_CPT_INDEX );

		       if( ( active_cpt == me->NbCpts ) ||
			   ( active_cpt == 2 ) )
			  FIg_disable( form_ptr, gadget_label );
		    
		       actual_cpt = active_cpt - 1;

		       __DBGpr_int( " No. of connect points are ", me->NbCpts);

		       __DBGpr_int( " Active connect point index is" ,active_cpt);	

		       /** Fill up tier_spacing,  no. of tiers , width and depth **/

			__DBGpr_int( " Values for connect point", actual_cpt);	
			__DBGpr_int("Width", me->RwCptData[actual_cpt].width);
			__DBGpr_int("Depth", me->RwCptData[actual_cpt].depth);
			__DBGpr_int("No.of Tiers", me->RwCptData[actual_cpt].nb_tier);
			FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, me->RwCptData[actual_cpt].nb_tier);

			for(j=1; j<(me->RwCptData[actual_cpt].nb_tier+1); j++)
			{
			    IGRint row ;
			    row = j-1 ;
			    __DBGpr_dbl( " Tier spacing " , me->RwCptData[actual_cpt].tier_sp[row]);
			}


		       FIg_set_value(me->form_ptr[MAIN_FORM],FRM_NO_TIER_2,me->RwCptData[actual_cpt].nb_tier);
		       FIfld_set_value(me->form_ptr[MAIN_FORM], FRM_WIDTH_2, 0, 0,
					me->RwCptData[actual_cpt].width, sel_flag );
		       FIfld_set_value( me->form_ptr[MAIN_FORM], FRM_DEPTH_2, 0, 0,
					me->RwCptData[actual_cpt].depth, sel_flag );


		      for(j=1; j<(me->RwCptData[actual_cpt].nb_tier+1); j++)
		      {
			IGRchar temp_sp[20];
			IGRchar temp_tn[3];
			IGRint  row , sel_flag;

			row = j - 1;
			sprintf(temp_sp,"%.2f",me->RwCptData[actual_cpt].tier_sp[row]);
			sprintf(temp_tn,"%d",j);

			sprintf(temp_sp,"%.2f",me->RwCptData[actual_cpt].tier_sp[row]);
			sprintf(temp_tn,"%d",j);

			FIfld_set_text(me->form_ptr[MAIN_FORM], FRM_TIER_SP_2, row, 0,
						     temp_tn, sel_flag );
			FIfld_set_text(me->form_ptr[MAIN_FORM],FRM_TIER_SP_2,row,1,
						     temp_sp,sel_flag);

		      }

		     }

		     break;

		    /********************   CR179900491 - End  **************/

	  default:
		      __DBGpr_com( "undefined gadget \n" );
		      break;

	  }
      }
      else {			/* for sub form */
	  switch ( gadget_label )
	      {

		/*A Only FI_ACCEPT and FI_CANCEL must erase the form */
		case FI_CANCEL:
		case FI_ACCEPT:
        		/* Erase and Reset the displayed form */
			FIf_erase( form_ptr );
			FIg_set_state_off( me->form_ptr[SUB_FORM],
				gadget_label );

			/* Set button to off */
			FIg_set_state_off( me->form_ptr[MAIN_FORM],
				USR_ATTR_BUTTON );
			FIg_set_notify_on( me->form_ptr[MAIN_FORM],
				USR_ATTR_BUTTON );

			FIg_set_state_off( me->form_ptr[MAIN_FORM],
				STAT_ATTR_BUTTON );
			FIg_set_notify_on( me->form_ptr[MAIN_FORM],
				STAT_ATTR_BUTTON );

			break;
	      }

	   }/* me->form_ptr[SUB] */	
End
quit :

  return OM_S_SUCCESS;

} /* end form_notification method */

/*C	VRSetParamForm : creates the subform required and sets the
	data in the subform
*/

method	VRSetParamForm ( long *msg; int	gadget_label )
{
	IGRint			status = OM_S_SUCCESS;
	IGRlong			retmsg;
	extern int 		COB_FI_form_notification();
	struct	GRid		ParamId;
	IGRchar			CondCode[VR_CODE_LENGTH+1];

	*msg = MSSUCC;


	/*A set the Param Id based on the button activated */
	switch ( gadget_label )
	{
		case STAT_ATTR_BUTTON :
			/*C get the ModelId from the current component */
			status = 
			om$send( msg   = message VRGeneric.VRGetModel
				( &retmsg, &me->ModelId, 
				&me->LocatedObjects[me->CurCmpIndex].mod_env ),
			targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
			targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
			as$status( action = RET_STATUS );
	
			/*"ModelId of the Cmp = %d \n",
				me->ModelId.objid */
			
			ParamId = me->ModelId;
			break;
			
		case USR_ATTR_BUTTON :
			ParamId = me->UsrId;
			break;
		
		case COND_ATTR_BUTTON :
			FIg_get_text( me->form_ptr[MAIN_FORM],
				CONDUCTOR_CODE, CondCode );

			status =
			VRGetCondAttr( CondCode, &ParamId );
			break;

		default :
			printf(" Undefined Gadget \n");
			return OM_E_INVARG;

	} /* end of switch for form index */

	/*C error checking */
	if ( ParamId.objid == NULL_OBJID ) 
	{
		if ( gadget_label == STAT_ATTR_BUTTON )
		{
		ex$message(in_buff = "No Static Attributes found for the Component",
				field = ERROR_FIELD );
		} else if (  gadget_label == USR_ATTR_BUTTON ) {
		ex$message(in_buff = "No User Attributes found for the Component",
				field = ERROR_FIELD );
		} else {
		ex$message(in_buff = "No Attributes found for the Conductor",
				field = ERROR_FIELD );
		}
		return OM_E_ABORT;
	}

	/*A prepare sub form */
	if( me->form_ptr[SUB_FORM] == NULL )
	{
		IGRint		Xpos=-1, Ypos=-1;

		/*C create sub form */
		status = FIf_new( SUB_FORM, me->form_name[SUB_FORM],
						COB_FI_form_notification, 
						&me->form_ptr[SUB_FORM] );

		if ( status )
		{
			me->form_ptr[SUB_FORM] = NULL;
			return OM_E_ABORT;
		}

		status = FIf_set_cmd_oid_os
			( me->form_ptr[SUB_FORM], my_id, OM_Gw_current_OS );

		/*C set the location of the subform relative
		    to the base form */
		switch( me->Product )
		{
			case VR_PIPING:
				Xpos = 240;
				Ypos = 250;
				break;

			case VR_HVAC:
				Xpos = 240;
				Ypos = 400;
				break;

			case VR_CABLING:
				Xpos = 240;
				Ypos = 395;
				break;

			case VR_ELECTRIC:
			case VR_FIBER:
				Xpos = 240;
				Ypos = 200;
				break;

		}

		FIf_set_rel_location( me->form_ptr[SUB_FORM],
		 Xpos, Ypos,me->form_ptr[MAIN_FORM]);

		if( status ) return OM_E_ABORT;

	} /* end create sub form */

	/*A erase the sub form title */
	FIg_erase(me->form_ptr[SUB_FORM], ADD_PARAM_TEXT );
	FIg_erase(me->form_ptr[SUB_FORM], STAT_ATTR_TEXT );
	FIg_erase(me->form_ptr[SUB_FORM], USER_ATTR_TEXT );
	FIg_erase(me->form_ptr[SUB_FORM], COND_ATTR_TEXT );

	/*A display appropriate sub form title */
	if ( gadget_label == STAT_ATTR_BUTTON )
		FIg_display(me->form_ptr[SUB_FORM], STAT_ATTR_TEXT );
	else if (  gadget_label == USR_ATTR_BUTTON )
		FIg_display(me->form_ptr[SUB_FORM], USER_ATTR_TEXT );
	else
		FIg_display(me->form_ptr[SUB_FORM], COND_ATTR_TEXT );

	/*A display the collection data in the subform	*/
	status = VR$DispCollAttr(pForm   = me->form_ptr[SUB_FORM],
				Gadget  = USER_ATTR_FLD,
		 		pCollId = &ParamId );
	as$status( action = RET_STATUS );

	/*A display the missing attributes along with user attributes */
	if ( gadget_label == USR_ATTR_BUTTON && 
			me->MissingId.objid != NULL_OBJID )
	{
		struct	ACrg_coll	ListAttr[VR_MAX_ATTR];
		IGRint			NbAttr;

		NbAttr = 0;

		/*A get the number of rows in the list */
		status = 
		om$send( msg      = message ACrg_collect.AClist_attribute
			( &retmsg, VR_MAX_ATTR, ListAttr, &NbAttr ),
				targetid = ParamId.objid,
				targetos = ParamId.osnum );
		as$status( action = RET_STATUS );
	
		/*"Nb of User Attributes = %d \n", NbAttr */

		/*A display the collection data in the subform	*/
		status = VR$DispCollAttr(pForm   = me->form_ptr[SUB_FORM],
				Gadget  = USER_ATTR_FLD,
				Row = NbAttr,
		 		pCollId = &me->MissingId );
		as$status( action = RET_STATUS );
	}
	return OM_S_SUCCESS;

}/* end VRSetParamForm */

IGRint	VRGetCondAttr( CondCode, pCollId )
	IGRchar		*CondCode;	/* I - conductor's code		*/
	struct	GRid	*pCollId;	/* O - collection Id		*/
{
	IGRint			status;
	IGRlong			retmsg;
	IGRchar			sz50Where[50];
	IGRchar			**Buffer=NULL;
	IGRint			NbRows=0, i;

	status = OM_S_SUCCESS;

	if ( !CondCode ) return	0;

	sprintf(sz50Where, "conductor_code=\'%s\'",
			CondCode );
	
	/*printf( " search string for conductor's attributes = %s \n",
				sz50Where );	*/

/*H : KLUDGE : column names hard coded, num columns is also hard coded*/

	/*A get the attributes of the conductor */
	status=
	vdb$RisSelect(	select =
"alt_direct,sect_conduct,clad_diam,voltage,intensity,resistance,modal_bw,len_sca_fac,resis_measure_wl,sensitivity",
			table_name = VRDB_ELECOND_TBL,
			where	= sz50Where,
			numselect = 10,
			p_numrows = &NbRows,
			p_buffer  = &Buffer);

	if ( status&1 && NbRows )
	{
		extern GRclassid	OPP_ACrg_collect_class_id;
		IGRchar		*ps10KludgeNames[10]={ 	"alt_direct",
							"sect_conduct",
							"clad_diam",
							"voltage",
							"intensity",
							"resistance",
							"modal_bw",
							"len_sca_fac",
							"resis_measure_wl",
							"sensitivity"};

		/*C Create static collection */
		pCollId->objid = NULL_OBJID;
		pCollId->osnum = OM_Gw_current_OS;

		status =
		om$construct(	classid = OPP_ACrg_collect_class_id,
			p_objid = &pCollId->objid,
			osnum	= pCollId->osnum,
			msg     = message ACrg_collect.ACset_list_attribute
					( &retmsg, 0, NULL));
		as$status( action = GOTO_VALUE, value = wrapup ) ;

		/*C fill collection with attributes */
		for (i=0; i<10; i++)
		{
			struct ACrg_coll	Attr;

			VRAsciiToAttr ( ps10KludgeNames[i], Buffer[i],
				&Attr );

			status =
			om$send( msg = message ACrg_collect.ACadd_list_attribute
						( &retmsg, 1, &Attr ),
				senderid = NULL_OBJID,
				targetid = pCollId->objid,
				targetos = pCollId->osnum );
			as$status();
		}
	}
	else
	{
		printf ("%s : Error, Select from <%s> where <%s>\n",
			CondCode, VRDB_ELECOND_TBL, sz50Where );
		status = 0;
	}

wrapup :
	VdsRisFreeBuffer ( Buffer, NbRows*10 );
	return status;

}/* end VRGetCondAttr */


IGRint	VRGetCondCode( Product, CabCode, CondCode )
        IGRint           Product;
	IGRchar		*CabCode;	/* I - cable code		*/
	IGRchar		*CondCode;	/* O - conductor's code		*/
{
	IGRint			status;
	IGRchar			sz50Where[50];
	IGRchar			**Buffer=NULL;
	IGRint			NbRows=0;

	status = OM_S_SUCCESS;

	if ( !CabCode || !CondCode ) return 0;

	sprintf(sz50Where, "comp_code=\'%s\'",
			CabCode );
	
/*H : KLUDGE : column names hard coded, num columns is also hard coded*/

        if (Product == VR_ELECTRIC)
	{ /*A get the attributes of the conductor */
	  status=
	  vdb$RisSelect(select = VR_N_V_COND_CODE_AN,
	  		table_name = VRDB_ELECABCONST_TBL,
			where	= sz50Where,
			numselect = 1,
			p_numrows = &NbRows,
			p_buffer  = &Buffer);
	}
	else
	{ /*A   or the fiber    */
	  status=
	  vdb$RisSelect(select = VR_N_V_FOPTIC_CODE_AN,
	  		table_name = VRDB_FOCONST_TBL,
			where	= sz50Where,
			numselect = 1,
			p_numrows = &NbRows,
			p_buffer  = &Buffer);
	}

/*KLUDGE : what if more than one row is found in the DB */

	if ( status&1 && NbRows )
	{
		if ( CondCode )
			strcpy( CondCode, Buffer[0] );
	}
	else
	{
          if (Product == VR_ELECTRIC)
		printf ("%s : Error, Select from <%s> where <%s>\n",
			CabCode, VRDB_ELECABCONST_TBL, sz50Where );
	  else
		printf ("%s : Error, Select from <%s> where <%s>\n",
			CabCode, VRDB_FOCONST_TBL, sz50Where );
		status = 0;
	}

	VdsRisFreeBuffer ( Buffer, NbRows*1);
	return	status;

}/* end VRGetCondCode */

end implementation VRRevAttr;

