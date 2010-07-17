/*
	I/STRUCT

	When dynamically loaded, this file overrides the behavior of method
	"NDdrawing_copy_geom" of class "ACncpx" to invoke the Drawing Extraction
	setup file so that users may configurate how macro occurrence should
	be extracted from the model to the drawing sheet. The software to read
	and interpret the Drawing Extraction setup file is in I/STRUCT, hence
	the need for this override.

	NOTE : this dynamic-load override will have no effect if the executable
	image $MODEL/bin/Model has been stripped.
*/
class implementation ACncpx ;

#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "growner.h"
#include "vsdef.h"
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
#include "vsdrwproto.h"
#include "vsvecmxproto.h"
/*----------------------------------------------------------------------------*/
static long VS_ACncpx_NDdrawing_copy_geom(	construction,
						selected_elements,
						nb_elements,
						outList,
						outCount,
						vector,
						point,
						levelMask,
						lbsys,
						from_env,
						to_env )
struct GRid	*construction ;
struct GRid	*selected_elements ;
int		nb_elements ;
struct GRid	**outList ;
int		*outCount ;
double		*vector,
		*point ;
int		*levelMask ;
struct IGRlbsys *lbsys ;
struct GRmd_env *from_env,
		*to_env ; {

	long			sts,
				msg ;
	struct IGRplane		drawingPlane,
				viewPlane ;
	struct GRsymbology	mySymb ;
	IGRvector		viewVector ;
	IGRpoint		viewPoint ;

	*outCount	= 0 ;
	*outList	= NULL ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( &msg, &mySymb ),
			senderid= construction->objid,
			targetid= construction->objid,
			targetos= construction->osnum ) ;
	__CheckRC( sts, msg, "message GRvg.GRgetsymb", wrapup ) ;

	if( DPlevel_check( mySymb.level, levelMask ) ) {

		VSdrwOutputData		*output = NULL ;
		
		drawingPlane.point	= point ;
		drawingPlane.normal	= vector ;
		
		viewPlane.point		= VSmxorigin( lbsys->matrix, 
		 				      viewPoint ) ;
		viewPlane.normal	= vector ;

		VSvccpy( viewVector, vector ) ;

		sts = vs$drwExecConfig(	msg		= &msg,
					elmId		= construction,
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

} /* VS_ACncpx_NDdrawing_copy_geom */
/*----------------------------------------------------------------------------*/
method NDdrawing_copy_geom(	struct GRid	*selected_elements ;
				int		nb_elements ;
				struct GRid	**drawing_elements ;
				int		*nb_drawing_elem ;
				double		*vector,
						*point ;
				int		*levelMask ;
				struct IGRlbsys *lbsys ;
				struct GRmd_env *from_env,
						*to_env ) {

	struct GRid moi ;
	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	return VS_ACncpx_NDdrawing_copy_geom(	&moi,
						selected_elements,
						nb_elements,
						drawing_elements,
						nb_drawing_elem,
						vector,
						point,
						levelMask,
						lbsys,
						from_env,
						to_env ) ;

} /* method NDdrawing_copy_geom */
/*----------------------------------------------------------------------------*/

end implementation ACncpx ;
