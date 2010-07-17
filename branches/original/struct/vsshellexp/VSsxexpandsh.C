/* $Id: VSsxexpandsh.C,v 1.5 2001/08/20 17:21:09 hans Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsshellexp/VSsxexpandsh.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsxexpandsh.C,v $
 *      Revision 1.5  2001/08/20 17:21:09  hans
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/08/17 21:59:04  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.3  2001/02/20 01:19:13  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/02/14 21:22:28  ramarao
 *      Modifications Related to SetProc() macro.
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/06/01  21:35:26  pinnacle
 * (No comment)
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
 * 05/19/99    Ming    TR179900548
 * 08/18/2001  HF      TR's 4388 & 4798
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
#include "bsdistptpt.h"
#include "bschangepar.h"
#include "bsredptscht.h"

#include "vds.h"

#include "v_miscmacros.h"
//#include "v_geommacros.h"
//#include "vsdbgmacros.h"

#include "VDtypedef.h"
#include "VSpsi.h"

#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

#define NB_ISO_CVS	200		/* Count of iso-parametric curves of  */
					/* shell.			      */


extern long	VSsxGetContourGeometry(),
		VSsxFindXsForIntersection(),
		VSsxFindIsoCurvesForIntersection(),
		VSsxFindPointsOntoShellContour(),
		VSsxIntersectionPlaneIsoCv(),
		VSsxFreeIsoCv(),
		VSsxProjectReferenceLinePointOntoShell() ;

extern double	VSsxLengthPt1Pt2 () ;
extern double	VSsxLengthPt1Pt2Y() ;
static int	use_isocurves;

/*----------------------------------------------------------------------------*/
int VSsxPmCmp( A, B )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif

void	*A,
	*B ;
{
	double	*a	= (double *) A,
		*b	= (double *) B ;
	int	rc ;

		if( a[2] < b[2] )	rc = -1 ;
	else	if( a[2] > b[2] )	rc =  1 ;
	else				rc =  0 ;

	return rc ;

} /* VSsxPmCmp */
/*----------------------------------------------------------------------------*/
long VSsxExpandShell( msg, shId, shEnv, xMin, xMax, refLine, xCvLnStr )

long			*msg ;
struct GRid		*shId ;
struct GRmd_env 	*shEnv ;
double			xMin,
			xMax,
			refLine ;

struct IGRpolyline	*xCvLnStr ;
{
  /*
   * Given a shell ( shId, shEnv ), a reference line ( refLine )
   * ( a Z-axis value ), this function returns the line-string
   * ( xCvLnStr ) representing the shell expansion between X-axis
   * minimum ( xMin ) and X-axis maximum ( xMax ).
   *
   *		-----------------------------	  <- Shell.
   *					    /
   *					   /
   *					  /
   *		-.-.-.-.-.-.-.-.-.-.-.-.-/-.-.-.- <- Reference line.
   *					/
   *				       /
   *				       \
   *					\
   *					 \
   *  Z					 /
   *  ^		-------------------------
   *  |
   *  -> X	    |		 |
   *		  X mini       X maxi
   *
   *
   * Note :
   * ======
   *	'xCvLnStr->points' is allocated and hence must be freed by
   *	the caller with 'free( xCvLnStr->points )'.
   */

