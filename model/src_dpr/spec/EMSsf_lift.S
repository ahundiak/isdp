/*
  ABSTRACT

  DPR class for surface and composite surface lift vertex, edge or
  face.


  HISTORY

  RC  3/1/88      Creation Date
  Now this class is obsolete.
*/

class specification EMSsf_lift (1:0) of EMSlift;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSbnddef.h"
#include "EMSlift.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsf_lift
{
   IGRint                                   num_instructions;
   variable struct EMinstruction_table_info move_info[1];
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMlift_vertex
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  IGRpoint from_pt;
  IGRpoint to_pt;
  struct GRid sf_GRid;
  struct GRid ed_GRid;
  IGRshort which_end_pt;
  IGRushort active_constraints;
  struct EMSlft_cnstrnt_info *constraint_info;
);
        
message EMlift_edge
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  IGRpoint from_pt;
  IGRpoint to_pt;
  struct GRid srf_GRid;
  struct GRid edge_GRid;
  IGRushort active_constraints;
  struct EMSlft_cnstrnt_info *constraint_info;
);

message EMlift_face
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  IGRpoint from_pt;
  IGRpoint to_pt;
  struct GRid srf_GRid;
  IGRushort active_constraints;
  struct EMSlft_cnstrnt_info *constraint_info;
  IGRushort dis_options;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMlift_execute
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  struct GRvg_construct *construct_list;
  struct EMSlft_info *lift_info;
  IGRushort dis_options;
  GRobjid **display_ids;
  IGRint *display_count;
);

override
  EMconstruct_associative,
  EMgetsolidclass,
  EMactivate,
  EMdeactivate;

#endif

end specification EMSsf_lift;
