/*
  ABSTRACT

  This is an abstract class that represents a linear element in
  the parametric space of a surface.

 
  HISTORY

  DLB     07/10/91        Disable tagging.
  gupta MAY 17 90 Removed EMedge_round message
  SM	30-Oct-89	Moved EMconn_to_my_assoc message to 
			EMSboundary.
  gupta   18 sep 1989     added message EMpyxyz_geometry.
  AIC     25 Jan 1989     Promoted EMstroke_iso_edge
                          message from EMSlinedge.
  SM	21-Jan-89	Added EMreplace_edge message.
  AIC     12 Oct 1988     Added ptol argument to
                          EMSedgepack message.
  SM      29-Sep-88       Added 'surf_data' argument to
                          EMputpygeom. It is required only if the
                          edge is iso.
  AIC     25-Sep-88       Added EMS.h to pre-define _iob for shared
                          library compilations.
  RV      07-Sep-88       Added matrix-type and matrix to
                          EMputpygeom.
  PP      08/11/88        Added partolbasis and options to
                          EMgetbcgeom and EMgetpygeom
  SM      14-Oct-87       1.1 Genesis
*/

class specification EMSedge (1:1) of EMSboundary;

# include "EMS.h"
# include <stdio.h>             

/*------------------ INSTANCE DATA SECTION -------------------*/

channel owner_channel
{
  (rel_ordered,
   many_to_many,
   initial = 1, increment = 1)
   EMSbd_owner.to_comps;
};

channel common_edge_channel
{
  (one_to_one)
  EMSedge.to_common_edge;
};

instance EMSedge
{
  channel owner_channel         to_owner;       
  channel common_edge_channel   to_common_edge; 
  IGRushort             	ed_props;       
  IGRuchar              	curve_type;     
};

override
  GRgraphics;

not_taggable;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetedgedef
(
  IGRlong *EMmsg;
  IGRushort options;
  struct EMSedgeinfo *edinfo;
);

message EMget_props
(
  IGRlong *EMmsg;
  IGRushort *props;
);

message EMget_props_type
(
  IGRlong *EMmsg;
  IGRushort *props;
  IGRuchar *type;
);

message EMgeomattr
(
  IGRlong *msg;
  IGRushort opts;
  IGRdouble uvtol;
  IGRboolean *is_uvdegen;
  IGRboolean *is_xyzdegen;
  IGRboolean *is_uvopen;
  IGRboolean *is_xyzopen;
);

message EMtopoattr
(
  IGRlong *msg;
  IGRushort opts;
  IGRboolean *is_connected;
  IGRboolean *is_dominant;
  IGRboolean *is_revconnected;
  IGRboolean *is_natural;
);

message EMendpts
(
  IGRlong *EMmsg;
  IGRdouble *begin_pt;
  IGRdouble *end_pt;
  struct EMSedgebound *begin_param;
  struct EMSedgebound *end_param;
  struct EMSpartedinfo *bnd;
);

message EMgetpygeom
(
  IGRlong *msg;
  IGRint from_spaninx;
  IGRint num_spans;
  IGRboolean reverse;
  struct EMSpartedinfo *partinfo;
  struct IGRpolyline *pygeom;
  struct EMSpartolbasis *partolbasis;
  IGRushort options;
);

message EMgetbcgeom
(
  IGRlong *msg;
  IGRint from_spaninx;
  IGRint num_spans;
  IGRboolean reverse;
  struct EMSpartedinfo *partinfo;
  struct IGRbsp_curve *bcgeom;
  struct EMSpartolbasis *partolbasis;
  IGRushort options;
);

message EMgetgeom
(
  IGRlong *msg;
  IGRint from_spaninx;
  IGRint num_spans;
  IGRboolean reverse;
  struct EMSpartedinfo *partinfo;
  struct EMSaltdataselect *geom;
);

