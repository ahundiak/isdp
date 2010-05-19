/* $Id: VDdrw_PlSTbl.I,v 1.24 2001/07/17 15:44:08 ylong Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vdtbl/func / VDdrw_PlSTbl.I
 *
 * Description:
 *	Functions used by the "Create Table by Stage" command.
 *		VDdrw_placeStageTable
 *
 * Dependencies:
 *
 * History:
 *      07/19/00        Ming            Created
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "EMSmsgdef.h"
#include "exmacros.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDtblCmdDef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "vddrwattr.h"
#include "vdparmacros.h"
#include "VDcompmacros.h"
#include "VDdrwtbl.h"
#include "VDCmdDef.h"
#include "v_drwprocess.h"
#include "vdtr_macros.h"
#include "VDassert.h"
#include "vdmiscmacros.h"
#include "VDexp.h"

from NDnode		import	NDget_objects;
from NDmacro		import	ACreturn_foot;
from ACrg_collect	import	AClist_attribute;
from VDdrwTbl		import	VDgetTableParts,
				VDgetTableLayoutName,
				VDgetTotalNbOfRows,
				VDputAdsTblName;
from VDdrwTblHdr	import	VDgetRowInfo,
				VDremoveRow,
				VDaddAndConstructRows,
				VDgetCornerPointForRow,
				VDputConstructInfo,
				VDconstructHdrTrl,
				VDgetRowHeight,
				VDinsertRow,
				VDrowNoToGRid;
from VDdrwTblRow	import	VDgetParentObjectList,
				VDgetQtyExpr,
				VDgetRowNumber,
				VDputQtyExpr,
				VDisRowLinedOut,
				VDinitTblRow,
				VDcreate,
				VDputUserDefRowFlag,
				VDgetParentSetId;
from VDdrwSet		import	VDemptySet, 
				VDaddObjectsToSet,
				VDinitSet,
				VDgetSetObjects;
from ACcpx		import	ACfind_temp_obj;
from GRgencs		import	GRcvt_to_wld_coords;

extern IGRlong		VDdrw_addObjectsToTable();

VDASSERT_FFN("vds/vdtbl/func/VDdrw_PlSTbl.I");

/* -------------------------------------------------------------------------
 *
 * Function to get nodelists based on selection rgColl 
 * and provide those lists for further processing 
 *
 * ------------------------------------------------------------------------- 
*/

