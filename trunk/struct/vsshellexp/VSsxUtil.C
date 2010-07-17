/* $Id: VSsxUtil.C,v 1.3 2001/08/17 21:58:56 hans Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsshellexp/VSsxUtil.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSsxUtil.C,v $
 *      Revision 1.3  2001/08/17 21:58:56  hans
 *      Fix for TR's 4388 & 4798
 *
 *      Revision 1.2  2001/02/20 01:19:11  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:00  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  1999/06/01  21:34:48  pinnacle
 * (No comment)
 *
 * Revision 1.2  1998/09/14  18:50:22  pinnacle
 * Replaced: vsshellexp/VSsxUtil.C for:  by mdong for struct
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/03/01  14:59:14  pinnacle
 * TR179701791
 *
 * Revision 1.1  1997/05/08  14:03:58  pinnacle
 * Struct 250
 *
 * Revision 1.3  1996/05/07  17:10:42  pinnacle
 * Replaced: vsshellexp/VSsxUtil.C for:  by s240_int for struct
 *
 * Revision 1.2  1996/01/31  08:12:06  pinnacle
 * Replaced: vsshellexp/VSsxUtil.C for:  by svkadamb for struct
 *
 *
 * History:
 * MM/DD/YY    AUTHOR  DESCRIPTION
 * 09/26/97    ah      added header
 * 09/30/97    ah      TR179701791 Don't allocate 0 bytes
 * 03/01/98    ah      TR179701791 Major rewrite using psi routines
 * 08/28/98    Ming    TR179801427 Add a new function
 *		       VSsxMinInterPointBevelPlaneCurve();
 * 05/19/99    Ming    TR179900548
 * 08/18/2001  HF      TR's 4388 & 4798
 *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "madef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "msdef.h"
#include "emsdef.h"
#include "exmacros.h"

#include "igrdef.h"
#include "godef.h"
#include "igr.h"

#include "growner.h"
#include "grmacros.h"
#include "grdpbdef.h"

#include "vds.h"
#include "VDmsg.h"
#include "vdAPImacros.h"

#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "vsdbgmacros.h"

#include "VDtypedef.h"
#include "VSpsi.h"

#include "vsdpb.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>
/*
 * Includes of function prototypes.
 */
#include "bsalloccv.h"
#include "bsarclen.h"
#include "bsbx2.h"
#include "bsconstprcv.h"
#include "bscrossp.h"
#include "bscumdist.h"
#include "bscvarreval.h"
#include "bscveval.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bsmdistcvcv.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bspj_pt_sf.h"
#include "bspl_cv_int.h"
#include "bsprintbspc.h"
#include "bssfeval.h"
#include "macubepy.h"
#include "maidmx.h"

#include "EMSutlmacros.h"
#include "vsvecmxproto.h"

#define TOL_LENGTH_ALONG_Y	0.05	/* If Y-axis value of a point is < or */
					/* equal to this tolerance, it will   */
					/* be considered as equal to 0.       */

#define DELTA_X 		5000	/* Used with the length vector	      */
					/* tolerance to have more precision.  */

extern long	VSdrwMakeSfContourCompCurve() ;
extern void	VSsetGRids() ;

/*----------------------------------------------------------------------------*/
static int VSsxPtCmpZ( A, B )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif

void	*A,
	*B ;
{
	double	*a	= (double *) A,
		*b	= (double *) B ;
	int	rc ;

		if( a[2] < b[2] ) rc = -1 ;
	else	if( a[2] > b[2] ) rc =	1 ;
	else			  rc =	0 ;

	return rc ;

} /* VSsxPtCmpZ */

/*----------------------------------------------------------------------------*/
static int VSsxDblCmp( A, B )

#if defined(__STDC__) || defined(__cplusplus)
	const
#endif

void	*A,
	*B ;
{
	double	*a	= (double *) A,
		*b	= (double *) B ;
	int	rc ;

		if( *a < *b )	rc = -1 ;
	else	if( *a > *b )	rc =  1 ;
	else			rc =  0 ;

	return rc ;

} /* VSsxDblCmp */
/*----------------------------------------------------------------------------*/
static void VSsxRmDupXs( Xs, nbXs )

double	*Xs ;
int	*nbXs ;
{
  long		msg ;
  int		i, j ;
  double	previous, tollenvec ;

  BSEXTRACTPAR( &msg, BSTOLLENVEC, tollenvec ) ;

  qsort( Xs, *nbXs, sizeof *Xs, VSsxDblCmp ) ;

  previous = -MAXDOUBLE ;

  for( i=j=0; i<*nbXs; i++ )
    if( fabs( Xs[i] - previous ) > tollenvec )
      Xs[j++] = previous = Xs[i] ;

  *nbXs = j ;

} /* VSsxRmDupXs */
/*----------------------------------------------------------------------------*/
long VSsxGetContourGeometry( msg, shId, shEnv, ctGeom )

long			*msg ;
struct GRid		*shId ;
struct GRmd_env 	*shEnv ;
struct IGRbsp_curve	**ctGeom ;
{
	/*
	 * Given a shell ( shId, shEnv ), this function returns the geometry
	 * of its contour curve ( ctGeom ).
	 *
	 * Note :
	 * ======
	 *	'*ctGeom' is allocated and hence must be freed by the caller
	 *	with 'free( *ctGeom )' if not NULL.
	 */

	long			sts ;	 /* OM return code.	*/
	struct GRmd_env 	curEnv ; /* Current module env. */
	struct GRid		ctId ;	 /* Id of contour.	*/

        __enterFunction ( name = "VSsxGetContourGeometry" //, argfmt = "", args = ``
        );

	*ctGeom = NULL ;

	ctId.objid = NULL_OBJID ;

