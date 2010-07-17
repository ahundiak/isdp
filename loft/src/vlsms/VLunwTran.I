/* $Id: VLunwTran.I,v 1.7 2001/06/27 15:34:43 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLunwMisc.I
 *
 * Description: 2D to 3D Translation routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLunwTran.I,v $
 * Revision 1.7  2001/06/27 15:34:43  ahundiak
 * ah
 *
 * Revision 1.6  2001/06/22 15:12:24  ahundiak
 * ah
 *
 * Revision 1.5  2001/06/15 13:27:34  ahundiak
 * ah
 *
 * Revision 1.4  2001/06/14 18:29:20  ahundiak
 * ah
 *
 * Revision 1.3  2001/06/08 20:50:03  ahundiak
 * ah
 *
 * Revision 1.2  2001/06/07 21:00:38  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/05/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDxml.h"
#include "VDcvg.h"
#include "VDsa.h"

#include "vddrwattr.h"
#include "vlmsg.h"
#include "vlstructure.h"
#include "vlunwext.h"

#include "VLunwMisc.h"

#include "mainvmx.h"
#include "mamulmx.h"
#include "matypemx.h"
#include "maoptsxfo.h"

VDASSERT_FFN("vlsms/VLunwTran.I");

extern IGRstat VLunw2GetRange  __((TGRobj_env *unwrapOE, GRrange range));
extern IGRstat VLunwGet3Points __((TGRobj_env *unwrapOE, IGRdouble *pts));

extern IGRlong VLunwGetPointOnPlate __((TGRobj_env *unwrapOE,
					IGRint	 num_pt,
					IGRdouble  *pt_unw,
					IGRdouble  *pt_plate));



from GRcurve import GRgetrang;

/* -------------------------------------------------------------------
 * Wrapper for the get range code
 * Using the Getrang meth results in bigger ranges for a few
 * pieces which in turn messes up some of th 2d to 3d transformation
 *
 * Try getting the min rect then using it's range
 */
