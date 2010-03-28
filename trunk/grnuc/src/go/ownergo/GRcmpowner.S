/*
  ABSTRACT

  This class consists of entities  which associate or relate other
  graphic objects.  This class implies that the subclasses share a 
  common channel which relates the owner object to one or more other
  graphics objects which are a subclass of GRconnector.  There are no
  other implications about the representation of the owners subclassed
  under this class.


  HISTORY

  Gray Winn   08/31/87    Design and Coding Date.
*/

class specification GRcmpowner (1:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "igrdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "dpstruct.h"
#include "lc.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRcmpowner
{
   channel
   {
      (many_to_many,
       rel_ordered,
       initial=1,
       increment=2)
      GRconnector.to_owners;
    } to_components;    
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message GRlocate_owner
(
  IGRlong *msg;
  struct GRlc_cvl *cvl;
  struct GRlc_path *path;
  IGRint *path_position;
);

message GRownaddwrng
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  GRobjid *objid;
  GRrange range;
);

message GRownremwrng
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  GRobjid *objid;
  GRrange range;
);

message GRcomponent_disconnecting
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRid *comp_id;
);

message GRrigid_connecting
(
  IGRlong *msg;
  struct GRid *go_id;
);

message GRcomponent_idchanged
(
  IGRlong *msg;
  IGRshort *num_comp_ids;
  struct GRid *comp_ids;
);

override 
  unknown;    

#endif

end specification GRcmpowner;
