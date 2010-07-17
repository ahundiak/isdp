/* $Id: VCDefaults.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vcutil / VCDefaults.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCDefaults.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1998/04/20  04:01:24  pinnacle
# Created: vcutil/VCDefaults.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 * 	4-98	KDD	creation
 *
 *************************************************************************/

class implementation Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "VCdbpost.h"
#include "VCTagDef.h"
#include "vc_define.h"
#include "vc_default.h"
#include "VCCmdDef.h"
#include "VCdbaccess.h"
#include "VDScheckdef.h"


extern GRclassid   OPP_VCElTerm_class_id;
extern GRclassid   OPP_VCFoTerm_class_id;
extern GRclassid   OPP_VCElCable_class_id;
extern GRclassid   OPP_VCFoCable_class_id;
extern GRclassid   OPP_VCDBElTerm_class_id;
extern GRclassid   OPP_VCDBFoTerm_class_id;
extern GRclassid   OPP_VCDBElCab_class_id;
extern GRclassid   OPP_VCDBFoCab_class_id;
extern GRclassid   OPP_VCECbConn_class_id;
extern GRclassid   OPP_VCFCbConn_class_id;

/*------------------------------------------------------------------------------
*
* This function returns default info on the default settings for Electrial or
* Fiber-Optic cables/terminals/etc.
*-------------------------------------------------------------
*
* 4-98 KDD
*
* Electrical is the default placement for all Cable components.
* ----------
*
* Parameters:
*
* I: IGRint     Selector        - default info selector
*                                 If not VC_PROD_FO or VC_CMDTYP_FO, then
*                                 electrical is assumed.
*
* I: IGRint     DataType        - data type as defined in vc_default.h
* O: char       *Data           - pointer to the output data. Actual type
*                                 depends on DataType.
*-----------------------------------------------------------------------------*/

