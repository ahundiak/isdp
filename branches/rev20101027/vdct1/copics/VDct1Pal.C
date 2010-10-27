/* $Id: VDct1Pal.C,v 1.2 2001/02/20 15:22:35 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/copics/VDct1Pal.C
 *
 * Description: Convert Pallets
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDct1Pal.C,v $
 * Revision 1.2  2001/02/20 15:22:35  ahundiak
 * ah
 *
 * Revision 1.1  2001/01/11 22:16:23  art
 * sp merge
 *
 * Revision 1.3  2000/10/24  14:04:20  pinnacle
 * js
 *
 * Revision 1.2  2000/10/11  20:22:34  pinnacle
 * js
 *
 * Revision 1.1  2000/07/17  19:21:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/05/00  ah      Creation
 *
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDxml.h"
#include "VDvlaInfo.h"

#include "VDct1Copics.h"

static int traceFlag;

/* -------------------------------------------------------
 * Process node_name
 */
IGRstat VDct1CopProcessNodeName(IGRchar *i_node_name, IGRchar *o_node_name)
{
  IGRstat retFlag = 1;
  IGRchar *p;

  // Drop cage code???
  strcpy(o_node_name,i_node_name);
  p = strstr(o_node_name,"1CC97-");
  if (p == o_node_name) strcpy(o_node_name,o_node_name+6);
    
  // Control codes have snuck in
  for(p = o_node_name; *p >= ' '; p++);
  *p = 0;
  
  // Done
  return retFlag;
}

/* -------------------------------------------------------
 * Sort two copics pals
 */
IGRint VDct1SortCopPal(const void *p1, const void *p2)
{
  TVDct1CopPalInfo *pal1 = *(TVDct1CopPalInfo**)p1;
  TVDct1CopPalInfo *pal2 = *(TVDct1CopPalInfo**)p2;

  IGRdouble qty1,qty2;
  IGRdouble delta;
  
  IGRint sts;

  // By Pallet Code
  sts = strcmp(pal1->pallet_code,pal2->pallet_code);
  if (sts) return sts;

  // Match
  return 0;
}


/* -------------------------------------------------------
 * Sort two copics itemss
 */
IGRint VDct1SortCopItem(const void *p1, const void *p2)
{
  TVDct1CopItemInfo *item1 = *(TVDct1CopItemInfo**)p1;
  TVDct1CopItemInfo *item2 = *(TVDct1CopItemInfo**)p2;

  IGRdouble qty1,qty2;
  IGRdouble delta;
  
  IGRint sts;

  // By Pallet Code
  sts = strcmp(item1->pallet_code,item2->pallet_code);
  if (sts) return sts;

  // By part cage num
  sts = strcmp(item1->node_name,item2->node_name);
  if (sts) return sts;
  
  // By qty
  qty1 = atof(item1->qty);
  qty2 = atof(item2->qty);
  delta = qty1 - qty2;
  
  if (delta < 0.0) return -1;
  if (delta > 0.0) return  1;

  // Match
  return 0;
}

/* ------------------------------------------------------
 * Swap attributes for palette items.
 * qty and um from pct_mino, node_name from copics_num
 */
