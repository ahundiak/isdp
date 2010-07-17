/* $Id: VSsxexpandcv.C,v 1.4 2001/08/20 16:59:15 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSsxexpandcv.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsxexpandcv.C,v $
 *      Revision 1.4  2001/08/20 16:59:15  hans
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/08/17 21:59:02  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.2  2001/02/14 21:22:26  ramarao
 *      Modifications Related to SetProc() macro.
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
 *      Initial import to CVS
 *
 * Revision 1.4  1999/06/01  21:35:50  pinnacle
 * (No comment)
 *
 * Revision 1.3  1999/04/09  20:44:26  pinnacle
 * Replaced: vsshellexp/VSsxexpandcv.C for:  by mdong for struct
 *
 * Revision 1.2  1998/09/14  18:50:34  pinnacle
 * Replaced: vsshellexp/VSsxexpandcv.C for:  by mdong for struct
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/03/01  14:59:14  pinnacle
 * TR179701791
 *
 *
 * History:
 * MM/DD/YY    AUTHOR  DESCRIPTION
 * 09/26/97    ah      added header
 * 09/30/97    ah      TR179701791 Don't allocate 0 bytes
 * 03/01/98    ah      TR179701791 Major rewrite using psi routines
 * 08/28/98    Ming    TR179801427
 * 06/01/99    Ming    TR179900548
 * 08/18/2001  HF      TR's 4388 & 4798
 *
 ***************************************************************************/

#include "stdio.h"
#include "stdlib.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"

#include "exmacros.h"

#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "EMSmsgdef.h"

#include "igrtypedef.h"
#include "igrdef.h"
#include "godef.h"
#include "igr.h"
#include "igetypedef.h"

#include "gr.h"
#include "growner.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"

#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
/*
 * Function prototypes.
 */
#include "macubepy.h"
#include "bsdistptpt.h"
#include "bschangepar.h"
#include "bsredptscht.h"
#include "bsprintbspc.h"

#include "vds.h"
#include "v_miscmacros.h"
#include "VDtypedef.h"
#include "VSpsi.h"

#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

#define NB_ISO_CVS	200		/* Count of iso-parametric curves of  */
					/* shell.			      */

extern long	VSsxGetContourGeometry() ;
extern long	VSsxFindPointsForExpandCurve() ;
extern long	VSsxFindIsoCurvesForIntersection() ;
extern long	VSsxFindPointsOntoShellContour() ;
extern long	VSsxIntersectionPlaneIsoCv() ;
extern long	VSsxProjectReferenceLinePointOntoShell() ;
extern long	VSsxFreeIsoCv() ;

extern double	VSsxLengthPt1Pt2 () ;
extern double	VSsxLengthPt1Pt2Y() ;

extern int	VSsxPmCmp() ;
static int	use_isocurves;

/*----------------------------------------------------------------------------*/
int VSsxPtsPmCmp( A, B )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif

void	*A,
	*B ;
{
	double	*a	= (double *) A,
		*b	= (double *) B ;
	int	rc ;

		if( a[0] < b[0] )	rc = -1 ;
	else	if( a[0] > b[0] )	rc =  1 ;
	else				rc =  0 ;

	return rc ;

} /* VSsxPtsPmCmp */

/*----------------------------------------------------------------------------*/
long VSsxExpandCurve( msg, shId, shEnv, cvId, cvEnv, xMin, xMax, refLine, xCvLnStr )

long			*msg ;
struct GRid		*shId ;
struct GRmd_env		*shEnv ;
struct GRid		*cvId ;
struct GRmd_env		*cvEnv ;
double			 xMin,
			 xMax,
			 refLine ;
