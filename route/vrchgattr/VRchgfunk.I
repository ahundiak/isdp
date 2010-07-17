/* $Id: VRchgfunk.I,v 1.3 2001/02/20 01:12:04 build Exp $  */

/* I/ROUTE
 *
 * File:        vrchgattr/VRchgfunk.I
 *
 * Description:
 *
 * 	This file contains the different functions necessary for the command
 *	Modify Component Design Parameters, such as Updating the System form,
 *	Updating the component., etc.
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRchgfunk.I,v $
 *	Revision 1.3  2001/02/20 01:12:04  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 22:40:10  anand
 *	SP merge
 *	
# Revision 1.4  2000/07/21  13:42:56  pinnacle
# Replaced: route/vrchgattr/VRchgfunk.I for:  by apazhani for Service Pack
#
# Revision 1.3  2000/07/13  22:53:00  pinnacle
# Replaced: route/vrchgattr/VRchgfunk.I for:  by apazhani for Service Pack
#
# Revision 1.2  2000/05/11  22:17:34  pinnacle
# Replaced: route/vrchgattr/VRchgfunk.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/10  16:04:00  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.8  2000/04/04  16:38:58  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by lawaddel for route
#
# Revision 1.7  2000/02/10  19:25:18  pinnacle
# (No comment)
#
# Revision 1.6  1999/11/05  19:58:42  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by lawaddel for route
#
# Revision 1.5  1999/09/07  22:48:54  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by aharihar for route
#
# Revision 1.4  1999/04/26  17:04:18  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for: CR 179900491 by aharihar for route
#
# Revision 1.3  1998/08/05  16:00:00  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by lawaddel for route
#
# Revision 1.2  1998/06/26  22:57:24  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/01/14  18:30:00  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by lawaddel for route
#
# Revision 1.3  1997/09/15  14:20:20  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by onayragu for route
#
# Revision 1.3  1997/09/09  20:35:06  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by lawaddel for route
#
# Revision 1.2  1997/09/04  22:38:24  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by onayragu for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/05/14  22:46:28  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by hverstee for route240
#
# Revision 1.5  1996/04/09  19:30:44  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by hverstee for route240
#
# Revision 1.4  1996/04/04  16:57:12  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by r240_int for route240
#
# Revision 1.3  1996/02/29  11:56:16  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  20:47:00  pinnacle
# Replaced: vrchgattr/VRchgfunk.I for:  by r240_int for route240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	-----------------------------------------------------------------------
 *	08/19/94	  MM		Modified the function VRUpdALLSysForm
 *					upon adding a new gadget for VR_TRAY 
 *					shape.
 *	09/21/94	Manyam		Fix for TR#179310632
 *	09/22/94	Manyam		Fix for CR#179415710
 *					processing needed to display the max
 *					velocity in fpm
 *	10/24/94	Lori		Fix for CR#179422038
 *					Modified function VRUpdALLSysForm 
 *					upon adding user choice of material
 *					class (spec) for HVAC
 *	01/15/96	tlb		Add VX_FIproto.h, prototypes
 *
 *      02/29/96        Shankar         Added functions to Update or Reset the
 *                                      forms.
 *      09/05/97        law             Fix for TR179700742-put "System Class"
 *                                      and "Unit" fields in both clear and
 *                                      check-off sections.
 *      01/12/98        law             CR179309874 - New raceway shapes.
 *      01/12/98        law             CR179700399 - Link diameter/width/depth
 *      06/24/98        law             TR179801141 - Add vendor ro rway form
 *      07/25/98        LAW             Added tiers for raceway - CR179801144
 *     26 Apr 99        Anand           CR 179900491-some changes at form level
 *      7 Sep 99        Anand           TR 179900776 - Removed label-overlap
 *      11/05/99	law		tr179900932 - form cleanup     
 *      02/10/2000	Alwin		CR179900696 - update the material list
 *      04/04/00        law             tr179901333 - Removed double label
 *					based on the spec_name
 *      May 9 2k        Anand 		Removed FIg_erase calls to Corner
 *      				Radius related fields for all Raceway
 *      				forms - TR 179901473
 *      May 10 2k       Alwin 		CR179901312 Display Acoustic Insulation flds
 *      Jul 13 2k       Alwin 		CR179901661 Display ACST parameter
 *      Jul 21 2k       Alwin 		CR179901615 Modified VRUpdALLSysForm
 *					method to update the insulation 
 *					thickness list, for the insul_type.
 */

class implementation VRchgattr;


#include <stdlib.h>
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcordef.h"
#include "VRcompdef.h"
#include "vrconsdef.h"
#include "vrparameters.h"
#include "VRDbParamDef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VRchgattrdef.h"
#include "VRparamdef.h"
#include "VRact_params.h"
#include "VRattr_index.h"
#include "AS_status.h"
#include "VRMcForm.h"
#include "bsvalues.h"
#include "HV_param.h" /* CR179700399 */
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VDDfEntCode.h"
#include "VRDbStruct.h"
#include "vrpdu_pto.h"
#include "vrchgatt_pto.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"
#include "VRRwDimen.h"
#include "FI.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define AS_DEBUG 	 1
#define UNKNOWN 	 -1

