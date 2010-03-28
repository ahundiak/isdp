/* #######################    APOGEE COMPILED   ######################## */
/*

Abstract
        This method tells an object to prepare itself to 
	be clipped and connect to the owners channel.  If the
	object does not need to do any special preparation,
	the return code will be set to GRNO_PROCESSING_NEEDED.

	If the object needs to construct special objects for 
	plotting, the constructed objects are connected to
	the input objects channel (set_id).

	The construction of the objects should always be in 
	target_env object space.  In the case of reference 
	files, the master file is the target environment.  
	The set_id also resides master object space.

 GRplotprep(IGRlong *msg; struct GRmd_env *cur_env; 
       struct GRmd_env *target_env; IGRshort *num_prisms;
       struct IGRcv_prism *prism_array; struct GRid *set_id;
       IGRlong *begin_index, *end_index)

Arguments
	IGRlong	*msg			return code
				GRNO_PROCESSING_NEEDED - no special
					processing needed
				MSSUCC - method succeeded
	struct GRmd_env *cur_env	objects environment
	struct GRmd_env *target_env	environment for new objects
	IGRlong *num_prisms		number of prisms in array
	struct IGRcv_prism *prism_array prisms to be clipped against
	struct GRid *set_id		id for channel connection
	IGRlong	*begin_index		beginning channel index
					for connections
	IGRlong	*end_index		last index used for channel
					connections
*/
class implementation GRgraphics;

#include "grimport.h"
#include "grerr.h"
#include "godef.h"
#include "gocmacros.h"

method GRplotprep(IGRlong *msg; struct GRmd_env *cur_env; 
       struct GRmd_env *target_env; IGRshort *num_prisms;
       struct IGRcv_prism *prism_array; struct GRid *set_id;
       IGRlong *begin_index, *end_index)
{
    IGRlong	OMmsg;
    
    *msg = GRNO_PROCESSING_NEEDED;
    OMmsg = OM_S_SUCCESS;

    *end_index = *begin_index;

    

    return (OMmsg);
}
end implementation GRgraphics;
