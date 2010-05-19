/* $Id: VDvalTolerance.c,v 1.4 2002/06/07 14:48:24 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/VDvalTolerance.c
 *
 * Description:	Be able to specify lot's of tolerances
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalTolerance.c,v $
 *      Revision 1.4  2002/06/07 14:48:24  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/24 20:00:43  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/22 15:16:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:50:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDxdom.h"
#include "VDctx.h"
#include "VDval.h"

VDASSERT_FFN("VDvalTolerance.c");

typedef struct 
{
  TGRid           toleranceIDs;
  TGRid           findID;
  TVDctxNodeList  nameList;
} Tinfo;

static Tinfo *info;

/* -----------------------------------------------
 * Get the tolerances from web server
 */
void VDvalWebTolerances(TGRid *toleranceIDs)
{
  VDASSERT_FN("VDvalWebTolerances");

  // Arg check
  VDASSERTW(toleranceIDs); toleranceIDs->objid = NULL_OBJID;
  
  VDxdomCreateTreeFromWebFile(NULL,"/isdp/tolerances.xml",toleranceIDs);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the tolerances from xml file
 */
void VDvalFileTolerances(TGRid *toleranceIDs)
{
  VDASSERT_FN("VDvalFileTolerances");

  IGRchab path;
  
  // Arg check
  VDASSERTW(toleranceIDs); toleranceIDs->objid = NULL_OBJID;

  // Find the file
  VDsysFindFile("config/xml","tolerances.xml",path);
  if (*path == 0) goto wrapup;
  
  VDxdomCreateTreeFromXmlFile(path,toleranceIDs);

 wrapup:
  return;
}
/* -----------------------------------------------
 * Index on name
 */
static IGRint compareName(const void *p1, const void *p2) 
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab name1,name2;
  
  VDctxGetTxtAtr(node1ID,"name",name1); strlwr(name1);
  VDctxGetTxtAtr(node2ID,"name",name2); strlwr(name2);
  
  return strcmp(name1,name2);
}

static void indexName()
{
  VDASSERT_FN("indexName");
  
  // Build the list
  VDctxGetNodeListByType(&info->toleranceIDs,"tolerance",&info->nameList);
  
  // Sort em
  VDctxSortNodeList(&info->nameList,compareName);
  
  // For searching
  VDxdomCreateTree("find",&info->findID);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * get the tolerances tree, creating one if necessary
 */
void VDvalGetTolerances(TGRid *toleranceIDs)
{
  VDASSERT_FN("VDvalGetTolerances");

  IGRint flag = 0;
  
  // Arg check
  VDASSERTW(toleranceIDs); toleranceIDs->objid = NULL_OBJID;

  // See if loaded
  if (info) {
    
    // Is it already loaded
    *toleranceIDs = info->toleranceIDs;
    if ((toleranceIDs->objid != 0) && (toleranceIDs->objid != NULL_OBJID)) goto wrapup;
  }
  if (info == NULL) {  
    info = calloc(1,sizeof(Tinfo));
    VDASSERTW(info);
    flag = 1;
  }
  info->toleranceIDs.objid = NULL_OBJID;

  // Load in text file
  VDvalFileTolerances(toleranceIDs);
  if (toleranceIDs->objid != NULL_OBJID) {
    info->toleranceIDs = *toleranceIDs;
    if (flag) indexName();
    goto wrapup;
  }

  // Try the web
  VDvalWebTolerances(toleranceIDs);
  if (toleranceIDs->objid != NULL_OBJID) {
    info->toleranceIDs = *toleranceIDs;
    if (flag) indexName();
    goto wrapup;
  }

  // Oops
  VDlogPrintFmt(VDLOG_ERROR,1,"*** Unable to load tolerance cache");
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get a particular tolerance
 * Default unknown tolerances to 1.0 with retFlag = 0
 */
IGRstat VDvalGetTolerance(IGRchar *name, IGRdouble *value)
{
  VDASSERT_FN("VDvalGetTolerance");

  IGRstat retFlag = 0;
  
  TGRid  toleranceIDs;
  TGRid *foundID;
  
  // Argcheck
  VDASSERTW(value); *value = 1.0;
  VDASSERTW(name && *name);
  
  // Need the tolerances
  VDvalGetTolerances(&toleranceIDs);
  if (toleranceIDs.objid == NULL_OBJID) goto wrapup;

  // Use the indexed info
  VDctxAppTxtAtr(&info->findID,"name",name);  
  foundID = VDctxSearchNodeList(&info->findID,&info->nameList,compareName);
  if (foundID == NULL) {
    // VDlogPrintFmt(VDLOG_ERROR,1,"*** Could not find tolerance for %s",name);
    goto wrapup;
  }

  // Get it
  VDctxGetDblAtr(foundID,"value",value);
  retFlag = 1;
    
 wrapup:
  return retFlag;
}


  
