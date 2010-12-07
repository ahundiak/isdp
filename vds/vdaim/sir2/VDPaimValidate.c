/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimValidate.c
 *
 * Description: 1st shot at validation command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimValidate.c,v $
 *      Revision 1.1.2.6  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.5  2003/09/10 15:56:22  ahundiak
 *      ah
 *
 *      Revision 1.1.2.4  2003/08/21 14:32:51  ahundiak
 *      ah
 *
 *      Revision 1.1.2.3  2003/06/11 13:31:19  ahundiak
 *      ah
 *
 *      Revision 1.1.2.2  2003/06/05 16:45:17  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/06/04 18:13:42  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/03/03  ah      Creation
 * 08/21/03  ah      TR7971 - Add warning when sttributes exceed max length
 * 09/10/03  ah      TR8041 - Add call to VDPaimReconnectDAD
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDpdm.h"
#include "VDfrmc.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDdoom.h"
#include "VDdom2.h"

#include "PDUuser.h"
#include "VDScheckdef.h"
#include "ACcheckin.h"

#include "VDPdef.h"
#include "VDPaimUtil.h"
#include "VDPaimPostMan.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
extern Display *_FI_display;

VDASSERT_FFN("VDPaimValidate.c");

/* ----------------------------------------------
 * Command data
 */
typedef struct
{ 
  Form   form;
  IGRint ready;
  IGRint loop;
  IGRint test;
  
  IGRint  statusRow;

  IGRchar logFileName[128];
  IGRchar calFileName[128];
  IGRchar xmlFileName[128];

  domNode fileInfoNode;
  domNode postObjectsNode;
  domNode asirPlacementsNode;

  domNode objNode;  /* The current object being edited */
  domNode cpyNode;  /* A copy of the current object    */

} Ts_info;

static Ts_info *s;

#define VDP_AIM_FORM_VALIDATE_NUM  111
#define VDP_AIM_FORM_VALIDATE_NAME "AIMvalidate"

#define VDP_AIM_FORM_VALIDATE_G_LIST 12

#define VDP_AIM_FORM_VALIDATE_G_LIST_STATUS  0
#define VDP_AIM_FORM_VALIDATE_G_LIST_OBJID   1
#define VDP_AIM_FORM_VALIDATE_G_LIST_CLASS   2
#define VDP_AIM_FORM_VALIDATE_G_LIST_TAG_NUM 3
#define VDP_AIM_FORM_VALIDATE_G_LIST_NOTES   4
#define VDP_AIM_FORM_VALIDATE_G_LIST_MAX     5

#define VDP_AIM_FORM_VALIDATE_G_ATTRS      35
#define VDP_AIM_FORM_VALIDATE_G_ATTRS_NAME  0
#define VDP_AIM_FORM_VALIDATE_G_ATTRS_MODE  1
#define VDP_AIM_FORM_VALIDATE_G_ATTRS_VALUE 2

#define VDP_AIM_FORM_VALIDATE_B_STORE_ATTRS   14
#define VDP_AIM_FORM_VALIDATE_B_COMPUTE_ATTRS 26
#define VDP_AIM_FORM_VALIDATE_B_SAVE_XML_FILE 16

#define VDP_AIM_FORM_VALIDATE_T_SHOW_PROBS    33

static void fillList    ();
static void fillListRow (domNode objNode, int *row);
static void fillAttrList(domNode objNode);

static void notifyList();
static void notifyComputeAttrs();
static void notifyStoreAttrs();

static domNode getTplNode(domNode objNode);
static domNode copyNode  (domNode objNode);

/* ----------------------------------------------
 * get the template node for the object node
 */
static domNode getTplNode(domNode objNode)
{
  domNode tplNode = NULL;
  char asirClassName[32];

  if (objNode == NULL) goto wrapup;

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);
  tplNode = VDPaimGetOccTemplateNode(asirClassName);
 
wrapup:
  return tplNode;
}
/* ----------------------------------------------
 * Pull the object id in integer format
 */
