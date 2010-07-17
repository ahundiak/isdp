/* $Id: VRget_params.I,v 1.3 2001/02/20 01:18:11 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRget_params.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRget_params.I,v $
 *	Revision 1.3  2001/02/20 01:18:11  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:29  anand
 *	SP merge
 *	
# Revision 1.4  2000/08/17  18:47:32  pinnacle
# Replaced: route/vrtools/VRget_params.I for:  by apazhani for Service Pack
#
# Revision 1.3  2000/07/13  23:07:04  pinnacle
# Replaced: route/vrtools/VRget_params.I for:  by apazhani for Service Pack
#
# Revision 1.2  2000/07/10  19:27:40  pinnacle
# Replaced: route/vrtools/VRget_params.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/11  21:52:02  pinnacle
# Created: route/vrtools/VRget_params.I by apazhani for Service Pack
#
# Revision 1.6  1999/04/21  11:36:54  pinnacle
# Replaced: vrtools/VRget_params.I for:  by aharihar for route
#
# Revision 1.3  1998/08/05  16:00:14  pinnacle
# Replaced: vrtools/VRget_params.I for:  by lawaddel for route
#
# Revision 1.2  1998/06/26  22:34:32  pinnacle
# Replaced: vrtools/VRget_params.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/04/04  23:35:52  pinnacle
# Replaced: vrtools/VRget_params.I for:  by kddinov for route
#
# Revision 1.5  1998/04/01  18:44:40  pinnacle
# Replaced: vrtools/VRget_params.I for:  by lawaddel for route
#
# Revision 1.4  1998/01/14  19:01:52  pinnacle
# Replaced: vrtools/VRget_params.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/09/18  05:02:42  pinnacle
# Replaced: vrtools/VRget_params.I for:  by ashankar for route
#
# Revision 1.7  1996/06/04  21:47:38  pinnacle
# Replaced: vrtools/VRget_params.I for:  by hverstee for route240
#
# Revision 1.6  1996/05/13  15:03:52  pinnacle
# Replaced: vrtools/VRget_params.I for:  by ashankar for route240
#
# Revision 1.5  1996/01/18  00:32:40  pinnacle
# Replaced: vrtools/VRget_params.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      01/08/98        law     CR179700399 - Add friction/corner radius
 *      04/01/98        law     VRget_code_list_set returns fixed length buffer
 *	4-98		KDD	import from user_data moved up for solris to
 *				compile. 
 *      06/24/98        law     TR179801141 Add vendor to rway forms
 *      25-Jul-1998     LAW     Added tiers for raceway - CR179801144
 *      19-Apr-1999    Anand	Modified for variably-spaced-tiers of raceway
 *      			- CR 179800491
 *      10-May-2000    Alwin	CR179901312 Added two more attributes for
 *				HVAC acst_insul_type and acst_insul_thick
 *      10-Jul-2000    Alwin	CR179901003 Modified VRInitAttributes function
 *				initialize the Raceway Nozzle attributes.
 *      13-Jul-2000    Alwin	CR179901661 Modified VRInitAttributes function
 *				and VRinit_attributes function to initialize
 *				"ACST" attribute
 *      17-Aug-2000    Alwin	CR179901873 Added unit_number attribute to the
 *				HVAC & PIPING system attributes list.
 *************************************************************************/

class implementation CEO_LOCATE ;

#include <stdio.h>
#include <ctype.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "nddef.h"
#include "vrdef.h"
#include "vrparameters.h"
#include "VRattr_def.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRDbStruct.h"
#include "VRDbParamDef.h"
#include "VRchgattrdef.h"
#include "VRdbcodlst.h"
#include "vrpdu_pto.h"

#include "vrdbgmacros.h"
#include "VRRwDimen.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define  AS_DEBUG

from VRActParam		import	VRInitAttr,
				VRDeleteAttr,
				VRUpdSysForm,
				VRUpdUsrForm;
from ACrg_collect	import 	ACcreate,
				GRchgname,
				ACset_list_attribute;
from NDnode		import	NDchg_state;

extern	GRclassid	OPP_ACrg_collect_class_id;

#define  DIR_NAME_SYMB  ":IGENOD:VRclsymb1"
from	user_data	import	set_data, get_data, update_data;
extern	GRclassid	OPP_user_data_class_id; 

/******************************************************************************/
/*									      */
/*	This function initilize systeme parameters with default value.	      */
/*									      */
/*	Arguments :							      */
/*		IN : VRproduct		IGRchar     Type of product defined   */
/*						    in vrdef.h		      */
/*									      */
/*              OUT : Attr      struct ACrg_collect Attributes description    */
/*									      */
/*	Return values : 						      */
/*		- OM_S_SUCCESS	    : Successfull operation.		      */
/*		- OM_E_INVARG	    : Bad type of product.		      */
/*									      */
/******************************************************************************/

IGRlong VRinit_attributes( VRproduct, Attr, NbAttr )

IGRint			VRproduct ;
struct ACrg_coll	*Attr;
IGRint			*NbAttr ;

