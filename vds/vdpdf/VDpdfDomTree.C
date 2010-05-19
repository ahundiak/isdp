/* $Id: VDpdfDomTree.C,v 1.1 2001/01/11 19:42:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdpdf/VDpdfDomTree.C
 *
 * Description: Converts pdf binary file to dom tree
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDpdfDomTree.C,v $
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

VDASSERT_FFN("vds/vdpdf/VDpdfDomTree.C");

/* -----------------------------------------------------
 * Read 32 bit integer
 */
static IGRstat readInt(FILE *file, IGRlong *val)
{
  unsigned char *p;
  int i;

  *val = 0;
  p = (unsigned char *)val;

  for(i = 3; i >= 0; i--) {
    if (fread(p+i,1,1,file) == 0) return 0;
  }
  return 1;
}

/* -----------------------------------------------------
 * Read 4 byte real
 */
static IGRstat readReal(FILE *file, IGRdouble *val)
{
  unsigned char *p;
  int i;

  float f;

  *val = 0.0;

  p = (unsigned char *)&f;

  for(i = 3; i >= 0; i--) {
    if (fread(p+i,1,1,file) == 0) return 0;
  }
  *val = f;

  return 1;
}

/* -------------------------------
 * Read a real and convert to text
 */
static IGRstat readRealTxt(FILE *file, IGRchar *txt)
{
  IGRdouble real = 0.0;
  IGRchar  *p;

  readReal(file,&real);
  sprintf(txt,"%.3f",real);
  for(p = txt + strlen(txt) - 1; (p >= txt) && (*p == '0'); p--);
  *(p+2) = 0;

  return 1;
}

/* -----------------------------------------------
 * One copy holds master data to avoid statics
 *
 * Other is for recursion
 */
typedef struct 
{
  FILE      *pdfBinFile;
  IGRint     pdfErrorCnt;
  TVDdomEle *ele;
} TVDpdfDOMMain;

typedef struct {
  IGRchar    desc[64];
  TVDdomEle *ele;
  
} TVDpdfDOMChild;

/* -------------------------------------------------------
 * Safely strcat a value into the buffer
 */
