This is a file to explain the macros for use with nodes and tables
It is a partial list of macros contained in vds/include/vdtr_macros.h

/* Particular generic processes of interest */
vdtr$GetAllTrees
	Useful to get all the trees available to the file

vdtr$GetAllSets
	Useful to get all the sets available to the file

vd$trget_nodes
	Useful to get all the nodes for specific criterion under at rootNodeID

vdtr$IsTreeAncestry
	Useful to make sure a node is actually a AST/OTM tree (other class filters are not ready yet) 

vdtr$GetTreeObjectsByProcess
	Useful to get the tree objects under a nodePath/nodeProcess/nodeIndex

vdtr$GetTreeObjectsByProcessID
	Same Process as vdtr$GetTreeObjectsByProcess except allows direct node ID access to the process
	Useful to get the tree objects under a nodeID/nodeProcess/nodeIndex

vd$trget_nodePath
	Gives the nodePath for VDct1 and VDat nodes

vdtr$GetNodeFromPath
	Returns the nodeID from a nodePath for VDct1 and VDat nodes

vd$trget_modelObject
	Returns the model object of a nodeID

vdtr$IsLeaf
	Returns the status of matching a leaf definition

vdtr$IsSet
	Returns the status of matching a set definition

vdtr$IsTree
	Returns the status of matching a tree definition

vdtr$IsNode
	Returns the status of matching a node definition

/* lesser value items */
vdtr$GetSetType
vdtr$GetNodeType
vdtr$GetSetName
vdtr$GetNodeName
	These 4 are also available by VDctxGetBaseInfo which is probably better to use
	They are just returning specific information

<Next 2 processes may or may not be of much use externally because the node to path/path to node process is complete>	
vdtr$GetNodeKeysFromNodePath
	This requires a full path designation which includes the (<truePath>|nodeKeys) nodeKeys 
	This allows the return of the nodeKeys tree_key and node_key for use

vdtr$GetTruePathFromNodePath
	This clips the truePath from the full path (<truePath>|nodeKeys)
	This is used for all the other nodePath operations -- the process of getting node from path and path from node
	is pretty much self contained. 

vdtr$GetNodeListByEXP
	May occasionally be of some external use but is called in the vdtr$GetTreeObjectsByProcess and the 
	vdtr$GetTreeObjectsByProcessID


/* ***************** example prototype calls **************************/

   // get all the nodes under the root node
/*
 * This has a lot more possible processes
 * This is but one simple call
 * check with the file for much more information
 */
  status = vd$trget_nodes( nodeID     = rootNode,
                           lookupType = VDTR_FIND_ALL_NODE,
                           outID      = &tmpNodeList,
                           cnt 	      = &tmpNodeCount ) ;

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

/*
 *  This is the new partner to getting nodePath 
 *  It returns the node from the path
 *  Bonus it also returns the treeID
 *  this is naturally a part of the retreval process
 */
	vdtr$GetNodeFromPath(nodePath     = nodePath,
			     nodeID       = &nodeID,
			     treeID       = &treeID);

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

       vd$trget_modelObject(nodeID = &nodeID,
			    objOE  = &objOE);



/*****************************************************
 *
 * Is the object a leaf?
 *
 *****************************************************/
/*
 * Rule test to see if an object fits the definition
 * of a leaf applies to VDat and VDct1 now
 */
	sts = vdtr$IsLeaf(nodeID = &nodeID);

/*****************************************************
 *
 * Is the object a set?
 *
 *****************************************************/
/*
 * Rule test to see if an object fits the definition
 * of a set 
 */
	sts = vdtr$IsSet(nodeID = &nodeID);

/*****************************************************
 *
 * Is the object a tree?
 *
 *****************************************************/
/*
 * Rule test to see if an object fits the definition
 * of a tree 
 */
	sts = vdtr$IsTree(nodeID = &nodeID);

/*****************************************************
 *
 * Is the object a node under a tree?
 *
 *****************************************************/
/*
 * Rule test to see if an object fits the definition
 * of a node 
 */
	sts = vdtr$IsNode(nodeID = &nodeID);

/*****************************************************
 *
 * Is the object of one of the trees?
 *
 *****************************************************/
/*
 * Rule to test to see if an object is of proper tree ancestry
 * applies to AST/OTM only right now
 */

      sts =  vdtr$IsTreeAncestry(nodeID = nodeID);


/***********************************************
 * Get the nodePath for any node
 * input *nodeID  (required)
 * output *path 
 ***********************************************/
/* 
 * This is the new function to get a nodePath
       vd$trget_nodePath(nodeID = &nodeID,
			 path   = nodePath);


/***********************************************************
 * Get the nodeType
 * Input  *nodeID
 * output *nodeType
 ***********************************************************/
/*
 * useful but VDctxGetBaseInfo will do the trick too!
 */ 
       vdtr$GetNodeType(nodeID   = &nodeID,
			nodeType = nodeType);