message EMget_bcxyz_geom
(
  IGRlong *EMmsg;
  struct GRmdenv_info *mdenv;
  struct GRid *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRint from_spaninx;
  IGRint num_spans;
  IGRboolean reverse;
  struct EMSpartedinfo *partinfo;
  struct IGRbsp_curve *curve;
);

message EMget_location
(
  IGRlong *rc;
  IGRshort *location;
);

message EMgetrange
(
  IGRlong *EMmsg;
  IGRdouble *range;
  struct EMSpartedinfo *bnd;
);

message EMptproject
(
  IGRlong *EMmsg;
  IGRdouble *point;
  IGRint num_points;
  struct EMSproj_info *proj_info;
  struct EMSpartedinfo *bnd;
  struct EMSpartolbasis *partolbasis;
);

message EMptatpr
(
  IGRlong *EMmsg;
  IGRint num_param;
  struct EMSedgebound *param;
  IGRdouble *bs_param;
  IGRdouble *point;
);

message EMpratpt
(
  IGRlong *EMmsg;
  IGRdouble *points;
  IGRint num_points;
  struct EMSedgebound *params;
  IGRboolean *off_edge;
  struct EMSpartedinfo *bnd;
  struct EMSpartolbasis *partolbasis;
);

message EMsendmsg_changing_props
(
  IGRlong *msg;
  IGRushort chgprops;
  IGRshort chgopt;
  OM_p_MESSAGE messg;
);

message EMget_bottom_edge
(
  IGRlong *EMmsg;
  GRobjid *bottom_edge;
);

/*
  DESCRIPTION

  The following method returns TRUE if the edge is degenrate against a  given
  UV tolerance. The underlying fact here is not to classify the edge
  as degenerate depending on the  degenerate  bit  set on it, as one
  does not know which tolerance was used to  set the  bit.  So,  the
  system must be flexible enough to use it's own tolerances  for the
  geometry checks. This method provides such a flexibility.
*/

message EMisdegentol
(
  struct EMSpartedinfo *partinfo;
  IGRdouble tol;
  IGRboolean *is_degen;
);

message EMpostgeom
(
  IGRchar *edgeom
);

message EMset_props
(
  IGRlong *EMmsg;
  IGRushort props;
  IGRshort option;
);

message EMset_type
(
  IGRlong *EMmsg;
  IGRuchar curve_type;
);

message EMgetvtxedges
(
  IGRlong *msg;
  IGRushort options;
  IGRboolean right_vtx;
  IGRint num_buff;
  IGRint *num_edges;
  GRobjid **edges;
  IGRboolean **is_rightend;
);

message EMgetstrkpy
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct IGRbsp_surface *srfgeom;
  struct EMSpartolbasis *partolbas;
  IGRushort options;
  IGRint *num_xyzpts;
  IGRint *num_uvpts;
  IGRdouble **xyzpts;
  IGRdouble **uvpts;
);

message EMreverse
(
  IGRlong *EMmsg;
);

reject
  EMget_bcxyz_geom,
  EMgetpygeom, 
  EMgetbcgeom, 
  EMgetgeom, 
  EMendpts, 
  EMgetrange, 
  EMptproject, 
  EMptatpr, 
  EMpratpt,
  EMgeomattr,
  EMisdegentol, 
  EMpostgeom;

override
  EMgetsurface_info;

#ifndef BASE_EMS

message EMget_sf_geom
(
  IGRlong *EMmsg;
  struct GRid *srf_id;
  struct IGRbsp_surface **srf_geom;
  struct GRmdenv_info *md_env;
);

message EMget_edge_length
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmdenv_info *mdenv_info;
  IGRdouble *from_param;
  IGRdouble *to_param;
  IGRdouble *mid_pt_param;
  IGRdouble *edge_length;
);

message EMptalong
(
  IGRlong *msg;
  IGRushort opts;
  struct GRmdenv_info *mdenv_info;
  IGRpoint refpt;
  IGRdouble dist;
  IGRboolean in_fwd_dir;
  struct EMSpartedinfo *partinfo;
  IGRpoint pt;
);

