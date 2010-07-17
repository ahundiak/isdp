/* $Id: VSimposbndry.I,v 1.3 2001/02/14 21:17:23 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSimposbndry.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSimposbndry.I,v $
 *      Revision 1.3  2001/02/14 21:17:23  ramarao
 *      Modifications Related to SetProc() macro.
 *
 *      Revision 1.2  2001/01/16 23:41:54  ramarao
 *      *** empty log message ***
 *
# Revision 1.3  2000/05/23  00:22:40  pinnacle
# Replaced: struct/vsgeom/VSimposbndry.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/05/05  13:59:12  pinnacle
# Replaced: struct/vsgeom/VSimposbndry.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/27  18:52:46  pinnacle
# Created: struct/vsgeom/VSimposbndry.I by rchennup for Service Pack
#
# Revision 1.5  1999/12/06  19:40:16  pinnacle
# tr179900842
#
# Revision 1.3  1999/06/16  15:55:20  pinnacle
# (No comment)
#
# Revision 1.2  1999/06/01  18:55:34  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/12/16  20:46:54  pinnacle
# Tolerance Cleanup
#
# Revision 1.2  1997/09/26  14:39:28  pinnacle
# Tolerance Problem
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      09/26/97  ah      added header
 *      09/26/97  ah	  added tolerance adjustments better failure message
 *	12/16/97  ah      Cleaned up the tolerance code
 *	05/31/99  Ming    Modify code for creating Modify Operator command
 *	10/01/99  bkeesara TR179900842 calling VSptinbx if range of bndry is 
 *	                    covers the surface range
 *      05/22/00  Jayadev TR179901551, TR179901550, TR179901543, TR179901496
 *                        EMMapBnd_NoClip option added for imposing process
 ***************************************************************************/

class implementation EMSsubbs ;

#include <stdlib.h>
#include <math.h>
#include "msdef.h"
#include "growner.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "EMStypedef.h"
#include "EMSopt.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "EMSdef.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "vspart.h"
#include "bserr.h"
#include "vsplatedef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"



/*
 * Inludes of function prototypes.
 */
#include "bsptinbx.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "EMSutlmacros.h"


from EMSloopset		import	EMget_loops ;
from EMSloop		import	EMtoggle_type,
				EMtreemod ;
from EMSboundary	import	EMarea ;

from expression         import NDgive_value;
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GRbspline_class_id;
extern OMuword	OPP_GR3dlineseg_class_id;

/* ----------------------------------------------------
 * Looks in :fil::IGENOD:tolerance directory for the
 * tolName object and if found, returns the value
 * Returns 0 if not found
 */ 
int VSgetVariableTolerance(IGRchar *tolName, IGRdouble *adjust)
{
  char        chtName[DI_PATH_MAX];
  struct GRid chtId;

  long sts;

  GRspacenum osnum;
  IGRdouble value;

  *adjust  = 1.0;
  *chtName = 0;

  ex$get_cur_mod(osnum = &osnum);
  di$give_pathname(osnum = osnum, pathname= chtName ) ;

  strcat(chtName,":IGENOD:tolerance:");
  strcat(chtName,tolName);

  sts = di$translate(
    objname =  chtName,
    p_osnum = &chtId.osnum,
    p_objid = &chtId.objid
  );

  if (!(sts & 1)) return 0;

  value = 1.0;
  sts = om$send(
    msg = message expression.NDgive_value(&value),
    senderid = NULL_OBJID,
    targetid = chtId.objid,
    targetos = chtId.osnum
  );
  if (!(sts & 1)) return 0;

  *adjust = value;

  return 1;
}

/* ----------------------------------------------
 * Wrapper function for the impose boundary
 * Chord height tolerance
 */
int VSgetImpBoundCht(IGRdouble *adjust) {

  return VSgetVariableTolerance("VSimpBoundCht",adjust);

}

