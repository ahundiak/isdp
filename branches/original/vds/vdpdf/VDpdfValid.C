/* $Id: VDpdfValid.C,v 1.1 2001/01/11 19:42:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdpdf/VDpdfValid
 *
 * Description: Validate pdf dom tree
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDpdfValid.C,v $
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

VDASSERT_FFN("vds/vdpdf/VDpdfValid.C");

/* -----------------------------------------------
 * Need a little structure to hold specific part information
 * mainly for error reporting
 */
typedef struct 
{
  IGRint     errorCnt;
  FILE      *file;
  TVDdomEle *ele;
  IGRchar    name[32];
} TVDpdfPieceInfo;

static IGRstat pdfValidateDomTreeLabel(TVDpdfPieceInfo *pieceInfo, TVDdomEle *labelEle);

/* -----------------------------------------------
 * Validate a marking object
 */
static IGRstat pdfValidateDomTreeCurve(TVDpdfPieceInfo *pieceInfo, 
				       TVDdomEle       *curveEle,
				       IGRdouble        minLength)
{
  VDASSERT_FN("pdfValidateDomTreeCurve");
  IGRstat retFlag = 0;

  FILE *file = pieceInfo->file;
  
  TVDdomEle *verEle;
  TVDdomAtr *verAtr;

  struct 
  {
    IGRint     cnt;
    IGRdouble  dbls[3];
    TVDdomAtr *atr;
    IGRpoint   pt;
  } ver0,ver1;
  
  IGRint verCnt = 0;
  IGRdouble length;
  
  // Is it a marking line
  if (strcmp(curveEle->type,"PDF_OBJ_CURVE")) goto wrapup;
  
  // Bad error from here
  retFlag = 2;

  // Cycle through attributes
  verCnt = 0;
  ver0.atr = NULL;
  ver1.atr = NULL;
  verEle = curveEle->children;
  while(verEle) {

    // Make sure its a vertex
    if (strcmp(verEle->type,"PDF_OBJ_VERTEX")) {
      printf("*** Bad vertex object\n");
      goto wrapup;
    }
    
    // Grab the attribute
    VDdomFindAttributeByType(verEle,"PDF_ATR_VERTEX",&verAtr);
    if (verAtr == NULL) {
      printf("*** Bad vertex attribute\n");
      goto wrapup;
    }
    
    // Should only be one attribute

    // Track first and liast attribute
    if (verCnt == 0) ver0.atr = verAtr;
    else             ver1.atr = verAtr;
    
    // Next
    verCnt++;
    verEle = verEle->sibling;
  }

  // Need two end points
  if ((ver0.atr == NULL) || (ver1.atr == NULL)) {
    printf("Missing vertexes for curve\n");
    goto wrapup;
  }
  
  // Pull out the data
  VDdomGetDoublesFromAttribute(ver0.atr->value,3,&ver0.cnt,ver0.dbls);
  VDdomGetDoublesFromAttribute(ver1.atr->value,3,&ver1.cnt,ver1.dbls);
  
  // Get the arc length
  ver0.pt[0] = ver0.dbls[1];
  ver0.pt[1] = ver0.dbls[2];
  ver0.pt[2] = 0.0;
  ver1.pt[0] = ver1.dbls[1];
  ver1.pt[1] = ver1.dbls[2];
  ver1.pt[2] = 0.0;

  // VDgeomGetDisPtPt(ver0.pt,ver1.pt,&length);
  length = 1000.0;
  
  // Check the distance
  if (length < minLength) {
    printf("*** Short Curve %.2f %.2f\n",minLength,length);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Validate a marking object
 */
static IGRstat pdfValidateDomTreeMarking(TVDpdfPieceInfo *pieceInfo, TVDdomEle *markEle)
{
  VDASSERT_FN("pdfValidateDomTreeMarking");
  IGRstat retFlag = 0;
  IGRstat sts,sts1,sts2;
  
  TVDdomAtr *typeAtr;
  TVDdomEle *childEle;
  
  IGRint haveCurve;
  IGRint haveLabel;
  
  IGRint atrCnt;
  
  FILE *file = pieceInfo->file;
  
  // Is it a marking line
  if (strcmp(markEle->type,"PDF_OBJ_MARKING_LINE")) goto wrapup;
  
  // Bad error from here
  retFlag = 2;

  // Get the type
  VDdomFindAttributeByType(markEle,"PDF_ATR_MARKING_LINE_TYPE",&typeAtr);

  // Validate marking type
  if (typeAtr == NULL) {
    fprintf(file,"*** %s has marking with no type\n",
	    pieceInfo->name);
    pieceInfo->errorCnt++;
    goto wrapup;
  }

  // Make sure have only 1 attribute
  VDdomGetAttributeCount(markEle,&atrCnt);
#if 0
  if (atrCnt != 1) {
    fprintf(file,"*** %s has marking %s with %d attributes (should be 1)\n",
	    pieceInfo->name,typeAtr->value,atrCnt);
    pieceInfo->errorCnt++;
    goto wrapup;
  }
#endif
  printf("Mark  %s %s\n",pieceInfo->name,typeAtr->value);

  // Cycle through kids (labels or curves)
  haveCurve = 0;
  haveLabel = 1;
  
  childEle = markEle->children;
  while(childEle) {
    
    // Label
    sts1 = pdfValidateDomTreeLabel(pieceInfo,childEle);
    if (sts1 & 1) haveLabel++;
    
    // Curve
    sts2 = pdfValidateDomTreeCurve(pieceInfo,childEle,50.0);
    if (sts2 & 1) haveCurve++;

    // Something besides label or curve?
    if ((sts1 == 0) && (sts2 == 0)) {
      fprintf(file,"*** Marking %s %s has invalid child %s\n",
	      pieceInfo->name,typeAtr->value,childEle->type);
      pieceInfo->errorCnt++;
      goto wrapup;
    }
    
    // Next child
    childEle = childEle->sibling;
  }

  // Make sure have a curve
  if (haveCurve == 0) {
    fprintf(file,"*** Marking %s %s has no curve\n",
	    pieceInfo->name,typeAtr->value);
    pieceInfo->errorCnt++;
  }
  
  // Is a label always required?
  if (haveCurve == 0) {
    fprintf(file,"*** Marking %s %s has no label\n",
	    pieceInfo->name,typeAtr->value);
    pieceInfo->errorCnt++;
    goto wrapup;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Validate a single label structure
 */
static IGRstat pdfValidateDomTreeLabel(TVDpdfPieceInfo *pieceInfo, TVDdomEle *labelEle)
{
  VDASSERT_FN("pdfValidateDomTreeLabel");
  IGRstat retFlag = 0;
  
  TVDdomAtr *typeAtr;
  TVDdomAtr *textAtr;
  TVDdomAtr *locxAtr;
  TVDdomAtr *sizeAtr;
  
  IGRint atrCnt;
  
  FILE *file = pieceInfo->file;
  
  // Is it a label
  if (strcmp(labelEle->type,"PDF_OBJ_LABEL")) goto wrapup;
  
  // Return of 2 means an actual error
  retFlag = 2;
  
  // All labels should have four attributes
  VDdomFindAttributeByType(labelEle,"PDF_ATR_LABEL_TYPE",        &typeAtr);
  VDdomFindAttributeByType(labelEle,"PDF_ATR_LABEL_TEXT",        &textAtr);
  VDdomFindAttributeByType(labelEle,"PDF_ATR_LABEL_LOCATION",    &locxAtr);
  VDdomFindAttributeByType(labelEle,"PDF_ATR_LABEL_HEIGHT_WIDTH",&sizeAtr);
  
  // Validate label type
  if (typeAtr == NULL) {
    fprintf(file,"*** %s has label with no type\n",
	    pieceInfo->name);
    pieceInfo->errorCnt++;
    goto wrapup;
  }
  if ((textAtr == NULL) || (*textAtr->value == 0)) {
    fprintf(file,"*** %s has label of type %s with no text \n",
	   pieceInfo->name,typeAtr->value);
    pieceInfo->errorCnt++;
    goto wrapup;
  }
  
  // Warn about labels starting with blank
  if (*textAtr->value == ' ') {
    fprintf(file,"*** %s has label of type %s '%s' with blank text \n",
	   pieceInfo->name,typeAtr->value,textAtr->value);
    pieceInfo->errorCnt++;
  }
  
  // Make sure have only 4
  VDdomGetAttributeCount(labelEle,&atrCnt);
  if (atrCnt != 4) {
    fprintf(file,"*** %s has label %s %s with %d attributes (should be 4)\n",
	    pieceInfo->name,typeAtr->value,textAtr->value,atrCnt);
    pieceInfo->errorCnt++;
    goto wrapup;
  }
  
  printf("Label %s %s %s\n",pieceInfo->name,typeAtr->value,textAtr->value);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Validate a single piece tree child
 */
static IGRstat pdfValidateDomTreePieceChild(TVDpdfPieceInfo *pieceInfo, TVDdomEle *childEle)
{
  VDASSERT_FN("VDpdfValidateDomTreePieceChild");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  // Labels
  sts = pdfValidateDomTreeLabel(pieceInfo,childEle);
  if (sts) goto wrapup;
  
  // Markings
  sts = pdfValidateDomTreeMarking(pieceInfo,childEle);
  if (sts) goto wrapup;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Validate a single plate tree
 */
IGRstat VDpdfValidateDomTreePlate(FILE *file, TVDdomEle *plateEle)
{
  VDASSERT_FN("VDpdfValidateDomTreePlate");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDdomAtr *pcmkAtr;

  TVDdomEle *childEle;

  TVDpdfPieceInfo pieceInfo;
  
  // Arg check
  VDASSERTW(plateEle);
  sts = strcmp(plateEle->type,"PDF_OBJ_PLATE");
  VDASSERTW(sts == 0);

  // Adjust status file
  if (file == NULL) file = stdout;
  
  // Get the piece mark
  VDdomFindAttributeByType(plateEle,"PDF_ATR_TREE_NODE_PCMK",&pcmkAtr);
  VDASSERTW(pcmkAtr);
  
  // Setup info
  memset(&pieceInfo,0,sizeof(TVDpdfPieceInfo));
  pieceInfo.ele = plateEle;
  sprintf(pieceInfo.name,"%s %s","PLATE",pcmkAtr->value);
  pieceInfo.file = file;
  
  // Say Hi
  printf("----------------------------------------\n");
  printf("PIECE %s\n",pieceInfo.name);
  
  // Start processing assorted children
  childEle = plateEle->children;
  while(childEle) {

    // Marking lines

    // Labels
    pdfValidateDomTreePieceChild(&pieceInfo,childEle);
    
    // Next child
    childEle = childEle->sibling;
    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Check for various spades problems in the dom tree
 */
IGRstat VDpdfValidateDomTree(TVDdomEle *rootEle)
{
  VDASSERT_FN("VDpdfValidateDomTree");
  IGRstat retFlag = 0;

  TVDdomEle *platesEle = NULL;
  TVDdomEle *plateEle  = NULL;
  
  // Arg check
  VDASSERTW(rootEle);
  
  // Get the parts section
  VDdomFindElementByType(rootEle,"PDF_OBJ_PLATES",&platesEle);
  if (platesEle == NULL) {
    printf("Not plates in pdf dom tree\n");
    goto wrapup;
  }
  // Cycle through
  plateEle = platesEle->children;
  while(plateEle) {
    
    // Check it
    VDpdfValidateDomTreePlate(NULL,plateEle);
    
    // Next one
    plateEle = plateEle->sibling;
  }
  
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}




