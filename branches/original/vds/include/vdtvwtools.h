/* $Id: vdtvwtools.h,v 1.6 2001/10/02 15:55:16 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdtvw/vdtvwtools.h
 *              Supports operations of "Tree Node Selection"
 *
 * Description: Definitions for basic generic item selection
 *
 * Dependencies:
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/01  pn      Creation
 ***************************************************************************/


/* 
 * synopsis:
 * This is a list of helpful routines used for all sorts of basic chores
 * These routines include:
 * [1] making node lists
 * [2] making string lists
 * [3] ordering string lists
 * [4] Handling WildCard issues
 * [5] Validating if a string is a number 
 *
 *
 *
 * This stuff could be pretty handy for very nearly anything
 * Many of these routines allow the user to ignore memory allocation issues 
 * when using lists with the exception of freeing the lists when done.
 *
 * Other tools allow some handy tricks with list order and items in text boxes
 *
 * These tools can pretty well speed up handling nodeIDs.  In particular you no longer
 * need to worry about a list of nodeID's.  If you have a nodelist you want to start just
 * start it with one of these tools with the count of zero.  Add nodes as you see fit.
 * it even checks to see if the node is in the list before adding it to the list.
 *
 * The text list handling tools allow ordering and limiting the list to unique items 
 * Again all that is needed is to add items to the list as needed.  It takes care of 
 * the checking to see if the item is already in the list.
 */

#ifndef vdtvwtools_include
#define vdtvwtools_include

/*
 * Check a node to see if it matches attribute values
 * It allows a nodeID to be sent in together
 * with the name and value of an attribute
 * It requires the user to send in a text string
 * containing the boolean operators to be tested
 * for this condition ('=', '!=') etc.
 * It returns the 1 if the condition is met and a 
 * 0 if it is not.
 */

extern IGRint VDtvwDoesNodeHaveThisAttribute __((TGRid   *nodeID,
						 IGRchar *attrName,
						 IGRchar *attrValue,
						 IGRchar *blnTxt));

#omdef vdtvw$DoesNodeHaveThisAttribute(nodeID,
				       attrName,
				       attrValue,
				       blnTxt)
VDtvwDoesNodeHaveThisAttribute((nodeID),
			       (attrName),
			       (attrValue),
			       (blnTxt))
#endomdef

/*
 * Check for a WildCard match
 * wildCard is the string containing the wildcards of ('#' or '*')
 * item  is the string to be tested
 * returns a 1 if it matches and 0 if not
 * this could be pretty handy in a lot of places 
 */
extern IGRint VDtvwIsWildCardMatchItem __((IGRchar *wildCard,
					   IGRchar *item));
#omdef vdtvw$IsWildCardMatchItem(wildCard,
				 item)
VDtvwIsWildCardMatchItem((wildCard),
			  (item))
#endomdef


/* 
 * Add a node to a list with a check to make sure that it 
 * is not already in the list 
 * This can be used without much consideration of memory
 * allocation except to free the list when done
 * The nodeListCnt should be started at '0' value 
 * when starting to fill a list.
 * It does not need to be reset when adding a node to the 
 * existing list.  Setting to '0' will free the memory and 
 * start a new list
 * Just keep adding nodes to this list and the list will not
 * contain any duplicates and will continue to allocate 
 * memory as need be for the nodes
 */
extern IGRint VDtvwAddNodeToListUnique __((TGRid  *addNode,
					   TGRid **nodeList,
					   IGRint *nodeListCnt));

#omdef vdtvw$AddNodeToListUnique(addNode,
				 nodeList,
				 nodeListCnt)

VDtvwAddNodeToListUnique((addNode),
			 (nodeList),
			 (nodeListCnt))
#endomdef

/*
 * Subtract a node from a list
 * This allows the subtaction of a node from a list without
 * worry about the memory free issue.
 * if the count returns '0' the memory is free...
 * It does require the node list to be unique. 
 * it will look through the list and pull out any node that 
 * is specified.
 * just make nodeID the node to be removed and hand it to the list

 */
extern IGRint VDtvwRemoveNodeFromList __((TGRid    *nodeID,
					  TGRid   **List,
					  IGRint   *ListCnt));
#omdef vdtvw$RemoveNodeFromList(nodeID,
				List,
				ListCnt)

VDtvwRemoveNodeFromList((nodeID),
			(List),
			(ListCnt))

#endomdef

