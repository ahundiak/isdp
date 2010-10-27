class implementation VDpretendin;

#include	<stdio.h>
#include	<string.h>
#include	"v_dbgmacros.h"

method NDsleep(struct GRmd_env *md_env)
{
	SetProc( VDpretendin_NDsleep ); Begin

	End 
	return OM_S_SUCCESS;
}

method NDcompute_node(	IGRlong *msg;
			int cn_type;
			int count;
                        struct GRid list[];
			struct GRmd_env *md_env )
{

	SetProc( VDpretendin_NDcompute_node ); Begin

	*msg = MSSUCC ;

	End
	return OM_S_SUCCESS ;
}


/*==========================================================================*/

method NDparent_deleted( IGRlong *msg;
                         IGRint count_deleted;
                         struct GRid list_deleted [];
                         struct GRid *new_obj;
                         struct GRmd_env *md_env )

{
IGRlong stat;

	SetProc( VDpretendin_NDparent_deleted ); Begin

	stat =
	om$send( msg = message Root.delete(0),
                 targetid = my_id );
	if(! (stat & 1)){
		printf(" ERROR: msg Root.delete \n" );
	}

	End
	*msg = MSSUCC;
	return OM_S_SUCCESS;
}

/*==========================================================================*/

end implementation VDpretendin;

