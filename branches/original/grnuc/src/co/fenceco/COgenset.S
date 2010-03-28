/*
Name
        COgenset

Description
        This class is used to implement the Generate Set form.

History
        mrm     05/06/91    creation
*/

class specification COgenset(2:0) of super_cmd;

#include <FI.h>
#include "exdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grpgendef.h"

instance COgenset
{
    variable struct GRevent event[1];
    variable Form form[0];
    IGRchar *form_data;
    IGRuchar color_bitmask[COLOR_MASK_SIZE];
    IGRuchar style_bitmask[STYLE_MASK_SIZE];
    IGRuchar weight_bitmask[WEIGHT_MASK_SIZE];
    IGRint symb, symb_set;
    IGRint obj_count, mod_count;
    OM_S_OBJID top_gs, current_gs;
    OMuword top_os, current_os;
    struct GRmd_env top_mod;
};

override init, wakeup, execute, sleep;

end specification COgenset;

