/* $Id: VDct1LoadRhgr.C,v 1.1 2001/01/12 15:02:14 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/VDct1Rhgr.C
 *
 * Description: Load Part Table Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1LoadRhgr.C,v $
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
 * Revision 1.1  2000/09/14  20:35:36  pinnacle
 * Created: vds/vdct1/test/VDct1LoadRhgr.C by jdsauby for Service Pack
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/11/00  js      Creation
 *
 ***************************************************************************/

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Attrs.h"
#include "VDct1Rhgr.h"
#include "VDobj.h"

/* --------------------------------------
 * check to see that the hanger and its' parts are in OPS
 */
static IGRstat VDct1IsRhgrInOPS(TVDct1RhgrInfo *rhgr)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDrisInfo   ris;
  
  // Arg Check
  if (rhgr == NULL) goto wrapup;
  
  // init
  vdris$InitInfo(info = &ris);
  
  // check for the hanger assembly itself
  VDct1QryPartIdForPartNum(&ris,rhgr->mino);
  if (ris.rows < 1) goto wrapup;

  // check the downcomer
  vdris$InitInfo(info = &ris);
  VDct1QryPartIdForPartNum(&ris,rhgr->mino_dc);
  if (ris.rows < 1) goto wrapup;

  // check the cross tier
  vdris$InitInfo(info = &ris);
  VDct1QryPartIdForPartNum(&ris,rhgr->mino_ct);
  if (ris.rows < 1) goto wrapup;

  // check the bolt
  vdris$InitInfo(info = &ris);
  VDct1QryPartIdForPartNum(&ris,rhgr->mino_bolt);
  if (ris.rows < 1) goto wrapup;

  // check the nut
  vdris$InitInfo(info = &ris);
  VDct1QryPartIdForPartNum(&ris,rhgr->mino_nut);
  if (ris.rows < 1) goto wrapup;

  // done
  retFlag = 1;
  
 wrapup:
  if (ris.buf) vdris$FreeInfo(info = &ris);
  return retFlag;
}

      
      
/* ----------------------------------------
 * create the rhgr assembly
 */