IGRstat VDct1CopItemSwapAttr(TVDct1CopItemInfo *item)
{
  IGRstat retFlag = 0;

  IGRchar pct_mino[32];
  IGRchar buf[32];
  IGRchar *p,*q;
  
  // set node_name from copics_num attribute
  //printf("### item->copics_num = %s\n",item->copics_num);
  if (strcmp(item->copics_num,"")) strcpy(item->node_name,item->copics_num);

  // set qty and um from pct_mino attribute
  //printf("### item->pct_mino = %s\n",item->pct_mino);
  if (strcmp(item->pct_mino,"")) {
    q = item->pct_mino;
    p = strchr(q,' ');
    if (p) {
      *p = 0;
      strcpy(item->qty,q);

      q = p + 1;
      strcpy(item->um,q);

    }
  }
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
  
/* -------------------------------------------------------
 * Given an index into an array of items, roll the item
 * with any following parts of the same type
 */
IGRstat VDct1CopRollItem(TVDct1CopItemInfo **items,   // I - Array Of Parts
			 IGRint              i,       // I - Index into parts
			 IGRint              cnt,     // I - Number of parts
			 IGRint             *rollCnt, // O - Number rolled
			 IGRdouble          *qty)     // O - Rolled Qty
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (qty)     *qty     = 0.0;
  if (rollCnt) *rollCnt = 0;
  
  if (items == NULL) goto wrapup;
  if (i >= cnt)      goto wrapup;
  
  // Ok
  retFlag = 1;
  
  // Have at least
  while(1) {
    
    // Update qty and roll
    if (qty)     *qty     = *qty + atof(items[i]->qty);
    if (rollCnt) *rollCnt = *rollCnt + 1;
    
    // Have more
    i++;
    if (i >= cnt) goto wrapup;
    
    // Same pallet
    if (strcmp(items[i-1]->pallet_code,items[i]->pallet_code)) {
      goto wrapup;
    }
    
    // Does it match previous
    if (strcmp(items[i-1]->node_name,items[i]->node_name)) {
      goto wrapup;
    }
  }
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * helper function to determine if a pallet has 
 * already been printed or not
 */
static IGRstat isPalDisplayed(TVDct1CopPalInfo  *info,
			      TVDct1CopItemInfo *item,
			      IGRint            i)
{
  IGRstat retFlag = 0;
  IGRint  j;
  
  TVDct1CopItemInfo *itemx;

  // say hi
  if (traceFlag) printf(">>> isPalDisplayed\n");
  
  // i = current location of list
  // display the first one
  if (i == 0) {
    goto wrapup;
  }

  // compare to list of pallettes above current location
  for (j = 0; j < i; j++) {
    itemx = info->items.data[i - (j+1)];
    if (!strcmp(item->pallet_code,itemx->pallet_code)) {
      retFlag = 1;
      goto wrapup;
    }
  }
      
  // done
  retFlag = 0;
  
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * helper function to determine if a pallet has 
 * already been printed or not
 */
static IGRstat isDwgDisplayed(TVDct1CopPalInfo  *info,
			      TVDct1CopItemInfo *item,
			      IGRint            i)
{
  IGRstat retFlag = 0;
  IGRint  j;
  
  TVDct1CopItemInfo *itemx;

  // say hi
  if (traceFlag) printf(">>> isPalDisplayed\n");
  
  // i = current location of list
  // display the first one
  if (i == 0) {
    goto wrapup;
  }

  // compare to list of drawings above current location
  for (j = 0; j < i; j++) {
    itemx = info->items.data[i - (j+1)];
    if (!strcmp(item->dwg_num,itemx->dwg_num)) {
      retFlag = 1;
      goto wrapup;
    }
    
  }
        
  // done
  retFlag = 0;
  
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------------
 * Write the drawing out to file record MC-002
 */
static IGRstat VDct1CopPalWriteCopDwg(TVDct1CopPalInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;

  TVDct1CopItemInfo *item;
    
  // say hi
  if (traceFlag) printf(">>> VDct1CopPalWriteCopDwg\n");

  // display them  
  for (i = 0; i < info->items.cnt; i++) {
    item = info->items.data[i];
    
    // print the first one
    sts = isDwgDisplayed(info,item,i);
    
    if (!(sts & 1)) {
      fprintf(info->file.cop,"MC-002 %-19s\n",item->dwg_num);    
    }
    
  }
  
  // insert a blank line
  fprintf(info->file.cop,"\n");
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Write the palettes out to file record MC-004
 */
static IGRstat VDct1CopPalWriteCopPal(TVDct1CopPalInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;

  TVDct1CopItemInfo *item;
    
  // say hi
  if (traceFlag) printf(">>> VDct1CopPalWriteCopPal\n");

  // display them
  
  for (i = 0; i < info->items.cnt; i++) {
    item = info->items.data[i];
    
    // print the first one
    sts = isPalDisplayed(info,item,i);
    
    if (!(sts & 1)) {
      fprintf(info->file.cop,"MC-004 %-19s\n",item->pallet_code);    
    }
    
  }

  // insert a blank line
  fprintf(info->file.cop,"\n");

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}


/* -------------------------------------------------------
 * Write the loaded info structure to copics
 */
IGRstat VDct1CopPalWriteCopics(TVDct1CopPalInfo *info)
{
  IGRchar fn[] = "VDct1CopPalWriteCopics";
  IGRstat retFlag = 0;
  IGRstat sts;
  
  FILE *file;
  
  IGRdouble qty;
  IGRint    i,rollCnt;
  TVDct1CopItemInfo *item;

  IGRchar node_name[32];
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  if (info == NULL) goto wrapup;
  file = info->file.cop;

  // Swap the attributes around
  for (i = 0; i < info->items.cnt; i++) {
    VDct1CopItemSwapAttr((TVDct1CopItemInfo *)info->items.data[i]);
  }

  // Sort the items
  qsort(info->items.data,info->items.cnt,sizeof(TVDct1CopItemInfo *),VDct1SortCopItem);

  // Process items
  rollCnt = 0;
  for(i = 0; i < info->items.cnt; i += rollCnt) {

    // Roll it
    VDct1CopRollItem((TVDct1CopItemInfo**)info->items.data,i,
		     info->items.cnt,
		     &rollCnt,&qty);

    // Grab It
    item = info->items.data[i];

    // Node Name
    VDct1CopProcessNodeName(item->node_name,node_name);

    // Print it
    fprintf(file,"MC-005 %-7s %-19s %-7s %-19s %-19s %9.2f\n",
	    item->hull_num,
	    item->dwg_num,
	    item->contract_job_num,
	    item->pallet_code,
	    node_name,qty);
    
  }
    
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------------------
 * The main traffic director
 * Need to break into to to handle different inputs
 */
IGRstat VDct1CopPalGenerateCopics(IGRchar           *xmlFileName,
				  IGRchar           *theFileName,
				  TVDct1CopPalInfo  *info)
{
  IGRchar fn[] = "VDct1CopPalGenerateCopics";
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar copFileName[1056];
  IGRchar errFileName[1056];
  IGRchar *p;
  
  //TVDct1CopPalInfo     info;
  TVDxmlParseInfo parseInfo;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",fn,xmlFileName);
  
  // Arg check
  if (xmlFileName == NULL) goto wrapup;

  // Fill up assemblies structure
  sts = VDxmlParseFile(&parseInfo,xmlFileName,VDct1CopPalSaxCallback,info);

  if (*theFileName != NULL) {
    // Setup other files
    strcpy(copFileName,theFileName);
    sprintf(errFileName,"%s.err",theFileName);
    
    // Open Them
    info->file.cop = fopen(copFileName,"wt");
    info->file.err = fopen(errFileName,"wt");
    
    // Write em
    // drawings
    VDct1CopPalWriteCopDwg(info);
    
    // palettes
    VDct1CopPalWriteCopPal(info);
    
    // Allocations
    VDct1CopPalWriteCopics(info);

    
    
    // Close up
    if ((info->file.cop) && (info->file.cop != stdout)) fclose(info->file.cop);
    if ((info->file.err) && (info->file.err != stdout)) fclose(info->file.err);
  }
  
  // Done
  retFlag = 1;
  
wrapup:


  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  //printf("### Translation Complete ###\n");
  
  return retFlag;
}

/* -------------------------------------------------------
 * The main traffic director
 * Need to break into to to handle different inputs
 */
IGRstat VDct1CopPalGenerateCopicsFromBuf(IGRchar *xmlBuf)
{
  IGRchar fn[] = "VDct1CopPalGenerateCopicsFromBuf";
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar theFileName[256];
  IGRchar copFileName[256];
  IGRchar errFileName[256];
  IGRchar *p;
  
  TVDct1CopPalInfo     info;
  TVDxmlParseInfo parseInfo;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Init the data structures
  memset(&info,0,sizeof(TVDct1CopPalInfo));
  vdvla$InitInfo(info = &info.items);
  
  // Arg check
  if (xmlBuf == NULL) goto wrapup;
  
  // Setup master filename
  strcpy(theFileName,"copics");
  p = strrchr(copFileName,'.');
  if (p) *p = 0;
  
  // Setup other files
  sprintf(copFileName,"%s.pal", theFileName);
  sprintf(errFileName,"%s.err",theFileName);
  
  // Open Them
  // info.file.cop = fopen(copFileName,"wt");
  // info.file.err = fopen(errFileName,"wt");
  
  if (info.file.cop == NULL) info.file.cop = stdout;
  if (info.file.err == NULL) info.file.err = stdout;
  
  // Fill up assemblies structure
  sts = VDxmlParseBuf(&parseInfo,NULL,xmlBuf,0,VDct1CopPalSaxCallback,&info);

  // Write em
  VDct1CopPalWriteCopics(&info);
    
  // Close up
  if ((info.file.cop) && (info.file.cop != stdout)) fclose(info.file.cop);
  if ((info.file.err) && (info.file.err != stdout)) fclose(info.file.err);
    
  // Done
  retFlag = 1;
  
wrapup:

  // Free up data structures
  vdvla$FreeInfo(info = &info.items);

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  //printf("### Translation Complete ###\n");
  
  return retFlag;
}








