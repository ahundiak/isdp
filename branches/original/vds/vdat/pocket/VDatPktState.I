/* $Id: VDatPktState.I,v 1.4 2001/07/20 18:50:30 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pocket/VDatPktState.I
 *
 * Description: Stores the state of the pocket command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPktState.I,v $
 *      Revision 1.4  2001/07/20 18:50:30  ylong
 *      CR4080
 *
 *      Revision 1.3  2001/07/17 18:42:01  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/03/05 22:31:49  ylong
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/09 23:42:21  ylong
 *      Renamed
 *
 *      Revision 1.7  2001/02/09 21:31:14  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/02/09 18:23:02  ylong
 *      Migrate from vdct1/cmd2/VDct1TreeF.c
 *
 *      Revision 1.4  2001/02/08 15:12:44  ad
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/11 21:01:17  art
 *      sp merge
 *
# Revision 1.3  2000/12/08  19:52:36  pinnacle
# pn
#
# Revision 1.2  2000/08/22  15:13:20  pinnacle
# ah
#
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/00  ah      Creation
 * 08/22/00  ah      Don't use mcf when selecting default selected row
 * 02/03/01  yl      Enabel to remember selected nodes for next show
 * 02/08/01  yl      Show last selections for VDct1
 ***************************************************************************/

class implementation VDatBase;

#include "VDatMaster.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDahFrm.h"
#include "VDfrm.h"
#include "VDppl1.h"
#include "VDct1.h"

#include "VDatPocket.h"

static int traceFlag;

static  TGRid   sSavedSetID;

%safe
static	struct VDatPKT_elem_buf savedNodes = {0, 0, 0};
%endsafe

static	IGRint	sSavedNodeToggle;
static IGRint   sPickList[UNFOLD_NB_OPT];

/* ---------------------------------------------------------------
 * Fills in the pick list data structure
 * Use an array to match the loft structure
 */
IGRstat VDatPKTFillInternalPickList(Form form)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRchar fn[] = "VDatPKTFillInternalPickList";
  IGRint numRows,row,sel;
  IGRint gadget = VDAT_FORM_PKT_G_PICK_LIST;
  
  IGRchar buf[128];
  if (traceFlag) printf("||>>>vds/vdat/pocket/VDatState.I:  %s\n",fn);
  // Get the rows
  numRows = -1;
  FIfld_get_num_rows(form,gadget,&numRows);
  if (numRows <= 0) goto wrapup;
  if (numRows >= UNFOLD_NB_OPT) numRows = UNFOLD_NB_OPT;
  
  // Cycle through // this VDAT_FORM_PKT_G_PICK_LIST is roll lines etc
  for(row = 0; row < numRows; row++) {
    vdfrm$GetText(form = form, gadget = gadget, row = row, txt = buf);
    FIfld_get_select(form,gadget,row,0,&sel);
    sPickList[row] = sel;
    //if(traceFlag)  printf("%s %d\n",buf,sel);
    // printf("%s %d\n",buf,sel);
    
  }
  
  // Done
  retFlag = 1;

 wrapup:
  if (traceFlag) printf("||<<<vds/vdat/pocket/VDatState.I:  %s(%d)\n",fn,retFlag);
  return retFlag;
  
}

/*----------------------------------------------------------------
 * Get and display last selected node, created by ylong
 */