/*
 *  Sometimes it is useful to know if a node is in a list
 *  this is built into the node adding and subtracting routines
 *  but it can be pretty useful to check this sometimes
 *  So a rule check to see if a node is in a list
 *  nodeID is the node being checked for
 *  List is the list of nodes
 *  ListCnt is the count of nodes in the List
 */
extern VDtvwIsNodeInList __((TGRid    *nodeID,
			     TGRid    *List,
			     IGRint    ListCnt));

#omdef vdtvw$IsNodeInList(nodeID,
			  List,
			  ListCnt)

VDtvwIsNodeInList((nodeID),
		  (List),
		  (ListCnt))

#endomdef 

  /* the following two operations may be a bit much */

/*
 * Subtract a List of nodes from a list of nodes 
 */
extern IGRint VDtvwSubNodeListsUnique __((TGRid **subIDs,
					  IGRint *subIDsCnt,
					  TGRid **listIDs,
					  IGRint *listIDsCnt));
#omdef vdtvw$SumNodeListsUnique(subIDs,
				subIDsCnt,
				listIDs,
				listIDsCnt)

VDtvwSubNodeListsUnique((subIDs),
			(subIDsCnt),
			(listIDs),
			(listIDsCnt))

#endomdef

/*
 * Add a List of nodes to a list of nodes (Unique)
 */
extern VDtvwAddNodeListsUnique __((TGRid **addIDs,
				   IGRint *addIDsCnt,
				   TGRid **listIDs,
				   IGRint *listIDsCnt));

#omdef vdtvw$AddNodeListsUnique(addIDs,
				addIDsCnt,
				listIDs,
				listIDsCnt)

VDtvwAddNodeListsUnique((addIDs),
			(addIDsCnt),
			(listIDs),
			(listIDsCnt))

#endomdef

/*
 * Some String Toys that can be most useful
 */

/*
 * Add a string to a list of strings (only limit is the int count)
 * This produces a unique filtered list.  There is no Duplication allowed.
 * It takes care of the memory allocation except the free of the stringlist
 * using _LOOPFREE when done.
 * This is a tripple pointer!
 * useful trick:  If you want to subtract text from a list 
 * set up the condition check for the subtraction and add all the items in this list 
 * back to a new list except the subtracted items
 * Then _LOOPFREE the old list.
 */
extern IGRint VDtvwAddStrListUnique __((IGRchar   *item,
					IGRchar ***List,
					IGRint    *ListCnt));

#omdef vdtvw$AddStrListUnique(item,
			      List,
			      ListCnt)

VDtvwAddStrListUnique((item),
		      (List),
		      (ListCnt))

#endomdef

  /* not unique list */
extern IGRint VDtvwAddStrList __((IGRchar   *item,
				  IGRchar ***List,
				  IGRint    *ListCnt));

#omdef vdtvw$AddStrList(item,
			List,
			ListCnt)
  
  VDtvwAddStrList((item),
		  (List),
		  (ListCnt))
    
#endomdef


  /*******************************************************************
   * run the VDtvwItem .... node selection tool
   * This requires the x/y position for the form to be determined
   * and set, it also returns the "Accept" if the list was accepted
   * All based on a basenodeID sent in for the top of the display
   * any node in the tree will do 
   ********************************************************************/
/*
 * crank up and run the selection form
 * xpos and ypos can be used to place another form as
 * this keeps track of movements
 * accept reports if the list was accepted by the user
 */
extern IGRint VDtvwCTBSStartItem __((TGRid  *basenodeID,
				     IGRint *xpos,
				     IGRint *ypos,
				     IGRint *accept));

#omdef vdtvw$CTBSStartItem(basenodeID,
			   xpos,
			   ypos,
			   accept)

VDtvwCTBSStartItem((basenodeID),
		   (xpos),
		   (ypos),
		   (accept))

#endomdef
/*
 * Fetch back the itemList from the Item selection form 
 * This can only be of value if the list is accepted
 * This can also only be of value if the previous operation is 
 * done before using this one
 */
extern IGRint VDtvwGetItemList __((TGRid **itemList,
				   IGRint *itemListCnt));

#omdef vdtvw$GetItemList(itemList,
			 itemListCnt)

VDtvwGetItemList((itemList),
		 (itemListCnt))
#endomdef
/*
 * Rule check to see if the itemlist has been accepted on the form and if there
 * are nodes to return
 */
extern IGRint VDtvwIsItemAccepted __(());

 
#omdef vdtvw$IsItemAccepted()

