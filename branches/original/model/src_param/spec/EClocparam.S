/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This command object locates the parameters of parametric/associative
    objects. The parameters located are geometric parameters:
    1) Parametric Points
    2) Parametric Vectors
    3) Parametric Planes
    4) Graphic objects

    The locate can be limited to only certain types of parameters
    and parameter characteristics.
    
    A message is provided that goes through the following steps to locate
    the parameter. User interface control is communicated via the arguments
    in this message:
    a) "Identify parametric element" 
       The user issues a data point or inputs a name to locate the object.
       The object highlights at the same time displaying the parameters
    b) "Accept with data point near parameter"
       The user issues a data point near the highlighted parameter.
    c) The accept data point is converted to a boreline and a geometric
       check performed against all the applicable parameters. If an
       unambiguos decision can be reached the parameter object is returned
       without further ado. In the case of ambiguity, all the possible
       parametric objects are gone through an accept/reject cycle.

  HISTORY

    SS  :  04/02/91  :  Creation
*/

class specification EClocparam (2:0) of ECelements;

instance EClocparam
  {
  IGRint paramtype;
  struct GRid paramobj;

  IGRint state;
  };

override
  execute,
  get_locate_criteria;

message locate_param (IGRlong *msg; IGRushort options;
                      IGRushort param_types;
                      enum EMSuser_responses *useract;
                      IGRint *response; IGRchar *response_data;
                      struct GRid *paramobj; struct GRevent *paramevent);

end specification EClocparam;

