/* $Id: vdtr_macros.h,v 1.24.4.2 2003/06/04 15:51:08 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/vdtr_macros.h
 *              supports operations of
 *              vds/vdct1/tools/VDtrTools.I
 *
 * Description: Definitions for basic node tools 
 *              Generic operations for class free handling of
 *              node operations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdtr_macros.h,v $
 *      Revision 1.24.4.2  2003/06/04 15:51:08  ylong
 *      Modify macro prototypes
 *
 *      Revision 1.24.4.1  2003/05/12 20:55:29  ylong
 *      TR7673 Filter out DELETED nodes/parts
 *
 *
 *      Revision 1.2  2001/01/19 15:15:26  paul_noel
 *      Tools added to
 *      GetNodeType
 *      GetNodeName
 *      GetSetType
 *      GetSetName
 *      GetSetTree
 *
 *      Revision 1.1  2001/01/10 16:31:37  art
 *      sp merge
 *
 *

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/28/00  pn      Creation
 * 01/10/01  ah      sp merge
 * 04/11/01  pn      add readAnyFile
 * 11/17/10  ah      SOL10 Added frozen to trget_nodes
 ***************************************************************************/

/***************************************************************************
 *  EXTREMELY IMPORTANT:  SOME OF THESE ROUTINES ALLOCATE MEMORY FOR THE   *
 *  VARIABLES THAT CALL THEM   THIS REQUIRES THE USER TO FREE THE MEMORY   *
 ***************************************************************************/


#ifndef vdtr_macros_include
#define vdtr_macros_include

/* --------------------------------------------
 * This is the master include file, pull in
 * other files automatically
 */

#ifndef   VDct1_include
#include "VDct1.h"
#endif

#ifndef   VDobj_include
#include "VDobj.h"
#endif    
 
#ifndef   VDatMaster_include
#include "VDatMaster.h"
#endif

#ifndef   VDct1Tree_include
#include "VDct1Tree.h"
#endif

#ifndef   VDos_include
#include "VDos.h"
#endif

#ifndef   DItypedef_include
#include "DItypedef.h"
#endif

#ifndef   DIdef_include
#include "DIdef.h"
#endif

#ifndef   DIglob_include
#include "DIglob.h"
#endif

#ifndef   DIprims_include
#include "DIprims.h"
#endif

#ifndef   VDsa_include
#include "VDsa.h"
#endif

#ifndef   VDiofile_include
#include "VDiofile.h"
#endif

#ifndef   VDctx_include
#include "VDctx.h"
#endif

#ifndef   VDct1Attrs_include
#include "VDct1Attrs.h"
#endif

#ifndef   VDdrwlo_include
#include "VDdrwlo.h"
#endif


/* -----------------------------------------------
 * Holds info needed to access VDat sets
 */
typedef struct {
  IGRchar name[ 24];
  IGRchar type[ 24];
  IGRchar desc[128];
  IGRkey  key;
  TGRid   id;
} TVDtrSetInfo;


#define VDTR_NODE_NAME_LEN  24
#define VDTR_BUF_SIZE      128
/********************************************************
 * Definitions for finding items in trees
 */
#define VDTR_FIND_TREE        0x00000001
#define VDTR_FIND_MANAGER     0x00000010
#define VDTR_FIND_PARENT      0x00000100
#define VDTR_FIND_CHILD       0x00001000
#define VDTR_FIND_CHILD_NODE  0x00010000
#define VDTR_FIND_ALL_NODE    0x00100000
#define VDTR_FIND_ALL         0x10000000

#define VDTR_ALL_CHILD        VDTR_FIND_ALL | VDTR_FIND_CHILD
#define VDTR_ALL_PARENT       VDTR_FIND_ALL | VDTR_FIND_PARENT
 

#define VDTR_FIND_MODEL       0x00000001
#define VDTR_FIND_NODE        0x00000010
#define VDTR_FIND_LEAF        0x00000100

#define VDTR_NODE_MODEL       0x00000011
#define VDTR_NODE_LEAF        0x00000110

