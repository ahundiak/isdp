/* $Id: VDdrwTblUp.I,v 1.42.2.2 2003/07/29 16:50:44 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/XXX/VDdrwTblUp.I
 *
 * Description:
 *	
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwTblUp.I,v $
 *	Revision 1.42.2.2  2003/07/29 16:50:44  ylong
 *	Fix for TR7750
 *
 *	Revision 1.42.2.1  2003/05/12 19:29:09  ylong
 *	TR7673 Filter out DELETED nodes/parts
 *	
 *	Revision 1.42  2002/05/20 22:26:46  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.41  2002/05/20 18:36:31  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.40  2002/05/15 13:05:16  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.37  2002/05/07 17:01:49  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.36  2002/05/02 21:15:15  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.35  2002/05/01 21:04:25  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.34  2002/04/29 15:48:19  ahundiak
 *	tr4650, missing tree structure as a parent of the table
 *	
 *	Revision 1.33  2002/04/17 19:36:08  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.32  2002/04/04 18:42:38  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.31  2002/03/30 16:57:06  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.30  2002/03/29 14:25:12  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.29  2002/03/26 16:57:18  ahundiak
 *	ETL12676
 *	
 *	Revision 1.28  2002/02/18 16:09:39  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.27  2002/02/15 21:39:13  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.26  2002/02/14 22:53:16  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.24  2002/02/05 22:05:51  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.23  2001/11/20 20:10:31  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.22  2001/11/15 20:58:43  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.21  2001/11/14 20:07:15  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.20  2001/11/14 17:08:51  ylong
 *	CR5779
 *	
 *	Revision 1.19  2001/11/09 17:58:39  ylong
 *	TR5778
 *	
 *	Revision 1.18  2001/11/06 16:31:23  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.17  2001/10/30 14:52:23  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.16  2001/10/30 14:24:57  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.15  2001/10/29 20:53:24  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.14  2001/10/29 17:57:40  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.13  2001/10/29 15:49:45  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.12  2001/10/27 22:41:17  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.10  2001/08/29 20:59:51  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.9  2001/07/16 19:26:25  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.8  2001/06/29 21:45:00  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/06/22 20:55:15  anand
 *	*** empty log message ***
 *	
 *	Revision 1.6  2001/03/08 22:41:05  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.5  2001/03/02 14:16:22  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/02/25 02:22:17  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/02/19 20:23:16  ylong
 *	mograte from vdmisc
 *	
 *	Revision 1.1  2001/01/18 23:08:58  hans
 *	SP16 modifications
 *	
# Revision 1.21  2000/10/03  19:40:48  pinnacle
# ylong
#
# Revision 1.20  2000/09/25  18:53:46  pinnacle
# ylong
#
# Revision 1.19  2000/09/13  19:35:42  pinnacle
# (No comment)
#
# Revision 1.18  2000/09/12  14:49:50  pinnacle
# changed prompt
#
# Revision 1.17  2000/08/29  22:22:58  pinnacle
# ylong
#
# Revision 1.16  2000/08/28  17:02:26  pinnacle
# (No comment)
#
# Revision 1.15  2000/08/25  19:04:12  pinnacle
# ylong
#
# Revision 1.14  2000/08/23  18:15:06  pinnacle
# ylong
#
# Revision 1.12  2000/08/18  16:39:38  pinnacle
# ylong
#
# Revision 1.10  2000/08/12  17:05:16  pinnacle
# Replaced: vds/vdmisc/VDdrwTblUp.I for:  by rchennup for Service Pack
#
# Revision 1.9  2000/08/11  21:13:00  pinnacle
# Replaced: vds/vdmisc/VDdrwTblUp.I for:  by rchennup for Service Pack
#
# Revision 1.8  2000/08/11  17:44:42  pinnacle
# ylong
#
# Revision 1.7  2000/08/10  16:00:08  pinnacle
# ylong
#
# Revision 1.6  2000/08/09  20:12:54  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY	AUTHOR	DESCRIPTION
 * 08/06/00     ylong	Created for Update Drawing and Table command
 * 10/03/00     ylong	TR179902043
 * 02/04/02	ylong	TR5918
 * 05/20/02	ylong	TR6376
 ***************************************************************************/

class implementation Root;

#define  vdsDEBUG 1

#include <stdlib.h>
#include "VDmaster.h"
#include "VDahFrm.h"		// Wrappers for FI calls
#include "VDatClass.h"		// VDAT_CHN_TO_CHILDREN
#include "VDobj.h"		// vdobj$GetParent
#include "VDfrm.h"
#include "VDatmacros.h"
#include "vdrefmacros.h"
#include "vddrwattr.h"
#include "VDsa.h"
#include "detaildef.h"
#include "griomacros.h" 

#include "vdtr_macros.h"
#include "VDdrwTblUp.h"
#include "VDtblXml.h"
#include "VDlog.h"
#include "vddlodef.h"
#include "vddlomacros.h"

from	ACcpx		import	ACfind_temp_obj;
from	GRdrawview	import	GRget_drawing_attachment_id;
from	GRdvattach	import	GRget_component_id;
from	GRvg		import	GRgetattr;
from	NDnode		import	NDgive_structure;
from	VDdrwTblRow	import	VDgetItemNumber, VDputItemNumber;
from	VDdrwTbl	import	VDgetTableParts;
from	ACrg_collect	import	ACset_list_attribute;
from	NDnode		import	NDget_objects;

extern	OMuword	OPP_GRdrawview_class_id;
extern	OMuword	OPP_VDdrawing_class_id;
extern	OMuword	OPP_VDdrw2d_class_id;
extern	OMuword	OPP_VDdrw3d_class_id;
extern	OMuword	OPP_VDdrwTbl_class_id;
extern	OMuword	OPP_VDdrwTblHdr_class_id;
extern	OMuword	OPP_VDdrwTblRow_class_id;
extern	OMuword	OPP_VDatBase_class_id;
extern	OMuword	OPP_VDct1Base_class_id;
extern	OMuword	OPP_VDatLeaf_class_id;

extern int ci_notification();
extern int VDnotify_form();

/*
 * global varibles
 */
%safe
static	IGRint	VDdrwTbl_sort_by;// = SORT_PCMK_BTN;
static	IGRchar	VDdrwTbl_startItemNo[20];
static	IGRint	UTAD_dbgOn = 0;
%endsafe

IGRint VDdrwTblCMD_setDbgOn()
{
	UTAD_dbgOn = !UTAD_dbgOn;
	if( UTAD_dbgOn )	VDlogOpenCat( "UTAD_dbg.log" );
	else			VDlogCloseCat( "UTAD_dbg.log" );
	return UTAD_dbgOn;
}

IGRint VDdrwTblCMD_dbgOn()
{
	return UTAD_dbgOn;
}


IGRlong	VDdrwTblCMD_getLeafNodes (	TGRid	*nodeID, 
					TGRid	**leafIDs, 
					IGRint	*leafCnt);

IGRlong VDdrwTblCMD_readDataList(	IGRchar         *fileName,
					IGRchar         *path,
					IGRchar         *listName,
					IGRchar         **list,
					IGRint          *itemLen,
					IGRint          *count );

void VDdrwTblCMD_getStartItemNo( IGRchar *startItemNo )
{
	strcpy( startItemNo, VDdrwTbl_startItemNo );
}

/*---------------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_setItems( TVDdrwTblInfo *info )
{
  IGRlong	sts = 0;
  IGRint	xpos,ypos,accept = 0;

  if( !info || info->rootID.objid == NULL_OBJID) goto wrapup;

  FIf_erase( info->cmdFrm );
  FIf_get_location(info->cmdFrm, &xpos, &ypos);

  /* Send tree as root */
  VDtvwCTBSStartItem(&info->rootID, &xpos, &ypos, &accept);
  FIf_set_location(info->cmdFrm, xpos, ypos);
  FIf_display( info->cmdFrm );
  sts = accept;

wrapup:
  return sts;
}
/*------------------------------------------------------------------------
 * Print process info  testing
 */
IGRint  VDdrwTbl_printNodeInfo( IGRchar *comm, struct PrcInfo *prc, IGRint cnt )
{
	IGRint		outType = VDLOG_INFO;	// can be VDLOD_DEBUG
	IGRint		stdOutFlag = 0;		// = 1 print also on screen
	IGRint		i;
	IGRchar		buf[128], buf1[128];

	if( !VDdrwTblCMD_dbgOn() ) {
		goto wrapup;
	}

	if ( prc == NULL || !cnt ) {
		goto wrapup;
	}

	sprintf(buf, "\n######### %s, Number of objects reviewed: [%d]\n", 
				comm, cnt);
	VDlogPrintBuf( outType, stdOutFlag, buf);

	for( i = 0; i < cnt; i++ ) {
		sprintf(buf, "Obj[%d]:", i); 
		VDlogPrintObject(outType, stdOutFlag, buf, &prc[i].model, NULL);
		VDlogPrintObject(outType, stdOutFlag, "ObjNew: ", &prc[i].modelNew,NULL);
		sprintf(buf, "\tprocess:[%d] path:[%s]\n", 
				prc[i].process,prc[i].path);
		VDlogPrintBuf( outType, stdOutFlag, buf);
	}
wrapup:
        return 1 ;
}

IGRlong	VDdrwTblCMD_getNodeFromModel (	TGRid	*treeID,
					TGRid	*objID,
					TGRid	*nodeID )
{
	IGRlong		sts = 0;
	TGRid		*nodeIDs = NULL;
	TGRobj_env	model;
	IGRint		nodeCnt = 0, i, vdat = 0;

	if( !treeID || !objID || !nodeID ) goto wrapup;

	nodeID->objid = NULL_OBJID;

	if( vdtr$IsTreeAncestry( nodeID = objID) ) {
		*nodeID = *objID;
		sts = 1;
		goto wrapup;
	}

	vd$trget_nodes (	nodeID		= treeID,
				lookupType	= VDTR_FIND_ALL_NODE,
				frozen		= 1,
				outID		= &nodeIDs,
				cnt		= &nodeCnt);
	if( nodeCnt < 1 || !nodeIDs ) goto wrapup;

	vdat = vdobj$IsAncestryValid(
				objID = treeID,
				superClassID = OPP_VDatBase_class_id);
 
	for( i = 0; i < nodeCnt; i++ ) {
		if( vdat && !vdtr$IsLeaf(nodeID = &nodeIDs[i]) ) continue;

		model.obj_id.objid = NULL_OBJID;
		VDctxGetModelObject( &nodeIDs[i], &model );
		if( model.obj_id.objid == objID->objid &&
		    model.obj_id.osnum == objID->osnum ) {
			*nodeID = nodeIDs[i];
			sts = 1;
			goto wrapup;
		}
	}
		
	sts = 1;
wrapup:
	_FREE( nodeIDs );
	return sts;
}


/*-----------------------------------------------------------------------
 */
IGRint	VDdrwTblCMD_get_list_select(Form form, IGRint gadget, IGRint *row)
{
	IGRint		ret = -1;
	IGRint		i, sel = 0, nrows = 0;

	*row = -1;
	if( !form ) {
		goto wrapup;
	}

	FIfld_get_list_num_rows(form, gadget, 0, &nrows);
	for( i = 0; i < nrows; i++ ) {
		sel = 0;
		FIfld_get_list_select(form, gadget, i, 0, &sel);
		if(sel) break;
	}
	
	if( i < nrows ) {
		*row = ret = i;
	}
wrapup:
	return ret;
}


/*----------------------------------------------------------------
 * Display node based on input mode
 */
void VDdrwTblCMD_displayNode( TGRid *nodeID, enum GRdpmode mode)
{
	IGRint		i, cnt = 0;
	TGRid		*nodeIDs = NULL;
	TGRobj_env	objOE;

	if( nodeID == NULL || nodeID->objid == NULL_OBJID ) goto wrapup;

	if( vdtr$IsTreeAncestry( nodeID = nodeID ) )
	{
		VDdrwTblCMD_getLeafNodes( nodeID, &nodeIDs, &cnt);
		if( cnt <= 0 || nodeIDs == NULL ) goto wrapup;

		for( i = 0; i < cnt; i++ ) {
			objOE.obj_id.objid = NULL_OBJID;
			vd$trget_modelObject (	nodeID	= &nodeIDs[i],
						objOE	= &objOE);
			gr$display_object (object_id = &objOE.obj_id, 
					   md_env    = &objOE.mod_env,
					   mode      = mode);
		}
	}
	else {
		gr$display_object (object_id = nodeID, 
				   mode      = mode);
	}

wrapup:
	_FREE(nodeIDs);
	return;
}

/* ----------------------------------------------------------------
 */
void VDdrwTblCMD_enableForm(Form form)
{
	if( form == NULL ) return;

	FIg_enable(form, SETS_FLD);
	FIg_enable(form, SELECT_BY);
	FIg_enable(form, STAGE_FLD);
	FIg_enable(form, STAGE_NAME_FLD);
	FIg_enable(form, ASSIGN_BTN);
	FIg_enable(form, REVIEW_BTN);
	FIg_enable(form, PROCESS_BTN);
	FIg_enable(form, PRINT_BTN);
	FIg_enable(form, OUTPUT_FILE_FLD);
	FIg_enable(form, REPORT_FLD);

	return;
}

/* ----------------------------------------------------------------
 */
void VDdrwTblCMD_disableForm(Form form)
{
	if( form == NULL ) return;

	FIg_disable(form, SETS_FLD);
	FIg_disable(form, SELECT_BY);
	FIg_disable(form, STAGE_FLD);
	FIg_disable(form, STAGE_NAME_FLD);
	FIg_disable(form, ASSIGN_BTN);
	FIg_disable(form, REVIEW_BTN);
	FIg_disable(form, PROCESS_BTN);
	FIg_disable(form, PRINT_BTN);
	FIg_disable(form, OUTPUT_FILE_FLD);
	FIg_disable(form, REPORT_FLD);

	return;
}

/* ----------------------------------------------------------------
 */
void VDdrwTblCMD_enableExec(Form form)
{
	if( form == NULL ) return;

	FIg_enable(form, ASSIGN_BTN);
	FIg_enable(form, REVIEW_BTN);
	FIg_enable(form, PROCESS_BTN);
	FIg_enable(form, PRINT_BTN);
	FIg_enable(form, OUTPUT_FILE_FLD);

	return;
}

/* ----------------------------------------------------------------
 */
void VDdrwTblCMD_disableExec(Form form)
{
	if( form == NULL ) return;

	FIg_disable(form, ASSIGN_BTN);
	FIg_disable(form, REVIEW_BTN);
	FIg_disable(form, PROCESS_BTN);
	FIg_disable(form, PRINT_BTN);
	FIg_disable(form, OUTPUT_FILE_FLD);

	return;
}