static IGRstat valcat(IGRchar *des, IGRchar *src, IGRchar *msg)
{
  IGRstat retFlag = 0;
  IGRint  len;
  
  // Check the length
  len = strlen(des) + strlen(src) + 2;
  if (len >= VDDOM_ATR_VALUE_LEN) {
    if (msg) printf("*** DOM Value overflow for %s %s %s\n",msg,des,src);
    else     printf("*** DOM Value overflow for %s %s\n",       des,src);
    goto wrapup;
  }
  
  // Do It
  if (*des) strcat(des," ");
  strcat(des,src);
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Process attribute
 */
static IGRstat readRecordAttribute(TVDpdfDOMMain  *domMain, 
				   TVDpdfDOMChild *domChild,
				   IGRlong         dataType,
				   IGRlong         dataLen,
				   IGRchar        *desc)
{
  VDASSERT_FN("readRecordAttribute");
  IGRstat retFlag = 0;
  
  TVDdomAtr *atr = NULL;
  TVDdomEle *vertexEle = NULL;
  TVDdomEle *curveEle  = NULL;

  IGRchar    buf[1024];
  IGRchar   *msg1;
  IGRchar    real1[32],real2[32];
  
  IGRint  i,j;
  IGRlong data,bundle;
  
  FILE *inFile = domMain->pdfBinFile;
  
  // Should always be correctly set
  VDASSERTW(domChild->ele);
    
  // Its an attribute
  atr = calloc(1,sizeof(TVDdomAtr));
  VDASSERTW(atr);
  strcpy(atr->type,desc);
  
  // Adjust for possible long lengths
  if (dataLen == 252) readInt(inFile,&dataLen);

  // Process various types
  switch(dataType) {

    case PDF_DT_TEXT:

      fread(buf,dataLen*4,1,inFile);
      *(buf + (dataLen * 4)) = 0;
      valcat(atr->value,buf,"DT_TEXT");
	
      break;

    case PDF_DT_INT:

      readInt(inFile,&data);
      sprintf(atr->value,"%d",data);
      
      break;

    case PDF_DT_REAL:

      readRealTxt(inFile,buf);
      valcat(atr->value,buf,"DT_REAL");

      break;
  
    case PDF_DT_REALS:
    
      i = 0;

      if (dataLen > 8) printf("### Have DT_REALS %d\n",dataLen);
      
      while(dataLen) {
 
	// Group by fours
	if (i == 4) {
	  i = 0;
	}
	i = i + 1; 
	readRealTxt(inFile,buf);
	valcat(atr->value,buf,"DT_REALS");      
	dataLen--;
      }
      break;

    case PDF_DT_3D_PT:
    case PDF_DT_3D_PTS:

      i = 0;
    
      if (dataLen > 9) printf("### Have DT_3D_PT %d\n",dataLen);
    
      while(dataLen) {
 
	// Group by threes
	if (i == 3) {
	  i = 0;
	}
	i = i + 1;
	readRealTxt(inFile,buf);
	valcat(atr->value,buf,"3D_PTS");      
	dataLen--;
      }

      break;

    case PDF_DT_2D_PT:
    case PDF_DT_2D_PTS:
      
      i = 0;
      
      while(dataLen) {
 
	// Group by 2's
	if (i == 2) {
	  i = 0;
	}
	i = i + 1;
	readRealTxt(inFile,buf);
	valcat(atr->value,buf,"2D_PTS");
	dataLen--;
      }
      
      break;
      
    case PDF_DT_2D_OVAL:
    case PDF_DT_2D_ELLIPSE:
      
      if (dataType == PDF_DT_2D_OVAL) strcpy(atr->value,"OVAL");
      else                            strcpy(atr->value,"ELLIPSE");
      
      msg1 = "DT_2D_OVAL_ELLIPSE";
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      dataLen -= 6;
      
      break;
      
    case PDF_DT_2D_CIRCLE:
      
      strcpy(atr->value,"CIRCLE");
      
      msg1 = "DT_2D_CIRCLE";
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      readRealTxt(inFile,buf);
      valcat(atr->value,buf,msg1);
      
      dataLen -= 3;
      
      break;
      
    case PDF_DT_2D_LINE_ARC:
    {
      // Make a curve element
      curveEle = calloc(1,sizeof(TVDdomEle));
      VDASSERTW(curveEle);
      strcpy(curveEle->type,"PDF_OBJ_CURVE");
      VDdomAppendChildNode(domChild->ele,curveEle);
      
      while(dataLen > 0) {
	
	readInt(inFile,&bundle);
	dataLen--;
	
	for(i = 0; (i < 32) && (dataLen > 0); i++, dataLen -= 2) {
	  
	  readRealTxt(inFile,real1);
	  readRealTxt(inFile,real2);
	  
	  if (bundle & 0x01) j = 1;
	  else               j = 0;
	  bundle = bundle >> 1;
	  
	  // Here we need to think a bit
	  // Each vertex should be it's own object?
	  vertexEle = calloc(1,sizeof(TVDdomEle));
	  VDASSERTW(vertexEle);
	  strcpy(vertexEle->type,"PDF_OBJ_VERTEX");
	  VDdomAppendChildNode(curveEle,vertexEle);

	  // Might need a new attribute
	  if (atr == NULL) atr = calloc(1,sizeof(TVDdomAtr));
	  VDASSERTW(atr);

	  strcpy (atr->type,"PDF_ATR_VERTEX");
	  sprintf(atr->value,"%d %s %s",j,real1,real2);
	  VDdomAppendAttribute(vertexEle,atr);

	  atr = NULL;
	  
	}	
      }

      // Attribute is already processed
      if (atr) free(atr);
      atr = NULL;
      
    }
    
    break;
    
    default:
      printf("Unknown Data Type %s %2d %2d\n",domChild->desc,dataType,dataLen);
      strcpy(atr->value,"UNKNOWN DATA TYPE");
      
      while(dataLen) {
	fread(&data,1,sizeof(data),inFile); 
	dataLen--;
      }
      domMain->pdfErrorCnt++;
  }

  // Add the attribute
  if (atr) VDdomAppendAttribute(domChild->ele,atr);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Read and process next record, either object or attribute
 * Recursive routine
 */
static IGRstat readRecord(TVDpdfDOMMain *domMain, TVDpdfDOMChild *domChild)
{
  VDASSERT_FN("readRecord");
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRlong hdr;
  IGRlong data;
  IGRlong recType,dataType,dataLen;

  IGRint  objEnd = 0;

  IGRchar desc[64];
  
  TVDpdfDOMChild domChildx;
  
  TVDdomEle *ele;
  
  FILE *inFile = domMain->pdfBinFile;;
  
  // Infinite recurse loop
  while(1) {
    
    // Get the header
    sts = readInt(inFile,&hdr);
    if (!(sts & 1)) {
      if (*domChild->desc != 0) {
	printf("Unexpected end of file\n");
	domMain->pdfErrorCnt++;
	goto wrapup;
      }
      // Normal exit
      retFlag = 1;
      goto wrapup;
      
    }

    // Chop it up
    recType  = (hdr >> 16) & 0xFFFF;
    dataType = (hdr >>  8) & 0x00FF;
    dataLen  = (hdr >>  0) & 0x00FF;

    // Is it an object end
    objEnd = 0;
    if ((recType & 0xC000) == 0xC000) objEnd = 1;

    // Strip end flag
    recType &= 0xBFFF;
    
    /* -------------------------------------------
     * Spades itself limits the nesting of objects
     * hence, use PDF_ATR_OBJ_BEG/END flags to fake some
     * nested objects
     *
     * Detect and expand them here
     */
    switch(recType & 0x3FFF) {

      case PDF_ATR_OBJ_END:
	objEnd = 1;
	
      case PDF_ATR_OBJ_BEG:

	// Read in new record type
	readInt(inFile,&data);
	recType = data | 0x8000;
	dataType = 0;
	dataLen  = 0;
	break;
	
    }
    
    // Get the type
    VDpdfGetRecDesc(recType,desc);
    if (*desc == 0) {
      printf("Invalid record type %4d\n",recType);
    }

    // Have an object?
    if (recType & 0x8000) {

      // Type and length should zero
      if ((dataType != 0) || (dataLen != 0)) {
	printf("Invalid object dataType/dataLen %s,%02x,%02x\n",
	       desc,dataType,dataLen);
	domMain->pdfErrorCnt++;
      }

      // Have an object end?
      if (objEnd) {

	// Type should match that on the stack
	if (strcmp(domChild->desc,desc)) {
	  printf("Object beg/end mismatch %s %s\n",desc,domChild->desc);
	  domMain->pdfErrorCnt++;
	}
	
	// Go back up the stack
	retFlag = 1;
	goto wrapup;
	
      }
    
      // New object
      ele = calloc(1,sizeof(TVDdomEle));
      VDASSERTW(ele);

      strcpy(ele->type,desc);
      
      // Might be the very first
      if (domMain->ele == NULL) domMain->ele = ele;

      // Child of the current
      if (domChild->ele) VDdomAppendChildNode(domChild->ele,ele);
    
      // Recurse to process
      memset(&domChildx,0,sizeof(TVDpdfDOMChild));
      domChildx.ele = ele;
      strcpy(domChildx.desc,desc);
      readRecord(domMain,&domChildx);
    }
  
    // Its an attribute
    else readRecordAttribute(domMain,domChild,dataType,dataLen,desc);

  }

 wrapup:
  return retFlag;
  
}

/* -------------------------------------------------------
 * Convert a pdf spades binary file to a dom tree
 */
IGRstat VDpdfFileToDomTree(IGRchar    *binFileName, 
			   IGRint      popupErrors,
			   TVDdomEle **treeEle, 
			   IGRchar     *msg)
{
  VDASSERT_FN("VDpdfFileToDomTree");
  IGRstat retFlag = 0;

  TVDpdfDOMMain  domMain;
  TVDpdfDOMChild domChild;
  
  // Arg check
  if (msg) *msg = 0;
  VDASSERTW(treeEle); *treeEle = NULL;
  VDASSERTW(binFileName && *binFileName);
  
  // Init
  memset(&domMain, 0,sizeof(domMain));
  memset(&domChild,0,sizeof(domChild));

  // Open the binary file
  domMain.pdfBinFile = fopen(binFileName,"rb");
  if (domMain.pdfBinFile == NULL) {
    printf("Verification failed opening %s\n",binFileName);
    domMain.pdfErrorCnt++;
    goto wrapup;
  }

  // Recurse loop through
  readRecord(&domMain,&domChild);

  // Pull out the tree
  *treeEle = domMain.ele;
  
  // Print it
  // VDdomPrintNode(domMain.ele,1,NULL,NULL);
  
  // Done
  retFlag = 1;

wrapup:
  if (domMain.pdfBinFile) fclose(domMain.pdfBinFile);
  if (msg) {  
    if (domMain.pdfErrorCnt) {
      sprintf(msg,"File to DOM complete, %d errors",domMain.pdfErrorCnt);
    }
    else {
      sprintf(msg,"File to DOM complete, No errors");
    }
  }
  return retFlag;
}

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
  VDpdfCheckDiffFile(difFileName,&difCnt);
  VDASSERTW(difCnt == 0);
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (file) fclose(file);
  if (ele)  VDdomFreeTree(ele);

  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}




