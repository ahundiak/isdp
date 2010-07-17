/* ------------------------------------
 * Some plate specific processing
 */
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmac.h"
#include "VDsa.h"

#include "VDmem.h"
#include "VDgeom.h"
#include "VDefp.h"

#include "vs.h"
#include "vsdef.h"
#include "vsplatedef.h"

#include "bssfnormal.h"
#include "bssfevaln.h"
#include "bstrans1.h"
#include "bsinv_mat.h"

extern VDclassid OPP_VSplate_class_id;
extern VDclassid OPP_VSbeam_class_id;

from GRvg import GRdetplane;

#define STD_PCMK_FILE_NAME "StdPcmk.txt"

static int traceFlag;

typedef struct 
{
  TGRobj_env plateOE;
  TGRobj_env neatPlateOE;
  
  IGRmatrix  mat;  // 2d to 3d
  IGRmatrix  inv;  // 3d to 2d

  IGRint     isNotPlanar;
  IGRint     isPlanar;
  
  struct {
    IGRint     isNotPlanar;
    IGRint     isPlanar;
    
    IGRpoint   center;
    IGRvector  normal;
    TGRobj_env oe;
    TGRbsp_surface *bsp;
  } srf;
  
} TVSefpPlateInfo;

/* -----------------------------------------------------------------------
 * Wrapper to translate a 3d model point to a 2d spades extraction point
 * For flat plates, it's a simple transform
 * for curved plates, need to use the unwrap mapping code
 */
IGRstat VSefpTranslatePlate3D2D(TVSefpPlateInfo *plateInfo, IGRpoint pt3D, IGRpoint pt2D)
{
  VSefpMxPt(plateInfo->inv,pt3D,pt2D);
  return 1;
}

/* --------------------------------------------------------
 * Get and process the plate surface
 */
IGRstar VSefpGetPlateSurfaceInfo(TVSefpPlateInfo *plateInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  TGRplane  srfPlane;
  
  IGRpoint  pt,pt1,pt2;
  IGRvector vec;
  IGRvector vecx[3];
  
  IGRint i,j;

  TGRobj_env    *srfOE;
  TGRmdenv_info *mat,mat1,mat2;

  IGRdouble mat3x3[3][3];
  IGRvector transVector;
  IGRdouble scale[3];
 
  // Say hi
  if (traceFlag) printf(">>> VSefpGetPlateSurfaceInfo\n");

  // Get its base surface
  srfOE = &plateInfo->srf.oe;
  vdobj$GetFoot(objOE    = &plateInfo->neatPlateOE, 
		footName =  VS_K_plBotSfPath, 
		footOE   =  srfOE);

  // vdobj$Print(objOE = srfOE);
  if (srfOE->obj_id.objid == NULL_OBJID) goto wrapup;
  
  // For planar plates, get surface normal and point
  srfPlane.point  = plateInfo->srf.center;
  srfPlane.normal = plateInfo->srf.normal;
  
  sts = om$send(msg = message GRvg. 
		GRdetplane(&msg,
			   &srfOE->mod_env.md_env.matrix_type,
			    srfOE->mod_env.md_env.matrix,
			   &srfPlane),
		senderid = NULL_OBJID,
		targetid = srfOE->obj_id.objid,
		targetos = srfOE->obj_id.osnum);

  if (!(sts & msg & 1)) {
    printf("Plate surface is not planar\n");
    goto wrapup;
  }
  plateInfo->srf.isNotPlanar = 0;
  plateInfo->srf.isPlanar    = 1;
  
  if (traceFlag) {
    printf("nrm %8.2f,%8.2f,%8.2f\n",
	   srfPlane.normal[0],
	   srfPlane.normal[1],
	   srfPlane.normal[2]);
  }
  
  // Get the geomotry
  vdgeom$Get(objOE = srfOE, bsp = (IGRchar**)&plateInfo->srf.bsp);
  if (plateInfo->srf.bsp == NULL) {
    printf("Problem getting surface geometry\n");
    goto wrapup;
  }

  /* Want to calculate physical center of surface
   * Some surfaces can have unexpected .5,.5 points */
  BSsfevaln(plateInfo->srf.bsp,0.0,0.0,1,&i,pt1,vecx,&rc);
  BSsfevaln(plateInfo->srf.bsp,1.0,1.0,1,&i,pt2,vecx,&rc);

  for(i = 0; i < 3; i++) {
    plateInfo->srf.center[i] = pt1[i] + ((pt2[i] - pt1[i]) * .5);
  }
  if (traceFlag) {
    
    printf("cen %8.2f,%8.2f,%8.2f\n",
	   plateInfo->srf.center[0],
	   plateInfo->srf.center[1],
	   plateInfo->srf.center[2]);
  }
  
  // Want translation matrix to xy plane
  pt [0] = 0.0; pt [1] = 0.0; pt [2] =  0.0;
  vec[0] = 0.0; vec[1] = 0.0; vec[2] = -1.0; // Material goes into xy plane

  BStrans1(&rc,
	   plateInfo->srf.center,
	   plateInfo->srf.normal,
	   pt, vec,
	   transVector,
	   mat3x3,
	   scale);

  if (rc != BSSUCC) {
    printf("BStrans1 failed\n");
    goto wrapup;
  }

  // Fill out the matrix
  for(i = 0; i < 3; i++) {
    plateInfo->mat[(i*4)+0] = mat3x3[0][i];
    plateInfo->mat[(i*4)+1] = mat3x3[1][i];
    plateInfo->mat[(i*4)+2] = mat3x3[2][i];
    plateInfo->mat[(i*4)+3] = transVector[i];
  }
  plateInfo->mat[(i*4)+3] = 1.0;
  
  // Invert to go from 3d to 2d
  BSinv_mat(4, plateInfo->mat, plateInfo->inv, &rc);

  // Test
  VSefpMxPt(plateInfo->inv,pt1,pt);
  VSefpMxPt(plateInfo->inv,pt2,pt);

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VSefpGetPlateSurfaceInfo\n");
  return retFlag;
}