/* ----------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_fillNameList ( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0;
	IGRint		i, row;
	IGRchar		text[128];
	IGRchar		nodePath[128];
	IGRchar		nodeType[128];
	TGRid		*nodeIDs = NULL;
	IGRint		nodeCnt = 0;

	SetProc(VDdrwTblCMD_fillNameList); Begin

	if( info->treeID.objid == NULL_OBJID ) {
	   printf("Missing Tree id. File: %s, line: %d\n", __FILE__,__LINE__);
	   goto wrapup;
	}
	vd$trget_nodeInfo (	nodeID	 = &info->treeID,
				nodeType = nodeType,
				path	 = nodePath);
	if( !strcmp( nodeType, info->stage ) ) {
		_FREE(info->nodeList.nodeIDs);
		info->nodeList.nodeIDs = _MALLOC( 1, TGRid );
		if( !info->nodeList.nodeIDs ) goto wrapup;
		info->nodeList.nodeIDs[0] = info->treeID;
		info->nodeList.nodeCnt = 1;
		vdfrm$SetListText(form   = info->form,
				gadget = STAGE_NAME_FLD,
				row    = 0,
				txt    = nodePath);
		retFlag = 1;
		goto wrapup;
	}
	vd$trget_nodes(	nodeType	= info->stage,
			nodeID		= &info->treeID,
			lookupType	= VDTR_FIND_ALL_NODE,
			frozen		= 1,
			outID		= &nodeIDs,
			cnt		= &nodeCnt);

	if( nodeCnt < 1 || !nodeIDs ) goto wrapup;

	FIg_reset( info->form, STAGE_NAME_FLD );
	VIfld_set_list_num_rows(info->form, STAGE_NAME_FLD, 0, nodeCnt);

	for(i = 0; i < nodeCnt; i++ ) {
		nodeType[0] ='\0';
		nodePath[0] ='\0';
		vd$trget_nodeInfo (	nodeID	 = &nodeIDs[i],
					nodeType = nodeType,
					path	 = nodePath);
		vdfrm$SetListText(form   = info->form,
				gadget = STAGE_NAME_FLD,
				row    = i,
				txt    = nodePath);
	}

	_FREE(info->nodeList.nodeIDs);
	info->nodeList.nodeIDs = nodeIDs;
	info->nodeList.nodeCnt = nodeCnt;

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/* ----------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_getNodeList ( 
	TGRid	*rootID, 
	TGRid	**nodeList, 
	IGRint	*nodeCnt )
{
	IGRlong		retFlag = 0;
	IGRlong		sts, msg ;
	IGRint          i, cnt = 0;
	TGRid		*nodeIDs = NULL;

	SetProc(VDdrwTblCMD_getNodeList); Begin

	(*nodeList)	= NULL;
	(*nodeCnt)	= 0;
	
	vd$trget_nodes (	nodeID		= rootID,
				lookupType	= VDTR_FIND_ALL_NODE,
				frozen		= 1,
				outID		= &nodeIDs,
				cnt		= &cnt);


	(*nodeList) = _CALLOC( (cnt + 1),  TGRid);
	if( (*nodeList) == NULL) {
		printf("_CALLOC failed for nodeList\n");
		goto wrapup;
	}

	(*nodeList)[0] = *rootID;
	(*nodeCnt)++;
	for(i = 0; i < cnt; i++) {
		if( !vd_$is_ancestry_valid( object  = &nodeIDs[i],
					classid	  = OPP_VDct1Base_class_id ) &&
		    !vd_$is_ancestry_valid( object  = &nodeIDs[i],
                                        classid   = OPP_VDatBase_class_id ))
		{
			continue;
		}

		(*nodeList)[*nodeCnt] = nodeIDs[i];
		(*nodeCnt)++;
	}


        retFlag = 1 ;
wrapup:
	_FREE( nodeIDs );
	End
        return retFlag ;
}

/* ----------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_fillSets( TVDdrwTblInfo *info )
{
	SetProc(VDdrwTblCMD_fillSets); Begin

	VDtrTblMgrFillSets(info->form, SETS_FLD);

	End
	return 1;
}

/*------------------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_getTblObjs(TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, sts, msg;
	struct PrcInfo	*list = NULL;
	IGRint		i, cnt = 0, attrCnt = 0, nodeCnt = 0;
	TACrg_coll	*attr = NULL;
	IGRchar		nodePath[128], nodeProc[128], nodeType[128], index[40],
			*pcmk = NULL, *ptr = NULL;
	TGRid		*nodeIDs = NULL, rowID;

	SetProc(VDdrwTblCMD_getTblObjs); Begin

	nodePath[0] = '\0';
	nodeProc[0] = '\0';
	nodeType[0] = '\0';
	rowID.objid = NULL_OBJID;
	
	if( info == NULL || info->dtOE.obj_id.objid == NULL ) {
		__DBGpr_com("No tabel object input at all");
		goto wrapup;
	}
	__DBGpr_obj("info->dtOE.obj_id", info->dtOE.obj_id);

	/*
	 * get object list from table
	 */
	sts = vd$tbl_getObjects(msg		= &msg,
				tblId		= &info->dtOE.obj_id,
				count		= &cnt,
				objectList	= &list);
	if( !(sts&msg&1) ) {
		__DBGpr_com("vd$tbl_getObjects failed");
		goto wrapup;
	}
	if( cnt <= 0 || list == NULL ) {
		__DBGpr_com("Object list is NULL from vd$tbl_getObjects");
		goto wrapup;
	}

	/*
	 * check and assign attibutes for object list
	 */
	for(i = 0; i < cnt; i++) {
		list[i].type[0] = '\0';
		list[i].pcmk[0] = '\0';
		if(list[i].model.obj_id.objid == NULL_OBJID && 
		   list[i].path[0] != '\0') {
			strcpy( nodePath, list[i].path);
			if( (pcmk = strrchr(list[i].path, '-' ) ) != NULL ) {
				if( (ptr = strchr( pcmk, '|' )) != NULL ) {
					*ptr = '\0';
				}
				strcpy(list[i].pcmk, ++pcmk);
			}
			continue;
		}

		list[i].path[0] = '\0';

		sts = VDtblRowExecPplName (	&msg, 
						&list[i].model.obj_id, 
						&rowID,
						"VDrow_info",
						"type", 
						list[i].type );

		vdsa$GetStruct(	objID	= &list[i].model.obj_id, 
				name	= "SA_AST:StagingTree:0:pcmk", 
				txt	= list[i].pcmk);

		__DBGpr_obj("table object list", list[i].model.obj_id);
	}
	if( info->curList != NULL ) _FREE(info->curList);
	info->curList = list;
	info->curCnt = cnt;

	/*
	 * get root node from table
	 */
	vd$tbl_getAttributes(	msg		= &msg,
				tblId		= &info->dtOE.obj_id,
				nodeCnt		= &nodeCnt,
				nodeIds		= &nodeIDs,
				attrCnt		= &attrCnt,
				attrList	= &attr);

	if( attrCnt >= 3 ) {
		strcpy(	nodePath, attr[0].desc.value.att_txt);
		strcpy(	nodeProc, attr[1].desc.value.att_txt);
		strcpy(	index,    attr[2].desc.value.att_txt);
	}

	if( !nodeIDs || nodeIDs[0].objid == NULL_OBJID ) {
		vdtr$GetNodeFromPath (	nodePath	= nodePath,
					nodeID		= &info->rootID);
	}
	else if( nodeIDs && nodeCnt ) {
		info->rootID = nodeIDs[0];
	}
	else info->rootID.objid = NULL_OBJID;
	
	/*
	 * get path from root node, only trust root node now
	 */
	strcpy(nodeType, "unknown");
	strcpy(nodePath, "unknown");
	if( nodeIDs && nodeIDs[0].objid != NULL_OBJID ) {
		vd$trget_nodeInfo (	nodeID	= &nodeIDs[0], 
					path	= nodePath,
					nodeType= nodeType );
	}
	else {
	   printf("No tree node for the table\n");
	}

	/*
	 * get process from table: Index, Stage or Object
	 */
	
	if( !strcmp(nodeProc, "index" ) ) {
		info->select_mod = TBL_SELECT_BY_INDEX;
		FIg_set_text( info->cmdFrm, SELECT_BY, "Index");
		strcpy(info->stage, nodePath);
		info->indList.index = _MALLOC( 80*(attrCnt-2), IGRchar );
		if( !info->indList.index ) goto wrapup;
		info->indList.indLen = 80;
		info->indList.indCnt = attrCnt-2;
		for( i = 0; i < attrCnt-2; i++ ) {
			strcpy( &info->indList.index[i*info->indList.indLen],
				attr[i+2].desc.value.att_txt);
		}

		_FREE(attr); attrCnt = 0;
	}
	else if( !strcmp(nodeProc, "part_list" ) ) {
		info->select_mod = TBL_SELECT_BY_STAGE;
		FIg_set_text( info->cmdFrm, SELECT_BY, "Stage");
		strcpy(info->stage, nodeType);
		strcpy(info->sname, nodePath);
	}
	else if( !strcmp(nodeProc, "model_obj" ) ) {
		info->select_mod = TBL_SELECT_BY_OBJECT;
		FIg_set_text( info->cmdFrm, SELECT_BY, "Model_obj");
		strcpy(info->stage, nodeType);
		strcpy(info->sname, nodePath);
	}
	else if( !strcmp(nodeProc, "item" ) ) {
		info->select_mod = TBL_SELECT_BY_ITEM;
		FIg_set_text( info->cmdFrm, SELECT_BY, "Item");
		strcpy(info->stage, nodeType);
		strcpy(info->sname, nodePath);
	}

	retFlag = 1;
wrapup:
	_FREE(attr);
	End
	return retFlag;
}


/*------------------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_getDrwObjs(TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, sts, msg;
	IGRint		i, cnt;
	GRname		path, type, text;

	TGRid		drwVwId;
	TGRid		*drawings,	*drw2ds,	*drw3ds;
	IGRint		drawingCnt,	drw2dCnt,	drw3dCnt;

	IGRushort	classid;
	IGRint		chanIndex;
	struct	PrcInfo	*objInfo;
	TGRobj_env	objOE;
	TGRid		*models = NULL;

	SetProc(VDdrwTblCMD_getDrwObjs); Begin

	text[0]		= '\0';
	info->stage[0]	= '\0';
	info->sname[0]	= '\0';

	objInfo	= NULL;
	cnt	= 0;

	drawings = NULL;
	drw2ds = NULL;
	drw3ds = NULL;
	drawingCnt = 0;
	drw2dCnt = 0;
	drw3dCnt = 0;

	if(info == NULL || info->dtOE.obj_id.objid == NULL_OBJID) {
		goto wrapup;
	}

	// Get node name

	sts = VDdrwGetNodName( info->dtOE.obj_id, path );
	if( (sts&1) && path[0] != '\0' ) {

		vdtr$GetNodeFromPath (	nodePath	= path,
					nodeID		= &info->rootID);

		vd$trget_nodeInfo(	nodeID		= &info->rootID,
					path		= info->sname,
					nodeType	= info->stage);
		info->select_mod = DRW_SELECT_BY_STAGE;
	}
	else {
		info->select_mod = DRW_SELECT_BY_OBJECT;
	}

	// Get curList 

	if(info->curList != NULL) {
		_FREE(info->curList);
		info->curCnt = 0;
	}

	// Get VDdrawing's
	sts = VDgetDrawingObjects(&info->dtOE.obj_id, &drawingCnt, &drawings);
	if( !(sts & 1) || drawings == NULL ) drawingCnt = 0;

	// Get VDdrw2d's
 	drwVwId.objid   = NULL_OBJID;
        sts = VDdrw_GetChannelOwner (	&msg, 
					&info->dtOE._grid, 
					VD_O_drw2d, 
					&drwVwId );
        if((sts&msg&1) || (drwVwId.objid != NULL_OBJID)) {
		sts = VDdrw_GetChannelObjects (	&msg,	
						&drwVwId,
                                                &info->dtOE.mod_env,
                                                VD_O_drw2dObj,
                                                &drw2dCnt,
                                                &drw2ds,
						NULL);
        }

	if( !(sts&msg&1) || drw2ds == NULL ) drw2dCnt = 0;

	// Get VDdrw3d's
 	drwVwId.objid   = NULL_OBJID;
        sts = VDdrw_GetChannelOwner (	&msg, 
					&info->dtOE._grid, 
					VD_O_drw3d, 
					&drwVwId );
        if((sts&msg&1) || (drwVwId.objid != NULL_OBJID)) {
		sts = VDdrw_GetChannelObjects (	&msg,	
						&drwVwId,
                                                &info->dtOE.mod_env,
                                                VD_O_drw3dObj,
                                                &drw3dCnt,
                                                &drw3ds,
						NULL);
	}

	if( !(sts&msg&1) || drw3ds == NULL ) drw3dCnt = 0;


	// Dump all drawings to struct PrcInfo
	cnt = drawingCnt + drw2dCnt + drw3dCnt;
	if( cnt <= 0 ) goto wrapup;

	if( (objInfo = _CALLOC(cnt, struct PrcInfo) ) == NULL ) goto wrapup;
	info->curList = objInfo;
	info->curCnt = cnt;

	if( (models = _CALLOC(cnt, TGRid )) == NULL ) goto wrapup;

	for( i = 0; i < drawingCnt; i++ ) {
		VDahGetObjectEnv( &drawings[i], &objInfo[i].drwtbl);
	}

	for(  ; i < (drawingCnt + drw2dCnt); i++ ) {
		VDahGetObjectEnv( &drw2ds[i], &objInfo[i].drwtbl);
	}

	for(  ; i < cnt; i++ ) {
		VDahGetObjectEnv( &drw3ds[i], &objInfo[i].drwtbl);
	}

	// Get model objects
	i = 0;
	VDgetModelObjs(	drawings,	// inputr VDdrawing list
			drawingCnt,	// number of input
			&models[i], 	// returned model
			0 );		// chan index, 0 for VDdrawing

	i = drawingCnt;
	VDgetModelObjs(	drw2ds,		// inputr VDdrw2d list
			drw2dCnt, 	// number of input
			&models[i], 	// returned model
			1 );		// chan index, 1 for VDdrw2d

	i = drawingCnt + drw3dCnt ;
	VDgetModelObjs(	drw3ds,		// inputr VDdrw3d list
			drw3dCnt, 	// number of input
			&models[i], 	// returned model
			2 );		// chan index, 2 for VDdrw3d, maybe

	for(i = 0; i < cnt; i++) {
		objInfo[i].pcmk[0] = '\0';
		objInfo[i].type[0] = '\0';
		objInfo[i].path[0] = '\0';
		objInfo[i].model.obj_id.objid = NULL_OBJID;
		objOE.obj_id.objid = NULL_OBJID;
		objInfo[i].model.obj_id = models[i];
		VDahGetObjectEnv(&models[i], &objInfo[i].model);
		sts = om$send( msg = message  ACcpx.ACfind_temp_obj(
                                (int*)&msg,
                                "model",
                                &objOE.obj_id),
		senderid = NULL_OBJID,
                targetid = objInfo[i].drwtbl.obj_id.objid,
                targetos = objInfo[i].drwtbl.obj_id.osnum );

		__DBGpr_obj("ACpretend", objOE.obj_id);
		objInfo[i].pretend = objOE.obj_id;
		objInfo[i].application = info->obj_type;
		vdsa$GetStruct( objOE = &objInfo[i].model,
				name  = "SA_OBJ:category",
				txt   = objInfo[i].type);
		vdsa$GetStruct(	objID	= &objInfo[i].model.obj_id, 
				name	= "SA_AST:StagingTree:0:pcmk", 
				txt	= objInfo[i].pcmk);
		objInfo[i].application = info->obj_type;
		__DBGpr_obj("drawings", info->curList[i].drwtbl.obj_id);
		__DBGpr_obj("model   ", info->curList[i].model.obj_id);
		__DBGpr_obj("pretend", info->curList[i].pretend);
		__DBGpr_str("pcmk   ", info->curList[i].pcmk);
		__DBGpr_str("type   ", info->curList[i].type);

	}

	retFlag = 1;
wrapup:
	_FREE(drawings);
	_FREE(drw2ds);
	_FREE(drw3ds);
	_FREE(models);
	End
	return retFlag;
}

/* ----------------------------------------------------------------
 */
