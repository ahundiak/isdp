/* $Id: VDtreeSaveSet.I,v 1.15 2001/12/06 21:03:56 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdat/pocket/VDtreeSaveSet.I
 *
 * Description: save set Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDtreeSaveSet.I,v $
 *      Revision 1.15  2001/12/06 21:03:56  ylong
 *      *** empty log message ***
 *
 *      Revision 1.14  2001/12/06 16:14:31  ylong
 *      *** empty log message ***
 *
 *      Revision 1.13  2001/12/05 19:27:29  ylong
 *      *** empty log message ***
 *
 *      Revision 1.12  2001/10/29 20:18:21  ylong
 *      CR5709
 *
 *      Revision 1.11  2001/10/16 20:52:43  ylong
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/09/20 17:29:37  ylong
 *      *** empty log message ***
 *
 *      Revision 1.9  2001/09/08 14:26:55  ylong
 *      *** empty log message ***
 *
 *      Revision 1.8  2001/09/06 15:35:19  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/09/04 20:27:05  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/08/31 21:43:20  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/08/21 14:02:13  ylong
 *      CR5532
 *
 *      Revision 1.3  2001/07/31 19:20:15  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/07/25 17:58:16  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/07/20 18:50:57  ylong
 *      CR4080
 *
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 07/18/01	ylong		Creation
 * 12/06/01	ylong		CR5916, added loading save set msg
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDctx.h"
#include "VDdoom.h"
#include "VDlog.h"
#include "VDss.h"
#include "VDpdm.h"
#include "VDobj.h"
#include "vdtr_macros.h"
#include "VDtag.h"
#include "AS_status.h"
#include "VDmem.h"
#include "dpstruct.h"
#include "VDatPocket.h"
#include "vdrefmacros.h"
#include "VDtreeSaveSet.h"

from	GRvg	import	GRputname;
from	VDbuf	import	vdbufSetData, vdbufGetData;


/*-----------------------------------------------------------------------
 * Get saved set list, API
 */
IGRstat	VDtrStGetSavedSets (	TGRid	*setID,		// in
				TGRid	**doomIDs,	// out
				GRname	**names,	// out
				GRname	**paths,	// out
				IGRint	*count )	// out
{
	IGRstat         ret = 0;
	IGRlong         sts, msg ;
	IGRint          i, j, len,
			cnt	= 0,
			objCnt	= 0, 
			objCnt1	= 0, 
			refOsCnt= 0;
	GRspacenum      cur_osnum, 
			*refOsList = NULL;
	TGRid           objID,
			*objIDs = NULL, *objIDs1 = NULL;
	GRname		path, objName, partName, fileName;
	TVDctxBaseInfo	baseInfo;


	if ( !setID || setID->objid == NULL_OBJID ) goto wrapup;
	if ( !doomIDs && !names && !paths) goto wrapup;

	if( doomIDs ) *doomIDs = NULL;
	if( names )   *names = NULL;

	// First, all objects from active file
	ex$get_cur_mod ( osnum = &cur_osnum ) ;

	sts = VDgetAllObjectsByClassName (	cur_osnum,
						"VDbufMacro", 
						&objCnt, 
						&objIDs);
        if( !(sts&1) ) {
		_FREE(objIDs);
		objCnt = 0;
	}


	// Then get all from reference files

        sts = vd$get_ref_os_list(msg            = &msg,
                                main_os         = &cur_osnum,
                                num_ref_os      = &refOsCnt,
                                ref_os_list     = &refOsList);

	if( (sts&msg&1) ) {

		for( i = 0; i < refOsCnt; i++ ) {
			sts = VDgetAllObjectsByClassName (	refOsList[i],
								"VDbufMacro", 
								&objCnt1, 
								&objIDs1);
			
			if( !(sts&1) || objCnt1 < 1 ) {
				_FREE( objIDs1 );
				continue;
			}

			objIDs = realloc( objIDs, (objCnt+objCnt1)*sizeof(TGRid) );
			for( j = 0; j < objCnt1; j++ ) {
				objIDs[j+objCnt] = objIDs1[j];
			}
			objCnt += objCnt1;
			objCnt1 = 0 ;
			_FREE( objIDs1 ) ;
        	}
	}
	VDctxGetBaseInfo(setID, &baseInfo);
	sprintf(partName, ":%s:%s", VDAT_SATGE_SETS_DIR, baseInfo.setName);

	cnt = 0;
	for( i = 0; i < objCnt; i++ ) {
		vdobj$Get (	objID	= &objIDs[i],
				objPath	= path );
		if( strstr( path, partName ) ) {
			cnt++;
		}
	}
	
	if( cnt < 1 ) {
		*count = 0;
		ret = 1;
		goto wrapup;
	}

	if( doomIDs ) {
		*doomIDs = _MALLOC( cnt, TGRid );
		if( !(*doomIDs) ) goto wrapup;
	}
	
	if( names ) {
		*names = _MALLOC( cnt, GRname );
		if( !(*names) ) goto wrapup;
	}

	if( paths ) {
		*paths = _MALLOC( cnt, GRname );
		if( !(*paths) ) goto wrapup;
	}
	*count = cnt;

	cnt = 0;
	for( i = 0; i < objCnt; i++ ) {
		vdobj$Get (	objID	= &objIDs[i],
				objPath	= path,
				objName	= objName );
		if( strstr( path, partName ) ) {
		    if( doomIDs ) (*doomIDs)[cnt] = objIDs[i];
		    if( names ) {
			if( strstr( path, ":ref:" ) ) {
				VDosGetFileName(objIDs[i].osnum, fileName);
				sprintf((*names)[cnt],"%s[%s]", objName,fileName);
			}
			else {
				strcpy((*names)[cnt], objName);
			}
		    }
		    if( paths ) strcpy( (*paths)[cnt], path );
		    cnt++;
		}
	}

        ret = 1 ;
wrapup:
        _FREE( objIDs ) ;
        _FREE( objIDs1 ) ;
        _FREE( refOsList ) ;
        return ret ;
}