/*.VRinit_attributes */
{
  IGRint Units;

/************* Define macro to simplify the code **********/

#define SET_ATTR( atindex, attype, atname, attext, atvalue ) \
	strcpy (Attr[(atindex)].name,(atname)) ;\
	Attr[(atindex)].desc.type = (attype);\
	if ( (attype) == AC_ATTRIB_TEXT ) \
	strcpy (Attr[(atindex)].desc.value.att_txt,(attext)) ;\
	else \
	if ( (attype) == AC_ATTRIB_DOUBLE ) \
	Attr[(atindex)].desc.value.att_exp = (atvalue) ;\
	else printf ("%s :Undefined Attribute Type\n", __FILE__);\
	(atindex) = (atindex) + 1;

/******************** end define macro *******************/

	/*A validity checking for the arguments*/
	if( VRproduct != VR_PIPING   &&
		VRproduct != VR_HVAC     &&
	    	  VRproduct != VR_RWAY  &&
	    	    VRproduct != VR_ELECTRIC &&
	    	      VRproduct != VR_FIBER ||
	    		!NbAttr || !Attr  )	return OM_E_INVARG ;

	/*"Product : %d\n", VRproduct */

	/*A init Number of attributes */
	*NbAttr = 0;

	/*A init common attributes */
	SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_SYST_NAME_AN,"sys1",0);
	SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_UNIT_AN,"",0);
	SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_ZONE_AN,"bloc1",0);

	if( VRproduct == VR_HVAC || VRproduct == VR_RWAY )
	{
		SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_CONSTR_STAT_AN,"New",0);
	}
	else if( VRproduct == VR_PIPING )
	{
		SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_CONSTR_STAT_AN,"N",0); 
	}

	if( VRproduct == VR_HVAC || VRproduct == VR_RWAY )
	{
	    SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_APPRV_STAT_AN,"Approved",0);
	}
	else if ( VRproduct == VR_PIPING )
	{
	    SET_ATTR(*NbAttr,AC_ATTRIB_TEXT,VR_N_APPRV_STAT_AN,"A",0);
	}

	/*A init network attributes */
	if ( VRproduct == VR_PIPING || VRproduct == VR_HVAC ||
		VRproduct == VR_RWAY )
	{        
		SET_ATTR( *NbAttr,
		  AC_ATTRIB_TEXT  , VR_N_SEQ_NUMBER_AN, 	"seq1",0);
		SET_ATTR( *NbAttr,
		  AC_ATTRIB_DOUBLE, VR_N_INSUL_THK_DB,  	"",0.0626) ;
	}

	if( VRproduct == VR_HVAC || VRproduct == VR_RWAY )
	{
		SET_ATTR( *NbAttr,
		  AC_ATTRIB_TEXT  , VR_N_INSUL_TYPE_AN,		"Foam",0) ;
	}
	else if ( VRproduct == VR_PIPING )
	{
		SET_ATTR( *NbAttr,
		  AC_ATTRIB_TEXT  , VR_N_INSUL_TYPE_AN,		"N",0) ;
	}


	/*A init other parameters for given product */
	switch( VRproduct ) 
	{
	case VR_PIPING	:
		Units = VRenq_proj_units();

		if( Units == VR_IMPERIAL_UNITS )
		/* set default diameter to 4 inches */
		{
		  SET_ATTR( *NbAttr, AC_ATTRIB_DOUBLE, VR_N_GDIAMETER_DB,
			    "", 4.0 );
		  SET_ATTR( *NbAttr, AC_ATTRIB_DOUBLE, VR_N_RDIAMETER_DB,
			    "", 4.0 );
		}
		else
		/* set default diameter to 20 mm */
		{
		  SET_ATTR( *NbAttr, AC_ATTRIB_DOUBLE, VR_N_GDIAMETER_DB,
			    "", 20.0 );
		  SET_ATTR( *NbAttr, AC_ATTRIB_DOUBLE, VR_N_RDIAMETER_DB,
			    "", 20.0 );
		}

		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_OPER_TEMP_DB, 	"",1.0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_OPER_PRESS_DB,	"",3.0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DGN_TEMP_DB,  	"",5.0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DGN_PRESS_DB ,	"",7.0) ;
		SET_ATTR( *NbAttr, 		AC_ATTRIB_TEXT,
			  VR_N_CLASS_AN,	"N1",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_LINE_ID_AN,	"id1",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_TRACING_CODE_AN, "NT",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_FLUID_CODE_AN,	"W",0) ;
                SET_ATTR( *NbAttr,              AC_ATTRIB_DOUBLE,
			  VR_N_PID_SCALE_DB,  	"",1.0) ;
		break ;

	case VR_HVAC	:

		//added these for Acoustical Insulation. CR179901661 Alwin
		SET_ATTR( *NbAttr,
		  AC_ATTRIB_DOUBLE, VR_N_ACST_DB,  	"",0.0) ;

		//added these for Acoustical Insulation. CR179901312 Alwin
		SET_ATTR( *NbAttr,
		  AC_ATTRIB_DOUBLE, VR_N_ACST_INSUL_THK_DB,  	"",0.0626) ;

		SET_ATTR( *NbAttr,
		  AC_ATTRIB_TEXT  , VR_N_ACST_INSUL_TYPE_AN,		"ACST",0) ;

		SET_ATTR( *NbAttr,      	AC_ATTRIB_DOUBLE,
			  VR_N_CORN_RAD_DB,  	"",1.0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_PRESS_CLASS_AN,	"Low",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_SERVICE_AN,	"Exhaust",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_MAX_FRICT_DB,	"",1) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_MAX_VELOC_DB,	"",2) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_FLOW_RATE_DB,	"",1) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_EQUIV_DIA_DB,	"",8) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_FRICTION_FACT_DB,	"",.0001) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_SIZE_METHOD_AN,	"Velocity",0) ;
                SET_ATTR( *NbAttr,              AC_ATTRIB_DOUBLE,
			  VR_N_PID_SCALE_DB,  	"",1.0) ;
		SET_ATTR( *NbAttr,      	AC_ATTRIB_TEXT,
			  VR_N_CLASS_AN,  	"SERV1",0) ;
                /* TR179801141 */
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_SHAPE_IN,	"",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_WIDTH1_DB,	"",12) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DEPTH1_DB,	"",6) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_WIDTH2_DB,	"",12) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DEPTH2_DB,	"",6) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_THROAT_DB,	"",6) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_TRANS_L_DB,	"",12) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_CP_OFFSET_DB,	"",0.0625) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DUCT_THICK_DB,	"",0.1) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_DUCT_MATERIAL_AN,"Steel",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_MAX_DEPTH_DB,	"",18) ;
                break; /* end TR179801141 */
	case VR_RWAY:
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_SHAPE_IN,	"",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_WIDTH1_DB,	"",12) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DEPTH1_DB,	"",6) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_WIDTH2_DB,	"",12) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DEPTH2_DB,	"",6) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_THROAT_DB,	"",6) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_TRANS_L_DB,	"",12) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_CP_OFFSET_DB,	"",0.0625) ;
		SET_ATTR( *NbAttr,      	AC_ATTRIB_DOUBLE,
			  VR_N_CORN_RAD_DB,  	"",1.0) ;

		/* Below lines modified/added by Anand for CR 179900491 */
		{
		    IGRchar	AttrName_NoTier[25], AttrName_TierSp[25];

		    VR_Build_Tier_Str( 1, 0, AttrName_TierSp, AttrName_NoTier);
		    __DBGpr_str(" AttrName_NoTier",AttrName_NoTier);
		    __DBGpr_str(" AttrName_TierSp",AttrName_TierSp);

		    SET_ATTR( *NbAttr,      	AC_ATTRIB_DOUBLE,
			      AttrName_NoTier,	"",1.0) ;
		    SET_ATTR( *NbAttr,      	AC_ATTRIB_TEXT,
			      AttrName_TierSp,	"6.0",0.0) ;

		    VR_Build_Tier_Str( 2, 0, AttrName_TierSp, AttrName_NoTier);
		    __DBGpr_str(" AttrName_NoTier",AttrName_NoTier);
		    __DBGpr_str(" AttrName_TierSp",AttrName_TierSp);

		    SET_ATTR( *NbAttr,      	AC_ATTRIB_DOUBLE,
			      AttrName_NoTier,	"",1.0) ;
		    SET_ATTR( *NbAttr,      	AC_ATTRIB_TEXT,
			      AttrName_TierSp,	"6.0",0.0) ;
		}
		/* Above lines modified/added by Anand for CR 179900491 */

		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_DUCT_THICK_DB,	"",0.1) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_TEXT,
			  VR_N_DUCT_MATERIAL_AN,"Steel",0) ;
		SET_ATTR( *NbAttr,		AC_ATTRIB_DOUBLE,
			  VR_N_MAX_DEPTH_DB,	"",18) ;
                /* TR179801141 */
		SET_ATTR( *NbAttr,      	AC_ATTRIB_TEXT,
			  VR_N_CLASS_AN,  	"VEND1",0) ;
		break ;
	
	  case VR_ELECTRIC :
                SET_ATTR( *NbAttr,              AC_ATTRIB_DOUBLE,
			  VR_N_PID_SCALE_DB,  	"",1.0) ;
		break;

	}/* end switch on product */

	/*"Nb attr = %d \n",*NbAttr */

