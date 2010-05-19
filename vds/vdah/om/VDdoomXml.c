/* $Id: VDdoomXml.c,v 1.6 2001/11/16 14:26:12 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdah/om/VDdoomXml.c
 *
 * Description: DOOM Xml Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdoomXml.c,v $
 *      Revision 1.6  2001/11/16 14:26:12  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/19 20:11:27  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/10/19 18:30:21  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/16 19:02:43  jdsauby
 *      Added VDdoomXmlParseFileForRoot
 *
 *      Revision 1.2  2001/03/13 00:16:20  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/22 22:52:13  ahundiak
 *      *** empty log message ***
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/22/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"

#include "VDctx.h"

#include "VDdoom.h"
#include "VDtest.h"

VDASSERT_FFN("VDdoomXml.c");

/* -----------------------------------------------
 * Create either a tree or just the root node
 * For now, always returns the tree id, need to
 * write a sax routine for getting the root node
 */
void VDdoomCreateTree(TGRid *doomID, IGRint rootOnly, TGRid *treeID)
{
  VDASSERT_FN("VDdoomCreateTree");
  IGRstat retFlag = 1;
  
  IGRint   len;
  IGRchar *buf = NULL;

  TGRid nodeID;
  
  // Arg check
  VDASSERTW(treeID);  treeID->objid  = NULL_OBJID;
  VDASSERTW(doomID && doomID->objid != NULL_OBJID);

  // Pull the data from it
  VDdoomGetData(doomID,&len,&buf);
  VDASSERTW(buf);
  
  // Parse it
  if (rootOnly) VDxdomCreateRootFromXmlBuf(buf,treeID);
  else          VDxdomCreateTreeFromXmlBuf(buf,treeID);
  VDASSERTW(treeID->objid != NULL_OBJID);
    
 wrapup:
  return;
}

/* -----------------------------------------------
 * Init a structure
 */
void VDdoomInitDoomInfo(TVDdoomInfo *info)
{
  VDASSERT_FN("VDdoomInitDoomInfo");
  
  VDASSERTW(info);
  
  memset(info,0,sizeof(TVDdoomInfo));

  info->doomID.objid = NULL_OBJID;
  info->rootID.objid = NULL_OBJID;
  info->treeID.objid = NULL_OBJID;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Free a structure
 */
void VDdoomFreeDoomInfo(TVDdoomInfo *info)
{
  VDASSERT_FN("VDdoomFreeDoomInfo");
  
  VDASSERTW(info);

  if (info->rootID.objid != NULL_OBJID) {
    VDctxDeleteNode(&info->rootID);
  }
  if (info->treeID.objid != NULL_OBJID) {
    VDctxDeleteNode(&info->treeID);
  }
  
  VDdoomInitDoomInfo(info);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Fill up a structure
 */
void VDdoomFillDoomInfo(TGRid *doomID, IGRint treeFlag, TVDdoomInfo *info)
{
  VDASSERT_FN("VDdoomFillDoomInfo");
  
  VDASSERTW(info);
  VDdoomInitDoomInfo(info);
  VDASSERTW(doomID && doomID->objid != NULL_OBJID);

  // Save the doom
  info->doomID = *doomID;

  // Make the root
  VDdoomCreateTree(doomID,1,&info->rootID);
  VDASSERTW(info->rootID.objid != NULL_OBJID);

  // Some bits
  VDctxGetBaseInfo(&info->rootID,&info->baseInfo);
  VDctxGetTxtAtr  (&info->rootID,VDCTX_ATR_CREATION_TIMESTAMP,info->ts);

  // Do the tree
  if (treeFlag) {
    VDdoomCreateTree(doomID,0,&info->treeID);
    VDASSERTW(info->treeID.objid != NULL_OBJID);
  }
  
 wrapup:
  return;
}

/* -------------------------------------------------
 * Parses an xml file to get the root node
 */
IGRstat VDdoomXmlParseFileForRoot(IGRchar *fileName,
                                  TGRid   *rootID)
{
  VDASSERT_FN("VDdoomXmlParseFileForRoot");

  TGRid nodeID;
  
  // arg Check
  VDASSERTW(fileName);
  VDASSERTW(rootID);

  // Parse it
  VDxdomCreateRootFromXmlFile(fileName,rootID);
  //VDxdomCreateTreeFromXmlFile(fileName,rootID);
  VDASSERTW(rootID->objid != NULL_OBJID);
  
  
 wrapup:
  return 1;
}