/*---------------------------------------------------------------------
 * Compare saved set names for sorting
 */
IGRint	VDtrStCmpNames(	GRname	name1, GRname name2 )
{
	IGRchar	*ptr1 = NULL, *ptr2 = NULL;
	GRname	ref1, ref2;

	ref1[0] = '\0';
	ref2[0] = '\0';

	if( (ptr1 = strchr( name1, '[' )) ) {
		strcpy( ref1, ++ptr1 );
		if( (ptr1 = strchr( ref1, ']' )) ) *ptr1 = '\0';
	}

	if( (ptr2 = strchr( name2, '[' )) ) {
		strcpy( ref2, ++ptr2 );
		if( (ptr2 = strchr( ref2, ']' )) ) *ptr2 = '\0';
	}

	if( ref1[0] != '\0' && ref2[0] != '\0' ) {
		if( !strcmp( ref1, ref2 ) )	return strcmp( name1, name2 );
		else				return strcmp( ref1, ref2 );
	}

	if( ref1[0] == '\0' && ref2[0] != '\0' ) {
		return -1;
	}

	if( ref1[0] != '\0' && ref2[0] == '\0' ) {
		return 1;
	}

	return strcmp( name1, name2 );
}

/*---------------------------------------------------------------------
 * Fill saved set list in the form
 */
IGRstat VDatPKTFillSaveSetList ( 	Form	form,		// in
					IGRint	gadget,		// in
					TGRid	*setID )	// in
{
	IGRstat		retFlag	= 0;
	TGRid		*doomIDs = NULL;
	GRname		*names = NULL;
	IGRint		count = 0, i;

	if( !form || !setID || setID->objid == NULL_OBJID ) goto wrapup;

	retFlag = vd$TreeSet_getList (	treeSetID	= setID,
					nameList	= &names,
					count		= &count);

	qsort((char *)names, count, sizeof( GRname ), (int(*)())VDtrStCmpNames);

	if( !retFlag ) goto wrapup;

	VIfld_set_list_num_rows ( form, gadget, 0, count);
	for(i = 0; i < count; i++ ) {
		VIfld_set_list_text( form, gadget, i, 0, names[i], FALSE);
	}

	retFlag = 1;
wrapup:
	_FREE(names);
	return retFlag;
}


/*---------------------------------------------------------------------------
 * Notify Save button
 */
