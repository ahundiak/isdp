/* $Id: VDatPktLines.I,v 1.1 2001/02/09 23:42:15 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pocket/VDatPktLines.I
 *
 * Description: Gets lines associated with a piece
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPktLines.I,v $
 *      Revision 1.1  2001/02/09 23:42:15  ylong
 *      Renamed
 *
 *      Revision 1.1  2001/01/11 21:01:17  art
 *      sp merge
 *
# Revision 1.2  2000/05/24  15:56:36  pinnacle
# ah
#
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/00  ah      Creation
 * 05/24/00  ah      Send viewOE when getting marking lines
 ***************************************************************************/

class implementation VDatBase;

#include "VDatMaster.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"
#include "VDvla.h"
#include "VDchn.h"

#include "VDppl1.h"

#include "VDatPocket.h"

from GRgrset import GSobject_add;

static int traceFlag;

/* -----------------------------------------------
 * Filters then adds a single marking line
 * This is just semple code, the unwrap has it's
 * own implementation
 */
IGRstat VDatPKTAddMarkingLineToSaveSet(TGRobj_env *viewOE,
				       TGRobj_env *modelOE,  
				       TGRid      *grsetID,
				       TGRid      *lineID)
{
  IGRchar fn[] = "VDatPKTAddMarkingLineToSaveSet";
  
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRid parentID;

  TGRobj_env lineOE;

  IGRint  env_prop = 0;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s\n",fn);
    vdobj$Print(objID = lineID);
  }
  
  // Only want lines that mark the piece 
  vdobj$GetParent(objID = lineID, idx = 2, parentID = &parentID);
  if (parentID.objid == NULL_OBJID)            goto wrapup;
  if (parentID.objid != modelOE->obj_id.objid) goto wrapup;
  if (parentID.osnum != modelOE->obj_id.osnum) goto wrapup;

  // No way of knowing matrix for sure, assume it's the same as the plate
  lineOE.mod_env =  modelOE->mod_env;
  lineOE.obj_id  = *lineID;
  
  lineOE.mod_env.md_id.osnum = lineID->osnum;
  ex$get_modid(mod_osnum =  lineID->osnum, 
	       mod_id    = &lineOE.mod_env.md_id.objid);

  // Copy view matrix if one is passed
  if ((viewOE) && (viewOE->obj_id.objid != NULL_OBJID)) {
    lineOE.mod_env.md_env = viewOE->mod_env.md_env;
  }
  
  // And add it
  sts = om$send(msg = message GRgrset.
		GSobject_add(&msg,
			     &lineOE.obj_id,
			     &lineOE.mod_env,
			     &env_prop,NULL,NULL),
		senderid = NULL_OBJID,
		targetid = grsetID->objid,
		targetos = grsetID->osnum);

  if (!(sts & msg & 1)) {
    printf("*** Problem adding marking line to save set\n");
    vdobj$Print(objOE = modelOE);
    vdobj$Print(objOE = &lineOE);
    goto wrapup;
  }
  
  // Done
  if (traceFlag) printf("Added\n");
  
  retFlag = 1;
  
 wrapup:
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Gets the desired lines for the model object then
 * adds them to the save set
 *
 * This is actually just a sample function, the real 
 * function will probably be in loft
 */
IGRstat VDatPKTAddLinesToSaveSet(TGRobj_env *viewOE,
				 TGRobj_env *modelOE, 
				 IGRint     *pickList, 
				 TGRid      *grsetID)
{
  IGRchar fn[] = "VDatPKTAddLinesToSaveSet";
  
  IGRstat retFlag = 0;

  TVDvlaID lineVLA;
  TGRid    lineID;
  
  IGRint i;

  // Say hi
  //traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s\n",fn);
  }
  
  // Init
  vdvla_id$Construct(vla = &lineVLA);
  
  // Check for marking lines
  if (pickList[UNFOLD_ATT_IDX_MARK]) {

    if (traceFlag) printf("Adding marking lines\n");
    
    // Get list of marking line objects
    vdvla_id$Empty(vla = &lineVLA);

    vdchn$GetChildrenByClass(objOE     =  modelOE,
                             className = "VLmrkLine",
                             vla       = &lineVLA);

    for(i = 0; 
        vdvla_id$GetAt(vla = &lineVLA, nth = i, objID = &lineID); 
        i++) {

      VDatPKTAddMarkingLineToSaveSet(viewOE,modelOE,grsetID,&lineID);
      
    }
    vdvla_id$Empty(vla = &lineVLA);
    
  
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  vdvla_id$Delete(vla = &lineVLA);
  if (traceFlag) {
    printf("<<< %s %d\n",fn,retFlag);
  }
  return retFlag;
}

end implementation VDatBase;



