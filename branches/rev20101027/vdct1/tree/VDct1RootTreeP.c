 /* $Id: VDct1RootTreeP.c,v 1.5 2001/04/24 20:43:20 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1RootTreeP.C
 *
 * Description: Posting routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1RootTreeP.c,v $
 *      Revision 1.5  2001/04/24 20:43:20  jdsauby
 *      Post table timestamp, CR4474
 *
 *      Revision 1.4  2001/03/06 20:23:28  paul_noel
 *      Fix TR4795 Missing tm_outfit_dynamic attributes supplied
 *      parent_tree_index and tree_index
 *
 *      Revision 1.3  2001/02/11 17:15:54  ahundiak
 *      Renamed VDris2 to VDrisc
 *
 *      Revision 1.2  2001/02/01 21:25:31  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.2  2000/09/04  14:44:32  pinnacle
 * js
 *
 * Revision 1.1  2000/08/25  19:58:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/24/00  ah      Creation
 * 01/13/01  ah      Convert to c,  changed the way column names are retrieved
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Post2.h"
#include "VDct1Forms.h"
#include "VDct1Trace.h"

#include "VDrisc.h"
#include "VDnfmc.h"

#include "VDpdm.h"           /* Needed for VDpdmPostTableTimestamp  JTS CR 4474 */

VDASSERT_FFN("vdct1/tree/VDct1RootTreeP.c");

#define MY_TREE VDCT1_TREE_TYPE_ROOT_TREE

// Holds all the bits needed for posting
typedef struct 
{
  TVDct1JD      treeJD;  // May not actually use
  TVDctBaseInfo treeBaseInfo;
  
  TVDct1JD     nodeJD;  // May not actually use
  IGRint       sort;
  IGRchar      table_name[40];
  TVDatPDMInfo pdmInfo;
  FILE        *file;
  TVDflds      flds;
} TVDct1PostInfo;

static IGRstat postTreeBeg2(TVDct1JD       *treeJD, 
			    FILE           *file, 
			    IGRint          verbose,
			    TVDct1PostInfo *post);

/* -----------------------------------------------
 * Sets the value of a flds attribute
 * store everything as text
 * Special just for posting
 *
 * If txt is NULL then jnt will have a value
 *
 * Also want to store max field len info somewhere and
 * do length checks here and maybe ris char checks here
 */
