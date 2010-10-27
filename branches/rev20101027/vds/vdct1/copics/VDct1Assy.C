/* $Id: VDct1Assy.C,v 1.2 2001/02/20 15:22:34 ahundiak Exp $  */

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
 * $Log: VDct1Assy.C,v $
 * Revision 1.2  2001/02/20 15:22:34  ahundiak
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
 * Sort two copics parts
 */
IGRint VDct1SortCopPart(const void *p1, const void *p2)
{
  TVDct1CopPartInfo *part1 = *(TVDct1CopPartInfo**)p1;
  TVDct1CopPartInfo *part2 = *(TVDct1CopPartInfo**)p2;

  IGRdouble qty1,qty2;
  IGRdouble delta;
  
  IGRint sts;

  // By part cage num
  sts = strcmp(part1->node_name,part2->node_name);
  if (sts) return sts;
  
  // By qty
  qty1 = atof(part1->qty);
  qty2 = atof(part2->qty);
  delta = qty1 - qty2;
  
  if (delta < 0.0) return -1;
  if (delta > 0.0) return  1;

  // Match
  return 0;
}

/* -------------------------------------------------------
 * Sort two copics assys
 */
IGRint VDct1SortCopAssy(const void *p1, const void *p2)
{
  TVDct1CopAssyInfo *assy1 = *(TVDct1CopAssyInfo**)p1;
  TVDct1CopAssyInfo *assy2 = *(TVDct1CopAssyInfo**)p2;
  
  IGRint sts;

  // By part cage num
  sts = strcmp(assy1->node_name,assy2->node_name);
  if (sts) return sts;

  // Really shoud not get here
  if (traceFlag) printf("*** Duplicate Copics Assemblies %s\n",assy1->node_name);
  
  // Match
  return 0;
}

/* -------------------------------------------------------
 * Given an index into an array of parts, roll the part
 * with any following parts of the same type
 */
IGRstat VDct1CopRollPart(TVDct1CopPartInfo **parts,   // I - Array Of Parts
			 IGRint              i,       // I - Index into parts
			 IGRint              cnt,     // I - Number of parts
			 IGRint             *rollCnt, // O - Number rolled
			 IGRdouble          *qty)     // O - Rolled Qty
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (qty)     *qty     = 0.0;
  if (rollCnt) *rollCnt = 0;
  
  if (parts == NULL) goto wrapup;
  if (i >= cnt)      goto wrapup;
  
  // Ok
  retFlag = 1;
  
  // Have at least
  while(1) {
        
    // Update qty and roll
    if (qty)     *qty     = *qty + atof(parts[i]->qty);
    if (rollCnt) *rollCnt = *rollCnt + 1;
    
    // Have more
    i++;
    if (i >= cnt) goto wrapup;
    
    // Does it match previous
    if (strcmp(parts[i-1]->node_name,parts[i]->node_name)) {
      goto wrapup;
    }
  }
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Swap part attributes around
 */