IGRstat	VDatPKTNotifySaveSet (	Form	form )
{
	IGRstat		retFlag	= 0;
	IGRint		row, nrow;
	IGRint		sel, nsel;
	TGRid		setID, objID;
	TGRid		*nodeIDs = NULL;
	IGRchab		setName;
	IGRchar		msgTxt[128];
	
	msgTxt[0] = '\0';
	if( !form ) goto wrapup;

	/*
	 * Get saved setName 
	 */
	vdfrm$GetText(	form    = form,
                        gadget  = VDAT_FORM_PKT_G_SET_NAME,
                        txt     = setName );
	if( setName[0] == '\0' ) {
		strcpy( msgTxt, "Missing Set Name");
		UI_status( msgTxt );
		goto wrapup;
	}

	/*
	 * Get tree set
	 */
	row = -1;
	vdfrm$GetActiveRow (	form   = form,
				gadget = VDAT_FORM_PKT_L_SETS, 
				row    = &row);
	if (row < 0) {
		strcpy( msgTxt, "No tree exists");
		UI_status( msgTxt );
		goto wrapup;
	}

	vdfrm$GetText (	form	= form,
			gadget	= VDAT_FORM_PKT_L_SETS,
			row	= row, 
			col	= 3, 
			objID	= &setID);
	/*
	 * Get selected tree nodes
	 */
	vdfrm$GetNumRows (	form	= form,
				gadget  = VDAT_FORM_PKT_G_TREE,
				rows    = &nrow);
	if( nrow < 1 ) {
		strcpy( msgTxt, "The tree is empty");
		UI_status( msgTxt );
		goto wrapup;
	}

	nsel = 0;
	for( row = 0; row < nrow; row++ ) {
		sel = 0;
		vdfrm$GetSelect (	form    = form,
					gadget  = VDAT_FORM_PKT_G_TREE,
					col     = 2,
					row     = row,
					sel     = &sel);
		if( sel ) nsel++;
	}
	if( nsel < 1 ) {
		strcpy( msgTxt, "No nodes selected from tree");
		UI_status( msgTxt );
		goto wrapup;
	}

	if( !(nodeIDs = _MALLOC( nsel, TGRid ) ) ) goto wrapup;

	nsel = 0;
	for( row = 0; row < nrow; row++ ) {
		sel = 0;
		vdfrm$GetSelect (	form    = form,
					gadget  = VDAT_FORM_PKT_G_TREE,
					col     = 2,
					row     = row,
					sel     = &sel);
		if( !sel ) continue;

		vdfrm$GetText (	form    = form,
				gadget  = VDAT_FORM_PKT_G_TREE,
				col     = 3,
				row     = row,
				objID	= &nodeIDs[nsel]);
		nsel++;
	}

	retFlag = vd$TreeSet_create (	setName		= setName,
					treeSetID	= &setID,
					objList		= nodeIDs,
					count		= nsel,
					check		= TRUE );
	if(!retFlag ) {
		goto wrapup;
	}

	/*
	 * Re-load saved set list 
	 */
	VDatPKTFillSaveSetList ( form, VDAT_FORM_PKT_G_SET_NAME, &setID );

	retFlag = 1;
	sprintf( msgTxt, "%s has been saved", setName);
	UI_status( msgTxt );
wrapup:
	_FREE( nodeIDs );
	return retFlag;
}


/*------------------------------------------------------------------------
 * Notify Delete button
 */
IGRstat	VDatPKTNotifyDeleteSet( Form	form )
{
	IGRstat		retFlag = 0;
	IGRchab		setName;
	TGRid		doomID, setID;
	IGRint		row, pos;
	IGRchar		msgTxt[128];
	
	msgTxt[0] = '\0';
	
	if( !form ) goto wrapup;

	vdfrm$GetText(	form    = form,
                        gadget  = VDAT_FORM_PKT_G_SET_NAME,
                        txt     = setName );
	if( setName[0] == '\0' ) {
		UI_status("Missing Set Name");
		goto wrapup;
	}

	FIfld_get_active_row(form, VDAT_FORM_PKT_L_SETS, &row, &pos);
	VDahFrmGetGRid(form,VDAT_FORM_PKT_L_SETS,row,3, &setID);
	if( vd$TreeSet_delete (setName = setName, treeSetID = &setID)) {
		VDatPKTFillSaveSetList(form, VDAT_FORM_PKT_G_SET_NAME, &setID);
		FIg_set_text( form, VDAT_FORM_PKT_G_SET_NAME, "");
	}
	
	retFlag = 1;
wrapup:
	return retFlag;
}

/*------------------------------------------------------------------------
 * Notify Load button
 */