static IGRstat postSetAttr(TVDct1JD *treeJD, 
			   TVDflds  *flds, 
			   IGRchar  *name, 
			   IGRchar  *txt,
			   IGRint    jnt)
{
  VDASSERT_FN("postSetAttr");
  IGRstat retFlag = 0;
  
  IGRint  i;
  TVDfld *fld;
  
  // Arg check
  VDASSERTW(flds);
  VDASSERTW(name);
  
  // Find the attribute
  for(i = 0; (i < flds->cnt) && (strcmp(name,flds->fld[i].name)); i++); 
  if (i >= flds->cnt) goto wrapup;
  
  if (txt) strcpy (flds->fld[i].val.txt,txt);
  else     sprintf(flds->fld[i].val.txt,"%d",jnt);
  
  // Done
  retFlag =1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Given a filled in post structure, empty the table
 * of the given tree
 */
static IGRstat postEmptyTable(TVDct1JD *treeJD, TVDct1PostInfo *post)
{
  VDASSERT_FN("postEmptyTable");
  IGRstat retFlag;
  IGRchar sql[256];
  
  // Arg check
  VDASSERTW( post);
  VDASSERTW(*post->table_name);
  VDASSERTW(*post->treeBaseInfo.setType);
  VDASSERTW(*post->treeBaseInfo.setName);
  
  // Do It
  sprintf(sql,
	  "Delete from %s "
	  "where %s=%d and %s='%s' and %s='%s' ",
	  post->table_name,
	  VDCT1_RIS_POST_COLNI_FILE_KEY,
	  post->pdmInfo.key,
	  VDCT1_RIS_POST_COLNC_TREE_TYPE,
	  post->treeBaseInfo.setType,
	  VDCT1_RIS_POST_COLNC_TREE_NAME,
	  post->treeBaseInfo.setName);

  VDrisExecute(sql);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Debugging routine, dump posted tree data
 */
static IGRstat postDumpTree(TVDct1JD *treeJD, FILE *file)
{
  VDASSERT_FN("postDumpTree");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1PostInfo post;
  TVDrisInfo     ris;
  
  // Setup post information
  if (file == NULL) file = stdout;
  sts = postTreeBeg2(treeJD,file,0,&post);
  VDASSERTW(sts & 1);
  
  printf("Dumping %s %s %s\n",
	 post.treeBaseInfo.nodeType,
	 post.treeBaseInfo.nodeName,
	 post.table_name);

  // Query
  VDrisInitInfo(&ris);
  sprintf(ris.sql,
	  "Select %s,%s,%s,%s,%s,%s,%s from %s "
	  "where %s=%d and %s='%s' and %s='%s' "
	  "order by %s;",

	  VDCT1_RIS_POST_COLNI_FILE_KEY,
	  VDCT1_RIS_POST_COLNC_ASSEMBLY_NAM,
	  VDCT1_RIS_POST_COLNI_SORT_KEY,
	  VDCT1_RIS_POST_COLNC_TREE_TYPE,
	  VDCT1_RIS_POST_COLNC_TREE_NAME,
	  VDCT1_RIS_POST_COLNC_NODE_TYPE,
	  VDCT1_RIS_POST_COLNC_NODE_NAME,

	  post.table_name,

	  VDCT1_RIS_POST_COLNI_FILE_KEY,
	  post.pdmInfo.key,
	  VDCT1_RIS_POST_COLNC_TREE_TYPE,
	  post.treeBaseInfo.setType,
	  VDCT1_RIS_POST_COLNC_TREE_NAME,
	  post.treeBaseInfo.setName,

	  VDCT1_RIS_POST_COLNI_SORT_KEY);
  
  VDrisQuery(&ris,NULL);
  
  // Dump it
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {
    ris.j = ris.i * ris.cols;
    fprintf(file,"%3d %s %s %s %s %s %s %s\n",
	   ris.i,
	   ris.buf[ris.j+0],
	   ris.buf[ris.j+1],
	   ris.buf[ris.j+2],
	   ris.buf[ris.j+3],
	   ris.buf[ris.j+4],
	   ris.buf[ris.j+5],
	   ris.buf[ris.j+6]);    
  }
  VDrisFreeInfo(&ris);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Insert the actual record into database
 */
static IGRstat postInsertRecord(TVDct1JD *nodeJD, TVDct1PostInfo *post)
{
  VDASSERT_FN("postInsertRecord");
  
  IGRstat retFlag = 0;

  // Need a big buffer;
  IGRchar sql[4096];
  IGRchar buf[128];
  IGRchar *p;
  
  TVDflds *flds;
  TVDfld  *fld;
  IGRint   i;
  
  // Internal routine, args should be clean
  VDASSERTW(post);
  flds = &post->flds;
  VDASSERTW(flds->cnt);
  
  // Linup for values
  sprintf(sql,"Insert into %s values(\n",post->table_name);
  
  // Cycle through
  for(i = 0; i < flds->cnt; i++) {
    fld = &flds->fld[i];
    switch(fld->type) {

      case VDFLD_TYPE_TXT:
	// Clean txt a bit?
	sprintf(buf,"'%s',",fld->val.txt);
	strcat(sql,buf);
	break;

      case VDFLD_TYPE_INT:
	if (*fld->val.txt) sprintf(buf,"%s,",fld->val.txt);
	else               strcpy (buf,"0,");
	strcat(sql,buf);
	break;

      case VDFLD_TYPE_REAL:
      case VDFLD_TYPE_DOUBLE:
	if (*fld->val.txt) sprintf(buf,"%s,",fld->val.txt);
	else               strcpy (buf,"0.0,");
	strcat(sql,buf);
	break;
    }
  }
  
  // Close paren
  p = strrchr(sql,',');
  if (p) strcpy(p,  ");");
  else   strcat(sql,");");

  // Do it
  // printf("%s\n",sql);
  VDrisExecute(sql);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Fill up the standard attributes for the given node
 */
static IGRstat postFillStandardAttributes(TVDct1JD *nodeJD, TVDct1PostInfo *post)
{
  VDASSERT_FN("postFillStandardAttributes");
  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDflds *flds;
  IGRint   i;
  
  TVDct1JD parentJD;
  
  // Arg check
  VDASSERTW(post);
  flds = &post->flds;
  VDASSERTW(flds->cnt);
  
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  VDASSERTW(*baseInfo.nodeType);

  // Reset all values
  for(i = 0; i < flds->cnt; i++) {
    *flds->fld[i].val.txt = 0;
  }
  
  // The easy stuff
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNI_COMP_SEQNO,  NULL,nodeJD->id.osnum);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_ASSEMBLY_CAT,post->pdmInfo.cat,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_ASSEMBLY_NAM,post->pdmInfo.part,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_ASSEMBLY_VER,post->pdmInfo.rev,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNI_FILE_KEY,    NULL,post->pdmInfo.key);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNI_SORT_KEY,    NULL,post->sort);

  post->sort++;

  // baseInfo
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_TREE_TYPE,baseInfo.setType,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_TREE_NAME,baseInfo.setName,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_TREE_REV, baseInfo.setTypeRev,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_NODE_TYPE,baseInfo.nodeType,0);
  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNC_NODE_NAME,baseInfo.nodeName,0);

  // Parent
  VDjt1GetTreeParent(nodeJD,&parentJD);
  if (parentJD.id.objid == NULL_OBJID) parentJD.id.osnum = 0;

  postSetAttr(nodeJD,flds,VDCT1_RIS_POST_COLNI_PARENT_SEQNO,NULL,parentJD.id.osnum);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------------------------------
 * Provate routine to deal with model attributes
 */