#define	NON_ITEM_NUMBER	9999999
#define	NAG_ITEM_NUMBER	-9999999

IGRlong VDdrwTblCMD_setStartItemNo( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, msg, sts;
	IGRchar		itemNo[80];
	IGRint		startNo = NON_ITEM_NUMBER;
	IGRint		i, size, nb;
	TGRid		rowID;

	SetProc( VDdrwTblCMD_setStartItemNo ); Begin

	rowID.objid = NULL_OBJID;
	for( i = 0; i < info->curCnt; i++ ) {
		if( IF_EQ_GRID(rowID,info->curList[i].drwtbl.obj_id) ) continue;

		rowID = info->curList[i].drwtbl.obj_id;
		if( rowID.objid == NULL_OBJID ) { continue; }
		sts = om$send (	msg    = message VDdrwTblRow.VDgetItemNumber
						( &msg, &size, itemNo),
				senderid = NULL_OBJID,
				targetid = rowID.objid,
				targetos = rowID.osnum );
		if( !(sts&msg&1) ) continue;
		nb = atoi(itemNo);
		if( nb < startNo && nb > 0 )  startNo = nb;
	}

	if( startNo != NON_ITEM_NUMBER ) {
		sprintf( itemNo, "%d", startNo );
		FIg_set_text(info->cmdFrm, ITEMNO_FLD, itemNo);
		strcpy( VDdrwTbl_startItemNo, itemNo );
	}

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/* ----------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_getLocatedInfo( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, msg, sts;
	IGRushort	classid;
	IGRchar		classname[128];
	IGRint		i, cnt = 0, nodeCnt = 0, nb = 0;
	TGRid		objID, *nodeIDs = NULL;

	SetProc(VDdrwTblCMD_getLocatedInfo); Begin

	if( info->dtOE.obj_id.objid == NULL_OBJID ) goto wrapup;

	sts = om$get_classid (	objid	  = info->dtOE.obj_id.objid,
				osnum	  = info->dtOE.obj_id.osnum,
				p_classid = &classid);
	if ( !(sts&1) ) goto wrapup;

	if (	classid == OPP_VDdrawing_class_id	||
  		classid == OPP_VDdrw2d_class_id		||
  		classid == OPP_VDdrw3d_class_id ) 
	{

		info->obj_type = DRAWING;
		VDdrwTblCMD_getDrwObjs(info);
		VIfld_set_list_num_rows(info->cmdFrm, SELECT_BY, 0, 2 );
		VIfld_set_list_text(info->cmdFrm, SELECT_BY, 0, 0, "Stage", FALSE);
		VIfld_set_list_text(info->cmdFrm, SELECT_BY, 1, 0, "Model_obj", FALSE);
	}
	else if(classid == OPP_VDdrwTbl_class_id)//	||
		//classid == OPP_VDdrwTblHdr_class_id	||
		//classid == OPP_VDdrwTblRow_class_id ) 
	{
		info->obj_type = TABLE;
		VDdrwTblCMD_getTblObjs(info);
		VDdrwTblCMD_setStartItemNo(info);
		VIfld_set_list_num_rows(info->cmdFrm, SELECT_BY, 0, 4 );
		VIfld_set_list_text(info->cmdFrm, SELECT_BY, 0, 0, "Stage", FALSE);
		VIfld_set_list_text(info->cmdFrm, SELECT_BY, 1, 0, "Index", FALSE);
		VIfld_set_list_text(info->cmdFrm, SELECT_BY, 2, 0, "Model_obj", FALSE);
		VIfld_set_list_text(info->cmdFrm, SELECT_BY, 3, 0, "Item", FALSE);

	}
	else {
		goto wrapup;
	}

	__DBGpr_int("info->obj_type", info->obj_type);

	info->filename[0] = '\0';
	cnt = 0;

	if( info->select_mod == TBL_SELECT_BY_ITEM )
	{
		nodeIDs = _MALLOC( info->curCnt, TGRid );
		if( !nodeIDs ) goto wrapup;
		nodeCnt = 0;
		for( i = 0; i < info->curCnt; i++ ) {
			VDdrwTblCMD_getNodeFromModel (
				&info->rootID,
				&info->curList[i].model.obj_id, 
				&objID );
			if( objID.objid != NULL_OBJID ) {
				nodeIDs[nodeCnt] = objID;
				nodeCnt++;
			}
		}
		VDtvwSetItemList( nodeIDs, nodeCnt, info->rootID, info->setID);
	}
	else if( info->select_mod == TBL_SELECT_BY_OBJECT ||
		 info->select_mod == DRW_SELECT_BY_OBJECT )
	{
		vd$tbl_getAttributes(	msg		= &msg,
					tblId		= &info->dtOE.obj_id,
					nodeCnt		= &nodeCnt,
					nodeIds		= &nodeIDs);
		if( nodeCnt < 1 || !nodeIDs ) goto wrapup;
		cnt = 0;
		if( nodeCnt > 1 ) cnt = 1;

		nb = 0;
		for( i = cnt; i < nodeCnt; i++ ) {
			VDdrwTblCMD_getNodeFromModel (
				&info->rootID,
				&nodeIDs[i], 
				&objID );
			if( objID.objid != NULL_OBJID ) {
				nodeIDs[nb] = objID;
				nb++;
			}
		}

		nodeCnt = nb;
		VDtvwSetItemList( nodeIDs, nodeCnt, info->rootID, info->setID);
	}

	FIg_enable( info->cmdFrm, 0 );
	
	retFlag = 1 ;
wrapup:
	End
	_FREE( nodeIDs ); nodeCnt = 0;
	return retFlag;
}

/*----------------------------------------------------------------
 * Filter function to get the node directly connecting to a model
 */
static IGRint modelFilter ( TGRid *nodeID )
{
	TGRobj_env	modelOE;

	if( !nodeID || nodeID->objid == NULL_OBJID ) return 0;

	modelOE.obj_id.objid = NULL_OBJID;

	VDctxGetModelObject( nodeID, &modelOE );
	if( modelOE.obj_id.objid == NULL_OBJID ) return 0;

	return 1;
}

/*-----------------------------------------------------------------
 * Get any nodes directly connecting to models. May not a Leaf for
 * VDct1 tree
 */
IGRlong	VDdrwTblCMD_getLeafNodes( TGRid	*nodeID, TGRid **leafIDs, IGRint *leafCnt)
{
	IGRlong		retFlag = 0;
	TGRid		*objIDs = NULL;
	IGRint		objCnt = 0, cnt = 0, i;
	TVDvlaID	leafVLA, *ptr = NULL;
	TVDctxNodeList	leafList;
	
	VDvlaID_Construct( &leafVLA );
	VDctxInitNodeList( &leafList );

	if( !leafIDs || !leafCnt ) goto wrapup;
	*leafIDs = NULL;
	*leafCnt = 0;

	if( !nodeID || nodeID->objid == NULL_OBJID ) goto wrapup;
	
	if(vdobj$IsAncestryValid (	objID	     = nodeID,
					superClassID = OPP_VDatBase_class_id) )
	{
		retFlag = VDatGetLeafsVLA( nodeID, &leafVLA );
		if( !retFlag )  {
			goto wrapup;
		}

		cnt = 0;
		for( ptr = &leafVLA; ptr != NULL; ptr = (TVDvlaID*)ptr->next ) {
			cnt += ptr->cnt;
		}
	
		*leafCnt = cnt;
		*leafIDs = _MALLOC( cnt, TGRid );
		if( !(*leafIDs) ) goto wrapup;

		cnt = 0;
		for( ptr = &leafVLA; ptr != NULL; ptr = (TVDvlaID*)ptr->next ) {
			for( i = 0; i < ptr->cnt; i++ ) {
				(*leafIDs)[cnt] = ptr->list[i];
				cnt++;
			}
		}
	}
	else if(vdobj$IsAncestryValid (	objID	     = nodeID,
					superClassID = OPP_VDct1Base_class_id))
	{
		VDctxGetNodeListByFilter( nodeID, modelFilter, &leafList);
		if( leafList.cnt < 1 ) goto wrapup;
		*leafIDs = _MALLOC( leafList.cnt, TGRid );
		if( !(*leafIDs) ) goto wrapup;
		for( i = 0; i < leafList.cnt; i++ ) {
			(*leafIDs)[i] = leafList.listIDs[i];
		}
		*leafCnt = leafList.cnt;
	}

	retFlag = 1;
wrapup:
	VDvlaID_Delete( &leafVLA );
	VDctxFreeNodeList( &leafList );
	return retFlag;
}


/* ----------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_getWorkNodeInfo( 
	TVDdrwTblInfo	*info, 
	TGRid		*nodeID, 
	IGRchar		*path )
{
	IGRlong		retFlag = 0, sts, msg;
	IGRint		i, row, nrows = 0, found = 0, nodeCnt = 0;
	TGRid		objID, rootID, treeID, setID, *nodeIDs = NULL;
	IGRchar		nodePath[80];
	GRname		fileName, treeName;
	OMuword		classid;
	Form		form;

	SetProc(VDdrwTblCMD_getWorkNode); Begin

	if( info == NULL ) goto wrapup;

	objID.objid = NULL_OBJID;
	rootID.objid = NULL_OBJID;
	treeID.objid = NULL_OBJID;
	setID.objid = NULL_OBJID;

	if( nodeID != NULL ) {
		rootID = *nodeID;
	}
	else if( path != NULL ) {
		vdtr$GetNodeFromPath (	nodePath	= path,
					nodeID		= &rootID);
	}
	else {
		printf("No path, no nodeId input\n");
		goto wrapup;
	}
	if( rootID.objid == NULL_OBJID ) goto wrapup;

	VDctxGetTree ( &rootID, &treeID );
	if( treeID.objid == NULL_OBJID ) goto wrapup;

	VDctxGetNodeName( &treeID, treeName );
	VDosGetFileName( treeID.osnum, fileName );

	form = info->cmdFrm;
	FIfld_get_num_rows(form, SETS_FLD, &nrows);
	for( row = 0; row < nrows; row++) {
		setID.objid = NULL_OBJID;
		vdfrm$GetText(  form    = form,
				gadget  = SETS_FLD,
				row     = row,
				col     = 3,
				objID   = &setID);
		if( setID.objid == NULL_OBJID )  continue;

		objID.objid = NULL_OBJID;
		vdtr$GetSetTree(setID	= &setID,
				treeID	= &objID);
		if( objID.objid == NULL_OBJID )  continue;


		if(objID.objid == treeID.objid && objID.osnum == treeID.osnum){
			VDdrwTblCMD_getNodeList(&treeID, &nodeIDs, &nodeCnt );
			info->setID = setID;
			info->treeID = treeID;
			info->rootID = rootID;
			info->nodeList.nodeIDs = nodeIDs;
			info->nodeList.nodeCnt = nodeCnt;
			FIfld_set_active_row(form, SETS_FLD, row, 0);
			FImcf_set_select(form, SETS_FLD, row, TRUE);
			break;
		}
	}

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/* ----------------------------------------------------------------
 * set stage and name fields
 */
IGRlong VDdrwTblCMD_setStageName( TVDdrwTblInfo *info )
{
	IGRlong	retFlag = 0, msg, sts;
	IGRint	i, stage, row;
	IGRchar	nodePath[128], text[128], *pathPtr = NULL;
	TGRid	nodeID, setID, objID, *nodePtr = NULL;
	Form	form = NULL;

	SetProc(VDdrwTblCMD_setStageName ); Begin

	// find setID and treeID which dtOE belongs to, and set them selected
	// in th form
	if(info->stage[0] == '\0') {
		__DBGpr_com("Initially, no node path found");
		retFlag = 1;
                goto wrapup;
	}

	form = info->cmdFrm;
	if( form == NULL) goto wrapup;
	sts = VDdrwTblCMD_getWorkNodeInfo( info, &info->rootID, NULL );
	if( !(sts&1) ) goto wrapup;
	
	VDdrwTblCMD_fillStageList(info);

	if( info->select_mod == TBL_SELECT_BY_INDEX ) {
		VDdrwTblCMD_fillRootList(info);
	}
	else {
		VDdrwTblCMD_fillNameList(info);
		FIg_set_text(form,STAGE_NAME_FLD,info->sname);
	}

	FIg_set_text(form,STAGE_FLD,info->stage);

	//sts = VDdrwTblCMD_getNewList(info);

	retFlag = sts;
wrapup:
	End
	return retFlag;

} 

/* ----------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_initForm( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, msg, sts;
	IGRint		stage, row;
	IGRchar		nodePath[128], text[128];
	Form		form = NULL;
	VD_drwLoInfo	drwInfo;

	SetProc(VDdrwTblCMD_initForm ); Begin

	form = info->form;
	if( form == NULL ) goto wrapup;
	__DBGpr_obj("Located object", info->dtOE.obj_id);

	/*
	 * Initialize status bars and some gadgets
	 */
	FIg_reset( form, FI_MSG_FIELD ); 
	FIg_reset( form, STAGE_NAME_FLD );
	FIg_reset( form, STAGE_FLD ); 

	text[0] = '\0';
	FIg_get_text( form, SELECT_BY, text);

	/*
	 * Get select_mod (Select by what, for what)
	 */

	if( info->obj_type == DRAWING ) {
		if(!strcmp(text, "Model_obj") ) {
			info->select_mod = DRW_SELECT_BY_OBJECT;
		}
		else {
			info->select_mod = DRW_SELECT_BY_STAGE;
		}
		FIg_erase( form, TBL_OPT_GRP );
	}
	else { // info->obj_type == TABLE
		if(!strcmp(text, "Index") ){
			info->select_mod = TBL_SELECT_BY_INDEX;
		}
		else if(!strcmp(text, "Model_obj") ) {
			info->select_mod = TBL_SELECT_BY_OBJECT;
		}
		else if(!strcmp(text, "Stage") ) {
			info->select_mod = TBL_SELECT_BY_STAGE;
		}
		else if(!strcmp(text, "Item") ) {
			info->select_mod = TBL_SELECT_BY_ITEM;
		}

		FIg_display( form, TBL_OPT_GRP );
		sts = vd$drw_layout_info (	msg	= &msg,
						type	= VD_K_drwLO_tblLinedOut,
						info	= &drwInfo );
		if( (sts&msg&1) && drwInfo.val.iValue ) {
			FIg_set_text( form, ITEMNO_OPT_FLD, "Auto");
  			info->usrOpt	= VD_TBL_ITEMNO_AUTO;
		}

		FIg_get_text( form, ITEMNO_OPT_FLD, text );
		if( !strcasecmp( text, "Auto" ) ) {
			FIg_erase( form, ITEMNO_TXT );
			FIg_erase( form, ITEMNO_FLD );
		}
		else {
			FIg_display( form, ITEMNO_TXT );
			FIg_display( form, ITEMNO_FLD );
		}
	}


	/*
	 * Set gadgets by select_mod
	 */

	FIg_erase( form, STAGE_TXT);
	FIg_erase( form, STAGE_NAME_TXT);
	FIg_erase( form, SHOW_TREE_BTN);
	FIg_erase( form, INDEX_FLD);
	//VDdrwTblCMD_disableExec(info->cmdFrm);

	switch( info->select_mod ) {

	case DRW_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_ITEM:
		FIg_display(form, SHOW_TREE_BTN);
		FIg_set_text( form, STAGE_TXT, "Stage");
		FIg_set_text( form, STAGE_NAME_TXT,"Name");
		break;

	case DRW_SELECT_BY_STAGE:
	case TBL_SELECT_BY_STAGE:
		FIg_set_text( form, STAGE_TXT, "Stage");
		FIg_set_text( form, STAGE_NAME_TXT,"Name");
		FIg_enable(form, ASSIGN_BTN);
		break;

	case TBL_SELECT_BY_INDEX:
		FIg_set_text( form, STAGE_TXT, "Root");
		FIg_set_text( form, STAGE_NAME_TXT,"Index");
		FIg_erase( form, STAGE_NAME_FLD);
		FIg_display( form, INDEX_FLD);
		break;
	};

	FIg_display( form, STAGE_TXT);
	FIg_display( form, STAGE_NAME_TXT);

	VDdrwTblCMD_setStageName(info );

	retFlag = 1;
wrapup:
	End
	return retFlag;

} 