IGRstat	VDatPKTNotifyAddSet( Form	form)
{
	IGRstat		retFlag	= 0;
	IGRchab		setName;
	TGRid		setID, objID, rootID;
	TGRid		*listIDs = NULL, *selIDs = NULL;
	IGRint		listCnt = 0, selCnt = 0, cnt = 0;
	IGRint		i, j, row, nrow, pos, sel;
	IGRchar		msgTxt[128], hOpt[40];

	msgTxt[0] = '\0'; 

	if( !form ) goto wrapup;

	vdfrm$GetText(	form    = form,
                        gadget  = VDAT_FORM_PKT_G_SET_NAME,
                        txt     = setName );
	if( setName[0] == '\0' ) {
		strcpy( msgTxt, "Missing Saved Set Name");
		goto wrapup;
	}

	setID.objid = NULL_OBJID;
	FIfld_get_active_row(form, VDAT_FORM_PKT_L_SETS, &row, &pos);
	VDahFrmGetGRid(form,VDAT_FORM_PKT_L_SETS,row,3,&setID);
	if( setID.objid == NULL_OBJID ) goto wrapup;

	vd$TreeSet_getSaveSet (	setName		= setName,
				treeSetID	= &setID,
				objList		= &listIDs,
				count		= &listCnt );

	if( setID.objid == NULL_OBJID || listIDs == NULL || listCnt < 1 ) {
		sprintf( msgTxt, "Can not get saved set %s", setName);
		goto wrapup;
	}

#ifdef DEBUG
	printf("setID loaded: "); vdobj$Print(objID=&setID);
	for( i = 0; i < listCnt; i++ ) {
		printf("\tnode[%d]: ", i); vdobj$Print(objID=&listIDs[i]);
	}
#endif

	nrow = -1;
	if(FIfld_get_num_rows(form,VDAT_FORM_PKT_G_TREE,&nrow) != FI_SUCCESS) {
		goto wrapup ;
	}

	for(row = 0; row < nrow; row++) {
		FIfld_get_select (form, VDAT_FORM_PKT_G_TREE, row, 2, &sel);
		if( sel ) selCnt++;
	}

	if ( selCnt ) {
	   selIDs = _MALLOC( listCnt + selCnt, TGRid );
	   if( !selIDs ) goto wrapup;
	
	   selCnt = 0;
	   for(row = 0; row < nrow; row++) {
	     FIfld_get_select (form, VDAT_FORM_PKT_G_TREE, row, 2, &sel);
	     if( sel ) {
		VDahFrmGetGRid(form,VDAT_FORM_PKT_G_TREE,row,3,&selIDs[selCnt]);
		selCnt++;
	     }
	   }

	   cnt = 0;
	   for( i = 0; i < listCnt; i++ ) {
	     for( j = 0; j < selCnt+cnt; j++ ) {
		if( selIDs[j].objid == listIDs[i].objid ) break;
	     }
	     if( j == selCnt+cnt ) {
		selIDs[selCnt+cnt] = listIDs[i];
		cnt++;
	     }
	   }

	   _FREE( listIDs );
	   listIDs = selIDs;
	   listCnt = selCnt + cnt;
	}

	retFlag = VDtrStExpandTree (	form, 
					VDAT_FORM_PKT_G_TREE, 
					&setID, 
					listIDs, 
					listCnt );
	if( !retFlag ) goto wrapup;

	sprintf( msgTxt, "Saved Set %s Loaded", setName);

	FIg_get_text( form, VDAT_FORM_PKT_G_HILIT_OPT, hOpt);
	VDtrStHiliteSavedSet (	hOpt, listIDs, listCnt );

	retFlag = 1;
wrapup:
	UI_status( msgTxt );
	_FREE( listIDs );
	return retFlag;
}

/*------------------------------------------------------------------------
 * Notify Load button
 */
IGRstat	VDatPKTNotifyLoadSet( Form	form)
{
	IGRstat		retFlag	= 0;
	IGRchab		setName;
	TGRid		setID, objID, rootID;
	TGRid		*listIDs = NULL;
	IGRint		listCnt = 0;
	IGRint		i, row, nrow, pos;
	IGRchar		msgTxt[128], hOpt[40];

	msgTxt[0] = '\0'; 

	if( !form ) goto wrapup;

	vdfrm$GetText(	form    = form,
                        gadget  = VDAT_FORM_PKT_G_SET_NAME,
                        txt     = setName );
	if( setName[0] == '\0' ) {
		strcpy( msgTxt, "Missing Saved Set Name");
		goto wrapup;
	}

	setID.objid = NULL_OBJID;
	FIfld_get_active_row(form, VDAT_FORM_PKT_L_SETS, &row, &pos);
	VDahFrmGetGRid(form,VDAT_FORM_PKT_L_SETS,row,3,&setID);
	if( setID.objid == NULL_OBJID ) goto wrapup;

	vd$TreeSet_getSaveSet (	setName		= setName,
				treeSetID	= &setID,
				objList		= &listIDs,
				count		= &listCnt );

	if( setID.objid == NULL_OBJID || listIDs == NULL || listCnt < 1 ) {
		sprintf( msgTxt, "Can not get saved set %s", setName);
		goto wrapup;
	}

#ifdef DEBUG
	printf("setID loaded: "); vdobj$Print(objID=&setID);
	printf("rootID loaded: "); vdobj$Print(objID=&rootID);
#endif

	/*
	nrow = -1;
	if(FIfld_get_num_rows(form,VDAT_FORM_PKT_L_SETS,&nrow) != FI_SUCCESS) {
		goto wrapup ;
	}

	for(row = 0; row < nrow; row++) {
		VDahFrmGetGRid(form,VDAT_FORM_PKT_L_SETS,row,3,&objID);
		if(setID.objid == objID.objid && setID.osnum == objID.osnum ) {
		    FIfld_set_active_row(form, VDAT_FORM_PKT_L_SETS, row, 0);
		    FImcf_set_select    (form, VDAT_FORM_PKT_L_SETS, row, 1);
		    break ;
		}
	}
	*/

	retFlag = VDtrStExpandTree (	form, 
					VDAT_FORM_PKT_G_TREE, 
					&setID, 
					listIDs, 
					listCnt );
	if( !retFlag ) goto wrapup;

	sprintf( msgTxt, "Saved Set %s Loaded", setName);

	FIg_get_text( form, VDAT_FORM_PKT_G_HILIT_OPT, hOpt);
	VDtrStHiliteSavedSet (	hOpt, listIDs, listCnt );

	retFlag = 1;
wrapup:
	UI_status( msgTxt );
	_FREE( listIDs );
	return retFlag;
}

/*---------------------------------------------------------------------------
 * Expand saved set
 */
