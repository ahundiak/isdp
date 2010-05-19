/* $Id: VDctxCt1i.I,v 1.4 2001/09/18 14:01:28 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxCt1i.I
 *
 * Description: Context Classes OM Implementation
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxCt1i.I,v $
 *      Revision 1.4  2001/09/18 14:01:28  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/13 00:18:32  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/17 14:21:33  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:09:04  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 * 09/18/01  ah      Internal calls not initializing results
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDct1.h"
#include "VDchn.h"

VDASSERT_FFN("vdctx/c/VDctxCt1i.I");

/* ----------------------------------------------------------------------
 * Get the model attached to the node
 */ 
static void getModelObject(TGRid      *nodeID,
			   TGRobj_env *modelOE)
{
  VDASSERT_FN("getModelObject");
  TGRid   modelID;

  // Init
  modelOE->obj_id.objid = NULL_OBJID;
  
  // Say hi
  if (traceFlag) printf(">>> %s %s\n",ffn(),fn);
  
  // do it
  vdchn$Get2(objID   =  nodeID, 
	     chnName = "VDct1Base.to_notify", 
	     nth     = 0,
	     outID   = &modelID);

  if (modelID.objid == NULL_OBJID) goto wrapup;
  modelOE->obj_id = modelID;
  
  // Fake the enviroment for now
  gr$get_module_env(buffer = &modelOE->mod_env);

  modelOE->mod_env.md_id.osnum = modelID.osnum;
  
  ex$get_modid(mod_osnum =  modelOE->mod_env.md_id.osnum,
	       mod_id    = &modelOE->mod_env.md_id.objid);

  // Done
  
wrapup:
  if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
  
  return;
}

/* -----------------------------------------------
 * Initializer
 */
IGRstat VDctxInitCt1CPi(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitCt1CPi");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);

  cp->getModelObject = getModelObject;

#if 0
  cp->get = get;
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;