VDtvwIsItemAccepted(())

#endomdef

  /***********************************************************
   * Some text box tricks to use with 
   * text boxes which have associated selection lists
   * This allows the ordering of such lists and 
   * allows the handling of issues regards to the
   * display of the text in the box itself
   ***********************************************************/

/*
 * Make a text box list into a unique list 
 * identify the form,gadget and flag what to do with the text 
 * in the box 
 * flag can be set to -1, 0, or 1 
 * -1  causes the displayed text to be blank
 *  0  causes the displayed text to be whatever was in the gadget
 *  1  causes the displayed text to be whatever is in the first 
 *     row of the associated list
 * addItem can be set to -1, 0, or 1 (controls adding text to the associated list)
 * -1  causes the adding of any text in the box but excludeds blank text
 *  0  does not add any text from the box  to the associated list
 *  1  causes any text from the box including blank text to be added to the associated list)
 *     (Since this is a unique list it will only add any item one time)
 */
extern IGRint VDtvwFormMakeTextItemsUnique __((Form     form,
					       IGRint   gadget,
					       IGRint   flag,
					       IGRint   addItem));
#omdef vdtvw$FormMakeTextItemsUnique(form,
				     gadget,
				     flag,
				     addItem)

VDtvwFormMakeTextItemsUnique((form),
			     (gadget),
			     (flag),
			     (addItem))

#endomdef

  /*******************************************************************
   * 
   * Did you ever want to make this unique textbox associated list
   * have an order ascending or descending?
   * the following two tools make this happen
   * Their switches are the same as just above this 
   ********************************************************************/
/*
 * SORT A TEXT BOX ASSOCIATED LIST UP / DOWN 
 */
extern IGRint VDtvwFormMakeTextItemsUniqueAUp __((Form     form,
						  IGRint   gadget,
						  IGRint   flag,
						  IGRint   addItem));

#omdef  vdtvw$FormMakeTextItemsUniqueAUp(form,
					 gadget,
					 flag,
					 addItem)
VDtvwFormMakeTextItemsUniqueAUp((form),
				(gadget),
				(flag),
				(addItem))

#endomdef

extern IGRint VDtvwFormMakeTextItemsUniqueADn __((Form     form,
						  IGRint   gadget,
						  IGRint   flag,
						  IGRint   addItem));

#omdef vdtvw$FormMakeTextItemsUniqueADn(form,
					gadget,
					flag,
					addItem)

VDtvwFormMakeTextItemsUniqueADn((form),
				(gadget),
				(flag),
				(addItem))
#endomdef

  /*******************************************************************
   * 
   * Did you ever want to make this textbox associated list
   * have an order ascending or descending?
   * the following two tools make this happen
   * Their switches are the same as just above this 
   * these are (NOT UNIQUE) lists
   ********************************************************************/
/*
 * SORT A TEXT BOX ASSOCIATED LIST UP / DOWN 
 */
extern IGRint VDtvwFormMakeTextItemsAUp __((Form     form,
					    IGRint   gadget,
					    IGRint   flag,
					    IGRint   addItem));

#omdef  vdtvw$FormMakeTextItemsAUp(form,
				   gadget,
				   flag,
				   addItem)
VDtvwFormMakeTextItemsAUp((form),
			  (gadget),
			  (flag),
			  (addItem))

#endomdef

extern IGRint VDtvwFormMakeTextItemsADn __((Form     form,
					    IGRint   gadget,
					    IGRint   flag,
					    IGRint   addItem));

#omdef vdtvw$FormMakeTextItemsADn(form,
				  gadget,
				  flag,
				  addItem)

VDtvwFormMakeTextItemsADn((form),
			  (gadget),
			  (flag),
			  (addItem))
#endomdef


  /************************************************************
   *
   * a few tools for filtering a list of nodes by type, name
   *
   ************************************************************/

/*
 * Filter a list of ID's by type(stage)
 */
extern IGRint VDtvwListFilterNodeIDsByStage __((IGRchar *stage,
						TGRid  **nodeList,
						IGRint  *nodeListCnt));
#omdef vdtvw$ListFilterNodeIDsByStage(stage,
				      nodeList,
				      nodeListCnt)

VDtvwListFilterNodeIDsByStage((stage),
			      (nodeList),
			      (nodeListCnt))
#endomdef
/*
 * Filter a list of ID's by name
 */
