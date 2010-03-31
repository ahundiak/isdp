/*
  DESCRIPTION

  This message asks the associative object to return a triad which will
  define the dimensioning-plane (dim_plane + dim_plane_xaxis) on which
  the dimension that drives this "paramobj" should be placed. In addition,
  it returns the geometry that should be used by the dimension to anchor
  to. It may or may not be the same geometry represented in "paramobj".

  Any one of the output arguments is optional, indicated by NULL
  pointers.

  The method return EMS_I_NoResponse by default. This indicates no output
  has been processed. The caller must check for this and take appropriate
  action.

  HISTORY

  SS  :  03/27/91  :  Creation
*/

class specification EMSdim (2:0) of dim_src, dim_plan, EMSassoc;

#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimplcmacros.h"
#include "dimplan.h"
#include "diminfo.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMautodimparam
(
  IGRlong *msg;
  IGRushort opts;
  IGRshort *mattyp;
  IGRmatrix mat;
  GRobjid paramobj;
  struct IGRplane *dim_plane;
  IGRdouble *dim_plane_xaxis;
  struct EMSgeomdata *dim_geom;
  IGRint *dim_type;
);

message EMdim
(
  IGRlong * msg;
  struct GRmd_env * mod_env;
  IGRushort options;
  IGRint type;
  IGRchar * info;
  IGRint num_parents;
  struct GRid * parents;
);

message EMdimparam
(
  IGRlong * msg;
  struct GRmd_env * mod_env;
  IGRushort options;
  IGRint type;
  IGRchar * info;
  IGRint num_parents;
  struct GRid * parents;
  IGRint index;
  struct IGRplane * dim_plane;
  IGRdouble * dim_plane_xaxis;
  struct EMSgeomdata * dim_geom;
  IGRint * dim_type;
);

reject   
  EMdim;

override 
  give_plane, 
  EMautodim,
  EMdeautodim,
  give_axis, 
  DMgive_structure,
  DMmodify,
  EMassoc_autodimparam,
  EMassoc_dimparam;

#endif

end specification EMSdim;
