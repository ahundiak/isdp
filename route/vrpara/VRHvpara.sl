/* $Id: VRHvpara.sl,v 1.3 2001/02/20 01:14:33 build Exp $  */
/*************************************************************************+
 * I/ROUTE
 *
 * File:	vrpara/VRHvpara.sl
 *
 * Description:
 *	Display HVAC Parameters Form
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRHvpara.sl,v $
 *	Revision 1.3  2001/02/20 01:14:33  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 16:38:57  anand
 *	SP Merge
 *	
# Revision 1.3  2000/07/13  22:48:42  pinnacle
# Replaced: route/vrpara/VRHvpara.sl for:  by apazhani for Service Pack
#
# Revision 1.2  2000/05/12  22:14:54  pinnacle
# Replaced: route/vrpara/VRHvpara.sl for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/11  22:20:30  pinnacle
# Created: route/vrpara/VRHvpara.sl by apazhani for Service Pack
#
# Revision 1.6  2000/02/06  15:00:50  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by impd252 for route
#
# Revision 1.5  2000/02/04  18:25:06  pinnacle
# (No comment)
#
# Revision 1.4  1999/05/11  10:04:46  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by sbilla for route
#
# Revision 1.3  1998/05/26  19:31:30  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by kddinov for route
#
# Revision 1.2  1998/05/20  22:33:36  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by lawaddel for route
#
# Revision 1.9  1998/04/22  19:23:40  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by lawaddel for route
#
# Revision 1.8  1998/03/03  16:53:50  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by lawaddel for route
#
# Revision 1.7  1998/03/02  15:16:56  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by lawaddel for route
#
# Revision 1.5  1998/02/10  21:27:22  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by lawaddel for route
#
# Revision 1.4  1998/01/14  18:54:24  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by lawaddel for route
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
# Revision 1.6  1996/04/24  19:05:08  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by ashankar for route240
#
# Revision 1.5  1996/04/24  18:42:46  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by ashankar for route240
#
# Revision 1.4  1996/01/17  14:47:22  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by r240_int for route240
#
# Revision 1.3  1995/12/11  13:02:28  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by ashankar for route240
#
# Revision 1.2  1995/12/08  21:23:06  pinnacle
# Replaced: vrpara/VRHvpara.sl for:  by r240_int for route240
#
 *
 * History:
 *	10/24/94	Lori	CR#179422038 Add spec to HVAC
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      01/17/97        law     Restore units right of boxes TR179603395
 *      01/08/98        law     CR179700399 - link diameter->width/depth
 *      01/08/98        law     CR179700380 - reset width/depth
 *      02/27/98        law     TR179800553 - Add HVUSER_ATTR_BUTTON.
 * 	04/29/98	law	TR179801054 - Correct depth store in collection
 * 	05/18/98	law	CR179801061 - Add comp-method for width/depth
 * 	05/11/99        Reddy   TR179900568 - Added Sizing method attribute 
 *				to the collector for storage .
 * 	02/04/2000      Alwin   CR179900696-Update the Material Info according 
 *				to the spec selection. And the thickness's 
 *				based on the selection of Material & Insulation
 *				respectively.
 * 	05/10/2000      Alwin   CR179901312 - Added Acoustical Insulation cases
 * 	07/13/2000      Alwin   CR179901661 - Remove the "acst" attribute from
 *				User Parameters collection. Add it to the
 *				system collection to prevent editing the value.
 *	01/11/2001	Anand	Merging for Pload
 *************************************************************************/

command_string       VRC_M_DisplayHvDgPr,0,VRDsHVDgPr
class                VRHvpara
super_class          VRActParam
/* product_name         "$SPXR" */
product_name         "$ROUTE"
command_table	     "route.cmd"

specification

implementation

#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "OMminimum.h" /* CR179700399 */
#include "igr.h"
#include "exmacros.h"
#include "FI.h"
#include "FEI.h"
#include "AS_status.h"
#include "VRdef.h"
#include "VRact_params.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRMcForm.h"
#include "vrparameters.h"
#include "VRmsg.h"
#include "VRPid.h"
#include "VDSutil.h"
#include "VDDfEntCode.h"
#include "VRDbStruct.h"

#include "HV_param.h"

#include "vrchgatt_pto.h"
#include "vrinit_pto.h"
#include "vrtools_pto.h"
#include "vrpdu_pto.h"
#include "vrflow_pto.h"
#include "VRchgattrdef.h"
#include "vrdbgmacros.h"
#include "VDmem.h"
#include "VRRwDimen.h"

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

extern double pow();

      /* added for TR179800380 */

/* KDD May'98  Comment out the next 4 lines for "z d l" */
/* -- */
%safe
double noncirc_depth = -1.0;
double noncirc_width = -1.0;
%endsafe
/* -- */

/* Modified from safe to extern for dload for TR179801054 */
/***
extern
double noncirc_depth;
extern
double noncirc_width;
 ***/

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
 me->Product		= VR_HVAC;
 me->CommandName	= COMM_NAME_HVAC;
 me->form_name[MAIN] 	= "VRHvDgPar" ;
 me->form_name[SUB] 	= "VRUserParam" ;
}

/*********************************************************/

action VRUpdSysForm()

