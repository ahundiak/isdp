/*
  ABSTRACT

  Class that defines the DPR for capping of a surface object.

 
  HISTORY
 
  10/21/92  : AMD : Creation 
*/

class specification EMSsfcapsf (1:0) of EMSsfsolid,EMSsfdpr;

#include "emsclasses.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfcapsf
{
  IGRint         num_edges;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

from EMSsfsolid inherit 
  EMoffset, 
  EMget_params, 
  EMdim,
  EMdimparam, 
  GRgetobjinfo;

message EMprepare_dpr_state
(
  IGRlong *EMmsg;
  IGRushort dpr_options;
  IGRint num_caps;
  GRobjid *caps;
);

override 
  EMconstruct_associative,
  EMgetInGeomIds,
  EMgetInInfo,	
  EMputSSI, 
  EMactivate,
  EMdeactivate,
  EMsavestatedelete,
  EMintcopy,
  EMcheckOverlap, 
  EMgetsolidclass,
  EMresetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMgetSSI;

#endif

end specification EMSsfcapsf;
