/* $Id: VDItemDB.h,v 1.3 2001/01/14 16:39:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDItemDB.h
 *
 * Description: Routines for getting additional attributes from database tables
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDItemDB.h,v $
 *      Revision 1.3  2001/01/14 16:39:21  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/09 21:35:20  art
 *      ah
 *
 * Revision 1.1  2000/12/06  20:38:20  pinnacle
 * Created: vds/api/item/VDItemDB.h by jdsauby for Service Pack
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/08/00  js      Creation
 *
 ***************************************************************************/

#ifndef VDItemDB_include
#define VDItemDB_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDItemDBUtil_include
#include "VDItemDBUtil.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ------------------------------------------
 * DEFINE some default knowns
 */

// keys
#define VDITEMDB_KEY_VALUE     "mat_id_key"

// PPL name STRUCT
#define VDITEMDB_PPL_NAME_STRUCT   "VDit_struct"

// PPL function names
#define VDITEMDB_PPL_F_STRUCT_BEAM     "VDitemdbGetMatIDForBeamObject"
#define VDITEMDB_PPL_F_STRUCT_JOINT    "VDitemdbGetMatIDForJointObject"
#define VDITEMDB_PPL_F_STRUCT_PLATE    "VDitemdbGetMatIDForPlateObject"
#define VDITEMDB_PPL_F_STRUCT_STFNR    "VDitemdbGetMatIDForStfnrObject"
#define VDITEMDB_PPL_F_STRUCT_SURF     "VDitemdbGetMatIDForStSurfObject"
#define VDITEMDB_PPL_F_STRUCT_STRUCT   "VDitemdbGetMatIDForStructureObject"

// PPL name VDS
#define VDITEMDB_PPL_NAME_VDS      "VDit_vds"

// PPL function names
#define VDITEMDB_PPL_F_VDS_EQUIP       "VDitemdbGetMatIDForEquipObject"
#define VDITEMDB_PPL_F_VDS_STAGE       "VDitemdbGetMatIDForStageObject"
#define VDITEMDB_PPL_F_VDS_MACRO       "VDitemdbGetMatIDForMacroObject"

// PPL name ROUTE
#define VDITEMDB_PPL_NAME_ROUTE    "VDit_route"


#define VDITEMDB_PPL_F_ROUTE_CABLE     "VDitemdbGetMatIDForCableObject"
#define VDITEMDB_PPL_F_ROUTE_CON_COMP  "VDitemdbGetMatIDForConCompObject"
#define VDITEMDB_PPL_F_ROUTE_GUIDE     "VDitemdbGetMatIDForGuideObject"
#define VDITEMDB_PPL_F_ROUTE_HVAC      "VDitemdbGetMatIDForHvacObject"
#define VDITEMDB_PPL_F_ROUTE_NOZZLE    "VDitemdbGetMatIDForNozzleObject"
#define VDITEMDB_PPL_F_ROUTE_PIPE      "VDitemdbGetMatIDForPipeObject"
#define VDITEMDB_PPL_F_ROUTE_RWAY      "VDitemdbGetMatIDForRwayObject"
#define VDITEMDB_PPL_F_ROUTE_TERM      "VDitemdbGetMatIDForTermObject"

// PPL name for Attributes
#define VDITEMDB_PPL_NAME_ATTRS		"VDit_attrs"

#define VDITEMDB_PPL_F_ATTRS		"VDitemdbGetAttrsForKey"

// Maximum attributes
#define VDITEMDB_MAX_ATTRS		2056


/* ------------------------------------------
 * Functions in vdroot/VDrtgivestr.I
 */

// get the VDITEMDB_KEY_VALUE for object
extern IGRstat VDitemDBGetMatIdKey __(( struct GRid  *object,
					IGRchar      *keyValue,
					struct GRid  *keyValueID ));

/* -----------------------------------------------------
 * functions in VDutItemdb.I
 */


// returns key value for any foot_name, set up for multiple key values if needed
extern IGRstat VDitemdbGetKeyValue __((IGRint  *rc, 
				       TGRid   *myGRid,
				       IGRchar *foot_name,
				       IGRchar *keyValue ));

// returns attribute value for given attribute (foot_value for foot_name)
extern IGRstat VDitemdbGetAttrInfo __(( IGRint  *rc, 
					IGRchar *keyValue,
					IGRchar *foot_name,
					IGRchar *foot_value ));

// returns key value for object, wrapper around PPL
extern IGRstat VDitemdbGetMatIDForObject __((TGRid   *myGRid, 
					     IGRchar *keyValue ));


// appends attributes and values to plist.  wrapper around a customizable PPL
extern IGRstat VDgetItemDbParameters __((IGRlong	   *status,
	    				 struct GRid       *object,
	    				 struct GRmd_env   *md_env,
					 IGRint            *count,
					 struct ACrg_coll  **plist ));


/*---------------------------------------------------------------------
 * Get the attributes from the collector.  
 * I - keyValue      - the itemdb key by which the attributes are stored against
 * 0 - Collection    - the list of attribute names, type, and value
 * O - NbCollect     - the number of attributes in the list
 * *****/
/*extern IGRstat VDitemdbGetItemDBCollectorAttributes __(( IGRchar           *keyValue,
 						     	 struct ACrg_coll  *Collection,
  						    	 IGRint            *NbCollect ));

 */
extern IGRstat VDitemdbGetItemDBCollectorAttributes __(( IGRchar             *keyValue,
 						     	 TVDitemdbCollAttrs  *list ));




//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
