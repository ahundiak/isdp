/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
/*
HISTORY

    21 Aug     92   NP      Modofied for ANSI compliance.
    13 July    88   RC      Changed Root.connect to GRnotify.GRntfyconn
                            in EMputDescription implementation.
    28 October 87   AIC     Conversion to EMS version 1.1

    30-Sep-1987 jBk Creation.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

# if DEBUG
# include <stdio.h>
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

from EMSname import EMputDescription, EMgetDescription, EMlenDescription;

method EMputDescription (EMSrc *rc; char description[])
{
    OM_S_CHANSELECT assoChan;
    EMSrc om_msg;

#   if DEBUG
    (void)fprintf (stderr, "EMsfDesc.I put:  %s\n",
        description IS NULL ? "NULL" : description);
#   endif

    assoChan.type = OM_e_addr;
    assoChan.u_sel.addr = &me^^GRnotify.notification;

    *rc = EMS_I_NoResponse;

    om_msg = om$send (
        msg = message EMSname.EMputDescription (rc, description),
        p_chanselect = &assoChan
    );

#   if DEBUG
    (void)EFmsgReport (stderr, om_msg, "EMsfDesc.I 1 put");
#   endif

    if (*rc IS EMS_I_NoResponse)
    {
        OM_S_OBJID newId;

        om_msg = om$construct (
            classname = "EMSname",
            p_objid = &newId,
            msg = message EMSname.EMputDescription (rc, description)
        );

        if (EMSokay (om_msg))
        {
            OM_S_CHANSELECT descChan;
            struct GRid name_GRid;
	    IGRint lis_index = 0;
            IGRboolean tag = FALSE;

            descChan.type = OM_e_name;
            descChan.u_sel.name = "EMSname.to_described";
            name_GRid.objid = newId;
            name_GRid.osnum = OM_Gw_current_OS;

            om_msg = om$send (
                msg = message GRnotify.GRntfyconn ((IGRlong *)rc, &name_GRid,
			&descChan, &lis_index, &tag, &OM_Gw_current_OS),  
                targetid = my_id);

            if (!(1 & om_msg & *rc) )
            {
                (void)om$send (
                    msg = message Root.delete (FALSE),
                    targetid = newId
                );
            }
        }
    }

#   if DEBUG
    {
        EMSrc rc2;
        char desc2[BUFSIZ];
        int len;

        om$send (
            msg = message EMSname.EMlenDescription (&rc2, &len),
            p_chanselect = &assoChan
        );
        om$send (
            msg = message EMSname.EMgetDescription (&rc2, desc2, 0),
            p_chanselect = &assoChan
        );

        (void)fprintf (stderr, "EMsfDesc.I put:  %d %s\n",
            len, desc2);
    }
#   endif

    *rc = om_msg;
    return om_msg;
}

method EMgetDescription (EMSrc *rc; char description[]; int len)
{
    EMSrc om_msg;

    if (len >= 0)
    {
        OM_S_CHANSELECT assoChan;

        assoChan.type = OM_e_addr;
        assoChan.u_sel.addr = &me^^GRnotify.notification;

        *rc = EMS_I_NoResponse;

        om_msg = om$send (
            msg = message EMSname.EMgetDescription
                (rc, description, len),
            p_chanselect = &assoChan
        );

        if (om_msg IS OM_W_UNKNOWN_MSG)
        {
            om_msg = OM_S_SUCCESS;
        }

        if (*rc IS EMS_I_NoResponse)
        {
            description[0] = '\0';
        }
    }
    else /* (len < 0) */
    {
        om_msg = OM_E_INVARG;
    }

    *rc = om_msg;
    return om_msg;
}

method EMlenDescription (EMSrc *rc; int *len)
{
    OM_S_CHANSELECT assoChan;
    EMSrc om_msg;

    assoChan.type = OM_e_addr;
    assoChan.u_sel.addr = &me^^GRnotify.notification;

    *rc = EMS_I_NoResponse;

    om_msg = om$send (
        msg = message EMSname.EMlenDescription
            (rc, len),
        p_chanselect = &assoChan
    );

    if (om_msg IS OM_W_UNKNOWN_MSG)
    {
        om_msg = OM_S_SUCCESS;
    }

    if (*rc IS EMS_I_NoResponse)
    {
        *len = 0;
    }

    *rc = om_msg;
    return om_msg;
}

end implementation EMSsurface;
