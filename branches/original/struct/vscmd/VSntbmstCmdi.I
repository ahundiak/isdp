/*
	I/STRUCT
*/
class implementation VSntbmstCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "growner.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bserr.h"
#include "bsdistptpt.h"
#include "vsioproto.h"
#include "vsrangebxint.h"

from	NDmacro		import ACreturn_foot ;
from	GRgraphics	import GRconstruct, GRgetrang;
from	GRvg		import GRgetsymb ;

extern OMuword			OPP_GRcurve_class_id ;
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {
 
#define MAXOP VS_K_bbMAX_NOTCHES

	long		sts ;		/* OM return code		*/
	int		beamCount,	/* Count of input beams		*/
			notchCount,	/* Count of input notches	*/
			nbObj,		/* Count of located objects	*/
			i,ii,		/* Loop index			*/
			j,jj,		/* Loop index			*/
			maxOp,
			boolCount,	/* Counts bool. ops done	*/
			noAlloc ;	/* TRUE if malloc failed	*/
	struct GRobj_env
			*locatedObj,	/* All located objects		*/
			*beamList,	/* Located beams		*/
			*notchList,	/* Located notches		*/
			parent[MAXOP+1],
			*operator ;
					/* Of one boolean beam		*/
	GRrange   	objRng, cvRng;
	IGRboolean	world=TRUE;
	IGRdouble	maxDist[MAXOP];
	IGRdouble	AllMaxDist, d;

	struct GRobj_env*set1,		/* 1st set for check (beams)	*/
			*set2 ;		/* 2nd set for check (notches)	*/
	char		*mapping,	/* Beams/notches mapping array	*/
			buf[40] ;	/* Message buffer		*/
	struct GRvg_construct
			cst ;		/* Of boolean beams		*/
	struct VScnst_list
			attr ;		/* Class attr. of boolean beams	*/
	struct GRsymbology
			mySymb ;	/* My symbology			*/
	struct GRid	cylinder[MAXOP] ;
	char		cylsToDel[MAXOP]; /* Flags cyls to be deleted   */

	sts		= OM_S_SUCCESS ;
	set1		= NULL ;
	mapping		= NULL ;
	beamCount	= me->oprndCount ;
	notchCount	= me->oprtrCount ;
	nbObj		= beamCount + notchCount ;
	noAlloc		= FALSE ;
	memset ( cylsToDel, 0, MAXOP );

	if( !notchCount ) {
		me->ret = VS_K_NEED_OP ; return OM_S_SUCCESS ;
	}
	if( !( locatedObj = _MALLOC( nbObj, struct GRobj_env ) ) ) {
		noAlloc = TRUE ; goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
						msg, nbObj, locatedObj ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	beamList	= locatedObj ;
	notchList	= locatedObj + beamCount ;

	if( !( set1 = _MALLOC( nbObj, struct GRobj_env ) ) ) {
		noAlloc = TRUE ; goto wrapup ;
	}
	set2 = set1 + beamCount ;

	for( i = 0 ; i < notchCount ; i++ ) set2[i] = notchList[i] ;

	/*
	 * Get segments of beams.
	 */
	for( i = 0 ; i < beamCount ; i++ ) {
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_bmGrCmpName,
							&set1[i]._grid, 
							NULL, NULL ),
				targetid= beamList[i]._objid,
				targetos= beamList[i]._osnum ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		set1[i].mod_env = beamList[i].mod_env ;
	}
	/*
	 * For operators which are curves (supposed closed and planar),
	 * generate a cutting cylinder.
	 */
	for( i = 0 ; i < notchCount ; i++ ) 
		if( vs$is_ancestry_valid(
					object	= &notchList[i]._grid,
					classid = OPP_GRcurve_class_id ) ) {
		for ( j = 0; j < beamCount; j++ )  {
	sts = om$send(	msg	= message GRgraphics.GRgetrang(
						msg,
						&set1[j].mod_env.md_env.matrix_type,
						set1[j].mod_env.md_env.matrix,
						&world,
						objRng ),
			senderid= NULL_OBJID,
			targetid= set1[j]._objid,
			targetos= set1[j]._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	sts = om$send(	msg	= message GRgraphics.GRgetrang(
						msg,
						&set2[i].mod_env.md_env.matrix_type,
						set2[i].mod_env.md_env.matrix,
						&world,
						cvRng ),
			senderid= NULL_OBJID,
			targetid= set2[i]._objid,
			targetos= set2[i]._osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	maxDist[i] = 0 ;
	for( ii = 0 ; ii < 2 ; ii++ ) {
		for( jj = 0 ; jj < 2 ; jj++ ) {
			d = BSdistptpt( msg, objRng + 3 * ii, cvRng + 3 * jj ) ;
			if( d > maxDist[j] ) 
				maxDist[j] = d ;
		}
	}
	}
	
	AllMaxDist = maxDist[0];
	for ( j = 0; j < beamCount; j++ )  
		if( AllMaxDist <  maxDist[j] ) 
		{ AllMaxDist =  maxDist[j]; ii=j; }

	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),

			targetid= notchList[i]._objid,
			targetos= notchList[i]._osnum  ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(Cnst_list	= cst,
			  Msg		= msg,
			  Env_info	= &notchList[i].mod_env,
			  Display	= &mySymb.display_attr,
			  Level		= mySymb.level );

			sts = VSmakePenetratingCyl(	msg,
							&set1[i]._grid,
							&set1[i].mod_env,
							&notchList[i]._grid,
							&notchList[i].mod_env,
							&cst,
							&cylinder[i] ,
							NULL ) ;
			if( !( sts & 1 & *msg ) ) goto wrapup ;

		cylsToDel[i]	= TRUE ;
		set2[i]._grid	= cylinder[i] ;
		set2[i].mod_env	= *cst.env_info ;

	}


	if( !( mapping = _MALLOC( beamCount * notchCount, char ) ) ) {
		noAlloc = TRUE ; goto wrapup ;
	}

	sts = VSfindRngBoxInters( msg, beamCount, set1, notchCount, set2, TRUE,
					mapping ) ;
	__CheckRC( sts, *msg, "VSfindRngBoxInters", wrapup ) ;

	/*
	 * Fill construction list, do not specify the display parameters
	 * since object will take its parent part's.
	 */
	vs$fill_cnst_list(
			Cnst_list	= cst,
			Msg		= msg,
			Env_info	= &me->cstEnv,
			Display		= NULL,
			Level		= 0,
			Class_attr	= &attr ) ;

	attr.parent_list	= parent ;
	/*
	 * No specific attributes whatsoever.
	 */
	attr.feature_att	= NULL ;
	attr.representation	= AC_NO_REP ;

	me->constructedObject.osnum = me->cstEnv._MD_OS ;

	operator = parent + 1 ;

	/*
	 * Construct boolean beams with possibly intersection notching solids.
	 */
#define MAPPING( u, v )	(mapping[ (v) * beamCount + (u)])

	for( boolCount = i = 0 ; i < beamCount ; i++ ) {

		parent[0] = beamList[i] ;
		/*
		 * Gather parents ( `operators' ) for beam # i. Do not take more
		 * than MAXOP.
		 */
		for( j = maxOp = 0 ; j < notchCount && maxOp < MAXOP ; j++ ) {
			if( MAPPING( i, j ) ) {
				operator[maxOp++] = notchList[j] ;
			}
		}

		if( !maxOp ) continue ;

		/*
		 * We have a match between one beam and several notches.
		 * Which does not mean that the boolean operation will
		 * succeed anyway ...
		 */
		boolCount++ ;

		sprintf( buf, "%s # %d", VSmsgkey2string( VS_gI_Beam ),
			 boolCount ) ;
		ex$message(	msgnumb		= VS_gI_ProcessingSomething,
				type		= "%s",
				var		= `buf`,
				field		= PROMPT_FIELD,
				justification	= CENTER_JUS ) ;

		attr.parent_count = maxOp + 1 ;


		sts = om$construct(
			classname= me->const_class,
			osnum	 = me->cstEnv._MD_OS,
			p_objid	 = &me->constructedObject.objid,
			msg	 = message GRgraphics.GRconstruct( &cst ) ) ;
		if( sts & 1 & *msg ) {
			vs$bulk_display(count	= 1,
					grids	= &me->constructedObject,
					theEnv	= &me->cstEnv,
					dpmode	= GRbd ) ;
		} else {
			/*
			 * Beam and notche(s) did not all intersect.
			 * Go on with the rest.
			 */
			om$send(msg	= message VSpartopCmd.setErrorStatus(
								*msg, 2 ),
				targetid= my_id );
			*msg	= MSSUCC ;
			sts	= OM_S_SUCCESS ;
		}
	}

	wrapup :
	for( i = 0 ; i < MAXOP ; i++ ) {
		if( cylsToDel[i] ) {
			vs$bulk_delete( grids  = cylinder + i,
					theEnv = &me->cstEnv   );
		}
	}

		if( noAlloc )	me->ret = VS_K_ABORT_CMD ;
		else		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS
							 : VS_K_RESTART_CMD ;

		_FREE( locatedObj ) ; _FREE( set1 ) ; _FREE( mapping ) ;

		return OM_S_SUCCESS ;

#undef MAPPING
#undef MAXOP

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSntbmstCmd ;