static VDobjid getObjid(domNode objNode)
{
  char buf[32];
  VDobjid objid = 0;

  if (objNode == NULL) goto wrapup;

  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,buf);
  objid = atoi(buf);
 
wrapup:
  return objid;
}

/* ----------------------------------------------
 * Get the row that holds the object
 */
static int getObjRow(int objid)
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_LIST;

  int numRows,row;
  char buf[32];
 
  /* Select the row */
  VDfrmGetNumRows(form,gadget,&numRows,NULL,NULL);
  for(row = 0; row < numRows; row++)
  {
    VDfrmGetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_OBJID,buf);
    if (objid == atoi(buf)) return row;
  }
  return -1;
}

/* ----------------------------------------------
 * Store the editable attributes in the object
 */
static void notifyStoreAttrs()
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_ATTRS;
  int i,row;
  int changedFlag;

  domNode objNode,objAttrNode;
  domNode cpyNode,cpyAttrNode;
  domNode tplNode,tplAttrNode;

  char cpyBuf[128];
  char objBuf[128];
  char name   [32];
  char edit   [32];

  char comp_tagx[128];

  TGRid objID;

  /* Make sure have a active node */
  cpyNode = s->cpyNode;          if (cpyNode == NULL) goto wrapup;
  objNode = s->objNode;          if (objNode == NULL) goto wrapup;
  tplNode = getTplNode(cpyNode); if (tplNode == NULL) goto wrapup;

  /* Build the objID */
  VDosGetCurrentOS(&objID.osnum);
  objID.objid = getObjid(cpyNode);

  /* Do the compute, this fills cpyNode with the latest values */
  notifyComputeAttrs();

  /* Cycle through and update the object */
  changedFlag = 0;
  for(i = 0; tplAttrNode = domGetNthChildNode(tplNode,i); i++)
  {
    domGetNodeProp(tplAttrNode,"edit",edit);
    if (*edit == '1')
    {
      domGetNodeProp(tplAttrNode,"name",name);   
      domGetTextAttrNodeValue(cpyNode,name,cpyBuf);
      domGetTextAttrNodeValue(objNode,name,objBuf);
      if (strcmp(cpyBuf,objBuf))
      {
        VDobjSetUserTextAttr(NULL,&objID,name,cpyBuf);
        changedFlag = 1;
      }
    }
  }
  /* Skip the rest if no changes */
  if (changedFlag == 0)
  {
    VDfrmSetStatus(form,10,"No attributes were changed");
    goto wrapup;
  }
  /* Tag Version Changed */
  VDctxGetCompTagx(&objID,comp_tagx);
  domSetTextAttrNodeValue(cpyNode,VDP_XML_ATTR_COMP_TAGX,comp_tagx);
 
  /* Move all changed and computed attributes to objNode */
  for(i = 0; cpyAttrNode = domGetNthChildNode(cpyNode,i); i++)
  {
    domGetNodeProp(cpyAttrNode,"name",   name);   
    domGetNodeProp(cpyAttrNode,"value",  cpyBuf);   
    domSetTextAttrNodeValue(objNode,name,cpyBuf);
  }

  /* Update the main row */
  row = getObjRow(objID.objid); if (row < 0) goto wrapup;
  fillListRow(objNode,&row); row--;

  /* Make it active */
  gadget = VDP_AIM_FORM_VALIDATE_G_LIST;
  for(i = 0; i < VDP_AIM_FORM_VALIDATE_G_LIST_MAX; i++)
  {
    VDfrmSetSelect(form,gadget,row,i,1);
  }
  VDfrmSetActiveRow(form,gadget,row,1);
  VDfrmShowRow     (form,gadget,row);
  notifyList();

  /* Done */
  VDfrmSetStatus(form,10,"Saved Attributes");
   
wrapup:
  return;
}

/* ----------------------------------------------
 * The compute button was pressed
 */
