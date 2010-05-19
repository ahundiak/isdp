/* $Id: VDahClass.I,v 1.3 2001/01/11 16:34:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDahClass.I
 *
 * Description: Class toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahClass.I,v $
 *      Revision 1.3  2001/01/11 16:34:30  art
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

/* ----------------------------------
 * Return Class id
 */
IGRstat VDahClaGetClassId(TGRid *objID, VDclassid *classID)
{
  IGRstat retFlag = 0;

  OM_S_OSD      *osd;
  OM_S_CLASSDEF *def;

  *classID = 0;

  osd = OM_GA_OSDs[objID->osnum];
  if (osd == NULL) goto wrapup;
  
  def = (osd->Spacemap[objID->objid]).p_acld;
  if (def == NULL) goto wrapup;

  *classID = def->w_classid;

  switch(*classID) {
    case OM_K_NOTUSING_CLASSID:
    case 0:
     *classID = 0;
      goto wrapup;
  }

  retFlag  = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------
 * Return Class name
 */
IGRstat VDahClaGetClassName(TGRid *objID, IGRchar *className)
{
  IGRstat retFlag = 0;

  OM_S_OSD      *osd;
  OM_S_CLASSDEF *def;

  *className = 0;

  osd = OM_GA_OSDs[objID->osnum];
  if (osd == NULL) goto wrapup;
  
  def = (osd->Spacemap[objID->objid]).p_acld;
  if (def == NULL) goto wrapup;

  strcpy(className,def->s_name);
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * See if object belongs to given class
 */
IGRstat VDahClaIsInVLA(TGRid *objID, TVDvlaCLASS *classVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDclassid  classID;

  // Grab Class
  sts = VDahClaGetClassId(objID, &classID);
  if (!(sts & 1)) goto wrapup;

  // Match it
  sts = VDvlaCLASS_IsIn(classVLA,classID);
  if (!(sts & 1)) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -------------------------------------------
 * Get worst case number of derived classes
 * Dup derived classes are not tossed
 */
IGRstat VDahClaGetNumDerCla(VDclassid curClassID, IGRint *numClasses)
{
  IGRint retFlag = 0;
  OM_S_CLASSDEF *curClassDef;
  OM_S_ANCESTRY *desClassAnc;
  VDclassid      desClassID;

  curClassDef = OM_GA_active_classes[curClassID];
  if (curClassDef == NULL) goto wrapup;

  for(
    desClassAnc = curClassDef->p_subclass_list;
    desClassAnc;
    desClassAnc = desClassAnc->p_sibling
  ) {

    desClassID  = desClassAnc->p_classdef->w_classid;
    *numClasses = *numClasses + 1;
    VDahClaGetNumDerCla(desClassID,numClasses);

  }
  retFlag = 1;

wrapup:
  return retFlag;
}

// Build list of classes derived from first id
IGRstat VDahClaGetDerCla(VDclassid curClassID, TVDvlaCLASS *classVLA)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  OM_S_CLASSDEF *curClassDef;
  OM_S_ANCESTRY *desClassAnc;

  VDclassid      desClassID;

  curClassDef = OM_GA_active_classes[curClassID];
  if (curClassDef == NULL) goto wrapup;

  for(
    desClassAnc = curClassDef->p_subclass_list;
    desClassAnc;
    desClassAnc = desClassAnc->p_sibling
  ) {

    desClassID = desClassAnc->p_classdef->w_classid;

    sts = VDvlaCLASS_AppendNoDups(classVLA,desClassID);
    if (sts & 1) {
      VDahClaGetDerCla(desClassID,classVLA);
    }
  }
  retFlag = 1;

wrapup:
  return retFlag;
}

IGRstat VDahClaGetDerClaForClaName(IGRchar *className, TVDvlaCLASS *classVLA)
{
  IGRstat   retFlag = 1;
  IGRstat   sts;
  VDclassid classID;

  // Get the classID
  sts = om$get_classid(
    classname =  className,
    p_classid = &classID
  );
  if (!(sts & 1)) goto wrapup;

  VDahClaGetDerCla(classID,classVLA);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * And a test routine
 */
IGRstat VDahClaGetDerClaTest(IGRchar *className)
{
  IGRstat retFlag = 0;
  IGRstat sts;

   VDclassid  classID;
  TVDvlaCLASS classVLA;

  IGRuint i;

  OM_S_CLASSDEF *classDef;

  printf("----------------------------\n");
  printf("Getting Derived Clases For '%s'\n",className);

  VDvlaCLASS_Construct(&classVLA);

  sts = VDahClaGetDerClaForClaName(className,&classVLA);
  if (!(sts & 1)) goto wrapup;

  for(i = 0; VDvlaCLASS_GetAt(&classVLA,&classID,i); i++) {

    classDef = OM_GA_active_classes[classID];
    printf("%4d %s\n",classDef->w_classid,classDef->s_name);

  }

  retFlag = 1;

wrapup:
  VDvlaCLASS_Delete(&classVLA);
  return retFlag;
}

end implementation Root;
