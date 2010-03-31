/*
 * This file contains the structure definitions needed for
 * a Lift operation messages/methods.
 */

# ifndef EMSlift_include
# define EMSlift_include   1

/*Defines for EMSs?dlift associative type*/
#define     EMdlft_NEG_MAG_OUTSIDE                  0x1
#define     EMdlft_NEG_ANGLE_OUTSIDE                0x2
#define     EMdlft_POS_MAG_INSIDE                   0x4
#define     EMdlft_PLANE_CONVERSION                 0x8

/*Defines for EMSs?lift associative type*/
#define     EMlft_POS_WITH_VECT                     0x1
#define     EMlft_WITH_POS_ORIENT                   0x2
#define     EMlft_PLANE_CONVERSION                  0x4

/*
 * The following structure is used to store the relevant
 * information needed in processing an edge during a regular
 * lift operation.
 */

struct EMSlft_ed_info
{
   struct   GRid              ed_GRid;
   IGRushort          ed_sf_type;
   IGRuchar           ed_cv_type;
   IGRushort          ed_constraint_type;
};

/*
 * The following structure is used to store the relevant
 * information needed in processing a subloop during a regular
 * lift operation.
 */

struct EMSlft_slp_info
{
   IGRint                    num_edges;
   struct  EMSlft_ed_info    *ed_info;
};

/*
 * The following structure is used to store the relevant
 * information needed in processing a loop during a regular
 * lift operation.
 */

struct EMSlft_lp_info
{
   IGRint                    num_sublps;
   struct EMSlft_slp_info    *sublps_info;
   IGRboolean                match_end_pts_eds;
};

/*
 * The following structure is used to store the relevant
 * information needed in processing a regular
 * lift operation.
 */

struct EMSlft_info
{
   struct GRid               sf_GRid;
   IGRuchar          lift_operation;
   IGRushort         active_constraints;
   IGRint                    num_lps;
   IGRint                    num_ed_infos;
   struct   EMSlft_lp_info   *lps_info;
};

/*
 * The following structure is used to store the relevant
 * information needed in processing an edge during a lift
 * with draft operation.
 */

struct EMSdlft_ed_info
{
   struct   GRid              ed_GRid;
   IGRushort          ed_sf_type;
   IGRuchar           ed_cv_type;
   IGRushort          ed_constraint_type;
   IGRdouble                  draft_angle;
   struct EMSvalue_info       assoc_draft_angle;
   IGRint                     offset_code;
};

/*
 * The following structure is used to store the relevant
 * information needed in processing a loop during a 
 * lift with draft operation.
 */

struct EMSdlft_lp_info
{
  struct GRid               lp_GRid;
  IGRboolean                is_uniform;
  IGRdouble                 draft_angle;
  struct EMSvalue_info      assoc_draft_angle;
  IGRboolean                fillet;
  IGRint                    num_eds;
  struct EMSdlft_ed_info    *eds_info;
};

/*
 * The following structure is used to store the relevant
 * information needed in processing a lift-with-draft
 * operation.
 */

struct EMSdlft_info
{
   struct GRid               sf_GRid;
   IGRuchar          lift_operation;
   IGRvector                 draft_vec;
   struct EMSvalue_info      assoc_magnatude;
   IGRdouble                 mx_exlp_dangle;
   IGRboolean                uniform_surface;
   struct EMSvalue_info      assoc_draft_angle;
   IGRboolean                no_fillets;
   IGRint                    num_ed_infos;
   IGRint                    num_lps;
   struct   EMSdlft_lp_info  *lps_info;
};

/*
 * The following structure is used to store the 
 * edge specific constraint information.
 */

struct EMSlft_cnstrnt_info
{
   IGRint            num_edges;
   struct GRid       *ed_GRid;
   IGRushort *ed_constraint;
};

/*
 * The following structure is used to store the information
 * regarding an edge and the edges resulting from its split.
 * It stores the edge id, num of split edges per edge and
 * out split edges' ids.
 */

struct EMSlft_edsp_info
{
  IGRint     num_eds;
  IGRint     eds_arrsz;
  IGRint     num_sp_eds;
  IGRint     sp_eds_arrsz;
  GRobjid    *ed_ids;
  IGRint     *sp_eds_pred;
  GRobjid    *sp_eds;
};

/*
 * The following structure is used to store the 
 * old and new common edge information regarding an edge 
 * used in lift process. There are four edge objids per
 * edge lifted. The four objids are store in the following
 * manner:
 *
 * 1. Edge id.
 * 2. Edge's old_cm_ed id.
 * 3. Edge's new_cm_ed id.
 * 4. EDge's old_cm_ed's_new_cm_ed id.
 */

struct EMSlft_edv0v1_info
{
  IGRint       num_eds;
  IGRint       array_size;
  GRobjid      *ed_ids;
};

/*
 * The folowing structure is used to save the edges whose
 * common edge connections have been moved.
 *
 * For each entry, there will be two edge objids stored, namely:
 *
 *  1. The edge_1 whose common edge is moved to edge_2.
 *  2. The edge_2 to which the common edge of edge_1 is moved.
 */
 
struct EMSlft_edcn_info
{
   IGRint        num_eds;
   IGRint        array_size;
   GRobjid       *ed_ids; 
};

/*
 * The following structure is used to store the information 
 * needed to perform edge_matching between two groups of edges.
 *
 * For each edge, its objid and its surface's objid is stored.
 */

struct EMSlft_edmtch_info
{
  IGRint   num_eds;
  IGRint   array_size;
  GRobjid  *ed_ids;
  GRobjid  *sf_ids;
};  

/* 
 * The folowing structure is used to store the information
 * about the loops added/removed (modified) per surface
 * during a lift operation.
 */

struct EMSlft_lpmod_info
{
  IGRint    num_sfs;
  IGRint    sf_arrsz;
  IGRint    num_lps_added;
  IGRint    num_lps_rmvd;
  IGRint    lps_added_arrsz;
  IGRint    lps_rmvd_arrsz;
  GRobjid   *sf_ids;
  GRobjid   *lp_added_ids;
  GRobjid   *lp_rmvd_ids;
  IGRint    *lps_added_prsf;
  IGRint    *lps_rmvd_prsf;
};

/*
 * The following structure is used to store the information
 * regarding the composites from which the surfaces are taken
 * out, removed surfaces and the composite indices
 */

struct EMSlft_sfrmvd_info
{
  IGRint      num_compsf;
  IGRint      compsf_arrsz;
  GRobjid     *compsf_ids;
  IGRint      *num_sf_prcompsf;
  IGRint      num_sf_rmvd;
  IGRint      sf_arrsz;
  GRobjid     *sf_ids;
  IGRint      *sf_idx;
};

# endif
