/* $Id: VDatmacroi.I,v 1.7 2001/01/23 15:11:36 build Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/XXX/VDatmacroi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDatmacroi.I,v $
 *	Revision 1.7  2001/01/23 15:11:36  build
 *	*** empty log message ***
 *	
 *	Revision 1.6  2001/01/22 18:38:24  paul_noel
 *	*** empty log message ***
 *	
 *	Revision 1.5  2001/01/22 17:31:56  hans
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/01/22 16:52:02  paul_noel
 *	*** empty log message ***
 *
 *	Revision 1.3  2001/01/22 16:09:01  paul_noel
 *	Initial Pinnacle checkin alterations
 *
 *	Revision 1.2  2001/01/19 16:47:31  paul_noel
 *	*** empty log message ***
 *
 *	Revision 1.1  2001/01/18 23:08:53  hans
 *	SP16 modifications
 *
# Revision 1.1  2000/08/04  19:07:30  pinnacle
# temporarily as apis
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 ***************************************************************************/

class implementation VDatBase;

//#define  vdsDEBUG 1

#include "VDmaster.h"
#include "VDatClass.h"		// VDAT_CHN_TO_CHILDREN
#include "VDobj.h"		// vdobj$GetParent
#include "VDatmacros.h"
#include "vdrefmacros.h"
#include "detaildef.h"


/*------------------------------------------------------------------------
 * Print tree node info for testing
 */
IGRint  VDatPrintNodeInfo( TGRid *nodeID )
{
        IGRchar	nodeName[128], nodeType[128], className[128] ;
#ifdef vdsDEBUG
	if(nodeID->objid == NULL_OBJID) return 0;

        VDatGetNodeName( nodeID, nodeName );
        VDatGetNodeType( nodeID, nodeType );
	vdobj$Get( objID = nodeID, className = className);
        printf("nodeName:[%s], nodeType:[%s], className:[%s], ID:[%d, %d]\n",
                 nodeName, nodeType, className, nodeID->objid, nodeID->osnum );
#endif
        return 1 ;
}

/*--------------------------------------------------------------------
 * Get all nodes recursively
 */
IGRstat	VDatGetTreeNodeList (
TGRid		*nodeID,
IGRchar		*type,
TGRid		*nodeList,
IGRint		*cnt)
{
	TGRid           childID;
        TGRobj_env      objOE;
	IGRchar		nodeType[128];
        IGRint          i, sts;

	SetProc(VDatGetTreeNodeList); Begin

	childID.objid		= NULL_OBJID;
	objOE.obj_id.objid	= NULL_OBJID;

	if(nodeID->objid == NULL_OBJID) {
		__DBGpr_com("NULL_OBJID, returned");
		End
		return 1;
	}
	else if ( VDatIsBaseType( nodeID, VDAT_CLASSI_LEAF) ) {
		if( type != NULL && !strcmp(type, "PART") ) {
			sts = VDatGetLeafObject( nodeID, &objOE );
			nodeList[*cnt] = objOE.obj_id;
			(*cnt)++;
		}

		End
		return 1;
	}

	// Get the children and recurse through them
	for(i = 0; VDatGetChildObject( nodeID, i, &childID); i++ ) {
		if( type != NULL) {
			nodeType[0] = '\0';
			VDatGetNodeType(&childID, nodeType);
			if( !strcmp(type,  nodeType) ) {
				nodeList[*cnt] = childID;
				(*cnt)++;
			}
		}
		else {
			nodeList[*cnt] = childID;
			(*cnt)++;
		}

		VDatGetTreeNodeList(&childID, type, nodeList, cnt);
        }

	End
        return 1;
}

/* ----------------------------------------------------------------
 */
