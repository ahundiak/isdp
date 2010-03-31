/*
  ABSTRACT

  This class represents a geometric solid.


  HISTORY

  msm 06/04/91        Override GRreport, GRreport_defaults, GRupdate_gadgets.
                      Removed override GRloadform and GRgetsfsize.
  dhm 05/16/88        Overrode GRgetsfsize and GRloadform.
  SM	25-Mar-88       Moved EMcross_section to EMSsurface.
  AIC 15 January 88   Added override for GRlocate_owner.
  AIC/DLB 10/15/87    Conversion to 1.1.0
  NG  06-May-1987     Remove EMlmmove and EMlmsplit overrides.
  AIC     03/09/87    Creation Date
*/

class specification EMSsolid (2:0) of EMScompsurf;

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  GRgeomprops;

#ifndef BASE_EMS

message EMorient_yourself
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmd_env *env;
);

message EMesttplgy
(
  IGRlong *EMmsg;
  IGRshort no_of_edges;
  IGRshort no_of_faces;
  IGRushort natural_edprops[][4];
  IGRuchar natural_curve_type[][4];
  IGRushort connectivity[][5];
  struct GRid *surf_GRids;
  struct GRvg_construct *construct_list;
);

message EMproj_4_bnd_on_plane
(
  IGRlong *EMmsg;
  struct IGRbsp_surface *surf;
  struct GRlc_info *located_surf;
  IGRpoint point_on_plane;
  IGRvector plane_normal;
  IGRvector projection_vector;
  struct GRvg_construct *construct_list;
);

message EMcount_vertices
(
  IGRlong *EMmsg;
  IGRint *no_of_vertices;
);

message EMpoint_locate
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRushort options;
  IGRpoint inpoint;
  IGRpoint range[2];
  IGRulong *location;
);

override
  GRlocate,
  GRreport,
  GRreport_defaults,
  GRupdate_gadgets,
  GRlocate_owner,
  GRgetobjinfo;

#endif

end specification EMSsolid;