static IGRstat postGetModelAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  VDASSERT_FN("postGetModelAttr");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRobj_env modelOE;
  IGRchar *p;

  TVDatPDMInfo pdmInfo;
  
  // See if want one
  p = strstr(name,VDCT1_RIS_POST_COLNC_MODEL_PREFIX);
  if (p != name) goto wrapup;
  
  // See if have an attached model
  VDjt1GetModelObject(nodeJD,&modelOE);
  if (modelOE.obj_id.objid == NULL_OBJID) goto wrapup;
  
  // Model os file key
  if (!strcmp(name,VDCT1_RIS_POST_COLNI_MODEL_KEY)) {
    VDatPOSTGetPDMInfo(modelOE.obj_id.osnum,&pdmInfo);
    sprintf(value,"%d",pdmInfo.key);
    goto wrapup;
  }

  // Model objid
  if (!strcmp(name,VDCT1_RIS_POST_COLNI_MODEL_OBJID)) {
    sprintf(value,"%d",modelOE.obj_id.objid);
    goto wrapup;
  }
  
  // Unknown model attribute
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Use this to get post attribute values
 * Normally system runs through ACgive_structure which is fine but 
 * has some overhead
 *
 * Also want to do some special processing for connect model objects
 * Don't really want to move into ACgive_struct quite yet
 */
