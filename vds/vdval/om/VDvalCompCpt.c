/***************************************************************************
 * I/VDS
 *
 * File:        vdval/om/VDvalCompCpt.c
 *
 * Description: Connection Point routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalCompCpt.c,v $
 *      Revision 1.3  2001/11/16 15:18:11  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/08/29 17:00:21  louis
 *      ah
 *
 *      Revision 1.1  2001/08/14 19:16:30  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/03/01  ah      Creation
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


VDASSERT_FFN("VDvalCompCpt.c");

/* -----------------------------------------------
 * Compute an xml connection point
 */
IGRstat VDvalComputeXmlCpt(TGRobj_env *macOE,
			   IGRint      opFlag,
			   IGRint     *feetCntx,
			   TGRid      *feetIDs)
{
  VDASSERT_FN("VDvalComputeXmlCpt");
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRmd_env *env;
  IGRint     feetCnt = 0;

  TGRid    cptID;
  TGRid    orgID;
  IGRpoint orgPT;
  
  IGRchar *txt;
  
  // Arg check
  VDASSERTW(feetCntx); *feetCntx = 0;
  VDASSERTW(feetIDs);
  VDASSERTW(macOE);
  
  env = &macOE->mod_env;
  
  // Only support internal buffer
  VDbufGetDomTree(macOE,&cptID);
  VDASSERTW(cptID.objid != NULL_OBJID);

  // Get the origirn
  sts = VDctxGetTxtAtrPtr(&cptID,"origin",&txt);
  VDASSERTW(sts);
  VDvalConvertTextToPoint(txt,orgPT);
  
  VDdrawLinear(1,orgPT,env,&orgID);
  VDASSERTW(orgID.objid != NULL_OBJID);

  feetIDs[feetCnt] = orgID;
  feetCnt++;
  

  // Done
  *feetCntx = feetCnt;
  retFlag = 1;

 wrapup:
  
  VDctxDeleteNode(&cptID);
  
  return retFlag;
}
