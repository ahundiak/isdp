/*
  ABSTRACT

  This class represents an region on the surface.


  HISTORY

  DLB     07/10/91    Disable tagging.
  11 Jul 1989 jBk Replaced matrix and matrix_type arguments of
                  EMareaDisplay message with p_env argument.
  19 Dec 1988 jBk Added messages EMfindContiguousArea,
                  EMploopLeaveLoopset, EMcloopLeaveLoopset and
                  EMareaDisplay.
  12 Oct 1988 AIC Added ptol argument to EMrgpack message.
  09 Sep 1988 jBk Changed name of message EMget_adjacent_loops to
                  EMgetAdjacentLoops.  Added mustHaveProps and
                  mustNotHaveProps arguments to message
                  EMgetAdjacentLoops.
  SM      14-Oct-87       1.1 Genesis
  RC      10-Nov-87       Changed arguments to EMmake_natural_loop.
  PP      12/01/87        Changed arguments to EMmake_lb_loop
  SM      01-Dec-87       made the option argument to EMnext_edge
                          into a unsigned short. See file
                          emsgeteddef.h for options.
  RC      02/08/87        Added EMmkf_lp_display.
  RC      04/09/88        Added message EMptproject.
  SAM     07-Apr-88       Changed EMinsert_edge to EMmodify_edge.
  AIC     10-Aug-88       Removed EMnaturalIntPts.
  SM      10-Aug-88       Added 'options' argument to EMlpinit.
  RC      18-Nov-88       Added EMperform_xsection_update message.
  SM      07-Dec-88       Argument change for EMtoggle_type.
*/

class specification EMSloop (1:1) of EMSrequester,EMSbd_owner,EMSboundary;

# include "EMSadt.h"
# include "EMSintf.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

channel outter_channel
{
  (many_to_one)
  EMSloop, EMSloopset;
};

channel inner_channel
{
  (rel_ordered,
   one_to_many,
   initial = 0, increment = 1)
  EMSloop.to_outter;
};

instance EMSloop
{
  channel outter_channel        to_outter;      
  channel inner_channel         to_inner;       
  IGRdouble                     range[4];       
  IGRushort             lp_props;       
};

not_taggable;

override        
  GRgraphics;


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

message EMgeomattr
(
  IGRlong *msg;
  IGRushort opts;
  IGRdouble uvtol;
  IGRboolean *is_noarea;
  IGRboolean *is_openloop;
);

message EMtopoattr
(
  IGRlong *msg;
  IGRushort opts;
  IGRboolean *is_connected;
  IGRboolean *is_active;
  IGRboolean *is_ploop;
  IGRboolean *is_natural;
);

message EMnext_edge
(
  IGRlong *EMmsg;
  IGRushort option;
  GRobjid ref_edge;
  GRobjid *edge;
);

message EMendpts
(
  IGRlong *EMmsg;
  IGRdouble *begin_pt;
  IGRdouble *end_pt;
  struct EMSedgebound *begin_param;
  struct EMSedgebound *end_param;
);

message EMset_props
(
  IGRlong *EMmsg;
  IGRushort props;
  IGRshort option;
);

message EMsetrange
(
  IGRlong *EMmsg;
);

override
  EMgetsurface_info;

#ifndef BASE_EMS

message EMlpgetbdry
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct IGRbsp_surface *srfgeom;
  struct EMSpartolbasis *partolbas;
  IGRushort options;
  IGRint depth;
  IGRint *numbdrys;
  struct IGRpolyline **xyzbdrys;
  struct IGRpolyline **uvbdrys;
  IGRdouble **lpranges;
  IGRushort **lpprops;
  GRobjid **lpids;
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
  IGRushort eligible_edge_type;
);

message EMrgpack
(
  IGRlong *EMmsg;
  IGRboolean *on_off;
  IGRint *num_bdrys;
  struct IGRbsp_bdry_pts **bdrys;
  IGRint *size;
  struct EMSdataselect *surf_data;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRushort options;
  struct EMSpartolbasis *ptol;
);

message EMmodify_edge
(
  IGRlong *EMmsg;
  IGRlong option;
  IGRlong num_edges;
  GRobjid ref_edge;
  GRobjid *edge;
  IGRboolean update_range;
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
  IGRdouble *point;
  struct EMSptloc_info *location;
  struct EMSpartolbasis *partolbasis;
);

