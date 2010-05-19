/* $Id: VDatTest3.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatTest3.I
 *
 * Description: Check results of
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTest3.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:18  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/02/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatTest3.I");

#if 0
/* -----------------------------------------------
 * Sort two piece mark info items
 * Key on existing pcmk1
 */
IGRint VDatSortPcmkInfoTest2(const void *a_info1, const void *a_info2)
{
  IGRint sts;
  
  TVDatPcmkInfo *info1 = (TVDatPcmkInfo*)a_info1;
  TVDatPcmkInfo *info2 = (TVDatPcmkInfo*)a_info2;

  TVDatPcmkLeafInfo *leaf1 = info1->leaf;
  TVDatPcmkLeafInfo *leaf2 = info2->leaf;
  
  // First by piece mark
  //if (leaf1->pcmk1 < leaf2->pcmk1) return -1;
  //if (leaf1->pcmk1 > leaf2->pcmk1) return  1;
  
  // Then by type
  //if (leaf1->pieceType < leaf2->pieceType) return -1;
  //if (leaf1->pieceType > leaf2->pieceType) return  1;

  // Then by name
  sts = strcmp(leaf1->pieceName,leaf2->pieceName);
  if (sts) return sts;
  
  // The same???
  return 0;
}
#endif

/* -----------------------------------------------
 * See if items meet the intial attribute criteria
 */
