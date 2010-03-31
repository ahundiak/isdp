/*
  ABSTRACT

  This class represents the natural edges of a surface.


  HISTORY

  SM      14-Oct-87       1.1 Genesis
  RC      10-Nov-87       Changed arguments to EMmake_natural_edge.
  DLB     07/10/91    Disable tagging.
*/

class specification EMSnatedge (1:1) of EMSedge;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSnatedge
{
  IGRuchar      location;       
};

not_taggable;

override
  GRgraphics;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetedgedef, 
  EMgeomattr,
  EMget_location,
  EMgetrange,
  EMptatpr,
  EMpratpt,
  EMptproject,
  EMendpts,
  EMgetgeom,
  EMget_bcxyz_geom,
  EMgetpygeom,
  EMgetbcgeom,
  EMisdegentol,
  EMpostgeom;

#ifndef BASE_EMS

message EMmake_natural_edge
(
  IGRlong *EMmsg;
  IGRuchar location;
  IGRuchar *curve_type;
  IGRushort *edge_props;
);

override
  EMdisplay,
  EMget_natural_edges,
  EMuv_transform,
  EMconnect_to_ne,
  debug,
  EMextractyourself,
  EMpt_location,
  EMgetbounds,
  EMedpytrimint,
  EMedbstrimint,
  EMgettopedge,
  EMbndtobs,
  EMpyxyz_geometry, 
  EMbstobnd;

#endif

end specification EMSnatedge;
