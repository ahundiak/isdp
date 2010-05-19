/* $Id: VDpdfDomDiff.C,v 1.1 2001/01/11 19:42:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdpdf/VDpdfDomDiff.C
 *
 * Description: Compares two pdf dom trees
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDpdfDomDiff.C,v $
 *      Revision 1.1  2001/01/11 19:42:21  art
 *      sp merge
 *
 * Revision 1.1  2000/08/05  16:51:38  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/31/00  ah      Creation
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDdom.h"
#include "VDpdf.h"

#include "VDassert.h"

VDASSERT_FFN("vds/vdpdf/VDpdfDomDiff.C");

/* -------------------------------------------------------
 * Check one line from a diff file
 */
static IGRstat pdfCheckDiffFileLine(IGRchar *buf, IGRint *difCnt)
{
  IGRstat retFlag = 1;
  IGRchar *p;
  
  // Skip all ines except those with > or <
  switch(*buf) {
    case '>':
    case '<':
      break;
    default: goto wrapup;
  }

  // Ignore PDF_ATR_SETUP_FILE_NAME (time stamp
  p = strstr(buf,"PDF_ATR_SETUP_FILE_NAME");
  if (p) goto wrapup;
  
  // Have a difference
  *difCnt += 1;
  fputs(buf,stdout);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Analize a diff file to see if the changes really matter
 */
IGRstat VDpdfCheckDiffFile(IGRchar *difFileName, IGRint *difCnt)
{
  VDASSERT_FN("VDpdfCheckDiffFile");
  
  IGRstat retFlag = 0;
  IGRchar buf[1024];
  
  FILE *file = NULL;
  
  // Arg check
  VDASSERTW(difCnt); *difCnt = 0;
  VDASSERTW(difFileName);
  
  // Open it
  file = fopen(difFileName,"rt");
  VDASSERTW(file);
  
  // Cycle through
  while(fgets(buf,sizeof(buf),file)) {
    pdfCheckDiffFileLine(buf,difCnt);
  }
  
  // Done
  fclose(file);
  file = NULL;
  
 wrapup:
  if (file) fclose(file);
  return retFlag;
  
}

/* -----------------------------------------------
 * Diff two pdf files and analize the differences
 */
IGRstat VDpdfDiffFiles(IGRchar *pdfFileName1,
		       IGRchar *pdfFileName2,
		       IGRchar *difFileName)
{
  VDASSERT_FN("VDpdfDiffFiles");
  
  IGRstat retFlag = 0;
  
  TVDdomEle *tree1 = NULL;
  TVDdomEle *tree2 = NULL;
  
  IGRchar msg[128];
  IGRchar cmd[512];

  IGRint  difCnt = 0;

  IGRchar domFileName1[128];
  IGRchar domFileName2[128];
  IGRchar *p;

  FILE *file;
  
  // Arg check
  VDASSERTW(pdfFileName1);
  VDASSERTW(pdfFileName2);
  VDASSERTW(difFileName);

  // Say Hi
  printf("----------------------------------------------\n");
  printf("Diffing %s %s to %s\n",pdfFileName1,pdfFileName2,difFileName);
  
  // Tree 1
  VDpdfFileToDomTree(pdfFileName1,0,&tree1,msg);
  if (tree1 == NULL) goto wrapup;

  // Dom 1
  sprintf(domFileName1,"%s.dom",pdfFileName1);
  file = fopen(domFileName1,"wt");
  VDASSERTW(file);
  VDdomPrintNode(tree1,1,NULL,file);
  fclose(file);
  
  // Tree 2
  VDpdfFileToDomTree(pdfFileName2,0,&tree2,msg);
  if (tree2 == NULL) goto wrapup;

  // Dom 2
  sprintf(domFileName2,"%s.dom",pdfFileName2);
  file = fopen(domFileName2,"wt");
  VDASSERTW(file);  
  VDdomPrintNode(tree2,1,NULL,file);
  fclose(file);
  
  // Diff em
  sprintf(cmd,"/bin/diff %s %s > %s",domFileName1,domFileName2,difFileName);
  system (cmd);
  
  // Analize
  VDpdfCheckDiffFile(difFileName,&difCnt);
  
  // Done
  retFlag = 1;
  
 wrapup:

  VDdomFreeTree(tree1);
  VDdomFreeTree(tree2);
  
  printf("Diff Complete, Diff Count %d\n",difCnt);
  
  return retFlag;
}

#if 0
/* -----------------------------------------------
 * Test the pdf file to dom conversion
 */
IGRstat VDpdfTestFileToDomTree(IGRchar *pdfFileName)
{
  VDASSERT_FN("VDpdfTestFileToDom");
  IGRstat retFlag = 0;
  
  TVDdomEle *ele = NULL;
  IGRchar    msg[128];

  IGRint  difCnt = 0;
  
  IGRchar domFileName[128];
  IGRchar refFileName[128];
  IGRchar difFileName[128];
  IGRchar cmd[512];
  
  IGRchar *p;
  FILE    *file = NULL;
  
  // Arg check
  VDASSERTW(pdfFileName);

  // Say Hi
  traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s %s\n",ffn(),fn,pdfFileName);
  }
  
  // Convert to dom tree
  VDpdfFileToDomTree(pdfFileName,0,&ele,msg);
  if (traceFlag) {
    printf("%s\n",msg);
  }
  VDASSERTW(ele);
  
  // Save it to a file
  strcpy(domFileName,pdfFileName);
  p = strrchr(domFileName,'.');
  VDASSERTW(p);
  strcpy(p,".dom");
  file = fopen(domFileName,"wt");
  VDASSERTW(file);
  VDdomPrintNode(ele,1,NULL,file);
  fclose(file);
  file = NULL;
  
  // See if the reference file name exists
  strcpy(refFileName,pdfFileName);
  p = strrchr(refFileName,'.');
  strcpy(p,".ref");
  file = fopen(refFileName,"rt");
  if (file) fclose(file);
  else {
    sprintf(cmd,"/bin/cp %s %s",domFileName,refFileName);
    system (cmd);
  }
  file = NULL;
  
  // Dif em
  strcpy(difFileName,pdfFileName);
  p = strrchr(difFileName,'.');
  strcpy(p,".dif");

  sprintf(cmd,"/bin/diff %s %s > %s",domFileName,refFileName,difFileName);
  system (cmd);

  // Check the results
  pdfCheckDiffFile(difFileName,&difCnt);
  VDASSERTW(difCnt == 0);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (file) fclose(file);
  VDdomFreeTree(ele);

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
#endif