IGRstat VDct1CopPartSwapAttr(TVDct1CopPartInfo *part)
{
  IGRstat retFlag = 0;

  IGRchar pct_mino[32];
  IGRchar buf[32];
  IGRchar *p,*q;
  
  // set node_name from copics_num attribute
  //printf("### part->copics_num = %s\n",part->copics_num);
  if (strcmp(part->copics_num,"")) strcpy(part->node_name,part->copics_num);
  //printf("### part->node_name = %s\n",part->node_name);

  // set qty and um from pct_mino attribute
  if (strcmp(part->pct_mino,"")) {
    q = part->pct_mino;
    p = strchr(q,' ');
    if (p) {
      *p = 0;
      strcpy(part->qty,q);
      //printf("### qty = %s\n",part->qty);
      q = p + 1;
      strcpy(part->um,q);
      //printf("### um = %s\n",part->um);
    }
  }
  
  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Process a Part
 */
IGRstat VDct1CopPartProcess(FILE *file, TVDct1CopPartInfo *part)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  
  IGRchar   part_node_name[128];

  IGRdouble qty;
  
  // Say Hi
  //file = stdout;
  
  // Process node name
  VDct1CopProcessNodeName(part->node_name,part_node_name);

  // Write It
  fprintf(file,"BM-001 %-19s 4 %-10s %-2s\n",
	  part_node_name,
	  part->comm_code,
	  part->um);    

  fprintf(file,"\n");
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Process an assembly
 */
IGRstat VDct1CopAssyProcess(FILE *file, TVDct1CopAssyInfo *assy)
{
  IGRstat retFlag = 0;
  
  IGRint i,rollCnt;
  TVDct1CopPartInfo *part;
  
  IGRchar   assy_node_name[128];
  IGRchar   part_node_name[128];

  IGRdouble qty;
  
  // Say Hi
  // file = stdout;
  
  // Process node name
  VDct1CopProcessNodeName(assy->node_name,assy_node_name);

  // Write It
  fprintf(file,"BM-001 %-19s 2 %-10s EA\n",
	  assy_node_name,
	  assy->comm_code);    

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

    // What to do about qty?
    // qty = atof(part->qty);
    
    // And write
    fprintf(file,"BM-002 %-19s %-19s %9.2f\n",
	    assy_node_name,
	    part_node_name,
	    qty);
  }
  fprintf(file,"\n");
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Write loaded part data structure
 */
IGRstat VDct1CopPartWriteCopics(TVDct1CopEngInfo *info)
{
  IGRchar fn[] = "VDct1CopPartGenerateCopics";
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i;
  TVDct1CopPartInfo *part,*partx;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // swap part attributes
  for (i = 0; i < info->parts.cnt; i++) {
    VDct1CopPartSwapAttr((TVDct1CopPartInfo *)info->parts.data[i]);
  }

  // Sort the parts
  qsort(info->parts.data,info->parts.cnt,sizeof(TVDct1CopPartInfo *),VDct1SortCopPart);

  // Process Parts one at a time
  for(i = 0; i < info->parts.cnt; i++) {
    part = info->parts.data[i];

    // must print the first one
    if (i == 0) VDct1CopPartProcess(info->file.cop,part);
    
    // use node name to compare
    if (i > 0) {
      partx = info->parts.data[i-1];
      if (strcmp(part->node_name,partx->node_name))
	VDct1CopPartProcess(info->file.cop,part);
    }
  }
  
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------------------
 * Write loaded assy data structure
 */
IGRstat VDct1CopAssyWriteCopics(TVDct1CopEngInfo *info)
{
  IGRchar fn[] = "VDct1CopAssyGenerateCopics";
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint i;
  TVDct1CopAssyInfo *assy;
  TVDct1CopAssyInfo *assyx;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Sort the assemblies
  qsort(info->assys.data,info->assys.cnt,sizeof(TVDct1CopAssyInfo *),VDct1SortCopAssy);

  // Process assemblies one at a time
  for(i = 0; i < info->assys.cnt; i++) {
    assy = info->assys.data[i];
    
    // do the first one
    if (i == 0) VDct1CopAssyProcess(info->file.cop,assy);

    // only do the rest if not already done
    if (i > 0) {
      assyx = info->assys.data[i-1];
      if (strcmp(assy->node_name,assyx->node_name))
	VDct1CopAssyProcess(info->file.cop,assy);
    }
    
  }
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);
  
  return retFlag;
}

/* -------------------------------------------------------
 * The main traffic director
 *
 * Should filter on units?
 */
IGRstat VDct1CopAssyGenerateCopics(IGRchar          *xmlFileName,
				   IGRchar          *theFileName,
				   TVDct1CopEngInfo *info)
{
  IGRchar fn[] = "VDct1CopAssyGenerateCopics";
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar copFileName[1056];
  IGRchar errFileName[1056];
  IGRchar *p;
  
  //  TVDct1CopEngInfo     info;
  TVDxmlParseInfo parseInfo;

  IGRint i;
  TVDct1CopAssyInfo *assy;
    
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s %s\n",fn,xmlFileName);

  // Arg check
  if (xmlFileName == NULL) goto wrapup;

  // fill up the part structures
  sts = VDxmlParseFile(&parseInfo,xmlFileName,VDct1CopPartSaxCallback,info);
  if (!(sts & 1)) goto wrapup;

  // Fill up Std assemblies structure
  sts = VDxmlParseFile(&parseInfo,xmlFileName,VDct1CopStdAssySaxCallback,info);
  if (!(sts & 1)) goto wrapup;
  
  // Fill up Eng assemblies structure
  sts = VDxmlParseFile(&parseInfo,xmlFileName,VDct1CopEngAssySaxCallback,info);
  if (!(sts & 1)) goto wrapup;

  if (*theFileName != NULL) {
    // setup other files
    strcpy(copFileName,theFileName);
    sprintf(errFileName,"%s.err",theFileName);
    
    // open the files
    info->file.cop = fopen(copFileName,"wt");
    info->file.err = fopen(errFileName,"wt");
  
    // Write parts
    VDct1CopPartWriteCopics(info);
    
    // Write assemblies
    VDct1CopAssyWriteCopics(info);
    
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
