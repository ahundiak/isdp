/* $Id: VSdrwbmorien.I,v 1.2 2001/03/13 15:43:58 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwbmorien.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwbmorien.I,v $
 *      Revision 1.2  2001/03/13 15:43:58  ramarao
 *      Fixed TR# 4793.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/13/01        Rama Rao        Header Creation and Fixed TR# 4793.
 * -------------------------------------------------------------------*/

class implementation VSbeam ;

#include <string.h>
#include <math.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsdrwdef.h"
#include "vsdrwapi.h"
#include "vsglobalmsg.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsvecmxproto.h"

extern const char	*VSdrwNotABeam ;

from GRcurve	import GRendpts ;
/*----------------------------------------------------------------------------*/
static void VSaxisMostFollowed( const IGRvector V, char axis[3] ) {

	int	i, imax = 0 ;
	double	d = 0. ;

	for( i = 0 ; i < 3 ; i++ ) {
		double a = fabs( V[i] ) ;
		if( a > d ) { d = a ; imax = i ; }
	}

	axis[0] = V[imax] >= 0 ? '+' : '-' ;
	axis[1] = "xyz"[imax] ;
	axis[2] = '\0' ;

} /* VSaxisMostFollowed */
/*----------------------------------------------------------------------------*/
static long VSgetBeamDirection(	long			*msg,
				const struct GRid	*bmId,
				const struct GRmd_env	*bmEnv,
				IGRpoint		segment[2] ) {

	long			sts ;
	struct GRobj_env	axis ;

	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
					msg, (struct GRmd_env *) bmEnv, &axis ),
			senderid= NULL_OBJID,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( vs$is_curve_linear( msg = msg, curveId = &axis._grid,
				curveEnv = &axis.mod_env ) ) {
	  sts = om$send(msg	= message GRcurve.GRendpts(
					  msg, &axis._matrix_type,
					  axis._matrix,
					  segment[0], segment[1] ),
			senderid= NULL_OBJID,
			targetid= axis._objid,
			targetos= axis._osnum ) ;
	  __CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;
	} else {
	   /*
	    * Use the beam's range box...
	    */
	   IGRboolean world = TRUE ;
	   sts = om$send(msg	= message GRgraphics.GRgetrang(
	   				              msg, &axis._matrix_type,
	   				              axis._matrix, &world,
	   				              (double *) segment ),
	   		 senderid= NULL_OBJID,
			 targetid= axis._objid,
			 targetos= axis._osnum ) ;
	   __CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;
	}

	wrapup :
		return sts ;

} /* VSgetBeamDirection */
/*----------------------------------------------------------------------------*/
void VSgetWldAxisFollowedByBeam( const struct GRid     *bmId,
				 const struct GRmd_env *bmEnv,
				 char                  axis[3] ) {

  /*
   * Find the world CS axis most followed by the beam (supposed roughly linear).
   * and returns "x", "+y" (on +y side of centerline), "y" (crosses centerline),
   *  "-y" (on -y side of centerline), "z" or "" (error)
   */

  long		sts, msg ;
  IGRpoint	pts[2] ;

  sts = VSgetBeamDirection( &msg, bmId, bmEnv, pts ) ;

  if( sts & 1 & msg ) {
    /*
     * Project segment on the 3 coordinate axes: the direction of the
     * segment will be taken to be that which has the longest projection.
     */
    char	dir ;

    {
      double	d = 0. ;
      int	i, idir = 0 ;

      for( i = 0 ; i < 3 ; i++ ) {
        double dxi = fabs( pts[0][i] - pts[1][i] ) ;
        if( dxi > d ) { d = dxi ; idir = i ; }
      }
      dir = "xyz"[idir] ;
    }

    if( 'y' == dir ) {
      /* Find position with respect to center line (Ox axis).
       */
      int p1 = pts[0][1] >= 0 ? 1 : 0 ;
      int p2 = pts[1][1] >= 0 ? 1 : 0 ;

      switch( p1 + p2 ) {
        case 0 : axis[0] = '-' ; axis[1] = 'y'  ; axis[2] = '\0' ; break ;
        case 1 : 
        {
	    axis[0] = 'y' ; 
	    axis[1] = '\0' ;                  

	    /* 
	     * The beam may be touching the center line.
	     * Assign proper directions.
	     */
	    if( fabs( pts[0][1] ) < 1e-4 )
	    {
		if(  pts[1][1] > 1e-4 )
		{
		   axis[0] = '+' ; axis[1] = 'y'  ; axis[2] = '\0' ; 
		}
		else
		{
		   axis[0] = '-' ; axis[1] = 'y'  ; axis[2] = '\0' ;
		}
	    }

            if( fabs( pts[1][1] ) < 1e-4 )
            {
                if(  pts[0][1] > 1e-4 )   
                {
                   axis[0] = '+' ; axis[1] = 'y'  ; axis[2] = '\0' ; 
                }
                else
                {
                   axis[0] = '-' ; axis[1] = 'y'  ; axis[2] = '\0' ;
                }
            }
	    break ;
	}
        case 2 : axis[0] = '+' ; axis[1] = 'y'  ; axis[2] = '\0' ; break ;
      }
    } else {
      axis[0] = dir ; axis[1] = '\0' ;
    }

  } else *axis = '\0' ;

} /* VSgetWldAxisFollowedByBeam */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, beam_orientation ) {

	/*
	 * Find out direction of beam: return "x" if stiffener is along the
	 * fore-aft axis, "z" if stiffener is vertical, "+y" if stiffener is
	 * transverse and on the left of the centerline, "-y" if transverse
	 * and on the right, "y" if transverse and crossing the centerline.
	 * Here, x, y and z are coordinates in the model, *not* on the drawing
	 * sheet.
	 */

	long		sts,
			rc ;		/* Other completion code	*/
	IGRpoint	pts[2] ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

	/*
	 * Input element must be a beam/stiffener
	 */
	if(    xData->parsedElmType != VS_gI_Beam
	    && xData->parsedElmType != VS_gI_Stiffener ) {
		XFERR( VSdrwNotABeam, function ) ;
		return xfINVARG ;
	}

	sts = VSgetBeamDirection( &rc, inp->elmId, inp->elmEnv, pts ) ;
	__CheckRC( sts, rc, "VSgetBeamDirection", wrapup ) ;

	VSgetWldAxisFollowedByBeam( inp->elmId, inp->elmEnv, res->_sval ) ;
	if( !*res->_sval ) rc = 0 ;

	wrapup:
		return sts & 1 & rc ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONbeam_orientation */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, flange_orientation ) {

	long		sts,		/* OM return code		*/
			rc ;		/* Other completion code	*/
	VSsuppList	bmSupps ;	/* Supports of beam (sf + axis)	*/
	int		count ;		/* Count of supports		*/
	IGRmatrix	prflCS ;	/* Matrix of profile		*/

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

	/*
	 * Input element must be a beam/stiffener
	 */
	if(    xData->parsedElmType != VS_gI_Beam
	    && xData->parsedElmType != VS_gI_Stiffener ) {
		XFERR( VSdrwNotABeam, function ) ;
		return xfINVARG ;
	}

	sts = om$send(	msg	= message VSpart.VSgetSupports(
					&rc, inp->elmEnv, &count, bmSupps ),
			senderid= NULL_OBJID,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;

	{
   	  struct GRid	prflDef ;	/* Id of profile definition	*/

	  sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
								&rc,
								inp->elmEnv,
								bmSupps + 0,
								bmSupps + 1,
								0.5,
								&prflDef,
								prflCS ),
			senderid= NULL_OBJID,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	  if( !( sts & 1 & rc ) ) goto wrapup ;
	}

	{
	  IGRvector	xp ;

	  xp[0] = prflCS[0] ; xp[1] = prflCS[4] ; xp[2] = prflCS[8] ;

	  VSaxisMostFollowed( xp, res->_sval ) ;
	}

	wrapup:
		return sts & 1 & rc ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONflange_orientation */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VS, web_orientation ) {

	long		sts,		/* OM return code		*/
			rc ;		/* Other completion code	*/
	VSsuppList	bmSupps ;	/* Supports of beam (sf + axis)	*/
	int		count ;		/* Count of supports		*/
	IGRmatrix	prflCS ;	/* Matrix of profile		*/

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 0 )

	/*
	 * Input element must be a beam/stiffener
	 */
	if(    xData->parsedElmType != VS_gI_Beam
	    && xData->parsedElmType != VS_gI_Stiffener ) {
		XFERR( VSdrwNotABeam, function ) ;
		return xfINVARG ;
	}

	sts = om$send(	msg	= message VSpart.VSgetSupports(
					&rc, inp->elmEnv, &count, bmSupps ),
			senderid= NULL_OBJID,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) goto wrapup ;

	{
   	  struct GRid	prflDef ;	/* Id of profile definition	*/

	  sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
								&rc,
								inp->elmEnv,
								bmSupps + 0,
								bmSupps + 1,
								0.5,
								&prflDef,
								prflCS ),
			senderid= NULL_OBJID,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	  if( !( sts & 1 & rc ) ) goto wrapup ;
	}

	{
	  IGRvector	yp ;

	  yp[0] = prflCS[1] ; yp[1] = prflCS[5] ; yp[2] = prflCS[9] ;

	  VSaxisMostFollowed( yp, res->_sval ) ;
	}

	wrapup:
		return sts & 1 & rc ? xfSUCCESS : xfFAILURE ;

} /* VSdrwFUNCTIONweb_orientation */
/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VS, where_is ) {

	long		sts,		/* OM return code		*/
			rc ;		/* Other completion code	*/
	VStktxt		where ;
	IGRvector	V ;

	res->type	= VS_string ;
	*res->_sval	= '\0' ;

	CHECK_ARGCOUNT( 1 )

	VSdrwStrVal( &arglist->arg, where ) ;

	if( !strcmp( where, "centerline"	) ) {
	    IGRpoint pts[2] ;

	    /*
	     * Input element must be a beam/stiffener for evaluation against
	     * the centerline (Oxy plane).
	     */
	    if(    xData->parsedElmType != VS_gI_Beam
	        && xData->parsedElmType != VS_gI_Stiffener ) {
	      XFERR( VSdrwNotABeam, function ) ;
	      return xfINVARG ;
	    }

	    /*
	     * Find along which axis beam goes most (in model coords).
	     */
	    sts = VSgetBeamDirection( &rc, inp->elmId, inp->elmEnv, pts ) ;
	    if( !( sts & 1 & rc ) ) return xfFAILURE ;
	    
	    if( pts[0][1] <= 0 && pts[1][1] <= 0 ) {
	      /* centerline is towards +y in model coords */
	      V[0] = 0 ; V[1] = 1 ; V[2] = 0 ;
	    } else if( pts[0][1] >= 0 && pts[1][1] >= 0 ) {
	      /* centerline is towards -y in model coords */
	      V[0] = 0 ; V[1] = -1 ; V[2] = 0 ; 
	    } else if( fabs( pts[0][1] ) >= fabs( pts[1][1] ) ) {
	      if( pts[0][1] >= 0 ) {
	      	V[0] = 0 ; V[1] = -1 ; V[2] = 0 ;
	      } else {
	      	V[0] = 0 ; V[1] =  1 ; V[2] = 0 ;
	      }
	    } else {
	      if( pts[1][1] >= 0 ) {
	      	V[0] = 0 ; V[1] = -1 ; V[2] = 0 ;
	      } else {
	      	V[0] = 0 ; V[1] =  1 ; V[2] = 0 ;
	      }
	    }
	} else if( !strcmp( where, "fore"      ) || !strcmp( where, "+x" ) ) {
	   V[0] =  1 ; V[1] =  0 ; V[2] =  0 ;
	} else if( !strcmp( where, "aft"       ) || !strcmp( where, "-x" ) ) {
	   V[0] = -1 ; V[1] =  0 ; V[2] =  0 ;
	} else if( !strcmp( where, "portside"  ) || !strcmp( where, "+y" ) ) {
	   V[0] =  0 ; V[1] =  1 ; V[2] = 0 ;
	} else if( !strcmp( where, "starboard" ) || !strcmp( where, "-y" ) ) {
	   V[0] =  0 ; V[1] = -1 ; V[2] =  0 ;
	} else if( !strcmp( where, "top"       ) || !strcmp( where, "+z" ) ) {
	   V[0] =  0 ; V[1] =  0 ; V[2] =  1 ;
	} else if( !strcmp( where, "bottom"    ) || !strcmp( where, "-z" ) ) {
	   V[0] =  0 ; V[1] =  0 ; V[2] = -1 ;
	}
	/*
	 * Now find direction of V in drawing sheet.
	 */
	{
	  IGRvector Vdrw ;
	  VSmxprodvc( inp->elmEnv->_MATRIX, V, Vdrw ) ;

	  /*
	   * See in which direction the vector points to in the drawing sheet.
	   */
	  VSaxisMostFollowed( V, res->_sval ) ;
	}

	return xfSUCCESS ;

} /* VSdrwFUNCTIONwhere_is */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
