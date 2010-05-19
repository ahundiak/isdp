/* $Id: VDobj3.I,v 1.8 2002/06/07 15:55:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/om/VDobj3.I
 *
 * Description:	Object Filtering
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDobj3.I,v $
 * Revision 1.8  2002/06/07 15:55:13  ahundiak
 * ah
 *
 * Revision 1.7  2002/03/04 20:57:17  ylong
 * CR5068 and CR5286
 *
 * Revision 1.6  2002/01/03 14:44:41  ahundiak
 * ah
 *
 * Revision 1.5  2001/08/24 19:59:06  ahundiak
 * ah
 *
 * Revision 1.4  2001/08/02 15:31:14  ahundiak
 * ah
 *
 * Revision 1.3  2001/07/29 16:59:27  ahundiak
 * ah
 *
 * Revision 1.2  2001/07/28 17:30:58  ahundiak
 * ah
 *
 * Revision 1.1  2001/06/03 14:41:33  ahundiak
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/01/01  ah      Creation
 * 07/28/01  ah      Reject frozen pieces
 * 08/02/01  ah      Add Equipment Scan
 ***************************************************************************/
class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDobj2.h"
#include "VDos.h"

VDASSERT_FFN("vdah/om/VDobj3.I");

/* -----------------------------------------------
 * For speed and portability, fill these in here
 */
static VDclassid srcPlateClassId;
static VDclassid booPlateClassId;
static VDclassid holPlateClassId;
static VDclassid subPlateClassId;
static VDclassid splPlateClassId;
static VDclassid frzPlateClassId;
static VDclassid thePlateClassId;

static VDclassid theBeamClassId;
static VDclassid booBeamClassId;
static VDclassid srcBeamClassId;
static VDclassid stfBeamClassId;
static VDclassid ornBeamClassId;
static VDclassid subBeamClassId;
static VDclassid frzBeamClassId;
static VDclassid splBeamClassId;

static VDclassid vdEqpClassId;

static VDclassid vrxCompClassId;
static VDclassid vrpCompClassId;
static VDclassid vrhCompClassId;
static VDclassid vrrCompClassId;
static VDclassid vrxConcCompClassId;

static VDclassid nci_macroClassId;

static IGRint initialized;

/* -----------------------------------------------
 * Initialize the scanner
 */
static void initClasses()
{
  VDASSERT_FN("initClasses");
  
  IGRstat sts;

  // See if already done
  if (initialized) goto wrapup;
  initialized = 1;

  // VDS first
  sts = VDomGetClassIdForClassName("VDequipment", &vdEqpClassId);
  if (sts != 1) goto wrapup;
  
  // Setup class id's (verify struct is loaded)
  sts = VDomGetClassIdForClassName("VSplate",&thePlateClassId);
  if (sts) {

    VDomGetClassIdForClassName("VSsrcPlate",&srcPlateClassId);
    VDomGetClassIdForClassName("VSsubPlate",&subPlateClassId);
    VDomGetClassIdForClassName("VSbooPlate",&booPlateClassId);
    VDomGetClassIdForClassName("VSholPlate",&holPlateClassId);
    VDomGetClassIdForClassName("VSsplPlate",&splPlateClassId);
    VDomGetClassIdForClassName("VSfrzPlate",&frzPlateClassId);
 
    VDomGetClassIdForClassName("VSbeam",    &theBeamClassId);
    VDomGetClassIdForClassName("VSsrcBeam", &srcBeamClassId);
    VDomGetClassIdForClassName("VSstfBeam", &stfBeamClassId);
    VDomGetClassIdForClassName("VSbooBeam", &booBeamClassId);
    VDomGetClassIdForClassName("VSornBeam", &ornBeamClassId);
    VDomGetClassIdForClassName("VSsubBeam", &subBeamClassId);
    VDomGetClassIdForClassName("VSsplBeam", &splBeamClassId);
    VDomGetClassIdForClassName("VSfrzBeam", &frzBeamClassId);
  }
 
  // Route
  sts = VDomGetClassIdForClassName("VRComponent", &vrxCompClassId);
  if (sts) {
    VDomGetClassIdForClassName("VRPComp", &vrpCompClassId);
    VDomGetClassIdForClassName("VRHComp", &vrhCompClassId);
    VDomGetClassIdForClassName("VRRComp", &vrhCompClassId);

    VDomGetClassIdForClassName("VRConcComp", &vrxConcCompClassId);
   }
  
  // nci_macro for bevels, pens and pcgs
  sts = VDomGetClassIdForClassName("nci_macro", &nci_macroClassId);

 wrapup:  
  return;
}

