/*
 * Description
 *
 *  This file contains the definitions needed in translating a 
 *  a surface from EMS to IGDS and from EMS to ENVELOPE format.
 *
 * History
 * 
 *    RC  05/18/89    Creation Date

 */

#ifndef EMSfmtsf_include
#define EMSfmtsf_include 1

/*
 * The following defintions are used in translating an object from
 * EMS to ENVELOPE format
 */

#define ENGLISH               0
#define METRIC                1

#define MODEL_ITEM            200
#define ENTITY                200

/*
 * The following defintions are used in breaking a surface before
 * converting it to IGDS/ENVELOPE format
 */

#define BND_ELEMS_OVERFLOW    0x1
#define BND_PTS_OVERFLOW      0x2

# define OVERLAP_ZONE         .10
# define CUT_ALONG_U          0
# define CUT_ALONG_V          1

# define MERGE_INFO_BUF_SIZE    50

/*
 * Define IGDS constants.  Note that the number 150 should
 * actually be 151.  I have defined this way because the GUotype24 
 * routine uses 150.
 */

#define PRODUCTION      1

#if PRODUCTION
#define MAX_POLES 101
#define MAX_PNTS_PER_TYPE_25 150
#define MAX_TYPE_25_ELEMENTS 16
#define MAX_POINTS_PER_BOUNDARY 600
#else
#define MAX_POLES 4
#define MAX_PNTS_PER_TYPE_25 20
#define MAX_TYPE_25_ELEMENTS 8
#define MAX_POINTS_PER_BOUNDARY 60
#endif

/*
 * Structure defintions used in conversion
 */

struct EMSbint_info
{
  IGRdouble       *int_pts;
  IGRint          *ptinx;
  IGRint          num_ints;
  IGRint          int_arrsz;
};


struct EMSbnd_info
{
  IGRdouble                  range[4];
  struct   IGRbsp_bdry_pts   *bdry;
  struct   EMSbint_info      int_info;
};

struct EMSsbnd_info
{
  struct EMSbnd_info    *bnd_info;
  IGRdouble             range[4];
  IGRdouble             beg_pt[2], end_pt[2];
  IGRint                beg_inx, end_inx, num_pts;
  struct  EMSsbnd_info  *next;
};

struct EMSgrbnd_info
{
  IGRdouble             range[4];
  IGRint                num_pts;
  IGRboolean            whole_bnd;
  struct EMSsbnd_info   *sbnd_info;
};

struct EMSgr_info
{
  IGRdouble              range[4];
  IGRint                 num_bnds;
  IGRint                 grbnd_arrsz;
  IGRint                 overflow;
  IGRint                 num_type_25_needed;
  struct EMSgrbnd_info   **grbnd_info;  
};

/*
 * Structure used in adding information linkage to igds element
 */

  struct  EMSinfo_linkage
  {
   IGRuchar type;
   IGRuchar props;
   IGRshort         entity;
   IGRlong          occurrence;
  };

/*
 * Macros used in conversion
 */


#define  EFpt_lie_on_range_box_save(pt, box) \
(( (((pt)[0] == (box)[0]) && ((pt)[1] >= (box)[1]) &&  \
    ((pt)[1] <= (box)[3])) || \
   (((pt)[0] == (box)[2]) && ((pt)[1] >= (box)[1]) &&  \
    ((pt)[1] <= (box)[3])) || \
   (((pt)[1] == (box)[1]) && ((pt)[0] >= (box)[0]) && \
    ((pt)[0] <= (box)[2])) || \
   (((pt)[1] == (box)[3]) && ((pt)[0] >= (box)[0]) &&  \
    ((pt)[0] <= (box)[2])) ) \
    ? TRUE : FALSE )

#define EFget_sbnd(trsh_sbnds, num_trsh_sbnds, sbnd_info) \
{ \
  if (*num_trsh_sbnds) \
    sbnd_info = (trsh_sbnds)[--(*num_trsh_sbnds)]; \
  else \
  { \
   sbnd_info = (struct EMSsbnd_info *) om$malloc (size = \
                                       sizeof(struct EMSsbnd_info)); \
   EMerr_hndlr (!sbnd_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup); \
  } \
  sbnd_info->bnd_info = NULL; \
  sbnd_info->next = NULL; \
}

#define EFtrash_sbnd(trsh_sbnds,num_trsh_sbnds,trsh_sbnds_arrsz,in_sbnd) \
{ \
   if ((*num_trsh_sbnds + 1) > *trsh_sbnds_arrsz) \
   { \
     EFmemory_allocation (&rc, (IGRchar ***) trsh_sbnds, \
       *num_trsh_sbnds+1, trsh_sbnds_arrsz, \
       sizeof(struct EMSsbnd_info *), 10, 5); \
     EMerr_hndlr(!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup); \
   } \
   (*trsh_sbnds)[(*num_trsh_sbnds)++] = in_sbnd; \
}

#define EFget_grbnd(trsh_grbnds, num_trsh_grbnds, grbnd_info) \
{ \
  if (*num_trsh_grbnds) \
    grbnd_info = (trsh_grbnds)[--(*num_trsh_grbnds)]; \
  else \
  { \
   grbnd_info = (struct EMSgrbnd_info *) om$malloc (size = \
                                       sizeof(struct EMSgrbnd_info)); \
   EMerr_hndlr (!grbnd_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup); \
  } \
  grbnd_info->whole_bnd = FALSE; \
  grbnd_info->sbnd_info = NULL; \
}