message EMstroke_iso_edge
(
  IGRlong *EMmsg;
  IGRmatrix matrix;
  IGRshort *mx_type;
  struct GRid *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRboolean reverse;
  struct EMSpartolbasis *my_partol;
  GRobjid user_id;
  struct IGRpolyline *stroked_geom;
  IGRboolean update_instance_data;
);

message EMedge_config
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRpoint point_on_edge;
  GRobjid my_surf_id;
  GRobjid com_surf_id;
  IGRvector av_normal;
  struct IGRbsp_curve *my_geom;
  IGRdouble check_tol;
  IGRshort *edge_config;
);

message EMpyxyz_geometry
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct GRid *surf_id;
  struct IGRbsp_surface *surf_geom;
  IGRint from_spaninx;
  IGRint num_spans;
  IGRboolean reverse;
  struct EMSpartedinfo *partinfo;
  struct IGRpolyline *pygeom;
  struct EMSpartolbasis *partolbasis;
  IGRint *num_iso;
  struct EMtopology_info *topology;
  IGRboolean *swap_valid;
  IGRint *swap_index;
  IGRushort options;
);

message EMvertex_surface
(
  IGRlong *EMmsg;
  IGRint *vertex_number;
  IGRshort option;
  struct GRmd_env *my_env;
  IGRboolean vtx_to_int;
  struct GRvg_construct *construct_list;
  struct EMedge_round_info *my_info;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  IGRint num_edges;
  GRobjid *vtx_surf_id;
);

message EMtangent
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  GRobjid *my_surf_id;
  IGRpoint loc_pnt;
  IGRdouble disp_fac;
  struct IGRbsp_curve *my_geom;
  IGRvector tangent;
);

message EMget_plane
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  IGRint end_condition;
  IGRshort other_edge_type;
  GRobjid *f_edges;
  struct EMedge_round_info *my_info;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  struct IGRbsp_surface *my_surf_geom;
  struct IGRbsp_surface *other_surf_geom;
  IGRpoint *points;
  IGRpoint *pla_points;
  GRobjid other_edge;
  GRobjid *plane_id;
  struct GRvg_construct *construct_list;
  struct GRid *edge_id;
  IGRboolean *is_on_boundary;
  GRobjid *round_id;
);

message EMgeneral_patch
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct IGRbsp_curve *my_geom;
  struct IGRbsp_curve *other_geom;
  GRobjid *f_edges;
  IGRboolean end_condition;
  struct EMedge_round_info *my_info;
  IGRint *num_pair_info;
  struct EMedge_con_info *pair_info;
  IGRpoint *points;
  IGRpoint *pla_points;
  struct GRvg_construct *construct_list;
  GRobjid *plane_id;
  struct GRid *edge_id;
  GRobjid *round_id;
);
  
message EMshrink_geom
(
  IGRlong *EMmsg;
  IGRboolean my_stop;
  GRobjid other_loop;
  IGRboolean sender_atstop;
  struct EMSpartolbasis *partol;
);

message EMalter_geometry
(
  IGRlong *EMmsg;
  struct EMSsfintedpar *inters;
  IGRboolean end_truncated;
);

message EMexecuteCurveFunction
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf;
  IGRshort *mx_type;
  IGRmatrix mx;
  GRobjid surf_id;
  IGRint (*f)();
  IGRchar *args;
  IGRboolean *first_edge;
  IGRushort eligible_edge_type;
);

message EMtst_reversibility
(
  IGRlong *EMmsg;
  IGRboolean *rev_connect;
  GRobjid partner_id;
  GRobjid my_srf_id;
  GRobjid partner_srf_id;
  IGRboolean seam;
  struct GRmd_env *mod_info;
);