IGRstat	VDtrStExpandTree(	Form	form, 
				IGRint	gadget,
				TGRid	*setID, 
				TGRid	*listIDs,
				IGRint	cnt )
{
	IGRstat		retFlag  = 0;
	IGRint		i, j, row, nsel = 0, sel, nrow;
	IGRint		type = 0, VDAT_TREE = 0, VDCT_TREE = 1;
	TGRid		nodeID, *objIDs = NULL;

	if( !form || !setID || !listIDs || cnt < 1 ) goto wrapup;

	FIg_reset( form, gadget );

	if(vdobj$IsAncestryValid (
			objID        = setID,
			superClassID = OPP_VDatBase_class_id)) 
	{
		VDatPKTFormFillTree(form, gadget, setID);
		type = VDAT_TREE;
	}
	else if(vdobj$IsAncestryValid(
			objID        = setID,
			superClassID = OPP_VDct1Base_class_id)) 
	{
		VDct1PKTFormFillTree(form, gadget, setID);
		type = VDCT_TREE;
	}
	else 
	{
		UI_status( "Unkown Tree Type !");
		goto wrapup;
	}


	objIDs = _MALLOC( cnt, TGRid );
	if( objIDs == NULL ) goto wrapup;
	for( i = 0; i < cnt; i++ ) objIDs[i] = listIDs[i];

expand:

	for( i = 0; i < cnt; i++ ) 
	{
		if( objIDs[i].objid == NULL_OBJID ) continue;

		if( type == VDAT_TREE ) {
		    VDatExpandTree(form, gadget, setID, &objIDs[i]);
		}
		else {
		    VDct1PKTFormExpandTree(form, gadget, setID, &objIDs[i]);
		}
	}
		
	/*
	 * In case higher level node expanded later than lower level node so 
	 * that lower level expanded node is contracted again during 
	 * expanding higher level nodes, we have to check to make sure.
	 */
	VIfld_get_num_rows(form, gadget, &nrow);
	nsel = 0;
	for( row = 0; row < nrow; row++ ) {
	    VIfld_get_select(form, gadget, row, 2, &sel);
	    if ( sel ) nsel++;
	}

	if( nsel < cnt ) {
		for( row = 0; row < nrow; row++ ) {
			VIfld_get_select(form, gadget, row, 2, &sel);
			if( !sel ) continue;
		
			VDahFrmGetGRid(form, gadget, row, 3, &nodeID);
			for( i = 0; i < cnt; i++ ) {
				if(objIDs[i].objid == nodeID.objid) {
					objIDs[i].objid = NULL_OBJID;
				}
			}
		}
		goto expand;
	}

	retFlag = 1;
wrapup:
	_FREE(objIDs);
	return retFlag;
}


/*-------------------------------------------------------------------
 * Get attributes from input objID and add them to pieceID
 */
IGRstat VDtrStAddPieceAttributes(TGRid *objID, TGRid *pieceID)
{
	IGRstat		retFlag	= 1;
	IGRchab		buf, fileName;
	TVDtag		tag;
	

	if( !objID   || objID->objid  == NULL_OBJID ) goto wrapup;
	if( !pieceID || pieceID->objid == NULL_OBJID ) goto wrapup;

	vd$trget_nodeInfo (	nodeID		= objID,
				fullPath	= buf);

	VDctxAppTxtAtr(pieceID, VDAT_SAVE_SET_ATTR_PATH, buf);

	VDosGetFileName(objID->osnum, fileName);
	vdtag$GetInfo (	objID	= objID,
			tag	= &tag );
			
	sprintf(buf, "%s:%u:%u:%u", fileName, objID->objid, tag.num, tag.ver);
	VDctxAppTxtAtr(pieceID, VDAT_SAVE_SET_ATTR_TAG, buf);

	retFlag = 1;
wrapup:
	return retFlag;
}


/*--------------------------------------------------------------------------
 * Create or overwrite saved set, API
 */
