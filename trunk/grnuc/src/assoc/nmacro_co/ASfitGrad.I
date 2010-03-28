class implementation ASgradMac ;

#include <stdio.h>
#include "OMindex.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "csmacros.h"
#include "AS_status.h"

#define AS_DEBUG

from module	import	GRmod_passon ;
from GRgraphics	import  GRaddwrng,
			GRremwrng ;

extern 		MAidmx() ;
extern double	MAdabs() ;

struct get_stat_arg_st {
	OM_p_RTREESTAT	rtree_stat ;
	int		*ret ;
} ;

/*----------------------------------------------------------------------------*/
method DPfit( long *msg ; int notUsed ) {

	long			sts ;
	int			ret_code,
				debut,
				fin,
				in_flags ;
	double			range[6],
				rng_delta,
				x_delta,
				y_delta,
				z_delta ;
	struct GRmd_env		md_env ;
	struct GRid		gragad,
				csbase ;
	OM_S_RTREESTAT		rtree_info ;
	struct get_stat_arg_st	get_stat_arg ;
	OM_S_MESSAGE		get_stat_msg ;

	sts  = OM_S_SUCCESS ;

	/*
	 * Get range of the R-tree.
	 */
		/*
		 * Make message to retrieve range informations.
		 */
	get_stat_arg.rtree_stat = &rtree_info ;
	get_stat_arg.ret	= &ret_code ;

	rtree_info.request_type 		 = RTREE_PAGE_STATUS ;
	rtree_info.rtree_status.page.level_no	 = 0 ;

	*msg = MSFAIL ;

	sts = om$make_message( classname	= "GRrtree",
			       methodname	= "get_stat",
			       size		= sizeof( struct get_stat_arg_st ),
			       p_arglist	= &get_stat_arg,
			       p_msg		= &get_stat_msg ) ;

	as$status( sts = sts, action = GOTO_VALUE, value = wrapup ) ;

		/*
		 * Retrieve module environement of the gragad.
		 */
	md_env.md_id.osnum	= OM_Gw_current_OS ;

	ex$get_modid( mod_osnum = md_env.md_id.osnum,
		      mod_id	= &md_env.md_id.objid ) ;

	/*"Module env : [%d,%d]\n", md_env.md_id.osnum, md_env.md_id.objid*/
	
	md_env.md_env.matrix_type = 2 ;
	MAidmx( msg, md_env.md_env.matrix ) ;

		/*
		 * Before asking about range of the R-tree, remove the
		 * base coordinate from the R-tree.
		 */
	sts = cs$get_active_info( msg 	 = msg,
				  osnum  = md_env.md_id.osnum,
			 	  module = md_env.md_id.objid,
			          objid  = &csbase.objid ) ;
			          
	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	
	csbase.osnum = md_env.md_id.osnum ;
	
	/*"CS base : [%d,%d]\n", csbase.osnum, csbase.objid*/
	
	sts = om$send( msg      = message GRgraphics.GRremwrng( msg, 
							        &md_env ),
	               targetid = csbase.objid,
	               targetos = csbase.osnum ) ;
	               
	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

		/*
		 * Retrieve range of the R-tree.
		 */
	debut	= 0 ;
	fin	= 0 ;

	sts = om$send( msg	= message module.GRmod_passon( msg,
							       &get_stat_msg,
							       "primary",
							       &debut,
							       &fin ),
		       targetid = md_env.md_id.objid,
		       targetos = md_env.md_id.osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	
		/*
	 	 * Add base coordinate to the R-tree.
	 	 */
	sts = om$send( msg      = message GRgraphics.GRaddwrng( msg, 
							        &md_env ),
	               targetid = csbase.objid,
	               targetos = csbase.osnum ) ;
	               
	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;
	
	/*
	 * Adjust range to view volume.
	 */
	range[0] = rtree_info.rtree_status.page.page_range.r3ddkey.xmin ;
	range[1] = rtree_info.rtree_status.page.page_range.r3ddkey.ymin ;
	range[2] = rtree_info.rtree_status.page.page_range.r3ddkey.zmin ;
	range[3] = rtree_info.rtree_status.page.page_range.r3ddkey.xmax ;
	range[4] = rtree_info.rtree_status.page.page_range.r3ddkey.ymax ;
	range[5] = rtree_info.rtree_status.page.page_range.r3ddkey.zmax ;
	
	/*"min of range R-tree : %g %g %g\n", range[0], range[1], range[2]*/
	/*"max of range R-tree : %g %g %g\n", range[3], range[4], range[5]*/

	x_delta = range[3] - range[0] ;
    	y_delta = range[4] - range[1] ;
    	z_delta = range[5] - range[2] ;

	x_delta = MAdabs( msg, &x_delta ) ;
	y_delta = MAdabs( msg, &y_delta ) ;
	z_delta = MAdabs( msg, &z_delta ) ;
	
	/*"x delta : %g\n", x_delta*/
	/*"y delta : %g\n", y_delta*/
	/*"z delta : %g\n", z_delta*/
	
		/*
		 * Search the greater delta.
		 */
     	if( x_delta > y_delta ) {
	    	if( x_delta > z_delta ) {
	    		/*|x delta greater*/
	    	     	rng_delta = x_delta ;
	    	} else {
	    		/*|z delta greater*/
	    	     	rng_delta = z_delta ;
		}
    	} else {
	    	if( y_delta > z_delta ) {
	    		/*|y delta greater*/
	    	     	rng_delta = y_delta ;
	    	} else {
	    		/*|z delta greater*/
	    	 	rng_delta = z_delta ;
	    	}
	}	
		
	rng_delta *= 0.03 ;
	
	/*"range delta : %g\n", rng_delta*/
	
	range[0] -= rng_delta ;
	range[1] -= rng_delta ;
	range[2] -= rng_delta ;
	range[3] += rng_delta ;
	range[4] += rng_delta ;
	range[5] += rng_delta ;

	/*
	 * Set new view volume of the gragad.
	 */
	/*"view volume min : %g %g %g\n", range[0], range[1], range[2]*/
	/*"view volume max : %g %g %g\n", range[3], range[4], range[5]*/

	gragad.osnum = OM_Gw_current_OS ;
	gragad.objid = my_id ;

	in_flags =  FRONT_CLIP		|
		    BACK_CLIP		|
		    ACTIVE_Z_EDGE	|
		    WORLD_COOR		|
		    SETIN ;

	sts = dp$view_vol( msg		= msg,
			   in_flags	= in_flags,
			   gg_id	= &gragad,
			   vw_vol	= range,
			   update	= TRUE ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	wrapup :
	return sts ;

} /* DPfit */
/*----------------------------------------------------------------------------*/

end implementation ASgradMac ;
