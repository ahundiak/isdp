class implementation Root;

#include "VDtypedef.h"

#include "VPpdf.h"

/* -----------------------------------------------------
 * Use static globals for output files
 */
static FILE *pdfBinFile;

IGRstar VPpdfSetBinFile(FILE *file) 
{
  pdfBinFile = file;
  return 1;
}

FILE *VPpdfGetBinFile()
{
  return pdfBinFile;
}


/* -----------------------------------------------------
 * Write int
 */
IGRstar VPpdfWriteInt(IGRlong val)
{
  unsigned char *p;
  int i;

  p = (unsigned char *)&val;

  for(i = 3; i >= 0; i--) {
    if (pdfBinFile) fwrite(p+i,1,1,pdfBinFile);
  }
  return 1;
}

/* -----------------------------------------------------
 * Write real
 */
IGRstar VPpdfWriteReal(IGRdouble val)
{
  unsigned char *p;
  int i;

  float f = (float)val;

  p = (unsigned char *)&f;

  for(i = 3; i >= 0; i--) {
    if (pdfBinFile) fwrite(p+i,1,1,pdfBinFile);
  }

  return 1;
}

/* -----------------------------------------------------
 * Write real attribute
 */
IGRstar VPpdfWriteAttrReal(IGRint recType, IGRdouble val)
{

  VPpdfWriteHdr(recType,PDF_DT_REAL,1);

  VPpdfWriteReal(val);

  return 1;
}

/* -----------------------------------------------------
 * Write int attribute
 */
IGRstar VPpdfWriteAttrInt(IGRint recType, IGRlong val)
{

  VPpdfWriteHdr(recType,PDF_DT_INT,1);

  VPpdfWriteInt(val);

  return 1;
}

/* -----------------------------------------------------
 * Write text attribute
 */
IGRstar VPpdfWriteAttrText(IGRint recType, IGRchar *val)
{
  IGRstat retFlag = 0;
  
  IGRint  len,adj;

  IGRchar buf[1024];

  IGRchar *p;
  
  // Arg Check
  if (val == NULL) goto wrapup;

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
  VPpdfWriteHdr(recType,PDF_DT_TEXT,len / 4);

  // printf("Text %2d '%s'\n",len,buf);
  
  if (pdfBinFile) fwrite(buf,len,1,pdfBinFile);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Write text attribute
 */
IGRstar VPpdfWriteAttrText1(IGRint recType, IGRchar *val)
{
  IGRstat retFlag = 0;
  
  IGRint  len,adj,wlen;
  IGRlong val0 = 0;
  
  // Arg Check
  if (val == NULL) goto wrapup;
  
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

  VPpdfWriteHdr(recType,PDF_DT_TEXT,wlen);

  if (pdfBinFile) fwrite( val,len,1,pdfBinFile);

  if (adj) {
    if (pdfBinFile) fwrite(&val0,adj,1,pdfBinFile);
  }
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}
    
/* --------------------------------------------------------------------
 * Write Record Header
 */
IGRstar VPpdfWriteHdr(IGRint recType, IGRint dataType, IGRint dataLen) 
{
  IGRstat retFlag = 0;
  
  struct {
    unsigned char recType1,recType2,dataType,dataLen;
  } hdr;

  hdr.recType1  = (recType & 0xFF00) >> 8;
  hdr.recType2 =  (recType & 0x00FF);

  hdr.dataType = dataType;
  hdr.dataLen  = dataLen;

  if (pdfBinFile) fwrite(&hdr,sizeof(hdr),1,pdfBinFile);
  
  retFlag = 1;
  
  return retFlag;;
}

/* ---------------------------------------------------
 * Beginning of an object
 */
IGRstar VPpdfWriteObjBeg(IGRint recType) 
{
  IGRint  type;
  
  type = recType | PDF_OBJ_BEG_MASK;
  
  VPpdfWriteHdr(
    type,
    PDF_OBJ_DT,
    PDF_OBJ_LEN
  );
  
//wrapup:
  return 1;
}

/* ---------------------------------------------------
 * Ending of an object
 */
IGRstar VPpdfWriteObjEnd(IGRint recType) 
{
  IGRint type;
  
  type = recType | PDF_OBJ_BEG_MASK | PDF_OBJ_END_MASK;
  
  VPpdfWriteHdr(type,
		PDF_OBJ_DT,
		PDF_OBJ_LEN);

//wrapup: 
  return 1;
}

/* ---------------------------------------------------
 * Write 3d end point attributes
 */
IGRstar VPpdfWrite3dEndPts(IGRint recType, TGRbsp_curve *bsp)
{
  IGRstat retFlag  = 0;
  IGRint  dataType = PDF_DT_3D_PTS;
  IGRint  dataLen  = 3 * 2;
  
  IGRint i,ix;
  
  // Arg Check
  if (bsp == NULL) goto wrapup;

  // Put out the header
  VPpdfWriteHdr(recType,dataType,dataLen);

  // And the data
  for(i = 0; i < 3; i++) {
    VPpdfWriteReal(bsp->poles[i]);
  }
  ix = 3 * (bsp->num_poles - 1);
  for(i = 0; i < 3; i++) {
    VPpdfWriteReal(bsp->poles[i+ix]);
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Write array of 3d points
 */
IGRstar VPpdfWrite3dPts(IGRint recType, IGRint ptCnt, IGRdouble *pts)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_3D_PTS;
  IGRint  dataLen  = 3 * ptCnt;
  
  IGRint i,j;
  
  // Arg Check
  if (pts == NULL) goto wrapup;

  // Put out the header
  VPpdfWriteHdr(recType,dataType,dataLen);

  // And the data
  for(i = 0; i < ptCnt; i++) {
          
    for(j = 0; j < 3; j++) {
      
      VPpdfWriteReal(pts[(3*i)+j]);
      
    }    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Write single 2D point
 */
IGRstar VPpdfWrite2dPt(IGRint recType, IGRdouble *pt)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_2D_PT;
  IGRint  dataLen  = 2;
  
  // Arg Check
  if (pt == NULL) goto wrapup;

  // Put out the header
  VPpdfWriteHdr(recType,dataType,dataLen);

  // And the data
  VPpdfWriteReal(pt[0]);
  VPpdfWriteReal(pt[1]);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ---------------------------------------------------
 * Write 2D points
 */
IGRstar VPpdfWrite2dPts(IGRint recType, IGRint ptCnt, IGRdouble *pts)
{
  IGRstat retFlag  = 0;

  IGRint  dataType = PDF_DT_2D_PTS;
  IGRint  dataLen  = 2 * ptCnt;
  IGRint  i;
  
  // Arg Check
  if (pts == NULL) goto wrapup;

  // Put out the header
  VPpdfWriteHdr(recType,dataType,dataLen);

  // And the data
  for(i = 0; i < ptCnt; i++) {
          
    // And the data
    VPpdfWriteReal(pts[(3*i)+0]);
    VPpdfWriteReal(pts[(3*i)+1]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;

