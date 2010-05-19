/* $Id: VDatmacros.h,v 1.1 2001/01/10 16:38:28 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDatmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatmacros.h,v $
 *      Revision 1.1  2001/01/10 16:38:28  art
 *      sp merge
 *
 * Revision 1.1  2000/08/04  20:34:28  pinnacle
 * temporarily as apis
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef VDatmacros_include
#define VDatmacros_include 1

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern	IGRstat	VDatGetNodeListFromTree	__((
	TGRid	*i_treeID, 
	IGRchar	*i_type, 
	TGRid	*o_nodeList, 
	IGRint	*o_nodeCnt
)); 

#omdef	vdat$GetNodeList( treeID, type = NULL, nodeList = NULL, nodeCnt )

	VDatGetNodeListFromTree((treeID), (type), (nodeList), (nodeCnt))

#endomdef


extern	IGRstat	VDatGetTreeListByType	__((
	IGRchar	*i_type,          
	TGRid	*o_treeList,	
	IGRint	*o_treeCnt
));

#omdef	vdat$GetTreeList( 
		type	 = NULL, 	// in,  tree type, null for all types
		treeList = NULL,	// out, output tree list 
		treeCnt )		// out, number of trees

	VDatGetTreeListByType((type), (treeList), (treeCnt))
#endomdef

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif

