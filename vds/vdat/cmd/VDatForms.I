/* $Id: VDatForms.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatForms.I
 *
 * Description: Utility Forms
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatForms.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/25  15:44:20  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 *
 ***************************************************************************/

class implementation VDatBase;

#include "VDatCmd.h"

/* ------------------------------------------------
 * Routine for storing misc data
 */
IGRstat VDatFormSetStatus(Form form, IGRint status)
{
  IGRint  retFlag = 0;
  IGRchar buf[128];
  IGRint  gadget = VDAT_FORM_ALL_L_MISC;

  // Arg Check
  if (form == NULL) goto wrapup;

  // Data in first one
  sprintf(buf,"%d",status);
  VDahFrmSetTextRC(form,gadget,0,0,buf);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Routine for getting misc data
 */
IGRstat VDatFormGetStatus(Form form, IGRint *status)
{
  IGRint  retFlag = 0;
  IGRchar buf[128];
  IGRint  gadget = VDAT_FORM_ALL_L_MISC;

  // Init
  *status = 0;
  if (form == NULL) goto wrapup;

  *buf = 0;
  VDahFrmGetTextRC(form,gadget,0,0,buf);

  *status = atoi(buf);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Uses misc to make a form active/deactive
 */
IGRstat VDatFormSetActive(Form form, IGRint active)
{
  IGRint  retFlag = 0;
  IGRint  status;

  // Init
  if (form == NULL) goto wrapup;

  VDatFormGetStatus(form,&status);

  if (active) status |= 0x0001;
  else        status &= 0x00FE;

  VDatFormSetStatus(form,active);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Tests if a form is active
 * 1 - Active
 * 0 = Not
 */
IGRstat VDatFormIsActive(Form form)
{
  IGRint  retFlag = 0;
  IGRint  status;

  // Init
  if (form == NULL) goto wrapup;

  VDatFormGetStatus(form,&status);

  if (status && 0x0001) retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Makes the specified row visible
 */
IGRstat VDatFormShowRow(Form form, IGRint gadget, IGRint row)
{
  IGRint numRows,numVisRows,offsetRow;

  // Collect all the data
  numRows = -1;
  VIfld_get_num_rows(form,gadget,&numRows);
  if (numRows < 0) return 0;

  numVisRows = -1;
  FIfld_get_num_vis_rows(form,gadget,&numVisRows);
  if (numVisRows < 0) return 0;

  offsetRow  = -1;
  FIfld_get_row_offset(form,gadget,&offsetRow);
  if (offsetRow < 0) return 0;

  // Need to scroll up
  if (row < offsetRow) {
    FIfld_set_active_row(form,gadget,row,0);
    return 1;
  }

  // No scroll at all
  if (row < (offsetRow + numVisRows)) {
    return 1;
  }
 
  // Need to scroll up
  FIfld_set_active_row(form,gadget,row,numVisRows - 1);
  return 1;
}
  
/* ----------------------------------------
 * Cycle through form, highliting any selected rows
 */
IGRstat VDatFormHiLiteGadget(Form form, IGRint gadget, IGRint col, IGRint col1)
{
  IGRint rowMax,row,sel;
  TGRid  rowID;

  enum GRdpmode mode = GRhhd;

  rowMax = -1;
  VIfld_get_num_rows(form,gadget,&rowMax);

  for(row = 0; row < rowMax; row++) {

    sel = -1;
    VIfld_get_select(form,gadget,row,col,&sel);

    if (sel == 1) {

      VDahFrmGetGRid(form,gadget,row,col1,&rowID);
      VDatDisplayNode(&rowID,mode);
    }
  }

  return 1;
}

/* ----------------------------------------
 * Cycle through form, unselecting rows
 * Don't mess with display?
 */
IGRstat VDatFormUnSelectGadget(Form form, IGRint gadget, IGRint col, IGRint col1)
{
  IGRint rowMax,row,sel;
  TGRid  rowID;

  enum GRdpmode mode = GRhe;

  rowMax = -1;
  VIfld_get_num_rows(form,gadget,&rowMax);

  for(row = 0; row < rowMax; row++) {

    sel = -1;
    VIfld_get_select(form,gadget,row,col,&sel);

    if (sel == 1) {

      VDahFrmGetGRid(form,gadget,row,col1,&rowID);
      VDatDisplayNode(&rowID,mode);
      VIfld_set_select(form,gadget,row,col,0);
    }
  }

  return 1;
}

IGRstat VDatFormUnHiLiteAll()
{
  IGRstat msg;

  dp$erase_hilite(msg = &msg);

  return 1;
}

/* ----------------------------------------
 * Readjusts all highlited objects
 */
IGRstat VDatFormHiLite(Form form)
{
  IGRstat msg;

  dp$erase_hilite(msg = &msg);

  VDatFormHiLiteGadget(form,VDAT_FORM_G_PLATES,0,1);
  VDatFormHiLiteGadget(form,VDAT_FORM_G_TREE,  2,3);

  return 1;
}

/* ----------------------------------------
 * Not sure for now if want to store these ids in global
 * data structure or in the form itself
 * Put a wrapper on for now
 */
IGRstat VDatFormSetGRid(Form form, IGRint row, TGRid *objID)
{
  VDahFrmSetGRid(form,VDAT_FORM_G_GRIDS,row,0,objID);
  return 1;
}
IGRstat VDatFormGetGRid(Form form, IGRint row, TGRid *objID)
{
  objID->objid = NULL_OBJID;
  VDahFrmGetGRid(form,VDAT_FORM_G_GRIDS,row,0,objID);
  return 1;
}

IGRstat  VDatFormSetMgrID(Form form, TGRid *objID) 
{ 
  return VDatFormSetGRid(form,0,objID);
}
IGRstat  VDatFormGetMgrID(Form form, TGRid *objID) 
{ 
  return VDatFormGetGRid(form,0,objID);
}
IGRstat  VDatFormSetSetsID(Form form, TGRid *objID) 
{ 
  return VDatFormSetGRid(form,1,objID);
}
IGRstat  VDatFormGetSetsID(Form form, TGRid *objID) 
{ 
  return VDatFormGetGRid(form,1,objID);
}
IGRstat  VDatFormSetSetID(Form form, TGRid *objID) 
{ 
  return VDatFormSetGRid(form,2,objID);
}
IGRstat  VDatFormGetSetID(Form form, TGRid *objID) 
{ 
  return VDatFormGetGRid(form,2,objID);
}
IGRstat  VDatFormSetTreeID(Form form, TGRid *objID) 
{ 
  return VDatFormSetGRid(form,3,objID);
}
IGRstat  VDatFormGetTreeID(Form form, TGRid *objID) 
{ 
  return VDatFormGetGRid(form,3,objID);
}

/* --------------------------------------
 * Runs through tree manager and sets id's
 * of interest
 */
IGRstat VDatFormSetIDs(Form form)
{
  IGRstat retFlag = 0;
  TGRid    mgrID;

  TGRid   setsID;
  TGRid    setID;

  TGRid   treeID;

  /* Make sure have manager */
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    printf("No tree manager found\n");
    goto wrapup;
  }
  VDatFormSetMgrID(form,&mgrID);

  // Sets Object
  VDatGetSets(&mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) {
    printf("No sets found\n");
    goto wrapup;
  }
  VDatFormSetSetsID(form,&setsID);

  // First set by default
  VDatGetSet(&setsID,&setID);
  if (setID.objid == NULL_OBJID) {
    printf("No default set found\n");
    goto wrapup;
  }
  VDatFormSetSetID(form,&setID);

  // First tree in set
  VDatGetTree(&setID,&treeID);
  if (treeID.objid == NULL_OBJID) {
    printf("No tree found in first set\n");
    goto wrapup;
  }
  VDatFormSetTreeID(form,&treeID);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;
