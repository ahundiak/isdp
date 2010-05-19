/* $Id: VDct1CopCmd.C,v 1.1 2001/01/11 22:16:23 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/copics/VDct1Assy.C
 *
 * Description: Convert Assemblys
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDct1CopCmd.C,v $
 * Revision 1.1  2001/01/11 22:16:23  art
 * sp merge
 *
 * Revision 1.4  2000/10/25  14:39:10  pinnacle
 * js
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
#include <stdio.h>
#include <FI.h>
#include "VDtypedef.h"
#include "VDxml.h"
#include "VDvlaInfo.h"

#include "VDct1Copics.h"
#include "VDct1CopForm.h"

static int traceFlag;

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

/* --------------------------------------------------
 * display all drawings
 */
static IGRstat viewDwgPalInfo(Form             *form,
			      TVDct1CopPalInfo *info,
			      IGRint           *rowCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,cnt;
  IGRchar viewDwg[1056];

  TVDct1CopItemInfo *item;
    
  // say hi
  if (traceFlag) printf(">>> viewDwgPalInfo\n");

  // init
  *viewDwg = 0;
  
  // display them
  cnt = *rowCnt;
  
  for (i = 0; i < info->items.cnt; i++) {
    item = info->items.data[i];
    
    // print the first one
    sts = isDwgDisplayed(info,item,i);
    
    if (!(sts & 1)) {
      sprintf(viewDwg,"MC-002 %-19s",item->dwg_num);    
      FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, cnt, 0, viewDwg, 0);
      cnt++;
    }
    
  }
  

  // done
  *rowCnt = cnt;
  
  retFlag = 1;
  
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

/* -----------------------------------------------------
 * show only palette codes
 */
static IGRstat viewPalPalInfo(Form             *form,
			      TVDct1CopPalInfo *info,
			      IGRint           *rowCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i,cnt;
  IGRchar viewPal[1056];

  TVDct1CopItemInfo *item;
    
  // say hi
  if (traceFlag) printf(">>> viewPalPalInfo\n");

  // init
  *viewPal = 0;
  
  // display them
  cnt = *rowCnt;
  
  for (i = 0; i < info->items.cnt; i++) {
    item = info->items.data[i];
    
    // print the first one
    sts = isPalDisplayed(info,item,i);
    
    if (!(sts & 1)) {
      sprintf(viewPal,"MC-004 %-19s",item->pallet_code);    
      FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, cnt, 0, viewPal, 0);
      cnt++;
    }
    
  }
  

  // done
  *rowCnt = cnt;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}



/* ------------------------------------------------------
 * process the palette info
 */
static IGRstat viewAllocPalInfo(Form             *form,
				TVDct1CopPalInfo *info,
				IGRint           *rowCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRdouble qty;
  IGRint    i,rollCnt,cnt;
  TVDct1CopItemInfo *item;

  IGRchar node_name[32];
  IGRchar viewPal[1056];
  
  // say hi
  if (traceFlag) printf(">>> viewAllocPalInfo\n");
      
  // Arg check
  if (info == NULL) goto wrapup;
 
  // Swap the attributes around
  for (i = 0; i < info->items.cnt; i++) {
    VDct1CopItemSwapAttr((TVDct1CopItemInfo *)info->items.data[i]);
  }
  
  // Sort the items
  qsort(info->items.data,info->items.cnt,sizeof(TVDct1CopItemInfo *),VDct1SortCopItem);

  // Process items
  cnt = *rowCnt;
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
    sprintf(viewPal,"MC-005 %-7s %-19s %-7s %-19s %-19s %9.2f\n",
	    item->hull_num,
	    item->dwg_num,
	    item->contract_job_num,
	    item->pallet_code,
	    node_name,qty);
    
    FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, cnt, 0, viewPal, 0);
    cnt++;
    
  }

  // done
  *rowCnt = cnt;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Process all pal info
 */
