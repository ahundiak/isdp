/* $Id: VDvalEqp.c,v 1.1 2002/01/03 14:36:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/VDvalEqp.c
 *
 * Description:	Equipment validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalEqp.c,v $
 *      Revision 1.1  2002/01/03 14:36:25  ahundiak
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
#include "glib.h"

VDASSERT_FFN("VDvalFamily.c");

typedef struct 
{
  TGRid macroIDs;
} Tinfo;

static Tinfo *s_info;

/* -----------------------------------------------
 * Return the static info, allocting if necessary
 */
static Tinfo *getInfo()
{
  if (s_info) return s_info;
  
  s_info = g_new0(Tinfo,1);
  s_info->macroIDs.objid = NULL_OBJID;
  
  return s_info;
}

/* ------------------------------------------
 * Static some fileds in a catalog are
 * useless or need to be handled specially
 */
static void filterPartFld(TGRid *partID, TVDfld *fld)
{
  IGRchar *name = fld->name;
  IGRchar *val  = fld->val.txt;

  // Some mapping
  if (!strcmp(name,"n_itemname")) {
    VDctxAppTxtAtr(partID,"part_name",val);
    goto wrapup;
  }
  if (!strcmp(name,"n_itemrev")) {
    if (*val != '0') VDctxAppTxtAtr(partID,"part_rev",val);
    goto wrapup;
  }
  if (!strcmp(name,"n_itemdesc")) {
    if (*val) VDctxAppTxtAtr(partID,"part_desc",val);
    goto wrapup;
  }
  if (!strcmp(name,"p_macro")) {
    VDctxAppTxtAtr(partID,"macro_name",val);
    goto wrapup;
  }

  // Skip the rest of the n_ and p_
  // Might be safer to have a list
  if (!strncmp(name,"n_",2)) goto wrapup;
  if (!strncmp(name,"p_",2)) goto wrapup;
  
  // printf("Field %s\n",name);
  VDctxAppTxtAtr(partID,name,val);

 wrapup:
  return;
}

/* ------------------------------------------
 * Given a catalog, add in the parts
 */
static void addParts(TGRid *catID)
{
  IGRchab catName;
  IGRchar sql[256];

  TGRid  partID;
  TGRid  tableID;
  TGRid  recordID;
  IGRint i,j;

  IGRchab partName,partRev,partDesc;
  
  TVDfld *flds = NULL;
  IGRint  cnt;
  
  // Need the name
  VDctxGetTxtAtr(catID,"cat_name",catName);
  if (*catName == 0) goto wrapup;

  // Query
  sprintf(sql,
	  "Select * "
	  "from %s order by n_itemname,n_itemrev;",
	  catName);
  VDrisDomQuery(sql,&tableID);

  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&tableID,i,&recordID); i++) {

    // Make new node
    VDctxCreateNode(catID,"cat_part",NULL,&partID);

    // Make sure have room for fields
    if (flds == NULL) flds = g_new(TVDfld,100);
    
    // Cycle through and append fields
    VDctxGetFldAtrs(&recordID,&cnt,flds);
    for(j = 0; j < cnt; j++) {
      filterPartFld(&partID,&flds[j]);
    }
    
  }
  VDctxDeleteNode(&tableID);
  g_free(flds);
  
 wrapup:
  return;
}

/* ------------------------------------------
 * Given a macro library, add in the catalogs
 */
static void addCatalogs(TGRid *libID)
{
  IGRchab libName;
  IGRchab catName;
  IGRchar sql[256];

  TGRid catID;
  TGRid tableID;
  TGRid recordID;
  IGRint i;
  
  // Need the name
  VDctxGetTxtAtr(libID,"lib_name",libName);
  if (*libName == 0) goto wrapup;

  // Query
  sprintf(sql,
	  "Select n_catalogname from pdmparamloc "
	  "where p_macrocat = 'pdmlibraries' and "
	  "p_macropartno = '%s' order by n_catalogname;",
	  libName);
  VDrisDomQuery(sql,&tableID);

  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&tableID,i,&recordID); i++) {

    // Make new node
    VDctxCreateNode(libID,"eqp_cat",NULL,&catID);
    VDctxGetTxtAtr(&recordID,"n_catalogname",catName);
    VDctxAppTxtAtr(&catID,"cat_name",catName);
 
    // printf("%s %s\n",libName,catName);

    // Add the part information
    addParts(&catID);
    
  }
  VDctxDeleteNode(&tableID);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Load in list of macro libraries
 */
