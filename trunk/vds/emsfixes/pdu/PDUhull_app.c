/* $Id: PDUhull_app.c,v 1.1.2.2 2004/03/29 16:29:22 ahundiak Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/PDUhull_app.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: PDUhull_app.c,v $
 * Revision 1.1.2.2  2004/03/29 16:29:22  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/16/04  ah      LHAR, Header, lpd specific code is bypassed for lhar
 * -------------------------------------------------------
 */
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDxdom.h"
#include "VDrisc.h"
#include "VDship.h"
#include "VDctx.h"
#include <string.h>

extern char *PDU_dyn_part_search;

static TGRid hullAppIDs;

typedef struct 
{
  char name[32];
} Tfield;

/* --------------------------------------------
 * Fills in PDU_dyn_part_search string for
 * the HULL Apps stuff
 */
static int processHull(char *hulls, int max, int *cnt, Tfield *fields)
{
  char *p,*dash;
  char hull [128];
  char hullx[128];
  char shipClassName[32];

  int beg,end,i;

  /* Keep it simple */
  p = strchr(hulls,',');
  if (p) {
    *p = 0;
    strcpy(hull,hulls);
    strcpy(hulls,p+1);
  }
  else
  {
    strcpy(hull,hulls);
    *hulls = 0;
  }
  /* Strip leading blanks */
  for(p = hull; *p == ' '; p++);
  if (p != hull) strcpy(hull,p);

  /* Strip trailing blanks */
  while((p = strrchr(hull,' '))) *p = 0;

  /* Make sure have something */
  if (*hull == 0) goto wrapup;

  /* Add lpd if only have numbers */
  if ((*hull >= '0') && (*hull <= '9')) 
  {
    VDshipGetClassName(shipClassName);
    strcpy(hullx,hull);
    sprintf(hull,"%s%s",shipClassName,hullx);
  }

  /* Pull out any range */
  dash = strchr(hull,'-');
  if (dash) *dash = 0;

  /* Store first one */
  if (*cnt >= max) goto wrapup;
  strcpy(fields[*cnt].name,hull);
  *cnt = *cnt + 1;

  /* If no range then done */
  if (dash == 0) goto wrapup;

  /* Range */
  end = atoi(dash+1);
  if (end > 99) end = 99;

  for(p = dash-1; (p >= hull) && ((*p >= '0') && (*p <= '9')); p--);
  p++;
  beg = atoi(p) + 1;
  if (beg < 0) beg = 0;
  *p = 0;

  for(i = beg; i <= end; i++)
  {
    if (*cnt >= max) goto wrapup;
    sprintf(fields[*cnt].name,"%s%d",hull,i);
    *cnt = *cnt + 1;
  }

wrapup:
  return 1;
}
static int processNode(TGRid *nodeID)
{
  char *data;
  char hulls[256];

  Tfield fields[30];
  int  max = 30;
  int  cnt = 0;

  int  len,i;

  /* Check for where clause */
  VDctxGetTxtAtrPtr(nodeID,"where",&data);
  if (data && strlen(data))
  {
    PDU_dyn_part_search = malloc(strlen(data) + 6 + 1);
    sprintf(PDU_dyn_part_search,"WHERE %s",data);
    goto wrapup;
  }
  /* Check for hulls */
  VDctxGetTxtAtrPtr(nodeID,"hull",&data);
  if (!data || !strlen(data)) goto wrapup;

  /* Make a copy since the buffer will be changed */
  strcpy(hulls,data);
  while(*hulls) {
    processHull(hulls,max,&cnt,fields);
  }

  /* See if got any */
  if (cnt == 0) goto wrapup;

  /* Calc size */
  len = 6 + 1;
  for(i = 0; i < cnt; i++)
  {
    len += strlen(fields[i].name) + 20; /* Little bit extra */
  }

  /* Fill it up */
  PDU_dyn_part_search = malloc(len);
  strcpy(PDU_dyn_part_search,"WHERE ");
  for(i = 0; i < cnt; i++)
  {
    if (i) strcat(PDU_dyn_part_search," AND "); 
    strcat(PDU_dyn_part_search,fields[i].name);
    strcat(PDU_dyn_part_search,"='Y'");
  }

wrapup:
  return 1;
}
int PDUfill_hull_app_search(Form form, int gadget)
{
  char show [128];
  char showx[128];
  TGRid hullAppID;
  int i;

  /* Init */
  PDU_dyn_part_search = NULL;

  /* See if something has been picked */
  VDfrmGetgText(form,gadget,show);
  if (!strcasecmp(show,"All")) goto wrapup;

  /* Make sure have a tree */
  if ((hullAppIDs.objid == NULL_OBJID) || 
      (hullAppIDs.objid == 0)) goto wrapup;

  /* Look it up */
  for(i = 0; VDctxGetNthTreeChild(&hullAppIDs,i,&hullAppID); i++)
  {
    VDctxGetTxtAtr(&hullAppID,"show",showx);
    if (!strcasecmp(show,showx))
    {
      /* Process it */
      processNode(&hullAppID);
      goto wrapup;
    }
  }

  /* Done */
wrapup:
  return 1;
}