IGRint	VCGetDefaultInfo( 	IGRint		Selector,
				IGRint		DataType,
				char		*Data) 
{
  IGRint		status = 1;

  IGRint		*TermTag 		= NULL,
			*CabTag			= NULL,
			*Product 		= NULL;

  char      		*tablename 		= NULL,
			*SchTermTable		= NULL,
			*DynTermTable		= NULL,
			*DB_CabTable		= NULL,
			*DB_TermTable		= NULL;

  GRclassid        	*CabClassid 		= NULL,
			*CabConClassid		= NULL,
			*TermClassid		= NULL,
			*DB_TermClassid 	= NULL,
			*DB_CabClassid 		= NULL;

  if ( !Data ) goto wrapup;


/* Map input pointer to appropriate data type */

  switch ( DataType) {

    case VC_GET_TABLE_NAME:				// 2 
	tablename = (IGRchar *) Data;			
	break;

    case VC_GET_CAB_CON_CLASS_ID:			// 12
	CabConClassid = (GRclassid * ) Data;
        break;

    case VC_GET_TERM_TAG:				// 3
	TermTag	= (IGRint *) Data; 			
        break;

    case VC_GET_CAB_TAG:				// 13
	CabTag	= (IGRint *) Data; 			
        break;

    case VC_GET_PRODUCT:				// 4
	Product	= (IGRint *) Data; 			
        break;

    case VC_GET_DB_TERM_CLASS_ID:			// 5
	DB_TermClassid = (GRclassid * ) Data;
        break;

    case VC_GET_DB_TERM_TABLE:				// 6
	DB_TermTable = (char * ) Data;
        break;

    case VC_GET_DB_CABLE_CLASS_ID:			// 7
	DB_CabClassid = (GRclassid * ) Data;
        break;

    case VC_GET_DB_CABLE_TABLE:				// 8
	DB_CabTable = (char * ) Data;
        break;

    case VC_GET_TERM_CLASS_ID:				// 9
	TermClassid = (GRclassid * ) Data;
        break;

    case VC_GET_VD_SCH_TERM_TABLE:			// 10
	SchTermTable = (char * ) Data;
        break;

    case VC_GET_VD_DYN_TERM_TABLE:			// 11
	DynTermTable = (char * ) Data;
        break;

    case VC_GET_CAB_CLASS_ID:				// 1
	CabClassid = (GRclassid * ) Data;
        break;

    default:
	printf("Unknown data type for retrieving default Cable settings\n"
	       "file = %s, line = %d\n", __FILE__, __LINE__); 

	goto wrapup; 
  } 



/* Load output pointer with proper value */

  if ( 	(Selector == VC_PROD_FO) || 			// 4
	(Selector == VC_CMDTYP_FO) )   			// 2
  {

    if ( CabClassid)  	{*CabClassid 	= OPP_VCFoCable_class_id; goto wrapup;}

    if (CabConClassid)  {*CabConClassid	= OPP_VCFCbConn_class_id; goto wrapup;}

    if ( tablename)  	{strcpy(tablename, VC_DYN_FO_FTO);  goto wrapup;}

    if ( TermTag)  	{*TermTag 	= VCTAG_CAT_FOTERM; goto wrapup;}

    if ( CabTag)  	{*CabTag 	= VCTAG_CAT_FOCABLE; goto wrapup;}

    if ( Product  )  	{*Product   	= VC_PROD_FO; goto wrapup;}

    if (DB_TermClassid) {*DB_TermClassid= OPP_VCDBFoTerm_class_id; goto wrapup;}

    if ( DB_TermTable) 	{strcpy(DB_TermTable, VC_DBT_FOTERM);  goto wrapup;}

    if ( DB_CabClassid) {*DB_CabClassid = OPP_VCDBFoCab_class_id; goto wrapup;}

    if ( DB_CabTable) 	{strcpy(DB_CabTable, VC_DBT_FOCAB);  goto wrapup;}

    if ( TermClassid)  	{*TermClassid 	= OPP_VCFoTerm_class_id; goto wrapup;}

    if ( SchTermTable)	{strcpy( SchTermTable, VD_CKTB_S_CBFTERM); goto wrapup;}

    if ( DynTermTable)	{strcpy( DynTermTable, VD_CKTB_M_CBFTERM); goto wrapup;}

  }
  else 
  { 
	// VC_PROD_ELEC					// 3
	// VC_CMDTYP_EL					// 1

	// VC_PROD_NONE					// -1
	// VC_CMDTYP_GEN				// 0
	// VC_CMDTYP_MISC1				// 3

    if ( CabClassid)  	{*CabClassid 	= OPP_VCElCable_class_id; goto wrapup;}

    if (CabConClassid)  {*CabConClassid	= OPP_VCECbConn_class_id; goto wrapup;}

    if ( tablename)  	{strcpy( tablename, VC_DYN_EL_FTO); goto wrapup;}

    if ( TermTag)  	{*TermTag 	= VCTAG_CAT_ELTERM; goto wrapup;}

    if ( CabTag)  	{*CabTag 	= VCTAG_CAT_ELCABLE; goto wrapup;}

    if ( Product  )  	{*Product   	= VC_PROD_ELEC; goto wrapup;}

    if (DB_TermClassid) {*DB_TermClassid= OPP_VCDBElTerm_class_id; goto wrapup;}

    if ( DB_TermTable) 	{strcpy(DB_TermTable, VC_DBT_ELTERM);  goto wrapup;}

    if ( DB_CabClassid) {*DB_CabClassid = OPP_VCDBElCab_class_id; goto wrapup;}

    if ( DB_CabTable) 	{strcpy(DB_CabTable, VC_DBT_ELCAB);  goto wrapup;}

    if ( TermClassid)  	{*TermClassid 	= OPP_VCElTerm_class_id; goto wrapup;}

    if ( SchTermTable)	{strcpy( SchTermTable, VD_CKTB_S_CBETERM); goto wrapup;}

    if ( DynTermTable)	{strcpy( DynTermTable, VD_CKTB_M_CBETERM); goto wrapup;}

  }


   
wrapup:
if ( !Data || (*Data == NULL) )  status = 0; 
return ( status); 
}

end implementation Root;
