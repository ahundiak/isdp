/* $Id: VSdrwcstsmbl.C,v 1.1.1.1 2001/01/04 21:10:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwcstsmbl.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwcstsmbl.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:33  cvs
 *      Initial import to CVS
 *
 * Revision 1.4  1999/04/07  14:29:58  pinnacle
 * tr179801988
 *
 * Revision 1.2  1998/08/07  17:34:10  pinnacle
 * Replaced: vsdrawing/VSdrwcstsmbl.C for:  by mdong for struct
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/29/98        Ming            TR179801167
 *      04/07/99        ylong           TR179801988
 * -------------------------------------------------------------------*/
#include <string.h>
#include <stdlib.h>
#include "bstypes.h"
#include "bsparameters.h"
#include "msdef.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "maidmx.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"
#include "bsxtractpar.h"
#define	_X	0
#define _Y	1
#define _Z	2

extern int		VSdrwGetEndTxOrientAndJust() ;
extern int		VSdrwGetMidTxOrientAndJust() ;
extern int		VSdrwGetTxOrientAndJust() ;
/*----------------------------------------------------------------------------*/
int VSdrwCstSymbol( msg, inp, xData, outpgr, outptx )

long		        *msg ;	   /* OUT: Completion code		  */
const VSdrwInputData    *inp ;	   /* IN : Data input to interpreter      */
VSdrwExecData	        *xData ;   /* IN : Data modified during execution */
const VSdrwGraphicGroup *outpgr ;  /* IN : List of constructed graphics   */
VSdrwGraphicGroup       *outptx ; {/* I/O: List to which add new symbol   */

	long			sts ;		/* Return status	*/
	struct IGRbsp_curve	*cvGeom	= NULL,	/* Geom of input curve	*/
				**cvGeoms= NULL;/* Geom of input curves	*/
	IGRvector		cvDir,		/* Dir. vector of curve	*/
				endTn1,		/* Tg. of cv at 1st end	*/
				endTn2,		/* Tg. of cv at 2nd end	*/
				midTn ;		/* Tg. of cv at mid pnt	*/
	int			hasNoDir,	/* Curve has no dir. ?	*/
				txJust,		/* Text justification	*/
				i ;		/* Loop-on-geoms index	*/
	IGRpoint		cvBox[4],	/* Box of curve		*/
				txPos,		/* Text position	*/
				endPt1,		/* 1st end point of cv.	*/
				endPt2,		/* 2nd end point of cv.	*/
				midPt ;		/* Mid point of curve	*/
	VSblkJustPnts		cvJustPnts ;	/* Justif pnts of curve	*/
	VSdirectionType		cvDirType ;	/* Direction type of cv	*/
	VSdrwVertTxOffset	txVtOff ;	/* Vert. offset type	*/
	VSdrwHoriTxOffset	txHzOff ;	/* Hori. offset type	*/
	VSdrwTxDir		txDir ;		/* Direction of text	*/
	VSdrwTxLoc		txLoc ;		/* Location of text	*/
	double			*p,
				*v = NULL,
				txHOval,	/* Val of horiz. offset	*/
				txVOval ;	/* Val of vert.  offset	*/
	IGRmatrix		txMx ;		/* Matrix for text	*/
	char			*txString ;	/* String of text	*/
	short			txLength ;	/* Length of text	*/
	struct GRid		txObj ;		/* Constructed text	*/
	VSdrwTxPosHelper	txPosHelper ;	/* Flag for text dir+pos*/

#ifdef vsDEBUG
	printf( "VSdrwCstSymbol enter\n" ) ;
#endif

	*msg = MSSUCC;

	txObj.objid = NULL_OBJID ;
	txPosHelper = xData->txPosHelper ;

	switch( txPosHelper ) {

		case VSuseAnchorPoint	: hasNoDir = TRUE ; break ;

		case VSuseAnchorCurve	: break ;

		case VSuseFirstCurve	:
		case VSuseAllCurves	:
		if( !outpgr || !( outpgr->count && outpgr->list ) ) {
			if( xData->verbose ) {
				VSdrwPrintf( "!!! No object constructed to put symbol on\n" ) ;
			}
			*msg = MSINARG ; return FALSE ;
		}
		if( 1 == outpgr->count ) txPosHelper = VSuseFirstCurve ;
		break ;

		default			:
		case VSundefTxPosHelper	: /* Should never get here ... */
			*msg = MSINARG ; return FALSE ;
	}

	txLoc		= xData->overrides.textPos.loc ;
	txDir		= xData->overrides.textPos.dir ;
	txHzOff		= xData->overrides.textPos.hoff;
	txVtOff		= xData->overrides.textPos.voff;
	txHOval		= xData->overrides.textPos.hoffVal ;
	txVOval		= xData->overrides.textPos.voffVal ;

	switch( txPosHelper ) {

	case VSuseAnchorPoint	:
		/*
		 * We shall use the anchor point for the text position it it
		 * the same as having a curve with not predominant direction
		 * (eg. like a circle).
		 */
		hasNoDir = TRUE ;
		break ;

	case VSuseAnchorCurve	:
		vs$get_geometry(	msg	= msg,
					grobjId	= &xData->anchorCurve._grid,
					grobjEnv= &xData->anchorCurve.mod_env,
					geometry= &cvGeom ) ;
		if( !( *msg & 1 ) ) {
			goto wrapup ;
		}
		VSfindDirOfCvInXYPlane( msg, cvGeom, cvDir, &hasNoDir ) ;
		/*
		 * From here on same processing as for `VSuseFirstCurve'.
		 */
		txPosHelper = VSuseFirstCurve ;
		break ;

	case VSuseFirstCurve	:
		/*
		 * We shall use the first curve in `outpgr->list' to find the
		 * position, direction and justification of the text.
		 */
		vs$get_geometry(	msg	= msg,
					grobjId	= outpgr->list,
					grobjEnv= inp->drwInfo.drwEnv,
					geometry= &cvGeom ) ;
		if( !( *msg & 1 ) ) {
			goto wrapup ;
		}
		VSfindDirOfCvInXYPlane( msg, cvGeom, cvDir, &hasNoDir ) ;
		break ;

	case VSuseAllCurves	:
		/*
		 * We shall use the all the curves in `outpgr->list' to find the
		 * position, direction and justification of the text.
		 */
		/*
		 * For beam/stiffener and projection, must find the right
		 * wireframe for annotation.
		 */
		cvGeoms = _CALLOC( outpgr->count, struct IGRbsp_curve * ) ;

		for( i = 0 ; i < outpgr->count ; i++ ) {
#ifdef vsDEBUG
			ShowObj( outpgr->list + i ) ;
#endif
			vs$get_geometry(	msg	= msg,
						grobjId	= outpgr->list + i,
						grobjEnv= inp->drwInfo.drwEnv,
						geometry= cvGeoms + i ) ;
			if( !( *msg & 1 ) ) {
				goto wrapup ;
			}
		}
		VSfindDirOfSetOfCurvesInXYPlane( msg, outpgr->count, cvGeoms,
						 cvDir, &hasNoDir ) ;
		break ;
	}

	if( hasNoDir ) {
		/*
		 * Curve with no directions are considered horizontal.
		 */
		cvDir[_X] = 1. ; cvDir[_Y] = cvDir[_Z] = 0. ;
		cvDirType = VShorizontal ;
	} else {
		cvDirType = VSgetDirType( cvDir ) ;
	}

	__DBGpr_int( "Curve direction", cvDirType ) ;
	__DBGpr_int( "Text location", txLoc ) ;

	if( VSuseFirstCurve == txPosHelper ) {
		int	swapped ;

		switch( txLoc ) {

		case VS1stEnd 	:
		case VS2ndEnd	:
			VSfindEndPtsCvInXYPlane( msg, cvGeom, cvDirType,
						 endPt1, endPt2,
						 endTn1, endTn2, &swapped ) ;
			break ;
		
		case VSmiddle	:
			if( cvGeom->phy_closed ) txLoc = VScenter ;
			else VSfindMidPtCvInXYPlane( msg, cvGeom,
						     midPt, midTn ) ;
			break ;
		case VSinnermost:
			 VSfindTheMostInteriorPointToACurve(	msg,
			 					cvGeom,
			 					midPt ) ;
			 break ;
		}
	} else if( VSuseAllCurves == txPosHelper ) {
		VSdrwTxLoc	t = txLoc ;
		int		swapped ;
		int		findTan = FALSE ;

		switch( t ) {
		default		:
		case VSinnermost:
	/* Commented by Ming for TR179801167
		case VScenter	:
	*/
		case VSmiddle	: txLoc = VScenter ;
			VSfindCenterOfSetOfCurvesInXYPlane(	msg,
								outpgr->count,
								cvGeoms,
								midPt ) ;
			goto XMOST ;  // TR179801988 by ylong for getting i
			break ;

		/* TR179801167 by Ming */
		case VScenter	:
			txLoc = VScenter;
			VSfindCenterOfSetOfCurvesInXYPlane(     msg,
                                                                outpgr->count,
                                                                cvGeoms,
                                                                midPt ) ;
		case VSbottom	:
		case VSright	:
		case VStop	:
		case VSleft	: goto XMOST ;
		case VS1stEnd	:
			t = VShorizontal == cvDirType ? VSleft : VStop ;
			findTan = TRUE ;
			goto XMOST ;

		case VS2ndEnd	:
			t = VShorizontal == cvDirType ? VSright : VSbottom ;
			findTan = TRUE ;

		XMOST		:
			VSfindXMostCurve( msg, t, outpgr->count, cvGeoms, &i ) ;
                        if( findTan ) {
			    VSfindEndPtsCvInXYPlane( msg, cvGeoms[i], cvDirType,
					             endPt1, endPt2,
						     endTn1, endTn2, &swapped );
			}
			break ;
		}
		cvGeom = cvGeoms[i] ;
	}

        /* Commented by Ming for TR179801167 
	if(      VSuseAllCurves == txPosHelper 
	    && (    VScenter    == txLoc 
	         || VSinnermost == txLoc ) ) {
        */
	if( (VSuseAllCurves == txPosHelper) && (VSinnermost == txLoc) ) {
		/*
		 * An horizontal vector is used.
		 */
		VSvccpy( cvJustPnts.Center, midPt ) ;
        }
	/* TR179801167 by Ming */
   	else if( (VSuseAllCurves == txPosHelper) &&
	         (VScenter == txLoc) )
        {
	  VSfindBoxOfCvInXYPlane( msg, cvGeom, hasNoDir ? NULL : cvDir,
                                  cvBox ) ;
          VSgetJustPntsOfBlk( cvBox, cvDir, &cvJustPnts ) ;
	  VSvccpy( cvJustPnts.Center, midPt );
        }
	else if(    VSuseAllCurves  == txPosHelper 
		   || VSuseFirstCurve == txPosHelper ) {
		/*
		 * We do not not need justification points when we have
		 * several curves with a text at center.
		 */
		VSfindBoxOfCvInXYPlane( msg, cvGeom, hasNoDir ? NULL : cvDir,
					cvBox ) ;

		VSgetJustPntsOfBlk( cvBox, cvDir, &cvJustPnts ) ;
	}

	/*
	 * Set the point for text location, as well as the vector `v' to
	 * evaluate the matrix for the text.
	 */
	if( VSuseAnchorPoint == txPosHelper ) {
		VSvccpy( txPos, xData->anchorPoint ) ;
		/*
		 * Use the horizontal vector as `tangent to curve' for
		 * computation of text orientation and justification, when
		 * `txPosHelper' is `VSuseAnchorPoint', `cvDir' contains the
		 * horizontal vector.
		 */
		v = cvDir ;
	} else /* VSuseFirstCurve or VSuseAllCurves */ {
		switch( txLoc ) {
			case VSinnermost: p = midPt		  ; break ;
			case VScenter	: p = cvJustPnts.Center   ; break ;
			case VSbottom	: p = cvJustPnts.BotMid   ; break ;
			case VSright	: p = cvJustPnts.RightMid ; break ;
			case VStop	: p = cvJustPnts.TopMid   ; break ;
			case VSleft	: p = cvJustPnts.LeftMid  ; break ;
			case VS1stEnd	: p = endPt1 ; v = endTn1 ; break ;
			case VS2ndEnd	: p = endPt2 ; v = endTn2 ; break ;
			default		: txLoc = VSmiddle ; /* Do not break */
			case VSmiddle	: p = midPt  ; v = midTn  ; break ;
		}
		VSvccpy( txPos, p ) ;
	}
	__DBGpr_vec( "Text point before offset", txPos ) ;

/* ALAIN OLD: absolute offset - CAN BE IMPLEMENTED WHEN SOMEONE NEEDS IT
	__DBGpr_int( "Horizontal offset", txHzOff ) ;
	switch( txHzOff ) {
		case VStoTheLeft	: txPos[_X] -= txHOval ; break ;
		case VShcenter		: break ;
		case VStoTheRight	: txPos[_X] += txHOval ; break ;
	}

	__DBGpr_int( "Vertical offset", txVtOff ) ;
	switch( txVtOff ) {
		case VSbelow	: txPos[_Y] -= txVOval ; break ;
		case VSvcenter	: break ;
		case VSabove	: txPos[_Y] += txVOval ; break ;
	}
END ALAIN OLD */

	/* TR179801167 by Ming
	if( VScenter == txLoc || VSinnermost == txLoc ) txDir = VShoriz ;
	*/
	if( VSinnermost == txLoc ) txDir = VShoriz ;

	/*
	 * Evaluate text's matrix and text's justification flag.
	 */
	if(    ( VS1stEnd == txLoc || VS2ndEnd == txLoc )
	    && ( VSpara   == txDir || VSortho  == txDir ) ) {

		VSdrwGetEndTxOrientAndJust(	msg,
						v,
						cvDirType,
						txDir,
						txLoc,
						txMx,
						&txJust ) ;
	} else if( VSmiddle == txLoc ) {

		VSdrwGetMidTxOrientAndJust(	msg,
						v,
						cvDirType,
						txDir,
						txMx,
						&txJust ) ;
	} else {

		VSdrwGetTxOrientAndJust(	msg,
						&cvJustPnts,
						txDir,
						txLoc,
						txMx,
						&txJust ) ;
	}

	/* relative offset */
	__DBGpr_int( "Horizontal offset", txHzOff ) ;
	switch( txHzOff ) {
		case VStoTheLeft : txPos[_X] -= txHOval * txMx[0] ;
				   txPos[_Y] -= txHOval * txMx[4] ; break ;
		case VShcenter	 : break ;
		case VStoTheRight: txPos[_X] += txHOval * txMx[0] ;
				   txPos[_Y] += txHOval * txMx[4] ; break ;
	}

	__DBGpr_int( "Vertical offset", txVtOff ) ;
	switch( txVtOff ) {
		case VSbelow	: txPos[_X] -= txVOval * txMx[1] ;
				  txPos[_Y] -= txVOval * txMx[5] ; break ;
		case VSvcenter	: break ;
		case VSabove	: txPos[_X] += txVOval * txMx[1] ;
				  txPos[_Y] += txVOval * txMx[5] ; break ;
	}

	if( VS_K_DRW_JUST_NOT_SET == xData->overrides.textSymb.Active_just ) {
		__DBGpr_int( "Overriding just w/", txJust ) ;
		xData->overrides.textSymb.Active_just = txJust ;
	}

	if( xData->textFormat.bufsiz ) {
		txString = xData->textFormat.buffer ;
		txLength = xData->textFormat.curpos ;
		__DBGpr_int( "Text length", txLength ) ;

	} else {
		txString = "" ;
		txLength = 0 ;
	}
	if( xData->overrides.dpAttr.filledDisplay ) {
		xData->overrides.textSymb.Active_flags |= GRFILLED_TEXT ;
	} else {
		xData->overrides.textSymb.Active_flags &= ~GRFILLED_TEXT ;
	}

	/*
	 * Correct text matrix if text is requested to be uspide down or
	 * right-to-left.
	 */
	__DBGpr_int( "Upside down", xData->overrides.textPos.rev & VSupsideDown ) ;
	if( (int) xData->overrides.textPos.rev & (int) VSupsideDown ) {
		txMx[1] = - txMx[1] ;
		txMx[5] = - txMx[5] ;
	}
	__DBGpr_int( "Right to left", xData->overrides.textPos.rev & VSrightToLeft ) ;
	if( (int) xData->overrides.textPos.rev & (int) VSrightToLeft ) {
		txMx[0] = - txMx[0] ;
		txMx[4] = - txMx[4] ;
	}

	__DBGpr_mat( "Text mx    ", txMx ) ;
	__DBGpr_vec( "Text point ", txPos ) ;

	sts = co$place_text(
			msg		= msg,
			ModuleInfo	= inp->drwInfo.drwEnv,
			lbs_matrix	= txMx,
			text_string	= txString,
			text_length	= &txLength,
			ActiveDisplay	= &xData->overrides.elmDisplay,
			ActiveLevel	= xData->overrides.elmLevel,
			TextSymb	= &xData->overrides.textSymb,
			origin		= txPos,
			flags		= 0,
			buffer		= &txObj ) ;

	if( sts & 1 & *msg ) {
		__DBGpr_obj( "Text", txObj ) ;
		__DBGpr_int( "Old count", outptx->count ) ;

		outptx->list	= _MALLOC( 1, struct GRid ) ;
		outptx->list[0]	= txObj ;
		outptx->count	= 1 ;
	} else {
		vs$bulk_delete(	grids	= &txObj,
				theEnv	= inp->drwInfo.drwEnv ) ;
#ifdef vsDEBUG
		printf( "TEXT FAILED\n");
#endif
	}

	wrapup :
		switch( txPosHelper ) {
			case VSuseFirstCurve	:
				_FREE( cvGeom ) ;
				break ;

			case VSuseAllCurves	:			
				if( cvGeoms ) {
					for( i = 0 ; i < outpgr->count ; i++ ) {
						_FREE( cvGeoms[i] ) ;
					}
					_FREE( cvGeoms ) ;
				}
				break ;
			default			: break ;
		}

		return *msg & 1 ;

} /* VSdrwCstSymbol */
/*----------------------------------------------------------------------------*/
int VSdrwGetTxOrientAndJust( msg, jPnts, txDir, txLoc, orientMx, txJust )

