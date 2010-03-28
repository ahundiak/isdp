/*
  DESCRIPTION

  This is the class defining the object that holds the plane information on
  which the dimension sits.

 
  HISTORY

  Unknown
*/

class specification dim_plan(2:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "report.h"
#include "dimplan.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message give_plane
(
  IGRint *msg;
  IGRmatrix matrix;
  struct GRmd_env *md_env;
);

message give_axis
(
  IGRint *msg;
  IGRvector axis;
  struct GRmd_env *md_env;
);

message give_info
(
  IGRint *msg;
  struct DMplan_info *plan_info;
  struct GRmd_env *md_env;
);

message draw_axis
(
  IGRint *msg;
  IGRdouble origin[3];
);

message select_axis
(
  IGRint *msg;
  IGRdouble origin[3];
  IGRdouble pt[3];
  IGRint *axis;
);

message give_parents
(
  IGRint *count;
  struct GRid list[];
);

reject 
  give_plane;

#endif

end specification dim_plan;
