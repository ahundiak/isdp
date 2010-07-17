/* $Id: VLsmsPlate.I,v 1.7 2001/06/27 15:34:43 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLsmsPlate.I
 *
 * Description: Plate specific functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsPlate.I,v $
 *      Revision 1.7  2001/06/27 15:34:43  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/06/15 13:58:07  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/08 20:50:03  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/07 21:00:37  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/19 14:22:05  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/18 17:55:32  art
 *      ah
 *
# Revision 1.1  2000/04/25  16:31:42  pinnacle
# ah
#
# Revision 1.1  2000/02/25  18:16:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/25/00  ah      Creation
 *
 ***************************************************************************/

class implementation VLunwObj;

/* ------------------------------------------------------
 * Initial shot at extracting data from the unwrap object
 */
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "VDsa.h"

#include "VDxml.h"
#include "VDcvg.h"
#include "VLsms.h"

#include "vddrwattr.h"
#include "vlstructure.h"
#include "vlunwext.h"

#include "VLunwMisc.h"

#include "vs.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsmiscmacros.h"

#include "bssfevaln.h"
#include "bscrossp.h"

static IGRint traceFlag;

/* --------------------------------------------------------
 * Given a vector, return material orientation
 */
IGRstar VLsmsGetPlateMaterialDirection(IGRvector vec, IGRchar *dir)
{
  IGRstat retFlag = 0;
  
  IGRint x,y,z;
  
  // Arg check
  if (dir == NULL) goto wrapup;
  strcpy(dir,"UNK");
  
  // Assume only has major orientations
  x = y = z = 0;
  if (vec[0] >  .9) x =  1;
  if (vec[0] < -.9) x = -1;
  if (vec[1] >  .9) y =  1;
  if (vec[1] < -.9) y = -1;
  if (vec[2] >  .9) z =  1;
  if (vec[2] < -.9) z = -1;
  
  // Up/down
  if ((x == 0) && (y == 0) && (z == 1)) {
    strcpy(dir,"UP");
    return 1;
  }
  if ((x == 0) && (y == 0) && (z == -1)) {
    strcpy(dir,"DOWN");
    return 1;
  }

  // Fwd/aft
  if ((x == 1) && (y == 0) && (z == 0)) {
    strcpy(dir,"FWD");
    return 1;
  }
  if ((x == -1) && (y == 0) && (z == 0)) {
    strcpy(dir,"AFT");
    return 1;
  }

  // Port/stbd
  if ((x == 0) && (y == 1) && (z == 0)) {
    strcpy(dir,"PORT");
    return 1;
  }
  if ((x == 0) && (y == -1) && (z == 0)) {
    strcpy(dir,"STBD");
    return 1;
  }
#if 0
  printf("### Unknown orientation %8.2f,%8.2f,%8.2f %d,%d,%d\n",
	 vec[0],vec[1],vec[2],x,y,z);
#endif
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * Spades wants material direction and reference points
 * Add in an is_planar flag
 */
IGRstat VLsmsWritePlatePdfStuff(TVLsmsFileInfo *info, 
				TGRobj_env     *unwrapOE,
				TGRobj_env     *plateOE)
{
  IGRchar fn[]="VLsmsWritePlatePdfStuff";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;

  TVDxmlFileInfo *xml = NULL;
  TVDcvgFileInfo *cvg = NULL;
    
  IGRint  i;
  IGRchar buf[128];
  
  IGRdouble pt2d[9],pt3d[9];
  GRrange   range;
  
  IGRvector vec,vec1,vec2;
  
  IGRdouble expand;
  
  TGRobj_env srfOE;
  IGRint isPlanar;
  
  IGRshort  trfType;
  IGRdouble trfMat[16];
  IGRlong   three = 3;
  
  // Say hi
  //if (traceFlag | 1) printf(">>> %s\n",fn);
  
  // Arg Check
  if (unwrapOE == NULL) goto wrapup;
  if (info     == NULL) goto wrapup;
  xml = &info->cvg.xml;
  cvg = &info->cvg;

  // Get its base surface
  vdobj$GetFoot(objOE    = plateOE, 
		footName = VS_K_plBotSfPath, 
		footOE   = &srfOE);

  // vdobj$Print(objOE = srfOE);
  if (srfOE.obj_id.objid == NULL_OBJID) {
    printf("*** Unable to get base surface for\n");
    vdobj$Print(objOE = plateOE);
    goto wrapup;
  }

  /* ---------------------------------------------
   * Spades assumes that everyhing is in the z=0 plane
   * But in fact the unwraps are generated with different z depths
   * So the trick if use a 2d ref point at z = 0
   * To generate the 3d points
   * That way, the spades generated matrix should be correct???
   *
   * The actual range and matrix are stored in a different spot
   * to allow reconstructing the unwrap file directly
   *
   * Use the transformation matrix here just in case the
   * GetPlatePoint routine does not like the z axis changing
   */

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

  // Z should always be zero
  //pt2d[2] = pt2d[5] = pt2d[8] = 0.0;

  // Translate them up
  VLunw2GetMatrix(unwrapOE,&trfType,trfMat);
  MAoptsxform(&rc,&three,&trfType,trfMat,pt2d,pt3d);

  // Get normal for material direction
  for(i = 0; i < 3; i++) {
    vec1[i] = pt3d[i+3] - pt3d[i];
    vec2[i] = pt3d[i+6] - pt3d[i];
  }
  // Bit of majic to get material direction right
  BScrossp(&rc,vec2,vec1,vec);
  
  // Match the normal to material direction
  VLsmsGetPlateMaterialDirection(vec,buf);
  // printf("Material Direction %s\n",buf);
  
  // Output the junk
  VDxmlWriteObjBeg(xml,XML_PDF_PLATE_3D,1,0);
  VDxmlWriteAtrTxt(xml,XML_PDF_PLATE_3D_MATERIAL_DIRECTION,buf,0,0);

  // See if the unwrap has expansion applied

  /* 13 Feb 2001, use to take expansion from the fab data set
   * Now take it directly from the unwrap
   */
  // Major Expansion
  // vdsa$GetStruct(objOE = plateOE, name = "SA_AST:FabData:0:exp_major", dbl = &expand);
  expand = 0.0;
  vdsa$GetStruct(objOE = unwrapOE, name = "ScaleFactorInX", dbl = &expand);
  expand += 1.0;  
  if ((expand < 1.0) || (expand > 1.1)) {
    printf("*** Major Expansion Factor is Invalid %.4f\n",expand);
    expand = 1.0;
  }
  VDxmlWriteAtrDbl(xml,XML_PDF_PLATE_3D_EXPAND_MAJOR,expand,0,0);

  // Minor Expansion
  expand = 0.0;
  vdsa$GetStruct(objOE = unwrapOE, name = "ScaleFactorInY", dbl = &expand);
  expand += 1.0;  
  if ((expand < 1.0) || (expand > 1.1)) {
    printf("*** Minor Expansion Factor is Invalid %.4f\n",expand);
    expand = 1.0;
  }
  VDxmlWriteAtrDbl(xml,XML_PDF_PLATE_3D_EXPAND_MINOR,expand,0,0);

  // Want a planar flag
  VDgeomGetSurfacePlanarProps(&srfOE,0.0,&isPlanar,NULL,NULL);
  VDxmlWriteAtrInt(xml,XML_PDF_PLATE_3D_IS_PLANAR,isPlanar,0,0);

  // Done pdf 3d info
  VDxmlWriteAtrEnd(xml,0,1);
  
  VDcvgWritePoint3D(cvg,&pt3d[0]);
  VDcvgWritePoint3D(cvg,&pt3d[3]);
  VDcvgWritePoint3D(cvg,&pt3d[6]);
  
  VDxmlWriteObjEnd(xml,XML_PDF_PLATE_3D,1);

  // Done
  retFlag = 1;
  
wrapup:
  //if (traceFlag | 1) printf("<<< %s\n",fn);
  
  return retFlag;
}

end implementation VLunwObj;



