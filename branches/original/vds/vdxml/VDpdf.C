/* $Id: VDpdf.C,v 1.4 2002/05/02 19:21:24 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdxf.C
 *
 * Description: Basic pdf (spades) functions
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDpdf.C,v $
 *      Revision 1.4  2002/05/02 19:21:24  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/07 19:04:19  ahundiak
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
 ***************************************************************************/
#include "VDtypedef.h"
#include "VDcvg.h"
#include "VDpdf.h"

static int traceFlag;

/* -----------------------------------------------------
 * Write int
 */
IGRstat VDpdfWriteInt(TVDpdfFileInfo *pdf, IGRlong val)
{
  unsigned char *p;
  int i;

  // Arg check
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;
  
  p = (unsigned char *)&val;

  for(i = 3; i >= 0; i--) {
    fwrite(p+i,1,1,pdf->file);
  }

wrapup:
  return 1;
}

/* -----------------------------------------------------
 * Write real
 */
IGRstat VDpdfWriteReal(TVDpdfFileInfo *pdf, IGRdouble val)
{
  unsigned char *p;
  int i;

  float f = (float)val;

  // Arg check
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;

  p = (unsigned char *)&f;

  for(i = 3; i >= 0; i--) {
    fwrite(p+i,1,1,pdf->file);
  }

wrapup:
  return 1;
}

/* -----------------------------------------------------
 * Write real attribute
 */
IGRstat VDpdfWriteAttrReal(TVDpdfFileInfo *pdf, IGRint recType, IGRdouble val)
{

  VDpdfWriteHdr (pdf,recType,PDF_DT_REAL,1);
  VDpdfWriteReal(pdf,val);

  return 1;
}

/* -----------------------------------------------------
 * Write array of reals, limit to 250 or so
 */
IGRstat VDpdfWriteAttrReals(TVDpdfFileInfo *pdf, 
			    IGRint          recType,
			    IGRint          cnt,
			    IGRdouble      *val)
{
  IGRint i;
  
  VDpdfWriteHdr (pdf,recType,PDF_DT_REALS,cnt);

  for(i = 0; i < cnt; i++) {
    VDpdfWriteReal(pdf,val[i]);
  }
  
  return 1;
}

/* -----------------------------------------------------
 * Write int attribute
 */
IGRstat VDpdfWriteAttrInt(TVDpdfFileInfo *pdf, IGRint recType, IGRlong val)
{

  VDpdfWriteHdr(pdf,recType,PDF_DT_INT,1);
  VDpdfWriteInt(pdf,val);

  return 1;
}

/* -----------------------------------------------------
 * Write text attribute
 */