message EMkeypoint
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surface;
  struct IGRline *boreline;
  IGRpoint keypoint;
  struct GRparms *key_parm;
  IGRdouble *dist_sq;
);

message EMlocate
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surface;
  struct GRmdenv_info *env_info;
  struct GRid *surface_id;
  struct GRlc_info *loc_parms;
  struct GRlc_cvl *cvl;
  IGRlong *prism_rel;
  IGRboolean *inside;
  IGRboolean *outside;
  IGRboolean *overlap;
  IGRboolean locate_natural_edges;
  IGRboolean *was_located;
);

message EMdisplay
(
  IGRlong *EMmsg;
  struct DPele_header *ele_header;
  IGRshort *mx_type;
  IGRmatrix matrix;
  enum GRdpmode *mode;
  struct DP_information *sp_info;
  IGRshort display_flag;
  struct EMSpartedinfo *partinfo;
);

message EMget_natural_edges
(
  IGRlong *EMmsg;
  IGRint edge_num;
  GRobjid *buffer;
  IGRint buffer_size;
  GRobjid **nat_edge_ids;
  IGRint *num_nat_edges;
);

message EMconstruct_seg
(
  IGRlong *EMmsg;
  struct EMSpartedinfo *partinfo;
  struct EMSpartolbasis *partolbasis;
  GRobjid *new_objid;
);

message EMmove_vertex
(
  IGRlong *rc;
  IGRshort option;
  struct GRmd_env *my_env;
);

message EMmake_compatible
(
  IGRlong *rc;
  struct GRmd_env *my_env;
);

message EMmove_edge
(
  IGRlong *rc;
  struct GRmd_env *my_env;
);

message EMdrop
(
  IGRlong *EMmsg;
);

message EMedgepack
(
  IGRlong *EMmsg;
  IGRint *num_points;
  IGRdouble **points;
  IGRint *size;
  struct EMSdataselect *surf_data;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRushort options;
  struct EMSpartolbasis *ptol;
);



message EMconnect_edges
(
  IGRlong *EMmsg;
  IGRushort props;
  IGRboolean chk_reversibility;
  GRobjid partner_id;
  GRobjid mysrf_id;
  GRobjid partnersrf_id;
  struct GRmdenv_info *mdenv_info;
);

message EMpt_location
(
  IGRlong *msg;
  IGRdouble *pt;
  struct EMSptloc_info *info;
  struct EMSpartedinfo *part;
  struct EMSpartolbasis *partolbasis;
);


message EMsplityourself
(
  IGRlong *EMmsg;
  struct EMSsfintedpar **split_info;
  IGRushort options;
  GRobjid *svtx;
  GRobjid *edges;
  GRobjid *spliting_edge;
  IGRint *direction;
  struct EMSpartedinfo *part;
  struct EMSpartolbasis *partolbasis;
  struct GRmd_env *env;
  GRobjid **ptedges;
  IGRint *num_ptedges;
  IGRint *ptedges_buf;
);

message EMgetbounds
(
  IGRlong *EMmsg;
  struct EMSedgebound *bound;
);

message EMunsplityourself
(
  IGRlong *EMmsg;
  GRobjid *replace_edge;
);

message EMissplit
(
  IGRlong *EMmsg;
  IGRushort *split;
  GRobjid *split_obj;
);

message EMfind_commvtx
(
  IGRlong *msg;
  GRobjid commedge;
  IGRboolean commedge_right;
  IGRboolean searchdir_right;
  GRobjid *found_vtxedge;
);

message EMputpygeom
(
  IGRlong *msg;
  IGRint before_ptinx;
  IGRboolean reverse;
  struct IGRpolyline *inpygeom;
  IGRboolean check_constraints;
  struct EMSpartolbasis *partolbasis;
  struct EMSpartedinfo *part;
  struct EMSdataselect *surf_data;
  IGRshort *mattyp;
  IGRmatrix mat;
);

