/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalComputeStdPc.c
 *
 * Description: Standard Piece Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalCompStdPc.c,v $
 *      Revision 1.2  2001/11/16 15:18:11  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/11/09 15:04:28  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDbuf.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDdraw.h"
#include "VDobj2.h"

#include "VDval.h"
#include "VDvalLike.h"

#include "VDctx.h"
#include "VDss.h"

#include "glib.h"

VDASSERT_FFN("VDvalComputeStdPc.c");


/* -----------------------------------------------
 * Compute an xml standard piece
 */
IGRstat VDvalComputeStdPc(TGRobj_env *macOE,
			  IGRint      opFlag,
			  IGRint     *feetCntx,
			  TGRid      *feetIDs)
{
  VDASSERT_FN("VDvalComputeStdPc");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env pieceOE;
  TGRid      pieceID;
    
  IGRint     i,j;
  IGRint     feetCnt = 0;
  TGRmd_env *env;

  IGRchar *buf;
  
  TGRbsp_curve *crv = NULL;
  TGRid  crvID;
  
  TGRmdenv_info mat;
  
  IGRdouble dis;
  
  IGRdouble pt3d[9];
  IGRdouble pt2d[9];
  
  IGRchab pcmk;
  IGRint  pcmki;
  
  // Init
  pieceID.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(feetCntx); *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;
  
  // Grab the internal data
  VDbufGetDomTree(macOE,&pieceID);
  VDASSERTW(pieceID.objid != NULL_OBJID);

  // Get the outer contour
  sts = VDctxGetTxtAtrPtr(&pieceID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,&buf);
  VDASSERTW(sts);
  VDvalConvertTextToBspCurve(buf,&crv);
  VDASSERTW(crv);
  VDgeom2CloseCurve(crv);
  VDdrawCurve(crv,env,&crvID);
  if (crvID.objid != NULL_OBJID) {
    feetIDs[feetCnt] = crvID;
    feetCnt++;
  }

  // Matrix stuff
  VDgeom2GetCurveRange(crv,&pt3d[0],&pt3d[3]);
  VDgeom2GetCurveRange(crv,&pt3d[0],&pt3d[6]);

  // Generates 3d major/minor axis
  pt3d[4] = pt3d[1];
  pt3d[8] = pt3d[2];
  
  // Calculate origin based on pcmk
  VDctxGetTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_PCMK,pcmk);
  pcmki = atoi(pcmk);
  if (pcmki >= 9000) pcmki -= 9000;
  
  // 2D Origin
  pt2d[0] = pt2d[3] = pt2d[6] = (pcmki % 50) * 1000.0;
  pt2d[1] = pt2d[4] = pt2d[7] = (pcmki / 50) * 1000.0;
  pt2d[2] = pt2d[5] = pt2d[8] =    0.0;

  // 2d major/minor axis
  VDgeom2GetDisPtPt(&pt3d[0],&pt3d[3],&dis);
  pt2d[4] += dis;

  VDgeom2GetDisPtPt(&pt3d[0],&pt3d[6],&dis);
  pt2d[6] += dis;
  
  // Actual matrix and transformation
  VDgeom2GenMatrix(pt3d,pt2d,&mat.matrix_type,mat.matrix);
  
  VDgeom2TransformCurve(crv,&mat,NULL);
  VDdrawCurve(crv,env,&crvID);
  if (crvID.objid != NULL_OBJID) {
    feetIDs[feetCnt] = crvID;
    feetCnt++;
  }
    
  // Done
  *feetCntx = feetCnt;
  retFlag = 1;

 wrapup:
  
  VDctxDeleteNode(&pieceID);
  
  if (crv) free(crv);
  
  return retFlag;
}

/* -----------------------------------------------
 * Place the given std pcmk macro 
 */
void VDvalPlaceStdPcMacro(IGRchar *pcmk, TGRobj_env *macOE)
{
  VDASSERT_FN("VDvalPlaceStdPcMacro");

  IGRstat sts;
  
  TGRid pcmkID;
  TGRid geomID;
  TGRid pieceID;
  
  IGRchar *geom_key  = NULL;
  IGRchar *geom_data = NULL;
  
  IGRchab buf;
  
  // Arg check
  VDASSERTW(macOE); macOE->obj_id.objid = NULL_OBJID;
  VDASSERTW(pcmk && *pcmk);
  
  // Query for attributes
  VDvalQryStdPcmk2ByPcmk(pcmk,&pcmkID);
  if (pcmkID.objid == NULL_OBJID) goto wrapup;
  
  // Query for actual geometry
  sts = VDctxGetTxtAtrPtr(&pcmkID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&geom_key);
  if (!(sts & 1)) goto wrapup;
  
  VDvalQryStdGeom2(geom_key,&geomID);
  VDASSERTW(geomID.objid != NULL_OBJID);

  sts = VDctxGetTxtAtrPtr(&geomID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,&geom_data);
  if (!(sts & 1)) goto wrapup;
  
  // Build my own little piece node
  VDctxCreateXdomTree("piece",NULL,&pieceID);
  VDctxAppTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_PCMK,pcmk);

  VDctxGetTxtAtr( &pcmkID,VDCTX_STD_PCMK_ATR_GRADE,buf);
  VDctxAppTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_GRADE,buf);

  VDctxGetTxtAtr( &pcmkID,VDCTX_STD_PCMK_ATR_THICK,buf);
  VDctxAppTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_THICK,buf);

  VDctxAppTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_key);
  VDctxAppTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_OUTER_CONTOUR,geom_data);

  // And place it
  VDbufPlaceMacro("VDxml","xml_stdpc",pcmk,NULL,&pieceID,macOE);
  VDctxDeleteNode(&pieceID);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Have a geometry key that is not in the database
 */