static IGRstat viewAllPalInfo(Form             *form,
			      TVDct1CopPalInfo *info)
{ 
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  rowCnt = 0;
  
  
  // say hi
  if (traceFlag) printf(">>> viewAllPalInfo\n");
  
  // drawings
  sts = viewDwgPalInfo(form,info,&rowCnt);
  if (!(sts & 1)) goto wrapup;

  // palettes
  rowCnt++;
  sts = viewPalPalInfo(form,info,&rowCnt);
  if (!(sts & 1)) goto wrapup;

  // allocations
  rowCnt++;
  sts = viewAllocPalInfo(form,info,&rowCnt);
  if (!(sts & 1)) goto wrapup;
  

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -------------------------------------------------------
 * Process an assembly
 */
static IGRstat viewCopAssyProcess(Form              *form,
				  TVDct1CopAssyInfo *assy,
				  IGRint            *rowCnt)
{
  IGRstat retFlag = 0;
  
  IGRint i,rollCnt,newCnt;
  TVDct1CopPartInfo *part;
  
  IGRchar   assy_node_name[128];
  IGRchar   viewAssy      [1056];
  IGRchar   part_node_name[128];
  IGRchar   viewPart      [1056];
  
  IGRdouble qty;
  
  // Say Hi
  if (traceFlag) printf(">>> viewCopAssyProcess\n");
  
  // Process node name
  VDct1CopProcessNodeName(assy->node_name,assy_node_name);

  // Write It
  newCnt = *rowCnt;
  
  sprintf(viewAssy,"BM-001 %-25s 2 %-10s EA\n",
	  assy_node_name,
	  assy->comm_code);    
  FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, newCnt, 0, viewAssy, 0);
  
  newCnt++;

  // swap part attributes
  for (i = 0; i < assy->parts.cnt; i++) {
    VDct1CopPartSwapAttr((TVDct1CopPartInfo *)assy->parts.data[i]);
  }

  // Sort the parts
  qsort(assy->parts.data,assy->parts.cnt,sizeof(TVDct1CopPartInfo *),VDct1SortCopPart);
  
  // Do each part
  rollCnt = 0;
  for(i = 0; i < assy->parts.cnt; i += rollCnt) {

    // Roll it
    VDct1CopRollPart((TVDct1CopPartInfo**)assy->parts.data,i,
		     assy->parts.cnt,
		     &rollCnt,&qty);
    
    // Get part
    part = assy->parts.data[i];
    
    // Node name
    VDct1CopProcessNodeName(part->node_name,part_node_name);

    // And write
    sprintf(viewPart,"BM-002 %-25s %-25s %9.2f\n",
	    assy_node_name,
	    part_node_name,
	    qty);
    FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, newCnt, 0, viewPart, 0);

    newCnt++;
    
  }
  
  
  // Done
  *rowCnt = newCnt + 1;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


/* -------------------------------------------------------
 * viewAssy Info on form
 */