IGRstat VDdrw_getSelectList(struct ACrg_coll *rg_list,TGRid *rootNode,IGRchar *nodeName,IGRchar *nodeType,TGRid **nodeList,IGRint *nodeCnt)
{
  VDASSERT_FN("VDdrw_getSelectList");
  IGRchar          indexType[128];
  IGRint           i,retFlag = 0;
  IGRstat          status = 0;
  IGRint           tmpNodeCount = 0,
                   localNodeCount = 0;
  struct GRid      *tmpNodeList;
  struct GRobj_env modelObj;

  // args check
  VDASSERTW(rg_list);
  VDASSERTW(rootNode);
  
  // inits
  *nodeCnt = 0;
  *nodeList = NULL;
  

  // this value "part_list" is from the gadget on the form.
  if( !(strcmp(rg_list[1].desc.value.att_txt, "part_list")) )
  {
    status = vd$trget_nodes( nodeID     = rootNode,
                             lookupType = VDTR_FIND_CHILD_NODE,
                             outID      = nodeList,
                             cnt        = nodeCnt ) ;
    
    if( !( status & 1) || *nodeCnt <= 0 ) goto wrapup;
  }

    else if( !(strcmp(rg_list[1].desc.value.att_txt, "index")) )
    {
      strcpy( indexType, rg_list[2].desc.value.att_txt );

      // See if it is a exp
      if (!strncmp(indexType,VDSA_KEY_SA_EXP,VDSA_KEY_SA_EXPn)) {
        //printf("Would have tired an expression here!\n");

        vdtr$GetNodeListByEXP(rootNode = rootNode,
                              attrExp  = indexType,
                              nodeList = nodeList,
                              nodeCnt  = nodeCnt);

      }
      else {
        // it is not an expression so go get the data directly
        status = vd$trget_nodes( nodeID     = rootNode,
                                 nodeType   = indexType,
                                 lookupType = VDTR_FIND_ALL_NODE,
                                 outID      = nodeList,
                                 cnt 	  = nodeCnt ) ;
      }
      if( !(status & 1) || *nodeCnt <= 0 ) goto wrapup;
    }

    /**************************************************/
    else if( !(strcmp(rg_list[1].desc.value.att_txt, "model_obj")) )
    {
      status = vd$trget_nodes( nodeID     = rootNode,
                               lookupType = VDTR_FIND_ALL_NODE,
			       outID      = &tmpNodeList,
                               cnt 	  = &tmpNodeCount ) ;

      if( !(status & 1) || tmpNodeCount <= 0 ) goto wrapup;

      if( tmpNodeCount > 0 )
      {
        *nodeList = _MALLOC( tmpNodeCount, struct GRid );
        if( !(nodeList) ) goto wrapup;

        *nodeCnt = 0;
        for( i = 0 ; i < tmpNodeCount ; i++ )
        {
          status = vd$trget_modelObject( nodeID = &tmpNodeList[i],
	  			         objOE = &modelObj );
	  if( status && (modelObj.obj_id.objid != NULL_OBJID) )
          {
             (*nodeList)[*nodeCnt] = modelObj.obj_id;
 	    *nodeCnt = *nodeCnt + 1;
	  }
        }
        _FREE ( tmpNodeList );
      }
      else
	*nodeCnt = 0;
        if(*nodeCnt == 0) _FREE( *nodeList );
    }// end of "Model_obj"
  retFlag = 1;
  
wrapup:
  return retFlag;
}




/*+fe
 -------------------------------------------------------------------------
  Function VDdrw_placeStageTable

  Abstract
        Function creates the stage table based on the inputs - table header
	object ID, table object ID and the stage node object ID 

  Arguments

        IGRlong         *msg            O       return code
  	IGRint		tblType		I	table type: 
						part list:VD_DRW_STBL_PLIST
						index:VD_DRW_STBL_INDEX
	struct GRid	*hdrId		I	table header ID
	struct GRid	*tblId		I	table ID
	struct GRid	*nodeId		I	node ID
	struct GRmd_env	*mod_env	I	Module environment 

  Returns
        OM_S_SUCCESS    = if success
        OM_E_ABORT      = if error
 -------------------------------------------------------------------------
-fe*/

IGRlong VDdrw_placeStageTable (	IGRlong			*msg,
				struct GRid		*tblId,
				struct GRid		*nodeId,
				struct GRmd_env		*mod_env,
				struct VDtblStImInfo	*tblInfo )
{
    IGRint		 i, j, k;
    IGRlong		 status;
    IGRint		 stageNodeCount = 0,
    		 	 tmpNodeCount = 0,
                         indexNodeCount = 0,
			 nbHdrs,
			 nbAttr,
			 sizeAttr,
			 nbParents;
    struct GRid		 rootNode,
			 *hdrId,
			 *stageNodeList,
                         *indexNodeList,
			 *tmpNodeList,
    			 parentIds[3];
    struct ACrg_coll     *rg_list;
    IGRchar              indexType[30];
    struct PrcInfo       *newList;
    struct GRobj_env	 modelObj;
    IGRchar              nodeType[128],nodeName[128],nodePath[128];
    


    SetProc( VDdrw_placeStageTable ); Begin

    *msg = MSSUCC;
    rg_list = NULL;
    hdrId = NULL;
    stageNodeList = NULL;
    tmpNodeList = NULL;
    newList = NULL;
    status = 0;

    if( tblId == NULL ) goto wrapup;

