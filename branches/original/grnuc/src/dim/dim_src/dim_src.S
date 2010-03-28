/*
  DESCRIPTION

  Class defining the objects from which all geometry sources for the dimension
  are derived.

 
  HISTORY

  Unknown
*/

class specification dim_src(2:0) of Root;

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

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message DMgive_structure
(
  IGRint *msg;
  IGRint type;
  IGRboolean inq0_set1;
  struct dim_ret_struct *str;
  struct GRmd_env *md_env;
);

message DMmodify
(
  IGRint *msg;
  struct GRmd_env *md_env;
  IGRint key;
  IGRboolean ptdist;
  struct IGRline *boreline;
);

message DMgive_tangent
(
  IGRint *msg;
  IGRboolean *src_type;
  IGRdouble tangent[3];
  IGRdouble box[4][3];
  struct GRmd_env *md_env;
);

reject 
  DMgive_structure, 
  DMmodify;

#endif

end specification dim_src;
