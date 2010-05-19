/* $Id: VDatGet.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/VDatGet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDatGet.I,v $
 * Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/11/07  14:02:42  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/06/98  ah      creation
 *
 ***************************************************************************/
class implementation VDatBase;

#include "VDobj.h"
#include "VDchn.h"

/* --------------------------------------------------------
 * get either the parent or child object using either
 * an index or a type
 */
IGRstar VDatGetObj(TGRid *i_objID, 
                   IGRint i_ind, 
                   IGRint i_type,
	           TGRid *o_childID,
		   TGRid *o_parentID
                  )
{
  IGRstat retFlag = 0;
  IGRint  chnIDX = VDCHN_IDX_NONE;
  TGRid   itemID;
  IGRint  i;
  IGRint  type;

  // Init
  if (o_childID)  {
    o_childID->objid = NULL_OBJID;
    chnIDX = VDCHN_IDX_PARENT;
  }
  if (o_parentID) {
    o_parentID->objid = NULL_OBJID;
    chnIDX = VDCHN_IDX_CHILD;
  }

  // Arg check
  if ((i_objID == NULL) || (i_objID->objid == NULL_OBJID)) goto wrapup;
  if (chnIDX == VDCHN_IDX_NONE) goto wrapup;

  // Want nth item
  if (i_ind >= 0) {
    vdchn$Get(il_objID  = i_objID,
              ic_IDX    = chnIDX,
              ir_objIDX = i_ind,
              or_objID  = &itemID);

    if (itemID.objid != NULL_OBJID) goto got_it;
    goto wrapup;
  }

  // Scan for type
  if (i_type < 0) {
    goto wrapup;
  }
  for(i = 0;
      vdchn$Get(il_objID  =  i_objID,
                ic_IDX    =  chnIDX,
                ir_objIDX =  i,
                or_objID  = &itemID);
      i++) {

    VDatGetBaseType(&itemID,&type);
    if (type == i_type) goto got_it;
  }
  goto wrapup;

got_it:
  if (o_childID)  *o_childID  = itemID;
  if (o_parentID) *o_parentID = itemID;
  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;

