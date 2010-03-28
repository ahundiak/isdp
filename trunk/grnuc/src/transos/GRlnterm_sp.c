
/* - special conversion routine GRlnterm$GRlnterm - */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "ex.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "OMport.h"

struct GRlnterm_instance
{
    struct GRevent   attach_event;
    IGRshort         end_of_curve;
    OM_p_CHANNEL_HDR to_notify;
};


GRlnterm$GRlnterm(classid, ME, me)
short classid;
char *ME;
struct GRlnterm_instance *me;
{
    int                sts, response_type;
    struct EX_button  *button;

    response_type = om$integer_value(&me->attach_event.response);

    switch (response_type)
    {
        case EX_DATA:
	case EX_OBJID:

	    button = &me->attach_event.event.button;
            sts = om$conv_double(&button->x, 1);
            sts = om$conv_double(&button->y, 1);
            sts = om$conv_double(&button->z, 1);
            sts = om$conv_int(&button->window, 1);
            sts = om$conv_int(&button->objid, 1);
            sts = om$conv_short(&button->osnum, 1);
            sts = om$conv_short(&button->numb, 1);
            sts = om$conv_short(&button->clicks, 1);
            sts = om$conv_short(&button->button_down, 1);
            break;

        case EX_STRING:  /* don't need to do anything since this indicates */
	case EX_CHAR:    /* an array of characters */
            break;

        case EX_VALUE:
            sts = om$conv_double(&me->attach_event.event.value, 1);
            break;

        default:  /* other types don't put anything in event struct */
            break;
    }
    return(1);
}
