/* $Id: VDatAttr.I,v 1.2 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/leaf/VDatAttr.I
 *
 * Description: Piece Mark Attribute Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatAttr.I,v $
 *      Revision 1.2  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  19:22:20  pinnacle
# ah
#
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatAttr.I");

/* -----------------------------------------------
 * Fill in plate specific attr information
 */
IGRstat VDatGetPcmkPlateAttrInfo(TVDatPcmkInfo *info)
{
  VDASSERT_FN("VDatGetPcmkPlateAttrInfo");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env  srfOE;
  TGRobj_env *pieceOE;
  
  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;
  
  // Say hi
  traceFlagx = traceFlag;
  // traceFlagx = 1;
  if (traceFlagx) {
    printf(">>> %s\n",fn);
  }
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(info->leaf);
  VDASSERTW(info->attr);

  // Make things easier
  leaf = info->leaf;
  attr = info->attr;
  pieceOE = &leaf->pieceOE;

  // Regular attributes
  vdsa$GetStruct(objOE = pieceOE,
		 name  = "plate_thk",
		 dbl   = &attr->type.plate.thickness);
  
  /* ---------------------------------------------
   * Causes problems
  vdsa$GetStruct(objOE = pieceOE,
		 name  = "surface_area",
		 dbl   = &attr->type.plate.area);
  */

  // Work from base surface
  vdobj$GetFoot(objOE = pieceOE,
		footName = "plate:base",
		footOE = &srfOE);

  if (srfOE.obj_id.objid == NULL_OBJID) {
    printf("*** PCMK Unable to find base surface for\n");
    vdobj$Print(objOE = pieceOE);
    goto wrapup;
  }
  if (traceFlagx) {  
    vdobj$Print(objOE = pieceOE);
    vdobj$Print(objOE = &srfOE);
  }

  // For some testing
  attr->type.plate.isPlanar = 1;
  attr->type.plate.area = 5000.0;

#if 1
  // Get Planar props
  VDgeomGetSurfacePlanarProps(&srfOE,0.0,&attr->type.plate.isPlanar,NULL,NULL);
  
  // Get the area
  VDgeomGetSurfaceAreaProps(&srfOE,&attr->type.plate.area,NULL,NULL);
#endif
  
  if (traceFlagx) {
    printf("Planar %d, Area %.2f\n",
	   attr->type.plate.isPlanar,
	   attr->type.plate.area);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlagx) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Fill in beam specific attr information
 */
IGRstat VDatGetPcmkBeamAttrInfo(TVDatPcmkInfo *info)
{
  VDASSERT_FN("VDatGetPcmkBeamAttrInfo");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRobj_env *pieceOE;
  
  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(info->leaf);
  VDASSERTW(info->attr);
  
  // Easier
  leaf = info->leaf;
  attr = info->attr;
  pieceOE = &leaf->pieceOE;

  // Regular attributes
  vdsa$GetStruct(objOE = pieceOE,
		 name  = "end_treatment0",
		 txt   = attr->type.beam.et0);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "end_treatment1",
		 txt   = attr->type.beam.et1);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "end_treatinfo0",
		 txt   = attr->type.beam.ei0);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "end_treatinfo1",
		 txt   = attr->type.beam.ei1);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "memb_cut_leng",
		 dbl   = &attr->type.beam.length);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "x_Height",
		 dbl   = &attr->type.beam.height);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Fill in attr information
 */
IGRstat VDatGetPcmkAttrInfo(TVDatPcmkInfo *info)
{
  VDASSERT_FN("VDatGetPcmkAttrInfo");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;
  TGRobj_env        *pieceOE;
  
  // Arg check
  VDASSERTW(info);
  VDASSERTW(info->leaf);
  VDASSERTW(info->attr);

  // Easier
  leaf = info->leaf;
  attr = info->attr;
  pieceOE = &leaf->pieceOE;
  
  // Init
  memset(attr,0,sizeof(TVDatPcmkAttrInfo));

  // Regular attributes
  vdsa$GetStruct(objOE = pieceOE,
		 name  = "family_name",
		 txt   = attr->family);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "part_num",
		 txt   = attr->part_num);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "material",
		 txt   = attr->material);

  vdsa$GetStruct(objOE = pieceOE,
		 name  = "grade",
		 txt   = attr->grade);

  // Type specific
  switch(leaf->pieceType) {

    // Plate
    case VDAT_PCMK_INFO_PIECE_TYPE_PLATE:
      VDatGetPcmkPlateAttrInfo(info);
      break;
      
    // Beam
    case VDAT_PCMK_INFO_PIECE_TYPE_BEAM:
      VDatGetPcmkBeamAttrInfo(info);
      break;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Fill in piece mark attribute info
 */
IGRstat VDatGetPcmkAttrInfos(TVDatPcmkInfos *infos)
{
  VDASSERT_FN("VDatGetPcmkAttrInfos");
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRuint i;
  TGRid   childID;
  
  IGRchar buf[64];
  
  // Arg check
  VDASSERTW(infos);

  // See if attributes are allocated
  if (infos->attrs == NULL) {

    // Allocate
    infos->attrs = calloc(infos->max,sizeof(TVDatPcmkAttrInfo));
    VDASSERTW(infos->attrs);
    
    // Adjust pointers
    for(i = 0; i < infos->max; i++) {
      infos->infos[i].attr = &infos->attrs[i];
    }
    
  }
  
  // Fill up each one
  for(i = 0; i < infos->cnt; i++) {

    // Status
    if ((i % 25) == 0) {
      sprintf(buf,"Getting Attribute Info %d of %d...",i,infos->cnt);
      UI_status(buf);
    }

    // User interrupt
    if (IGEstop()) goto wrapup;

    // Do it
    sts = VDatGetPcmkAttrInfo(&infos->infos[i]);

    // Not sure about this
    // if (!(sts & 1)) goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (retFlag & 1) UI_status("Done getting attribute info");
  else             UI_status("Failed getting attribute info");
  
  return retFlag;
}

end implementation Root;





