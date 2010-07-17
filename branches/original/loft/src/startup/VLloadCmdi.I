class implementation VLloadCmd;

#include	"acdef.h"
#include	"acmacros.h"
#include	"gr.h"
extern struct GRid MANwk_hull;

/* ************************************************************************** */
method init ( int type ; char * str_ptr ) {

  	return OM_S_SUCCESS;
}
/* ************************************************************************** */
method execute( int *response ; char *response_data ; int pos ) {

	IGRint	sts;

	MANwk_hull.objid = NULL_OBJID;

	sts = ac$construct_path ( mode = AC_ADD_PATH, name = "VLmacro" );
	if (!(sts&1))	printf( "Load Macro Library <VLmacro> failed\n");

	sts = ac$construct_path ( mode = AC_ADD_PATH, name = "VLsymb" );
	if (!(sts&1))	printf( "Load Macro Library <VLsymb> failed\n");

	sts = ac$construct_path ( mode = AC_ADD_PATH, name = "VLtext" );
	if (!(sts&1))	printf( "Load Macro Library <VLtext> failed\n");

        sts = ac$construct_path ( mode = AC_ADD_PATH, name = "VLpcard" );
        if (!(sts&1))   printf( "Load Macro Library <VLpcard> failed\n");

	*response = TERMINATE;		    

  	return OM_S_SUCCESS;
}
/* ************************************************************************** */

end implementation VLloadCmd;