#undef	SET_ATTR

	return OM_S_SUCCESS ;

} /* VRinit_attributes */
/*---------------------------------------------------------------------------*/

IGRlong VRInitAttributes( Product, CollectId, attribute_name )

IGRint		Product;
struct	GRid	*CollectId;
IGRchar 	attribute_name[DI_PATH_MAX];

/*.VRInitAttributes*/
{
  IGRint		i, NbCollect;
  IGRlong		status, msg, retcode,retmsg;
  IGRshort		listsize, *code_num;
  IGRchar 		*codelist, *speclist;
  IGRdouble		*npdlist;
  struct ACrg_coll	Collection[VR_MAX_ATTR];

  SetProc( Fn VRInitAttributes ); Begin 

  status = OM_S_SUCCESS;
  
  strcpy( Collection[0].name, VR_N_TAG_NUMBER_AN );
  Collection[0].desc.type = AC_ATTRIB_TEXT;
  strcpy( Collection[0].desc.value.att_txt, "" );    
  if( Product == VR_RWAY ) //added for CR179901003
  {
	NbCollect = 16;

	strcpy( Collection[1].name, VR_N_CLASS_AN );
  	Collection[1].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[1].desc.value.att_txt, "VEND1" );

        strcpy( Collection[2].name, VR_N_WIDTH1_DB );
        Collection[2].desc.type = AC_ATTRIB_DOUBLE;
        Collection[2].desc.value.att_exp = 12.0;

        strcpy( Collection[3].name, VR_N_DEPTH1_DB );
        Collection[3].desc.type = AC_ATTRIB_DOUBLE;
        Collection[3].desc.value.att_exp = 6.0;

        strcpy( Collection[4].name, VR_N_WIDTH2_DB );
        Collection[4].desc.type = AC_ATTRIB_DOUBLE;
        Collection[4].desc.value.att_exp = 12.0;

        strcpy( Collection[5].name, VR_N_DEPTH2_DB );
        Collection[5].desc.type = AC_ATTRIB_DOUBLE;
        Collection[5].desc.value.att_exp = 6.0;

        strcpy( Collection[6].name, VR_N_DUCT_MATERIAL_AN );
        Collection[6].desc.type = AC_ATTRIB_TEXT;
        strcpy( Collection[6].desc.value.att_txt, "Steel" );

        strcpy( Collection[7].name, VR_N_DUCT_THICK_DB );
        Collection[7].desc.type = AC_ATTRIB_DOUBLE;
        Collection[7].desc.value.att_exp = 0.1;

 	strcpy( Collection[8].name, VR_N_THROAT_DB );
  	Collection[8].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[8].desc.value.att_exp = 1.0;

 	strcpy( Collection[9].name, VR_N_TRANS_L_DB );
  	Collection[9].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[9].desc.value.att_exp = 1.0;

 	strcpy( Collection[10].name, VR_N_CORN_RAD_DB );
  	Collection[10].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[10].desc.value.att_exp = 1.0;

 	strcpy( Collection[11].name, VR_N_UNIT_AN );
  	Collection[11].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[11].desc.value.att_txt, "" );

 	strcpy( Collection[12].name, VR_N_ZONE_AN );
  	Collection[12].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[12].desc.value.att_txt, "bloc1" );

 	strcpy( Collection[13].name, VR_N_APPRV_STAT_AN );
  	Collection[13].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[13].desc.value.att_txt, "Not Approved" );

 	strcpy( Collection[14].name, VR_N_CONSTR_STAT_AN );
  	Collection[14].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[14].desc.value.att_txt, "New" );

	strcpy( Collection[15].name, VR_N_CP_OFFSET_DB );
  	Collection[15].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[15].desc.value.att_exp = 1.0;
  }
  else if( Product == VR_HVAC )  
  {
  	NbCollect = 24;

  	strcpy( Collection[1].name, VR_N_SERVICE_AN );
  	Collection[1].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[1].desc.value.att_txt, "Exhaust" );    

	strcpy( Collection[2].name, VR_N_WIDTH1_DB );
  	Collection[2].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[2].desc.value.att_exp = 12.0;    

	strcpy( Collection[3].name, VR_N_DEPTH1_DB );
  	Collection[3].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[3].desc.value.att_exp = 6.0;    

	strcpy( Collection[4].name, VR_N_WIDTH2_DB );
  	Collection[4].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[4].desc.value.att_exp = 12.0;    

	strcpy( Collection[5].name, VR_N_DEPTH2_DB );
  	Collection[5].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[5].desc.value.att_exp = 6.0;    

	strcpy( Collection[6].name, VR_N_FLOW_RATE_DB );
  	Collection[6].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[6].desc.value.att_exp = 1.0;    

	strcpy( Collection[7].name, VR_N_CLASS_AN );
  	Collection[7].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[7].desc.value.att_txt, "N1" );

	strcpy( Collection[8].name, VR_N_PRESS_CLASS_AN );
  	Collection[8].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[8].desc.value.att_txt, "Low" );

	strcpy( Collection[9].name, VR_N_SIZE_METHOD_AN );
  	Collection[9].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[9].desc.value.att_txt, "Velocity" );

	strcpy( Collection[10].name, VR_N_FLOW_RATE_DB );
  	Collection[10].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[10].desc.value.att_exp = 1.0;    

	strcpy( Collection[11].name, VR_N_MAX_VELOC_DB );
  	Collection[11].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[11].desc.value.att_exp = 2.0;    

	strcpy( Collection[12].name, VR_N_MAX_DEPTH_DB );
  	Collection[12].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[12].desc.value.att_exp = 18.0;    

	strcpy( Collection[13].name, VR_N_DUCT_MATERIAL_AN );
  	Collection[13].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[13].desc.value.att_txt, "Steel" );

	strcpy( Collection[14].name, VR_N_DUCT_THICK_DB );
  	Collection[14].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[14].desc.value.att_exp = 0.1; 

	strcpy( Collection[15].name, VR_N_INSUL_THK_DB );
  	Collection[15].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[15].desc.value.att_exp = 0.626; 

 	strcpy( Collection[16].name, VR_N_INSUL_TYPE_AN );
  	Collection[16].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[16].desc.value.att_txt, "N" );
  
 	strcpy( Collection[17].name, VR_N_ZONE_AN );
  	Collection[17].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[17].desc.value.att_txt, "bloc1" );

 	strcpy( Collection[18].name, VR_N_PREP_G_IN );
  	Collection[18].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[18].desc.value.att_exp = 0;

 	strcpy( Collection[19].name, VR_N_PREPS_G_IN );
  	Collection[19].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[19].desc.value.att_txt, "FF" );

	// added the following attributes for HVAC Acoustical Insulation. Alwin
	strcpy( Collection[20].name, VR_N_ACST_INSUL_THK_DB );
  	Collection[20].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[20].desc.value.att_exp = 0.0; 

 	strcpy( Collection[21].name, VR_N_ACST_INSUL_TYPE_AN );
  	Collection[21].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[21].desc.value.att_txt, "ACST" );

 	strcpy( Collection[22].name, VR_N_ACST_DB );
  	Collection[22].desc.type = AC_ATTRIB_DOUBLE;
  	Collection[22].desc.value.att_exp = 0.0;

	// for CR179901873
  	strcpy( Collection[23].name, VR_N_UNIT_AN );
  	Collection[23].desc.type = AC_ATTRIB_TEXT;
  	strcpy( Collection[23].desc.value.att_txt, "" );    
  }
  else
  {
	  NbCollect = 19;

	  /*| -- Get Nozzle Service List and initialize form -- */
	  status = VRget_code_list_set( &retmsg, VR_PIPING, VR_P_NOZ_SRV_LSTNUM,
	  			&listsize , &codelist, &code_num, NULL);
	  if( status & 1 )
	  {
	  /***** Note that only the first value is in the collection */
		  strcpy( Collection[1].name, VR_N_SERVICE_AN );
		  Collection[1].desc.type = AC_ATTRIB_TEXT;
		  for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
			    i+=VR_SHORT_CODETEXT_SIZE)
		  {
		     if (codelist [i])
		     {
			  strcpy(Collection[1].desc.value.att_txt,&codelist[i]);
			  break;
		     }
		  }
	  }

	  /*| -- Get Nominal Size List and initialize form -- */
	  status = VRget_npd_list ( &retmsg, VR_PIPING, "NOZZLE",  &listsize , 
					&npdlist, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[2].name,  VR_N_GDIAMETER_DB);  
		Collection[2].desc.type = AC_ATTRIB_DOUBLE;
		Collection[2].desc.value.att_exp = npdlist[0];
	   }


	  /*| -- Get End Condition List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
					VR_P_END_COND_LSTNUM, &listsize , 
					&codelist, &code_num, NULL);
	  if( status & 1 )
	  {
	      strcpy( Collection[3].name, VR_N_PREPS_G_IN );
	      Collection[3].desc.type = AC_ATTRIB_TEXT;
	      for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				i+=VR_SHORT_CODETEXT_SIZE)

	      {
		  if (codelist [i])
		  {
		       strcpy( Collection[3].desc.value.att_txt,&codelist[i]);
		       break;
		  }
	      }
	  }

	  /*| -- Get Pressure Class List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
					VR_P_PRES_CLASS_LSTNUM, &listsize , 
					&codelist, &code_num, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[4].name, VR_N_RATINGS_G_DB );
		Collection[4].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		    if (codelist [i])
		    {
		       strcpy( Collection[4].desc.value.att_txt,&codelist[i]);
		       break;
		    }
		}
	  }

	  /*| -- Get Schdl/Thick ovrd List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_SCHED_THK_LSTNUM, &listsize, &codelist, 
				&code_num, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[5].name, VR_N_THICK_OVER_AN );
		Collection[5].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		    if (codelist [i])
		    {
			strcpy(Collection[5].desc.value.att_txt, &codelist[i]); 
			break;
		    }
		}
	  }

	  /*| -- Get End Standard List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
					VR_P_END_STD_LSTNUM, 
					&listsize , &codelist, &code_num, NULL);  
	  if( status & 1 )
	  {
		strcpy( Collection[6].name, VR_N_END_STD_G_IN );
		Collection[6].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		    if (codelist [i])
		    {
		      strcpy( Collection[6].desc.value.att_txt, &codelist[i] ); 
		      break;
		    }
		}
	  } 


	  /*| -- Get Insul Type List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg, VR_PIPING, 
				VR_P_INSUL_TYPE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[7].name, VR_N_INSUL_TYPE_AN );
		Collection[7].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		    if (codelist [i])
		    {
		      strcpy( Collection[7].desc.value.att_txt, &codelist[i] );
		      break;
		    }
		}
	  }

	  /*| -- Get Tracing Type List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_TRACE_TYPE_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[8].name, VR_N_TRACING_CODE_AN );
		Collection[8].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		    if (codelist [i])
		    {
		      strcpy( Collection[8].desc.value.att_txt, &codelist[i] ); 
		      break;
		    }
		}
	  }

	  /*| -- Get Approval Status List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_APP_STS_LSTNUM,
				 &listsize , &codelist, &code_num, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[9].name, VR_N_APPRV_STAT_AN );
		Collection[9].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		    if (codelist [i])
		    {
		      strcpy( Collection[9].desc.value.att_txt, &codelist[i] );
		      break;
		    }
		}
	  }

	  /*| -- Get Constrained Status List and initialize form -- */
	  status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_CONST_STS_LSTNUM, 
				 &listsize , &codelist, &code_num, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[10].name, VR_N_CONSTR_STAT_AN );
		Collection[10].desc.type = AC_ATTRIB_TEXT;
		for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				  i+=VR_SHORT_CODETEXT_SIZE)
		{
		  if (codelist [i])
		  {
		      strcpy( Collection[10].desc.value.att_txt, &codelist[i] );
		      break;
		  }
		}
	  }

	  /*| -- Get Nominal Size List and initialize form -- */
	  status = VRget_npd_list ( &retmsg, VR_PIPING, "NOZZLE",  
				&listsize , &npdlist, NULL);
	  if( status & 1 )
	  {
		strcpy( Collection[11].name,  VR_N_RDIAMETER_DB);
		Collection[11].desc.type = AC_ATTRIB_DOUBLE;
		Collection[11].desc.value.att_exp = npdlist[0];
	   }


	   /*| -- Get Fluid List and initialize form -- */
	   status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_FLUID_CODE_LSTNUM, 
				   &listsize , &codelist, &code_num, NULL);
	    if( status & 1 )
	    {
		  strcpy( Collection[12].name, VR_N_FLUID_CODE_AN );
		  Collection[12].desc.type = AC_ATTRIB_TEXT;
		  for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				    i+=VR_SHORT_CODETEXT_SIZE)
		  {
		    if (codelist [i])
		    {
		      strcpy( Collection[12].desc.value.att_txt, &codelist[i] );
		      break;
		    }
		  }
	    }


	    /*| -- Get End Condition List and initialize form -- */
	    status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_END_COND_LSTNUM, 
				   &listsize , &codelist, &code_num, NULL);
	    if( status & 1 )
	    {
		  strcpy( Collection[13].name, VR_N_PREP_G_IN );
		  Collection[13].desc.type = AC_ATTRIB_DOUBLE;
		  for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				    i+=VR_SHORT_CODETEXT_SIZE)
		  {
		    if (codelist[i])
		    {
		      Collection[13].desc.value.att_exp = 
					(IGRdouble) code_num[i/9];
		      break;
		    }
		  }
	    }

	    /*| -- Get Spec Name List and initialize form -- */
	    status = VRget_spec_list (&retmsg,  VR_PIPING, &listsize , 
					&speclist, NULL);
	    if( status & 1 )
	    {
		  strcpy( Collection[14].name, VR_N_CLASS_AN );
		  Collection[14].desc.type = AC_ATTRIB_TEXT;

		  for(i=0;;i++)
		  {
		    if (speclist[i])
		    {
		      strcpy( Collection[14].desc.value.att_txt, &speclist[i] );
		      break;
		    }
		  }
	    }

	    /*| -- Get Paint Type List and initialize form -- */
	    status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_PAINT_TYPE_LSTNUM, 
			   &listsize , &codelist, &code_num, NULL);
	    if( status & 1 )
	    {
		  strcpy( Collection[15].name, VR_N_PAINT_CODE_AN );
		  Collection[15].desc.type = AC_ATTRIB_TEXT;
		  for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				    i+=VR_SHORT_CODETEXT_SIZE)
		  {
		    if (codelist [i])
		    {
		      strcpy( Collection[15].desc.value.att_txt, &codelist[i] );
		      break;
		    }
		  }
	    }

	    /*| -- Get Weigth Group List and initialize form -- */
	    status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
					VR_P_WEIGHT_GRP_LSTNUM, 
				   &listsize , &codelist, &code_num, NULL);
	    if( status & 1 )
	    {
		  strcpy( Collection[16].name, VR_N_WEIGHT_GRP_IN );
		  Collection[16].desc.type = AC_ATTRIB_TEXT;
		  for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				    i+=VR_SHORT_CODETEXT_SIZE)
		  {
		    if (codelist [i])
		    {
		      strcpy( Collection[16].desc.value.att_txt, &codelist[i] );
		      break;
		    }
		  }
	    }

	    /*| -- Get Change no List and initialize form -- */
	    status = VRget_code_list_set ( &retmsg,  VR_PIPING, 
				VR_P_CHANGE_NO_LSTNUM, 
				   &listsize , &codelist, &code_num, NULL);
	    if( status & 1 )
	    {
		  strcpy( Collection[17].name, VR_N_CHG_REQ_NUM_IN);
		  Collection[17].desc.type = AC_ATTRIB_TEXT;
		  for(i=0;i<listsize*VR_SHORT_CODETEXT_SIZE;
				    i+=VR_SHORT_CODETEXT_SIZE)
		  {
		    if (codelist [i])
		    {
		      strcpy( Collection[17].desc.value.att_txt, &codelist[i] );
		      break;
		    }
		  }
	    }

	    // for CR179901873
	    strcpy( Collection[18].name, VR_N_UNIT_AN );
	    Collection[18].desc.type = AC_ATTRIB_TEXT;
	    strcpy( Collection[18].desc.value.att_txt, "" );    
  }

  /*"CollectId->objid = %d  %d\n",CollectId->objid,CollectId->osnum*/
  if ( CollectId->objid == NULL_OBJID )
  {
  	status = om$construct (
			classname = "ACdyn_col",
			osnum     = CollectId->osnum,
			msg 	  = message ACrg_collect.ACcreate (
						&retcode, attribute_name ),
			p_objid   = &(CollectId->objid));
  	as$status ();

  	status = om$send( msg      = message NDnode.NDchg_state
						((IGRchar) ND_DEL_NO_CH,
						 (IGRchar) ND_DEL_NO_CH),
		    	  senderid = NULL_OBJID,
		    	  targetid = CollectId->objid,
		    	  targetos = CollectId->osnum );
  	as$status( action = RET_STATUS );

  	/*"Create Collection = %d %d \n",CollectId->objid, CollectId->osnum*/

         status = 
	 om$send( msg = message ACrg_collect.ACset_list_attribute( &retcode, 
				NbCollect, Collection ),
		    	  senderid = NULL_OBJID,
		    	  targetid = CollectId->objid,
		    	  targetos = CollectId->osnum );
    	as$status( action = RET_STATUS );
  }
  else
  {
	status = VR$ModifyCollection( p_msg                   = &msg,
                                      Operation               = VR_MERGE_COLL,
				      p_ParamsListToModify    = Collection,
         			      NbParamsToModify        = NbCollect,
                                      p_OutputCollectionId    = CollectId );
     	as$status();
     	as$status( sts = msg );

  }

  End
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/

