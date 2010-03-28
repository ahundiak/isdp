/*
  DESCRIPTION

  This class is subclassed from OMrtree to add a channel linkage to
  connect the range tree object to the module object.  Other than that,
  it will behave identically to the OMrtree object.


  HISTORY

  rc      01/10/86    design date
  mrm     02/24/92    override debug
  spr     06/15/93    added display_pass and skew_display_pass for
                      display lists
*/

class specification GRrtree (1:0) of OMrtree;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "OMerrordef.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

channel obj_to_owner
{
    (many_to_one)
};

instance GRrtree
{
    channel obj_to_owner rtree_owner;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message GRrtconn
(
  IGRlong *rc;
  struct GRid *md_id;
  IGRushort *mdchan;
);

message display_pass
(
  OM_p_MESSAGE msg;
  OM_p_KEY_DESC p_select_key;
  OM_p_CLASSLIST classlist;
  OM_p_KEY_DESC p_target_key;
  int (*user_compare)();
  int *ret;
);

message skew_display_pass
(
  OM_p_MESSAGE msg;
  OM_p_SKEW_DESC p_key;
  OM_p_KEY_DESC p_target_key;
  OM_p_CLASSLIST classlist;
  int (*user_compare)();
  int *ret;
);

override 
  debug;

#endif

end specification GRrtree;