	/*
	 * Get current module env.
	 */
	sts = ex$get_cur_mod( id    = &curEnv._MD_ID,
			      osnum = &curEnv._MD_OS ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Get contour (composite curve) of shell.
	 */
	sts = VSdrwMakeSfContourCompCurve( msg,
					   shId,
					   shEnv,
					   &curEnv,
					   &ctId ) ;

	__CheckRC( sts, *msg, "VSdrwMakeSfContourCompCurve", wrapup ) ;

	/*
	 * Get geometry of contour.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= &ctId,
			       grobjEnv = &curEnv,
			       geometry = ctGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		vs$bulk_delete( grids  = &ctId,
				theEnv = &curEnv ) ;

        __exitFunction ( name = "VSsxGetContourGeometry", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		return sts ;

} /* VSsxGetContourGeometry */
/*----------------------------------------------------------------------------*/
long VSsxFindXsForIntersection( msg, ctGeom, xMin, xMax, Uite, nbXs, Xs )

long			*msg ;
struct IGRbsp_curve	*ctGeom ;
double			xMin,
			xMax,
			Uite ;
int			*nbXs ;
double			**Xs ;
{
  /*
   * Given the shell contour ( ctGeom ), an iteration value for  the U
   * parameter ( Uite ), this function returns the number ( nbXs ) and
   * the list of X-coordinate values ( Xs ) ( between a given minimum
   * value ( xMin ) and a given maximum value ( xMax ) ) for the
   * intersections between the shell and planes ( Point = (Xs[i],0,0)
   * Normal = (1,0,0) ).
   *
   * Note :
   * ======
   *	'*Xs' is allocated and hence must be freed by the caller
   *	with 'free( *Xs )'.
   */

  long			sts ;	/* OM return code.		      */
  BSrc			bsRC ;	/* BS return code.		      */
  int			i,	/* Loop index.			      */
                        numPt ; /* Number of points on input curve.   */
  double		*cvPt,	/* List of points on input curve.     */
                        *cvPm,	/* List of parameters of above points.*/
                        tollenvec ;
                                /* Minimum length of vector.	      */
  GRrange               range;

  SetProc( VSsxFindXsForIntersection ); Begin;

//    // Do this for more accuracy and more evenly distributed points along the contour...
//    Uite /= 10.0;

  __enterFunction ( name = "VSsxFindXsForIntersection" , argfmt = "xMin = %lg, xMax = %lg, Uite = %lg", args = `xMin, xMax, Uite` );

  *nbXs = 0 ;
  *Xs   = NULL ;

  numPt = 0 ;
  cvPt  = cvPm = NULL ;

  /*
   * See if the iteration value is <1.
   */
  if( Uite >= 1.0 ) vs$inv_arg() ;

  /*
   * Allocate memory for list of points and parameters.
   */
  numPt = (int) ceil( 1.0 / Uite ) +1 ;
  if( !( cvPt = _MALLOC( 3*(numPt+4), double ) ) ||
      !( cvPm = _MALLOC( numPt + 1,   double ) ) ) vs$mem_fail() ;

  /*
   * Find parameters of points.
   */
  cvPm[0]       = 0. ;
  cvPm[numPt-1] = 1. ;

  for( i=1; i<numPt-1; i++ ) cvPm[i] = cvPm[i-1] + (1.0 / (numPt-1)) ;

  /*
   * Find points on curve.
   */
  BScvarreval( &bsRC,
               ctGeom,
               cvPm,
               numPt,
               0,
               cvPt ) ;

  if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

  /*
   * Find box of curve.
   */
  sts = MAcubepy( msg, ctGeom, cvPt +3*numPt, cvPt +3*(numPt+1) ) ;

  __CheckRC( sts, *msg, "MAcubepy", wrapup ) ;

  memcpy(range, &cvPt[3*numPt], sizeof(GRrange));

  //printf("range ctGeom = %lf %lf %lf     %lf %lf %lf\n", range[0], range[1], range[2], range[3], range[4], range[5]);
  /*
   * For more precision at extremites, add the two above points with
   * delta X-coordinate value.
   *
   *	1) low[0]   + DELTA_X*tollenvec
   *	2) hight[0] - DELTA_X*tollenvec
   */
//    BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;

//    VSvccpy( cvPt +3*(numPt+2), cvPt +3*numPt     ) ;
//    VSvccpy( cvPt +3*(numPt+3), cvPt +3*(numPt+1) ) ;

//    cvPt[3*(numPt+2)] += DELTA_X*tollenvec ;
//    cvPt[3*(numPt+3)] -= DELTA_X*tollenvec ;

//    numPt += 4 ;

  /*
   * Find ouput list.
   */
  if( !( *Xs = _MALLOC( numPt+2, double ) ) ) vs$mem_fail() ;

  (*Xs)[0] = xMin ;
  (*Xs)[1] = xMax ;
  *nbXs    = 2 ;

  if (range[0] > xMin) (*Xs)[0] = range[0];
  if (range[3] < xMax) (*Xs)[1] = range[3];

  for( i=0; i<numPt; i++ )
    if( cvPt[3*i] > xMin && cvPt[3*i] < xMax )
      (*Xs)[(*nbXs)++] = cvPt[3*i] ;

//    for (i=0; i < *nbXs; i++)
//    {
//      printf(">>>>> Xs[%3d] = %16.6lf\n", i, (*Xs)[i]);
//    }

  // Round, leave first two alone (and NOT first & last)...
  {
#define VS_SH_ROUND 100.0
    IGRdouble xd, margin, rnd = VS_SH_ROUND;
    IGRint    xi;

    margin = 0.05 * fabs(range[3] - range[0]);
    //for(i = 1; i < (numPt-1); i++)
    for(i = 2; i < *nbXs; i++)
    {
      rnd = VS_SH_ROUND;
      // This is done to get a more accurate representation
      // at the back and front of the hull...
      if ( fabs(xMax - (*Xs)[i]) < margin ||
           fabs(xMin - (*Xs)[i]) < margin ) rnd /= 10.0;
      xd = ((*Xs)[i] + (rnd / 2.0)) / rnd;
      xi = (IGRint)xd;
      xd = xi * rnd;
      (*Xs)[i] = xd;
    }
  }
  VSsxRmDupXs( *Xs, nbXs ) ;
  if( !( *Xs = _REALLOC( *Xs, *nbXs + 1, double ) ) )
  {
    *nbXs = 0 ;
    vs$mem_fail() ;
  }
//    for (i=0; i < *nbXs; i++)
//    {
//      printf("<<<<< Xs[%3d] = %16.6lf\n", i, (*Xs)[i]);
//    }

  __DBGpr_int( "Count of Xs", *nbXs ) ;

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :

  if (cvPt) _FREE( cvPt ) ;
  if (cvPm) _FREE( cvPm ) ;

  __exitFunction ( name = "VSsxFindXsForIntersection", argfmt = "sts = %d, msg = %#x, bsRC = %d, nbXs = %d, numPt = %d",
                   args = `sts, *msg, bsRC, *nbXs, numPt` );

  End

  return sts ;

} /* VSsxFindXsForIntersection */
/*----------------------------------------------------------------------------*/
void VSsxFreeIsoCv( nbIso, isoCv )

int			nbIso ;
struct IGRbsp_curve	*isoCv[] ;
{
  BSrc	bsRC ;
  int	i ;

  for( i=0; i<nbIso; i++ )
    if( isoCv[i] ) BSfreecv( &bsRC, isoCv[i] ) ;

  if (isoCv) _FREE( isoCv ) ;

} /* VSsxFreeIsoCv */
/*----------------------------------------------------------------------------*/
long VSsxFindIsoCurvesForIntersection( msg, shGeom, iteration, nbIso, isoCv )

long			*msg ;
struct IGRbsp_surface	*shGeom ;
double			iteration ;
int			*nbIso ;
struct IGRbsp_curve	**isoCv[] ;
{
	/*
	 * Given a shell ( shGeom ), an iteration value ( iteration ), this
	 * function returns the number ( nbIso ) and the ordered list of
	 * iso-parametric curves ( isoCv ) "parallel" to the X-axis.
	 *
	 * Notes :
	 * =======
	 *	- The first iso-parametric curve is near the X-axis.
	 *
	 *	- '*isoCv' is allocated and hence must be freed by the caller
	 *	  with 'VSsxFreeIsoCv( *nbIso, *isoCv )'.
	 */

	long			sts ;	    /* OM return code.		      */
	BSrc			bsRC ;	    /* BS return code.		      */
	int			i,	    /* Loop index.		      */
				parAlU,     /* Shell "parallel" to X-axis     */
					    /* along u ( TRUE / FALSE ).      */
				uv0nearX ;  /* Is parameter (u or v) = 0. is  */
					    /* near the X-axis ?	      */
	double			Pu00v05[3], /* Point at u=0.  v=0.5	      */
				Pu10v05[3], /* Point at u=1.  v=0.5	      */
				Pu05v00[3], /* Point at u=0.5 v=0.	      */
				Pu05v10[3], /* Point at u=0.5 v=1.	      */
				duz,	    /* Delta U z.		      */
				dvz,	    /* Delta V z.		      */
				uv ;	    /* Parameter (u or v) to get      */
					    /* iso-parametric curves.	      */
	short			opt,	    /* Direction option.	      */
				tst_plan ;  /* Test planarity of iso ?	      */

	SetProc( VSsxFindIsoCurvesForIntersection ); Begin

  __enterFunction ( name = "VSsxFindIsoCurvesForIntersection" //, argfmt = "", args = ``
  );

  *nbIso = 0 ;
  *isoCv = NULL ;

  /*
   * See if the iteration value is <1.
   */
  if( iteration >= 1.0 ) vs$inv_arg() ;

  /*
   * See if the shell goes up or down along u.
   */
  BSsfeval( shGeom, 0.0, 0.5, 0, (IGRpoint *) Pu00v05, &bsRC ) ;
  BSsfeval( shGeom, 1.0, 0.5, 0, (IGRpoint *) Pu10v05, &bsRC ) ;
  BSsfeval( shGeom, 0.5, 0.0, 0, (IGRpoint *) Pu05v00, &bsRC ) ;
  BSsfeval( shGeom, 0.5, 1.0, 0, (IGRpoint *) Pu05v10, &bsRC ) ;

  duz = fabs( Pu10v05[2] - Pu00v05[2] ) ;
  dvz = fabs( Pu05v10[2] - Pu05v00[2] ) ;

  if( duz < dvz ) parAlU = TRUE ;
  else		  parAlU = FALSE ;

  __DBGpr_int( "Parallel along U ?", parAlU ) ;

  /*
   * See if parameter (u or v) = 0. is near X-axis.
   */
  uv0nearX = parAlU ? ( Pu05v00[2] < Pu05v10[2] ? TRUE : FALSE ) :
                      ( Pu00v05[2] < Pu10v05[2] ? TRUE : FALSE ) ;

  __DBGpr_int( "Parameter (u or v) = 0 near X-axis ?", uv0nearX ) ;

  /*
   * Allocate memory for output iso-parametric curves.
   */
  *nbIso = (int) ceil( 1.0 / iteration ) +1 ;
  if( !( *isoCv = _CALLOC( *nbIso, struct IGRbsp_curve * ) ) )
    vs$mem_fail() ;

  /*
   * Find iso-parametric curves.
   */
  __DBGpr_int( "Count of iso-parametric curves", *nbIso ) ;

  opt       = parAlU ? 2 : 1 ;
  tst_plan  = FALSE ;
  uv        = uv0nearX ? 0. : 1. ;
  iteration = uv0nearX ? iteration : -iteration ;

  if (1)
  {
#include "bsprintbspc.h"
    char      *name   = NULL;
    IGRboolean option = FALSE;
    FILE      *fp;
    if (VDcomment)
    {
      fp = fopen("iso_curves", "w");
    }

    for( i=0; i<*nbIso; i++ )
    {
      if( uv0nearX  && uv > 1. ) uv = 1. ;
      if( !uv0nearX && uv < 0. ) uv = 0. ;

      BSalloccv( parAlU ? shGeom->u_order : shGeom->v_order,
                 parAlU ? shGeom->u_num_poles : shGeom->v_num_poles,
                 shGeom->rational,
                 shGeom->num_boundaries,
                 *isoCv +i,
                 &bsRC ) ;

      if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

      BSconstprcv( &bsRC,
                   shGeom,
                   &opt,
                   &uv,
                   &tst_plan,
                   (*isoCv)[i] ) ;
      if (VDcomment)
      {
        BSprintbspc(fp, name, (*isoCv)[i], option);
      }

      if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

      uv += iteration ;
    }
    if (VDcomment)
    {
      fclose(fp);
    }
  }

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :
  if( !( sts & 1 & *msg ) )
  {
    VSsxFreeIsoCv( *nbIso, *isoCv ) ;
    *nbIso = 0 ;
    *isoCv = NULL ;
  }

  __exitFunction ( name = "VSsxFindIsoCurvesForIntersection", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

  End

  return sts ;

} /* VSsxFindIsoCurvesForIntersection */
/*----------------------------------------------------------------------------*/
long VSsxIntersectionPlaneIsoCv( msg, nbIso, isoCv, XaxisVal, nbPt, pts )

long			*msg ;
int			nbIso ;
struct IGRbsp_curve	*isoCv[] ;
double			XaxisVal ;
int			*nbPt ;
double			**pts ;
{
	/*
	 * Given an ordered list of iso-parametric curves ( nbIso, isoCv ),
	 * an X-axis value ( XaxisVal ), this function intersects the
	 * iso-parametric curves and the plane ( Point = (XaxisVal,0,0)
	 * Normal = (1,0,0) ). It returns the number ( nbPt ) and the
	 * intersection points ( pts ).
	 *
	 * Note :
	 * ======
	 *	'*pts' is allocated and hence must be freed by the caller
	 *	with 'free( *pts )'.
	 */

	long			sts ;	  /* OM return code.		      */
	BSrc			bsRC ;	  /* BS return code.		      */
	int			i,	  /* Loop index.		      */
				j,	  /* Loop index.		      */
				n_int,	  /* Number of intersection points    */
					  /* Between an iso-parametric curve  */
					  /* and plane. 		      */
				n_seg ;   /* Number of overlaps.	      */
	double			nmPl[3],  /* Normal of plane.		      */
				ptPl[3],  /* Point of plane.		      */
				*int_pts, /* Intersection points between an   */
					  /* iso-parametric curve and plane.  */
				*u,	  /* Parameters of intersection pts.  */
				*a,	  /* Start parameters of overlaps.    */
				*b ;	  /* End parameters of overlaps.      */
	int			sortPts,  /* Should sort the intersections    */
					  /* points ? ( TRUE / FALSE )	      */
				nbPtAlloc;/* Number of intersection points    */
					  /* already malloced.		      */

        __enterFunction ( name = "VSsxIntersectionPlaneIsoCv" //, argfmt = "", args = ``
        );

	*nbPt	= 0 ;
	*pts	= NULL ;

	n_int	= n_seg = 0 ;
	int_pts = u = a = b = NULL ;

	sortPts = FALSE ;

	/*
	 * Allocate memory for intersection between an iso-parametric curve
	 * and the plane.
	 */
	if( !( int_pts = _MALLOC( 3*isoCv[0]->num_poles, double ) ) ||
	    !( u       = _MALLOC( isoCv[0]->num_poles,	 double ) ) ||
	    !( a       = _MALLOC( isoCv[0]->num_poles,	 double ) ) ||
	    !( b       = _MALLOC( isoCv[0]->num_poles,	 double ) ) )
		vs$mem_fail() ;

	/*
	 * Allocate memory for output points.
	 */
	if( !( *pts = _MALLOC( 3*nbIso, double ) ) ) vs$mem_fail() ;
	nbPtAlloc = nbIso ;

	/*
	 * Intersect iso-parametric curves and plane.
	 */
	ptPl[0] = XaxisVal	; ptPl[1] = ptPl[2] = 0. ;
	nmPl[0] = 1.		; nmPl[1] = nmPl[2] = 0. ;

	for( i=0; i<nbIso; i++ )
        {
		BSpl_cv_int( &bsRC,
			     isoCv[i],
			     ptPl,
			     nmPl,
			     &n_int,
			     int_pts,
			     u,
			     &n_seg,
			     a,
			     b ) ;

                //__printf ( "BSpl_cv_int(%d) bsRC = %d, n_int = %d, n_seg = %d", `i, bsRC, n_int, n_seg` );

		if( BSERROR( bsRC ) || !n_int ) continue ;

		/*
		 * EF 03/29/94 : Remove duplicate point.
		 */
		if( *nbPt && VSeqPoints( int_pts, *pts + 3*((*nbPt)-1) ) )
			continue ;

		/*
		 * EF 07/06/94 : For multiple intersections with one iso curve.
		 *
		 * A iso curve can be like this ( especially on the back ) :
		 *
		 *	\  p1
		 *	 \...
		 *	     \
		 *	     |			Z
		 *	    /			^
		 *	   .p2			|
		 *	  |			---> X
		 *	  |
		 *	   .p3
		 *	    \
		 *	     ------------   -> Orientation of the iso curve.
		 *
		 *	   |
		 *
		 *	XaxisVal
		 *
		 * The number of intersections is 3 ( p1,p2,p3 ), but in fact
		 * we take only p1 ( is the first intersection with respect
		 * to the orientation of the iso curve ).
		 * As result, we have the intersection points which is not
		 * ordered along Z axis.
		 * So, we take all the intersection points with the iso curve,
		 * and we have to ordered the output intersection points along
		 * Z axis.
		 *
		 * Old code :
		 * ==========
		 *
		 * VSvccpy( *pts + 3*((*nbPt)++), int_pts ) ;
		 */
		if( n_int > 1 ) {
			int	NbPts ;

			NbPts	= (nbPtAlloc + n_int -1) * 3 ;
			sortPts = TRUE ;

			if( !( *pts = _REALLOC(	*pts, NbPts + 1, double ) ) ){
				vs$mem_fail() ;
			}

			for( j=0; j<n_int; j++ )
				VSvccpy( *pts + 3*((*nbPt)++), int_pts + 3*j ) ;

			nbPtAlloc += n_int -1 ;

		} else {
			VSvccpy( *pts + 3*((*nbPt)++), int_pts ) ;
		}
	}

	if( sortPts )
        {
		__DBGpr_com( "Sort intersection points" ) ;

		qsort( *pts, *nbPt, 3 * sizeof( double ), VSsxPtCmpZ ) ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) )
                {
                  if (*pts)
                  {
                    _FREE( *pts );
                    *pts  = NULL ;
                    *nbPt = 0 ;
                  }
		}

		if (int_pts) _FREE( int_pts ) ;
		if (u) _FREE( u       ) ;
		if (a) _FREE( a       ) ;
		if (b) _FREE( b       ) ;

        __exitFunction ( name = "VSsxIntersectionPlaneIsoCv", argfmt = "sts = %d, msg = %#x, *nbPt = %d",
                         args = `sts, *msg, *nbPt` );

		return sts ;

} /* VSsxIntersectionPlaneIsoCv */
/*----------------------------------------------------------------------------*/
long VSsxIntersectionPlaneCurve( msg, cvGeom, XaxisVal, nbPt, pts, pm )

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
double			XaxisVal ;
int			*nbPt ;
double			**pts ;
double			**pm ;
{
  /*
   * Given a curve to expand ( cvGeom ), an X-axis value ( XaxisVal ),
   * this function intersects the curve and the plane
   * ( Point = (XaxisVal,0,0) Normal = (1,0,0) ). It return the number
   * ( nbPt ), the intersection points ( pts ) and the corresponding
   * parameters ( pm ) on the curve.
   *
   * Note :
   * ======
   *	'*pts' and '*pm' are allocated and hence must be freed by the
   *	caller with 'free( *pts )' and 'free( *pm )'.
   */

  long			sts ;	  /* OM return code.		      */
  BSrc			bsRC ;	  /* BS return code.		      */
  int			i,	  /* Loop index.		      */
			n_int,	  /* Number of intersection points    */
				  /* Between curve and plane.	      */
			n_seg ;   /* Number of overlaps.	      */
  double		nmPl[3],  /* Normal of plane.		      */
			ptPl[3],  /* Point of plane.		      */
			*int_pts, /* Intersection points between      */
				  /*  curve and plane.		      */
			*u,	  /* Parameters of intersection pts.  */
			*a,	  /* Start parameters of overlaps.    */
			*b ;	  /* End parameters of overlaps.      */
  double                midPt[3];

  __enterFunction ( name = "VSsxIntersectionPlaneCurve" //, argfmt = "", args = ``
  );

  *nbPt	= 0 ;
  *pts	= NULL ;
  *pm	= NULL ;

  n_int	= n_seg = 0 ;
  int_pts = u = a = b = NULL ;

  /*
   * Allocate memory for intersection between curve and plane.
   */
  if( !( int_pts = _MALLOC( 3*cvGeom->num_poles, double ) ) ||
      !( u       = _MALLOC( cvGeom->num_poles,   double ) ) ||
      !( a       = _MALLOC( cvGeom->num_poles,   double ) ) ||
      !( b       = _MALLOC( cvGeom->num_poles,   double ) ) )
    vs$mem_fail() ;

  /*
   * Intersect curve and plane.
   */
  ptPl[0] = XaxisVal	; ptPl[1] = ptPl[2] = 0. ;
  nmPl[0] = 1.		; nmPl[1] = nmPl[2] = 0. ;

  BSpl_cv_int( &bsRC,
               cvGeom,
               ptPl,
               nmPl,
               &n_int,
               int_pts,
               u,
               &n_seg,
               a,
               b ) ;

  if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

  /*
   * Output intersection points.
   */
  if( n_int )
  {
    if( !( *pts = _MALLOC( 3*n_int, double ) ) ||
        !( *pm  = _MALLOC( n_int,   double ) ) ) vs$mem_fail() ;

    for( i=0; i<n_int; i++ )
    {
      VSvccpy( *pts +3*i, int_pts +3*i ) ;
      (*pm)[i] = u[i] ;
    }

    *nbPt = n_int ;
  }

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :
  if( !( sts & 1 & *msg ) )
  {
    if (*pts) { _FREE( *pts ) ; *pts = NULL ;}
    if (*pm ) { _FREE( *pm  ) ; *pm  = NULL ;}
    *nbPt = 0 ;
  }

  if (int_pts) _FREE( int_pts ) ;
  if (u) _FREE( u       ) ;
  if (a) _FREE( a       ) ;
  if (b) _FREE( b       ) ;

  __exitFunction ( name = "VSsxIntersectionPlaneCurve", argfmt = "sts = %d, msg = %#x, bsRC = %d, n_int = %d, n_seg = %d",
                   args = `sts, *msg, bsRC, n_int, n_seg` );

  return sts ;

} /* VSsxIntersectionPlaneCurve */
/*----------------------------------------------------------------------------*/
long VSsxFindPointsOntoShellContour( msg, ctGeom, XaxisVal, nbPt, shPts, shPm )

long			*msg ;
struct IGRbsp_curve	*ctGeom ;
double			XaxisVal ;
int			*nbPt ;
double			**shPts ;
double			**shPm ;
{
  /*
   * Given the shell contour ( ctGeom ), a X-axis value ( XaxisVal ), this
   * function intersects the shell contour and the plane
   * ( Point = (XaxisVal,0,0) Normal = (1,0,0) ). It return the number
   * ( nbPt ), an ordered list of intersection points ( shPts ) and the
   * corresponding parameters ( shPm ) on the shell contour. The first
   * point is the point at minimum Z-axis value (#0), the last point is
   * the point at maximum  Z-axis value (#3), the other points are points
   * where there are no intersections between plane and shell (#1,#2),
   * if any ( Those points are ordered along Z-axis ).
   *
   *			pt #3
   *			  |
   *			  v
   *		----------*----   <- Shell contour.
   *			      /
   *			     /
   *			    /
   *			   /
   *			  *    <- pt #2
   *			 /
   *			 \
   *			  *    <- pt #1
   *			   \
   *  Z			   /
   *  ^		----------*    <- pt #0
   *  |
   *  -> X
   *			  |
   *
   *		       X-value
   *
   *
   * Note :
   * ======
   *	'*shPts' and '*shPm' are allocated and hence must be freed by
   *	the caller with 'free( *shPts )' and 'free( *shPm )'.
   */

  long			sts ;	  /* OM return code.		      */
  int			i,	  /* Loop index.		      */
                        j,	  /* Loop index.		      */
                        n_int,	  /* Number of intersections between  */
                                  /*  plane and shell contour.	      */
                        n_pts ;   /* Number of output points.	      */
  double		*i_pts,   /* Intersection points between      */
				  /*  plane and shell contour.	      */
                        *i_pm,	  /* Parameters of intersection pts.  */
                        tmp_pm,   /* Local parameter.		      */
                        tmp_pt[3];/* Local point.		      */

  __enterFunction ( name = "VSsxFindPointsOntoShellContour" , argfmt = "<<<<<<<<<<<<<<<<<<<<<< XaxisVal = %lf >>>>>>>>>>>>>>>>>>>>>>",
                    args = `XaxisVal` );

  *nbPt  = 0 ;
  *shPts = NULL ;
  *shPm  = NULL ;

  n_int  = n_pts = 0 ;
  i_pts  = i_pm  = NULL ;

  /*
   * Intersect plane and shell contour.
   */
  sts = VSsxIntersectionPlaneCurve( msg,
                                    ctGeom,
                                    XaxisVal,
                                    &n_int,
                                    &i_pts,
                                    &i_pm ) ;
  __CheckRC( sts, *msg, "VSsxIntersectionPlaneCurve", wrapup ) ;

  if( !n_int ) goto wrapup ;

  /*
   * EF 03/29/94 : If the number of intersection points is 1. This
   *		 point is valid only if it's near the extremites
   *		 of the shell.
   */
  if( n_int == 1 )
  {
    double	tollenvec, low[3], high[3] ;

    BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;

    sts = MAcubepy( msg, ctGeom, low, high ) ;
    __CheckRC( sts, *msg, "MAcubepy", wrapup ) ;

    low[0]  += DELTA_X*tollenvec ;
    high[0] -= DELTA_X*tollenvec ;

    if( i_pts[0] > low[0] && i_pts[0] < high[0] ) goto wrapup ;
  }

  /*
   * Sort and remove equal points along Z-axis.
   */
  for( i=0; i<n_int; i++ )
  {
    for( j=i; j<n_int; j++ )
      /* TR179900548 by Ming */
      if( (i_pts[3*j +1] < i_pts[3*n_pts +1]) )
      {
        tmp_pm	    = i_pm[j] ;
        i_pm[j]     = i_pm[n_pts] ;
        i_pm[n_pts] = tmp_pm ;

        VSvccpy( tmp_pt,         i_pts +3*j	 ) ;
        VSvccpy( i_pts +3*j,     i_pts +3*n_pts  ) ;
        VSvccpy( i_pts +3*n_pts, tmp_pt 	 ) ;
      }

    if( !n_pts ||
        !VSeqPoints( i_pts +3*n_pts, i_pts +3*(n_pts-1) ) )
      n_pts++ ;
    else
      i_pts[3*n_pts +2] = MAXDOUBLE ;
  }

  n_int = n_pts ;

  /*
   * If number of intersection points is <1, no points are valid.
   */
  if( n_int < 1 ) goto wrapup ;

  /*
   * Allocate memory for output points.
   */
  if( !( *shPts = _MALLOC( 3*n_int, double ) ) ||
      !( *shPm  = _MALLOC( n_int,   double ) ) ) vs$mem_fail() ;

  /*
   * Find output points.
   */
  n_pts = 1 ;

  /*
   * Point at minimum Z-axis value.
   */
  VSvccpy( *shPts, i_pts ) ;
  (*shPm)[0] = i_pm[0] ;

  if( n_int == 1 )
  {
    *nbPt = n_pts ;
    goto wrapup ;
  }

  /*
   * Points where there are no intersections.
   */
  for( i=1; i<n_int-1; i++ )
    if( fabs( i_pts[3*i +1] ) <= TOL_LENGTH_ALONG_Y )
    {
      VSvccpy( *shPts +3*n_pts, i_pts +3*i ) ;
      (*shPm)[n_pts] = i_pm[i] ;
      n_pts++ ;
    }

  /*
   * If number of above points is odd, reject those points.
   * Find new point at minimum Z-axis value which should be
   * at minimum Y-axis value.
   */
  if( (n_pts-1) & 1 ) n_pts = 1 ;

  /*
   * Point at maximum Z-axis value.
   */
  VSvccpy( *shPts +3*n_pts, i_pts +3*(n_int-1) ) ;
  (*shPm)[n_pts] = i_pm[n_int-1] ;
  n_pts++ ;

  /*
   * KLUDGE : In case the number of output points is equal
   * to 2, and the number of intersection is > 2, the point
   * at minimum Z-axis value should be also at minimum Y-axis
   * value.
   */
  if( n_pts == 2 && n_int > 2 )
  {
    for( i=1; i<n_int-1; i++ )
    {
      if( (*shPts)[1] > i_pts[3*i +1] )
      {
        VSvccpy( *shPts, i_pts + 3*i ) ;
        (*shPm)[0] = i_pm[i] ;
      }
    }
  }

  *nbPt = n_pts ;

  if (n_pts > 1)    // HF: 08/01/2001
  {
    int     k = 0;
    double *PtsPm = NULL;

    if( !( PtsPm = _MALLOC( 4 * n_pts, double ) ) ) vs$mem_fail() ;

    for( i=0, j=0; i < 4 * n_pts; i+=4, j++ )
    {
      PtsPm[i+3] = (*shPm)[j];
      memcpy(&PtsPm[i], &(*shPts)[3*j], 3 * sizeof(double));
    }
    /*
     * Sort points along Z-axis from zMin to zMax...
     */
    qsort( PtsPm, n_pts, 4*sizeof( double ), VSsxPtCmpZ ) ;

    for( i=0, j=0; i < 4 * n_pts; i+=4, j++ )
    {
      (*shPm)[j] = PtsPm[i+3];
      memcpy(&(*shPts)[3*j], &PtsPm[i], 3 * sizeof(double));
    }
    if (PtsPm) _FREE(PtsPm);
  }

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :
  if( !( sts & 1 & *msg ) )
  {
    if (*shPts) { _FREE( *shPts ) ; *shPts = NULL ;}
    if (*shPm ) { _FREE( *shPm  ) ; *shPm  = NULL ;}
    *nbPt = 0 ;
  }

  if (i_pts) _FREE( i_pts ) ;
  if (i_pm ) _FREE( i_pm  ) ;

  __exitFunction ( name = "VSsxFindPointsOntoShellContour", argfmt = "sts = %d, msg = %#x, *nbPt = %d", args = `sts, *msg, n_pts` );

  return sts ;

} /* VSsxFindPointsOntoShellContour */

/* --------------------------
 * Find index of nearest point
 */
IGRint VSsxGetSecIndex(
  IGRint    nbPt,
  IGRdouble *secPts,
  IGRdouble *pt)
{
  IGRint    i,index;
  IGRdouble dist,minDist;
  BSrc      rc;

  __enterFunction ( name = "VSsxGetSecIndex" //, argfmt = "", args = ``
  );

  minDist = 1000000.0 * 1000000.0 * 1000000.0;
  index = -1;

  for(i = 0; i < nbPt; i++)
  {
    dist = BSdistptpt(&rc,pt,&secPts[i*3]);

    if (dist < minDist)
    {
      minDist = dist;
      index = i;
    }
  }

  if (index == -1)
  {
    printf("Problem getting interesction index\n");
  }

  __exitFunction ( name = "VSsxGetSecIndex", argfmt = "index = %d", args = `index` );

  return index;
}

IGRdouble VSsxLengthPt1Pt2X(
  IGRlong   *msg,
  IGRint     nbPt,
  IGRdouble *secPts,
  IGRdouble *pt1,
  IGRdouble *pt2
)
{
  IGRlong   i1,i2,i;
  IGRdouble len = 0.0;
  BSrc      rc;

  __enterFunction ( name = "VSsxLengthPt1Pt2X" //, argfmt = "", args = ``
  );
/*
  printf("**********************\n");
  for(i = 0; i < nbPt; i++) {
    printf("%3d %8.2f %8.2f %8.2f\n",i,
      secPts[(i*3)+0],
      secPts[(i*3)+1],
      secPts[(i*3)+2]
    );
  }
*/
  i1 = VSsxGetSecIndex(nbPt,secPts,pt1);
  i2 = VSsxGetSecIndex(nbPt,secPts,pt2);

  // printf("I1 I2 %3d %3d\n",i1,i2);

  if (secPts[(i1*3)+2] < pt1[2]) {
    i1 += 1;
  }

  if (secPts[(i2*3)+2] > pt2[2]) {
    if (i2) i2 -= 1;
  }

  if (i1 == i2) {
    len = BSdistptpts(&rc,pt1,pt2);
    goto wrapup;
  }

  i = i2 - i1 + 1;
  if (i == 2) {
    len = BSdistptpt(&rc,pt1,pt2);
    goto wrapup;
  }

  BScumdist(&rc,&i,&secPts[3*i1],NULL,&len);

  // printf("X %d %d %.3f\n",i,i1,len);

  len += BSdistptpt(&rc,pt1,&secPts[3*i1]);
  len += BSdistptpt(&rc,pt2,&secPts[3*i2]);

wrapup:
/*
  printf("Calc Dist %10.3f %10.3f %10.3f\n",pt1[0],pt1[1],pt1[2]);
  printf("     Dist %10.3f %10.3f %10.3f\n",pt2[0],pt2[1],pt2[2]);
  printf("      Len %10.3f %3d %3d %3d\n",len,i1,i2,i2-i1);
*/

  *msg = MSSUCC;

  __exitFunction ( name = "VSsxLengthPt1Pt2X", argfmt = "len = %lg, msg = %#x", args = `len, *msg` );

  return len;
}

IGRdouble VSsxLengthPt1Pt2Y(
  IGRstat   *msg,
  IGRint     nbPt,
  IGRdouble *secPts,
  IGRdouble *pt1,
  IGRdouble *pt2,
  VSpsiInfo *info
)
{
  TGRbsp_curve *bsp;
  int       i;
  IGRdouble arcLen[2] = { 0.0 };
  IGRdouble par0,par1,parM;

  IGRboolean arcBool;

  BSrc rc;
  struct IGRbsp_curve        *curve1 = NULL;
  struct IGRbsp_curve        *curve2 = NULL;
  IGRint                      num    = 0;
  IGRdouble                  *prm1   = NULL;
  IGRdouble                  *prm2   = NULL;
  IGRpoint                   *pnt1   = NULL;
  IGRpoint                   *pnt2   = NULL;
  IGRdouble                   dist   = 0.0;

  struct
  {
    IGRint i;
    IGRdouble par;
  } p1,p2;

  IGRdouble length = 0.0;

  __enterFunction ( name = "VSsxLengthPt1Pt2Y" , argfmt = "info->crv.cnt = %d", args = `info->crv.cnt` );

  // Maintain Compatibility
  *msg = MSSUCC;
  if (nbPt);
  if (secPts);

  // Make sure got at least 1 curve
  if (info->crv.cnt < 1) goto wrapup;

  // Get curve parameters
  VSpsiGetCurve(info, pt1, &p1.i, &p1.par);
  VSpsiGetCurve(info, pt2, &p2.i, &p2.par);

  __printf("Par %d,%lf  %d,%lf", `p1.i, p1.par, p2.i, p2.par`);

  // HF: 08/10/2001 - This really is the lazy way out...
//    if (p1.i != p2.i)
//    {
//      length = BSdistptpt(&rc,pt1,pt2);
//      goto wrapup;
//    }

  if (p1.i == p2.i)
  {
    par0 = p1.par;
    par1 = p2.par;
    parM = (par0 + par1) / 2.0;
    bsp  = info->crv.bsps[p1.i];
    BSarclen(&rc, &arcBool, bsp, &par0, &par1, &parM, arcLen);

    length = arcLen[0];
  }
  else if (info->crv.cnt == 2)
  {
    curve1 = info->crv.bsps[0];
    curve2 = info->crv.bsps[1];
    BSmdistcvcv( curve1, curve2, &num, &prm1, &prm2, &pnt1, &pnt2, &dist, &rc);
    if( BSERROR( rc ) ) goto wrapup ;

    par0 = p1.par;
    par1 = prm1[0];
    parM = (par0 + par1) / 2.0;
    BSarclen(&rc, &arcBool, curve1, &par0, &par1, &parM, arcLen);
    if( BSERROR( rc ) ) goto wrapup ;

    par0 = p2.par;
    par1 = prm2[0];
    parM = (par0 + par1) / 2.0;
    BSarclen(&rc, &arcBool, curve2, &par0, &par1, &parM, &arcLen[1]);
    if( BSERROR( rc ) ) goto wrapup ;

    length = arcLen[0] + arcLen[1] + dist;

//      for (i=0; i < num; i++)
//      {
//        printf("BSmdistcvcv num[%d] prm1 = %lf, pnt1 = %lf %lf %lf, dist = %lf\n", i, prm1[i], pnt1[i][0], pnt1[i][1], pnt1[i][2], dist);
//        printf("BSmdistcvcv        prm2 = %lf, pnt2 = %lf %lf %lf\n\n", prm2[i], pnt2[i][0], pnt2[i][1], pnt2[i][2]);
//      }
  }
  else
  {
    length = BSdistptpt(&rc, pt1, pt2);
    goto wrapup;
  }
wrapup:

  if (prm1) { free (prm1); prm1 = NULL; }
  if (prm2) { free (prm2); prm2 = NULL; }
  if (pnt1) { free (pnt1); pnt1 = NULL; }
  if (pnt2) { free (pnt2); pnt2 = NULL; }

  if (info->crv.cnt != 2)
  {
    __exitFunction ( name = "VSsxLengthPt1Pt2Y", argfmt = "msg = %#x, length = %lg", args = `*msg, length` );
  }
  else
  {
    __exitFunction ( name = "VSsxLengthPt1Pt2Y", argfmt = "msg = %#x, length = %lg, arcLen[] = %lg %lg, dist = %lg",
                     args = `*msg, length, arcLen[0], arcLen[1], dist` );
  }
  return length;
}

/*----------------------------------------------------------------------------*/
double VSsxLengthPt1Pt2( msg, nbPt, secPts, pt1, pt2)

long		*msg ;
int		nbPt ;
double		*secPts,
		*pt1,
		*pt2 ;
{
	/*
	 * Given two points ( pt1, pt2 ), the number ( nbPt ) and the list of
	 * points ( secPts ) which represent the section of the shell, this
	 * function returns the length of the section between point #1 and
	 * point #2.
	 *
	 * Note :
	 * ======
	 *	pt2[2] should be superior or equal to pt1[2].
	 */

	BSrc			bsRC ;	/* BS return code.		      */
	int			iStart, /* Index of first point where	      */
					/*  Z-coordinate is > to pt1[2].      */
				iEnd ;	/* Index of last point where	      */
					/*  Z-coordinate is < to pt2[2].      */
	long			num ;	/* Number of points to compute	      */
					/*  cumulated distance. 	      */
	double			length ;/* Length between point #1 and	      */
					/*  point #2.			      */

        __enterFunction ( name = "VSsxLengthPt1Pt2" //, argfmt = "", args = ``
        );

#define PT_SEC_BEFORE( pt, index ) (\
	( ( secPts[3*((index)+1)+0] - secPts[3*(index)+0] ) *\
	  ( (pt)[0]		    - secPts[3*(index)+0] ) +\
	  ( secPts[3*((index)+1)+1] - secPts[3*(index)+1] ) *\
	  ( (pt)[1]		    - secPts[3*(index)+1] ) +\
	  ( secPts[3*((index)+1)+2] - secPts[3*(index)+2] ) *\
	  ( (pt)[2]		    - secPts[3*(index)+2] ) )\
	  >= 0. ? TRUE : FALSE )

	iStart = iEnd = 0 ;
	length = 0. ;

	*msg = MSSUCC ;

	/*
	 * If point #1 and point #2 are equal, the length is 0.
	 */
	if( VSeqPoints( pt1, pt2 ) ) goto wrapup ;

	/*
	 * If Z-coordinate of point #1 is equal to Z-coordinate of point #2,
	 * the length is the distance between point #1 and point #2.
	 */
	if( VSzeroDist( fabs( pt1[2] - pt2[2] ) ) ) {
		length = BSdistptpt( &bsRC, pt1, pt2 ) ;
		goto wrapup ;
	}

	/*
	 * Find iStart and iEnd.
	 * EF 03/29/94 : If point #1 is equal to the first point of the section
	 *		 and point #2 is equal to the last point of the section
	 *		 then the length is the cumulated distance between the
	 *		 first and the last point of the section.
	 */
	if( VSeqPoints( pt1, secPts )			&&
	    VSeqPoints( pt2, secPts +3*(nbPt-1) )	) {
		iStart = 0 ;
		iEnd   = nbPt -1 ;
	} else {

		while( iStart < nbPt -1 && PT_SEC_BEFORE( pt1, iStart ) )
			iStart++ ;

		if( iStart == nbPt -1 ) goto wrapup ;

		iEnd = iStart ;
		while( iEnd < nbPt - 1 && PT_SEC_BEFORE( pt2, iEnd ) )
			iEnd++ ;

		iEnd-- ;
	}

	if( iEnd < iStart ) goto wrapup ;

	/*
	 * Compute cumulated distance between point at iStart and point at
	 * iEnd.
	 */
	num = iEnd - iStart + 1 ;

	BScumdist( &bsRC,
		   &num,
		   secPts +3*iStart,
		   NULL,
		   &length ) ;
  //printf("Y %d %d %.3f\n",num,iStart,length);

	if( BSERROR( bsRC ) ) {
		length = 0. ;
		*msg   = EMS_E_BSerror ;
		goto wrapup ;
	}

	/*
	 * Add distance from point pt1 to point at iStart.
	 */
	length += BSdistptpt( &bsRC, pt1, secPts +3*iStart ) ;

	/*
	 * Add distance from point at iEnd to pt2.
	 */
	length += BSdistptpt( &bsRC, secPts +3*iEnd, pt2 ) ;

	wrapup :
#ifdef XXX
{
  IGRdouble lengthX = 0.0;
  lengthX = VSsxLengthPt1Pt2Y( pt1, pt2, info );

  printf("Length: %8.2f %8.2f %8.2f    %10.4f    %10.4f\n",
    pt1[0],pt1[1],pt1[2], length, fabs(length-lengthX));

  printf("        %8.2f %8.2f %8.2f    %10.4f\n",
    pt2[0],pt2[1],pt2[2], lengthX);

  length = lengthX;
}
#endif

        __exitFunction ( name = "VSsxLengthPt1Pt2", argfmt = "length = %lg, msg = %#x", args = `length, *msg` );

		return length ;

#undef PT_SEC_BEFORE

} /* VSsxLengthPt1Pt2 */
/*----------------------------------------------------------------------------*/
long VSsxProjectReferenceLinePointOntoShell( msg, shGeom, xRef, zRef, havePt, pjPt )

long			*msg ;
struct IGRbsp_surface	*shGeom ;
double			xRef,
			zRef ;
short			*havePt ;
double			*pjPt ;
{
  /*
   * Given the shell ( shGeom ), the X-coordinate ( xRef ) and the
   * Z-coordinate ( zRef ) of the reference line point, this function
   * projects the reference line point ( xRef, 0, zRef ) onto the shell
   * along the vector (0,1,0). It returns the projection point ( pjPt )
   * if any and a flag indicating if we have a projection point
   * ( havePt ).
   */

  long		i0, sts,	/* OM return code.		      */
                num_pts ;	/* Number of projection points.       */
  BSrc		bsRC ;		/* BS return code.		      */
  double	vec[3], 	/* Vector of projection.	      */
                point[3],	/* Point to project.		      */
               *proj_pts,	/* Projection points.		      */
               *u_par, 		/* U parameters value on shell.       */
               *v_par ;		/* V parameters value on shell.       */

  __enterFunction ( name = "VSsxProjectReferenceLinePointOntoShell" , argfmt = "xRef = %lf, zRef = %lf, num_poles = %dx%d",
                    args = `xRef, zRef, shGeom->u_num_poles, shGeom->v_num_poles` );

  *havePt  = FALSE ;

  num_pts  = 0 ;
  proj_pts = u_par = v_par = NULL ;

  point[0] = xRef ;
  point[1] = 0.	;
  point[2] = zRef ;

  vec[0] = vec[2] = 0. ;
  vec[1] = 1. ;

  BSpj_pt_sf( shGeom,
              point,
              vec,
              &num_pts,
              (IGRpoint **) &proj_pts,
              &u_par,
              &v_par,
              &bsRC ) ;

  if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

  if( num_pts )
  {
    VSvccpy( pjPt, proj_pts ) ;
    *havePt = TRUE ;
    __DBGpr_vec( "Reference line point", pjPt ) ;
  }

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :

  if (proj_pts) _FREE( proj_pts ) ;
  if (u_par)    _FREE( u_par	) ;
  if (v_par)    _FREE( v_par	) ;

  if(*havePt)
  {
    __exitFunction ( name = "VSsxProjectReferenceLinePointOntoShell", argfmt = "sts = %d, msg = %#x, bsRC = %d, num_pts = %d, pjPt = %lf %lf %lf",
                     args = `sts, *msg, bsRC, num_pts, pjPt[0], pjPt[1], pjPt[2]` );
  }
  else
  {
    __exitFunction ( name = "VSsxProjectReferenceLinePointOntoShell", argfmt = "sts = %d, msg = %#x, bsRC = %d, num_pts = %d, havePt = %d",
                     args = `sts, *msg, bsRC, num_pts, *havePt` );
  }

  return sts ;

} /* VSsxProjectReferenceLinePointOntoShell */
/*----------------------------------------------------------------------------*/
long VSsxFindPointsForExpandCurve( msg, cvGeom, xMin, xMax, Uite, nbPt, cvPts, cvPm )

long			*msg ;
struct IGRbsp_curve	*cvGeom ;
double			xMin,
			xMax,
			Uite ;
int			*nbPt ;
double			**cvPts,
			**cvPm ;
{
  /*
   * Given a curve to expand ( cvGeom ), an iteration value for the U
   * parameter ( Uite ), this function returns the number ( nbPt ),
   * the list of points to expand ( cvPts ) ( between a given minimum
   * X-coordinate value ( xMin ) and a given maximum X-coordinate value
   * ( xMax ) ) and the corresponding parameters on curve ( cvPm ).
   *
   * Note :
   * ======
   *	'*cvPts' and '*cvPm' are allocated and hence must be freed by
   *	the caller with 'free( *cvPts )' and 'free( *cvPm )'.
   */

  long		sts ;		/* OM return code.		      */
  BSrc		bsRC ;		/* BS return code.		      */
  int		i,		/* Loop index.			      */
		numMax, 	/* Max number of points on curve.     */
		numInt ;	/* Number of intersection points.     */
  double	u,		/* Parameter to get point.	      */
		*ptsInt,	/* Intersection points and	      */
		*pmInt, 	/* parameters on curve between	      */
				/* curve and a plane.		      */
		tollenvec ;	/* Minimum length of vector.	      */

  SetProc( VSsxFindPointsForExpandCurve ); Begin;

  __enterFunction ( name = "VSsxFindPointsForExpandCurve" , argfmt = "xMin = %lg, xMax = %lg, Uite = %lg", args = `xMin, xMax, Uite` );

  *nbPt  = 0 ;
  *cvPts = *cvPm = NULL ;

  numMax = numInt = 0 ;
  ptsInt = pmInt  = NULL ;

  /*
   * See if the iteration value is <1.
   */
  if( Uite >= 1.0 ) vs$inv_arg() ;

  /*
   * To have more precision at the extremites of the curve, we expand it
   * not from 'xMin' to 'xMax', but from 'xMin'+DELTA_X*tollenvec to
   * 'xMax'-DELTA_X*tollenvec.
   */
  BSEXTRACTPAR( msg, BSTOLLENVEC, tollenvec ) ;

  xMin += DELTA_X*tollenvec ;
  xMax -= DELTA_X*tollenvec ;

  /*
   * Allocate memory for output points.
   */
  numMax = (int) ceil( 1.0 / Uite ) +3 ;
  if( !( *cvPts = _MALLOC( 3*numMax, double ) ) ||
      !( *cvPm  = _MALLOC( numMax,   double ) ) ) vs$mem_fail() ;

  /*
   * Intersect curve and plane ( Point = (xMin,0,0) Normal = (1,0,0) ).
   */
  sts = VSsxIntersectionPlaneCurve( msg,
                                    cvGeom,
                                    xMin,
                                    &numInt,
                                    &ptsInt,
                                    &pmInt ) ;

  __CheckRC( sts, *msg, "VSsxIntersectionPlaneCurve", wrapup ) ;

  if( numInt )
  {
    VSvccpy( *cvPts, ptsInt ) ;
    (*cvPm)[0] = pmInt[0] ;
    *nbPt	   = 1 ;

    numInt = 0 ;
    if (ptsInt) { _FREE( ptsInt ) ; ptsInt = NULL ;}
    if (pmInt ) { _FREE( pmInt  ) ; pmInt  = NULL ;}
  }

  /*
   * Find points between xMin and xMax.
   */
  u = 0. ;

  for( i=0; i<numMax-2; i++ )
  {
    BScveval( cvGeom, u, 0, (IGRpoint *) ( *cvPts +3 * (*nbPt) ), &bsRC ) ;

    if( BSERROR( bsRC ) ) vs$error( msgval = EMS_E_BSerror ) ;

    (*cvPm)[*nbPt] = u ;

    u += Uite ;

    if( u > 1. ) u = 1. ;

    if( (*cvPts)[3*(*nbPt)] > xMin &&
        (*cvPts)[3*(*nbPt)] < xMax ) (*nbPt)++ ;
  }

  /*
   * Intersect curve and plane ( Point = (xMax,0,0) Normal = (1,0,0) ).
   */
  sts = VSsxIntersectionPlaneCurve( msg,
                                    cvGeom,
                                    xMax,
                                    &numInt,
                                    &ptsInt,
                                    &pmInt ) ;

  __CheckRC( sts, *msg, "VSsxIntersectionPlaneCurve", wrapup ) ;

  if( numInt )
  {
    VSvccpy( *cvPts +3*(*nbPt), ptsInt ) ;
    (*cvPm)[*nbPt] = pmInt[0] ;
    (*nbPt)++ ;
  }

  __DBGpr_int( "Count of points", *nbPt ) ;

  sts  = OM_S_SUCCESS ;
  *msg = MSSUCC ;

wrapup :
  if( !( sts & 1 & *msg ) )
  {
    if (*cvPts) _FREE( *cvPts ) ;
    if (*cvPm ) _FREE( *cvPm  ) ;
    *nbPt = 0 ;
  }

  if (ptsInt) _FREE( ptsInt ) ;
  if (pmInt ) _FREE( pmInt  ) ;

  __exitFunction ( name = "VSsxFindPointsForExpandCurve", argfmt = "sts = %d, msg = %#x, numMax = %d, nbPt = %d",
                   args = `sts, *msg, numMax, *nbPt` );

  End;

  return sts ;

} /* VSsxFindPointsForExpandCurve */
/*----------------------------------------------------------------------------*/
static int VSsxIsCurveClosed( cvId, cvEnv )

struct GRid	*cvId ;
struct GRmd_env *cvEnv ;
{
	/*
	 * Returns TRUE if input curve is closed. Otherwise returns FALSE.
	 * We cannot test the geometric properties for curve closure here:
	 * the input curve may be a "closed" linestring which does not have
	 * its "phy_closed" bit set.
	 */

