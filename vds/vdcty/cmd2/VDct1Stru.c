/* $Id: VDct1Stru.c,v 1.1 2001/01/14 16:01:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/Vct1Stru.C
 *
 * Description: Struct ISDP OPS COPICS Link
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Stru.c,v $
 *      Revision 1.1  2001/01/14 16:01:21  art
 *      sp merge
 *
 * Revision 1.3  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/23  14:51:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/09  13:07:12  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/08/00  ah      Creation
 ***************************************************************************/
/* -----------------------------------------------
 * This is basically a quick debugging form for mapping
 * stuff from isdp to ps and copics
 * 
 * The structure is a bit out of data and needs to be cleaned up
 * But it works for now
 */
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDobj2.h"
#include "VDris2.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"

#include "VDct1Part.h"
#include "VDct1Ris.h"

VDASSERT_FFN("vdct1/cmd/VDct1Stru.c");

static TVDct1CmdInfo *cmdInfo;

static TGRid activeNodeID;

#define VDCT_FORM_STRU_F_NAME "VDct1Struct.F"

/* -----------------------------------------------
 * This structure has all the info needed to link
 * an isdp plate or beam with the ops system
 * and the copics system
 */
typedef struct 
{
  TGRobj_env pieceOE;

  IGRchar cage_code[10];
  
  struct 
  {  
    IGRchar   family  [40];  // table name
    IGRchar   part_num[40];  // n_itemname
    IGRchar   desc    [40];  // n_itemdesc
    
    IGRchar   material[20];  // material
    IGRchar   grade   [20];  // grade
    IGRchar   units   [20];
    
    IGRdouble amount;      // Length or Area

    IGRint    isBeam;
    IGRint    isPlate;
    IGRchar   type[20];    // For debugging
    
  } isdp;
  
  struct 
  {
    IGRchar   noun_name[40];
    IGRchar   material [20];
    IGRchar   part_size[40];
    IGRchar   mino     [40];
    IGRchar   units    [40];
    IGRdouble amount;
  } ops;
  
  struct 
  {
    IGRchar   mino     [40];
    IGRchar   units    [40];
    IGRdouble amount;        // Stock size
    IGRdouble percent;       // Amount of stock used    
  } cop;

  TVDct1RisIOC ris;
  
} TVDct1IOC;
  
/* -----------------------------------------------
 * Fills in ioc structure for a given piece
 */