#define VDTR_SORT_TTYPE       0x00000001
#define VDTR_SORT_TNAME       0x00000010
#define VDTR_SORT_TTYPE_TNAME 0x00000011

#define VDTR_SORT_NTYPE       0x00000100
#define VDTR_SORT_NNAME       0x00001000
#define VDTR_SORT_NTYPE_NNAME 0x00001100

#define VDTR_CLASS_VDAT       0x00000001
#define VDTR_CLASS_VDCT1      0x00000010
#define VDTR_CLASS_NONE       0x00000000
#define VDTR_AST_CLASS        "AST"
#define VDTR_OTM_CLASS        "OTM"
#define VDTR_XML_CLASS        "XML"
#define VDTR_DOM_CLASS        "DOM"

/* define the PPL control form gadgets */
#define VDTR_PPL_TITLE        11
#define VDTR_PPL_TEXT         16
#define VDTR_PPL_LIST         12
#define VDTR_PPL_DATA_TITLE   18
#define VDTR_PPL_SEL_PPL      15
#define VDTR_PPL_DATA         14
#define VDTR_PPL_B_RUN        17
#define VDTR_PPL_DISP         10
#define VDTR_PPL_KEY_TXT      19
#define VDTR_PPL_KEY_TIT      20
#define VDTR_PPL_KEY_B        21
#define VDTR_PPL_KEYX_B       22
#define VDTR_PPL_KEYC_B       24


extern IGRstat VDatGetLeafObject __((TGRid *leafID, TGRobj_env *objOE));
/****************************************************
 * VDtrTools.I Macro Definitions for generic access *
 * Routines for accessing tree data                 *
 ****************************************************/
/*
 * This routine gets the manager ID based upon getting input of 
 * either the nodeID or the class (using the defined types above)
 * it reports out the manager based upon that
 */

// get the manager
extern IGRstat VDtrget_manager __((TGRid  *nodeID,
				   TGRid  *mgrID,
				   IGRint *class));
#omdef vd$trget_manager(nodeID = NULL,
			mgrID,
			class  = NULL)

VDtrget_manager((nodeID),
		(mgrID),
		(class))
#endomdef
/* 
 * this routine reports out the class as defined above
 * given the input of the nodeID
 */
// get the ancestry right
extern IGRstat VDtrget_class __((TGRid  *nodeID, 
				 IGRint *class));

#omdef vd$trget_class(nodeID,
		      class)
  
VDtrget_class((nodeID),
	      (class)) 
#endomdef

/************************************************
 * Generic routine to get all trees by type  or *
 * an individual tree based upon a treeName     *
 ************************************************/  
  /*
   * This routine gets all of the trees by type or 
   * an individual tree by type and name 
   *
   * inputs optional set are 
   * treeType (character array)
   * treeName (character array)
   * class    (defined Type -- VDTR_CLASS_VDAT or  VDTR_CLASS_VDCT1)
   * active_file   (int 0 or 1) defines if 0 -> activefile or 1 -> reference file
   *
   * output is treeID a list of treeIDs or individual treeID
   * output is cnt 
   * when seeking an individual tree be sure to check the count for 1
   * This routine ALLOCATES MEMORY the user is OBLIGATED to 
   * free any memory used.
   * this routine DEALLOCATES any MEMORY if(*cnt == 0)
   */

extern IGRstat VDtrget_trees __((IGRchar *treeType,
				 IGRchar *treeName,
				 IGRint  *class,
				 IGRint  active_file,
				 TGRid   **treeID,
				 IGRint  *cnt));

#omdef vd$trget_trees(treeType      = NULL,
		      treeName      = NULL,
		      class         = NULL,
		      active_file   = 1,
		      treeID        = NULL,
		      cnt)

VDtrget_trees((treeType),
	      (treeName),
	      (class),
	      (active_file),
	      (treeID),
	      (cnt))

#endomdef 


/************************************************
 * Generic routine to get all trees by type  or *
 * an individual tree based upon a treeName     *
 ************************************************/    
  /* 
   * This routine is wrapped by VDtrget_trees (above)
   * it may be accessed directly and under the same terms 
   * it actually gets the data
   * EXCEPT this routine DOES NOT ALLOCATE THE MEMORY
   */

