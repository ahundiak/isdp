class implementation VLtrace;

#include "AS_status.h"
#include "vlglinedef.h"
#include "vds.h"
#include "vlmsg.h"

/* ****************** MSG NDcheck_cmpt_level () ***********************	*/

method	NDcheck_cmpt_level( IGRlong *msg; IGRshort count; struct GRid list[];
			struct GRmd_env *md_env; 
			IGRshort *level; IGRchar *def_name; IGRboolean load )
{

long		sts;
int		int_msg;
char		*ptr_name;

	*msg	= MSSUCC;
	if( level )	*level	= 4;
	ptr_name = TRACE_DEF_4;
	if( def_name )	strcpy( def_name, ptr_name );
	if( load ){
		sts = om$send(	msg = message ACcpx.ACattach
						( &int_msg, ptr_name ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = int_msg );
	}

return	OM_S_SUCCESS;
}
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjTrace;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLtrace;

