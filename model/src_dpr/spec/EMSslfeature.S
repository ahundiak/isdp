/*
  ABSTRACT

  This is a class which represents the new solid boolean feature objects
  implemented for Phoenix.


  NOTES

  The "override GRvg" statement got inadvertently cut off by a missing 
  comment delimiter. This happened ages ago and the consequence of it has
  been that this class will always have needlessly included the GRvg
  instance data (which no other DPR includes). We will have to live with
  this (and it is really no big deal -- just a short) forever. Just
  interesting, that's all.


  HISTORY

  NP  06/23/93	Creation.
  Rust 8/4/93     Added "EMcreate_add_rem_mat_feature" message
  Rust 9/22/93    Added "EMpattern_copy" in the override list for GVK.
  Rust 1/3/94     Added "EMgive_noncount_based_key,EMgive_count_based_key"
                  in the override list.
*/

class specification EMSslfeature (1:0) of EMSslboolfea, EMSsffeature;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMcreate_add_rem_mat_feature
(
  IGRlong *msg;
  IGRushort feat_type;
  IGRboolean projected;
  IGRboolean revolved;
  IGRboolean skinned;
  IGRdouble proj_dist;
  IGRboolean normal;
  IGRboolean symmetric;
  IGRboolean close;
  IGRlong feaopts;
  IGRlong matopts;
  struct GRid *from_surf_id;
  struct GRid *to_surf_grid;
  struct GRevent *event_info;
  IGRpoint pivot_pnt;
  IGRvector projection_vec;
  IGRvector matadd_vector;
  IGRdouble *ang_val;
  IGRvector axis_vec;
  struct GRid *trace;
  struct GRvg_construct *const_args;
  IGRushort assoc_opts;
);

override
  EMpattern_copy,
  GRgetobjinfo,
  EMgetsolidclass,
  EMgive_noncount_based_key,
  EMgive_count_based_key;

#endif

end specification EMSslfeature;