IGRstat VDpdfWriteAttrText(TVDpdfFileInfo *pdf, IGRint recType, IGRchar *val)
{
  IGRstat retFlag = 0;
  
  IGRint  len,adj;

  IGRchar buf[1024];

  IGRchar *p;
  
  // Arg Check
  if  (val == NULL) goto wrapup;
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;

  // Strip any trailing blanks
  strcpy(buf,val);
  for(p = buf + strlen(buf) - 1; (p >= buf) && (*p == ' '); p--);
  *(p+1) = 0;
  
  len = strlen(buf);
  adj = 4-(len % 4);
  if (adj == 4) adj = 0;
  
  if (adj) {
    memset(buf+len,0,adj);
    len += adj;
  }
  VDpdfWriteHdr(pdf,recType,PDF_DT_TEXT,len / 4);

  // printf("Text %2d '%s'\n",len,buf);
  
  fwrite(buf,len,1,pdf->file);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Write text attribute
 */
IGRstat VDpdfWriteAttrText1(TVDpdfFileInfo *pdf, IGRint recType, IGRchar *val)
{
  IGRstat retFlag = 0;
  
  IGRint  len,adj,wlen;
  IGRlong val0 = 0;
  
  // Arg Check
  if  (val == NULL) goto wrapup;
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;
  
  {
    IGRchar *p;
    
    if (strlen(val) > 32) {
      printf("Long text attribute '%s'\n",val);
    }
    for(p = val; (*p != 0) && (*p >= ' ') && (*p <= 'z'); p++);
    if (*p != 0) {
      printf("Control Code '%s'\n",val);
    }
  }
  
  /* Adjust lengths to nearest 4 */
  len = strlen(val);
  adj = 4 - (len % 4);

  wlen = (len + adj) / 4;

  VDpdfWriteHdr(pdf,recType,PDF_DT_TEXT,wlen);

  fwrite( val,len,1,pdf->file);

  if (adj) {
    fwrite(&val0,adj,1,pdf->file);
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
    
/* --------------------------------------------------------------------
 * Write Record Header
 */
IGRstat VDpdfWriteHdr(TVDpdfFileInfo *pdf, IGRint recType, IGRint dataType, IGRint dataLen) 
{
  IGRstat retFlag = 0;
  
  struct {
    unsigned char recType1,recType2,dataType,dataLen;
  } hdr;

  // Arg check
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;

  hdr.recType1  = (recType & 0xFF00) >> 8;
  hdr.recType2 =  (recType & 0x00FF);

  hdr.dataType = dataType;
  hdr.dataLen  = dataLen;

  fwrite(&hdr,sizeof(hdr),1,pdf->file);
  
  retFlag = 1;

wrapup:  
  return retFlag;;
}

/* ---------------------------------------------------
 * Beginning of an object
 */
IGRstat VDpdfWriteObjBeg(TVDpdfFileInfo *pdf, IGRint recType) 
{
  IGRint  type;
  
  type = recType | PDF_OBJ_BEG_MASK;
  
  VDpdfWriteHdr(pdf,type,PDF_OBJ_DT,PDF_OBJ_LEN);
  
wrapup:
  return 1;
}

/* ---------------------------------------------------
 * Ending of an object
 */
IGRstat VDpdfWriteObjEnd(TVDpdfFileInfo *pdf, IGRint recType) 
{
  IGRint type;
  
  type = recType | PDF_OBJ_BEG_MASK | PDF_OBJ_END_MASK;
  
  VDpdfWriteHdr(pdf,type,PDF_OBJ_DT,PDF_OBJ_LEN);

wrapup: 
  return 1;
}

/* ---------------------------------------------------
 * Write array of reals
 */
IGRstat VDpdfWriteReals(TVDpdfFileInfo *pdf,
			IGRint          recType, 
			IGRint          realCnt, 
			IGRdouble      *reals)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_REALS;
  IGRint  dataLen  = realCnt;
  
  IGRint i,j;
  
  // Arg Check
  if (reals == NULL) goto wrapup;
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;

  // Put out the header
  VDpdfWriteHdr(pdf,recType,dataType,dataLen);

  // And the data
  for(i = 0; i < realCnt; i++) {
    VDpdfWriteReal(pdf,reals[i]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Write array of 3d points
 * Warning, this is really only for the 3d ref points
 * Currently does not apply the trn translation
 */
IGRstat VDpdfWrite3dPts(TVDpdfFileInfo *pdf,
			IGRint          recType, 
			IGRint          ptCnt, 
			IGRdouble      *pts)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_3D_PTS;
  IGRint  dataLen  = 3 * ptCnt;
  
  IGRint i,j;
  
  // Arg Check
  if (pts == NULL) goto wrapup;
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;

  // Put out the header
  VDpdfWriteHdr(pdf,recType,dataType,dataLen);

  // And the data
  for(i = 0; i < ptCnt; i++) {
          
    for(j = 0; j < 3; j++) {
      
      VDpdfWriteReal(pdf,pts[(3*i)+j]);
      
    }    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Write single 2D point
 * No translation
 */
IGRstat VDpdfWrite2dPt(TVDpdfFileInfo *pdf, 
		       IGRint recType, 
		       IGRdouble      *pt)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_2D_PT;
  IGRint  dataLen  = 2;
  
  // Arg Check
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;
  if (pt == NULL) goto wrapup;

  // Put out the header
  VDpdfWriteHdr(pdf,recType,dataType,dataLen);

  // And the data
  VDpdfWriteReal(pdf,pt[0]);
  VDpdfWriteReal(pdf,pt[1]);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Write 2D points
 * No translation
 */
IGRstat VDpdfWrite2dPts(TVDpdfFileInfo *pdf,
			IGRint          recType, 
                        IGRint          ptCnt, 
                        IGRdouble      *pts)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_2D_PTS;
  IGRint  dataLen  = 2 * ptCnt;
  IGRint  i;
  
  // Arg Check
  if ((pdf == NULL) || (pdf->file == NULL)) goto wrapup;
  if (pts == NULL) goto wrapup;

  // Put out the header
  VDpdfWriteHdr(pdf,recType,dataType,dataLen);

  // And the data
  for(i = 0; i < ptCnt; i++) {
          
    // And the data
    VDpdfWriteReal(pdf,pts[(3*i)+0]);
    VDpdfWriteReal(pdf,pts[(3*i)+1]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Label writing stuff
 */
IGRstat VDpdfWriteCvgLabel(TVDpdfFileInfo *pdf,
			   IGRint          flag,
			   IGRchar        *labelType,
			   TVDcvgText     *text)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];
  IGRdouble pts[9];
  IGRdouble val[3];
  
  IGRint    i;
  
  // Arg check
  if (pdf       == NULL) goto wrapup;
  if (labelType == NULL) goto wrapup;
  if (text      == NULL) goto wrapup;
  
  // Do it
  if (flag) VDpdfWriteAttrInt(pdf,PDF_ATR_OBJ_BEG,PDF_OBJ_LABEL);
  else      VDpdfWriteObjBeg (pdf,PDF_OBJ_LABEL);
  
  // Make type upper case
  strcpy(buf,labelType);
  VDstrupr(buf);
  VDpdfWriteAttrText(pdf,PDF_ATR_LABEL_TYPE,buf);

  // Make value upper case
  strcpy(buf,text->value);
  VDstrupr(buf);
  VDpdfWriteAttrText(pdf,PDF_ATR_LABEL_TEXT,buf);

  //VPpdfWrite2dPt    (PDF_ATR_LABEL_LOCATION, label->org2D);
  for(i = 0; i < 6; i++) pts[i] = 0.0;
  pts[0] = atof(text->x1) - pdf->trn.x;
  pts[1] = atof(text->y1) - pdf->trn.y;
  pts[3] = atof(text->x2) - pdf->trn.x;
  pts[4] = atof(text->y2) - pdf->trn.y;
  VDpdfWrite2dPts(pdf,PDF_ATR_LABEL_LOCATION,2,pts);
  
  // Do the height/width
  val[0] = atof(text->height);
  val[1] = atof(text->width);
  VDpdfWriteAttrReals(pdf,PDF_ATR_LABEL_HEIGHT_WIDTH,2,val);

  // Done
  if (flag) VDpdfWriteAttrInt(pdf,PDF_ATR_OBJ_END,PDF_OBJ_LABEL);
  else      VDpdfWriteObjEnd (pdf,PDF_OBJ_LABEL);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Curve writing stuff
 */
typedef struct {
  IGRint    type;
  IGRdouble x,y,z;
} TVDpdfVertex;

IGRstat VDpdfWriteCvgCurve(TVDpdfFileInfo *pdf,
			   IGRint          recType,
			   IGRint          a_numCvgVertexes,
			   TVDcvgVertex   *a_cvgVertexes)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  IGRint  i,j;
  IGRint  len,hdrLen;

  IGRlong   numPoles;
  IGRdouble poles[3];

  IGRint    numBundles;
  IGRint    bundle;
  unsigned int long flag;

  IGRint    numPdfVertexes;

  TVDcvgVertex *cvgVertex;
  TVDpdfVertex *pdfVertex;
  TVDpdfVertex *pdfVertexes = NULL;
  
  /* Arg check */
  if (pdf           == NULL) goto wrapup;
  if (pdf->file     == NULL) goto wrapup;
  if (a_cvgVertexes == NULL) goto wrapup;

  // Say hi
  if (traceFlag) {
    printf(">>> VDpdfWriteCvgCurve %d\n",a_numCvgVertexes);
  }

  /* ---------------------------------------------
   * Worse case is need twice as many vertexes
   * as the cvg list to account for arcs
   *
   * Later on, can modify this routine to avod the need
   * for doing this conversion, should be able to
   * write the cvg stuff on the fly
   *
   * But getting the record length stuff just rite will be a pain
   * so just use code know works for now
   */
  pdfVertexes = (TVDpdfVertex*)calloc(2 * a_numCvgVertexes,sizeof(TVDpdfVertex));
  if (pdfVertexes == NULL) {
    printf("*** Problem allocating pdf vertexes\n");
    goto wrapup;
  }
  // Convert from cvg to pdf
  numPdfVertexes = 0;
  for(i = 0; i < a_numCvgVertexes; i++) {
    cvgVertex = &a_cvgVertexes[i];
    pdfVertex = &pdfVertexes[numPdfVertexes];

    pdfVertex->type = 0;
    pdfVertex->x = cvgVertex->endx - pdf->trn.x;
    pdfVertex->y = cvgVertex->endy - pdf->trn.y;
    pdfVertex->z = 0.0;
    numPdfVertexes++;

    if (a_cvgVertexes[i].type == *XML_CVG_VERTEX_TYPE_CARC_TO) {

      pdfVertex->type = 1;
      pdfVertex->x = cvgVertex->midx - pdf->trn.x;
      pdfVertex->y = cvgVertex->midy - pdf->trn.y;
      pdfVertex->z = 0.0;

      pdfVertex = &pdfVertexes[numPdfVertexes];
      pdfVertex->type = 0;
      pdfVertex->x = cvgVertex->endx - pdf->trn.x;
      pdfVertex->y = cvgVertex->endy - pdf->trn.y;
      pdfVertex->z = 0.0;
      numPdfVertexes++;
    }
  }
  if (numPdfVertexes == 0) goto wrapup;

  /* Bundle in groups of 32 */
  numBundles = ((numPdfVertexes - 1) / 32) + 1;
  len = (numPdfVertexes * 2) + numBundles;

  if (len > 250) hdrLen = 252;
  else           hdrLen = len;

  // printf("Length: %d, Points: %d, Bundles %d\n",len,vtxCnt,numBundles);

  VDpdfWriteHdr(pdf,recType,PDF_DT_2D_LINE_ARC,hdrLen);

  if (hdrLen == 252) {
    VDpdfWriteInt(pdf,len);
  }

  /* Go through bundle by bundle */
  for(bundle = 0; bundle < numBundles; bundle ++) {

    /* Control Flags */
    flag = 0;
    for(i = 0; i < 32; i++) {

      flag = flag >> 1;

      j = (bundle * 32) + i;
      if ((j < numPdfVertexes) && (pdfVertexes[j].type == 1)) flag |= 0x80000000;
    }
    VDpdfWriteInt(pdf,flag);

    /* Data */
    for(i = 0; i < 32; i++) {

      j = (bundle * 32) + i;
      if (j < numPdfVertexes) {

        /* Apply final matrix */
        poles[0] = pdfVertexes[j].x;
        poles[1] = pdfVertexes[j].y;
        poles[2] = pdfVertexes[j].z;
        numPoles = 1;
	
        VDpdfWriteReal(pdf,poles[0]);
        VDpdfWriteReal(pdf,poles[1]);
	
      }
    }
  }

  retFlag = 1;

wrapup:
  if (pdfVertexes) free(pdfVertexes);
  
  return retFlag;

}

/* -----------------------------------------------
 * Write a possibly parametric curve
 */
IGRstat VDpdfWriteCvgCurveParametric(TVDpdfFileInfo *pdf,
				     IGRint          recType,
				     TVDcvgCurve    *crv)
{
  IGRstat retFlag = 0;
  
  /* Arg check */
  if (pdf       == NULL) goto wrapup;
  if (pdf->file == NULL) goto wrapup;
  if (crv       == NULL) goto wrapup;

  // If not parametric then just write normally
  if (*crv->type == 0) {
    retFlag = VDpdfWriteCvgCurve(pdf,recType,crv->numVertexes,crv->vertexes);
    goto wrapup;
  }
  
  // Look for circle
  if (!strcmp(crv->type,XML_CVG_CURVE_TYPE_CIRCLE)) {
    VDpdfWriteHdr (pdf,recType,PDF_DT_2D_CIRCLE,3);
    VDpdfWriteReal(pdf,crv->center[0]);
    VDpdfWriteReal(pdf,crv->center[1]);
    VDpdfWriteReal(pdf,crv->radius * 2.0);
    retFlag = 1;
    goto wrapup;
  }
  // Look for ellipse
  if (!strcmp(crv->type,XML_CVG_CURVE_TYPE_ELLIPSE)) {
    VDpdfWriteHdr (pdf,recType,PDF_DT_2D_ELLIPSE,6);
    VDpdfWriteReal(pdf,crv->center[0]);
    VDpdfWriteReal(pdf,crv->center[1]);
    VDpdfWriteReal(pdf,crv->major [0]);
    VDpdfWriteReal(pdf,crv->major [1]);
    VDpdfWriteReal(pdf,crv->minor [0]);
    VDpdfWriteReal(pdf,crv->minor[1]);
    retFlag = 1;
    goto wrapup;
  }
  // Look for oval
  if (!strcmp(crv->type,XML_CVG_CURVE_TYPE_OVAL)) {
    VDpdfWriteHdr (pdf,recType,PDF_DT_2D_OVAL,6);
    VDpdfWriteReal(pdf,crv->center[0]);
    VDpdfWriteReal(pdf,crv->center[1]);
    VDpdfWriteReal(pdf,crv->major [0]);
    VDpdfWriteReal(pdf,crv->major [1]);
    VDpdfWriteReal(pdf,crv->minor [0]);
    VDpdfWriteReal(pdf,crv->minor[1]);
    retFlag = 1;
    goto wrapup;
  }
  
  // Cannot handle this kind yet
  retFlag = VDpdfWriteCvgCurve(pdf,recType,crv->numVertexes,crv->vertexes);
  
wrapup:
  return retFlag;
}


/* ----------------------------------------
 * Open pdf file 
 */
IGRstat VDpdfOpenOutputFile(TVDpdfFileInfo *pdf, IGRchar *fileName)
{
  IGRstat retFlag = 0;

  // Arg check
  if (pdf == NULL) goto wrapup;
  memset(pdf,0,sizeof(TVDpdfFileInfo));
  if (fileName == NULL) goto wrapup;
  
  /* Open it */
  strcpy(pdf->fileName,fileName);
  pdf->file = fopen(pdf->fileName,"wb");
  if (pdf->file == NULL) {
    printf("Problem opening %s for writing\n",pdf->fileName);
    goto wrapup;
  }
   
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Close pdf file 
 */
IGRstat VDpdfCloseOutputFile(TVDpdfFileInfo *pdf)
{
  IGRint  retFlag = 0;
  IGRchar cmd[256];
  
  /* Check it */
  if (pdf       == NULL) goto wrapup;
  if (pdf->file == NULL) goto wrapup;

  /* Close It */
  fclose(pdf->file);
  pdf->file = NULL;
   
  // Adjust permissions
  sprintf(cmd,"chmod 777 %s",pdf->fileName);
  system (cmd);
  
  /* Done */
  retFlag = 1;
  
wrapup:
  return retFlag;
}