/* Added for CR 179900491 by Anand */
#define D_RCWY_SIZE	718

from	NDnode		import	NDs_compute_node;
from	VRCnrlSeg	import	VRget_terminators;
from	VRGeneric	import	VRGetSupports;
from 	ACrg_collect 	import	ACget_named_attribute, ACadd_list_attribute;

extern	GRclassid 	OPP_VRCorrection_class_id;

extern double fabs ();


IGRint	VRUpdALLSysForm ( product, form_ptr, pId )
	IGRint			product;
	Form			form_ptr;
	struct  GRid		*pId;
{
    struct ACrg_coll	AttrList;
    IGRlong			retmsg;
    IGRint			int_conv, status, sel_flag;
    /* Below  added for CR179700399 */
    IGRchar              szText[MAX_FIELD];
    IGRint       row = 0, col = 0;
    IGRint       r_pos;
    IGRlong	 mask=0;

    SetProc( VRUpdALLSysForm ); Begin

    sel_flag = 0;

    if ( !form_ptr )
    {
	printf ("Error in form managment\n");
	End
	return OM_S_SUCCESS;
    }

    __DBGpr_obj(" Collection", (*pId) );

    /*A display the attributes in the gadgets */
    switch (product)
    {
      case VR_PIPING :

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= PIPING_MAT_CLASS,
			    pAttrName	= VR_N_CLASS_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= NOM_PIPE_DIAM,
			    pAttrName 	= VR_N_GDIAMETER_DB);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= LINE_SEQ_NO,
			    pAttrName 	= VR_N_SEQ_NUMBER_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= LINE_ID,
			    pAttrName 	= VR_N_LINE_ID_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= FLUID_CODE,
			    pAttrName 	= VR_N_FLUID_CODE_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= HEAT_TRACING,
			    pAttrName 	= VR_N_TRACING_CODE_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= INSULATION_THICKNESS,
			    pAttrName 	= VR_N_INSUL_THK_DB);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= INSULATION_TYPE,
			    pAttrName 	= VR_N_INSUL_TYPE_AN);
	  /* 
	   * Based on the insulation_type we need to update the insulation
	   * thickness list. CR179901615 Alwin 
	   */
	  // don't do this if its Review command.
	  FIfld_get_attr( form_ptr, INSULATION_THICKNESS, 0, &mask );

	FIg_get_text( form_ptr, INSULATION_TYPE, szText );
	__DBGpr_str( " Insulation type ", szText );

	  //if( mask & FI_ASSOCIATED_LIST )
	  {
	      FIg_get_text( form_ptr, INSULATION_TYPE, szText );
	      __DBGpr_str( " Insulation type ", szText );
	      VRPGetInsulThkFromType( form_ptr, INSULATION_THICKNESS, szText );
	  }

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= BLOCK_NO,
			    pAttrName 	= VR_N_ZONE_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= OP_NORMAL_TEMP,
			    pAttrName 	= VR_N_OPER_TEMP_DB);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= OP_NORMAL_PRES,
			    pAttrName 	= VR_N_OPER_PRESS_DB);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= DES_NORMAL_TEMP,
			    pAttrName 	= VR_N_DGN_TEMP_DB);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= DES_NORMAL_PRES,
			    pAttrName 	= VR_N_DGN_PRESS_DB);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= APPROVAL_STATUS,
			    pAttrName 	= VR_N_APPRV_STAT_AN);

	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= CONSTRUC_STATUS,
			    pAttrName 	= VR_N_CONSTR_STAT_AN);


	  VR$DispCollAttr ( pForm	= form_ptr,
			    pCollId 	= pId,
			    Gadget	= PID_SCALE,
			    pAttrName	= VR_N_PID_SCALE_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= SYSTEM_NAME,
			    pAttrName 	= VR_N_SYST_NAME_AN);

	  if ( !( status&1 ) )
	  {
	      strcpy(AttrList.name, VR_N_SYST_NAME_AN);
	      AttrList.desc.type = AC_ATTRIB_TEXT;
	      strcpy(AttrList.desc.value.att_txt,"");

	      status = om$send( msg      = message 
		      ACrg_collect.ACadd_list_attribute( 
			  &retmsg, 1, &AttrList ),
		      senderid = NULL_OBJID,
		      targetid = pId->objid,
		      targetos = pId->osnum );
	      as$status( action = RET_STATUS );

	      status=
	      VR$DispCollAttr ( pForm 	= form_ptr,
		      pCollId		= pId,
		      Gadget		= SYSTEM_NAME,
		      pAttrName 	= VR_N_SYST_NAME_AN);
	  }

	  break;

      case VR_HVAC :

	  // display the ACST parameter. CR179901661
	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= ACST,
			    pAttrName 	= VR_N_ACST_DB );

	  // display the acoustic related information. CR179901312
	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= ACOUSTIC_MATERIAL,
			    pAttrName 	= VR_N_ACST_INSUL_TYPE_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= ACOUSTIC_THICK,
			    pAttrName 	= VR_N_ACST_INSUL_THK_DB);

	  status =
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= HVAC_MAT_CLASS,
			    pAttrName	= VR_N_CLASS_AN);

	  { //  added for CR179900696
		IGRchar 	szSpecName[30];

		//Need to update the Material list based on the spec Name being set
		//to the form
		FIg_get_text( form_ptr, HVAC_MAT_CLASS, szSpecName );
		VRUpdMaterial_InsulationList(form_ptr, TRUE, szSpecName, DUCT_MATER );
	  }

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= PRESS_CLASS,
			    pAttrName 	= VR_N_PRESS_CLASS_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= SERVICE,
			    pAttrName 	= VR_N_SERVICE_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= SIZE_METHOD,
			    pAttrName 	= VR_N_SIZE_METHOD_AN);
	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= MAX_VELOCITY,
			    pAttrName 	= VR_N_MAX_VELOC_DB);

	  /*A convert the max velocity from fps to fpm and display */
	  if ( VRenq_proj_units() == VR_IMPERIAL_UNITS )
	  {
	      /* Onay Sep 10 1997. Fix the lost of precision for	*/
	      /* infinite ending numbers such as .33333 and .66666	*/
	      double		dValue;
	      IGRint		Tmp, bInfinite = FALSE;
	      IGRchar		szTmp [100], *p;
	      extern char *strtok (), *strpbrk ();

	      FIg_get_value( form_ptr, MAX_VELOCITY, &dValue );
	      sprintf (szTmp, "%.6lf", dValue );
	      p = (IGRchar *) strtok (szTmp, ".");
	      p = (IGRchar *) strtok (NULL, ".");
	      if (p != NULL)
	      {
		  /* Now check everything ends by a set of 3 or 6	*/
		  /* and expect value potentially rounded to 4 or 7.	*/
		  if (strstr (p, "33") || strstr (p, "34"))
		  {
		      /* Skipping any 8 in 8333 ...	*/
		      p+=2;
		      if (!strpbrk (p, "1256789"))
		      {
			  bInfinite	= TRUE;
		      }
		  } /* end if */
		  if (strstr (p, "66") || strstr (p, "67"))
		  {
		      p+=2;
		      if (!strpbrk (p, "1234589"))
		      {
			  bInfinite	= TRUE;
		      }
		  } /* end if */
	      } /* end if */
	      if (bInfinite)
	      {
		  dValue 	= dValue * 60 + 0.02;
		  Tmp	= (IGRint) dValue;
		  dValue	= (IGRdouble) Tmp;
	      }
	      else
		  dValue 	= dValue * 60.0;
	      FIg_set_value( form_ptr, MAX_VELOCITY, dValue );
	  } /* end if imperial units */

	  /* Friction added for CR179700399 */
	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= FRICTION,
			    pAttrName 	= VR_N_FRICTION_FACT_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= AIR_FLOW,
			    pAttrName 	= VR_N_FLOW_RATE_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= INSULA_MATER,
			    pAttrName 	= VR_N_INSUL_TYPE_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= INSULA_THICK,
			    pAttrName 	= VR_N_INSUL_THK_DB);

	  status =
	  VR$DispCollAttr ( pForm	= form_ptr,
			    pCollId	= pId,
			    Gadget	= PID_SCALE,
			    pAttrName	= VR_N_PID_SCALE_DB);

	  if ( !( status&1 ) )
	  {
	      strcpy(AttrList.name, VR_N_PID_SCALE_DB);
	      AttrList.desc.type = AC_ATTRIB_DOUBLE;
	      AttrList.desc.value.att_exp = 1.;

	      status = om$send( msg      = message 
		      ACrg_collect.ACadd_list_attribute( 
			  &retmsg, 1, &AttrList ),
		      senderid = NULL_OBJID,
		      targetid = pId->objid,
		      targetos = pId->osnum );
	      as$status( action = RET_STATUS );

	      status=
	      VR$DispCollAttr ( pForm 	= form_ptr,
		      pCollId		= pId,
		      Gadget		= PID_SCALE,
		      pAttrName 	= VR_N_PID_SCALE_DB);
	  }
	  /* Below added for CR179700399 */
	  FIfld_get_text( form_ptr, SIZE_METHOD , row, col, MAX_FIELD,
		  (unsigned char *) szText, &sel_flag, &r_pos );

	  /* Friction added for CR179700399 */
	  if(!strcmp(szText,"Friction"))
	      VRUpdEquiDiamFF ( form_ptr );

	  else
	      /*A This computes the equivalent diameter based on the
		flow rate and velocity of the form */
	      VRUpdEquiDiamFV ( form_ptr );


      case VR_CABLING :
	  /*C get shape from collection */
	  strcpy(AttrList.name, VR_N_SHAPE_IN);

	  status =
	  om$send( msg = message 
		  ACrg_collect.ACget_named_attribute
		  ( &retmsg, &AttrList ),
		  senderid = NULL_OBJID,
		  targetid = pId->objid,
		  targetos = pId->osnum );
	  as$status( action = RET_STATUS );

	  int_conv = AttrList.desc.value.att_exp;

	  /*A in case of HVAC */
	  if ( product == VR_HVAC )
	  {
	      switch ( int_conv )
	      {
		  /* Below modified for CR179700399 */
		case VR_RECT:
		    FIg_erase( form_ptr, OVAL_SHAPE );
		    FIg_erase( form_ptr, CIRCULAR_SHAPE );
		    FIg_erase( form_ptr, RADIUS_SHAPE );
		    FIg_display( form_ptr, RECTANGULAR_SHAPE );
		    FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
		    break;

		    /* Below modified for CR179700399 */
		case VR_CIRC:
		    FIg_erase( form_ptr, OVAL_SHAPE );
		    FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		    FIg_erase( form_ptr, RADIUS_SHAPE );
		    FIg_display( form_ptr, CIRCULAR_SHAPE );
		    FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
		    FIfld_set_mode(form_ptr, D_SIZE, 0, FI_REVIEW);
		    break;

		    /* Below modified for CR179700399 */
		case VR_OVAL:
		    FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		    FIg_erase( form_ptr, CIRCULAR_SHAPE );
		    FIg_erase( form_ptr, RADIUS_SHAPE );
		    FIg_display( form_ptr, OVAL_SHAPE );
		    FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_REVIEW);
		    break;

		case VR_CORNER:
		    FIg_erase( form_ptr, RECTANGULAR_SHAPE );
		    FIg_erase( form_ptr, CIRCULAR_SHAPE );
		    FIg_erase( form_ptr, OVAL_SHAPE );
		    FIg_display( form_ptr, RADIUS_SHAPE );
		    FIfld_set_mode(form_ptr, CORNER_RADIUS, 0, FI_INSERT);
		    break;

		default:
		    break;
	      }
	  }
	  else 	/*A in case of VR_CABLING */
	  {
                      int       VndChkBoxMask=0;
	      /* Following FIg_erase calls have been put in common,
	       * before entering the switch statement in order to
	       * reduce the amount of code. Further, variably-spaced
	       * multi-tiers and its related form-level changes have
	       * been done.	-	Anand for CR 179900491 */

	      FIg_erase( form_ptr, OVAL_SHAPE );
	      FIg_erase( form_ptr, CIRCULAR_SHAPE );
	      FIg_erase( form_ptr, ELLP_SHAPE );
	      FIg_erase( form_ptr, RADIUS_SHAPE );
	      FIg_erase( form_ptr, RECTANGULAR_SHAPE );
	      FIg_erase( form_ptr, N_TIER_DG );
	      FIg_erase( form_ptr, SP_TIER_DG );
	      FIg_erase (form_ptr, RW_SP_TIER_TEXT);
	      FIg_erase (form_ptr, RW_SP_TIER_TX_IN);
	      FIg_erase (form_ptr, RW_SP_TIER_TX_MM);
	      FIg_erase (form_ptr, RW_N_TIER_TEXT);

	      switch ( int_conv )
	      {
		  /* Below modified for CR179309874 */
		case VR_RECT:
		  FIg_display( form_ptr, RECTANGULAR_SHAPE );
		  /* Modified for CR179801144 */
		  FIg_display( form_ptr, N_TIER_DG );
		  FIg_display( form_ptr, SP_TIER_DG );
		  FIfld_set_mode(form_ptr, D_RCWY_SIZE, 0, FI_REVIEW);
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
		  /* Below lines added by Anand for TR 179900776 */
		  {
		      int	NumChkBoxMask=0, SpChkBoxMask=0;

		      FIg_get_attr( form_ptr, SYMB_N_TIER_DG, &NumChkBoxMask );
		      FIg_get_attr( form_ptr, SYMB_SP_TIER_DG, &SpChkBoxMask );

		      if( NumChkBoxMask & FI_NOT_DISPLAYED )
		      {
#ifdef vdsDEBUG
			  printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 
			  FIg_display (form_ptr, RW_N_TIER_TEXT);
		      }
		      if( SpChkBoxMask & FI_NOT_DISPLAYED )
		      {
#ifdef vdsDEBUG
			  printf("CHECK %d %s\n", __LINE__ , __FILE__);
#endif 
			  FIg_display (form_ptr, RW_SP_TIER_TEXT);
		      }
		  }
		  /* Above lines added by Anand for TR 179900776 */
		  break;

		  /* Below modified for CR179309874 */
		case VR_CORNER:

		      FIg_get_attr( form_ptr, SYMB_RWAY_VNDR_CODE,
                                                              &VndChkBoxMask );
		  FIg_display( form_ptr, RADIUS_SHAPE );
		  FIg_display( form_ptr, CORNER_RADIUS );
		  if( VndChkBoxMask & FI_NOT_DISPLAYED )
                  {
		     FIg_display( form_ptr, CORNER_RADIUS_LBL );
                  }
                  else
                  {
                     FIg_display( form_ptr, SYMB_CORNER_RADIUS );
                  }

		  strcpy(AttrList.name, VR_N_CORN_RAD_DB);
		  om$send( msg = message 
			  ACrg_collect.ACget_named_attribute
			  ( &retmsg, &AttrList ),
			  senderid = NULL_OBJID,
			  targetid = pId->objid,
			  targetos = pId->osnum );
		  FIg_set_value( form_ptr, CORNER_RADIUS,
			  AttrList.desc.value.att_exp );
		  break;

		  /* Below modified for CR179309874 */
		case VR_CIRC:
		  FIg_erase( form_ptr, D_RCWY_SIZE );
		  FIg_erase( form_ptr, RW_D_SIZE_TEXT );
		  FIg_display( form_ptr, CIRCULAR_SHAPE );
		  break;

		  /* Below modified for CR179309874 */
		case VR_OVAL:
		  FIg_display( form_ptr, OVAL_SHAPE );
		  break;

		  /* Ellipse added,tray deleted for CR179309874 */
		case VR_ELLIPSE:
		  FIg_display( form_ptr, ELLP_SHAPE );
		  break;
	      }
	  }
	  /* TR179801141-added vendor to form */
	  status =
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= RWAY_VNDR_CODE,
			    pAttrName	= VR_N_CLASS_AN);

	  /* Below added for CR179309874 */
	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= CORNER_RADIUS,
			    pAttrName 	= VR_N_CORN_RAD_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= GAP,
			    pAttrName 	= VR_N_CP_OFFSET_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= LINE_NUMBER,
			    pAttrName 	= VR_N_SEQ_NUMBER_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= MAX_WIDTH,
			    pAttrName 	= VR_N_MAX_DEPTH_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= DUCT_MATER,
			    pAttrName 	= VR_N_DUCT_MATERIAL_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= DUCT_THICK,
			    pAttrName 	= VR_N_DUCT_THICK_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= CONST_STATUS,
			    pAttrName 	= VR_N_CONSTR_STAT_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= APPROVAL_STAT,
			    pAttrName 	= VR_N_APPRV_STAT_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= SYSTEM,
			    pAttrName 	= VR_N_SYST_NAME_AN);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= ZONE,
			    pAttrName 	= VR_N_ZONE_AN);

	  /* Following if condition added by Anand for CR 179900491 */
	  if( product != VR_CABLING )
	  {
	      status=
	      VR$DispCollAttr ( pForm 		= form_ptr,
				pCollId		= pId,
				Gadget		= W_SIZE,
				pAttrName 	= VR_N_WIDTH1_DB);

	      status=
	      VR$DispCollAttr ( pForm 		= form_ptr,
				pCollId		= pId,
				Gadget		= D_SIZE,
				pAttrName	= VR_N_DEPTH1_DB);
	  }

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= THROAT_RADIUS,
			    pAttrName 	= VR_N_THROAT_DB);

	  status=
	  VR$DispCollAttr ( pForm 	= form_ptr,
			    pCollId	= pId,
			    Gadget	= TRANS_LENGTH,
			    pAttrName 	= VR_N_TRANS_L_DB);

    }/* end switch on product */

    /*A display the unit number */
    status=
    VR$DispCollAttr ( pForm         = form_ptr,
		      pCollId       = pId,
		      Gadget        = UNIT_NUMBER,
		      pAttrName     = VR_N_UNIT_AN);

    if ( !( status&1 ) )
    {
	strcpy(AttrList.name, VR_N_UNIT_AN);
	AttrList.desc.type = AC_ATTRIB_TEXT;
	strcpy(AttrList.desc.value.att_txt,"");

	status = om$send( msg      = message 
		ACrg_collect.ACadd_list_attribute( 
		    &retmsg, 1, &AttrList ),
		senderid = NULL_OBJID,
		targetid = pId->objid,
		targetos = pId->osnum );
	as$status( action = RET_STATUS );

	status=
	VR$DispCollAttr ( pForm		= form_ptr,
			  pCollId	= pId,
			  Gadget	= UNIT_NUMBER,
			  pAttrName	= VR_N_UNIT_AN);
    }

    FIfld_set_text( form_ptr, MESSAGE, 0, 0, "", sel_flag );

    End
    return (OM_S_SUCCESS);

}/* end VRUpdALLSysForm */

