class specification NMcreated (1:0) of GRnotify;


#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "go.h"
#include "igrdef.h"
#include "ex.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "nmdef.h"
#include "nmchandef.h"
#include "OMminimum.h"
#include "OMerrordef.h"


instance NMcreated
{
 OM_S_OBJID creator_id;
};

message NMget_put_creator_id(IGRlong *EMmsg;
                             GRobjid *creator_id;
                             IGRboolean put_it);


override GRmksource;

end specification NMcreated;
