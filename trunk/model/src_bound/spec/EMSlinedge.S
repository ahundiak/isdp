/*
  ABSTRACT

  This class represents edges as linestrings in parametric space.


  HISTORY

  DLB     07/10/91    Disable tagging.
  SM	14-Sep-1989	Added sfid argument to leinit. if not
			NULL_OBJID, it will be used for setting
			meaningful curve types for linear edges that
			get converted to iso edges.
			Also added the message EMsetIsoType.
  AIC     25 Jan 1989     Promoted EMstroke_iso_edge
                        message to EMSedge.
  SM      14-Oct-87       1.1 Genesis
*/

class specification EMSlinedge (1:1) of EMSedge;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSlinedge
{
  IGRushort     num_points;     
  variable IGRdouble    points[];       
};

override   
  GRgraphics;

not_taggable;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMget_iso_geom
(
  IGRlong *EMmsg;
  struct GRmdenv_info *mdenv;
  struct GRid *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRboolean reverse;
  struct EMSpartedinfo *partinfo;
  struct IGRbsp_curve *curve;
);

override
  EMgetedgedef, 
  EMgeomattr,
  EMgetpygeom,
  EMgetgeom,
  EMgetbcgeom,
  EMget_bcxyz_geom,
  EMgetrange,
  EMptatpr,
  EMpratpt,
  EMptproject,
  EMendpts,
  EMisdegentol,
  EMpostgeom;

#ifndef BASE_EMS

message EMleinit
(
  IGRlong *msg;
  IGRushort ed_props;
  IGRuchar curve_type;
  struct IGRpolyline *inpoly;
  struct EMSpartolbasis *partolbasis;
  IGRushort option;
  GRobjid sfid;
);

message EMsetIsoType
(
  IGRlong *EMmsg;
  GRobjid sfid;
  IGRuchar *outtype;
  IGRuchar *intype_u;
  IGRuchar *intype_v;
  IGRboolean update;
);

override
  EMstroke_iso_edge,
  EMdisplay,
  EMconstruct_seg,
  EMuv_transform,
  EMpt_location,
  EMgetbounds,
  EMputpygeom,
  EMputbcgeom,
  EMedpytrimint,
  EMgettopedge,
  EMbstobnd,
  EMbndtobs,
  EMextractyourself,
  EMrefine_points, 
  EMextend_geom,
  EMalter_geometry,
  EMpyxyz_geometry, 
  debug,
  GRprint,
  GRread;

#endif

end specification EMSlinedge;
