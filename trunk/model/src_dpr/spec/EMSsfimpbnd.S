/*
  ABSTRACT

  This class represents the modifications to single or composite
  surfaces by imposing boundaries and putting the resulting object on the
  state tree. 

        
  HISTORY

  mrm   06/05/91    more overrides for 2.0.1
  mrm   06/03/91    Override EMconstruct_associative
  SM    05-Nov-87   Fixed the message declaration problems.
  DLB   10/15/87    1.1.0 class conversion
  SM    05/11/87    Creation Date
*/

class specification EMSsfimpbnd (2:0) of EMSsfregmod;

#include "REsfimpbnd.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMsfimpbnd_init
(
  IGRlong *msg;
  GRobjid surf1;
  IGRushort grvg_props;
);

message EMget_subbs
(
  IGRlong *EMmsg;
  GRobjid *sfid;
);

override  
  EMgetInInfo,
  EMgetOutInfo,
  EMgetInGeomIds, 
  EMconstruct_associative,
  EMconnectTopology,
  EMcheckOverlap,
  EMgetsolidclass,
  EMintcopy,
  EMactivate,
  EMdeactivate,
  NDattach_to_track_pt,
  NDdetach_from_track_pt;

#endif

end specification EMSsfimpbnd;
