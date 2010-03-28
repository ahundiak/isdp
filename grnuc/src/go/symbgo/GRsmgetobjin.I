/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRsmhdr.GRgetobjinfo

Description
        This method reports information about the object.

        IGRlong *msg        completion code
        GRobj_info *info    structure for information about the object

Return Values
        MSSUCC - successful completion

History
        HGW     09/10/86    Design date.
        HGW     11/06/87    Changes for version 1.1
        mrm     03/20/89    prevent memory overwriting
*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "vardef.h"
#include "gocmacros.h"
#include "msmacros.h"
#include "grmessage.h"

#define BUFFER_LENGTH   30      /* length of the objinfo type array */

from GRsymbol import GRset_inq_symbol;

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    IGRchar             symbol_name[MAX_SYMBOL_DEF_NAME];
    IGRchar             *c;
    IGRlong              size;
    OM_S_CHANSELECT     to_comp;
    struct GRvar_list   list[2];

    *msg = MSSUCC;

    om$make_chanselect (channame = "GRcmpowner.to_components",
                        p_chanselect = &to_comp);

    list[0].var = GR_SYMBOL_NAME;
    list[0].var_ptr = symbol_name;
    list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
    list[0].bytes_returned = &size;

    list[1].var = END_PARAM;
    list[1].var_ptr = NULL;
    list[1].num_bytes = NULL;
    list[1].bytes_returned = NULL;

    om$send (msg = message GRsymbol.GRset_inq_symbol (msg, 0, list),
             p_chanselect = &to_comp);

    ex$message (msgnumb = GR_I_symbol, buff = info->type);
    size = strlen (info->type);
    c = &info->type[size];
    strncpy (c, symbol_name, BUFFER_LENGTH - size);
    info->type[BUFFER_LENGTH - 1] = NULL;

    *msg = MSSUCC;
    return(OM_S_SUCCESS);
}
end implementation GRsmhdr;
