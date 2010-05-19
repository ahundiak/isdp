/* $Id: VDct1Misc.c,v 1.8 2002/01/07 18:53:34 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1Misc.I
 *
 * Description: Utility Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Misc.c,v $
 *      Revision 1.8  2002/01/07 18:53:34  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.7  2001/10/03 15:15:53  jdsauby
 *      JTS MP CR 5571
 *
 *      Revision 1.6  2001/05/14 20:49:34  jdsauby
 *      CR5180 Update Nodes
 *
 *      Revision 1.5  2001/05/08 19:58:36  jdsauby
 *      CR 4620 modified computeNode, and VDct1GetMiscStaticAttrValue to handle tree nodes.
 *      CR 5178 modified getParentForModelObject
 *
 *      Revision 1.4  2001/02/17 14:48:09  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/02/09 22:29:33  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/12 15:14:10  art
 *      sp merge
 *
 * Revision 1.1  2000/12/08  15:49:42  pinnacle
 * ah
 *
 * Revision 1.12  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * Revision 1.11  2000/09/25  20:42:54  pinnacle
 * js
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDobj2.h" 
#include "VDrisc.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Attrs.h"
#include "VDct1Ris.h"
#include "VDct1Part.h"
#include "VDct1Trace.h"

#include "VDctx.h"

#include "VDassert.h"

VDASSERT_FFN("vdct1/tree/VDct1Misc.C");

/* -----------------------------------------
 * Scans a tree, used to update any required changes
 */