static IGRstat VDct1CreateRhgrAssy(TVDct1RhgrInfo *rhgr,
				   TVDct1JD       *commCodeNodeJD)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1JD  assyNodeJD,dcNodeJD,ctNodeJD,boltNodeJD,nutNodeJD;
  
  IGRchar   assyNodeName[64];
  IGRchar   dcNodeName  [64];
  IGRchar   ctNodeName  [64];
  IGRchar   boltNodeName[64];
  IGRchar   nutNodeName [64];
  
  
  // Arg check
  if (rhgr == NULL) goto wrapup;
  
  // init 
  assyNodeJD.id.objid = NULL_OBJID;
  dcNodeJD.id.objid   = NULL_OBJID;
  ctNodeJD.id.objid   = NULL_OBJID;
  boltNodeJD.id.objid = NULL_OBJID;
  nutNodeJD.id.objid  = NULL_OBJID;

  sprintf(assyNodeName,"%s-%s",rhgr->cage,rhgr->mino);
  sprintf(dcNodeName,  "%s-%s",rhgr->cage,rhgr->mino_dc);
  sprintf(ctNodeName,  "%s-%s",rhgr->cage,rhgr->mino_ct);
  sprintf(boltNodeName,"%s-%s",rhgr->cage,rhgr->mino_bolt);
  sprintf(nutNodeName, "%s-%s",rhgr->cage,rhgr->mino_nut);

  // Create the assembly
  _RTCJDB(commCodeNodeJD)->createNode(commCodeNodeJD,VDCT1_NODE_TYPE_STD_ASSY2,
				      assyNodeName,&assyNodeJD);
  if (assyNodeJD.id.objid == NULL_OBJID) goto wrapup;
  

  // Create the downcomer part
  _RTCJDB(&assyNodeJD)->createNode(&assyNodeJD,VDCT1_NODE_TYPE_STD_PART,
				   dcNodeName,&dcNodeJD);
  if (dcNodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // set the qty attribute
  _RTCJDB(&dcNodeJD)->setAttr(&dcNodeJD,VDCT1_ATTR_ITEM_QTY,rhgr->qty_dc);
  
  // Create the cross tier part
  _RTCJDB(&assyNodeJD)->createNode(&assyNodeJD,VDCT1_NODE_TYPE_STD_PART,
				   ctNodeName,&ctNodeJD);
  if (ctNodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // set the qty attribute
  _RTCJDB(&ctNodeJD)->setAttr(&ctNodeJD,VDCT1_ATTR_ITEM_QTY,rhgr->qty_ct);
  

  // Create the bolts
  _RTCJDB(&assyNodeJD)->createNode(&assyNodeJD,VDCT1_NODE_TYPE_STD_PART,
				   boltNodeName,&boltNodeJD);
  if (boltNodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // set the qty attribute
  _RTCJDB(&boltNodeJD)->setAttr(&boltNodeJD,VDCT1_ATTR_ITEM_QTY,rhgr->qty_bolt);
  

  // Create the nuts
  _RTCJDB(&assyNodeJD)->createNode(&assyNodeJD,VDCT1_NODE_TYPE_STD_PART,
				   nutNodeName,&nutNodeJD);
  if (nutNodeJD.id.objid == NULL_OBJID) goto wrapup;
  
  // set the qty attribute
  _RTCJDB(&nutNodeJD)->setAttr(&nutNodeJD,VDCT1_ATTR_ITEM_QTY,rhgr->qty_nut);
  

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * get the comm_code node under the Master Std Assy Tree
 * if one does not exist, create it.
 */
static IGRstat VDct1GetCommCodeNode(TVDct1JD *commCodeNodeJD)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1JD  setJD,setJDx,rootJD;

  IGRchar setType [64],setName [64];
  IGRchar nodeType[64],nodeName[64];
  
  IGRint  isCase = 1;
  
  TVDctBaseInfo  treeBaseInfo,commBaseInfo;
  
  // init
  rootJD.id.objid          = NULL_OBJID;
  commCodeNodeJD->id.objid = NULL_OBJID;
 
  
  // find a std assy tree node named MASTER
  strcpy(setType,VDCT1_TREE_TYPE_STD_ASSYS);
  strcpy(setName,"MASTER");
  
  // don't want one created, it should already exist
  // Need class pointer
  setJD.cl = VDct1GetTreeClassForSetType(setType);
  
  if (setJD.cl == NULL) goto wrapup;
  setJD.id.objid = NULL_OBJID;
  ex$get_cur_mod(osnum = &setJD.id.osnum);

  // Kick off a standard locate
  memset(&setJDx,0,sizeof(TVDct1JD));
  _RTCJDB(&setJD)->findSetByTypeName(&setJD,isCase,
				     VDCT1_FIND_SET_OPT_CUR_FILE,
				     setType,setName,&setJDx);
  if (setJDx.id.objid == NULL_OBJID) goto wrapup;
  if (setJDx.cl == NULL) goto wrapup;

  // Get root Node for set
  _RTCJDB(&setJDx)->getNodeForSet(&setJDx,&rootJD);
  if (rootJD.id.objid == NULL_OBJID) goto wrapup;
  

  // find CommCode Node with name RHGR
  strcpy(nodeType,VDCT1_NODE_TYPE_COMM_CODE);
  strcpy(nodeName,"RHGR");
  
  _RTCJDB(&rootJD)->findNodeByTypeName(&rootJD,isCase,
				       VDCT1_FIND_NODE_OPT_ENTIRE_TREE,
				       nodeType,nodeName,commCodeNodeJD);
  
  // if found, delete it
  if (commCodeNodeJD->id.objid != NULL_OBJID) {
    _RTCJDB(commCodeNodeJD)->deleteNode(commCodeNodeJD);
  }
  
  // Now, create a new one
  _RTCJDB(&rootJD)->createNode(&rootJD,nodeType,nodeName,commCodeNodeJD);
  if (commCodeNodeJD->id.objid == NULL_OBJID) goto wrapup;
  

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * add a rhgr to rhgrs
 */
static IGRstat VDct1AddRhgrInfo(TVDct1RhgrInfos *infos, TVDct1RhgrInfo *rhgr)
{
  IGRstat retFlag = 0;
  TVDct1RhgrInfo **rhgrs;
  
  // Arg check
  if (rhgr  == NULL)        goto wrapup;
  if (infos == NULL)        goto wrapup;
  if (infos->rhgrs == NULL) goto wrapup;
  
  // Expand list of necessary
  if (infos->cnt == infos->max) {

    rhgrs = realloc(infos->rhgrs,(infos->max + infos->inc) * sizeof(TVDct1RhgrInfo *));

    if (rhgrs == NULL) {
      printf("*** Problem allocating VDct1RhgrInfos list\n");
      goto wrapup;
    }
    infos->rhgrs = rhgrs;
    infos->max  += infos->inc;
  }
  
  // Add it
  infos->rhgrs[infos->cnt] = rhgr;
  infos->cnt++;

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Loads up the rhgrinfo structure
 */
static IGRstat VDct1LoadDelimitedRhgrInfo(TVDct1RhgrInfos *infos,
					  IGRchar         *buf)
{
  IGRstat retFlag = 0;

  TVDct1RhgrInfo *rhgr = NULL;

  IGRint  i;
  IGRchar *p,*q;
  IGRchar bufx[1024];
  
  // Arg check
  if (infos == NULL) goto wrapup;
  if (buf   == NULL) goto wrapup;
  
  // get a hanger
  rhgr = calloc(1,sizeof(TVDct1RhgrInfo));
  if (rhgr == NULL) goto wrapup;
  
  // make a local copy of buf
  strcpy(bufx,buf);
  
  // go through each entry separated by '|' and fill up rhgr
  q = bufx;
  
  // ops_id
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->ops_id,q);
  q = p + 1 ;
  
  // mino
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mino,q);
  q = p + 1 ;
  
  // partnum
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->partnum,q);
  q = p + 1 ;
  
  // type
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->type,q);
  q = p + 1 ;
  
  // comp_code
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->comp_code,q);
  q = p + 1 ;
  
  // material
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->material,q);
  q = p + 1 ;
  
  // mat_abb
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mat_abb,q);
  q = p + 1 ;
  
  // width_1
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->width_1,q);
  q = p + 1 ;
  
  // width_1m
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->width_1m,q);
  q = p + 1 ;
  
  // no_tiers
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->no_tiers,q);
  q = p + 1 ;
  
  // dp
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->dp,q);
  q = p + 1 ;
  
  // dp_m
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->dp_m,q);
  q = p + 1 ;
  
  // dp1
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->dp1,q);
  q = p + 1 ;
  
  // dp1_m
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->dp1_m,q);
  q = p + 1 ;
  
  // dp2
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->dp2,q);
  q = p + 1 ;
  
  // dp2_m
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->dp2_m,q);
  q = p + 1 ;
  
  // mino_dc
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mino_dc,q);
  q = p + 1 ;
  
  // mino_ct
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mino_ct,q);
  q = p + 1 ;
  
  // mino_bolt
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mino_bolt,q);
  q = p + 1 ;
  
  // mino_nut
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mino_nut,q);
  q = p + 1 ;
  
  // qty_dc
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->qty_dc,q);
  q = p + 1 ;
  
  // qty_ct
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->qty_ct,q);
  q = p + 1 ;
  
  // qty_bolt
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->qty_bolt,q);
  q = p + 1 ;
  
  // qty_nut
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->qty_nut,q);
  q = p + 1 ;
  
  // wt_dc
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->wt_dc,q);
  q = p + 1 ;
  
  // wt_ct
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->wt_ct,q);
  q = p + 1 ;
  
  // weight
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->weight,q);
  q = p + 1 ;
  
  // mthd_no
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mthd_no,q);
  q = p + 1 ;
  
  // mthd_type
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->mthd_type,q);
  q = p + 1 ;
  
  // cage
  p = strchr(q,VDCT1_RHGR_DELIM_CHAR);
  if (p == NULL) {
    free (rhgr);
    goto wrapup;
    }
  *p = 0;
  strcpy(rhgr->cage,q);
  q = p + 1 ;
  
  // description = the rest of the string
  strcpy(rhgr->description,q);
  
 
  // add this rhgr to the list of rhgrs
  VDct1AddRhgrInfo(infos,rhgr);
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * reads the text file, one line at a time
 */  
