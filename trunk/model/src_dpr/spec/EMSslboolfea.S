/*
  ABSTRACT

  This is a class which represents solid boolean feature objects.


  HISTORY

  BL  06/21/90	Creation Date.
  BL  06/29/90	Added inherit GRloadform, GRgetsfsize.
  Tapadia 04/02/91 Override EMconstruct_associative
  Tapadia 04/22/91 Override EMgetInGeomIds
  msm 06/10/91    Removed GRloadfrom from inheritance list and insted added 
                  GRreport, GRreport_defaults, GRupdate_gadgets. 
  srh 06/20/91    Override EMreport_defaults/EMreport/EMupdate
  Tapadia 07/15/91 Override EMdim & EMdimparam
  Tapadia 09/16/92 Implementation of selective boolean for holes
*/

class specification EMSslboolfea (1:0) of EMSslboolean, EMSsfboolfea;

#ifndef EMSfeadef_include
#include  "EMSfeadef.h"	
#endif

/*------------------ INSTANCE DATA SECTION -------------------*/

override  
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMpunch_hole
(
  IGRlong *EMmsg;
  IGRushort hole_type;
  IGRushort *depth_type;
  struct GRlc_info *surf_info;
  IGRdouble *v_angle;
  struct GRvg_construct *construct_list;
  IGRint num_holes;
  struct EMShole *holes;
  struct GRid *active_GRid;
);

message EMpunch_counterpart
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRint part_type;
  IGRboolean axis_normal;
  IGRboolean through_hole;
  IGRdouble *bottom_ang;
  struct GRlc_info *surf0_info;
  IGRint num_parts;
  struct part_data *parts;
  IGRdouble *angle_or_depth;
  IGRdouble *drill_radius;
  IGRdouble *hole_radius;
  struct GRid *solid_id;
);

message EMmake_part
(
  IGRlong *EMmsg;
  IGRint *part_type;
  IGRdouble *center;
  IGRboolean *through_hole;
  IGRdouble *bottom_ang;
  GRspacenum *osnum;
  struct part_data *part;
  struct GRvg_construct *construct_list;
  IGRdouble *angle_or_depth;
  IGRdouble *drill_radius;
  IGRdouble *hole_radius;
);

message EMhole_sel_boolean
(
  IGRlong *EMmsg;
  IGRushort hole_type;
  IGRushort *depth_type;
  struct GRlc_info *surf_info;
  IGRdouble *v_angle;
  struct GRvg_construct *construct_list;
  IGRint num_holes;
  struct EMShole *holes;
  struct GRid *active_GRid;
);

from EMSslboolean inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

override 
  EMoffset,
  EMconstruct_associative, 
  EMgetInGeomIds,
  EMdeactivate,
  EMdim,
  EMdimparam,
  EMpattern_copy;

#endif

end specification EMSslboolfea;