struct IGRpolyline	*xCvLnStr ;
{
  long			sts ;	   /* OM return code.		      */
  IGRstat               status ;   /* Function return code.           */
  BSrc			bsRC ;	   /* BS return code.		      */
  int			i,	   /* Loop index.		      */
			j,	   /* Loop index.		      */
			nbIso,	   /* Number of iso-parametric curves.*/
			nbPtEC,    /* Number of points of expanded    */
				   /* curve.			      */
			nbPtCt,    /* Number of points on shell       */
				   /* contour.			      */
			nbPtCv,    /* Number of points on curve.      */
			nbInPt ;   /* Number of intersection points   */
				   /* between plane and shell.	      */
  double		*ptEC,	   /* Points of expanded curve.       */
				   /* 0 : X-coordinate. 	      */
				   /* 1 : Length.		      */
				   /* 2 : Parameter on curve.	      */
			 ptSE,     /* Points of shell expansion.      */
                                   /*   : Length.                     */
                                   /* Points and parameters to	      */
			*cvPts,	   /* curve.			      */
			*cvPm,	   /* curve.			      */
			*shPts,    /* Points and parameters to	      */
			*shPm,	   /* shell contour at X-axis value.  */
			*intPts,   /* Intersection points between     */
				   /* plane and shell.		      */
			pjRLP[3],  /* Projected reference line point. */
			tollenvec ;/* Length tolerance. 	      */
  struct IGRbsp_surface	*shGeom ;  /* Geometry of shell.	      */
  struct IGRbsp_curve	*cvGeom,   /* Geometry of curve.	      */
			*ctGeom,   /* Geometry of contour of shell.   */
			**isoCv ;  /* List of iso-parametric curves.  */
  short			havePjRLP, /* Have projected reference line   */
				   /* point ? ( TRUE / FALSE )	      */
			cvPtUp ;   /* Have point on curve upper       */
				   /* than reference line ?	      */
				   /* ( TRUE / FALSE )		      */
  double                savcht,    /* Saved cht                       */
                        newcht;    /* Modified cht                    */
  double                divfac;
  double                mindst = 1.0e8;
  short                 extend_srf = FALSE, sign = 1, indx = 0;
  GRrange               range;

  VSpsiInfo psiInfo;

#define LEN( pt1, pt2 ) \
	VSsxLengthPt1Pt2Y( msg, nbInPt, intPts, (pt1), (pt2), &psiInfo )

  SetProc( VSsxExpandCurve ); Begin;

  __enterFunction ( name = "VSsxExpandCurve", argfmt = "shId = [%d,%d], cvId = [%d,%d], xMin/xMax = %lg, %lg, refLine = %lg",
                    args = `shId->osnum, shId->objid, cvId->osnum, cvId->objid, xMin, xMax, refLine` );

  memset(&psiInfo,0,sizeof(psiInfo));
  psiInfo.srfObj.obj_id  = *shId;
  psiInfo.srfObj.mod_env = *shEnv;
  VSpsiInitInfo(&psiInfo);

  __DBGpr_obj( "Curve", *cvId ) ;
  __DBGpr_obj( "Shell", *shId ) ;

  xCvLnStr->num_points	= 0 ;
  xCvLnStr->points	= NULL ;

  ex$message( justification = CENTER_JUS,
              msgnumb       = VS_gI_Processing ) ;

  nbPtEC   = nbPtCv = nbPtCt = nbInPt = 0 ;
  ptEC     = cvPts  = cvPm = shPts = shPm = intPts = NULL ;
  pjRLP[0] = pjRLP[1] = pjRLP[2] = ptSE = 0.0;

  shGeom   = NULL ;
  cvGeom   = NULL ;
  ctGeom   = NULL ;

  nbIso    = 0 ;
  isoCv    = NULL ;
  divfac   = 100;

  for( i = 0 ; i < 3 ; i++ ) pjRLP[i] = 0.0;

  if( xMin >= xMax ) vs$inv_arg() ;

  BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;
  BSEXTRACTPAR( msg, BSTOLCHRDHT, savcht ) ;
  newcht = savcht;
  if ( tollenvec <= .001 && (savcht / tollenvec) > 1000.0 )
  {
    newcht = tollenvec * 1000.0;
    BSchangepar( &bsRC, BSTOLCHRDHT, newcht);
  }
//    tollenvec /= 10000.0;

  /*
   * Get geometry of curve.
   */
  sts = vs$get_geometry( msg      = msg,
                         grobjId  = cvId,
                         grobjEnv = cvEnv,
                         geometry = &cvGeom ) ;

  __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

  /*
   * Get geometry of shell.
   */
  sts = vs$get_geometry( msg      = msg,
                         grobjId  = shId,
                         grobjEnv = shEnv,
                         geometry = &shGeom ) ;

  __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

  /*
   * Get geometry of contour of shell.
   */
  sts = VSsxGetContourGeometry( msg,
                                shId,
                                shEnv,
                                &ctGeom ) ;

  __CheckRC( sts, *msg, "VSsxGetContourGeometry", wrapup ) ;

  if (VDcomment)
  {
    char      *name   = NULL;
    IGRboolean option = FALSE;
    FILE      *fp;
    if ( fp = fopen("shell_contour", "w") )
    {
      BSprintbspc(fp, name, ctGeom, option);
      fclose(fp);
    }
  }

  /*
   * Find range-box of contour.
   */
  sts = MAcubepy( msg, ctGeom, range, range+3 ) ;

  __CheckRC( sts, *msg, "MAcubepy", wrapup ) ;

  /*
   * Find points of curve to expand.
   */
  if ( cvGeom->num_poles > 500 )
  {
    divfac = 500;
  }
  else if ( cvGeom->num_poles > 100 )
  {
    divfac = 100;
  }
  else if ( cvGeom->num_poles > 50 )
  {
    divfac = 50;
  }
  else
  {
    divfac = 10;
  }

  sts = VSsxFindPointsForExpandCurve( msg,
                                      cvGeom,
                                      xMin,
                                      xMax,
                                      1.0/divfac,    // cvGeom->num_poles,
                                      &nbPtCv,
                                      &cvPts,
                                      &cvPm ) ;

  __CheckRC( sts, *msg, "VSsxFindPointsForExpandCurve", wrapup ) ;

  if( !nbPtCv )
  {
    sts  = OM_S_SUCCESS ;
    *msg = MSSUCC ;
    goto wrapup ;
  }

  if (1)    // HF: 07/18/2001
  {
    double *PtsPm = NULL;

    if( !( PtsPm = _MALLOC( 4 * nbPtCv, double ) ) ) vs$mem_fail() ;

    for( i=0, j=0; i < 4 * nbPtCv; i+=4, j++ )
    {
      // Don't allow Z-values < 0.0 ...
      cvPts[3*j+2] = fabs(cvPts[3*j+2]);

      memcpy(&PtsPm[i], &cvPts[3*j], 3 * sizeof(double));
      PtsPm[i+3] = cvPm[j];
    }
    /*
     * Sort points along X-axis from xMin to xMax...
     */
    qsort( PtsPm, nbPtCv, 4*sizeof( double ), VSsxPtsPmCmp ) ;

    for( i=0, j=0; i < 4 * nbPtCv; i+=4, j++ )
    {
      memcpy(&cvPts[3*j], &PtsPm[i], 3 * sizeof(double));
      cvPm[j] = PtsPm[i+3];
    }
    if (PtsPm) _FREE(PtsPm);
  }

