/* $Id: VRRwpara.sl,v 1.3 2001/02/20 01:14:41 build Exp $  */

/***********************************************************************
 * I/ROUTE
 *
 * File:        vrpara/VRRwpara.sl
 *
 * Description:
 *	Specification file for the command object Display RWAY Parameters.
 *
 * Dependencies:
 *
 * Log History:
 *	$Log: VRRwpara.sl,v $
 *	Revision 1.3  2001/02/20 01:14:41  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 16:38:57  anand
 *	SP Merge
 *	
# Revision 1.2  2000/05/11  14:53:20  pinnacle
# Replaced: route/vrpara/VRRwpara.sl for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/10  16:01:00  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.6  2000/04/05  22:23:56  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by apazhani for route
#
# Revision 1.5  1999/04/22  08:24:48  pinnacle
# Replaced: vrpara/VRRwpara.sl for: CR 179900491 by aharihar for route
#
# Revision 1.4  1999/04/17  13:30:30  pinnacle
# Replaced vrpara/VRRwpara.sl for: CR 179900491 by aharihar for route
#
# Revision 1.3  1998/08/05  15:59:40  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by lawaddel for route
#
# Revision 1.2  1998/06/26  22:57:02  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/01/14  18:54:44  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.3  1997/02/14  20:56:30  pinnacle
# Replaced: vrpara for:  by lawaddel for route
#
# Revision 1.2  1996/08/19  09:19:40  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/06/06  14:29:56  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by hverstee for route240
#
# Revision 1.4  1996/02/28  21:36:22  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/17  14:47:46  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by r240_int for route240
#
# Revision 1.2  1995/12/08  21:23:40  pinnacle
# Replaced: vrpara/VRRwpara.sl for:  by r240_int for route240
#
 *
 * History:
 *	08/19/94	  MM	Modified the Form notification due to
 *					the addition of a new shape.
 *	12/06/95	tlb	Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      01/17/97        law     Restore units right of boxes TR179603395
 *      12/18/97        law     Added new shapes - CR179309874
 *      06/24/98        law     TR179801141 Add vendor to rway forms
 *      07/25/98        law     CR179801144 add tiers to rway forms
 *     April 1999      Anand    CR 179900491 - Variable tier spacing.
 *     04/05/2000      Alwin    Just to avoid a TR. Forcing the Caching update
 *      May 9 2k        Anand   Removed FIg_erase calls to Corner Radius related
 *                              fields for all Raceway forms - TR 179901473
 *	01/11/2001	Anand	Merging for Pload
 *
 ***********************************************************************/

/*---------------------
 * class specification area
 */

command_string       VRC_M_DisplayRwDgPr,0,VRDsRwDgPr
class                VRRwpara
super_class          VRActParam
/* product_name         "$SPXR" */
product_name         "$ROUTE"
command_table	     "route.cmd"

/*+cmd
  Command Object Class VRRwpara

  Superclass
      VRActParam

  Abstract
      This command object is for Display Raceway Design Parameters. This 
      displays the system and user attributes, and lets the user set them.

  Design Reference
      <Optional>

  Methods
      <Name>            <Public/Private>        <Description>

  Overridden Methods
     <Name>             <Description>

  Forms
     <Name>             <File>          <Description>
      VRRwDgPar				Form for Raceway design parameters.
      VRUserParam			For for manipulating User parameters.

  Notes/Remarks
      <Optional>

-cmd*/

specification

/* Added for CR 179900491 */
#include "VRRwDimen.h"

instance
{
    struct VRRwCptDetails	RcwyCptInfo;
}
/* Added for CR 179900491 */



implementation

#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
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

#include "HV_param.h"
#include "vrchgatt_pto.h"
#include "vrtools_pto.h"
#include "vrpdu_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "VRRwDimen.h"
#include "vrdbgmacros.h"
#include "VRRDBmac.h"
#include "VRRDBdef.h"

#define  AS_DEBUG 1

#define  MAX_FIELD 	 256

#define MAIN 0
#define SUB 1