message EMputbcgeom
(
  IGRlong *msg;
  IGRint from_spaninx;
  IGRboolean reverse;
  struct IGRbsp_curve *inbcgeom;
);

message EMedpytrimint
(
  IGRlong *msg;
  struct IGRpolyline *inpoly;
  IGRdouble *inpoly_range;
  struct EMSpartolbasis *partol_basis;
  struct EMSpartedinfo *partinfo;
  IGRushort options;
  IGRint *num_inters;
  struct EMSsfintedpar **my_inters;
  struct EMSpypoint **polyinters;
);

message EMgettopedge
(
  IGRlong *msg;
  struct EMSedgebound *par;
  struct EMSpartolbasis *partol_basis;
  GRobjid *topedge;
);

message EMbstobnd
(
  IGRlong *EMmsg;
  IGRint num_param;
  IGRdouble *bs_param;
  struct EMSedgebound *bnd_param;
);

message EMbndtobs
(
  IGRlong *EMmsg;
  IGRint num_param;
  struct EMSedgebound *bnd_param;
  IGRdouble *bs_param;
);

message EMget_sf_edges
(
  IGRlong *EMmsg;
  IGRshort search_flag;
  struct GRid *edge_ids;
  IGRint *num_edges;
);

message EMtst_xyz_clsd
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *srf_geom;
  GRobjid srf_id;
  struct GRmdenv_info *md_env;
  IGRboolean *is_xyz_closed;
);

message EMtst_degn
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf;
  GRobjid srf_id;
  struct GRmdenv_info *md_env;
  IGRboolean *is_degen;
);

message EMtrimyourself
(
  IGRlong *EMmsg;
  GRobjid *against;
  IGRushort options;
  struct EMSsfintedpar **against_bdrys;
  struct EMSsfintedpar **my_bdrys;
  IGRint *num_bdrys;
  struct EMSpartedinfo *part;
  struct EMSpartolbasis *partolbasis;
);

message EMextractyourself
(
  IGRlong *EMmsg;
  struct EMSsfintedpar *my_bdrys;
  struct EMSsfintedpar *ele_bdrys;
  IGRint num_bdrys;
  GRobjid **output_obj;
  struct EMSsfintedpar ***out_bdrys;
  struct EMSsfintedpar ***against_bdrys;
  IGRboolean output_pairs;
  IGRushort options;
  struct EMSpartedinfo *bnd;
  struct EMSpartolbasis *partolbasis;
);

message EMconnect_to_ne
(
  IGRlong *EMmsg;
  GRobjid *connect_id;
);

message EMchild_crv_parm
(
  IGRlong *rc;
  struct EMSedgebound *my_edge_info;
  struct EMSedgebound *child_edge_info;
  struct GRmd_env *my_env;
  IGRshort my_edge_pos;
  GRobjid child_id;
);

message EMget_range_edges
(
  IGRlong *rc;
  struct GRmd_env *my_env;
  IGRshort position;
  IGRint num_parms;
  IGRdouble *in_parms;
  GRobjid (*pch_edge_ids)[4];
  GRobjid saved_edge;
  IGRint *num_full_edge;
  GRobjid *full_edge;
  GRobjid *keep_end_edge;
  GRobjid *keep_beg_edge;
  GRobjid *keep_mid_edge;
  struct EMSedgebound *parme;
  struct EMSedgebound *parmb;
);

message EMtwin_crv_parm
(
  IGRlong *rc;
  struct EMSedgebound *my_edge_info;
  struct EMSedgebound *other_edge_info;
  struct GRmd_env *my_env;
  IGRshort other_edge_pos;
  GRobjid *my_surf;
  GRobjid *other_surf;
);

message EMsplit_twin
(
  IGRlong *rc;
  IGRint num_parm;
  struct GRmd_env *my_env;
  IGRdouble *parm;
  IGRint *split_num;
  GRobjid *edge_ids;
  IGRboolean *reverse;
);