    /*
    ** get number of table parts(headers)
    */
    nbHdrs = 0;
    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         NULL),
	     senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) || (nbHdrs == 0) ) goto wrapup;
    hdrId = NULL;
    hdrId = _MALLOC( nbHdrs, struct GRid );
    if( hdrId == NULL ) goto wrapup;

    status =
    om$send( msg      = message VDdrwTbl.VDgetTableParts(msg,
                                                         &nbHdrs,
                                                         hdrId),
             senderid = NULL_OBJID,
             targetid = tblId->objid,
             targetos = tblId->osnum );
    if( !(status&*msg&1) ) goto wrapup;

    status =
    om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                          	     parentIds,
                                        	     3,
                                        	     NULL,
                                        	     0,
                                        	     OM_K_MAXINT,
                                        	     &nbParents),
      	     senderid = NULL_OBJID,
             targetid = hdrId[0].objid,
             targetos = hdrId[0].osnum );
    __CheckRC( status, *msg, "NDnode.NDget_objects", wrapup );
    
    if( nbParents < 3 ) goto wrapup;
    if( nodeId == NULL )
    {
      status =
      om$send( msg      = message NDmacro.ACreturn_foot(msg,
                                                        "",
                                                        &rootNode,
                                                        NULL, 
							NULL),
               senderid = NULL_OBJID,
               targetid = parentIds[2].objid,
               targetos = parentIds[2].osnum );

      __CheckRC( status, *msg, "NDmacro.ACreturn_foot", wrapup );
    }
    else
    {
      rootNode.objid = nodeId->objid;
      rootNode.osnum = nodeId->osnum;
    }

    nbAttr = 0;

    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                              0,
                                                              NULL,
                                                              &nbAttr),
 	     senderid = NULL_OBJID,
             targetid = parentIds[0].objid,
             targetos = parentIds[0].osnum );
    if( !(status&*msg&1) || (nbAttr==0) ) goto wrapup;

    if( !(rg_list = _MALLOC(nbAttr, struct ACrg_coll)) ) goto wrapup;

    sizeAttr = nbAttr;

    status =
    om$send( msg      = message ACrg_collect.AClist_attribute(msg,
                                                              sizeAttr,
                                                              rg_list,
                                                              &nbAttr),
             senderid = NULL_OBJID,
             targetid = parentIds[0].objid,
             targetos = parentIds[0].osnum );
    if( !(status&*msg&1) ) goto wrapup;

    vdtr$GetTreeObjectsByProcessID(nodeID      = &rootNode,
                                     nodeProcess = rg_list[1].desc.value.att_txt,
                                     nodeIndex   = rg_list[2].desc.value.att_txt,
                                     nodeList    = &stageNodeList, 
                                     nodeCnt     = &stageNodeCount);

    newList = NULL;
    if( stageNodeCount > 0 )
    {
      newList = _MALLOC( stageNodeCount, struct PrcInfo );
      if( newList == NULL ) {
	goto wrapup;
      }
      
    }

    for( i = 0 ; i < stageNodeCount ; i++ )
    {
      if( vdtr$IsLeaf(nodeID = &stageNodeList[i]) &&
	  vdobj$IsAncestryValid(objID		= &stageNodeList[i],
				superClassName	= "VDatBase") ) 
      {
	modelObj.obj_id.objid = NULL_OBJID;
	vd$trget_modelObject (	nodeID	= &stageNodeList[i],
				objOE	= &modelObj );
	if( modelObj.obj_id.objid != NULL_OBJID )
	{
	  newList[i].model = modelObj;
	}
	else
	{
	  newList[i].model.obj_id = stageNodeList[i];
	}
      }
      else 
      {
        newList[i].model.obj_id = stageNodeList[i];
      }
    }

    status = VDdrw_addObjectsToTable (	msg,
					tblId,
					newList,
					stageNodeCount,
					tblInfo );

    if( !(status&*msg&1) ) goto wrapup;

    status = OM_S_SUCCESS;

    UI_status( "Done ..." );


wrapup:

    _FREE( stageNodeList );
    _FREE( rg_list );
    _FREE( newList );
    _FREE( hdrId );

    End
    return status;
} /* VDdrw_placeStageTable */

end implementation Root;
