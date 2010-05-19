/* $Id: VDatAttr.I,v 1.6 2001/10/19 18:29:20 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatAttr.I
 *
 * Description: Attribute Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatAttr.I,v $
 *      Revision 1.6  2001/10/19 18:29:20  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/22 21:45:42  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/22 20:51:00  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/12 20:30:18  paul_noel
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/03/08 16:05:46  paul_noel
 *      TR 4419 checkin of notices
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.5  2000/02/23  13:56:40  pinnacle
# ah
#
# Revision 1.4  1998/11/07  14:06:32  pinnacle
# ah
#
# Revision 1.3  1998/10/25  12:03:50  pinnacle
# ah
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 02/23/00  ah      Problem with showing doubles in form
 *                   Scanning for control codes in the text strings
 * 03/22/01  ah      More scans for invalid attribute values
 *                   Using VDatFldValidateTxt
 ***************************************************************************/

class implementation VDatBase;

#include "VDatCmd.h"

#define VDAT_FORM_ATTR_L_ATTRS  12
#define VDAT_FORM_ATTR_L_VALUES 13
#define VDAT_FORM_ATTR_G_VALUES 19

#define VDAT_FORM_ATTR_G_NODE     21
#define VDAT_FORM_ATTR_T_ATTRS    20
#define VDAT_FORM_ATTR_T_ATTR_SEL 18

#define VDAT_FORM_ATTR_B_UPDATE     14
#define VDAT_FORM_ATTR_B_UPDATE_SEL 15
#define VDAT_FORM_ATTR_B_UPDATE_BRA 16

#define VDAT_FORM_ATTR_T_LOCK       17
#define VDAT_FORM_ATTR_B_SUMMARIZE  23

IGRstat VDatCMDAttrActivateForm(TVDatFrmList *fl);
IGRstat VDatCMDAttrActivateSet (TVDatFrmList *fl);
IGRstat VDatCMDAttrActivateLeaf(TVDatFrmList *fl);
IGRstat VDatCMDAttrActivateNode(TVDatFrmList *fl);

IGRstat VDatCMDAttrNotifyForm     (TVDatFrmList *fl);
IGRstat VDatCMDAttrNotifyAttrs    (TVDatFrmList *fl);
IGRstat VDatCMDAttrNotifyUpdate   (TVDatFrmList *fl, TGRid *nodeID);
IGRstat VDatCMDAttrNotifyUpdateSel(TVDatFrmList *fl);

IGRstat VDatCMDAttrNotifyValues(TVDatFrmList *fl);
IGRstat VDatCMDAttrSetValueList(TVDatFrmList *fl,IGRchar *atrName);

IGRstat VDatCMDAttrGetActiveNode(TVDatFrmList *fl, TGRid *nodeID);

IGRstat VDatCMDAttrNotifySummarize(TVDatFrmList *fl);

/* ----------------------------------------
 * Pulls active node from attr form
 */
