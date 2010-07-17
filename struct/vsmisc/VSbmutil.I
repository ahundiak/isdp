/* $Id: VSbmutil.I,v 1.1.1.1 2001/01/04 21:10:50 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsmisc/VSbmutil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbmutil.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:50  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/23  20:26:04  pinnacle
# TR179800263
#
# Revision 1.3  1997/09/29  14:59:44  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *                      Lots of changes to support new cardinal points
 *      01/23/98 ah     TR179800263  Rewrote VScardpoint_to_vector
 *                      It was failing for the av_bulb shape
 *                      The original code is still in place
 ***************************************************************************/
 
class implementation VSbeam ;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vsdpb.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"

/*
#define vsDEBUG
#define vserrDEBUG
*/

#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vschgsymb.h"
#include "vsbeamproto.h"
#include "vssectiondef.h"

extern IGRdouble fabs();

from 	VSxscurve 	import	VStransUsrNmToCmp;
from	GRcurve		import	GRmidpoint;
from	GRcurve		import	GRendpts;
from	GRcurve		import	GRtotlength;
from	VScompcurve	import	VSgetMapping ;
from	VScompcurve	import	VStransUsrIxToCmp ;

IGRlong VSgetCmpPoints(
  struct      GRid     *curveID, 
  struct      GRmd_env *curveENV, 
  IGRint      cmpIndex, 
  IGRdouble  *pts
);

/* ---------------------------------------------------------
 * TR179800263 Failing on some profiles, rewrote it
 * For envelopment placements, just returns the range points
 * For web alignment, find the two web segments (defined as the
 * two longest vertical segments) and returns the x value
 */
IGRlong VScardpoint_to_vector( 
  IGRlong              *msg, 
  struct GRmd_env      *curveENV, 
  struct GRid          *curveID, 
  IGRboolean           *profOpt, 
  enum VScardinal_point card, 
  IGRvector             vector 
)
{
  IGRlong     sts ;
  IGRboolean  wrt_world_ref ;
  GRrange     range ;
  IGRdouble   cvWidth,cvHeight ;

  IGRdouble   pts[9];
  IGRdouble   xLeft,xRight;

  // Init
  vector[0] = vector[1] = vector[2] = 0.0;

  /* Compute profile curve range */
  wrt_world_ref = TRUE ; /* same matrix used anyway */
  sts = om$send(
    msg = message GRgraphics.GRgetrang(
      msg,
     &curveENV->_MATRIX_TYPE,
      curveENV->_MATRIX,
     &wrt_world_ref,
      range 
    ),
    senderid = curveID->objid,
    targetid = curveID->objid,
    targetos = curveID->osnum 
  );
  __CheckRC( sts, *msg, "GRvg.GRgetrang", wrapup ) ;

  cvHeight  = range[4] - range[1] ;
  cvWidth   = range[3] - range[0] ;

  // Y Component is a function of cvHeight
  switch( card ) {
    case VS_e_UPP_LEFT :
    case VS_e_TOP_MIDD :
    case VS_e_UPP_RGHT : vector[1] = - cvHeight ; break ;
    case VS_e_LFT_MIDD :
    case VS_e_GEO_CENT :
    case VS_e_RGH_MIDD : vector[1] = - cvHeight * 0.5 ; break ;
    case VS_e_BOT_MIDD :
    case VS_e_BOT_RGHT :
    case VS_e_BOT_LEFT : vector[1] = 0.0 ; break ;
  }
  vector[1] = vector[1] - range[1] ;

  // For envelope, x component is a function of cvWidth
  if (*profOpt == 0) {
    switch( card ) {
      case VS_e_UPP_LEFT :
      case VS_e_BOT_LEFT : 
      case VS_e_LFT_MIDD : vector[0] = 0.0 ; break ;
      case VS_e_TOP_MIDD :
      case VS_e_GEO_CENT : 
      case VS_e_BOT_MIDD : vector[0] = -cvWidth * 0.5 ; break ;
      case VS_e_UPP_RGHT :
      case VS_e_RGH_MIDD : 
      case VS_e_BOT_RGHT : vector[0] = -cvWidth ; break;
    }
    vector[0] = vector[0] - range[0] ;
    *msg = MSSUCC ;
    goto wrapup;
  }

  // Get the web x values
  sts = VSgetCmpPoints(curveID,curveENV,VS_K_sc_WebL,pts);
  if (sts != 1) goto wrapup;
  xLeft = pts[0];

  sts = VSgetCmpPoints(curveID,curveENV,VS_K_sc_WebR,pts);
  if (sts != 1) goto wrapup;
  xRight = pts[0];

  switch( card ) {
    case VS_e_UPP_LEFT :
    case VS_e_BOT_LEFT : 
    case VS_e_LFT_MIDD : vector[0] =  xLeft ; break ;
    case VS_e_TOP_MIDD :
    case VS_e_GEO_CENT : 
    case VS_e_BOT_MIDD : vector[0] = (xLeft + xRight) * 0.5 ; break ;
    case VS_e_UPP_RGHT :
    case VS_e_RGH_MIDD : 
    case VS_e_BOT_RGHT : vector[0] =  xRight ; break;
  }
  vector[0] *= -1.0;
  *msg = MSSUCC ;

/*
printf("Range %8.2f %8.2f, Vector0 %8.2f, Vector1 %8.2f\n",
  range[0],range[3],vector[0],vector[1]);
*/

wrapup : 

  return 1;
}

