#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

struct mult_tk_surfs_views {
   IGRint      num_sfs_per_mult_tks;
   OMuword     best_view_index;
   IGRdouble   uv_point[2];
  };

#template struct mult_tk_surfs_views   shell_sfs_T