/*****************************************************************************

				Reset Gadget

*****************************************************************************/

VRreset_gadget( product, form_ptr )

IGRint	product;
IGRchar	*form_ptr;

/*.VRreset_gadget */
{
	int sel_flag;

	SetProc( VRreset_gadget ); Begin

        sel_flag = 0;

      	FIfld_set_text( form_ptr, MESSAGE, 0, 0,"", sel_flag );
	switch( product )
	{
	case VR_PIPING:
        	FIg_set_state_off( form_ptr, SYMB_PIPING_MAT_CLASS );
        	FIfld_set_text( form_ptr, 
				PIPING_MAT_CLASS, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_SYSTEM_NAME );
        	FIfld_set_text( form_ptr,
        	                SYSTEM_NAME, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_UNIT_NUMBER );
        	FIfld_set_text( form_ptr,
        	                UNIT_NUMBER, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_NOM_PIPE_DIAM );
        	FIfld_set_text( form_ptr, 
				NOM_PIPE_DIAM, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_LINE_SEQ_NO );
        	FIfld_set_text( form_ptr, 
				LINE_SEQ_NO, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_FLUID_CODE );
        	FIfld_set_text( form_ptr, 
				FLUID_CODE, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_HEAT_TRACING );
        	FIfld_set_text( form_ptr, 
				HEAT_TRACING, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_INSULATION_THICKNESS );
        	FIfld_set_text( form_ptr, 
				INSULATION_THICKNESS, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_INSULATION_TYPE );
        	FIfld_set_text( form_ptr, 
				INSULATION_TYPE, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_BLOCK_NO );
        	FIfld_set_text( form_ptr, 
				BLOCK_NO, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_OP_NORMAL_TEMP );
        	FIfld_set_text( form_ptr, 
				OP_NORMAL_TEMP, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_OP_NORMAL_PRES );
        	FIfld_set_text( form_ptr, 
				OP_NORMAL_PRES, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_DES_NORMAL_TEMP );
        	FIfld_set_text( form_ptr, 
				DES_NORMAL_TEMP, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_DES_NORMAL_PRES );
        	FIfld_set_text( form_ptr, 
				DES_NORMAL_PRES, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_APPROVAL_STATUS );
        	FIfld_set_text( form_ptr, 
				APPROVAL_STATUS, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_CONSTRUC_STATUS );
        	FIfld_set_text( form_ptr, 
				CONSTRUC_STATUS, 0, 0,"", sel_flag );

        	FIg_set_state_off( form_ptr, SYMB_PID_SCALE );
        	FIfld_set_text( form_ptr, 
				PID_SCALE, 0, 0,"", sel_flag );

			break;

	case VR_HVAC:
        	FIg_set_state_off( form_ptr, SYMB_PID_SCALE );
        	FIfld_set_text( form_ptr, 
				PID_SCALE, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_HVAC_MAT_CLASS );
        	FIfld_set_text( form_ptr, 
				HVAC_MAT_CLASS, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_SIZE_METHOD );
        	FIfld_set_text( form_ptr, 
				SIZE_METHOD, 0, 0,"", sel_flag );

       		FIg_set_state_off( form_ptr, SYMB_AIR_FLOW );
        	FIfld_set_text( form_ptr, 
				AIR_FLOW, 0, 0,"", sel_flag );
                /* friction added for CR179700399 */
      		FIg_set_state_off( form_ptr, SYMB_FRICTION );
        	FIfld_set_text( form_ptr, 
				FRICTION, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_MAX_VELOCITY );
        	FIfld_set_text( form_ptr, 
				MAX_VELOCITY, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_INSULA_MATER );
        	FIfld_set_text( form_ptr, 
				INSULA_MATER, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_INSULA_THICK );
        	FIfld_set_text( form_ptr, 
				INSULA_THICK, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_ACOUSTIC_MATERIAL );
        	FIfld_set_text( form_ptr, 
				ACOUSTIC_MATERIAL, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_ACOUSTIC_THICK );
        	FIfld_set_text( form_ptr, 
				ACOUSTIC_THICK, 0, 0,"", sel_flag );

		// CR179901661
        	FIfld_set_text( form_ptr, 
				ACST, 0, 0,"", sel_flag );

	case VR_CABLING:
                /* TR179801141-added vendor to form */
        	FIg_set_state_off( form_ptr, SYMB_RWAY_VNDR_CODE );
        	FIfld_set_text( form_ptr, 
				RWAY_VNDR_CODE, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_LINE_NUMBER );
        	FIfld_set_text( form_ptr, 
				LINE_NUMBER, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_PRESS_CLASS );
        	FIfld_set_text( form_ptr, 
				PRESS_CLASS, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_CONST_STATUS );
        	FIfld_set_text( form_ptr, 
				CONST_STATUS, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_APPROVAL_STAT );
        	FIfld_set_text( form_ptr, 
				APPROVAL_STAT, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_SERVICE );
        	FIfld_set_text( form_ptr, 
				SERVICE, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_SHAPE );

      		FIg_set_state_off( form_ptr, SYMB_DUCT_THICK );
        	FIfld_set_text( form_ptr, 
				DUCT_THICK, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_MAX_WIDTH );
        	FIfld_set_text( form_ptr, 
				MAX_WIDTH, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_DUCT_MATER );
        	FIfld_set_text( form_ptr, 
				DUCT_MATER, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_SYSTEM );
        	FIfld_set_text( form_ptr, 
				SYSTEM, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_N_TIER_DG ); /*CR179801144*/
        	FIfld_set_text( form_ptr, 
				N_TIER_DG, 0, 0,"", sel_flag ); /*CR179801144*/

      		FIg_set_state_off( form_ptr, SYMB_SP_TIER_DG ); /*CR179801144*/
        	FIfld_set_text( form_ptr, 
				SP_TIER_DG, 0, 0,"", sel_flag ); /*CR179801144*/

      		FIg_set_state_off( form_ptr, SYMB_CORNER_RADIUS );
        	FIfld_set_text( form_ptr, 
				CORNER_RADIUS, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_ZONE );
        	FIfld_set_text( form_ptr, 
				ZONE, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_GAP );
        	FIfld_set_text( form_ptr, 
				GAP, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_W_SIZE );
        	FIfld_set_text( form_ptr, 
				W_SIZE, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_D_SIZE );
        	FIfld_set_text( form_ptr, 
				D_RCWY_SIZE, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_THROAT_RADIUS );
        	FIfld_set_text( form_ptr, 
				THROAT_RADIUS, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_TRANS_LENGTH );
        	FIfld_set_text( form_ptr, 
				TRANS_LENGTH, 0, 0,"", sel_flag );

      		FIg_set_state_off( form_ptr, SYMB_UNIT_NUMBER );
        	FIfld_set_text( form_ptr, 
				UNIT_NUMBER, 0, 0,"", sel_flag );


	default:break;
	}

	End
	return OM_S_SUCCESS;
}