IGRstat	VDtrStCreateSaveSet (	IGRchab	setName, 	// in
				TGRid	*setID, 	// in
				TGRid	*rootID, 	// in
				TGRid	*listIDs, 	// in
				IGRint	cnt,		// in
				IGRint	check,		// in
				TGRid	*outID )	// out
{
	IGRlong		status = 0, msg;
	IGRstat		ret = 0;
	IGRint		i, bufLen;
	TGRid		treeID;
	TGRid		doomID, objID;
	TGRid		xsetID, xrootID, xnodeID;
	TVDctxBaseInfo	baseInfo;
	IGRchab		buf;
	IGRchar		pwdName[DI_PATH_MAX];
	IGRchar		path[DI_PATH_MAX];
	IGRchar		tmpPath[DI_PATH_MAX];
	IGRchar		*bufXml = NULL;
	GRname		curFileName;
	VDosnum		osnum;
	TGRid		dirObj;
	IGRchar		msgTxt[128];

	treeID.objid = NULL_OBJID;
	doomID.objid = NULL_OBJID;
	objID.objid  = NULL_OBJID;

	if( !setName || !setID || !listIDs ) goto wrapup;
	if( setName[0] == '\0' ) goto wrapup;
	if( outID ) outID->objid = NULL_OBJID;

	status = VDtrStGetDoomObjByName ( setName, setID, &doomID );
	if( (status&1) && doomID.objid != NULL_OBJID ) {
		
	    vdobj$Get( objID = &doomID, objPath = path );
	    if( strstr( path, ":ref:" ) ) {
		UI_status("Save set in ref: Permision Denied");
		status = 0;
		goto wrapup;
	    }

	    if( check ) {
		sprintf(msgTxt, 
		"%s already exists. Do you want to overwrite it?", setName);
		if( !GRconfirm_box(msgTxt) ) {
			goto wrapup;
		}
	    }
	}

	pwdName[0] ='\0';
	status = di$pwd( dirname = pwdName );
	as$status();

	ex$get_cur_mod(osnum = &osnum);
	VDosGetFileName(osnum, curFileName);

	/*
	 * cd or make directory stage_sets
	 */
	sprintf(path, ":%s:%s", curFileName,VDAT_SATGE_SETS_DIR);

	status = di$translate (	objname = path,
				osnum   = osnum,
				p_objid = &dirObj.objid,
				p_osnum = &dirObj.osnum );
	if( !(status&1) ) {
		status = di$mkdir (dirname = path,
				osnum   = osnum,
				p_dirid = &dirObj.objid,
				p_osnum = &dirObj.osnum );
		as$status();

		status = di$cd( dirname = path );
		as$status();
	}
	else {
		status = di$cd( dirname = path );
	}

	/*
	 * cd or make sub directory treeXXX
	 */

	VDctxGetBaseInfo(setID, &baseInfo);

	DIstrcat(path, baseInfo.setName);

	status = di$translate (	objname = path,
				osnum   = osnum,
				p_objid = &dirObj.objid,
				p_osnum = &dirObj.osnum );
	if( !(status&1) ) {
		status = di$mkdir (dirname = path,
				osnum   = osnum,
				p_dirid = &dirObj.objid,
				p_osnum = &dirObj.osnum );
		as$status();

		status = di$cd( dirname = path );
		as$status();
	}
	else {
		status = di$cd( dirname = path );
	}

	if( !setID || !listIDs || !cnt ) goto wrapup;
	if( setID->objid == NULL_OBJID ) goto wrapup;

#ifdef DEBUG
	for(i = 0; i < cnt; i++) {
		printf("listIDs[%d]: ", i); vdobj$Print(objID=&listIDs[i]);
	}
#endif

	/*
	 * create xml tree
	 */
	VDctxCreateXdomTree(setName, NULL, &treeID);
	DIstrcat(path, setName);
	VDctxAppTxtAtr(&treeID, VDAT_SAVE_SET_ATTR_PATH, path);
	
	/*
	 * create xml node for tree set
	 */
	VDctxCreateNode(&treeID, VDAT_SAVE_SET_TYPE_TSET, NULL, &xsetID);
	VDtrStAddPieceAttributes( setID, &xsetID );

	/*
	 * create xml node for tree root under tree set, set is the default root
	 */
	VDctxCreateNode(&xsetID, VDAT_SAVE_SET_TYPE_ROOT, NULL, &xrootID);
	if( rootID && rootID->objid != NULL_OBJID ) {
		VDtrStAddPieceAttributes( rootID, &xrootID );
	}
	else {
		objID.objid = NULL_OBJID;
		VDctxGetTree ( setID, &objID );
		if( objID.objid != NULL_OBJID ) {
			VDtrStAddPieceAttributes( &objID, &xrootID );
		}
		else {
			VDtrStAddPieceAttributes( setID, &xrootID );
		}
	}
			
	for(i = 0; i < cnt; i++) {
		VDctxGetNodeType(&listIDs[i], baseInfo.nodeType);
		VDctxGetNodeName(&listIDs[i], baseInfo.nodeName);
		VDctxCreateNode(&xrootID,
				VDAT_SAVE_SET_TYPE_NODE,
				NULL,
				&xnodeID );
		VDtrStAddPieceAttributes( &listIDs[i], &xnodeID );
	}

	/*
	 * create dom object. need to do more about name
	 */
	if( doomID.objid == NULL_OBJID ) {
		VDdoomCreateFromTree(&treeID, &doomID);
		if( setName ) {
			status = om$send(msg	 = message GRvg.GRputname
								(&msg, setName),
					senderid = NULL_OBJID,
					targetid = doomID.objid,
					targetos = doomID.osnum);
		}
	}
	else {
		VDctxSaveTreeToXmlBuf(&treeID, &bufXml);
		bufLen = strlen( bufXml ) + 1;
		status = om$send (	msg	 = message VDbuf.vdbufSetData
							(1,0,bufLen,bufXml),
				senderid = NULL_OBJID,
				targetid = doomID.objid,
				targetos = doomID.osnum);
		as$status();
	}


	if( outID ) *outID = doomID;

#ifdef DEBUG_XML
	/*
	 * create xml file for test
	 */
	VDctxSaveTreeToXmlFile( &treeID, "my_xml");
	VDgtkShowTreeID(&treeID);
#endif

	status = 1;
wrapup:
	if( treeID.objid != NULL_OBJID) VDctxDeleteNode(&treeID);

	if( pwdName[0] != '\0' ){
		di$cd( dirname = pwdName );
	}
	_FREE(bufXml);
	return status;
}


