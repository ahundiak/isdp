/* $Id: VDahLoc.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDahLoc.I
 *
 * Description: Locate toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahLoc.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/11/25  01:16:10  pinnacle
# AssyTree
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      11/25/97  ah      creation
 *
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"

/* --------------------------------------------
 * Helper file for filtering classes
 */
IGRstat VDahLocClaFilter(
  OM_S_SPAMAPENT *map, 
   VDobjid        mapObjID, 
  TVDvlaCLASS    *classVLA
)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CLASSDEF  *def;
  VDclassid       classID;

  // Trys to be fast
  def =  map[mapObjID].p_acld;   
  if (def == NULL) goto wrapup;

  classID = def->w_classid;
  switch(classID) {
    case OM_K_NOTUSING_CLASSID:
    case 0:
      goto wrapup;
  }

  // Check in list
  sts = VDvlaCLASS_IsIn(classVLA,classID);
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ---------------------------------------------
 * Cycles through os looking for objects in
 * class list
 */
IGRstat VDahLocClaForOS(
  TGRmd_env   *osENV, 
  TVDvlaCLASS *classVLA,
  TVDvlaOE    *objVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  IGRuint mapMax;

  OM_S_OSD       *osd;
  OM_S_SPAMAPENT *map;
  VDobjid         mapObjID;

  TGRobj_env objOE;

  /* See if any exist in os */
  if (VDvlaCLASS_GetCnt(classVLA) == 0) goto wrapup;

  // Check osd
  osd = OM_GA_OSDs[osENV->md_id.osnum];
  if (osd == NULL) goto wrapup;
  
  // Cycle Through
  map    = osd->Spacemap;
  mapMax = osd->CurSpaceMapSize;

  // Object enviroment
  objOE.mod_env = *osENV;
  objOE.obj_id.osnum = osENV->md_id.osnum;

  for(mapObjID = 0; mapObjID < mapMax; mapObjID++) {

    sts = VDahLocClaFilter(map,mapObjID,classVLA);
    if (sts & 1) {
      objOE.obj_id.objid = mapObjID;
      VDvlaOE_Append(objVLA,&objOE);
    }
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 *
 * Helper routine to take list of active class id's and
 * translate into os class list
 *
 * Mapping of class names to class id's depend on
 * what products are active at a given time.
 *
 * OM_GA_active_classes is the master array of class def's
 *
 * Spacemap entries for all loaded object spaces point
 * to OM_GA_active_classes so using this pointer will always
 * yield the correct active class number
 *
 * Each os also maintains a translation array between active class
 * id and it's original class id.  
 *
 * It only has entries if OSCO classes exist in that particular OS
 * These could be used to locate classes that don't exist in the active
 * OS? They can also be used to to add classes to active when
 * an os is attached?
 *
 * In any event, because entries only exist for classes actually present
 * in a given os, when can use it to reduce the number of classes to 
 * match when searching an entire os.
 */

IGRstat VDahLocMapClaIds(
   VDosnum     refOSnum, 
  TVDvlaCLASS *classVLA, 
  TVDvlaCLASS *classVLAos 
)
{
  IGRstat   retFlag = 0;
  IGRuint   i;
  OM_S_OSD *osd;

  VDclassid classID;
  VDclassid classIDos;

  VDvlaCLASS_Empty(classVLAos);
  osd = OM_GA_OSDs[refOSnum];
  if (osd == NULL) goto wrapup;

  for(i = 0; VDvlaCLASS_GetAt(classVLA,&classID,i); i++) {

    classIDos = osd->ActToFil[classID];

    if (classIDos) {
      VDvlaCLASS_AppendNoDups(classVLAos,classID);
    }
  }
 
  retFlag = 1;

wrapup:

  return retFlag;
}

/* ----------------------------------------------------------
 * Locates all objects derived from class in all os's 
 */
IGRstat VDahLocClassTest(IGRchar *className)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDosnum refOSnum;
  IGRuint i;

  TVDvlaENV   refVLA;
  TGRmd_env   refEnv;

  TVDvlaCLASS classVLA;
  TVDvlaCLASS classVLAos;

  TVDvlaOE   objVLA;
  TGRobj_env objOE;

  printf("---------------\n");
  printf("Starting Locate\n");

  VDvlaOE_Construct   (&objVLA);
  VDvlaENV_Construct  (&refVLA);
  VDvlaCLASS_Construct(&classVLA);
  VDvlaCLASS_Construct(&classVLAos);

  // Class id's
  sts = VDahClaGetDerClaForClaName(className,&classVLA);
  if (!(sts & 1)) goto wrapup;

  // List of reference files to search
  sts = VDahRefGetRefList(&refVLA);
  if (!(sts & 1)) goto wrapup;

  // For each os
  for(i = 0; VDvlaENV_GetAt(&refVLA,&refEnv,i); i++) {

    refOSnum = refEnv.md_id.osnum;

    printf("%2d %2d %s\n",i,refOSnum,OM_GA_OSDs[refOSnum]->name);

    sts = VDahLocMapClaIds(refOSnum,&classVLA,&classVLAos);
    if (!(sts & 1)) goto wrapup;

    sts = VDahLocClaForOS(&refEnv,&classVLAos,&objVLA);

  }

  // Show results
  for(i = 0; VDvlaOE_GetAt(&objVLA,&objOE,i); i++) {
    VDbroPrintObj(&objOE.obj_id);
  }
  retFlag = 1;

wrapup:

  VDvlaOE_Delete   (&objVLA);
  VDvlaENV_Delete  (&refVLA);
  VDvlaCLASS_Delete(&classVLA);
  VDvlaCLASS_Delete(&classVLAos);

  return retFlag;
}

/* ----------------------------------------------------------
 * Locates all objects derived from class in all os's 
 */
IGRstat VDahLocObjectsByClass(IGRchar *className, TVDvlaOE *objVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDosnum refOSnum;
  IGRuint i;

  TVDvlaENV   refVLA;
  TGRmd_env   refEnv;

  TVDvlaCLASS classVLA;
  TVDvlaCLASS classVLAos;

  VDvlaENV_Construct  (&refVLA);
  VDvlaCLASS_Construct(&classVLA);
  VDvlaCLASS_Construct(&classVLAos);

  // Class id's
  sts = VDahClaGetDerClaForClaName(className,&classVLA);
  if (!(sts & 1)) goto wrapup;

  // List of reference files to search
  sts = VDahRefGetRefList(&refVLA);
  if (!(sts & 1)) goto wrapup;

  // For each os
  for(i = 0; VDvlaENV_GetAt(&refVLA,&refEnv,i); i++) {

    refOSnum = refEnv.md_id.osnum;

//  printf("%2d %2d %s\n",i,refOSnum,OM_GA_OSDs[refOSnum]->name);

    sts = VDahLocMapClaIds(refOSnum,&classVLA,&classVLAos);
    if (!(sts & 1)) goto wrapup;

    sts = VDahLocClaForOS(&refEnv,&classVLAos,objVLA);

  }
  retFlag = 1;

wrapup:

  VDvlaENV_Delete  (&refVLA);
  VDvlaCLASS_Delete(&classVLA);
  VDvlaCLASS_Delete(&classVLAos);

  return retFlag;
}

end implementation Root;
