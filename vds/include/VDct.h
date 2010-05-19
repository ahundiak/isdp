/* $Id: VDct.h,v 1.2 2001/01/09 22:10:26 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct.h
 *
 * Description: Collector Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct.h,v $
 *      Revision 1.2  2001/01/09 22:10:26  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  2000/12/08  15:32:34  pinnacle
 * ah
 *
 * Revision 1.2  2000/05/05  15:06:36  pinnacle
 * pn
 *
 * Revision 1.6  1999/10/26  14:50:46  pinnacle
 * ah
 *
 *
 * Revision 1.3  1999/05/28  20:02:10  pinnacle
 * ct
 *
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 10/16/99  ah      Misc Updates
 * 12/07/00  ah      c friendly
 * 01/09/01  ah      sp merge
 ***************************************************************************/

#ifndef VDct_include
#define VDct_include

/* --------------------------------------------
 * This is the master include file, pull in
 * other files automatically
 */
#ifndef   VDtypedefc_include
#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif
#endif

#ifndef   VDfld_include
#include "VDfld.h"
#endif

#ifndef   VDcla_include
#include "VDcla.h"
#endif

#ifndef   VDcol_include
#include "VDcol.h"
#endif

#ifndef   VDlnk_include
#include "VDlnk.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* --------------------------------------------
 * Define class types and names
 */
#define VDCT_CLASS_TYPE_MGR  1000
#define VDCT_CLASS_TYPE_SET  1010
#define VDCT_CLASS_TYPE_NODE 1020

#define VDCT_CLASS_NAME_MGR  "VDctMgr"
#define VDCT_CLASS_NAME_SET  "VDctSet"
#define VDCT_CLASS_NAME_NODE "VDctNode"

/* -------------------------------------------
 * Needed Defines and typedefs
 */

#define VDCT_SET_NAME_NAME            "set_name"
#define VDCT_SET_TYPE_NAME            "set_type"
#define VDCT_SET_TYPE_REV_NAME        "set_type_rev"
#define VDCT_SET_TYPE_DESC_NAME       "set_type_desc"
#define VDCT_SET_TYPE_NODE_TABLE_NAME "set_type_node_table"
#define VDCT_SET_TYPE_LEAF_TABLE_NAME "set_type_leaf_table"

#define VDCT_NODE_VERSION         "tversion"
#define VDCT_NODE_NAME            "node_name"
#define VDCT_NODE_NAME_NAME       "node_name"

#define VDCT_NODE_TYPE_NAME       "node_type"
#define VDCT_NODE_TYPE_DESC       "node_type_desc"
#define VDCT_NODE_TYPE_LEVEL      "node_type_level"
#define VDCT_NODE_TYPE_TABLE_NAME "node_type_table_name"

#define VDCT_BASE_INFO_NAME "base_info"
#define VDCT_BASE_NAME_NAME "base_name"
#define VDCT_BASE_NAME_LEN   50

#define VDCT_SET_TYPE_LEN        16
#define VDCT_SET_TYPE_REV_LEN     4
#define VDCT_SET_TYPE_DESC_LEN   34
#define VDCT_SET_TYPE_TABLE_LEN  20

#define VDCT_SET_NAME_LEN        32

#define VDCT_NODE_NAME_LEN       32
#define VDCT_NODE_TYPE_LEN       16
#define VDCT_NODE_TYPE_DESC_LEN  34
#define VDCT_NODE_TYPE_LEVEL_LEN  4
#define VDCT_NODE_TYPE_TABLE_LEN 20

#define VDCT_ATTR_NAME_LEN   VDFLD_MAX_NAME

typedef IGRchar  TVDctBaseName[VDCT_BASE_NAME_LEN];

typedef IGRchar  TVDctSetType     [VDCT_SET_TYPE_LEN];
typedef IGRchar  TVDctSetTypeRev  [VDCT_SET_TYPE_REV_LEN];
typedef IGRchar  TVDctSetTypeDesc [VDCT_SET_TYPE_DESC_LEN];
typedef IGRchar  TVDctSetTypeTable[VDCT_SET_TYPE_TABLE_LEN];

typedef IGRchar  TVDctSetName [VDCT_SET_NAME_LEN];

typedef IGRchar  TVDctNodeName     [VDCT_NODE_NAME_LEN];
typedef IGRchar  TVDctNodeType     [VDCT_NODE_TYPE_LEN];
typedef IGRchar  TVDctNodeTypeDesc [VDCT_NODE_TYPE_DESC_LEN];
typedef IGRchar  TVDctNodeTypeLevel[VDCT_NODE_TYPE_LEVEL_LEN];
typedef IGRchar  TVDctNodeTypeTable[VDCT_NODE_TYPE_TABLE_LEN];

