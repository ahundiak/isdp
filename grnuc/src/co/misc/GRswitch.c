/*
Name
        GRget_switchprod_state
        GRset_switchprod_state

Description
        This file contains functions to allow applications to determine
        whether switchprod is running.  This makes a difference in how license
        request failures are handled.  The flag is set in switchprod, and
        cleared in checkswitch.

History
        mrm     12/11/92    creation
*/

#define FALSE   0

static int GRswitchprod_state = FALSE;

int GRget_switchprod_state()
{
    return(GRswitchprod_state);
}

void GRset_switchprod_state(state)
int state;
{
    GRswitchprod_state = state;
}
