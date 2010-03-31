/*
  DESCRIPTION

    This class of objects implement the ground constraint for graphic points.
    This class allows their use within the SKmgr-system as read-only variables.
*/

class specification SKasptgrnd (2:0) of NDnodein, SKground;

#include "nddef.h"
#include "asbox.h"
#include "dimsrc.h"

instance SKasptgrnd
{
  IGRchar asptinx;
};

#ifndef BASE_EMS
message SKinit_assocpt_ground (IGRlong *msg; IGRushort options;
                               struct GRmd_env *md_env;
                               struct GRid *assoc_src; IGRint point_inx;
                               GRobjid mgrobj;
                               IGRchar *moreinfo;
                               GRobjid *vgpt);
       
override
  debug,
  GRdelete, GRgetobjinfo,
/*
 * This override returns itself to be point_generic.
 */
  NDgive_structure,
  NDupdate, NDget_objects;

/*
 * The following graph copy related overrides have been provided and
 * do nothing but return success. We do this since manager is the god and 
 * he does everything.
 * pp 08/16/91
 */
 
override 
 NDcompute_node, /* Calls NDupdate internally */
 NDcopy,
 NDcopy_to_root,
 NDcopy_graph,
 ACcopy_to_Groot,
 NDdisplay,
 ASreturn_go,
 /*
  * NDmove_to_root will delete the underlying SKptvar and 
  * all the associated constraints.  Happens when the parent ASsource
  * gets deleted.  - Rajiv  9/1/93
  */
 NDmove_to_root,
 SKevaluate;
#endif
 
end specification SKasptgrnd;
