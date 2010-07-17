
/* $Id: VRRevSetup.I,v 1.3 2001/02/20 01:14:39 build Exp $  */

/*************************************************************************

 * I/ROUTE
 *
 * File:	vrpara / VRRevSetup.I
 *
 * Description:
	Contains the VRUpdSysForm method
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRevSetup.I,v $
 *	Revision 1.3  2001/02/20 01:14:39  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 21:51:45  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/10  16:00:46  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.8  1999/11/05  19:56:50  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by lawaddel for route
#
# Revision 1.7  1999/10/22  15:50:24  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by lawaddel for route
#
# Revision 1.6  1999/05/19  06:56:42  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by sbilla for route
#
# Revision 1.4  1999/04/30  09:07:16  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by sbilla for route
#
# Revision 1.3  1999/04/19  11:02:34  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by sbilla for route
#
# Revision 1.2  1998/08/05  15:59:36  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/04  21:06:10  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/07/24  19:18:54  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by lawaddel for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/05/15  20:11:08  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/17  14:47:40  pinnacle
# Replaced: vrpara/VRRevSetup.I for:  by r240_int for route240
#
 *
 * History:
 *	08/11/93	Manyam	creation
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      07/25/98        LAW     Added tiers for raceway - CR179801144
 *      04/19/99        Reddy   Added multi-tiers for Raceway - CR179800491
 *      04/30/99        Reddy   Added info for transition components-CR179800491
 *      05/19/99        Reddy   Corrected the dangle information gadget 
 *      09/19/99        LAW     TR17900780/781- rway cleanup
 *	11/05/99	LAW	tr179900932 form cleanup
 *      May 9 2k        Anand   Removed FIg_erase calls to Corner Radius related
 *                              fields for all Raceway forms - TR 179901473
 *************************************************************************/

class implementation VRRevAttr;

#include	<stdio.h>
#include	"ACrg_collect.h"
#include	"VRchgattrdef.h"
#include	"vrparameters.h"
#include	"VRMcForm.h"
#include	"AS_status.h"
#include	"VDmacdef.h"
#include	"vdsmacros.h"
#include	"VRDbStruct.h"
#include	"VRdimdef.h"
#include	"vrpara_pto.h"
#include	"vrpdu_pto.h"
#include	"vrchgatt_pto.h"

#include	"VRRwDimen.h"
#include	"vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

/* This represents the group of all tier related gadgets for Raceways */
#define 	TIER_INFOGROUP 	     777 

#define 	VR_OPTCODE_LIST_NUM  400
#define 	CMP_CODE  	     94

from	VRGeneric	import	VRGetInstance;
from	VRGeneric	import	VRGetNumberOfCpts;
from	ACrg_collect	import	ACget_named_attribute;
from	NDmacro		import	ACgive_structure;

/*C	VRUpdSysForm : Given the Sys Attr collection Id, this 
	method displays these attributes in to the respective
	form
*/

