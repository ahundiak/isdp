/* $Id: VSbevelVer.I,v 1.1 2001/01/17 00:07:28 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsedge/VSbevelVer.I
 *
 * Description: Verification Routines For Bevels
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevelVer.I,v $
 *      Revision 1.1  2001/01/17 00:07:28  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/10/25  19:22:54  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/17/00  ah      Creation
 * -------------------------------------------------------------------*/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"

#include "VSbevel2.h"

#include "bsmdistptsf.h"
#include "bssfevaln.h"
#include "bsmdstptcv.h"
#include "bsnorvec.h"

#include "EMSssprops.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "dp.h"

VDASSERT_FFN("struct/vsedge/VDbevelVer.I");

/* -------------------------------------------------------------------
 * Helper routine, returns true if the object is a new bevel macro
 */
IGRstat VSbevelIsBevel(TGRobj_env *a_bevelOE, TGRid *a_bevelID) 
{
  IGRchar macName[64];
  TGRid   bevelID;
  
  // get the object
  bevelID.objid = NULL_OBJID;
  if (a_bevelOE) bevelID =  a_bevelOE->obj_id;
  if (a_bevelID) bevelID = *a_bevelID;
  if (bevelID.objid == NULL_OBJID) return 0;
  
  vdobj$Get(objID = &bevelID, macName = macName);
  
  if (!strcmp(macName,"Bevel"))       return 1;
  if (!strcmp(macName,"EJ_Bevel"))    return 1;
  if (!strcmp(macName,"VA_Bevel"))    return 1;
  return 0;
}

/* -----------------------------------------------
 * Validate a bevel and do some various checks
 */
IGRstat VSbevelValidateBevel(TGRobj_env *bevelOE)
{
  VDASSERT_FN("VSbevelValidateBevel");

  IGRstat retFlag = 0;
  IGRstat sts,msg;
  IGRint  gotOne = 0;
  
  // Make sure have a bevel
  VDASSERTW(bevelOE);
  sts = VSbevelIsBevel(bevelOE,NULL);
  if (!(sts & 1)) goto wrapup;
  
  // Say hi
  traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s\n",fn);
    vdobj$Print(objOE = bevelOE);
  }
  gotOne = 1;
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag && gotOne) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  
  return retFlag;
}

end implementation Root;