extern IGRstat VDtrget_treeList __((IGRchar *treeType,
				    IGRchar *treeName,
				    IGRint  *class,
				    TGRid   **treeID,
				    IGRint  *cnt));

#omdef vd$trget_treeList(treeType = NULL,
			 treeName = NULL,
			 class    = NULL,
			 treeID   = NULL,
			 cnt)
  
VDtrget_treeList((treeType),
		 (treeName),
		 (class),
		 (treeID),
		 (cnt))

#endomdef 

/************************************************
 * Generic routine find all child nodes         *
 * a specific node                              *
 * has available a filter for only nodes of a   *
 * specific setType  (specific tree type)       *
 * Also can find the Parent of a specific node  *
 * also can find treeID for a specific node     *
 ************************************************/  
  /* 
   * This routine DOES NOT ALLOCATE MEMORY
   * it probably should not be accessed directly 
   * Used to find a specific list of nodes or the count of nodes
   * based upon a given nodeID or nodeType
   * Inputs: nodeID - required
   *         type   - optional
   *         lookup - required see the list in VDtrget_nodes (below)
   * Outputs: nodeList - optional 
   *          cnt      _ required  tells how many nodes of the type found
   * filters by type the children or all the children of a node if 
   * a type is supplied
   * also: may return as a list of 1 the tree or the parent of a nodeID
   * see the options in VDtrget_nodes(below)
   */

extern IGRstat	VDtrget_treeNodeList __((TGRid		*nodeID,
					 IGRchar	*type,
					 TGRid		**nodeList, 
					 IGRint         lookup,
					 IGRint		*cnt));

#omdef vd$trget_treeNodeList(nodeID,
			     type     = NULL,
			     nodeList = NULL,
			     lookup,
			     cnt)

VDtrget_treeNodeList((nodeID),
		     (type),
		     (nodeList),
		     (lookup),
		     (cnt))
#endomdef

/************************************************
 * Generic routine to get all the stages in  a  *
 * tree list and count or by type               *
 * an individual tree by treeName               *
 ************************************************/ 
  /*
   * This routine gets a list of stages and the count of stages that
   * occurs in a tree
   * inputs:
   *        treeType  optional 
   *        treeName  optional
   *        treeID    optional
   *  omission of the treeID obligates the selection of
   *  the treeType and treeName to identify a tree
   *  this is because the treeType finds the CLASS
   *  and the treeName id's the tree
   *  It ignores treeType and treeName if the treeID is given
   *  outputs:
   *        stageCnt  required
   *        stages    required
   *  NOTE: THIS ROUTINE ALLOCATES MEMORY  the user is 
   *        OBLIGATED to FREE any memory so allocated
   *        this routine also frees any memory if the 
   *        count is 0 
   */

extern IGRstat VDtrget_stages __((IGRchar  *treeType,
				  IGRchar  *treeName,
				  TGRid    *treeID,
				  IGRint   *stageCnt,
				  IGRchar  **stages));	      
  

#omdef vd$trget_stages(treeType = NULL,
		       treeName = NULL,
		       treeID   = NULL,
		       stageCnt,
		       stages)      
  
VDtrget_stages((treeType),
	       (treeName),
	       (treeID),
	       (stageCnt),
	       (stages))     
#endomdef 