message EMcloseyourself
(
  IGRlong *EMmsg;
  GRobjid *loopset;
  IGRboolean *closed;
  struct EMSpartolbasis *partolbasis;
);

message EMlpinit
(
  IGRlong *EMmsg;
  IGRushort props;
  struct EMSpartolbasis *partolbasis;
  IGRushort options;
);

message EMgivenestinfo
(
  IGRlong *EMmsg;
  struct EMSnest_info *nesting;
);

message EMtreemod
(
  IGRlong *EMmsg;
  struct EMSnest_info *nesting;
  IGRint operation;
  struct EMSpartolbasis *partolbasis;
);


message EMreverse
(
  IGRlong *EMmsg;
);

message EMptnesting
(
  IGRlong *EMmsg;
  IGRdouble *pt;
  struct EMSptloc_info *info;
  struct EMSpartolbasis *partolbasis;
);

message EMlppytrimint
(
  IGRlong *msg;
  struct IGRpolyline *inpoly;
  IGRdouble *inpoly_range;
  struct EMSpartolbasis *partol_basis;
  IGRint tree_depth;
  IGRushort options;
  IGRint *num_inters;
  struct EMSsfintedpar **myinters;
  struct EMSpypoint **polyinters;
);

message EMlpcleanup
(
  IGRlong *msg;
  IGRint *numsfs;
  struct EMSownercomp **sfloops;
  IGRint *numowners;
  struct EMSownercomp **owncomps;
  IGRushort options;
);

message EMtplydelete
(
  IGRlong *msg;
  IGRint *numsfs;
  struct EMSownercomp **sfloops;
  IGRint *numowners;
  struct EMSownercomp **owncomps;
  IGRushort options;
);

