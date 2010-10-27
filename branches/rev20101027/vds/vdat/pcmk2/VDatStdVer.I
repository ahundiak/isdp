/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatStdVer.I
 *
 * Description: Control which version of std pcmk routines to use
 *
 * Dependencies:
 *
 * Revision History:
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/07/01  ah      Creation
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDdir.h"
#include "VDobj2.h"
#include "VDexp.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk2/VDatStdVer.I");

from expression import NDgive_value;
from GRlinear   import GRgetpolyline;

extern VDclassid OPP_GR3dpoint_class_id;

/* -----------------------------------------------
 * Builds the path to the standard flag object
 *
 * For now, use the current os but later have it search
 * for the production file
 */
static void getOS(VDosnum *osnum)
{
  ex$get_cur_mod(osnum = osnum);
  return;
}

static void getStdPcmkVersionPath(IGRchar *path)
{
  VDosnum osnum;

  *path = 0;

  getOS(&osnum);
  di$give_pathname(osnum = osnum, pathname = path) ;

  strcat(path,":IGENOD:StdPcmkVer");

  return;
}


/* -----------------------------------------------
 * Returns the version of the std pcmks to use
 * Version 1 is the 2.6.2.10 version
 * Version 2 is the database driven version
 */
void VDatGetStdPcmkVersion(IGRint *ver)
{
  VDASSERT_FN("VDatGetStdPcmkVersion");
  
  IGRchar path[128];
  IGRchar buf [128];
  TGRid   verID;
  
  VDosnum osnum;
  
  // Arg check
  VDASSERTW(ver); *ver = 0;
  
  // Need the path
  getStdPcmkVersionPath(path);
  
  // Find the object
  verID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_osnum = &verID.osnum,
	       p_objid = &verID.objid);

  // Pull the value
  if (verID.objid != NULL_OBJID) {
    vdexp$Get(objID = &verID,txt = buf);
    *ver = atoi(buf);
    goto wrapup;
  }
  
  // Need to create
  getOS(&osnum);
  strcpy(buf,"1");
  
  VDexpCreateTextExp(osnum,path,buf,&verID);
  if (verID.objid == NULL_OBJID) {
    goto wrapup;
  }
  *ver = 1;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Sets the version, creating object if necessary
 * Version 1 is the 2.6.2.10 version
 * Version 2 is the database driven version
 */
void VDatSetStdPcmkVersion(IGRint ver)
{
  VDASSERT_FN("VDatSetStdPcmkVersion");
  
  IGRchar path[128];
  IGRchar buf [128];
  TGRid   verID;
  IGRint  verx;
  
  // See if it needs changing
  VDatGetStdPcmkVersion(&verx);
  if (verx == ver) goto wrapup;
  
  // Need the path
  getStdPcmkVersionPath(path);
  
  // Find the object, the Get routine should have created it
  verID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_osnum = &verID.osnum,
	       p_objid = &verID.objid);

  if (verID.objid == NULL_OBJID) goto wrapup;
  
  // Update it
  sprintf(buf,"%d",ver);
  VDexpModifyTextExp(&verID,buf);
    
 wrapup:
  return;
}


/* -----------------------------------------------
 * Returns a 1 if this file is the master standard piece
 * library file, 
 * Sneak it in here since a .I is required
 */
IGRstat VDatIsMasterStdLib()
{
  VDASSERT_FN("VDatGetStdPcmkVersion");

  IGRstat retFlag = 0;
  
  IGRchar path[128];
  IGRchar buf [128];
  TGRid   expID;
  
  VDosnum osnum;
  
  // Need the path
  *path = 0;
  VDosGetCurrentOS(&osnum);
  di$give_pathname(osnum = osnum, pathname = path) ;
  strcat(path,":IGENOD:MasterStdLib");
  
  // Find the object
  expID.objid = NULL_OBJID;
  di$translate(objname =  path,
	       p_osnum = &expID.osnum,
	       p_objid = &expID.objid);

  // Pull the value
  if (expID.objid == NULL_OBJID) goto wrapup;
  vdexp$Get(objID = &expID,txt = buf);
  if (atoi(buf) == 1) retFlag = 1;
  
  
 wrapup:
  return retFlag;
}

/* ----------------------------------------------
 * Given a stock macro, extract the 3D point
 */
IGRint VDefpGetStockPoint(stockID,pt)
TGRid *stockID;
IGRdouble *pt;
{
  IGRint retFlag;
  IGRstat sts,msg;

  TGRobj_env endOE;
  TGRobj_env stockOE;
  TGRobj_env pointOE;

  TGRpolyline polyline;
  IGRint action;

  // Reset
  retFlag = 0;
  pt[0] = pt[1] = pt[2] = 0.0;

  // The foot is really a selector?
  stockOE.obj_id = *stockID;
  VDobjResetOE(&stockOE);
  // vdobj$Print(objOE = &stockOE);

  VDobjGetFoot(&stockOE,NULL,"endpoint",&endOE);
  if (endOE.obj_id.objid == NULL_OBJID) goto wrapup;
  // vdobj$Print(objOE = &endOE);
 
  VDobjGetFoot(&endOE,NULL,"output0",&pointOE);
  if (pointOE.obj_id.objid == NULL_OBJID) goto wrapup;
 
  // vdobj$Print(objOE = &pointOE);

  // Just to be safe
  sts = vdobj$IsAncestryValid(objOE = &pointOE,
                              superClassID = OPP_GR3dpoint_class_id);
  if (!(sts & 1)) goto wrapup;

  // Get it
  polyline.points = pt;
  polyline.num_points = 1;
  action = 1;
  om$send(msg = message GRlinear.
          GRgetpolyline(&msg,
                        &pointOE.mod_env.md_env.matrix_type,
                         pointOE.mod_env.md_env.matrix,
                        &action,
                        &polyline),
          senderid = NULL_OBJID,
          targetid = pointOE.obj_id.objid,
          targetos = pointOE.obj_id.osnum);

  // printf("Point %.2f,%.2f,%.2f\n",pt[0],pt[1],pt[2]);

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}


end implementation Root;