  if (VDcomment)
  {
    for (i=0; i < 3 * nbPtCv; i+=3)
    {
      __printf("cvPts[%3d] = %16.6lf %16.6lf %16.6lf, cvPm[] = %lf", `i/3, cvPts[i], cvPts[i+1], cvPts[i+2], cvPm[i/3]`);
    }
  }

//    if (use_isocurves)    // HF: 08/08/2001 - Obsolete !!!!!
//    {
//      /*
//       * Find iso-parametric curves to intersect with planes
//       * ( Point = (X,0,0) Normal = (1,0,0) ).
//       */
//      sts = VSsxFindIsoCurvesForIntersection( msg,
//                                              shGeom,
//                                              (double) 1/NB_ISO_CVS,
//                                              &nbIso,
//                                              &isoCv ) ;
//
//      __printf("cvGeom->num_poles = %d, nbPtCv = %d, nbIso = %d, divfac = %lg, tollenvec = %lg, savcht = %lg, newcht = %lg",
//               `cvGeom->num_poles, nbPtCv, nbIso, divfac, tollenvec, savcht, newcht`);
//
//      __CheckRC( sts, *msg, "VSsxFindIsoCurvesForIntersection", wrapup ) ;
//    }
  /*
   * Allocate points for expanded curve.
   */
  if( !( ptEC = _CALLOC( 3*nbPtCv, double ) ) ) vs$mem_fail() ;