IGRboolean VSinfLineInBox( IGRlong	*msg,
			   IGRdouble	*point,
			   IGRdouble    *vector,
			   IGRdouble    *inp_range  )
{
IGRint		i;
IGRdouble 	radius=1e-6, org[3], dir[3], range[6], tlo, thi, ttemp,
		para_low=-1e+6, para_high=1e6;

    // step 1. expand box diagonal on both ends by the radius of the ray.
    for( i=0; i<3; ++i )
	range[i] = inp_range[i] - radius;

    for( i=3; i<6; ++i )
        range[i] = inp_range[i] + radius;

    // step 2. move ray to boxes  unit cube space.
    range[3] -= range[0];
    range[4] -= range[1];
    range[5] -= range[2];

    for( i=0; i<3; ++i ) org[i] = ( point[i] - range[i] ) / range[i+3] ;
    for( i=0; i<3; ++i ) dir[i] = vector[i] / range[i+3] ;

    for( i=0; i<3; ++i )
    {
	tlo = ( 1 - org[i] ) / dir[i] ;
	thi = ( -1 * org[i] ) / dir[i] ;

	if( tlo > thi )
	{
	   ttemp = tlo;
           tlo   = thi;
           thi   = ttemp;
	}

	if( tlo > para_low)
            para_low = tlo;
        if (thi < para_high)
            para_high = thi;

        if (para_high < para_low)
            return FALSE;
    }

    return TRUE;
}

/*----------------------------------------------------------------------------*/
static long VSfindPointInArea( msg, surface, bndryCount, bndryList, uv_pm )

