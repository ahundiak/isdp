/* ----------------------------------------------------
 * Surface extraction routines
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"

#define vdsDEBUGx 1

#include "vldbgmacros.h"

#include "VPpdf.h"

from GRvg       import GRdetplane;
from GRgraphics import GRgetrang;

#include "bssfnormal.h"
#include "bssfevaln.h"
#include "bstrans1.h"

#if 0
/* -----------------------------------------------------
 * Given a point and a normal, make a translation matrix
 */
IGRstat VPpdfGetTransMatrix(IGRpoint  srfPoint, 
                            IGRvector srfNormal,
                            TGRmdenv_info *srfMat) 
{
  IGRstat retFlag = 0;

  BSrc rc;

  IGRvector xyNormal;
  IGRpoint  xyPoint;
  IGRint    i;

  TGRmdenv_info mat1,mat2;

  IGRdouble mat3x3[3][3];
  IGRvector transVector;
  IGRdouble scale[3];
  
  // Arg check
  SetProc(VPpdfGetTransMatrix); Begin

  if (srfMat == NULL) goto wrapup;

  /* XFrom to xy plane at origin */
  xyPoint [0] = 0.0;
  xyPoint [1] = 0.0;
  xyPoint [2] = 0.0;
  xyNormal[0] = 0.0;
  xyNormal[1] = 0.0;
  xyNormal[2] = 1.0;

  BStrans1(&rc,
     srfPoint,srfNormal,
     xyPoint, xyNormal,
     transVector,
     mat3x3,
     scale
  );
  if (rc != BSSUCC) {
    printf("BStrans1 failed\n");
    goto wrapup;
  }
 
  printf("nrm %8.2f,%8.2f,%8.2f\n",
	 srfNormal[0],srfNormal[1],srfNormal[2]);
  
  /* Rotate it to xy plane */
  VDgeomSetMatToIdentity(&mat2);
  for(i = 0; i < 3; i++) {
    mat2.matrix[(i*4)+0]  =  mat3x3[i][0];
    mat2.matrix[(i*4)+1]  =  mat3x3[i][1];
    mat2.matrix[(i*4)+2]  =  mat3x3[i][2];

    printf("mat %8.2f %8.2f %8.2f\n",
	   mat3x3[i][0],mat3x3[i][1],mat3x3[i][2]);
							  
  }
  MAtypemx(&rc,mat2.matrix,&mat2.matrix_type);

  /* Translate to origin */
  VDgeomSetMatToIdentity(&mat1);
  mat1.matrix[ 3] = -transVector[0];
  mat1.matrix[ 7] = -transVector[1];
  mat1.matrix[11] = -transVector[2];
  MAtypemx(&rc,mat1.matrix,&mat1.matrix_type);

  vdgeom$MultMat(mat1 = &mat2, mat2 = &mat1, mat3 = srfMat);

  // vdgeom$Print(txt = "Surface", mat = srfMat);
  
  retFlag = 1;

wrapup:
  End
  return retFlag;
}

/* ------------------------------------------------
 * Extracts a translation matrix from the surface
 */
