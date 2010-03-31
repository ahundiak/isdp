/*
  ABSTRACT

  This class represents a set of loops that make up all the
  boundaries of a surface.


  HISTORY

  SM      14-Oct-87       1.1 Genesis
  RC      10-Nov-87       Changed arguments to 
                          EMmake_natural_loopset.
  SM      07-Dec-87       Added message EMupdate_features.
  SAM     10-Feb-88       Added message EMbounded_uv_range.
  RC      04-APR-88       Added message EMptproject.
  AIC     12 Oct 1988     Added ptol argument to EMpack
                          message.
  SM      14-Nov-88       Added arguments surf_data, matrix_type, matrix,
                          and options to EMpack message.
  DLB     07/10/91        Disable tagging.
*/

class specification EMSloopset (1:1) of EMSboundary;

# include "emsbool.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

channel surface_channel
{
  (one_to_one)
  EMSsubbs.to_loopset;
};

channel loop_channel
{
  (rel_ordered,
   one_to_many,
   initial = 1, increment = 1)
  EMSloop.to_outter;
};

instance EMSloopset
{
  channel loop_channel          to_loops;       
  channel surface_channel       to_surface;     
  IGRuchar              ls_props;       
};

override      
  GRgraphics;     
override        
  EMSboundary;    

not_taggable;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMget_props
(
  IGRlong *EMmsg;
  IGRushort *props;
);

message EMgetrange
(
  IGRlong *EMmsg;
  IGRdouble *range;
);

message EMset_props
(
  IGRlong *EMmsg;
  IGRushort props;
  IGRshort option;
);

override
  EMgetsurface_info;


#ifndef BASE_EMS

message EMlsgetbdry
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct IGRbsp_surface *srfgeom;
  struct EMSpartolbasis *partolbas;
  IGRushort options;
  IGRint *numbdrys;
  struct IGRpolyline **xyzbdrys;
  struct IGRpolyline **uvbdrys;
  IGRdouble **lpranges;
  IGRushort **lpprops;
  GRobjid **lpids;
);

message EMmakeFRT
(
  IGRlong *EMmsg;
  GRobjid surf_id;
);

message EMtoglpactive
(
  IGRlong *EMmsg;
);

message EMdrop
(
  IGRlong *EMmsg;
);

message EMlsparttrim
(
  IGRlong *msg;
  struct EMSdataselect *ingeom;
  struct EMSpartolbasis *tol_basis;
  IGRushort options;
  IGRint *num_bdrys;
  struct EMSpypoint **bdrys;
  struct EMSsfintedpar **bdry_parms;
);

message EMlscleanup
(
  IGRlong *msg;
  IGRint *numsfs;
  struct EMSownercomp **sfloops;
  IGRint *numowners;
  struct EMSownercomp **owncomps;
  IGRushort options;
);

message EMtrim_extract
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct EMedge_round_info *my_info;
  struct GRid srf_GRid;
  IGRint num_edges;
  struct EMSpartolbasis *partolbasis;
  IGRint num_imp_loops;
  GRobjid *imp_loop_ids;
  IGRint *num_entries;
  GRobjid **out_loops;
  IGRboolean *in_area_trim;
  IGRboolean info_to_save;
  IGRint *num_saves;
  GRobjid *edge_ids;
  IGRboolean *to_disconnect;
  IGRint num_conn_edge;
  GRobjid *conn_edges;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  IGRint *num_def_info;
  struct EMdef_con_info *def_info;
  IGRboolean blend_surface;
  struct EMSsfintedpar ***trim_info;
);

message EMget_loops
(
  IGRlong *EMmsg;
  IGRlong option;
  IGRint *depth;
  GRobjid **loop_ids;
  IGRushort **props;
  IGRint *buf_size;
  IGRint *count;
);

message EMsplityourself
(
  IGRlong *EMmsg;
  GRobjid *input_loops;
  IGRint num_input_loops;
  struct EMSsfintedpar **in_trim_info;
  struct EMSsfintedpar ***out_trim_info;
  IGRint *num_out_trim_info;
  GRobjid **output_loops;
  IGRint *num_output_loops;
  IGRushort option;
  IGRint *num_sfs;
  struct EMSownercomp **sfloops;
  struct EMSpartolbasis *partolbasis;
  struct GRmd_env *env;
);

message EMimpose_boundaries
(
  IGRlong *EMmsg;
  GRobjid *bdrys;
  IGRint num_bdrys;
  IGRdouble *in_point;
  IGRboolean in_point_in_area;
  GRobjid **output_loops;
  IGRint *num_output_loops;
  struct EMSsfintedpar ***out_trim_info;
  IGRint *num_out_trim_info;
  IGRint *num_sfs;
  struct EMSownercomp **sfloops;
  struct EMSpartolbasis *partolbasis;
  struct GRmd_env *env;
  GRobjid *working_ls;
  IGRushort options;
);

message EMpack
(
  IGRlong *EMmsg;
  IGRboolean *on_off;
  IGRint *num_bdrys;
  struct IGRbsp_bdry_pts **bdrys;
  struct EMSdataselect *surf_data;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRushort options;
  struct EMSpartolbasis *ptol;
);

message EMmake_natural_loopset
(
  IGRlong *EMmsg;
  IGRuchar *curve_type;
  IGRushort *edge_props;
  GRobjid *edge_ids;
);

message EMtreemod
(
  IGRlong *EMmsg;
  struct EMSnest_info *nesting;
  IGRint operation;
  struct EMSpartolbasis *partolbasis;
);

message EMnesting
(
  IGRlong *EMmsg;
  struct EMSnest_info *nesting;
  struct EMSpartolbasis *partolbasis;
);

message EMpt_location
(
  IGRlong *EMmsg;
  IGRdouble *pt;
  struct EMSptloc_info *location;
  struct EMSpartolbasis *partolbasis;
);

message EMlsfulltrim
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct EMSdataselect *my_uvdata;
  struct EMSdataselect *my_xyzdata;
  struct IGRbsp_surface *my_srf;
  struct EMSpartolbasis *mypartol_basis;
  struct EMSdataselect *other_data;
  struct GRmdenv_info *other_datenv;
  struct EMSdataselect *other_uvdata;
  struct EMSdataselect *other_xyzdata;
  struct IGRbsp_surface *other_srf;
  struct EMSpartolbasis *otherpartol_basis;
  IGRdouble *correl_params;
  IGRushort options;
  IGRint *num_bdrys;
  struct EMSpypoint **my_bdrys;
  struct EMSsfintedpar **my_bdryparms;
  struct EMSpypoint **other_bdrys;
  struct EMSsfintedpar **other_bdryparms;
);

message EMsplit_into_two_ls
(
  IGRlong *EMmsg;
  IGRint num_imp_lps;
  GRobjid *imp_lp_ids;
  struct GRmd_env *env;
  struct EMSpartolbasis *partolbasis;
  GRobjid *gr1_ls_id;
  GRobjid *gr2_ls_id;
  GRobjid **amb_lps;
  IGRint *num_amb_lps;
);
	
message EMmkface_collapse_copy
(
  IGRlong *EMmsg;
  struct EMSpartolbasis *partolbasis;
  GRobjid *new_lps_added;
  IGRint *num_lps_added;
  GRobjid **lps_removed;
  IGRint *num_lps_removed;
  IGRint *lps_rm_array_size;
  struct EMSmkf_edcon_info **ed_con_info;
  IGRint *num_edcon_entries;
  IGRint *edcon_array_size;
);

message EMunpack
(
  IGRlong *EMmsg;
  struct EMSpartolbasis *partolbasis;
  struct GRvg_construct *const_list;
  GRobjid *bad_bdry_lnstr;
  IGRint *num_bad_bdrys;
);

message EMwindow
(
  IGRlong *EMmsg;
  IGRdouble *parm1;
  IGRdouble *parm2;
  IGRdouble *parm3;
  IGRshort *across_seam;
  IGRint split_ind;
  GRobjid *loopset_out;
  struct IGRbsp_surface *surf;
  IGRboolean transform;
  IGRdouble mint[];
  IGRdouble maxt[];
  struct EMSpartolbasis *partolbasis;
  struct GRmd_env *env;
  IGRboolean want_status_messages;
);

message EMcvboolean
(
  IGRlong *msg;
  enum EMSbooltype operation;
  GRobjid operand2;
  IGRushort options;
  IGRushort lssplit_opt;
  struct EMSownercomp **sfloops_unused1;
  struct EMSownercomp **sfloops_unused2;
  struct EMSownercomp **sfloops_used1;
  struct EMSownercomp **sfloops_used2;
  struct EMSpartolbasis *partolb;
);

message EMreverse
(
  IGRlong *msg;
);

message EMlspytrimint
(
  IGRlong *msg;
  struct IGRpolyline *inpoly;
  IGRdouble *inpoly_range;
  struct EMSpartolbasis *partol_basis;
  IGRushort options;
  IGRint *num_inters;
  struct EMSsfintedpar **myinters;
  struct EMSpypoint **polyinters;
);

message EMupdate_features
(
  IGRlong *EMmsg;
  GRobjid **added_obj;
  IGRint *num_added_obj;
  IGRint *numsfs;
  struct EMSownercomp **sfloops;
  IGRint *numowners;
  struct EMSownercomp **owncomps;
  IGRboolean insert_into_loopset;
  struct EMSpartolbasis *partolbasis;
);

message EMbounded_uv_range
(
  IGRlong *EMmsg;
  IGRdouble *range;
  IGRdouble *area;
  IGRshort *across_seam;
  IGRint *split_ind;
  IGRdouble *mid_uv;
  IGRlong *loop_num;
  GRobjid **lp_ids;
  IGRdouble **lp_ranges;
);
		
message EMdebug_send
(
  IGRlong *msg;
);

message EMptproject
(
  IGRlong *EMmsg;
  IGRdouble *points;
  IGRint num_points;
  struct EMSproj_info *proj_info;
  GRobjid *ed_ids;
  struct EMSpartolbasis *partolbasis;
);

reject 
  EMget_put_creator_id, 
  EMfix_creator_id;

override
  EMchksliver, 
  EMmatch_topology,
  EMsendtomsc,
  EMcoincedges,
  EMpostrtree,
  EMpostdelete,
  EMpostxform_xyz,
  EMremmsc,
  EMchkbindings,
  EMmk_act_cm_eds_connectable,
  EMtree_traverse,
  EMlinintgrl,
  EMcompress_top,
  EMuv_transform,
  delete, 
  EMobint,
  EMintcopy,
  EMcount_edges,
  EMget_edges,
  EMcheck_props, 
  debug,
  EMvalidate,
  EMbdrylocate,
  EMdebug_display;

#endif

end specification EMSloopset;
