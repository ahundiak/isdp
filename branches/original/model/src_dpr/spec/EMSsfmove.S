/*
  ABSTRACT

  DPR class for surface move edge or vertex and composite surface face
  edge and vertex.


  HISTORY

  RC    09/01/88    Added override EMget_mdsfs_info.
  DLB   10/15/87    1.1.0 class conversion
  RC    06/10/87    overrode EMintcopy method
  gupta 04/07/87    Creation Date
*/

class specification EMSsfmove (1:0) of EMSsflm;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSssi.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfmove
{
  IGRpoint from_point;
  IGRpoint to_point;
  variable struct EMexec_info exec_info[10];
  IGRushort     no_of_instructions;
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMloop_add
(
  IGRlong *rc;
  struct EMinstruction_table_info info;
  GRobjid loop_id;
);

message EMmove_execute
(
  IGRlong *rc;
  IGRpoint from_point;
  IGRpoint to_point;
  struct GRmd_env *my_env;
  IGRshort *option;
  GRobjid **display_ids;
  IGRint *display_count;
);

override
  EMgetmodinfo,
  EMcheckOverlap,
  EMgetsolidclass,
  EMputSSI,
  EMactivate,
  EMdeactivate,
  EMintcopy,
  EMislmintree,
  EMget_mdsfs_info, 
  GRgetobjinfo,
  EMgetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer;

#endif

end specification EMSsfmove;