extern IGRint VDtvwListFilterNodeIDsByName __((IGRchar *name,
					       TGRid  **nodeList,
					       IGRint  *nodeListCnt));
#omdef vdtvw$ListFilterNodeIDsByName(name,
				     nodeList,
				     nodeListCnt)

VDtvwListFilterNodeIDsByName((name),
			     (nodeList),
			     (nodeListCnt))

#endomdef
/******************************************************
 *
 * write a file from a text buffer 
 *
 ******************************************************/
extern IGRstat VDio_write_anyFile __((IGRchar   *fileName, 
				      IGRchar   *partPath, 
				      IGRchar  **fileLines,
				      IGRint    *lineCnt));
#omdef vdio$WriteAnyFile(fileName,
			 partPath,
			 fileLines,
			 lineCnt)

VDio_write_anyFile((fileName),
		   (partPath),
		   (fileLines),
		   (lineCnt))

#endomdef 
/******************************************************
 *
 * read a file to a text buffer 
 *
 ******************************************************/
extern IGRstat VDio_read_anyFile __((IGRchar    *fileName, 
				      IGRchar   *partPath, 
				      IGRchar ***fileLines,
				      IGRint    *lineCnt));

#omdef vdio$ReadAnyFile(fileName,
			partPath,
			fileLines,
			lineCnt)
  
VDio_read_anyFile((fileName),
		  (partPath),
		  (fileLines),
		  (lineCnt))

#endomdef 


/*****************************************************
 *
 * Generic node fetching function and it does not 
 * depend on all the old stuff
 * extreme self protection 
 * and a lot of powerful features
 * including wild cards! 
 * node  may be any nodeID from the top of the tree down to the 
 * bottom of the tree.
 *
 *  ***** optional inputs ******
 * type  is optional and may be NULL or a wild card or
 *       it may be a specific nodeType.  The process will
 *       check to see if it contains a wild card or is NULL
 * name  is optional and may be NULL or a wild card or
 *       it may be a specific nodeName.  The process will
 *       check to see if it contains a wild card or is NULL
 * child May be NULL if so defaults to (0) which limits the search 
 *       to only the direct children of the node.  
 *       if (1) all children are selected
 * flag  May be NULL if so it defaluts (0) which says do not include the 
 *       nodeID (treeID) or (topID) in the list.
 *       if (1) says include the nodeID ...
 * invt  May be NULL if so it defaults to (1) which says chose these items as 
 *       they are wanted.
 *       if (0) this means to chose those not equal to the condition.
 *
 *   **** outputs *****  REQUIRED *****
 * nodeList is the list of nodes returned.  It is entirely
 *          freed and cleaned on start.
 * nodeListCnt is the count of nodes and is always started at zero.  
 * 
 * ************** wrapper for internally used function ************
 *                call this if you  are wanting a list    
 *
 *****************************************************/
extern IGRstat VDfileGetNodeList __((TGRid   *nodeID,
				     IGRchar *type, 
				     IGRchar *name,
				     IGRint  *child,
				     IGRint  *flag,
				     IGRint  *invt,
				     TGRid  **nodeList,
				     IGRint  *nodeListCnt));
#omdef vdfile$GetNodeList(nodeID,
			  type    = NULL, 
			  name    = NULL,
			  child   = NULL,
			  flag    = NULL,
			  invt    = NULL,
			  nodeList,
			  nodeListCnt)

VDfileGetNodeList((nodeID),
		  (type), 
		  (name),
		  (child),
		  (flag),
		  (invt),
		  (nodeList),
		  (nodeListCnt))
  
#endomdef

/***************************************************
 * 
 * Given a node fetch its parents up to the tree Top:
 * note: the list will return empty if the node 
 * is the treeID 
 * The order is direct parent then each up to the 
 * treeID and includes treeID if parents exist.
 * Allows direct check of parent types/names/attributes
 * from this list
 * useful for makeing the queries work faster and easier
 *
 * don't try sending it any mgrID's or setID's or setsID's
 * cannot be sure exactly what would happen if this were 
 * done
 *
 ***************************************************/
extern IGRstat VDfileGetNodeParentList __((TGRid    *nodeID,
					   TGRid   **nodeList,
					   IGRint   *nodeListCnt));

#omdef vdfile$GetNodeParentList(nodeID,
				nodeList,
				nodeListCnt)

VDfileGetNodeParentList((nodeID),
			(nodeList),
			(nodeListCnt))
#endomdef