long			*msg ;
struct GRobj_env	*surface ;
int			bndryCount ;
struct GRobj_env	bndryList[] ;
double			*uv_pm ; {
	
	long		sts ;
	int		i,
			havePt,
			nd = 3 ;
	unsigned int	attempt_no ;
	double		*rangeList = NULL,
			ptInArea[3] ,
			surfRangeList[6], tol = 0.001;
	struct EMparms	params ;
	short		world = TRUE ;
	
	/*
	 * Get range of boundaries.
	 */
	/* By Ming for Modify Operator command */
	if( bndryCount > 0 )
	  if( !( rangeList = _MALLOC( bndryCount*6, double ) ) ) vs$mem_fail() ;
	for( i=0; i<bndryCount; i++ ) {
	  sts = om$send( msg      = message GRgraphics.GRgetrang(
	    msg,
	    &bndryList[i]._matrix_type,
	    bndryList[i]._matrix,
	    &world,
	    rangeList+(6*i) ),
			 senderid = bndryList[i]._objid,
			 targetid = bndryList[i]._objid,
			 targetos = bndryList[i]._osnum ) ;
	  __CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
	}
	/*
	 * Find point in area.
	 */
	
	sts = om$send( msg      = message GRgraphics.GRgetrang(
	  msg,
	  &surface[0]._matrix_type,
	  surface[0]._matrix,
	  &world,
	  surfRangeList ),
		       senderid = surface[0]._objid,
		       targetid = surface[0]._objid,
		       targetos = surface[0]._osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
	
	/*  Check if the surface range is within the boundary range if so we have a problem */      
        if( 			 BSptinbx( msg, 
					   surfRangeList, 
					   rangeList, 
					   rangeList+3,
					   &nd )   &&  
				 BSptinbx( msg, 
					   surfRangeList+3, 
					   rangeList, 
					   rangeList+3,
					   &nd )
	) {
	  sts = VSptinbx(msg, surface, &bndryCount, bndryList,  uv_pm); 
	  if(!(sts & 1)){ goto wrapup; }
	  else{
	    goto jump;
	  }
	  
	  /* get the geometry of the range of the curve */
	}
	
	havePt     = FALSE ;
	attempt_no = 0 ;
	
	while( !havePt ) {
	  sts = om$send( msg      = 
			 message EMSsubbs.EMget_point_on_surface(
			   msg,
			   &surface->mod_env,
			   attempt_no,
			   1,
			   ptInArea,
			   &params ),
			 senderid = surface->_objid,
			 targetid = surface->_objid,
			 targetos = surface->_osnum ) ;	       
	  __CheckRC( sts, *msg, "EMSsubbs.EMget_point_on_surface", wrapup ) ;
	  
	  for( i=0; i<bndryCount; i++ )
	    if( VSinfLineInBox( msg,
                          	ptInArea,
				params.normal,
                          	rangeList+(6*i) ) ) break;
/*
	    if( BSptinbx( msg, 
			  ptInArea, 
			  rangeList+(6*i), 
			  rangeList+(6*i)+3,
			  &nd )) break;
*/
	  
	  if( i == bndryCount ) {
	    havePt = TRUE ;
	    uv_pm[0] = params.u ;
	    uv_pm[1] = params.v ;
	  } else  attempt_no++ ;
	}
	
        jump :
	  sts  = OM_S_SUCCESS ;
	  *msg = MSSUCC ;
	
	wrapup :
	  _FREE( rangeList ) ;
	return sts ;
	
} /* VSfindPointInArea */

/*----------------------------------------------------------------------------*/
IGRint VSptinbx(msg, surface, bndryCount, bndryList, uv)
long               *msg;
struct GRobj_env   *surface;
int                *bndryCount;
struct GRobj_env   bndryList[];
IGRdouble          *uv;{
  
  struct IGRbsp_curve  *cv;
  BSrc                 rc;
  struct GRid	         *contour_id;
  struct  GRvg_construct  cnst;
  int                  i, jj, j, val[2];
  IGRint               sts, ind;
  IGRlong		siz=0;
  IGRdouble           param1 = 0.5,
    param2 = 0.75,
    ptInArea[3] ,
    t[11], tol = 0.01;
  IGRboolean          planar = TRUE, havePt;			
  unsigned int	attempt_no ;
  struct EMparms	params ;
  unsigned char		edCvType ;
  OMuword			edCvClassid ;
  short		world = TRUE ;
  IGRdouble           rangelist[6];
  IGRdouble           points[33];
  IGRdouble		TMat[3][3], TVec[3], NewZ[3], scale;
  IGRboolean		OrientKnow, Orient;
  IGRpoint		newpt;
  
  for( i = 0 ; i < *bndryCount ; i++ ) {
    cv = NULL;
    /* Get locate object size */
    sts = om$send ( msg = message GRvg.GRgetsize (
      msg,
      &bndryList[i]._matrix_type,
      bndryList[i]._matrix,
      &siz ),
		    senderid = NULL_OBJID,
		    targetid = bndryList[i]._objid,
		    targetos = bndryList[i]._osnum );
    if (!(sts&1&(*msg))) {
      EFmsgReport ( 0, sts,  "GRvg.GRgetsize");
      EFmsgReport ( 0, *msg, "GRvg.GRgetsize");
      goto wrapup;
    }
    
    /* Allocate memory for Bspline curve */
    cv = (struct IGRbsp_curve *) om$malloc (size = siz);
    cv->poles = NULL; cv->knots = NULL;
    cv->weights = NULL; cv->bdrys = NULL;
    
    /* get the geometry of the Bspline curve */
    sts = om$send ( msg = message GRvg.GRgetgeom (
      msg,
      &bndryList[i]._matrix_type,
      bndryList[i]._matrix,
      (IGRchar *) cv ),
		    senderid = NULL_OBJID,
		    targetid = bndryList[i]._objid,
		    targetos = bndryList[i]._osnum ); 
    if(cv->poles == NULL || cv->knots == NULL){ 
      goto wrapup;
    }
    /* NewZ is the unit normal vector to the planar curve */
    
    BScvnormal(&rc, cv, NewZ) ;
    if(rc != BSSUCC) goto wrapup;
    
    /* TMat will be the rotation matrix to transform to a new cs
     * with z axis is given by NewZ    */
    
    BStrans2(NewZ, TRUE, TMat, &rc);
    if(rc != BSSUCC) goto wrapup;
    
    TVec[0] = 0; TVec[1] = 0; TVec[2] = 0;
    scale = 1;
    
    /* transform the curve in the new cs (TVec,TMat,scale), now the
     * curve is on xy plane */
    BScvoton(&rc, TVec, TMat, &scale, cv, cv);
    if(rc != BSSUCC) goto wrapup;
    
    
    havePt     = FALSE ;
    attempt_no = 0 ;
    
    while( !havePt ) {
      sts = om$send( msg      = 
		     message EMSsubbs.EMget_point_on_surface(
		       msg,
		       &surface->mod_env,
		       attempt_no,
		       1,
		       ptInArea,
		       &params ),
		     senderid = surface->_objid,
		     targetid = surface->_objid,
		     targetos = surface->_osnum ) ;	       
      __CheckRC( sts, *msg, "EMSsubbs.EMget_point_on_surface", 
		 wrapup ) ;
      
      
      /* project the point onto local xy plane */
      
      BSptoldtnw(&rc, TVec, TMat, &scale, ptInArea, newpt);
      if(rc != BSSUCC) goto wrapup;
      
      /* determine the position of the point */
      
      OrientKnow = FALSE;
      BSpt_in_cv(cv, newpt, OrientKnow, &Orient, &ind, &rc);
      if(rc != BSSUCC) goto wrapup;
      if( ind == 0){
	havePt = TRUE ;
	uv[0] = params.u ;
	uv[1] = params.v ;
	
      }else attempt_no++;
      
    }
    sts  = OM_S_SUCCESS ;
    *msg = MSSUCC ;
    _FREE(cv);
  }
  
  wrapup :
    _FREE(cv);
  return sts;
  
}
/*----------------------------------------------------------------------------*/
long VSimpose_boundaries( msg, surface, bndryCount, bndryList, sfIsPlanar )

long			*msg ;
struct GRobj_env	bndryList[],
			*surface ;
int			bndryCount,
			sfIsPlanar ; {

/*
 * This function is interfaced by macro vs$imposeBoundaries.
 */
	long		sts,	/* OM return code		*/
			msg1,		/* Impose error message		*/
			mapOptions ;	/* For impose-boundary		*/
#define MAX VS_K_MAX_BOUNDARIES
	struct IGRbsp_curve
			*bndryGeom[MAX];/* Boundaries' geometries	*/
	int		i ;		/* Loop index			*/
	double		in_uv[2] ;	/* Area uv of surface.          */

struct {
  int flag;
  double org;
  double new;
  double adjust;
} cht;

        SetProc( VSimpose_boundaries ); Begin

        cht.flag = VSgetImpBoundCht(&cht.adjust);

        if (cht.flag) 
        {
            gr$get_chord_height_tolerance( sizbuf = sizeof(cht.org), 
					   buffer = &cht.org);
            cht.new = cht.org * cht.adjust;
        }

	*msg = msg1 = MSSUCC ;
	for( i = 0 ; i < MAX ; i++ ) bndryGeom[i] = NULL ;

	sts = VSfindPointInArea( msg, surface, bndryCount, bndryList, in_uv ) ;
	__CheckRC( sts, *msg, "VSfindPointInArea", wrapup ) ;

	sfIsPlanar = 0 ;

	if( bndryCount > VS_K_MAX_BOUNDARIES ) bndryCount = VS_K_MAX_BOUNDARIES;

	for( i = 0 ; i < bndryCount ; i++ ) {
		
		sts = vs$get_geometry( msg 	= msg,
				       grobjId  = &bndryList[i]._grid,
				       grobjEnv = &bndryList[i].mod_env,
				       geometry = bndryGeom+i ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;
	}
	/*
	 * Allow clipping (do not put  EMMapBnd_NoClip) since data may overlap
	 * the surface's natural boundary.
	 */
	mapOptions =   EMMapBnd_WantBadCurves
		     | EMMapBnd_StrokeIfNeeded
		     | EMMapBnd_WantStatMsg|EMMapBnd_NoClip ;
	if( sfIsPlanar ) mapOptions |= EMMapBnd_SurfIsPlane ;
	
	/*
	 * Bug in EMS : If boundaries are on the same object space but have
	 * different environments ( same boundary in references files ).
	 * Using argument 'info' of message, EMS compute geometry with a bad
	 * environment. So, give geometry of boundaries to the message.
	 */

        if (cht.flag) 
	{
  	    gr$put_chord_height_tolerance( sizbuf = sizeof(cht.new), 
				 	   buffer = &cht.new);
        }

	sts = om$send(	msg	= message EMSsurface.EMimpose_boundaries(
							msg,
							bndryCount,
			(struct IGRbsp_curve *)		bndryGeom,	
							NULL,
							in_uv,	
			/* No area: unused here	*/	TRUE,	
							&surface->mod_env,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							mapOptions,
							EMImpBnd_NoStateTree,
							NULL ),
			senderid= surface->_objid,
			targetid= surface->_objid, 
			targetos= surface->_osnum ) ;
if (cht.flag) {
  gr$put_chord_height_tolerance(sizbuf = sizeof(cht.org), buffer = &cht.org);
}
	if(	*msg == EMS_E_Fail
	     || *msg == EMS_E_InvalidArg
	     || *msg == EMS_I_NoMoreLoops ) {
		/*
		 * There is a boundary overlapping the surface's natural
		 * boundary: re-send message without auto-nest option and no
		 * point in area: this will result in the loopset being split
		 * in all possible regions: we later decide which loop to
		 * remove.
		 */
		OM_S_CHANSELECT		toLoopSet ;
		int			maxInt		= OM_K_MAXINT,
					size		= 0,
					loopCount	= 0,
					delLoopCount	= 0,
					j ;
		OM_S_OBJID		*loopList	= NULL,
					*delLoopList	= NULL ;
		struct EMSpartolbasis	partolbasis ;
		double			a, amax = 0 ;
if (cht.flag) {
  gr$put_chord_height_tolerance(sizbuf = sizeof(cht.new), buffer = &cht.new);
}

		sts = om$send(	msg	= message EMSsurface.EMimpose_boundaries(
							msg,
							bndryCount,
				(struct IGRbsp_curve *) bndryGeom,	
							NULL,
			/* No point in area	*/	NULL,
			/* No area: unused here	*/	TRUE,	
							&surface->mod_env,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							mapOptions,
							EMImpBnd_NoStateTree,
							NULL ),
				senderid= surface->_objid,
				targetid= surface->_objid, 
				targetos= surface->_osnum ) ;

if (cht.flag) {
  gr$put_chord_height_tolerance(sizbuf = sizeof(cht.org), buffer = &cht.org);
}

		if( !( sts & 1 & *msg ) ) {

/*
printf("WARNING: EMSsurface.EMimpose_boundaries failed in VSimposeBoundaries\n");
printf("This means that one of the surfaces did not get processed!\n");
printf("But I am not going to tell you which one cause I don't know!\n");
printf("Might try changing the chord height tolerance\n");
*/
			/* Failed again: desperate ! */
			msg1 = EMS_E_Fail ;
		} else if( *msg == EMS_I_NoMoreLoops ) {
			/*
			 * Not all boundaries valid to impose: probably some
			 * or all of them outside of surface's natural boundary:
			 * accept result anyway.
			 * Should behavior be wanted to be different (ie. err
			 * if not all boundaries imposed ), replaace the two
			 * following lines by :
			 *
			 *	*msg	= EMS_E_NoMoreLoops ;
			 *	sts	= OM_W_ABORT ;
			 *	goto wrapup ;
			 */

/*
printf("WARNING: EMSsurface.EMimpose_boundaries returned EMS_I_NoMoreLoops\n");
printf("while in VSimposeBoundaries\n");
printf("This means that one of the surfaces did not get processed!\n");
printf("But I am not going to tell you which one cause I don't know!\n");
printf("Might try changing the chord height tolerance\n");
*/
/*
			*msg	= MSSUCC ;
			sts	= OM_S_SUCCESS ;
*/
			msg1 = EMS_E_Fail ;
		}

		/*
		 * Get loop set, then get all loops.
		 */
		ems$make_chanselect( chan_label    = EMSsubbs_to_loopset,
				     chan_selector = &toLoopSet ) ;

		sts = om$send(	msg	= message EMSloopset.EMget_loops(
								msg,
								EMS_OPT_ALL,
				/* Depth		*/	&maxInt,
				/* List of loops	*/	&loopList,
				/* Propreties		*/	NULL,
				/* Size of buffer	*/	&size,
				/* Count of loops	*/	&loopCount ),
				senderid	= surface->_objid,
				targetos	= surface->_osnum,
				p_chanselect	= &toLoopSet ) ;
		__CheckRC( sts, *msg, "EMSloopset.EMget_loops", theEnd ) ;

		j = 0 ;
		for( i = 0 ; i < loopCount ; i++ ) {
			a = 0 ;
			sts = om$send(	msg	= message EMSboundary.EMarea(
								msg, &a ),
					senderid= loopList[i],
					targetid= loopList[i],
					targetos= surface->_osnum ) ;
			if( !( sts & 1 & *msg ) ) a = 0 ;

			if( ( a = fabs( a ) ) > amax ) {
				j	= i ;
				amax	= a ;
			}
		}

		/*
		 * Make loop to keep a P-loop, all other loops will become
		 * C-loops, and ask for the list of deletable loops.
		 */
		sts = om$send(	msg	= message EMSloop.EMtoggle_type(
							msg,
			/* Make it a P-loop	*/	TRUE,
			/* Make it non-deletable*/	FALSE,
			/* Sender id		*/	surface->_objid,
			/* Option list		*/	EMTogType_SendInner
							| EMTogType_SendOuter
							| EMTogType_SendAdjacent
							| EMTogType_NoAction,
			/* # of toggled loops	*/	NULL,
			/* List of toggled loops*/	NULL,
			/* # of deletable loops	*/	&delLoopCount,
			/* List of the above	*/	&delLoopList,
			/* Internal use		*/	NULL,
			/* Internal use		*/	NULL ),
				senderid= surface->_objid,
				targetid= loopList[j],
				targetos= surface->_osnum ) ;
		__CheckRC( sts, *msg, "EMSloop.EMtoggle_type", theEnd ) ;

		/*
		 * Now get rid of the deletable loops.
		 */
		partolbasis.is_valid = FALSE ;
		for( i = 0 ; i < delLoopCount ; i++ ) {

			sts = om$send(	msg	= message EMSloop.EMtreemod(
								msg,
								NULL,
								DELETE,
								&partolbasis ),
					senderid= surface->_objid,
					targetid= delLoopList[i],
					targetos= surface->_osnum ) ;
			__CheckRC( sts, *msg, "EMSloop.EMtreemod", theEnd ) ;
		}

		theEnd :
			if( loopCount	) _FREE( loopList	) ;
			if( delLoopCount) _FREE( delLoopList	) ;
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;
	if((msg1 == EMS_E_Fail) || (msg1 == EMS_E_InvalidArg)) {
		__DBGpr_com(" Problem in impsoe_boundaries ");
		*msg = msg1  ;
		//*msg = MSFAIL  ;
		sts = OM_W_ABORT; 
	}

	wrapup :
		for( i = 0 ; i < bndryCount ; i++ ) _FREE( bndryGeom[i] ) ;
		End
		return sts ;

} /* VSimpose_boundaries */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
