# ifndef EMSxsection_include
# define EMSxsection_include 1

/*
   DESCRIPTION

      This file contains the definitions and the structures needed
      in creating/updating a cross section.


   HISTORY

     RC    09/10/88    Creation Date

*/

/*
 * The follwoing options are used in retrieving the surfaces
 * that are added/modified/removed while going from one node
 * to another in a state tree.
 */

 #define EMS_O_NEW_SFS      0x01
 #define EMS_O_GM_MD_SFS    0x02
 #define EMS_O_TP_MD_SFS    0x04
 #define EMS_O_RMVD_SFS     0x08

/*
 * The following flags are used in stating the type of correlation
 * between an old edge and a new edge of a cross_section.
 */

#define EMSXS_NO_MATCH                 0
#define EMSXS_OLD_NEW_ED_MATCH_FULLY   1
#define EMSXS_OLD_ED_PART_OF_NEW_ED    2
#define EMSXS_NEW_ED_PART_OF_OLD_ED    3

#define EMSED_UNMD        0
#define EMSED_MD          1
#define EMSED_RMVD        2

/*
 * The following options are used in storing the alignment information
 */

#define EMS_FMT_TRANS_VEC_ROT_ANGLE     0x1
#define EMS_FMT_MATRIX                  0x2


/*
 * The following options are used in retrieving corss section edges
 * that are associated to the model's surfaces.
 */

#define EMSXS_ACT_EDGES     0x1
#define EMSXS_INACT_EDGES   0x2


/*
 * The following definitions are used in connecting edges
 * of the adjacent planes of the cross section.
 */

#define EMSXS_NO_MATCH       0x1
#define EMSXS_ED_U0_MATCH    0x2
#define EMSXS_ED_U1_MATCH    0x4
#define EMSXS_ED_U0_PRC      0x8
#define EMSXS_ED_U1_PRC     0x10


/*
 * The following structure is used to store the information
 * regarding the surfaces modified/added/removed in going
 * from one node to another in a state tree.
 */

struct EMSsfs_md_info
 {
   IGRint       num_sfs_added;
   IGRint       num_sfs_gm_md;
   IGRint       num_sfs_tp_md;
   IGRint       num_sfs_rmvd;
   IGRint       sfs_added_arrsz;
   IGRint       sfs_gm_md_arrsz;
   IGRint       sfs_tp_md_arrsz;
   IGRint       sfs_rmvd_arrsz;
   struct GRid  *sfs_added;
   struct GRid  *sfs_gm_md;
   struct GRid  *sfs_tp_md;
   struct GRid  *sfs_rmvd;
 };

/*
 * The following structure is used to store 
 * model-surface/cross-section-edge association information when
 * a cross section is constructed/upated.
 */

struct EMSxs_assoc_info
{
  GRobjid     *sf_list;
  GRobjid     *ed_list;
  IGRint      *num_eds_sf;
  IGRint      sf_list_arrsz;
  IGRint      num_sfs;
  IGRint      ed_list_arrsz;
  IGRint      num_eds;
};

/*
 * The following structure is used to store the save state
 * information while updating a cross-section.
 */

struct EMSxsreg_md_info
{
  IGRint      num_cmsf;
  IGRint      cmsf_arrsz;
  GRobjid     *cmsf_ids;
  IGRint      *num_sf_rmvd_cmsf;
  IGRint      num_rmvd_sfs;
  IGRint      rmvd_sf_arrsz;
  GRobjid     *rmvd_sf_ids;
  IGRint      *rmvd_sf_idx;
  GRobjid     *sf_ids;
  IGRint      *num_reg_sf_in;
  IGRint      *num_reg_sf_out;
  GRobjid     *reg_in_ids;
  GRobjid     *reg_out_ids;
  IGRint      num_sfs;
  IGRint      sf_arrsz;
  IGRint      num_reg_in;
  IGRint      reg_in_arrsz;
  IGRint      num_reg_out;
  IGRint      reg_out_arrsz;
};

/*
 * The following structure is used to store the cross_section planes
 * information while constructing from a cross_section profile.
 */

struct EMSxs_pl_info
{
  IGRdouble     seg_pts[6];
  IGRdouble     pl_nrml[3];
  IGRdouble     trans_vec[3];
  IGRdouble     rot_ang;
};

struct EMSxs_ed_match_info
{
  GRobjid                *old_ed_ids;
  GRobjid                *new_ed_ids;
  IGRshort               *match_type;
  struct   EMSedgebound  *ed_bnds;
  IGRint                 num_eds;
  IGRint                 eds_arrsz;
  
};

 struct EMSxs_ed_info
 {
   struct EMSedgebound       bnd[2];
   IGRdouble                 range[4], end_pts[4], mid_pt[2];
   IGRshort                  overlap;
   GRobjid                   objid, oed_id;
   IGRboolean                end_pts_match[2], processed;
 };

struct EMSxs_tp_upd_info
{
  IGRint num_lps;
  struct EMSxs_lp_info *lps_info;
};

struct EMSxs_lp_info
{
  GRobjid  lp_id;
  IGRint   num_eds;
  GRobjid  *ed_ids;
  GRobjid  *ed_sf_ids;
  IGRshort *ed_status;
};

struct EMSxs_sfcn_info
{ 
  struct GRid              sf_GRid;
  struct GRid              *ed_u0_GRids;
  struct GRid              *ed_u1_GRids;
  IGRint                   num_ed_u0s;
  IGRint                   num_ed_u1s;
  IGRshort                 match_info;
  IGRdouble                ed_u0_pts[6];
  IGRdouble                ed_u1_pts[6];
  struct EMSxs_sfcn_info   *next, *fwrd, *bkwrd;
};

struct EMSxs_cn_info
{
  IGRint                  num_sfs;
  struct EMSxs_sfcn_info  *sfcn_info;
};

# endif