IGRstat VDatPKTLoadState(Form form)
{
  IGRstat retFlag = 0;
  IGRstat traceFlag = 0;
  IGRstat sts,sts1;

  TGRid   setID, nodeID, chldID ;
  IGRint  treeGadget     = VDAT_FORM_PKT_G_TREE ;
  IGRint  setGadget      = VDAT_FORM_PKT_L_SETS ;
  IGRint  toggleGadget   = VDAT_FORM_PKT_T_MODEL_OR_NODE;
  IGRint  pickListGadget = VDAT_FORM_PKT_G_PICK_LIST;
  IGRint  treeType, VDAT_TREE = 0, VDCT1_TREE = 1;

  
  IGRint  i, j, row, numRows, sel = 0 ;

  // Restore the pick list
  numRows = 0;
  FIfld_get_num_rows(form, pickListGadget, &numRows);
  if (numRows >= UNFOLD_NB_OPT) numRows = UNFOLD_NB_OPT;
  for(row = 0; row < numRows; row++) {
    FIfld_set_active_row(form, pickListGadget, row, row);
    FIfld_set_select    (form, pickListGadget, row, 0, sPickList[row]);
  }

  // Set state toggle to last selection, 12-07-99 by ylong 
  if(sSavedNodeToggle) FIg_set_state_on (form, toggleGadget);
  else                 FIg_set_state_off(form, toggleGadget);

  // Make sure have previously selected set/node
  if(sSavedSetID.objid <= 0 ) {
    goto wrapup ;
  }

  /*
   * Enable it later on if needed
   */
  if(vdobj$IsAncestryValid(objID        = &sSavedSetID,
                           superClassID = OPP_VDct1Base_class_id)) {
    goto wrapup;
  }


     treeType = VDCT1_TREE;
  // Expand tree to last selected nodes
  if( FIfld_get_num_rows(form, setGadget, &numRows) != FI_SUCCESS) {
    goto wrapup ;
  }
  for(row = 0; row < numRows; row++) {
    VDahFrmGetGRid(form,setGadget,row,3,&setID);
    if(setID.objid == sSavedSetID.objid &&
       setID.osnum == sSavedSetID.osnum )
    {
      FIfld_set_active_row(form, setGadget, row, 0);
      FImcf_set_select    (form, setGadget, row, 1);
      VDatPKTFillSaveSetList ( form, VDAT_FORM_PKT_G_SET_NAME, &setID );
      break ;
    }
  }

  if(vdobj$IsAncestryValid(objID        = &sSavedSetID,
                           superClassID = OPP_VDatBase_class_id)) {
     treeType = VDAT_TREE;
     VDatPKTFormFillTree(form, treeGadget, &sSavedSetID);
     for( i = 0; i < savedNodes.count; i++ ) {
        VDatExpandTree(form,treeGadget,&sSavedSetID,&savedNodes.objIDs[i]);
     }
  }
  else if(vdobj$IsAncestryValid(objID        = &sSavedSetID,
                                superClassID = OPP_VDct1Base_class_id)) {
     treeType = VDCT1_TREE;
     VDct1PKTFormFillTree(form, treeGadget, &sSavedSetID);
     for( i = 0; i < savedNodes.count; i++ ) {
        VDct1PKTFormExpandTree(form,treeGadget,&sSavedSetID,&savedNodes.objIDs[i]);
     }
  }
  else {
     goto wrapup;
  }

  // Done
  retFlag = 1 ;
wrapup:
  
  return retFlag ;
}


/*--------------------------------------------------------
 * Saves the currently selected information
 */
