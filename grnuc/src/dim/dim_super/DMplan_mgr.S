class specification DMplan_mgr(2:0) of global_class, GRcmpowner;

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

instance DMplan_mgr
{
};

/* MESSAGES */

message get_dim_plane(
	IGRint *msg;
	struct GRid win_grid;
	struct GRmd_env *md_env;
	struct GRid *dim_plan);

/*
	 	- create_dim_plane -

     if (win_grid.objid == NULL_OBJID) then the matrix
     supplied is used to define the dimension plane else
     the window orientation is used to define dimension plane
*/

message create_dim_plane(
	IGRint *msg;
	struct GRid win_grid;
	IGRmatrix matrix;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env;
	struct GRid *dim_plan);

message create_local_plane(
	IGRint *msg;
	struct GRid win_grid;
	IGRdouble matrix[16];
	IGRint count;
	struct GRid list[];
	IGRdouble axis[6];
	struct GRmd_env *md_env;
	struct GRid *dim_plan);

/* OVERRIDE MESSAGES */

override super_construct;
override wake_up;

end specification DMplan_mgr;