/* ---------------------------------------------------------
 * For envelopment placements, just returns the range points
 * For web alignment, find the two web segments (defined as the
 * two longest vertical segments) and returns the x value
 *
 * I actually wrote two versions, this one is like the original in
 * that it cycles through the componenet looking for the
 * longest vertical segments to call the web
 *
 * But just asking for the web segments give the same results
 */
#if 0
IGRlong VScardpoint_to_vector( 
  IGRlong              *msg, 
  struct GRmd_env      *curveENV, 
  struct GRid          *curveID, 
  IGRboolean           *profOpt, 
  enum VScardinal_point card, 
  IGRvector             vector 
)
{
  IGRlong     sts ;
  IGRboolean  wrt_world_ref ;
  GRrange     range ;
  IGRdouble   cvWidth,cvHeight ;
  IGRdouble   pts[9];

  IGRpoint    begPnt,midPnt,endPnt;
  IGRint      i,size;
  IGRint     *usrIndices = NULL;

  struct {
    IGRdouble x,len;
    IGRint    flag;
  } p1,p2;

  IGRdouble   xTmp,len;

  struct GRid cmpID;

  /* Compute profile curve range */
  wrt_world_ref = TRUE ; /* same matrix used anyway */
  sts = om$send(
    msg = message GRgraphics.GRgetrang(
      msg,
     &curveENV->_MATRIX_TYPE,
      curveENV->_MATRIX,
     &wrt_world_ref,
      range 
    ),
    senderid = curveID->objid,
    targetid = curveID->objid,
    targetos = curveID->osnum 
  );
  __CheckRC( sts, *msg, "GRvg.GRgetrang", wrapup ) ;

  cvHeight  = range[4] - range[1] ;
  cvWidth   = range[3] - range[0] ;

  // Z component is always 0
  vector[2] = 0.0;

  // Y Component is a function of cvHeight
  switch( card ) {
    case VS_e_UPP_LEFT :
    case VS_e_TOP_MIDD :
    case VS_e_UPP_RGHT : vector[1] = - cvHeight ; break ;
    case VS_e_LFT_MIDD :
    case VS_e_GEO_CENT :
    case VS_e_RGH_MIDD : vector[1] = - cvHeight * 0.5 ; break ;
    case VS_e_BOT_MIDD :
    case VS_e_BOT_RGHT :
    case VS_e_BOT_LEFT : vector[1] = 0.0 ; break ;
  }
  vector[1] = vector[1] - range[1] ;

  // For envelope, x component is a function of cvWidth
  if (*profOpt == 0) {
    switch( card ) {
      case VS_e_UPP_LEFT :
      case VS_e_BOT_LEFT : 
      case VS_e_LFT_MIDD : vector[0] = 0.0 ; break ;
      case VS_e_TOP_MIDD :
      case VS_e_GEO_CENT : 
      case VS_e_BOT_MIDD : vector[0] = -cvWidth * 0.5 ; break ;
      case VS_e_UPP_RGHT :
      case VS_e_RGH_MIDD : 
      case VS_e_BOT_RGHT : vector[0] = -cvWidth ; break;
    }
    vector[0] = vector[0] - range[0] ;
    *msg = MSSUCC ;
    goto wrapup;
  }

  // Return 0 on error
  vector[0] = 0.0;
  p1.flag = 0;
  p2.flag = 0;

  // Need to find vertical web components
  // Still not sure why we cannot just ask for web left or web right
  // But stick with for now 
  sts = om$send(
    msg = message VScompcurve.VSgetMapping(msg,&size,&usrIndices),
    senderid = curveID->objid,
    targetid = curveID->objid,
    targetos = curveID->osnum
  ) ;
  __CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup );

  // Check each component
  for(i = 0; i < size ; i ++ ) {
    sts = om$send(	
      msg = message VScompcurve.VStransUsrIxToCmp(
        msg,usrIndices[i],NULL,&cmpID
      ),
      senderid = curveID->objid,
      targetid = curveID->objid,
      targetos = curveID->osnum 
    ) ;
    __CheckRC( sts, *msg, "VScompcurve.VStransUsrIxToCmp", wrapup );
		
//  __DBGpr_obj("Components", cmpID);

    // Get the end points
    sts = om$send(  
      msg = message GRcurve.GRendpts(
         msg,
        &curveENV->_MATRIX_TYPE,
	 curveENV->_MATRIX,
	 begPnt,endPnt
      ),
      senderid = cmpID.objid,
      targetid = cmpID.objid,
      targetos = cmpID.osnum 
    );
    __CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

    // And the mid point
    sts = om$send(
      msg = message GRcurve.GRmidpoint(
        msg,
        &curveENV->_MATRIX_TYPE,
	 curveENV->_MATRIX,NULL,
	 midPnt
      ),
      senderid = cmpID.objid,
      targetid = cmpID.objid,
      targetos = cmpID.osnum 
    );
    __CheckRC( sts, *msg, "GRcurve.GRmidpoint", wrapup ) ;


    // Check for vertical line
    if ((fabs(begPnt[0]-midPnt[0]) < .001) &&
        (fabs(endPnt[0]-midPnt[0]) < .001)) {

      len = fabs(begPnt[1] - endPnt[1]);

      if (p1.flag == 0) {
        p1.x    = begPnt[0];
        p1.len  = len;
        p1.flag = 1;
      }
      else if (p2.flag == 0) {
        p2.x    = begPnt[0];
        p2.len  = len;
        p2.flag = 1;
      }
      else {

        // Replace the shortest one
        if (p1.len < p2.len) {
          if (p1.len < len) {
            p1.len = len;
            p1.x = begPnt[0];
          }
        }
        else {
          if (p2.len < len) {
            p2.len = len;
            p2.x = begPnt[0];
          }
        }
      }
    }
  }

  // Need at least one vertical element
  if (p1.flag == 0) {
    vector[0] = 0.0;
    *msg = MSFAIL;
    goto wrapup;
  }
  // I guess 1 is ok
  if (p2.flag == 0) {
    vector[0] = -p1.x;
    *msg = MSSUCC;
    goto wrapup;
  }
  if (p1.x > p2.x) {
    xTmp = p1.x;
    p1.x = p2.x;
    p2.x = xTmp;
  }

  sts = VSgetCmpPoints(curveID,curveENV,VS_K_sc_WebL,pts);
  if (sts != 1) goto wrapup;
  p1.x = pts[0];

  sts = VSgetCmpPoints(curveID,curveENV,VS_K_sc_WebR,pts);
  if (sts != 1) goto wrapup;
  p2.x = pts[0];

  switch( card ) {
    case VS_e_UPP_LEFT :
    case VS_e_BOT_LEFT : 
    case VS_e_LFT_MIDD : vector[0] =  p1.x ; break ;
    case VS_e_TOP_MIDD :
    case VS_e_GEO_CENT : 
    case VS_e_BOT_MIDD : vector[0] = (p1.x + p2.x) * 0.5 ; break ;
    case VS_e_UPP_RGHT :
    case VS_e_RGH_MIDD : 
    case VS_e_BOT_RGHT : vector[0] =  p2.x ; break;
  }
  vector[0] *= -1.0;
  *msg = MSSUCC ;