static void notifyComputeAttrs()
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_ATTRS;
  int numRows,i;

  char name [32];
  char value[128];
  char mode [4];

  domNode cpyNode;

  /* Make sure have a active node */
  cpyNode = s->cpyNode;
  if (cpyNode == NULL) goto wrapup;

  /* Xfer all the editable attributes */
  VDfrmGetNumRows(form,gadget,&numRows,NULL,NULL);
  if (numRows == 0) goto wrapup;
  for(i = 0; i < numRows; i++)
  {
    VDfrmGetfText(form,gadget,i,VDP_AIM_FORM_VALIDATE_G_ATTRS_NAME, name);
    VDfrmGetfText(form,gadget,i,VDP_AIM_FORM_VALIDATE_G_ATTRS_VALUE,value);
    VDfrmGetfText(form,gadget,i,VDP_AIM_FORM_VALIDATE_G_ATTRS_MODE, mode);
    if (*mode == 'E')
    {
      domSetTextAttrNodeValue(cpyNode,name,value);
    }
  }

  /* Specific computes */
  VDPaimComputeSirTagNum(cpyNode);
  VDPaimComputeLocation (cpyNode);

  /* And feed the results back */
  fillAttrList(cpyNode);
  VDfrmSetStatus(form,10,"Computed Attributes");
wrapup:
  return;
}

/* ----------------------------------------------
 * Little helper for filling in attribute value pair
 */
static void addAttr(domNode objNode, domNode tplAttrNode, int *row)
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_ATTRS;

  char name [32];
  char value[128];
  char ignore[32];
  char edit[32];

  char mode[2];

  /* See if it should be ignored */
  domGetNodeProp(tplAttrNode,"ignore",ignore);
  if (*ignore == '1') goto wrapup;

  /* See if it can be edited */
  domGetNodeProp(tplAttrNode,"edit",edit);
  if (*edit == '1') strcpy(mode,"E");
  else              strcpy(mode,"");

  /* Grab the name */
  domGetNodeProp(tplAttrNode,"name",name);

  /* The value */
  domGetTextAttrNodeValue(objNode,name,value);

  /* Display */
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_ATTRS_NAME, name);
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_ATTRS_VALUE,value);
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_ATTRS_MODE, mode);

  *row = *row + 1;

wrapup:
  return;
}

/* ----------------------------------------------
 * Make a copy of the current node
 */
static domNode copyNode(domNode objNode)
{
  domNode cpyNode = NULL;
  domNode attrNode;
  char name [128];
  char value[128];

  int i;

  if (objNode == NULL) goto wrapup;

  cpyNode = domCreateDoc(VDP_XML_NODE_ISDP_POST_OBJECT);

  for(i = 0; attrNode = domGetNthChildNode(objNode,i); i++)
  {
    domGetNodeProp(attrNode,"name", name);
    domGetNodeProp(attrNode,"value",value);

    domCreateTextAttrNode(cpyNode,name,value);

  }

wrapup:
  return cpyNode;
}

/* ----------------------------------------------
 * Fills the attribute list
 */
static void fillAttrList(domNode objNode)
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_ATTRS;
  int row;
  int i;

  char asirClassName[128];

  domNode tplNode;
  domNode tplAttrNode;

  /* Init */
  VDfrmSetNumRows(form,gadget,0);
  if (objNode == NULL) goto wrapup;

  /* Need the tpl node */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);
  tplNode = VDPaimGetOccTemplateNode(asirClassName);
  if (tplNode == NULL)
  {
    VDfrmSetStatus(form,10,"Unable to load occurence template information");
    goto wrapup;
  }

  /* Copy the data down */
  row = 0;
  for(i = 0; tplAttrNode = domGetNthChildNode(tplNode,i); i++)
  {
    addAttr(objNode,tplAttrNode,&row);
  }

wrapup:
  return;
}

/* ----------------------------------------------
 * Object was selected in the list
 */