/******************************************************************************/
/*									      */
/*	This function is designed to perform a initialization, a store,       */
/*	a replace or a retrieve operation on the current active	parameters    */
/*	box.								      */
/*									      */
/* 	Operation can be :				                      */
/*		- VR_INIT : Initialize system parameters with default values  */
/*		            or user parameters with given names and values.   */
/*			    If parameters exist nothing will be done.         */
/*									      */
/*		- VR_STORE : Create a new active parameters box ( system      */
/*                           or user ). The old parameters box already        */
/*                           exist.               			      */
/*                             						      */
/*		- VR_REPLACE : Given a parameters box, this one will be the   */
/*		               new active parameters box.                     */
/*		               						      */
/*		- VR_RETRIEVE : Return the active parameters box.             */
/*									      */
/*	Arguments :							      */
/*		IN : operation		IGRchar		Type of operation :   */
/*							 VR_INIT,	      */
/*						         VR_STORE,            */
/*						         VR_RETRIEVE,	      */
/*						         VR_REPLACE.	      */
/*		IN : mode		IGRchar		Type of parameters    */
/*		                                        box :		      */
/*		                                         VR_SYSTEM_MODE or    */
/*		                                         VR_USER_MODE.        */
/*		IN : update_flag	IGRchar		Update form or not :  */
/*		 					 VR_UPDATE,           */
/*		 					 VR_NOUPDATE.         */
/*		IN : *form_to_update    struct GRid     Id of command which   */
/*							to send message       */
/*							'update_form'.        */
/*		IN : VRproduct		IGRchar         Product :             */
/*							 VR_HVAC,	      */
/*							 VR_PIPING,	      */
/*							 VR_RWAY.	      */
/*		IN : number		IGRint		Number of attributes. */
/*		IN : *ListAttr		struct ACrg_collAttributes list.      */
/*									      */
/*		IN  : for working OS.					      */
/*		OUT : for VR_INIT, 					      */
/*		          VR_STORE, 					      */
/*		          VR_RETRIEVE.					      */
/*		      *act_params_id	struct GRid	Id of collection.     */
/*									      */
/*	Return values : 						      */
/*		- OM_S_SUCCESS	    : Successfull operation.		      */
/*		- OM_E_INVARG	    : Invalid arguments.		      */
/*		- OM_E_NODYNMEM     : No dynamic memory.		      */
/*		- DIR_S...	    : Directory error. 		              */
/*									      */
/******************************************************************************/