/*------------------------------------------------------------------------
 * Delete a saved set, denied if it is in reference file, API
 */
IGRstat	VDtrStDeleteSavedSet (	IGRchar		*setName,	// in
				TGRid		*setID ) 	// in
{
	IGRstat		retFlag = 0, sts;
	TGRid		doomID;
	IGRchar		msgTxt[128], path[128];

	if( !setName || !setID || setID->objid == NULL_OBJID ) goto wrapup;

	sts =  VDtrStGetDoomObjByName ( setName, setID, &doomID );

	if( sts && doomID.objid != NULL_OBJID ) {
		vdobj$Get( objID = &doomID, objPath = path );
		if( strstr( path, ":ref:" ) ) {
			sprintf(msgTxt, "Delete set in ref: Permision Denied");
			goto wrapup;
		}
		sprintf(msgTxt, "Delete %s?", setName);
		if( !GRconfirm_box(msgTxt) ) {
			goto wrapup;
		}
		VDct1DeleteRootObject(&doomID);
		sprintf(msgTxt, "Set %s has been deleted", setName);
	}
	else {
	    sprintf(msgTxt, "%s not found. Deleting Saved Set failed",setName);
	    UI_status( msgTxt );
	    goto wrapup;
	}
	
	retFlag = 1;
wrapup:
	UI_status( msgTxt );
	return retFlag;
}


/*---------------------------------------------------------------------------
 * Extract stage node id from xml node
 */
IGRstat	VDtrStExtractStObj (	GRspacenum	osnum,		// in
				TGRid		*nodeID, 	// in
				TGRid		*objID )	// out
{
	IGRstat		ret = 0;
	IGRlong		sts;
	IGRchab		buf;
	IGRchar		*tok = NULL;

	if( !nodeID || !objID ) goto wrapup;
	if( nodeID->objid == NULL_OBJID )  goto wrapup;

	VDctxGetTxtAtr(nodeID, VDAT_SAVE_SET_ATTR_TAG, buf);
	if( buf[0] == '\0' ) goto wrapup;

	tok = strtok( buf, ":" );
	if( tok ) {
		VDosGetFileNameOS( tok, &objID->osnum );
		if( objID->osnum == OM_K_NOT_AN_OS ) {
			objID->osnum = osnum;
		}
	}
	else {
		goto wrapup;
	}

	tok = strtok( NULL, ":" );
	if( tok ) {
		objID->objid = atoi(tok);
	}
	else {
		goto wrapup;
	}

	if( !vdtr$IsTreeAncestry( nodeID = objID) ) {
		UI_status("Failed to extract object from xdom");
		goto wrapup;
	}

	ret = 1;
wrapup:
	return ret;
}

/*-----------------------------------------------------------------------
 * Get VDbufMacro by name and tree set id
 */
IGRstat	VDtrStGetDoomObjByName (	IGRchab	doomName, 	// in
					TGRid	*setID,		// in 
					TGRid	*doomID )	// out
{
	IGRlong		sts;
	IGRstat		ret = 0;
	IGRint		i, doomCnt = 0;
	GRname		fileName;
	GRname		setName;
	GRname		setPath;
	GRname		path;
	VDosnum		osnum;
	IGRchar		*ptr = NULL;
	TGRid		*doomIDs = NULL;
	TVDctxBaseInfo	baseInfo;

	if( !doomName || !doomID ) {
		goto wrapup;
	}

	if( doomName[0] == '\0' ) goto wrapup;

	strcpy( setName, doomName );
	if( (ptr = strchr( setName, '[' )) ) {
		strcpy( fileName, ++ptr );
		--ptr; *ptr = '\0';
		if( (ptr = strchr( fileName, ']')) ) {
			*ptr = '\0';
		}
		VDosGetFileNameOS(fileName, &osnum);
	}
	else {
		ex$get_cur_mod(osnum = &osnum);
		VDosGetFileName(osnum, fileName);
	}
	if( osnum == OM_K_NOT_AN_OS || *fileName == 0 ) goto wrapup;

	sts = VDgetAllObjectsByClassName (	osnum, 
						"VDbufMacro", 
						&doomCnt, 
						&doomIDs );

	if( !(sts&1) || doomCnt < 1 ) {
		goto wrapup;
	}

	VDctxGetBaseInfo(setID, &baseInfo);
	sprintf(setPath, ":%s:%s:%s:%s", 
		fileName, VDAT_SATGE_SETS_DIR, baseInfo.setName, setName);

	for( i = 0; i < doomCnt; i++ ) {
		vdobj$Get (	objID	= &doomIDs[i],
				objPath	= path );
		if( strstr( path, setPath ) ) {
			*doomID = doomIDs[i];
			ret = 1;
			goto wrapup;
		}
	}
	
wrapup:
	_FREE( doomIDs );
	return ret;
}


