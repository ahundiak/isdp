/* $Id: VDatPktSearch.I,v 1.1 2001/02/09 23:42:19 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pocket/VDatPktSearch.I
 *
 * Description: Search Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPktSearch.I,v $
 *      Revision 1.1  2001/02/09 23:42:19  ylong
 *      Renamed
 *
 *      Revision 1.4  2001/02/09 22:38:46  ylong
 *      TR3231
 *
 *      Revision 1.3  2001/02/09 21:09:10  ylong
 *      *** empty log message ***
 *
# Revision 1.2  2000/06/08  16:52:32  pinnacle
# Replaced: vds/vdat/pocket/VDatSearch.I for:  by azuurhou for Service Pack
#
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 * 06/07/00  adz     Chnage GRhhd -> GRhd full hilight ....
 * 02/09/01  yl      TR3231
 ***************************************************************************/

class implementation VDatBase;

#include "VDatMaster.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDahFrm.h"
#include "VDfrm.h"
#include "VDppl1.h"

#include "VDatPocket.h"

/* -----------------------------------------------
 * Search for and display node
 */
IGRstat VDatPKTNotifySearch(Form form)
{
  IGRstat retFlag =0;
  TGRid   nodeID;	
  TGRid   treeID;	
  TGRid   setID;	
  IGRchar searchString[128];
  IGRint	row, pos;
  enum GRdpmode   DisplayMode;

  row = -1;
  FIfld_set_text(form, VDAT_FORM_PKT_G_NOTICE, 0,0, "", 0);
  FIfld_get_active_row(form,VDAT_FORM_PKT_L_SETS,&row,&pos);
  if(row < 0) goto wrapup;

  // Get the set id
  VDahFrmGetGRid(form,VDAT_FORM_PKT_L_SETS,row,3,&setID);
  if(row < 0) goto wrapup;
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Get the Search String
  VIg_get_text(form, VDAT_FORM_PKT_G_SEARCH, searchString);
	
  // Check it
  if(!(strcmp(searchString, "")))goto wrapup;

  // Get the nodeID corresponding to that node
  VDatSearchForNode(&setID, searchString, &nodeID);

  if(nodeID.objid == NULL_OBJID)  
  {
    FIfld_set_text(form, VDAT_FORM_PKT_G_NOTICE, 0,0, 
		   "No Node or Piecemark available", 0);
    goto wrapup;
  }
  // Expand the tree to that Node
  VDatExpandTree(form, VDAT_FORM_PKT_G_TREE, &setID, &nodeID);

  // Display node in model
  DisplayMode = GRhd ;
  VDatDisplayNode(&nodeID, DisplayMode );

  retFlag = 1;
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Called when the PICK button is pressed
 */
IGRstat VDatPKTNotifyPick(Form form)
{
  IGRstat retFlag = 0;
  TGRid	  setID;
  IGRint  row, pos;

  // Init
  retFlag = 1;
  setID.objid = NULL_OBJID;
	
  FIfld_set_text(form, VDAT_FORM_PKT_G_NOTICE, 0,0, "", 0);

  // Get the active set.
  row = -1;
  FIfld_get_active_row(form,VDAT_FORM_PKT_L_SETS,&row,&pos);

  if(row < 0){
    FIfld_set_text(form, VDAT_FORM_PKT_G_NOTICE, 0,0, "No Set Selected", 0);
    goto wrapup;
  }

  // Get the set id
  VDahFrmGetGRid(form,VDAT_FORM_PKT_L_SETS,row,3,&setID);
  if (setID.objid == NULL_OBJID) 
  {
    FIfld_set_text(form, VDAT_FORM_PKT_G_NOTICE, 0,0, "No Set Selected", 0);
    goto wrapup;
  }
  VDatPKTLocateObject(form, &setID);

  // Done
  retFlag =1;
 wrapup:

  return retFlag;

}

/* -----------------------------------------------
 * Kicks off a ppl to locate an object
 */
IGRstat VDatPKTLocateObject(Form form, TGRid *setID)
{
  TGRid	  pplID;
  IGRint  pplRET;

  vdppl$Load(name = "VDatLocate", pplID = &pplID);

  vdppl$SetData (pplID = &pplID,
		 name  = "SET_ID",
		 size  = sizeof(TGRid),
		 data  = (IGRchar*) setID);

  vdppl$SetData (pplID = &pplID,
		 name  = "FORM",
		 size  = sizeof(Form),
		 data  = (IGRchar*) &form);

  vdppl$Run(pplID = &pplID, name = "locateObject", ret = &pplRET);
  vdppl$Delete(pplID = &pplID);

//wrapup:
  return 1;
}

/* ------------------------------------------------------------------
 * Not used ???
 */
IGRstat VDatPKTDisplayLocate(Form form, TGRid *setID, TGRobj_env *objOE)
{
  TGRid   treeID;
  TGRid   leafID;
  IGRchar setType[128];

  VDatGetTree(setID, &treeID);

  VDatRDBGetSetType(setID, setType);
  VDatGetObjectLeafForSetType(objOE, setType, &leafID);

  // Expand the tree to that Node
  VDatExpandTree(form, VDAT_FORM_PKT_G_TREE, setID, &leafID);
  return 1;
}

end implementation VDatBase;