static void notifyList()
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_LIST;

  IGRint row,sel;
  enum GRdpmode mode;

  TGRid objID;

  IGRchar buf  [128];
  IGRchar objid[128];
  IGRchar asirClassName[128];
  IGRchar asirStatus   [128];
  IGRchar isdpClassName[128];
  IGRchar cage[32];
  IGRchar mino[32];

  IGRint i,flag;
  domNode objNode;
  domNode tplNode;
  domNode tplAttrNode;

  /* Arg check */
  if (form == NULL) goto wrapup;

  /* Get the row */
  VDfrmGetActiveRow(form,gadget,&row,NULL);
  if (row < 0) goto wrapup;

  /* Just to make Jack Happy */
  VDctxEraseHilite();

  /* Is it selected */
  VDfrmGetSelect(form,gadget,row,0,&sel);
  if (sel == 0) mode = GRheo;
  else          mode = GRhdo;

  /* Get the object */
  VDfrmGetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_OBJID,buf);
  objID.objid = atoi(buf);
  if (objID.objid <= 0) goto wrapup;
  VDosGetCurrentOS(&objID.osnum);
 
  /* Hilite unless deleted */
  VDfrmGetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_STATUS,asirStatus);
  if (*asirStatus != 'D')
  {
    VDctxDisplayNode(&objID,mode,0);
  }

  /* Reset Attribute List */
  VDfrmSetNumRows(form,VDP_AIM_FORM_VALIDATE_G_ATTRS,0);

  /* get rid of any copies */
  if (s->cpyNode) 
  {
    domFreeDoc(s->cpyNode);
    s->cpyNode = NULL;
  }

  /* Find the node */
  flag = 1;
  for(i = 0;(flag) && 
            (objNode = domGetNthChildNode(s->postObjectsNode,i)); 
      i++)
  {
    domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,buf);
    if (objID.objid == atoi(buf)) flag = 0;
  }
  s->objNode = objNode;
  if (objNode == NULL) goto wrapup;
  s->cpyNode = copyNode(objNode);

  fillAttrList(s->cpyNode);

wrapup:
  return;
}
/* ----------------------------------------------
 * Build a little message flagging any problems
 */
static void getListNotes(domNode objNode, char *notes)
{
  domNode tplNode;
  domNode tplAttrNode;

  int  sts;
  int  i;
  char asirClassName[32];
  char name[32];
  char value[128];
  char required[32];
  char compt_num[128];

  char size[128],*p;
  int  sizex;

  /* Init */
  *notes = 0;

  /* get the template */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);
  tplNode = VDPaimGetOccTemplateNode(asirClassName);
  if (tplNode == NULL)
  {
    strcpy(notes,"NO TEMPLATE NODE");
    goto wrapup;
  }

  /* Cycle through and check for missing */
  for(i = 0; tplAttrNode = domGetNthChildNode(tplNode,i); i++)
  {
    domGetNodeProp(tplAttrNode,"required",required);
    if (*required == '1')
    {
      domGetNodeProp(tplAttrNode,"name",name);
      domGetTextAttrNodeValue(objNode,name,value);
      if (*value == 0)
      {
        if (*notes == 0) strcpy(notes,"MISSING");
        strcat(notes," ");
        strcat(notes,name);
      }
    }
  }
  /* Cycle through and check for size problems */
  for(i = 0; tplAttrNode = domGetNthChildNode(tplNode,i); i++)
  {
    domGetNodeProp(tplAttrNode,"size",size);
    sizex = atoi(size);
    domGetNodeProp(tplAttrNode,"name",name);
    domGetTextAttrNodeValue(objNode,name,value);
    if (strlen(value) > sizex)
    {
      if (*notes) strcat(notes," ");
      p = notes + strlen(notes);
      sprintf(p,"%s EXCEEDS MAX SIZE OF %d",name,sizex);
    }
  }
  /* Validate compartment */
  sts = VDPaimValidateComptNumber(objNode);
  if (!(sts & 1))
  {
    if (*notes) strcat(notes," ");
    strcat(notes,"INVALID");
    strcat(notes," COMPT_NUMBER");
  }
      
wrapup:
  return;
}

/* ----------------------------------------------
 * Get the asir posting status for the object
 */
