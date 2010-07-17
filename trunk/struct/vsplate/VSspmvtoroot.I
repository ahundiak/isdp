/*
	I/STRUCT
*/
class implementation VSsrcPlate ;

#include "nddef.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
method NDmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ) {

	long			sts ;
	struct 	GRid		MY_GRid ;

	MY_GRid.objid = my_id;
	MY_GRid.osnum = OM_Gw_current_OS ;

	/*
         * This object cannot live without parents: move-to-root means delete:
         * undisplay yourself then put yourself on the delete-batch queue.
         */ 

	sts = vs$bulk_display(	count  = 1,
                                dpmode = GRbe,
                                grids  = &MY_GRid,
                                theEnv = myEnv ) ;

	sts = nd$wait_batch(	type 		= GR_DELETED, 
				l_object 	= &MY_GRid, 
				nb_obj 		= 1 ) ;
	 return sts ;

} /* method NDmove_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSsrcPlate ;