/**************************************************************
 *
 * Given a list of nodes fetch all the nodes by the 
 * Rules in VDfileGetNodeList 
 *
 **************************************************************/
extern IGRstat VDfileGetNodeListFromList __((TGRid  **nodeIDs,
					     IGRint   nodeIDsCnt,
					     IGRchar *type, 
					     IGRchar *name,
					     IGRint  *child,
					     IGRint  *flag,
					     IGRint  *invt,
					     TGRid  **nodeList,
					     IGRint  *nodeListCnt));

#omdef vdfile$GetNodeListFromList(nodeIDs,
				  nodeIDsCnt,
				  type       = NULL, 
				  name       = NULL,
				  child      = NULL,
				  flag       = NULL,
				  invt       = NULL,
				  nodeList,
				  nodeListCnt)

VDfileGetNodeListFromList((nodeIDs),
			  (nodeIDsCnt),
			  (type), 
			  (name),
			  (child),
			  (flag),
			  (invt),
			  (nodeList),
			  (nodeListCnt))

#endomdef 

/*
 * Check to see if the string is actually a number
 * This operation returns a 1 or 0 depending on it the 
 * testStr sent to it is a number or not.
 * if it is a number it returns 1
 */

extern IGRint VDtvwIsStrNumber __((IGRchar *testStr));

#omdef vdtvw$IsStrNumber(testStr)

VDtvwIsStrNumber((testStr))

#endomdef

/**************************************************
 *
 * Get MY LEVEL list COHORT
 * useful for determining if a node is 
 * on the same level as another node.
 *
 **************************************************/
extern IGRint VDtvwGetCohortList __((TGRid   nodeID,
				     TGRid **nodesOut,
				     IGRint *nodesOutCnt));

#omdef vdtvw$GetCohortList(nodeID,
			   nodesOut,
			   nodesOutCnt)

VDtvwGetCohortList((nodeID),
		   (nodesOut),
		   (nodesOutCnt))
#endomdef
/**************************************************
 *
 * Useful string stripper to cut off back of string
 * blanks 
 *
 **************************************************/
extern IGRint VDstripstrend __((IGRchar *testStr));

#omdef VD_stripStringEnd(testStr)

VDstripstrend((testStr))
#endomdef


/*****************************************************
 *
 * Get Processing instructions from an xml Document
 * this is not any node just the xmlDocument level 
 *
 *****************************************************/
extern IGRstat VDtrGetXMLProcInstDoc __((TGRid     *nodeID,
					 IGRchar   *filter,
					 IGRchar ***instList,
					 IGRint    *instListCnt));

#omdef vdtr$GetXMLProcInstDoc (nodeID,
			       filter = NULL,
			       instList,
			       instListCnt)


VDtrGetXMLProcInstDoc((nodeID),
		      (filter),
		      (instList),
		      (instListCnt))

#endomdef

/*****************************************************
 *
 * Get Processing instructions from an xml Document
 * this is not any node just the xmlDocument level 
 *
 *****************************************************/
extern IGRstat VDtrGetXMLProcInstNode __((TGRid     *nodeID,
					  IGRchar   *filter,
					  IGRchar ***instList,
					  IGRint    *instListCnt));

#omdef vdtr$GetXMLProcInstNode (nodeID,
				filter = NULL,
				instList,
				instListCnt)
  
  
VDtrGetXMLProcInstNode((nodeID),
		       (filter),
		       (instList),
		       (instListCnt))
    
#endomdef
/*****************************************************
 *
 * Get a document level xsl style sheet ID 
 * if one exists 
 *
 * inputs
 * xmlID  - ID from xml Schema file
 * filter - MUST BE SPECIFIED like "ISDP-stylesheet"
 * output
 * xslID  - NULL_OBJID if no style sheet returns
 *          return if stylesheet an ID.
 * xslSS  - name of xslStyleSheet (optional)
 *
 * finds a style sheet definition then opens it
 * if it does not exist the xslID->objid == NULL_OBJID
 *****************************************************/
extern IGRstat VDtrGetDocStyleSheetID __((TGRid      *xmlID,
					  IGRchar    *filter,
					  TGRid      *xslID,
					  IGRchar    *xslSS));

#omdef vdtr$GetDocStyleSheetID(xmlID,
			       filter,
			       xslID,
			       xslSS = NULL)

VDtrGetDocStyleSheetID((xmlID),
		       (filter),
		       (xslID),
		       (xslSS))
		       
#endomdef
#endif 
    
    
    
    
    