  long			sts ;	   /* OM return code.		      */
  IGRstat		status ;   /* Function return code.	      */
  BSrc			bsRC ;	   /* BS return code.		      */
  int			i,	   /* Loop index.		      */
			j,	   /* Loop index.		      */
			k,	   /* Loop index.		      */
			nbXs,	   /* Number of X-coordinate values.  */
			nbIso,	   /* Number of iso-parametric curves.*/
			nbPtSE,    /* Number of points of shell       */
				   /* expansion.		      */
			nbPtCt,    /* Number of points on shell       */
				   /* contour.			      */
			nbInPt ;   /* Number of intersection points   */
				   /*  between plane and shell.	      */
  double		*Xs,	   /* List of X-coordinate values.    */
			*ptSE,	   /* Points of shell expansion.      */
				   /* 0 : X-coordinate. 	      */
				   /* 1 : Length.		      */
				   /* 2 : Parameter on contour.       */
			*shPts,    /* Points and parameters on        */
			*shPm,	   /*  shell contour at X-axis value. */
			*intPts,   /* Intersection points between     */
				   /*  plane and shell.		      */
                        tollenvec, /* Length tolerance.               */
			pjRLP[3] ; /* Projected reference line point. */
  struct IGRbsp_surface	*shGeom ;  /* Geometry of shell.	      */
  struct IGRbsp_curve	*ctGeom,   /* Geometry of contour of shell.   */
			**isoCv ;  /* List of iso-parametric curves.  */
  short			havePjRLP, /* Have projected reference line   */
				   /* point ? ( TRUE / FALSE )	      */
			ctPtUp ;   /* Have point on contour above     */
				   /* reference line ?		      */
				   /* ( TRUE / FALSE )		      */
  double                savcht,    /* Saved cht                       */
                        newcht;    /* Modified cht                    */
  short                 extend_srf = FALSE, sign = 1, indx = 0;

  VSpsiInfo 		psiInfo;

  SetProc( VSsxExpandShell ); Begin;

  __enterFunction ( name = "VSsxExpandShell", argfmt = "shId = [%d,%d], xMin/xMax = %lg, %lg, refLine = %lg",
                    args = `shId->osnum, shId->objid, xMin, xMax, refLine` );

  memset(&psiInfo,0,sizeof(psiInfo));
  psiInfo.srfObj.obj_id  = *shId;
  psiInfo.srfObj.mod_env = *shEnv;
  VSpsiInitInfo(&psiInfo);

  __DBGpr_obj( "Shell", *shId ) ;

  xCvLnStr->num_points = 0 ;
  xCvLnStr->points     = NULL ;

  ex$message( justification = CENTER_JUS,
              msgnumb       = VS_gI_Processing ) ;

  nbXs   = 0 ;
  Xs     = NULL ;

  shGeom = NULL ;
  ctGeom = NULL ;

  nbIso  = 0 ;
  isoCv  = NULL ;

  nbPtSE = 0 ;
  ptSE   = NULL ;

  nbPtCt = 0 ;
  shPts  = shPm = NULL ;

  nbInPt = 0 ;
  intPts = NULL ;

  if( xMin >= xMax ) vs$inv_arg() ;

  BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec );
  BSEXTRACTPAR( msg, BSTOLCHRDHT, savcht ) ;
  newcht = savcht;
  if ( tollenvec <= .001 && (savcht / tollenvec) > 1000.0 )
  {
    newcht = tollenvec * 1000.0;
    BSchangepar( &bsRC, BSTOLCHRDHT, newcht);
  }
//    tollenvec /= 10000.0;    // Why ????

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

  /*
   * Find list of X-coordinate values for the intersections between
   * the shell and planes ( Point = (Xs[i],0,0) Normal = (1,0,0) ).
   */
  sts = VSsxFindXsForIntersection( msg,
                                   ctGeom,
                                   xMin,
                                   xMax,
                                   1.0/(shGeom->u_num_poles * shGeom->v_num_poles),
                                   &nbXs,
                                   &Xs ) ;

  __CheckRC( sts, *msg, "VSsxFindXsForIntersection", wrapup ) ;

  if( !nbXs )
  {
    sts  = OM_S_SUCCESS ;
    *msg = MSSUCC ;
    goto wrapup ;
  }

  if (VDcomment)
  {
    for (i=0; i < nbXs; i++)
    {
      __printf("Xs[%3d] = %16.6lf", `i, Xs[i]`);
    }
  }

