/* $Id: VDah.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDah.h
 *
 * Description: my own tool kit, Requires VDmaster.h
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDah.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.7  1998/04/02  21:17:42  pinnacle
 * ah
 *
 * Revision 1.6  1998/03/15  15:18:54  pinnacle
 * AssyTree
 *
 * Revision 1.5  1998/03/02  18:37:44  pinnacle
 * AssyTree
 *
 * Revision 1.4  1998/02/25  16:03:50  pinnacle
 * ah
 *
 * Revision 1.3  1998/02/15  15:46:52  pinnacle
 * PPL Routines
 *
 * Revision 1.2  1997/12/17  18:44:20  pinnacle
 * VDsupEtc
 *
 * Revision 1.1  1997/11/25  01:12:12  pinnacle
 * AssyTree
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 12/17/97  ah      VDahExp and VDahObj
 * 02/15/98  ah      PPL Interface
 * 02/25/98  ah      Make PPL friendly
 * 03/15/98  ah      Channel Macro Interface
 * 03/31/98  ah      Moved channel macro into VDchn.h
 ***************************************************************************/
#ifndef VDah_include
#define VDah_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ---------------------------------------
 * vdah/VDahChn.I
 * Channel Processing
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahGetChnCount __((
  TGRid   *chnId,
  IGRchar *chnName,
  IGRuint *chnCount
));
extern IGRstat VDahGetChnObject __((
  TGRid   *objId,
  IGRchar *chnName,
  IGRuint  chnObjIndex,
  TGRid   *chnObjId
));
extern IGRstat VDahGetChnObjects __((
  TGRid         *objId,
  IGRchar       *chnName,
  IGRint         chnIdMax,
  TGRid         *chnIds,
  IGRint        *chnIdCnt
));
extern IGRstat VDahGetChnObjects1 __((
  TGRid         *objId,
  IGRchar       *chnName,
  IGRint         chnIdMax,
  TGRid        **chnIds,
  IGRint        *chnIdCnt
));
extern IGRstat VDahGetChnObjs __((
  TGRid     *objID,
  IGRchar   *chnName,
  TVDvlaID  *chnVLA
));

#if defined(__cplusplus)
}
#endif

/* ---------------------------------------
 * vdah/VDahClass.I
 * Class Processing
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahClaGetClassId   __((TGRid *objID, VDclassid   *classID));
extern IGRstat VDahClaGetClassName __((TGRid *objID, IGRchar     *className));
extern IGRstat VDahClaIsInVLA      __((TGRid *objID, TVDvlaCLASS *classVLA));
extern IGRstat VDahClaGetNumDerCla __((VDclassid curClassID, IGRint *numClasses));
extern IGRstat VDahClaGetDerCla    __((VDclassid curClassID, TVDvlaCLASS *classVLA));
extern IGRstat VDahClaGetDerClaForClaName __((IGRchar *className, TVDvlaCLASS *classVLA));

#if defined(__cplusplus)
}
#endif

/* ---------------------------------------
 * vdah/VDahRef.I
 * Reference File  Processing
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahRefGetRefMgr  __((GRspacenum modId_osnum, TGRid *mgrID)); 
extern IGRstat VDahRefGetRefEnv  __((TGRid *refID, TGRmd_env *refENV));
extern IGRstat VDahRefAddRef     __((TGRid *mgrID, IGRuint chnIndex, TVDvlaENV *refEnvVLA));
extern IGRstat VDahRefGetRefList __((TVDvlaENV *refEnvVLA));

#if defined(__cplusplus)
}
#endif

/* ---------------------------------------
 * vdah/VDahLoc.I
 * Locate Processing
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahLocClaFilter __((
  OM_S_SPAMAPENT *map, 
   VDobjid        mapObjID, 
  TVDvlaCLASS    *classVLA
));
extern IGRstat VDahLocClaForOS __((
  TGRmd_env   *osENV, 
  TVDvlaCLASS *classVLA,
  TVDvlaOE    *objVLA
));
extern IGRstat VDahLocMapClaIds __((
   VDosnum     refOSnum, 
  TVDvlaCLASS *classVLA, 
  TVDvlaCLASS *classVLAos 
));
extern IGRstat VDahLocObjectsByClass __((IGRchar *className, TVDvlaOE *objVLA));

#if defined(__cplusplus)
}
#endif

/* ---------------------------------------
 * vdah/VDahExp.I
 * Expression Processing
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahMakeExpObject __((IGRchar *str, TGRid *expID,     IGRchar *status));
extern IGRstat VDahTestExpObject __((TGRid *expID, IGRdouble *value, IGRchar *status));
extern IGRstat VDahDumpExpObject __((TGRid *expID));
extern IGRstat VDahGetExpStr     __((TGRid *expID, IGRchar *str));
//extern IGRstat VDahSetExpForm    __((TGRid *expID, Form form, IGRint gadget));

#if defined(__cplusplus)
}
#endif

/* ---------------------------------------
 * vdah/VDahObj.I
 * Object Processing
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahGetObjectEnv   __((TGRid      *srcID, TGRobj_env *objOE));
extern IGRstat VDahMakeSource     __((TGRobj_env *objOE, TGRid      *srcID));
extern IGRstat VDahGetObjectDesc  __((TGRid      *objID, IGRchar    *desc));
extern IGRstat VDahGetNextOccName __((IGRchar *occPrefix, IGRchar *occPath, IGRchar *occName));

#if defined(__cplusplus)
}
#endif

/* ----------------------------------------
 * vdah/VDahPPL.I
 * PPL Interface
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahPPL_Load __((
  IGRchar *pplName,   // I - PPL File Name
  TGRid   *pplID      // O - PPL objid
));

extern IGRstat VDahPPL_Run __((
  TGRid   *pplID,     // I - PPL objid (Existing)
  IGRchar *pplEntry,  // I - PPL Function Name
  IGRint  *pplVAL     // O - Return Value
));

extern IGRstat VDahPPL_IsEntryDefined __((
  TGRid   *pplID,     // I - PPL objid (Existing)
  IGRchar *pplEntry   // I - PPL Function Name
));

extern IGRstat VDahPPL_SetValue __((
  TGRid   *pplID,          // I - PPL objid (Existing)
  IGRchar *pplValueName,   // I - PPL Variable Name
  IGRint   pplValueSize,   // I - PPL Variable Size
  IGRchar *pplValuePtr     // I - PPL Variable Value
));

extern IGRstat VDahPPL_GetValue __((
  TGRid   *pplID,          // I - PPL objid (Existing)
  IGRchar *pplValueName,   // I - PPL Variable Name
  IGRint   pplValueSize,   // I - PPL Variable Size
  IGRchar *pplValuePtr     // I - PPL Variable Value
));

extern IGRstat VDahPPL_Delete __((
  TGRid *pplID        // I: Existing PPL Object
));

#if defined(__cplusplus)
}
#endif

#endif