IGRstat VDatPKTSaveState(Form form)
{
  IGRstat traceFlag = 0;
  IGRchar fn[] = "VDatPKTSaveState";
  
  IGRstat retFlag = 0;

  IGRint treeGadget = VDAT_FORM_PKT_G_TREE;
  IGRint setGadget  = VDAT_FORM_PKT_L_SETS ;
  IGRint row, nrow = 0, sel = 0, nsel = 0 ;
  TGRid  nodeID, objID;

  // Say hi
  if (traceFlag) printf("||>>>vds/vdat/pocket/VDatState.I:  %s\n",fn);
  
  // Save Set
  row = -1;
  vdfrm$GetActiveRow(form   = form,
                     gadget = setGadget,
                     row    = &row);
  if (row >= 0) {
    vdfrm$GetText(form   = form,
		  gadget = setGadget,
		  row    = row,
		  col    = 3,
		  objID  = &sSavedSetID);
  }
  
  // Save last selected state in both states, 12-07-99 by ylong
  vdfrm$GetState( form   = form,
		  gadget = VDAT_FORM_PKT_T_MODEL_OR_NODE, // gadget 22
		  state  = &sSavedNodeToggle);
  
  // Save the pick list info // gadget 21 lookup of roll lines etc
  VDatPKTFillInternalPickList(form);
  
  // Save selected nodes
  vdfrm$GetNumRows (    form    = form,
                        gadget  = treeGadget,
                        rows    = &nrow);
  if( nrow <= 0 ) {
        retFlag = 1;
        goto wrapup;
  }

  for( row = 0; row < nrow; row++ ) {
     sel = 0;
     vdfrm$GetSelect(   form    = form,
                        gadget  = treeGadget,
                        col     = 2,
                        row     = row,
                        sel     = &sel);
     if( sel ) nsel++;
  }

  if( savedNodes.bufSize < nsel ) {
    savedNodes.objIDs = (TGRid *)realloc(savedNodes.objIDs, nsel*sizeof(TGRid));
    savedNodes.bufSize = nsel;
  }

  savedNodes.count = 0;

  for( row = 0; row < nrow; row++ ) {
     sel = 0;
     vdfrm$GetSelect(   form    = form,
                        gadget  = treeGadget,
                        col     = 2,
                        row     = row,
                        sel     = &sel);
     if( sel ) {
        nodeID.objid = NULL_OBJID;
        nodeID.osnum = 0;
        vdfrm$GetText(  form   = form,
                        gadget = treeGadget,
                        row    = row,
                        col    = 3,
                        objID  = &nodeID);

        if( nodeID.objid != NULL_OBJID ) {
           savedNodes.objIDs[savedNodes.count++] = nodeID;
        }
     }
  }

  // Done
  retFlag = 1;
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get/Set interface to the state variables
 */
IGRstat VDatPKTGetStateSavedNodeToggle(IGRint *nodeToggle) 
{
  IGRstat traceFlag = 0;

  if (*nodeToggle) *nodeToggle = sSavedNodeToggle;

  return 1;
}
IGRstat VDatPKTSetStateSavedNodeToggle(IGRint nodeToggle) 
{
  IGRstat traceFlag = 0;
  IGRchar fn[] = "VDatPKTSetStateSavedNodeToggle";
  if (traceFlag) printf("||>>>vds/vdat/pocket/VDatState.I:  %s\n",fn);
  sSavedNodeToggle = nodeToggle;
  if (traceFlag) printf("||<<<vds/vdat/pocket/VDatState.I:  %s(%d)\n",fn,1);
  return 1;
}
IGRstat VDatPKTGetStateSavedSet(TGRid *setID) 
{
  IGRstat traceFlag = 0;
  IGRchar fn[] = "VDatPKTGetStateSavedSet";
  if (traceFlag) printf("||>>>vds/vdat/pocket/VDatState.I:  %s\n",fn);
  if (setID) *setID = sSavedSetID;
  if (traceFlag) printf("||<<<vds/vdat/pocket/VDatState.I:  %s(%d)\n",fn,1);
  return 1;
 
}
IGRstat VDatPKTSetStateSavedSet(TGRid *setID) 
{
  IGRstat traceFlag = 0;
  IGRchar fn[] = "VDatPKTSetStateSavedSet";
  if (traceFlag) printf("||>>>vds/vdat/pocket/VDatState.I:  %s\n",fn);
  sSavedSetID = *setID;
  if (traceFlag) printf("||<<<vds/vdat/pocket/VDatState.I:  %s(%d)\n",fn,1);
  return 1;
}
IGRstat VDatPKTGetStateSavedNode(TGRid *nodeID) 
{
  IGRstat traceFlag = 0;

  // if (nodeID) *nodeID = sSavedNodeID;
  printf("VDatPKTGetStateSavedNode is disabled !\n");

  return 1;

}
IGRstat VDatPKTSetStateSavedNode(TGRid *nodeID) 
{
  IGRstat traceFlag = 0;

  // sSavedNodeID = *nodeID;
  printf("VDatPKTSetStateSavedNode is disabled !\n");

  return 1;
}
IGRstat VDatPKTGetStatePickList(IGRint *pickList) 
{
  IGRint i;
  IGRstat traceFlag = 0;
  IGRchar fn[] = "VDatPKTGetStatePickList";
  if (traceFlag) printf("||>>>vds/vdat/pocket/VDatState.I:  %s\n",fn);
  if (pickList) {
    for(i = 0; i < UNFOLD_NB_OPT; i++) {
      pickList[i] = sPickList[i];
    }
    
  }
  if (traceFlag) printf("||<<<vds/vdat/pocket/VDatState.I:  %s(%d)\n",fn,1);
  return 1;
}

end implementation VDatBase;





