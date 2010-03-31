/*
  ABSTRACT

  This is the Design Process Representation class. It is designed as
  a means of modifying the design process by inserting, deleteing,
  and modifying states in the state tree.
  This is an abstract class.


  HISTORY

  DLB    04/19/91 Changed dpr_props to a short.
  SM  24-May-89   Added EMchangeClass message
  DLB 9/22/87     Mod for new class struct.
  DLB 08-May-1987 Third parameter of EMadd changed from
                  IGRboolean to struct GRid.
  JBK 06-May-1987 Added EMget_dpr_props method.
  AIC    03/02/87 Move from EMScompsurf to GRvg
  AIC    12/28/86 Creation date
*/

class specification EMSdpr (3:0) of EMScomposite;

# include "EMSssi.h"
# include "EMSri.h"
# include "EMSprop.h"
# include "EMSmsgdef.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSdpr
{
  variable OM_S_OBJID   ids[];        
  unsigned short dpr_props;           
};

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMget_dpr_props
(
  IGRlong *EMmsg;
  IGRushort *props;
);

#ifndef BASE_EMS

message EMgetSSI
(
  IGRlong *EMmsg;
  union EMSssi_table **ssi;
);

message EMgetSSIbuffer
(
  IGRlong *EMmsg;
  union EMSssiSizeData *size;
  union EMSssi_table **ssi;
);

message EMgetSSIsize
(
  IGRlong *EMmsg;
  union EMSssiSizeData *size;
);

message EMgetRI
(
  IGRlong *EMmsg;
  union EMSri_table **ri;
);

message EMgetmodinfo
(
  IGRlong *msg;
  IGRushort options;
  struct EMSmodobjinfo *modobjinfo;
);

message EMputSSI
(
  IGRlong *EMmsg;
  union EMSssi_table *ssi;
);

message EMputRI
(
  IGRlong *EMmsg;
  union EMSri_table *ri;
);

message EMactivateprims
(
  IGRlong *EMmsg;
  IGRushort *option;
  struct GRmd_env *my_env;
  struct GRid **active_state;
  IGRint *num;
  IGRint *buff_size;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRint *involk_count;
);

message EMislmintree
(
  IGRlong *EMmsg;
  IGRboolean *flag;
);

message EMreexecute
(
  IGRlong *EMmsg;
  IGRushort *option;
  struct GRmd_env *env;
  IGRint parent_count;
  struct GRid *parent_list;
  IGRuint type;
  IGRchar *recomp_info;
  struct GRvg_construct *construct_list;
);

message EMprep_reex
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
);

message EMsavestatedelete
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  union EMSssi_table *ssi;
);

message EMrecompinfodelete
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRushort options;
  union EMSri_table *ri;
);

message EMtreecleanup
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
);
  
message EMactivate
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *env_info;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMdeactivate
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *env_info;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMsetprops
(
  IGRlong *EMmsg;
  IGRboolean *action;
  IGRushort *mask;
);

message EMmake_primitive1
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct GRid *new_id;
);

message EMundo
(
  IGRlong *EMmsg;
  IGRushort *option;
  struct GRmd_env *my_env;
  struct GRid **active_state;
  IGRint *num;
  IGRint *buff_size;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRint *involk_count;
);

message EMredo
(
  IGRlong *EMmsg;
  IGRushort *option;
  struct GRmd_env *my_env;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRint *involk_count;
);

message EMchangeClass
(
  IGRlong *EMmsg;
  OMuword *newclassid;
  OMuword *changedToClassid;
);

message EMevaluateOps
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmd_env *env;
  IGRint parent_count;
  struct GRid *parent_list;
  IGRuint type;
  IGRchar *recomp_info;
);

message EMcleanSSI
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRushort options;
);

message EMresetSSI
(
  IGRlong *EMmsg;
);

message EMtoggleKDFlag
(
  IGRlong *EMmsg;
  IGRboolean *turn_off;
);

message EMgetUnevalIds
(
  IGRlong *EMmsg;
  GRobjid uneval_sender_id;
  IGRboolean is_kd_on;
  IGRushort options;
  IGRint *num_ids;
  GRobjid **ids;
);

message EMcheckOverlap
(
  IGRlong *EMmsg;
  struct EMSinlist *inlist;
  IGRboolean *does_overlap;
  IGRushort options;
);

message EMdeactivateState
(
  IGRlong *EMmsg;
  struct EMSinlist *inlist;
  IGRushort flags;
  IGRushort options;
  IGRint *display_count;
  GRobjid **display_ids;
  struct GRmd_env *env;
);

message EMgetInInfo
(
  IGRlong *EMmsg;
  struct EMSinlist *inlist;
  GRobjid uneval_sender_id;
  IGRboolean is_kd_on;
  IGRushort options;
);

message EMremoveOpnd
(
  IGRlong *EMmsg;
  GRobjid operand_id;
  struct GRmd_env *env;
  GRobjid *new_active_id;
  GRobjid *remaining_id;
  IGRushort options;
);

message EMaddManager
(
  IGRlong *EMmsg;
  GRobjid uneval_sender_id;
  IGRboolean is_kd_on;
  IGRushort options;
);

