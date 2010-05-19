/* $Id: VDct1Part.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Mgr.C
 *
 * Description: Main Forms Manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Part.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.5  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.4  2000/08/23  14:51:24  pinnacle
 * ah
 *
 * Revision 1.3  2000/08/17  11:31:40  pinnacle
 * js
 *
 * Revision 1.2  2000/08/08  16:35:14  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/04  19:28:50  pinnacle
 * Created: vds/vdct1/cmd2/VDct1Part.C by jdsauby for Service Pack
 *
 * Revision 1.1  2000/07/27  15:13:14  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/25/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDris2.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Part.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

VDASSERT_FFN("vdct1/cmd/VDct1Part.c");

static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;
static TGRid lockedNodeID;


/* -------------------------------------------
 * Update the attribute list
 */
IGRstat VDct1CmdPartUpdateAttrList(Form form, IGRchar *part_cage_num)
{
  VDASSERT_FN("VDct1CmdPartUpdateAttrList");


  IGRstat retFlag = 0;
  IGRint gadget = VDCT_FORM_OPS_L_ATTRS;
  
  TVDct1_part_fld_part_id part_id;
  
  TVDrisInfo ris;
  
  IGRint row;

  // Arg check
  VDASSERTW(form);
  VDASSERTW(part_cage_num);

  // Say Hi
  if (traceFlag) printf(">>> %s %s %s",ffn(),fn,part_cage_num);
  
  // Init
  VDrisInitInfo(&ris);
  VDfrmSetSts(form,"");

  // Init form
  VDfrmSetgText  (form,VDCT_FORM_OPS_G_PART_CAGE_NUM,part_cage_num);
  VDfrmSetNumRows(form,gadget,0);
  if (*part_cage_num == 0) goto wrapup;
  
  // Need the unique part_id
  VDct1ReadPartIdForPartCageNum(part_cage_num,part_id);
  if (*part_id == 0) {
    VDfrmSetSts(form,"NOT IN OPS!");
    UI_status("Part is not in OPS!");
    goto wrapup;
  }
  
  // Do the query here
  VDct1QryAttrsForPartId(&ris,part_id);
  
  // Fill the form
  row = 0;
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {

    ris.j = ris.i * ris.cols;

    VDfrmSetfText(form,gadget,row,VDCT_FORM_OPS_L_ATTRS_NAME,
		  ris.buf[ris.j+VDCT1_RIS_COLI_ATTRS_NAME]);

    VDfrmSetfText(form,gadget,row,VDCT_FORM_OPS_L_ATTRS_VALUE,
		  ris.buf[ris.j+VDCT1_RIS_COLI_ATTRS_VALUE]);
    row++;
  }

  // Really should add copics information to here

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  VDrisFreeInfo(&ris);
  return retFlag;
}

/* -------------------------------------------
 * User typed something into part_cage_num
 */
IGRstat VDct1CmdPartNotifyPartCageNum()
{
  VDASSERT_FN("VDct1CmdPartNotifyPartCageNum");
  
  IGRstat retFlag = 0;
  Form    form = cmdInfo->part.form;
  IGRchar buf[64];
  
  // Say Hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // Get it
  VDfrmGetgText(form,VDCT_FORM_OPS_G_PART_CAGE_NUM,buf);

  // Do It
  VDct1CmdPartUpdateAttrList(form,buf);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Called when a node is activated
 */
static IGRstat activateNode(TGRid *nodeID)
{  
  VDASSERT_FN("activateNode");
  
  IGRstat       retFlag = 0;

  Form form = cmdInfo->part.form;
    
  TVDct1_part_fld_part_cage_num part_cage_num;

  // Save it
  VDASSERTW(nodeID);
  activeNodeID = *nodeID;

  // If form is not displayed, do nothing
  if (!cmdInfo->part.displayed) goto wrapup;
  
  // Get part cage num
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
 * The notification routine, called by the ppl
 */
static IGRstat notifyForm()
{
  VDASSERT_FN("notifyForm");
  
  IGRstat retFlag = 1;
  IGRstat sts;
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->part;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Process It
  switch(cmdInfo->gadget) {

  case FI_CANCEL:
    VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
    break;
 
  case VDCT_FORM_OPS_G_PART_CAGE_NUM:
    VDct1CmdPartNotifyPartCageNum();
    break;

  }
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }
  return retFlag;
}

/* -------------------------------------------
 * Called to activate the form
 */
static IGRstat activateForm()
{
  VDASSERT_FN("activateForm");
  
  IGRstat retFlag = 1;

  TVDct1CmdFormInfo *formInfo = &cmdInfo->part;

  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);
 
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitPartCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitPartCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_CMD_PART);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;
 
  activeNodeID.objid = NULL_OBJID;
  lockedNodeID.objid = NULL_OBJID;
    
  // Default init
  formInfo = &cmdInfo->part;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_OPS_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm   = notifyForm;
  formInfo->activateForm = activateForm;
  formInfo->activateNode = activateNode;

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
