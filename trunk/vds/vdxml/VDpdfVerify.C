/* $Id: VDpdfVerify.C,v 1.4 2001/09/14 13:49:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdxf.C
 *
 * Description: Converts pdf binary file to xml file
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDpdfVerify.C,v $
 *      Revision 1.4  2001/09/14 13:49:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/21 13:01:00  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/05/11 13:07:15  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/18  16:26:44  pinnacle
 * sms
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/26/99  ah      Changed to .C for stand alone programs
 * 05/11/01  ah      Slip this into the service pack
 *                   Adjusted the xml format so it's well formed
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDpdf.h"

static FILE *pdfBinFile;
static FILE *pdfTxtFile;

static int pdfErrorCnt;
static int pdfIndent;

/* -----------------------------------------------------
 * Read 32 bit integer
 */
static IGRstat VDpdfReadInt(IGRlong *val)
{
  unsigned char *p;
  int i;

  *val = 0;
  p = (unsigned char *)val;

  for(i = 3; i >= 0; i--) {
    if (fread(p+i,1,1,pdfBinFile) == 0) return 0;
  }
  return 1;
}

/* -----------------------------------------------------
 * Read 4 byte real
 */
static IGRstat VDpdfReadReal(IGRdouble *val)
{
  unsigned char *p;
  int i;

  float f;

  *val = 0.0;

  p = (unsigned char *)&f;

  for(i = 3; i >= 0; i--) {
    if (fread(p+i,1,1,pdfBinFile) == 0) return 0;
  }
  *val = f;

  return 1;
}

/* -------------------------------
 * Read a real and convert to text
 */
static IGRstat VDpdfReadRealTxt(IGRchar *txt)
{
  IGRdouble real = 0.0;
  IGRchar  *p;

  VDpdfReadReal(&real);
  sprintf(txt,"%f",real);
  for(p = txt + strlen(txt) - 1; (p >= txt) && (*p == '0'); p--);
  *(p+2) = 0;

  return 1;
}

typedef struct {
  IGRchar desc[64];
  IGRint  atrEnd;
  IGRchar remarks[128];
} TVDpdfRecordXML;

static IGRstat VDpdfWriteIndent()
{
  IGRint i;

  for(i = 0; i < pdfIndent; i++) {
    fputc(' ',pdfTxtFile);
  }
  return 1;
}

/* -------------------------------------------------------
 * Read and process next record, either object or attribute
 * Recursive routine
 */
