/*
Name
        COcvigdsige

Description
	This command object class is used to convert IGDS design files
        into an MDEM object space format.  Applications may override
        the methods defined here to provide different interpretations
        of the IGDS elements.

History
	???     ??/??/??    created
        mrm     06/24/91    added cvt_type22
*/

class specification COcvigdsige (1:1) of COconst;

#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"

instance COcvigdsige
{
    struct GUcvt_bufs	cvt_bufs;	/* Buffers used to read file */
    struct GRmd_env	current_env;    /* current module environment*/
    IGRlong		IGDS_file_type;	/* IGDS file type, 2D or 3D  */
    IGRlong		object_type;	/* IGDS file type, 2D or 3D  */
    IGRdouble		scale_factor;   /* conversion factor from IGDS
					   to IGE working units      */
};

/*
 *  Message declarations.
 */

message cvt_igds_ige(IGRlong *msg; IGRchar *file_name);
message cvt_next_ele(IGRlong *msg; struct GRid *object_info);
message cvt_type2(IGRlong *msg; struct GRid *object_info);
message cvt_type3(IGRlong *msg; struct GRid *object_info);
message cvt_type4(IGRlong *msg; struct GRid *object_info);
message cvt_type5(IGRlong *msg; struct GRid *object_info);
message cvt_type6(IGRlong *msg; struct GRid *object_info);
message cvt_type9(IGRlong *msg; struct GRid *object_info);
message cvt_type1113(IGRlong *msg; struct GRid *object_info);
message cvt_type1214(IGRlong *msg; struct GRid *object_info);
message cvt_type15(IGRlong *msg; struct GRid *object_info);
message cvt_type16(IGRlong *msg; struct GRid *object_info);
message cvt_type17(IGRlong *msg; struct GRid *object_info);
message cvt_type1819(IGRlong *msg; struct GRid *object_info);
message cvt_type23(IGRlong *msg; struct GRid *object_info);
message cvt_type8788(IGRlong *msg; struct GRid *object_info);
message cvt_type22(IGRlong *msg; struct GRid *object_info);
message cvt_type2427(IGRlong *msg; struct GRid *object_info);
message cvt_unknown_type(IGRlong *msg; struct GRid *object_info);

override init, wakeup, execute, sleep;

end specification COcvigdsige;
