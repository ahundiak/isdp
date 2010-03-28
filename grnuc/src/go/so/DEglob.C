#include <tools.h>
#include "OMminimum.h"

OM_S_OBJID      *DEsos = NULL;                /* list of valid soos        */
OM_S_OBJID      DElocked_views [MAX_WINDOW];  /* views ignoring  overrides */
OM_S_CHANSELECT DEso_to_windows_chanselect,   /* channel to windows        */
                IGEgragad_winsup_chanselect,  /* window's channel          */
                GRcontext_to_misc_chanselect, /* channel to contexts       */
                DEso_to_contexts_chanselect;  /* channel to contexts       */