//    if (use_isocurves)    // HF: 08/08/2001 - Obsolete !!!!!
//    {
//      /*
//       * Find iso-parametric curves to intersect with planes
//       * ( Point = (Xs[i],0,0) Normal = (1,0,0) ).
//       */
//      sts = VSsxFindIsoCurvesForIntersection( msg,
//                                              shGeom,
//                                              (double) 1/NB_ISO_CVS,
//                                              &nbIso,
//                                              &isoCv ) ;
//
//      __CheckRC( sts, *msg, "VSsxFindIsoCurvesForIntersection", wrapup ) ;
//    }

  /*
   * Allocate points for shell expansion.
   */
  if( !( ptSE = _MALLOC( 2*3*nbXs, double ) ) ) vs$mem_fail() ;

  /*
   * For each X-coordinate value :
   * 1) Find points of shell expansion.
   * 2) Intersect iso-parametric curves and plane ( Point = (Xs[i],0,0)
   *    Normal = (1,0,0) ).
   * 3) Find distance of each points of shell expansion.
   */
  for( i=0; i<nbXs; i++ )
  {
    sign = 1;
    ex$message( justification = CENTER_JUS,
                msgnumb       = VS_gI_ProcessingSection,
                var           = `i+1, nbXs`,
                type          = "%d%d" ) ;

    /* TR179900548 by Ming */
    status = VSpsiProcessPlane(&psiInfo,Xs[i]);
    if( !(status) ) continue;

    nbPtCt = 0 ;
    if ( shPts  ) { _FREE( shPts ) ; shPts = NULL ; }
    if ( shPm   ) { _FREE( shPm  ) ; shPm  = NULL ; }

    nbInPt = 0 ;
    if ( intPts ) { _FREE( intPts ) ; intPts = NULL ; }

    sts = VSsxFindPointsOntoShellContour( msg,
                                          ctGeom,
                                          Xs[i],
                                          &nbPtCt,
                                          &shPts,
                                          &shPm ) ;
    for (j=0; j < 3*nbPtCt; j+=3)
    {
      // Don't allow Z-values < 0.0 ...
      shPts[j+2] = fabs(shPts[j+2]);

      if (VDcomment)
      {
        __printf("shPts[%d] = %16.6lf %16.6lf %16.6lf  shPm[%d] = %16.6lf", `j/3, shPts[j], shPts[j+1], shPts[j+2], j/3, shPm[j/3]`);
      }
    }
    __CheckRC( sts, *msg, "VSsxFindPointsOntoShellContour", wrapup ) ;

    if( !nbPtCt ) continue ;

//      if (use_isocurves)    // HF: 08/08/2001 - Obsolete !!!!!
//      {
//        if( nbPtCt > 0 )
//        {
//          sts = VSsxIntersectionPlaneIsoCv( msg,
//                                            nbIso,
//                                            isoCv,
//                                            Xs[i],
//                                            &nbInPt,
//                                            &intPts ) ;
//
//          __CheckRC( sts, *msg, "VSsxIntersectionPlaneIsoCv", wrapup ) ;
//
//          if( nbInPt < nbPtCt ) continue ;    // ??????
//        }
//      }

    if( nbPtSE + nbPtCt > 2 * nbXs )
      if( !( ptSE = _REALLOC( ptSE, 3*(nbPtSE+nbPtCt), double ) ) ) vs$mem_fail() ;

    __printf("i = %d, nbPtCt = %d, nbPtSE = %d, nbXs = %d, ptSE = %#x",
             `i, nbPtCt, nbPtSE, nbXs, ptSE`);

    /*
     * Project reference line point onto shell.
     */
    /* TR179900548 by Ming */
    havePjRLP = FALSE ;
    if( fabs(refLine) > tollenvec )
    {
      sts = VSsxProjectReferenceLinePointOntoShell( msg,
                                                    shGeom,
                                                    Xs[i],
                                                    refLine,
                                                    &havePjRLP,
                                                    pjRLP ) ;

      if( !( sts & 1 & *msg ) ) continue ;
    }

    /*
     * Process contour points upper to the reference line.
     */
    j = 0 ;

    /* TR179900548 by Ming */
    if( fabs(refLine) > tollenvec )
      while( j < nbPtCt && refLine > shPts[3*j+2] ) j++ ;

    if( j != nbPtCt )
    {
      ptSE[3*nbPtSE]   = Xs[i] ;
      ptSE[3*nbPtSE+2] = shPm[j] ;

      if( refLine != 0. )
        ctPtUp = shPts[3*j+2] >= refLine ? TRUE : FALSE ;
      else
        ctPtUp = TRUE ;

      sign = ctPtUp ? 1 : -1;

      if( havePjRLP )
      {
        ptSE[3*nbPtSE+1] = sign * VSsxLengthPt1Pt2Y( msg,
                                                     nbInPt,
                                                     intPts,
                                                     ctPtUp ? pjRLP : shPts +3*j,
                                                     ctPtUp ? shPts +3*j : pjRLP,
                                                     &psiInfo ) ;
      }
      else
      {
        ptSE[3*nbPtSE+1] = shPts[3*j+2] - refLine;
      }
      __printf( "\tUpper_0 j = %d, sign = %d, ptSE[%d] = %lf", `j, sign, 3*nbPtSE+1, ptSE[3*nbPtSE+1]` ) ;

      nbPtSE++ ;
      j++ ;

      for( ; j<nbPtCt; j++ )
      {
        ptSE[3*nbPtSE]   = Xs[i] ;
        ptSE[3*nbPtSE+2] = shPm[j] ;

        if( refLine != 0. )
          ctPtUp = shPts[3*j+2] >= refLine ? TRUE : FALSE ;
        else
          ctPtUp = TRUE ;

        sign = ctPtUp ? 1 : -1;

        ptSE[3*nbPtSE+1] = ptSE[3*(nbPtSE-1)+1] + sign * VSsxLengthPt1Pt2Y( msg,
                                                                            nbInPt,
                                                                            intPts,
                                                                            ctPtUp ? shPts +3*(j-sign) : shPts +3*j,
                                                                            ctPtUp ? shPts +3*j : shPts +3*(j-sign),
//                                                                              shPts +3*(j-1),
//                                                                              shPts +3*j,
                                                                            &psiInfo);

        /* TR179900548 by Ming */
        if( fabs(ptSE[3*nbPtSE+1] - ptSE[3*(nbPtSE-1)+1]) < tollenvec )
        {
          ptSE[3*nbPtSE+1] += shPts[3*j+2] - shPts[3*(j-sign)+2] ;
        }
        __printf( "\tUpper_1 j = %d, sign = %d, ptSE[%d] = %lf", `j, sign, 3*nbPtSE+1, ptSE[3*nbPtSE+1]` ) ;

        nbPtSE++ ;
      }
    }

    /*
     * Process contour points lower to the reference line.
     */
    j = 0 ;
    while( j < nbPtCt && refLine > shPts[3*j+2] ) j++ ;

    if( j-- )
    {
      ptSE[3*nbPtSE]   = Xs[i] ;
      ptSE[3*nbPtSE+2] = shPm[j] ;

      if( refLine != 0. )
        ctPtUp = shPts[3*j+2] >= refLine ? TRUE : FALSE ;
      else
        ctPtUp = TRUE ;

      sign = ctPtUp ? 1 : -1;

      if( havePjRLP )
      {
        ptSE[3*nbPtSE+1] = sign * VSsxLengthPt1Pt2Y( msg,
                                                     nbInPt,
                                                     intPts,
                                                     ctPtUp ? pjRLP : shPts +3*j,
                                                     ctPtUp ? shPts +3*j : pjRLP,
                                                     &psiInfo ) ;
      }
      else
      {
        ptSE[3*nbPtSE+1] = shPts[3*j+2] - refLine;
      }
      __printf( "\tLower_0 j = %d, sign = %d, ptSE[%d] = %lf", `j, sign, 3*nbPtSE+1, ptSE[3*nbPtSE+1]` ) ;

      nbPtSE++ ;
      j-- ;

      for( ; j>=0; j-- )
      {
        ptSE[3*nbPtSE]   = Xs[i] ;
        ptSE[3*nbPtSE+2] = shPm[j] ;

        if( refLine != 0. )
          ctPtUp = shPts[3*j+2] >= refLine ? TRUE : FALSE ;
        else
          ctPtUp = TRUE ;

        sign = ctPtUp ? 1 : -1;

        ptSE[3*nbPtSE+1] = ptSE[3*(nbPtSE-1)+1] + sign * VSsxLengthPt1Pt2Y( msg,
                                                                            nbInPt,
                                                                            intPts,
                                                                            ctPtUp ? shPts +3*(j-sign) : shPts +3*j,
                                                                            ctPtUp ? shPts +3*j : shPts +3*(j-sign),
//                                                                              shPts +3*j,
//                                                                              shPts +3*(j+1),
                                                                            &psiInfo);

        /* TR179900548 by Ming */
        if( fabs(ptSE[3*nbPtSE+1] - ptSE[3*(nbPtSE-1)+1]) < tollenvec )
        {
          ptSE[3*nbPtSE+1] += shPts[3*j+2] - shPts[3*(j-sign)+2] ;
        }
        __printf( "\tLower_1 j = %d, sign = %d, ptSE[%d] = %lf", `j, sign, 3*nbPtSE+1, ptSE[3*nbPtSE+1]` ) ;

        nbPtSE++ ;
      }
    }
  }

  ex$message( justification = CENTER_JUS,
              msgnumb       = VS_gI_Processing ) ;

        // HF: 07/20/2001 - Can NOT do this on ptSE !!!!!