/************************************************
 * Generic routine to get ParentID or children  *
 * for a node, or a specific node               *
 * given a specific starting node               *
 ************************************************/    
  /* 
   * This routine is the basic routine for accessing nodes
   * it is extremely wide in its operations 
   * potential data recovery includes 
   * [1] finding all the nodes 
   * that are directly children of a node supplied to this
   * [2] finding a list of all the nodes below a node supplied 
   * inclusive of all levels
   * [3] finding the parent directly above the supplied node
   * [4] finding the tree top above the supplied node
   * options [1] and [2] may be filtered by 
   * nodeType and nodeName or by setType and setName
   * The selection also provides a count of nodes in the resulting list
   * Inputs:  
   *    Optional: nodeType: filters on either setType or nodeType (see LookupType)
   *              nodeName: filters on either setName or nodeName (see LookupType)
   *              frozen: filter out the node, defined by VDtrFilterFrozenNode

   *    Required: nodeID:   gives the node to base the lookup from
   *              lookupType: 
   *             <VDTR_FIND_CHILD>      finds children of a setType and/or setName
   *             <VDTR_FIND_CHILD_NODE> finds children of a nodeType and/or nodeName
   *             <VDTR_FIND_ALL>        finds all children of a setType and/or setName
   *             <VDTR_FIND_ALL_NODE>   finds all children of a nodeType and/or nodeName
   *             <VDTR_FIND_PARENT>     finds the parent of the supplied nodeID
   *             <VDTR_FIND_TREE>       finds the tree for the supplied nodeID
   * Outputs: outID:  supplies the list of nodeID's per the settings
   *                  output of this is functionally an array of TGRid 
   *                  addressed by a (TGRid *nodeID) definition 
   *            cnt:  supplies the number of items in the list of nodeID's
   * NOTE: THIS ROUTINE ALLOCATES MEMORY FOR THE outID variable so the user must
   *       FREE this memory
   */

extern IGRstat VDtrget_nodes __((IGRchar *nodeType,
				 IGRchar *nodeName,
				 TGRid   *nodeID,
				 IGRint  lookupType,
				 IGRint  frozen,
				 IGRint  active_file,
				 TGRid   **outID,
				 IGRint  *cnt));


#omdef vd$trget_nodes(nodeType   = NULL,
		      nodeName   = NULL,
		      nodeID,
		      lookupType = 0,
		      frozen	 = 0,
		      active_file= 1,
		      outID      = NULL,
		      cnt        = NULL)

VDtrget_nodes((nodeType),
	      (nodeName),
	      (nodeID),
	      (lookupType),
	      (frozen),
	      (active_file),
	      (outID),
	      (cnt))
#endomdef 

/************************************************
 * Generic routine to get node basic info       *
 * for a specific node                          *
 ************************************************/    
  /*
   * This routine is to supply information about a node 
   * Require Input:  nodeID
   *  optional outputs: nodeType 
   *                    nodeName 
   *                    path
   *  all are IGRchar pointers
   */

extern IGRstat VDtrget_nodeInfo __((IGRchar *nodeType,
				    IGRchar *nodeName,
                                    IGRchar *setType,
                                    IGRchar *setName,
				    TGRid   *nodeID,
				    IGRchar *path,
                                    IGRchar *fullPath));

#omdef vd$trget_nodeInfo(nodeType = NULL,
			 nodeName = NULL,
                         setType  = NULL,
                         setName  = NULL,
			 nodeID,
			 path     = NULL,
                         fullPath = NULL)

VDtrget_nodeInfo((nodeType),
		 (nodeName),
                 (setType),
                 (setName),
		 (nodeID),
		 (path),
                 (fullPath))
#endomdef 

/************************************************
 * Generic routine to get a specific node       *
 * selects based upon node path                 *
 * finds the nodeID and its treeID & setID      *
 ************************************************/
/* This routine searches the trees for a matching node path
 * it returns the treeID or the nodeID for the path
 * inputs: nodePath  Required input
 * outputs: nodeID   Optional output 
 *          treeID   Optional output
 *          setID    Optional output
 *                   must have either a nodeID or a treeID to output 
 * will return a treeID even if the path does not find a nodeID
 */

extern IGRstat VDtrget_nodeFromPath __((IGRchar *nodePath,
					TGRid   *nodeID,
					TGRid   *treeID));
#omdef vdtr$GetNodeFromPath(nodePath,
			     nodeID       = NULL,
			     treeID       = NULL)

VDtrget_nodeFromPath((nodePath),
		     (nodeID),
		     (treeID))
#endomdef 

/********************************************************
 * Generic Routine to secure access to the Model Object *
 * Input is nodeID and output is the objID for the      *
 * model object   checks the connections                *
 ********************************************************/
  /*
   * simple device to get object environment for a specific node
   * contains class filters  to make this lookup regardless of 
   * VDat or VDct1 class bases
   */