  /*
   * For each points to expand.
   * 1) Intersect contour of shell and plane ( Point = (X,0,0)
   *    Normal = (1,0,0) ).
   * 2) Intersect iso-parametric curves and plane ( Point = (X,0,0)
   *    Normal = (1,0,0) ).
   * 3) Find distance of each point to expand.
   */
  for( i=0; i<nbPtCv; i++ )
  {
    sign = 1;
    ex$message( justification = CENTER_JUS,
                msgnumb       = VS_gI_ProcessingSection,
                var           = `i+1, nbPtCv`,
                type          = "%d%d" ) ;

    nbPtCt = 0 ;
    if ( shPts  ) { _FREE( shPts ) ; shPts = NULL ; }
    if ( shPm   ) { _FREE( shPm  ) ; shPm  = NULL ; }

    nbInPt = 0 ;
    if ( intPts ) { _FREE( intPts ) ; intPts = NULL ; }

    sts = VSsxFindPointsOntoShellContour( msg,
                                          ctGeom,
                                          cvPts[3*i],
                                          &nbPtCt,
                                          &shPts,
                                          &shPm ) ;
    __printf( "cvPts[%d] = %lf, nbPtCt = %d", `i, cvPts[3*i], nbPtCt` ) ;
    if (VDcomment)
    {
      for (j=0; j < 3*nbPtCt; j+=3)
      {
        __printf("shPts[%d] = %16.6lf %16.6lf %16.6lf  shPm[%d] = %16.6lf", `j/3, shPts[j], shPts[j+1], shPts[j+2], j/3, shPm[j/3]`);
      }
    }
    __CheckRC( sts, *msg, "VSsxFindPointsOntoShellContour", wrapup ) ;

    if( !nbPtCt )
    {
      continue ;
    }

		/*--------- Commented by Ming for TR179801427 ---------
		 * KLUDGE : Some points have their Z-coordinates above or in
		 * below the shell contour. So, adjust points so that they be
		 * in the middle of the contour. This is because the shell is
		 * not really good.
		 *
		 *   p1 .------------------	  <- Right view of shell.
		 *	|		  /
		 *	|		 /
		 *	|		/
		 *	|	       /
		 *	|     pm      /			^ z
		 *   p2 .---- . ------			|
		 *	     \./
		 *	      p
		 *
		 * p1 : First point onto shell contour.
		 * p2 : Last point onto shell contour.
		 * p  : Bad point moved to pm.

		if( cvPts[3*i+2] < shPts[2] )
			cvPts[3*i+2] = shPts[2] ;

		if( cvPts[3*i+2] > shPts[3*(nbPtCt-1)+2] )
			cvPts[3*i+2] = shPts[3*(nbPtCt-1)+2] ;
		---------------- End of comment ----------------*/

//      if (use_isocurves)    // HF: 08/08/2001 - Obsolete !!!!!
//      {
//        if( nbPtCt > 0 )
//        {
//          sts = VSsxIntersectionPlaneIsoCv( msg,
//                                            nbIso,
//                                            isoCv,
//                                            cvPts[3*i],
//                                            &nbInPt,
//                                            &intPts ) ;
//
//          __CheckRC( sts, *msg, "VSsxIntersectionPlaneIsoCv", wrapup ) ;
//
//          if( nbInPt < nbPtCt ) continue ;    // ??????
//        }
//      }

    status = VSpsiProcessPlane(&psiInfo, cvPts[3*i]);
    if( !(status) )
    {
      continue ;
    }

    /*
     * Project reference line point onto shell.
     */
    /* TR179900548 by Ming */
    havePjRLP = extend_srf = FALSE ;
    if( fabs(refLine) > tollenvec )
    {
      sts = VSsxProjectReferenceLinePointOntoShell( msg,
                                                    shGeom,
                                                    cvPts[3*i],
                                                    refLine,
                                                    &havePjRLP,
                                                    pjRLP ) ;

      if( !( sts & 1 & *msg ) ) continue ;

      if (havePjRLP == FALSE) extend_srf = TRUE;
    }

    // This only makes sense at the aft part of the shell ...
    // (supposing that AFT is near range[0])
    if ( extend_srf && cvPts[3*i] < .75 * range[0] )    // < -150000.0
    {
      sts = VSpsiProcessPlaneExtendedSurf( msg, &psiInfo, cvPts[3*i], shGeom, refLine, &havePjRLP, pjRLP);
      if( !(sts & 1 & *msg) || !havePjRLP )
      {
        continue ;
      }
    }

    /*
     * Find distance of each point to expand.
     */
    ptEC[3*nbPtEC]   = cvPts[3*i] ;
    ptEC[3*nbPtEC+2] = cvPm[i] ;

    if( refLine != 0. )
      cvPtUp = cvPts[3*i+2] >= refLine ? TRUE : FALSE ;
    else
      cvPtUp = TRUE ;

    __printf("i = %d, nbPtCt = %d, nbInPt = %d, nbPtEC = %d, havePjRLP = %d, cvPtUp = %d",
             `i, nbPtCt, nbInPt, nbPtEC, havePjRLP, cvPtUp`);

    /*----------- Commented by Ming for TR179801427 --------
		j = 0 ;
		if( refLine != 0. ) {
			while( j < nbPtCt && refLine > shPts[3*j+2] ) j++ ;

			if( !cvPtUp ) j-- ;
		}

		 *
		 * If point on curve is between first point on contour
		 * 'near' reference point and reference point, distance is
		 * only reference point -> point on curve.
		 *
		if( cvPtUp ? ( (shPts[3*j+2] - cvPts[3*i+2]) > tollenvec ) :
			     ( (cvPts[3*i+2] - shPts[3*j+2]) > tollenvec ) ) {

			ptEC[3*nbPtEC+1] = ( cvPtUp ? 1. : -1. )
					   * LEN( cvPtUp ? pjRLP : cvPts +3*i,
						  cvPtUp ? cvPts +3*i : pjRLP );

			 *
			 * EF 06/09/94 : In the back of the shell, we can have
			 * the shell like this :
			 *
			 *	\  <- Shell contour.		Z
			 *	 \     .       .		^
			 *	  \   **.**	.		|
			 *	   \	 . * p	 .		---> X
			 *	    |	 .  *@***.******* <- Curve to expand.
			 *	    |	 .	 .
			 *	    |	 .   +R  .    (R) : Projected reference
			 *	   /	.	 .	    line point.
			 *	  /    .	.
			 *	 /    .        .
			 *	/    .	      .
			 *     /    .	      .
			 *    |    (A)	     (B)      (A) : Iso curve #i.
			 *     \		      (B) : Iso curve #i+1.
			 *	\
			 *	 ---------------------
			 *
			 *		     |
			 *		     F
			 *
			 * p : The point onto the curve to expand.
			 *
			 * We have :
			 *
			 *  cvPtUp = TRUE ;
			 *  ptEC[3*nbPtEC+1] = 1. * LEN( 'R', 'p' ) ;
			 *		     = 0. ;
			 *		       ^
			 *		       |
			 *		       Because there are no points
			 * representing the hull section ('intPts' list )
			 * between 'R' and 'p' along Z axis. So, the function
			 * 'LEN' returns 0.
			 *
			 * Solution :
			 * ==========
			 *
			 *	If ptEC[3*nbPtEC+1] == 0. then
			 *	      ptEC[3*nbPtEC+1] = p[2] - R[2] ;
			 *	fi
			 *
			 *
			if( ptEC[3*nbPtEC+1] == 0. )
				ptEC[3*nbPtEC+1] = cvPts[3*i+2] - pjRLP[2] ;

			nbPtEC++ ;

			continue ;
		}

		 *
		 * Distance reference point -> first point on contour
		 * 'near' reference point.
		 *
		if( havePjRLP )
			ptEC[3*nbPtEC+1] = ( cvPtUp ? 1. : -1. )
					   * LEN( cvPtUp ? pjRLP : shPts +3*j,
						  cvPtUp ? shPts +3*j : pjRLP );

		else	ptEC[3*nbPtEC+1] = shPts[3*j+2] - refLine ;

		 *
		 * Distance next point on contour -> last point on
		 * contour 'near' point on curve.
		 *
		cvPtUp ? j++ : j-- ;

		for( ;
		     cvPtUp ? j<nbPtCt : j>=0 ;
		     cvPtUp ? j++      : j--  ) {

			if( cvPtUp ?
				( (shPts[3*j+2] - cvPts[3*i+2]) > tollenvec ) :
				( (cvPts[3*i+2] - shPts[3*j+2]) > tollenvec ) )
					break ;

			length = ( cvPtUp ? 1. : -1. )
				 * LEN( cvPtUp ? shPts +3*(j-1) :
						 shPts +3*j,
					cvPtUp ? shPts +3*j	:
						 shPts +3*(j+1) ) ;

			if( length != 0. )
				ptEC[3*nbPtEC+1] += length ;
			else
				ptEC[3*nbPtEC+1] += shPts[3*j+2]
						  -( cvPtUp ? shPts[3*(j-1)+2] :
							      shPts[3*(j+1)+2]);
		}

		 *
		 * Distance last point on contour 'near' point on
		 * curve -> point on curve.
		 *
		cvPtUp ? j-- : j++ ;

		ptEC[3*nbPtEC+1] += ( cvPtUp ? 1. : -1. )
				    * LEN( cvPtUp ? shPts +3*j :
						    cvPts +3*i ,
					   cvPtUp ? cvPts +3*i :
						    shPts +3*j ) ;

    ----------- End of comment ----------------------------*/

    sign = cvPtUp ? 1 : -1;
    indx = 0;

    /* TR179801427 by Ming */
    if( havePjRLP )
    {
//        ptEC[3*nbPtEC+1] = sign * LEN( cvPtUp ? pjRLP : cvPts +3*i,
//                                       cvPtUp ? cvPts +3*i : pjRLP );
      ptEC[3*nbPtEC+1] = sign * VSsxLengthPt1Pt2Y(msg,
                                                  nbInPt,
                                                  intPts,
                                                  cvPts +3*i,
                                                  pjRLP,
                                                  &psiInfo);
    }
    else
    {
      // Find closest contour point ...
      if( refLine != 0. )
      {
        BSrc   rc;
        double lng = mindst;
        mindst     = 1.0e8;

        // Assuming a maximum of at most 4 shell contour points (shPts; ordered in increasing Z...),
        // we want to find which of the 2 interior points is closest to: cvPts[3*i]
        for (j=3; j < 3*(nbPtCt-1); j+=3)
        {
          lng = BSdistptpt(&rc, cvPts +3*i, shPts +j);
          if (lng < mindst)
          {
            mindst = lng;
            indx   = j;
          }
        }
      }

      sign = (fabs(cvPts[3*i + 2]) > refLine) ? 1 : -1;

      ptSE = shPts[indx+2] - refLine;

      ptEC[3*nbPtEC+1] = ptSE + sign * VSsxLengthPt1Pt2Y(msg,
                                                         nbInPt,
                                                         intPts,
                                                         shPts +indx,
                                                         cvPts +3*i,
                                                         &psiInfo);
    }
    __printf( "havePjRLP = %d, sign = %d, cvPtUp = %d, ptEC[%d] = %lf, ptSE = %lf, indx = %d, mindst = %lf",
              `havePjRLP, sign, cvPtUp, 3*nbPtEC+1, ptEC[3*nbPtEC+1], ptSE, indx, mindst` ) ;

    nbPtEC++ ;
  }