	long			msg,	 /* Return code.		      */
				sts ;	 /* OM return code.		      */
	BSrc			bsRC ;	 /* BS return code.		      */
	int			closed ; /* Is curve closed ?		      */
	struct IGRbsp_curve	*cvGeom ;/* Geometry of input curve.	      */
	double			stPt[3], /* Start point of curve.	      */
				enPt[3] ;/* End point of curve. 	      */

        __enterFunction ( name = "VSsxIsCurveClosed" //, argfmt = "", args = ``
        );

	cvGeom = NULL ;
	closed = FALSE ;

	/*
	 * Get geometry of curve.
	 */
	sts = vs$get_geometry( msg	= &msg,
			       grobjId	= cvId,
			       grobjEnv = cvEnv,
			       geometry = &cvGeom ) ;

	__CheckRC( sts, msg, "vs$get_geometry", wrapup ) ;

	/*
	 * Get start and end points.
	 */
	BScveval( cvGeom, 0., 0, (IGRpoint *) stPt, &bsRC ) ;
	if( BSERROR( bsRC ) ) goto wrapup ;

	BScveval( cvGeom, 1., 0, (IGRpoint *) enPt, &bsRC ) ;
	if( BSERROR( bsRC ) ) goto wrapup ;

	/*
	 * If start point is equal to end point, curve is closed.
	 */
	if( VSeqPoints( stPt, enPt ) ) closed = TRUE ;

