/*
  DESCRIPTION

  Class used to implement "feature suppression"


  HISTORY

  Probably PP long ago.
*/

class specification EMSsuppress (1:0) of NDnodein, GRowner;

#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMStypedef.h"
#include "emsdef.h"
#include "EMSprop.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsuppress
{
  OMbyte props;
};

not_taggable;

override 
  NDchildren;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message EMgetProps
(
  IGRlong *EMmsg;
  OMuword *props;
);

#ifndef BASE_EMS

message EMsetProps
(
  IGRlong *EMmsg;
  IGRboolean clear;
  OMuword props;
);

message EMmove_comps
(
  IGRlong *EMmsg;
  GRobjid dpr;
  IGRboolean to_suppress;
  IGRint num_comps;
  GRobjid *comps;
  OMuword options;
);

message EMget_suppress_id
(
  IGRlong *EMmsg;
  GRobjid *suppress_id;
  OMuword options;
);

message EMget_suppressed_geom
(
  IGRlong *EMmsg;
  IGRint *num_suppressed_geom_ids;
  GRobjid **suppressed_geom_ids;
  OMuword options;
);

override
  NDcompute_node,
  NDmove_to_root,
  debug,
  NDget_objects,        
  NDmove_to_tmp_clone;  

#endif

end specification EMSsuppress;
