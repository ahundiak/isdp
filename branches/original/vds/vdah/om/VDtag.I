/* $Id: VDtag.I,v 1.3 2001/01/11 16:34:32 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDtag.I
 *
 * Description:	Tag System Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtag.I,v $
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/03/17  17:55:36  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/17/00  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDtag.h"

from GRgraphics import GRgetname;

/* --------------------------------------------------------------------
 * Gets tag information
 */
IGRstat VDtagGetInfo(TGRobj_env *i_objOE, 
		     TGRid      *i_objID,
		     TVDtag     *o_tag,
		     TVDtagInfo *o_info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid   objID;
  TVDtag  tag;
  
  // Arg check
  if (o_tag)  memset(o_tag, 0,sizeof(TVDtag));
  if (o_info) memset(o_info,0,sizeof(TVDtagInfo));
  
  // Get the object in question
  objID.objid = NULL_OBJID;
  if (i_objOE) objID =  i_objOE->obj_id;
  if (i_objID) objID = *i_objID;
  if (objID.objid == NULL_OBJID) goto wrapup;
  
  // Get the tag
  sts = om$objid_to_tag(osnum     = objID.osnum,
			objid     = objID.objid,
			p_tag     = &tag.num,
			p_version = &tag.ver);
  if (!(sts & 1)) goto wrapup;
  
  // Adjust data
  if (o_tag) *o_tag = tag;
  if (o_info) {
    o_info->tag = tag;
    o_info->id  = objID;

    om$send(msg = message GRgraphics.GRgetname(&msg,o_info->path),
	    senderid = NULL_OBJID,
	    targetid = objID.objid,
	    targetos = objID.osnum);
    
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}


end implementation Root;