#define EFtrash_grbnd(trsh_grbnds,num_trsh_grbnds,trsh_grbnds_arrsz,in_grbnd) \
{ \
   if ((*num_trsh_grbnds + 1) > *trsh_grbnds_arrsz) \
   { \
     EFmemory_allocation (&rc, (IGRchar ***) trsh_grbnds, \
       *num_trsh_grbnds+1, trsh_grbnds_arrsz, \
       sizeof(struct EMSgrbnd_info *), 10, 5); \
     EMerr_hndlr(!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup); \
   } \
   (*trsh_grbnds)[(*num_trsh_grbnds)++] = in_grbnd; \
}

#define EFget_gr_info(trsh_grs_info, num_trsh_grs_info, gr_info) \
{ \
 if (*num_trsh_grs_info) \
   gr_info = (trsh_grs_info)[--(*num_trsh_grs_info)]; \
 else \
 { \
  gr_info = (struct EMSgr_info *) om$malloc (size = \
                                      sizeof(struct EMSgr_info)); \
  EMerr_hndlr (!gr_info, *EFmsg, EMS_E_NoDynamicMemory, wrapup); \
  gr_info->grbnd_arrsz = 0; \
 } \
 if (!gr_info->grbnd_arrsz) \
 { \
  gr_info->grbnd_info = (struct EMSgrbnd_info **) om$malloc (size = \
               sizeof(struct EMSgrbnd_info *) * MAX_TYPE_25_ELEMENTS); \
  EMerr_hndlr(!gr_info->grbnd_info,*EFmsg,EMS_E_NoDynamicMemory,wrapup); \
  gr_info->grbnd_arrsz = MAX_TYPE_25_ELEMENTS; \
 } \
 gr_info->num_bnds = 0; \
 gr_info->overflow = FALSE; \
 gr_info->num_type_25_needed = 0; \
}

#define EFtrash_gr_info(trsh_grs_info, num_trsh_grs_info, trsh_grs_info_arrsz, in_gr_info) \
{ \
   if ((*num_trsh_grs_info + 1) > *trsh_grs_info_arrsz) \
   { \
     EFmemory_allocation (&rc, (IGRchar ***) trsh_grs_info, \
       *num_trsh_grs_info+1, trsh_grs_info_arrsz, \
       sizeof(struct EMSgr_info *), 10, 5); \
     EMerr_hndlr(!(1&rc),*EFmsg,EMS_E_NoDynamicMemory,wrapup); \
   } \
   (*trsh_grs_info)[(*num_trsh_grs_info)++] = in_gr_info; \
}


#define EFnum_type_25_needed(num_pts, num_type_25_needed) \
{ \
  num_type_25_needed = (num_pts) / MAX_PNTS_PER_TYPE_25; \
  if ( (num_type_25_needed * MAX_PNTS_PER_TYPE_25) != (num_pts)) \
    num_type_25_needed++; \
}
  
#define EFmrg_possible(num_pts, num_pts_inc, num_type_25_needed,count,mrg_possible) \
{ \
 if ( (num_pts + num_pts_inc) > MAX_POINTS_PER_BOUNDARY) \
   mrg_possible = FALSE; \
 else \
 { \
  EFnum_type_25_needed((num_pts), count); \
  num_type_25_needed -= count; \
  EFnum_type_25_needed((num_pts+num_pts_inc), count); \
  num_type_25_needed += count; \
  mrg_possible = num_type_25_needed > MAX_TYPE_25_ELEMENTS ? \
                   FALSE : TRUE; \
 } \
}

#define EFis_end_pt_greater_than_beg_pt(beg_inx, end_inx, beg_pt, end_pt,bdry, end_pt_greater_than_beg_pt) \
{ \
 if ((end_inx) > (beg_inx))  (end_pt_greater_than_beg_pt) = TRUE; \
 else \
 { \
   if ((end_inx) < (beg_inx)) (end_pt_greater_than_beg_pt) = FALSE; \
   else \
   { \
    if (EM2ddistptpt(&((bdry)->points[2*(end_inx)]), (end_pt)) >=  \
        EM2ddistptpt(&((bdry)->points[2*(beg_inx)]), (beg_pt))) \
      (end_pt_greater_than_beg_pt) = TRUE; \
    else \
     (end_pt_greater_than_beg_pt) = FALSE; \
   } \
 } \
}

#define   EFget_sbnd_num_pts(beg_inx,end_inx, beg_pt, end_pt, bdry, end_pt_greater_than_beg_pt, num_pts) \
  { \
   EFis_end_pt_greater_than_beg_pt(beg_inx, end_inx, beg_pt, end_pt, \
                                   bdry, end_pt_greater_than_beg_pt); \
   if (end_pt_greater_than_beg_pt) \
    (num_pts) = (end_inx) - (beg_inx); \
   else \
    (num_pts) = (bdry->num_points) - (beg_inx) - 1 + (end_inx); \
   (num_pts) += 2; \
  }



#endif