	wrapup :
		if (cvGeom) _FREE( cvGeom ) ;

        __exitFunction ( name = "VSsxIsCurveClosed", argfmt = "closed = %d", args = `closed` );

		return closed ;

} /* VSsxIsCurveClosed */
/*----------------------------------------------------------------------------*/
long VSsxGetClosedInnerBoundaries( msg, shId, shEnv, nbBound, boundaries )

long		*msg ;
struct GRid	*shId ;
struct GRmd_env *shEnv ;
int		*nbBound ;
struct GRid	**boundaries ;
{
	/*
	 * Given a shell ( shId, shEnv ), this function returns the number
	 * ( nbBound ) and a list of closed inner boundaries ( boundaries )
	 *
	 * Notes :
	 * =======
	 *	- '*boundaries' is allocated and hence must be freed by the
	 *	  caller with 'free( *boundaries )'.
	 *
	 *	- The output list is a copy of inner boundaries, thus the
	 *	  caller can delete it.
	 */

	long			sts ;		/* OM return code.	*/
	int			i,		/* Loop index.		*/
				index,		/* Index.		*/
				edCount ;	/* Count of inside edges*/
	OMuint			lpCount ;	/* Count of loops.	*/
	struct GRid		*edList,	/* List of inside edges.*/
				*grList,	/* List of graphic edges*/
				*p ;		/* Pointer.		*/
	struct GRmd_env 	curEnv ;	/* Current module env.	*/
	OM_S_CHANSELECT 	edgeToOwner ;	/* Channel edge->loop.	*/
	OM_S_OBJECT_LINKAGE	loop ;		/* Id of a loop.	*/
	OM_S_OBJID		prevLoop ;	/* Previous loop.	*/

