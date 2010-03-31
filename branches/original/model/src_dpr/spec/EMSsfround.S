/*
  ABSTRACT

  DPR class for rounding edge and vertices.


  HISTORY

  RC    12/14/88    Added override EMget_mdsfs_info.
  gupta 10/09/87    Creation Date
  Now obsolete
*/

class specification EMSsfround (1:0) of EMSsfregmod;

#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfround
{
  IGRushort	no_of_boundaries;
  variable struct EMround_exec_info round_exec_info[5];
  IGRuchar operation_type;
};

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMloopset_add
(
  IGRlong *EMmsg;
  struct EMboundary_info bnd_info;
  GRobjid loopset_id;
);

message EMround_execute
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct EMedge_round_info *my_info;
  IGRint num_edges;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  IGRint *num_def_info;
  struct EMdef_con_info *def_info;
  IGRshort *option;
  struct EMround_save_state *svst_info;
  IGRboolean *add_s1_to_tree;
  IGRboolean *add_s2_to_tree;
  IGRboolean *response_taken;
  IGRboolean *exit_gracefully;
  IGRushort dis_options;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMround
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct GRvg_construct *construct_list;
  IGRushort operation_type;
  IGRboolean vtx_to_int;
  IGRint *num_edges;
  GRobjid *edge_ids;
  IGRdouble *edge_radius;
  IGRushort dis_options;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMfix_end_point
(
  IGRlong *EMmsg;
  GRobjid loop_id;
);

message EMadd_defered_info
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRint *num_def_info;
  struct EMdef_con_info *def_info;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  struct EMround_save_state *svst_info;
);

message EMprepare_rnd_ssi
(
  IGRlong *EMmsg;
  struct EMround_save_state *svst_info;
);

message EMset_tply_props
(
  IGRlong *EMmsg;
  IGRboolean partner_props;
  struct EMSsfintedpar **trim_info;
  IGRint num_trim_info;
  IGRint num_loops_added;
  GRobjid *loops_added;
  GRobjid surface_id;
  struct EMround_save_state *svst_info;
);


message EMround_graceful_exit
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct GRid surf_GRid;
  struct EMSpartolbasis *partolbasis;
  IGRint num_orgnl_loops;
  GRobjid *orgnl_loops;
  struct EMround_save_state *svst_info;
);

message EMget_boundary_in_model_space
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid srf_id;
  struct IGRbsp_surface *srf_geom;
  GRobjid *edge_id;
  struct IGRbsp_curve **edge_geom;
  IGRpoint pt_area;
  IGRint *index;
  IGRboolean *bnd_found;
);

message EMreevaluate_geometry
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRint index;
  IGRpoint pt_area;
  GRobjid my_surf_id;
  GRobjid edge_id;
  struct IGRbsp_curve *edge_geom;
  struct IGRbsp_surface *edge_surf;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  struct EMSpartolbasis *partol;
);

message EMfillet_auto_trim
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid surface1_id;
  GRobjid surface2_id;
  IGRboolean s1_nat_norm;
  IGRboolean s2_nat_norm;
  IGRpoint starting_point;
  IGRdouble starting_radius;
  IGRpoint ending_point;
  IGRdouble ending_radius;
  IGRdouble rho;
  IGRboolean *add_s1_to_tree;
  IGRboolean *add_s2_to_tree;
  struct GRvg_construct *construct_list;
);

message EMround_cleanup
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRint *num_surf_ids;
  struct GRid *surf_ids;
);

message EMcleanup_surfaces
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRint num_out_loops;
  GRobjid *out_loops;
  IGRint num_trim_info;
  struct EMSsfintedpar **trim_info;
  struct EMedge_round_info *my_info;
  struct EMround_save_state *svst_info;
);

override
  EMdim,
  EMdimparam,
  EMconstruct_associative,
  EMmatch,
  EMgetOutInfo,
  EMgetInInfo,
  EMconnectTopology,
  EMgetmodinfo,
  EMgettreepath,
  EMcheckOverlap,
  EMgetsolidclass,
  EMsavestatedelete,
  EMintcopy,
  EMputSSI,
  EMdeactivate,
  EMactivate,
  GRchgcolor,
  GRputsymb,
  GRchghprops,
  GRchgdp,
  GRchglevel,
  GRchgstyle,
  GRchgweight,
  GRxform,
  GRaddwrng,
  GRremwrng,
  EMgetSSI,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMget_mdsfs_info;

#endif

end specification EMSsfround;