long			*msg ;
VSblkJustPnts		*jPnts ;
VSdrwTxDir		txDir ;
VSdrwTxLoc		txLoc ;
IGRmatrix		orientMx ;
int			*txJust ; {


	double		*vx,
			*vy ;
	IGRvector	botToTop,
			leftToRight,
			topToBot,
			rightToLeft ;
	int		haveB2T		= FALSE,
			haveL2R		= FALSE ;

	/*
	 * CASE PARALLEL			CASE ORTHOGONAL
	 *             y                                  x
	 *             ^                                  ^
	 *             |                                  |
	 *             -> x                            y <-
	 *         x +---T----+                      +---T----+
	 *         ^ |        | -> y           y     |        | y
	 *         | L        R |              ^     L        R ^
	 *       y<- |        | v              |     |        | |
	 *           +---B----+ x              -> x  +---B----+ -> x
	 *             y                                 -> y
	 *             ^                                 |
	 *             |                                 v
	 *             -> x                              x
	 * Remember: block justification points are supposed to be in an
	 * xy-plane, hence vectors have a null z.
	 */
	MAidmx( msg, orientMx ) ;


	/* Commented by Ming for TR179801167
	if( VScenter == txLoc || VSinnermost == txLoc ) {
	*/
	if( VSinnermost == txLoc ) {
		*txJust = CENTER_CENTER ; goto wrapup ;
	}

	if( VShoriz == txDir ) {
		switch( txLoc ) {
			/* TR179801167 by Ming */
			case VScenter	: *txJust = CENTER_CENTER ; break ;
			case VSbottom	: *txJust = CENTER_TOP    ; break ;
			case VSright	: *txJust = LEFT_CENTER   ; break ;
			case VStop	: *txJust = CENTER_BOTTOM ; break ;
			case VSleft	: *txJust = RIGHT_CENTER  ; break ;
		}
		goto wrapup ;
	}
	if( !VSeqPoints( jPnts->BotLeft, jPnts->TopLeft ) ) {
		BSmkvec( msg, botToTop, jPnts->BotLeft, jPnts->TopLeft  ) ;
		BSnorvec( msg, botToTop ) ;
		haveB2T = TRUE ;
	}

	if( !VSeqPoints( jPnts->BotLeft, jPnts->BotRight ) ) {
		BSmkvec( msg, leftToRight, jPnts->BotLeft, jPnts->BotRight ) ;
		BSnorvec( msg, leftToRight ) ;
		haveL2R = TRUE ;
	}

	if( !haveB2T ) {
		if( haveL2R ) {
			botToTop[_X] = - leftToRight[_Y] ;
			botToTop[_Y] =   leftToRight[_X] ;
			botToTop[_Z] =   leftToRight[_Z] ;
		} else {
			goto wrapup ;
		}
	} else if( !haveL2R ) {
		leftToRight[_X] =   botToTop[_Y] ;
		leftToRight[_Y] = - botToTop[_X] ;
		leftToRight[_Z] =   botToTop[_Z] ;
	}

	VSnegvc( leftToRight, rightToLeft ) ;
	VSnegvc( botToTop   , topToBot    ) ;

	if( VSpara == txDir ) {
		switch( txLoc ) {
			default		:
			/* TR179801167 by Ming */
			case VScenter	:
				vx = leftToRight; vy = botToTop    ;
				*txJust = CENTER_CENTER; break ;
			case VSbottom	:
				vx = leftToRight; vy = botToTop    ;
				*txJust = CENTER_TOP   ; break ;
			case VSright	:
				vx = topToBot	; vy = leftToRight ;
				*txJust = CENTER_BOTTOM; break ;
			case VStop	:
				vx = leftToRight; vy = botToTop    ;
				*txJust = CENTER_BOTTOM; break ;
			case VSleft	: 
				vx = botToTop	; vy = rightToLeft ;
				*txJust = CENTER_BOTTOM; break ;
		}
	} else /* VSortho */ {
		switch( txLoc ) {
			case VS1stEnd	:
			default		:
			/* TR179801167 by Ming */
			case VScenter	:
				vx = topToBot	; vy = leftToRight ;
				*txJust = CENTER_CENTER; break ;
			case VSbottom	:
				vx = topToBot	; vy = leftToRight ;
				*txJust = LEFT_CENTER  ; break ;
			case VSright	:
				vx = leftToRight; vy = botToTop	   ;
				*txJust = LEFT_CENTER  ; break ;
			case VS2ndEnd	:
			case VStop	:
				vx = botToTop	; vy = rightToLeft ;
				*txJust = LEFT_CENTER  ; break ;
			case VSleft	:
				vx = leftToRight; vy = botToTop	   ;
				*txJust = RIGHT_CENTER ; break ;
				
		}
	}

	orientMx[0] = vx[_X] ; orientMx[4] = vx[_Y] ;
	orientMx[1] = vy[_X] ; orientMx[5] = vy[_Y] ;

	wrapup :
		*msg = MSSUCC ;
		return 1 ;

} /* VSdrwGetTxOrientAndJust */
/*----------------------------------------------------------------------------*/
int VSdrwGetEndTxOrientAndJust( msg, endTan, cvDirType, txDir, txLoc,
				orientMx, txJust )