static void getAsirStatus(domNode objNode, char *status)
{
  domNode plcsNode = s->asirPlacementsNode;
  domNode plcNode;
  int i;

  TVDtag  objTag,  plcTag;
  int     objObjid,plcObjid;

  /* Init */
  *status = 0;

  /* Skip if no placements */
  if (plcsNode == NULL) goto wrapup;

  /* Need tag information */
  VDPaimGetNodeTag(objNode,&objTag);
  if (objTag.num < 1) goto wrapup;

  domGetIntAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,&objObjid);

  /* Cycle through */
  for(i = 0; plcNode = domGetNthChildNode(plcsNode,i); i++)
  {
    VDPaimGetNodeTag(plcNode,&plcTag);
    if (objTag.num == plcTag.num)
    {
      if (objTag.ver == plcTag.ver) strcpy(status,"P");
      else                          strcpy(status,"M");
      goto wrapup;
    }

    /* Try to stay compatible with older postings */
    domGetIntAttrNodeValue(plcNode,VDP_XML_ATTR_OBJID,&plcObjid);
    if ((objObjid == plcObjid) && (plcTag.num == 0) && (plcObjid != 0))
    {
      strcpy(status,"M");
      goto wrapup;
    }
  }
  strcpy(status,"N");

wrapup:
  return;
}

/* ----------------------------------------------
 * Fill in one row in the list of objects
 */
static void fillListRow(domNode objNode,int *row)
{
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_LIST;
  int showProbsOnly;

  IGRchar objid[32];
  IGRchar isdpClassName[32];
  IGRchar asirClassName[32];
  IGRchar cage [32];
  IGRchar mino [32];
  IGRchar compt[32];
  IGRchar asirTagNum[32];
  IGRchar notes[512];
  IGRchar asirStatus[32];

  /* Make sure actually want to display */
  getListNotes(objNode,notes);

  VDfrmGetState(form,VDP_AIM_FORM_VALIDATE_T_SHOW_PROBS,&showProbsOnly);
  if (!showProbsOnly && *notes == 0) goto wrapup;

  /* Cycle through */
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,          objid);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_ISDP_CLASS_NAME,isdpClassName);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_CAGE,           cage);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_MINO,           mino);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_COMPT_NUMBER,   compt);
  domGetTextAttrNodeValue(objNode,VDP_XML_ATTR_SR_TAG_NUM,     asirTagNum);

  getAsirStatus(objNode,asirStatus);

  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_LIST_STATUS, asirStatus);
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_LIST_OBJID,  objid);
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_LIST_CLASS,  asirClassName);
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_LIST_TAG_NUM,asirTagNum);
  VDfrmSetfText(form,gadget,*row,VDP_AIM_FORM_VALIDATE_G_LIST_NOTES,  notes);
  *row = *row + 1;

wrapup:
  return;
}
/* ----------------------------------------------
 * Fill in the list of objects
 */