static void addToTree(IGRchar *modelFileName, TGRobj_env *pieceOE, IGRchar *geom_key, TGRid *treeID)
{
  IGRstat sts;
  
  TGRid pieceID;
  IGRint i;

  IGRchar *geom_keyx;
  IGRchab  fam_part1,fam_part2;
  
  FILE *file = NULL;
  
  // Create a tree if necessary
  if (treeID->objid == NULL_OBJID) {
    VDctxCreateXdomTree("pieces",NULL,treeID);
  }
  
  // Check if already processed
  for(i = 0; VDctxGetNthTreeChild(treeID,i,&pieceID); i++) {

    VDctxGetTxtAtrPtr(&pieceID,VDCTX_STD_PCMK_ATR_GEOM_KEY,&geom_keyx);
    if (!strcmp(geom_key,geom_keyx)) goto wrapup;
    
  }

  // New node
  VDctxCreateNode(treeID,"piece",NULL,&pieceID);
  VDctxAppTxtAtr(&pieceID,VDCTX_STD_PCMK_ATR_GEOM_KEY,geom_key);
  // printf("*** %s\n",geom_key);

  // Master results file
  file = fopen("/usr/tmp/missing.txt","a+t");
  
  // What is missing
  VDvalQryMissingStdGeom2(geom_key,fam_part1,fam_part2);
  if (*fam_part1) {
    VDctxAppTxtAtr(&pieceID,"fam_part1",fam_part1);
    printf("Penetrated  %s\n",fam_part1);
    if (file) fprintf(file,"%s Penetrated  %s\n",modelFileName,fam_part1);
  }
  if (*fam_part2) {
    VDctxAppTxtAtr(&pieceID,"fam_part2",fam_part2);
    printf("Penetrating %s\n",fam_part2);
    if (file) fprintf(file,"%s Penetrating %s\n",modelFileName,fam_part2);
  }
  if (file) {
    fclose(file);
    system("chmod 777 /usr/tmp/missing.txt");
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Validate that all possible standard pieces
 * have a geometry key
 */
void VDvalCheckStdPcGeom(TVDtestTestInfo *info)
{
  VDASSERT_FN("VDvalCheckStdPcGeom");
  
  TGRid   treeID;

  IGRchab buf,unit,modelFileName;
  
  VDosnum modelOS;

  IGRint  plateCnt,beamCnt,pieceCnt;
  
  TGRid  *listPieces = NULL;
  TGRobj_env pieceOE;
  
  IGRint i;
  
  IGRchab geom_key,grade,thick;
  
  TGRid geomID;
  
  // Init
  treeID.objid = NULL_OBJID;
  
  VDnfmOpenEnv(NULL,NULL,NULL);
  
  // The os number
  VDrrvGetDefaultUnitModel(unit,modelFileName);
  VDosGetFileNameOS(modelFileName,&modelOS);
  if (modelOS == OM_K_NOT_AN_OS) goto wrapup;

  // Grab the pieces
  VDobjGetPieces(modelOS, &plateCnt, &beamCnt, &listPieces);
  pieceCnt = plateCnt + beamCnt;

  // Cycle through
  for(i = 0; i < pieceCnt; i++) {
    pieceOE.obj_id = listPieces[i];
    VDobjResetOE(&pieceOE);

    // Grab the key if any
    VDvalGetStdPcmk2Info(&pieceOE,geom_key,grade,thick);
    if (*geom_key) {

      // Look it up
      VDvalQryStdGeom2(geom_key,&geomID);
      if (geomID.objid == NULL_OBJID) {	
	addToTree(modelFileName,&pieceOE,geom_key,&treeID);
      }
    }    
  }

  // Process the results

  // Done
  if (info) info->worked = 1;
  
 wrapup:

  VDctxDeleteNode(&treeID);
  
  g_free(listPieces);
  
  return;
}
