/* $Id: VDct1Part.I,v 1.2 2001/02/11 17:43:52 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/VDct1Part.I
 *
 * Description: Part (OPS) Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Part.I,v $
 *      Revision 1.2  2001/02/11 17:43:52  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.1  2001/01/11 22:03:42  art
 *      sp merge
 *
# Revision 1.5  2000/07/20  20:15:44  pinnacle
# js
#
# Revision 1.4  2000/06/30  17:29:32  pinnacle
# ah
#
# Revision 1.3  2000/06/04  17:04:56  pinnacle
# ah
#
# Revision 1.2  2000/06/03  17:34:30  pinnacle
# ah
#
# Revision 1.1  2000/06/02  16:32:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/01/00  ah      Creation
 ***************************************************************************/

class implementation VDct1Base;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDfrm.h"
#include "VDrisc.h"
#include "VDsa.h"
#include "VDppl1.h"

#include "VDct1.h"
#include "VDct1Part.h"
#include "VDct1Cmd.h"
#include "VDct1Forms.h"

static int traceFlag;

static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid lockedNodeID;


/* -------------------------------------------
 * Update the attribute list
 */
IGRstat VDct1CmdPartUpdateAttrList(Form form, IGRchar *part_cage_num)
{
  IGRstat retFlag = 0;
  IGRint gadget = VDCT_FORM_OPS_L_ATTRS;
  
  TVDct1_part_fld_part_id part_id;
  
  TVDrisInfo ris;
  
  IGRint row;

  // Init
  vdris$InitInfo(info = &ris);
  vdfrm$SetStatus(form = form, txt = "");

  // Arg check
  if (form          == NULL) goto wrapup;
  if (part_cage_num == NULL) goto wrapup;

  // Init form
  vdfrm$SetText(form   = form,
		gadget = VDCT_FORM_OPS_G_PART_CAGE_NUM,
		txt    = part_cage_num);
  vdfrm$SetNumRows(form = form, gadget = gadget, rows = 0);
  if (*part_cage_num == 0) goto wrapup;
  
  // Need the unique part_id
  VDct1ReadPartIdForPartCageNum(part_cage_num,part_id);
  if (*part_id == 0) {
    vdfrm$SetStatus(form = form, txt = "NOT IN OPS!");
    UI_status("Part is not in OPS!");
    goto wrapup;
  }
  
  // Do the query here
  VDct1QryAttrsForPartId(&ris,part_id);
  
  // Fill the form
  row = 0;
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {

    ris.j = ris.i * ris.cols;

    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_OPS_L_ATTRS_NAME,
		  txt    = ris.buf[ris.j+VDCT1_RIS_COLI_ATTRS_NAME]);

    vdfrm$SetText(form   = form,
		  gadget = gadget,
		  row    = row,
		  col    = VDCT_FORM_OPS_L_ATTRS_VALUE,
		  txt    = ris.buf[ris.j+VDCT1_RIS_COLI_ATTRS_VALUE]);
    row++;
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  vdris$FreeInfo(info = &ris);
  return retFlag;
}

/* -------------------------------------------
 * Node was activated
 */
IGRstat VDct1CmdPartActivateNode(TGRid *nodeID)
{
  IGRstat retFlag = 0;

  Form   form   = cmdInfo->part.form;
  
  TVDct1_part_fld_part_cage_num part_cage_num;

  // Save it but do nothing else unless for is showing
  activeNodeID = *nodeID;
  if (!cmdInfo->part.displayed) goto wrapup;
  
  // See if have a part number
  VDct1GetPartCageNumForNode(nodeID,part_cage_num);
  if (*part_cage_num == 0) goto wrapup;

  // Update the form list
  VDct1CmdPartUpdateAttrList(form,part_cage_num);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * User typed something into part_cage_num
 */
IGRstat VDct1CmdPartNotifyPartCageNum()
{
  IGRstat retFlag = 0;
  Form    form = cmdInfo->part.form;
  IGRchar buf[64];
  
  // Get it
  vdfrm$GetText(form   = form,
		gadget = VDCT_FORM_OPS_G_PART_CAGE_NUM,
		txt    = buf);

  // Do It
  VDct1CmdPartUpdateAttrList(form,buf);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDct1CmdPartNotifyForm()
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Process it
  if (traceFlag) printf(">>> VDct1CmdPartNotifyForm\n");
  switch(cmdInfo->gadget) {
    
  case FI_CANCEL:
    vdfrm$EraseForm(form =  cmdInfo->part.form, 
                    flag = &cmdInfo->part.displayed);
    break;

  case VDCT_FORM_OPS_G_PART_CAGE_NUM:
    VDct1CmdPartNotifyPartCageNum();
    break;
    
  }
  retFlag = 1;

//wrapup:
  if (traceFlag) printf("<<< VDct1CmdPartNotifyForm\n");
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDct1CmdPartActivateForm()
{
  IGRstat retFlag = 0;

  // Ignore if already active for now
  if (cmdInfo->part.displayed) {
    retFlag = 1;
    goto wrapup;
  }
  if (traceFlag) printf(">>> VDct1CmdPartActivateForm\n");

  // Display
  vdfrm$DisplayForm(form =  cmdInfo->part.form, 
                    flag = &cmdInfo->part.displayed);

  // Done
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDct1CmdPartActivateForm\n");
  return retFlag;
}

/* --------------------------------------------------------
 * Called on startup
 */
IGRstat VDct1CmdPartInit(TVDct1CmdInfo *a_cmdInfo)
{
  IGRstat retFlag = 0;

  traceFlag = 0;
  if (traceFlag) printf(">>> VDct1CmdPartInit\n");

  cmdInfo = a_cmdInfo;

  activeNodeID.objid = NULL_OBJID;
  lockedNodeID.objid = NULL_OBJID;
  
  retFlag = 1;

  if (traceFlag) printf("<<< VDct1CmdPartInit\n");
  return retFlag;
}

/* ---------------------------------------------------------
 * Standard event handlers
 */
#argsused
IGRstat VDct1CmdPartCreatedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdPartDeletedTree(TGRid *treeID)
{
  return 1;
}
#argsused
IGRstat VDct1CmdPartRenamedTree(TGRid *treeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdPartCreatedNode(TGRid *nodeID)
{  
  return 1;
}
#argsused
IGRstat VDct1CmdPartDeletedNode(TGRid *nodeID, TGRid *parentID)
{    
  return 1;
}

IGRstat VDct1CmdPartRenamedNode(TGRid *nodeID)
{ 
  return 1;
}


end implementation VDct1Base;