static IGRstat viewAssysInfo(Form             *form,
			     TVDct1CopEngInfo *info,
			     IGRint           *rowCnt)
{

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i;
  TVDct1CopAssyInfo *assy;
  TVDct1CopAssyInfo *assyx;
  
  // Say hi
  if (traceFlag) printf(">>> viewAssysInfo\n");
  
  // Sort the assemblies
  qsort(info->assys.data,info->assys.cnt,sizeof(TVDct1CopAssyInfo *),VDct1SortCopAssy);

  // Process assemblies one at a time
  for(i = 0; i < info->assys.cnt; i++) {
    assy = info->assys.data[i];

    // do the first one
    if (i == 0) viewCopAssyProcess(form,assy,rowCnt);

    // do the rest
    if (i > 0) {
      assyx = info->assys.data[i-1];
      if (strcmp(assy->node_name,assyx->node_name))
	viewCopAssyProcess(form,assy,rowCnt);
    }
        
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------
 * print a part to the form
 */
static IGRstat viewCopPartProcess(Form              *form,
				  IGRint            i,
				  TVDct1CopPartInfo *part)
{
  IGRchar viewPart[1056];
  IGRchar part_node_name[32];
  
  // process the node_name
  VDct1CopProcessNodeName(part->node_name,part_node_name);

  // gather the string
  sprintf(viewPart,"BM-001 %-25s 4    %-10s %-2s\n",
	  part_node_name,
	  part->comm_code,
	  part->um);

  // update the form
  FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, i, 0, viewPart, 0);

  // done
  return 1;
}

/* ------------------------------------------------
 * viewParts on form
 */
static IGRstat viewPartsInfo(Form             *form,
			     TVDct1CopEngInfo *info,
			     IGRint           *rowCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i,cnt;
  IGRchar header[1056];
  
  TVDct1CopPartInfo *part,*partx;
  
  // Say hi
  if (traceFlag) printf(">>> viewPartsInfo\n");
  
  // swap part attributes
  for (i = 0; i < info->parts.cnt; i++) {
    VDct1CopPartSwapAttr((TVDct1CopPartInfo *)info->parts.data[i]);
  }

  // Sort the parts
  qsort(info->parts.data,info->parts.cnt,sizeof(TVDct1CopPartInfo *),VDct1SortCopPart);

  // place the part header on the form
  cnt = *rowCnt;
  //sprintf(header,"RECORD %-25s TYPE %-10s %-2s\n","MINO","COMM CODE","UM");
  //FIfld_set_text(form, VDCT1_FORM_COP_G_VIEW_AREA, cnt, 0, header, 0);
  //cnt++;
  
  // Process Parts one at a time
  for(i = 0; i < info->parts.cnt; i++) {
    part = info->parts.data[i];
    
    // must print the first one
    if (i == 0) {
      viewCopPartProcess(form,cnt,part);
      cnt++;
    }
    
    // printing the rest  
    if (i > 0) {
      partx = info->parts.data[i-1];
        
      // use node name to compare
      if (strcmp(part->node_name,partx->node_name)) {
	
	viewCopPartProcess(form,cnt,part);
	cnt++;
      }
    }
    *rowCnt = cnt;
    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------
 * view all the BM assy info
 */
static IGRstat viewAllAssyInfo(Form             *form,
			       TVDct1CopEngInfo *info)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint rowCnt = 0;
    
  // say hi
  if (traceFlag) printf(">>> viewAllAssyInfo\n");
  
  // display the parts
  viewPartsInfo(form,info,&rowCnt);
    
  // display the assemblies
  rowCnt++;
  viewAssysInfo(form,info,&rowCnt);
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------
 * helper function to get the .xml files
 */
static IGRstat getXMLFileNames(IGRchar *filePath,
			       IGRchar **fileNames,
			       IGRint  *fileCnt)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar lsCmd[1056],rmCmd[1056];
  IGRchar fileName[1056];
  IGRint  i;
  IGRchar buf[1056],bufx[80];
  IGRchar *p,*q;
      
  FILE    *file = NULL;
  
  // say hi
  if (traceFlag) printf(">>> getXMLFileNames\n");

  // init
  *lsCmd = 0;
  *rmCmd = 0;
  
  // make the system commands
  sprintf(lsCmd,"\\ls %s/*.xml > %s/.lsxml",filePath, filePath);
  sprintf(rmCmd,"rm %s/.lsxml",filePath);
  
  // execute system ls command
  system(lsCmd);

  // open the file for processing
  sprintf(fileName,"%s/.lsxml",filePath);
  
  file = fopen(fileName,"rt");
  if (file == NULL) {
    printf("## Could not open %s\n",fileName);
    goto wrapup;
  }
  
  // process the file
  i = 0;
  while(fgets(buf,sizeof(buf),file)) {
    
    // clean out the path
    q = buf;
    while(p = strchr(q,'/')) {
      q = p + 1;
      *p = 0;
    }

    // clean out any trailing characters
    for(p = q; *p > ' '; p++); *p = 0;
    if (q) {
      fileNames[i] = (IGRchar*)malloc(sizeof(buf));
      strcpy(fileNames[i],q);
      
      *fileCnt = i + 1;
      i++;
    }
    
  }  // end of while
  
  // done
  retFlag = 1;
  
 wrapup:
  // close file
  if (file) fclose(file);
  // remove file
  system(rmCmd);
  
  return retFlag;
}

/* --------------------------------------
 * set the extension on the output file
 */
static IGRstat setOutputFileExtension(Form    *form,
				      IGRchar *a_outFile)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  state;
  
  IGRchar fileExt[24],*p,*q;
  IGRchar outFile[80];
  
  // say hi
  if (traceFlag) printf(">>> setOutputFileExtension\n");
  
  // init
  *fileExt = 0;
  
  // the state determines the extension
  // 0 - BMIT (.bm)
  // 1 - MCAU (.mc)
  FIg_get_state(form, VDCT1_FORM_COP_T_MCBM, &state);

  if (state == 0) strcpy(fileExt,".bm");
  if (state == 1) strcpy(fileExt,".mc");
  if (*fileExt == 0) goto wrapup;

  // do it
  if (a_outFile == NULL) FIg_get_text(form, VDCT1_FORM_COP_G_OUT_F, outFile);
  else strcpy(outFile,a_outFile);
  
  q = outFile;
  p = strchr(q,'.');
  
  if (p == NULL) {
    strcat(outFile,fileExt);
  }
  
  else {
    *p = 0;
    strcpy(outFile,q);
    strcat(outFile,fileExt);
  }

  // set the text on the form
  FIg_set_text(form, VDCT1_FORM_COP_G_OUT_F, outFile);

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ---------------------------------------
 * Set the view options text
 */
static IGRstat getViewOptGadgetText(IGRint  state,
				    IGRint  i,
				    IGRchar *buf)
{
  IGRstat retFlag = 1;

  if (traceFlag) printf(">>>getViewOptGadgetText, %d, %d\n",state,i);
  
  if (state == 0) {    // BMIT
    
    switch (i) {
      case 0: strcpy(buf,"1 - All");        goto wrapup;
      case 1: strcpy(buf,"2 - Parts");      goto wrapup;
      case 2: strcpy(buf,"3 - Assemblies"); goto wrapup;
      default: retFlag = 0;                 goto wrapup;
    }
  }
  
  if (state == 1) {    // MCAU
    
    switch (i) {
      case 0: strcpy(buf,"1 - All");         goto wrapup;
      case 1: strcpy(buf,"2 - Drawings");    goto wrapup;
      case 2: strcpy(buf,"3 - Palettes");    goto wrapup;
      case 3: strcpy(buf,"4 - Allocations"); goto wrapup;
      default: retFlag = 0;                  goto wrapup;
    }
  }
	
  // done
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------
 * write file button was pushed
 */
static IGRstat notifyWriteFile(Form *form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  state;
  IGRchar xmlFilePath[1056];
  IGRchar xmlFileName[1056];
  IGRchar outFileName[1056];
  IGRchar outFilePath[1056];
  
  IGRint  i;
  TVDct1CopEngInfo   engInfo;
  TVDct1CopPalInfo   palInfo;
  TVDct1CopAssyInfo *assy;

  // say hi
  if (traceFlag) printf(">>> notifyWriteFile\n");
  
  // init
  *xmlFileName = NULL;
  *xmlFilePath = NULL;
  *outFileName = NULL;
  *outFilePath = NULL;
  
  // Init the data structures
  memset(&engInfo,0,sizeof(TVDct1CopEngInfo));
  vdvla$InitInfo(info = &engInfo.assys);
  vdvla$InitInfo(info = &engInfo.parts);
  
  memset(&palInfo,0,sizeof(TVDct1CopPalInfo));
  vdvla$InitInfo(info = &palInfo.items);

  // get the xml file path
  FIg_get_text(form, VDCT1_FORM_COP_G_PATH, xmlFilePath);
  if (*xmlFilePath == NULL) strcpy(xmlFilePath,"./");
  else                      strcat(xmlFilePath,"/");

  strcpy(outFilePath,xmlFilePath);

  // get the xml file name
  FIg_get_text(form, VDCT1_FORM_COP_G_XML_F, xmlFileName);
  if (*xmlFileName == NULL) goto wrapup;
  strcat(xmlFilePath,xmlFileName);
  
  // get the out file name
  FIg_get_text(form, VDCT1_FORM_COP_G_OUT_F, outFileName);
  if (*outFileName == NULL) goto wrapup;
  
  strcat(outFilePath,outFileName);

  // get the state of the toggle
  // state = 0  --> BMIT
  // state = 1  --> MCAU
  FIg_get_state(form, VDCT1_FORM_COP_T_MCBM, &state);
  
  if (state == 0) {
    VDct1CopAssyGenerateCopics(xmlFilePath,outFilePath,&engInfo);
  }
    
  else {
    VDct1CopPalGenerateCopics(xmlFilePath,outFilePath,&palInfo);
  }
  
  // done
  retFlag = 1;
  
 wrapup:
  
  // Free up data structures
  for(i = 0; i < engInfo.assys.cnt; i++) {
    assy = engInfo.assys.data[i];
    vdvla$FreeInfo(info = &assy->parts);
  }
  vdvla$FreeInfo(info = &engInfo.assys);
  vdvla$FreeInfo(info = &engInfo.parts);
  vdvla$FreeInfo(info = &palInfo.items);

  return retFlag;
}

/* ------------------------------------
 * Display the correct info in the view area 
 * based on viewing options
 */
static IGRstat notifyViewFile(Form *form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar viewOpt[80];
  IGRint  state;
  IGRchar xmlFilePath[1056];
  IGRchar xmlFileName[1056];
  IGRchar outFileName[1056];
  IGRint  i,rowCnt; 
 
  TVDct1CopEngInfo   engInfo;
  TVDct1CopPalInfo   palInfo;
  TVDct1CopAssyInfo *assy;

  // say hi
  if (traceFlag) printf(">>> notifyViewFile\n");
  
  // init
  *xmlFileName = NULL;
  *xmlFilePath = NULL;
  *viewOpt     = NULL;
  *outFileName = NULL;
  
  // Init the data structures
  memset(&engInfo,0,sizeof(TVDct1CopEngInfo));
  vdvla$InitInfo(info = &engInfo.assys);
  vdvla$InitInfo(info = &engInfo.parts);

  memset(&palInfo,0,sizeof(TVDct1CopPalInfo));
  vdvla$InitInfo(info = &palInfo.items);
  
  // get the option
  FIg_get_text(form, VDCT1_FORM_COP_G_VIEW_OPT, viewOpt);
  if (*viewOpt == NULL) goto wrapup;
  
  // get the xml file path
  FIg_get_text(form, VDCT1_FORM_COP_G_PATH, xmlFilePath);
  if (*xmlFilePath == NULL) strcpy(xmlFilePath,"./");
  else                      strcat(xmlFilePath,"/");
  
  // get the xml file name
  FIg_get_text(form, VDCT1_FORM_COP_G_XML_F, xmlFileName);
  if (*xmlFileName == NULL) goto wrapup;
  strcat(xmlFilePath,xmlFileName);
  
  // get the state of the toggle
  // state = 0  --> BMIT
  // state = 1  --> MCAU
  FIg_get_state(form, VDCT1_FORM_COP_T_MCBM, &state);
  
  if (state == 0) {
    FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Processing . . .");
    VDct1CopAssyGenerateCopics(xmlFilePath,outFileName,&engInfo);
    
    switch (*viewOpt) {

      case '1':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
	
	
	sts = viewAllAssyInfo(form,&engInfo);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;

      case '2':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
	
	rowCnt = 0;
	sts = viewPartsInfo(form,&engInfo,&rowCnt);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;
	
      case '3':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
	
	rowCnt = 0;
	sts = viewAssysInfo(form,&engInfo,&rowCnt);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;
	
    }  // end of switch BMIT
  } // end of state = 0
  
  else {
    
    FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Processing . . .");
    VDct1CopPalGenerateCopics(xmlFilePath,outFileName,&palInfo);
    
    switch (*viewOpt) {
      
      case '1':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
		
	sts = viewAllPalInfo(form,&palInfo);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;

      case '2':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
	rowCnt = 0;
	sts = viewDwgPalInfo(form,&palInfo,&rowCnt);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;
	
      case '3':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
	rowCnt = 0;
	sts = viewPalPalInfo(form,&palInfo,&rowCnt);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;
	
      case '4':
	FIg_reset(form, VDCT1_FORM_COP_G_VIEW_AREA);
	rowCnt = 0;
	sts = viewAllocPalInfo(form,&palInfo,&rowCnt);
	if (!(sts & 1)) {
	  printf("## Could not view info\n");
	  retFlag = 0;
	}
	FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Do Something");
	break;
		  
    }  // end of switch MCAU
  } // end of state = 1
  
  // done
  retFlag = 1;
  
 wrapup:
  
  // Free up data structures
  for(i = 0; i < engInfo.assys.cnt; i++) {
    assy = engInfo.assys.data[i];
    vdvla$FreeInfo(info = &assy->parts);
  }
  vdvla$FreeInfo(info = &engInfo.assys);
  vdvla$FreeInfo(info = &engInfo.parts);
  vdvla$FreeInfo(info = &palInfo.items);
  return retFlag;
}

/* -------------------------------------
 * get .xml files from selected path
 */
static IGRstat notifyXMLFile(Form *form)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar filePath  [1056];
  IGRchar *fileNames[1056];
  IGRint  fileCnt;
  IGRint  i;
  IGRchar outFile[80];
  
  // say hi
  if (traceFlag) printf(">>> notifyXMLFile\n");

  // init
  *filePath  = 0;
  *fileNames = 0;
  fileCnt    = 0;
  *outFile   = 0;
  
  // get the path
  FIg_get_text(form, VDCT1_FORM_COP_G_PATH, filePath);
  if (*filePath == 0) strcpy(filePath,".");
  
  // get the .xml files listed in path
  sts = getXMLFileNames(filePath,fileNames,&fileCnt);
  if (*fileNames == 0) {
    FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Cannot Find any XML files in Path");
    goto wrapup;
  }

  // reset the list on form
  FIfld_set_list_num_rows(form, VDCT1_FORM_COP_G_XML_F, 0, 0);
  
  // set the text for the list
  for (i = 0; i < fileCnt ; i++) {
    FIfld_set_list_text(form, VDCT1_FORM_COP_G_XML_F, i, 0, fileNames[i], 0);
  }

  // set the output file
  FIg_get_text(form, VDCT1_FORM_COP_G_XML_F, outFile);
  sts = setOutputFileExtension(form,outFile);
  if (!(sts & 1)) {
    FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Could not reset Output File Extension");
    goto wrapup;
  }

  // done
  retFlag = 1;
  
 wrapup:
  // free up fileNames
  if (fileNames) for (i = 0; i < fileCnt; i++) free(fileNames[i]);
  
  return retFlag;
}


/* ----------------------------------------
 * Set the viewing Options gadget list
 */
static IGRstat setViewOptGadgetList(Form *form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  state;
  IGRint  i;
  IGRchar buf[80];
    

  // reset the list
  FIfld_set_list_num_rows(form, VDCT1_FORM_COP_G_VIEW_OPT, 0, 0);

  // get the state of the toggle
  // state = 0  --> BMIT
  // state = 1  --> MCAU
  FIg_get_state(form, VDCT1_FORM_COP_T_MCBM, &state);

  // set the text for the list
  for (i = 0; getViewOptGadgetText(state,i,buf) ; i++) {
    FIfld_set_list_text(form, VDCT1_FORM_COP_G_VIEW_OPT, i, 0, buf, 0);
  }
  
  // done
  return 1;
}

/* ----------------------------------------
 * BMIT / MCAU Toggle button was pressed
 */
static IGRstat notifyToggle(Form  *form)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  if (traceFlag) printf(">>> notifyToggle\n");
  
  sts = setViewOptGadgetList(form);
  if (!(sts & 1)) {
    FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Could not reset Viewing Options");
    goto wrapup;
  }

  sts = setOutputFileExtension(form,NULL);
  if (!(sts & 1)) {
    FIg_set_text(form, VDCT1_FORM_COP_G_STATUS, "Could not reset Output File Extension");
    goto wrapup;
  }

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* ----------------------------------------
 * Form notification routine
 */
IGRint VDct1NotifyCopForm(IGRint    f_label,
			  IGRint    g_label,
			  IGRdouble value,
			  Form     *form)
{

  IGRstat retFlag = 1;
  IGRstat sts;

  // say hi
  if (traceFlag) printf(">>> VDct1NotifyCopForm\n");
  
  // do it
  switch(g_label) {

    case FI_CANCEL:
      FIf_erase(form);
      exit (-1);
      break;
      
    case FI_RESET:
      FIf_reset(form);
      break;
                  
    case VDCT1_FORM_COP_T_MCBM:
      // change viewing options
      // change default output file extension
      sts = notifyToggle(form);
      if (!(sts & 1)) {
	printf("## Unable to reset form toggle\n");
	retFlag = 0;
      }
      break;
      
    case VDCT1_FORM_COP_G_PATH:
    case VDCT1_FORM_COP_G_XML_F:
      // show files in path with .xml extension
      sts = notifyXMLFile(form);
      if (!(sts & 1)) {
	printf("## Could not get any XML files\n");
	retFlag = 0;
      }
      break;

    case VDCT1_FORM_COP_G_WRITE_F:
      // create the .bm or .mc file depending on toggle
      sts = notifyWriteFile(form);
      if (!(sts & 1)) {
	printf("## Could not view selected file\n");
	retFlag = 0;
      }
      break;
            
    case VDCT1_FORM_COP_G_VIEW_OPT:
      // check that a file has been selected
      // generate text in view area depending on opt and toggle
      sts = notifyViewFile(form);
      if (!(sts & 1)) {
	printf("## Could not view selected file\n");
	retFlag = 0;
      }
      break;

    case VDCT1_FORM_COP_G_PROC_COP:
      // this will be used to execute any script or seperate program to actually
      // process this info into COPICS.
      break;
      
            
  }  // end of switch

  // done
 wrapup:
  return retFlag;
}