message EMtrimyourself
(
  IGRlong *EMmsg;
  GRobjid *against;
  IGRushort options;
  struct EMSsfintedpar ***against_bdrys;
  struct EMSsfintedpar ***lp_bdrys;
  GRobjid **loopids;
  IGRint *num_loops;
  IGRint **num_bdrys;
  IGRint *buf_size;
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
  struct EMSpartolbasis *partolbasis;
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

message EMtoggle_type
(
  IGRlong *EMmsg;
  IGRboolean P_loop;
  IGRboolean deletable;
  GRobjid sender_obj;
  IGRushort options;
  IGRint *numtogloops;
  GRobjid **togloops;
  IGRint *numdelloops;
  GRobjid **delloops;
  IGRint *num_loops_received;
  GRobjid **loops_received;
);

message EMlpbstrimint
(
  IGRlong *EMmsg;
  struct IGRbsp_curve *incurve;
  IGRdouble *incurve_range;
  struct EMSpartolbasis *partol_basis;
  IGRint tree_depth;
  IGRushort options;
  IGRint *num_inters;
  struct EMSsfintedpar **myinters;
  struct EMSpypoint **polyinters;
);

message EMmakeFRT
(
  IGRlong *EMmsg;
  GRobjid surf_id;
);

message EMdrop
(
  IGRlong *EMmsg;
);

message EMmake_lb_loop
(
  IGRlong *EMmsg;
  IGRushort loop_props;
  IGRint no_of_edges;
  struct IGRbsp_curve **edgegeom;
  IGRuchar *curve_type;
  struct EMSpartolbasis *partolbasis;
  GRobjid *edgeids;
);

message EMmake_natural_loop
(
  IGRlong *EMmsg;
  IGRuchar *curve_type;
  IGRushort *edge_props;
  GRobjid *edges;
);

message EMmergeloop
(
  IGRlong *msg;
  GRobjid loop;
  IGRboolean *inloop_atend;
  IGRboolean *thisloop_atend;
  struct EMSpartolbasis *partol_basis;
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

message EMgroup_loops
(
  IGRlong *EMmsg;
  GRobjid gr1_lp_to_connect;
  GRobjid gr2_lp_to_connect;
  IGRlong sender_lp_type;
  IGRlong sender_lp_gr;
);

message EMgetAdjacentLoops
(
  IGRlong *EMmsg;
  GRobjid *master_list_lps;
  IGRint *num_master_list_lps;
  GRobjid *adjacent_lps;
  IGRint *num_adj_lps;
  IGRushort mustHaveProps;
  IGRushort mustNotHaveProps;
);

message EMactivate_loop
(
  IGRlong *EMmsg;
);

message EMptinside
(
  IGRlong *msg;
  IGRuint *callinx;
  struct EMSpartolbasis *partolb;
  IGRint numpts;
  IGRdouble *pts;
  IGRdouble *atleast_dist;
);

message EMalternate_pt_location
(
  IGRlong *EMmsg;
  IGRdouble *point;
  struct EMSptloc_info *location;
  struct EMSpartolbasis *partolbasis;
);

message EMmkf_lp_display
(
  IGRlong *EMmsg;
  struct DPele_header *sf_ele_header;
  IGRshort *mx_type;
  IGRmatrix matrix;
  enum GRdpmode *display_mode;
  struct DP_information *sp_info;
  IGRshort display_flag;
  IGRlong sender_lp_type;
  IGRlong sender_lp_gr;
  IGRlong external_lp_gr;
  IGRlong display_gr;
  IGRuchar p_lp_style;
  IGRuchar c_lp_style;
  IGRboolean *any_lp_displayed;
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

message EMfindContiguousArea
(
  IGRlong *rc;
  OM_S_OBJID adjPloopsScratchMemory[];
  struct EMStreeHeap **pp_area;
);

message EMpropagateToAdjacentLoops
(
  IGRlong *rc;
  OM_S_OBJID adjPloopsScratchMemory[];
  OM_p_MESSAGE messageToPropagate;
);

message EMareaDisplay
(
  IGRlong *rc;
  struct GRmd_env *p_env;
  enum GRdpmode mode;
);

message EMperform_xsection_update
(
  IGRlong *EMmsg;
  struct EMSxs_tp_upd_info *xs_tp_info;
  struct EMSxs_assoc_info *xs_assoc_info;
  struct EMSxs_assoc_info *md_sfs_old_int;
  struct EMSsfs_md_info *sfs_md_info;
);

message EMgetbcgeom
(
  IGRlong *EMmsg;
  struct IGRbsp_curve **bcgeom;
  struct EMSpartolbasis *ptol;
  IGRushort options;
);

message EMloopInterference
(
  IGRlong *EMmsg;
  GRobjid other;
  enum EMSintfType *type;
  struct IGRbsp_curve **outmycv;
  struct IGRbsp_curve **outothercv;
  struct IGRbsp_curve *inmycv;
  struct IGRbsp_curve *inothercv;
  IGRdouble *maxdist;
  IGRdouble *mindist;
  IGRdouble *maxpts;
  IGRdouble *minpts;
  struct EMSpartolbasis *ptol;
);

message EMdelbnd_init
(
  IGRlong *msg;
  struct GRvg_construct construct_list;
  IGRint *numsfs;
  struct EMSownercomp **sfloops;
  IGRint *numowners;
  struct EMSownercomp **ownercomps;
  IGRint *num_edges;
  GRobjid **edges;
  IGRushort options;
);

message EMget_nest_depth
(
  IGRlong *msg;
  GRobjid *loop_id;
  IGRboolean *found;
  IGRint *count;
  IGRint *depth;
  IGRint *width;
);

message EMremove_adjacent_holes
(
  IGRlong *msg;
  IGRulong options;
  IGRboolean in_area;
  struct EMSinters *inters;
  struct EMSownercomp **sfloops;
  IGRint *num_loops_visited;
  GRobjid **loops_visited;
);


message EMget_all_connected_loops
(
  IGRlong *msg;
  IGRboolean restriction;
  GRobjid *restricted_loops;
  IGRint num_of_restricted_loops;
  GRobjid **lp_node;
  IGRint *loop_count;
);

override
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
  EMmk_act_cm_eds_connectable,
  EMgetxyzobj,
  EMtree_traverse,
  EMlinintgrl,
  EMuv_transform,
  EMcompress_top,
  EMcount_edges,
  EMget_edges,
  delete,
  EMintcopy,
  EMobint,
  EMcheck_props, 
  debug,
  EMvalidate,
  EMbdrylocate,
  EMdebug_display;

#endif

end specification EMSloop;