method	VRUpdSysForm()
{
	IGRlong			retmsg;
	int			status;
        IGRint			shape_code; /* CR179801144 */

	if ( !me->form_ptr[MAIN_FORM] || 
		me->SysId.objid == NULL_OBJID )
			return OM_E_ABORT;

	/*C erase the gadgets first */
	FIg_erase( me->form_ptr[MAIN_FORM], LENGTH); 
	FIg_erase( me->form_ptr[MAIN_FORM], SYMB_LENGTH); 
	FIg_erase( me->form_ptr[MAIN_FORM], LENGTH_IMP_UNIT); 
	FIg_erase( me->form_ptr[MAIN_FORM], LENGTH_MET_UNIT); 
	FIg_erase( me->form_ptr[MAIN_FORM], BEND_ANGLE); 
	FIg_erase( me->form_ptr[MAIN_FORM], SYMB_BEND_ANGLE); 
	FIg_erase( me->form_ptr[MAIN_FORM], BEND_ANGLE_UNIT); 

	/*A get the info from the located component */
	{
		char			DispStr[20];
		IGRdouble		dSysComp; /* System Comp attr */
		IGRint			Index=-1;
		struct ret_struct	AttrSt;
		IGRchar			*FootName;

		/*C get the component code */
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_TAG_NUMBER_AN,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
		as$status();


		/*C set the comp code */
		FIg_set_text( me->form_ptr[MAIN_FORM],
			CMP_NUMBER, AttrSt.var.text_st.text_string );

		/* Cmp Number =%s\n",AttrSt.var.text_st.text_string*/

		/*C get the AABBCC code */
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_COMP_CODE_AN,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
		as$status();

		/*C set the comp AABBCC code */
		FIg_set_text( me->form_ptr[MAIN_FORM],
			CMP_CODE, AttrSt.var.text_st.text_string );

		/* "Cmp Code = %s \n", AttrSt.var.text_st.text_string */

		/*C get the shape code CR179801144 */
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_SHAPE_IN,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
		as$status();

		shape_code = ( int )AttrSt.var.root_pm_st.value;
		/*C processing for conductor code */
		if (( me->Product == VR_ELECTRIC ) ||
                    ( me->Product == VR_FIBER))
		{
			IGRchar		szCbCode[VR_CODE_LENGTH+1],
					szCondCode[VR_CODE_LENGTH+1];

			strcpy( szCbCode, AttrSt.var.text_st.text_string);

			/*A get the conductor code */
			if ( strlen( szCbCode ) > 0 )
			  status = VRGetCondCode( me->Product,
                                                  szCbCode, szCondCode );

			if ( strlen(szCbCode) == 0 || status != 1 )
			  /*C erase the conductor code gadgets*/
			  FIg_erase( me->form_ptr[MAIN_FORM],
					CONDUCTOR_GROUP );
			else {
			  /*C set the conductor code */
			  FIg_set_text(  me->form_ptr[MAIN_FORM],
				CONDUCTOR_CODE, szCondCode );
			  /*C display the conductor code gadgets*/
			  FIg_display( me->form_ptr[MAIN_FORM],
					CONDUCTOR_GROUP );
			}
		} /* end processing for conductor code */

		if ( me->Product == VR_PIPING )
		{
		IGRint	i_code;
		IGRchar	o_lname[16], p_error[30];
		
		/*C get the option code */
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_OPTION_IN,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );
		as$status();

		i_code = ( int )AttrSt.var.root_pm_st.value;
		o_lname[0] = '\0';

		status = 
		vd$get_alias (  p_msg	= &retmsg,
		    	       product	= PIPING,
		    	       type	= VR_OPTCODE_LIST_NUM,
		               i_code	= i_code,
		    	       o_lname	= o_lname,
		    	       p_error	= p_error	);

		if ( !strlen(o_lname) ) 
			sprintf(o_lname, "%d", i_code );

		/*C set the option code */
		FIg_set_text( me->form_ptr[MAIN_FORM],
			OPT_CODE, o_lname ); 

		/*"Option Code = %d \n", AttrSt.var.root_pm_st.value */

		}

		FIg_erase ( me->form_ptr[MAIN_FORM], NUM_OF_COMPS);

		/*C erase the next and previous buttons if only one component 
	    	    is identified	*/
		if ( me->NumOfObjects == 1 ) 
		{
			FIg_erase( me->form_ptr[MAIN_FORM], NEXT); 
			FIg_erase( me->form_ptr[MAIN_FORM], PREVIOUS); 
		} else {
			FIg_display( me->form_ptr[MAIN_FORM], NEXT); 
			FIg_display( me->form_ptr[MAIN_FORM], PREVIOUS); 

			/*C display the number of components to be reviewed */
			sprintf( DispStr, "%d%s%d",me->CurCmpIndex+1,"/",
				me->NumOfObjects );

			FIg_set_text ( me->form_ptr[MAIN_FORM],
				NUM_OF_COMPS, DispStr );
			FIg_display ( me->form_ptr[MAIN_FORM], NUM_OF_COMPS);
		}

		/*C get the material take off value */
		Index=-1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_NO_MTO_AN,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );

		/*C set the corresponding values in the gadgets */
  		if( AttrSt.var.text_st.text_string[0] == '1' )
			FIg_set_text (me->form_ptr[MAIN_FORM], 
				MAT_TAKE_OFF, "Yes");
  		else
			FIg_set_text ( me->form_ptr[MAIN_FORM],
				MAT_TAKE_OFF, "No");

		/*A  get the sytem computed attributes	*/
		if ( me->Product != VR_ELECTRIC )
		{		
		/*C get the length for the linear components */
		Index = -1;
		if ( me->Product == VR_PIPING )
			FootName = VR_N_PIPE_LNG_DB;
		else
			FootName = VR_N_DUCT_LNG_DB;
			
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, FootName,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );

		if ( ! ( status & 1 & retmsg ) ) dSysComp = 0.0;
		else
			dSysComp =  AttrSt.var.root_pm_st.value;

		/*"Length of the Cmp =%lf\n",dSysComp */

		/*C better if we make them in to a group */

		/*C display the length in the gadget	NYC */
		if ( dSysComp != 0 )
		{

			switch (VRenq_proj_units())
			{
				case VR_METRIC_UNITS :
				case VR_MIXED_UNITS :
	/* Divide length by 1000 for meters rather than millimeters */
					dSysComp /= 1000;
					FIg_display( me->form_ptr[MAIN_FORM], 
					 LENGTH_MET_UNIT);
					break;
				case VR_IMPERIAL_UNITS :
	/* Divide length by 12 for feet rather than inches */
					dSysComp /= 12;
					FIg_display( me->form_ptr[MAIN_FORM], 
					 LENGTH_IMP_UNIT);
					break;
			}
			FIg_display( me->form_ptr[MAIN_FORM], SYMB_LENGTH); 
			FIg_display( me->form_ptr[MAIN_FORM], LENGTH); 
			FIg_set_value( me->form_ptr[MAIN_FORM],
				LENGTH, dSysComp ); 
		}

		/*C get the bend sweep value */
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_BEND_ANG_DB,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );

		if ( ! ( status & 1 & retmsg ) ) dSysComp = 0.0;
		else
			dSysComp = AttrSt.var.root_pm_st.value;

		/* Bend angle =%lf\n",dSysComp */

		/*C display the bend sweep in the resp gadget NYC */
		if ( dSysComp != 0 )
		{
			FIg_erase( me->form_ptr[MAIN_FORM], LENGTH); 
			FIg_erase( me->form_ptr[MAIN_FORM], SYMB_LENGTH); 
			FIg_erase( me->form_ptr[MAIN_FORM], LENGTH_IMP_UNIT); 
			FIg_erase( me->form_ptr[MAIN_FORM], LENGTH_MET_UNIT); 
			FIg_display( me->form_ptr[MAIN_FORM], SYMB_BEND_ANGLE); 
			FIg_display( me->form_ptr[MAIN_FORM], BEND_ANGLE); 
			FIg_set_value( me->form_ptr[MAIN_FORM],
				BEND_ANGLE, dSysComp ); 
			FIg_display( me->form_ptr[MAIN_FORM], BEND_ANGLE_UNIT); 
		}

		} /*end not VR_ELECTRIC	*/

		/*A get the surf_area in case if the product is HVAC */
		if ( me->Product == VR_HVAC )
		{
		Index = -1;
		status =
		om$send (msg = message NDmacro.ACgive_structure
			( (IGRint *) &retmsg, &Index, VR_N_SURF_AREA_DB,
			&AttrSt,&me->LocatedObjects[me->CurCmpIndex].mod_env ),
		targetid = me->LocatedObjects[me->CurCmpIndex].obj_id.objid,
		targetos = me->LocatedObjects[me->CurCmpIndex].obj_id.osnum );

		if ( ! ( status & 1 & retmsg ) ) dSysComp = 0.0;
		else
			dSysComp = AttrSt.var.root_pm_st.value;

		/* Surface Area =%lf\n",dSysComp */
		
		/*C display the surface area in the gadget NYC */
		FIg_set_value( me->form_ptr[MAIN_FORM],
			 SURF_AREA, dSysComp ); 
		} /* end if HVAC */

	} /* end sytem computed attributes */
	
	/*A set all the system attributes */
	if ( me->Product != VR_ELECTRIC )
	{
	status = 
	VRUpdALLSysForm( me->Product, me->form_ptr[MAIN_FORM],
		&me->SysId );
	as$status( action = RET_STATUS );
	} 
        
	
	/********************** CR179900491 *******************/

	if(me->Product == VR_RWAY)
	{
	     IGRint		active_cpt ;
	     IGRint 		proc_mode ;
	     IGRlong		retmsg;
	     IGRint		status;
	     IGRint		i, j;
	     struct GRid	CmpId;
	     
	     active_cpt =2 ;
	     proc_mode = 0 ;
         
	     __DBGpr_com( " Computing for RaceWay Tiers ");

	     /* Get the number of the connect points for the
	     component located    */
             
	     CmpId = me->LocatedObjects[me->CurCmpIndex].obj_id;

	     __DBGpr_obj(" Located object is " , CmpId);

	     status=om$send(msg = message VRGeneric.VRGetNumberOfCpts
				 (&retmsg, &me->NbCpts,
				  &me->LocatedObjects[me->CurCmpIndex].mod_env),
		  targetid = CmpId.objid,
		  targetos = CmpId.osnum );
	     as$status ( action = RET_STATUS );

	    __DBGpr_int( " No. of connect points are ", me->NbCpts);
            __DBGpr_int( " Shape code is " , shape_code);	

	    /*  Intialise the structure for Raceway details(me->RwCptData)  */

		__DBGpr_com( " Initialising the RwCptData structure ");

		for( i=0; i<(me->NbCpts); i++ )
		{
		    me->RwCptData[i].width  = 0.0 ;
		    me->RwCptData[i].depth  = 0.0;
		    me->RwCptData[i].nb_tier = 0 ;
		    for( j=0 ; j<(me->RwCptData[i].nb_tier); j++)
		    me->RwCptData[i].tier_sp[j] = 0.0 ;
		}

	     __DBGpr_com( " Calling VRRw_dimen_fields ");

	     VRRw_dimen_fields(  NULL, NULL, &CmpId,
				 &me->LocatedObjects[me->CurCmpIndex].mod_env,
				 me->NbCpts, &active_cpt, proc_mode, shape_code,
				 me->RwCptData, NULL );
	
	    for( i=0; i<(me->NbCpts); i++ )
	    {
		__DBGpr_int( " Values for connect point index" , i+1);
		__DBGpr_int( " Width 1 ", me->RwCptData[i].width );
		__DBGpr_int( " Depth 1 ", me->RwCptData[i].depth );

		__DBGpr_int( " nb_tier ", me->RwCptData[i].nb_tier);

		for( j=0 ; j<(me->RwCptData[i].nb_tier); j++)
		__DBGpr_dbl( " tier_spacing ",me->RwCptData[i].tier_sp[j]) ;
            }  
	  }

	/********************** CR179900491 *******************/

	/*A	set application specific data in the forms	*/
	switch ( me->Product)
	{
	 case VR_PIPING :
		/*C manipulate the Pid gadgets	*/
		if ( me->bPid ) 
		{
			/*C display Pid gadgets */
			FIg_display( me->form_ptr[MAIN_FORM], PID_SCALE );
			FIg_display( me->form_ptr[MAIN_FORM], SYMB_PID_SCALE );
		}
		else
		{
			/*C erase Pid gadgets */
			FIg_erase( me->form_ptr[MAIN_FORM], PID_SCALE );
			FIg_erase( me->form_ptr[MAIN_FORM], SYMB_PID_SCALE );
		}

       		VR$DispCollAttr ( pForm         = me->form_ptr[MAIN_FORM],
                          pCollId       = &me->SysId,
                          Gadget        = P_NPD_R,
                          pAttrName     = VR_N_RDIAMETER_DB);
		break;

	 case VR_HVAC :
	 case VR_CABLING:
		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  pCollId	= &me->SysId,
			  Gadget	= WIDTH2,
			  pAttrName 	= VR_N_WIDTH2_DB);

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  pCollId	= &me->SysId,
			  Gadget	= DEPTH2,
			  pAttrName 	= VR_N_DEPTH2_DB);

		if ( me->Product == VR_CABLING )
		{
		 VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
				  Gadget	= SERVICE,
			  	  pAttrName 	= VR_N_SERVICE_AN);

		 VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= EQUIV_DIAM,
		  		  pAttrName 	= VR_N_EQUIV_DIA_DB);