extern IGRstat VDtrget_modelObject __((TGRid      *nodeID,
				       TGRobj_env *objOE));

#omdef vd$trget_modelObject(nodeID,
			    objOE)

VDtrget_modelObject((nodeID),
		    (objOE))
#endomdef

/**********************************************************************************
 * test routine to print out the nodeID, setType, setName nodeName, nodeType      *
 **********************************************************************************/
  /* 
   * extremely useful diagnostic routine
   * prints out give a nodeID the basic node identity information 
   * the title is a optional input that allows the user
   * to clearly mark what report is being printed
   * prints to back screen
   */
extern IGRstat VDtr_getNodePrint __((TGRid   *nodeID,
				     IGRchar *title));

#omdef vd$trget_getNodePrint(nodeID,
			     title = NULL)

VDtr_getNodePrint((nodeID),
		  (title))
#endomdef

/*******************************************************************
 * test routine to print out based upon the nodeJD the nodeID data *
 *******************************************************************/
extern IGRstat VDtr_getNodeJDPrint __((TVDct1JD *nodeJD,
				       IGRchar  *title));

#omdef vd$tr_getNodeJDPrint(nodeJD,
			    title)

VDtr_getNodeJDPrint((nodeJD),
		    (title))
#endomdef

  // get vdct1 and vdat nodePath
extern IGRstat VDtrget_nodePath __((TGRid *nodeID, IGRchar *path));
#omdef vdtr$GetNodePath(nodeID,
			path)
VDtrget_nodePath((nodeID),(path))
#endomdef 
// get the vdct1 path
  /* useful routine applies only to vdct1 class to get the path of a node
   * "<nodeType> <nodeName>;" path applies as in quotes repeated delimited with ";"
   */
  //extern IGRstat VDtrget_vdct1NodePath __((TGRid   *nodeID,
  //				 IGRchar *path));

  //#omdef vd$trget_vdct1NodePath(nodeID,
  //		      path)

  //VDtrget_vdct1NodePath((nodeID),
  //	  (path))
  //#endomdef


// get the path treeName
  extern IGRstat VDtrget_treeNameFromPath __((IGRchar *nodePath,
					      IGRchar *nodeName));
#omdef vd$trget_treeNameFromPath(nodePath,
				 nodeName)
  
VDtrget_treeNameFromPath((nodePath),
			 (nodeName))

#endomdef
/*****************************************************
 *
 * Is the object a leaf?
 *
 *****************************************************/
extern IGRstat VDtrIsLeaf __((TGRid *nodeID));

#omdef vdtr$IsLeaf(nodeID)

VDtrIsLeaf((nodeID))
#endomdef

/*****************************************************
 *
 * Is the object of one of the trees?
 *
 *****************************************************/
extern IGRstat VDtrIsTreeAncestry __((TGRid *nodeID));

#omdef vdtr$IsTreeAncestry(nodeID)

VDtrIsTreeAncestry((nodeID))
#endomdef

/*****************************************************
 *
 * Is the object a Set ?
 *
 *****************************************************/
extern IGRstat VDtrIsSet __((TGRid *nodeID));

#omdef vdtr$IsSet(nodeID)

VDtrIsSet((nodeID))
#endomdef

/*****************************************************
 *
 * Is the object a tree ?
 *
 *****************************************************/
extern IGRstat VDtrIsTree __((TGRid *nodeID));

#omdef vdtr$IsTree(nodeID)

VDtrIsTree((nodeID))
#endomdef

/*****************************************************
 *
 * Is the object a node under a tree (not the tree itself)?
 *
 *****************************************************/
extern IGRstat VDtrIsNode __((TGRid *nodeID));

#omdef vdtr$IsNode(nodeID)

VDtrIsNode((nodeID))
#endomdef

/***********************************************
 * Get the nodePath for any node
 * input *nodeID  (required)
 * output *path 
 ***********************************************/
extern IGRstat VDtrget_nodePath __((TGRid *nodeID, IGRchar *path));

#omdef vd$trget_nodePath(nodeID,
			 path)
VDtrget_nodePath((nodeID),
		 (path))
