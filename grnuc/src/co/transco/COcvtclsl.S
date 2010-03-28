/* #######################    APOGEE COMPILED   ######################## */
class specification COcvtclsl (1:1) of COcvigdsige;

#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "transdef.h"

instance COcvtclsl
{
	IGRchar			btreename[40];
	GRrange			range;
};

/*
 *  Message declarations
 */

message cvt_cellib ( IGRlong *msg;
		     IGRchar *filename; IGRchar *seedfile;
		     struct GRsymbol_lib_file *asl_file );
message cvt_type1 ( IGRlong *msg;
		    struct GRid *object_info );

	override init, execute, cvt_next_ele, cvt_type5;


end specification COcvtclsl;