/* -----------------------------------------
 * Fill in the plate info structure
 */
IGRstat VSefpGetPlateInfo(TGRobj_env *plateOE)
{
  IGRstat retFlag = 0;
  TVSefpPlateInfo  plateInfox;
  TVSefpPlateInfo *plateInfo;
  
  // Init
  plateInfo = &plateInfox;
  if (plateInfo == NULL) goto wrapup;
  memset(plateInfo,0,sizeof(TVSefpPlateInfo));
  plateInfo->plateOE.obj_id.objid = NULL_OBJID;
  
  if ((plateOE == NULL) || (plateOE->obj_id.objid == NULL_OBJID)) goto wrapup;
  
  // Say Hi
  traceFlag = 1;
  if (traceFlag) {
    printf(">>> VSefpGetPlateInfo\n");
    vdobj$Print(objOE = plateOE);
  }
  
  // Xfer plate
  plateInfo->plateOE = *plateOE;
  VSefpGetNeatPlate(&plateInfo->plateOE,
                    &plateInfo->neatPlateOE, 
                    NULL);
  

  // Setup transform stuff
  VSefpGetPlateSurfaceInfo(plateInfo);
  
  // Done
  retFlag = 1;
  
wrapup:

  if (traceFlag) printf("<<< VSefpGetPlateInfo\n");

  return retFlag;
}

/* -----------------------------------------
 * Find the standard piece mark from the key
 */