IGRstat VDatCMDAttrGetActiveNode(TVDatFrmList *fl, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  Form    form = fl->attr;

  // Init
  nodeID->objid = NULL_OBJID;

  VDahFrmGetGRid(form,VDAT_FORM_ATTR_G_NODE,0,1,nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Summarizes all nodes downstream
 */
IGRstar VDatCMDAttrNotifySummarize(TVDatFrmList *fl)
{
  IGRstat retFlag = 1;
  
  Form    form = fl->attr;

  TVDvlaID leafVLA;

  TGRid    leafID;
  TGRid    nodeID;
  
  IGRint   i;

  // Init
  VDvlaID_Construct(&leafVLA);

  // Get the active node
  VDatCMDAttrGetActiveNode(fl, &nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Get all leafs under node
  VDatGetLeafsVLA(&nodeID,&leafVLA);
  
  // Cycle through
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {
    VDatSummarizeLeaf(&leafID);
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  VDvlaID_Delete(&leafVLA);
  VIg_set_text(form,10,"Summarize Complete");
  return retFlag;
}
  
/* ---------------------------------------------------
 * Update all selected nodes/leafs
 */
IGRstat VDatCMDAttrNotifyUpdateSel(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->attr;

  TVDvlaID leafVLA;
  TGRid    leafID;
  IGRint   i;

  // Init
  VDvlaID_Construct(&leafVLA);

  // Get selected leaves
  VDatCMDLeafGetSelectedLeafs(fl,&leafVLA);
  VDatCMDTreeGetSelectedRows (fl,&leafVLA);
  for(i = 0; VDvlaID_GetAt(&leafVLA,&leafID,i); i++) {
    VDatCMDAttrNotifyUpdate(fl,&leafID);
  }

//wrapup:
  VDvlaID_Delete(&leafVLA);
  VIg_set_text(form,10,"Update Complete");
  return retFlag;
}

/* -----------------------------------------------
 * User picked a row in values list
 */
IGRstat VDatCMDAttrNotifyValues(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->attr;
  IGRint  pos;

  struct {
    IGRint  gadget;
    IGRint  row;
    IGRchar txt[1024];
    IGRchar name[128];
  } val;

  struct {
    IGRint  gadget;
    IGRint  row,rows;
    IGRchar name[128];
  } attr;

  // Get the selected value
  val.row = -1;
  val.gadget = VDAT_FORM_ATTR_L_VALUES;
  VIfld_get_active_row(form,val.gadget,&val.row,&pos);

  // Desc is in second column
  VDahFrmGetTextRC(form,val.gadget,val.row,1,val.txt);
  VIg_set_text(form,10,val.txt);

  // Xfer the value
  VDahFrmGetTextRC(form,val.gadget, val.row,0,val.txt);
  *val.name = 0;
  VIg_get_text(form,VDAT_FORM_ATTR_G_VALUES,val.name);

  // Go through attribute list
  attr.gadget = VDAT_FORM_ATTR_L_ATTRS;
  attr.rows   = -1;
  VIfld_get_num_rows(form,attr.gadget,&attr.rows);

  for(attr.row = 0; attr.row < attr.rows; attr.row++) {

    VDahFrmGetTextRC(form,attr.gadget,attr.row,0,attr.name);
    if (strcmp(val.name,attr.name) == 0) {
      VDahFrmSetTextRC(form,attr.gadget,attr.row,2,val.txt);      
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Update list of values
 */
IGRstat VDatCMDAttrSetValueList(TVDatFrmList *fl,IGRchar *attrName)
{
  IGRstat retFlag = 1;

  Form    form = fl->attr;
  IGRint  gadget = VDAT_FORM_ATTR_L_VALUES;
  IGRint  row;

  TGRid nodeID;
  TGRid attrID;

  TVDatFld  flds[VDAT_FLD_MAX];
  TVDatFld *fld;
  IGRint    cnt,i;

  // Clear
  VIfld_set_num_rows(form,gadget,0);
  VIg_set_text(form,VDAT_FORM_ATTR_G_VALUES,attrName);
  VIg_set_text(form,10,"");

  // Get the active node
  VDatCMDAttrGetActiveNode(fl, &nodeID);
  if (nodeID.objid == NULL_OBJID) goto wrapup;

  // Find the attribute object
  VDatRDBGetAttrByName(&nodeID,attrName,&attrID);
  if (attrID.objid == NULL_OBJID) goto wrapup;

  // Grab the attributes
  VDatFldGetAllAttrs(&attrID,flds,&cnt);
  row = 0;
  for(i = 0; i < cnt; i++) {

    fld = &flds[i];

    if (fld->flag == 1) {

      // Store the value
      VDahFrmSetTextRC(form,gadget,row,0,fld->valueTxt);

      // Desc follows
      i++;
      VDahFrmSetTextRC(form,gadget,row,1,flds[i].valueTxt);
      
      row++;
    }

    // Master attribute description in status field
    if (fld->index == 3) {
      VIg_set_text(form,10,fld->valueTxt);
    }
  }

wrapup:
  VIg_set_text(form,10,"Update Branch Complete");
  return retFlag;
}

/* ---------------------------------------------
 * User picked an attibute name
 */
IGRstat VDatCMDAttrNotifyAttrs(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form = fl->attr;
  IGRint  gadget = VDAT_FORM_ATTR_L_ATTRS;
  IGRint  row,pos;
  IGRchar attrName[128];

  // Get the active row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);

  // Get the attribute name
  VDahFrmGetTextRC(form,gadget,row,0,attrName);
  if (*attrName == 0) goto wrapup;

  // Fill the list
  VDatCMDAttrSetValueList(fl,attrName);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Update one attribute
 * 22 Feb 2000 - Add checks against invalid data
 */
IGRstat VDatCMDAttrUpdateAttr(
  TVDatFld *orgFLDs,
  IGRint    orgCNT,
  IGRchar  *atrName,
  IGRchar  *atrValue,
  TVDatFld *newFLDs,
  IGRint   *newCNT
)
{
  IGRstat retFlag = 0;
  IGRint  i;
  IGRint  valueInt;
  IGRdouble valueDbl;
  
  // Find original entry
  for(i = 0; (i < orgCNT) && (strcmp(atrName,orgFLDs[i].name)); i++);
  if (i == orgCNT) goto wrapup;

  // Add some checks to guard against bad data
  VDatFldValidateTxt(atrValue);
    
  // Only update changed values
  switch(orgFLDs[i].type) {

  case VDAT_FLD_TYPE_CHAR: {
    if (strcmp(atrValue, orgFLDs[i].valueTxt) == 0) goto wrapup;

    newFLDs[*newCNT] = orgFLDs[i];
    strcpy(newFLDs[*newCNT].valueTxt,atrValue);
    *newCNT = *newCNT + 1;

    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FLD_TYPE_DOUBLE: {
    valueDbl = atof(atrValue);
    if (fabs(valueDbl -  orgFLDs[i].valueDbl) < 0.001) goto wrapup;

    newFLDs[*newCNT] = orgFLDs[i];
    newFLDs[*newCNT].valueDbl = valueDbl;
    *newCNT = *newCNT + 1;

    retFlag = 1;
    goto wrapup;

  }

  case VDAT_FLD_TYPE_INT: {
    valueInt = atoi(atrValue);
    if (valueInt == orgFLDs[i].valueInt) goto wrapup;

    newFLDs[*newCNT] = orgFLDs[i];
    newFLDs[*newCNT].valueInt = valueInt;
    *newCNT = *newCNT + 1;

    retFlag = 1;
    goto wrapup;

  }

  } // switch

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Update current attribute
 */
IGRstat VDatCMDAttrNotifyUpdate(TVDatFrmList *fl, TGRid *a_nodeID)
{
  IGRstat retFlag = 0;
  TGRid   nodeID;

  Form    form = fl->attr;
  IGRint  gadget = VDAT_FORM_ATTR_L_ATTRS;
  IGRint  row,rows;

  IGRchar atrName  [128];
  IGRchar atrValue[1024];

  TVDatFld orgFLDs[VDAT_FLD_MAX];
  TVDatFld newFLDs[VDAT_FLD_MAX];
  IGRint   orgCNT;
  IGRint   newCNT;

  IGRint   state,sel;

  // Get the node to update
  if (a_nodeID != NULL) nodeID = *a_nodeID;
  else  VDahFrmGetGRid(form,VDAT_FORM_ATTR_G_NODE,0,1,&nodeID);
  if ((nodeID.objid == NULL_OBJID)) goto wrapup;

  // Get the original attributes
  VDatFldGetAllAttrs(&nodeID,orgFLDs,&orgCNT);
  newCNT = 0;

  // All or only selected attributes
  state = 0;
  VIg_get_state(form,VDAT_FORM_ATTR_T_ATTR_SEL,&state);

  // Cycle through form and match attributes
  rows = -1;
  VIfld_get_num_rows(form,gadget,&rows);
  for(row = 0; row < rows; row++) {

    sel = 0;
    VIfld_get_select(form,gadget,row,0,&sel);
    if ((state == 0) || (sel == 1)) {

      VDahFrmGetTextRC(form,gadget,row,0,atrName);
      VDahFrmGetTextRC(form,gadget,row,2,atrValue);
    
      // Update it
      VDatCMDAttrUpdateAttr(orgFLDs,orgCNT,atrName,atrValue,newFLDs,&newCNT);
    }
  }
  // Update then
  VDatFldUpdAllAttrs(&nodeID,newFLDs,newCNT);

  retFlag = 1;
wrapup:
  VIg_set_text(form,10,"Update One Complete");
  return retFlag;
}

/* ------------------------------------------------
 * Fills in one attribute
 * 22 Feb 2000 - Format double values better, match xml output
 */
IGRstat VDatFormFillAttr(
  Form     form, 
  IGRint   gadget, 
  TVDatFld *fld,
  IGRint   flag, 
  IGRint   *row
)
{
  IGRstat retFlag = 0;

  IGRchar value[1024];
  IGRchar type [128];
  IGRchar *p;
  
  // Special case for comp_path
  if (!strcmp(fld->name,VDAT_ATTR_COMP_PATH)) {
    VIg_set_text(form,10,fld->valueTxt);
    goto wrapup;
  }
  
  // Use the rest
  if (flag == 0) goto use_it;

  // Filter
  if (strncmp(fld->name,"u_",2) == 0)      goto use_it;
  if (strcmp (fld->name,"node_desc") == 0) goto use_it;
  
  goto wrapup;

use_it:
  switch(fld->type) {

  case VDAT_FLD_TYPE_CHAR: {
    VDatFldValidateTxt(fld->valueTxt);
    sprintf(value,"%s",fld->valueTxt);
    strcpy (type,"txt");
    break;
  }

  case VDAT_FLD_TYPE_DOUBLE: {

    // Clean up a bit
    sprintf(value,"%f",fld->valueDbl);
    for(p = value + strlen(value) - 1; (p >= value) && (*p == '0'); p--);
    if (p < value) strcpy(value,"0.0");
    else {
      if (*p == '.') strcpy(p,".0");
      else *(p+1) = 0;
    }
    strcpy (type,"dbl");
    break;
  }

  case VDAT_FLD_TYPE_INT: {
    sprintf(value,"%d",fld->valueInt); 
    strcpy (type,"int");
    break;
  }
  } // switch


  // Write to list
  VDatFldValidateTxt(value);
  VDahFrmSetTextRC(form,gadget,*row,0,fld->name);
  VDahFrmSetTextRC(form,gadget,*row,1,type);
  VDahFrmSetTextRC(form,gadget,*row,2,value);
  *row = *row + 1;

  retFlag = 1;
wrapup:
  VIg_set_text(form,10,"");
  return retFlag;
}
  
/* ---------------------------------------------------
 * Fill in the attribute info
 */
IGRstat VDatFormFillAttrs(Form form)
{
  IGRstat retFlag = 0;

  IGRint gadget = VDAT_FORM_ATTR_L_ATTRS;
  IGRint row;

  IGRint   cnt,i,flag;
  TVDatFld flds[VDAT_FLD_MAX];

  TGRid objID;

  IGRint traceFlag = 0;
  
  if (traceFlag) printf(">>> VDatFormFillAttrs\n");
  
  // Clear
  VIfld_set_num_rows(form,gadget,0);

  // Get node/leaf
  VDahFrmGetGRid(form,VDAT_FORM_ATTR_G_NODE,0,1,&objID);
  if ((objID.objid == NULL_OBJID)) goto wrapup;

  // Which attrs to show
  VIg_get_state(form,VDAT_FORM_ATTR_T_ATTRS,&flag);

  // Get the attributes
  cnt = 0;
  row = 0;
  VDatFldGetAllAttrs(&objID,flds,&cnt);

  for(i = 0; i < cnt; i++) {
    VDatFormFillAttr(form,gadget,&flds[i],flag,&row);
  }
  VIg_set_text(form,10,"");
  retFlag = 1;

wrapup:
  if (traceFlag) printf("<<< VDatFormFillAttrs\n");
  return retFlag;
}

/* ---------------------------------------------------
 * Initializes the form with a new active node
 */
IGRstat VDatCMDAttrActivateNode(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  
  TGRid   nodeID;
  Form    form = fl->attr;
  IGRchar nodePath[128];
  IGRint  state;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Ignore if locked
  state = 0;
  VIg_get_state(form,VDAT_FORM_ATTR_T_LOCK,&state);
  if (state != 0) goto wrapup;

  // Get active node
  VDatCMDAllGetActiveNode(fl,&nodeID);

  // Summarize it
  // VDatSummarizeNode(&nodeID);

  // Heading
  *nodePath = 0;
  VDatGetNodePath(&nodeID,nodePath);
  VDahFrmSetTextRC(form,VDAT_FORM_ATTR_G_NODE,0,0, nodePath);
  VDahFrmSetGRid  (form,VDAT_FORM_ATTR_G_NODE,0,1,&nodeID);

  VDatFormFillAttrs(form);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Updates the form if the node attributes may
 * have changed, for example if the node has been
 * summarized
 */
IGRstat VDatCMDAttrUpdateNode(TGRid *a_nodeID)
{
  IGRstat retFlag = 0;
  
  TGRid   nodeID;

  TVDatFrmList *fl;  
  Form          form;

  IGRchar nodePath[128];

  // Make sure form system is active
  fl = (TVDatFrmList *) VDatCMDMgrGetFl();
  if (fl == NULL) goto wrapup;
  form = fl->attr;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Get active node
  VDatCMDAllGetActiveNode(fl,&nodeID);

  // Ignore if not the one to update
  if ((nodeID.objid != a_nodeID->objid) || 
      (nodeID.osnum != a_nodeID->osnum)) goto wrapup;
  
  // Rest is the same as activate, combine later
  *nodePath = 0;
  VDatGetNodePath(&nodeID,nodePath);
  VDahFrmSetTextRC(form,VDAT_FORM_ATTR_G_NODE,0,0, nodePath);
  VDahFrmSetGRid  (form,VDAT_FORM_ATTR_G_NODE,0,1,&nodeID);

  VDatFormFillAttrs(form);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Initializes the form with a new active leaf
 */
IGRstat VDatCMDAttrActivateLeaf(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   leafID;
  Form    form = fl->attr;

  IGRchar nodePath[128];
  IGRint  state;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Ignore if locked
  state = 0;
  VIg_get_state(form,VDAT_FORM_ATTR_T_LOCK,&state);
  if (state != 0) goto wrapup;

  // Fill inactive leaf
  VDatCMDAllGetActiveLeaf(fl,&leafID);
  if (leafID.objid != NULL_OBJID) {

    // If mass props have not been cached, then cache them
    sts = VDatHasSummary(&leafID);

    // printf("Has Summaru %d\n",sts);

    if (!(sts & 1)) {
      VDatSummarizeLeaf(&leafID);
    }
  }

  // Heading
  *nodePath = 0;
  VDatGetDisplayName(&leafID,nodePath);

  VDahFrmSetTextRC(form,VDAT_FORM_ATTR_G_NODE,0,0, nodePath);
  VDahFrmSetGRid  (form,VDAT_FORM_ATTR_G_NODE,0,1,&leafID);
  VIg_set_text(form,10,""); 
  VDatFormFillAttrs(form);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Called when leaf attributes may have changed
 */
IGRstat VDatCMDAttrUpdateLeaf(TGRid *a_leafID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   leafID;

  TVDatFrmList *fl;
  Form    form = NULL;

  IGRchar nodePath[128];

  // Make sure form system is active
  fl = (TVDatFrmList *) VDatCMDMgrGetFl();
  if (fl == NULL) goto wrapup;
  form = fl->attr;

  // Ignore if the form is not active
  if (VDatFormIsActive(form) != 1) goto wrapup;

  // Get active node
  VDatCMDAllGetActiveLeaf(fl,&leafID);

  // Ignore if not the one to update
  if ((leafID.objid != a_leafID->objid) || 
      (leafID.osnum != a_leafID->osnum)) goto wrapup;

  // Heading
  *nodePath = 0;
  VDatGetDisplayName(&leafID,nodePath);

  VDahFrmSetTextRC(form,VDAT_FORM_ATTR_G_NODE,0,0, nodePath);
  VDahFrmSetGRid  (form,VDAT_FORM_ATTR_G_NODE,0,1,&leafID);

  VDatFormFillAttrs(form);

  retFlag = 1;
wrapup:
  if (form) VIg_set_text(form,10,"");
  return retFlag;
}

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDAttrActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  Form    form = fl->attr;

  TGRid   setID;
  IGRchar setName[128];

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set, if none just clear gadgets
  *setName = 0;
  VDatCMDAllGetActiveSet(fl,&setID,setName);

  // Update form
  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);

  // Clears the attributes
  VIfld_set_num_rows(form,VDAT_FORM_ATTR_G_NODE,0);
  VDatFormFillAttrs (form);

  if (VDatIsSetInActiveOS(&setID)) {    
    VIg_enable(form,VDAT_FORM_ATTR_B_UPDATE);
    VIg_enable(form,VDAT_FORM_ATTR_B_UPDATE_SEL);
    VIg_enable(form,VDAT_FORM_ATTR_B_UPDATE_BRA);
  }
  else {
    VIg_disable(form,VDAT_FORM_ATTR_B_UPDATE);
    VIg_disable(form,VDAT_FORM_ATTR_B_UPDATE_SEL);
    VIg_disable(form,VDAT_FORM_ATTR_B_UPDATE_BRA);
  }

  retFlag = 1;
wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine
 */
IGRstat VDatCMDAttrNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form;
  IGRint  gadget;

  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;

  switch(gadget) {

  case VDAT_FORM_ATTR_L_VALUES: {
    retFlag = VDatCMDAttrNotifyValues(fl);
    goto wrapup;
  }

  case VDAT_FORM_ATTR_L_ATTRS: {
    retFlag = VDatCMDAttrNotifyAttrs(fl);
    goto wrapup;
  }

  case VDAT_FORM_ATTR_T_ATTRS: {
    retFlag = VDatFormFillAttrs(fl->attr);
    goto wrapup;
  }
  case VDAT_FORM_ATTR_B_UPDATE: {
    retFlag = VDatCMDAttrNotifyUpdate(fl,NULL);
    goto wrapup;
  }
  case VDAT_FORM_ATTR_B_UPDATE_SEL: {
    retFlag = VDatCMDAttrNotifyUpdateSel(fl);
    goto wrapup;
  }

  case VDAT_FORM_ATTR_B_SUMMARIZE: {
    retFlag = VDatCMDAttrNotifySummarize(fl);
    goto wrapup;
  }

  case FI_CANCEL: {
    VIf_erase(form);
    VDatFormSetActive(form,0);
    retFlag = 1;
    goto wrapup;
  }
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDatCMDAttrActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  // Arg check
  if ((fl == NULL) || (fl->attr == NULL)) goto wrapup;
  form = fl->attr;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);

  VDatCMDAttrActivateSet (fl);
  VDatCMDAttrActivateLeaf(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

