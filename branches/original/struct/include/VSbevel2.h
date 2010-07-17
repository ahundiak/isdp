/* $Id: VSbevel2.h,v 1.1 2001/01/16 23:53:50 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/include/VSbevel.h
 *
 * Description: created for bevel macros: Bevel, EJ_Bevel, VA_Bevel
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevel2.h,v $
 *      Revision 1.1  2001/01/16 23:53:50  ramarao
 *      *** empty log message ***
 *
 * Revision 1.1  2000/10/25  19:23:42  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/24/00  ah      Creation
 * -------------------------------------------------------------------*/

#ifndef VSbevel2_include
#define VSbevel2_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * VSbevel2.I
 */
extern IGRstat VScomputeBevel __((TGRobj_env *macOE,
				  IGRint      tempCnt,
				  IGRint     *feetCnt,
				  TGRid	     *feetIDs));


extern IGRstat VScomputeEJ_Bevel __((TGRobj_env *macOE,
				     IGRint      tempCnt,
				     IGRint     *feetCnt,
				     TGRid	*feetIDs));

extern IGRstat VScomputeFab_Stock __((TGRobj_env *macOE,
				     IGRint       tempCnt,
				     IGRint      *feetCnt,
				     TGRid	 *feetIDs));

extern IGRstat VScomputeVariable_Bevel __((TGRobj_env *macOE,
					   IGRint      tempCnt,
					   IGRint     *feetCnt,
					   TGRid      *feetIDs));

/* -----------------------------------------------
 * VSbevelMisc.I
 */

extern IGRstat VSbevelSetFontSize __((IGRint fontSize, TGRobj_env *macOE));
extern IGRint  VSbevelGetFontSize();

extern IGRstat VSbevelCreateStockSymbol __((IGRdouble  *pointPt,
					    IGRdouble  *orient,
					    TGRobj_env *macOE,
					    TGRid      *symID));

extern IGRstat VSbevelCreateTextLabel __((IGRchar        *textStr,
					  IGRint          stock,
					  IGRdouble      *pointPt,
					  IGRdouble      *orient,
					  TGRobj_env     *macOE,
					  TGRid          *textID));

extern IGRstat VSbevelCreateFootCollector __((TGRobj_env *attrOE, 
					      TGRobj_env *macOE,
					      TGRid      *colID,
					      IGRchar    *textStr,
					      IGRint     *haveStock));

extern IGRstat VSbevelFillOrient __((TGRbsp_surface *srfBsp,
				     TGRobj_env     *srfOE,
				     IGRdouble      *pointPt,
				     TGRbsp_curve   *crvBsp,
				     IGRdouble      *orient));

extern IGRstat VSbevelGetCurveOverlap __((TGRbsp_curve *crv1, 
					  TGRbsp_curve *crv2, 
					  TGRobj_env   *macOE,
					  TGRbsp_curve **crv));

/* -----------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif
