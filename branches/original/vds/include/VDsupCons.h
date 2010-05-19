/* $Id: VDsupCons.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsupCons.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupCons.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/28  19:05:38  pinnacle
 * Added Headers
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/28/97        ah              added header
 ***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

/* --------------------------------------------
 * Info used during actual construction
 */
typedef struct { 
  IGRdouble  dis1,dis2;
  IGRdouble  cut1,cut2,cutf;

  IGRdouble  cnt;

  TGRlc_info baseSurfLc;
  TGRlc_info baseObj1Lc;
  TGRlc_info baseObj2Lc;
  TGRlc_info baseCrv1Lc;
  TGRlc_info baseCrv2Lc;
  TGRlc_info trim1Lc;
  TGRlc_info trim2Lc;

  TGRpoint    dirPt;
  TGRpoint    selPt;
  IGRboolean  dirBool;
  IGRboolean  selBool;

  /* Some Controlling Stuff */
  TGRmd_env *md_env;

  IGRint     traceNum;
  IGRint     typeMacro;
  IGRint     tempNum;
  TGRid     *tempListId;
  TGRid     *tl;

  IGRint    *feetNum;
  TGRid     *feetListId; 

  IGRchar    occName[DI_PATH_MAX];

} VDsupConsInfo;

#if defined(__cplusplus)
extern "C" {
#endif


IGRstat VDsupGetCrvOrSurfGeom __((
  VDsupConsInfo *info,
  TGRlc_info    *lc,
  TGRbsp_curve **bsp
));

IGRstat VDsupPlaceCurve __((
  VDsupConsInfo *info,
  TGRpoint      *ptList,
  IGRlong        j
));

IGRstat VDsupGetIntersection __((
  VDsupConsInfo *info,
  TGRlc_info    *obj1Lc,
  TGRlc_info    *obj2Lc,
  TGRid         *intId
));

IGRstat VDsupGetTrimPar __((
  TGRbsp_curve *crvBsp,
  TGRlc_info   *lcInfo,
  IGRdouble    *par
));

IGRstat VDsupTrimCurve __((
  VDsupConsInfo *info,
  TGRid         *crvId,
  TGRid         *trimId
));

IGRstat VDsupCutCurve __((
  VDsupConsInfo *info,
  TGRid         *crvId,
  TGRid         *cutId
));

IGRstat VDsupMakeCurveFromPars __((
  VDsupConsInfo *info,
  TGRbsp_curve  *crvBsp,
  IGRdouble      par1,
  IGRdouble      par2,
  TGRid         *newId
));

IGRstat VDsupConsCrv __((VDsupConsInfo *info));
IGRstat VDsupConsOff __((VDsupConsInfo *info));
IGRstat VDsupConsEqu __((VDsupConsInfo *info));

#if defined(__cplusplus)
}
#endif

