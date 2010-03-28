/*
    Abstract:  This command object gives users the ability to edit unit of
               measure types via a form driven interface

    History:
       elp            02/04/92            copied FEM's version and modified
 */

class specification COedtuom (2:0) of super_cmd;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

instance COedtuom
  {
  struct GRid md_id;
  int sts;
  };

override init, wakeup, execute, sleep, delete;

message set_state( short state );
message get_state( short *state );

end specification COedtuom;
