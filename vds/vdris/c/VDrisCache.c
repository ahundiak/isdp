/* $Id: VDrisCache.c,v 1.3 2002/05/31 19:22:29 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdris/c/VDrisCache.c
 *
 * Description:	RIS Cache Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrisCache.c,v $
 *      Revision 1.3  2002/05/31 19:22:29  jdsauby
 *      Changed Tinfo to TVDrisCacheInfo.  JDS
 *
 *      Revision 1.2  2002/05/31 16:12:01  jdsauby
 *      Added ci=COz_risCache for debug tool for VDrisCache.c, JDS
 *
 *      Revision 1.1  2002/05/09 17:45:23  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/08/02  ah      Creation
 ***************************************************************************/
/*
 * RIS Database caching is generally a good thing.  But it usually requires
 * some sort of custom routine for each type of query or maybe some sort
 * of special parsing of the select statement.
 *
 * But, Jeff had an idea.
 * For many queries, assume that the sql statement can be considered a unique key.
 * And assume the results can be saved indexed against the sql statement.
 *
 * The tree code makes saving the result set easy.
 *
 * So, in theory, this should be a generic caching mechanism that assorted
 * query statements can call.  Only implement as a tree function for now though
 * there is nothing in theory that prevents putting a ris buf interface on top.
 */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDgbl.h"
#include "VDctx.h"

#include "VDrisc.h"

#include "glib.h"
#include "xdom.h"

extern char *strdup(const char *p);

VDASSERT_FFN("VDrisCache.c");

#if 0
typedef struct 
{
  TGRid           findID;
  TGRid           queryIDs;
  TVDctxNodeList  queryList;
} Tinfo;

typedef struct
{
  IGRint cnt;
  Tinfo *infos;
} Tinfos;
#endif

/* -----------------------------------------------
 * Returns the info for the nth cache
 * Taking care of all allocating and initializing
 * stuff needed
 */
static TVDrisCacheInfo *getInfo(IGRint nth)
{
  TVDrisCacheInfos *infos;
  TVDrisCacheInfo  *info = NULL;
  IGRint  i;
  IGRint  cnt;
  IGRchar buf[80];

  // First, decide if the entire structure is allocated yet
  infos = vdGblStaticData10;
  if (infos == NULL) {
    infos = g_new0(TVDrisCacheInfos,1);
    vdGblStaticData10 = infos;
  }

  // Return if already allocated
  if (nth < infos->cnt) {
    info = &infos->infos[nth];
    goto wrapup;
  }

  // Need to add some more
  cnt = nth + 1;
  infos->infos = g_renew(TVDrisCacheInfo,infos->infos,cnt);

  // Clear some data
  for(i = infos->cnt; i < cnt; i++) {

    info = &infos->infos[i];

    // Couple of nodes
    VDctxCreateXdomTree("querys",NULL,&info->queryIDs);

    snprintf(buf,sizeof(buf),"%d",i);
    VDctxAppTxtAtr(&info->queryIDs,"cache_num",buf);

    VDsysGetTimeStamp(buf);
    VDctxAppTxtAtr(&info->queryIDs,"timestamp",buf);

    VDctxCreateXdomTree("find",NULL,&info->findID);
    VDctxInitNodeList(&info->queryList);
  }
  infos->cnt = cnt;

  info = &infos->infos[nth];
  
wrapup:
  return info;
}

/* -----------------------------------------------
 * Compares two query keys
 */
static IGRint compareKey(const void *p1, const void *p2) 
{
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchar *key1,*key2;
  
  VDctxGetTxtAtrPtr(node1ID,"key",&key1);
  VDctxGetTxtAtrPtr(node2ID,"key",&key2);
  
  return strcmp(key1,key2);
}

/* -----------------------------------------------
 * Execute a query using automatic cache
 */
