/* $Id: VDgeom.h,v 1.2 2001/01/10 15:47:26 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDgeom.h
 *
 * Description:	Geometry Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDgeom.h,v $
 *      Revision 1.2  2001/01/10 15:47:26  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.6  2000/11/27  16:24:18  pinnacle
 * ah
 *
 * Revision 1.5  2000/10/16  17:18:00  pinnacle
 * ah
 *
 * Revision 1.4  2000/06/19  18:06:20  pinnacle
 * ah
 *
 * Revision 1.3  2000/04/28  19:16:54  pinnacle
 * ah
 *
 * Revision 1.9  2000/03/28  17:18:44  pinnacle
 *
 *
 * Revision 1.1  1998/10/08  17:39:26  pinnacle
 * ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/08/98  ah      Creation
 * 01/28/99  ah      Added assorted functions
 * 10/26/99  ah      Added GetSurface
 * 03/21/00  ah      Added VDgeomAllocCrv
 * 04/11/00  ah      Added VDgeomIsCurveObjectClosed
 * 10/15/00  ah      Added md_env to VDdrawCurve
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef VDgeom_include
#define VDgeom_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------
 * Default tolerances
 * Most functions which require a tolerance will allow the user
 * to override the tolerance but will default to these values
 * if a tolerance of 0 is sent.
 */

/* ----------------------------------------------------
 * The calling program may not always know what tolerance to use
 * If a zero tolerance is passed, the processing program will
 * default to an appropiate value
 * 
 * This number is used to determine when 0 has been passed
 */
#define VDGEOM_TOL_ZERO .000001

/* ----------------------------------------------------
 * In many cases, we need to step through geometry 1 parameter value
 * at a time.  We need to avoid processing the same paremeter value multiple
 * times.  Curves often have multiple duplicate knots to indicate
 * various stuff to the real bs routines.
 * 
 * To skip these multiple knots, need a tolerance to indicate when two parameter
 * values should be considered identical.
 *
 * A value of .001 was derived through trial and error.  Many line strings have
 * parameter values of less than .01 difference but so far none are less than
 * .001
 */
#define VDGEOM_TOL_PARAMETER .001

/* ----------------------------------------------
 * Really based on spades, if an internal cutout
 * is parametric based on this tolerance then
 * pass it as parametric
 */
#define VDGEOM_TOL_IS_SYM .5

/* ----------------------------------------------
 * Sometimes curves get opened a bit
 * after processing
 * Usually the software will force the ends to match
 */
#define VDGEOM_TOL_IS_CLOSED .01

/* ----------------------------------------------
 * This is used to compare two curves on a point by point basis
 * Usually, the second curve is a reduction of the first curve
 * and we just need to check that they match within a production
 * oriented tolerance
 */
#define VDGEOM_TOL_CURVES_MATCH .1

/* ---------------------------------------------------
 * Used to determine is part of a curve is linear
 */
#define VDGEOM_TOL_LINEAR .1

/* ----------------------------------------------------
 * Way to get geometry and stuff
 * VDgeomGet.I
 */

extern IGRstat VDgeomGet
__((TGRobj_env    *objOE,
    TGRid         *objID, 
    TGRmdenv_info *mat,
    IGRchar      **bsp
));

#omdef vdgeom$Get(objOE = NULL,
		  objID = NULL,
		  mat   = NULL,
		  bsp)

VDgeomGet((objOE),(objID),(mat),(bsp))
#endomdef

/* ----------------------------------------------------
 * Way to get geometry without stupid typecasting
 */

extern IGRstat VDgeomGet2
__((TGRobj_env      *objOE,
    TGRid           *objID, 
    TGRmdenv_info   *mat,
    TGRbsp_curve   **crv,
    TGRbsp_surface **srf
));

#omdef vdgeom$Get2(objOE = NULL,
		   objID = NULL,
		   mat   = NULL,
		   crv   = NULL,
                   srf   = NULL)

VDgeomGet2((objOE),(objID),(mat),(crv),(srf))
#endomdef

/* ----------------------------------------------------
 * Allows getting surface geometry with edge option
 */

extern IGRstat VDgeomGetSurface
__((TGRobj_env      *objOE,
    TGRid           *objID, 
    TGRmdenv_info   *mat,
    IGRboolean       getEdges,
    TGRbsp_surface **srf
));

