/* $Id: VDctyBase.c,v 1.1 2001/01/14 16:00:47 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctyBase.c
 *
 * Description: Base Tree Class
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctyBase.c,v $
 *      Revision 1.1  2001/01/14 16:00:47  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDos.h"
#include "VDctx.h"
#include "VDcty.h"

VDASSERT_FFN("vdcty/base/VDctyBase.c");

/* -----------------------------------------------
 * Set type information
 */
static void getSetTypeInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			    TVDctySetTypeInfo *info)
{
  VDASSERT_FN("getSetTypeInfo");

  info->flag = 0;
  info->nth  = VDCTY_CLASSI_BASE_TREE;
  strcpy(info->type,VDCTY_CLASSN_BASE_TREE);
  strcpy(info->rev, "000");
  strcpy(info->desc,"Abstract Base Tree");
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Returns value for form gadget
 * Every time we get a new parent,
 * this will get called.
 */
static IGRstat getGadgetText(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
  VDASSERT_FN("baseGetGadgetText");

  IGRstat        retFlag = 0;
  TVDctxBaseInfo baseInfo;
  
  // Say Hi
  if (traceFlag) printf(">>> %s\n",fn);
  
 wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Class filter
 */
static void getFilter(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
		      OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("baseGetFilter");
  
  // Doit
  VDomGetClassIdForClassName("VDSroot",&classList->p_classes[0]);
  classList->w_count = 1;
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Link the base methods
 */
IGRstat VDctyInitBaseTP(TVDctyTP *tp)
{
  VDASSERT_FN("VDctyInitBaseTP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(tp);
  memset(tp,0,sizeof(TVDctyTP));
  
  // Xfer functions
  tp->getFilter      = getFilter;
  tp->getGadgetText  = getGadgetText;
  tp->getSetTypeInfo = getSetTypeInfo;
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}




