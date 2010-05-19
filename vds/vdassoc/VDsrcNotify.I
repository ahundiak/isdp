/* $Id: VDsrcNotify.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/VDsrcNotify
 *
 * Description:	Intercepts notification messages and asks the
 *              object if the really want to process them
 *              Useful because the parent-child connection turns
 *              almost listener messages to update
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDsrcNotify.I,v $
 * Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 * Initial import to CVS
 *
# Revision 1.2  1999/04/10  16:49:14  pinnacle
# ah
#
# Revision 1.1  1999/04/10  16:40:44  pinnacle
# Notify Intercept
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/10/99  ah      Creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDppl1.h"

static int traceFlag;

extern VDclassid OPP_nci_macro_class_id;

/* ----------------------------------------------
 * Ask each child if they really want the message
 *
 * Currently a fake, need to replace the vdobj/vdchn functions with
 * lower level routines so it will load when product starts
 * or lese move the real routine higher up some where
 */
#if 0
IGRstat VDsrcNotifylisChild(TGRid *srcID, IGRlong mask, TGRid *childID)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRchar macName[128];

  TGRid  pplID;
  IGRint pplRet;
  
  // Only want nci_macro's for now
  sts = vdobj$IsAncestryValid(objID = childID,
			      superClassID = OPP_nci_macro_class_id);
  if (!(sts & 1)) goto wrapup;
  if (1) goto wrapup;
  
  // Get the macro name
  vdobj$Get(objID = childID, macName = macName);
  if (*macName == 0) goto wrapup;
  
  // Load it
  vdppl$Load(name = macName, pplID = &pplID);
  if (pplID.objid == NULL_OBJID) goto wrapup;
  
  // Verify have entry point
  sts = vdppl$IsEntryDefined(pplID = &pplID, name = "Notifylis");
  if (!(sts & 1)) goto wrapup;

  if (traceFlag) {
    printf("Processing %s\n",macName);
  }
 
  // Set what data we know about
  vdppl$SetData(pplID = &pplID, 
		name  = "SRC_ID", 
		size  = sizeof(TGRid), 
		data  = (IGRchar*)srcID);

  vdppl$SetData(pplID = &pplID, 
		name  = "CHILD_ID", 
		size  = sizeof(TGRid), 
		data  = (IGRchar*)childID);

  vdppl$SetData(pplID = &pplID, 
		name  = "NOTIFY_MASK", 
		size  = sizeof(IGRlong), 
		data  = (IGRchar*)&mask);
  
  // And run it
  vdppl$Run(pplID = &pplID, name = "Notifylis", ret = &pplRet);
  if (pplRet & 1) retFlag = 1;
  
wrapup:
  return retFlag;
}
#endif

/* ------------------------------------------------------
 * Intercept the ASsource.notifylis message
 * Just a stub for now
 */ 
IGRstat VDsrcNotifylis(TGRid *srcID, IGRlong mask)
{
  IGRstat retFlag = 0;

  if (1) goto wrapup;
  
#if 0
  IGRstat sts;

  IGRint i;
  TGRid  childID;

  // Debug trace
  traceFlag = VDdbgGetTraceDev3();
  //traceFlag = 1;
  
  // Filter all but a few types of messages
  switch(mask) {

  case GR_GEOM_XFORMED: 
    break;
    
  default: goto wrapup;
    
  }

  if (traceFlag) {
    printf(">>> VDsrcNotifylis, %d, modified\n",mask);
    vdobj$Print(objID = srcID);
    
  }

  // ask the kids if they really want it
  for(i = 0; 
      vdchn$Get2(objID  = srcID, 
		 chnIDx = VDCHN_IDX_CHILD, 
		 nth    = i, 
		 outID  = &childID); 
      i++) {

    sts = VDsrcNotifylisChild(srcID,mask,&childID);

    // If any kids say to skip, skip all
    if (sts & 1) retFlag = 1;
    
  }         

  if (traceFlag) {
    printf("@@@ VDsrcNotifylis, modified, %d\n",retFlag);
  }
  
#endif

wrapup:
  
  return retFlag;
}

end implementation Root;