/*--------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_fillRootList(TVDdrwTblInfo *info)
{
	IGRlong		retFlag = 0;
	IGRchar		nodePath[128];
	IGRint		i, row = 0;
	Form		form = NULL;
	TVDstageList	*nodeList;
	TGRid		*nodeIDs = NULL;
	IGRint		nodeCnt  = 0;

	nodePath[0] = '\0';

	if(info->rootID.objid == NULL_OBJID) goto wrapup;
	form = info->form;

	/*
	 * get stage from root node and set root field
	 */
	vd$trget_nodeInfo (	nodeID	= &info->rootID,
				path	= nodePath);
	VIg_set_text(form, STAGE_FLD, nodePath);
	strcpy(info->stage, nodePath);

	/* 
	 * get node list from tree id.
	 */
	VDdrwTblCMD_getNodeList (	&info->treeID, 
					&nodeIDs, 
					&nodeCnt);
	if( nodeCnt < 1 || nodeIDs == NULL ) {
		goto wrapup;
	}

	_FREE(info->nodeList.nodeIDs);
	if( (info->nodeList.nodeIDs = _CALLOC(nodeCnt, TGRid)) == NULL ) {
		goto wrapup;
	}

	info->nodeList.nodeCnt = nodeCnt;
	info->nodeList.nodeIDs = nodeIDs;

	/*
	 * fill in root list on the form
	 */
	for(i = 0; i < nodeCnt; i++) 
	{
		vd$trget_nodeInfo (	nodeID  = &nodeIDs[i],
					path    = nodePath);
		vdfrm$SetListText (	form   = form,
					gadget = STAGE_FLD,
					row    = row,
					txt    = nodePath);
		row++;
	}

	retFlag = 1;
wrapup:
	return retFlag;
}


/* ----------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_setForm( TVDdrwTblInfo *info )
{
	IGRlong	retFlag = 0, msg, sts;
	IGRint	i, select_mod = -1;
	IGRchar	nodePath[128], text[128];
	TGRid	nodeID, setID, objID;
	Form	form = NULL;

	SetProc(VDdrwTblCMD_setForm ); Begin

	form = info->form;
	if( form == NULL ) goto wrapup;
	__DBGpr_obj("Located object", info->dtOE.obj_id);

	text[0] = '\0';
	FIg_get_text( form, SELECT_BY, text);

	// Get select_mod (Select by what, for what)

	if( info->obj_type == DRAWING ) {
		if(!strcmp(text, "Stage") ) {
			select_mod = DRW_SELECT_BY_STAGE;
		}
		else if(!strcmp(text, "Model_obj") ) {
			select_mod = DRW_SELECT_BY_OBJECT;
		}
		else {
			retFlag = 1;
			goto wrapup;
		}
	}
	else { // info->obj_type == TABLE
		if(!strcmp(text, "Stage") ) {
			select_mod = TBL_SELECT_BY_STAGE;
		}
		else if(!strcmp(text, "Index") ){
			select_mod = TBL_SELECT_BY_INDEX;
		}
		else if(!strcmp(text, "Model_obj") ) {
			select_mod = TBL_SELECT_BY_OBJECT;
		}
		else if(!strcmp(text, "Item") ) {
			select_mod = TBL_SELECT_BY_ITEM;
		}
		else {
			retFlag = 1;
			goto wrapup;
		}
	}


	// Set gadgets by select_mod

	if( info->select_mod == select_mod ) {
		retFlag = 1;
		goto wrapup;
	}
		
	info->select_mod = select_mod;

	FIg_reset( form, FI_MSG_FIELD ); 
	FIg_reset( form, STAGE_NAME_FLD );
	FIg_reset( form, STAGE_FLD);
	FIg_reset( form, REPORT_FLD);
	FIg_erase( form, STAGE_TXT );
	FIg_erase( form, STAGE_NAME_TXT );
	FIg_erase( form, STAGE_NAME_FLD );
	FIg_erase( form, INDEX_FLD);
	FIg_erase(form, SHOW_TREE_BTN);
	FIg_disable(form, ASSIGN_BTN);

	switch( select_mod ) {

	case DRW_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_ITEM:
		FIg_set_text( form, STAGE_TXT, "Stage");
		FIg_set_text( form, STAGE_NAME_TXT, "Name");
		FIg_get_text( form, STAGE_NAME_FLD, text);
		FIg_display( form, STAGE_NAME_FLD );
		if( text[0] != '\0') FIg_display(form, SHOW_TREE_BTN);
		VDdrwTblCMD_fillStageList(info);
		break;

	case DRW_SELECT_BY_STAGE:
	case TBL_SELECT_BY_STAGE:
		FIg_set_text( form, STAGE_TXT, "Stage");
		FIg_set_text( form, STAGE_NAME_TXT,"Name");
		FIg_enable(form, ASSIGN_BTN);
		FIg_display( form, STAGE_NAME_FLD );
		VDdrwTblCMD_fillStageList(info);
		break;

	case TBL_SELECT_BY_INDEX:
		FIg_set_text( form, STAGE_TXT, "Root");
		FIg_set_text( form, STAGE_NAME_TXT,"Index");
		FIg_erase( form, STAGE_NAME_FLD );
		FIg_display( form, INDEX_FLD);
		vdtr$GetSetTree ( setID = &info->setID, treeID = &info->rootID);
		VDdrwTblCMD_fillRootList(info);
		VDdrwTblCMD_fillStageList( info );
		break;
	};

	FIg_display( form, STAGE_TXT);
	FIg_display( form, STAGE_NAME_TXT);

	retFlag = 1;
wrapup:
	End
	return retFlag;

} 

/* --------------------------------------
 */
IGRlong	VDdrwTblCMD_getModels(	TGRid	**modelIDs, 
				IGRint	*modelCnt )
{
	IGRlong		sts = 0, msg;
	TGRid		*nodeIDs = NULL, *tmpIDs = NULL, *leafIDs = NULL;
	IGRint		nodeCnt  = 0,    tmpCnt  = 0,    leafCnt  = 0;
	IGRint		cnt = 0, i, j, k;
	TGRobj_env	modelOE;
	
	if( !modelIDs || !modelCnt ) goto wrapup;

	*modelIDs = NULL;
	*modelCnt = 0;

	VDtvwGetItemList( &nodeIDs, &nodeCnt ); 
	if( nodeCnt < 1 || !nodeIDs ) {
		goto wrapup;
	}
	
	cnt = 0;
	tmpIDs = _MALLOC( 1, TGRid );
	if( !tmpIDs ) goto wrapup;

	for( i = 0; i < nodeCnt; i++ ) {
		VDdrwTblCMD_getLeafNodes (	&nodeIDs[i], 
						&leafIDs, 
						&leafCnt);
		tmpIDs = _REALLOC( tmpIDs, cnt+leafCnt, TGRid );
		if( !tmpIDs ) goto wrapup;
		for( j = 0; j < leafCnt; j++ ) {
			for( k = 0; k < cnt; k++ ) {
				if( tmpIDs[k].objid == leafIDs[j].objid ) break;
			}
			if( k == cnt ) {
				tmpIDs[cnt] = leafIDs[j];
				cnt++;
			}
		}
	}

	*modelCnt = 0;
	for( i = 0; i < cnt; i++ ) {
		modelOE.obj_id.objid = NULL_OBJID;
		VDctxGetModelObject( &tmpIDs[i], &modelOE );
		if( modelOE.obj_id.objid != NULL_OBJID ) {
			tmpIDs[*modelCnt] = modelOE.obj_id;
			(*modelCnt)++;
		}
	}

	*modelIDs = tmpIDs;

	sts = 1;
wrapup:
	return sts;
}

/* --------------------------------------
 */
IGRlong	VDdrwTblCMD_getNewList( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, sts = 0, msg;
	IGRint		i, j, cnt = 0, nrows, sel, pos;
	IGRint		nodeCnt = 0;
	TGRid		*nodeIDs = NULL, *tmpIDs = NULL, rowID, objID;
	TGRobj_env	objOE;
	IGRchar		nodeProc[80], nodeIndex[80];
	Form		form;

	SetProc(VDdrwTblCMD_getNewList); Begin

	if( info == NULL ) goto wrapup;

	nodeProc[0] = '\0';
	nodeIndex[0] = '\0';
	form = info->cmdFrm;

	UI_status("Loading Objects for Table ...");

	switch( info->select_mod) {

	case DRW_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_OBJECT:
		info->stage[0] = '\0';
		info->sname[0] = '\0';
		strcpy( nodeProc, "Model_obj" );
		VDdrwTblCMD_getModels( &nodeIDs, &nodeCnt );
		break;
	case TBL_SELECT_BY_ITEM:
		info->stage[0] = '\0';
		info->sname[0] = '\0';
		strcpy( nodeProc, "Item" );
		break;
	case DRW_SELECT_BY_STAGE:
		VDdrwTblCMD_displayNode( &info->rootID, GRhd);
		strcpy( nodeProc, "Model_obj" );
		break;
	case TBL_SELECT_BY_STAGE:
		VDdrwTblCMD_displayNode( &info->rootID, GRhd);
		strcpy( nodeProc, "Part_list" );
		break;
	case TBL_SELECT_BY_INDEX:
		strcpy( nodeProc, "Index" );
		FIfld_get_num_rows(form, INDEX_FLD, &nrows);
		nodeIDs = _MALLOC( 1, TGRid );
		nodeCnt = 0;
		if( !nodeIDs ) goto wrapup;
		for( i = 0; i < nrows; i++ ) {
			VIfld_get_text(form, INDEX_FLD, i, 0, 40, 
						nodeIndex, &sel, &pos);
			if( !sel ) continue;

			vdtr$GetTreeObjectsByProcessID (
				nodeID		= &info->rootID,
				nodeProcess	= nodeProc,
				nodeIndex	= nodeIndex,
				nodeList	= &tmpIDs,
				nodeCnt		= &cnt);
			if( cnt < 1 || !tmpIDs ) {
				continue;
			}

			nodeIDs = _REALLOC( nodeIDs, nodeCnt+cnt, TGRid);
			if( !nodeIDs ) goto wrapup;

			for( j = 0; j < cnt; j++ ) {
				nodeIDs[j+nodeCnt] = tmpIDs[j];
			}
			nodeCnt += cnt;
			_FREE( tmpIDs );
			cnt = 0;
		}

		if( !nodeCnt ) {
			goto wrapup;
		}
		
		break;
	default:
		goto wrapup;
	};

	if( nodeCnt < 1 ) 
	{
		vdtr$GetTreeObjectsByProcessID (
				nodeID		= &info->rootID,
				nodeProcess	= nodeProc,
				nodeIndex	= nodeIndex,
				nodeList	= &nodeIDs,
				nodeCnt		= &nodeCnt);
	}

	if( nodeCnt < 1 || !nodeIDs ) goto wrapup;

	_FREE(info->newList); 
	info->newCnt = 0;

	info->newList = _CALLOC( nodeCnt, struct PrcInfo);
	if( info->newList == NULL ) {
		printf("_CALLOC failed for newList\n");
		goto wrapup;
	}
	info->newCnt = nodeCnt;

	rowID.objid = NULL_OBJID;
	for( i = 0; i < nodeCnt; i++ ) {
		info->newList[i].type[0] = '\0';
		info->newList[i].path[0] = '\0';
		info->newList[i].pcmk[0] = '\0';
		info->newList[i].application = info->obj_type;
		info->newList[i].process = -1;

		info->newList[i].model.obj_id = nodeIDs[i];
		sts = VDtblRowExecPplName (	&msg, 
						&nodeIDs[i], 
						&rowID,
						"VDrow_info",
						"name", 
						info->newList[i].path );
		sts = VDtblRowExecPplName (	&msg, 
						&nodeIDs[i], 
						&rowID,
						"VDrow_info",
						"type", 
						info->newList[i].type );
		if( VDatIsLeaf( &nodeIDs[i] ) ) {
			objOE.obj_id.objid = NULL_OBJID;
			vd$trget_modelObject (	nodeID	= &nodeIDs[i],
						objOE	= &objOE);
			info->newList[i].model = objOE;
			nodeIDs[i] = objOE.obj_id;
		}
		vdsa$GetStruct(	objID	= &nodeIDs[i], 
				name	= "SA_AST:StagingTree:0:pcmk", 
				txt	= info->newList[i].pcmk);
		//printf("node %d: ", i);
		//vdobj$Print(objID=&info->newList[i].model.obj_id);
	}

	// clean up outList and rvwList
	_FREE(info->rvwList); info->rvwCnt = 0;
	_FREE(info->outList); info->outCnt = 0;

	//VDdrwTblCMD_enableExec(info->cmdFrm);
	UI_status("");

	retFlag = 1;
wrapup:
	_FREE( nodeIDs );
	_FREE( tmpIDs );
	if( !retFlag || !sts ) {
	   UI_status("Failed to get new list");
	   VIg_set_text(info->cmdFrm,FI_MSG_FIELD,"Failed to get new list");
	}
	End	
	return retFlag;
}