IGRstat	VDatGetNodeListFromTree (
TGRid	*treeID,	// in,  tree id
IGRchar	*type, 		// in,  node type, NULL for all types
TGRid	*nodeList, 	// out, node list
IGRint	*nodeCnt)	// out, number of nodes
{
	IGRstat	retFlag = 0;
	IGRint	i, j, cnt = 0, num = 0;
	TGRid	nodeIDs[4096];
	IGRchar	nodeType[128];

	*nodeCnt  = 0;

	if(treeID == NULL || treeID->objid == NULL_OBJID) {
		goto wrapup;
	}
/*
	if ( !VDatIsBaseType( treeID, VDAT_CLASSI_TREE) ) {
		goto wrapup;
	}
*/
	if ( !vdobj$IsAncestryValid (	objID		= treeID,
					superClassName	= "VDatBase") ) {
		goto wrapup;
	}

	i = 0;
	if( type == NULL ) {
		if( nodeList != NULL) nodeList[i] = *treeID;
		(*nodeCnt)++;
		i = 1;
	}
	else {
		nodeType[0] = '\0';
		VDatGetNodeType(treeID, nodeType);
		if( !strcmp(type,  nodeType) ) {
			if( nodeList != NULL) nodeList[i] = *treeID;
			(*nodeCnt)++;
			i = 1;
		}
	}

	VDatGetTreeNodeList(treeID, type, nodeIDs, &cnt);

	*nodeCnt += cnt;

	if( nodeList != NULL) {
		for(j = 0; j < cnt; j++) {
			nodeList[i] = nodeIDs[j];
			i++;
		}
	}

	retFlag = 1;
wrapup:
	return retFlag;
}

/* ----------------------------------------------------------------
 * Get tree list by type. If type = NULL, output all trees
 */
IGRstat	VDatGetTreeListByType (
IGRchar		*type,		// in,	tree type, such as StagingTree or like
TGRid		*treeList,	// out,	output tree list array
IGRint		*treeCnt )	// out, number of trees
{
	IGRstat		retFlag = 0;
	IGRlong		sts, msg ;
	IGRint          i, j, k, cnt, refOsCnt;
	GRspacenum      currOs, *refOsList;
	TGRid           mgrID, stSetID, setID, setsID, rdbSetID, treeID;
	IGRchar		setType[128];

	SetProc( VDatGetTreeListByType ); Begin
	retFlag		= 0 ;
        refOsCnt        = 0;
        *treeCnt	= 0;
        refOsList       = NULL;
	mgrID.objid	= NULL_OBJID;

	// get current osnum
        ex$get_cur_mod ( osnum = &currOs ) ;

	// get reference osnums
        sts = vd$get_ref_os_list(msg            = &msg,
                                main_os         = &currOs,
                                num_ref_os      = &refOsCnt,
                                ref_os_list     = &refOsList);

        if( !(sts&msg&1) || refOsCnt == 0 || refOsList == NULL ) {
		refOsCnt = 0; // as current osnum
	}

	// go through each file to get set mgr and trees
        for( j = 0; j <= refOsCnt; j++ ) {
		for(k = 0; k < j; k++) { // kick out duplicate
			if( refOsList[k] == refOsList[j] ) break;
		}
		if( k < j ) continue;

		// get set manager, VDatSetMgr
		mgrID.objid = NULL_OBJID;
		if( j == refOsCnt ) {
			sts = VDatGetSetMgr(currOs, &mgrID);
		}
		else {
			sts = VDatGetSetMgr(refOsList[j], &mgrID);
		}
		if( !(sts&1) || mgrID.objid == NULL_OBJID) continue;

		__DBGpr_obj("mgrID", mgrID);

		// get VDatSets from mgrID
		setsID.objid = NULL_OBJID;
		if( !VDatGetSets( &mgrID, &setsID)) {
			continue;
		}

		__DBGpr_obj("setsID", setsID);

		// get VDatSet's from VDatSets, trees from VDatSet's
		for(i = 0; VDatGetChildObject(&setsID,i, &setID); i++){
			if( type != NULL ) {
				VDatRDBGetSet(&setID, &rdbSetID);
				VDatGetBaseName(&rdbSetID, setType);
				if( strcmp(setType, type)) continue;
			}

			sts = VDatGetTree(&setID, &treeID);
			if(!(sts&1) || treeID.objid == NULL_OBJID ) continue;
			if(treeList != NULL) {
				treeList[*treeCnt] = treeID;
			}
			(*treeCnt)++;
		}

        }

        retFlag = 1 ;
wrapup:
        _FREE( refOsList ) ;
	End
        return retFlag ;

}