static IGRstat postGetAttr(TVDct1JD *nodeJD, IGRchar *name, IGRchar *value)
{
  VDASSERT_FN("postGetAttr");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  // Arg check
  VDASSERTW(value);
  *value = 0;
  retFlag = 1;
  
  // Regular attribute
  sts = VDjt1GetAttr(nodeJD,name,value);
  if (sts & 1) goto wrapup;

  // Private attribute
  sts = VDjt1GetPrivateAttr(nodeJD,name,value);
  if (sts & 1) goto wrapup;
  
  // Model Attribute
  sts = postGetModelAttr(nodeJD,name,value);
  if (sts & 1) goto wrapup;
  
  // Pass off to ACgive_struct??? maybe,maybe not

  // Give up for now
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Fill up the standard attributes for the given node
 */
static IGRstat postFillCustomAttributes(TVDct1JD *nodeJD, TVDct1PostInfo *post)
{
  VDASSERT_FN("postFillCustomAttributes");
  IGRstat retFlag = 0;
  
  TVDflds *flds;
  TVDfld  *fld;
  IGRint   i;
  
  IGRchar value[128];
  
  // Arg check
  VDASSERTW(post);
  flds = &post->flds;
  VDASSERTW(flds->cnt);
  
  // Need last standard field
  flds = &post->flds;
  for(i = 0; 
      (i < flds->cnt) && (strcmp(flds->fld[i].name,VDCT1_RIS_POST_COLNI_LAST));
      i++);
  
  // Process the remaining attributes
  for(i++; i < flds->cnt; i++) {

    fld = &flds->fld[i];

    // Always get text rep
    postGetAttr(nodeJD,     fld->name,value);
    postSetAttr(nodeJD,flds,fld->name,value,0);
    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Recursive routine to actually post the nodes
 */
static IGRstat postTreeNode(TVDct1JD *nodeJD, TVDct1PostInfo *post)
{
  VDASSERT_FN("postTreeNode");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDctBaseInfo baseInfo;
  TVDct1JD childJD;
  IGRint   i;
  
  // Say Hi
  if (traceFlag) {
    printf("--------------------------------------\n");
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Internal routine so the args should be ok

  // Make sure not at the end
  VDjt1GetBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Log File
  fprintf(post->file,"Post %4d %-12s %s\n",
	  post->sort,
	  baseInfo.nodeType,
	  baseInfo.nodeName);
  
  // Fill up the standard attributes
  sts = postFillStandardAttributes(nodeJD, post);
  VDASSERTW(sts & 1);
  
  // Now the custom ones
  sts = postFillCustomAttributes(nodeJD, post);
  VDASSERTW(sts & 1);

  // Now do the actual post
  sts = postInsertRecord(nodeJD, post);
  VDASSERTW(sts & 1);

  // Update log

  // Repeat for each child
  for(i = 0; VDjt1GetTreeChild(nodeJD,i,&childJD); i++) {
    sts = postTreeNode(&childJD,post);
    VDASSERTW(sts & 1);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  
  return retFlag;
}

/* -----------------------------------------------
 * Master tree poster
 */
static IGRstat postTree(TVDct1JD *treeJD, FILE *file)
{
  VDASSERT_FN("postTree");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1PostInfo post;
  
  // Say Hi
  traceFlagx = traceFlag = 0;
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Arg check
  if (file == NULL) file = stdout;
  
  // Gather a bunch of post information
  sts = postTreeBeg2(treeJD,file,1,&post);
  if (!(sts & 1)) goto wrapup;

  // Empty It
  sts = postEmptyTable(treeJD,&post);
  VDASSERTW(sts & 1);
  
  // And post
  sts = postTreeNode(treeJD,&post);
  VDASSERTW(sts & 1);
  printf("Posted %d nodes\n",post.sort);
  
  // Dump It
  sts = postDumpTree(treeJD,file);
  VDASSERTW(sts & 1);

  // Need to post a post_date for each table posted to (JTS CR 4474)
  VDpdmPostTableTimestamp(post.table_name);
  
  // Done  
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Gets all the stuff ready for posting
 * (Or to retrieve posted information)
 */
static IGRstat postTreeBeg2(TVDct1JD       *treeJD, 
			    FILE           *file, 
			    IGRint          verbose,
			    TVDct1PostInfo *post)
{
  VDASSERT_FN("postTreeBeg2");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid pdmMgrID;
  TVDctBaseInfo *baseInfo;
  
  TVDfld *fld;
  IGRint  i;
  
  TVDrisInfo ris;
  
  // Init
  VDrisInitInfo(&ris);
  
  // Arg check
  VDASSERTW(post);
  memset(post,0,sizeof(TVDct1PostInfo));
  post->treeJD = *treeJD;
  
  // File pointer
  if (file == NULL) file = stdout;
  post->file = file;
  
  // Need info
  baseInfo = &post->treeBaseInfo;
  VDjt1GetBaseInfo(treeJD,baseInfo);
  VDASSERTW(*baseInfo->nodeType);
  
  // Make sure it's postable
  sts = VDjt1IsTreePostable(treeJD);
  if (!(sts & 1)) {
    fprintf(file,"Tree %s %s is not postable\n",
	    baseInfo->setType,
	    baseInfo->setName);
    goto wrapup;
  }
  
  // Mkae sure logged in
  sts = VDrisIsSchemaOpen();
  if (!(sts & 1)) {
    fprintf(file,"Not logged into pdm\n");
    goto wrapup;
  }
  
  // Get the table name
  VDjt1GetTreePostTable(treeJD,post->table_name);
  if (*post->table_name == 0) {
    fprintf(file,"Tree %s %s has no pdm table to post to\n",
	    baseInfo->setType,
	    baseInfo->setName);
    goto wrapup;
  }
  
  // Progress
  if (verbose) {  
    fprintf(file,"==================================\n");
    fprintf(file,"Posting Tree %s %s to %s\n",
	    baseInfo->setType,baseInfo->setName,post->table_name);
  }
  
  // Basically a list of all files
  VDatCreatePdmMgr(OM_K_NOT_AN_OS,&pdmMgrID);
  VDASSERTW(pdmMgrID.objid != NULL_OBJID);
  
  // Get the file stuff from the env
  VDatPOSTGetPDMInfo(treeJD->id.osnum,&post->pdmInfo);
  if (*post->pdmInfo.part == 0) {
    fprintf(stdout,"Tree file is not in pdm database???\n");
    goto wrapup;
  }
  if (verbose) {  
    fprintf(file,"PDM File %s %s %s %d\n",
	    post->pdmInfo.cat,
	    post->pdmInfo.part,
	    post->pdmInfo.rev,
	    post->pdmInfo.key);
  }

  // Need a list of columns in the table
  VDrisQryTableColumns(&ris,post->table_name);
  post->flds.cnt = 0;
  
  // Fill in fld list
  for(ris.i = 0; ris.i < ris.rows; ris.i++) {
    fld = &post->flds.fld[ris.i];
    ris.j = ris.i * ris.cols;
    strcpy(fld->name,ris.buf[ris.j+VDRIS_COLI_COLUMNS_NAME]);
    fld->type = atoi(ris.buf[ris.j+VDRIS_COLI_COLUMNS_TYPE]);

    // Validate type
    switch(fld->type) {
      case VDFLD_TYPE_INT:
      case VDFLD_TYPE_TXT:
      case VDFLD_TYPE_REAL:
      case VDFLD_TYPE_DOUBLE:
	break;
      default:
	fprintf(file,"*** Unsupport ris data type, %d %s\n",fld->type,fld->name);
	VDASSERTW(0);
    }
    post->flds.cnt++;
    if (traceFlag) printf("Column %2d %s\n",fld->type,fld->name);
  }
  if (traceFlag) printf("\n");
  
  // Done
  retFlag = 1;
  
 wrapup:  
  VDrisFreeInfo(&ris);
  return retFlag;
}

static IGRstat postTreeEnd(TVDct1JD *treeJD, FILE *file)
{
  return 1;
}
static IGRstat postTreeBeg(TVDct1JD *treeJD, FILE *file)
{
  return 1;
}

/* -----------------------------------------------
 * Trees are not postable by default
 */
static IGRstat isTreePostable(TVDct1JD *treeJD)
{
  return 0;
}

/* -------------------------------------------------------------------
 * PDM Table - Default to none
 */
static IGRstat getTreePostTable(TVDct1JD *nodeJD, IGRchar *table_name)
{
  VDASSERT_FN("getTreePostTable");
  IGRstat retFlag = 0;
  
  VDASSERTW(table_name);
  
  *table_name = 0;

  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Inits these pointers
 */
IGRstat VDct1InitRootTreeClassP(TVDct1RootTreeClass *cl)
{
  VDASSERT_FN("VDct1InitRootTreeClassP");
  
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_POST);
  //traceFlagx = 1;
  
  // Fill up pointers
  cl->base.isTreePostable   = isTreePostable;
  cl->base.getTreePostTable = getTreePostTable;

  cl->base.postTree    = postTree;
  cl->base.postTreeBeg = postTreeBeg;
  cl->base.postTreeEnd = postTreeEnd;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