/*----------------------------------------------------------------------
 */
IGRstat	VDdrwTblCMD_getStatusStr(IGRint status, IGRchar *stsStr)
{
	IGRstat	retFlag = 0;

	if( stsStr == NULL ) goto wrapup;

	switch(status) {

	case UNCHANGED:
		strcpy(stsStr, "unchanged");
		break;
	case MODIFY:
		strcpy(stsStr, "modified");
		break;
	case DELETE:
		strcpy(stsStr, "deleted");
		break;
	case MIGRATE:
		strcpy(stsStr, "migrate");
		break;
	case NEW_MODEL:
		strcpy(stsStr, "added");
		break;
	case CONNECT:
		strcpy(stsStr, "unconsumed");
		break;
	default:
		strcpy(stsStr, "unknown");
	};

	retFlag = 1;
wrapup:
	return retFlag;
}

/* --------------------------------------
 */
IGRlong	VDdrwTblCMD_fillReport (
Form		form,
IGRint		gadget,
struct	PrcInfo	*objInfo,
IGRint		cnt)
{
	IGRlong		retFlag = 0;
	IGRint		i;
	IGRchar		stsStr[128], path;
	TGRobj_env	objOE;

	if(cnt <= 0 ) goto wrapup;
	if( form == NULL || objInfo == NULL ) goto wrapup;

	stsStr[0] = '\0';

	FIg_reset(form, gadget);

	for(i = 0; i < cnt; i++) {
		stsStr[0] = '\0';
		VDdrwTblCMD_getStatusStr(objInfo[i].process, stsStr);
		__DBGpr_obj("objInfo[i].modelNew", objInfo[i].modelNew.obj_id);
		__DBGpr_str("objInfo[i].path", objInfo[i].path);
		__DBGpr_str("objInfo[i].process", stsStr);

		vdfrm$SetText (	form	= form,
				gadget	= gadget,
				row	= i,
				col	= 0,
				txt	= objInfo[i].pcmk);

		vdfrm$SetText (	form	= form,
				gadget	= gadget,
				row	= i,
				col	= 1,
				txt	= objInfo[i].path);

		vdfrm$SetText (	form	= form,
				gadget	= gadget,
				row	= i,
				col	= 2,
				txt	= objInfo[i].type);

		vdfrm$SetText (	form	= form,
				gadget	= gadget,
				row	= i,
				col	= 3,
				txt	= stsStr);
		vdfrm$SetText (	form	= form,
				gadget	= gadget,
				row	= i,
				col	= 4,
				objOE	= &objInfo[i].modelNew);
	}

	retFlag = 1;
wrapup:
	return retFlag;
}


/*-------------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_getPathFromFullPath(IGRchar *fullPath, IGRchar *path)
{
	IGRlong		retFlag = 0;
	TGRid		nodeID;
	GRname		buf;
	IGRchar		*ptr = NULL, *endp = NULL;

	if( fullPath == NULL || path == NULL ) goto wrapup;

	path[0] = '\0';

	/*
	nodeID.objid = NULL_OBJID;

	vdtr$GetNodeFromPath (	nodePath	= fullPath,
				nodeID		= &nodeID);

	vd$trget_nodeInfo (	nodeID	= &nodeID,
				path	= path);

	if( path[0] == '\0' ) strcpy( path, fullPath );
	*/

	strcpy( buf, fullPath );
	if( !strncmp( buf, "OTM:", 4 ) || !strncmp( buf, "AST:", 4 ) ) {
		ptr = buf + 4;
		endp = strchr( ptr, '|' );
		if ( endp ) *endp = '\0';
		strcpy( path, ptr );
	}
	else {
		strcpy( path, fullPath );
	}

	retFlag = 1;
wrapup:
	return retFlag;
}

/* ------------------------------------------------------------------
 */
static int setAppendList( struct PrcInfo *e1, struct PrcInfo *e2 )     
{
	if( e1->process == NEW_MODEL && e2->process != NEW_MODEL ) {
		return 1;
	}
	else if( e1->process != NEW_MODEL && e2->process == NEW_MODEL ) {
		return -1;
	}
	else {
		return 0;
	}
}

/* ------------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_chkStartItemNo( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, sts, msg = 1;
	IGRint		i, max = 0, nb = 0, size;
	IGRchar		itemNo[40], text[128];
	TGRid		rowID;
	Form		form;

	SetProc( VDdrwTblCMD_chkStartItemNo ); Begin
	if( !info ) goto wrapup;

	form = info->cmdFrm;

	*VDdrwTbl_startItemNo = 0;

	if( !( info->usrOpt & VD_TBL_ITEMNO_AUTO ) ) 
	{
		FIg_get_text( form, ITEMNO_FLD, itemNo );
		VD_stripString( itemNo );
		if( isdigit( *itemNo ) ) {
			sprintf( VDdrwTbl_startItemNo, "%d", atoi(itemNo) );
		}
	}


	nb = atoi(VDdrwTbl_startItemNo);

	if( !( info->usrOpt & VD_TBL_ITEMNO_MANUAL ) ) {
		retFlag = 1;
		goto wrapup;
	}

	for( i = 0; i < info->curCnt; i++ ) {
		rowID = info->curList[i].drwtbl.obj_id;
		if( rowID.objid == NULL_OBJID ) { continue; }

		sts = om$send (	msg    = message VDdrwTblRow.VDgetItemNumber
						( &msg, &size, itemNo),
				senderid = NULL_OBJID,
				targetid = rowID.objid,
				targetos = rowID.osnum );
		if( !(sts&msg&1) ) {
			continue;
		}
		if( isdigit( *itemNo ) ) max = atoi( itemNo);
	}

	if( max > 0 ) max++;
	else {
		retFlag = 1;
		goto wrapup;
	}
	if( nb < max && nb > 0 ) {
		if( !GRconfirm_box("Start item number is invalid. Accept next available item number value?") ) {
			sprintf(text, "Next available item number is greater or eqeal to %d", max);
			UI_status( text );
			goto wrapup;
		} 
		else {
			sprintf( VDdrwTbl_startItemNo, "%d", max );
			FIg_set_text( form, ITEMNO_FLD, VDdrwTbl_startItemNo );
		}
	}

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/* ------------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_reviewOut( TVDdrwTblInfo *info )
{
	IGRlong			retFlag = 0, sts, msg = 1;
	IGRchar			path[128], *chPtr = NULL;
	IGRint			i, j, bufSize = 0, percent;
	IGRint			newCnt	= 0, rvwCnt = 0;
	TGRobj_env		*newOEs	= NULL;
	struct PrcInfo		*rvwList = NULL, *ptr;
	TGRobj_env		expOE;
	TGRmd_env		md_env;
	struct	ret_struct	exp;
	IGRchar			szmsg[128], itemNo[80];

	SetProc(VDdrwTblCMD_reviewOut); Begin

	sts = VDdrwTblCMD_getNewList(info);

	if(info->curCnt  <= 0 || info->curList == NULL ) {
		printf("curList NOT found\n");
		goto wrapup;
	}
	if(info->newCnt  <= 0 || info->newList == NULL ) {
		printf("newList NOT found\n");
		goto wrapup;
	}

	if(info->outCnt > 0 || info->outList != NULL) {
		_FREE(info->outList);
		info->outCnt = 0;
	}
	
	newCnt = info->newCnt;

	UI_prompt("");

	if((newOEs = _CALLOC(newCnt, TGRobj_env)) == NULL) goto wrapup;
	for(i = 0; i < newCnt; i++) {
		newOEs[i] = info->newList[i].model;
	}

	switch(info->obj_type) {

	case TABLE:
		sts = vd$review_table(
			msg	= &msg,
			curList = info->curList,
			curCnt  = info->curCnt,
			newList = newOEs,
			newCnt  = newCnt,
			outList = &info->outList,
			outCnt  = &info->outCnt);
		break;

	case DRAWING:
		sts = vd$review_drawing(
			curList = info->curList,
			curCnt  = info->curCnt,
			newList = newOEs,
			newCnt  = newCnt,
			outList = &info->outList,
			outCnt  = &info->outCnt);
		break;
	};

	if(!(sts&msg&1) || info->outCnt <= 0 ) {
		printf("------- review failed ---------\n");
		goto wrapup;
	}

	rvwCnt = info->outCnt;
	if( rvwCnt == 0 ) goto wrapup;
	if( (rvwList = _CALLOC( rvwCnt, struct PrcInfo )) == NULL ) {
		printf("_CALLOC failed for rvwList\n");
		goto wrapup;
	}

	// assign path, pcmk and type to outList for displaying
	for(i = 0; i < info->outCnt; i++ ) {
		percent = 1 + 100*i/info->outCnt;
		if( !(percent%10) ) {
		  sprintf( szmsg, "Processing Review List: %d%s", percent,"%" );
		  UI_status( szmsg );
		}

		rvwList[i].path[0] = '\0';
		rvwList[i].pcmk[0] = '\0';
		rvwList[i].type[0] = '\0';

		rvwList[i].model	= info->outList[i].model;
		rvwList[i].modelNew	= info->outList[i].modelNew;
		rvwList[i].drwtbl	= info->outList[i].drwtbl;
		rvwList[i].pretend	= info->outList[i].pretend;
		rvwList[i].VDdrwSet	= info->outList[i].VDdrwSet;
		rvwList[i].application	= info->outList[i].application;
		rvwList[i].process	= info->outList[i].process;

		if(rvwList[i].modelNew.obj_id.objid == NULL_OBJID) {
			rvwList[i].modelNew = rvwList[i].model;
		}

		if( info->obj_type == TABLE && rvwList[i].process == DELETE ) {
			// in this case, path is filled with occurance, and pcmk
			// and type are set to nulls in vd$review_table()
			strcpy(rvwList[i].path, info->outList[i].path);
			strcpy(rvwList[i].pcmk, info->outList[i].pcmk);
			continue;
		}

		// get from newList
		for(j = 0; j < newCnt; j++ ) {
		  ptr = &info->newList[j];
		  if(rvwList[i].modelNew.obj_id.objid == ptr->model.obj_id.objid &&
		     rvwList[i].modelNew.obj_id.osnum == ptr->model.obj_id.osnum)
		  {
			strcpy(rvwList[i].path, ptr->path);
			strcpy(rvwList[i].pcmk, ptr->pcmk);
			strcpy(rvwList[i].type, ptr->type);
			break;
		  }
		}

		if(rvwList[i].path[0] != '\0') {
			VDdrwTblCMD_getPathFromFullPath(rvwList[i].path, path);
			strcpy( rvwList[i].path, path);
			continue;
		}

		// get from curList
		for(j = 0; j < info->curCnt; j++ ) {
		   ptr = &info->curList[j];
		   if (	rvwList[i].model.obj_id.objid == ptr->model.obj_id.objid &&
			rvwList[i].model.obj_id.osnum == ptr->model.obj_id.osnum)
		   {
			strcpy(rvwList[i].path, ptr->path);
			strcpy(rvwList[i].pcmk, ptr->pcmk);
			strcpy(rvwList[i].type, ptr->type);
			break;
		   }
		}
		if(rvwList[i].path[0] != '\0') {
			VDdrwTblCMD_getPathFromFullPath(rvwList[i].path, path);
			strcpy( rvwList[i].path, path);
			continue;
		}

		// get type from drawing's foot "macro"
		expOE.obj_id.objid = NULL_OBJID;

		vdobj$GetFoot(	objOE	 = &rvwList[i].drwtbl,
				footName = "macro",
				footOE	 = &expOE);
		__DBGpr_obj("Gtext object: macro", expOE.obj_id);
		sts = om$send(	msg = message NDnode.NDgive_structure
					(&msg, &exp, &expOE.mod_env),
				senderid = NULL_OBJID,
				targetid = expOE.obj_id.objid,
				targetos = expOE.obj_id.osnum);
		if(!(sts&msg&1) ) {
			__DBGpr_com("NDnode.NDgive_structure 1 failed");
			continue;
		}

		if(	strstr(exp.var.text_st.text_string, "beam") ||
			strstr(exp.var.text_st.text_string, "Beam") ) {
			strcpy(rvwList[i].type, "beam");
		}
		else if(strstr(exp.var.text_st.text_string, "plate") ||
			strstr(exp.var.text_st.text_string, "Plate") ) {
			strcpy(rvwList[i].type, "plate");
		}
		else {
			strcpy(rvwList[i].type, "other");
		}

		__DBGpr_str("exp", exp.var.text_st.text_string);
		__DBGpr_int("beam and Beam", !strncmp("VSsrcBeam","Beam", 3));

		// get occurence from drawing's foot "occurence" 
		// as a path for deleted model object
		expOE.obj_id.objid = NULL_OBJID;
		vdobj$GetFoot(	objOE	 = &rvwList[i].drwtbl,
				footName = "occurence",
				footOE	 = &expOE);
		__DBGpr_obj("Gtext object: macro", expOE.obj_id);
		sts = om$send(	msg = message NDnode.NDgive_structure
					(&msg, &exp, &expOE.mod_env),
				senderid = NULL_OBJID,
				targetid = expOE.obj_id.objid,
				targetos = expOE.obj_id.osnum);
		if(!(sts&msg&1) ) {
			__DBGpr_com("NDnode.NDgive_structure 1 failed");
			continue;
		}
		strcpy(rvwList[i].path, exp.var.text_st.text_string);
	}

	UI_status( "Complete Review List" );

	VDdrwTbl_printNodeInfo( "curList", info->curList, info->curCnt );
	VDdrwTbl_printNodeInfo( "newList", info->newList, info->newCnt );
	VDdrwTbl_printNodeInfo( "outList", info->outList, info->outCnt );
	//VDdrwTbl_printNodeInfo( "rvwList", rvwList, rvwCnt );

	_FREE(info->rvwList);
	info->rvwList = rvwList;
	info->rvwCnt  = rvwCnt;

	UI_prompt("Manipulate Form:");

	retFlag = 1;
wrapup:
	_FREE(newOEs);
	if( !retFlag ) {
		UI_status("Update Review failed ");
		VIg_set_text(info->cmdFrm,FI_MSG_FIELD,"Update Review failed");
	}
	End
	return retFlag;
}

/* ------------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_readDataList(      
				IGRchar         *fileName,
                                IGRchar         *path,
                                IGRchar         *listName,
                                IGRchar         **list,
                                IGRint          *itemLen,
                                IGRint          *count )
{
        IGRlong         sts = 0, msg;
        IGRint          maxLen = 0, cnt = 0;
        IGRchar         filePath[80], buf[80], tmpBuf[80];
        IGRchar         *ptr = NULL;
        FILE            *fp = NULL;

        filePath[0]     = '\0';

        if( !listName || !list || !itemLen || !count ) goto wrapup;

        *list = NULL;
        *count = 0;


        vd$file_path(   msg                             = &msg,
                        fileToFind                      = fileName,
                        dirToSearchFirst                = ".",
                        dirInProdPathToSearchThen       = path,
                        absPathName                     = filePath);


        if( !(msg&1) || filePath[0] == '\0' ) goto wrapup;

        __DBGpr_str("filePath", filePath);

        fp = (FILE*)VD_openFile( &msg, filePath, "r" );
        if( !fp ) goto wrapup;

        while( fgets( buf, DI_PATH_MAX, fp ) ) {
                while( (ptr = strchr( buf, '\n' ) ) != NULL ) *ptr = ' ';
                VD_stripString(buf);

                __DBGpr_str("buf from file", buf);

                if( buf[0] != '%' ) continue;
                buf[0] = ' ';
                VD_stripString(buf);
                if( !strcmp( buf, listName ) ) {
                        while( fgets( tmpBuf, DI_PATH_MAX, fp ) ) {
                                if( tmpBuf[0] == '%' ) break;
                                if( tmpBuf[0] == '#' ) {
                                        tmpBuf[0] = ' ';
                                        VD_stripString(tmpBuf);
                                        if( strlen(tmpBuf) > maxLen )
                                                maxLen = strlen(tmpBuf);
                                        cnt++;
                                }
                        }
                        break;
                }
        }

        maxLen++;
        *count = cnt;
        if( maxLen*cnt < 1 ) goto wrapup;

        *list = _MALLOC( cnt*maxLen, IGRchar );
        if( !list ) goto wrapup;

        rewind(fp);

        cnt = 0;
        while( fgets( buf, DI_PATH_MAX, fp ) ) {
           while( (ptr = strchr( buf, '\n' ) ) != NULL ) *ptr = ' ';
           VD_stripString(buf);
           if( buf[0] != '%' ) continue;
           buf[0] = ' ';
           VD_stripString(buf);
           if( !strcmp( buf, listName ) ) {
              while( fgets( tmpBuf, DI_PATH_MAX, fp ) ) {
                 if( tmpBuf[0] == '%' ) break;
                 if( tmpBuf[0] == '#' ) {
                    tmpBuf[0] = ' ';
                    while( (ptr = strchr( tmpBuf, '\n' ) ) != NULL ) *ptr = ' ';
                    VD_stripString(tmpBuf);
                    strcpy( &(*list)[cnt*maxLen], tmpBuf );
                    cnt++;
                 }
              }
              break;
           }
        }

        *itemLen = maxLen;

        sts = 1;
wrapup:
        return sts;
}

/* ------------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_fillStageList( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0;
	IGRint		i, j, cnt = 0, gadget, active_row = -1;
	IGRchar		nodeType[128], treeType[128];
	Form		form = NULL;
	IGRchar		*strList = NULL;
	TGRid		rootID;
	IGRchar		*exprList = NULL;     
	IGRint		exprLen = 0, len = 0, sel,
			exprCnt = 0;
	
	SetProc(VDdrwTblCMD_fillStageList);Begin
	
	rootID.objid = NULL_OBJID;

	if(info == NULL) goto wrapup;

	form = info->cmdFrm;

	vdtr$GetNodeType (	nodeID	 = &info->treeID,
				nodeType = treeType );

	switch(info->select_mod) {
	
	case DRW_SELECT_BY_STAGE:
	case DRW_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_STAGE:
	case TBL_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_ITEM:
		gadget = STAGE_FLD;
		FIg_reset(form, gadget );
		vd$trget_stages(treeID		= &info->treeID,
				stages		= &strList,
				stageCnt	= &cnt);
		for( i = 0; i < cnt; i++ ) {
			vdfrm$SetListText (
				form   = form,
				gadget = gadget,
				row    = i,
				txt    = &strList[VDTR_NODE_NAME_LEN*i]);
		}

		break;
	case TBL_SELECT_BY_INDEX:
		gadget = INDEX_FLD;

		vd$trget_stages(treeID		= &info->rootID,
				stages		= &strList,
				stageCnt	= &cnt);
		if( cnt < 1 ) {
		   strList = _MALLOC(	VDTR_NODE_NAME_LEN, IGRchar);
		   if( !strList ) goto wrapup;
		}

		VDdrwTblCMD_readDataList (	"expr_table",
						"config/drawing",
						treeType,
						&exprList,     
						&exprLen,
						&exprCnt );
		strList = _REALLOC (	strList,
					(2+cnt+exprCnt)*VDTR_NODE_NAME_LEN, 
					IGRchar);
		if( !strList ) goto wrapup;

		for( i = 0; i < exprCnt; i++ ) {
			strcpy( &strList[VDTR_NODE_NAME_LEN*(i+cnt)],
				&exprList[i*exprLen]);
		}
		cnt += exprCnt;
				
		VIfld_set_num_rows(form, gadget, cnt );
		len = info->indList.indLen;
		for( i = 0; i < cnt; i++ ) {
		    sel = 0;
		    for( j = 0; j < info->indList.indCnt; j++ ) {
			if(!strcmp(	&info->indList.index[j*len], 
					&strList[VDTR_NODE_NAME_LEN*i])) {
			    if( active_row < 0 ) active_row = i;
			    sel = 1;
			    break;
			}
		    }
		    VIfld_set_text(form, gadget, i, 0,
				&strList[VDTR_NODE_NAME_LEN*i], sel);
		}

		if( active_row >= 0 ) {
		    FIfld_set_active_row(form, gadget, active_row, 0);
		}
		else {
		    UI_status("No specified stage exists under the root node"); 
		    VIg_set_text(form,FI_MSG_FIELD,
			     "No specified stage exists under the root node");
		}
		break;
	};


	retFlag = 1;
wrapup:
	_FREE(strList);
	_FREE( exprList );
	End
	return retFlag;
}

/* --------------------------------------
 */
