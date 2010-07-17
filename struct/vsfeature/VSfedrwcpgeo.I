/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
#include "vsdrwproto.h"
/*----------------------------------------------------------------------------*/
method NDdrawing_copy_geom(	struct GRid	*selected_elements ;
				int		nb_elements ;
				struct GRid	**outList ;
				int		*outCount ;
				double		*vector,
						*point ;
				int		*levelMask ;
				struct IGRlbsys *lbsys ;
				struct GRmd_env *from_env,
						*to_env ) {

	long			sts,
				msg ;
	struct GRsymbology	mySymb ;

	*outCount	= 0 ;
	*outList	= NULL ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( &msg, &mySymb ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "GRvg.GRgetsymb", wrapup ) ;

	if( DPlevel_check( mySymb.level, levelMask ) ) {

		struct IGRplane		drawingPlane,
					viewPlane ;
		IGRvector		viewVector ;
		IGRpoint		viewPoint ;
		struct GRid		moi ;
		VSdrwOutputData		*output = NULL ;

		drawingPlane.point	= point ;
		drawingPlane.normal	= vector ;
		
		viewPlane.point		= VSmxorigin( lbsys->matrix, 
		 				      viewPoint ) ;
		viewPlane.normal	= vector ;

		VSvccpy( viewVector, vector ) ;

		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;

		/*
		 * Invoke Drawing Extraction Language Interpreter.
		 */
		sts = vs$drwExecConfig(	msg		= &msg,
					elmId		= &moi,
					elmEnv		= from_env,
					drwPlane	= &drawingPlane,
					viewPlane	= &viewPlane,
					viewVector	= viewVector,
					drwEnv		= to_env,
					drwLbsys	= lbsys,
					selCount	= nb_elements,
					selList		= selected_elements,
					output		= &output ) ;
		if( sts & 1 & msg ) {
			int		n	= 0 ;
			VSdrwOutputData	*p	= output ;
			while( p ) { n += p->set.count ; p = p->next ; }

			if( n ) {
				*outList = _MALLOC( n, struct GRid ) ;
				if( *outList ) {
					n = 0 ;
					p = output ;
					while( p ) {
						int i ;
						int max = p->set.count ;
						struct GRid *l = p->set.list ;
						for( i = 0 ; i < max ; i++ ) {
							(*outList)[n++] = l[i] ;
						}
						p = p->next ;
					}
					*outCount = n ;
				}
			}
			VSdrwFreeOutputData( &output ) ;
		}

	} else sts = OM_S_SUCCESS ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method NDdrawing_copy_geom */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

