/* $Id: VDsupMisc.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsupMisc.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsupMisc.h,v $
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
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
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

#if defined(__cplusplus)
extern "C" {
#endif

IGRstat VDsupGetLcInfo __((
  TGRmd_env     *md_env,
  TGRid         *id,
  TGRlc_info    *lc
));

IGRstat VDsupGetPoint __((
  TGRmd_env     *md_env,
  TGRid         *id,
  TGRpoint      *pt,
  IGRboolean    *bool
));

IGRstat VDsupGetDouble __((
  TGRmd_env     *md_env,
  TGRid         *id,
  IGRdouble     *value
));

IGRstat VDsupGetPtCrvPar __((
  TGRbsp_curve *crv,
  TGRpoint     *pt,
  IGRdouble    *par
));

IGRstat VDsupIntCrvCrv __((
  TGRbsp_curve *crv1,
  TGRbsp_curve *crv2,
  TGRpoint     *pt1,
  TGRpoint     *pt2,
  IGRdouble    *par1,
  IGRdouble    *par2,
  IGRdouble    *dist
));

IGRstat VDsupConsObj __((
  GRclassid  classid, 
  TGRmd_env *md_env, 
  TGRid     *objId
));

IGRstat VDsupGetDistPt __((
  TGRbsp_curve *crv,
  IGRdouble     intPar,
  IGRdouble     dirPar,
  IGRdouble     dist,
  TGRpoint     *pt
));

IGRstat VDsupLinestrToCurve __((
  TGRid           *strId,   // IN : lineString id
  TGRmd_env	  *strEnv,  // IN : linestring GRmd_env
  TGRvg_construct *strCnst, // IN : B-spline cnst info
  TGRid 	  *bspId    // OUT: B-spline curve
));

IGRstat VDsupSelectClosestCv __((
  IGRint      nb_cv,	   /*I number of cv in list	*/
  TGRid      *list_cv,	   /*I list of cv		*/
  TGRmd_env  *cv_env,	   /*I module enviroment of cvs*/
  IGRdouble  *select_pt,   /*I point of selection	*/
  TGRid      *closest	   /*O selected element	*/
));

IGRstat VDsupSelectClosestCvObj __((
  IGRint      nb_cv,	   /*I number of cv in list	*/
  GRobjid    *list_obj,	   /*I list of cv		*/
  TGRmd_env  *cv_env,	   /*I module enviroment of cvs*/
  IGRdouble  *select_pt,   /*I point of selection	*/
  TGRid      *closest	   /*O selected element	*/
));

void VDsupInitCnst __((
  TGRvg_construct *usr_cnst
));

#if defined(__cplusplus)
}
#endif