/* -----------------------------------------------
 * Returns true if object is a valid final object
 * Meeting certain requirements for layers and rep
 */
IGRstat VDobjIsFinal(TGRobj_env *a_objOE, TGRid *a_objID, IGRint verbose)
{
  IGRstat      retFlag = 0;
  IGRstat      sts;
  IGRuchar     rep;
  TGRsymbology symb;

  VDclassid classId;
  TGRid     theID;
  
  // Get the object
  VDobjGetID(a_objOE,a_objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  sts = som_get_classid(theID.osnum,NULL,theID.objid,NULL,&classId);
  if (sts != 1) goto wrapup;
  
  // Ignore if consumed
  sts = VDobjIsConsumed(NULL,&theID);
  if (sts & 1) goto wrapup;
  
  // Cannot be phantom on layer 0
  VDobjGetSymbology(NULL,&theID,&symb);
  if (symb.level == 0) {
    if (verbose) {  
      VDlogPrintObject(VDLOG_ERROR,1,"*** Problem with ",NULL,&theID);
      VDlogPrintFmt   (VDLOG_ERROR,1,"    Phantom Piece on layer 0, should be deleted");
    }
    goto wrapup;
  }
  // Only 3d reps should be here
  VDobjGetRep(NULL,&theID,&rep);
  if (rep != 4) {
    if (verbose) {  
      VDlogPrintObject(VDLOG_ERROR,1,"*** Problem with ",NULL,&theID);
      VDlogPrintFmt   (VDLOG_ERROR,1,"    Piece does not have 3d rep, should be looked at");
    }
    goto wrapup;
  }
    
  // Accept it
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Returns true if object is a valid final plate
 */
IGRstat VDobjIsFinalPlate(TGRobj_env *a_objOE, TGRid *a_objID, IGRint verbose)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  VDclassid classId;
  TGRid     theID;
  
  // Init
  initClasses();
  
  // Get the object
  VDobjGetID(a_objOE,a_objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  sts = som_get_classid(theID.osnum,NULL,theID.objid,NULL,&classId);
  if (sts != 1) goto wrapup;
  
  // Must be derived from plate
  sts = som_is_ancestry_valid(classId,thePlateClassId,NULL,NULL);
  if (sts != 1) goto wrapup;

  // Ignore if consumed
  sts = VDobjIsConsumed(NULL,&theID);
  if (sts & 1) goto wrapup;
  
  // Accept specific types
  if ((classId == srcPlateClassId) ||
      (classId == booPlateClassId) ||
      (classId == holPlateClassId) ||
      (classId == subPlateClassId)) {
    
    // One more check
    sts = VDobjIsFinal(NULL,&theID,verbose);
    if (sts != 1) goto wrapup;

    // Accept it
    retFlag = 1;
    goto wrapup;
  }

  // Reject specific types
  if ((classId == splPlateClassId) ||
      (classId == frzPlateClassId)) {
    goto wrapup;
  }
  
  // For debugging, warn about anything else found
  if (verbose) {  
    VDlogPrintObject(VDLOG_ERROR,1,"*** Problem with ",NULL,&theID);
    VDlogPrintFmt   (VDLOG_ERROR,1,"    Should not be using plates of this type");
  }
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Count the number of beams in the space
 */
IGRstat VDobjIsFinalBeam(TGRobj_env *a_objOE, TGRid *a_objID, IGRint verbose)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid     theID;
  VDclassid classId;
  
  // Init
  initClasses();
  
  // Get the object
  VDobjGetID(a_objOE,a_objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  sts = som_get_classid(theID.osnum,NULL,theID.objid,NULL,&classId);
  if (sts != 1) goto wrapup;

  // Must be derived from beam
  sts = som_is_ancestry_valid(classId,theBeamClassId,NULL,NULL);
  if (sts != 1) goto wrapup;

  // Ignore if consumed
  sts = VDobjIsConsumed(NULL,&theID);
  if (sts & 1) goto wrapup;

  // Accept specific types
  if ((classId == srcBeamClassId) ||
      (classId == booBeamClassId) ||
      (classId == stfBeamClassId) ||
      (classId == ornBeamClassId) ||
      (classId == subBeamClassId)) {
    
    // One more check
    sts = VDobjIsFinal(NULL,&theID,verbose);
    if (sts != 1) goto wrapup;

    // Accept it
    retFlag = 1;
    goto wrapup;
  }
  
  // Reject specific types
  if ((classId == splBeamClassId) ||
      (classId == frzBeamClassId)) {
    goto wrapup;
  }

  // Whats left?
  if (verbose) {  
    VDlogPrintObject(VDLOG_ERROR,1,"*** Problem with ",NULL,&theID);
    VDlogPrintFmt   (VDLOG_ERROR,1,"    Should not be using beams of this type");
  }
  goto wrapup;
  
 wrapup:
  return retFlag;
}

#define DO_BEAMS  1
#define DO_PLATES 1

/* ------------------------------------------------------
 * Generate a list of plates and beams in an object space
 * The scanning is quick so two passes are made
 * All the arguments are optional if you just want a count
 */
IGRstat VDobjGetPieces(VDosnum osnum, IGRint *a_plateCnt, IGRint *a_beamCnt, TGRid **a_listIDs)
{
  VDASSERT_FN("VDobjGetPieces");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint max;
  
  TGRid objID;

  IGRint cnt;
  IGRint plateCnt = 0;
  IGRint beamCnt  = 0;
  
  TGRid *listIDs = NULL;
  
  // Arg check
  if (a_listIDs)  *a_listIDs  = NULL;
  if (a_plateCnt) *a_plateCnt = 0;
  if (a_beamCnt)  *a_beamCnt  = 0;

  // Cycle through
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
  objID.osnum = osnum;

  // One pass for the count
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

#if DO_PLATES
    sts = VDobjIsFinalPlate(NULL,&objID,1);
    if (sts == 1) plateCnt++;
#endif

#if DO_BEAMS
    sts = VDobjIsFinalBeam(NULL,&objID,1);
    if (sts == 1) beamCnt++;
#endif

  }
  
  // Save results
  if (a_plateCnt) *a_plateCnt = plateCnt;
  if (a_beamCnt)  *a_beamCnt  = beamCnt;
  
  // Alloc room
  if (a_listIDs == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  cnt = plateCnt + beamCnt;
  if (cnt == 0) goto wrapup;
  
  listIDs = calloc(cnt,sizeof(TGRid));
  VDASSERTW(listIDs);
  
  // Cycle again
  cnt = 0;
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

#if DO_PLATES
    sts = VDobjIsFinalPlate(NULL,&objID,0);
    if (sts == 1) listIDs[cnt++] = objID;
#endif

#if DO_BEAMS
    sts = VDobjIsFinalBeam(NULL,&objID,0);
    if (sts == 1) listIDs[cnt++] = objID;
#endif

  }
  if (a_listIDs) *a_listIDs = listIDs;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Is object a VDequipment
 */
IGRstat VDobjIsFinalEqp(TGRobj_env *a_objOE, TGRid *a_objID, IGRint verbose)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid     theID;
  VDclassid classId;
  
  // Init
  initClasses();
  
  // Get the object
  VDobjGetID(a_objOE,a_objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  sts = som_get_classid(theID.osnum,NULL,theID.objid,NULL,&classId);
  if (sts != 1) goto wrapup;

  // Must be derived from VDequipment
  sts = som_is_ancestry_valid(classId,vdEqpClassId,NULL,NULL);
  if (sts != 1) goto wrapup;

  // Ignore if consumed
  sts = VDobjIsConsumed(NULL,&theID);
  if (sts & 1) goto wrapup;

  // Accept specific types
  if (classId == vdEqpClassId) {

    /* -------------------------------------------
     * Not going to do this check yet
     * Do need a check against copied equipment
     * Unless those are valid?
     * Is there a moved to root function?
     */
#if 0
    // One more check
    sts = VDobjIsFinal(NULL,&theID,verbose);
    if (sts != 1) goto wrapup;
#endif
    // Accept it
    retFlag = 1;
    goto wrapup;
  }
  
  // Reject specific types

  // Whats left?
  if (verbose) {  
    VDlogPrintObject(VDLOG_ERROR,1,"*** Problem with ",NULL,&theID);
    VDlogPrintFmt   (VDLOG_ERROR,1,"    Should not be using equipment of this type");
  }
  goto wrapup;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Generate a list of equipment in an object space
 * The scanning is quick so two passes are made
 * All the arguments are optional if you just want a count
 */
IGRstat VDobjGetEqps(VDosnum osnum, IGRint *a_eqpCnt, TGRid **a_listIDs)
{
  VDASSERT_FN("VDobjGetEqps");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint max;
  
  TGRid objID;

  IGRint cnt = 0;
  
  TGRid *listIDs = NULL;
  
  // Arg check
  if (a_listIDs)  *a_listIDs  = NULL;
  if (a_eqpCnt)   *a_eqpCnt = 0;

  // Cycle through
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
  objID.osnum = osnum;

  // One pass for the count
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalEqp(NULL,&objID,1);
    if (sts == 1) cnt++;

  }
  
  // Save results
  if (a_eqpCnt) *a_eqpCnt = cnt;
  
  // Alloc room
  if (a_listIDs == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  if (cnt == 0) goto wrapup;
  
  listIDs = calloc(cnt,sizeof(TGRid));
  VDASSERTW(listIDs);
  
  // Cycle again
  cnt = 0;
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalEqp(NULL,&objID,0);
    if (sts == 1) listIDs[cnt++] = objID;

  }
  if (a_listIDs) *a_listIDs = listIDs;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Is object a VRComponent
 */
IGRstat VDobjIsFinalRouteComponent(TGRobj_env *a_objOE, TGRid *a_objID, IGRint verbose)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid     theID;
  VDclassid classId;
  
  // Init
  initClasses();
  
  // Get the object
  VDobjGetID(a_objOE,a_objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  sts = som_get_classid(theID.osnum,NULL,theID.objid,NULL,&classId);
  if (sts != 1) goto wrapup;

  // Must be derived from VRComponent or VRConcComp
  sts = som_is_ancestry_valid(classId,vrxCompClassId,NULL,NULL);
  if (sts != 1) {
    sts = som_is_ancestry_valid(classId,vrxConcCompClassId,NULL,NULL);
  }
  if (sts != 1) goto wrapup;

  // Accept it
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Generate a list of equipment in an object space
 * The scanning is quick so two passes are made
 * All the arguments are optional if you just want a count
 */
IGRstat VDobjGetRouteComponents(VDosnum osnum, IGRint *a_objCnt, TGRid **a_listIDs)
{
  VDASSERT_FN("VDobjGetRouteComponents");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint max;
  
  TGRid objID;

  IGRint cnt = 0;
  
  TGRid *listIDs = NULL;
  
  // Arg check
  if (a_listIDs)  *a_listIDs  = NULL;
  if (a_objCnt)   *a_objCnt = 0;

  // Cycle through
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
  objID.osnum = osnum;

  // One pass for the count
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalRouteComponent(NULL,&objID,1);
    if (sts == 1) cnt++;

  }
  
  // Save results
  if (a_objCnt) *a_objCnt = cnt;
  
  // Alloc room
  if (a_listIDs == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  if (cnt == 0) goto wrapup;
  
  listIDs = calloc(cnt,sizeof(TGRid));
  VDASSERTW(listIDs);
  
  // Cycle again
  cnt = 0;
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalRouteComponent(NULL,&objID,0);
    if (sts == 1) listIDs[cnt++] = objID;

  }
  if (a_listIDs) *a_listIDs = listIDs;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Generate a list of equipment or route components in an object space
 * The scanning is quick so two passes are made
 * All the arguments are optional if you just want a count
 */
IGRstat VDobjGetEqpRouteComponents(VDosnum osnum, IGRint *a_objCnt, TGRid **a_listIDs)
{
  VDASSERT_FN("VDobjGetEqpRouteComponents");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint max;
  
  TGRid objID;

  IGRint cnt = 0;
  
  TGRid *listIDs = NULL;
  
  // Arg check
  if (a_listIDs)  *a_listIDs  = NULL;
  if (a_objCnt)   *a_objCnt = 0;

  // Cycle through
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
  objID.osnum = osnum;

  // One pass for the count
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalEqp(NULL,&objID,1);
    if (sts == 1) cnt++;
    else {  
      sts = VDobjIsFinalRouteComponent(NULL,&objID,1);
      if (sts == 1) cnt++;
    }
    
  }
  
  // Save results
  if (a_objCnt) *a_objCnt = cnt;
  
  // Alloc room
  if (a_listIDs == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  if (cnt == 0) goto wrapup;
  
  listIDs = calloc(cnt,sizeof(TGRid));
  VDASSERTW(listIDs);
  
  // Cycle again
  cnt = 0;
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalEqp(NULL,&objID,1);
    if (sts == 1) listIDs[cnt++] = objID;
    else {  
      sts = VDobjIsFinalRouteComponent(NULL,&objID,0);
      if (sts == 1) listIDs[cnt++] = objID;
    }
  }
  if (a_listIDs) *a_listIDs = listIDs;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Count the number of nci_macros in the space
 */
IGRstat VDobjIsFinalMacro(	IGRchar		*a_macName,
				TGRobj_env	*a_objOE, 
				TGRid		*a_objID, 
				IGRint		verbose)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar macName[40];

  TGRid     theID;
  VDclassid classId;
  
  // Init
  initClasses();
  
  // Get the object
  VDobjGetID(a_objOE,a_objID,&theID);
  if (theID.objid == NULL_OBJID) goto wrapup;
  sts = som_get_classid(theID.osnum,NULL,theID.objid,NULL,&classId);
  if (sts != 1) goto wrapup;

  // Must be nci_macro
  sts = som_is_ancestry_valid(classId,nci_macroClassId,NULL,NULL);
  if (sts != 1) goto wrapup;

  // Accept specific named nci_macro
  VDobjGetMacroName(NULL, &theID, macName);
  retFlag = !strcmp( macName, a_macName );
    
 wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Generate a list of named nci_macro objects in an object space
 * The scanning is quick so two passes are made
 * All the arguments are optional if you just want a count
 */
IGRstat VDobjGetNamedMacros(VDosnum osnum, IGRchar *macName, IGRint *a_macCnt, TGRid **a_listIDs)
{
  VDASSERT_FN("VDobjNamedMacros");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint max;
  
  TGRid objID;

  IGRint cnt = 0;
  
  TGRid *listIDs = NULL;
  
  // Arg check
  if (a_listIDs)  *a_listIDs  = NULL;
  if (a_macCnt)   *a_macCnt = 0;

  // Cycle through
  max = OM_GA_OSDs[osnum]->CurSpaceMapSize;
  objID.osnum = osnum;

  // One pass for the count
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalMacro(macName,NULL,&objID,1);
    if (sts == 1) cnt++;
  }
  
  // Save results
  if (a_macCnt) *a_macCnt = cnt;
  
  // Alloc room
  if (a_listIDs == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  if (cnt == 0) goto wrapup;
  
  listIDs = calloc(cnt,sizeof(TGRid));
  VDASSERTW(listIDs);
  
  // Cycle again
  cnt = 0;
  for(objID.objid = 0; objID.objid < max; objID.objid++) {

    sts = VDobjIsFinalMacro(macName,NULL,&objID,0);
    if (sts == 1) listIDs[cnt++] = objID;
  }
  if (a_listIDs) *a_listIDs = listIDs;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/*--------------------------------------------------------
 * Get bevels
 */
IGRstat VDobjGetBevels(	VDosnum	osnum, 
			IGRint	*bevelCnt, 
			IGRint	*ej_bevelCnt,
			IGRint	*fab_stockCnt,
			IGRint	*va_bevelCnt,
			TGRid	**a_listIDs)
{
  IGRstat	retFlag = 0;
  IGRstat	sts;
  TGRid		*listIDs = NULL;
  IGRint	cnt = 0, bvlCnt = 0, i, j;
  IGRchar	*macNames[] = {"Bevel", "EJ_Bevel", "Fab_Stock", "VA_Bevel"};

  // Arg check
  if (a_listIDs)	*a_listIDs  = NULL;
  if (bevelCnt)		*bevelCnt = 0;
  if (ej_bevelCnt)	*ej_bevelCnt = 0;
  if (fab_stockCnt)	*fab_stockCnt = 0;
  if (va_bevelCnt)	*va_bevelCnt = 0;

   
  for( i = 0; i < 4; i++ ) {
    sts = VDobjGetNamedMacros(osnum, macNames[i], &cnt, &listIDs);
    if( (sts&1) && cnt > 0 ) {
      if( a_listIDs ) {
         *a_listIDs = realloc(*a_listIDs, (bvlCnt+cnt)*sizeof(TGRid));
         if( !(*a_listIDs) ) goto wrapup;
	 for(j = 0; j < cnt; j ++) {
	    (*a_listIDs)[bvlCnt+j] = listIDs[j];
	 }
      }
      bvlCnt += cnt;
      if( bevelCnt && i == 0 )     *bevelCnt     = cnt;
      if( ej_bevelCnt && i == 1 )  *ej_bevelCnt  = cnt;
      if( fab_stockCnt && i == 3 ) *fab_stockCnt = cnt;
      if( va_bevelCnt && i == 3 )  *va_bevelCnt  = cnt;
    }
    if( listIDs != NULL) {
      free(listIDs); listIDs = NULL;
    }
  }


  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/*--------------------------------------------------------
 * Get penetrations and controls
 */
IGRstat VDobjGetPenPcg(	VDosnum	osnum, 
			IGRint	*penCnt, 
			IGRint	*pcgCnt,
			TGRid	**a_listIDs)
{
  IGRstat	retFlag = 0;
  IGRstat	sts;
  TGRid		*listIDs = NULL;
  IGRint	cnt = 0, objCnt = 0, i, j;
  IGRchar	*macNames[] = {"pcgMacro", "penMacro"};

  // Arg check
  if (a_listIDs)	*a_listIDs  = NULL;
  if (pcgCnt)		*pcgCnt = 0;
  if (penCnt)		*penCnt = 0;

   
  for( i = 0; i < 2; i++ ) {
    sts = VDobjGetNamedMacros(osnum, macNames[i], &cnt, &listIDs);
    if( (sts&1) && cnt > 0 ) {
      if( a_listIDs ) {
         *a_listIDs = realloc(*a_listIDs, (objCnt+cnt)*sizeof(TGRid));
         if( !(*a_listIDs) ) goto wrapup;
	 for(j = 0; j < cnt; j ++) {
	    (*a_listIDs)[objCnt+j] = listIDs[j];
	 }
      }
      objCnt += cnt;
      if( pcgCnt && i == 0 )  *pcgCnt = cnt;
      if( penCnt && i == 1 )  *penCnt = cnt;
    }
    if( listIDs != NULL) {
      free(listIDs); listIDs = NULL;
    }
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation Root;