static void fillList()
{
  Form form  = s->form;
  int  gadget = VDP_AIM_FORM_VALIDATE_G_LIST;

  int i,j,row,flag;
  domNode objsNode = s->postObjectsNode;
  domNode objNode;

  domNode plcsNode;
  domNode plcNode;

  char objid[32];
  char asirClassName[32];

  TVDtag objTag,  plcTag;
  int    objObjid,plcObjid;

  /* Arg check */
  if (form == NULL) goto wrapup;
  VDfrmSetNumRows(form,gadget,0);
  if (objsNode == NULL) goto wrapup;

  /* Cycle through */
  row=0;
  for(i = 0; objNode = domGetNthChildNode(objsNode,i); i++)
  {
    fillListRow(objNode,&row);
  }

  /* --------------------------------------------
   * Fill in any deleted items still in SIR
   */
  plcsNode = s->asirPlacementsNode;
  if (plcsNode == NULL) goto wrapup;
  for(i = 0; plcNode = domGetNthChildNode(plcsNode,i); i++)
  {
    VDPaimGetNodeTag(plcNode,&plcTag);
    domGetIntAttrNodeValue(plcNode,VDP_XML_ATTR_OBJID,&plcObjid);

    flag = 1;

    for(j = 0;  objNode = domGetNthChildNode(objsNode,j); j++)
    {
      VDPaimGetNodeTag(objNode,&objTag);
      if (plcTag.num == objTag.num) flag = 0;

      domGetIntAttrNodeValue(objNode,VDP_XML_ATTR_OBJID,&objObjid);
      if ((plcObjid == objObjid) && (plcTag.num == 0) && (plcObjid != 0))
      {
        flag = 0;
      }
    }
    if (flag)
    {
      /* It was deleted */
      domGetTextAttrNodeValue(plcNode,VDP_XML_ATTR_OBJID,          objid);
      domGetTextAttrNodeValue(plcNode,VDP_XML_ATTR_ASIR_CLASS_NAME,asirClassName);

      VDfrmSetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_STATUS, "D");
      VDfrmSetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_OBJID,  objid);
      VDfrmSetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_CLASS,  asirClassName);
      VDfrmSetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_TAG_NUM,"");
      VDfrmSetfText(form,gadget,row,VDP_AIM_FORM_VALIDATE_G_LIST_NOTES,  "IN SIR, DELETED FROM ISDP");
      row++;
    }
  }
wrapup:
  return;
}

/* ----------------------------------------------
 * Objects or object were located
 */
IGRstat VDPaimCmdLocateValidate(TGRobj_env *objOE)
{  
  Form form  = s->form;
  int gadget = VDP_AIM_FORM_VALIDATE_G_LIST;

  IGRint row,sel,i;
  IGRint numRows;

  VDobjid objid;
  VDosnum osnum;
  char    buf[128];

  /* Make sure it's in the current space */
  VDosGetCurrentOS(&osnum);
  if (objOE->obj_id.osnum != osnum) goto wrapup;

  /* Check the id */
  objid = objOE->obj_id.objid;
  if (objid == NULL_OBJID) goto wrapup;

  /* Select the row */
  row = getObjRow(objid);
  if (row < 0) goto wrapup;

  /* Make it active */
  for(i = 0; i < VDP_AIM_FORM_VALIDATE_G_LIST_MAX; i++)
  {
    VDfrmSetSelect(form,gadget,row,i,1);
  }
  VDfrmSetActiveRow(form,gadget,row,1);
  VDfrmShowRow     (form,gadget,row);

  notifyList();

wrapup:
  return 1;
}

/* -----------------------------------------------
 * Notification routine
 */
