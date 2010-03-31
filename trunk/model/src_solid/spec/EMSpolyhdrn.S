/*
  ABSTRACT

  This class represents a solid poyhedron.

 
  HISTORY

  jhw 06/12/91    Added EMdim and EMdimparam.
  msm 06/03/91    Override GRreport, GRreport_defaults, GRupdate_gadgets.
                  Removed Override GRloadform and GRgetsfsize.
  jhw 04/10/91    Added EMconstruct_associative override.
  PP  07/12/88    Removed override for debug
  dhm 05/16/88    Overrode GRgetsfsize and GRloadform.
  JBK 13-May-1987 Added EMget_vertices message
  AIC 12/28/86    Creation date
  PP  03/18/87    Changed message declarations due to changes
                  in the class structure of solids
*/

class specification EMSpolyhdrn (2:0) of EMSsolid;

#include "REpolyhdrn.h"

#define MAX_NO_OF_VERTICES_ON_FACE 4
#define MAX_NO_VERTICES  10

#define RECTANGULAR_PLANE 0
#define TRIANGLE 1
#define ORDER_2_SURF 2

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMget_vertices
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRint array_size;
  IGRint *no_of_vertices;
  IGRpoint *vertices;
);
 
message EMcnsplyhdrn
(
  IGRlong *EMmsg;
  IGRshort no_of_faces;
  IGRshort no_of_edges;
  IGRshort no_of_vertices;
  IGRpoint *vertices;
  IGRint *option;
  IGRshort faces[][5];
  IGRushort natural_edprops[][4];
  IGRuchar natural_curve_type[][4];
  IGRushort connectivity[][5];
  struct GRvg_construct *construct_list;
);

message EMcvx6f8v
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint *pts;
);

message EMcvx6f7v
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint *pts;
);

message EMcvx5f6v
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint *pts;
);

message EMcvx5f5v
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint *pts;
);

message EMcvx4f4v
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  IGRpoint pts[8];
);


override
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets,
  EMconstruct_associative,
  EMdim,
  EMdimparam;

#endif

end specification EMSpolyhdrn;