typedef IGRchar  TVDctAttrName     [VDCT_ATTR_NAME_LEN];

/* --------------------------------------------
 * Map generic channels to VDct channels
 */
#define VDCT_CHN_MGR             VDLNK_NTH_PAIR0
#define VDCT_CHN_MGR_TO_PARENT   VDLNK_NTH_TO_LEFT0
#define VDCT_CHN_MGR_TO_CHILD    VDLNK_NTH_TO_RIGHT0

#define VDCT_CHN_TREE1           VDLNK_NTH_PAIR1
#define VDCT_CHN_TREE1_TO_PARENT VDLNK_NTH_TO_LEFT1
#define VDCT_CHN_TREE1_TO_CHILD  VDLNK_NTH_TO_RIGHT1

#define VDCT_CHN_TREE2           VDLNK_NTH_PAIR2
#define VDCT_CHN_TREE2_TO_PARENT VDLNK_NTH_TO_LEFT2
#define VDCT_CHN_TREE2_TO_CHILD  VDLNK_NTH_TO_RIGHT2

typedef struct
{
  IGRdouble    xcoord;
  IGRdouble    ycoord;
  IGRdouble    zcoord;
  IGRdouble    mass;
} TVDctCGinfo;

typedef struct
{
  TVDctSetType    setType;
  TVDctSetTypeRev setTypeRev;
  TVDctSetName    setName;
  TVDctNodeType   nodeType;
  TVDctNodeName   nodeName;
  TVDctBaseName   baseName;
} TVDctBaseInfo;

typedef struct
{
  TVDctSetType      type;
  TVDctSetTypeRev   rev;
  TVDctSetTypeDesc  desc;
  TVDctSetTypeTable nodeTable;
  TVDctSetTypeTable leafTable;
} TVDctSetTypeInfo;

typedef struct
{
  TVDctNodeType      type;
  TVDctNodeTypeDesc  desc;
  TVDctNodeTypeLevel level;
  TVDctNodeTypeTable table;
} TVDctNodeTypeInfo;

typedef struct 
{
  TVDctAttrName name;
  IGRint        type;
  IGRint        len;
  TVDctAttrName base;
  IGRchar       desc[VDFLD_MAX_TXT];
  IGRchar       defaultValue[72];  /* PPL Routine         */
  IGRchar       pickList   [256];  /* PPL Routine or list */
  IGRchar       validate    [72];  /* PPL Routine         */
} TVDctAttrInfo;

/* --------------------------------------------------------
 * set/VDctMgr.I
 */

// Create the Manager Object
extern IGRstat VDctCreateManager __((VDosnum osnum, TGRid *mgrID));

#ifndef c_ONLY
#omdef vdct$CreateManager(
  osnum =  OM_K_NOT_AN_OS, // I - Otherwise current osnum
  mgrID                    // O - Created Manger Object
)
VDctCreateManager((osnum),(mgrID))
#endomdef
#endif

// Obtain the Manager
extern IGRstat VDctGetManager    __((VDosnum osnum, TGRid *mgrID));

#ifndef c_ONLY
#omdef vdct$GetManager(
  osnum =  OM_K_NOT_AN_OS, // I - Input osnum to search
  mgrID                    // O - Obtained Manager
)
VDctGetManager((osnum),(mgrID))
#endomdef
#endif

/* --------------------------------------------------------
 * set/VDctBase.I
 */
extern IGRstat VDctCreateBaseObject __((TVDclaType classType,
					VDosnum    osnum,
					TGRid     *objID));

#ifndef c_ONLY
#omdef vdct$CreateBaseObject(classType,
			     osnum = OM_K_NOT_AN_OS,
			     objID)
VDctCreateBaseObject((classType), (osnum), (objID))
#endomdef
#endif

extern IGRstat VDctGetBaseInfo __((TGRobj_env    *objOE,
				   TGRid         *objID,
				   IGRchar       *name,
				   IGRchar       *txt,       
				   TVDctBaseInfo *rs));

#ifndef c_ONLY
#omdef vdct$GetBaseInfo(objOE = NULL,
			objID = NULL,
			name  = NULL,
			txt   = NULL,
			baseInfo = NULL)
VDctGetBaseInfo((objOE), (objID), (name), (txt), (baseInfo))
#endomdef
#endif

extern IGRstat VDctSetBaseInfo __((TGRobj_env    *objOE,
				   TGRid         *objID,
				   TVDctBaseInfo *baseInfo));