long			*msg ;
IGRvector		endTan ;
VSdirectionType		cvDirType ;
VSdrwTxDir		txDir ;
VSdrwTxLoc		txLoc ;
IGRmatrix		orientMx ;
int			*txJust ; {

	/*
	 * Vertical curve		Horizontal curve
	 * PARALLEL
	 *      x->y
	 *      |
	 *      v
	 *      +		    y  		  y
	 *      |                   ^  		  ^
	 *      |		   x|-> +--------+|->x
	 *      |                       
	 *      +                       
	 *      ->y
	 *      |
	 *      v
	 *      x
	 * ORTHOGONAL
	 *      ^y
	 *      |
	 *      ->x
	 *      +		     x
	 *      |                    ^
	 *      |		  y<-|  +--------+|->y
	 *      |                                 v
	 *      +                                 x
	 *      ^y
	 *      |
	 *      ->x
	 *
	 * In all cases x = input endTan (supposed to point away from curve
	 * and be normalized).
	 */
	IGRvector	xTx,
			yTx ;

	MAidmx( msg, orientMx ) ;
	VSvccpy( xTx, endTan ) ;

	if( VSpara == txDir ) {
		switch( cvDirType ) {

		default			:
		case VShorizontal	:
			switch( txLoc ) {
				default	      :
				case VS1stEnd : /* Leftmost  point	*/
					xTx[_X] = - endTan[_X] ;
					xTx[_Y] = - endTan[_Y] ;
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
				case VS2ndEnd : /* Rightmost point	*/
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
			}
			break ;
		case VSvertical		:
			switch( txLoc ) {
				default	      :
				case VS1stEnd : /* Uppermost point	*/
					xTx[_X] = - endTan[_X] ;
					xTx[_Y] = - endTan[_Y] ;
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
				case VS2ndEnd : /* Lowermost point	*/
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
			}
			break ;
		}
	} else /* VSortho */ {
		switch( cvDirType ) {
			default			:
			case VShorizontal	:
			switch( txLoc ) {
				case VS1stEnd : /* Leftmost  point	*/
					xTx[_X] =   endTan[_Y] ;
					xTx[_Y] = - endTan[_X] ;
					yTx[_X] =   endTan[_X] ;
					yTx[_Y] =   endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
				case VS2ndEnd : /* Rightmost point	*/
	/* Commented by Ming for TR179801167
					xTx[_X] = - endTan[_Y] ;
					xTx[_Y] =   endTan[_X] ;
	*/
					xTx[_X] =   endTan[_Y] ;
					xTx[_Y] = - endTan[_X] ;
					yTx[_X] =   endTan[_X] ;
					yTx[_Y] =   endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
			}
			break ;
		case VSvertical		:
			switch( txLoc ) {
				default	      :
				case VS1stEnd : /* Uppermost point	*/
					xTx[_X] =   endTan[_Y] ;
					xTx[_Y] = - endTan[_X] ;
					yTx[_X] =   endTan[_X] ;
					yTx[_Y] =   endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
				case VS2ndEnd : /* Lowermost point	*/
					xTx[_X] = - endTan[_Y] ;
					xTx[_Y] =   endTan[_X] ;
					yTx[_X] = - endTan[_X] ;
					yTx[_Y] = - endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
			}
			break ;
		}
	}

	orientMx[0] = xTx[_X] ; orientMx[4] = xTx[_Y] ;
	orientMx[1] = yTx[_X] ; orientMx[5] = yTx[_Y] ;

	*msg = MSSUCC ;

	return *msg & 1 ;
	
} /* VSdrwGetEndTxOrientAndJust */
/*----------------------------------------------------------------------------*/
int VSdrwGetMidTxOrientAndJust( msg, midTan, cvDirType, txDir,
				orientMx, txJust )

