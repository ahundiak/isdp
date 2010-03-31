# ifndef EMSlm_include
# define EMSlm_include

/*
    Depends on igrtypedef.h
*/

struct EMinstruction_table_info
{
    union operation_params
    {
        IGRdouble  vt_pt[2];
        IGRdouble end_pts[4];
    } params;
    unsigned short move_operation;
};

struct EMexec_info
{
  struct EMinstruction_table_info instruction;
  IGRshort index;
};

/*
 * The following structures are only for internal use
 * of MAKE FACE opeartion
 */

struct	EMSmkf_edcon_info
{
     GRobjid	ed_id;       /* edge whose common edges connection is */
                             /* moved to its copy during make face    */
     GRobjid	cm_ed_id;    /* edge's common edge id                 */
};

struct EMSmkf_grouping_info
{
  GRobjid                gr1_ls_id;
  GRobjid                gr2_ls_id;
  GRobjid                *amb_lps;
  IGRint                 num_amb_lps;
  GRobjid                *sf_org_lps;
  IGRint                 num_sf_org_lps;
  GRobjid                sf_org_ls;
  struct EMSsfintedpar   **loops_trim_info;
  IGRint                 num_trim_info;
  struct EMSownercomp    *sf_lps_removed;
  IGRint                 num_new_lps_added;
  GRobjid                *new_lps_added;
};

/*  round structs */

struct EMboundary_info
{
 IGRshort bnd_type;
 GRobjid loop_id;
 GRobjid rnd_loop_id;
 GRobjid rnd_edge_id;
 IGRdouble end_pts[4];
 IGRdouble point_in_area[2];
};

struct EMround_exec_info
{
  IGRshort index;
  struct EMboundary_info bnd_info;
};

struct EMedge_round_info
{
  GRobjid edge_id;
  IGRushort edge_type;
  IGRdouble radius;
  struct IGRbsp_curve *curve;
  struct IGRbsp_surface *surface;
  GRobjid surface_id;
  struct IGRbsp_curve *comm_curve;
  GRobjid comm_surface_id;
  struct IGRbsp_curve *other_curve;
  struct IGRbsp_surface *fillet_surface;
  GRobjid fillet_id;
  IGRboolean ends_free;
  IGRboolean fillet_modified;
};

struct EMvertex_curves
{
  struct IGRbsp_curve *curve;
  GRobjid edge_id;
  struct IGRbsp_surface *curves_surface;
  GRobjid fillet_id;
};

struct EMdef_con_info
{
 GRobjid def_edge;
 GRobjid com_edge1;
 IGRboolean c_e1_split;
 struct EMSedgebound ce1_param;
 GRobjid com_edge2;
 IGRboolean c_e2_split;
 struct EMSedgebound ce2_param;
 GRobjid edge_surf[3];
};

struct EMedge_con_info
{
 GRobjid edge;
 GRobjid edge_surf;
 GRobjid comm_edge;
 GRobjid comm_edge_surf;
 IGRboolean align_normal;
 struct IGRbsp_surface *surf_geom;
 struct IGRbsp_surface *comm_surf_geom;
};

struct EMround_save_state
{
 IGRint     num_surfaces;
 GRobjid    *surface_ids;
 IGRint     *num_regions_in;
 GRobjid    **region_in_ids;
 IGRint     *num_regions_out;
 GRobjid    **region_out_ids;
 IGRint     num_edges_out;
 GRobjid    *edge_out_ids;
 IGRint     *num_edges_in;
 GRobjid    **edge_in_ids;
 IGRint     num_edges_rounded;
 GRobjid    *rounded_edge_ids;
};

# endif
