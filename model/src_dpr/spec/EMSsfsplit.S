/*
  ABSTRACT

  DPR class for composite surface and surface split.


  HISTORY

  RC    12/14/88    Added override EMget_mdsfs_info.
  RC    2/3/88      Override GRaddwrng.
  DLB   10/15/87    1.1.0 class conversion.
  RC    06/10/87    Overrode EMintcopy
  gupta 04/06/87    Creation Date
*/

class specification EMSsfsplit (1:0) of EMSsflm;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSssi.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfsplit
{
  IGRushort owner_index; 
};

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMest_split_top
(
  IGRlong *rc;
  IGRint option;
  IGRint num_surf;
  IGRdouble *parms;
  struct GRmd_env *surf_env;
  struct GRid insurf_GRid;
  IGRboolean *uv_closed;
  GRobjid *out_surface;
);

override
  EMgetSurfsOfPrim,
  EMnodeBrokeApart,
  EMgetmodinfo,
  EMgetCompIndex,
  EMputCompIndex,
  EMcheckOverlap,
  EMgettreepath,
  EMgetsolidclass,
  GRchgcolor,
  GRputsymb,
  GRchghprops,
  GRchgdp,
  GRchglevel,
  GRchgstyle,
  GRchgweight,
  GRaddwrng,
  GRremwrng,
  EMgetownerinfo,   
  GRxform,
  EMsavestatedelete,
  EMputSSI,
  EMactivate,
  EMdeactivate,
  EMsplit_surface,
  EMintcopy,
  EMgetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMget_mdsfs_info;

#endif

end specification EMSsfsplit;
