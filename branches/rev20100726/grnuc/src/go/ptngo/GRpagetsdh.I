/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        GRpagetsdh

Description
            This function retrieves the id and osnum of the symbol definition
        header stored on the LCcmd_iso on the input channel.  It also returns
        the classname of the object to construct using the symbol definition,
        e.g. "GRsmhdr", and the range of the symbol definition in its
        local coordinate system.

Synopsis
        IGRint GRpagetsdh (msg, caller, to_sdh, module, sdh, sdh_range,
                           classname)

        IGRlong             *msg;           return code
        GRobjid             *caller;        calling object's id
        OM_S_CHANSELECT     *to_sdh;        channel to sdh defining pattern
        struct GRmd_env     *module;        patterning module information
        struct GRid         *sdh;           sdh's objid & osnum
        IGRdouble           *sdh_range;     sdh's range
        IGRchar             *classname;     to construct

Return Codes
        IGRint ()       OM_S_SUCCESS if successful
        IGRlong msg     MSSUCC if successful

History
        mrm     11/25/87    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lcmacros.h"

IGRint GRpagetsdh (msg, caller, to_sdh, module, sdh, sdh_range, classname)

IGRlong             *msg;           /* return code */
GRobjid             *caller;        /* calling object's id */
OM_S_CHANSELECT     *to_sdh;        /* channel to sdh defining pattern */
struct GRmd_env     *module;        /* patterning module information */
struct GRid         *sdh;           /* sdh's objid & osnum */
IGRdouble           *sdh_range;     /* sdh's range */
IGRchar             *classname;     /* to construct */

{
    IGRchar                 dbtype[MAX_DB_TYPE_SIZE];   /* from dpb */
    IGRlong                 size;           /* size variable */
    IGRboolean              world;          /* flag for getrang */
    IGRlong                 count;          /* of objects on channel */
    IGRlong                 sts;            /* return code */
    OM_S_OBJECT_LINKAGE     obj_link;       /* to get symbol id off channel */

    sts = OM_S_SUCCESS;

    /*
     *  get the class name to construct
     */

    size = MAX_DB_TYPE_SIZE;

    sts = gr$get_database_type (msg = msg,
                                sizbuf = &size,
                                buffer = dbtype,
                                nret = &size);

    if ((sts & *msg & 1))
    {
        if (!strcmp (dbtype, "3d"))
        {
            sprintf (classname, "GRsmhdr");     /* 3d symbol */
        }
        else
        {
            sprintf (classname, "GR%ssmhdr", dbtype);
        }

        /*
         *  get the symbol from the iso
         */

        sts = lc$get_channel_objects (objid = *caller,
                                      p_chanselect = to_sdh,
                                      list = &obj_link,
                                      size = 1,
                                      count = &count);

        if ((sts & 1) && (count))
        {
            sdh->objid = obj_link.S_objid;
            sdh->osnum = obj_link.osnum;
            world = FALSE;

            sts = om$send (msg = message GRgraphics.GRgetrang
                                (msg, &module->md_env.matrix_type,
                                 module->md_env.matrix, &world,
                                 sdh_range),
                           senderid = *caller,
                           targetid = sdh->objid,
                           targetos = sdh->osnum);
        }
    }
            
    return (sts);
}

end implementation GRpa;
