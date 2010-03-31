class specification ECdmcnstr (2:0) of COdmplace;

#include "dimdef.h"

instance ECdmcnstr
  {
  struct GRid constraint_GRid;
  struct GRmd_env display_env;
  IGRuchar props;
  IGRint ref_plane_lock;
  };

override
  init, wakeup,
  super_cmd.sleep,
  get_dim_plane, dimension_driving, delete_dimension;

end specification ECdmcnstr;
