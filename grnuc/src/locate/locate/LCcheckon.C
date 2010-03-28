/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"


static IGRint   LC_Gi_check_class = 1;
static IGRint   LC_Gi_check_layer = 1;

LCclass_check_off ()
{
    LC_Gi_check_class = 0;
}

LCclass_check_on ()
{
    LC_Gi_check_class = 1;
}

LCget_class_check ()
{
    return (LC_Gi_check_class);
}


LClayer_check_off ()
{
    LC_Gi_check_layer = 0;
}

LClayer_check_on ()
{
    LC_Gi_check_layer = 1;
}

LCget_layer_check ()
{
    return (LC_Gi_check_layer);
}

LC_criteria_off ()
{
    LCclass_check_off ();
    LClayer_check_off ();
    return (1);
}

LC_criteria_on ()
{
    LCclass_check_on ();
    LClayer_check_on ();
    return (1);
}