//  	/*
//  	 * Reduce number of points.
//  	 */
//  	BSredptscht( &nbPtSE,
//  		     (IGRpoint *) ptSE,
//  		     &bsRC ) ;
//  	if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

  /*
   * Output line-string of shell expansion.
   */
  if( nbPtSE )
  {
    /*
     * Sort points along its parameter on contour shell.
     */
    qsort( ptSE, nbPtSE, 3*sizeof( double ), VSsxPmCmp ) ;

    if( !( xCvLnStr->points = _MALLOC( 3*nbPtSE, double ) ) )
      vs$mem_fail() ;

    for( i=0; i<nbPtSE; i++ )
    {
      (xCvLnStr->points)[3*i]   = ptSE[3*i];
      (xCvLnStr->points)[3*i+1] = ptSE[3*i+1];
      (xCvLnStr->points)[3*i+2] = 0.0;
    }
    /*
     * Reduce number of points.
     */
    BSredptscht( &nbPtSE,
                 (IGRpoint *) xCvLnStr->points,
                 &bsRC ) ;
    if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

    (xCvLnStr->points)[3*nbPtSE]   = ptSE[0] ;
    (xCvLnStr->points)[3*nbPtSE+1] = ptSE[1] ;
    (xCvLnStr->points)[3*nbPtSE+2] = 0.	 ;

    xCvLnStr->num_points = nbPtSE+1 ;
  }

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :
  ex$message( msgnumb = VS_gI_EmptyMessage ) ;

  BSchangepar( &bsRC, BSTOLCHRDHT, savcht);

  if ( Xs     ) _FREE( Xs     ) ;
  if ( shGeom ) _FREE( shGeom ) ;
  if ( ctGeom ) _FREE( ctGeom ) ;
  if ( ptSE   ) _FREE( ptSE   ) ;
  if ( shPts  ) _FREE( shPts  ) ;
  if ( shPm   ) _FREE( shPm   ) ;
  if ( intPts ) _FREE( intPts ) ;

  if( nbIso && isoCv ) VSsxFreeIsoCv( nbIso, isoCv ) ;

  VSpsiFreeInfo(&psiInfo,1);

  __exitFunction ( name = "VSsxExpandShell", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

  End

  return sts ;

} /* VSsxExpandShell */
/*----------------------------------------------------------------------------*/