IGRlong VDdrwTblCMD_resetForm( TVDdrwTblInfo *info )
{
	IGRlong	retFlag = 0, sts ;

	IGRchar	text[128];
	IGRint	i;

	SetProc( VDdrwTblCMD_resetForm ); Begin

	FIg_reset(info->form, SETS_FLD);
	sts = VDdrwTblCMD_fillSets(info);
	if(!sts) goto wrapup;

	FIfld_set_num_rows(info->form, STAGE_FLD, 0);
	memset(&text[0],0,sizeof(text));
	FIg_set_text(info->form,STAGE_FLD,text);
	FIg_set_text(info->form,STAGE_NAME_FLD,text);

	FIg_reset(info->form, STAGE_FLD);
	FIg_reset(info->form, STAGE_NAME_FLD);
	FIg_reset(info->form, REPORT_FLD);
	FIg_reset(info->form, OUTPUT_FILE_FLD);

	FIg_disable( info->form, 0 );
	FIg_enable( info->form, FI_CANCEL );

	VDdrwTblCMD_delete(info);
	VDdrwTblCMD_init(info);

	retFlag = 1;

wrapup:
	End
	return retFlag;

} // VDdrwTblCMD_resetForm

/* --------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_setNodeName(TVDdrwTblInfo *info)
{
	IGRlong		retFlag = 0, sts, msg;
	IGRint		i, nrows = 0, sel = 0, pos = 0, cnt = 0;
	IGRint		nbHdrs = 0, nbParents = 0;
	IGRchar		stage[128], name[128], nodePath[128], msgStr[128];
	IGRchar		fullPath[128];
struct	ACrg_coll	attr[50];
	Form		form;
	TGRid		parentIds[3], *hdrIds = NULL;

	SetProc(VDdrwTblCMD_setNodeName); Begin

	if( info == NULL || info->dtOE.obj_id.objid == NULL_OBJID ) {
		goto wrapup;
	}

	form = info->cmdFrm;

	// Empty table attribute collector

	sts = om$send (	msg      = message VDdrwTbl.VDgetTableParts(
							&msg,
							&nbHdrs,
							NULL),
			senderid = NULL_OBJID,
			targetid = info->dtOE.obj_id.objid,
			targetos = info->dtOE.obj_id.osnum );
	if( !(sts&msg&1) || (nbHdrs < 1) ) goto wrapup;

	hdrIds = _MALLOC( nbHdrs, struct GRid );
	if( hdrIds == NULL ) goto wrapup;

	sts = om$send (	msg      = message VDdrwTbl.VDgetTableParts(
							&msg,
							&nbHdrs,
							hdrIds),
			senderid = NULL_OBJID,
			targetid = info->dtOE.obj_id.objid,
			targetos = info->dtOE.obj_id.osnum );
	if( !(sts&msg&1) ) goto wrapup;

	sts = om$send (	msg      = message NDnode.NDget_objects(
							ND_ROOT,
							parentIds,
							3,
							NULL,
							0,
							OM_K_MAXINT,
							&nbParents),
			senderid = NULL_OBJID,
			targetid = hdrIds[0].objid,
			targetos = hdrIds[0].osnum );
	if( !(sts&msg&1) ) goto wrapup;

	sts = om$send (	msg      = message ACrg_collect.ACset_list_attribute(
							&msg,
							0,
							NULL),
			senderid = NULL_OBJID,
			targetid = parentIds[0].objid,
			targetos = parentIds[0].osnum );
	if( !(sts&msg&1) ) goto wrapup;

	// Set node name to drawing or table

	fullPath[0] = '\0';
	vd$trget_nodeInfo (	nodeID		= &info->rootID,
				fullPath	= fullPath);

	if(fullPath[0] == '\0') {
		vd$trget_nodeInfo (	nodeID		= &info->treeID,
					fullPath	= fullPath);
	}

	attr[0].desc.type = 1;
	attr[1].desc.type = 1;
	attr[2].desc.type = 1;
	strcpy(attr[0].name, "node_path");
	strcpy(attr[1].name, "node_process");
	strcpy(attr[2].name, "node_index");

	switch( info->select_mod ) {

	case DRW_SELECT_BY_STAGE:
		msg = 1;
		sts = VDdrwSetNodName(info->dtOE.obj_id, fullPath);
		break;
	case TBL_SELECT_BY_STAGE:
		strcpy(attr[0].desc.value.att_txt, fullPath);
		strcpy(attr[1].desc.value.att_txt, "part_list");
		strcpy(attr[2].desc.value.att_txt, "unknown");

		sts = vd$tbl_setAttributes (	msg	 = &msg,
						tblId	 = &info->dtOE.obj_id,
						attrList = attr,
						attrCnt	 = 3);
		break;
	case TBL_SELECT_BY_INDEX:
		strcpy(attr[0].desc.value.att_txt, fullPath);
		strcpy(attr[1].desc.value.att_txt, "index");
		cnt = 2;
		FIfld_get_num_rows(form, INDEX_FLD, &nrows);
		for( i = 0; i < nrows; i++ ) {
			VIfld_get_text(form, INDEX_FLD, i, 0, 40, 
						name, &sel, &pos);
			if( !sel ) continue;
			attr[cnt].desc.type = 1;
			sprintf(attr[cnt].name, "node_index_%d", cnt-2);
			strcpy( attr[cnt].desc.value.att_txt, name);
			cnt++;
		}
		if( cnt < 3 ) {
			strcpy(msgStr, "Missing Index");
			goto wrapup;
		}
		strcpy(attr[2].name, "node_index");
		sts = vd$tbl_setAttributes (	msg	 = &msg,
						tblId	 = &info->dtOE.obj_id,
						attrList = attr,
						attrCnt	 = cnt);
		break;
	case TBL_SELECT_BY_OBJECT:
		strcpy(attr[0].desc.value.att_txt, fullPath);
		strcpy(attr[1].desc.value.att_txt, "model_obj");
		strcpy(attr[2].desc.value.att_txt, "unknown");
		sts = vd$tbl_setAttributes (	msg	 = &msg,
						tblId	 = &info->dtOE.obj_id,
						attrList = attr,
						attrCnt	 = 3);

		break;
	case TBL_SELECT_BY_ITEM:
		strcpy(attr[0].desc.value.att_txt, fullPath);
		strcpy(attr[1].desc.value.att_txt, "item");
		strcpy(attr[2].desc.value.att_txt, "unknown");
		sts = vd$tbl_setAttributes (	msg	 = &msg,
						tblId	 = &info->dtOE.obj_id,
						attrList = attr,
						attrCnt	 = 3);

		break;
	};
	
	if( (sts&msg&1) ) {
		strcpy(msgStr, "Node path assigned");
	}
	else {
		strcpy(msgStr, "Failed to assign node path");
	}
	
	retFlag = 1;
wrapup:
	UI_status(msgStr);
	VIg_set_text(form,FI_MSG_FIELD, msgStr);
	End
	return retFlag;
}

/* --------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_processSet( TVDdrwTblInfo *info)
{
	IGRlong		retFlag = 0, sts;
	IGRint		row, sel = 0, pos;
	TGRid		setID, treeID;

	SetProc(VDdrwTblCMD_processSet); Begin

	setID.objid = NULL_OBJID;
	treeID.objid = NULL_OBJID;
	
	// Clean up some gadgets
	FIg_reset(info->cmdFrm, STAGE_FLD);
	FIg_reset(info->cmdFrm, STAGE_NAME_FLD);
	FIg_reset(info->cmdFrm, REPORT_FLD);

	// Disable PRINT, REVIEW and PROCESS
	//VDdrwTblCMD_disableExec(info->cmdFrm);

	// Get active and selected row
	VIfld_get_active_row(info->cmdFrm, SETS_FLD, &row,&pos);
	VIfld_get_select(info->cmdFrm, SETS_FLD, row, 0, &sel);

	if( !sel ) {
		FIg_disable( info->cmdFrm, STAGE_FLD);
		FIg_disable( info->cmdFrm, STAGE_NAME_FLD);
		FIg_disable( info->cmdFrm, SELECT_BY);
		FIg_disable( info->cmdFrm, SHOW_TREE_BTN);
		goto wrapup;
	}
	else {
		FIg_enable( info->cmdFrm, STAGE_FLD);
		FIg_enable( info->cmdFrm, STAGE_NAME_FLD);
		FIg_enable( info->cmdFrm, SELECT_BY);
		FIg_enable( info->cmdFrm, SHOW_TREE_BTN);
	}

	// Get selected set
	setID.objid = NULL_OBJID;
	vdfrm$GetText(  form    = info->cmdFrm,
			gadget  = SETS_FLD,
			row     = row,
			col     = 3,
			objID   = &setID);
	if( setID.objid == NULL_OBJID) goto wrapup;

	info->setID = setID;

	// Get tree from set
	vdtr$GetSetTree (	setID	= &setID,
				treeID	= &info->treeID);

	sts = VDdrwTblCMD_getNodeList (	&info->treeID,
					&info->nodeList.nodeIDs,
					&info->nodeList.nodeCnt);
	info->rootID = info->treeID;

	switch( info->select_mod ) {

	case DRW_SELECT_BY_STAGE:
	case TBL_SELECT_BY_STAGE:
	case DRW_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_OBJECT:
	case TBL_SELECT_BY_ITEM:
		VDdrwTblCMD_fillStageList(info);
		break;

	case TBL_SELECT_BY_INDEX:
		VDdrwTblCMD_fillRootList(info);
		VDdrwTblCMD_fillStageList(info);
		break;
	};

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/*--------------------------------------------------------------
 */