/*****************************************************************************

				Update All Gadget

*****************************************************************************/

VRupd_all_checkgadgets( product, form_ptr )

IGRint	product;
IGRchar	*form_ptr;

/*.VRreset_gadget */
{

	SetProc( VRupd_all_checkgadgets ); Begin

	switch( product )
	{
	case VR_PIPING:
       		FIg_set_state_on( form_ptr, SYMB_PIPING_MAT_CLASS );
        	FIg_set_state_on( form_ptr, SYMB_SYSTEM_NAME );
        	FIg_set_state_on( form_ptr, SYMB_UNIT_NUMBER );
       		FIg_set_state_on( form_ptr, SYMB_NOM_PIPE_DIAM );
       		FIg_set_state_on( form_ptr, SYMB_LINE_SEQ_NO );
       		FIg_set_state_on( form_ptr, SYMB_FLUID_CODE );
       		FIg_set_state_on( form_ptr, SYMB_HEAT_TRACING );
       		FIg_set_state_on( form_ptr, SYMB_INSULATION_THICKNESS );
       		FIg_set_state_on( form_ptr, SYMB_INSULATION_TYPE );
       		FIg_set_state_on( form_ptr, SYMB_BLOCK_NO );
       		FIg_set_state_on( form_ptr, SYMB_OP_NORMAL_TEMP );
       		FIg_set_state_on( form_ptr, SYMB_OP_NORMAL_PRES );
       		FIg_set_state_on( form_ptr, SYMB_DES_NORMAL_TEMP );
       		FIg_set_state_on( form_ptr, SYMB_DES_NORMAL_PRES );
       		FIg_set_state_on( form_ptr, SYMB_APPROVAL_STATUS );
       		FIg_set_state_on( form_ptr, SYMB_CONSTRUC_STATUS );
       		FIg_set_state_on( form_ptr, SYMB_PID_SCALE );
		break;

        /* Add friction for CR179700399 */
	case VR_HVAC:
       		FIg_set_state_on( form_ptr, SYMB_PID_SCALE );
/*     		FIg_set_state_on( form_ptr, SYMB_HVAC_MAT_CLASS ) TR179801141 */
      		FIg_set_state_on( form_ptr, SYMB_SIZE_METHOD );
      		FIg_set_state_on( form_ptr, SYMB_FRICTION );

	case VR_CABLING:
                /* TR179801141-Added vendor to form */
      		FIg_set_state_on( form_ptr, SYMB_RWAY_VNDR_CODE );
      		FIg_set_state_on( form_ptr, SYMB_LINE_NUMBER );
      		FIg_set_state_on( form_ptr, SYMB_PRESS_CLASS );
      		FIg_set_state_on( form_ptr, SYMB_CONST_STATUS );
      		FIg_set_state_on( form_ptr, SYMB_APPROVAL_STAT );
      		FIg_set_state_on( form_ptr, SYMB_SERVICE );
      		FIg_set_state_on( form_ptr, SYMB_SHAPE );
      		FIg_set_state_on( form_ptr, SYMB_MAX_VELOCITY );
      		FIg_set_state_on( form_ptr, SYMB_AIR_FLOW );
      		FIg_set_state_on( form_ptr, SYMB_DUCT_THICK );
      		FIg_set_state_on( form_ptr, SYMB_MAX_WIDTH );
      		FIg_set_state_on( form_ptr, SYMB_DUCT_MATER );
      		FIg_set_state_on( form_ptr, SYMB_SYSTEM );
      		FIg_set_state_on( form_ptr, SYMB_CORNER_RADIUS );
      		FIg_set_state_on( form_ptr, SYMB_ZONE );
      		FIg_set_state_on( form_ptr, SYMB_INSULA_MATER );
      		FIg_set_state_on( form_ptr, SYMB_INSULA_THICK );
      		FIg_set_state_on( form_ptr, SYMB_GAP );
      		FIg_set_state_on( form_ptr, SYMB_W_SIZE );
      		FIg_set_state_on( form_ptr, SYMB_D_SIZE );
      		FIg_set_state_on( form_ptr, SYMB_THROAT_RADIUS );
      		FIg_set_state_on( form_ptr, SYMB_TRANS_LENGTH );
      		FIg_set_state_on( form_ptr, SYMB_N_TIER_DG );/* CR179801144 */
      		FIg_set_state_on( form_ptr, SYMB_SP_TIER_DG );/*CR179801144*/

      		FIg_set_state_on( form_ptr, SYMB_UNIT_NUMBER );
	default:break;
	}

	End
	return OM_S_SUCCESS;
}

