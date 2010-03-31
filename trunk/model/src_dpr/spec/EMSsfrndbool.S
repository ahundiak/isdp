/*
  DESCRIPTION

  Class that represents the rounding operation as a special type of
  boolean operation.

 
  HISTORY

  SS  Creation  Long Ago   
*/

class specification  EMSsfrndbool (1:0) of EMSsfboolean;

#include "EMSrnd.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMround
(
  IGRlong *msg;
  IGRushort options;
  struct GRvg_construct *const_list;
  struct GRid *model_id;
  IGRint num_edges;
  struct EMSrnd_boundary_input *edges;
  IGRchar status_str[];
  IGRint *display_count;
  GRobjid **display_ids;
  struct EMSrnd_error *rnderror;
);

from EMSsurface inherit 
  GRgetobjinfo;

override 
  EMoffset,
  EMdim,
  EMdimparam,
  EMconstruct_associative, 
  EMreexecute,
  EMgetInGeomIds, 
  EMdeactivate;

#endif

end specification EMSsfrndbool;