message EMis_parm_valid
(
  IGRlong *rc;
  IGRshort position;
  IGRint num_parm;
  IGRdouble *parms;
  IGRint *num_valid_parms;
  IGRdouble **valid_parms;
);

message EMmkface_collapse_copy
(
  IGRlong *EMmsg;
  struct EMSpartolbasis *partolbasis;
  IGRboolean always_cp_ed;
  GRobjid *ed_cp_id;
  struct EMSmkf_edcon_info **ed_conn_info;
  IGRint *num_entries;
  IGRint *array_size;
);

message EMget_top_part_edges
(
  IGRlong *EMmsg;
  GRobjid **part_edges;
  IGRint *num_part_edges;
  IGRint *buf_size;
);

message EMedbstrimint
(
  IGRlong *msg;
  struct IGRbsp_curve *incrv;
  IGRdouble *incrv_range;
  struct EMSpartolbasis *partol_basis;
  struct EMSpartedinfo *partinfo;
  IGRushort options;
  IGRint *num_inters;
  struct EMSsfintedpar **my_inters;
  struct EMSpypoint **polyinters;
);

message EMactivate_loop
(
  IGRlong *EMmsg;
  IGRint edge_index;
);

message EMis_edge_modif
(
  IGRlong *rc;
  IGRshort option;
  IGRshort which_vtx;
  IGRboolean *modifiable;
);
       
message EMstitch
(
  IGRlong *EMmsg;
  struct EMSstitch_info *pair;
  struct GRmd_env *mod_info;
  struct GRid *prim_obj;
  IGRint sample_size;
  IGRdouble match_tol;
  struct EX_button *button;
  FILE *fileptr;
);

message EMsfintdata
(
  IGRlong *msg;
  struct GRid *sf1;
  IGRboolean sf1_rev;
  struct GRmdenv_info *toxypln1;
  struct GRmdenv_info *towspace1;
  struct GRid *sf2;
  IGRboolean sf2_rev;
  struct GRmdenv_info *toxypln2;
  struct GRmdenv_info *towspace2;
  IGRushort proc_info;
  struct GRvg_construct *const_args;
  IGRushort outworld_options;
  IGRushort outparam_options;
  IGRushort trim_options;
  IGRlong *num_inters;
  struct EMSinters **sf1_inters;
  struct EMSinters **sf2_inters;
);

message EMsend_dummy_edge
(
  IGRlong *EMmsg;
  GRobjid sender_obj;
  OM_p_MESSAGE messg;
  IGRboolean *dummy_edge_found;
);

message EMget_coincedent_edge
(
  IGRlong *EMmsg;
  GRobjid *coincedent_edge;
);

message EMinternalpt
(
  IGRlong *msg;
  IGRint numpts;
  struct EMSproj_info *prjpts;
  IGRdouble *pts;
  struct EMSpartedinfo *partinfo;
  struct EMSpartolbasis *partolbasis;
);

message EMrefine_points
(
  IGRlong *EMmsg;
  struct EMSdataselect *surf_data[3];
  struct GRmdenv_info *env[3];
  struct EMSpartolbasis *tol[3];
  IGRdouble *uv_approx[3];
  IGRdouble *xyz_int_approx;
  IGRdouble *uv_exact[3];
  IGRdouble *xyz_int_exact;
  struct EMSsfintedpar *my_edpar;
  struct EMSsfintedpar *comm_edpar;
  IGRboolean *me_refined;
  IGRboolean *comm_refined;
  IGRboolean *me_hole;
  IGRboolean *comm_hole;
  struct EMSpartedinfo *part;
);
                        
message EMextend_geom
(
  IGRlong *EMmsg;
  IGRdouble *extnd_pt;
  IGRint *location;
  IGRboolean replace_endpt;
  IGRdouble *mindist;
  struct EMSpypoint *outpypoint;
  struct IGRpolyline *new_geom;
  struct EMSpartolbasis *partolbasis;
  IGRushort option;
  struct GRid *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRmatrix matrix;
  IGRshort *mx_type;
);
                
message EMextend_geometry
(
  IGRlong *EMmsg;
  GRobjid rnd_edge_id;
  GRobjid comm_surf_id;
  GRobjid my_surf_id;
  struct IGRbsp_surface *edge_surf;
  struct EMSpartolbasis *partol;
  GRobjid *round_id;
  struct GRmd_env *my_env;
);

message EMxyz_endpt
(
  IGRlong *EMmsg;
  struct GRid *surf_id;
  struct GRmdenv_info *md_env;
  IGRdouble *begin_pt_uv;
  IGRdouble *end_pt_uv;
  IGRdouble *begin_pt_xyz;
  IGRdouble *end_pt_xyz;
  struct IGRbsp_surface **surf_geom;
);

message EMget_topology_info
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf;
  IGRshort *mx_type;
  IGRmatrix mx;
  GRobjid surf_id;
  IGRushort eligible_edge_type;
  struct EMStopinfo **topinfo;
  IGRint *buf_size;
  IGRint *num_in_buf;
);

message EMptcoinc
(
  IGRlong *msg;
  IGRdouble *at_point;
  GRobjid *coincedge;
  IGRshort *neighbor_loc1;
  IGRshort *neighbor_loc2;
  struct EMSpartedinfo *partinfo;
  struct EMSpartolbasis *ptolbas;
);

message EMreplace_edge
(
  IGRlong *EMmsg;
  GRobjid new_edge;
  IGRboolean delete_old_edge;
);

message EMoffpoint
(
  IGRlong *EMmsg;
  struct EMSedgebound *edpar;
  IGRdouble *edpt;
  IGRdouble *tangent;
  IGRdouble offdist;
  GRobjid *sfobjid;
  struct IGRbsp_surface *sfgeom;
  struct GRmdenv_info *env;
  struct EMSpartolbasis *partolb;
  IGRint *numedges_visited;
  IGRint *edbufsize;
  GRobjid **edges_visited;
  IGRushort options;
  IGRdouble *off_edptuv;
  IGRdouble *off_edptxyz;
  GRobjid *off_edptsf;
);
		
message EMchkconvex
(
  IGRlong *msg;
  IGRushort opts;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRdouble neutral_angle_tol;
  IGRboolean *convex;
  IGRboolean *neutral;
  IGRdouble *angmeas;
);

message EMget_vtx_sfs
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRboolean is_stop_end;
  IGRint *num_surfaces;
  GRobjid **sf_ids;
  IGRboolean *is_vtx_closed;
);

message EMget_encompassing_edges
(
  IGRlong *msg;
  IGRushort options;
  IGRboolean right_vertex;
  GRobjid *surfs;
  IGRint *num_edges;
  GRobjid **edges;
);


reject
  EMstroke_iso_edge,
  EMpt_location, 
  EMgetbounds, 
  EMpyxyz_geometry,
  EMputbcgeom, 
  EMedpytrimint, 
  EMgettopedge, 
  EMbndtobs, 
  EMbstobnd, 
  EMextractyourself, 
  EMconstruct_seg;

override
  EMbdrylocate,
  EMcount_edges, 
  EMget_edges,
  EMtree_traverse,
  EMchksliver, 
  EMmatch_topology,
  EMsendtomsc,
  EMcoincedges,
  EMpostrtree,
  EMpostdelete,
  EMpostxform_xyz,
  EMputmsc,
  EMremmsc,
  EMchkbindings,
  EMarea, 
  EMgetxyzobj, 
  EMmk_act_cm_eds_connectable,
  EMlinintgrl,
  EMcompress_top,
  EMgetobjinfo,
  delete,
  EMintcopy,
  EMcheck_props,
  EMobint,
  EMvalidate,
  EMdebug_display,
  GRprint,
  GRread;

#endif

end specification EMSedge;