long	VRactive_params(  operation,
		  	mode,
		  	update_flag,
		  	form_to_update,
		  	VRproduct,
		  	act_params_id)

IGRint	 		operation ;
IGRint	 		mode ;
IGRint	 		update_flag ;
struct GRid		*form_to_update ;
IGRint			VRproduct ;
struct	GRid		*act_params_id ;
/*.VRactive_params*/
{

	IGRchar 		path_name[DI_PATH_MAX],
				product_name[DI_PATH_MAX],
				attribute_name[DI_PATH_MAX],
				*psColName="?", /* collection name */
				*psDirName="?"; /* directory name */
	IGRint			size,
				ret_size,
				nb_of_attr ;
	IGRlong 		status,
				msg ;
	IGRboolean		product_dir_exist = FALSE,
				attribute_exist   = FALSE ;
	struct GRid		VRcomm_obj,
				dir_entry;
	struct GRmd_env 	mod_env ;

	/*|Checking arguments */


	if ( mode != VR_USER_MODE	&&
	     mode != VR_SYSTEM_MODE	&&
	     mode != VR_NOZZLE_MODE	||
	     !act_params_id		||
	     operation != VR_INIT	&&
	     operation != VR_RETRIEVE	&&
	     operation != VR_REPLACE	||
	     VRproduct != VR_PIPING	&&
	     VRproduct != VR_HVAC	&&
	     VRproduct != VR_RWAY	&&
	     VRproduct != VR_ELECTRIC &&
	     VRproduct != VR_FIBER  )	return OM_E_INVARG ;

	/*
	 * Retrieve path name.
	 */
	/*"working OS : %d\n", act_params_id->osnum*/
	status =
	di$give_pathname( osnum    = act_params_id->osnum,
			  pathname = path_name ) ;

	if ( status != DIR_S_SUCCESS )
	{
		di$report_error(sts	= status,
				comment	= "error in give pathname" ) ;
		return OM_E_INVARG ;
	}

	/*
	 * init product and attribute directory.
	 */
	switch( VRproduct )
	{

		/* ----------- */
		case VR_PIPING	:

		psDirName = DIR_NAME_PIPING;
		if      ( mode == VR_SYSTEM_MODE )
			psColName = "psystem";
		else if ( mode == VR_USER_MODE )
			psColName = "puser";
		else if ( mode == VR_NOZZLE_MODE )
			psColName = "pnozzle";
		break ;

		/* ----------- */
		case VR_HVAC	:
		
		psDirName = DIR_NAME_HVAC;
		if      ( mode == VR_SYSTEM_MODE )
			psColName = "hsystem";
		else if ( mode == VR_USER_MODE )
			psColName = "huser";
		else if ( mode == VR_NOZZLE_MODE )
			psColName = "hnozzle";
		break ;

		/* ----------- */
		case VR_RWAY    :

		psDirName = DIR_NAME_RWAY;
		/*** for CR179901003
		psColName = mode == VR_SYSTEM_MODE ?
			    "csystem" : "cuser";
		***/
		if      ( mode == VR_SYSTEM_MODE )
			psColName = "csystem";
		else if ( mode == VR_USER_MODE )
			psColName = "cuser";
		else if ( mode == VR_NOZZLE_MODE )
			psColName = "cnozzle";
		break ;

		/* ----------- */
		case VR_ELECTRIC :

		psDirName = DIR_NAME_ELEC;
		psColName = mode == VR_SYSTEM_MODE ?
			    "esystem" : "euser";
		break ;

		/* ----------- */
		case VR_FIBER :

		psDirName = DIR_NAME_FOPTIC;
		psColName = mode == VR_SYSTEM_MODE ?
			    "fosystem" : "fouser";
		break ;

		default 	:
			/*"Error in Product Type VRproduct %d", VRproduct  */
			return OM_E_INVARG ;

	}/* end switch on product */

	status =
	DIstmcpy(attribute_name,
		 path_name,
		 psDirName,
		 psColName,
		 NULL ) ;
	if( !(status & 1) )
	{
		di$report_error(  sts		= status,
				  comment	= "error in DIstmcpy" ) ;
		return OM_E_ABORT ;
	}

	status =
	DIstmcpy(product_name,
		 path_name,
		 psDirName,
		 NULL ) ;

	if( !(status & 1) )
	{
		di$report_error(  sts		= status,
				  comment	= "error in DIstmcpy" ) ;
		return OM_E_ABORT ;
	}

	/*"attributes directory : %s\n", attribute_name */
	/*"product directory	: %s\n", product_name */

	/*
	 * See if product directory exist.
	 */
	status =
	di$translate (  objname = product_name,
			osnum	= act_params_id->osnum,
			p_objid = &dir_entry.objid,
			p_osnum = &dir_entry.osnum ) ;


	switch( status )
	{

		case DIR_S_SUCCESS	  :
			/*|Product name exist*/
			product_dir_exist = TRUE ;
			break ;

		case DIR_W_NAME_NOT_FOUND :
			/*|Product name doesn't exist -> create it*/
			status =
			di$mkdir( dirname = product_name,
				  osnum   = act_params_id->osnum ) ;

			if( status != DIR_S_SUCCESS ) {
				/*|ERROR : Cannot create directory*/
				di$report_error( sts = status ) ;
				return status ;
			}
			break ;

		default :
			/*|ERROR : in di$translate*/
			return status ;
	}

	/*
	 * See if attributes directory exist.
	 */
	if( product_dir_exist )
	{
		status =
		di$translate(objname = attribute_name,
			     osnum   = act_params_id->osnum,
			     p_objid = &dir_entry.objid,
			     p_osnum = &dir_entry.osnum ) ;

		switch( status ) {
			case DIR_S_SUCCESS 		:
				/*|attribute name exist*/
				attribute_exist = TRUE ;
				break ;
				
			case DIR_W_NAME_NOT_FOUND	:
				/*|attribute name doesn't exist -> create it*/
				attribute_exist = FALSE ;
				break ;
				
			default 			:
				/*|ERROR : in di$translate*/
				return status ;
		}
	}

	/*
	 * Do operation.
	 */
	switch( operation ) {

		case VR_INIT	:

		{
			struct ACrg_coll	TmpAttr[VR_MAX_ATTR];
		/*
		 * See if attributes directory exist.
		 */
		if( attribute_exist )
		{
			/*"Attributes was already initialized\n"*/
			*act_params_id = dir_entry ;
			/*"ACrg_collect found : [%d,%d]\n",act_params_id->osnum, act_params_id->objid */
			return OM_S_SUCCESS ;
		}
		/*|Attributes wasn't initialized*/
		if( mode == VR_NOZZLE_MODE ) {
			act_params_id->objid = NULL_OBJID;
			status = VRInitAttributes
			( VRproduct, act_params_id, attribute_name);
			return OM_S_SUCCESS ;
		}

		/*
		 * Create collection.
		 */
		/*|create collection*/

		status =
		om$construct ( classid = OPP_ACrg_collect_class_id,
				p_objid = &(act_params_id->objid),
				osnum	= act_params_id->osnum,
			msg	= message ACrg_collect.ACcreate(
				    &msg,attribute_name ) ) ;

		as$status( action = RET_STATUS ) ;
		as$status( action = RET_STATUS, sts = msg ) ;


		/*
		 * Init attributes with default values for system mode.
		 */
		if( mode == VR_SYSTEM_MODE )
		{
			/*
			 * Retrieve default values.
			 */
			status = VRinit_attributes( VRproduct,
						    TmpAttr,
						    &nb_of_attr ) ;
			as$status( action = RET_STATUS ) ;


		}
		else
		{
			/* Initialize list of user attributes */
			if ( VRproduct == VR_ELECTRIC ||
				VRproduct == VR_FIBER )
			{
				nb_of_attr = 4;
				strcpy ( TmpAttr[0].name, "compart_x" );
				TmpAttr[0].desc.type = AC_ATTRIB_TEXT;
				strcpy(TmpAttr[0].desc.value.att_txt,"");

				strcpy ( TmpAttr[1].name, "deck_x" );
				TmpAttr[1].desc.type = AC_ATTRIB_TEXT;
				strcpy(TmpAttr[1].desc.value.att_txt,"");

				strcpy ( TmpAttr[2].name, "original" );
				TmpAttr[2].desc.type = AC_ATTRIB_DOUBLE;
				TmpAttr[2].desc.value.att_exp=1;

				strcpy ( TmpAttr[3].name, "group" );
				TmpAttr[3].desc.type = AC_ATTRIB_TEXT;
				strcpy(TmpAttr[3].desc.value.att_txt,"");

			} else {
				nb_of_attr = 1;
				strcpy ( TmpAttr[0].name, "env" );
				TmpAttr[0].desc.type = AC_ATTRIB_DOUBLE;
				TmpAttr[0].desc.value.att_exp = 1.0;
			}
		}

		/*
		 * Add attributes to collection.
		 */

		status =
		VR$ModifyCollection (
			p_msg = &msg,
			Operation = VR_MERGE_COLL,
			p_ParamsListToModify = TmpAttr,
			NbParamsToModify = nb_of_attr,
			p_OutputCollectionId = act_params_id );
		as$status ( action = RET_STATUS );

		}/* end VR_INIT */

		break ;

		case VR_REPLACE :
		/*|Operation -> replace attributes */

		/*
		 * Retrieve module env.
		 */
		size = sizeof( struct GRmd_env ) ;

		gr$get_module_env( msg	  = &msg,
				   sizbuf = &size,
				   buffer = &mod_env,
				   nret   = &ret_size );

		/*
		 * See if attributes directory exist.
		 */
		status =
		om$send( msg = message NDnode.NDchg_state(
					( (IGRchar)  ND_DEL_NO_CH ),
					( (IGRchar) ~ND_DEL_NO_CH ) ),
			senderid = NULL_OBJID,
			targetid = act_params_id->objid,
			targetos = act_params_id->osnum ) ;
		as$status( action = RET_STATUS ) ;

	if( attribute_exist )
		{
			/* unname collection */

			status =
			om$send( msg = message ACrg_collect.GRchgname
						( &msg, &mod_env, "" ),
				senderid = NULL_OBJID,
				targetid = dir_entry.objid,
				targetos = dir_entry.osnum ) ;
			as$status( action = RET_STATUS ) ;

			status =
			om$send( msg = message NDnode.NDchg_state(
						( (IGRchar) ND_DEL_NO_CH ),
						( (IGRchar) ND_DEL_NO_CH ) ),
				senderid = NULL_OBJID,
				targetid = dir_entry.objid,
				targetos = dir_entry.osnum ) ;
			as$status( action = RET_STATUS ) ;

		}
		status = om$send( msg = message ACrg_collect.GRchgname(
						       &msg,
						       &mod_env,
						       attribute_name ),
				  senderid = act_params_id->objid,
				  targetid = act_params_id->objid,
				  targetos = act_params_id->osnum ) ;

		as$status( action = RET_STATUS ) ;


		/*
		 * Change name of collection given.
		 */

		break ;

		case VR_RETRIEVE :

		/*
		 * See if attributes directory exist.
		 */
		if( attribute_exist ) {
			/*|Attributes exist*/
			*act_params_id = dir_entry ;
		}
		else
		{
			/*|No attributes before*/
			VRactive_params(  VR_INIT,
	  				  mode,
	  				  VR_NOUPDATE,
	  				  form_to_update,
	  				  VRproduct,
	  				  act_params_id );
		}
		break ;

	}/* end of switch (operation) */

	/*TBD upd form for electrical and F-Optic */

	/*
	 * Update form.
	 */
	 if ( update_flag == VR_UPDATE ) {
	 	/*|Update form*/

		  if( !form_to_update ) {
		  	/*
		  	 * Retrieve objid of command object in transient
		  	 * directory.
		  	 */
		        status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
					           pathname = path_name ) ;

   		        if ( status != DIR_S_SUCCESS ) {
				/*|ERROR : in give pathname */
				return OM_E_ABORT ;
      			}

		    	switch( VRproduct ) {
				case VR_PIPING	:
	 				strcat( path_name, COMM_NAME_PIPING ) ;
					break ;

				case VR_HVAC	:
	 				strcat( path_name, COMM_NAME_HVAC ) ;
					break ;

				case VR_RWAY	:
	 				strcat( path_name, COMM_NAME_CABLE ) ;
					break ;
		        }

      		        /*"Command path name : %s \n", path_name */
			
      		        status = di$translate ( objname = path_name,
				                osnum   = OM_Gw_TransOSnum_0,
			                        p_objid = &VRcomm_obj.objid,
			                        p_osnum = &VRcomm_obj.osnum ) ;

      			if ( status != DIR_S_SUCCESS ) {
      				/*|ERROR : Command object not found*/
      				return OM_E_ABORT ;
			}
			
    		 } else VRcomm_obj = *form_to_update ;

		/*"Command object : [%d,%d]\n", VRcomm_obj.osnum, VRcomm_obj.objid*/
		
		/*
		 * Update form.
		 */


		if( mode == VR_SYSTEM_MODE )
		{
			om$send( msg = message VRActParam.VRDeleteAttr
	                                ( VR_SYSTEM_ATTR ),
				   senderid = VRcomm_obj.objid,
				   targetid = VRcomm_obj.objid,
				   targetos = VRcomm_obj.osnum ) ;
			om$send( msg = message VRActParam.VRInitAttr
	                                ( VR_SYSTEM_ATTR ),
				   senderid = VRcomm_obj.objid,
				   targetid = VRcomm_obj.objid,
				   targetos = VRcomm_obj.osnum ) ;
			om$send( msg = message VRActParam.VRUpdSysForm
				(),
			   senderid = VRcomm_obj.objid,
			   targetid = VRcomm_obj.objid,
			   targetos = VRcomm_obj.osnum ) ;
		}
		else
		{
			om$send( msg = message VRActParam.VRDeleteAttr
	                                ( VR_USER_ATTR ),
				   senderid = VRcomm_obj.objid,
				   targetid = VRcomm_obj.objid,
				   targetos = VRcomm_obj.osnum ) ;
			om$send( msg = message VRActParam.VRInitAttr
	                                ( VR_USER_ATTR ),
				   senderid = VRcomm_obj.objid,
				   targetid = VRcomm_obj.objid,
				   targetos = VRcomm_obj.osnum ) ;
			om$send( msg = message VRActParam.VRUpdUsrForm
                                (),
			   senderid = VRcomm_obj.objid,
			   targetid = VRcomm_obj.objid,
			   targetos = VRcomm_obj.osnum ) ;
		}

	}

  	return OM_S_SUCCESS ;

} /* VRactive_params */