IGRstat VSefpFindPlateStandardPieceMark(IGRchar *key, IGRchar *pcmk)
{
  IGRstat retFlag = 0;
  FILE   *file;

  IGRchar buf[256];
  IGRchar *p;
  
  IGRchar pcmkx[32];
  IGRint  pcmkn;
  
  // Arg check
  if (pcmk == NULL) goto wrapup;
  strcpy(pcmk,"UNKSTD");
  if (key == NULL) goto wrapup;
  
  // Very first pcmk
  strcpy(pcmkx,"S7999");
  
  // Search the file
  file = fopen(STD_PCMK_FILE_NAME,"rt");
  if (file == NULL) goto addPieceMark;
  
  while(fgets(buf,sizeof(buf),file)) {

    p = strchr(buf,',');
    if (p) {
      *p = NULL; p++;
      *(p + strlen(p) - 1) = NULL;
      if (!strcmp(key,p)) {
	strcpy(pcmk,buf);
	retFlag = 1;
	fclose(file);
	goto wrapup;
      }
      strcpy(pcmkx,buf); // Save last number
    }
  }
  fclose(file);
  
  // Need to add it
addPieceMark:
  file = fopen(STD_PCMK_FILE_NAME,"at");
  if (file == NULL) {
    printf("Problem opening %s for appending\n",STD_PCMK_FILE_NAME);
    goto wrapup;
  }

  pcmkn = atoi(pcmkx+1) + 1;
  sprintf(pcmk,"S%04d",pcmkn);
  fprintf(file,"%s,%s\n",pcmk,key);
  
  fclose(file);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------
 * Determines tha standard piece mark
 */
IGRstat VSefpGetPlateStandardPieceMark(TGRobj_env *plateOE,IGRchar *pcmk)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar className[32];
  
  TGRid macID,pretendID,idID;
 
#if 0
  TGRid     defID;
  IGRdouble int_width;
  IGRdouble int_height;
#endif

  TGRobj_env macOE;
  TGRobj_env surfOE;
  
  struct {
    IGRchar family[32];
    IGRchar part[32];
    IGRchar material[32];
    IGRchar grade[32];
    IGRdouble thickness;
    TGRobj_env objOE;
  } parent1,parent2;

  IGRchar key[256];

  TGRobj_env *footOE;
  IGRint      footCnt;
  
  // Arg check
  if (pcmk == NULL) goto wrapup;
  strcpy(pcmk,"NOTSTD");
  
  // Only define for plates for now
  vdobj$Get(objOE = plateOE, className = className);
  if (strcmp(className,"VSsrcPlate")) {
    goto wrapup;
  }

  // Get the macro it is placed on
  vdobj$GetParent(objOE = plateOE, idx = 0, parentID = &macID, pretendID = &pretendID);
  
  // Make sure connected through pretend
  if (pretendID.objid == NULL_OBJID) goto wrapup;
  
  // Make sure got the parent macro
  if (macID.objid == NULL_OBJID) goto wrapup;

  //vdobj$Print(objID = &macID);
  
  // Get a foot named ID
  vdmac$Get(objID = &macID, footName = "ID", footID = &idID);
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    vdmac$Get(objID = &macID, footName = "id", footID = &idID);

  }
  if (idID.objid == NULL_OBJID) {

    // Consistency is all
    vdmac$Get(objID = &macID, footName = "Id", footID = &idID);

  }
  if (idID.objid == NULL_OBJID) goto wrapup;
  vdobj$Print(objID = &idID); // This tells me the name of the downstream macro

