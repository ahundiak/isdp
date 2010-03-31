/*
  ABSTRACT

  This class represents edges that are part of other edges.


  HISTORY

  DLB     07/10/91    Disable tagging.
  AIC     25 Jan 89       Override EMstroke_iso_edge
  SM      14-Oct-87       1.1 Genesis
*/

class specification EMSpartedge (1:1) of EMSbd_owner, EMSedge;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSpartedge
{
  struct EMSedgebound   boundary[2];    
};

not_taggable;

override        
  GRgraphics;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMpeinit
(
  IGRlong *EMmsg;
  IGRushort props;
  struct EMSedgebound *boundary;
  IGRuchar curve_type;
);

override
  EMgetedgedef, 
  EMgeomattr,
  EMget_bcxyz_geom,
  EMgetgeom,
  EMendpts,
  EMgetrange,
  EMget_location,
  EMptatpr,
  EMpratpt,
  EMptproject,
  EMgetpygeom,
  EMgetbcgeom,
  EMget_bottom_edge,
  EMisdegentol,
  EMpostgeom;

#ifndef BASE_EMS

message EMmake_end_compatible
(
  IGRlong *EMmsg;
  struct GRmd_env *my_env;
);

message EMputbounds
(
  IGRlong *msg;
  struct EMSedgebound *bounds;
);

message EMchange_bounds
(
  IGRlong *EMmsg;
  IGRint before_ptinx;
  struct IGRpolyline *insert_poly;
  struct IGRpolyline *remove_poly;
  struct IGRpolyline *new_geom;
  IGRuchar *new_curve_type;
  struct EMSedgebound *new_bdry;
  IGRushort *new_ed_props;
  IGRboolean update_partedges;
  IGRushort options;
  struct EMSpartolbasis *partolbasis;
);

message EMget_span_constraints
(
  IGRlong *EMmsg;
  IGRint span_inx;
  IGRint *num_constraints;
  struct EMSedgebound **params;
  GRobjid **partedids;
  IGRint *buf_size;
);

override
  EMmatch_topology,
  EMvalidate, 	
  EMstroke_iso_edge,
  EMreplace_edge, 
  EMptcoinc,
  EMdisplay,
  EMget_natural_edges,
  EMedbstrimint,
  EMconstruct_seg,
  EMuv_transform,
  EMmkface_collapse_copy,
  EMdrop,
  EMcompress_top,
  EMconnect_to_ne,
  EMget_location,
  delete,
  EMintcopy,
  EMpt_location,
  EMsplityourself,
  EMreverse,
  EMgetbounds,
  EMedpytrimint,
  EMgettopedge,
  EMbndtobs,
  EMbstobnd,
  EMtrimyourself,
  EMextractyourself,
  EMsend_dummy_edge, 
  EMinternalpt,
  EMrefine_points, 
  EMputpygeom, 
  EMpyxyz_geometry, 
  debug; 

#endif

end specification EMSpartedge;