/******************************************************************************/
/*									      */
/*	This function translate a list of attribute names and attributes      */
/*	values to a list of ACrg_collect structure.			      */
/*									      */
/*	Arguments :							      */
/*		IN : **attribute_names	    IGRchar   Attributes names.       */
/*		IN : **attribute_values     IGRchar   Attributes values.      */
/*		IN : nb_of_attributes	    IGRint    Number of attributes.   */
/*		OUT : **list_attr	    struct ACrg_collect 	      */
/*						      list retourned.	      */
/*									      */
/*	Notes : 							      */
/*		list_attr is allocated by the function and should be	      */
/*		freeing by the user.					      */
/*									      */
/*	Return values : 						      */
/*		- OM_S_SUCCESS	    : Successfull operation.		      */
/*		- OM_E_NODYNMEM     : No dynamic memory.		      */
/*		- OM_E_INVARG	    : Invalid arguments.		      */
/*									      */
/******************************************************************************/

/*----------------------------------------------------------------------------*/
VRAsciiToAttr( attribute_name,
	       attribute_value,
	       attr )

IGRchar 		*attribute_name ;
IGRchar 		*attribute_value ;
struct ACrg_coll	*attr ;

/*.VRAsciiToAttr*/
{
	IGRchar 		*p ;
	IGRboolean		have_double ;
	IGRdouble		value ;
	
	/*
	 * Checking arguments.
	 */
	if( !attribute_name 	||
	    !attribute_value 	||
	    !attr		)
	{
		
		/*|Invalid arguments */
		return OM_E_INVARG ;
	}

	/*
	 * Convert
	 */

	/*"name = %s\n", attribute_name*/

	strcpy( attr->name, attribute_name ) ;

	have_double = TRUE ;

	for( p=attribute_value; *p ; p++ )
	{
		if( *p == '.' || *p == '-' ) continue ;

		if( !isdigit( *p ) )
		{
			have_double = FALSE ;
			break ;
		}
	}

	if( have_double )
	{

		attr->desc.type = AC_ATTRIB_DOUBLE ;

		sscanf( attribute_value, "%lf", &value ) ;

		attr->desc.value.att_exp = value ;

		/*"value = %g\n", attr->desc.value.att_exp*/

	}
	else
	{
		attr->desc.type = AC_ATTRIB_TEXT ;

		strcpy( attr->desc.value.att_txt, 
			    attribute_value ) ;

		/*"text = %s\n", attr->desc.value.att_txt*/

	}

	return OM_S_SUCCESS ;

} /* VRAsciiToAttr */
/*----------------------------------------------------------------------------*/




