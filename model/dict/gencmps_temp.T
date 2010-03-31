#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

struct d_s_codes_views {
	IGRint	as_code;
	OMuword	view_index;
};

struct surfs_per_thickness
{
    IGRint      num_sfs_per_tks;
    OMuword     best_view_index;
    IGRdouble   uv_point[2];
};

#template struct d_s_codes_views	codes_views_T
#template IGRpoint	IGRpoint_T
#template IGRvector	IGRvector_T
#template struct surfs_per_thickness    surfs_views_T


