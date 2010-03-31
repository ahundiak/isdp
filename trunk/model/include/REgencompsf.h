#ifndef REgencompsf_h
#define REgencompsf_h 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSgencompsf. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

  EMS_ASblend_curve_surface               9 
  EMS_ASfillet_by_surfaces_and_radii      19
  EMS_ASfillet_by_surfaces_and_radii_w_track_pt 20
  EMS_ASsurface_by_offsetting_surface     28
  EMS_ASdrafted_surface                   29
  EMS_ASextracted_partial_surface         30

  EMS_ASsurface_by_offsetting_surface1    31
  EMS_ASdrafted_surface1                  32
  EMS_ASextracted_partial_surface1        33

  EMS_ASfillet_by_edge_radius                       40
  EMS_ASfillet_by_edge_radius_w_track_pt            41
  EMS_ASfillet_by_edge_radii                        42
  EMS_ASfillet_by_edge_radii_w_track_pt             43
  EMS_ASfillet_by_surface_surface_radius            44
  EMS_ASfillet_by_surface_surface_radius_w_track_pt 45
  EMS_ASfillet_by_surface_surface_radii             46
  EMS_ASfillet_by_surface_surface_radii_w_track_pt  47
  EMS_ASfillet_by_curve_surface_surface             48
  EMS_ASfillet_by_curve_surface_surface_w_track_pt  49
  EMS_ASfillet_by_curve_surface_radius              50
  EMS_ASfillet_by_curve_surface_radius_w_track_pt   51
  EMS_ASfillet_by_triple_surfaces                   52
  EMS_ASfillet_by_triple_surfaces_w_track_pt        53

History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
 SY: 03/23/93: Add new fillet surface types and the structure.
*/

/* Recompute info for type fillet surface. */

#define EMS_ASfillet_by_surfaces_and_radii   19
#define EMS_ASfillet_by_surfaces_and_radii_w_track_pt 20

#define EMS_NATURAL_NORMAL1 1
#define EMS_NATURAL_NORMAL2 2
#define EMS_CHAMFER_FILLET  4
#define EMS_VARIABLE_FILLET 8
#define EMS_LAW_CURVE       16
#define EMS_NO_EXT_FILLET   32
#define EMS_EXT_EXD_FILLET  64
#define EMS_EXT_ROLL_BALL_FILLET 128
#define EMS_INT_EXD_FILLET       256
#define EMS_INT_ROLL_BALL_FILLET 512

struct EMSfillet_surface
{
 unsigned  short props;
 IGRdouble rho_value ;
 OMuword   view_index;
};

/* Recompute info for new fillet surface types.  03/23/93 : JSY */

#define EMS_ASfillet_by_edge_radius                       40
#define EMS_ASfillet_by_edge_radius_w_track_pt            41
#define EMS_ASfillet_by_edge_radii                        42
#define EMS_ASfillet_by_edge_radii_w_track_pt             43
#define EMS_ASfillet_by_surface_surface_radius            44
#define EMS_ASfillet_by_surface_surface_radius_w_track_pt 45
#define EMS_ASfillet_by_surface_surface_radii             46
#define EMS_ASfillet_by_surface_surface_radii_w_track_pt  47
#define EMS_ASfillet_by_curve_surface_surface             48
#define EMS_ASfillet_by_curve_surface_surface_w_track_pt  49
#define EMS_ASfillet_by_curve_surface_radius              50
#define EMS_ASfillet_by_curve_surface_radius_w_track_pt   51
#define EMS_ASfillet_by_triple_surfaces                   52
#define EMS_ASfillet_by_triple_surfaces_w_track_pt        53

#define EMS_FIL_NATURAL_NORMAL1  0x1
#define EMS_FIL_NATURAL_NORMAL2  0x2
#define EMS_FIL_NATURAL_NORMAL3  0x4
#define EMS_FIL_EQUAL_END_RADII  0x8
#define EMS_FIL_DEFAULT_RHO      0x10
#define EMS_FIL_SURF_ORIENTED    0x20
#define EMS_FIL_BOUND_SURF       0x40
#define EMS_FIL_FLIP_EDGE_ENDS   0x80
#define EMS_FIL_INT_ROLLING_BALL 0x100
#define EMS_FIL_CHECK_CURV_PROB  0x200
#define EMS_FIL_SINGLE_FILLET    0x400

struct EMSfillet_surface_new
{
  IGRushort props;              /* properties                      */
  OMuword   view_index;
  IGRdouble cht_tol;            /* chord height tolerance used     */
  IGRboolean reverse;           /* TRUE if reverse the center line */
};                              /* curve, FALSE otherwise          */

#define EMS_ASblend_curve_surface               9 

struct EMSblend_curve_surface
{
 IGRpoint center_point;
 IGRvector normal_vector;
};

/*
 * This structure is used by EMconstruc_associative to communicate
 * with the command object. 
 */
struct EMSblend_curve_surface_ret_info
{
 IGRpoint center_point;
 IGRvector normal_vector;
};

#define EMS_ASsurface_by_offsetting_surface     28
#define EMS_ASsurface_by_offsetting_surface1    31

/* Recompute info for simple/composite offset surface. */
#define EMS_NATURAL_NORMAL  1
#define EMS_TRIMMING        2
#define EMS_SYMMETRIC_OFFSET 4

struct EMSoffset_simple_surface
{
    unsigned  long   props;
};

/* Recompute info for composite offset surface */

struct surfs_per_thickness
{
    IGRint      num_sfs_per_tks;
    OMuword     best_view_index;
    IGRdouble   uv_point[2];
};
struct EMSoffset_surface
{
    unsigned long   props;
    IGRint          num_spec_tks;
    struct surfs_per_thickness off_surf_views[1];
};

/* Recompute info for drafted surfaces and solids. */

#define EMS_ASdrafted_surface                   29
#define EMS_ASdrafted_surface1                  32

#define EMS_IS_UNIFORM      1
#define EMS_IS_FILLETED     2
#define EMS_IS_RIGHT_SIDE   4

struct d_s_codes_views
{
  IGRint  as_code;
  OMuword view_index;
};

#ifndef __DDP__
struct EMSdrafted_surface
{
  unsigned short props;
  unsigned short num_sides;
  struct d_s_codes_views codes_views[1];
};
#endif

#define EMS_ASextracted_partial_surface         30
#define EMS_ASextracted_partial_surface1        33

#endif