/*----------------------------------------------------------------------
 * Get node id by node name
 */
IGRstat	VDatGetNodebyFullName(
IGRchar		*fullName,
TGRid		*nodeID)
{
	IGRstat		retFlag = 0;
	IGRlong		sts, msg;
	IGRchar		path[128], *nodeType = NULL, *setName = NULL;
	IGRint		i, j, k;
        IGRint		refOsCnt = 0, nodeCnt = 0;
        TGRid		nodeList[4096];
	TGRid		mgrID, setsID, setID, treeID, treesID;
	GRspacenum      currOs, *refOsList = NULL;

	SetProc(VDatGetNodebyFullName); Begin

	if( nodeID ) nodeID->objid = NULL_OBJID;

	__DBGpr_str("input name", fullName);
	if( fullName == NULL || fullName[0] == '\0') {
		__DBGpr_com("name is empty");
		goto wrapup;
	}


	// Get prefix as node type
	strcpy(path, fullName);
	nodeType = strtok(path, " ");
	if( nodeType == NULL ) goto wrapup;
	__DBGpr_str("nodeType", nodeType);

	// Get tree name from remaining string
	setName = strtok(NULL, "-");
	if( setName == NULL ) goto wrapup;
	__DBGpr_str("setName", setName);

	// get current osnum
        ex$get_cur_mod ( osnum = &currOs ) ;

	// get reference osnums
        sts = vd$get_ref_os_list(msg            = &msg,
                                main_os         = &currOs,
                                num_ref_os      = &refOsCnt,
                                ref_os_list     = &refOsList);

        if( !(sts&msg&1) || refOsCnt == 0 || refOsList == NULL ) {
		refOsCnt = 0; // as current osnum
	}
	mgrID.objid	= NULL_OBJID;

	// go through each file to get set mgr and trees
        for( j = 0; j <= refOsCnt; j++ ) {
		for(k = 0; k < j; k++) { // kick out duplicate
			if( refOsList[k] == refOsList[j] ) break;
		}
		if( k < j ) continue;

		// get set manager, VDatSetMgr
		mgrID.objid = NULL_OBJID;
		if( j == refOsCnt ) {
			sts = VDatGetSetMgr(currOs, &mgrID);
		}
		else {
			sts = VDatGetSetMgr(refOsList[j], &mgrID);
		}
		if( !(sts&1) || mgrID.objid == NULL_OBJID) continue;

		sts = VDatGetSets(&mgrID, &setsID);
		if( !(sts&1) || setsID.objid == NULL_OBJID) continue;

		setID.objid = NULL_OBJID;
		for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {
			treeID.objid = NULL_OBJID;
			sts = VDatGetTreeByName(&setID, setName, &treeID);
			if( (sts&1) && treeID.objid != NULL_OBJID ) break;
		}

		if( !(sts&1) || treeID.objid == NULL_OBJID) {
			continue;
		}

		sts = vdat$GetNodeList( treeID	= &treeID,
					type	= nodeType,
					nodeList= nodeList,
					nodeCnt	= &nodeCnt);

		if( !(sts&1) || nodeCnt <= 0 ) {
			__DBGpr_obj("failed to get nodelist from treeID",treeID);
			continue;
		}

		for( i = 0; i < nodeCnt; i++ ) {
			path[0] = '\0';
			VDatGetNodePath(&nodeList[i], path);
			if(path[0] == '\0') continue;
			__DBGpr_str("path from nodeList", path);
			if( !strcmp( fullName, path ) ) {
				*nodeID = nodeList[i];
				retFlag = 1;
				goto wrapup;
			}
		}

        }


	retFlag = 1;
wrapup:
	_FREE(refOsList);
	End
	return retFlag;
}

end  implementation VDatBase;