/**************************************************************************/
/*									  */
/*	fct VRinit_symbology This function initilize active parameter    */
/*      IN			pointer to IGRlong for status of call	  */
/*	IN - OUT		pointer to structure GRsymbology	  	  */
/**************************************************************************/

IGRint VRinit_symbology( msg, symbology )

IGRlong			*msg;
struct GRsymbology	*symbology;

/*.VRinit_symbology */
{
  IGRlong	number_returned;
  IGRlong	size;
  
  /*| VRinit_symbology */

  /*| init with active display */

  size = sizeof( struct IGRdisplay );
  gr$get_active_display(
			msg    = msg,
			sizbuf = &size,
			buffer = &( symbology->display_attr ),
			nret   = &number_returned );

  /*^printf( "after get_active_display, rc%d\n", 
		*msg ); */

  if ( !(*msg&1) )  return OM_E_ABORT;

  /*| init with active level */

  size = sizeof( symbology->level );
  gr$get_active_level( 	msg 	= msg,
			sizbuf 	= &size,
			buffer 	= &( symbology->level ),
			nret   	= &number_returned );

  if ( !(*msg&1) ) return OM_E_ABORT;

 return OM_S_SUCCESS;

}/* end VRinit_symbology */

IGRint VRsymbology(msg,operation,CollId,symbology )

