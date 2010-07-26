/* #######################    APOGEE COMPILED   ######################## */

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"

GRbuildbuf(buffer,md_env,pass_on,info)

struct GRfunction_info *buffer;
struct GRmd_env *md_env;
IGRshort	pass_on;
IGRchar		*info;

{
    buffer->md_env = md_env;
    buffer->pass_to_other_spaces = pass_on;
    buffer->info = info;

    return(1);
}

