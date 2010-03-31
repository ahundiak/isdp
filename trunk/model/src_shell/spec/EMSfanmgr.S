/* ###################   APOGEE COMPILED   ################## */
class specification EMSfanmgr (1:2) of EMSobjmgr;

#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"

/*
Abstract
  This class represents fan manager manager object.
  It simultaes 1:m channel relationship.

History

  RC    08/17/88      Creation date
*/


instance EMSfanmgr
{
  IGRint           num_tips;
  IGRint           num_fans;
  variable IGRint  tips_p_fan[];
  variable GRobjid fans[];
  variable GRobjid tips[];
};

message EMputentry (IGRlong *msg; IGRushort option; 
                    struct EMSfnmgr_info *put_info);

message EMgetentry (IGRlong *msg; IGRushort option;
                    struct EMSfnmgr_info *get_info);

message EMdelentry (IGRlong *msg; IGRushort option;
                    struct EMSfnmgr_info *del_info);

message EMrplentry (IGRlong *msg; IGRushort option;
                    struct EMSfnmgr_info *org_info, *rpl_info);

override
 EMinit,
 EMwakeup, 
 EMsleep,
 debug;

end specification EMSfanmgr;
