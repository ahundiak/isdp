/*
 * ABSTRACT
 *
 *  This file contains the structure definitions needed for
 *  sorting the intersection data in a special boolean operation
 *  such as special union, difference or intersection.
 *
 * HISTORY
 *          RC     06/30/89      Creation Date
 *          NP     07/06/93      Added "EMadd_material" and "EMSremove_material"
 *                               related to generation of sort points.
 */

  
# ifndef EMSsfintsort_include
# define EMSsfintsort_include   1


/* These options are related to add/remove material. These are used in 
 * generation of sort points for selective boolean.
 */

#define EMSadd_material 0x01
#define EMSremove_material 0x02








#define EMSsgr_bnd                     0
#define EMSed_bnd_wopen_end            1
#define EMSed_bnd_wfixed_end           2
#define EMSed_bnd                      3
#define EMSlp_bnd                      4
#define EMSface_bnd                    5
#define EMSno_bnd                      6

#define EMSoprnd_A          0
#define EMSoprnd_B          1

#define OP2_BUF_SIZE        10

#define EMSextend_begin_cap   0
#define EMSextend_end_cap     1
#define EMSextend_both_ends   2

struct EMSsortpt_info
{
 struct GRmd_env      md_env;
 struct EMSptloc_info ptloc_info;
 IGRpoint             xyz_pt;
 GRobjid              sf_id;
 IGRint               ed_oprnd;
};

struct EMSint_set
{
 struct EMSsftracedata      trace_data[2];
 struct EMSsfintloopsdata   sflp_data[2];
 IGRint                     trdata_arrsz[2];
 IGRboolean                 has_pt;
 struct EMSsortpt_info      sortpt_info;
};

struct EMSsorted_info
{
  GRobjid               ed_id;
  struct EMSedgebound   ed_bounds[2];
  IGRdouble             ed_pts[4];
};

struct  EMSsortsgr_info
{
 IGRint              num_elems;
 IGRboolean          sgr_rev, sgr_closed;
 GRobjid             lp_id;   
 GRobjid             sf_id;
};

union EMSsortbnd_data
{
 struct EMSsorted_info     ed_info;
 struct EMSsortsgr_info    sgr_info;
};

struct EMSsortbnd_info
{
 IGRchar                   bnd_type;
 union EMSsortbnd_data     bnd_data;
 struct EMSsortbnd_info       *next;
};

struct EMSsortlp_info 
{
 GRobjid                  lp_id;
 struct EMSsortbnd_info   *bnd_info;
};

struct EMSsortfc_info
{
 struct EMSsortlp_info   *p_lp;
 struct EMSsortlp_info   **c_lps;
 IGRint                  num_c_lps;
 IGRint                  c_lps_arrsz;
};

struct EMSsortsf_info
{
 GRobjid                   sf_id;
 IGRint                    num_faces;
 IGRint                    faces_arrsz;
 struct EMSsortfc_info     **faces_info;
};

struct EMSsort_info
{
 IGRint                    num_sfs[2];
 IGRint                    sfs_arrsz[2];
 struct EMSsortsf_info     *sfs_info[2];
};

struct EMSsf_tol_info
{
 GRobjid      *sf_ids;
 IGRdouble    *par_tols;
 IGRint       num_sfs;
 IGRint       sfs_arrsz;
 IGRshort     *mattyp;
 IGRdouble    *matrix;
};

struct EMSgen_info
{
 IGRint   num_elems;
 IGRint   arrsz;
 IGRchar  **elems;
};

struct EMSused_lps
{
 IGRint   num_lps;
 IGRint   lps_arrsz;
 GRobjid  *lp_ids;
};

struct EMStp_objects_info
{
 GRobjid   ls_id;
 GRobjid   *lp_ids;
 IGRint    num_lps, lps_arrsz;
 GRobjid   *ped_ids;
 IGRint    num_peds, peds_arrsz;
};

struct EMSextend_info
{
  IGRdouble               bcap_ref_pt[3];
  IGRdouble               ecap_ref_pt[3];
  struct IGRbsp_curve     *bcap_geom;
  IGRshort                extension_type;
  OMuword                 object_classid;
 };

/*
 * Macros used in sorting the intersection data
 */

#define EFget_sortbnd(trsh_bnds_info, bnd_info) \
{ \
  if ((trsh_bnds_info)->num_elems) \
    (bnd_info) = (struct EMSsortbnd_info *)(trsh_bnds_info)->elems[--(trsh_bnds_info)->num_elems]; \
  else \
  { \
   (bnd_info) = (struct EMSsortbnd_info *) om$malloc (size = \
                             sizeof(struct EMSsortbnd_info)); \
   EMerr_hndlr (!bnd_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup); \
  } \
  (bnd_info)->bnd_type = EMSno_bnd; \
  (bnd_info)->next = NULL; \
}

#define EFget_sortlp(trsh_lps_info, lp_info) \
{ \
  if ((trsh_lps_info)->num_elems) \
    (lp_info) = (struct EMSsortlp_info *)(trsh_lps_info)->elems[--(trsh_lps_info)->num_elems]; \
  else \
  { \
   (lp_info) = (struct EMSsortlp_info *) om$malloc (size = \
                             sizeof(struct EMSsortlp_info)); \
   EMerr_hndlr (!lp_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup); \
  } \
  (lp_info)->lp_id = NULL_OBJID; \
  (lp_info)->bnd_info = NULL; \
}

#define EFget_sortface(trsh_faces_info, face_info) \
{ \
  if ((trsh_faces_info)->num_elems) \
    (face_info) = (struct EMSsortfc_info *)(trsh_faces_info)->elems[--(trsh_faces_info)->num_elems]; \
  else \
  { \
   (face_info) = (struct EMSsortfc_info *) om$malloc (size = \
                             sizeof(struct EMSsortfc_info)); \
   EMerr_hndlr (!face_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup); \
  } \
 (face_info)->p_lp = NULL; \
 (face_info)->c_lps = NULL; \
 (face_info)->num_c_lps = 0; \
 (face_info)->c_lps_arrsz = 0; \
}

#define EFappend_gen_info(gen_info, elem) \
{ \
   if (((gen_info)->num_elems + 1) > (gen_info)->arrsz) \
   { \
     EFmemory_allocation (&rc, (IGRchar ***) &(gen_info)->elems, \
       (gen_info)->num_elems+1, &(gen_info)->arrsz, \
       sizeof(IGRchar *), 10, 5); \
     EMerr_hndlr(!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup); \
   } \
   (gen_info)->elems[(gen_info)->num_elems++] = (IGRchar *) elem; \
}


#endif