#ifndef c_ONLY
#omdef vdct$SetBaseInfo (objOE = NULL,
			 objID = NULL,
			 baseInfo)
VDctSetBaseInfo((objOE), (objID), (baseInfo))
#endomdef
#endif

/* -----------------------------------------------------
 * set/VDctSet.I
 */

// Create the Set Object
extern IGRstat VDctCreateSet __((TGRid          *mgrID,   
				 TVDctSetType    setType,    
				 TVDctSetTypeRev setTypeRev,
				 TVDctSetName    setName,   
				 TGRid          *setID));

#ifndef c_ONLY
#omdef vdct$CreateSet(mgrID,
		      setType,
		      setTypeRev = NULL,
		      setName,
		      setID)
VDctCreateSet((mgrID), (setType), (setTypeRev), (setName), (setID))
#endomdef
#endif

extern IGRstat VDctGetSetTypeInfo __((IGRchar          *setType,
				      TVDctSetTypeInfo *setTypeInfo));

#ifndef c_ONLY
#omdef vdct$GetSetTypeInfo(setType,setTypeInfo)
VDctGetSetTypeInfo((setType), (setTypeInfo))
#endomdef
#endif

/* --------------------------------------------------------------
 * Low level channel manager, just wrappers to VDlnk functions
 * Wonder why these are duplicated in VDlnk.h?
 */
#ifndef c_ONLY
#omdef vdct$GetMgrParent(objID,        // I - Input Object
			 nth   = 0,    // I - Which Object on Channel
			 cnt   = NULL, // O - Number of Parents
			 outID = NULL  // O - Returned Parent
)
VDlnkGet ((objID), (VDCT_CHN_MGR_TO_PARENT), (nth), (cnt), (outID))
#endomdef
 
#omdef vdct$GetMgrChild( objID,        // I - Input Object
			 nth   = 0,    // I - Which Object on Channel
			 cnt   = NULL, // O - Number of Children
			 outID = NULL  // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_MGR_TO_CHILD), (nth), (cnt), (outID))

#endomdef

#omdef vdct$GetTree1Parent( objID,        // I - Input Object
			    nth   = 0,    // I - Which Object on Channel
			    cnt   = NULL, // O - Number of Children
			    outID = NULL  // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE1_TO_PARENT), (nth), (cnt), (outID))

#endomdef
#omdef vdct$GetTree1Child( objID,        // I - Input Object
			   nth   = 0,    // I - Which Object on Channel
			   cnt   = NULL, // O - Number of Children
			   outID = NULL  // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE1_TO_CHILD), (nth), (cnt), (outID))

#endomdef

#omdef vdct$GetTree2Parent( objID,        // I - Input Object
			    nth   = 0,    // I - Which Object on Channel
			    cnt   = NULL, // O - Number of Children
			    outID = NULL  // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE2_TO_PARENT), (nth), (cnt), (outID))

#endomdef
#omdef vdct$GetTree2Child( objID,        // I - Input Object
			   nth   = 0,    // I - Which Object on Channel
			   cnt   = NULL, // O - Number of Children
			   outID = NULL  // O - Returned Child
)

VDlnkGet ((objID), (VDCT_CHN_TREE2_TO_CHILD), (nth), (cnt), (outID))

#endomdef

#omdef vdct$ConnectMgrChild( mgrID,    // I - ManagerID
			     childID   // I - ObjectID of Child
)

VDlnkConnect((VDCT_CHN_MGR), (mgrID), (childID))

#endomdef

#omdef vdct$DisConnectMgrChild( mgrID,    // I - ManagerID
				childID   // I - ObjectID of Child
)

VDlnkDisconnect((VDCT_CHN_MGR), (mgrID), (childID))

#endomdef

#omdef vdct$ConnectTree1Child( treeID,   // I - TreeID
			       childID   // I - ObjectID of Child
)

VDlnkConnect((VDCT_CHN_TREE1), (treeID), (childID))

#endomdef

#omdef vdct$DisConnectTree1Child( treeID,   // I - TreeID
				  childID   // I - ObjectID of Child
)

VDlnkDisconnect((VDCT_CHN_TREE1), (tree1ID), (childID))

#endomdef

#omdef vdct$ConnectTree2Child( treeID,   // I - TreeID
			       childID   // I - ObjectID of Child
)

VDlnkConnect((VDCT_CHN_TREE2), (treeID), (childID))

#endomdef

#omdef vdct$DisConnectTree2Child( treeID,   // I - TreeID
				  childID   // I - ObjectID of Child
)
VDlnkDisconnect((VDCT_CHN_TREE2), (treeID), (childID))
#endomdef
#endif

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif






