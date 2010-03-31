/*
  ABSTRACT

  DPR class for surface and composite surface lift face with draft.


  HISTORY

  RC  3/17/88      Creation Date
  Tapadia 8/12/91  Override EMdim & EMdimparam
  Now obsolete class
*/

class specification EMSsfdlift (1:0) of EMSlift;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSlift.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMlift_face
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  struct EMSdlft_info *dlift_info;
  IGRushort dis_options;
  GRobjid **display_ids;
  IGRint *display_count;
);

override
  EMput_info,
  EMget_info,
  EMconstruct_associative,
  EMgetsolidclass,
  EMactivate,
  EMdeactivate,
  EMdim,
  EMdimparam;

#endif

end specification EMSsfdlift;