#omdef vdgeom$GetSurface(objOE = NULL,
		         objID = NULL,
		         mat   = NULL,
                         getEdges = 0,
                         srf);

VDgeomGetSurface((objOE),(objID),(mat),(getEdges),(srf))
#endomdef

extern IGRstat VDgeomGetSrfPt    __((TGRbsp_surface *bsp, 
				     IGRdouble u, 
				     IGRdouble v, 
				     IGRpoint pt));

extern IGRstat VDgeomGetCrvPt    __((TGRbsp_curve *bsp, 
				     IGRdouble u,  
				     IGRpoint pt));

extern IGRstat VDgeomGetDisPtCv  __((IGRpoint      pt, 
				     TGRbsp_curve *crv, 
				     IGRdouble    *dis));

extern IGRstat VDgeomGetDisPtCrv __((IGRpoint      pt, 
				     TGRbsp_curve *crv, 
				     IGRdouble    *dis));

extern IGRstat VDgeomGetDisPtPt  __((IGRpoint      pt1, 
				     IGRpoint      pt2, 
				     IGRdouble    *dis));

extern IGRstat VDgeomGetEndPoints __((TGRbsp_curve *crv, 
                                      IGRpoint      pt1, 
                                      IGRpoint      pt2));

extern IGRstat VDgeomGetCrvEndPts __((TGRbsp_curve *crv, 
                                      IGRpoint      pt1, 
                                      IGRpoint      pt2));

extern IGRstat VDgeomGetDisPtParCrv __((IGRpoint pt, 
					TGRbsp_curve *crv, 
					IGRdouble *dis, 
					IGRdouble *par));

// Make tolerances easier
extern IGRstar VDgeomGetTolerance  __((IGRdouble *basis,
                                       IGRdouble *cht,
                                       IGRdouble *offset,
                                       IGRdouble *arclen,
                                       IGRdouble *stepmax));

#omdef vdgeom$GetTolerance(basis   = NULL,
		           cht     = NULL,
		           offset  = NULL,
		           arclen  = NULL,
                           stepmax = NULL)

VDgeomGetTolerance((basis),(cht),(offset),(arclen),(stepmax))
#endomdef

/* ------------------------------------------------------------------------
 * Debugging tool for printing geometry
 * VDgeomPrint.I
 */
extern IGRstat VDgeomPrint
__((IGRchar        *txt,  
    TGRbsp_curve   *crv,
    TGRbsp_surface *srf,
    TGRmdenv_info  *mat
));

#omdef vdgeom$Print(txt = NULL,
		    crv = NULL,
		    srf = NULL,
		    mat = NULL)

VDgeomPrint((txt),(crv),(srf),(mat))
#endomdef

extern IGRstat VDgeomPrintMatrix2
__((FILE      *file,
    IGRchar   *txt, 
    IGRint     matrix_type, 
    IGRdouble *matrix,
    TGRmdenv_info *mat,
    TGRmd_env     *env,
    TGRobj_env    *objOE));

#omdef vdgeom$PrintMatrix(FILE  = stdout,
			  txt   = NULL,
			  type  = -1,
			  mat   = NULL,
			  matx  = NULL,
			  env   = NULL,
			  objOE = NULL)

VDgeomPrintMatrix2((file),(txt),(type),(mat),(matx),(env),(objOE))
#endomdef

/* ------------------------------------------------------------------------
 * Matrix type routines
 * VDgeomMat.I
 */
/* ------------------------------------------
 * Easy matrix multiplier
 */

extern IGRstat VDgeomMultMat
__((TGRmdenv_info *mat1, 
    TGRmdenv_info *mat2, 
    TGRmdenv_info *mat3
));

#omdef vdgeom$MultMat(mat1,
		      mat2,
		      mat3 = NULL)

VDgeomMultMat((mat1),(mat2),(mat3))
#endomdef

/* ------------------------------------------
 * Make identity matrix
 */

extern IGRstat VDgeomSetMatToIdentity
__((TGRmdenv_info *mat 
));

#omdef vdgeom$SetMatToIdentity(mat)

VDgeomSetMatToIdentity((mat))
#endomdef

extern IGRstat VDgeomSetMatToIdentity2
__((IGRshort *matrix_type,
    IGRmatrix matrix
));

#omdef vdgeom$SetMatToIdentity2(type = NULL, mat = NULL)

