/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "lcdef.h"

LCcheck_action (msg, action_handler)
IGRlong *msg;
IGRint  *action_handler;
{
    IGRint ret_code;
    IGRint LCptlocact(), LCaccact(), LCevaction();
    
    
    *msg = MSSUCC;
    ret_code = 1;

    if (action_handler == (IGRint *)(IGRint)LCptlocact) {
        *msg = LC_PTBL_ACTION;
        ret_code = 0;
    }
    else if (action_handler == (IGRint *)(IGRint)LCaccact) {
        *msg = LC_ACCEPT_ONE_ACTION;
        ret_code = 0;
    }
    else if (action_handler == (IGRint *)(IGRint)LCevaction) {
        *msg = LC_EVENT_ACTION;
        ret_code = 0;
    }
    return (ret_code);
}