IGRint VDPaimCmdNotifyValidate(IGRint    f_label,
			       IGRint    gadget,
			       IGRdouble value,
			       Form      form)
{
  VDASSERT_FN("VDPaimCmdNotifyValidate");
  IGRstat retFlag = 0;
  IGRchar buf[128];
  TGRid   doomID;

  /* Internal data must be set */
  VDASSERTW(s);
  VDASSERTW(s->form);

  /* Process it */
  switch(gadget) 
  {

    case FI_CANCEL:

      /* Clean up */
      VDfrmDeleteForm(s->form,0);
      s->form = NULL;
      s->loop = 0;

      /* Break out of locate loop */
      VDputResponse(RESET);
      break;

    case VDP_AIM_FORM_VALIDATE_G_LIST:
      notifyList();
      break;

    case VDP_AIM_FORM_VALIDATE_B_COMPUTE_ATTRS:
      notifyComputeAttrs();
      break;

    case VDP_AIM_FORM_VALIDATE_B_STORE_ATTRS:
      notifyStoreAttrs();
      break;

    case VDP_AIM_FORM_VALIDATE_T_SHOW_PROBS:
      fillList();
      break;

    case VDP_AIM_FORM_VALIDATE_B_SAVE_XML_FILE:
      domSaveDocToFile(s->fileInfoNode,s->xmlFileName);
      sprintf(buf,"SAVED %s",s->xmlFileName);
      UI_status(buf);

      //VDPaimCreateDoomFromTree(s->fileInfoNode,&doomID);

      // VDPaimUpdatePostTimestamp(s->fileInfoNode,0,1);

      break;
    
  }
  
  /* Done */
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the whole thing going
 *
 */
IGRstat VDPaimCmdInitValidate(TVDtestTestInfo *testInfo)
{
  VDASSERT_FN("VDPaimCmdInitValidate");
  IGRstat retFlag = 0;
  IGRstat sts;

  VDosnum osnum;
  domNode fileInfoNode;

  /* Should not be called recursivily */
  VDASSERTW(s == NULL);

  /* Clear screen */
  VDctxEraseHilite();

  /* Need a pdm login */
  if (!VDrisIsSchemaOpen())
  {
    UI_status("Need to log into PDM first");
    goto wrapup;
  }
  /* Clear caches */
  VDPaimDeleteItemCache();
  VDPaimDeleteFSIExpressions();

  /* Setup structure */
  s = calloc(1,sizeof(Ts_info));
  VDASSERTW(s);

  /* Files */
  sprintf(s->calFileName,"validate.cal");
  sprintf(s->logFileName,"validate.log");
  
  /* Create the form */
  sts = VDfrmNewForm(VDP_AIM_FORM_VALIDATE_NUM,
		     VDP_AIM_FORM_VALIDATE_NAME,
		     VDPaimCmdNotifyValidate,1,&s->form);
  VDASSERTW(sts);
  VDASSERTW(s->form);

  /* Display it */
  VDfrmDisplayForm(s->form,1,NULL);
  VDfrmSetStatus(s->form,10,"Getting posting information...");

  /* Reconnect DAD if need to */
  VDPaimReconnectDAD(NULL);

  /* Want the file info */
  VDosGetCurrentOS(&osnum);
  s->fileInfoNode = fileInfoNode = VDPaimGetFileInfo(osnum);

  domCreateNode(fileInfoNode,VDP_XML_NODE_ASIR_TEMPLATES);

  s->postObjectsNode =
    VDPaimGetPostObjectsData(osnum,fileInfoNode,fileInfoNode);

  /* --------------------------------------------
   * Build these if connected 
   */
  if(IsPmeEnabled())
  {
    VDPaimCreateAimInfoNode(osnum,fileInfoNode);

    s->asirPlacementsNode =
      VDPaimCreateAimPlacementsNode(osnum,fileInfoNode);
  }

  /* Generate the xml file name */
  VDosGetFileName(osnum,s->xmlFileName);
  strcat(s->xmlFileName,".sir_val.xml");

  /* Fill in the list gadget */
  VDfrmSetStatus(s->form,10,"");
  fillList();

  /* Done */
  retFlag = 1;

 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Loop on events
 * Usually called from a test routine
 * really need to add prompts and command name here
 */
void VDPaimCmdLoopValidate()
{
  VDASSERT_FN("VDPaimCmdLoopValidate");
  IGRstat sts;

  XEvent event;
  
  /* Should not be called recursivily */
  VDASSERTW(s && s->form);
  
  /* Loop until form told to break out */
  s->loop = 1;
  while(s->loop) {
    XNextEvent(_FI_display, &event);
    FI_process_event(&event, 0);
  }
  
 wrapup:
  return;
}


/* -----------------------------------------------
 * Shuts down
 * Usually called from the ppl command object on
 * something like clear stack.
 */
void VDPaimCmdKillValidate()
{
  VDASSERT_FN("VDaimCmdKillValidate");
  
  /* Verify running */
  if (s == NULL) goto wrapup;

  /* Free the form if necessary */
  if (s->form) VDfrmDeleteForm(s->form,1);

  /* Free the working objects */
  if (s->fileInfoNode) 
  {
    domFreeDoc(s->fileInfoNode);
  }
  if (s->cpyNode) 
  {
    domFreeDoc(s->cpyNode);
  }

  /* Done */
  free(s); s = NULL;
  
 wrapup:
  return;  
}


