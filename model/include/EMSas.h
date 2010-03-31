#ifndef EMSas_h
#define EMSas_h 1

/*
 * Directory stuff and nucleus associativity
 */
#include "DIdef.h"
#include "DItypedef.h"
#include "parametric.h"
/*
 * Dimensioning types. Added for EMS 2.0
 */
#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimplan.h"
#include "diminfo.h"

/*
 * The following is the list of structures for all the associative surface/
 * solid objects in EMS. These structures are used in the EMSparams structure
 * below. Every EMSassoc object needs to make sure that it has a type
 * defined for itself in EMSasdef.h and a structure that contains all of
 * it's parameters.
 */

struct EMSassoc_cylinder
  {
  struct EMSpoint_info basept;
  struct EMSpoint_info heightpt;
  struct EMSvalue_info radius;
  };

/*
 * The following structure is used to represent all the parameters of a
 * given EMSassoc object. The type in this structure is defined in the
 * file EMSasdef.h
 */

struct EMSparams
  {
  IGRint type;
  union 
    {
    struct EMSassoc_cylinder cyl;
    } parms;
  };
/*
 * The class-specifici "moreinfo" structures being passed in for the overrides
 * of EMScnstr.EMinit method.
 */

struct EMSasptinfo
  {
  IGRint type;		/* The subtype of the data-point - griodef.h:
                           GRst_CENTER, GRst_INTER, GRst_KEYPOINT,
                           GRst_MIDPOINT */

  IGRpoint pts[5];      /* Point info to supplement the parent information:
                           For the above types currently supported, only
                           pt[0] is necessary (the current value of the
                           point) */

  struct GRid win_pln;  /* The id of the window or a DMplan object. This
                           is currently used only for GRst_INTER */
  };

struct EMSlndminfo
  {
  struct GRid dim;        /* The dimension object that defines this
                             constraint */

  struct diminfo diminfo; /* Structure containing information about the
                             dimension that defines this constraint */

  IGRchar *name;          /* This expression-constraints name. If NULL, then
                             a default name is generated */
  };

struct EMSanginfo
  {
  struct GRid dim;        /* The dimension object that defines this
                             constraint */

  struct diminfo diminfo; /* Structure containing information about the
                             dimension that defines this constraint */

  IGRchar *name;          /* This expression-constraints name. If NULL, then
                             a default name is generated */
  };

struct EMSnrminfo
  {
  struct GRid win_pln;    /* The window or plane with respect to which the
                             normal was observed. If a plane, then it must
                             be an ND object which returns a ref_type */
  };

#define NUM_VIEWS  3
#define TOP_VIEW   0
#define FRONT_VIEW 1
#define RIGHT_VIEW 2
#define NO_VIEW    0xffff

struct EMSview_info
{
  OMuword parent_index;
  OMuword view_index;
};

struct EMSdrafted_lift
{
  IGRdouble           cht;
  OMuword             num_views;
  struct EMSview_info *view_info;    
  struct EMSdlft_info *dlift_info;
};

#ifndef __DDP__
struct EMSround_chamfer
{
  IGRdouble           cht;
  OMuword             num_views;
  struct EMSview_info view_info[1];    
};
#endif

struct EMSassoc_lift
{
    IGRdouble   cht;
    IGRboolean  lift_with_pos_orient;
};


struct EMSplace_pocket
{
 IGRboolean is_planar_surface,is_rounded, is_drafted;
 IGRint part_type;

};

struct EMSadd_draft
{
 IGRdouble cht;
 OMuword             num_views;
 struct EMSview_info view_info[1];    
};

#endif
