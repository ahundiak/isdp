/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpb;

#include "EMS.h"      /* For shared libraries */
#include "lcmacros.h" /* For lc$add_class macro */

extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_GRsubbc_class_id;

#ifndef IDRAW
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSelpsoid_class_id;
extern OMuword OPP_EMSelpcone_class_id;
extern OMuword OPP_EMSelpcyl_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMSproject_class_id;
extern OMuword OPP_EMSrevol_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMStorus_class_id;

extern OMuword OPP_EMScompsurf_class_id;
extern OMuword OPP_EMSgencompsf_class_id;
extern OMuword OPP_EMSprjcompsf_class_id;
extern OMuword OPP_EMSrevcompsf_class_id;

extern OMuword OPP_EMSsfsplit_class_id;
extern OMuword OPP_EMSsfmove_class_id;
extern OMuword OPP_EMSsf_lift_class_id;
extern OMuword OPP_EMSsfdlift_class_id;
extern OMuword OPP_EMSsfimpbnd_class_id;
extern OMuword OPP_EMSsfmkface_class_id;
extern OMuword OPP_EMSsfboolean_class_id;
extern OMuword OPP_EMSsfround_class_id;
extern OMuword OPP_EMSsfhist_class_id;
extern OMuword OPP_EMSsfstitch_class_id;
extern OMuword OPP_EMSsfspltwsf_class_id;

extern OMuword OPP_EMSsolid_class_id;
extern OMuword OPP_EMSblock_class_id;
extern OMuword OPP_EMSgensolid_class_id;
extern OMuword OPP_EMSpolyhdrn_class_id;
extern OMuword OPP_EMSwedge_class_id;
extern OMuword OPP_EMSsfsolid_class_id;
extern OMuword OPP_EMSsldpr_class_id;

extern OMuword OPP_EMSloop_class_id;
extern OMuword OPP_EMSedge_class_id;
#endif
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_EMSimpcnstr_class_id;
extern OMuword OPP_EMSexpcnstr_class_id;
extern OMuword OPP_SKexplicit_class_id;
extern OMuword OPP_SKimplicit_class_id;
extern OMuword OPP_SKmgr_class_id;
extern OMuword OPP_SKgeometry_class_id;
extern OMuword OPP_SKvariable_class_id;
extern OMuword OPP_SKconstraint_class_id;
extern OMuword OPP_SKdumpt_class_id;
extern OMuword OPP_DMdim_class_id;
extern OMuword OPP_DMannot_class_id;

