/* $Id: VPextProd.I,v 1.1.1.1 2001/01/04 21:11:58 cvs Exp $  */

/***************************************************************************
 * I/EFP
 *
 * File:        vpext/VPextProd.I
 *
 * Description: Extract Production Pieces
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VPextProd.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:58  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/05/24  18:39:42  pinnacle
# ah
#
# Revision 1.4  1998/11/29  19:51:24  pinnacle
# ah
#
# Revision 1.3  1998/11/29  14:41:50  pinnacle
# ah
#
# Revision 1.2  1998/11/14  14:09:48  pinnacle
# ah
#
# Revision 1.1  1998/06/14  16:13:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/12/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDfrm.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDatMaster.h"

#include "EMSopt.h"
#include "EMSlcdef.h"

#include "vsplatedef.h"

#include "VPextCmd.h"
#include "VPpdf.h"

from  EMSsubbs import  EMget_edges;
from  EMSedge  import  EMgetxyzobj;

/* --------------------------------------------------------
 * Recursive Extract Beam Node
 */
IGRstat VPextCMD_ExtractBeamNode(TVPextCMD_Info *info, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  IGRint  type,i;
  TGRid   childID;
  
  // ReCurse if it is a tree node
  VDatGetBaseType(nodeID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:

    VPextExtractBeamNode(nodeID);
    
    break;
    
  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE:  // Add itself then do all kids

    // Recursive Loop, add itself
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VPextCMD_ExtractBeamNode(info,&childID);
    }
    break;    
  }

  // Close it
  retFlag = 1;
  
//wrapup:
  return retFlag;
}
  
/* --------------------------------------------------------
 * Recursive Extract Plate Node
 */
IGRstat VPextCMD_ExtractPlateNode(TVPextCMD_Info *info, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  IGRint  type,i;
  TGRid   childID;
  
  // ReCurse if it is a tree node
  VDatGetBaseType(nodeID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:  // 

    VPextExtractPlateNode(nodeID);
    
    break;
    
  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE:  // Add itself then do all kids

    // Recursive Loop, add itself
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
      VPextCMD_ExtractPlateNode(info,&childID);
    }
    break;    
  }

  // Close it
  retFlag = 1;
  
//wrapup:
  return retFlag;
}
 
/* --------------------------------------------------------
 * Extract Selected Production Pieces
 */
IGRstar VPextCMD_ExtractProd(TVPextCMD_Info *info)
{
  IGRstat retFlag = 0;

  Form    form = info->ext.form;
  IGRint  gadget = VPEXT_FORM_G_TREE;
  
  IGRint  rows,row,sel;
  IGRint  selFlag;
  
  TGRid   nodeID;

  IGRchar what[64];
  IGRchar treeName[64];
  
  // Make sure set was picked
  if (info->setID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure want something for production
  vdfrm$GetText(form = form, gadget = VPEXT_FORM_G_FILE_WHAT, txt = what);
  if (!strcmp(what,"Tree")) goto wrapup;

  // Make sure have a tree
  VDatGetTree(&info->setID, &nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Put it's name for error checking
  vdsa$GetStruct(objID = &nodeID, name = "node_name", txt = treeName);

  // Find the selected items and write them out
  vdfrm$GetText(form = form, gadget = gadget, rows = &rows);

  // Say hi
  printf("========================================================\n");
  
  // Just make two loops, one for plates
  if (strcmp(what,"Beams")) {

    UI_status("Extracting Plates");
    
    VPpdfWriteObjBeg  (PDF_OBJ_PLATES);
    VPpdfWriteAttrText(PDF_ATR_TREE_NAME, treeName);
    selFlag = 0;
  
    for(row = 0; row < rows; row++) {
    
      vdfrm$GetText(form   = form,
		    gadget = gadget,
		    row    = row,
		    col    = 2,
		    sel    = &sel);

      if (sel) {

	selFlag = 1;  // At least one row was selected
      
	vdfrm$GetText(form   = form,
		      gadget = gadget,
		      row    = row,
		      col    = 3,
		      objID  = &nodeID);

	VPextCMD_ExtractPlateNode(info,&nodeID);
      }
    }
    if (selFlag == 0) {

      // Do everything be default
      VDatGetTree(&info->setID, &nodeID);
      VPextCMD_ExtractPlateNode(info,&nodeID);
    }
  
    VPpdfWriteObjEnd(PDF_OBJ_PLATES);
    UI_status("Extracted Plates");
    
  }
  
  // And one for beams
  if (strcmp(what,"Plates")) {
    
    UI_status("Extracting Beams");
    
    VPpdfWriteObjBeg  (PDF_OBJ_BEAMS);
    VPpdfWriteAttrText(PDF_ATR_TREE_NAME, treeName);
    selFlag = 0;
  
    for(row = 0; row < rows; row++) {
    
      vdfrm$GetText(form   = form,
		    gadget = gadget,
		    row    = row,
		    col    = 2,
		    sel    = &sel);

      if (sel) {
      
	selFlag = 1;  // At least one row was selected
	
	vdfrm$GetText(form   = form,
		      gadget = gadget,
		      row    = row,
		      col    = 3,
		      objID  = &nodeID);

	VPextCMD_ExtractBeamNode(info,&nodeID);
      }
    }
    if (selFlag == 0) {

      // Do everything be default
      VDatGetTree(&info->setID, &nodeID);
      VPextCMD_ExtractBeamNode(info,&nodeID);
    }

    VPpdfWriteObjEnd(PDF_OBJ_BEAMS);
    UI_status("Extracted Beams");
    
  }
  
  retFlag = 1;

wrapup:

  return retFlag;
}
 
end implementation VDbtBase;




