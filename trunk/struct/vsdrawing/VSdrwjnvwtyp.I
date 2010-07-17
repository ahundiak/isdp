/*
	I/STRUCT
*/

class implementation VSjoint ;

#include <malloc.h>
#include "bstypes.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsjointdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
long VSdrwGetViewTypeFromJoint( msg, inp, xData )

long		*msg ;		/* OUT : completion code	*/
VSdrwInputData	*inp ;		/* I/O : input data		*/
VSdrwExecData	*xData ; {	/* IN  : execution data		*/

	long			sts ;
	struct GRid		*jnId ;		/* Id of joint		*/
	struct GRmd_env 	*jnEnv ;	/* Mod. env. of joint	*/
	double			*viewVector ;	/* View vector		*/
	int			i,		/* Loop index		*/
				jnCvCount ;
	struct GRid		jnGroup,
				firstCurve ;
	struct IGRbsp_curve	*cvGeom	= NULL ;
	IGRpoint		eval[2] ;
	VSdrwInputData		locInp ;
	VSdrwExecData		locxData ;
	VSdrwViewType		vw ;

	jnId		= inp->elmId ;
	jnEnv		= inp->elmEnv ;
	viewVector	= inp->drwInfo.viewVector ;
	vw		= VSunknownViewType ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, VS_K_jnGrCmpName,
						&jnGroup, NULL, NULL ),
			senderid= NULL_OBJID,
			targetid= jnId->objid,
			targetos= jnId->osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(	msg	= message GRowner.GRget_components(
							msg,
							jnEnv,
							&firstCurve,
							1,
							&jnCvCount,
							0,
							0 ),
			senderid= NULL_OBJID,
			targetid= jnGroup.objid,
			targetos= jnGroup.osnum ) ;
	__CheckRC( sts, *msg, "GRowner.GRget_components", wrapup ) ;

	if( !jnCvCount ) goto wrapup ;

	vs$get_geometry(	msg	= msg,
				grobjId	= &firstCurve,
				grobjEnv= jnEnv,
				geometry= &cvGeom ) ;
	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	BScveval( cvGeom, 0., 1, (IGRpoint *) eval, msg ) ;

	if( VScolinearVectors( eval[1], viewVector ) ) {
		vw = VSendOn ;
	} else if( VSorthoVectors( eval[1], viewVector ) ) {

		struct GRobj_env	elm[2] ;
		unsigned long		type[2] ;
		VSdrwViewType		vt[2] ;
		int			v2 ;

		/*
		 * Decide on top, bottom, side by using the view type of the
		 * first or second welded element.
		 */
		sts = om$send(	msg	= message VSjoint.VSgetJoinedFeatures(
						msg, elm + 0, elm + 1, NULL ),
				senderid= jnId->objid,
				targetid= jnId->objid,
				targetos= jnId->osnum ) ;
		__CheckRC( sts, *msg, "VSjoint.VSgetJoinedFeatures", wrapup ) ;

		for( i = 0 ; i < 2 ; i++ ) {
			sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, type + i ),
					senderid= elm[i]._objid,
					targetid= elm[i]._objid,
					targetos= elm[i]._osnum ) ;
			__CheckRC( sts, *msg, "VSjoint.VSgetResultType", wrapup ) ;

			locInp 		= *inp ;
			locxData	= *xData ;
			locInp.elmId	= &elm[i]._grid ;
			locInp.elmEnv	= &elm[i].mod_env ;

			if( type[i] & VS_m_BEAM ) {

	       			VSdrwGetViewTypeFromBeam(	msg,
								&locInp,
								&locxData ) ;

			} else if( type[i] & VS_m_PLATE ) {

		       		VSdrwGetViewTypeFromPlate(	msg,
								&locInp,
								&locxData ) ;
			}
			vt[i] = locInp.viewType ;
		}

		v2 = (int) vt[0] & (int) vt[1] ;

		if(  (type[0] & VS_m_PLATE) && (type[1] & VS_m_PLATE) ) {

			     if( v2 & (int) VSfromTop    ) vw = VSfromTop ;
			else if( v2 & (int) VSfromBottom ) vw = VSfromBottom ;
			else				   vw = VSfromSide ;

		} else if(  (type[0] & VS_m_PLATE) && (type[1] & VS_m_BEAM )
		          ||(type[1] & VS_m_PLATE) && (type[0] & VS_m_BEAM ) ) {

			     if( v2 & (int) VSfromTop    ) vw = VSfromTop ;
			else if( v2 & (int) VSfromBottom ) vw = VSfromBottom ;
			else				   vw = VSfromSide ;

		} else if(  (type[0] & VS_m_BEAM ) && (type[1] & VS_m_BEAM ) ) {

			if( v2 & (int) VSendOn   )
			     	if( (int) VSendOn == v2 ) {
			     		vw = VSfromTop ;
			     	} else {
			     		v2 &= ~ (int) VSendOn ;
			     		vw = (VSdrwViewType) v2 ;
			     	}
			else if( v2 & (int) VSfromTop    ) vw = VSfromTop ;
			else if( v2 & (int) VSfromBottom ) vw = VSfromBottom ;
			else				   vw = VSfromSide ;

		}
	} else {
		vw = VSfromSide ;
	}

	wrapup :
		inp->viewType = vw ;

		*msg = MSSUCC ;
		_FREE( cvGeom ) ;
		return *msg & 1 ;

} /* VSdrwGetViewTypeFromJoint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