EFinit_locate_control(EMmsg)
IGRlong *EMmsg;
/* ************************************************************************
Description
 This function initialises the locate control lists.  

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.

Assumptions
 The owner name curve is assumed to be added by the loading of
 super_grdpb.

History
 Creation : PP : 02/08/89
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 05/06/91   mrm     Changed to use message keys (see emsclasses.mb)
   ************************************************************************ */
{
 OMuword classids[30];
 OM_S_CLASSLIST class_list;

 *EMmsg = EMS_S_Success;

/*
 * The owner name needs to be added first before the component logical
 * names are added. At the time of writing of this function the maximum
 * length of a logical name or an owner name is sixteen characters.
 */

 class_list.p_classes = classids;
 class_list.w_count = 0;
 class_list.w_flags = 0;

/*
 * curve This name is assumed to be added by DRAFT.
 *  general
 *  surface edges
 */

 classids[0] = OPP_GRsubbc_class_id;
 class_list.w_flags = OM_CLST_subclass;
 class_list.w_count = 1;
 lc$add_class(owner = "GRcurve", 
              name = "GRsubbc",
              classes = class_list);
#ifndef IDRAW
 classids[0] = OPP_EMSedge_class_id;
 lc$add_class(owner = "GRcurve",
              name = "EMSedge",
              classes = class_list,
              properties = 0);
#endif

/*
 * composite curve
 *  general
 *  surface edges
 */

 class_list.w_count = 0;
 class_list.w_flags = 0;
 lc$add_class(name = "compcurve", classes = class_list);
 
 class_list.w_count = 1;
 classids[0] = OPP_GRcompcurve_class_id;
 lc$add_class(owner = "compcurve", 
              name = "GRcompcurve",
              classes = class_list);
/*
 * By default surface edges are non-locatable.
 */
#ifndef IDRAW
 classids[0] = OPP_EMSloop_class_id;
 lc$add_class(owner = "compcurve", 
              properties = 0,
              name = "EMSloop",
              classes = class_list);
#endif

/*
 * Single surface classes.
 * Surface
 *  cone
 *  cylinder
 *  ellipsoid
 *  elliptical cone
 *  elliptical cylinder
 *  general
 *  partial cone
 *  partial cylinder
 *  plane
 *  projection
 *  revolution
 *  sphere
 *  torus
 */

/*
 * We declare all subclasses of EMSsubbs to be of type surface. So in the
 * future if anybody adds a class and does not give the same a logical
 * name it would be locatable if surfaces are locatable.
 */
#ifndef IDRAW
 class_list.w_count = 0;
 class_list.w_flags = 0;
 lc$add_class(name = "surface", classes = class_list);

/* Cone */

 class_list.w_flags = 0;
 class_list.w_count = 1;
 classids[0] = OPP_EMScone_class_id;
 lc$add_class (owner = "surface",
               name = "EMScone",
               classes = class_list);

/* Cylinder */

 classids[0] = OPP_EMScylindr_class_id;
 lc$add_class (owner = "surface",
               name = "EMScylindr",
               classes = class_list);
 
/* Ellipsoid */

 classids[0] = OPP_EMSelpsoid_class_id;
 lc$add_class (owner = "surface",
               name = "EMSelpsoid",
               classes = class_list);

/* Elliptical cone */

 classids[0] = OPP_EMSelpcone_class_id;
 lc$add_class (owner = "surface",
               name = "EMSelpcone",
               classes = class_list);

/* Elliptical cylinder */

 classids[0] = OPP_EMSelpcyl_class_id;
 lc$add_class (owner = "surface",
               name = "EMSelpcyl",
               classes = class_list);

/* General surface */

 classids[0] = OPP_EMSgenbs_class_id;
 lc$add_class (owner = "surface",
               name = "EMSgenbs",
               classes = class_list);

/* Partial cone */

 classids[0] = OPP_EMSpcone_class_id;
 lc$add_class (owner = "surface",
               name = "EMSpcone",
               classes = class_list);

/* Partial cylinder */

 classids[0] = OPP_EMSpcylindr_class_id;
 lc$add_class (owner = "surface",
               name = "EMSpcylindr",
               classes = class_list);

/* Plane */

 classids[0] = OPP_EMSplane_class_id;
 lc$add_class (owner = "surface",
               name = "EMSplane",
               classes = class_list);

/* Surface of projection */

 classids[0] = OPP_EMSproject_class_id;
 lc$add_class (owner = "surface",
               name = "EMSproject",
               classes = class_list);

/* Surface of revolution */

 classids[0] = OPP_EMSrevol_class_id;
 lc$add_class (owner = "surface",
               name = "EMSrevol",
               classes = class_list);

/* Sphere */

 classids[0] = OPP_EMSsphere_class_id;
 lc$add_class (owner = "surface",
               name = "EMSsphere",
               classes = class_list);
/* Torus */

 classids[0] = OPP_EMStorus_class_id;
 lc$add_class (owner = "surface",
               name = "EMStorus",
               classes = class_list);

/*
 * Composite surface
 *   general
 *   projected
 *   surf DPR 
 *   revolved
 */

/*
 * We have to list all these classes individually as lc$add_class does
 * not support combination of lists. Otherwise we could have said that a 
 * composite surface is an object which is a subclass of EMScompsurf and
 * not a subclass of EMSsolid etc. Hence the apparent tardiness.
 */


 class_list.w_flags = 0;
 class_list.w_count = 0;
 lc$add_class(name = "EMScompsurf", classes = class_list);
 
 class_list.w_flags = 0;
 class_list.w_count = 1;
 classids[0] = OPP_EMSgencompsf_class_id;
 lc$add_class (owner = "EMScompsurf",
               name = "EMSgencompsf",
               classes = class_list);

 classids[0] = OPP_EMSprjcompsf_class_id;
 lc$add_class (owner = "EMScompsurf",
               name = "EMSprjcompsf",
               classes = class_list);

 classids[0] = OPP_EMSrevcompsf_class_id;
 lc$add_class (owner = "EMScompsurf",
               name = "EMSrevcompsf",
               classes = class_list);

 classids[0] = OPP_EMSsfsplit_class_id;
 classids[1] = OPP_EMSsfmove_class_id;
 classids[2] = OPP_EMSsfboolean_class_id;
 classids[3] = OPP_EMSsfdlift_class_id;
 classids[4] = OPP_EMSsfimpbnd_class_id;
 classids[5] = OPP_EMSsfmkface_class_id;
 classids[6] = OPP_EMSsf_lift_class_id;
 classids[7] = OPP_EMSsfround_class_id;
 classids[8] = OPP_EMSsfhist_class_id;
 classids[9] = OPP_EMSsfstitch_class_id;
 classids[10] = OPP_EMSsfspltwsf_class_id;

 class_list.w_count = 11;
 lc$add_class (owner = "EMScompsurf",
               name = "EMSsurfDPR",
               classes = class_list);
/*
 * Solid
 *  block
 *  solid DPR
 *  general
 *  polyhedron
 *  surface
 *  wedge
 */ 

/*
 * All subclasses of EMSsolid will be solids.
 */

 class_list.w_flags = 0;
 class_list.w_count = 0;
 lc$add_class(name = "solid", classes = class_list);

 class_list.w_flags = 0;
 class_list.w_count = 1;
 classids[0] = OPP_EMSblock_class_id;
 lc$add_class (owner = "solid",
               name = "EMSblock",
               classes = class_list);

 class_list.w_flags = OM_CLST_subclass;
 classids[0] = OPP_EMSsldpr_class_id;
 lc$add_class (owner = "solid",
               name = "EMSsldpr",
               classes = class_list);

 class_list.w_flags = 0;
 classids[0] = OPP_EMSgensolid_class_id;
 lc$add_class (owner = "solid",
               name = "EMSgensolid",
               classes = class_list);

 classids[0] = OPP_EMSpolyhdrn_class_id;
 lc$add_class (owner = "solid",
               name = "EMSpolyhdrn",
               classes = class_list);

 classids[0] = OPP_EMSsfsolid_class_id;
 lc$add_class (owner = "solid",
               name = "EMSsfsolid",
               classes = class_list);

 classids[0] = OPP_EMSwedge_class_id;
 lc$add_class (owner = "solid",
               name = "EMSwedge",
               classes = class_list);
#endif

 class_list.w_count = 1;
 classids[0] = OPP_EMSdatpln_class_id;
 lc$add_class(
              name = "Refplane",
              classes = class_list);

 class_list.w_count = 0;
 class_list.w_flags = 0;
 lc$add_class(name = "constraints", classes = class_list);

 class_list.w_flags = OM_CLST_subclass;
 class_list.w_count = 2;
 classids[0] = OPP_SKimplicit_class_id;
 classids[1] = OPP_EMSimpcnstr_class_id;
 lc$add_class(owner = "constraints",
              name = "Geomcons",
              classes = class_list);

 class_list.w_count = 4;
 classids[0] = OPP_SKexplicit_class_id;
 classids[1] = OPP_EMSexpcnstr_class_id;
/* DMdim and DMannot are added for CR# 11900821 (20/11/97)-Ashok*/
 classids[2] = OPP_DMdim_class_id;
 classids[3] = OPP_DMannot_class_id;
 lc$add_class(owner = "constraints",
              name = "Dimcons",
              classes = class_list);

 class_list.w_count = 5;
 classids[0] = OPP_SKmgr_class_id;
 classids[1] = OPP_SKgeometry_class_id;
 classids[2] = OPP_SKvariable_class_id;
 classids[3] = OPP_SKconstraint_class_id;
 classids[4] = OPP_SKdumpt_class_id;
 lc$add_class(
              name = "Profiles",
              classes = class_list);

 return(TRUE);
}
end implementation EMSdpb;