	SetProc( VSsxGetClosedInnerBoundaries ); Begin

        __enterFunction ( name = "VSsxGetClosedInnerBoundaries" //, argfmt = "", args = ``
        );

	*nbBound    = 0 ;
	*boundaries = NULL ;

	edCount     = 0 ;
	edList	    = grList = NULL ;

	/*
	 * Get current module env.
	 */
	sts = ex$get_cur_mod( id    = &curEnv._MD_ID,
			      osnum = &curEnv._MD_OS ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Get inside edges of shell.
	 */
	sts = vs$get_surface_edges( msg 	= msg,
				    sfId	= shId,
				    sfEnv	= shEnv,
				    edgeType	= VS_K_INSIDE_EDGES,
				    edCount	= &edCount,
				    edList	= &edList ) ;

	__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;

	if( !edCount ) {
		sts  = OM_S_SUCCESS ;
		*msg = MSSUCC ;
		goto wrapup ;
	}

	/*
	 * Get copy of graphic edges.
	 */
	if( !( grList = _MALLOC( edCount, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( curEnv._MD_OS, edCount, grList ) ;

	for( i=0; i<edCount; i++ ) {

		sts = vs$get_graphic_edge( msg		= msg,
					   edId 	= edList +i,
					   edEnv	= shEnv,
					   copy 	= TRUE,
					   copyEnv	= &curEnv,
					   grEdge	= grList +i ) ;

		__CheckRC( sts, *msg, "vs$get_graphic_edge", wrapup ) ;

	}

	__DBGpr_objlist( "Graphic edges", edCount, grList ) ;

	/*
	 * Find output list.
	 */
	if( !( *boundaries = _MALLOC( edCount, struct GRid ) ) ) vs$mem_fail() ;
	VSsetGRids( curEnv._MD_OS, edCount, *boundaries ) ;

	ems$make_chanselect( chan_label    = EMSedge_to_owner,
			     chan_selector = &edgeToOwner ) ;

	prevLoop = NULL_OBJID ;
	index	 = 0 ;

	for( i=0; i<edCount+1; i++ ) {

		if( i != edCount ) {
			sts = om$get_channel_objects(
					      objid	   = edList[i].objid,
					      osnum	   = edList[i].osnum,
					      p_chanselect = &edgeToOwner,
					      size	   = 1,
					      list	   = &loop,
					      count	   = &lpCount ) ;

			__CheckRC( sts, 1, "om$get_channel_objects", wrapup ) ;

			if( !lpCount ) vs$failure() ;

			if( prevLoop == NULL_OBJID ) {
				prevLoop = loop.S_objid ;
				continue ;
			}

			if( IF_EQ_OBJID( prevLoop, loop.S_objid ) ) continue ;
		}

		/*
		 * If we have more than one edge on the same loop,
		 * create a composite curve.
		 */
		if( i-1 - index ) {

			p = grList +index ;

#ifdef vsDEBUG
{ int j ;
			__DBGpr_com( "Create composite curve with :" ) ;
			for( j=0; j<i-index; j++ )
				__DBGpr_obj( "", p[j] ) ;
}
#endif

			sts = vs$makeCompCurve( msg	= msg,
						cvList	= p,
						cvCount = i - index,
						cvEnv	= &curEnv,
						compEnv = &curEnv,
						compCv	= *boundaries
							  + *nbBound ) ;

			__CheckRC( sts, *msg, "vs$makeCompCurve", wrapup ) ;

		} else (*boundaries)[*nbBound] = grList[i-1] ;

		__DBGpr_obj( "Boundary", (*boundaries)[*nbBound] ) ;

		/*
		 * Keep curve if it's closed.
		 */
		if( VSsxIsCurveClosed( *boundaries +*nbBound, &curEnv ) ) {
			__DBGpr_com( "Closed" ) ;
			(*nbBound)++ ;
		} else	{
			__DBGpr_com( "NOT closed" ) ;
			vs$bulk_delete( grids  = *boundaries +*nbBound,
					theEnv = &curEnv ) ;
		}

		prevLoop = loop.S_objid ;
		index	 = i ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( grList && edCount )
				vs$bulk_delete( count  = edCount,
						grids  = grList,
						theEnv = &curEnv ) ;

			if( *boundaries && *nbBound )
				vs$bulk_delete( count  = *nbBound,
						grids  = *boundaries,
						theEnv = &curEnv ) ;

			if (*boundaries)
                        {
                          _FREE( *boundaries ) ;
                          *boundaries = NULL ;
                          nbBound     = 0 ;
                        }
		}

		if (edList) _FREE( edList ) ;
		if (grList) _FREE( grList ) ;

        __exitFunction ( name = "VSsxGetClosedInnerBoundaries", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* VSsxGetClosedInnerBoundaries */
/*----------------------------------------------------------------------------*/
long VSsxMinInterPointBevelPlaneCurve( msg, cvGeom, pt0, pt1, pts, pm )

long                    *msg;
struct IGRbsp_curve     *cvGeom;
IGRpoint                pt0;
IGRpoint                pt1;
IGRdouble               *pts;
IGRdouble               *pm;
{
        /*
        ** Given a curve to expand ( cvGeom ), two points (pt0, pt1),
        ** this function intersects the curve and the plane which have the
        ** two points (pt0, pt1) on it and normal to x-y coordinate plane.
	** It returns the point (pts) which is closest to the point pt0 and
        ** the corresponding parameters (pm) on the curve.
        **
        ** Note :
        ** ======
        **      '*pts' and '*pm' are allocated and hence must be freed by the
        **      caller with 'free( *pts )' and 'free( *pm )'.
        */

        long		sts ;     /* OM return code.                  */
        BSrc            bsRC ;    /* BS return code.                  */
        int             i,        /* Loop index.                      */
                        n_int,    /* Number of intersection points    */
                                  /* Between curve and plane.         */
                        n_seg ;   /* Number of overlaps.              */
        double          *int_pts, /* Intersection points between      */
                                  /*  curve and plane.                */
                        *u,       /* Parameters of intersection pts.  */
                        *a,       /* Start parameters of overlaps.    */
                        *b ;      /* End parameters of overlaps.      */
        IGRpoint        pt2;      /* The third point which constructs */
				  /* the plane with pt0 and pt1.      */
        IGRvector       vector0,  /* Vector from pt0 to pt1.          */
			vector1,  /* Vector from pt0 to pt2.          */
			normal;   /* Normal vector to the plane       */
	IGRdouble 	minDist, curDist;
	IGRint		minIndex;
	IGRdouble	a0, a1, a2;

        __enterFunction ( name = "VSsxMinInterPointBevelPlaneCurve" //, argfmt = "", args = ``
        );

        *pts    = NULL ;
        *pm     = NULL ;

        n_int   = n_seg = 0 ;
        int_pts = u = a = b = NULL ;
	minDist = 1000000.0 * 1000000.0 * 1000000.0;
	minIndex= -1;
	curDist  = 0.0;

        /*
        ** Allocate memory for intersection between curve and plane.
        */
        if( !(int_pts = _MALLOC(3*cvGeom->num_poles,double)) ||
            !(u       = _MALLOC(cvGeom->num_poles,  double)) ||
            !(a       = _MALLOC(cvGeom->num_poles,  double)) ||
            !(b       = _MALLOC(cvGeom->num_poles,  double)) )
          vs$mem_fail() ;

        /*
        ** Find the normal to the plane
        */
        pt2[0] = pt1[0];
        pt2[1] = pt1[1];
        pt2[2] = pt1[2] + 10.0;

        BSmkvec(  &bsRC, vector0, pt0, pt1 );
        BSmkvec(  &bsRC, vector1, pt0, pt2 );
        BScrossp( &bsRC, vector0, vector1, normal );
        BSnorvec( &bsRC, normal );

        /*
        ** Intersect curve and plane.
        */
        BSpl_cv_int( &bsRC,
                     cvGeom,
                     pt0,
                     normal,
                     &n_int,
                     int_pts,
                     u,
                     &n_seg,
                     a,
                     b ) ;

        if( BSERROR(bsRC) ) vs$error( msgval = EMS_E_BSerror ) ;

        /*
        ** Output intersection point which is closer to pt0.
        */
        if( n_int )
	{
          for( i = 0 ; i < n_int ; i++ )
	  {
	    a0 = pt0[0] - int_pts[3*i];
	    a1 = pt0[1] - int_pts[3*i+1];
	    a2 = pt0[2] - int_pts[3*i+2];
	    curDist = sqrt( a0*a0 + a1*a1 + a2*a2 );

	    if( curDist < minDist )
	    {
	      minDist  = curDist;
	      minIndex = i;
	    }
	  }

          VSvccpy( pts, int_pts+3*minIndex ) ;
          *pm = u[minIndex] ;
        }

        sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;

        wrapup :
        if( !(sts&1&*msg) )
	{
          if (pts) { _FREE( pts ) ; pts = NULL ;}
          if (pm ) { _FREE( pm  ) ; pm  = NULL ;}
        }

        if (int_pts) _FREE( int_pts ) ;
        if (u) _FREE( u       ) ;
        if (a) _FREE( a       ) ;
        if (b) _FREE( b       ) ;

        __exitFunction ( name = "VSsxMinInterPointBevelPlaneCurve", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

        return sts ;
} /* VSsxMinInterPointBevelPlaneCurve */
/*----------------------------------------------------------------------------*/