VDgeomSetMatToIdentity2((type),(mat))
#endomdef

// Wrapper for MAtypemx
extern IGRstat VDgeomSetMatType __((IGRmatrix matrix, IGRshort *matrix_type));

/* -----------------------------------------------------------------------
 * Knot Processing Routines
 * VDgeomKnot.I
 */
typedef struct 
{
  IGRdouble *sbuf;   // Static buffer
  IGRint     max;
  IGRint     cnt;
  IGRint     i;
  IGRdouble *knots;
} TVDgeomKnots;

extern IGRstat VDgeomInitKnots __((TVDgeomKnots *knots, IGRdouble *buf, IGRint max));
extern IGRstat VDgeomFreeKnots __((TVDgeomKnots *knots));

extern IGRstat VDgeomGetKnotsFromCurve
__((TGRbsp_curve *crv,     // I  - the curve 
    IGRdouble     tol,     // I  - Optional parameter tolerance
    IGRdouble     par0,    // I  - Optional parameter filter
    IGRdouble     par1,    // I  - Optional parameter filter
    TVDgeomKnots *knots)); // IO - Knot Information

#omdef vdgeom$GetKnotsFromCurve(crv,
				tol=VDGEOM_TOL_PARAMETER,
				par0=0.0,
				par1=1.0,
				knots)

VDgeomGetKnotsFromCurve((crv),(tol),(par0),(par1),(knots))
#endomdef

/* -----------------------------------------------------------------------
 * Arc Len Processing Routines
 * VDgeomLen.I
 */
typedef struct 
{
  IGRdouble *sbuf;
  IGRint     cnt;
  IGRint     max;
  IGRint     i;
  IGRdouble *lens;
} TVDgeomArcLens;

extern IGRstat VDgeomInitArcLens __((TVDgeomArcLens *lens, IGRdouble *buf, IGRint max));
extern IGRstat VDgeomFreeArcLens __((TVDgeomArcLens *lens));

extern IGRstat VDgeomGetArcLens
__((TGRbsp_curve *  crv,     // I  - the curve 
    IGRdouble       par0,    // I  - Optional parameter filter
    IGRdouble       par1,    // I  - Optional parameter filter
    IGRint          numSegs, // I  - Breaks per knot
    IGRdouble       minSegLen,
    TVDgeomArcLens *lens));  // IO - Len Information

#omdef vdgeom$GetArcLens(crv,
			 par0      = 0.0,
			 par1      = 1.0,
			 numSegs   = 0,
			 minSegLen = 1.0,
			 lens)

VDgeomGetArcLens((crv),(par0),(par1),(numSegs),(minSegLen),(lens))
#endomdef

extern IGRstat VDgeomGetCrvArcLen __((TGRbsp_curve *crv, 
				      IGRdouble     par0, 
				      IGRdouble     par1, 
				      IGRdouble    *len));

#omdef vdgeom$GetCrvArcLen(crv,
		           par0 = 0.0,
		           par1 = 1.0,
		           len)

VDgeomGetCrvArcLen((crv),(par0),(par1),(len))
#endomdef

extern IGRstat VDgeomGetCrvArcParPt __((TGRbsp_curve *crv, 
					IGRdouble     par0, 
					IGRdouble     par1, 
					IGRdouble     len,
					IGRdouble    *par,
					IGRpoint      pt));

#omdef vdgeom$GetCrvArcParPt(crv,
			     par0 = 0.0,
			     par1 = 1.0,
			     len,
			     par = NULL,
			     pt  = NULL)

VDgeomGetCrvArcParPt((crv),(par0),(par1),(len),(par),(pt))
#endomdef

extern IGRstat VDgeomGetCrvArcRatioParPt __((TGRobj_env   *objOE, // I - Object
					     TGRbsp_curve *crv,   // I - Curve
					     IGRdouble     par0,  // I Parameter boundaries
					     IGRdouble     par1,
					     IGRdouble     ratio, // I - usually .5 for mid
					     IGRdouble    *par,   // O - Parameter of point
					     IGRpoint      pt));  // O - The point

#omdef vdgeom$GetCrvArcRatioParPt(objOE = NULL,
				  crv   = NULL,
				  par0  = 0.0,
				  par1  = 1.0,
				  ratio = 0.5,
				  par   = NULL,
				  pt    = NULL)