#endomdef
/***********************************************************
 * Get the treeID
 * Input  *setID
 * output *treeID
 ***********************************************************/
extern IGRstat VDtrget_setTree __((TGRid *setID, TGRid *treeID));

#omdef vdtr$GetSetTree(setID,
		       treeID)

VDtrget_setTree((setID),
		(treeID))
#endomdef
/***********************************************************
 * Get the nodeType
 * Input  *nodeID
 * output *nodeType
 ***********************************************************/
extern  IGRstat VDtrget_nodeType __((TGRid *nodeID, IGRchar *nodeType));

#omdef vdtr$GetNodeType(nodeID,
			nodeType)

VDtrget_nodeType((nodeID),
		 (nodeType))
#endomdef

/***********************************************************
 * Get the nodeName
 * Input  *nodeID
 * output *nodeName
 ***********************************************************/
extern  IGRstat VDtrget_nodeName __((TGRid *nodeID, IGRchar *nodeName));

#omdef vdtr$GetNodeName(nodeID,
			nodeName)
VDtrget_nodeName((nodeID),
		 (nodeName))
#endomdef

/***********************************************************
 * Get the setType
 * Input  *nodeID
 * output *setType
 ***********************************************************/
extern  IGRstat VDtrget_setType __((TGRid *nodeID, IGRchar *setType));

#omdef vdtr$GetSetType(nodeID,
		       setType)
VDtrget_setType((nodeID),
		(setType))
#endomdef

/***********************************************************
 * Get the setName
 * Input  *nodeID
 * output *setName
 ***********************************************************/
extern IGRstat VDtrget_setName __((TGRid *nodeID, IGRchar *setName));

#omdef vdtr$GetSetName(nodeID,
		       setName)
VDtrget_setName((nodeID),
		(setName))
#endomdef
/*****************************************************
 *
 * Delimited string recovery function
 * clips out from a delimited string  a string
 * that is based upon the position of delimiters in 
 * the source string
 * Default delChr is ':'
 * Default posStr is 0
 *
 *****************************************************/
extern IGRstat VDtrGetDelimitedStr __((IGRchar *inpStr,
				       IGRchar *outStr,
				       IGRchar delChr,
				       IGRint  posStr));
#omdef vdtr$GetDelimitedStr(impStr,
			    outStr,
			    delChr,
			    posStr)


VDtrGetDelimitedStr((impStr),
		    (outStr),
		    (delChr),
		    (posStr))
#endomdef

/******************************************************
 * 
 * Get the nodeNaem from a standard path
 * File:      vds/incude/vdtr_macros.h
 * used internally to clip out the last nodeName listed
 * I = nodePath
 * O = nodeName
 * NOTE intended in a pure path not including |xxxx:xxxx at end
 * 
 ******************************************************/
extern IGRstat VDtrGetNodeNameFromPath __((IGRchar *nodePath,
                                           IGRchar *nodeName));
#omdef vdtr$GetNodeNameFromPath(nodePath,
                                nodeName)

VDtrGetNodeNameFromPath((nodePath),(nodeName))
#endomdef
/*****************************************************
 *
 * Specialized device for getting all setIDs
 * MEMORY ALLOCATED
 * all variables are outputs
 * 
 *****************************************************/
extern  IGRstat VDtrGetAllSets __((TGRid **setList,
                                   IGRint *setCnt));

#omdef vdtr$GetAllSets(setList,
                       setCnt)

VDtrGetAllSets((setList),
               (setCnt))
#endomdef

/*****************************************************
 *
 * Specialized device for getting all treeIDs
 * MEMORY ALLOCATED
 * all variables are outputs
 * 
 *****************************************************/

extern IGRstat VDtrGetAllTrees __((TGRid **treeList,
                                   IGRint *treeCnt));

#omdef vdtr$GetAllTrees(treeList,
                        treeCnt)

VDtrGetAllTrees((treeList),(treeCnt))
#endomdef

/******************************************************
 * 
 * Get the nodeKeys from the nodePath
 * '|' delimiter
 ******************************************************/
extern IGRstat VDtrGetNodeKeysFromNodePath __((IGRchar *nodePath,
                                               IGRchar *tree_key,
                                               IGRchar *node_key));

