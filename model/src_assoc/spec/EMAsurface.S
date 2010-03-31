/*
  DESCRIPTION

  This class provides for
  a) common functionality with regards to implementation of 
     associativity in EMS for all associative surfaces.
  b) common message declarations for supporting associativity.

  This is an abstract class.


  HISTORY

  Creation               : PP : 03/02/91
  Subclass from EMSdim   : jhw : 08/14/91
*/

class specification EMAsurface (2:0) of EMSdim,EMSsurface;

#include "EMSasdef.h"
#include "EMSas.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMcopy_recomp_info
(
  IGRlong *EMmsg;
  struct GRmd_env *obj_mdenv;
  struct GRmd_env *new_mdenv;
  GRobjid newobjid;
  struct EMcp_info *copy_info;
  IGRushort bdry_options;
  IGRushort sf_options;
);

message EMpreprocess_delete
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
);

from EMSassoc inherit 
  GRdelete, GRxform;

override 
  NDupdate,
  NDcopy_graph,
  NDdelete, 
  ACcopy_to_Groot,
  NDcopy_to_root,
  NDselect_copy,
  NDget_objects,
  ACbecome_macro,
  NDdisplay,
  EMastore;

#endif

end specification EMAsurface;
