/*
  ABSTRACT

  Abstract DPR class for surface and composite surface lift vertex, 
  edge or face.


  HISTORY

  RC  3/17/88      Creation Date
  RC  08/25/88      Added override EMget_mdsfs_info;
  RC  02/27/89      Added override GRaddwrng.
  Tapadia 08/12/91  Added override EMdim & EMdimparam;
*/

class specification EMSlift (1:0) of EMSsfregmod;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSlift.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSlift
{
   IGRvector                                lift_vector;
   IGRuchar                         operation_type;
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMlift_int_deactivate
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *md_env;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRdouble *lift_vec;
  IGRint *num_instructions;
  struct EMinstruction_table_info *move_info;
);

message EMlift_int_activate
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *md_env;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRdouble *lift_vec;
  IGRint *num_instructions;
  struct EMinstruction_table_info *move_info;
);

override
  EMgetSurfsOfPrim,
  EMgetInGeomIds,
  EMmatch,
  EMgetOutInfo,
  EMgetInInfo,
  EMnodeBrokeApart,
  EMconnectTopology,
  EMgetmodinfo,
  EMgetCompIndex,
  EMputCompIndex,
  EMcheckOverlap,
  EMgettreepath,
  GRaddwrng,
  GRremwrng,
  GRxform,
  EMsavestatedelete,
  EMintcopy,
  EMputSSI,
  EMget_mdsfs_info,
  EMdim,
  EMdimparam,
  GRgetobjinfo,
  EMgetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer;

#endif

end specification EMSlift;