  __printf(">>> End_Loop: nbPtEC = %d, nbPtCv = %d",
           `nbPtEC, nbPtCv`);

  ex$message( justification = CENTER_JUS,
              msgnumb       = VS_gI_Processing ) ;

  if (VDcomment)
  {
    for (i=0; i < 3 * nbPtEC; i+=3)
    {
      __printf("ptEC[%3d] = %16.6lf %16.6lf %16.6lf", `i/3, ptEC[i], ptEC[i+1], ptEC[i+2]`);
    }
  }

  /*
   * Sort points along its parameter on curve.
   */
  qsort( ptEC, nbPtEC, 3*sizeof( double ), VSsxPmCmp ) ;

  // HF: 07/20/2001 - Can NOT do this on ptEC !!!!!
//    /*
//     * Reduce number of points.
//     */
//    BSredptscht( &nbPtEC,
//                 (IGRpoint *) ptEC,
//                 &bsRC ) ;
//    if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

  /*
   * Output line-string of expanded curve.
   */
  if( nbPtEC )
  {
    if( !( xCvLnStr->points = _MALLOC( 3*nbPtEC, double ) ) )
      vs$mem_fail() ;

    for( i=0; i<nbPtEC; i++ )
    {
      (xCvLnStr->points)[3*i]   = ptEC[3*i];
      (xCvLnStr->points)[3*i+1] = ptEC[3*i+1];
      (xCvLnStr->points)[3*i+2] = 0.0;
    }
    /*
     * Reduce number of points.
     */
    BSredptscht( &nbPtEC,
                 (IGRpoint *) xCvLnStr->points,
                 &bsRC ) ;
    if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;
  }
  xCvLnStr->num_points = nbPtEC ;

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :
  ex$message( msgnumb = VS_gI_EmptyMessage ) ;

  BSchangepar( &bsRC, BSTOLCHRDHT, savcht);

  if ( ptEC   ) _FREE( ptEC   ) ;
  if ( cvPts  ) _FREE( cvPts  ) ;
  if ( cvPm   ) _FREE( cvPm   ) ;
  if ( shPts  ) _FREE( shPts  ) ;
  if ( shPm   ) _FREE( shPm   ) ;
  if ( intPts ) _FREE( intPts ) ;
  if ( shGeom ) _FREE( shGeom ) ;
  if ( cvGeom ) _FREE( cvGeom ) ;
  if ( ctGeom ) _FREE( ctGeom ) ;

  if( nbIso && isoCv ) VSsxFreeIsoCv( nbIso, isoCv ) ;

  VSpsiFreeInfo(&psiInfo,1);

  __exitFunction ( name = "VSsxExpandCurve", argfmt = "sts = %d, msg = %#x, bsRC = %d, nbPtEC = %d",
                   args = `sts, *msg, bsRC, nbPtEC` );

  End

  return sts ;

#undef LEN

} /* VSsxExpandCurve */
/*----------------------------------------------------------------------------*/