long			*msg ;
IGRvector		midTan ;
VSdirectionType		cvDirType ;
VSdrwTxDir		txDir ;
IGRmatrix		orientMx ;
int			*txJust ; {

	/*
	 * Vertical curve		Horizontal curve
	 * PARALLEL			PARALLEL
	 *
	 *      +			    y
	 *    x |			    ^
	 *    ^ |		            |
	 * y<-| m                           -> x
	 *      |			+---m---+
	 *      |
	 *      +
	 * ORTHOGONAL			ORTHOGONAL
	 *
	 *      +			    x
	 *      | y			    ^
	 *      | ^		            |
	 *      m |-> x                  y <-
	 *      |			+---m---+
	 *      |
	 *      +
	 *
	 * In all cases x = input midTan (supposed to point away from curve
	 * and be normalized).
	 */
	IGRvector	xTx,
			yTx ;
	IGRdouble	baseTol ;

	MAidmx( msg, orientMx ) ;

	BSxtractpar( msg, BSTOLBASIS, &baseTol );

	if(midTan[_X] < baseTol )	midTan[_X] = 0.0;

	if(midTan[_Y] < baseTol )	midTan[_Y] = 0.0;

	switch( cvDirType ) {
		default			:
		case VShorizontal	:
			switch( txDir ) {
				default		:
				case VShoriz	:
					*txJust = CENTER_CENTER ;
					break ;
				case VSpara	:
					if( midTan[_X] >= 0 ) { 
						xTx[_X] = midTan[_X] ;
						xTx[_Y] = midTan[_Y] ;
					} else {
						xTx[_X] = - midTan[_X] ;
						xTx[_Y] = - midTan[_Y] ;
					}
					yTx[_X] = - xTx[_Y] ;
					yTx[_Y] =   xTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
				case VSortho	:
					if( midTan[_X] < 0 ) { 
						yTx[_X] = midTan[_X] ;
						yTx[_Y] = midTan[_Y] ;
					} else {
/* ALAIN */
						if( midTan[_Y] >= 0 ) {
							yTx[_X] = midTan[_X] ;
							yTx[_Y] = midTan[_Y] ;
						} else {
/* ALAIN */
							yTx[_X] = - midTan[_X] ;
							yTx[_Y] = - midTan[_Y] ;
/* ALAIN */
						}
/* ALAIN */
					}
					xTx[_X] =   yTx[_Y] ;
					xTx[_Y] = - yTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
			}
			break ;
		case VSvertical		:
			switch( txDir ) {
				default	      	:
				case VShoriz	:
					*txJust = CENTER_CENTER ;
					break ;
				case VSpara	:
					if( midTan[_X] >= 0 ) { 
						xTx[_X] = midTan[_X] ;
						xTx[_Y] = midTan[_Y] ;
					} else {
						xTx[_X] = - midTan[_X] ;
						xTx[_Y] = - midTan[_Y] ;
					}
					yTx[_X] = - xTx[_Y] ;
					yTx[_Y] =   xTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
				case VSortho	:
					if( midTan[_X] >= 0 ) { 
						yTx[_X] = midTan[_X] ;
						yTx[_Y] = midTan[_Y] ;
					} else {
/* ALAIN */
						if( midTan[_Y] >= 0 ) {
							yTx[_X] = midTan[_X] ;
							yTx[_Y] = midTan[_Y] ;
						} else {
/* ALAIN */
							yTx[_X] = - midTan[_X] ;
							yTx[_Y] = - midTan[_Y] ;
/* ALAIN */
						}
/* ALAIN */
					}
					xTx[_X] =   yTx[_Y] ;
					xTx[_Y] = - yTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
			}
			break ;
	}

	if( txDir != VShoriz ) {
		orientMx[0] = xTx[_X] ; orientMx[4] = xTx[_Y] ;
		orientMx[1] = yTx[_X] ; orientMx[5] = yTx[_Y] ;
	}

	*msg = MSSUCC ;

	return *msg & 1 ;
	
} /* VSdrwGetMidTxOrientAndJust */
/*----------------------------------------------------------------------------*/