void VDrisDomQueryCache(IGRint cacheNum, IGRchar *qry, TGRid *recordsID)
{
  VDASSERT_FN("VDrisDomQueryCache");

  TVDrisCacheInfo *info = getInfo(cacheNum);
  TGRid *foundID;
  TGRid  qryID;
  TGRid  childID;
  TGRid  recordID;
  TGRid  bubbleID,tmpID;

  IGRint i,cmp;

  xmlNodePtr node;
  xmlAttrPtr attr;
  IGRchar   *p;

  TVDctxNodeList *nodes;

  // Arg check
  VDASSERTW(recordsID); recordsID->objid = NULL_OBJID;
  VDASSERTW(qry && *qry);

  // First see if in cache
  VDctxAppTxtAtr(&info->findID,"key",qry);
  foundID = VDctxSearchNodeList(&info->findID,&info->queryList,compareKey);
  if (foundID) {
    *recordsID = *foundID;
    goto wrapup;
  }

  // Execute the query
  VDrisDomQuery(qry,&qryID);
  VDASSERTW(qryID.objid != NULL_OBJID);

  // Need to copy since there is no easy way to move a child
  VDctxCreateNode(&info->queryIDs,"records",NULL,recordsID);
  VDctxAppTxtAtr(recordsID,"key",qry);

  for(i = 0; VDctxGetNthTreeChild(&qryID,i,&childID); i++) {

    VDctxCreateNode(recordsID,"record",NULL,&recordID);

    // Cheat for transfering the attributes
    node = xdom_nodeid_get_node(&childID);

    for(attr = node->properties; attr; attr = attr->next) {
      VDctxGetTxtAtrPtr(&childID,(IGRchar*)attr->name,&p);
      VDctxAppTxtAtr(&recordID,(IGRchar*)attr->name,p);
    }
  }
  VDctxDeleteNode(&qryID);

  // And index the thing
  nodes = &info->queryList;
  if (nodes->cnt >= nodes->max) {
    nodes->max += 100;
    nodes->listIDs = g_renew(TGRid,nodes->listIDs,nodes->max);
  }
  // Bubble it in
  bubbleID = *recordsID;
  for(i = 0; i < nodes->cnt; i++) {
    cmp = compareKey(&bubbleID,&nodes->listIDs[i]);
    if (cmp < 0) {
      tmpID = nodes->listIDs[i];
      nodes->listIDs[i] = bubbleID;
      bubbleID = tmpID;
    }
  }
  nodes->listIDs[nodes->cnt] = bubbleID;
  nodes->cnt++;

wrapup:
  return;
}

/* -----------------------------------------------
 * Execute a query using automatic cache
 * Interface to the YVDrisInfo structure
 */
void VDrisQueryCache(IGRint cacheNum, TVDrisInfo *ris, IGRchar *qry)
{
  VDASSERT_FN("VDrisQueryCache");

  TGRid  recordIDs;
  TGRid  recordID;

  IGRint i,cnt;

  xmlNodePtr node;
  xmlAttrPtr attr;
  IGRchar   *p;

  // Arg check
  VDASSERTW(ris);
  ris->rows = ris->cols = 0;
  ris->buf = NULL;

  if (qry == NULL) qry = ris->sql;
  VDASSERTW(*qry);

  // Get the tree
  VDrisDomQueryCache(cacheNum,qry,&recordIDs);
  if (recordIDs.objid == NULL_OBJID) goto wrapup;

  // Cycle through once to get a count
  for(i = 0; VDctxGetNthTreeChild(&recordIDs,i,&recordID); i++) {

    // Count fields for first one
    if (i == 0) {
      node = xdom_nodeid_get_node(&recordID);
      for(attr = node->properties; attr; attr = attr->next) {
        ris->cols++;
      }
    }
    ris->rows++;
  }
  // Alloc buf
  cnt = ris->rows * ris->cols;
  if (cnt == 0) {
    ris->rows = ris->cols = 0;
    goto wrapup;
  }
  ris->buf = g_new(IGRchar *,cnt);

  // Cycle again to copy the data
  cnt = 0;
  for(i = 0; VDctxGetNthTreeChild(&recordIDs,i,&recordID); i++) {

    // Xfer
    node = xdom_nodeid_get_node(&recordID);
    for(attr = node->properties; attr; attr = attr->next) {
      VDctxGetTxtAtrPtr(&recordID,(IGRchar*)attr->name,&p);
      ris->buf[cnt] = strdup(p);
      cnt++;
    }
  }
 
wrapup:
  return;
}

