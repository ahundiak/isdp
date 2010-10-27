/* $Id: VDtreeSaveSet.h,v 1.5 2001/12/06 21:04:25 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDtreeSaveSet.h
 *
 * Description:	Save Set
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtreeSaveSet.h,v $
 *      Revision 1.5  2001/12/06 21:04:25  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/07/31 20:26:49  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/07/31 19:19:17  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/07/25 17:58:47  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/07/20 18:52:36  ylong
 *      CR4080
 *
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 07/18/01	ylong		Creation
 ***************************************************************************/
#ifndef VDtreeSaveSet_include
#define VDareeSaveSet_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*--------------------------------------------------------------
 * VDAT_SATGE_SETS is the driectory under which saved set created
 */
#define	VDAT_SATGE_SETS_DIR	"stage_sets"
#define	VDAT_SAVE_SET_ATTR_PATH	"path"		/* node path or obj path */
#define	VDAT_SAVE_SET_ATTR_TAG	"tag"		/* file name and objid	 */

#define	VDAT_SAVE_SET_TYPE_TSET	"tree_set"	/* tree set saved  */
#define	VDAT_SAVE_SET_TYPE_ROOT	"tree_root"	/* tree root saved */
#define	VDAT_SAVE_SET_TYPE_NODE	"tree_node"	/* tree node saved */


/*---------------------------------------------------------------
 * Routines 
 */
extern	IGRstat	VDtrStExpandTree	__((	Form    form,
						IGRint  gadget,
						TGRid   *setID,
						TGRid   *listIDs,
						IGRint  cnt ));

extern IGRstat VDtrStAddPieceAttributes __((	TGRid *objID,
						TGRid *pieceID));

extern	IGRstat VDtrStGetDoomObjByName	__((	IGRchab doomName,
						TGRid   *treeSetID,
						TGRid   *doomID ));

extern	IGRstat VDtrStExtractStObj	__((	GRspacenum osnum,
						TGRid   *pieceID,  
						TGRid   *objID ));

extern	IGRstat VDtrStExtractStRoot	__((	TGRid   *piecesID, 
						TGRid   *rootID ));

extern	void	VDtrStHiliteSavedSet	__((	IGRchar	*hOpt,
						TGRid	*nodeIDs,
						IGRint	count ));

extern	IGRstat	VDatPKTFillSaveSetList	__((	Form    form,
						IGRint	gadget,
						TGRid	*treeSetID ));


/*----------------------------------------------------------------------
 *  Macro vd$TreeSet_getList
 */
extern IGRstat VDtrStGetSavedSets __((

	TGRid	*treeSetID,	// in, tree set id, VDatSet or VDct1Base
	TGRid	**objList,	// out, saved set list (VDbufMacro)
	GRname	**nameList,	// out, saved set name list
	GRname 	**pathList,	// out, saved set path list
	IGRint	*count		// out, number of saved sets
));

#omdef	vd$TreeSet_getList(	treeSetID,
				objList  = NULL,
				nameList = NULL,
				pathList = NULL,
				count )
VDtrStGetSavedSets((treeSetID),(objList),(nameList),(pathList),(count))
#endomdef

/*----------------------------------------------------------------------
 * 
 */
extern	IGRstat	VDtrStCreateSaveSet __((

	IGRchab setName,	// in, saved set name
	TGRid   *treeSetID,	// in, tree set id (VDatSet/VDct1Base)
	TGRid   *rootID,	// in, root node from tree
	TGRid   *objList,	// in, node list from tree
	IGRint  count,		// in, number of nodes in the list
	IGRint	check,		// in, check if obj exists with the same name
	TGRid   *outID		// out, saved set id (VDbufMacro)
));

#omdef	vd$TreeSet_create(	setName,
				treeSetID,
				rootID = NULL,
				objList,
				count,
				check = FALSE,
				outID = NULL )
VDtrStCreateSaveSet ((setName), (treeSetID), (rootID), (objList), (count),(check),(outID))
#endomdef

/*----------------------------------------------------------------------
 * Delete saved set. Not allowed to delete a saved set in a reference file
 */
extern	IGRstat VDtrStDeleteSavedSet	__((

	IGRchar	*setName,	// in, saved set name
	TGRid	*treeSetID	// in, tree set id (VDatSet or VDct1Base)
)); 

#omdef	vd$TreeSet_delete (	setName,
				treeSetID )
VDtrStDeleteSavedSet ((setName), (treeSetID))
#endomdef

/*----------------------------------------------------------------------
 *
 */
extern	IGRstat VDtrStGetSaveSetByName	__((

	IGRchab setName,	// in, saved set name
	TGRid   *treeSetID,	// in, tree set id (VDatSet or VDct1Base)
	TGRid   *rootID,	// out, root node from tree
	TGRid   **objList,	// out, node list
	IGRint  *count		// out, number of nodes
)); 

#omdef	vd$TreeSet_getSaveSet (	setName,
				treeSetID,
				rootID  = NULL,
				objList = NULL,
				count )
VDtrStGetSaveSetByName((setName), (treeSetID), (rootID), (objList), (count))

#endomdef


/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
