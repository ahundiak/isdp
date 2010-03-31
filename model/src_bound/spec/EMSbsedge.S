/*
  ABSTRACT

  This class represents the free form curves in parametric space.


  HISTORY

  DLB     07/10/91    Disable tagging.
  SM      14-Oct-87       Modified for version 1.1
  SM	  06-Jun-88	Override EMextend_geom to do polynomial
				extension upto the point.
*/

class specification EMSbsedge (1:1) of EMSedge;

/*------------------ INSTANCE DATA SECTION -------------------*/

not_taggable;

override        
  GRgraphics;

instance EMSbsedge                      
 {
   IGRuchar    order;           
   variable IGRdouble   packed_doubles[];  
   IGRushort   num_poles;       
   IGRuchar    bs_props;        
 };


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override
  EMgetedgedef, 
  EMgeomattr,
  EMget_bcxyz_geom,
  EMgetgeom,
  EMgetbcgeom,
  EMendpts,
  EMgetrange,
  EMptproject,
  EMpratpt,
  EMptatpr,
  EMgetpygeom,
  EMisdegentol, 
  EMpostgeom;

#ifndef BASE_EMS

message EMbsinit
(
  IGRlong *EMmsg;
  IGRushort ed_props;
  IGRuchar curve_type;
  struct IGRbsp_curve *curve;
  struct EMSpartolbasis *partolbasis;
);

override
  EMpt_location,
  EMuv_transform,
  EMconstruct_seg,
  EMedpytrimint,
  EMextractyourself,
  EMgettopedge,
  EMbstobnd,
  EMbndtobs,
  EMputbcgeom,
  EMalter_geometry,
  EMextend_geom, 
  debug,
  EMgetbounds,
  EMpyxyz_geometry;

#endif

end specification EMSbsedge;