IGRstat VPpdfGetSurfaceMatrix(TGRobj_env     *srfOE, 
			      TGRbsp_surface *a_srfBsp,
			      TGRmdenv_info  *srfMat) 
{
  IGRstat retFlag = 0;

  BSrc rc;

  IGRvector srfNormal;
  IGRpoint  srfPoint;
  IGRint    i;

  IGRpoint  pt1,pt2;
  IGRvector ptNormal[3];
  
  TGRbsp_surface *srfBsp = NULL;
 
  SetProc(VPpdfGetSurfaceMatrix); Begin
 
  // Arg check
  if (srfMat == NULL) goto wrapup;

  // Either passed geomotry or we get it
  if (a_srfBsp) srfBsp = a_srfBsp;
  else {
    
    // Get the geomotry
    vdgeom$Get(objOE = srfOE,
	       bsp   = (char **)&srfBsp);
    if (srfBsp == NULL) goto wrapup;
  }

  // Get the normal if planar
  BSsfnormal(srfBsp, srfNormal, &rc);
  if (rc != BSSUCC) {
    printf("Plate surface is not planar!!!\n");
    goto wrapup;
  }
  printf("nrm %8.2f,%8.2f,%8.2f\n",
	 srfNormal[0],srfNormal[1],srfNormal[2]);
#if 0  
  /* Use center of surface for normal */
  BSsfevaln(srfBsp,0.5,0.5,1,&i,srfPoint,srfNormal,&rc);
  if (rc != BSSUCC) goto wrapup;

  printf("nrm %8.2f,%8.2f,%8.2f\n",
	 srfNormal[0],srfNormal[1],srfNormal[2]);
#endif
  /* But want to calculate physical center of surface
   * Because some surfaces can have unexpected .5,.5 points */
  BSsfevaln(srfBsp,0.0,0.0,1,&i,pt1,ptNormal,&rc);
  BSsfevaln(srfBsp,1.0,1.0,1,&i,pt2,ptNormal,&rc);

  for(i = 0; i < 3; i++) {
    srfPoint[i] = pt1[i] + ((pt2[i] - pt1[i]) * .5);
  }
  
  /* And calc it */
  VPpdfGetTransMatrix(srfPoint,srfNormal,srfMat);

#if vdsDEBUG
  printf("Surface Center %12.4f,%12.4f,%12.4f\n",
	 srfPoint[0],
	 srfPoint[1],
	 srfPoint[2]);
  
  vdgeom$Print(txt = "Surface", mat = srfMat);
#endif

  retFlag = 1;

wrapup:

  if (a_srfBsp == NULL) _FREE(srfBsp);

  End
  return retFlag;
}

/* ------------------------------------------------
 * Extracts a translation matrix from a compcurve
 */
IGRstat VPpdfGetCurveMatrix(TGRobj_env *srfOE, TGRmdenv_info *srfMat) 
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  IGRvector srfNormal;
  IGRpoint  srfPoint;

  TGRplane  srfPlane;

  IGRboolean world = TRUE;
  GRrange    srfRange;
 
  SetProc( VPpdfGetCurveMatrix ); Begin
 
  // Arg check
  if (srfOE  == NULL) goto wrapup;
  if (srfMat == NULL) goto wrapup;

  // Get the plane's normal
  srfPlane.point  = srfPoint;
  srfPlane.normal = srfNormal;

  sts = om$send(msg = message GRvg.GRdetplane(
                 &msg,
                   &srfOE->mod_env.md_env.matrix_type,
                    srfOE->mod_env.md_env.matrix,
                   &srfPlane),
                  senderid = NULL_OBJID,
                  targetid = srfOE->obj_id.objid,
                  targetos = srfOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    printf("GRdetplane failed on loop, %s.%d\n",__FILE__,__LINE__);
    goto wrapup;
  }

  // get the range for getting the center
  sts = om$send(msg = message GRgraphics.GRgetrang(
                 &msg,
		 &srfOE->mod_env.md_env.matrix_type,
		  srfOE->mod_env.md_env.matrix,
		 &world,
		  srfRange),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);
  
  if (!(sts & msg & 1)) {
    printf("GRgetrange failed on loop, %s.%d\n",__FILE__,__LINE__);
    goto wrapup;
  }

  srfPoint[0] = (srfRange[0] + srfRange[3]) / 2.0;
  srfPoint[1] = (srfRange[1] + srfRange[4]) / 2.0;
  srfPoint[2] = (srfRange[2] + srfRange[5]) / 2.0;

  /* And calc it */
  VPpdfGetTransMatrix(srfPoint,srfNormal,srfMat);

  // vdgeom$Print(txt = "Surface", mat = srfMat);
  
  retFlag = 1;

wrapup:
  End
  return retFlag;
}

#endif

end implementation Root;