static void getMacroIDs(TGRid *macroIDs)
{
  Tinfo *info = getInfo();

  IGRchar buf[256];
  IGRchab sql;
  IGRchab libName;
  
  TGRid libID;
  
  TGRid recordID;
  TGRid tableID;
  
  IGRint i;
  
  // Cache copy
  if (info->macroIDs.objid != NULL_OBJID) goto wrapup;

  // File copy
  VDsysFindFile("config/xml","eqp_parts.xml",buf);
  if (*buf) {
    VDxdomCreateTreeFromXmlFile(buf,&info->macroIDs);
    goto wrapup;
  }

  // Make the tree
  VDctxCreateXdomTree("eqp_parts",NULL,&info->macroIDs);
  
  // Database
  if (VDrisIsSchemaOpen() == 0) goto wrapup;

  // List of macro libraries
  strcpy(sql,
	 "Select n_itemname,n_itemrev from pdmlibraries "
	 "where  n_itemdesc = 'equipment' order by n_itemname;");  
  VDrisDomQuery(sql,&tableID);
  
  // Cycle through
  for(i = 0; VDctxGetNthTreeChild(&tableID,i,&recordID); i++) {

    // Only deal with avondale libs
    VDctxGetTxtAtr(&recordID,"n_itemname",libName);
    if (!strncmp(libName,"av",2)) {
      
      // Make new node
      VDctxCreateNode(&info->macroIDs,"eqp_lib",NULL,&libID);
      VDctxAppTxtAtr(&libID,"lib_name",libName);
      // printf("%2d %s ",i,libName);

      // n_itemrev is always 'vds'
      // VDctxGetTxtAtr(&recordID,"n_itemrev",buf);
      // printf("%s\n",buf);
      addCatalogs(&libID);
      
    }
  }
  VDctxDeleteNode(&tableID);
  

  // Save to a file for later
  VDctxSaveTreeToXmlFile(&info->macroIDs,"eqp_parts.xml");
  
 wrapup:
  *macroIDs = info->macroIDs;
  return;
}

static IGRint compareMacroName(const void *p1, const void *p2)
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab macName1,macName2;
  
  VDctxGetTxtAtr(node1ID,"macro_name",macName1);
  VDctxGetTxtAtr(node2ID,"macro_name",macName2);
  return strcmp(macName1,macName2);
}

static IGRint filterCntFld(TVDfld *fld) 
{
  IGRint retFlag = 0;
  
  IGRchar *name = fld->name;

  if (!strcmp(name,"part_name"))    goto wrapup;
  if (!strcmp(name,"part_rev"))     goto wrapup;
  if (!strcmp(name,"part_desc"))    goto wrapup;
  if (!strcmp(name,"nomenclature")) goto wrapup;
  if (!strcmp(name,"macro_name"))   goto wrapup;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Curious about how many parts are in the system
 */
void VDvalGetEqpCnt()
{
  VDASSERT_FN("VDvalGetEqpCnt");

  TGRid macroIDs;

  TVDctxNodeList nodeList;

  IGRint cntMacros = 0;
  IGRint cntNoName = 0;
  IGRint cntPar    = 0;
  IGRint i;
  
  TGRid *node1ID,*node2ID;
  
  IGRchab macName1,macName2;

  TVDfld *flds = NULL;
  IGRint  cntFlds,cntFlag,j;
  
  // Init
  VDctxInitNodeList(&nodeList);
  
  // Start with list of equipment macro libraries
  getMacroIDs(&macroIDs);
  if (macroIDs.objid == NULL_OBJID) goto wrapup;
  
  // Want list of parts
  VDctxGetNodeListByType(&macroIDs,"cat_part",&nodeList);

  // Sort on macro name
  VDctxSortNodeList(&nodeList,compareMacroName);
#if 0
  
  // Cycle through
  for(i = 0; i < (nodeList.cnt-1); i++) {

    node1ID = &nodeList.listIDs[i];
    node2ID = &nodeList.listIDs[i+1];

    VDctxGetTxtAtr(node1ID,"macro_name",macName1);
    VDctxGetTxtAtr(node2ID,"macro_name",macName2);
    
    if (*macName1 == 0) cntNoName++;
    else {
      if (!strcmp(macName1,macName2)) {
	cntPar += 2;
	for(i++; i < (nodeList.cnt - 1) && !strcmp(macName1,macName2); i++) {
	  strcpy(macName1,macName2);
	  VDctxGetTxtAtr(&nodeList.listIDs[i+1],"macro_name",macName2);
	  if (!strcmp(macName1,macName2)) cntPar++;
	  else i--;
	}      
      }
    }
  }
  printf("Total %d, Par %d, No Macro %d\n",nodeList.cnt,cntPar,cntNoName);
#endif
  // Count macros with more than the standard attributes
  flds = g_new(TVDfld,100);
  cntPar = 0;
  for(i = 0; i < nodeList.cnt; i++) {
    VDctxGetFldAtrs(&nodeList.listIDs[i],&cntFlds,flds);
    cntFlag = 0;
    for(j = 0; j < cntFlds; j++) {
      if (filterCntFld(&flds[j])) cntFlag = 1;
    }
    if (cntFlag) cntPar++;
  }

  // Count unique macro names
  for(i = 1; i < nodeList.cnt; i++) {

    node1ID = &nodeList.listIDs[i-1];
    node2ID = &nodeList.listIDs[i];

    VDctxGetTxtAtr(node1ID,"macro_name",macName1);
    VDctxGetTxtAtr(node2ID,"macro_name",macName2);

    if (strcmp(macName1,macName2)) cntMacros++;
  }
  
  printf("Total %d, Par %d, Macros %d\n",nodeList.cnt,cntPar,cntMacros);
  
 wrapup:
  VDctxFreeNodeList(&nodeList);
  g_free(flds);
  
  return;
}
