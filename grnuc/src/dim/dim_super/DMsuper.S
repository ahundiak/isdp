class specification DMsuper(2:0) of global_class, GRcmpowner;

#include "OMlimits.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
/*#include "fidef.h"*/
/*#include "fi.h"*/
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "parametric.h"
#include "var.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "dimdef.h"
#include "dim.h"
#include "dimplan.h"
#include "dimext.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dm_status.h"
#include "dimerror.h"

instance DMsuper
{
	IGRint	dim_stan;
};

/* MESSAGES */

message get_dim_param(
	IGRint *msg;
	IGRint type;
	struct GRid *param);

message set_dim_stan(
	IGRint *msg;
	IGRint stan);

message create_dim_param(
	IGRint *msg;
	IGRboolean global;
	IGRint type;
	IGRint size;
	char *p_data;
	struct GRmd_env *md_env;
	struct GRid *p_grid);

message update_dim_param(
	IGRint *msg;
	IGRint type;
	IGRint size;
	char   *p_data;
	struct GRmd_env *md_env;
	struct GRid *param);

message activate_dim_param(IGRint *msg; struct GRid param);

message pass_message(OM_p_MESSAGE p_msg);

/* OVERRIDE MESSAGES */

override super_construct;
override wake_up, sleep;

end specification DMsuper;