IGRstat VDatCheckCriteria(FILE *file,
			  TVDatPcmkInfo *info1,
			  TVDatPcmkInfo *info2)
{
  VDASSERT_FN("VDatCheckCriteria");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDatPcmkAttrInfo *attr1,*attr2;
  TVDatPcmkLeafInfo *leaf1,*leaf2;
  
  IGRint delta;
  
  TVDgeomMat3x3 mat;
  
  IGRdouble bs_tol = 1.0;
  
  // Arg check
  VDASSERTW(info1);
  VDASSERTW(info2);

  // Make things easier
  attr1 = info1->attr;
  attr2 = info2->attr;
  leaf1 = info1->leaf;
  leaf2 = info2->leaf;

  VDASSERTW(attr1);
  VDASSERTW(attr2);
  VDASSERTW(leaf1);
  VDASSERTW(leaf2);
  
  // Skip standard pieces?
  if (leaf1->pcmk1 >= VDAT_PCMK_STD_MIN) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Header
  if (file) {
    fprintf(file,"\n");
    fprintf(file,"%-20s %-20s %-20s\n","PIECE NAME",
	    leaf1->pieceName,
	    leaf2->pieceName);
    fprintf(file,"%-20s %-20d %-20d\n","PIECE MARK",
	    leaf1->pcmk1,
	    leaf2->pcmk1);
    fprintf(file,"%-20s %-20d %-20d\n","PIECE OBJID",
	    leaf1->pieceOE.obj_id.objid,
	    leaf2->pieceOE.obj_id.objid);
    fprintf(file,"%-20s %-20d %-20d\n","PIECE TYPE",
	    leaf1->pieceType,
	    leaf2->pieceType);
    fprintf(file,"%-20s %-20d %-20d\n","CANNOT BE LIKE",
	    leaf1->notLike,
	    leaf2->notLike);

    fprintf(file,"%-20s %-20s %-20s\n","FAMILY",
	    attr1->family,
	    attr2->family);
    fprintf(file,"%-20s %-20s %-20s\n","PART NUM",
	    attr1->part_num,
	    attr2->part_num);
    fprintf(file,"%-20s %-20s %-20s\n","GRADE",
	    attr1->grade,
	    attr2->grade);
  }
  
  // Piece type
  if (leaf1->pieceType != leaf2->pieceType) {
    if (file) fprintf(file,"*** Different types of parts\n");
    goto wrapup;
  }

  // Family
  if (strcmp(attr1->family,attr2->family)) {
    if (file) fprintf(file,"*** Different families\n");
    goto wrapup;
  }
  // Part_num
  if (strcmp(attr1->part_num,attr2->part_num)) {
    if (file) fprintf(file,"*** Different part_nums\n");
    goto wrapup;
  }
  // Grade
  if (strcmp(attr1->grade,attr2->grade)) {
    if (file) fprintf(file,"*** Different grades\n");
    goto wrapup;
  }

  switch(leaf1->pieceType) {

    case VDAT_PCMK_INFO_PIECE_TYPE_PLATE:

      // Grade,thickness,area,planar should match
      if (file) {
	fprintf(file,"%-20s %-20.2f %-20.2f\n","THICKNESS",
		attr1->type.plate.thickness,
		attr2->type.plate.thickness);
	fprintf(file,"%-20s %-20.2f %-20.2f\n","AREA",
		attr1->type.plate.area,
		attr2->type.plate.area);
	fprintf(file,"%-20s %-20d %-20d\n","PLANAR",
		attr1->type.plate.isPlanar,
		attr2->type.plate.isPlanar);
      }

      // Cannot be like
      if ((leaf1->notLike == 1) || (leaf2->notLike == 1)) {
	if (file) fprintf(file,"*** Cannot be like\n");
	goto wrapup;
      }
  
      // Thickness
      sts = VDefpPcmkComparePlateThickness(attr1->type.plate.thickness,
					   attr2->type.plate.thickness);

      if (sts) {
	/* ---------------------------------------
	 * Sometimes the actual plate thickness has been changed
	 * from the default part_num value.  Get something like
	 * 15.62 mm instead of 16.0 mm. 2343501000.m
	 *
         * Need to see if this is a bug in the original code or not
	 * Since this test is for existing assignments, allow a bigger tolerance
	 * for plate thickness
	 */
	sts = VDefpPcmkCompareDouble(.5,
				     attr1->type.plate.thickness,
				     attr2->type.plate.thickness);
      }
      
      if (sts) {
	if (file) printf("*** Thickness is different\n");
	goto wrapup;
      }
      sts = VDefpPcmkComparePlateArea(attr1->type.plate.area,
				      attr2->type.plate.area);
      if (sts) {
	if (file) printf("*** Area is different\n");
	goto wrapup;
      }
      if (!attr1->type.plate.isPlanar) {
	if (file) printf("*** Not Planar\n");
	goto wrapup;
      }
      if (!attr2->type.plate.isPlanar) {
	if (file) printf("*** Not Planar\n");
	goto wrapup;
      }

      /* -----------------------------------------
       * Need transform information
       */
      if (info1->tran == NULL) {
	info1->tran = calloc(1,sizeof(TVDefpTranInfo));
	VDASSERTW(info1->tran);
	VDefpGetTranInfoForPlate(&leaf1->pieceOE,info1->tran);
      }
      if (info2->tran == NULL) {
	info2->tran = calloc(1,sizeof(TVDefpTranInfo));
	VDASSERTW(info2->tran);
	VDefpGetTranInfoForPlate(&leaf2->pieceOE,info2->tran);
      }
      sts = VDefpPcmkComparePlateEdgeLength(info1->tran->edgeLen,info2->tran->edgeLen);
      if (sts) {
	if (file) {
	  printf("*** Edge length different %8.2f %8.2f\n",
		 info1->tran->edgeLen,
		 info2->tran->edgeLen);
	}
	goto wrapup;
      }
      sts = VDefpPcmkCompareDouble(bs_tol,
				   info1->tran->center_minor_distance, 
				   info2->tran->center_minor_distance);
      if (sts) {
	if (file) {
	  printf("*** Center Minor Distance different %8.2f %8.2f\n",
		 info1->tran->center_minor_distance,
		 info2->tran->center_minor_distance);
	}
	goto wrapup;
      }
      
      sts = VDefpComparePlates(bs_tol,info1->tran,info2->tran,mat);
      if (!(sts & 1)) {
	if (file) {
	  printf("VDefpComparePlates failed\n");
	}
      }
      
      break;

    case VDAT_PCMK_INFO_PIECE_TYPE_BEAM:

      // Cannot be like
      if ((leaf1->notLike == 1) || (leaf2->notLike == 1)) {
	if (file) fprintf(file,"*** Cannot be like\n");
	goto wrapup;
      }
      
      break;
      
    default:
      if (file) {
	fprintf(file,"*** Unknown piece type\n");
      }
      goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Got an array of piece marks which were assigned 
 * Verify that the pieces still meet the criteria
 */
IGRstat VDatTestCriteria(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TVDatPcmkInfo *info1,*info2;
  IGRint i,cnt,cntx;
  
  IGRchar buf[128];
  
  // Say Hi
  printf("--------- Verifying existing piece marks -----------\n");
  
  // Arg check
  if (infos == NULL) goto wrapup;
  
  // Sort by piece mark
  qsort(infos->infos,infos->cnt,sizeof(TVDatPcmkInfo),VDatSortPcmkInfo1);

  // Process matching pairs
  cnt = infos->cnt - 1;
  cntx = 0;
  for(i = 0; i < cnt; i++) {

    if (IGEstop()) {
      UI_status("Stopping comparison");
      goto wrapup;
    }
    if ((i % 25) == 0) {
      sprintf(buf,"Checking %d of %d...",i,cnt);
      UI_status(buf);
    }
    
    info1 = &infos->infos[i];
    info2 = &infos->infos[i+1];

    // Check non-zero pieces
    if ((info1->leaf->pcmk1) && 
	(info1->leaf->pcmk1 == info2->leaf->pcmk1)) {

      // See if the criteria still matches
      sts = VDatCheckCriteria(NULL,info1,info2);
      if (!(sts & 1)) {
	cntx++;
	VDatCheckCriteria(stdout,info1,info2);
      }
    }    
  }
  
  // Results
  sprintf(buf,"Pieces Failing Check %d",cntx);
  UI_status(buf);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;





