#include "igrtypedef.h"
#include "msdef.h"
#include "msmacros.h"

extern IGRshort           MS_Gs_messages_on;

#if defined( __STDC__ )
void MSon ( IGRlong  *msg, IGRshort *previous_state )
#else
void MSon (msg, previous_state)
IGRlong  *msg;
IGRshort *previous_state;
#endif
{
    *msg = MSSUCC;
    *previous_state = MS_Gs_messages_on;
    MS_Gs_messages_on = 1;
}

#if defined( __STDC__ )
void MSoff ( IGRlong  *msg, IGRboolean *previous_state )
#else
void MSoff (msg, previous_state)
IGRlong  *msg;
IGRboolean *previous_state;
#endif
{
    *msg = MSSUCC;
    *previous_state = MS_Gs_messages_on;
    MS_Gs_messages_on = 0;
}

#if defined( __STDC__ )
void MSset ( IGRlong *msg, IGRshort new_state, IGRshort *previous_state )
#else
void MSset (msg, new_state, previous_state)
IGRlong *msg;
IGRshort new_state;
IGRshort *previous_state;
#endif
{
    *msg = MSSUCC;
    *previous_state = MS_Gs_messages_on;
    MS_Gs_messages_on = new_state;
}

#if defined( __STDC__ )
int MS_onoff ( IGRlong *msg, IGRshort *previous_state, IGRshort new_state,
               IGRint type )
#else
int MS_onoff (msg, previous_state, new_state, type)
IGRlong *msg;
IGRshort *previous_state;
IGRshort new_state;
IGRint type;
#endif
{
    if (type == MS_ON) {
    	MSon (msg, previous_state);
    }
    else if (type == MS_OFF) {
    	MSoff (msg, previous_state);
    }
    else if (type == MS_SET && new_state != MS_NO_STATE) {
    	MSset (msg, new_state, previous_state);
    }
    else {
    	*msg = MSFAIL;
    	return (0);
    }
    return (1);
}