message EMattemptBreakup
(
  IGRlong *EMmsg;
  GRobjid uneval_id;
  IGRboolean *did_breakup;
  GRobjid *new_state_id;
  struct GRmd_env *env;
  IGRushort options;
);

message EMgetCompIndex
(
  IGRlong *EMmsg;
  IGRint *num_chan;
  struct EMchanstruct **chan;
  IGRushort options;
);

message EMputCompIndex
(
  IGRlong *EMmsg;
  IGRint num_chan;
  struct EMchanstruct *chan;
  IGRushort options;
);

message EMcanRecompute
(
  IGRlong *EMmsg;
  IGRboolean *can_rc;
);

message EMcorrectOrient
(
  IGRlong *EMmsg;
);

message EMconnectTopology
(
  IGRlong *EMmsg;
  IGRchar **list;
  IGRushort options;
);

message EMcheckRngOverlap
(
  IGRlong *EMmsg;
  GRobjid node_id;
  GRrange node_range;
  GRobjid nodes_side_id;
  struct GRmd_env *env;
  IGRboolean *does_overlap;
  IGRushort options;
);

message EMgetOutInfo
(
  IGRlong *EMmsg;
  struct EMSoutlist *outlist;
  IGRushort options;
);

message EMoperandChanged
(
  IGRlong *EMmsg;
  GRobjid old_opnd;
  GRobjid new_opnd;
  IGRushort options;
);

message EMcleanupComputeInfo
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmd_env *env;
  IGRint num_compute_info;
  struct EMScompute_info *compute_info;
);

message EMrecover
(
  IGRlong *EMmsg;
  IGRint num_compute_info;
  struct EMScompute_info *compute_info;
  struct GRmd_env *env;
  IGRushort options;
);

message EMgetInGeomIds
(
  IGRlong *EMmsg;
  GRobjid nodes_side_id;
  IGRboolean is_kd_on;
  IGRint *num_in_geom_ids;
  GRobjid **in_geom_ids;
  IGRushort options;
);

message EMpass
(
  IGRlong *EMmsg;
  IGRint options;
  OM_p_MESSAGE mssg;
  IGRint *tree_depth;
);

message EMgetModRange
(
  IGRlong *EMmsg;
  struct EMSinlist *inlist;
  GRobjid nodes_side_id;
  struct GRmd_env *env;
);

message EMnodeBrokeApart
(
  IGRlong *EMmsg;
  GRobjid original_node_id;
  GRobjid new_node_id;
  IGRint num_comp_moved;
  GRobjid *comp_moved_ids;
  IGRushort options;
);

message EMtoggleOrient
(
  IGRlong *EMmsg;
  IGRushort options;
);

message EMmatch
(
  IGRlong *EMmsg;
  union EMSssi_table *old_ssi;
  IGRint old_num_surfs;
  GRobjid *old_surfs;
  IGRint new_num_surfs;
  GRobjid *new_surfs;
  IGRushort options;
  struct GRmd_env *env;
);

message EMcheckDPROverlap
(
  IGRlong *EMmsg;
  struct EMSinlist *inlist;
  struct EMSoutlist *outlist;
  struct GRmd_env *env;
  IGRushort options;
);

message EMmult_undo
(
  IGRlong *EMmsg;
  IGRushort *option;
  struct GRmd_env *my_env;
  struct GRid **active_state;
  IGRint *num;
  IGRint *buff_size;
  GRobjid **display_ids;
  IGRint *display_count;
  IGRint *invoke_count;
);

message EMsend_for_macro
(
  IGRlong *EMmsg;
  IGRint num_levels;
  IGRboolean deposit_botton_up;
  OM_S_MESSAGE *deposit_msg;
  OMuword options;
);

message EMget_macro_ids
(
  IGRlong *EMmsg;
  IGRint num_levels;
  IGRboolean return_bottom_up;
  IGRint *num_macro_ids;
  GRobjid **macro_ids;
  OMuword options;
);

message EMget_suppress_ids
(
  IGRlong *EMmsg;
  IGRint *num_sids;
  GRobjid **sids;
  OMuword options;
);

message EMdelete_feature
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  OMuword options;
);

message EMpartial_delete_group_feature
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  GRobjid group_comp_id;
  OMuword options;
);

message EMfixInGeomIds
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRushort options;
);

message EMget_feature_definition
(
  IGRlong *EMmsg;
  IGRint *feature_cnt;
  GRobjid **feature_ids;
  IGRushort options;
);

reject 
  EMfixInGeomIds,
  EMgetInGeomIds,
  EMattemptBreakup,
  EMresetSSI,
  EMtoggleKDFlag,
  EMcanRecompute,
  EMgetUnevalIds,
  EMcheckOverlap,
  EMremoveOpnd,
  EMaddManager,
  EMgetSSI,
  EMgetSSIbuffer,
  EMgetSSIsize,
  EMputSSI,
  EMgetRI,
  EMputRI,
  EMactivate,
  EMdeactivate;

override
  GRdisyourself,      
  EMcomponentchanged, 
  GRdelete,           
  debug,
  GRlocate,
  GRlocate_owner;

#endif

end specification EMSdpr;