/***********************************************************
 * Get the nodeName
 * Input  *nodeID
 * output *nodeName
 ***********************************************************/
/*
 * useful but VDctxGetBaseInfo will do the trick too!
 */ 
       vdtr$GetNodeName(nodeID   = &nodeID,
			nodeName = nodeName);


/***********************************************************
 * Get the setType
 * Input  *nodeID
 * output *setType
 ***********************************************************/
/*
 * useful but VDctxGetBaseInfo will do the trick too!
 */ 
	vdtr$GetSetType(nodeID  = &nodeID,
		        setType = setType);

/***********************************************************
 * Get the setName
 * Input  *nodeID
 * output *setName
 ***********************************************************/
/*
 * useful but VDctxGetBaseInfo will do the trick too!
 */ 
	vdtr$GetSetName(nodeID  = &nodeID,
		        setName = setName);

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
/*
 * An extremely useful string clipping algorithm which clips like this
 * strcpy(impStr,"str1:str2:str3:str4:str5|str6:str7");
 * <call the function with posStr = 2 and delChr = '|'>
 * returns outStr => "str6:str7"
 * <call the function with posStr = 2 and delChr = ':'>
 * returns outStr => "str2"
 * this returns a blank string is the string position 
 * requested is not present.
 */
       vdtr$GetDelimitedStr(impStr = impStr,
			    outStr = outStr,
			    delChr = ':',
			    posStr = 2);


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
/*
 * This it a typical call which clips the node name from a new standard path 
 * NOTE: This does not apply to VDatBase Class trees
 * This is probably best not used unless this application limitation is OK
 */
#omdef vdtr$GetNodeNameFromPath(nodePath = nodePath,
                                nodeName = nodeName);


/*****************************************************
 *
 * Specialized device for getting all treeIDs
 * MEMORY ALLOCATED
 * all variables are outputs
 * 
 *****************************************************/
/* 
 * Typical call for this process which obtains a useful list 
 * containing all of the trees available
 */

       vdtr$GetAllTrees(treeList = &treeList,
                        treeCnt  = &treeCnt);

/*****************************************************
 *
 * Specialized device for getting all setIDs
 * MEMORY ALLOCATED
 * all variables are outputs
 * 
 *****************************************************/
/* 
 * Typical call for this process which obtains a useful list 
 * containing all of the sets available
 */

       vdtr$GetAllSets(setList = &setList,
                       setCnt  = &setCnt);


/******************************************************
 * 
 * Get the nodeKeys from the nodePath
 * '|' delimiter
 ******************************************************/
/* 
 * typical call for this process allows return of these key strings from
 * the nodePath. It is up to the user if they are converted to IGRstat
 */
        vdtr$GetNodeKeysFromNodePath(nodePath = nodePath,
                                     tree_key = tree_key,
                                     node_key = node_key);

/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection criterion and processes
 * I = nodePath 
 * I = nodeProcess ("INDEX") etc
 * I = nodeIndex
 * 0 = nodeList (list of nodes) Memory allocated behind this
 * 0 = nodeCnt  (count of nodes in list) 
 * *** Note *** nodeList is allocated memory (User must free)
 * ------------------------------------------------------------------------- 
*/
/* 
 * Typical call for this macro obtains a nodeList for table generation by the criterion
 * In the process 
 * This process calls vdtr$GetNodeListByEXP to get the list
*/
      vdtr$GetTreeObjectsByProcess(nodePath    = rg_list[0].desc.value.att_txt,
                                   nodeProcess = rg_list[1].desc.value.att_txt,
                                   nodeIndex   = rg_list[2].desc.value.att_txt,
                                   nodeList    = &stageNodeList, 
                                   nodeCnt     = &stageNodeCount);

/*
 * This is a similar call for the same job but allows the user
 * to avoid the development of the slowing down to get the nodePath and then
 * having to reverse the process back to get the nodeID
 * This should be a bit faster if you already have a rootNode or nodeID
 */
      vdtr$GetTreeObjectsByProcessID(nodeID      = &rootNode,
                                     nodeProcess = rg_list[1].desc.value.att_txt,
                                     nodeIndex   = rg_list[2].desc.value.att_txt,
                                     nodeList    = &stageNodeList, 
                                     nodeCnt     = &stageNodeCount);

/* ------------------------------------------------------------------------
 *
 * Function to handle SA_EXP expressions 
 * for a root node
 * MEMORY IS ALLOCATED FOR **nodeList
 *
 * ------------------------------------------------------------------------
 */
/* 
 * called by vdtr$GetTreeObjectsByProcess 
 * provides the nodeList
 */

vdtr$GetNodeListByEXP(rootNode = &rootID,
                      attrExp  = attrExp,
                      nodeList = &nodeList,
                      nodeCnt  = &nodeCnt);