/*
printf("Range %8.2f %8.2f, Vector0 %8.2f, Vector1 %8.2f\n",
  range[0],range[3],vector[0],vector[1]);
*/

wrapup : 
  _FREE(usrIndices);
  return 1;
}
#endif

/* -------------------------------------------------
 * Returns the intersection of two lines
 * No longer required with the new routine
 */
#if 0
long VSgetIntPnt(	long		*msg ,
			struct GRid	line1,
			struct GRid	line2,
			struct GRmd_env *env,
			IGRpoint	intPnt )
{
	IGRpoint		stPntOfHor ;
	IGRpoint		edPntOfHor ;
	IGRpoint		stPntOfVer ;
	IGRpoint		edPntOfVer ;
	long			rc ;

	om$send(  msg     = message GRcurve.GRendpts(
						msg,
						&env->_MATRIX_TYPE,
						env->_MATRIX,
						stPntOfHor,
						edPntOfHor ),
			senderid = line1.objid,
			targetid = line1.objid,
			targetos = line1.osnum );
	__CheckRC( 1, *msg, "GRcurve.GRendpts", wrapup ) ;


	om$send(  msg     = message GRcurve.GRendpts(
						msg,
						&env->_MATRIX_TYPE,
						env->_MATRIX,
						stPntOfVer,
						edPntOfVer ),
			senderid = line2.objid,
			targetid = line2.objid,
			targetos = line2.osnum );
	__CheckRC( 1, *msg, "GRcurve.GRendpts", wrapup ) ;
	
	BSxln( 	&rc, stPntOfHor, edPntOfHor,stPntOfVer, edPntOfVer, intPnt );

wrapup :
	return ( *msg & 1 ) ;
}
#endif

/* ---------------------------------------------------------------------------
 * This routine is a good example of why programmers should not sniff glue.
 * It was origianlly developed to pick off physical flange end points then
 * severly and poorly hacked to to deal with web points.
 * it worked in some cases but failed for av_bulb.
 * 
 * The code really makes no sense so I cut it out
 */
#if 0
long VSgetCardinalPoints( 	msg, 		/* O: Return code	    */
				curve, 		/* I: profile curve	    */
				env, 		/* I: environ of the curve  */
				profileHeight,	/* I: Height of the profile */
				topCard, 	/* O: Top 3 cardinal points */
				botCard, 	/* O: Bottom 3 cardinal pnts*/
				midCard )	/* O: Middle 3 cardinal pnts*/