from 	ACrg_collect	import 		ACget_named_attribute,
					ACset_list_attribute,
					ACadd_list_attribute;
from	ACncpx		import		ACgive_structure;

#ifndef vr_VRRwDimen_include
extern	IGRint		VRRw_dimen_fields();
#endif

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
 me->Product		= VR_CABLING;
 me->CommandName	= COMM_NAME_CABLE;
 me->form_name[MAIN] 	= "VRRwDgPar" ;
 me->form_name[SUB] 	= "VRUserParam" ;
}

/*********************************************************/

action VRUpdSysForm()
{
    /*A display the attributes in the Sys form */
    status = VRUpdALLSysForm( me->Product, me->form_ptr[MAIN], &me->SysId );
    as$status( action = RET_STATUS );

    /* TR179801141 */
    VRGetAttrFromDB ( me->form_ptr[MAIN], me->Product );

    /* Below lines added by Anand for CR 179900491 */
    {
	IGRint			proc_mode, shape_code, *active_cpt;
	IGRlong			retmsg;
	struct ACrg_coll	AttrList;

	/* First get shape from collection */
	strcpy(AttrList.name, VR_N_SHAPE_IN);
	status = om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &AttrList ),
		     targetid = me->SysId.objid,
		     targetos = me->SysId.osnum );
	as$status( action = RET_STATUS );
	shape_code	=	AttrList.desc.value.att_exp;

	/* Now call VRRw_dimen_fields with proc_mode=0 to populate the
	 * RcwyCptInfo structure. */
	proc_mode	=	0;
	active_cpt	=	NULL;
	status = VRRw_dimen_fields( me->form_ptr[MAIN], 0, NULL,
				    &me->ModuleInfo, 1, active_cpt, proc_mode,
				    shape_code, &me->RcwyCptInfo, &me->SysId );

	/* Finally, call VRRw_dimen_fields with proc_mode=1 to display the
	 * RcwyCptInfo structure on the form. */
	proc_mode	=	1;
	active_cpt	=	&proc_mode; /* The function was not implemented
					       keeping this command in mind.
					       Hence, in order to get matters
					       working, pass a pointer whose
					       contents is unity - Anand */
	status = VRRw_dimen_fields( me->form_ptr[MAIN], 0, NULL, 
				    &me->ModuleInfo, 1, active_cpt, proc_mode,
				    shape_code, &me->RcwyCptInfo, NULL );

    }
    /* Above lines added by Anand for CR 179900491 */

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

