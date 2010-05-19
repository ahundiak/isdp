/* $Id: VDefpSrf.h,v 1.5 2002/05/01 19:54:00 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDefpSrf.h
 *
 * Description: Control accrss to the surface trnasformation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDefpSrf.h,v $
 *      Revision 1.5  2002/05/01 19:54:00  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/11/12 17:21:17  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/11/09 18:10:12  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 18:46:10  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:38:52  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/16/01  ah      Creation
 * 11/09/01  ah      Cleaned up problems with redefining typedefs
 ***************************************************************************/

#ifndef VDefpSrf_include
#define VDefpSrf_include

#ifndef   VDgeom_include
#ifndef   VDgeomc_include
#include "VDgeomc.h"
#endif
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Surface Transformation information
 * Keep in sync with VDefp
 */
typedef struct 
{
  TGRbsp_curve **bsps;
  IGRint         cnt;
} TVDgeomListBsps;
  
typedef struct {

  /* 
   * This is a single outer contour bspline made from
   * natural edges for (plate base surface or beam left web)
   */   
  TGRbsp_curve *edgeBsp;

  IGRdouble edgeLen;

  IGRdouble center_minor_distance;
  IGRdouble center_major_distance;
  IGRdouble  minor_major_distance;

  IGRpoint center;
  IGRpoint major;
  IGRpoint minor;

  IGRpoint material; /* Material direction from center */

  IGRvector center_major_vec;
  IGRvector center_minor_vec;
  IGRvector normal;
  IGRdouble angle;

  IGRdouble cutout_distance;
  
  TVDgeomListBsps inner;
  TVDgeomListBsps flange1;
  TVDgeomListBsps flange2;
  TVDgeomListBsps other;

  IGRint  numStockPts;
  IGRdouble *stockPts;

} TVDefpSrfTranInfo;

extern void VDefpInitSrfTranInfo __((TVDefpSrfTranInfo *info));
extern void VDefpFreeSrfTranInfo __((TVDefpSrfTranInfo *info));

extern IGRstat VDefpGetSrfTranInfo __((TGRobj_env *pieceOE, TVDefpSrfTranInfo *info));

extern IGRstat VDefpCompareSrfTranInfo __((IGRdouble      bs_tol,
					   TVDefpSrfTranInfo *info1,
					   TVDefpSrfTranInfo *info2,
					   TVDgeomMat3x3  mat));

/* ---------------------------------------------
 * The debug macro
 */
#define VDEFP_SRF_TRAN_MACRO_NAME       "srf_tran"

#define VDEFP_SRF_TRAN_FOOT_NAME_POINTS "points"
#define VDEFP_SRF_TRAN_FOOT_NAME_OUTER  "outer"
#define VDEFP_SRF_TRAN_FOOT_NAME_OTHER  "other"

#define VDEFP_SRF_TRAN_FOOT_IDX_POINTS     0
#define VDEFP_SRF_TRAN_FOOT_IDX_OUTER      1
#define VDEFP_SRF_TRAN_FOOT_IDX_OTHER      2

#define VDEFP_SRF_TRAN_FOOT_MAX_OTHER    100
#define VDEFP_SRF_TRAN_FOOT_MAX          102

#define VDEFP_SRF_TRAN_TEMP_NAME_PIECE "piece"
#define VDEFP_SRF_TRAN_TEMP_IDX_PIECE  0
#define VDEFP_SRF_TRAN_TEMP_MAX        1

extern IGRstat VDefpComputeSrfTran __((TGRobj_env *macOE,
				       IGRint      opFlag,
				       IGRint     *cnt,
				       TGRid      *ids));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
