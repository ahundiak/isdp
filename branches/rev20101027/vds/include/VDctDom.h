/* $Id: VDctDom.h,v 1.1 2001/01/09 22:25:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDctDom.h
 *
 * Description: Dom Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctDom.h,v $
 *      Revision 1.1  2001/01/09 22:25:31  art
 *      ah
 *
 * Revision 1.1  2000/12/06  14:45:06  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 10/16/99  ah      Misc Updates
 * 01/09/01  ah      sp merge, Is this file even used?
 ***************************************************************************/

#ifndef VDctDom_include
#define VDctDom_include

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* --------------------------------------------
 * From VDfld.h
 * Max number of attributes an object can have
 * Used to declare arrays in various spots
 */
#define VDFLD_MAX_NAME 80
#define VDFLD_MAX_TEXT 80
#define VDFLD_MAX_TXT  80
#define VDFLD_MAX_CNT 256

/* --------------------------------------------
 * Define class types and names
 */
#define VDCT1_CLASS_TYPE_MGR  1100
#define VDCT1_CLASS_TYPE_SET  1110
#define VDCT1_CLASS_TYPE_NODE 1120

#define VDCT1_CLASS_NAME_MGR  "VDct1Mgr"
#define VDCT1_CLASS_NAME_SET  "VDct1Set"
#define VDCT1_CLASS_NAME_NODE "VDct1Node"

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

#define VDCT_ATTR_NAME_LEN       VDFLD_MAX_NAME

typedef IGRchar  TVDctBaseName     [VDCT_BASE_NAME_LEN];

typedef IGRchar  TVDctSetType      [VDCT_SET_TYPE_LEN];
typedef IGRchar  TVDctSetTypeRev   [VDCT_SET_TYPE_REV_LEN];
typedef IGRchar  TVDctSetTypeDesc  [VDCT_SET_TYPE_DESC_LEN];
typedef IGRchar  TVDctSetTypeTable [VDCT_SET_TYPE_TABLE_LEN];

typedef IGRchar  TVDctSetName      [VDCT_SET_NAME_LEN];

typedef IGRchar  TVDctNodeName     [VDCT_NODE_NAME_LEN];
typedef IGRchar  TVDctNodeType     [VDCT_NODE_TYPE_LEN];
typedef IGRchar  TVDctNodeTypeDesc [VDCT_NODE_TYPE_DESC_LEN];
typedef IGRchar  TVDctNodeTypeLevel[VDCT_NODE_TYPE_LEVEL_LEN];
typedef IGRchar  TVDctNodeTypeTable[VDCT_NODE_TYPE_TABLE_LEN];

typedef IGRchar  TVDctAttrName     [VDCT_ATTR_NAME_LEN];

/* -----------------------------------------------
 * Some common structures
 */
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
  IGRchar       defaultValue[72];  // PPL Routine
  IGRchar       pickList   [256];  // PPL Routine or list
  IGRchar       validate    [72];  // PPL Routine
} TVDctAttrInfo;

/* -----------------------------------------------
 * Main interface to tree class system
 */
typedef struct 
{
  void *cl;
  TGRid id;
} TVDct1JD;

/* --------------------------------------
 * working to have a list of all nodes
 * in a particular tree.  This struct will
 * be of a node.  TVDct1NodeInfo.
 */
typedef struct
{
  TVDct1JD      parentJD;
  TVDct1JD      nodeJD;
  TVDctBaseInfo info;
} TVDct1NodeInfo;

/* -------------------------------------
 * NodeInfo list of all nodes in tree
 */
typedef struct
{
  IGRint         max;
  IGRint         inc;
  IGRint         cnt;
  TVDct1NodeInfo *nodes;
} TVDct1NodeInfos;

// init and free functions
extern IGRstat VDct1InitNodeInfos __((TVDct1NodeInfos *infos));
extern IGRstat VDct1FreeNodeInfos __((TVDct1NodeInfos *infos));

/* ---------------------------------------
 * User Info struct for setting user info
 * at node creation
 */
typedef struct 
{

  TGRobj_env   *objOE;
  TGRid        *windowID;
  // TGRsymbology *symb;
  
} TVDct1UserInfo;

/* -----------------------------------------------
 * vds/include/VDcla.h
 */
typedef IGRlong TVDclaType;
typedef IGRlong TVDclaFlag;

// Just a trick
#define VDct1_include
#define VDct1CmdTree_include
#define vdprocinfo_include

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif






