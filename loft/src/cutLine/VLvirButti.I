class implementation VLvirButt;

#include "vlglinedef.h"
#include "AS_status.h"
#include "expmacros.h"
#include "asmacros.h"
#include "vlgrdef.h"
#include "expression.h"

extern	GRclassid	OPP_EMScompsurf_class_id;
extern	GRclassid	OPP_nci_macro_class_id;
extern	struct	GRid	NULL_GRID;

from	expression	import	modify;
from	ci_macro	import	init;

/* ****************** MSG NDcheck_cmpt_level () ***********************	*/
/*	level 1 	--> BaseButt
/*	level 2		no def
/*	level 3		--> NextButt (min distance)
/*	level 4		--> NextButtDev (with surface develop)
/* --------------------------------------------------------------------	*/ 

method	NDcheck_cmpt_level( IGRlong *msg; IGRshort count; struct GRid list[];
			struct GRmd_env *md_env; IGRshort *level;
			IGRchar	*def_name; IGRboolean load )
{
IGRlong		sts;
IGRint		int_msg;
IGRshort	loc_level;
IGRchar		*ptr_def_name;

	*msg	= MSSUCC;
	if( level )	*level		= 1;
	if( def_name )	def_name[0]	= '\0';

	if( count < 4 ){ *msg = MSFAIL; return	OM_S_SUCCESS; }

	if( count == INDEX_START_CL ){ 

		loc_level	= 1;
		ptr_def_name 	= BUTT_DEF_1;

	} else {

		loc_level	= 3;
		ptr_def_name 	= BUTT_DEF_2;

	  }

	if( level )	*level = loc_level;
	if( def_name )	strcpy( def_name, ptr_def_name );
	if( load ){
		sts = om$send(	msg = message ACcpx.ACattach
						( &int_msg, ptr_def_name ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = int_msg );
	}

return	OM_S_SUCCESS;
}

end implementation VLvirButt;