#omdef  vdtr$GetNodeKeysFromNodePath(nodePath,
                                     tree_key,
                                     node_key)

VDtrGetNodeKeysFromNodePath((nodePath),
                            (tree_key),
                            (node_key))
#endomdef

/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection criterion and processes
 * I = nodePath 
 * I = nodeProcess ("INDEX") etc
 * I = nodeIndex
 * 0 = nodeList (list of nodes) Memory allocated behind this
 * 0 = nodeCnt  (count of nodes in list) 
 *
 * ------------------------------------------------------------------------- 
*/

extern IGRstat VDtrGetTreeObjectsByProcess __((IGRchar *nodePath, 
                                               IGRchar *nodeProcess, 
                                               IGRchar *nodeIndex, 
                                               TGRid  **nodeList,
                                               IGRint  *nodeCnt));
#omdef vdtr$GetTreeObjectsByProcess(nodePath,
                                    nodeProcess,
                                    nodeIndex,
                                    nodeList, 
                                    nodeCnt)

VDtrGetTreeObjectsByProcess((nodePath),
                            (nodeProcess),
                            (nodeIndex),
                            (nodeList), 
                            (nodeCnt))
#endomdef

/*
/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection criterion and processes
 * I = nodeID
 * I = nodeProcess ("INDEX") etc
 * I = nodeIndex
 * 0 = nodeList (list of nodes) Memory allocated behind this
 * 0 = nodeCnt  (count of nodes in list) 
 *
 * ------------------------------------------------------------------------- 
*/

extern IGRstat VDtrGetTreeObjectsByProcessID __((TGRid   *nodeID, 
                                                 IGRchar *nodeProcess, 
                                                 IGRchar *nodeIndex, 
                                                 TGRid  **nodeList,
                                                 IGRint  *nodeCnt));
#omdef vdtr$GetTreeObjectsByProcessID(nodeID,
                                      nodeProcess,
                                      nodeIndex,
                                      nodeList, 
                                      nodeCnt)
  
  VDtrGetTreeObjectsByProcessID((nodeID),
                                (nodeProcess),
                                (nodeIndex),
                                (nodeList), 
                                (nodeCnt))
#endomdef
/* ------------------------------------------------------------------------
 *
 * Function to handle SA_EXP expressions 
 * for a root node
 * MEMORY IS ALLOCATED FOR **nodeList
 *
 * ------------------------------------------------------------------------
 */

extern IGRstat VDtrGetNodeListByEXP __((TGRid   *rootNode,
                                        IGRchar *attrExp,
                                        TGRid  **nodeList,
                                        IGRint  *nodeCnt)); 
#omdef vdtr$GetNodeListByEXP(rootNode,
                             attrExp,
                             nodeList,
                             nodeCnt)

VDtrGetNodeListByEXP((rootNode),
                     (attrExp),
                     (nodeList),
                     (nodeCnt))
#endomdef

/******************************************************
 * 
 * Get the truePath and not all the other stuff after the 
 * '|' delimiter
 ******************************************************/
extern IGRstat VDtrGetTruePathFromNodePath __((IGRchar *nodePath,
                                               IGRchar *truePath));


#omdef vdtr$GetTruePathFromNodePath(nodePath,
                                    truePath)

VDtrGetTruePathFromNodePath((nodePath),
                            (truePath))
#endomdef

/*****************************************************
 *
 * Tracking function to report the current Path
 * does not actually provide the path just prints
 * it out for tracking purposes.
 *
 *****************************************************/
extern IGRstat VDtrTrackPath __((IGRchar *title));

#omdef vdtr$TrackPath(title)

VDtrTrackPath((title))

#endomdef

/*****************************************************
 *
 * Open/Create a file by name
 * append the incomming buffer to it and close the 
 * file flushing the buffer
 * writes only to the current directory
 *
 *****************************************************/
extern IGRstat VDio_append_named_file __((IGRchar *fileName,
					  IGRchar *fileData));

#omdef vdio$AppendNamedFile(fileName,
			    fileData)

VDio_append_named_file((fileName),
		       (fileData))