#if 0
  VDpplGetDoubleParent(&idID,1,&int_width);
  VDpplGetDoubleParent(&idID,2,&int_height);
  printf("int_width,height %.2f,%.2f\n",int_width,int_height);

  // Cgeck def
  vdmac$Get(objID = &macID, defID = &defID);
  //vdobj$Print(objID = &defID);
  
  // Intersect height/width
  vdsa$GetStruct(objID = &macID, name = "int_width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "int_height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);

  vdsa$GetStruct(objID = &macID, name = "Int_Width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "Int_Height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);

  vdsa$GetStruct(objID = &macID, name = "Int Width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "Int Height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);
  
  vdsa$GetStruct(objID = &macID, name = "width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);

  vdsa$GetStruct(objID = &macID, name = "x_width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "x_height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);

  vdsa$GetStruct(objID = &macID, name = "Width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "Height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);

  vdsa$GetStruct(objID = &macID, name = "x_Width",  dbl = &int_width);
  vdsa$GetStruct(objID = &macID, name = "x_Height", dbl = &int_height);
  //printf("int_width,height %.2f,%.2f\n",int_width,int_height);
#endif

  // Get the parents, assume macro is in same env as it's foot
  vdobj$GetTemplate(objOE = plateOE, nth = 0, templateOE = &surfOE);
  if (surfOE.obj_id.objid == NULL_OBJID) goto wrapup;
  macOE = surfOE;
  macOE.obj_id = macID;

  footCnt = 0;
  footOE  = NULL;
  sts = VD_findMatchFtNameSlSfInMacro( &msg,
				       &macOE.obj_id, &macOE.mod_env,
				       "*width",
				       1,
				       &footOE,
				       &footCnt);
  if (sts & msg & 1) {
    //printf("Got it %d\n",footCnt);
    //vdobj$Print(objOE = footOE);    
  }
  
  vdobj$GetTemplate(objOE = &macOE, nth = 0, templateOE = &parent1.objOE);
  vdobj$GetTemplate(objOE = &macOE, nth = 1, templateOE = &parent2.objOE);
  
  // Allow first parent to be either plate or beam
  sts = vdobj$IsAncestryValid(objOE = &parent1.objOE,
			      superClassID = OPP_VSplate_class_id);
  if (!(sts & 1)) {
    sts = vdobj$IsAncestryValid(objOE = &parent1.objOE,
				superClassID = OPP_VSbeam_class_id);
  }
  if (!(sts & 1)) goto wrapup;
  
  // Second parent should only be a beam?
  sts = vdobj$IsAncestryValid(objOE = &parent2.objOE,
			      superClassID = OPP_VSbeam_class_id);
  if (!(sts & 1)) goto wrapup;
  
  //vdobj$Print(objOE = &parent1.objOE);
  //vdobj$Print(objOE = &parent2.objOE);
  
  // Extract key fields
  vdsa$GetStruct(objOE = &parent1.objOE, name = "family_name", txt = parent1.family);
  vdsa$GetStruct(objOE = &parent1.objOE, name = "part_num",    txt = parent1.part);
  vdsa$GetStruct(objOE = &parent1.objOE, name = "material",    txt = parent1.material);
  vdsa$GetStruct(objOE = &parent1.objOE, name = "grade",       txt = parent1.grade);

  vdsa$GetStruct(objOE = &parent2.objOE, name = "family_name", txt = parent2.family);
  vdsa$GetStruct(objOE = &parent2.objOE, name = "part_num",    txt = parent2.part);
  vdsa$GetStruct(objOE = &parent2.objOE, name = "material",    txt = parent2.material);
  vdsa$GetStruct(objOE = &parent2.objOE, name = "grade",       txt = parent2.grade);

  // Thickness based on type
  sts = vdobj$IsAncestryValid(objOE = &parent1.objOE,
			      superClassID = OPP_VSplate_class_id);
  if (sts & 1) {
    vdsa$GetStruct(objOE = &parent1.objOE, name = "plate_thk",dbl = &parent1.thickness);
  }
  else {
    vdsa$GetStruct(objOE = &parent1.objOE, name = "x_Web_Thickness",dbl = &parent1.thickness);
  }
  sts = vdobj$IsAncestryValid(objOE = &parent2.objOE,
			      superClassID = OPP_VSplate_class_id);

  // Just in case decide parent 2 can be a plate
  if (sts & 1) {
    vdsa$GetStruct(objOE = &parent2.objOE, name = "plate_thk",dbl = &parent2.thickness);
  }
  else {
    vdsa$GetStruct(objOE = &parent2.objOE, name = "x_Web_Thickness",dbl = &parent2.thickness);
  }

  // The key
  sprintf(key,"%s,%s,%s,%s,%f,%s,%s,%s,%s,%f",
	  parent1.family,parent1.part,parent1.material,parent1.grade,parent1.thickness,
	  parent2.family,parent2.part,parent2.material,parent2.grade,parent2.thickness);
  
  //printf("KEY %s\n",key);

  // Look it up
  VSefpFindPlateStandardPieceMark(key,pcmk);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;