long                    *msg ;
struct GRid		*curve ;
struct GRmd_env		*env ;
double			profileHeight ;
IGRdouble		**topCard ;
IGRdouble		**botCard ;
IGRdouble		**midCard ;
{
	long		sts ;
	int		size,  *usrIndices = NULL ;
	int		i , maxCount , minCount, cnt;
	struct GRid	cmpId ;
	IGRpoint	stPnt, endPnt, midPnt;
	double		yMin, yMax ;
	IGRboolean	setYMax, setYMin ;
	double		tmp, tmp1 , ratio;
	double		len1, lengths[2], midPoint[2];
	struct GRid     verMem[2], horMem[2] ;
	
	yMin =  1000.0 ;
	yMax = -1000.0 ;
	cnt = 0;
	maxCount = minCount = 1;

	lengths[0] = 	lengths[1] = 0.0 ;

	setYMax = setYMin = FALSE ;

	tmp  = 0.0;
	tmp1 = 0.0;

verMem[0].objid = NULL_OBJID;
verMem[1].objid = NULL_OBJID;
horMem[0].objid = NULL_OBJID;
horMem[1].objid = NULL_OBJID;

	*botCard = (IGRdouble *) malloc ( 3 * sizeof( IGRdouble ) ) ;
	*topCard = (IGRdouble *) malloc ( 3 * sizeof( IGRdouble ) ) ;
	*midCard = (IGRdouble *) malloc ( 3 * sizeof( IGRdouble ) ) ;

	sts = om$send(	msg	= message VScompcurve.VSgetMapping(
						msg,
						&size,
						&usrIndices ),
			senderid = curve->objid,
			targetid = curve->objid,
			targetos = curve->osnum ) ;
	__CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup );

	for(i = 0; i < size ; i ++ ) {
		sts = om$send(	msg = message VScompcurve.VStransUsrIxToCmp (
							msg,
							usrIndices[i],
							NULL,
							&cmpId),
				senderid = curve->objid,
				targetid = curve->objid,
				targetos = curve->osnum ) ;
		__CheckRC( sts, *msg, "VScompcurve.VStransUsrIxToCmp", wrapup );
		
		__DBGpr_obj("Components", cmpId );

		sts = om$send(  msg     = message GRcurve.GRendpts(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							stPnt,
							endPnt ),
				senderid = cmpId.objid,
				targetid = cmpId.objid,
				targetos = cmpId.osnum );
		__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

  printf("VSshowComp %4d %8.2f,%8.2f,%8.2f %8.2f,%8.2f,%8.2f\n",
    cmpId.objid,stPnt[0],stPnt[1],stPnt[2],endPnt[0],endPnt[1],endPnt[2]
  );
	
		sts = om$send(  msg     = message GRcurve.GRmidpoint(
						msg,
						&env->_MATRIX_TYPE,
						env->_MATRIX,
						NULL,
						midPnt),
				senderid = cmpId.objid,
				targetid = cmpId.objid,
				targetos = cmpId.osnum );
		__CheckRC( sts, *msg, "GRcurve.GRmidpoint", wrapup ) ;
		/*
		 * Check if the component is horizontal.
		 * If horizontal store the end points and the 
		 * middle points
		 */
		if( (stPnt[1]  == endPnt[1] ) && 
		    (endPnt[1] == midPnt[1] ) )  {
			if( stPnt[1] >= yMax ) {
				if( stPnt[1] ==  yMax )	{
					maxCount++ ;
					continue ;
				}
				yMax = stPnt[1];
				setYMax = TRUE ;
				/*
				(*topCard)[0] = endPnt[0] < stPnt[0] ? 
							endPnt[0] : stPnt[0] ;
				(*topCard)[1] = midPnt[0] ;
				(*topCard)[2] = endPnt[0] > stPnt[0] ? 
							endPnt[0] : stPnt[0] ;
				*/
				tmp = ( stPnt[0]  < endPnt[0] ) ?
							stPnt[0] : endPnt[0] ;
				
				maxCount = 1;
				horMem[0] = cmpId ;
			}
			if ( stPnt[1] <= yMin ) {
				if( stPnt[1] ==  yMin ) {
					double		tmpPoint ;

					minCount++ ;
					tmpPoint = ( stPnt[0]  < endPnt[0] ) ? 
							stPnt[0] : endPnt[0] ;
					tmp1 = ( tmp1 < tmpPoint ) ? 
							tmp1 : tmpPoint;
					continue ;
				}
				yMin = stPnt[1];
				setYMin = TRUE ;
		/* 
		 * Commented. Keeping thing if the support want to revert to
		 * to the cardinal points on the detail representation profile.
		 *  

				(*botCard)[0] = endPnt[0] < stPnt[0] ? 
							endPnt[0] : stPnt[0] ;
				(*botCard)[1] = midPnt[0] ;
				(*botCard)[2] = endPnt[0] > stPnt[0] ? 
							endPnt[0] : stPnt[0] ;
		*/
				tmp1 = ( stPnt[0]  < endPnt[0] ) ? 
							stPnt[0] : endPnt[0] ;
				minCount = 1;
				horMem[1] = cmpId ;
			}
		} else 	if( (stPnt[0]  == endPnt[0] ) && 
		    	    (endPnt[0] == midPnt[0] ) )  {
			sts = om$send(  msg  = message GRcurve.GRtotlength(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							&len1),
					senderid = cmpId.objid,
					targetid = cmpId.objid,
					targetos = cmpId.osnum );
			__CheckRC( sts, *msg, "GRcurve.GRtotlength", wrapup ) ;
			ratio = len1/profileHeight ;
printf("Vert %d %f %d\n",cmpId.objid,ratio,cnt);
			if( ratio >= 0.3)
			{


				if( cnt > 1 )
				{
					/*
					 * Get rid of the smallest one
					 */
					if( lengths[0] < len1 ) {
						lengths[0] = len1 ; 
						midPoint[0] = midPnt[0];
						verMem[0] = cmpId ;
					}
					else if(lengths[1] < len1 ) {
						lengths[1] = len1;
						midPoint[1] = midPnt[0];
						verMem[1] = cmpId ;
					}
				} else {
					/*
					 * store mid Point
					 */
					lengths[cnt] = len1;
					midPoint[cnt] = midPnt[0];
					verMem[cnt]  = cmpId ;
				}
				cnt++ ;
			}
		}
	}
	/*
	 * Added code for getting the cardinal points along 
	 * web left and web right
	 */
	{
	IGRpoint webAl0, webAl1, webAl2, webAl3 ;

verMem[1].osnum = verMem[0].osnum;
verMem[1].objid = 1269;

	VSgetIntPnt( msg, horMem[0], verMem[0], env, webAl0 );


	VSgetIntPnt( msg, horMem[0], verMem[1], env, webAl1 );


	(*topCard)[0] = webAl1[0] < webAl0[0] ? webAl1[0] : webAl0[0] ;
	(*topCard)[1] = ( webAl0[0] + webAl1[0] )/2 ;
	(*topCard)[2] = webAl1[0] > webAl0[0] ? webAl1[0] : webAl0[0] ;

	VSgetIntPnt( msg, horMem[1], verMem[0], env, webAl2 );

	VSgetIntPnt( msg, horMem[1], verMem[1], env, webAl3 );

	(*botCard)[0] = webAl3[0] < webAl2[0] ? webAl3[0] : webAl2[0] ;
	(*botCard)[1] = ( webAl2[0] + webAl3[0] )/2 ;
	(*botCard)[2] = webAl3[0] > webAl2[0] ? webAl3[0] : webAl2[0] ;

	}
	if( setYMax && setYMin ) {
		IGRdouble	tmpPoint ;
		
		tmpPoint = ( tmp < tmp1 ) ? tmp : tmp1 ;

		for(i=0; i<3; i++ ) {
			(*topCard)[i] =  (*topCard)[i]  - tmpPoint ;
			(*botCard)[i] =  (*botCard)[i]  - tmpPoint ;
		}

		if( maxCount > 1 )
			_FREE( *topCard );
		if( minCount > 1 )
			_FREE( *botCard );

		if( cnt > 1 ){

			tmp = ( midPoint[0] < midPoint[1] ) ? 
						      midPoint[0] : midPoint[1];
			tmp1= ( midPoint[0] > midPoint[1] ) ? 
						      midPoint[0] : midPoint[1];

			midPoint[0] = tmp  - tmpPoint ;
			midPoint[1] = tmp1 - tmpPoint ;
		
			(*midCard)[0] = midPoint[0] ;
			(*midCard)[1] = ( midPoint[0] + midPoint[1] ) * 0.5 ; 
			(*midCard)[2] = midPoint[1] ;
		} else {
			_FREE( *midCard ) ;
		}
		*msg = MSSUCC ;
	} else {
		*msg = MSFAIL ;
	}