static IGRstat VDct1LoadDelimitedRhgrTextRecord(FILE    *file,
						IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  IGRchar bufx[1024];
  IGRchar *p;
  
  // Read it
  p = fgets(buf,1024,file);
  if (p == NULL) goto wrapup;
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

  
/* ----------------------------------------------
 * loads in rhgr infos from file
 */
static IGRstat VDct1LoadDelimitedRhgrInfosFromFile(TVDct1RhgrInfos *infos,
					    IGRchar         *fileName)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  FILE *file = NULL;
  IGRchar buf[1024];
  
  IGRint cnt = 0;
  
  // arg check
  if (infos == NULL) goto wrapup;
  if (fileName == NULL) goto wrapup;
  
  // Open
  file = fopen(fileName,"rt");
  if (file == NULL) {
    printf("*** Unable to open %s for reading\n",fileName);
    goto wrapup;
  }
  
  
  // Cycle through the file
  while(VDct1LoadDelimitedRhgrTextRecord(file,buf)) {
    
    // Add the buffer to the list
    VDct1LoadDelimitedRhgrInfo(infos,buf);
      
    if (cnt > 2000000) goto wrapup;
    cnt++;
    
  }

  // Done
  retFlag = 1;
  
 wrapup:
  if (file) fclose(file);
  return retFlag;
}