IGRstat VDct1ScanTree(TGRid *treeID)
{
  VDASSERT_FN("VDct1ScanTree");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid    nodeID;
  TVDct1JD nodeJD;
  
  // say hi
  if (traceFlag) printf(">>> VDct1ScanTree\n");
  
  // Arg Check
  if( treeID->objid == NULL_OBJID ) goto wrapup;
  if (traceFlag) printf("### treeID <%d,%d>\n",treeID->osnum,treeID->objid);
  nodeID = *treeID;
#if 0
  // get the tree id from the set
  VDlnkGet(setID,VDCT_CHN_MGR_TO_CHILD,0,NULL,&treeID);
  //VDct1GetSetTree( setID, &treeID);
  if (treeID.objid == NULL_OBJID) goto wrapup;
  if (traceFlag) printf("### treeID\n");
#endif
  // get some class
  nodeJD.cl = VDct1GetTreeClassForNode(&nodeID);
  if (nodeJD.cl == NULL) goto wrapup;
  nodeJD.id = nodeID;
  if (traceFlag) printf("### nodeJD.cl\n");
  
  sts = _RTCJDB(&nodeJD)->updateNodesOnTree(&nodeJD);
  if (!(sts & 1)) goto wrapup;
  if (traceFlag) printf("### updateNodes\n");
  
  // done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDct1ScanTree <%d>\n",retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Init a nodeInfos structure
 */
IGRstat VDct1InitNodeInfos(TVDct1NodeInfos *infos)
{
  IGRstat retFlag = 0;
  
  // Argcheck
  if (infos == NULL) goto wrapup;
  
  // Clear
  memset(infos,0,sizeof(TVDct1NodeInfos));
  
  // Setup
  infos->max = 100;
  infos->inc = 100;
  infos->nodes = malloc(infos->max * sizeof(TVDct1NodeInfo));

  if (infos->nodes == NULL) {
    printf("*** Problem allocating memory for TVDct1NodeInfos\n");
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Frees a nodeInfos structure
 */
IGRstat VDct1FreeNodeInfos(TVDct1NodeInfos *infos)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  // Argcheck
  if (infos == NULL) goto wrapup;
  if (infos->nodes == NULL) goto wrapup;
  
  // Free the array of pointers
  free(infos->nodes);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (infos) memset(infos,0,sizeof(TVDct1NodeInfos));
  return retFlag;
}


/* --------------------------------------------------------
 * Look through config directories for access control file
 */
static FILE *VDct1OpenAccessControlFile()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;

  // Look in local directory
  file = fopen("tm_access.tbl","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    EX_getpath(i,buf,sizeof(buf),EX_CONFIG_PATH);
    if (*buf == 0) {
      file = NULL;
      return file;
    }
   
    strcat(buf,"config/sets/tm_access.tbl");
    //printf("Directory for tm_access.tbl file is [%s]\n",buf);
    
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

  
/* ----------------------------------------------
 * check to see if access control file permits tree creation
 */
IGRstat VDct1IsCreateTreeAccessAllowed(IGRchar *setType,
				       IGRchar *pdm_catalog)
{
  VDASSERT_FN("VDct1IsCreateTreeAccessAllowed");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar buf[128],bufx[128];
  IGRchar catalogAccess[64],setTypeAccess[64];
  
  IGRchar *p,*q;
  
  FILE *file = NULL;

  VDASSERTW(setType != NULL);
  VDASSERTW(pdm_catalog != NULL);
  
  // say hi
  //traceFlag = 1;
  
  if (traceFlag) printf(">>> %s %s %s %s\n",ffn(),fn,setType,pdm_catalog);
  
  
  // Open the access control list
  file = VDct1OpenAccessControlFile();
  if (file == NULL) {
    printf("*** tm_access.tbl not found\n");
    goto wrapup;
  }
  
  // Cycle through file and make some comparisons
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    
    if (strncmp(buf,"#",1)) {
      
      for(p = buf; *p > ' '; p++); *p = 0;
      if (*buf) {
	
	// get the setType from the access file
	strcpy(setTypeAccess,buf);
	
	// get the catalog from the access file
	q = p + 1;
	strcpy(bufx,q);
	
	// Clean out any leading spaces
	for(p = bufx; *p == ' '; p++);
	if (p != bufx) strcpy(bufx,p);
	
	// clean out any trailing characters
	for(p = bufx; *p > ' '; p++); *p = 0;
	if (*bufx) strcpy(catalogAccess,bufx);
	
	// Compare file access to tree info
	if (traceFlag) printf("set = %s, catalog = %s\n",setTypeAccess,catalogAccess);

	if ( (!strcmp(setType,setTypeAccess)) && 
	     (!strcmp(pdm_catalog,catalogAccess)) ) {
	  retFlag = 1;
	  goto wrapup;
	}
	
      } // end of if (*buf)
      
    } // end of if (strncmp(buf,"#",1))
    
  } // end of while 

  // done
    
 wrapup:
  if (file) fclose(file);
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* --------------------------------------------
 * Tracing utility
 */
IGRstat VDct1TraceFlag(IGRchar *trace)
{
  IGRchar *envVar;
  IGRstat flag;
  
  // To trace it all
  // envVar = getenv("VDCT1_TRACE");
  if (getenv("VDCT1_TRACE")) {
    envVar = getenv("VDCT1_TRACE");
    flag = atoi(envVar);
    if (flag) return 1;
  }
  
  /* -------------------------------------
   * Command Object tracing
   */

  // Trace all command objects
  if (getenv("VDCT1_CMD_TRACE")) {
    envVar = getenv("VDCT1_CMD_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_ATTR))  ||
	(!strcmp(trace,VDCT1_TRACE_CMD_LIB))   ||
	(!strcmp(trace,VDCT1_TRACE_CMD_MGR))   ||
	(!strcmp(trace,VDCT1_TRACE_CMD_NODE))  ||
	(!strcmp(trace,VDCT1_TRACE_CMD_PART))  ||
	(!strcmp(trace,VDCT1_TRACE_CMD_SET))   ||
	(!strcmp(trace,VDCT1_TRACE_CMD_TREE))  ||
	(!strcmp(trace,VDCT1_TRACE_CMD_TREEF)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_ROOT))  ||
        (!strcmp(trace,VDCT1_TRACE_CMD_FREE))  ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) )  return 1;
  }
  
  // individual command tracing
  if (getenv("VDCT1_ATTR_TRACE")) {
    envVar = getenv("VDCT1_ATTR_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_ATTR)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_LIB_TRACE")) {
    envVar = getenv("VDCT1_LIB_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_LIB)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_MGR_TRACE")) {
    envVar = getenv("VDCT1_MGR_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_MGR)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_NODE_TRACE")) {
    envVar = getenv("VDCT1_NODE_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_NODE)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_PART_TRACE")) {
    envVar = getenv("VDCT1_PART_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_PART)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_SET_TRACE")) {
    envVar = getenv("VDCT1_SET_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_SET)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_TREE_TRACE")) {
    envVar = getenv("VDCT1_TREE_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_TREE)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_TREEF_TRACE")) {
    envVar = getenv("VDCT1_TREEF_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_TREEF)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_ROOT_TRACE")) {
    envVar = getenv("VDCT1_ROOT_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_ROOT)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }

  if (getenv("VDCT1_FREE_TRACE")) {
    envVar = getenv("VDCT1_FREE_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_FREE)) ||
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  if (getenv("VDCT1_CTEST_TRACE")) {
    envVar = getenv("VDCT1_CTEST_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_CMD_CTEST)) ) return 1;
  }
  
  /* --------------------------------------------------
   * Tree hierarchy, if tracing is set for one, then
   * all subsequent trees should trace
   */

  if (getenv("VDCT1_BASE_TRACE")) {
    envVar = getenv("VDCT1_BASE_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_BASE))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_COM))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	
	(!strcmp(trace,VDCT1_TRACE_TREE_PROD))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_XML))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PLOT))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PAL))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_ASSY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PART))  ||
	
	(!strcmp(trace,VDCT1_TRACE_TREE_ENGR))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_OFT))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_CABLE)) ||
	(!strcmp(trace,VDCT1_TRACE_TREE_WWAY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PIPE))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_HVAC)) ) return 1;
  }
  
  if (getenv("VDCT1_COM_TRACE")) {
    envVar = getenv("VDCT1_COM_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_COM))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	
	(!strcmp(trace,VDCT1_TRACE_TREE_PROD))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_XML))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PLOT))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PAL))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_ASSY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PART))  ||
	
	(!strcmp(trace,VDCT1_TRACE_TREE_ENGR))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_OFT))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_CABLE)) ||
	(!strcmp(trace,VDCT1_TRACE_TREE_WWAY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PIPE))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_HVAC)) ) return 1;
  }

  if (getenv("VDCT1_PROD_TRACE")) {
    envVar = getenv("VDCT1_PROD_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PROD))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_XML))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PLOT))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PAL))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_ASSY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PART))  ||
	
	(!strcmp(trace,VDCT1_TRACE_TREE_ENGR))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_OFT))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_CABLE)) ||
	(!strcmp(trace,VDCT1_TRACE_TREE_WWAY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PIPE))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_HVAC)) ) return 1;
  }

  if (getenv("VDCT1_XML_TRACE")) {
    envVar = getenv("VDCT1_XML_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_XML)) ) return 1;
  }

  if (getenv("VDCT1_PLOT_TRACE")) {
    envVar = getenv("VDCT1_PLOT_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PLOT)) ) return 1;
  }

  if (getenv("VDCT1_PAL_TRACE")) {
    envVar = getenv("VDCT1_PAL_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PAL)) ) return 1;
  }

  if (getenv("VDCT1_ASSY_TRACE")) {
    envVar = getenv("VDCT1_ASSY_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_ASSY)) ) return 1;
  }

  if (getenv("VDCT1_PART_TRACE")) {
    envVar = getenv("VDCT1_PART_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PART)) ) return 1;
  }
  
  if (getenv("VDCT1_ENGR_TRACE")) {
    envVar = getenv("VDCT1_ENGR_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_ENGR))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_OFT))   ||
	(!strcmp(trace,VDCT1_TRACE_TREE_CABLE)) ||
	(!strcmp(trace,VDCT1_TRACE_TREE_WWAY))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PIPE))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_HVAC)) ) return 1;
  }

  if (getenv("VDCT1_OFT_TRACE")) {
    envVar = getenv("VDCT1_OFT_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_OFT)) ) return 1;
  }

  if (getenv("VDCT1_CABLE_TRACE")) {
    envVar = getenv("VDCT1_CABLE_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_CABLE)) ) return 1;
  }

  if (getenv("VDCT1_WWAY_TRACE")) {
    envVar = getenv("VDCT1_WWAY_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_WWAY)) ) return 1;
  }

  if (getenv("VDCT1_PIPE_TRACE")) {
    envVar = getenv("VDCT1_PIPE_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_PIPE)) ) return 1;
  }

  if (getenv("VDCT1_HVAC_TRACE")) {
    envVar = getenv("VDCT1_HVAC_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST))  ||
	(!strcmp(trace,VDCT1_TRACE_TREE_HVAC)) ) return 1;
  }

  if (getenv("VDCT1_TTEST_TRACE")) {
    envVar = getenv("VDCT1_TTEST_TRACE");
    flag   = atoi(envVar);
    
    if ((flag) &&
	(!strcmp(trace,VDCT1_TRACE_TREE_TEST)) ) return 1;
  }

  // set by the ppl COset_trace
  // 76
  if (VDdbgGetTraceFlag(VDCT1_TRACE_COMMAND))  return 1;

  // 78
  if (VDdbgGetTraceFlag(VDCT1_TRACE_TREE))     return 1;
  
  // 77
  if (VDdbgGetTraceFlag(VDCT1_TRACE_OTM_TREE)) return 1;
  
  // no tracing set
  return 0;
    
}

/* -----------------------------------------------
 * Utility routine to update value of one attribute
 */
IGRstat VDct1UpdNodeAttr(TGRid *nodeID, IGRchar *name, IGRchar *value)
{
  IGRstat retFlag = 0;
  TVDfld  fld;
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  if (name   == NULL) goto wrapup;
  if (value  == NULL) goto wrapup;
  
  // Get it
  VDctxGetAttr(nodeID,name,&fld);
  if (*fld.name == 0) goto wrapup;
  
  // Update
  strcpy(fld.val.txt,value);
  VDctxUpdAttrs(nodeID,1,&fld);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Pull down means to go up the tree and find a parent
 * node with the attribute in question and grab it's value
 *
 * Uses a loop instead of recursion
 */
IGRstat VDct1PullDownAttr(TGRid *nodeID, IGRchar *attrName)
{
  IGRstat retFlag = 0;
  TVDfld  fld,fldx;

  TGRid   childID,parentID;
  
  // Arg Check
  if (attrName == 0) goto wrapup;

  // Make sure this node had the attribute
  VDctxGetAttr(nodeID,attrName,&fld);
  if (*fld.name == 0) goto wrapup;
  
  // Go up the tree looking for a value
  childID = *nodeID;
  
parent_loop:
  // get the parent
  VDctxGetTreeParent(&childID,&parentID);
  if (parentID.objid == NULL_OBJID) goto wrapup;
  
  // Get it's attribute
  VDctxGetAttr(&parentID,attrName,&fldx);
  if (*fldx.name == 0) {
    childID = parentID;
    goto parent_loop;
  }
  
  // Update
  strcpy(fld.val.txt,fldx.val.txt);
  VDctxUpdAttrs(nodeID,1,&fld);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

IGRstat VDct1GetElecDwgInfo(IGRchar            *dwg_num,
			    TVDct1ElecDwgInfo  *dwgInfo)
{
  VDASSERT_FN("VDct1GetElecDwgInfo");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDrisInfo ris;
  IGRint i;

  VDASSERTW(dwg_num);
  VDASSERTW(dwgInfo);
  
  
  // Say Hi
  traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_PROD);
  if (traceFlag) {
    printf (">>> %s %s %s\n",ffn(),fn,dwg_num);
  }
  
  // Init
  memset(dwgInfo,0,sizeof(TVDct1ElecDwgInfo));
    
  // query for info
  VDrisInitInfo(&ris);
  VDct1QryDwgInfoForDwgNum(&ris,dwg_num);
  if (ris.rows < 1) goto wrapup;

  // fill it up
  strcpy(dwgInfo->dwg_num   ,ris.buf[VDCT1_RIS_COLI_ELECDWG_DWG_NUM]);
  strcpy(dwgInfo->dwg_code  ,ris.buf[VDCT1_RIS_COLI_ELECDWG_DWG_CODE]);
  strcpy(dwgInfo->dwg_title ,ris.buf[VDCT1_RIS_COLI_ELECDWG_DWG_TITLE]);
  strcpy(dwgInfo->sect_num  ,ris.buf[VDCT1_RIS_COLI_ELECDWG_SECT_NUM]);  

  
  //Done
  retFlag = 1;
  goto wrapup;
  
wrapup:
  if (traceFlag) {
    printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  VDrisFreeInfo(&ris);
  return retFlag;
  
}



IGRstat VDct1GetCommInfo(IGRchar        *commCode,
			 TVDct1CommInfo *comm)
{
  VDASSERT_FN("VDct1GetCommInfo");
  
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDrisInfo ris;
  IGRint i;

  VDASSERTW(commCode);
  VDASSERTW(comm);
  
  
  // Say Hi
  // traceFlag = 1;
  if (traceFlag) {
    printf (">>> %s %s %s\n",ffn(),fn,commCode);
  }
  
  // Init
  memset(comm,0,sizeof(TVDct1CommInfo));
    
  // query for info
  VDrisInitInfo(&ris);
  VDct1QryCodesForCommCode(&ris,commCode);
  if (ris.rows < 1) goto wrapup;

  // fill it up
  strcpy(comm->comm_code  ,ris.buf[VDCT1_RIS_COLI_COMMS_COMM_CODE]);
  strcpy(comm->commodity  ,ris.buf[VDCT1_RIS_COLI_COMMS_COMMODITY]);
  strcpy(comm->cost_code  ,ris.buf[VDCT1_RIS_COLI_COMMS_COST_CODE]);
  strcpy(comm->sequence_no,ris.buf[VDCT1_RIS_COLI_COMMS_SEQUENCE_NO]);
  
  //Done
  retFlag = 1;
  goto wrapup;
  
wrapup:
  if (traceFlag) {
    printf ("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  
  VDrisFreeInfo(&ris);
  return retFlag;
  
}

IGRstat VDct1GetMiscStaticAttrValue(TVDct1JD   *nodeJD,
				    TGRobj_env *modelOE,
				    IGRchar    *attrName,
				    IGRchar    *attrValue)
{
  VDASSERT_FN("VDct1GetMiscStaticAttrValue");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo ris;
  IGRchar    cageNum[64];
  TVDctBaseInfo  baseInfo;

  TGRid   objID;

  TVDct1_part_fld_part_cage_num part_cage_num;
  TVDct1_part_fld_part_id       part_id;
  
      
  VDASSERTW((nodeJD->id.objid != NULL_OBJID) ||
	    ((modelOE->obj_id.objid != 0) && modelOE->obj_id.objid != NULL_OBJID));
  VDASSERTW(attrName);
  VDASSERTW(attrValue);
  
  // say hi
  if (traceFlag) printf(">>> %s %s %s\n",ffn(),fn,attrName);
  
  // init 
  VDrisInitInfo(&ris);
#if 0
  // set the objID
  objID.objid = NULL_OBJID;
  if (nodeJD)  objID = nodeJD->id;
  if (modelOE) objID = modelOE->obj_id;
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  if (traceFlag){
    printf("### %s %s the object\n",ffn(),fn);
    VDobjPrint2(NULL,&objID);
  }
#endif
  // get cageNum for node (modelOE)
  if ( (modelOE) && (modelOE->obj_id.objid != NULL_OBJID) ) {
      VDct1GetPartCageNumForModelObject(modelOE,NULL,part_cage_num,part_id);
      if (part_cage_num == NULL) goto wrapup;
      strcpy(cageNum,part_cage_num);
      goto queryIt;
  }
    
  // get cageNum for nodeJD (nodeJD)
  if ( (nodeJD) && (nodeJD->id.objid != NULL_OBJID) ) {
      _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
      if (baseInfo.nodeName == NULL) goto wrapup;
      strcpy(cageNum,baseInfo.nodeName);
      goto queryIt;
  }

queryIt:
  // query by cageNum and attrName, to return the attrValue
  VDct1QryMiscStatAttrsForCageNum(&ris,cageNum,attrName);
  if (ris.rows != 1) goto wrapup;
  
  // set attrValue
  strcpy(attrValue,ris.buf[VDCT1_RIS_COLI_MISC_SATTR_ATTR_VALUE]);
  
  // done
  retFlag = 1;
  
wrapup:
  VDrisFreeInfo(&ris);
  if (traceFlag) printf("<<< %s %s(%d) %s\n",ffn(),fn,retFlag,attrValue);
  return retFlag;
}