/* ----------------------------------------------
 * Support the old style interface as well
 */
extern void VDrisOldQueryCache(IGRint cacheNum, IGRchar *qry, 
                               IGRint *ncols, IGRint *nrows, IGRchar **results[])
{
  VDASSERT_FN("VDrisOldQueryCache");

  TVDrisInfo ris;

  // Init
  memset(&ris,0,sizeof(TVDrisInfo));

  // Arg check
  VDASSERTW(nrows); *nrows = 0;
  VDASSERTW(ncols); *ncols = 0;
  VDASSERTW(results); *results = NULL;
  VDASSERTW(qry && *qry);

  // Query
  VDrisQueryCache(cacheNum,&ris,qry);

  // Xfer
  *nrows = ris.rows;
  *ncols = ris.cols;
  *results = ris.buf;

wrapup:
  return;
}

/* ----------------------------------------------
 * Delete the cache
 */
//#if 0
void VDrisDeleteCache()
{
    TVDrisCacheInfos *infos;
    IGRint  i;
    IGRchar buf[80];

    // First, decide if the entire structure is allocated yet
    infos = vdGblStaticData10;
    if (infos == NULL) goto wrapup;

    // proceed
    for (i = 0; i < infos->cnt; i++) {


	VDctxFreeNodeList(&infos->infos[i].queryList);
	VDctxDeleteNode  (&infos->infos[i].queryIDs);
	VDctxDeleteNode  (&infos->infos[i].findID);
	g_free(&infos->infos[i]);
    }

    g_free(infos);
    infos = NULL;
    vdGblStaticData10 = NULL;

wrapup:
    return;
}
//#endif

/* ------------------------------------------------
 * Dump the cache to an xml file
 */
void VDrisDumpCache(IGRint cacheNum, IGRchar *fileName)
{
  TVDrisCacheInfo *info = getInfo(cacheNum);

  if (fileName == NULL) fileName = "RisCache.xml";

  VDctxSaveTreeToXmlFile(&info->queryIDs,fileName);
}

/* ------------------------------------------------
 * Be neat to have a load cache as well
 */
IGRstat VDrisLoadCacheFromXmlFile(IGRchar *fileName)
{
    IGRstat retFlag = 0;
    IGRstat sts;
    TVDrisCacheInfo *info = NULL;
    TGRid treeID;
    IGRchar cacheNumB[80];
    IGRint  cacheNum;

    if (fileName == NULL || *fileName == 0) goto wrapup;

    //printf("### fileName = %s\n",fileName);

    
    // Create the tree
    //printf("### Create Tree from XML file\n");
    VDxdomCreateTreeFromXmlFile(fileName,&treeID);
    if (treeID.objid == NULL_OBJID) goto wrapup;

    // get the cache_num attribute from the tree
    *cacheNumB = 0;
    VDctxGetTxtAtr(&treeID,"cache_num",cacheNumB);
    if (*cacheNumB == 0) {
	printf("### XML file is of wrong type\n");
	goto wrapup;
    }
    cacheNum = atoi(cacheNumB);
    //printf("### Cache Num = %d\n",cacheNum);

    // get the info
    info = getInfo(cacheNum);
    if (info == NULL) goto wrapup;

    // delete the queryIDs created in the getInfo
    //printf("### Delete the queryIDs\n");
    VDctxDeleteNode(&info->queryIDs);

    // now, set the queryIDs = treeID
    //printf("### set queryIDs = treeID\n");
    info->queryIDs = treeID;

    // now, index the thing
    //printf("### index the thing\n");
    VDctxGetNodeListByType(&info->queryIDs, "records" , &info->queryList);

    // now, sort the list
    VDctxSortNodeList(&info->queryList,compareKey); 

    //printf("### done\n");
    retFlag = 1;
wrapup:
    return retFlag;
}

/* -----------------------------------------------
 * Utility for outside calls to get the infos
 * */
IGRstat VDrisGetCacheInfos(TVDrisCacheInfos **infos)
{
    IGRstat retFlag = 0;
    
    *infos = vdGblStaticData10;
    if (*infos == NULL) goto wrapup;

    // done
    retFlag = 1;

wrapup:
    return retFlag;
}