#ifdef INCLUDE_IT 

		/** CR179900491 -  A new implementation for tier information has been made  **/ 

                 /* CR179801144 - If rectanuglar, display tiers */
		 if(shape_code == VR_RECT)
                 {
		   /* CR179801144 - set default values for missing parameters */
		   VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= SP_TIER_RV1,
				  pAttrName 	= VR_N_DEPTH1_DB);

		   FIg_set_value( me->form_ptr[MAIN_FORM],
			 N_TIER_RV1, 1.0 ); 

		   VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= SP_TIER_RV2,
				  pAttrName 	= VR_N_DEPTH2_DB);

		   FIg_set_value( me->form_ptr[MAIN_FORM],
			 N_TIER_RV2, 1.0 ); 

		   /* CR179801144 - get values for tier parameters */
		   VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= SP_TIER_RV1,
				  pAttrName 	= VR_N_TIERSP1_DB);

		   VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= N_TIER_RV1,
				  pAttrName 	= VR_N_NUMTIER1_IN);
		  
		   VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= SP_TIER_RV2,
				  pAttrName 	= VR_N_TIERSP2_DB);

		   VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
			  	  pCollId	= &me->SysId,
		  		  Gadget	= N_TIER_RV2,
				  pAttrName 	= VR_N_NUMTIER2_IN);
		 }
                 else /* erase tier fields */
                 {
		   FIg_erase( me->form_ptr[MAIN_FORM], N_TIER_RV1 );
		   FIg_erase( me->form_ptr[MAIN_FORM], N_TIER_RV2 );
		   FIg_erase( me->form_ptr[MAIN_FORM], SP_TIER_RV1 );
		   FIg_erase( me->form_ptr[MAIN_FORM], SP_TIER_RV2 );
                 }
		/** CR179900491 -  A new implementation for tier information has been made  **/ 

    #endif

		} else {
			/*C manipulate the Pid gadgets	*/
			if ( me->bPid ) 
			{
				/*C display Pid gadgets */
				FIg_display( me->form_ptr[MAIN_FORM], 
					PID_SCALE );
				FIg_display( me->form_ptr[MAIN_FORM], 
					SYMB_PID_SCALE );
			} else {
				/*C erase Pid gadgets */
				FIg_erase( me->form_ptr[MAIN_FORM],
					PID_SCALE );
				FIg_erase( me->form_ptr[MAIN_FORM], 
					SYMB_PID_SCALE );
			}
		} /* end of not cabling */
		break;

	 case VR_ELECTRIC :
		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
		  	  pCollId	= &me->SysId,
			  Gadget	= SYSTEM_NAME,
		  	  pAttrName 	= VR_N_SYST_NAME_AN );

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
		  	  pCollId	= &me->SysId,
			  Gadget	= UNIT_NUMBER,
		  	  pAttrName 	= VR_N_UNIT_AN );

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
		  	  pCollId	= &me->SysId,
			  Gadget	= BLOCK_NO,
		  	  pAttrName 	= VR_N_ZONE_AN );

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
		  	  pCollId	= &me->SysId,
			  Gadget	= CONSTRUC_STATUS,
		  	  pAttrName 	= VR_N_CONSTR_STAT_AN );

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
		  	  pCollId	= &me->SysId,
			  Gadget	= APPROVAL_STATUS,
		  	  pAttrName 	= VR_N_APPRV_STAT_AN );

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
		  	  pCollId	= &me->SysId,
			  Gadget	= APPROVAL_STATUS,
		  	  pAttrName 	= VR_N_APPRV_STAT_AN );

		VR$DispCollAttr ( pForm 	= me->form_ptr[MAIN_FORM],
				pCollId		= &me->SysId,
                          	Gadget        	= PID_SCALE,
                          	pAttrName     	= VR_N_PID_SCALE_DB);

		/*C manipulate the Pid gadgets	*/
		if ( me->bPid ) 
		{
			/*C display Pid gadgets */
			FIg_display( me->form_ptr[MAIN_FORM], PID_SCALE );
			FIg_display( me->form_ptr[MAIN_FORM], SYMB_PID_SCALE );
		}
		else
		{
			/*C erase Pid gadgets */
			FIg_erase( me->form_ptr[MAIN_FORM], PID_SCALE );
			FIg_erase( me->form_ptr[MAIN_FORM], SYMB_PID_SCALE );
		}
		break;


	}/* end switch on product */
	


	    /****************** CR179900491 ****************/

	    /**  Tier calculations for Raceways only. Begin   **/
	      if(me ->Product == VR_RWAY)
	      {
	       
		IGRchar		 cpt_index[10];
		IGRint  	 active_cpt, active_cpt_fir;
		IGRchar 	 active_cpt_index_fld[3];
		IGRint  	 sel_flag , actual_cpt ;
		IGRint  	 i , j;
	
  		/****** Display / undisplay corner radius gadget  ****/	
		/* added for tr179900780 */
                FIg_erase(me->form_ptr[MAIN_FORM],15);
                FIg_erase(me->form_ptr[MAIN_FORM],17);
                FIg_erase(me->form_ptr[MAIN_FORM],18);
                FIg_erase(me->form_ptr[MAIN_FORM],19);
                FIg_erase(me->form_ptr[MAIN_FORM],20);
                if(shape_code == VR_ELLIPSE)
		{
                   FIg_display( me->form_ptr[MAIN_FORM],20);
		}
                else if(shape_code == VR_OVAL)
		{
                   FIg_display( me->form_ptr[MAIN_FORM],15);
		}
                else if(shape_code == VR_CIRC)
		{
                   FIg_display( me->form_ptr[MAIN_FORM],17);
		}
                else if(shape_code == VR_RECT)
		{
                   FIg_display( me->form_ptr[MAIN_FORM],18);
		}
		if(shape_code == VR_CORNER)
		{
		    FIg_display( me->form_ptr[MAIN_FORM],CORNER_RADIUS);
		    FIg_display( me->form_ptr[MAIN_FORM],CORNER_RADIUS_LBL);
		    /* Corner here,hardcoding gadget activate */
		    FIg_display( me->form_ptr[MAIN_FORM],19);/*TR179900780*/
		}
			
		FIg_display(me->form_ptr[MAIN_FORM], FRM_DEPTH_1);
		FIg_display(me->form_ptr[MAIN_FORM], CMP_CODE); // Comp_code 

		/****** Display/undisplay gadgets concerned with tiers **/

		if(shape_code == VR_RECT) 
		 {

		/*Gadget labels for in for tier_sp1 is 47 and tier_sp2 is 82 */
		/*Gadget labels for mm for tier_sp1 is 46 and tier_sp2 is 51 */

		   FIg_display( me->form_ptr[MAIN_FORM], 46 );
		   FIg_display( me->form_ptr[MAIN_FORM], 51 );
		   FIg_display( me->form_ptr[MAIN_FORM], 47 );
		   FIg_display( me->form_ptr[MAIN_FORM], 82 );

		   /**  Make a group for tier info gadgets **/

		   FIg_display( me->form_ptr[MAIN_FORM], TIER_INFOGROUP );

		    switch (VRenq_proj_units())
		    {
		    case VR_METRIC_UNITS :
		    case VR_MIXED_UNITS :

		/* Here gadget labels indicate the units for tier spacing */
		/* Gadget labels for in for tier_sp1 is 47 and tier_sp2 is 82 */

		       FIg_erase( me->form_ptr[MAIN_FORM], 47 );

		       FIg_erase( me->form_ptr[MAIN_FORM], 82 );
		       break;
		    case VR_IMPERIAL_UNITS :

		/* Here gadget labels indicate the units for tier spacing */
		/* Gadget labels for mm for tier_sp1 is 46 and tier_sp2 is 51 */

		       FIg_erase( me->form_ptr[MAIN_FORM], 46 );
		       FIg_erase( me->form_ptr[MAIN_FORM], 51 );
		       break;
		    }

		   FIg_disable(me->form_ptr[MAIN_FORM],DECREASE_ACTIVE_CPT_INDEX);		
		 } else
		    {
		     /*Following gadget labels indicate mm and in for tier_sp*/

		     FIg_erase( me->form_ptr[MAIN_FORM], 46 );
		     FIg_erase( me->form_ptr[MAIN_FORM], 51 );
		     FIg_erase( me->form_ptr[MAIN_FORM], 47 );
		     FIg_erase( me->form_ptr[MAIN_FORM], 82 );

		     /**  Make a group for tier info gadgets **/
		     FIg_erase( me->form_ptr[MAIN_FORM], TIER_INFOGROUP );

		     /* If shape code is a transition component from 
			rectangular display  for connect pt.index1 and 
			erase tier_info gadgets for cpt_index2*/

		     if((shape_code == VR_RECT_OVAL) || (shape_code == VR_RECT_CIRC) || (shape_code == VR_RECT_CORN) || (shape_code == VR_RECT_ELLP))
			{
			  /* Following gadget labels indicate cpt_index1 tier_			             info */

			 FIg_display( me->form_ptr[MAIN_FORM], FRM_NO_TIER_1 );
			 FIg_display( me->form_ptr[MAIN_FORM], FRM_TIER_SP_1 );
	                 FIg_display(me->form_ptr[MAIN_FORM],27);// Text for nb.
	                 FIg_display(me->form_ptr[MAIN_FORM],28);// Tier spacing

			 switch (VRenq_proj_units())
			 {
			 case VR_METRIC_UNITS :
			 case VR_MIXED_UNITS :

	       /* Here gadget labels indicate the units for tier spacing */
	       /* Gadget labels for mm for tier_sp1 is 46       	 */

			  FIg_display( me->form_ptr[MAIN_FORM], 46 );
		          break;

			  case VR_IMPERIAL_UNITS :

		/* Here gadget labels indicate the units for tier spacing */
		/* Gadget labels for in for tier_sp1 is 47 and            */

			      FIg_display( me->form_ptr[MAIN_FORM], 47 );
			      break;
			 }

			}  

		   }



	 /** Tier calculations for Rectangular shape only . Begin **/

	       __DBGpr_int( " No. of connect points are ", me->NbCpts);
	       if(me->NbCpts <= 2) 
		{
			FIg_disable(me->form_ptr[MAIN_FORM],INCREASE_ACTIVE_CPT_INDEX);
			FIg_disable(me->form_ptr[MAIN_FORM],DECREASE_ACTIVE_CPT_INDEX);
		}

	       if(me->NbCpts > 2) FIg_enable(me->form_ptr[MAIN_FORM],INCREASE_ACTIVE_CPT_INDEX);

	       actual_cpt = 2;

	       __DBGpr_int( " Connect point index is " , actual_cpt );	

               FIg_erase(me->form_ptr[MAIN_FORM],ACTIVE_CPT_INDEX);	
	       sprintf( active_cpt_index_fld, "%d",actual_cpt);
	       FIg_set_text(me->form_ptr[MAIN_FORM],ACTIVE_CPT_INDEX,
					       active_cpt_index_fld);
	       if(shape_code == VR_RECT) 
               FIg_display(me->form_ptr[MAIN_FORM],ACTIVE_CPT_INDEX);	

	       FIfld_set_num_rows(me->form_ptr[MAIN_FORM], FRM_TIER_SP_1, me->RwCptData[0].nb_tier);
	       FIfld_set_num_rows(me->form_ptr[MAIN_FORM], FRM_TIER_SP_2, me->RwCptData[1].nb_tier);
	       if(me->NbCpts == 1) 
	       FIfld_set_num_rows(me->form_ptr[MAIN_FORM], FRM_TIER_SP_2, me->RwCptData[0].nb_tier);

	       __DBGpr_com(" Display the values for connect point index: 1 ");
	       __DBGpr_int(" Width", me->RwCptData[0].width);
	       __DBGpr_int(" Depth", me->RwCptData[0].depth);
	       __DBGpr_int(" No.of Tiers", me->RwCptData[0].nb_tier);

	       for(j=1; j<(me->RwCptData[0].nb_tier+1); j++)
	       {
		  IGRint row ;
		  row = j-1 ;
		  __DBGpr_dbl("Tier spacing ", me->RwCptData[0].tier_sp[row]);
	       }

	       /** For dangle copy the values of connectpoint-0 into those of
		   connect point-1  **/

		   if(me->NbCpts==1) 
		   {
		     me->RwCptData[1].nb_tier = me->RwCptData[0].nb_tier;
		     me->RwCptData[1].width = me->RwCptData[0].width;
		     me->RwCptData[1].depth = me->RwCptData[0].depth;
		   }

	       __DBGpr_com(" Display the values for connect point index: 2 ");
	       __DBGpr_int(" Width", me->RwCptData[1].width);
	       __DBGpr_int(" Depth", me->RwCptData[1].depth);
	       __DBGpr_int(" No.of Tiers", me->RwCptData[1].nb_tier);

	       for(j=1; j<(me->RwCptData[1].nb_tier+1); j++)
	       {
		  IGRint row ;
		  row = j-1 ;
		  __DBGpr_dbl(" Tier spacing ", me->RwCptData[1].tier_sp[row]);
	       }


	       FIg_set_value(me->form_ptr[MAIN_FORM],FRM_NO_TIER_1,me->RwCptData[0].nb_tier);
	       FIfld_set_value(me->form_ptr[MAIN_FORM], FRM_WIDTH_1, 0, 0,
				me->RwCptData[0].width, sel_flag );
	       FIfld_set_value(me->form_ptr[MAIN_FORM], FRM_DEPTH_1, 0, 0,
				  me->RwCptData[0].depth,sel_flag );

	       FIg_set_value(me->form_ptr[MAIN_FORM],FRM_NO_TIER_2,me->RwCptData[1].nb_tier);
	       FIfld_set_value(me->form_ptr[MAIN_FORM], FRM_WIDTH_2, 0, 0,
				me->RwCptData[1].width, sel_flag );
	       FIfld_set_value( me->form_ptr[MAIN_FORM], FRM_DEPTH_2, 0, 0,
				me->RwCptData[1].depth, sel_flag );

	      for(j=1; j<(me->RwCptData[0].nb_tier+1); j++)
	      {
		IGRchar temp_sp[20];
		IGRchar temp_tn[3];
		IGRint  row , sel_flag;

		row = j - 1;
		sprintf(temp_sp,"%.2f",me->RwCptData[0].tier_sp[row]);
		sprintf(temp_tn,"%d",j);

		FIfld_set_text( me->form_ptr[MAIN_FORM], FRM_TIER_SP_1, row, 0,
					     temp_tn, sel_flag );
		FIfld_set_text(me->form_ptr[MAIN_FORM],FRM_TIER_SP_1,row,1,
					     temp_sp,sel_flag);

	      }

	      /* Fill up Tier spacing for 0 and 1 connect pts. of a component */

	      for(j=1; j<(me->RwCptData[1].nb_tier+1); j++)
	      {
		IGRchar temp_sp[20];
		IGRchar temp_tn[3];
		IGRint  row , sel_flag;

		row = j - 1;

		if(me->NbCpts > 1) 
		 {
		  sprintf(temp_sp,"%.2f",me->RwCptData[1].tier_sp[row]);
		  sprintf(temp_tn,"%d",j);
		 }

		/** For dangle **/
		if(me->NbCpts == 1) 
		 {
		  sprintf(temp_sp,"%.2f",me->RwCptData[0].tier_sp[row]);
		  sprintf(temp_tn,"%d",j);
		 }

		FIfld_set_text( me->form_ptr[MAIN_FORM], FRM_TIER_SP_2, row, 0,
					     temp_tn, sel_flag );
		FIfld_set_text(me->form_ptr[MAIN_FORM],FRM_TIER_SP_2,row,1,
					     temp_sp,sel_flag);
	        }


	      }  /* Tier calculations for Raceways only.  End */

	   /***************  CR179900491 - Reddy ******************/

	return (OM_S_SUCCESS);
}
end implementation VRRevAttr;
