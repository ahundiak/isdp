class specification COlocelig (1:0) of CEO;



#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"


instance COlocelig
{
    variable struct GRelclass_f elclass[];
};


override init;

override form_notification;

end specification COlocelig;