wrapup :
	if( !( sts & *msg & 1 ) ) {
		_FREE( *topCard ) ;
		_FREE( *midCard ) ;
		_FREE( *botCard ) ;
	}
	_FREE( usrIndices );
	return sts;
} /* VSgetCardinalPoints */
#endif

/* ----------------------------------------------------------------------
 * Replaced with new routine
 */
#if 0
long VScardpoint_to_vectorX( msg, env, curve, profOpt, card, vector )

long			*msg ;
struct GRmd_env		*env ;
struct GRid		*curve ;
IGRboolean		*profOpt ;
enum VScardinal_point	card ;
IGRvector		vector ; {

	long		sts ;
	IGRboolean	wrt_world_ref ;
	GRrange		range ;
	double		cvWidth,
			cvHeight ;
	IGRdouble	midPoint[3];
	int		i ;
	IGRdouble	topPoint[3], botPoint[3];
	IGRdouble	*top, *bot , *mid;
	/*
	 * Compute its range.
	 */
	wrt_world_ref = TRUE ; /* same matrix used anyway */
	sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
        						&env->_MATRIX_TYPE,
							env->_MATRIX,
							&wrt_world_ref,
							range ),
			senderid = curve->objid,
			targetid = curve->objid,
			targetos = curve->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetrang", wrapup ) ;

	cvHeight  = range[4] - range[1] ;
	cvWidth   = range[3] - range[0] ;

	if( !(*profOpt ) )  goto ENVELOP_CARD ;
	top = bot = mid = NULL ;
	sts =  VSgetCardinalPoints(	msg, 
					curve, 
					env, 
					cvHeight, 
					&top, 
					&bot, 
					&mid);
	if( ( sts & *msg & 1 ) )
	{
		/*
		 * Curve is in xy-plane of world co-ordinates, its main 
		 * axes are the x- and y-axis.
		 */
		if( top ) {
			__DBGpr_com("Top Point Exists \n");
			for( i = 0; i< 3  ; i++ ) {
				topPoint[i] = top[i] ;
printf("Top %d %f\n",i,top[i]);
			}
		} else {
			__DBGpr_com("Top Point Doesnt Exists \n");
			topPoint[0] = 0.0 ;
			topPoint[1] = 0.5 * cvWidth ;
			topPoint[2] = 1.0 * cvWidth ;
		}
		if( bot ) {
			__DBGpr_com("Bot Point Exists \n");
			for( i = 0; i< 3  ; i++ ) {
				botPoint[i] = bot[i] ;
printf("Bot %d %f\n",i,bot[i]);
			}
		} else {
			__DBGpr_com("Bot  Point Doent Exists \n");
			botPoint[0] = 0.0 ;
			botPoint[1] = 0.5 * cvWidth ;
			botPoint[2] = 1.0 * cvWidth ;
		}
		if( mid ) {		
		__DBGpr_com("Mid Point Exists \n");
			for( i = 0; i< 3  ; i++ ) {
				midPoint[i] = mid[i] ;
			}
		} else {
			__DBGpr_com("Mid  Point Doent Exists \n");
			midPoint[0] = 0.0 ;
			midPoint[1] = 0.5 * cvWidth ;
			midPoint[2] = 1.0 * cvWidth ;
		}
		switch( card ) {
			case VS_e_UPP_LEFT : vector[0] = -topPoint[0]; break;
			case VS_e_BOT_LEFT : vector[0] = -botPoint[0]; break;
			case VS_e_LFT_MIDD : vector[0] = -midPoint[0]; break;
			case VS_e_TOP_MIDD : vector[0] = -topPoint[1]; break;
			case VS_e_BOT_MIDD : vector[0] = -botPoint[1]; break;
			case VS_e_GEO_CENT : vector[0] = -midPoint[1]; break;
			case VS_e_UPP_RGHT : vector[0] = -topPoint[2]; break;
			case VS_e_BOT_RGHT : vector[0] = -botPoint[2]; break;
			case VS_e_RGH_MIDD : vector[0] = -midPoint[2]; break ;
		}

		vector[0] = vector[0] - range[0] ;
		_FREE( top ) ;
		_FREE( mid ) ;
		_FREE( bot ) ;
	} else {
		IGRchar mesg[80];
		
		*profOpt = FALSE ;
		
		sprintf(mesg,"Detail Profile option is not valid for this cross-section");

		ex$message(	msgnumb	      = VS_gE_DetOptInv,
				field         = ERROR_FIELD,
				justification = CENTER_JUS );

		VS_Wait_timer( 60 );

ENVELOP_CARD	:
		switch( card ) {
			case VS_e_UPP_LEFT :
			case VS_e_BOT_LEFT : 
			case VS_e_LFT_MIDD : vector[0] = 0 ; break ;
			case VS_e_TOP_MIDD :
			case VS_e_GEO_CENT : 
			case VS_e_BOT_MIDD : vector[0] = -cvWidth * 0.5 ; break ;
			case VS_e_UPP_RGHT :
			case VS_e_RGH_MIDD : 
			case VS_e_BOT_RGHT : vector[0] = -cvWidth ; break;
		}

		vector[0] = vector[0] - range[0] ;
		*msg = MSSUCC ;
	}
	switch( card ) {
		case VS_e_UPP_LEFT :
		case VS_e_TOP_MIDD :
		case VS_e_UPP_RGHT : vector[1] = - cvHeight ; break ;
		case VS_e_LFT_MIDD :
		case VS_e_GEO_CENT :
		case VS_e_RGH_MIDD : vector[1] = - cvHeight * 0.5 ; break ;
		case VS_e_BOT_MIDD :
		case VS_e_BOT_RGHT :
		case VS_e_BOT_LEFT : vector[1] = 0 ; break ;
	}
	vector[1] = vector[1] - range[1] ;
	vector[2] = 0 ;