IGRlong	VDdrwTblCMD_setRowItemNo( TVDdrwTblInfo *info, TGRid xtblID )
{
	IGRlong		retFlag = 0, sts = 1, msg = 1;
	IGRint		i, nb = -999;
	IGRchar		itemNo[80];
	TGRid		rowID;

	SetProc(VDdrwTblCMD_setRowItemNo); Begin

	if( !info || info->outCnt < 1 ) goto wrapup;

	FIg_get_text( info->cmdFrm, ITEMNO_FLD, itemNo );
	VD_stripString(itemNo);
	if( isdigit(itemNo[0]) ) {
		nb = atoi( itemNo );
	}
	else {
		*itemNo = 0;
	}

	rowID.objid = NULL_OBJID;
	for( i = 0; i < info->outCnt; i++ ) {
		if( IF_EQ_GRID(rowID,info->outList[i].drwtbl.obj_id) ) continue;

		rowID = info->outList[i].drwtbl.obj_id;
		if( rowID.objid == NULL_OBJID ) { continue; }

		if( isdigit(itemNo[0] )) sprintf( itemNo, "%d", nb );
		sts = om$send (	msg    = message VDdrwTblRow.VDputItemNumber
						( &msg, itemNo),
				senderid = NULL_OBJID,
				targetid = rowID.objid,
				targetos = rowID.osnum );
		if( (sts&msg&1) ) nb++;
	}

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/*-------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_getUsrOpt( TVDdrwTblInfo *info )
{
	IGRlong		retFlag = 0, status, msg;
	IGRint		sel, startNo = 0;
	IGRchar		itemOpt[40], itemNo[40];
	Form		form;
	VD_drwLoInfo	drwInfo;

	form = info->cmdFrm;

	info->usrOpt = 0;

	/*
	 * keep user values in the table
	 */
	status = vd$drw_layout_info (	msg	= &msg,
					type	= VD_K_drwLO_tblUsrValue,
					info	= &drwInfo );
	if( (status&msg&1) && drwInfo.val.iValue ) {
		info->usrOpt |= VD_TBL_USR_VAL;
	}

	/*
	 * get append new objs to bottom opt
	 */
	FIg_get_state( form, APPEND_CHK, &sel );
	if( sel ) info->usrOpt |= VD_TBL_APP_NEW;

	/*
	 * get item number options
	 */
	FIg_get_text( form, ITEMNO_OPT_FLD, itemOpt );

	switch( itemOpt[0] ) {
	
	case 'o':
	case 'O':
		info->usrOpt |= VD_TBL_ITEMNO_OVERW;
		break;
	case 'm':
	case 'M':
		info->usrOpt |= VD_TBL_ITEMNO_MANUAL;
		break;
	case 'a':
	case 'A':
		info->usrOpt |= VD_TBL_ITEMNO_AUTO;
		break;
	};
	
	/*
	 * get review lined out option
	 */
	FIg_get_state( form, REV_LINED_OUT_CHK, &sel );
	if( sel ) info->usrOpt |= VD_TBL_REV_LINED_OUT;

	if( !VDdrwTblCMD_chkStartItemNo ( info ) ) goto wrapup;

	retFlag = 1;
wrapup:
	return retFlag;
}

/* --------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_update( TVDdrwTblInfo *info)
{
	IGRlong		retFlag = 0, sts = 1, msg = 1;
	IGRshort	usrValOpt = 0;
	TGRid		ctxID, xtblID;
	TGRid		*nodeIDs = NULL, *objIDs = NULL, *ptr = NULL;
	IGRint		nodeCnt = 0, i;

	SetProc(VDdrwTblCMD_update); Begin

	if( info == NULL ) goto wrapup;

	if( info->outCnt == 0 ||info->outList == NULL ) {
		sts = VDdrwTblCMD_reviewOut(info);
	}

	if( (!sts) || info->outCnt < 1 || info->outList == NULL ) {
		goto wrapup;
	}

	UI_prompt("");

	ctxID.objid = NULL_OBJID;
	xtblID.objid = NULL_OBJID;
	VDdrwTblCMD_setNodeName(info);

	switch( info->obj_type ) {
	
	case DRAWING:
		if(vd_$is_ancestry_valid( 
				object  = &info->dtOE.obj_id,
				classid = OPP_VDdrawing_class_id ))
		{
		    sts = VDGetContext(&info->dtOE.obj_id, &ctxID, NULL, 0, 0);
		}
		else if(vd_$is_ancestry_valid(
				object  = &info->dtOE.obj_id,
				classid = OPP_VDdrw2d_class_id ))
		{
		    sts = VDGetContext(&info->dtOE.obj_id, &ctxID, NULL, 0, 1);
		}
		else {
			goto wrapup;
		}

		if( !(sts&1) || ctxID.objid == NULL_OBJID ) {
			printf("Failed to get ctxID\n");
			goto wrapup;
		}

		sts = vd$drw_process (	refId    = ctxID,
					procList = info->outList,
					procCnt  = info->outCnt);

		break;
	case TABLE:
		
		if(!VDdrwTblCMD_getUsrOpt( info )) goto wrapup;

		if (	(info->usrOpt & VD_TBL_USR_VAL)       ||
			(info->usrOpt & VD_TBL_ITEMNO_MANUAL) ||
			(info->usrOpt & VD_TBL_ITEMNO_AUTO)   ) 
		{ 

			sts = vd$xmltbl_create ( tblID	 = &info->dtOE.obj_id, 
						 xtreeID = &xtblID ); 

			if( VDtbl_getDbgState() ) {
				VDctxSaveTreeToXmlFile(&xtblID, "UTAD_cur.xml");
			}
		} 

		if( info->select_mod == TBL_SELECT_BY_OBJECT ||
		    info->select_mod == DRW_SELECT_BY_OBJECT ) 
		{
			VDtvwGetItemList( &nodeIDs, &nodeCnt ); 
			if( nodeCnt > 0 ) {
				objIDs = _MALLOC( nodeCnt+1, TGRid );
				if( objIDs ) {
					objIDs[0] = info->rootID;
					nodeCnt++;
					for( i = 1; i < nodeCnt; i++ ) {
						objIDs[i] = nodeIDs[i-1];
					}
					ptr = objIDs;
				}
				else nodeCnt = 0;
			}
		}
		
		if( !nodeCnt ) {
			ptr = &info->rootID;
			nodeCnt = 1;
		}

		//VDdrwTblCMD_setRowItemNo( info, xtblID );
		
		vd$tbl_process( msg		= &msg,
				tblId		= &info->dtOE.obj_id,
				nodeIds		= ptr,
				nbNodes		= nodeCnt,
				newList		= info->outList,
				newCnt		= info->outCnt,
				usrOpt		= info->usrOpt,
				xtblId		= &xtblID);


		break;
	default:
		printf("Invalid obj_type\n");
		goto wrapup;
	};

	VDdrwTblCMD_printOutput(info);
	VDdrwTblCMD_disableForm(info->cmdFrm);

	retFlag  = 1;
wrapup:
	if(xtblID.objid != NULL_OBJID ) {
		VDctxDeleteNode( &xtblID );
		xtblID.objid = NULL_OBJID;
	}

	if( !retFlag ) {
		UI_status("Command failed ");
		VIg_set_text(info->cmdFrm,FI_MSG_FIELD,"Update failed");
	}
	else {
		UI_status("Update done ");
		VIg_set_text(info->cmdFrm,FI_MSG_FIELD,"Update done");
	}
	End
	_FREE( nodeIDs );
	_FREE( objIDs );

	return retFlag ;
}

/*------------------------------------------------------------------
 */
IGRstat	VDdrwTblCMD_FillTree(Form form, IGRint gadget, TGRid *setID)
{
	IGRstat		retFlag = 0;


	if(vdobj$IsAncestryValid(	objID = setID,
                              superClassID = OPP_VDatBase_class_id) )
	{
		VDatPKTFormFillTree(form, gadget, setID);
	}
	else if( vdobj$IsAncestryValid(objID = setID,
                              superClassID = OPP_VDct1Base_class_id) )
	{
		VDct1PKTFormFillTree(form, gadget, setID);
	}

	retFlag = 1;
wrapup:
	return retFlag;

}


/*-----------------------------------------------------------------
 */
void VDdrwTblCMD_fitObject(TVDdrwTblInfo *info)
{
	IGRlong		sts, msg;
	IGRint		response;
	IGRchar		response_data[128];
	struct	GRevent	event;
	TGRid		winID;
	TGRobj_env	objOE;
	IGRint		row = -1, pos, sel = 0;
	

	winID.objid = NULL_OBJID ;
	objOE.obj_id.objid = NULL_OBJID ;

	VIfld_get_active_row(info->cmdFrm, REPORT_FLD, &row,&pos);
	if(row < 0 ) return;

	VIfld_get_select(info->cmdFrm, REPORT_FLD, row, 0, &sel);
	if( !sel ) return;
	
	vdfrm$GetText(  form    = info->cmdFrm,
			gadget  = REPORT_FLD,
			row     = row,
			col     = 4,
			objOE   = &objOE);

	if( objOE.obj_id.objid == NULL_OBJID ) return;

	sts = co$getevent(msg		= &msg,
			prompt		= "Identify Window or Move on for all",
			response	= &response,
			event		= &event,
			response_data	= response_data,
			event_mask	= GRm_DATA);

	if( response == RESET ) {
		sts = vd$vw_fit_object( factor   = 2.0,
					object   = &objOE.obj_id);
	}
	else if( response == DATA ) {
		winID.objid	= event.event.button.objid;
		winID.osnum	= event.event.button.osnum;
		sts = vd$vw_fit_object( object   = &objOE.obj_id,
					ggid     = &winID,
					factor   = 2.0,
					num_ggid = 1 );
	}
	if((sts&1)) gr$display_object(object_id = &objOE.obj_id, mode  = GRhd );


	return;
}


/*-----------------------------------------------------------------
 */
void VDdrwTblCMD_hiliteObj(TVDdrwTblInfo *info)
{
	IGRint		row = -1, sel = 0, pos = -1, gadget;
	TGRobj_env	objOE;
	Form		form;
	enum GRdpmode	mode;

	if( info == NULL || info->cmdFrm == NULL ) goto wrapup;

	form = info->cmdFrm;
	gadget = REPORT_FLD;
	objOE.obj_id.objid = NULL_OBJID;

	VIfld_get_active_row(form, gadget, &row, &pos);
	VIfld_get_select(form, gadget, row, 0, &sel);
	vdfrm$GetText(  form    = form,
			gadget  = gadget,
			row     = row,
			col     = 4,
			objOE   = &objOE);
	__DBGpr_obj("selected object", objOE.obj_id);

	if( sel == 1 ) {
		__DBGpr_int("active row selected", row);
		mode = GRhd;
	}
	else {
		__DBGpr_int("active row not selected", row);
		mode = GRhe;
	}
	
	VDdrwTblCMD_displayNode( &objOE.obj_id, mode);
	
wrapup:
	return;
}

IGRstat	VDdrwTblCMD_notifyIndex( TVDdrwTblInfo *info )
{
	IGRstat		retFlag = 0;
	IGRlong		sts;
	IGRint		row = -1, sel = 0, pos;
	IGRint		gadget, sortby;

	retFlag = 1;
wrapup:
	return retFlag;
}


/*--------------------------------------------------------------------
 */
IGRstat VDdrwTblCMD_notifyItemNo(TVDdrwTblInfo *info)
{
	IGRstat ret = 0;
	IGRchar	itemOpt[20];
	Form	form;

	form = info->form;

	FIg_get_text( form, ITEMNO_OPT_FLD, itemOpt );
	if( !strcasecmp( itemOpt, "Auto" ) ) {
		FIg_erase( form, ITEMNO_TXT );
		FIg_erase( form, ITEMNO_FLD );
	}
	else {
		FIg_display( form, ITEMNO_TXT );
		FIg_display( form, ITEMNO_FLD );
	}

	/* clean item number option bits */
	info->usrOpt &= ~VD_TBL_ITEMNO_OVERW  & 
			~VD_TBL_ITEMNO_MANUAL & 
			~VD_TBL_ITEMNO_AUTO ;

	switch( itemOpt[0] ) {
	
	case 'o':
	case 'O':
		info->usrOpt |= VD_TBL_ITEMNO_OVERW;
		break;
	case 'm':
	case 'M':
		info->usrOpt |= VD_TBL_ITEMNO_MANUAL;
		break;
	case 'a':
	case 'A':
		info->usrOpt |= VD_TBL_ITEMNO_AUTO;
		break;
	};

	ret = 1;
wrapup:
	return ret;
}

/*--------------------------------------------------------------------
 */