IGRstat VLunw2GetRange(TGRobj_env *unwrapOE, GRrange range)
{
  VDASSERT_FN("VLunw2GetRange");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRboolean world = TRUE;
  
  TGRobj_env rectOE;
  
  // Arg check
  VDASSERTW(range);
  VDASSERTW(unwrapOE && unwrapOE->obj_id.objid != NULL_OBJID);

  // Use min rect
  VLunwGetMinRectangle(unwrapOE,&rectOE);
  VDASSERTW(rectOE.obj_id.objid != NULL_OBJID);
  
  // Cross fingers and hope this works
  world = FALSE;
  sts = om$send(msg = message GRcurve.GRgetrang(&msg,
						NULL,NULL,
						&world,
						range),
		senderid = NULL_OBJID,
		targetid = rectOE.obj_id.objid,
		targetos = rectOE.obj_id.osnum);
  VDASSERTW(sts & msg & 1);
  
  if (traceFlag) {    
    printf("Range %8.2f %8.2f %8.2f\n",range[0],range[1],range[2]);
    printf("      %8.2f %8.2f %8.2f\n",range[3],range[4],range[5]);
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Returns a 2d to 3d transformation matrix
 * Basically takes three points from the unwrap
 * Maps them to 3d space then generates the matrix
 *
 * Does not yet work right for boundary mesh plates
 * Because of VLunwGetPointOnPlate()

 */
IGRstat VLunw2GetMatrix(TGRobj_env *unwrapOE, IGRshort *type, IGRdouble *mat4x4)
{
  IGRstat retFlag = 0;
  IGRstat msg;
  
  GRrange range;
  IGRdouble  pt2d[9];
  IGRdouble  pt3d[9];

#if 0
  // Want the 2d range
  VLunw2GetRange(unwrapOE,range);
  pt2d[0] = range[0]; // X1
  pt2d[1] = range[1]; // Y1
  pt2d[2] = range[2]; // Z1
  pt2d[3] = range[3]; // X2
  pt2d[4] = range[1]; // Y1
  pt2d[5] = range[2]; // Z1
  pt2d[6] = range[0]; // X1
  pt2d[7] = range[4]; // Y2
  pt2d[8] = range[2]; // Z1
#endif
#if 0
  // 2d points
  VLunwGet3Points(unwrapOE,pt2d);
  
  // 3d points
  VLunwGetPointOnPlate(unwrapOE,3,pt2d,pt3d);
  
  // Majic to get a 4x4 matrix
  VDgeom2GenMatrix(pt2d,pt3d,type,mat4x4);
#endif

  // New routine
  VLunwGetUnwrapTransMatrix(unwrapOE,1,type,mat4x4);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * From the unwrap, get three ortho points
 * suitable for generating a translation matrix
 */
IGRstat VLunwGet3Points(TGRobj_env *unwrapOE, IGRdouble *pt2d)
{
  VDASSERT_FN("VLunwGet3Points");
  IGRstat retFlag = 0;
  
  TGRobj_env contourOE;
  TGRbsp_curve *crv = NULL;

  IGRpoint pt;
  IGRint i,j;
  
  GRrange range;
  
  // Arg check
  VDASSERTW(pt2d);
  VDASSERTW(unwrapOE && unwrapOE->obj_id.objid != NULL_OBJID);

  // Want the 2d range
  VLunw2GetRange(unwrapOE,range);
  pt2d[0] = range[0]; // X1
  pt2d[1] = range[1]; // Y1
  pt2d[2] = range[2]; // Z1
  pt2d[3] = range[3]; // X2
  pt2d[4] = range[1]; // Y1
  pt2d[5] = range[2]; // Z1
  pt2d[6] = range[0]; // X1
  pt2d[7] = range[4]; // Y2
  pt2d[8] = range[2]; // Z1

#if 0  
  // Use the center of the contour as a start
  VLunwGetExternalContour(unwrapOE,&contourOE);
  VDASSERTW(contourOE.obj_id.objid != NULL_OBJID);
  vdgeom$Get2(objOE = &contourOE, crv = &crv);
  VDASSERTW(crv);

  VDgeom2GetCurveCenter(crv,pt);
  for(i = 0; i < 3; i++) {
    for(j = 0; j < 3; j++) {
      pts[(i*3)+j] = pt[j];
    }
  }
  // Vector a bit
  pts[3] += 2.0; // X
  pts[7] += 3.0; // Y
#endif

  // Done
  retFlag = 1;
  
 wrapup:
  _FREE(crv); 
  return retFlag;
}

/* -----------------------------------------------
 * Compute routine for unw_tran
 */
IGRstat VLunwComputeTran(TGRobj_env *macOE,
			 IGRint      opFlag,
			 IGRint     *feetCnt,
			 TGRid      *feetIDs)
{
  VDASSERT_FN("VLunwComputeTran");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env unwrapOE;
  TGRobj_env plateOE;
  IGRchar pcmk[32];
  
  IGRdouble pt2d[9];
  IGRdouble pt3d[9];
  
  IGRdouble matrix [16];
  IGRdouble matrix2[16];
  
  TGRobj_env contourOE;
  TGRbsp_curve *crv = NULL;
  TGRid crvID;

  IGRint i,j,k;
  
  IGRshort type;
  IGRlong  three = 3;
  BSrc     rc;
  
  // Arg check
  VDASSERTW(feetCnt); *feetCnt = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
    
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = 0,
                    templateOE = &unwrapOE);
  VDASSERTW(unwrapOE.obj_id.objid != NULL_OBJID);

  // Grab some points
  VLunwGet3Points(&unwrapOE,pt2d);

  // Get a matrix
  VLunw2GetMatrix(&unwrapOE,&type,matrix);

  // Apply it
  MAoptsxform(&rc,&three,&type,matrix,pt2d,pt3d);
  
  // Place them
  VDdrawLinear(3,pt2d,NULL,&feetIDs[0]);
  VDdrawLinear(3,pt3d,NULL,&feetIDs[1]);
  *feetCnt = 2;

  // Show the contours as well
  VLunwGetExternalContour(&unwrapOE,&contourOE);
  VDASSERTW(contourOE.obj_id.objid != NULL_OBJID);

  vdgeom$Get2(objOE = &contourOE, crv = &crv);
  VDASSERTW(crv);

  VDdrawCurve(crv,&macOE->mod_env,&crvID);  
  VDASSERTW(crvID.objid != NULL_OBJID);
  feetIDs[2] = crvID;
  *feetCnt = 3;

  VDgeom2MatrixCurve(crv,matrix);

  VDdrawCurve(crv,&macOE->mod_env,&crvID);  
  VDASSERTW(crvID.objid != NULL_OBJID);
  feetIDs[3] = crvID;
  *feetCnt = 4;

  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);
  
  return retFlag;
  
}

#if 0
/* -----------------------------------------------
 * Compute routine for unw_tran
 */
IGRstat VLunwComputeTranOld(TGRobj_env *macOE,
			    IGRint      opFlag,
			    IGRint     *feetCnt,
			    TGRid      *feetIDs)
{
  VDASSERT_FN("VLunwComputeTran");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc rc;
  
  TGRobj_env unwrapOE;
  TGRobj_env plateOE;
  IGRchar pcmk[32];
  
  IGRdouble pt2d[9];
  IGRdouble pt3d[9];
  
  IGRdouble matrix [16];
  IGRdouble matrix2[16];
  IGRshort  type;
  
  TGRobj_env contourOE;
  TGRbsp_curve *crv = NULL;
  TGRid crvID;

  IGRint i,j,k;
  
  IGRshort type;
  
  // Arg check
  VDASSERTW(feetCnt); *feetCnt = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
    
  // Get 1st parent, 
  vdobj$GetTemplate(objOE      = macOE,
                    nth        = 0,
                    templateOE = &unwrapOE);
  VDASSERTW(unwrapOE.obj_id.objid != NULL_OBJID);

  // Grab some points
  VLunwGet3Points(&unwrapOE,pt2d);

  // Get a matrix
  VLunw2GetMatrix(&unwrapOE,&type,matrix);
  
#if 0
  // Transform using mapping process
  VLunwGetPointOnPlate(&unwrapOE,3,pt2d,pt3d);
#endif

  // Place them
  VDdrawLinear(3,pt2d,NULL,&feetIDs[0]);
  VDdrawLinear(3,pt3d,NULL,&feetIDs[1]);
  *feetCnt = 2;

  // Show the contours as well
  VLunwGetExternalContour(&unwrapOE,&contourOE);
  VDASSERTW(contourOE.obj_id.objid != NULL_OBJID);

  vdgeom$Get2(objOE = &contourOE, crv = &crv);
  VDASSERTW(crv);

  VDdrawCurve(crv,&macOE->mod_env,&crvID);  
  VDASSERTW(crvID.objid != NULL_OBJID);
  feetIDs[2] = crvID;
  *feetCnt = 3;
#if 0  
  // Move to 3d space
  VDgeom2GenMatrix(pt2d,pt3d,&type,matrix);

  // New routine
  VLunwGetUnwrapTransMatrix(&unwrapOE,1,NULL,matrix2);
  
  // Compare the two
  for(i = 0; i < 4; i++) {
    for(j = 0; j < 3; j++) {
      k = (i*4) + j;
      if (fabs(matrix[k] - matrix2[k]) > .01) goto different;
    }
    k = (i*4) + j;
    if (fabs(matrix[k] - matrix2[k]) > 2.0) goto different;
  }
  goto finish_it;
  
 different:
  VLunwGetPlateForUnwrap(&unwrapOE,NULL,&plateOE);  
  vdsa$Get(objOE = &plateOE, name = "SA_AST:StagingTree:PM:pcmk",txt = pcmk);
  printf("### Matrix is different for piece %s\n",pcmk);
  for(i = 0; i < 4; i++) {
    printf("Old ");
    for(j = 0; j < 4; j++) {
      printf("%10.2f ",matrix[(i*4)+j]);
    }
    printf("\n");
  }
  for(i = 0; i < 4; i++) {
    printf("New ");
    for(j = 0; j < 4; j++) {
      printf("%10.2f ",matrix2[(i*4)+j]);
    }
    printf("\n");
  }
  
  // Curve it
 finish_it:
#endif

  VDgeom2MatrixCurve(crv,matrix);

  VDdrawCurve(crv,&macOE->mod_env,&crvID);  
  VDASSERTW(crvID.objid != NULL_OBJID);
  feetIDs[3] = crvID;
  *feetCnt = 4;

  // Done
  retFlag = 1;
  
 wrapup:

  _FREE(crv);
  
  return retFlag;
  
}
#endif

end implementation Root;