/*-----------------------------------------------------------------------
 * Get saved set by name and tree set id, API
 */
IGRstat	VDtrStGetSaveSetByName (	IGRchab	setName, 	// in
					TGRid	*setID, 	// in
					TGRid	*rootID, 	// out
					TGRid	**listIDs, 	// out
					IGRint	*cnt )		// out
{
	IGRlong		status, msg;
	IGRstat		ret = 0;
	IGRint		i, nth;
	TGRid		treeID;
	TGRid		doomID, objID, xsetID, xrootID;
	IGRchar		*bufXml;

	treeID.objid = NULL_OBJID;

	if( !setName || !setID ) {
		goto wrapup;
	}

	if( listIDs ) {
		*listIDs = NULL;
	}

	if( !cnt ) goto wrapup;
	*cnt = 0;

	if( setID->objid == NULL_OBJID || setName[0] == '\0' ) goto wrapup;

	UI_status("Loading saved set ...");

	status = VDtrStGetDoomObjByName ( setName, setID, &doomID );
	if( !(status&1) || doomID.objid == NULL_OBJID ) {
		goto wrapup;
	}

	/* 
	 * Get xml buf from object. 
	 * Don't free bufXml, it is internal pointer !
	 */
	status = om$send (	msg	 = message VDbuf.vdbufGetData
						(1,0,0,0, NULL, &bufXml),
			senderid = NULL_OBJID,
			targetid = doomID.objid,
			targetos = doomID.osnum);
	as$status();

	VDxdomCreateTreeFromXmlBuf( bufXml, &treeID );
	if( treeID.objid == NULL_OBJID ) {
		printf("VDxdomCreateTreeFromXmlBuf failed\n");
		goto wrapup;
	}
	
	/*
	 * extract tree set
	 */
	nth = 0;
	status = VDctxGetNthTreeChild( &treeID, nth, &xsetID );
	if( !(status&1) || xsetID.objid == NULL_OBJID ) {
		UI_status("Failed to extract tree set from xdom");
		goto wrapup;
	}
	//VDtrStExtractStObj ( &xsetID, setID );

	/*
	 * extract tree root
	 */
	nth = 0;
	status = VDctxGetNthTreeChild( &xsetID, nth, &xrootID );
	if( !(status&1) || xrootID.objid == NULL_OBJID ) goto wrapup;
	if( rootID ) {
		VDtrStExtractStObj ( setID->osnum, &xrootID, rootID );
	}
	
	/*
	 * extract node ids
	 */
	for( nth = 0; VDctxGetNthTreeChild( &xrootID, nth, &objID ); nth++ );
	if( nth < 1 ) {
		UI_status("Failed to extract objects from xdom");
		goto wrapup;
	}
	*listIDs = _MALLOC( nth, TGRid );
	if( !(*listIDs) ) goto wrapup;

	for( i = 0; i < nth; i++ ) {
		VDctxGetNthTreeChild( &xrootID, i, &objID );
		VDtrStExtractStObj(setID->osnum, &objID, &(*listIDs)[i]);
	}

	*cnt = nth;

	UI_status("Saved set loaded");

	ret = 1;
wrapup:

	if( treeID.objid != NULL_OBJID) VDctxDeleteNode(&treeID);

	return ret;
}

/*------------------------------------------------------------------------
 * Highlight loaded saved set, based on Highlight option
 */
void	VDtrStHiliteSavedSet (	IGRchar	*hOpt,		// in
				TGRid	*nodeIDs,	// in
				IGRint	cnt )		// in
{
	IGRint		i;

	if( !hOpt || !nodeIDs || cnt < 1 ) goto wrapup;
	if( hOpt[0] == '\0' ) goto wrapup;

	if( !strcasecmp( hOpt, "None" )) {
		goto wrapup;
	}
	
	if(vdobj$IsAncestryValid (
			objID        = &nodeIDs[0],
			superClassID = OPP_VDatBase_class_id)) 
	{
		for( i = 0; i < cnt; i++ ) {
			VDatPKTDisplayNode ( &nodeIDs[i], GRhd, hOpt );
		}
	}
	else if(vdobj$IsAncestryValid(
			objID        = &nodeIDs[0],
			superClassID = OPP_VDct1Base_class_id)) 
	{
		for( i = 0; i < cnt; i++ ) {
			VDct1PKTDisplayNode ( &nodeIDs[i], GRhd, hOpt );
		}
	}

wrapup:
	return;
}

end implementation Root;
