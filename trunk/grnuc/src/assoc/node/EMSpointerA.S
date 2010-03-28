/*
  DESCRIPTION

  This is an abstract class which provides for message declarations
  for supporting indirection to components of surfaces/solids/DPR 
  elements. 


  HISTORY

  Moved this from EMS to GRNUC: PP : 06/09/92
  Creation                    : PP : 06/11/91 
*/

class specification EMSpointerA (2:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMstore_key_from_id
(
  IGRlong *EMmsg;
  IGRuint options;
  unsigned char *key;
);

message EMstore_id_from_key
(
  IGRlong *EMmsg;
  IGRuint options;
  OM_S_OBJID *objid;
);

message EMstore_id
(
  IGRlong *EMmsg;
  IGRuint options;
  OM_S_OBJID store_objid;
);

override
  EMstore_key_from_id, 
  EMstore_id_from_key, 
  EMstore_id;          

#endif

end specification EMSpointerA;