/* -----------------------------------------------
 * Init a rhgrs structure
 */
static IGRstat VDct1InitRhgrInfos(TVDct1RhgrInfos *infos)
{
  IGRstat retFlag = 0;
  
  // Argcheck
  if (infos == NULL) goto wrapup;
  
  // Clear
  memset(infos,0,sizeof(TVDct1RhgrInfos));
  
  // Setup
  infos->max = 1000;
  infos->inc = 1000;
  infos->rhgrs = malloc(infos->max * sizeof(TVDct1RhgrInfo *));

  if (infos->rhgrs == NULL) {
    printf("*** Problem allocating memory for TVDct1PartInfos\n");
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Frees a rhgrs structure
 */
static IGRstat VDct1FreeRhgrInfos(TVDct1RhgrInfos *infos)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  // Argcheck
  if (infos == NULL) goto wrapup;
  if (infos->rhgrs == NULL) goto wrapup;
  
  // Free each record
  for(i = 0; i < infos->cnt; i++) {
    if (infos->rhgrs[i]) free(infos->rhgrs[i]);
  }

  // Free the array of pointers
  free(infos->rhgrs);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (infos) memset(infos,0,sizeof(TVDct1RhgrInfos));
  return retFlag;
}


IGRstat VDct1LoadRhgrAssy(IGRchar *fileName)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDct1RhgrInfos infos;
  TVDct1RhgrInfo  *rhgr;
  
  IGRint  i,cnt;
  IGRint  current_cnt = 0;
  
  FILE *file = NULL;
  IGRchar buf[64];
  
  TVDct1JD  commCodeNodeJD;
  

  //init
  VDct1InitRhgrInfos(&infos);
  commCodeNodeJD.id.objid == NULL_OBJID;
  
  // Get the commCode node for RHGR
  VDct1GetCommCodeNode(&commCodeNodeJD);
  if (commCodeNodeJD.id.objid == NULL_OBJID) {
    UI_status("Problems getting Comm Code");
    goto wrapup;
  }
  
  
  // Load records from the file
  UI_status("Reading rhgrs from file...");
  VDct1LoadDelimitedRhgrInfosFromFile(&infos,fileName);
  
  // Dump File
  file = fopen("rhgr_load.txt","wt");
  if (file == NULL) file = stdout;
  
  // do it
  cnt = infos.cnt;
  for (i = 0; i < cnt; i++) {
    
    rhgr = infos.rhgrs[i];
    sts = VDct1IsRhgrInOPS(rhgr);
       
    if (sts & 1) {
      
      current_cnt++;
      
      VDct1CreateRhgrAssy(rhgr,&commCodeNodeJD);
      
      fprintf(file,"%-19s %-4s %-19s %-4s %-19s %-4s %-19s %-4s %-19s\n",
	      rhgr->mino,
	      rhgr->qty_dc,
	      rhgr->mino_dc,
	      rhgr->qty_ct,
	      rhgr->mino_ct,
	      rhgr->qty_bolt,
	      rhgr->mino_bolt,
	      rhgr->qty_nut,
	      rhgr->mino_nut);
    }
    if (!(i % 10)) {
      sprintf(buf,"Processing %d of %d",i,infos.cnt);
      UI_status(buf);
    }   
  }

  fprintf(file,"### Total Rhgrs Loaded %d\n",current_cnt);
   printf(     "### Total Rhgrs Loaded %d\n",current_cnt);
   sprintf(buf,"Loaded %d rhgrs",current_cnt);
   UI_status(buf);

  // done
  retFlag = 1;
  
  
 wrapup:  
  if ((file) && (file != stdout)) fclose(file);
  VDct1FreeRhgrInfos(&infos);
    
  return retFlag;
}
