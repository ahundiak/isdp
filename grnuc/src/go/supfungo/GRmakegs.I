/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRmake_graphic_set

Description
        This function will create a graphic set containing the
        specified objects.

History
        mrm     04/03/91    creation
*/

class implementation GRgrset;

#include "grgsdef.h"
#include "grgsmacros.h"

#if DEBUG
#include <stdio.h>
#define CHECK_ERROR(sts,msg,errmsg) \
        if (!(sts & msg & 1)) \
        { \
            fprintf(stderr,"%s: %#x, %#x\n", errmsg, sts, msg); \
            goto finish; \
        }
#else
#define CHECK_ERROR(sts,msg,errmsg)  if (!(sts & msg & 1)) goto finish
#endif

IGRlong GRmake_graphic_set(msg, nobjs, objs, osnum, grset)
IGRlong *msg;           /* < return code */
IGRint nobjs;           /* > number of objects to add to the set */
struct GRlc_info *objs; /* > objects to add to the set */
OMuword osnum;          /* > space in which to construct the graphic set */
struct GRid *grset;     /* < graphic set containing objects */
{
    IGRint i, sts = OM_S_SUCCESS, props = GRIS_DISPLAY_ALL;

    /* create a graphic set object */

    sts = gr$gsinit(msg = msg,
                    senderid = NULL_OBJID,
                    senderos = osnum,
                    osnum = (grset->osnum = osnum),
                    flag = 3,   /* GRgrset */
		    p_objid = &grset->objid);

    CHECK_ERROR(sts, *msg, "gr$gsinit");

    /* loop through the list */

    for (i = 0; i < nobjs; i++)
    {
        /* add the object to the graphic set */

        sts = om$send(msg = message GRgrset.GSobject_add
                           (msg, &objs[i].located_obj, &objs[i].module_info,
                            &props, grset, NULL),
                      senderid = NULL_OBJID,
                      targetid = grset->objid,
                      targetos = grset->osnum);

        CHECK_ERROR(sts, *msg, "GRgrset.GSobject_add");
    }

finish:

    return (sts);
}

end implementation GRgrset;