VDgeomGetCrvArcRatioParPt((objOE)(crv),(par0),(par1),(ratio),(par),(pt))
#endomdef

/* -----------------------------------------------------------------------
 * Curve processing Routines
 * VDgeomCurve.I
 */

/* ---------------------------------------------
 * Allocates a curve, use _FREE to free
 */
extern IGRstat VDgeomAllocCrv __((IGRint order,
				  IGRint num_poles,
				  IGRint rational,
				  IGRint num_boundaries,
				  IGRint flag,
				  TGRbsp_curve **crv));

#omdef vdgeom$AllocCrv(order,
		       num_poles,
		       rational=0,
		       num_boundaries=0,
		       flag=0,
		       crv)

VDgeomAllocCrv((order),(num_poles),(rational),(num_boundaries),(flag),(crv))
#endomdef

/* ---------------------------------------------
 * Allocates a curve, use _FREE to free
 */
extern IGRstat VDgeomAllocCurve __((IGRint order,
				    IGRint num_poles,
				    IGRint rational,
				    IGRint num_boundaries,
				    IGRint flag,
				    TGRbsp_curve **crv,
				    IGRchar       *buf,
				    IGRint         bufSize,
				    IGRint        *crvSize));

#omdef vdgeom$AllocCurve(order,
		         num_poles,
		         rational=0,
		         num_boundaries=0,
		         flag=0,
		         crv,
			 buf = NULL,
			 bufSize = 0,
			 crvSize = NULL)

VDgeomAllocCurve((order),(num_poles),(rational),(num_boundaries),(flag),
	         (crv),(buf),(bufSize),(crvSize))
#endomdef

  // Wrapper for getting curve size
extern IGRstat VDgeomGetCurveSize __((IGRint order,
				      IGRint num_poles,
				      IGRint rational,
				      IGRint num_boundaries,
				      IGRint *crvSize));

#omdef vdgeom$GetCurveSize(order,
			   num_poles,
			   rational=0,
			   num_boundaries=0,
			   crvSize = NULL)

VDgeomGetCurveSize((order),(num_poles),(rational),(num_boundaries),(crvSize))
#endomdef

/* ---------------------------------------------
 * These numbers were determined by using the size routine above
 * they can be used to allocate buffers for certain curves
 */
#define VDGEOM_SIZE_LINE   144
#define VDGEOM_SIZE_CIRCLE 368
#define VDGEOM_SIZE_ARC    368
#define VDGEOM_SIZE_OVAL   688

#define VDGEOM_SIZE_BUF   2048

// Still don't understand why math.h doesn not come along
#define  VDGEOM_M_PI            3.14159265358979323846
#define  VDGEOM_M_PI_2          1.57079632679489661923
#define  VDGEOM_M_PI_4          0.78539816339744830962

/* ---------------------------------------------
 * Transorms a curve
 */
extern IGRstat VDgeomTransformCurve __((TGRbsp_curve  *crv, 
                                        TGRmdenv_info *mat, 
                                        IGRvector      vec));

extern IGRstat VDgeomExtractCurve   __((TGRbsp_curve  *crv1, 
				        IGRdouble      par1, 
				        IGRdouble      par2, 
				        TGRbsp_curve **crv2));

extern IGRstat VDgeomCopyCurve      __((TGRbsp_curve  *crv1, 
				        TGRbsp_curve **crv2));

extern IGRstat VDgeomMergeTwoCurves __((TGRbsp_curve  *crv1,
					TGRbsp_curve  *crv2,
					TGRbsp_curve **crv3));

extern IGRstat VDgeomMakeLineCurve   __((IGRpoint pt1, 
					 IGRpoint pt2, 
					 TGRbsp_curve **crv));

extern IGRstat VDgeomMakeArcCurve    __((IGRpoint pt1, 
					 IGRpoint pt2, 
					 IGRpoint pt3, 
					 TGRbsp_curve **crv));


extern IGRstat VDgeomIsCurveLinear   __((TGRbsp_curve *bsp, 
					 IGRdouble     tol,
					 IGRint        numInts,
					 IGRdouble     minLen));

extern IGRstat VDgeomIsCrvLinear     __((TGRbsp_curve *bsp, 
					 IGRdouble     tol));

extern IGRstat VDgeomIsCrvCirArc     __((TGRbsp_curve *bsp, 
					 IGRdouble tol));