/*****************************************************************************/

VRUpdate( ObjId, OldType, NewType, MdEnv )

struct	GRid		*ObjId;
IGRint			OldType, NewType;
struct	GRmd_env	*MdEnv;
{
  IGRint		nb_cmp, NbSupp;
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;
  struct 	GRid 	CorId, SupportId[VR_MAX_CPTS], CmpId[2];

  status = om$send( msg      = message VRGeneric.VRGetSupports
                               ( &retcode, VR_MAX_CPTS, SupportId, &NbSupp ),
		    senderid = NULL_OBJID,
                    targetid = ObjId->objid,
                    targetos = ObjId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( OldType == VRP_V_3_WAYS_TOPO && NewType == VRP_V_OLET_TOPO ) 
  {
    status = VRGetCorrection( &retcode, &SupportId[0], ObjId, MdEnv, &CorId, NULL );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = VRMergeCorrections( &retcode, 1, &CorId, MdEnv );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }
  else if( OldType ==  VRP_V_OLET_TOPO && NewType == VRP_V_3_WAYS_TOPO ) 
  {
    status = om$send( msg      = message VRCnrlSeg.VRget_terminators
				 ( &retcode, &nb_cmp, MdEnv, NULL, CmpId ),
		      senderid = NULL_OBJID,
		      targetid = SupportId[0].objid,
		      targetos = SupportId[0].osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = VRGetCorrection
	     ( &retcode, &SupportId[0], &CmpId[0], MdEnv, &CorId, NULL );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    status = om$send( msg      = message NDnode.NDs_compute_node
	 			 			( &retcode, 0, MdEnv ),
		      senderid = NULL_OBJID,
		      targetid = ObjId->objid,
                      targetos = ObjId->osnum );

    status = VRSplitCorrection
	     ( &retcode, UNKNOWN, &CorId, NULL, &CmpId[0], MdEnv, UNKNOWN, NULL );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  return OM_S_SUCCESS;
 
}/* end VRUpdate */

/**************************************************************
			VRReportLineId

	Manyam		05 Oct 93	Creation
***************************************************************/
IGRint	VRReportLineId( pCmpCollId, pModCollId )
	struct	GRid		*pCmpCollId;	/* I : Cmp's Collection */
	struct	GRid		*pModCollId;	/* I : collection containing
						      modified attributes */
{
#ifdef	MANAGE_IDS
	IGRlong			status = OM_S_SUCCESS, retmsg;
	struct	ACrg_coll	Attr;
	IGRdouble		OldValue, NewValue;
	IGRchar			*sEnd=NULL;
			
	/*A look for line seq number in the collection (Input) */
	strcpy(Attr.name, VR_N_SEQ_NUMBER_AN);
	status = 
	om$send( msg      = message ACrg_collect.ACget_named_attribute(
			&retmsg, &Attr ),
		senderid = NULL_OBJID,
		targetid = pModCollId->objid,
		targetos = pModCollId->osnum );
	as$status();

	/*printf( "new line seq number = %s\n", 
			Attr.desc.value.att_txt );*/

	NewValue = strtod (Attr.desc.value.att_txt, &sEnd);
	if ( strlen (sEnd) )	return	OM_E_ABORT;

	if ( (retmsg&1) )
	{
		/*A get the previous seq number */
		strcpy(Attr.name, VR_N_SEQ_NUMBER_AN);
		status = 
		om$send( msg      = message ACrg_collect.ACget_named_attribute(
				&retmsg, &Attr ),
			senderid = NULL_OBJID,
			targetid = pCmpCollId->objid,
			targetos = pCmpCollId->osnum );
		as$status();
 
		if ( !(retmsg&1) ) return OM_E_ABORT;

		/*printf( "old line seq number = %s\n", 
			Attr.desc.value.att_txt );*/

		sEnd = NULL;
		OldValue = strtod (Attr.desc.value.att_txt, &sEnd);
		if ( strlen (sEnd) )	return	OM_E_ABORT;

		/*C Get system name */
		strcpy(Attr.name,VR_N_SYST_NAME_AN );
		status = 
		om$send( msg      = message ACrg_collect.ACget_named_attribute(
				&retmsg, &Attr ),
			senderid = NULL_OBJID,
			targetid = pCmpCollId->objid,
			targetos = pCmpCollId->osnum );
		as$status();

		/*printf( " OldValue = %f , NewValue = %f \n",
			OldValue, NewValue );*/

		VDModifyID( Attr.desc.value.att_txt,
			(int)VD_C_PIPES,(int)OldValue, (int)NewValue );

	}
#else

  /* get rid of compiler warnings   */

  IGRint   xx;

  xx = pCmpCollId->objid;
  xx = pModCollId->objid;

#endif

	return	OM_S_SUCCESS;

} /* end VRReportLineId */

/***************************************************************/

VRupd_all_gadget_subform ( IGRchar* form_ptr )
{
    IGRint num_rows, i, sel_flag=0;

    FIfld_get_max_num_rows( form_ptr, USER_ATTR_FLD, &num_rows );

#define ADD_FLD 3
    for ( i =0; i<num_rows; i++ )
	FIfld_set_text( form_ptr, USER_ATTR_FLD, i, ADD_FLD, "x", sel_flag );

    return 1;
}

/***************************************************************/

VRreset_gadget_subform ( IGRchar* form_ptr )
{
    IGRint num_rows, i, j, sel_flag=0;

    FIfld_get_max_num_rows( form_ptr, USER_ATTR_FLD, &num_rows );

    for ( i =0; i<num_rows; i++ )
         for ( j =0; j<5; j++ )
		FIfld_set_text( form_ptr, USER_ATTR_FLD, i, j, "", sel_flag );

    return 1;
}
end implementation VRchgattr;