static IGRstat VDpdfReadRecord(TVDpdfRecordXML *a_xml)
{
  IGRstat sts;

  IGRlong hdr;
  IGRlong data;
  IGRlong recType,dataType,dataLen;

  IGRint  objEnd = 0;
  IGRint  treatAsObject;
  
  IGRchar desc[64];
  IGRchar buf[1024];
  IGRchar *p;
  
  TVDpdfRecordXML xml;

  IGRint  i,j;
  IGRlong bundle;

  IGRchar real1[32],real2[32];

  // Init
  memset(&xml,0,sizeof(xml));

the_loop:

  // Get the header
  sts = VDpdfReadInt(&hdr);
  if (!(sts & 1)) {
    if (*a_xml->desc != 0) {
      printf("Unexpected end of file\n");
      pdfErrorCnt++;
      return 0;
    }
    return 1;
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

  // Get the type
  VDpdfGetRecDesc(recType,desc);
  if (*desc == 0) {
    printf("Invalid record type %4d\n",recType);
  }
  // else printf("Desc %s\n",desc);

  /* ----------------------------------------
   * Little hack for obj_atr beg and ends
   * want to generate well formed xml files
   */
  if (!strcmp(desc,"PDF_ATR_OBJ_BEG") || 
      !strcmp(desc,"PDF_ATR_OBJ_END")) {

    if (!strcmp(desc,"PDF_ATR_OBJ_END")) objEnd = 1;

    VDpdfReadInt(&data);
    VDpdfGetRecDesc(data,desc);

    dataType = 0;
    dataLen = 0;
    recType = 0x8000;
    
  }
  
  // Have an object?
  if (recType & 0x8000) {

    // Type and length should zero
    if ((dataType != 0) || (dataLen != 0)) {
      printf("Invalid object dataType/dataLen %s,%02x,%02x\n",
        desc,dataType,dataLen);
      pdfErrorCnt++;
    }
    
    // End of attribute flag
    if (a_xml->atrEnd == 0) {
      VDpdfWriteIndent();
      fprintf(pdfTxtFile,">\n");
      a_xml->atrEnd = 1;
    }

    // Have an object end?
    if (objEnd) {

      // Type should match that on the stack
      if (strcmp(a_xml->desc,desc)) {
        printf("Object beg/end mismatch %s %s\n",desc,a_xml->desc);
        pdfErrorCnt++;
      }

      // Write it out
      pdfIndent--;
      pdfIndent--;
      VDpdfWriteIndent();
      fprintf(pdfTxtFile,"</%s>\n\n",desc);
      return 1;
    }

    // Put it out
    pdfIndent++;
    VDpdfWriteIndent();
    fprintf(pdfTxtFile,"<%s\n",desc);
    pdfIndent++;

    // Process it
    memset(&xml,0,sizeof(xml));
    strcpy(xml.desc,desc);
    VDpdfReadRecord(&xml);

    // The next loop
    goto the_loop;
  }

  // Adjust for possible long lengths
  if (dataLen == 252) VDpdfReadInt(&dataLen);

  // Process different types
  VDpdfWriteIndent();

  /* ---------------------------------------------
   * treat certain attributes as objects in order
   * to generate a well formed xml file
   */
  if (!strcmp(desc,"PDF_ATR_MARKING_LINE_MTL_POINT") ||
      !strcmp(desc,"PDF_ATR_MARKING_LINE_CURVE")) {

    // End of attribute flag
    if (a_xml->atrEnd == 0) {
      fprintf(pdfTxtFile,">\n");
      VDpdfWriteIndent();
      a_xml->atrEnd = 1;
    }

    // Object beginning
    fprintf(pdfTxtFile,"<%s ",desc);
    treatAsObject = 1;
    
  }
  else treatAsObject = 0;
  
  fprintf(pdfTxtFile,"%s=\"",desc);

  switch(dataType) {

  case PDF_DT_TEXT:

    fread(buf,dataLen*4,1,pdfBinFile);
    *(buf + (dataLen * 4)) = 0;

    // Char by char to allow conversion to & stuff
    for(p = buf; *p; p++) {
      switch(*p) {
	case '&': 
	  fputs("&amp;",pdfTxtFile);
	  break;
	case '<': 
	  fputs("&lt;",pdfTxtFile);
	  break;
	case '>': 
	  fputs("&gt;",pdfTxtFile);
	  break;
	case '"': 
	  fputs("&quot;",pdfTxtFile);
	  break;
	case '\'': 
	  fputs("&apos;",pdfTxtFile);
	  break;
	default:
	  fputc(*p,pdfTxtFile);
    }
  }

  break;

  case PDF_DT_INT:

    VDpdfReadInt(&data);
    fprintf(pdfTxtFile,"%d",data);

  break;

  case PDF_DT_REAL:

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s",buf);

  break;

  case PDF_DT_REALS:
    
    i = 0;
    fprintf(pdfTxtFile,"\n");
    pdfIndent += 2;
    VDpdfWriteIndent();
    
    while(dataLen) {
 
      if (i == 4) {
        fprintf(pdfTxtFile,"\n");
        VDpdfWriteIndent();
        i = 0;
      }
      i = i + 1;
 
      VDpdfReadRealTxt(buf);
      fprintf(pdfTxtFile,"%s ",buf);
      dataLen--;
    }
    pdfIndent -= 2;

  break;

  case PDF_DT_3D_PT:
  case PDF_DT_3D_PTS:

    i = 0;
    fprintf(pdfTxtFile,"\n");
    pdfIndent += 2;
    VDpdfWriteIndent();
    
    while(dataLen) {
 
      if (i == 3) {
        fprintf(pdfTxtFile,"\n");
        VDpdfWriteIndent();
        i = 0;
      }
      i = i + 1;
 
      VDpdfReadRealTxt(buf);
      fprintf(pdfTxtFile,"%s ",buf);
      dataLen--;
    }
    pdfIndent -= 2;

  break;

  case PDF_DT_2D_PT:
  case PDF_DT_2D_PTS:

    i = 0;
    fprintf(pdfTxtFile,"\n");
    pdfIndent += 2;
    VDpdfWriteIndent();
    
    while(dataLen) {
 
      if (i == 2) {
        fprintf(pdfTxtFile,"\n");
        VDpdfWriteIndent();
        i = 0;
      }
      i = i + 1;
 
      VDpdfReadRealTxt(buf);
      fprintf(pdfTxtFile,"%s ",buf);
      dataLen--;
    }
    pdfIndent -= 2;

  break;

  case PDF_DT_2D_OVAL:
  case PDF_DT_2D_ELLIPSE:
    
    VDpdfReadRealTxt(buf);
    if (dataType == PDF_DT_2D_OVAL) fprintf(pdfTxtFile,"OVAL %s ",buf);
    else                            fprintf(pdfTxtFile,"ELLIPSE %s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    dataLen -= 6;

  break;

  case PDF_DT_2D_CIRCLE:
    
    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"CIRCLE %s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    VDpdfReadRealTxt(buf);
    fprintf(pdfTxtFile,"%s ",buf);

    dataLen -= 3;

  break;
    
  case PDF_DT_2D_LINE_ARC:
    { 
      pdfIndent += 2;
      
      while(dataLen > 0) {
      
	VDpdfReadInt(&bundle);
	dataLen--;
	
	for(i = 0; (i < 32) && (dataLen > 0); i++, dataLen -= 2) {
	
	  VDpdfReadRealTxt(real1);
	  VDpdfReadRealTxt(real2);

	  if (bundle & 0x01) j = 1;
	  else               j = 0;
	  bundle = bundle >> 1;
	
	  fprintf(pdfTxtFile,"\n");
	  VDpdfWriteIndent();
	  fprintf(pdfTxtFile,"%d %s %s",j,real1,real2);
	  
	}	
      }
      pdfIndent -= 2;
    }
  
  break;
    
  default:
    printf("Unknown Data Type %s %2d %2d\n",desc,dataType,dataLen);
    fprintf(pdfTxtFile,"UNKNOWN DATA TYPE\n");

    while(dataLen) {
      fread(&data,1,sizeof(data),pdfBinFile); 
      dataLen--;
    }
    pdfErrorCnt++;
  }
  fprintf(pdfTxtFile,"\"\n");

  if (treatAsObject) {
    VDpdfWriteIndent();
    fprintf(pdfTxtFile,"> </%s>\n\n",desc);
  }
  
  // Process next attribute
  goto the_loop;
}

/* -------------------------------------------------------
 * Verify a pdf file by converting to xml file
 * and checking stuff along the way
 */
IGRstat VDpdfVerifyFile(IGRchar *binFileName)
{
  IGRstat retFlag = 0;

  IGRchar txtFileName[256];
  IGRchar *p;

  TVDpdfRecordXML xml;

  IGRchar buf[128];

  // Init
  pdfBinFile = NULL;
  pdfTxtFile = NULL;

  memset(&xml,0,sizeof(xml));

  pdfErrorCnt =  0;
  pdfIndent   = -1;

  // Open the binary file
  pdfBinFile = fopen(binFileName,"rb");
  if (pdfBinFile == NULL) {
    printf("Verification failed opening %s\n",binFileName);
    pdfErrorCnt++;
    goto wrapup;
  }

  // Make the text file name
  strcpy(txtFileName,binFileName);
  p = strrchr(txtFileName,'.');
  if (p) *p = 0;
  strcat(txtFileName,".xml");

  // Open text file
  pdfTxtFile = fopen(txtFileName,"wt");
  if (pdfTxtFile == NULL) {
    printf("Verification failed opening %s\n",txtFileName);
    pdfErrorCnt++;
    goto wrapup;
  }

  // Standard header
  fprintf(pdfTxtFile,"<?xml version=\"1.0\" standalone=\"yes\"?>\n");
  //fprintf(pdfTxtFile,"<!DOCTYPE PDF_OBJ_ROOT SYSTEM \"ProdData.dtd\">\n");
  fprintf(pdfTxtFile,"\n");

  // Recurse loop through
  xml.atrEnd = 1;
  VDpdfReadRecord(&xml);

  // Done
  retFlag = 1;

wrapup:
  if (pdfBinFile) fclose(pdfBinFile);
  if (pdfTxtFile) fclose(pdfTxtFile);

  if (pdfErrorCnt == 0) {
    //UI_status("Verification complete, No errors");
    return 1;
  }
  sprintf(buf,"Verification complete, %d errors",pdfErrorCnt);
  //UI_status(buf);

  return 0;
}