/* --------------------------------------------
 * CR7415 Fill in Hull App Pick List
 */
int PDUfill_hull_app_pick_list(Form form, int gadget)
{ 
  IGRchar path[128];
  IGRchar buf [128];

  TGRid   hullAppID;
  IGRint  row,i;

  // Init 
  VDfrmSetgText(form,gadget,"All");
  VDfrmSetgListNumRows(form,gadget,0);
  VDfrmSetgListText   (form,gadget,0,"All");

  /* Delete any existing tree */
  if ((hullAppIDs.objid != NULL_OBJID) ||
      (hullAppIDs.objid != 0))
  {
    VDxdomDeleteNode(&hullAppIDs);
    hullAppIDs.objid = NULL_OBJID;
  }

  // Create the tree
  VDsysFindFile("config/xml","hull_app_list.xml",path);
  if (*path == 0) goto wrapup;
  
  VDxdomCreateTreeFromXmlFile(path,&hullAppIDs);
  if (hullAppIDs.objid == NULL_OBJID) goto wrapup;

  // Fill up the pick lists
  for(i = 0, row = 1; VDctxGetNthTreeChild(&hullAppIDs,i,&hullAppID); i++)
  {
    VDctxGetTxtAtr(&hullAppID,"show",buf);
    if (*buf) {
      VDfrmSetgListText(form,gadget,row,buf);
      row++;
    }
  }
wrapup:
  return 1;
}

/* ----------------------------------------------
 * Return 1 if the part is 17 and follow
 */
static int is17af(char *catalog, char *part, char *rev)
{
  int flag = 0;
  TVDrisInfo ris;
  int i;
  char shipClassName[32];

  /* Init */
  VDrisInitInfo(&ris);

  /* Only defined for the lpd class */
  VDshipGetClassName(shipClassName);
  if (strcmp(shipClassName,"lpd")) goto wrapup;

  /* Need everything */
  if (*catalog == 0) goto wrapup;
  if (*part    == 0) goto wrapup;
  if (*rev     == 0) goto wrapup;

  /* Make sure catalog has field */
  sprintf(ris.sql,
          "SELECT %s FROM %s WHERE %s='%s' AND %s='lpd17'",
          VDRIS_COLN_COLUMNS_POS,
          VDRIS_TBLN_COLUMNS,
          VDRIS_COLN_COLUMNS_TABLE,
          catalog,
          VDRIS_COLN_COLUMNS_NAME);

  VDrisQueryCache(VDRIS_CACHE_VDS,&ris,NULL);
  if (ris.rows == 0) goto wrapup;
  VDrisFreeInfo(&ris);
 
  /* The full query */
  sprintf(ris.sql,
    "SELECT lpd17,lpd18,lpd19,lpd20,lpd21,lpd22,lpd23,lpd24,lpd25,lpd26,lpd27,lpd28 "
    "FROM %s WHERE n_itemname='%s' AND n_itemrev='%s'",
    catalog,part,rev);
  VDrisQueryCache(VDRIS_CACHE_VDS,&ris,NULL);
  if (ris.rows == 0) goto wrapup;

  flag = 1;
  for(i = 0; i < ris.cols; i++)
  {
    if (strcasecmp(ris.buf[i],"Y")) flag = 0;
  }

wrapup:
  VDrisFreeInfo(&ris);
  return flag;
}

/* ----------------------------------------------
 * This is a post processing routine which takes
 * a list gadget and fills in the LPD17 and FOLLOW
 * column
 */
void PDUfill_parts_list_hull_app(Form form, int gadget)
{
  int flag;
  int row,rows;
  char catalog[32],part[32],rev[32];

  int col_cat,col_part,col_rev,col_flag;

  /* Two gadgets supported */
  switch(gadget)
  {
    case 11:
      col_cat  = 0;
      col_part = 1;
      col_rev  = 2;
      col_flag = 9;
      break;

    case 57:
      col_cat  = 1;
      col_part = 2;
      col_rev  = 3;
      col_flag = 8;
      break;

    default: goto wrapup;
  }

  /* Get number of rows */
  VDfrmGetNumRows(form,gadget,&rows,NULL,NULL);
  if (rows) UI_status("Getting hull app...");


  /* Cycle through */
  for(row = 0; row < rows; row++)
  {
    VDfrmGetfText(form,gadget,row,col_cat, catalog);
    VDfrmGetfText(form,gadget,row,col_part,part);
    VDfrmGetfText(form,gadget,row,col_rev, rev);

    flag = is17af(catalog,part,rev);

    /* printf("%d %d %s %s %s\n",row,flag,catalog,part,rev); */

    if (flag == 0) VDfrmSetfText(form,gadget,row,col_flag,"*");
  }
  if (rows) UI_status("");

  /* Done */
wrapup:
  return;
}