IGRlong			*msg;
IGRint			operation;
struct	GRid		*CollId;
struct  GRsymbology	*symbology;

/*.VRsymbology */
{
  IGRchar			path_name[DI_PATH_MAX];
  IGRint			data_size, status;

  /*"Look for path of osnum %d\n", CollId->osnum */

  if (!symbology ) return OM_E_INVARG;

  status = di$give_pathname( osnum = CollId->osnum,
			     pathname = path_name );

  if ( status != DIR_S_SUCCESS )
  {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return OM_E_INVARG ;
  }

  strcat( path_name, DIR_NAME_SYMB );

  /*"User path name is %s \n", path_name*/

  status = di$translate ( objname = path_name,
			  osnum	  = CollId->osnum,
			  p_objid = &CollId->objid,
			  p_osnum = &CollId->osnum );

  if ( status != DIR_S_SUCCESS )
  {
    if ( status == DIR_W_NAME_NOT_FOUND )
    {
      if( operation == VR_STORE )
      {
        /*| we create the user_data object  */

  	status = om$construct ( classid   = OPP_user_data_class_id,
			  	osnum     = CollId->osnum,
			  	p_objid   = &(CollId->objid));
  	as$status ();

	/*"created user_data %d\n", CollId->objid*/

	status = di$add_name( 	objname = path_name,
				objid   = CollId->objid,
				osnum   = CollId->osnum );
	if ( status != DIR_S_SUCCESS )
	{
		di$report_error( sts = status, comment = "Error : di$add_name" );
	}
	data_size = sizeof ( struct GRsymbology );
	status = om$send( msg = message user_data.set_data( data_size , 
					( char *)symbology ),
		senderid = NULL_OBJID,
		targetid = CollId->objid,
		targetos = CollId->osnum );
      }
      else
         VRinit_symbology( msg, symbology );

     }/* end DIR_W_NAME_NOT_FOUND */
     else
     {
	di$report_error( sts = status, comment = "PROBLEM" );
	VRinit_symbology( msg, symbology );
	return OM_S_SUCCESS;
     }

  }/* end not found in the directory */

 /* Work on existing user_data */

  if ( operation == VR_RETRIEVE )	
   {
	data_size = sizeof( struct GRsymbology );
	status =
	om$send( msg = message user_data.get_data( &data_size, (char **)&symbology ),
			senderid = NULL_OBJID,
			targetid = CollId->objid,
			targetos = CollId->osnum );
   }
  else if ( operation == VR_STORE )
   {
	data_size = sizeof( struct GRsymbology );

	/*| before update data */
	status =
	om$send( msg = message user_data.update_data( data_size,(char *)symbology ),
			senderid = NULL_OBJID,
			targetid = CollId->objid,
			targetos = CollId->osnum );
    }
   else status = OM_E_INVARG;

  return status; 

}/* end VRsymbology */

end implementation CEO_LOCATE ;