IGRstat VDdrwTblCMD_notifyFrm(TVDdrwTblInfo *info)
{
	IGRstat		retFlag = 0;
	IGRlong		sts;
	IGRint		row = -1, sel = 0, pos;
	IGRint		gadget, sortby;
	Form		form;
	IGRchar		text[128];
	TGRid		nodeID;
	TGRid		*nodeIDs = NULL;
	IGRint		nodeCnt = 0;


	SetProc(VDdrwTblCMD_notifyFrm); Begin

	if(info == NULL ) {
		goto wrapup;
	}

	if(info->form == NULL ) {
		goto wrapup;
	}

	// Command form
	if( info->form != info->cmdFrm) goto wrapup;
	form = info->form;
	gadget = info->gadget;
	text[0] = '\0';
	nodeID.objid = NULL_OBJID;

	switch (gadget) {

	case FI_CANCEL:
		retFlag = FI_CANCEL;  // Will bubble up and shutdown command
		goto wrapup;

	case ASSIGN_BTN:
		sts = VDdrwTblCMD_setNodeName(info);
		break;

	case REVIEW_BTN: 
		// get outList
		UI_status("Processing Review...");
		sts = VDdrwTblCMD_reviewOut(info);

		// sort list
		if(VDdrwTbl_sort_by > SORT_PCMK_BTN && 
	 	   VDdrwTbl_sort_by < SORT_STATUS_BTN) {
			sortby = VDdrwTbl_sort_by;
		}
		else sortby = SORT_PCMK_BTN;
		VDdrwTblCMD_sortList(info->rvwList, info->rvwCnt, VDdrwTbl_sort_by);

		// fill in report
		VDdrwTblCMD_fillReport(	form, 
					REPORT_FLD,
					info->rvwList,
				 	info->rvwCnt);

		UI_status("Process done");
		if(!(sts&1) ) goto wrapup;
		break;

	case REPORT_FLD:
		VDdrwTblCMD_hiliteObj(info);
		break;
	// Run
	case PROCESS_BTN: 
		UI_status("Processing...");
		sts = VDdrwTblCMD_update( info );
		if( !sts ) break;
		VDdrwTblCMD_resetForm( info );
		UI_status("Process done");
		UI_prompt("Identify Table or Drawing");
		break;

	case SETS_FLD: 
		VDdrwTblCMD_processSet(info);
		break;

	case SELECT_BY:
		sts = VDdrwTblCMD_setForm( info );
		//VDdrwTblCMD_disableExec(form);
		break;

	case STAGE_FLD:
		//VDdrwTblCMD_disableExec(form);
		FIg_reset( info->form, STAGE_NAME_FLD );
		FIg_get_text( form, STAGE_FLD, text );
		VDdrwTblCMD_get_list_select(form, STAGE_FLD, &row);
		if(text[0] == '\0') break;
		strcpy(info->stage, text);
		if( info->select_mod == TBL_SELECT_BY_STAGE ) 
		{
			if( !strcmp( text, "PM" ) ) {
				info->stage[0] = '\0';
				FIg_set_text( form, STAGE_FLD, "" );
	   			VIg_set_text(info->cmdFrm,FI_MSG_FIELD,
					"Leaf is not allowed for Stage");
				break;
			}
			sts = VDdrwTblCMD_fillNameList(info);
		}
		else if( info->select_mod == TBL_SELECT_BY_ITEM   ||
			 info->select_mod == TBL_SELECT_BY_OBJECT ||
			 info->select_mod == DRW_SELECT_BY_OBJECT ||
			 info->select_mod == DRW_SELECT_BY_STAGE   )
		{
			  sts = VDdrwTblCMD_fillNameList(info);
		}
		else if( info->select_mod == TBL_SELECT_BY_INDEX ) 
		{
			info->rootID = info->nodeList.nodeIDs[row];
			info->nodeList.index = row;
			FIg_erase( info->form, STAGE_NAME_FLD );
			FIg_display( info->form, INDEX_FLD );
			sts = VDdrwTblCMD_fillStageList( info );
		}
		FIg_erase(form, SHOW_TREE_BTN);
		break;

	case STAGE_NAME_FLD:
		UI_status("Processing...");
		FIg_get_text( form, STAGE_NAME_FLD, text );
		if(text[0] == '\0') break;
		strcpy(info->sname, text);
		VDdrwTblCMD_get_list_select(form, STAGE_NAME_FLD, &row);
		info->rootID = info->nodeList.nodeIDs[row];
		info->nodeList.index = row;

		if( info->select_mod == TBL_SELECT_BY_ITEM   ||
	 	    info->select_mod == TBL_SELECT_BY_OBJECT ||
		    info->select_mod == DRW_SELECT_BY_OBJECT )
		{
			FIg_display(form, SHOW_TREE_BTN);
			VDtvwGetItemList( &nodeIDs, &nodeCnt ); 
			VDtvwSetItemList( nodeIDs, nodeCnt, 
					info->rootID, info->setID);
			_FREE( nodeIDs );
		}

		//sts = VDdrwTblCMD_getNewList(info);

		FIg_reset( form, REPORT_FLD );
		UI_status("");
		break;

	case INDEX_FLD:
		VDdrwTblCMD_notifyIndex( info );
		break;

	case ITEMNO_OPT_FLD:
		VDdrwTblCMD_notifyItemNo( info );
		break;

	case OUTPUT_FILE_FLD:
		FIg_get_text( form, OUTPUT_FILE_FLD, info->filename );
		break;

	case PRINT_BTN:
		// check if outList exists
		if( info->outCnt == 0 ||info->outList == NULL ) {
			sts = VDdrwTblCMD_reviewOut(info);
		}

		//print output to file ;
		VDdrwTblCMD_printOutput(info);
		sprintf(text,"Update Review printed to \"%s\"",info->filename);
		UI_status(text);
		break;

	case SHOW_TREE_BTN:
		/* have to backup global nodeIDs and set again */
		VDtvwGetItemList( &nodeIDs, &nodeCnt ); 
		sts = VDdrwTblCMD_setItems( info );
		//if( (sts&1) )	VDdrwTblCMD_getNewList(info);
		//else VDtvwSetItemList( nodeIDs, nodeCnt, 
		//		info->rootID, info->setID);
		_FREE( nodeIDs );
		FIg_reset( form, REPORT_FLD );
		break;

	case SORT_PCMK_BTN:
	case SORT_PATH_BTN:
	case SORT_TYPE_BTN:
	case SORT_STATUS_BTN:
		if(gadget == VDdrwTbl_sort_by) break;
		VDdrwTblCMD_sortList(info->rvwList, info->rvwCnt, gadget);
		VDdrwTblCMD_fillReport(	info->cmdFrm, 
					REPORT_FLD,
					info->rvwList,
				 	info->rvwCnt);
	case FIT_OBJECT_BTN:
		VDdrwTblCMD_fitObject(info);
		break;


	};	// Switch

	retFlag = 1;
wrapup:
	End
	return retFlag;
}

/* --------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_printOutput(TVDdrwTblInfo *info)
{
	IGRlong	retFlag;
	IGRint	i, cnt = 0;
	FILE	*file = NULL;
	IGRchar	filename[64], text[128], str[128], stsStr[128];
	struct	PrcInfo	*objInfo = NULL;

	if(info == NULL) goto wrapup;

	if(info->rvwCnt > 0 && info->rvwList != NULL) {
		objInfo = info->rvwList;
		cnt	= info->rvwCnt;
	}
	else {
		goto wrapup;
	}

	filename[0] = '\0';
	FIg_get_text( info->cmdFrm, OUTPUT_FILE_FLD, filename);
	if( filename[0] == '\0' ) {
		strcpy(filename, "drw_tbl.txt");
	}
	strcpy(info->filename, filename);

	if( (file = fopen(filename, "wt") ) == NULL ) goto wrapup;

	// Print Title
	switch(info->obj_type) {
	
	case DRAWING:
		sprintf(str, "\t\tDawing Update Report\n\n");
		break;
	case TABLE:
		sprintf(str, "\t\tTable Update Report\n\n");
		break;
	default:
		sprintf(str, "\t\tUpdate Report (Unkown input objects)\n\n");
	}
	fprintf(file, str);

	// Print output header
	sprintf(str, "%-15s%-10s%-25s%-15s%-15s\n\n", 
		"Object", "PCMK", "Stage Path", "Object Type" , "Status");
	fprintf(file, str);

	// Print contents
	for(i = 0; i < cnt; i++ ) {
		sprintf(text, "[%d, %d]",
			objInfo[i].model.obj_id.objid,
			objInfo[i].model.obj_id.osnum);

		stsStr[0] = '\0';
		VDdrwTblCMD_getStatusStr(objInfo[i].process, stsStr);

		sprintf(str, "%-15s%-10s%-25s%-15s%-15s\n", 
				text,
				objInfo[i].pcmk,
				objInfo[i].path,
				objInfo[i].type,
				stsStr);
		fprintf(file, str);
	}
	
	retFlag = 1;
wrapup:
	if(file) fclose( file ) ;
	return retFlag;
}


/* --------------------------------------------------------------
 */
IGRlong VDdrwTblCMD_getClassList(OM_S_CLASSLIST *classList)
{
	IGRlong	ret = 0;

	om$get_classid(classname = "VDdrawing",
			p_classid = &classList->p_classes[0]);

	om$get_classid(classname = "VDdrw2d",
			p_classid = &classList->p_classes[1]);

	om$get_classid(classname = "VDdrw3d",
			p_classid = &classList->p_classes[2]);

	om$get_classid(classname = "VDdrwTbl",
			p_classid = &classList->p_classes[3]);

/*
	om$get_classid(classname = "VDdrwTblHdr",
			p_classid = &classList->p_classes[4]);

	om$get_classid(classname = "VDdrwTblRow",
			p_classid = &classList->p_classes[5]);
*/

	classList->w_count = 4;
	classList->w_flags = OM_CLST_subclass;

	ret = 1;
wrapup:

	return ret;
}

/*-------------------------------------------------------------------------
 * Sort by PCMK
 */
IGRint VDdrwTblCMD_sortPCMK(
	struct	PrcInfo	*e1, 
	struct	PrcInfo	*e2)
{
	IGRint	BIG_NUM = 100000000;
	IGRint	i1, i2;

	if( e1->pcmk[0] == '\0' ) {
		i1 = BIG_NUM;
	}
	else {
		i1 = atoi(e1->pcmk);
	}

	if( e2->pcmk[0] == '\0' ) {
		i2 = BIG_NUM;
	}
	else {
		i2 = atoi(e2->pcmk);
	}

	return( i1 - i2 );
}

/*-------------------------------------------------------------------------
 * Sort by PATH 
 */
IGRint VDdrwTblCMD_sortPATH( 
	struct	PrcInfo	*e1, 
	struct	PrcInfo	*e2)
{
	return( strcmp(e1->path, e2->path) );
}

/*-------------------------------------------------------------------------
 * Sort by TYPE 
 */
IGRint VDdrwTblCMD_sortTYPE( 
	struct	PrcInfo	*e1,
	struct	PrcInfo	*e2)
{
	return( strcmp(e1->type, e2->type) );
}

/*-------------------------------------------------------------------------
 * Sort by status 
 */
IGRint VDdrwTblCMD_sortSTATUS( 
	struct	PrcInfo	*e1, 
	struct	PrcInfo	*e2)
{
	IGRchar		status1[80], status2[80];

	VDdrwTblCMD_getStatusStr(e1->process, status1);
	VDdrwTblCMD_getStatusStr(e2->process, status2);
	return strcmp(status1, status2);
}


/*-------------------------------------------------------------------------
 * Sort veview list based ob "sortby"
 */
IGRlong	VDdrwTblCMD_sortList(
	struct	PrcInfo	*rvwList, 
	IGRint		rvwCnt, 
	IGRint		sortby)
{
	IGRlong		retFlag = 0;
	IGRint		i, size;

	if( rvwCnt < 2 || rvwList == NULL ) goto wrapup;

	size = sizeof(struct PrcInfo);

	if(sortby < SORT_PCMK_BTN || sortby > SORT_STATUS_BTN) {
		goto wrapup;
	}

	switch( sortby ) {
	
	case SORT_PCMK_BTN:
		qsort (	(char *)(rvwList), rvwCnt, size, 
			(int (*)())VDdrwTblCMD_sortPCMK);
		break;

	case SORT_PATH_BTN:
		qsort (	(char *)(rvwList), rvwCnt, size, 
			(int (*)())VDdrwTblCMD_sortPATH);
		break;

	case SORT_TYPE_BTN:
		qsort (	(char *)(rvwList), rvwCnt, size, 
			(int (*)())VDdrwTblCMD_sortTYPE);
		break;

	case SORT_STATUS_BTN:
		qsort (	(char *)(rvwList), rvwCnt, size, 
			(int (*)())VDdrwTblCMD_sortSTATUS);
		break;

	default: goto wrapup;
	};

	VDdrwTbl_sort_by = sortby;

	retFlag = 1;
wrapup:
	return retFlag;
}


/* --------------------------------------
 * Misc stuff
 */
#argsused
IGRlong VDdrwTblCMD_init(TVDdrwTblInfo *info)
{
  IGRint retFlag = 0;
  IGRint msg,sts;
  IGRint i;

  dp$erase_hilite(msg = &msg);

  VDdrwTbl_startItemNo[0] = '\0';

  info->treeID.objid = NULL_OBJID;
  info->rootID.objid = NULL_OBJID;
  info->setID.objid = NULL_OBJID;

  info->select_mod = -1;
  info->gadget = -1;
  info->stage[0] = '\0';
  info->sname[0] = '\0';
  info->indList.index  = NULL;
  info->indList.indCnt = 0;
  info->indList.indLen = 0;

  info->nodeList.nodeCnt = 0;
  info->nodeList.nodeIDs = NULL;
  info->usrOpt	= VD_TBL_ITEMNO_OVERW;
  info->curCnt	= 0;
  info->newCnt	= 0;
  info->outCnt	= 0;
  info->rvwCnt	= 0;
  info->curList	= NULL;
  info->newList	= NULL;
  info->outList	= NULL;
  info->rvwList	= NULL;
  VDtvwSetItemList( NULL, 0, info->rootID, info->setID);
  sts = gr$get_module_env(buffer = &info->dtOE.mod_env);
  if (!(sts & 1)) goto wrapup;
 
  retFlag = 1;
wrapup:
  return retFlag;
}

#argsused
IGRlong VDdrwTblCMD_sleep(TVDdrwTblInfo *info)
{
  IGRint msg;

  if (info->cmdFrm) FIf_erase(info->cmdFrm);

  dp$erase_hilite(msg = &msg);

  return 1;
}

#argsused
IGRlong VDdrwTblCMD_wakeup(TVDdrwTblInfo *info)
{
  //VDsupCMDEtcNotifyHiLite(info,1);
  return 1;
}

#argsused
IGRlong VDdrwTblCMD_delete(TVDdrwTblInfo *info)
{
  IGRint	i;
  IGRint	msg;

  _FREE(info->nodeList.nodeIDs);
  info->nodeList.nodeCnt = 0;

  _FREE(info->indList.index);
  info->indList.indCnt = 0;
  info->indList.indLen = 0;

  _FREE(info->curList);
  info->curCnt = 0;

  _FREE(info->newList);
  info->newCnt = 0;

  _FREE(info->outList);
  info->outCnt = 0;

  _FREE(info->rvwList);
  info->rvwCnt = 0;

  dp$erase_hilite(msg = &msg);

  return 1;
}

end  implementation Root;
