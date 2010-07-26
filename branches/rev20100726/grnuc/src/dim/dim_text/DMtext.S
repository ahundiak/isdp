class specification DMtext(2:0) of GR3dtext;

#include "dimdef.h"
#include "dim.h"
#include "dimplan.h"
#include "dimext.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dm_status.h"
#include "dimerror.h"
#include "dimtxtdef.h"
#include "dimtxt.h"


/* MESSAGES */

message make_text_string(
	IGRdouble dimn_val;
	IGRint meas_type;
	struct DMloc_param *loc_param;
	struct DMenv_param *env_param;
	struct DMmisc_param *misc_param;
	struct GRmd_env *md_env);

message DMget_dim_fields(
	struct DMenv_param *p_env;
	struct DMloc_param *p_loc;
	struct DMmisc_param *p_misc);


end specification DMtext;