{
	/*A display the attributes in the Sys form */
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
/* Included for TR179801054 Pload version. Not in pinnacle version */
        noncirc_depth = -1.;
        noncirc_width = -1 ;

	VRGetAttrFromDB( me->form_ptr[MAIN], me->Product );
        FIg_display( me->form_ptr[MAIN], HVUSER_ATTR_BUTTON );

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

/****************************************************************************/

action form_notification( int form_label; int gadget_label;
			  double value; char * form_ptr )
{
  IGRchar		 szText[MAX_FIELD];
  IGRdouble	         dValue;
 
  IGRint        	 NbAttr=0;
  struct ACrg_coll       ListAttr[VR_MAX_ATTR], ColAttr;
  
  IGRint	         sel_flag=0;
  IGRint	         r_pos;
  IGRint	         type;
  IGRint	         row = 0, col = 0;

  char		         form_mode;
  int		         num_rows;
  int		         length;
  int                    int_conv,i;

   /* Below added for CR179700399 - link diameter with depth/width */
  IGRchar		 tmpText[MAX_FIELD];
  double diameter;
  double radius;
  double dEquiDiam;
  double width_val,depth_val;
  double max_depth;
  char method_str[30];
  double ddepth,dwidth;

  IGRlong                retmsg;

  ex$message(in_buff = "",field=ERROR_FIELD);

  if ( form_ptr == NULL )
  {
    /*| form_ptr not set */
    return( OM_E_INVARG );

  }
  /*"form label %d \n", form_label */

  /*"gadget label %d \n", gadget_label */

  dValue = 0.0;
  szText[0] = '\0';

  FIfld_get_type( form_ptr, gadget_label, col, &type );

  if ( type == FI_DOUBLE || type == FI_INT )
  {

       FIfld_get_value( form_ptr, gadget_label, row, col,
		        &dValue, &sel_flag, &r_pos );
  }
  else if ( type == FI_ALPHA )	
  {
       FIfld_get_text( form_ptr, gadget_label, row, col, MAX_FIELD,
				(unsigned char *) szText, &sel_flag, &r_pos );
  }
  else
     /*|Gadget type not defined probably button/symbol\n*/;

  FIfld_set_text( form_ptr, MESSAGE, 0, 0, "", sel_flag );

if ( form_ptr == me->form_ptr[MAIN] )
 {


  /*| System form */
  form_mode = VR_SYSTEM_MODE;
  /*" form_mode is now %d sys is %d\n", form_mode, VR_SYSTEM_MODE */ 


  switch( gadget_label )
  {

    case LINE_NUMBER :

     	NbAttr = 1;
     	strcpy( ListAttr[0].name , VR_N_SEQ_NUMBER_AN  );

#ifdef	MANAGE_IDS
	if ( bVR_IS_PID_ACTIVE)
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
	}/* end verify unicity */
#endif
	break;

    case PRESS_CLASS:
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_PRESS_CLASS_AN );
     break;

    case HVAC_MAT_CLASS:
     NbAttr = 1;
     
     status = check_spec( &retmsg, VR_HVAC, szText, NULL );
	
     if( status != OM_S_SUCCESS )
     {
	FIfld_set_text( form_ptr, MESSAGE, 0, 0,
			"Mat. Class not found in DB", sel_flag );
     }
     strcpy( ListAttr[0].name , VR_N_CLASS_AN );

	 // added for CR179900696
     // Call this function to update the Material list...from db
     VRUpdMaterial_InsulationList( form_ptr, TRUE, szText, DUCT_MATER );

     break;

    case CONST_STATUS:
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_CONSTR_STAT_AN );
     break;

    case APPROVAL_STAT:
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_APPRV_STAT_AN );
     break;

    case SIZE_METHOD:
      /* Below added for CR179700399 - link diameter with depth/width */
      NbAttr = 0;
       FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
				(unsigned char *) tmpText, &sel_flag, &r_pos );
      if(!strncmp (tmpText,"Velocity",8))
      { IGRdouble dAirFlow, dVelocity, dEquiDiam;
	/* get air flow */
    	FIfld_get_value(form_ptr,AIR_FLOW,row,col,&dAirFlow,&sel_flag,&r_pos );

    	FIfld_get_value(form_ptr,MAX_VELOCITY,row,col,&dVelocity,&sel_flag,
                         &r_pos );

	/*A convert Velocity from fpm to fps	*/
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
     dValue = 0;
     strcpy(ColAttr.name, VR_N_SHAPE_IN);

     status =
        om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
     as$status( action = RET_STATUS );
        
     int_conv = (int)ColAttr.desc.value.att_exp;

     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
     break;

    case SERVICE:
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SERVICE_AN );
     break;

    case RECTANGULAR_SHAPE:
     dValue = (double) VR_OVAL;
     int_conv = VR_OVAL;
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.value.att_exp = dValue;
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

	/* Modify form for Oval shape */

     FIg_erase( form_ptr, RECTANGULAR_SHAPE );
     FIg_erase( form_ptr, CIRCULAR_SHAPE );
     FIg_erase( form_ptr, RADIUS_SHAPE );
     FIg_display( form_ptr, OVAL_SHAPE );

	/* needs for depth */
     FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
     FIg_display( form_ptr, D_SIZE );
     /* Below added for CR179700399 - link diameter with depth/width */
     FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
     FIg_display( form_ptr, W_SIZE );

	/* no needs for corner radius */
     FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
     FIg_display( form_ptr, CORNER_RADIUS);
     /* Reset auto width/depth computation */

     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr);

     break;

    case OVAL_SHAPE:
     dValue = (double) VR_CIRC;
     /* Below added for CR179700399 - link diameter with depth/width */
     int_conv = VR_CIRC;
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.value.att_exp = dValue;
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

      /* added for TR179800380 */
     FIfld_get_value( form_ptr,D_SIZE, row, col,
                                  &noncirc_depth,&sel_flag,&r_pos);
     FIfld_get_value( form_ptr,W_SIZE, row, col,
                                  &noncirc_width,&sel_flag,&r_pos);
	/* Modify form for Circular shape */

     FIg_erase( form_ptr, OVAL_SHAPE );
     FIg_erase( form_ptr, RECTANGULAR_SHAPE );
     FIg_erase( form_ptr, RADIUS_SHAPE );
     FIg_display( form_ptr, CIRCULAR_SHAPE );

	/* no need for depth or corner radius */
     FIfld_set_mode(form_ptr, D_SIZE, 0, FI_REVIEW);
     FIg_display   (form_ptr, D_SIZE );
     /* Below added for CR179700399 - link diameter with depth/width */
     FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, W_SIZE );
     FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
     FIg_display   (form_ptr, CORNER_RADIUS);
     FIfld_get_value( form_ptr,EQUIV_DIAM, row, col,
                                               &dEquiDiam,&sel_flag,&r_pos);
     /* Reset auto width/depth computation */

     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr);

     break;

    case CIRCULAR_SHAPE:
     /* Below modified for CR179700399 - link diameter with depth/width */
     dValue = (double) VR_CORNER;
     int_conv = VR_CORNER;
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.value.att_exp = dValue;
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
      /* added for TR179800380 */
     if(noncirc_width > 0.0)
     {
	FIfld_set_value( form_ptr, W_SIZE, row, col, noncirc_width, sel_flag );
     }
     if(noncirc_depth > 0.0)
     {
	FIfld_set_value( form_ptr, D_SIZE, row, col, noncirc_depth, sel_flag );
     }
      /* added for TR179800380 */
     noncirc_depth = -1.;
     noncirc_width = -1.;

	/* Modify form for Corner shape */

     FIg_erase( form_ptr, CIRCULAR_SHAPE );
     FIg_erase( form_ptr, RECTANGULAR_SHAPE );
     FIg_erase( form_ptr, OVAL_SHAPE );
     FIg_display(form_ptr, RADIUS_SHAPE );

	/* needs for depth or corner radius */
     FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, D_SIZE );
     /* Below added for CR179700399 - link diameter with depth/width */
     FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, W_SIZE );
     FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_INSERT);
     FIg_display   (form_ptr, CORNER_RADIUS);
     /* Reset auto width/depth computation */

     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr);

     break;
    case RADIUS_SHAPE:
     dValue = (double) VR_RECT;
     int_conv = VR_RECT; /* 179700399 */
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.value.att_exp = dValue;
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
      /* added for TR179800380 */
     noncirc_depth = -1.;
     noncirc_width = -1.;

	/* Modify form for Rectangle shape */

     FIg_erase( form_ptr,  RADIUS_SHAPE );
     FIg_erase( form_ptr,  CIRCULAR_SHAPE );
     FIg_erase( form_ptr,  OVAL_SHAPE );
     FIg_display( form_ptr, RECTANGULAR_SHAPE );

	/* needs for depth */
     FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, D_SIZE );
     /* Below added for CR179700399 - link diameter with depth/width */
     FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, W_SIZE );

	/* no needs for corner radius */
     FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
     FIg_display   (form_ptr, CORNER_RADIUS);
     /* Reset auto width/depth computation */

     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr);

     break;

    case MAX_VELOCITY:

      NbAttr = 1;
      strcpy(ListAttr[0].name, VR_N_MAX_VELOC_DB);
      ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;
      /* BRUNO update equiv diam attribute*/
      /* Below added for CR179700399 - link diameter with depth/width */
       FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
				(unsigned char *) tmpText, &sel_flag, &r_pos );
      if(!strncmp (tmpText,"Velocity",8))
      { IGRdouble dAirFlow, dEquiDiam;
	/* get air flow */
    	FIfld_get_value(form_ptr,AIR_FLOW,row,col,&dAirFlow,&sel_flag,&r_pos );

	/*A convert Velocity from fpm to fps	*/
	if ( VRenq_proj_units() == VR_IMPERIAL_UNITS )
			dValue = dValue/60;

	/* recompute Equiv diam */
	VREquiDiamFV ( dAirFlow, dValue, &dEquiDiam );
        /* Below added for CR179700399 - link diameter with depth/width */
	/* set equiv diam in the form */
	FIfld_set_value( form_ptr, EQUIV_DIAM, row, col, dEquiDiam, sel_flag );
        FIg_display   (form_ptr, EQUIV_DIAM);
        strcpy(ColAttr.name, VR_N_SHAPE_IN);

        status =
           om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
        as$status( action = RET_STATUS );
        
        int_conv = (int)ColAttr.desc.value.att_exp;

        status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
      }
     break;

    case FRICTION:

      NbAttr = 1;
      strcpy(ListAttr[0].name, VR_N_FRICTION_FACT_DB);
      ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
      /* BRUNO update equiv diam attribute*/
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;

      FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
				(unsigned char *) tmpText, &sel_flag, &r_pos );
      if(!strncmp (tmpText,"Friction",8))
      { IGRdouble dAirFlow, dEquiDiam;
	/* get air flow */
    	FIfld_get_value(form_ptr,AIR_FLOW,row,col,&dAirFlow,&sel_flag,&r_pos );

	/*A convert Velocity from fpm to fps	*/
	/* recompute Equiv diam */
	VREquiDiamFF ( dAirFlow, dValue, &dEquiDiam );

	/* set equiv diam in the form */
	FIfld_set_value( form_ptr, EQUIV_DIAM, row, col, dEquiDiam, sel_flag );
        /* Below added for CR179700399 - link diameter with depth/width */
        FIg_display   (form_ptr, EQUIV_DIAM);
        strcpy(ColAttr.name, VR_N_SHAPE_IN);

        status =
           om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
        as$status( action = RET_STATUS );
        
        int_conv = (int)ColAttr.desc.value.att_exp;

        status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
      }
     break;

     case AIR_FLOW:

      NbAttr = 1;
      strcpy(ListAttr[0].name, VR_N_FLOW_RATE_DB);
      ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;

      /* BRUNO update equiv diam attribute */
       /* Below modified for CR179700399 - link diameter with depth/width */
       FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
				(unsigned char *) tmpText, &sel_flag, &r_pos );
      if(!strncmp (tmpText,"Velocity",8))
      { IGRdouble dVelocity, dEquiDiam;

	/* get air velocity */
	FIfld_get_value(form_ptr,MAX_VELOCITY,row,col,&dVelocity,&sel_flag,&r_pos );

	if ( VRenq_proj_units() == VR_IMPERIAL_UNITS )
			dVelocity = dVelocity/60;
	/* recompute Equiv diam */
	VREquiDiamFV ( dValue, dVelocity, &dEquiDiam );

	/* set equiv diam in the form */
	FIfld_set_value( form_ptr, EQUIV_DIAM, row, col, dEquiDiam, sel_flag );

      }
      /* Below added for CR179700399 - link diameter with depth/width */
      else
      { IGRdouble dFriction, dEquiDiam;

	/* get air velocity */
	FIfld_get_value(form_ptr,FRICTION,row,col,&dFriction,&sel_flag,&r_pos );

	/* recompute Equiv diam */
	VREquiDiamFF ( dValue, dFriction, &dEquiDiam );

	/* set equiv diam in the form */
	FIfld_set_value( form_ptr, EQUIV_DIAM, row, col, dEquiDiam, sel_flag );

      }
      FIg_display   (form_ptr, EQUIV_DIAM);
      strcpy(ColAttr.name, VR_N_SHAPE_IN);

      status =
        om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
      as$status( action = RET_STATUS );
        
      int_conv = (int)ColAttr.desc.value.att_exp;

      status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);

     break;

    case DUCT_THICK:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_DUCT_THICK_DB);
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
     break;

    case MAX_WIDTH:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_MAX_DEPTH_DB);
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
     /*NEWADD Correction related to CR179700399 included
     with fix for TR179800380 */
     ListAttr[0].desc.value.att_exp = dValue;
      noncirc_depth = -1.;
      noncirc_width = -1.;

        strcpy(ColAttr.name, VR_N_SHAPE_IN);
        status =
          om$send( msg = message ACrg_collect.ACget_named_attribute
                        ( &retmsg, &ColAttr ),
                      targetid = me->SysId.objid,
                      targetos = me->SysId.osnum );
          as$status( action = RET_STATUS );

          int_conv = (int)ColAttr.desc.value.att_exp;
          status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,
                               &dValue,&NbAttr,&ListAttr[0]);

     break;

    case DUCT_MATER:
     NbAttr = 2;
     strcpy(ListAttr[0].name, VR_N_DUCT_MATERIAL_AN);

	 // added for CR179900696
     // Call this function to update the Material Thickness...from db
     VRUpdMaterial_InsulationThickness( form_ptr, TRUE, szText, DUCT_THICK );

     FIg_get_value( form_ptr, DUCT_THICK, &dValue );

     strcpy(ListAttr[1].name, VR_N_DUCT_THICK_DB);
     ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
     ListAttr[1].desc.value.att_exp = dValue;

     break;

    case SYSTEM:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_SYST_NAME_AN);
     break;

    case ZONE:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_ZONE_AN);
     break;
     
    case INSULA_MATER:
     NbAttr = 2;
     strcpy(ListAttr[0].name, VR_N_INSUL_TYPE_AN);

	 // added for CR179900696
     // Call this function to update the Material Thickness...from db
     VRUpdMaterial_InsulationThickness( form_ptr, FALSE, szText, INSULA_THICK );

     FIg_get_value( form_ptr, INSULA_THICK, &dValue );
     strcpy(ListAttr[1].name, VR_N_INSUL_THK_DB);
     ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
     ListAttr[1].desc.value.att_exp = dValue;

     {
	 IGRdouble	dACST = 0.0;
	 IGRdouble 	dAcousticThickness=0.0, dThermalThickness=0.0;

	 FIg_get_value( form_ptr, ACOUSTIC_THICK, &dAcousticThickness );

	 if( dAcousticThickness > 0.0 )
	   dACST = dAcousticThickness + dValue;
	 FIg_set_value( form_ptr, ACST, dACST );
     }
     break;

    case INSULA_THICK:
    {
	 IGRdouble	dACST = 0.0;
	 IGRdouble 	dAcousticThickness=0.0, dThermalThickness=0.0;

	 NbAttr = 1;
	 strcpy(ListAttr[0].name, VR_N_INSUL_THK_DB);
	 ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
	 FIg_get_value( form_ptr, ACOUSTIC_THICK, &dAcousticThickness );

	 if( dAcousticThickness > 0.0 )
	 {
	   FIg_get_value( form_ptr, INSULA_THICK, &dThermalThickness );
	   dACST = dAcousticThickness + dThermalThickness;
	 }
	 FIg_set_value( form_ptr, ACST, dACST );
    }
    break;

	/* added for CR179901312 */
    case ACOUSTIC_MATERIAL:
     NbAttr = 2;
     strcpy(ListAttr[0].name, VR_N_ACST_INSUL_TYPE_AN);

	 // added for CR179900696
     // Call this function to update the Acoustic Thickness...from db
     VRUpdMaterial_InsulationThickness( form_ptr, FALSE, szText, 
					ACOUSTIC_THICK );

     FIg_get_value( form_ptr, ACOUSTIC_THICK, &dValue );
     strcpy(ListAttr[1].name, VR_N_ACST_INSUL_THK_DB);
     ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
     ListAttr[1].desc.value.att_exp = dValue;

     {
	 IGRdouble	dACST = 0.0;
	 IGRdouble 	dThermalThickness=0.0;

	 if( dValue > 0.0 )
	 {
	   FIg_get_value( form_ptr, INSULA_THICK, &dThermalThickness );
	   dACST = dValue + dThermalThickness;
	 }
	 FIg_set_value( form_ptr, ACST, dACST );
     }
     break;

    case ACOUSTIC_THICK:
    {
	 IGRdouble	dACST = 0.0;
	 IGRdouble 	dAcousticThickness=0.0, dThermalThickness=0.0;

	 NbAttr = 1;
	 strcpy(ListAttr[0].name, VR_N_ACST_INSUL_THK_DB);
	 ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
	 FIg_get_value( form_ptr, ACOUSTIC_THICK, &dAcousticThickness );

	 if( dAcousticThickness > 0.0 )
	 {
	   FIg_get_value( form_ptr, INSULA_THICK, &dThermalThickness );
	   dACST = dAcousticThickness + dThermalThickness;
	 }
	 FIg_set_value( form_ptr, ACST, dACST );
    }
    break;

    case GAP:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_CP_OFFSET_DB);
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
     break;

    case UNIT_NUMBER:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_UNIT_AN);
     break;

    case PID_SCALE:
     NbAttr = 1;
     strcpy( ListAttr[0].name, VR_N_PID_SCALE_DB );
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
     break;

    case CORNER_RADIUS:
      NbAttr = 1;
      /* added for TR179800380 */
        strcpy(ListAttr[0].name, VR_N_CORN_RAD_DB);
        ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
      noncirc_depth = -1.;
      noncirc_width = -1.;
      if ( dValue > 0 )
       {
        /* Below added for CR179700399 - link diameter with depth/width */
        /* Get width from collection */
        strcpy(ColAttr.name, VR_N_WIDTH1_DB);
	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );
        dwidth = ColAttr.desc.value.att_exp;
        if(dValue > (0.5 * dwidth))
        {
           FIfld_set_text(  form_ptr, MESSAGE, row, col,  
     		         " Corner Radius greater than 1/2 width ",sel_flag );
        }
        /* Get width from collection */
        strcpy(ColAttr.name, VR_N_DEPTH1_DB);
	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );
        ddepth = ColAttr.desc.value.att_exp;
        if(dValue > (0.5 * ddepth))
        {
           FIfld_set_text(  form_ptr, MESSAGE, row, col,  
     		         " Corner Radius greater than 1/2 depth ",sel_flag );
        }


       }
      else
       {
        FIfld_set_text(  form_ptr, MESSAGE, row, col,  
     		         " Corner Radius Should be Greater than 0 ",sel_flag );

        /* Get value from collection */
        strcpy(ColAttr.name, VR_N_CORN_RAD_DB);
        ColAttr.desc.type = AC_ATTRIB_DOUBLE;
        
        /* Initialize Corner radius */

        ColAttr.desc.value.att_exp = 1.0;
  
	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );

        FIfld_set_value( form_ptr, CORNER_RADIUS, row, col,  
      		   	 ColAttr.desc.value.att_exp, 
			 sel_flag );

       }
       /* Below added for CR179700399 - link diameter with depth/width */
        strcpy(ColAttr.name, VR_N_SHAPE_IN);

        status =
        om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
        as$status( action = RET_STATUS );
        
        int_conv = (int)ColAttr.desc.value.att_exp;

        status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);

     break;

    case W_SIZE:
                /* added for TR179800380 */
                noncirc_depth = -1.;
                noncirc_width = -1.;
                if ( dValue > 0 )

                     NbAttr = 0;      /* added for TR179800380 */

                else
                {
                     /* added for TR179800380 */
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
                                   ListAttr[0].desc.value.att_exp,sel_flag);
                     dValue = ListAttr[0].desc.value.att_exp;
                }
                /* added for TR179800380 */
                strcpy(ColAttr.name, VR_N_SHAPE_IN);
                status =
                      om$send( msg = message ACrg_collect.ACget_named_attribute
                        ( &retmsg, &ColAttr ),
                      targetid = me->SysId.objid,
                      targetos = me->SysId.osnum );
                as$status( action = RET_STATUS );

                /* added for TR179800380 */
                int_conv = (int)ColAttr.desc.value.att_exp;

                /* added for TR179800380 */
                   status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,
                               &dValue,&NbAttr,&ListAttr[0]);

     break;

    case D_SIZE:
      /* added for TR179800380 */
     noncirc_depth = -1.;
     noncirc_width = -1.;

     if( dValue > 0)
     {
       NbAttr = 0;      /* added for TR179800380 */
     }
     else
     {
           NbAttr = 0;      /* added for TR179800380 */
           FIfld_set_text(  form_ptr, MESSAGE, row, col,  
        		       " D Should be greater than 0", sel_flag );

           /* get depth from collection */
           strcpy(ColAttr.name, VR_N_DEPTH1_DB);

           status =
           om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
           as$status( action = RET_STATUS );

           FIfld_set_value(  form_ptr, D_SIZE, row, col,  
       		   	     ColAttr.desc.value.att_exp, 
		  	     sel_flag );
     }
     strcpy(ColAttr.name, VR_N_SHAPE_IN);

     status =
        om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
     as$status( action = RET_STATUS );
        
     int_conv = (int)ColAttr.desc.value.att_exp;

      /* added for TR179800380 */
     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
     break;

    case THROAT_RADIUS:
      if ( dValue > 0 )
       {
        NbAttr = 1;
        strcpy(ListAttr[0].name, VR_N_THROAT_DB);
        ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
       }
      else
       {
        FIfld_set_text(  form_ptr, MESSAGE, row, col,  
     		         " Throat Radius Should be Greater than 0 ",sel_flag );

        /* Get value from collection */
        strcpy(ColAttr.name, VR_N_THROAT_DB);

	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );

        FIfld_set_value( form_ptr, THROAT_RADIUS, row, col,  
      		   	 ColAttr.desc.value.att_exp, 
			 sel_flag );
       }
     break;

    case TRANS_LENGTH: 
      if ( dValue > 0 )
       {
        NbAttr = 1;
        strcpy(ListAttr[0].name, VR_N_TRANS_L_DB);
        ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
       }
      else
       {
        FIfld_set_text( form_ptr, MESSAGE, row, col,  
     		        " Trans Length Should be Greater than 0 ", sel_flag );

        strcpy(ColAttr.name, VR_N_TRANS_L_DB);

	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );

        FIfld_set_value( form_ptr, TRANS_LENGTH, row, col,  
      		   	 ColAttr.desc.value.att_exp, 
			 sel_flag );
       }
     break;
     /* Below added for CR179700399 - link diameter with depth/width */

     case SIZE_COMP_METHOD:
             dValue = 0;
             NbAttr = 0;
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;

     FIfld_get_text( form_ptr, SIZE_COMP_METHOD, row, col, MAX_FIELD,
                                (unsigned char *) tmpText, &sel_flag, &r_pos );

     if(!strncmp(tmpText,"Enter ",6))
     {
       FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
       FIg_display( form_ptr, W_SIZE);
     }
     strcpy(ColAttr.name, VR_N_SHAPE_IN);

     status =
     om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
     as$status( action = RET_STATUS );
        
     int_conv = (int)ColAttr.desc.value.att_exp;

     status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
     break;
   case FI_CANCEL:     /* EXIT_NO_SAVE */
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;
      /*A free the unused ids */
      status =
      om$send ( msg     = message VRActParam.VRUnLockId(),
			targetid = my_id );
      as$status();

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
      me->delete_flag = 1;			

      status = om$send ( targetid = my_id,
			  msg     = message VRHvpara.delete( 0 ) );
      return ( status );

    case FI_RESET:    /* RESET_VALUES */
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;

      /* -- Forget all changes -- */
     /* Below added for CR179800380 - reset width/depth */
     FIfld_set_mode(form_ptr, D_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, D_SIZE );
     FIfld_set_mode(form_ptr, W_SIZE, 0, FI_INSERT);
     FIg_display   (form_ptr, W_SIZE );
      status =
      om$send ( msg   = message VRHvpara.VRDeleteAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );
      as$status( action = RET_STATUS );

      /* -- Reinitialize the working collections -- */
      status =
      om$send ( msg   = message VRHvpara.VRInitAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );
      as$status( action = RET_STATUS );

      /* TR179603395 law-17Jan97 */
      status = om$send( msg      = message VRActParam.VRDispForm
                                ( VR_SYSTEM_ATTR ), targetid = my_id );
      as$status( action = RET_STATUS );

       status =
      om$send( msg      = message VRActParam.VRUpdSysForm (),
               targetid = my_id );
      as$status( action = RET_STATUS );

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
/*      FIg_display( form_ptr, 85 );  KLUDGE to miss FB bug */
      return OM_S_SUCCESS;

   case FI_EXECUTE:      /* STORE_VALUES */
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;

	me->bLineNumUsed = FALSE;
      /* if shape is circular, store width/depth */
       /* Below added for CR179700399 - link diameter with depth/width */
        strcpy(ColAttr.name, VR_N_SHAPE_IN);

	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );
        
        int_conv = (int)ColAttr.desc.value.att_exp;

        /* Changed for coordination with sketch form - TR179801054 */
        NbAttr = 0;
        status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
        {
          /* Added EQUIV_DIAM for CR179801061 */
          NbAttr = 6;  // TR179900568 - NbAttr changed from 5 to 6 
          FIfld_get_value(form_ptr,D_SIZE,row,col,&ddepth,&sel_flag,&r_pos );
    	  FIfld_get_value(form_ptr,W_SIZE,row,col,&dwidth,&sel_flag,&r_pos );
    	  FIfld_get_value(form_ptr,EQUIV_DIAM,row,col,&dEquiDiam,&sel_flag,
                                                                     &r_pos );
	  /** TR179900568 **/
	  FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
                                (unsigned char *) tmpText, &sel_flag, &r_pos );
          __DBGpr_str( " sizing method ",tmpText);

          strcpy( ListAttr[0].name , VR_N_DEPTH1_DB );
          strcpy( ListAttr[1].name , VR_N_DEPTH2_DB );
          strcpy( ListAttr[2].name , VR_N_WIDTH1_DB );
          strcpy( ListAttr[3].name , VR_N_WIDTH2_DB );
          strcpy( ListAttr[4].name , VR_N_EQUIV_DIA_DB );
	  /** TR179900568 **/
	  strcpy( ListAttr[5].name , VR_N_SIZE_METHOD_AN );

          ListAttr[0].desc.value.att_exp = ddepth; 
          ListAttr[1].desc.value.att_exp = ddepth; 
          ListAttr[2].desc.value.att_exp = dwidth; 
          ListAttr[3].desc.value.att_exp = dwidth; 
          ListAttr[4].desc.value.att_exp = dEquiDiam; 
	  /** TR179900568 **/
	  strcpy(ListAttr[5].desc.value.att_txt , tmpText);

          ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[2].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[3].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[4].desc.type = AC_ATTRIB_DOUBLE;
	  /** TR179900568 **/
	  ListAttr[5].desc.type = AC_ATTRIB_TEXT;

          status =
          VR$ModifyCollection(
		 	p_msg 			= &retmsg,
			Operation 		= VR_UPDATE_COLL,
			p_ParamsListToModify 	= ListAttr,
			NbParamsToModify 	= NbAttr,
			p_OutputCollectionId 	= &me->SysId );
        }

      /*
       * Calling this function to move the "acst" parameter into Active System 
       * Parameters collection. To remove the "acst" from the Active User 
       * Parameters collection. Since the files created using the older version
       * of the software would contain this attribute, those needs to be 
       * deleted. Alwin for CR179901661
       */
      status = VRUpdate_ACST_User_Param( form_ptr, &me->UsrId, &me->SysId );

      /* -- Store the active parameters -- */
      VR$active_params(	operation	= VR_REPLACE,
			update_flag	= VR_NOUPDATE,
                        VRproduct       = VR_HVAC,
    			act_param_id	= &(me->SysId),
    			status		= status );
      as$status( action = RET_STATUS );

      ex$message(msgnumb=VR_S_ValuesStored,field=ERROR_FIELD);
      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
		
      /* -- Reinitialize the working collections -- */
      status = om$send ( msg = message VRHvpara.VRInitAttr
								( VR_SYSTEM_ATTR | VR_USER_ATTR ),
					   targetid = my_id );

      return status;
     
   case FI_ACCEPT:        /* EXIT_AND_STORE */
      /* added for TR179800380 */
      noncirc_depth = -1.;
      noncirc_width = -1.;
	me->bLineNumUsed = FALSE;

      /* if shape is circular, store width/depth */
      /* Below added for CR179700399 - link diameter with depth/width */

        strcpy(ColAttr.name, VR_N_SHAPE_IN);

	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );
        
        int_conv = (int)ColAttr.desc.value.att_exp;

        /* Changed for coordination with sketch form - TR179801054 */

        NbAttr = 0;
        status = VRHvupd_wd(form_ptr,int_conv,&width_val,&depth_val,&dValue,
                                                  &NbAttr,&ListAttr[0]);
        
        {
          /* Added EQUIV_DIAM for CR179801061 */
          NbAttr = 6; /* TR179900568 - NbAttr changed from 5 to 6 */
          FIfld_get_value(form_ptr,D_SIZE,row,col,&ddepth,&sel_flag,&r_pos );
    	  FIfld_get_value(form_ptr,W_SIZE,row,col,&dwidth,&sel_flag,&r_pos );
    	  FIfld_get_value(form_ptr,EQUIV_DIAM,row,col,&dEquiDiam,&sel_flag,
                                                                     &r_pos );
	  /** TR179900568 **/
          FIfld_get_text( form_ptr, SIZE_METHOD, row, col, MAX_FIELD,
				(unsigned char *) tmpText, &sel_flag, &r_pos );

          strcpy( ListAttr[0].name , VR_N_DEPTH1_DB );
          strcpy( ListAttr[1].name , VR_N_DEPTH2_DB );
          strcpy( ListAttr[2].name , VR_N_WIDTH1_DB );
          strcpy( ListAttr[3].name , VR_N_WIDTH2_DB );
          strcpy( ListAttr[4].name , VR_N_EQUIV_DIA_DB );
	  /** TR179900568 **/
	  strcpy( ListAttr[5].name , VR_N_SIZE_METHOD_AN );

          
          ListAttr[0].desc.value.att_exp = ddepth; 
          ListAttr[1].desc.value.att_exp = ddepth; 
          ListAttr[2].desc.value.att_exp = dwidth; 
          ListAttr[3].desc.value.att_exp = dwidth; 
          ListAttr[4].desc.value.att_exp = dEquiDiam; 
	  /** TR179900568 **/
	  strcpy(ListAttr[5].desc.value.att_txt , tmpText);

          ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[2].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[3].desc.type = AC_ATTRIB_DOUBLE;
          ListAttr[4].desc.type = AC_ATTRIB_DOUBLE;
	  /** TR179900568 **/
	  ListAttr[5].desc.type = AC_ATTRIB_TEXT;

          status =
          VR$ModifyCollection(
		 	p_msg 			= &retmsg,
			Operation 		= VR_UPDATE_COLL,
			p_ParamsListToModify 	= ListAttr,
			NbParamsToModify 	= NbAttr,
			p_OutputCollectionId 	= &me->SysId );
        }

       // Calling this function would update the "acst" User Parameter
       status = VRUpdate_ACST_User_Param( form_ptr, &me->UsrId, &me->SysId );

       /* -- Store the active parameters -- */
       VR$active_params(	operation	= VR_REPLACE,
				update_flag	= VR_NOUPDATE,
                                VRproduct       = VR_HVAC,
				act_param_id	= &(me->SysId),
				status		= status );
       as$status();

      /* -- Reinitialize the working collections -- */
      status = om$send ( msg = message VRHvpara.VRInitAttr
		      ( VR_SYSTEM_ATTR | VR_USER_ATTR ),
		     targetid = my_id );

       ex$message(msgnumb=VR_S_ValuesStored,field=ERROR_FIELD);
       me->delete_flag = 1;

       /* forget about this working collection */
       me->SysId.objid = NULL_OBJID;

       status =
       om$send ( msg     = message VRHvpara.delete( 0 ),
			targetid = my_id );

       return status;

     case LOAD_BUTTON:
       FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
      return OM_S_SUCCESS;

   case HVUSER_ATTR_BUTTON: /* CR179800553 */

	status =
	om$send( msg = message VRActParam.VRUpdUsrForm (),
	      	    	  targetid = my_id );
       	as$status( action = RET_STATUS );
	status = om$send( msg      = message VRActParam.VRDispForm
				( VR_USER_ATTR ),
	      	    	  targetid = my_id );
       	as$status( action = RET_STATUS );
	break;

     default:
	/*"gadget_label %d unknown\n", gadget_label */
     break;

   } /* switch on gadget label */

   /* ----------------------------------------------- */
   /* -- Update Collection with modified attribute -- */
   /* ----------------------------------------------- */
   /* Below modified for CR179700399 - link diameter with depth/width */
   if(NbAttr > 0)
   {
	status =
	om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ListAttr[0] ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
       	as$status( action = RET_STATUS );
	if (ListAttr[0].desc.type == AC_ATTRIB_TEXT)
	{
		strcpy (ListAttr[0].desc.value.att_txt, szText );
	}
	else if (ListAttr[0].desc.type == AC_ATTRIB_DOUBLE)
	{
		ListAttr[0].desc.value.att_exp = dValue;
	}
	else return OM_S_SUCCESS;

        status = VR$ModifyCollection(
		 	p_msg 			= &retmsg,
			Operation 		= VR_UPDATE_COLL,
			p_ParamsListToModify 	= ListAttr,
			NbParamsToModify 	= NbAttr,
			p_OutputCollectionId 	= &me->SysId );
  }
  return status;
  } /* if MAIN form */

 else if ( form_ptr == me->form_ptr[SUB] )
  {
    form_mode = VR_USER_MODE;

  switch ( gadget_label )
  {

    case USER_ATTR_FLD:     /* Sequenced to     */

          /*|Get the text string */

      col = 1;
      status = FIfld_get_text(  form_ptr, gadget_label,  row, col, MAX_FIELD, 
				(unsigned char *) szText, &sel_flag, &r_pos );
       /*" 2nd col is %s\n", szText */

      break;

    case FI_CANCEL:     /* Member of group   */

          /*| Erase and Reset the displayed form */
        if ( form_ptr != NULL )
           status = FIf_erase( form_ptr );

	if ( status == FI_SUCCESS )
	{
	 /*| Set button to off */
         FIg_set_state_off( me->form_ptr[MAIN], HVUSER_ATTR_BUTTON );
         FIg_set_notify_on( me->form_ptr[MAIN], HVUSER_ATTR_BUTTON );
         FIg_set_state_off( form_ptr, FI_CANCEL );

	}
	else
	{
	 /*| got bad return from erase_form */
         as$status( action = RET_STATUS );
	}
        break;

    case FI_EXECUTE:     /* Member of group   */
    case FI_ACCEPT:     /* Member of group   */

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
                          VRproduct             = VR_HVAC,
	    		  act_param_id		= &(me->UsrId),
			  mode			= VR_USER_MODE,
	    		  status		= status );
        as$status( action = RET_STATUS );

        FIg_set_state_off( form_ptr, gadget_label );

	/* -- Reinitialize the working collections -- */
	status =
	om$send ( msg   = message VRHvpara.VRInitAttr( VR_USER_ATTR ),
		targetid = my_id );
	as$status(action = RET_STATUS);
        /*| Erase the displayed form */
	if ( gadget_label ==  FI_ACCEPT )
	{
		status = FIf_erase( form_ptr );
 		/*| Set button to off */
       		FIg_set_state_off( me->form_ptr[MAIN], HVUSER_ATTR_BUTTON );
       		FIg_set_notify_on( me->form_ptr[MAIN], HVUSER_ATTR_BUTTON );
	}

       break;

  } /* END switch ( gadget_label ) */

  } /* me->form_ptr[SUB] */	
else
 {
   /*| Unknow form_ptr */
   return ( OM_E_INVARG );
 }
   return (OM_S_SUCCESS);
} /* notification action */