IGRstat VDct1FillIOC(TGRobj_env *pieceOE, TVDct1IOC *ioc)
{
  VDASSERT_FN("VDct1FillIOC");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint    isBeam,isPlate;
  IGRdouble amount;

  TVDrisInfo ris;

  TVDct1PartInfo part;
  IGRchar        part_cage_num[64];
  IGRchar        part_id      [64];
  
  TVDct1RisIOC iocx;
  
  // Arg check
  VDASSERTW(ioc);
  memset(ioc,0,sizeof(TVDct1IOC));
  VDASSERTW(pieceOE);
  
  // Plate or beam
  isBeam  = VDobjIsAncestryValid(pieceOE,NULL,0,"VSbeam");
  isPlate = VDobjIsAncestryValid(pieceOE,NULL,0,"VSplate");
  if ((isBeam == 0) && (isPlate == 0)) goto wrapup;
  
  // Xfer some info
  ioc->pieceOE = *pieceOE;
  strcpy(ioc->cage_code,VDCT1_DEFAULT_CAGE_CODE);
  
  if (isBeam) {
    ioc->isdp.isBeam = 1;
    strcpy(ioc->isdp.type, "BEAM");
    strcpy(ioc->isdp.units,"METERS");

    VDobjGetDblAtr(pieceOE,NULL,"memb_cut_leng",&amount);
    ioc->isdp.amount = amount / 1000.0;
    
  }
  if (isPlate) {
    ioc->isdp.isPlate = 1;
    strcpy(ioc->isdp.type, "PLATE");
    strcpy(ioc->isdp.units,"SQUARE METERS");
  }

  // More attributes
  VDobjGetTxtAtr(pieceOE,NULL,"family_name",ioc->isdp.family);
  VDobjGetTxtAtr(pieceOE,NULL,"part_num",   ioc->isdp.part_num);
  VDobjGetTxtAtr(pieceOE,NULL,"material",   ioc->isdp.material);
  VDobjGetTxtAtr(pieceOE,NULL,"grade",      ioc->isdp.grade);

  // Part size takes a query
  /* ---------------------------------------------
   * Make several assumptions here
   * part_num is unique in the table
   * material is still valid
   * Might be wise to check material here?
   */
  VDrisInitInfo(&ris);
  sprintf(ris.sql,
	  "Select n_itemdesc from %s where n_itemname = '%s';",
	  ioc->isdp.family,ioc->isdp.part_num);
  VDrisQuery(&ris,NULL);
  if (ris.rows > 0) {
    strcpy(ioc->isdp.desc,ris.buf[0]);
  }
  VDrisFreeInfo(&ris);

  // Generate the isdp name
  VDct1GetPartCageNumForModelObject(pieceOE,NULL,part_cage_num,NULL);
  
  // Fill in the ris data
  VDct1ReadIOCForPartCageNum(&ioc->ris,VDCT1_RIS_COLI_SIOC_ISDP_CAGE_NUM,part_cage_num);
  if (*ioc->ris.isdp_cage_num == 0) goto wrapup;
  
  /* ---------------------------------------------
   * Given isdp.part_num and material, query the
   * ioc table to get ops mino
   */
  strcpy(ioc->ops.mino,ioc->ris.ops_cage_num);
  
  // Given the ops mino and cage code fill in the standard part structure
  VDct1ReadPartIdForItemCageNum(ioc->ris.ops_cage_num,part_id);
  if (*part.part_id == 0) goto wrapup;
  VDct1ReadPartFromAttrsTable(part_id,&part);
  
  // Pull over info
  strcpy(ioc->ops.noun_name,part.noun_name);
  strcpy(ioc->ops.material, part.material);
  strcpy(ioc->ops.part_size,part.part_size);
  strcpy(ioc->ops.mino,     part.part_num);
  strcpy(ioc->ops.units,    part.unit_of_measure);
  
  // Xfer some copics info
  strcpy(ioc->cop.mino,ioc->ris.cop_cage_num);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Object is picked
 */
static IGRstat locatedObject()
{
  VDASSERT_FN("locatedObject");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env modelOE;

  TVDct1IOC ioc;
  
  Form form = cmdInfo->stru.form;
  
  IGRchar buf[128];
  
  // Ignore if form not displayed
  if (!cmdInfo->stru.displayed) goto wrapup;

  // Get the object, make sure its something
  modelOE = cmdInfo->locatedOE;
  VDASSERTW((modelOE.obj_id.objid != 0) && (modelOE.obj_id.objid != NULL_OBJID));
  
  // Fill in ioc stuff
  sts = VDct1FillIOC(&modelOE,&ioc);
  if (!(sts & 1)) goto wrapup;
  
  // Update the form

  // Isdp stuff
  VDfrmSetgText(form,35,ioc.isdp.family);
  VDfrmSetgText(form,33,ioc.isdp.material);
  VDfrmSetgText(form,32,ioc.isdp.grade);
  VDfrmSetgText(form,31,ioc.isdp.desc);
  VDfrmSetgText(form,17,ioc.isdp.part_num);
  VDfrmSetgText(form,38,ioc.isdp.units);
  
  sprintf(buf,"%.3f",ioc.isdp.amount);
  VDfrmSetgText(form,22,buf);
  
  // Ops stuff
  VDfrmSetgText(form,36,ioc.ops.noun_name);
  VDfrmSetgText(form,34,ioc.ops.material);
  VDfrmSetgText(form,19,ioc.ops.part_size);
  VDfrmSetgText(form,18,ioc.ops.mino);
  VDfrmSetgText(form,21,ioc.ops.units);

  sprintf(buf,"%.3f",ioc.ops.amount);
  VDfrmSetgText(form,23,buf);

  // Copics stuff
  VDfrmSetgText(form,30,ioc.cop.mino);
  VDfrmSetgText(form,39,ioc.cop.units);

  sprintf(buf,"%.3f",ioc.cop.amount);
  VDfrmSetgText(form,25,buf);

  sprintf(buf,"%.1f%%",ioc.cop.percent * 100.0);
  VDfrmSetgText(form,24,buf);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Called when a node is activated
 */
static IGRstat activateNode(TGRid *nodeID)
{  
  VDASSERT_FN("activateNode");
  
  IGRstat retFlag = 0;

  Form form = cmdInfo->stru.form;

  // Save it
  VDASSERTW(nodeID);
  activeNodeID = *nodeID;

  // If form is not displayed, do nothing
  if (!cmdInfo->stru.displayed) goto wrapup;
  
#if 0
  // Get part cage num
  VDct1GetPartCageNumForNode(nodeID,part_cage_num);
  if (*part_cage_num == 0) goto wrapup;
  
  // Update the form list
  VDct1CmdPartUpdateAttrList(form,part_cage_num);
#endif

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
  
  TVDct1CmdFormInfo *formInfo = &cmdInfo->stru;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,cmdInfo->gadget);
  }

  // Process It
  switch(cmdInfo->gadget) {

  case FI_CANCEL:
    VDfrmDisplayForm(formInfo->form,0,&formInfo->displayed);
    break;
#if 0
  case VDCT_FORM_OPS_G_PART_CAGE_NUM:
    VDct1CmdPartNotifyPartCageNum();
    break;
#endif

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

  TVDct1CmdFormInfo *formInfo = &cmdInfo->stru;

  VDfrmDisplayForm(formInfo->form,1,&formInfo->displayed);
 
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitStruCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitStruCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;
 
  activeNodeID.objid = NULL_OBJID;
    
  // Default init
  formInfo = &cmdInfo->stru;
  sts = VDct1CmdInitRootFormInfo(formInfo,VDCT_FORM_STRU_F_NAME);
  VDASSERTW(sts & 1);
  
  // Overridden functions
  formInfo->notifyForm   = notifyForm;
  formInfo->activateForm = activateForm;

  formInfo->activateNode  = activateNode;
  formInfo->locatedObject = locatedObject;

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
