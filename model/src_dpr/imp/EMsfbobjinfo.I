class implementation EMSsfboolean;

#include "EMS.h"
# include "msdef.h"
# include "msmacros.h"
# include "ECmsg.h"

extern OMuword OPP_EMSslboolean_class_id;

method GRgetobjinfo(IGRlong *EMmsg; struct GRobj_info *info)
{
    IGRchar buffer[MS_MAX_MSG_LENGTH+1];
    EMSrc omrc;
    IGRlong msgNumber;

    omrc = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            EMmsg,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            &msgNumber
        ),
        targetid = my_id
    );

    if (EMSokay (omrc) AND EMSokay (*EMmsg))
    {
        *EMmsg = EMS_S_Success;
        omrc = OM_S_SUCCESS;

        ex$message (
            msgnumb = msgNumber,
            buffer_size = 30,
            buff = buffer
        );

      if(EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS, 
         OPP_EMSslboolean_class_id, FALSE))
        ex$message (
            msgnumb = EMS_I_SolidAsAdjSomething,
            type = "%s",
            var = buffer,
            buffer_size = 30,
            buff = info->type
        )
      else
        ex$message (
            msgnumb = EMS_I_SurfaceAsAdjSomething,
            type = "%s",
            var = buffer,
            buffer_size = 30,
            buff = info->type
        )
    }
    else
    {
        *EMmsg = EMS_E_Fail;
        omrc = OM_E_ABORT;
    }

    return omrc;
}

end implementation EMSsfboolean;