action form_notification( int form_label; int gadget_label;
			  double value; char * form_ptr )
{
  IGRchar		 szText[MAX_FIELD];
  IGRdouble	         dValue, max_width = 0;
 
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

  IGRlong                retmsg;
  struct GRid	my_grid;  /* CR179801144 */

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
  /* my_grid added for tier processing-CR179801144 */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
                   
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

    /* TR179801141 - Add vendor to rway forms */
    case RWAY_VNDR_CODE:

     NbAttr = 1;

     status = check_spec( &retmsg, VR_RWAY, szText, NULL );

     if( status != OM_S_SUCCESS )
     {
        FIfld_set_text( form_ptr, MESSAGE, 0, 0,
                        "Vendor Code not found in DB", sel_flag );
     }

     strcpy( ListAttr[0].name , VR_N_CLASS_AN );
     ListAttr[0].desc.type = AC_ATTRIB_TEXT;
	 __DBGpr_str( " New Vendor Code ", szText );

	 /* added to force the Cache Update. Alwin */
	 {
		IGRint				FootIndex;
		struct ret_struct	ParamAttr;

		/*C Get Old Vendor Code */
		status = 
		om$send( msg      = message ACncpx.ACgive_structure
					   ( (IGRint*)&retmsg, &FootIndex, VR_N_CLASS_AN,
						 &ParamAttr, &me->ModuleInfo),
				   targetid = me->SysId.objid,
				   targetos = me->SysId.osnum );

		__DBGpr_str( " Old Vendor Code ", ParamAttr.var.text_st.text_string );
		if( strcmp( szText, ParamAttr.var.text_st.text_string ) )
		{
		   IGRshort		SpecNum;

		   /* Get vendor number from rway_spec table */
		   status = VR$RDB_SNUM( p_nam = szText, p_num = &SpecNum );

		   VR$RDB_SET( p_msg = &retmsg, spec = SpecNum );
		   as$status( action = RET_STATUS );
		}
	 }
	 /* added to force the Cache Update */

     break;

    case CONST_STATUS:
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_CONSTR_STAT_AN );
     break;

    case APPROVAL_STAT:
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_APPRV_STAT_AN );
     break;

     /* Below modified for CR179309874 - added new raceway shapes */
    case ELLP_SHAPE:
     dValue = VR_RECT;
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
     FIg_display (form_ptr, RW_D_SIZE_DGTEXT);
     /* Modified for tier processing - CR179801144 */
     FIfld_set_mode(form_ptr, FRM_DEPTH_1, 0, FI_REVIEW);
     FIg_display (form_ptr, FRM_DEPTH_1); /* Added with CR179801144 */
     FIg_display (form_ptr, FRM_NO_TIER_1);
     FIg_display (form_ptr, FRM_TIER_SP_1);
     FIg_display (form_ptr, RW_N_TIER_TEXT);
     FIg_display (form_ptr, RW_SP_TIER_TEXT);
     if (VRenq_proj_units() == VR_IMPERIAL_UNITS)
     {
       FIg_display (form_ptr, RW_SP_TIER_TX_IN);
       FIg_display (form_ptr, RW_D_SIZE_DGTX_IN);
     }
     else
     {
       FIg_display (form_ptr, RW_SP_TIER_TX_MM);
       FIg_display (form_ptr, RW_D_SIZE_DGTX_MM);
     }
     FIg_erase( form_ptr, OVAL_SHAPE );
     FIg_erase( form_ptr, RADIUS_SHAPE );
     FIg_erase( form_ptr, CIRCULAR_SHAPE );
     FIg_erase( form_ptr, ELLP_SHAPE );
     FIg_display ( form_ptr, RECTANGULAR_SHAPE );
     break;

     /* Below modified for CR179309874 - added new raceway shapes */
    case RECTANGULAR_SHAPE:
     dValue = VR_OVAL;
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

     FIg_display (form_ptr, FRM_DEPTH_1);
     /* Modified for tier processing - CR179801144 */
     FIg_erase (form_ptr, FRM_NO_TIER_1);
     FIg_erase (form_ptr, FRM_TIER_SP_1);
     FIg_erase (form_ptr, RW_SP_TIER_TEXT);
     FIg_erase (form_ptr, RW_SP_TIER_TX_IN);
     FIg_erase (form_ptr, RW_SP_TIER_TX_MM);
     FIg_erase (form_ptr, RW_N_TIER_TEXT);

     FIg_display (form_ptr, RW_D_SIZE_DGTEXT);
     FIfld_set_mode(form_ptr, FRM_DEPTH_1, 0, FI_INSERT);
     FIg_display (form_ptr, FRM_DEPTH_1); /* Added with CR179801144 */
     if (VRenq_proj_units() == VR_IMPERIAL_UNITS)
     {
       FIg_display (form_ptr, RW_D_SIZE_DGTX_IN);
     }
     else
     {
       FIg_display (form_ptr, RW_D_SIZE_DGTX_MM);
     }

     FIg_erase( form_ptr, RADIUS_SHAPE );
     FIg_erase( form_ptr, CIRCULAR_SHAPE );
     FIg_erase( form_ptr, ELLP_SHAPE );
     FIg_erase ( form_ptr, RECTANGULAR_SHAPE );
     FIg_display( form_ptr, OVAL_SHAPE );
     break;

     /* Below modified for CR179309874 - added new raceway shapes */
    case OVAL_SHAPE:
     dValue = VR_CIRC;
     NbAttr = 1;

     /*    erase depth  */
      /* Modified for CR179801144 */
     FIg_erase (form_ptr, FRM_DEPTH_1);
     FIg_erase (form_ptr, RW_D_SIZE_DGTEXT);
     FIg_erase (form_ptr, RW_D_SIZE_DGTX_MM);
     FIg_erase (form_ptr, RW_D_SIZE_DGTX_IN);
     FIg_erase (form_ptr, RW_SP_TIER_TEXT);

     /* Below modified for CR179309874 - added new raceway shapes */
     FIg_erase( form_ptr, OVAL_SHAPE );
     FIg_erase( form_ptr, RECTANGULAR_SHAPE );
     FIg_erase( form_ptr, ELLP_SHAPE );
     FIg_erase( form_ptr, RADIUS_SHAPE );
     FIg_display ( form_ptr, CIRCULAR_SHAPE );

     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

     /* Below modified for CR179309874 - added new raceway shapes */
     break;
    case CIRCULAR_SHAPE :
     dValue = VR_CORNER;
     NbAttr = 1;
     /* Below modified for CR179801144 */
     FIg_display (form_ptr, FRM_DEPTH_1);
     FIg_display (form_ptr, RW_D_SIZE_DGTEXT);
     FIg_erase (form_ptr, RW_N_TIER_TEXT);
     FIg_erase (form_ptr, RW_SP_TIER_TEXT);
     if (VRenq_proj_units() == VR_IMPERIAL_UNITS)
       FIg_display (form_ptr, RW_D_SIZE_DGTX_IN);
     else
       FIg_display (form_ptr, RW_D_SIZE_DGTX_MM);

     /* Below modified for CR179309874 - added new raceway shapes */
     FIg_display ( form_ptr, CORNER_RADIUS );
     FIg_display ( form_ptr, CORNER_RADIUS_LBL );

     strcpy(ListAttr[0].name, VR_N_CORN_RAD_DB);
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

     status = om$send( msg = message ACrg_collect.ACget_named_attribute
                                                ( &retmsg, &ListAttr[0] ),
                                targetid = me->SysId.objid,
                                targetos = me->SysId.osnum );
     as$status();
     FIfld_set_value( form_ptr, CORNER_RADIUS, row, col,
                      ListAttr[0].desc.value.att_exp,0 );

     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

     FIg_erase( form_ptr, OVAL_SHAPE );
     FIg_erase( form_ptr, RECTANGULAR_SHAPE );
     FIg_erase ( form_ptr, ELLP_SHAPE );
     FIg_erase( form_ptr, CIRCULAR_SHAPE );
     FIg_display ( form_ptr, RADIUS_SHAPE );
     break;

    /* Below added for CR179309874 - added new raceway shapes */
    case CORNER_RADIUS :
     strcpy(ListAttr[0].name, VR_N_CORN_RAD_DB);
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
     NbAttr=1;

     if ( dValue > 0 )
     {
             ListAttr[0].desc.value.att_exp = dValue;
     }
     else
     {
             FIfld_set_text( form_ptr, MESSAGE, row, col,
                         " Corner Radius Should be Greater than 0 ",sel_flag );
             /* Get value from collection */
             status = om$send( msg = message ACrg_collect.ACget_named_attribute
                                                ( &retmsg, &ListAttr[0] ),
                                targetid = me->SysId.objid,
                                targetos = me->SysId.osnum );
             as$status();
             dValue = ListAttr[0].desc.value.att_exp;
             FIfld_set_value( form_ptr, CORNER_RADIUS, row, col,
                                                           dValue, sel_flag );
     }

     break;

    /* Below modified for CR179309874 - added new raceway shapes */
    case RADIUS_SHAPE :
     dValue = VR_ELLIPSE;
     NbAttr = 1;
     strcpy( ListAttr[0].name , VR_N_SHAPE_IN );
     ListAttr[0].desc.type = AC_ATTRIB_DOUBLE;

     /* Below modified for CR179309874 - added new raceway shapes */
     FIg_display (form_ptr, FRM_DEPTH_1);
     /* Modified for CR179801144 */
     FIg_display (form_ptr, RW_D_SIZE_DGTEXT);
     FIg_erase (form_ptr, RW_N_TIER_TEXT);
     FIg_erase (form_ptr, RW_SP_TIER_TEXT);
     if (VRenq_proj_units() == VR_IMPERIAL_UNITS) 
       FIg_display (form_ptr, RW_D_SIZE_DGTX_IN);
     else
       FIg_display (form_ptr, RW_D_SIZE_DGTX_MM); 

     /* Below modified for CR179309874 - added new raceway shapes */
     FIg_erase( form_ptr, OVAL_SHAPE );
     FIg_erase( form_ptr, RADIUS_SHAPE );
     FIg_erase( form_ptr, CIRCULAR_SHAPE );
     FIg_erase( form_ptr, RECTANGULAR_SHAPE );
     FIg_display ( form_ptr, ELLP_SHAPE );
     break;

    case DUCT_THICK:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_DUCT_THICK_DB);
     break;

    case MAX_WIDTH:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_MAX_DEPTH_DB);
     /*| MAX WIDTH is being stored and retrieved as MAX_DEPTH. This
         may require some looking at later :-)  jim p. */
     break;

    case DUCT_MATER:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_DUCT_MATERIAL_AN);
	/*| DUCT MATERIAL???? */
     break;

    case SYSTEM:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_SYST_NAME_AN);
     break;

    case ZONE:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_ZONE_AN);
     break;

    case GAP:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_CP_OFFSET_DB);
     break;

    case UNIT_NUMBER:
     NbAttr = 1;
     strcpy(ListAttr[0].name, VR_N_UNIT_AN);
     break;


     /* The following four case statements revamped for CR 179900491 */
    case FRM_WIDTH_1:
    case FRM_DEPTH_1:
    case FRM_NO_TIER_1:
    case FRM_TIER_SP_1:
 
     if( gadget_label == FRM_WIDTH_1 )
     {
	 /* gets the max_width from Database */
	 FIfld_get_value( form_ptr, MAX_WIDTH, row, col,
		 &max_width, &sel_flag, &r_pos );

	 if (dValue > max_width)
	 {
	     FIfld_set_text( form_ptr, MESSAGE,row,
		     col, "Width set to max_width", sel_flag );

	     dValue = max_width;
	     FIg_set_value(form_ptr, FRM_WIDTH_1, max_width);
	 }

	 if( dValue <= 0 )
	 {
	     FIfld_set_text(  form_ptr, MESSAGE, row, col,  
		     "Entered value should be greater than 0", sel_flag );

	     /* get width from collection */
	     strcpy(ColAttr.name, VR_N_WIDTH1_DB);

	     status =
	     om$send( msg = message ACrg_collect.ACget_named_attribute
							 ( &retmsg, &ColAttr ),
		 targetid = me->SysId.objid,
		 targetos = me->SysId.osnum );
	     as$status( action = RET_STATUS );


	     FIfld_set_value( form_ptr, FRM_WIDTH_1, row, col,  
		     ColAttr.desc.value.att_exp, sel_flag );
	 }
     }

     if( gadget_label == FRM_DEPTH_1 && dValue <= 0 )
     {
	 /* get depth from collection */
	 strcpy(ColAttr.name, VR_N_DEPTH1_DB);

	 status = om$send( msg = message ACrg_collect.ACget_named_attribute
							 ( &retmsg, &ColAttr ),
		      targetid = me->SysId.objid,
		      targetos = me->SysId.osnum );
	 as$status( action = RET_STATUS );

	 FIfld_set_value(  form_ptr, FRM_DEPTH_1, row, col,  
		 ColAttr.desc.value.att_exp, sel_flag );
     }

     /* get the shape from collection */
     strcpy(ColAttr.name, VR_N_SHAPE_IN);
     status =
     om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
     as$status( action = RET_STATUS );

     {
	 IGRint			proc_mode, shape_code, *active_cpt;

	 shape_code	=	(IGRint) ColAttr.desc.value.att_exp;
	 proc_mode	=	1;
	 active_cpt	=	&proc_mode; /* The function was not implemented
					       keeping this command in mind.
					       Hence, in order to get matters
					       working, pass a pointer whose
					       contents is unity - Anand */

	 status = VRRw_dimen_fields( me->form_ptr[MAIN], gadget_label, NULL, 
				     &me->ModuleInfo, 1, active_cpt,
				     proc_mode, shape_code,
				     &me->RcwyCptInfo, &me->SysId );

     }
     break;
     /* End of the four case statements revamped for CR 179900491 */

    case THROAT_RADIUS:
      if ( dValue > 0 )
       {
        NbAttr = 1;
        strcpy(ListAttr[0].name, VR_N_THROAT_DB);
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

   case FI_CANCEL:     /* EXIT_NO_SAVE */
      /*A free the unused ids */
      status =
      om$send ( msg     = message VRActParam.VRUnLockId(),
			targetid = my_id );
      as$status();

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
      me->delete_flag = 1;			

      status = om$send ( targetid = my_id,
			  msg     = message VRActParam.delete( 0 ) );
      return ( status );

    case FI_RESET:    /* RESET_VALUES */

      /* -- Forget all changes -- */
      status =
      om$send ( msg   = message VRRwpara.VRDeleteAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );
      as$status( action = RET_STATUS );

      /* -- Reinitialize the working collections -- */
      status =
      om$send ( msg   = message VRRwpara.VRInitAttr( VR_SYSTEM_ATTR ),
		targetid = my_id );
      as$status( action = RET_STATUS );

      /* TR179603395 law-17Jan97 */
      status = om$send( msg      = message VRActParam.VRDispForm
                                     ( VR_SYSTEM_ATTR ),  targetid = my_id );
      as$status( action = RET_STATUS );

      status =
      om$send( msg      = message VRActParam.VRUpdSysForm (),
               targetid = my_id );
      as$status( action = RET_STATUS );

      FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
      return OM_S_SUCCESS;

   case FI_EXECUTE:      /* STORE_VALUES */
   case FI_ACCEPT:       /* EXIT_AND_STORE */

        /* Below added for CR179309874 - added new raceway shapes */
        strcpy(ColAttr.name, VR_N_SHAPE_IN);
        status =
        om$send( msg = message ACrg_collect.ACget_named_attribute
			( &retmsg, &ColAttr ),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
        as$status( action = RET_STATUS );

	/* A lot of code common to the cases for FI_EXECUTE and FI_ACCEPT
	 * was removed and replaced by the following lines.
	 * 					- Anand for CR 179900491 */

	status = VRRw_dimen_fields( me->form_ptr[MAIN], 0, NULL,
				    &me->ModuleInfo, 1, NULL, 2,
				    (IGRint)ColAttr.desc.value.att_exp,
				    &me->RcwyCptInfo, &me->SysId );

	/* Above function call sets the width, depth, number of tiers and the
	 * tier spacing attributes to the green connect point. So, copy these
	 * values for the other connect point.		- Anand */

	{
	    IGRchar     AttrName_NoTier[25], AttrName_TierSp[25];

	    VR_Build_Tier_Str( 1, 0, AttrName_TierSp, NULL);
	    strcpy(ColAttr.name, AttrName_TierSp);
	    status = om$send( msg = message ACrg_collect.ACget_named_attribute
							 ( &retmsg, &ColAttr ),
			 targetid = me->SysId.objid,
			 targetos = me->SysId.osnum );
	    as$status( action = RET_STATUS );

	    VR_Build_Tier_Str( 2, 0, AttrName_TierSp, AttrName_NoTier);

	    strcpy( ListAttr[0].name , AttrName_TierSp );
	    ListAttr[0].desc.type = AC_ATTRIB_TEXT;
	    strcpy(ListAttr[0].desc.value.att_txt,ColAttr.desc.value.att_txt);

	    strcpy( ListAttr[1].name , AttrName_NoTier );
	    ListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
	    ListAttr[1].desc.value.att_exp = me->RcwyCptInfo.nb_tier;

	    strcpy( ListAttr[2].name , VR_N_WIDTH2_DB );
	    ListAttr[2].desc.type = AC_ATTRIB_DOUBLE;
	    ListAttr[2].desc.value.att_exp = me->RcwyCptInfo.width;

	    strcpy( ListAttr[3].name , VR_N_DEPTH2_DB );
	    ListAttr[3].desc.type = AC_ATTRIB_DOUBLE;
	    ListAttr[3].desc.value.att_exp = me->RcwyCptInfo.depth;
	}

	status =
	VR$ModifyCollection( p_msg                   = &retmsg,
			     Operation               = VR_UPDATE_COLL,
			     p_ParamsListToModify    = ListAttr,
			     NbParamsToModify        = 4,
			     p_OutputCollectionId    = &me->SysId );

	/* Above lines added by Anand for CR 179900491 */

	me->bLineNumUsed = FALSE;

	/* -- Store the active parameters -- */
	VR$active_params( operation	= VR_REPLACE,
			  update_flag	= VR_NOUPDATE,
			  VRproduct	= VR_CABLING,
			  act_param_id	= &(me->SysId),
			  status	= status );
	as$status( action = RET_STATUS );

	ex$message(msgnumb=VR_S_ValuesStored,field=ERROR_FIELD);

	if( gadget_label == FI_EXECUTE )
	{
	    /* -- Reinitialize the working collections -- */
	    status = om$send( msg = message VRRwpara.VRInitAttr(VR_SYSTEM_ATTR),
			 targetid = my_id );
	}
	else if( gadget_label == FI_ACCEPT )
	{
	    me->delete_flag = 1;
	    me->SysId.objid = NULL_OBJID;  /* forget about this working
					      collection */
	    status = om$send ( msg     = message VRActParam.delete( 0 ),
			      targetid = my_id );
	}

	return status;

     case LOAD_BUTTON:
     case MOD_LOAD_BUTTON:
       FIbtn_set_auto_pop_up_on( form_ptr, gadget_label );
       return OM_S_SUCCESS;

   case USER_ATTR_BUTTON:
	
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

   /* Below modified for CR179309874 - added new raceway shapes */
   if(NbAttr > 0)
   {
        status =
        om$send( msg = message ACrg_collect.ACget_named_attribute
                        ( &retmsg, &ListAttr[0] ),
                targetid = me->SysId.objid,
                targetos = me->SysId.osnum );
        as$status( action = RET_STATUS );

        /* Below modified for CR179309874 - added new raceway shapes */
	if (ListAttr[0].desc.type == AC_ATTRIB_TEXT)
	{
		strcpy (ListAttr[0].desc.value.att_txt, szText );
	}
	else if (ListAttr[0].desc.type == AC_ATTRIB_DOUBLE)
	{
                ListAttr[0].desc.value.att_exp = dValue;
        }
	else return OM_S_SUCCESS;
   }

  status =
  VR$ModifyCollection( 	p_msg 			= &retmsg,
			Operation 		= VR_UPDATE_COLL,
			p_ParamsListToModify 	= ListAttr,
			NbParamsToModify 	= NbAttr,
			p_OutputCollectionId 	= &me->SysId );

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
         FIg_set_state_off( me->form_ptr[MAIN], USER_ATTR_BUTTON );
         FIg_set_notify_on( me->form_ptr[MAIN], USER_ATTR_BUTTON );
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
		FIfld_get_text_length
			( form_ptr, USER_ATTR_FLD, row, 0, &length );
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
                          VRproduct             = VR_CABLING,
	    		  act_param_id		= &(me->UsrId),
			  mode			= VR_USER_MODE,
	    		  status		= status );
        as$status( action = RET_STATUS );

        FIg_set_state_off( form_ptr, gadget_label );

	/* -- Reinitialize the working collections -- */
	status =
	om$send ( msg   = message VRRwpara.VRInitAttr( VR_USER_ATTR ),
		targetid = my_id );
	as$status(action = RET_STATUS);
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
   /*| Unknow form_ptr */
   return ( OM_E_INVARG );
 }
   return (OM_S_SUCCESS);
} /* notification action */