extern IGRstat VDgeomCloseCurve  __((TGRbsp_curve *crv));

extern IGRstat VDgeomLinkCurves  __((TGRbsp_curve *crv1, TGRbsp_curve *crv2));

extern IGRstat VDgeomRoundDouble __((IGRdouble    *dbl));
extern IGRstat VDgeomRoundCurve  __((TGRbsp_curve *crv));

/* -----------------------------------------------
 * VDgeomSym.I
 *
 * Symmetric (more commonly known as parametric)
 * Processing routines
 */  
#define VDGEOM_SYM_TYPE_NONE    0
#define VDGEOM_SYM_TYPE_CIRCLE  1
#define VDGEOM_SYM_TYPE_ELLIPSE 2
#define VDGEOM_SYM_TYPE_OVAL    3


typedef struct 
{
  IGRint       type;
  IGRpoint     center,major,minor;
  IGRpoint     pt0,pt1,pt2;

  TGRbsp_curve *bsp;
  IGRchar       buf[VDGEOM_SIZE_BUF];
  
} TVDgeomSym;

extern IGRstat VDgeomIsCrvSymCircle  __((TGRbsp_curve *crv,
					 IGRdouble     tol,
					 TVDgeomSym   *sym));

extern IGRstat VDgeomIsCrvSym        __((TGRbsp_curve *crv,
					 IGRdouble     tol,
					 TVDgeomSym   *sym));


extern IGRstat VDgeomExpandSymCrv    __((TGRbsp_curve *crv,
					 IGRpoint      center,
					 IGRdouble     exp));

extern IGRstat VDgeomGetSymCrvAxis   __((TGRbsp_curve *crv,
					 IGRpoint      center,
					 IGRpoint      major,
					 IGRpoint      minor));

extern IGRstat VDgeomGetSymCrvCenter __((TGRbsp_curve *crv,
					 IGRpoint      center));



/* -----------------------------------------------
 * VDgeomPar.I
 */  
extern IGRstat VDgeomDoCurvesMatch  __((TGRbsp_curve *crv1, 
				        TGRbsp_curve *crv2,
				        IGRdouble     tol,
					IGRint       *match));

extern IGRstat VDgeomIsCurveClosed  __((TGRbsp_curve *crv, 
					IGRdouble     tol, 
					IGRint    *closed));

extern IGRstat VDgeomIsCurveObjectClosed __((TGRobj_env *crvOE, 
					     IGRdouble   tol, 
					     IGRint     *closed));

/* ------------------------------------------------------------------------
 * Testing routines
 * VDgeomTest.I
 */
extern IGRstat VDgeomIsCirArc     __((TGRbsp_curve *crv, 
				      IGRpoint      arcCenter, 
				      IGRdouble    *arcRadius));
extern IGRstar VDgeomIsPtsLinear __((IGRint     cnt, 
                                     IGRdouble *pts, 
                                     IGRdouble *wgts,
                                     IGRdouble  tol));

extern IGRstat VDgeomIsCrvLinear  __((TGRbsp_curve *bsp, 
                                      IGRdouble     tol));

extern IGRstat VDgeomConvertToLine __((TGRbsp_curve *crv, 
                                       TGRbsp_curve **line));

extern IGRstat VDgeomConcatEdges   __((TGRbsp_curve  *crv1,
	 		               TGRbsp_curve  *crv2,
                                       IGRdouble      tol,
			               TGRbsp_curve **crv3));

extern IGRdouble fabs __((IGRdouble x));
extern IGRdouble asin __((IGRdouble x));
extern IGRdouble acos __((IGRdouble x));
extern IGRdouble atan __((IGRdouble x));

extern IGRdouble VDgeomRadToDeg __((IGRdouble rad));
extern IGRdouble VDgeomDegToRad __((IGRdouble deg));

/* -----------------------------------------------
 * Natural Edge Processing
 */
#define VDGEOM_WANT_BOTH   1
#define VDGEOM_WANT_OPEN   2
#define VDGEOM_WANT_CLOSED 1

extern IGRstat VDgeomGetSurfaceNaturalEdges __((TGRobj_env *srfOE,
						TGRobj_env *srfOEx,
						TGRmd_env  *edgeEnv,
						IGRint     *edgeCnt,
						TGRid     **edgeIds));


