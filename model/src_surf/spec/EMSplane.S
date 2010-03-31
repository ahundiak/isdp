/*
  ABSTRACT

  This class represents regular planes.


  HISTORY

  05-June-91 Jack Added override for EMinit_display.  2.0.1 Horizon Loops.
  31 May 1991 msm Override GRreport, GRreport_defaults, GRupdate_gadgets.
                  Removed override GRloadform and GRgetsfsize.
  19 Nov 1989 SM	Added EMplaneDef message.
  23 Feb 1989 RC  Modified arguments to EMcross_hatch to accomodate
                  material patterns.
  17 Jan 1989 RC  Added override EMintcopy.
  14 Oct 1988 rlw Added override GRxform
  22 Aug 1988 SM  Added override GRformatele.
  24 May 1988 jBk Added EMplaneContainingTwoClosedCurves message.
  16 May 1988 dhm Overrode GRloadform and GRgetsfsize.
  23 Mar 1988 rlw Removed EMtantosf() and EMplane_tan_to_curve()
                  methods.
                  Added EMplane_normal_and_tangent_to() method
                  which is a superset.
                  Also removed EMbounded_lsq_fit_plane() method.
  10 Mar 1988 aic Support surface of projection format.
  26 Jan 1988 pp  Modified arguments to EMplane_of_curve in wake of
                  support for composite curves
  04 Dec 1987 rc  Modified arguments to EMcross_hatch.
  13 Oct 1987 aic Conversion to EMS 1.1
  09 Sep 1987 rc  Added EMcross_hatch message and override
                  EMmake_frt and EMdelete_boundary.
  21 Sep 1986 rlw The beginning
*/

class specification EMSplane (2:0) of EMSproject;

# include "EMSchatch.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMis_rect_plane
(
  IGRlong *msg;
  IGRboolean *is_rect_plane;
);

#ifndef BASE_EMS

message EMplane
(
  IGRint *rc;
  struct GRvg_construct *arglist;
  IGRpoint points[];
  IGRint type;
);

message EMplane_of_curve
(
  IGRlong *EMmsg;
  struct GRvg_construct *arglist;
  struct GRlc_info *curve_lcinfo;
  struct IGRbsp_curve *incurve;
  IGRuchar *curve_type;
  IGRboolean test_degeneracy;
  IGRboolean construct_loopset;
  IGRpoint orientation_point;
  GRobjid *edgeids;
);

message EMcross_hatch
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
  struct EMSxh_info *xh_info;
  IGRdouble vw_mat[4][4];
);
              
message EMplane_normal_and_tangent_to
(
  IGRboolean want_tangent_plane;
  IGRboolean have_curve;
  IGRboolean u_partial;
  struct GRlc_info *the_object;
  struct GRparms *proj_parms;
  IGRdouble length;
  IGRdouble width;
  struct GRvg_construct *construct_list;
);

message EMplaneContainingTwoClosedCurves
(
  IGRlong rc[1];
  struct GRvg_construct list[1];
  struct IGRbsp_curve *cv[2];
);

message EMplaneDef
(
  IGRlong *EMmsg;
  IGRshort *mattyp;
  IGRmatrix mat;
  struct IGRplane *def;
);

message EMmap_edges_on_plane
(
  IGRlong *msg;
  struct GRvg_construct list;
  struct EMSpartolbasis *partolbasis;
  IGRint num_surfs;
  GRobjid *surfs;
  IGRint *num_edinfo;
  struct EMmerge_info **edinfo;
);

message EMreplace_with_new_plane
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  struct EMSpartolbasis *EMSpartolbasis;
  IGRint num_surfs;
  GRobjid *surfs;
  IGRint num_edinfo;
  struct EMmerge_info *edinfo;
  IGRint *numowners;
  struct EMSownercomp **ownercomps;
);

override
  EMinit_display,
  EMintcopy,
  GRxform,
  EMvalidateClass,
  EMget_natedge_info,
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets, 
  GRformatele;

#endif

end specification EMSplane;