#endomdef

/*****************************************************
 *
 * fix the problem with scroll bars that don't update
 *
 *****************************************************/
extern IGRstat VDtrFixScrollBar __((char  *form,
				    IGRint gadget));

#omdef vdtr$FixScrollBar(form,
			 gadget)

VDtrFixScrollBar((form),
		 (gadget))
#endomdef

/*****************************************************
 *
 * Fetches a Yes/No answer and returns it as
 * No  == 0
 * Yes == 1
 * function return
 * input is the request string and it is always 
 * added with the Y/N? request.
 * accepts any input repeats until a correct return is 
 * made will compare case independent
 *
 *****************************************************/
extern IGRstat VDtrGetCmdLineYNInput __((IGRchar *prompt));

#omdef vdtr$GetCmdLineYNInput(prompt)

VDtrGetCmdLineYNInput((prompt))

#endomdef

/*****************************************************
 *
 * Get the Input from the command line on the I/VDS
 * screen
 *
 *****************************************************/
extern IGRstat VDtrGetCmdLineInput __((IGRchar *prompt, IGRchar *answer));

#omdef vdtr$GetCmdLineInput(prompt,
			    answer)

VDtrGetCmdLineInput((prompt),
		    (answer))

#endomdef

/*****************************************************
 *
 * Save an XML tree to file with  prompts for correctness
 * checks to get the file name and such
 *
 *****************************************************/
extern IGRstat VDtrSaveXMLTreeToFile __((TGRid *xmlID));
#omdef vdtr$SaveXMLTreeToFile(xmlID)
VDtrSaveXMLTreeToFile((xmlID))
#endomdef


/**********************************************************************************
 * Print out structure stuff to see its content                                   *
 * No input is required but it will only print out what you supply                *
 * No title is required but it might be quite helpful                             *
 * Everything is input only                                                       *
 * Will print out all the content of the various listed structures                *
 * Will print out reports on only those structures supplied to the function       *
 **********************************************************************************/
/*
extern IGRstat VDtrPrintTblHdrX __((IGRchar               *title,
				    struct VDdrwexp_tab   *exp_tab,
				    struct VDdrwexp_data  *exp_data,
				    struct VDdrwexp_func  *exp_func,
				    struct VDdrwexp_temp  *exp_temp,
				    struct VDdrwlo_tab    *lo_tab,
				    struct VDdrwlo_sstab  *lo_sstab,
				    struct VDdrwlo_extrec *lo_extrec,
				    struct VDdrwlo_line   *lo_line,
				    struct VDdrwlo_text   *lo_text,
				    struct VDdrwlo_data   *lo_data,
				    struct VDdrwlo_sort   *lo_sort,
				    struct VDdrwlo_sqty   *lo_sqty,
				    struct VDdrwlo_qtyExp *lo_qtyExp,
				    struct VDdrwlo_smatch *lo_smatch,
				    struct VDadsym_rec    *sym_rec,
				    struct VDdrwlo_apifix *lo_apifix));

#omdef vdtr$PrintTblHdrX(title     = NULL,
			 exp_tab   = NULL,
			 exp_data  = NULL,
			 exp_func  = NULL,
			 exp_temp  = NULL,
			 lo_tab    = NULL,
			 lo_sstab  = NULL,
			 lo_extrec = NULL,
			 lo_line   = NULL,
			 lo_text   = NULL,
			 lo_data   = NULL,
			 lo_sort   = NULL,
			 lo_sqty   = NULL,
			 lo_qtyExp = NULL,
			 lo_smatch = NULL,
			 sym_rec   = NULL,
			 lo_apifix = NULL)

VDtrPrintTblHdrX((title),
		 (exp_tab),
		 (exp_data),
		 (exp_func),
		 (exp_temp),
		 (lo_tab),
		 (lo_sstab),
		 (lo_extrec),
		 (lo_line),
		 (lo_text),
		 (lo_data),
		 (lo_sort),
		 (lo_sqty),
		 (lo_qtyExp),
		 (lo_smatch),
		 (sym_rec),
		 (lo_apifix))

#endomdef
*/


#endif 
