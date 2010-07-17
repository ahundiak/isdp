/*
	I/ROUTE	Copy

	When dynamically loaded, this file overrides the behavior of method
	"NDdrawing_copy_geom" of class "ACncpx" to invoke the Drawing Extraction
	setup file so that users may configurate how macro occurrence should
	be extracted from the model to the drawing sheet. The software to read
	and interpret the Drawing Extraction setup file is in I/VDS & I/STRUCT,
	hence the need for this override.

	NOTE : this dynamic-load override will have no effect if the executable
	image $MODEL/bin/Model has been stripped.

	Manyam	12/21/94	Creation
*/
class implementation VRGeneric;

#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "growner.h"
#include "v_def.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "vdvisdef.h"
#include "vdvismacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_vecmxproto.h"

/*----------------------------------------------------------------------------*/
static long VR_ACncpx_NDdrawing_copy_geom(	construction,
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
		*to_env ; 
{

	long			sts,
				msg ;
	IGRchar			*fileName ;
	GRname			setup_file ;
	struct	GRid		drwId ;
	struct IGRplane		drawingPlane,
				viewPlane ;
	struct GRsymbology	mySymb ;
	IGRvector		viewVector ;
	IGRpoint		viewPoint ;

	SetProc( VD_ACncpx_NDdrawing_copy_geom ); Begin

        if( *outCount && *outList ){

                /*
                 * See if filename has been specified, by looking into the
                 * collect of the resulting object.
                 * If nothing is specified give the NULL string.
                 */
                drwId = *outList[0] ;
                vd_$visGetCollInfo(     msg     = &msg,
                                        elmId   = &drwId,
                                        name    = VD_Ks_VIS_DRW_SETUP,
                                        value   = setup_file );
                if( msg&1 ){
                        fileName = setup_file ;
			printf("fileName : %s \n", fileName );
                }
        }


	*outCount	= 0 ;
	*outList	= NULL ;

	sts = om$send(	msg	= message GRvg.GRgetsymb( &msg, &mySymb ),
			senderid= construction->objid,
			targetid= construction->objid,
			targetos= construction->osnum ) ;
	__CheckRC( sts, msg, "message GRvg.GRgetsymb", wrapup ) ;

	if( DPlevel_check( mySymb.level, levelMask ) ) {

		VD_drwOutputData		*output = NULL ;
		
		drawingPlane.point	= point ;
		drawingPlane.normal	= vector ;
		
		viewPlane.point		= VD_mxorigin( lbsys->matrix, 
		 				      viewPoint ) ;
		viewPlane.normal	= vector ;

		VD_vccpy( viewVector, vector ) ;

		sts = vd_$drwExecConfig(msg		= &msg,
					elmId		= construction,
					elmEnv		= from_env,
					drwPlane	= &drawingPlane,
					viewPlane	= &viewPlane,
					viewVector	= viewVector,
					drwEnv		= to_env,
					drwLbsys	= lbsys,
					selCount	= nb_elements,
					selList		= selected_elements,
                        filename = ( fileName ) ? fileName : NULL ,
					output		= &output ) ;

		if( sts & 1 & msg ) {
			int		n	= 0 ;
			VD_drwOutputData	*p	= output ;
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
			VD_drwFreeOutputData( &output ) ;
		}

	} else sts = OM_S_SUCCESS ;

	wrapup :

		End
		return OM_S_SUCCESS ;

} /* VR__ACncpx_NDdrawing_copy_geom */
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
						*to_env ) 
{

struct GRid		moi ;
int			status;

	SetProc( NDdrawing_copy_geom ); Begin

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;

	__DBGpr_obj( "my_id", moi );

	status = VR_ACncpx_NDdrawing_copy_geom(&moi,
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

	End
	return status;

} /* method NDdrawing_copy_geom */
/*----------------------------------------------------------------------------*/

end implementation VRGeneric;