extern IGRstat VDgeomGetSurfaceXYZEdge __((TGRobj_env    *a_edgeOE,
					   TGRid         *a_edgeID,
					   TGRmd_env     *a_edgeEnv,
					   IGRint         a_wantFlag,
					   TGRobj_env    *a_xyzOE,
					   TGRbsp_curve **a_crv));

extern IGRstat VDgeomGetSurfaceNaturalOuterContourGeometry 
__((TGRobj_env    *srfOE,
    IGRint         bspMax,
    IGRint        *bspCnt,
    TGRbsp_curve **bsps));

extern IGRstat VDgeomIsCurveObjectClosed __((TGRobj_env *crvOE, 
					     IGRdouble   tol, 
					     IGRint     *closed));

extern IGRstat VDgeomIsCurveClosed __((TGRbsp_curve *crv, 
				       IGRdouble     tol, 
				       IGRint       *closed));


/* -----------------------------------------------
 * Transformation Routines vdgeom/VDgeomTran.I
 */
typedef IGRdouble TVDgeomMat3x3[3][3];

extern IGRstat VDgeomGetTranForPts __((IGRpoint center1,
				       IGRpoint minor1,
				       IGRpoint major1,
				       IGRpoint center2,
				       IGRpoint minor2,
				       IGRpoint major2,
				       TVDgeomMat3x3 mat));

extern IGRstat VDgeomTransformPt   __((IGRpoint      origin1, 
				       IGRpoint      origin2, 
				       TVDgeomMat3x3 mat,
				       IGRpoint      pt1,
				       IGRpoint      pt2));

extern IGRstat VDgeomCpyPt __((IGRpoint srcPt, IGRpoint desPt));

/* -----------------------------------------------
 * Surface Routines vdgeom/VDgeomSrf.I
 */

extern IGRstat VDgeomGetSurfacePlanarProps __((TGRobj_env *srfOE,
					       IGRdouble   bs_tol,
					       IGRint     *isPlanar,
					       IGRpoint    pt,
					       IGRvector   nrm));

extern IGRstat VDgeomGetSurfaceAreaProps   __((TGRobj_env *srfOE,
					       IGRdouble  *area,
					       IGRpoint    centroid,
					       IGRdouble   moment[6]));

/* -----------------------------------------------
 * Commonly used bs routines
 * Skip for ppls
 */
#ifndef  VD_PPL

#include "bsalloccv.h"
#include "bsarc3pts.h"
#include "bsarclen.h"
#include "bsarclen2.h"

#include "bscirc3pts.h"
#include "bscircprop.h"
#include "bsconic.h"
#include "bscrossp.h"
#include "bscv_copy.h"
#include "bscveval.h"

#include "bsdistptpt.h"
#include "bsdividecv.h"
#include "bsdotp.h"

#include "bsellctaxrm.h"

#include "bsfndcent.h"
#include "bsfndcvcsp.h"
#include "bsfreecv.h"

#include "bsiarcln.h"
#include "bsinv_mat.h"

#include "bslsqptlnpl.h"
#include "bslsqptlpl2.h"

#include "bsmergarrcv.h"
#include "bsmerge_cv.h"
#include "bsmdistptcv.h"
#include "bsmkvec.h"
#include "bsmult_mats.h"

#include "bspartofcv.h"
#include "bsptlngen.h"

#include "bssfeval.h"

#include "bststcvarct.h"
#include "bststcvcarc.h"
#include "bstrans1.h"

#include "maidmx.h"
#include "maoptsxfo.h"
#include "marptsxfo.h"
#include "mascalvc.h"
#include "matypemx.h"
#include "maunitvc.h"

#endif

/* ----------------------------------------------------
 * For some reason, never mad a VDdraw.h file
 * Put them here for now
 * vds/vdah/VDdraw.I
 *
 * env = NULL means use current active enviroment
 */
extern IGRstat VDdrawCurve     __((TGRbsp_curve *crv, 
				   TGRmd_env    *env, 
				   TGRid        *newID));

extern IGRstat VDdrawLinear    __((IGRint     numPts, 
				   IGRdouble *pts, 
				   TGRmd_env *env, 
				   TGRid     *newID));

extern IGRstat VDdrawCopyCurve __((TGRobj_env *objOE, 
				   TGRmd_env  *env, 
				   TGRid      *newID));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
