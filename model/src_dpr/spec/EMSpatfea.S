/* 
  ABSTRACT

  This class does the job of creating the copies and 
  computing them with correct transformation matrix
  Number of state are inherited.
*/

class specification EMSpatfea(2:0) of ASnode,dim_src;

#include "OMmacros.h"
#include "GRascopy.h"
#include "EMpattern.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSpatfea
{
	IGRshort pattern_type;
	IGRshort fea_props;
	variable short deleted[];
	variable char info[];

  channel { (many_to_many, rel_ordered,initial=1, increment=1) } listeners;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMget_copy
(
  IGRlong *EMmsg;
  IGRint index;
  struct GRid *p_par_list;
  struct GRid *dpr_root;
  struct GRid *fea_par;
  IGRint num_fea;
  IGRint *p_count;
  IGRint p_size;
  struct GRmd_env *md_env;
  struct GRid *ref_plane;
);

message get_xform_at_index
(
  IGRlong *EMmsg;
  IGRint index;
  IGRmatrix ref_plane;
  IGRmatrix rot_matrix;
  struct GRmd_env *md_env;
);

message get_copy_count
(
  IGRint *msg;
  IGRint *count;
  IGRint *delete_count;
);

message EMget_pattern_info
(
  IGRlong *EMmsg;
  struct GRas_pattern *pattern;
  struct GRmd_env *md_env;
);


message EMadd_to_dpr_tree
(
  IGRlong *EMmsg;
  IGRint fe_index;
  IGRint fe_count;
  struct GRid *feature_list;
  struct GRid *copy_list;
  struct GRmd_env *p_md_env;
);

message get_feature_list
(
  IGRlong *EMmsg;
  struct GRid *fe_list;
  IGRint *count;
);

message EMplace_dimensions
(
  IGRlong *EMmsg;
  IGRint num_parents;
  struct GRid *parents;
  IGRint *num_dim_obj;
  struct GRid *dim_grid;
  struct GRmd_env *md_env;
);

message EMupdate_feature_pattern
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
);

message EMget_plane_info
(
  IGRlong *EMmsg;
  struct GRid *list;
  IGRmatrix plane;
  struct GRmd_env *md_env;
);

message EMcreate_pattern_elements
(
  IGRlong *EMmsg;
  IGRint *num_copies;
  struct GRid **copies;
  struct GRmd_env *md_env;
  struct GRid *master_GRid;
);

message EMdelete_pattern_node
(
  IGRlong *EMmsg;
  struct GRid *feature;
  struct GRmd_env *md_env;
);

override 
  ACbecome_macro,
  NDplace,
  NDcompute_node,
  DMgive_structure,
  ASreturn_go,
  GRdelete,
  NDmove_to_root,
  NDmake_source,
  NDselect_copy;

#endif

end specification EMSpatfea;


