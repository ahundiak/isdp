/* $Id: VLsmsTest.c,v 1.1 2001/06/14 18:29:20 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlext/VLsmsTest.c
 *
 * Description: Some test routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLsmsTest.c,v $
 * Revision 1.1  2001/06/14 18:29:20  ahundiak
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/12/01  ah      Creation
 ***************************************************************************/
#include "OMminimum.h"
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDobj2.h"
#include "VDos.h"

VDASSERT_FFN("VLsmsTest.c");

/* -----------------------------------------------
 * Test a single matrix
 */
void VLsmsTestMatrixesOne(IGRint pass, TGRid *unwrapID)
{
  TGRobj_env unwrapOE;
  
  IGRdouble range[6];
  
  IGRdouble matrix[16];
  
  IGRint i;
  
  // Init
  unwrapOE.obj_id = *unwrapID;
  VDobjResetOE(&unwrapOE);

  for(i = 0; i < 10; i++) {
    
    // Say hi
    printf("Unwrap Matrix %2d %2d %6d\n",pass,i,unwrapID->objid);
  
    // Get it
    VLunw2GetRange(&unwrapOE,range);
  
    VLunw2GetMatrix(&unwrapOE,NULL,matrix);  
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Cycle through the unwraps
 */
void VLsmsTestMatrixes()
{
  IGRstat sts;
  
  TGRid  unwrapID;
  IGRint pass;
  IGRint max;
  IGRint osnum = 2;
  
  VDclassid unwrapClassId;
  VDclassid classId;
  
  // Init
  unwrapID.osnum = osnum;
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;

  sts = VDomGetClassIdForClassName("VLunwObj",&unwrapClassId);
 
  // Multiple passes
  for(pass = 0; pass < 100; pass++) {
    
    // Cycle through
    for(unwrapID.objid = 0; unwrapID.objid < max; unwrapID.objid++) {

      sts = som_get_classid(unwrapID.osnum,NULL,unwrapID.objid,NULL,&classId);
      if (sts == 1) {
	sts = som_is_ancestry_valid(classId,unwrapClassId,NULL,NULL);
	if (sts == 1) {
	  VLsmsTestMatrixesOne(pass,&unwrapID);
	}
      }
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Main test interface
 */
void VLsmsTest1(TVDtestTestInfo *info)
{
  info->worked = 1;
  VLsmsTestMatrixes();
  
  return;
}