printf("Vector %f %f %f\n",vector[0],vector[1],vector[2]);

	wrapup : 
		return sts ;

} /* VScardpoint_to_vector */
#endif

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VScardpt_to_vector( env, macro, profOpt, card, vector ) 

struct GRmd_env		*env ;
struct GRid		macro ;
IGRboolean		*profOpt ;
enum VScardinal_point	card ;
IGRvector		vector ; {

	long			sts,
				msg,
				rc = FALSE ;
	struct GRobj_env	curve ;

	/*
	 * Get cross-section curve (simplified).
	 */
	if( *profOpt ) 
		sts = VSextractCachedSection( &msg, &macro, AC_3D_REP, &curve );
	else 
		sts = VSextractCachedSection( &msg, &macro, AC_2D_REP, &curve );
	

	if( sts & 1 & msg ) {
		sts = VScardpoint_to_vector(	&msg,
						&curve.mod_env,
						&curve._grid,
						profOpt,
						card,
						vector ) ;
		if( sts & 1 & msg ) rc = TRUE ;
	}
	return rc ;

} /* VScardpt_to_vector */

/* ------------------------------------------- */
/* Gets Points for Curve */
IGRlong VSgetCmpPoints(
  struct      GRid *curve, 
  struct      GRmd_env *env, 
  int         cmpIndex, 
  IGRdouble *pts)       // Beg Mid End 
{
  IGRlong retFlag = 0;
  IGRlong sts,msg;
  IGRdouble swap;

  struct GRid cmpId;
 
  sts = om$send(
    msg = message VScompcurve.VStransUsrIxToCmp (
      &msg,
      cmpIndex,
      NULL,
      &cmpId
    ),
    senderid = curve->objid,
    targetid = curve->objid,
    targetos = curve->osnum 
  );
  if (!(sts & msg & 1)) {
    printf("Get Indexed Component Failed\n");
    goto wrapup;
  }

  sts = om$send(  
    msg = message GRcurve.GRendpts(
      &msg,
      &env->md_env.matrix_type,
       env->md_env.matrix,
      &pts[0],
      &pts[6]
    ),
    senderid = cmpId.objid,
    targetid = cmpId.objid,
    targetos = cmpId.osnum 
  );
  if (!(sts & msg & 1)) {
    printf("Get GRcurve.GRendpts Failed\n");
    goto wrapup;
  }
  sts = om$send(  
    msg = message GRcurve.GRmidpoint(
      &msg,
      &env->md_env.matrix_type,
       env->md_env.matrix,
       NULL,
      &pts[3]
    ),
    senderid = cmpId.objid,
    targetid = cmpId.objid,
    targetos = cmpId.osnum 
  );
  if (!(sts & msg & 1)) {
    printf("Get GRcurve.GRmidpoint Failed\n");
    goto wrapup;
  }

  /* Order either horz or vertically */
  if ( (fabs(pts[0]-pts[3]) < .001) && (fabs(pts[3]-pts[6]) < .001) ) {

    if (pts[1] > pts[7]) {
      swap   = pts[1];
      pts[1] = pts[7];
      pts[7] = swap;
    }
  }
  if ( (fabs(pts[1]-pts[4]) < .001) && (fabs(pts[4]-pts[7]) < .001) ) {

    if (pts[0] > pts[6]) {
      swap   = pts[0];
      pts[0] = pts[6];
      pts[6] = swap;
    }
  }
/*
printf("Component %d\n",cmpIndex);
printf("   %8.2f %8.2f %8.2f\n",pts[0],pts[1],pts[2]);
printf("   %8.2f %8.2f %8.2f\n",pts[3],pts[4],pts[5]);
printf("   %8.2f %8.2f %8.2f\n",pts[6],pts[7],pts[8]);
*/
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------- */
/* Returns X values of web components              */
/* Assume longest vertical component is the web    */

long VSgetProfileCardinalPoint(
  struct GRid     *curve,
  struct GRmd_env *env,     
  enum   VScardinal_point card,
  IGRpoint		  point
)   
{
  IGRlong retFlag = 0;
  IGRlong sts;
	
  IGRdouble pts[9];
  IGRdouble xLft,xMid,xRgt;
  IGRdouble yBot,yMid,yTop;

  point[0] = 0.0;
  point[1] = 0.0;
  point[2] = 0.0;

  sts = VSgetCmpPoints(curve,env,VS_K_sc_WebL,pts);
  if (sts != 1) goto wrapup;
  xLft = pts[0];

  sts = VSgetCmpPoints(curve,env,VS_K_sc_WebR,pts);
  if (sts != 1) goto wrapup;
  xRgt = pts[0];

  xMid = (xLft + xRgt) * .5;

  sts = VSgetCmpPoints(curve,env,VS_K_sc_FlgInfE,pts);
  if (sts != 1) goto wrapup;
  yBot = pts[1];

  sts = VSgetCmpPoints(curve,env,VS_K_sc_FlgSupE,pts);
  if (sts != 1) goto wrapup;
  yTop = pts[1];

  yMid = (yBot + yTop) * .5;

  switch(card) {
    case VS_e_UPP_LEFT : point[0] = xLft; point[1] = yTop; break;
    case VS_e_BOT_LEFT : point[0] = xLft; point[1] = yBot; break;
    case VS_e_LFT_MIDD : point[0] = xLft; point[1] = yMid; break;

    case VS_e_TOP_MIDD : point[0] = xMid; point[1] = yTop; break;
    case VS_e_BOT_MIDD : point[0] = xMid; point[1] = yBot; break;
    case VS_e_GEO_CENT : point[0] = xMid; point[1] = yMid; break;

    case VS_e_UPP_RGHT : point[0] = xRgt; point[1] = yTop; break;
    case VS_e_BOT_RGHT : point[0] = xRgt; point[1] = yBot; break;
    case VS_e_RGH_MIDD : point[0] = xRgt; point[1] = yMid; break ;
  }
	
  retFlag = 1;

wrapup :

  return retFlag;
}

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VScardpoint_to_point( msg, env, curve, profOpt, card, point )

long			*msg ;
struct GRmd_env		*env ;
struct GRid		*curve ;
IGRboolean		*profOpt ;
enum VScardinal_point	card ;
IGRpoint		point ; 
{
  long        sts ;
  IGRboolean  wrt_world_ref ;
  GRrange     range ;

  if (*profOpt) {
    *msg = 1;
    sts = VSgetProfileCardinalPoint(curve,env,card,point);
    if (sts == 1) return sts;
  }

  /*
   * Compute its range.
   */
  wrt_world_ref = TRUE ; /* same matrix used anyway */
  sts = om$send(
    msg = message GRgraphics.GRgetrang(
      msg,
     &env->_MATRIX_TYPE,
      env->_MATRIX,
     &wrt_world_ref,
      range 
    ),
    senderid = curve->objid,
    targetid = curve->objid,
    targetos = curve->osnum 
  );
  __CheckRC( sts, *msg, "GRvg.GRgetrang", wrapup ) ;

  switch( card ) {
    case VS_e_UPP_LEFT :
    case VS_e_LFT_MIDD :
    case VS_e_BOT_LEFT : 
      point[0] = range[0] ;
      break ;

    case VS_e_TOP_MIDD :				     
    case VS_e_GEO_CENT :
    case VS_e_BOT_MIDD : 
      point[0] = ( range[0] + range[3] ) * 0.5 ;
      break ;

    case VS_e_UPP_RGHT :
    case VS_e_RGH_MIDD :
    case VS_e_BOT_RGHT : 
      point[0] = range[3] ;
      break ;
  }

  switch( card ) {
    case VS_e_UPP_LEFT :
    case VS_e_TOP_MIDD :
    case VS_e_UPP_RGHT : point[1] = range[4] ; break ;

    case VS_e_LFT_MIDD :
    case VS_e_GEO_CENT :
    case VS_e_RGH_MIDD : 
      point[1] = ( range[1] + range[4] ) * 0.5 ;
      break ;

    case VS_e_BOT_MIDD :
    case VS_e_BOT_RGHT :
    case VS_e_BOT_LEFT : 
      point[1] = range[1] ; 
      break ;
  }
  point[2] = 0 ;

  wrapup : return sts ;

} /* VScardpoint_to_point */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
long VScardpt_to_point( env, macro, profOpt, card, point ) 

struct GRmd_env		*env ;
struct GRid		macro ;
IGRboolean		*profOpt ;
enum VScardinal_point	card ;
IGRpoint		point ; {

	long			sts,
				msg,
				rc = FALSE ;
	struct GRobj_env	curve ;

	/*
	 * Get cross-section curve (simplified).
	 */
	if( *profOpt ) 
		sts = VSextractCachedSection( &msg, &macro, AC_3D_REP, &curve );
	else 
		sts = VSextractCachedSection( &msg, &macro, AC_2D_REP, &curve );

	if( sts & 1 & msg ) {
		sts = VScardpoint_to_point(	&msg,
						&curve.mod_env,
						&curve._grid,
						profOpt,
						card,
						point ) ;
		if( sts & 1 & msg ) rc = TRUE ;
	}
	return rc ;

} /* VScardpt_to_point */

/*----------------------------------------------------------------------------*/
long VSmapProfileToSite( msg, cst, mapMx, mxType, copy, originPrfl, onSitePrfl )

long			*msg ;
struct GRvg_construct	*cst ;
IGRmatrix		mapMx ;
short			*mxType ;
int			copy ;
struct GRobj_env	*originPrfl ;
struct GRid		*onSitePrfl ; {

/*
 * This function interfaced by macro vs$mapProfileToSite.
 */
	long       sts ;

	if( copy ) {
		sts = vs$grCopy(	msg	= msg,
					frEnv	= &originPrfl->mod_env,
					frObj	= &originPrfl->_grid,
					toEnv	= cst->env_info,
					toObj	= onSitePrfl ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	} else {
		*onSitePrfl = originPrfl->_grid ;
	}

	sts = om$send(	msg	= message GRgraphics.GRxform(
							msg,
							cst->env_info,
							mxType,
							mapMx,
							&onSitePrfl->objid ),
			senderid= onSitePrfl->objid,
			targetid= onSitePrfl->objid,
			targetos= onSitePrfl->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup ) ;

	/*
	 * Now change the display and level of the profile.
	 */
	VSchangeSymbology( msg, onSitePrfl, cst->level, cst->display ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		 return sts ;

} /* VSmapProfileToSite */

/*---------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
/* ACC bug : won't accept ANSI declaration with args inside and definition
   with args outside a la K&R C when an arg has type (unsigned) char: here
   rep causes it to choke...
 */
long VSextractCachedSection(	long			*msg,
				struct GRid		*xDef,
				VSdspRep		rep,
				struct	GRobj_env 	*xSectCv )
#else
long VSextractCachedSection( msg, xDef, rep, xSectCv )

long			*msg ;
struct GRid		*xDef ;
VSdspRep		rep ;
struct	GRobj_env 	*xSectCv ;
#endif

{
/*
Abstract :
        Get the graphic object of the foot name corresponding to the display
        representation "rep" of macro "xDef".
*/

	long	sts ;
	long	rc ;
	char	*fname ;

	switch( rep ) {
		case VS_m_2dSurface	:
		case AC_2D_REP		: fname = VS_K_SchematicCv	; break;
		case VS_m_3dWFillet	: fname = VS_K_WFilletCv	; break;
		case AC_3D_REP		: fname = VS_K_WoFilletCv	; break;
		case AC_ENV_REP		: fname = VS_K_EnvelopeCv	; break;
		default			: *msg = MSINARG ;
					  sts  = OM_E_INVARG ; goto wrapup ;
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							&rc,
							fname,
							&xSectCv->_grid,
							&xSectCv->_matrix_type,
							xSectCv->_matrix ),
			senderid= xDef->objid,
			targetid= xDef->objid,
			targetos= xDef->osnum );
	*msg = rc ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	xSectCv->_md_os = xSectCv->_osnum ;
	ex$get_modid(	mod_osnum	= xSectCv->_osnum,
			mod_id		= &xSectCv->_md_id ) ;

	wrapup : return sts ;

} /* VSextractCachedSection */

end implementation VSbeam ;
